if not SERVER then return end

local PS = HORDE.Pointshop
local C  = PS.Config
local DB = HORDE.DB

PS.Overrides   = PS.Overrides or { items = {}, custom = {} }
PS.DailyReroll = PS.DailyReroll or { day = -1, n = 0 }

local function log(msg)
    MsgC(Color(220, 40, 40), "[Horde Pointshop] ", color_white, msg .. "\n")
end

local function SteamKey(ply)
    if not IsValid(ply) or ply:IsBot() then return nil end
    return ply:SteamID()
end

---------------------------------------------------------------------------
-- Database
---------------------------------------------------------------------------

local tables_ready = false
function PS:EnsureTables()
    if tables_ready then return true end
    if not (DB and DB.IsReady and DB.IsReady()) then return false end
    local ok = DB.Transaction(function(exec)
        for _, stmt in ipairs({
            [[CREATE TABLE IF NOT EXISTS horde_ps_players (
                steamid  TEXT PRIMARY KEY,
                skulls   INTEGER DEFAULT 0
            );]],
            [[CREATE TABLE IF NOT EXISTS horde_ps_inventory (
                steamid   TEXT NOT NULL,
                item_id   TEXT NOT NULL,
                acquired  INTEGER DEFAULT 0,
                PRIMARY KEY (steamid, item_id)
            );]],
            [[CREATE TABLE IF NOT EXISTS horde_ps_equipped (
                steamid     TEXT NOT NULL,
                class_name  TEXT NOT NULL,
                item_id     TEXT NOT NULL,
                PRIMARY KEY (steamid, class_name)
            );]],
            [[CREATE TABLE IF NOT EXISTS horde_ps_contracts (
                steamid  TEXT PRIMARY KEY,
                day      INTEGER DEFAULT 0,
                data     TEXT
            );]],
            "CREATE INDEX IF NOT EXISTS idx_horde_ps_inventory_steamid ON horde_ps_inventory(steamid);",
        }) do
            local _, err = exec(stmt)
            if err then return false end
        end
        return true
    end)
    tables_ready = ok and true or false
    return tables_ready
end

local function GetMeta(key)
    if not PS:EnsureTables() then return nil end
    local value = DB.QueryValue("SELECT value FROM horde_redux_meta WHERE key = ?;", key)
    return value and util.JSONToTable(value) or nil
end

local function SetMeta(key, tbl)
    if not PS:EnsureTables() then return end
    DB.Query(DB.Prepare([[
        INSERT INTO horde_redux_meta (key, value) VALUES (?, ?)
        ON CONFLICT(key) DO UPDATE SET value = excluded.value;
    ]], key, util.TableToJSON(tbl)))
end

---------------------------------------------------------------------------
-- Catalog / overrides / daily store
---------------------------------------------------------------------------

function PS:LoadOverrides()
    local o = GetMeta("pointshop_overrides")
    if istable(o) then
        self.Overrides = { items = istable(o.items) and o.items or {}, custom = istable(o.custom) and o.custom or {} }
    end
    local r = GetMeta("pointshop_daily_reroll")
    if istable(r) then self.DailyReroll = { day = tonumber(r.day) or -1, n = tonumber(r.n) or 0 } end
end

function PS:SaveOverrides()
    SetMeta("pointshop_overrides", self.Overrides)
end

function PS:ComputeDaily()
    local day = self:GetDay()
    local reroll = (self.DailyReroll.day == day) and self.DailyReroll.n or 0
    local rng = self:NewRNG(day * 7919 + reroll * 104729 + 17)

    local pool = {}
    for _, item in ipairs(self:GetStoreItems()) do
        if item.price > 0 then pool[#pool + 1] = item end
    end

    local lo   = math.Clamp(math.floor(tonumber(C.DailyDiscountMin) or 0), 0, 100)
    local hi   = math.Clamp(math.floor(tonumber(C.DailyDiscountMax) or lo), lo, 100)
    local step = math.max(1, math.floor(tonumber(C.DailyDiscountStep) or 1))

    local deals = {}
    for _ = 1, math.min(math.max(0, C.DailyCount or 0), #pool) do
        local item, idx = rng:Pick(pool)
        table.remove(pool, idx)
        local discount = math.min(hi, lo + step * rng:Range(0, math.floor((hi - lo) / step)))
        deals[#deals + 1] = { id = item.id, discount = discount }
    end

    self.Daily = { day = day, deals = deals }
end

function PS:GetDailyDeal(id)
    for _, deal in ipairs(self.Daily and self.Daily.deals or {}) do
        if deal.id == id then return deal end
    end
end

function PS:GetPrice(id)
    local item = self.Catalog[id]
    if not item then return nil end
    local deal = self:GetDailyDeal(id)
    if deal then return self:DailyPrice(item.price, deal.discount), deal.discount end
    return item.price, 0
end

function PS:Rebuild()
    self:BuildCatalog(self.Overrides)
    self:ComputeDaily()
end

function PS:SendCatalog(target)
    local list = {}
    for _, id in ipairs(self.CatalogOrder) do list[#list + 1] = self.Catalog[id] end
    net.Start("Horde_PS_Catalog")
    self:WriteTable(list)
    if target then net.Send(target) else net.Broadcast() end
end

function PS:SendDaily(target)
    net.Start("Horde_PS_Daily")
    net.WriteUInt(self.Daily.day, 32)
    net.WriteUInt(self:SecondsUntilReset(), 32)
    net.WriteUInt(#self.Daily.deals, 8)
    for _, deal in ipairs(self.Daily.deals) do
        net.WriteString(deal.id)
        net.WriteUInt(deal.discount, 7)
    end
    if target then net.Send(target) else net.Broadcast() end
end

---------------------------------------------------------------------------
-- Player data
---------------------------------------------------------------------------

function PS:Data(ply)
    if not ply.Horde_PS then
        ply.Horde_PS = { loaded = false, skulls = 0, inventory = {}, owned = {}, equipped = {} }
    end
    return ply.Horde_PS
end

function PS:LoadPlayer(ply)
    local d = self:Data(ply)
    local sid = SteamKey(ply)
    if not sid or not self:EnsureTables() then return false end

    local skulls = DB.QueryValue("SELECT skulls FROM horde_ps_players WHERE steamid = ?;", sid)
    if skulls == nil then
        skulls = math.max(0, math.floor(tonumber(C.StartingSkulls) or 0))
        DB.Query(DB.Prepare("INSERT OR IGNORE INTO horde_ps_players (steamid, skulls) VALUES (?, ?);", sid, skulls))
    end
    d.skulls = tonumber(skulls) or 0

    d.inventory, d.owned = {}, {}
    for _, row in ipairs(DB.QueryP("SELECT item_id FROM horde_ps_inventory WHERE steamid = ? ORDER BY acquired ASC, item_id ASC;", sid) or {}) do
        d.inventory[#d.inventory + 1] = row.item_id
        d.owned[row.item_id] = true
    end

    d.equipped = {}
    for _, row in ipairs(DB.QueryP("SELECT class_name, item_id FROM horde_ps_equipped WHERE steamid = ?;", sid) or {}) do
        d.equipped[row.class_name] = row.item_id
    end

    d.loaded = true
    return true
end

function PS:SaveSkulls(ply)
    local d, sid = self:Data(ply), SteamKey(ply)
    if not d.loaded or not sid or not self:EnsureTables() then return end
    DB.Query(DB.Prepare([[
        INSERT INTO horde_ps_players (steamid, skulls) VALUES (?, ?)
        ON CONFLICT(steamid) DO UPDATE SET skulls = excluded.skulls;
    ]], sid, d.skulls))
end

function PS:GetSkulls(ply)
    return self:Data(ply).skulls
end

function PS:AddSkulls(ply, amount)
    local d = self:Data(ply)
    if not d.loaded then return false end
    d.skulls = math.Clamp(d.skulls + math.floor(tonumber(amount) or 0), 0, 2000000000)
    self:SaveSkulls(ply)
    self:SyncPlayer(ply)
    return true
end

-- Owned items that still exist in the catalog (in acquisition order).
function PS:GetInventory(ply)
    local list = {}
    for _, id in ipairs(self:Data(ply).inventory) do
        if self.Catalog[id] then list[#list + 1] = id end
    end
    return list
end

function PS:SyncPlayer(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    local d = self:Data(ply)
    net.Start("Horde_PS_Player")
    self:WriteTable({
        loaded    = d.loaded,
        skulls    = d.skulls,
        inventory = self:GetInventory(ply),
        equipped  = d.equipped,
        admin     = C.IsAdmin(ply) and true or false,
    })
    net.Send(ply)
end

function PS:SendResult(ply, ok, msg)
    net.Start("Horde_PS_Result")
    net.WriteBool(ok)
    net.WriteString(msg or "")
    net.Send(ply)
end

function PS:SyncAll(ply)
    self:SendCatalog(ply)
    self:SendDaily(ply)
    self:SyncPlayer(ply)
    if self.SyncContracts then self:SyncContracts(ply) end
end

---------------------------------------------------------------------------
-- Playermodels
---------------------------------------------------------------------------

function PS:GetEquippedItem(ply, class_name)
    if not IsValid(ply) or not class_name then return nil end
    local d = ply.Horde_PS
    if not d or not d.loaded then return nil end
    local id = d.equipped[class_name]
    local item = id and d.owned[id] and self.Catalog[id]
    if not item or not self:CanClassUse(item, class_name) then return nil end
    return item
end

function PS:GetEquippedModel(ply, class_name)
    local item = self:GetEquippedItem(ply, class_name)
    return item and item.model or nil
end

-- True when Horde should route the class model through Horde_SetClassModel for this player:
-- either a pointshop model is equipped for the class, or a previous one has to be removed.
function PS:ShouldApplyModel(ply, class)
    if not class then return false end
    return self:GetEquippedModel(ply, class.name) ~= nil or ply.Horde_PS_Applied ~= nil
end

local function FixHands(ply, mdl)
    local hands = player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(mdl))
    local hands_ent = ply:GetHands()
    if IsValid(hands_ent) and istable(hands) and hands.model and hands_ent:GetModel() ~= hands.model then
        hands_ent:SetModel(hands.model)
        hands_ent:SetSkin(hands.skin or 0)
        hands_ent:SetBodyGroups(hands.body or "0000000")
    end
end

function PS:SetModelNow(ply, mdl)
    util.PrecacheModel(mdl)
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end
        ply:SetModel(mdl)
        ply:SetupHands()
    end)
    timer.Simple(0.2, function()
        if IsValid(ply) then FixHands(ply, mdl) end
    end)
end

function PS:ApplyModel(ply, mdl)
    if not ply.Horde_PS_Applied then ply.Horde_PS_PrevModel = ply:GetModel() end
    ply.Horde_PS_Applied = mdl
    self:SetModelNow(ply, mdl)
end

local plymeta = FindMetaTable("Player")
PS.Base_SetClassModel = PS.Base_SetClassModel or plymeta.Horde_SetClassModel

function plymeta:Horde_SetClassModel(class)
    local item = class and PS:GetEquippedItem(self, class.name)
    if item then return PS:ApplyModel(self, item.model) end

    if self.Horde_PS_Applied then
        self.Horde_PS_Applied = nil
        local prev = self.Horde_PS_PrevModel
        self.Horde_PS_PrevModel = nil
        local base = class and HORDE.classes[class.name]
        if GetConVarNumber("horde_enable_class_models") ~= 0 and base and base.model and base.model ~= "" then
            return PS.Base_SetClassModel(self, class)
        end
        if prev then PS:SetModelNow(self, prev) end
        return
    end

    if PS.Base_SetClassModel then return PS.Base_SetClassModel(self, class) end
end

function PS:RefreshModel(ply, class_name)
    local class = ply:Horde_GetClass()
    if not class or class.name ~= class_name or not ply:Alive() then return end
    if self:ShouldApplyModel(ply, class) then ply:Horde_SetClassModel(class) end
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

function PS:Buy(ply, id)
    local d = self:Data(ply)
    if not d.loaded then return false, "Your pointshop data is not loaded yet." end
    local item = self.Catalog[id]
    if not item or not item.enabled then return false, "That item is not for sale." end
    if d.owned[id] then return false, "You already own " .. item.name .. "." end
    if #self:GetInventory(ply) >= C.InventorySlots then return false, "Your inventory is full." end

    local price = self:GetPrice(id)
    if d.skulls < price then
        return false, "Not enough " .. C.CurrencyName .. " (" .. self:FormatNumber(price - d.skulls) .. " more needed)."
    end

    local sid = SteamKey(ply)
    local new_skulls = d.skulls - price
    local ok = DB.Transaction(function(exec)
        local _, e1 = exec(DB.Prepare([[
            INSERT INTO horde_ps_players (steamid, skulls) VALUES (?, ?)
            ON CONFLICT(steamid) DO UPDATE SET skulls = excluded.skulls;
        ]], sid, new_skulls))
        if e1 then return false end
        local _, e2 = exec(DB.Prepare(
            "INSERT OR REPLACE INTO horde_ps_inventory (steamid, item_id, acquired) VALUES (?, ?, ?);",
            sid, id, os.time()))
        return not e2
    end)
    if not ok then return false, "Purchase failed (database error)." end

    d.skulls = new_skulls
    d.owned[id] = true
    d.inventory[#d.inventory + 1] = id

    -- First model bought for the player's current class gets equipped automatically.
    local class = ply:Horde_GetClass()
    if class and not d.equipped[class.name] and self:CanClassUse(item, class.name) then
        self:Equip(ply, class.name, id)
    end

    hook.Run("Horde_PS_ItemBought", ply, item, price)
    return true, "Purchased " .. item.name .. " for " .. self:FormatNumber(price) .. " " .. C.CurrencyName .. "."
end

function PS:Equip(ply, class_name, id)
    local d = self:Data(ply)
    if not d.loaded then return false, "Your pointshop data is not loaded yet." end
    if not (HORDE.classes and HORDE.classes[class_name]) then return false, "Unknown class." end
    local sid = SteamKey(ply)

    if id == nil or id == "" then
        d.equipped[class_name] = nil
        DB.Query(DB.Prepare("DELETE FROM horde_ps_equipped WHERE steamid = ? AND class_name = ?;", sid, class_name))
        self:RefreshModel(ply, class_name)
        return true, self:ClassDisplayName(class_name) .. " now uses the default model."
    end

    local item = self.Catalog[id]
    if not item or not d.owned[id] then return false, "You do not own that item." end
    if not self:CanClassUse(item, class_name) then
        return false, item.name .. " cannot be worn by " .. self:ClassDisplayName(class_name) .. "."
    end

    d.equipped[class_name] = id
    DB.Query(DB.Prepare([[
        INSERT INTO horde_ps_equipped (steamid, class_name, item_id) VALUES (?, ?, ?)
        ON CONFLICT(steamid, class_name) DO UPDATE SET item_id = excluded.item_id;
    ]], sid, class_name, id))
    self:RefreshModel(ply, class_name)
    return true, item.name .. " equipped on " .. self:ClassDisplayName(class_name) .. "."
end

---------------------------------------------------------------------------
-- Admin
---------------------------------------------------------------------------

local function CleanClasses(list)
    if not istable(list) then return {} end
    local out, seen = {}, {}
    for _, name in ipairs(list) do
        if isstring(name) and HORDE.classes[name] and not seen[name] then
            seen[name] = true
            out[#out + 1] = name
        end
    end
    return out
end

local function CleanName(name)
    if not isstring(name) then return nil end
    name = string.Trim((name:gsub("%c", "")))
    if #name == 0 then return nil end
    return name:sub(1, PS.MAX_NAME_LEN)
end

local function CleanPrice(price)
    price = tonumber(price)
    if not price or price ~= price then return nil end
    return math.Clamp(math.floor(price), 0, PS.MAX_PRICE)
end

local ADMIN_ACTIONS = {}

function ADMIN_ACTIONS.update(ply, data)
    local item = PS.Catalog[data.id]
    if not item then return false, "Unknown item." end
    local price = CleanPrice(data.price)
    if not price then return false, "Invalid price." end
    local classes = CleanClasses(data.classes)
    local rarity = C.Rarities[data.rarity] and data.rarity or item.rarity

    if item.custom then
        local src = PS.Overrides.custom[item.id]
        if not src then return false, "Unknown custom item." end
        local model = data.model and PS:SanitizeModel(data.model)
        if data.model and not model then return false, "Invalid model path." end
        if model and model ~= src.model and not util.IsValidModel(model) then
            return false, "Model not found on the server: " .. model
        end
        src.name    = CleanName(data.name) or src.name
        src.model   = model or src.model
        src.price   = price
        src.rarity  = rarity
        src.classes = classes
        PS.Overrides.items[item.id] = data.enabled == false and { disabled = true } or nil
    else
        local o = { price = price, classes = classes, rarity = rarity ~= item.rarity and rarity or nil }
        if data.enabled == false then o.disabled = true end
        PS.Overrides.items[item.id] = o
    end
    return true, "Saved " .. item.name .. "."
end

function ADMIN_ACTIONS.reset(ply, data)
    local item = PS.Catalog[data.id]
    if not item then return false, "Unknown item." end
    if item.custom then return false, "Custom items have no default; edit or delete it instead." end
    PS.Overrides.items[item.id] = nil
    return true, item.name .. " reset to config defaults."
end

function ADMIN_ACTIONS.add(ply, data)
    local name  = CleanName(data.name)
    local model = PS:SanitizeModel(data.model)
    local price = CleanPrice(data.price)
    if not name then return false, "Enter a name." end
    if not model then return false, "Invalid model path (expected models/....mdl)." end
    if not util.IsValidModel(model) then return false, "Model not found on the server: " .. model end
    if not price then return false, "Invalid price." end
    if table.Count(PS.Overrides.custom) >= 1000 then return false, "Too many custom items." end

    local base = "custom_" .. (name:lower():gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", ""):sub(1, 24))
    local id, n = base, 1
    while PS.Catalog[id] or PS.Overrides.custom[id] do
        n = n + 1
        id = base .. "_" .. n
    end

    PS.Overrides.custom[id] = {
        id      = id,
        name    = name,
        model   = model,
        price   = price,
        rarity  = C.Rarities[data.rarity] and data.rarity or C.DefaultRarity,
        classes = CleanClasses(data.classes),
    }
    return true, "Added " .. name .. "."
end

function ADMIN_ACTIONS.delete(ply, data)
    local item = PS.Catalog[data.id]
    if not item or not item.custom then return false, "Only custom items can be deleted. Disable config items instead." end
    PS.Overrides.custom[item.id] = nil
    PS.Overrides.items[item.id] = nil
    return true, "Deleted " .. item.name .. "."
end

function ADMIN_ACTIONS.reroll(ply, data)
    local day = PS:GetDay()
    PS.DailyReroll = { day = day, n = (PS.DailyReroll.day == day and PS.DailyReroll.n or 0) + 1 }
    SetMeta("pointshop_daily_reroll", PS.DailyReroll)
    return true, "Daily store rerolled."
end

---------------------------------------------------------------------------
-- Networking
---------------------------------------------------------------------------

local last_msg = {}
local function Throttle(ply, key, delay)
    last_msg[ply] = last_msg[ply] or {}
    local now = CurTime()
    if last_msg[ply][key] and now - last_msg[ply][key] < (delay or 0.25) then return true end
    last_msg[ply][key] = now
    return false
end

net.Receive("Horde_PS_Request", function(_, ply)
    if not IsValid(ply) or Throttle(ply, "request", 1) then return end
    PS:SyncAll(ply)
end)

net.Receive("Horde_PS_Buy", function(_, ply)
    if not IsValid(ply) or Throttle(ply, "buy") then return end
    local id = net.ReadString()
    local ok, msg = PS:Buy(ply, id)
    PS:SendResult(ply, ok, msg)
    PS:SyncPlayer(ply)
end)

net.Receive("Horde_PS_Equip", function(_, ply)
    if not IsValid(ply) or Throttle(ply, "equip") then return end
    local class_name = net.ReadString()
    local id = net.ReadString()
    local ok, msg = PS:Equip(ply, class_name, id)
    PS:SendResult(ply, ok, msg)
    PS:SyncPlayer(ply)
end)

net.Receive("Horde_PS_Admin", function(len, ply)
    if not IsValid(ply) or Throttle(ply, "admin") then return end
    if not C.IsAdmin(ply) then
        PS:SendResult(ply, false, "You do not have access to the pointshop admin panel.")
        return
    end
    local action = net.ReadString()
    local data = PS:ReadTable() or {}
    local fn = ADMIN_ACTIONS[action]
    if not fn then return end

    local ok, msg = fn(ply, data)
    if ok then
        if action ~= "reroll" then PS:SaveOverrides() end
        PS:Rebuild()
        PS:SendCatalog()
        PS:SendDaily()
        for _, p in ipairs(player.GetHumans()) do PS:SyncPlayer(p) end
        log(ply:Nick() .. " (" .. ply:SteamID() .. ") admin action '" .. action .. "': " .. msg)
    end
    PS:SendResult(ply, ok, msg)
end)

function PS:Open(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    if not self:Data(ply).loaded then
        if not self:LoadPlayer(ply) then
            HORDE:SendNotification("Pointshop is unavailable (database not ready).", 1, ply)
            return
        end
        if self.LoadContracts then self:LoadContracts(ply) end
    end
    self:SyncAll(ply)
    net.Start("Horde_PS_Open")
    net.Send(ply)
end

concommand.Add("horde_pointshop", function(ply) PS:Open(ply) end)

hook.Add("ShowSpare2", "Horde_PS_OpenF4", function(ply)
    if C.OpenWithF4 then PS:Open(ply) end
end)

hook.Add("PlayerSay", "Horde_PS_ChatCommand", function(ply, text)
    local cmd = string.lower(string.Trim(text))
    for _, c in ipairs(C.ChatCommands or {}) do
        if cmd == c then
            PS:Open(ply)
            return ""
        end
    end
end)

-- horde_ps_give_skulls <name | steamid | ^ (self)> <amount>
concommand.Add("horde_ps_give_skulls", function(ply, _, args)
    if IsValid(ply) and not C.IsAdmin(ply) then
        HORDE:SendNotificationDenyAccess(ply)
        return
    end
    local who, amount = args[1], math.floor(tonumber(args[2]) or 0)
    local function reply(msg)
        if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, msg) else print(msg) end
    end
    if not who or amount == 0 then
        reply("Usage: horde_ps_give_skulls <name|steamid|^> <amount>")
        return
    end

    local targets = {}
    for _, p in ipairs(player.GetHumans()) do
        if (who == "^" and p == ply) or p:SteamID() == who
            or string.find(string.lower(p:Nick()), string.lower(who), 1, true) then
            targets[#targets + 1] = p
        end
    end
    if #targets ~= 1 then
        reply(#targets == 0 and "No player matched '" .. who .. "'." or "More than one player matched '" .. who .. "'.")
        return
    end
    local target = targets[1]
    if PS:AddSkulls(target, amount) then
        reply(string.format("Gave %d %s to %s (now %d).", amount, C.CurrencyName, target:Nick(), PS:GetSkulls(target)))
        HORDE:SendNotification(string.format("%s: %+d", C.CurrencyName, amount), 0, target)
    else
        reply("That player's pointshop data is not loaded.")
    end
end)

---------------------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------------------

hook.Add("PlayerInitialSpawn", "Horde_PS_Load", function(ply)
    if ply:IsBot() then return end
    PS:Data(ply)
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        PS:LoadPlayer(ply)
        if PS.LoadContracts then PS:LoadContracts(ply) end
        PS:SyncAll(ply)
        local class = ply:Horde_GetClass()
        if class and ply:Alive() and PS:ShouldApplyModel(ply, class) then ply:Horde_SetClassModel(class) end
    end)
end)

hook.Add("PlayerDisconnected", "Horde_PS_Cleanup", function(ply)
    last_msg[ply] = nil
end)

-- Roll the daily store (and contracts, see sv_contracts.lua) over at the reset hour.
timer.Create("Horde_PS_DayCheck", 15, 0, function()
    if not PS.Daily or PS.Daily.day == PS:GetDay() then return end
    PS:ComputeDaily()
    PS:SendDaily()
    hook.Run("Horde_PS_NewDay", PS.Daily.day)
end)

PS:EnsureTables()
PS:LoadOverrides()
PS:Rebuild()

-- Lua refresh: resend everything to connected players.
for _, p in ipairs(player.GetHumans()) do
    if p.Horde_PS and p.Horde_PS.loaded then PS:SyncAll(p) end
end
