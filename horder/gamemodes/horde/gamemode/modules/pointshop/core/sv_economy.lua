if not SERVER then return end

local PS = HORDE.Pointshop
local C  = PS.Config
local DB = HORDE.DB

local function SteamKey(ply)
    if not IsValid(ply) or ply:IsBot() then return nil end
    return ply:SteamID()
end

---------------------------------------------------------------------------
-- Economy settings (ADMIN > ECONOMY)
-- Stored in horde_redux_meta 'pointshop_settings' as { [config key] = value };
-- saved values override sh_config.lua. Every client gets them through Horde_PS_Config.
---------------------------------------------------------------------------

local SETTINGS = {
    PlaytimeEnabled  = { kind = "bool" },
    PlaytimeAmount   = { kind = "int", min = 0, max = 1000000 },
    PlaytimeInterval = { kind = "int", min = 1, max = 1440 },
    PlaytimeAFKTime  = { kind = "int", min = 0, max = 86400 },
    SellPercent      = { kind = "int", min = 0, max = 100 },
    InventorySlots   = { kind = "int", min = 1, max = PS.MAX_SLOTS },
    CasinoEnabled    = { kind = "bool" },
    CasinoMinBet     = { kind = "int", min = 1, max = PS.MAX_PRICE },
    CasinoMaxBet     = { kind = "int", min = 1, max = PS.MAX_PRICE },
}
PS.EconomySettings = SETTINGS

local function Clean(key, value)
    local def = SETTINGS[key]
    if not def then return nil end
    if def.kind == "bool" then
        if isbool(value) then return value end
        return nil
    end
    value = tonumber(value)
    if not value or value ~= value then return nil end
    return math.Clamp(math.floor(value), def.min, def.max)
end

local function FixBetLimits()
    C.CasinoMinBet = Clean("CasinoMinBet", C.CasinoMinBet) or 10
    C.CasinoMaxBet = math.max(C.CasinoMinBet, Clean("CasinoMaxBet", C.CasinoMaxBet) or C.CasinoMinBet)
    C.InventorySlots = PS:SlotCount()
end

function PS:LoadEconomySettings()
    if not self:EnsureTables() then return end
    local json = DB.QueryValue("SELECT value FROM horde_redux_meta WHERE key = 'pointshop_settings';")
    local t = json and util.JSONToTable(json)
    if istable(t) then
        for key in pairs(SETTINGS) do
            local v = Clean(key, t[key])
            if v ~= nil then C[key] = v end
        end
    end
    FixBetLimits()
end

function PS:SaveEconomySettings()
    if not self:EnsureTables() then return end
    local t = {}
    for key in pairs(SETTINGS) do t[key] = C[key] end
    DB.Query(DB.Prepare([[
        INSERT INTO horde_redux_meta (key, value) VALUES ('pointshop_settings', ?)
        ON CONFLICT(key) DO UPDATE SET value = excluded.value;
    ]], util.TableToJSON(t)))
end

function PS:SendConfig(target)
    local t = {}
    for key in pairs(SETTINGS) do t[key] = C[key] end
    net.Start("Horde_PS_Config")
    self:WriteTable(t)
    if target then net.Send(target) else net.Broadcast() end
end

function PS.AdminActions.economy_save(ply, data)
    for key in pairs(SETTINGS) do
        local v = Clean(key, data[key])
        if v ~= nil then C[key] = v end
    end
    FixBetLimits()
    PS:SaveEconomySettings()
    PS:SendConfig()
    return true, "ok.settings_saved"
end

---------------------------------------------------------------------------
-- Playtime reward
---------------------------------------------------------------------------

local PLAYTIME_TICK = 10

hook.Add("KeyPress", "Horde_PS_Activity", function(ply)
    ply.Horde_PS_Active = CurTime()
end)

hook.Add("PlayerInitialSpawn", "Horde_PS_Activity", function(ply)
    ply.Horde_PS_Active = CurTime()
end)

timer.Create("Horde_PS_Playtime", PLAYTIME_TICK, 0, function()
    if not C.PlaytimeEnabled then return end
    local amount = math.floor(tonumber(C.PlaytimeAmount) or 0)
    local interval = math.max(1, math.floor(tonumber(C.PlaytimeInterval) or 10)) * 60
    if amount <= 0 then return end
    local afk = math.floor(tonumber(C.PlaytimeAFKTime) or 0)
    local now = CurTime()

    for _, ply in ipairs(player.GetHumans()) do
        local d = ply.Horde_PS
        local active = afk <= 0 or now - (ply.Horde_PS_Active or 0) <= afk
        if d and d.loaded and active then
            d.playtime = (d.playtime or 0) + PLAYTIME_TICK
            if d.playtime >= interval then
                d.playtime = d.playtime - interval
                PS:AddSkulls(ply, amount)
                PS:Notify(ply, "n.playtime", { PS:FormatNumber(amount), math.floor(interval / 60) })
                hook.Run("Horde_PS_PlaytimeReward", ply, amount)
            end
        end
    end
end)

---------------------------------------------------------------------------
-- Selling skins
---------------------------------------------------------------------------

function PS:Sell(ply, id)
    local d = self:Data(ply)
    if not d.loaded then return false, "err.not_loaded" end
    local item = self.Catalog[id]
    if not item or not d.owned[id] then return false, "err.not_owned" end
    if (tonumber(C.SellPercent) or 0) <= 0 then return false, "err.sell_disabled" end

    local sid = SteamKey(ply)
    if not sid or not self:EnsureTables() then return false, "err.db" end
    local refund = self:SellPrice(id)
    local new_skulls = math.Clamp(d.skulls + refund, 0, 2000000000)

    local ok = DB.Transaction(function(exec)
        local _, e1 = exec(DB.Prepare([[
            INSERT INTO horde_ps_players (steamid, skulls) VALUES (?, ?)
            ON CONFLICT(steamid) DO UPDATE SET skulls = excluded.skulls;
        ]], sid, new_skulls))
        if e1 then return false end
        local _, e2 = exec(DB.Prepare("DELETE FROM horde_ps_inventory WHERE steamid = ? AND item_id = ?;", sid, id))
        if e2 then return false end
        local _, e3 = exec(DB.Prepare("DELETE FROM horde_ps_equipped WHERE steamid = ? AND item_id = ?;", sid, id))
        return not e3
    end)
    if not ok then return false, "err.db" end

    d.skulls = new_skulls
    d.owned[id] = nil
    for i = #d.inventory, 1, -1 do
        if d.inventory[i] == id then table.remove(d.inventory, i) end
    end
    local was_equipped = false
    for key, eid in pairs(d.equipped) do
        if eid == id then
            d.equipped[key] = nil
            was_equipped = true
        end
    end
    if was_equipped then self:RefreshModel(ply) end

    hook.Run("Horde_PS_ItemSold", ply, item, refund)
    return true, "ok.sold", { item.name, self:FormatNumber(refund) }
end

net.Receive("Horde_PS_Sell", function(_, ply)
    if not IsValid(ply) or PS.Throttle(ply, "sell", 0.3) then return end
    local id = net.ReadString()
    local ok, key, args = PS:Sell(ply, id)
    PS:SendResult(ply, ok, key, args)
    PS:SyncPlayer(ply)
end)

---------------------------------------------------------------------------

PS:LoadEconomySettings()
PS:SendConfig()
