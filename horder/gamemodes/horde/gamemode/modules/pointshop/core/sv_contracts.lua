if not SERVER then return end

local PS = HORDE.Pointshop
local C  = PS.Config
local DB = HORDE.DB

local SAVE_INTERVAL = 30
local SYNC_INTERVAL = 2

local function SteamKey(ply)
    if not IsValid(ply) or ply:IsBot() then return nil end
    return ply:SteamID()
end

local function Template(tid)
    for _, t in ipairs(C.Contracts or {}) do
        if t.id == tid then return t end
    end
end

---------------------------------------------------------------------------
-- Generation
---------------------------------------------------------------------------

function PS:GenerateContracts(ply, day)
    local sid = SteamKey(ply) or "BOT"
    local rng = self:NewRNG(day * 92821 + (tonumber(util.CRC(sid)) or 0) % 1000003)

    local pool = {}
    for _, t in ipairs(C.Contracts or {}) do pool[#pool + 1] = t end

    local classes = {}
    for _, class in ipairs(self:GetClassList()) do classes[#classes + 1] = class.name end

    local list = {}
    for _ = 1, math.min(C.ContractsPerDay or 0, #pool) do
        local t, idx = rng:Pick(pool)
        table.remove(pool, idx)

        local lo, hi = t.min or 1, math.max(t.max or t.min or 1, t.min or 1)
        local step = math.max(1, t.step or 1)
        local goal = math.min(hi, lo + step * rng:Range(0, math.floor((hi - lo) / step)))

        local entry = { tid = t.id, goal = math.max(1, goal), progress = 0, claimed = false }
        if t.per_class then entry.class = rng:Pick(classes) end
        list[#list + 1] = entry
    end
    return { day = day, list = list }
end

---------------------------------------------------------------------------
-- Persistence
---------------------------------------------------------------------------

function PS:LoadContracts(ply)
    local d = self:Data(ply)
    local sid = SteamKey(ply)
    local day = self:GetDay()
    d.contracts = nil

    if sid and self:EnsureTables() then
        local row = DB.QueryRow("SELECT day, data FROM horde_ps_contracts WHERE steamid = ?;", sid)
        if row and tonumber(row.day) == day then
            local list = util.JSONToTable(row.data or "")
            if istable(list) then d.contracts = { day = day, list = list } end
        end
    end

    if not d.contracts then
        d.contracts = self:GenerateContracts(ply, day)
        d.contracts_dirty = true
        self:SaveContracts(ply)
    end
end

function PS:SaveContracts(ply)
    local d, sid = ply.Horde_PS, SteamKey(ply)
    if not d or not d.contracts or not d.contracts_dirty or not sid or not self:EnsureTables() then return end
    DB.Query(DB.Prepare([[
        INSERT INTO horde_ps_contracts (steamid, day, data) VALUES (?, ?, ?)
        ON CONFLICT(steamid) DO UPDATE SET day = excluded.day, data = excluded.data;
    ]], sid, d.contracts.day, util.TableToJSON(d.contracts.list)))
    d.contracts_dirty = false
end

function PS:ContractDescription(entry)
    local t = Template(entry.tid)
    if not t then return "Unknown contract." end
    if t.per_class then
        return string.format(t.desc or "", entry.goal, self:ClassDisplayName(entry.class))
    end
    return string.format(t.desc or "", entry.goal)
end

function PS:SyncContracts(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    local d = self:Data(ply)
    local out = {}
    for _, entry in ipairs(d.contracts and d.contracts.list or {}) do
        local t = Template(entry.tid)
        if t then
            out[#out + 1] = {
                name     = t.name,
                desc     = self:ContractDescription(entry),
                event    = t.event,
                progress = math.min(entry.progress, entry.goal),
                goal     = entry.goal,
                reward   = t.reward or C.ContractReward,
                claimed  = entry.claimed,
            }
        end
    end
    d.contracts_sync = false
    net.Start("Horde_PS_Contracts")
    net.WriteUInt(self:SecondsUntilReset(), 32)
    self:WriteTable(out)
    net.Send(ply)
end

---------------------------------------------------------------------------
-- Progress
---------------------------------------------------------------------------

local function ProgressAllowed()
    if GetConVar("sv_cheats"):GetBool() then return false end
    if not C.ContractsInSandbox and GetConVar("horde_enable_sandbox"):GetBool() then return false end
    return true
end

function PS:AddContractProgress(ply, matcher, amount)
    local d = ply.Horde_PS
    if not d or not d.loaded or not d.contracts then return end
    if d.contracts.day ~= self:GetDay() then return end

    for _, entry in ipairs(d.contracts.list) do
        local t = not entry.claimed and entry.progress < entry.goal and Template(entry.tid)
        if t and matcher(t, entry) then
            entry.progress = math.min(entry.goal, entry.progress + (amount or 1))
            d.contracts_dirty = true
            d.contracts_sync = true

            if entry.progress >= entry.goal then
                HORDE:SendNotification("Contract complete: " .. t.name .. "! Claim your "
                    .. (t.reward or C.ContractReward) .. " " .. C.CurrencyName .. " in the pointshop (F4).", 0, ply)
                self:SaveContracts(ply)
                self:SyncContracts(ply)
            end
        end
    end
end

local function NameSet(list)
    local set = {}
    for _, n in ipairs(list or {}) do set[string.lower(n)] = true end
    return set
end

hook.Add("Horde_OnEnemyKilled", "Horde_PS_ContractKill", function(victim, killer)
    if not IsValid(killer) or not killer:IsPlayer() or killer:IsBot() then return end
    if (HORDE.current_wave or 0) <= 0 or not ProgressAllowed() then return end
    if not IsValid(victim) or victim.Horde_NoReward then return end

    local name = string.lower(victim.Horde_GetName and victim:Horde_GetName() or "")
    local elite = victim.Horde_IsElite and victim:Horde_IsElite() or false
    local props = victim.Horde_GetBossProperties and victim:Horde_GetBossProperties()
    local boss = (props and props.is_boss == true) or victim:GetVar("is_boss") == true
    local class = killer:Horde_GetClass()
    local class_name = class and class.name

    PS:AddContractProgress(killer, function(t, entry)
        if t.event ~= "kill" then return false end
        if t.enemy then
            t._names = t._names or NameSet(t.enemy)
            if not t._names[name] then return false end
        end
        if t.elite and not elite then return false end
        if t.boss and not boss then return false end
        if t.per_class and entry.class ~= class_name then return false end
        return true
    end, 1)
end)

hook.Add("HordeWaveEnd", "Horde_PS_ContractWave", function()
    if not ProgressAllowed() then return end
    for _, ply in ipairs(player.GetHumans()) do
        if ply:Alive() then
            PS:AddContractProgress(ply, function(t) return t.event == "wave" end, 1)
        end
    end
end)

hook.Add("Horde_OnGameEnd", "Horde_PS_ContractWin", function(status)
    if status ~= "VICTORY" or not ProgressAllowed() then return end
    for _, ply in ipairs(player.GetHumans()) do
        PS:AddContractProgress(ply, function(t) return t.event == "win" end, 1)
    end
end)

---------------------------------------------------------------------------
-- Claiming / timers
---------------------------------------------------------------------------

net.Receive("Horde_PS_Claim", function(_, ply)
    if not IsValid(ply) then return end
    local index = net.ReadUInt(8)
    local d = PS:Data(ply)
    if not d.loaded or not d.contracts or d.contracts.day ~= PS:GetDay() then return end
    local entry = d.contracts.list[index]
    if not entry or entry.claimed or entry.progress < entry.goal then
        PS:SendResult(ply, false, "That contract is not complete yet.")
        return
    end
    local t = Template(entry.tid)
    local reward = t and t.reward or C.ContractReward

    entry.claimed = true
    d.contracts_dirty = true
    PS:SaveContracts(ply)
    PS:AddSkulls(ply, reward)
    PS:SyncContracts(ply)
    PS:SendResult(ply, true, "Contract claimed: +" .. PS:FormatNumber(reward) .. " " .. C.CurrencyName .. ".")
    hook.Run("Horde_PS_ContractClaimed", ply, entry, reward)
end)

hook.Add("Horde_PS_NewDay", "Horde_PS_ContractsNewDay", function(day)
    for _, ply in ipairs(player.GetHumans()) do
        local d = ply.Horde_PS
        if d and d.loaded then
            PS:SaveContracts(ply)
            d.contracts = PS:GenerateContracts(ply, day)
            d.contracts_dirty = true
            PS:SaveContracts(ply)
            PS:SyncContracts(ply)
            HORDE:SendNotification("New daily contracts and store deals are available! (F4)", 0, ply)
        end
    end
end)

timer.Create("Horde_PS_ContractSync", SYNC_INTERVAL, 0, function()
    for _, ply in ipairs(player.GetHumans()) do
        if ply.Horde_PS and ply.Horde_PS.contracts_sync then PS:SyncContracts(ply) end
    end
end)

timer.Create("Horde_PS_ContractSave", SAVE_INTERVAL, 0, function()
    for _, ply in ipairs(player.GetHumans()) do PS:SaveContracts(ply) end
end)

hook.Add("PlayerDisconnected", "Horde_PS_ContractSave", function(ply)
    PS:SaveContracts(ply)
end)

hook.Add("ShutDown", "Horde_PS_ContractSaveAll", function()
    for _, ply in ipairs(player.GetHumans()) do PS:SaveContracts(ply) end
end)
