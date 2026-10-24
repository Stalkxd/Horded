if not SERVER then return end

local PS = HORDE.Pointshop
local C  = PS.Config
local DB = HORDE.DB

local SAVE_INTERVAL = 30
local SYNC_INTERVAL = 2

local EVENTS = { kill = true, win = true, wave = true }

local function SteamKey(ply)
    if not IsValid(ply) or ply:IsBot() then return nil end
    return ply:SteamID()
end

---------------------------------------------------------------------------
-- Templates: config contracts merged with admin edits / custom contracts.
-- Stored in horde_redux_meta 'pointshop_contracts':
--   { templates = { [id] = template }, per_day = n, reward = n }
---------------------------------------------------------------------------

PS.ContractOverrides = PS.ContractOverrides or { templates = {} }
PS.ContractTemplates = PS.ContractTemplates or {}   -- ordered list (enabled + disabled)
PS.ContractTemplateMap = PS.ContractTemplateMap or {}

local config_ids = {}

function PS:RebuildContractTemplates()
    local over = self.ContractOverrides.templates or {}
    local list, map = {}, {}
    config_ids = {}
    for _, t in ipairs(C.Contracts or {}) do
        if isstring(t.id) then
            config_ids[t.id] = true
            local src = over[t.id] or t
            local copy = table.Copy(src)
            copy.id = t.id
            copy.overridden = over[t.id] ~= nil
            list[#list + 1] = copy
            map[t.id] = copy
        end
    end
    for id, t in SortedPairs(over) do
        if not config_ids[id] then
            local copy = table.Copy(t)
            copy.id = id
            copy.custom = true
            list[#list + 1] = copy
            map[id] = copy
        end
    end
    self.ContractTemplates, self.ContractTemplateMap = list, map
end

function PS:LoadContractOverrides()
    if not self:EnsureTables() then return end
    local json = DB.QueryValue("SELECT value FROM horde_redux_meta WHERE key = 'pointshop_contracts';")
    local t = json and util.JSONToTable(json)
    if istable(t) then
        self.ContractOverrides = { templates = istable(t.templates) and t.templates or {} }
        if tonumber(t.per_day) then C.ContractsPerDay = math.Clamp(math.floor(t.per_day), 0, 10) end
        if tonumber(t.reward) then C.ContractReward = math.Clamp(math.floor(t.reward), 0, 1000000) end
    end
end

function PS:SaveContractOverrides()
    if not self:EnsureTables() then return end
    DB.Query(DB.Prepare([[
        INSERT INTO horde_redux_meta (key, value) VALUES ('pointshop_contracts', ?)
        ON CONFLICT(key) DO UPDATE SET value = excluded.value;
    ]], util.TableToJSON({
        templates = self.ContractOverrides.templates,
        per_day   = C.ContractsPerDay,
        reward    = C.ContractReward,
    })))
end

local function Template(tid)
    return PS.ContractTemplateMap[tid]
end

local function Reward(t)
    return tonumber(t.reward) or C.ContractReward
end

---------------------------------------------------------------------------
-- Generation
---------------------------------------------------------------------------

-- salt (optional) changes the picks for the same day, used by the admin "regenerate" button.
function PS:GenerateContracts(ply, day, salt)
    local sid = SteamKey(ply) or "BOT"
    local rng = self:NewRNG(day * 92821 + (tonumber(util.CRC(sid)) or 0) % 1000003 + (salt or 0) * 7919)

    local pool = {}
    for _, t in ipairs(self.ContractTemplates) do
        if t.enabled ~= false then pool[#pool + 1] = t end
    end

    local classes = {}
    for _, class in ipairs(self:GetClassList()) do classes[#classes + 1] = class.name end

    local list = {}
    for _ = 1, math.min(C.ContractsPerDay or 0, #pool) do
        local t, idx = rng:Pick(pool)
        table.remove(pool, idx)

        local lo = math.max(1, math.floor(tonumber(t.min) or 1))
        local hi = math.max(lo, math.floor(tonumber(t.max) or lo))
        local step = math.max(1, math.floor(tonumber(t.step) or 1))
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

local function SafeFormat(fmt, ...)
    local ok, res = pcall(string.format, fmt or "", ...)
    return ok and res or (fmt or "")
end

-- { en = ..., ru = ... } for a contract's name and description.
function PS:ContractTexts(entry)
    local t = Template(entry.tid)
    if not t then return { en = "?", ru = "?" }, { en = "", ru = "" } end
    local function desc(fmt, lang)
        if t.per_class then return SafeFormat(fmt, entry.goal, entry.class and self:ClassName(entry.class, lang) or "") end
        return SafeFormat(fmt, entry.goal)
    end
    local name = { en = t.name or t.id, ru = (t.name_ru ~= nil and t.name_ru ~= "") and t.name_ru or (t.name or t.id) }
    local text = { en = desc(t.desc, "en"), ru = desc((t.desc_ru ~= nil and t.desc_ru ~= "") and t.desc_ru or t.desc, "ru") }
    return name, text
end

function PS:SyncContracts(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    local d = self:Data(ply)
    local out = {}
    for i, entry in ipairs(d.contracts and d.contracts.list or {}) do
        local t = Template(entry.tid)
        if t then
            local name, desc = self:ContractTexts(entry)
            out[#out + 1] = {
                index    = i,
                name     = name,
                desc     = desc,
                event    = t.event,
                progress = math.min(entry.progress, entry.goal),
                goal     = entry.goal,
                reward   = Reward(t),
                claimed  = entry.claimed,
            }
        end
    end
    d.contracts_sync = false
    net.Start("Horde_PS_Contracts")
    net.WriteUInt(self:SecondsUntilReset(), 32)
    self:WriteTable({ list = out, paused = self:ContractPauseReason() })
    net.Send(ply)
end

---------------------------------------------------------------------------
-- Progress
---------------------------------------------------------------------------

-- Why contract progress is paused (translation key), or nil when it counts.
-- Singleplayer always counts; on servers cheats / sandbox mode pause it (C.ContractsBlockCheats).
function PS:ContractPauseReason()
    if game.SinglePlayer() or not C.ContractsBlockCheats then return nil end
    if GetConVar("sv_cheats"):GetBool() then return "paused_cheats" end
    if GetConVar("horde_enable_sandbox"):GetBool() then return "paused_sandbox" end
    return nil
end

local function ProgressAllowed()
    return PS:ContractPauseReason() == nil
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
                local name = self:ContractTexts(entry)
                self:Notify(ply, "n.contract_complete", { name, self:FormatNumber(Reward(t)) })
                self:SaveContracts(ply)
                self:SyncContracts(ply)
            end
        end
    end
end

local function NameSet(list)
    local set = {}
    for _, n in ipairs(istable(list) and list or {}) do set[string.lower(n)] = true end
    return set
end

-- Finds the player responsible for a kill: the attacker itself, the owner of a minion /
-- turret / projectile, or the last player Horde saw damaging the enemy.
local function OwnerPlayer(ent)
    for _ = 1, 4 do
        if not IsValid(ent) then return nil end
        if ent:IsPlayer() then return ent end
        local minion_owner = HORDE.GetMinionOwner and HORDE:GetMinionOwner(ent)
        if IsValid(minion_owner) and minion_owner:IsPlayer() then return minion_owner end
        local owner = ent.GetOwner and ent:GetOwner()
        if not IsValid(owner) or owner == ent then return nil end
        ent = owner
    end
end

local function KillerOf(victim, attacker)
    local ply = OwnerPlayer(attacker)
    if IsValid(ply) then return ply end
    local last = victim.Horde_GetMostRecentAttacker and victim:Horde_GetMostRecentAttacker()
    return OwnerPlayer(last)
end

function PS:CountKill(victim, attacker)
    if not IsValid(victim) or victim.Horde_PS_Counted or victim:IsPlayer() then return end
    if HORDE.IsMinion and HORDE:IsMinion(victim) then return end -- friendly units
    local killer = KillerOf(victim, attacker)
    if not IsValid(killer) or killer:IsBot() then return end
    victim.Horde_PS_Counted = true
    if (HORDE.current_wave or 0) <= 0 or not ProgressAllowed() then return end

    local name = string.lower(victim.Horde_GetName and victim:Horde_GetName() or "")
    local elite = victim.Horde_IsElite and victim:Horde_IsElite() or false
    local props = victim.Horde_GetBossProperties and victim:Horde_GetBossProperties()
    local boss = (props and props.is_boss == true) or victim:GetVar("is_boss") == true
    local class = killer:Horde_GetClass()
    local class_name = class and class.name

    self:AddContractProgress(killer, function(t, entry)
        if t.event ~= "kill" then return false end
        if istable(t.enemy) and #t.enemy > 0 then
            t._names = t._names or NameSet(t.enemy)
            if not t._names[name] then return false end
        end
        if t.elite and not elite then return false end
        if t.boss and not boss then return false end
        if t.per_class and entry.class ~= class_name then return false end
        return true
    end, 1)
end

-- Several sources so no kill is missed; Horde_PS_Counted stops double counting.
hook.Add("Horde_OnEnemyKilled", "Horde_PS_ContractKill", function(victim, killer)
    PS:CountKill(victim, killer)
end)

hook.Add("OnNPCKilled", "Horde_PS_ContractNPCKilled", function(victim, attacker)
    PS:CountKill(victim, attacker)
end)

hook.Add("EntityRemoved", "Horde_PS_ContractRemoved", function(ent)
    if ent.Horde_PS_Counted or not (ent:IsNPC() or ent:IsNextBot()) then return end
    if ent:Health() > 0 then return end -- removed alive (e.g. wave cleanup), not a kill
    PS:CountKill(ent, nil)
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
-- Admin: contract editor
---------------------------------------------------------------------------

local function CleanText(s, max)
    if not isstring(s) then return nil end
    s = string.Trim((s:gsub("%c", "")))
    if #s == 0 then return nil end
    return s:sub(1, max)
end

local function CleanInt(v, lo, hi, def)
    v = tonumber(v)
    if not v or v ~= v then return def end
    return math.Clamp(math.floor(v), lo, hi)
end

local function CleanTemplate(data)
    local name = CleanText(data.name, 48)
    local desc = CleanText(data.desc, 160)
    if not name or not desc then return nil, "err.contract_text" end
    local event = EVENTS[data.event] and data.event or nil
    if not event then return nil, "err.contract_event" end

    local t = {
        name    = name,
        name_ru = CleanText(data.name_ru, 48),
        desc    = desc,
        desc_ru = CleanText(data.desc_ru, 160),
        event   = event,
        min     = CleanInt(data.min, 1, 100000, 1),
        step    = CleanInt(data.step, 1, 10000, 1),
        enabled = data.enabled ~= false,
    }
    t.max = CleanInt(data.max, t.min, 100000, t.min)
    if data.reward ~= nil and data.reward ~= "" then t.reward = CleanInt(data.reward, 0, 1000000, nil) end
    if event == "kill" then
        t.elite = data.elite == true or nil
        t.boss = data.boss == true or nil
        t.per_class = data.per_class == true or nil
        if istable(data.enemy) then
            local enemies = {}
            for _, e in ipairs(data.enemy) do
                local n = CleanText(e, 48)
                if n and #enemies < 20 then enemies[#enemies + 1] = n end
            end
            if #enemies > 0 then t.enemy = enemies end
        end
    end
    return t
end

local function EnemyNames()
    local names, seen = {}, {}
    for _, e in pairs(HORDE.enemies or {}) do
        if istable(e) and isstring(e.name) and not seen[e.name] then
            seen[e.name] = true
            names[#names + 1] = e.name
        end
    end
    table.sort(names)
    return names
end

function PS:SendContractAdmin(ply)
    local list = {}
    for _, t in ipairs(self.ContractTemplates) do
        local copy = table.Copy(t)
        copy._names = nil
        copy.config = config_ids[t.id] or nil
        list[#list + 1] = copy
    end
    self:SendAdminData(ply, "contracts", {
        templates = list,
        per_day   = C.ContractsPerDay,
        reward    = C.ContractReward,
        enemies   = EnemyNames(),
    })
end

local function AfterContractChange(ply)
    PS:SaveContractOverrides()
    PS:RebuildContractTemplates()
    PS:SendContractAdmin(ply)
    for _, p in ipairs(player.GetHumans()) do
        if p.Horde_PS and p.Horde_PS.loaded then PS:SyncContracts(p) end
    end
end

local ACT = PS.AdminActions

function ACT.contracts_get(ply)
    PS:SendContractAdmin(ply)
end

function ACT.contract_save(ply, data)
    local t, err = CleanTemplate(data)
    if not t then return false, err end
    local id = isstring(data.id) and data.id or nil
    if id and not PS.ContractTemplateMap[id] then return false, "err.contract_unknown" end
    if not id then
        local base = "custom_" .. (t.name:lower():gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", ""):sub(1, 24))
        if base == "custom_" then base = "custom_contract" end
        id = base
        local n = 1
        while PS.ContractTemplateMap[id] do
            n = n + 1
            id = base .. "_" .. n
        end
        if table.Count(PS.ContractOverrides.templates) >= 200 then return false, "err.too_many" end
    end
    PS.ContractOverrides.templates[id] = t
    AfterContractChange(ply)
    return true, "ok.contract_saved", { t.name }
end

function ACT.contract_reset(ply, data)
    if not isstring(data.id) or not config_ids[data.id] then return false, "err.contract_unknown" end
    PS.ContractOverrides.templates[data.id] = nil
    AfterContractChange(ply)
    return true, "ok.contract_reset"
end

function ACT.contract_delete(ply, data)
    if not isstring(data.id) or config_ids[data.id] or not PS.ContractOverrides.templates[data.id] then
        return false, "err.contract_delete"
    end
    PS.ContractOverrides.templates[data.id] = nil
    AfterContractChange(ply)
    return true, "ok.contract_deleted"
end

function ACT.contract_settings(ply, data)
    C.ContractsPerDay = CleanInt(data.per_day, 0, 10, C.ContractsPerDay)
    C.ContractReward = CleanInt(data.reward, 0, 1000000, C.ContractReward)
    AfterContractChange(ply)
    return true, "ok.settings_saved"
end

-- Re-roll today's contracts for everyone online (progress is lost). Handy after editing.
function ACT.contracts_regen(ply)
    local day = PS:GetDay()
    local salt = os.time() % 100000
    for _, p in ipairs(player.GetHumans()) do
        local d = p.Horde_PS
        if d and d.loaded then
            d.contracts = PS:GenerateContracts(p, day, salt)
            d.contracts_dirty = true
            PS:SaveContracts(p)
            PS:SyncContracts(p)
        end
    end
    return true, "ok.contracts_regen"
end

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
        PS:SendResult(ply, false, "err.contract_incomplete")
        return
    end
    local t = Template(entry.tid)
    local reward = t and Reward(t) or C.ContractReward

    entry.claimed = true
    d.contracts_dirty = true
    PS:SaveContracts(ply)
    PS:AddSkulls(ply, reward)
    PS:SyncContracts(ply)
    PS:SendResult(ply, true, "ok.contract_claimed", { PS:FormatNumber(reward) })
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
            PS:Notify(ply, "n.new_day")
        end
    end
end)

local last_pause
timer.Create("Horde_PS_ContractSync", SYNC_INTERVAL, 0, function()
    local pause = PS:ContractPauseReason()
    local changed = pause ~= last_pause
    last_pause = pause
    for _, ply in ipairs(player.GetHumans()) do
        if ply.Horde_PS and ply.Horde_PS.loaded and (changed or ply.Horde_PS.contracts_sync) then PS:SyncContracts(ply) end
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

PS:LoadContractOverrides()
PS:RebuildContractTemplates()
