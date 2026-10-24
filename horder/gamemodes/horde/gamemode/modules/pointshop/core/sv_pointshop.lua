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

-- Results and notifications are sent as translation keys (see sh_lang.lua) so every
-- client shows them in its own language. args may contain { en = ..., ru = ... } tables.
function PS:SendResult(ply, ok, key, args)
    if not IsValid(ply) or not key then return end
    net.Start("Horde_PS_Result")
    net.WriteBool(ok)
    net.WriteString(key)
    self:WriteTable(args or {})
    net.Send(ply)
end

function PS:Notify(ply, key, args)
    if not IsValid(ply) or ply:IsBot() then return end
    net.Start("Horde_PS_Notify")
    net.WriteString(key)
    self:WriteTable(args or {})
    net.Send(ply)
end

function PS:SendAdminData(ply, kind, tbl)
    net.Start("Horde_PS_AdminData")
    net.WriteString(kind)
    self:WriteTable(tbl or {})
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

-- The model a player should wear right now: the one equipped for their current
-- subclass, otherwise the one equipped for its parent class.
function PS:GetActiveItem(ply, class)
    class = class or ply:Horde_GetClass()
    if not class then return nil end
    local sub = ply.Horde_GetCurrentSubclass and ply:Horde_GetCurrentSubclass() or class.name
    if sub and sub ~= class.name and self:ParentClass(sub) == class.name then
        local item = self:GetEquippedItem(ply, sub)
        if item then return item end
    end
    return self:GetEquippedItem(ply, class.name)
end

-- True when Horde should route the class model through Horde_SetClassModel for this player:
-- either a pointshop model is equipped for the class / subclass, or a previous one has to be removed.
function PS:ShouldApplyModel(ply, class)
    if not class then return false end
    return self:GetActiveItem(ply, class) ~= nil or ply.Horde_PS_Applied ~= nil
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
    local item = class and PS:GetActiveItem(self, class)
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

-- key: the class or subclass whose loadout changed (nil = always refresh).
function PS:RefreshModel(ply, key)
    local class = ply:Horde_GetClass()
    if not class or not ply:Alive() then return end
    if key and self:ParentClass(key) ~= class.name then return end
    if self:ShouldApplyModel(ply, class) then ply:Horde_SetClassModel(class) end
end

-- Subclass changes don't go through Horde_SetClass, so refresh the model afterwards.
PS.Base_SetSubclass = PS.Base_SetSubclass or plymeta.Horde_SetSubclass
function plymeta:Horde_SetSubclass(...)
    local ok = PS.Base_SetSubclass(self, ...)
    if ok then
        timer.Simple(0, function()
            if IsValid(self) then PS:RefreshModel(self) end
        end)
    end
    return ok
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

function PS:Buy(ply, id)
    local d = self:Data(ply)
    if not d.loaded then return false, "err.not_loaded" end
    local item = self.Catalog[id]
    if not item or not item.enabled then return false, "err.not_for_sale" end
    if d.owned[id] then return false, "err.already_own", { item.name } end
    if #self:GetInventory(ply) >= C.InventorySlots then return false, "err.inventory_full" end

    local price = self:GetPrice(id)
    if d.skulls < price then
        return false, "err.not_enough", { self:FormatNumber(price - d.skulls) }
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
    if not ok then return false, "err.db" end

    d.skulls = new_skulls
    d.owned[id] = true
    d.inventory[#d.inventory + 1] = id

    -- First model bought for the player's current class gets equipped automatically.
    local class = ply:Horde_GetClass()
    if class and not self:GetActiveItem(ply, class) and self:CanClassUse(item, class.name) then
        self:Equip(ply, class.name, id)
    end

    hook.Run("Horde_PS_ItemBought", ply, item, price)
    return true, "ok.purchased", { item.name, self:FormatNumber(price) }
end

function PS:Equip(ply, class_name, id)
    local d = self:Data(ply)
    if not d.loaded then return false, "err.not_loaded" end
    if not self:IsLoadoutKey(class_name) then return false, "err.unknown_class" end
    local sid = SteamKey(ply)

    if id == nil or id == "" then
        d.equipped[class_name] = nil
        DB.Query(DB.Prepare("DELETE FROM horde_ps_equipped WHERE steamid = ? AND class_name = ?;", sid, class_name))
        self:RefreshModel(ply, class_name)
        return true, "ok.default_model", { self:ClassNameArg(class_name) }
    end

    local item = self.Catalog[id]
    if not item or not d.owned[id] then return false, "err.not_owned" end
    if not self:CanClassUse(item, class_name) then
        return false, "err.class_cannot_wear", { item.name, self:ClassNameArg(class_name) }
    end

    d.equipped[class_name] = id
    DB.Query(DB.Prepare([[
        INSERT INTO horde_ps_equipped (steamid, class_name, item_id) VALUES (?, ?, ?)
        ON CONFLICT(steamid, class_name) DO UPDATE SET item_id = excluded.item_id;
    ]], sid, class_name, id))
    self:RefreshModel(ply, class_name)
    return true, "ok.equipped", { item.name, self:ClassNameArg(class_name) }
end

---------------------------------------------------------------------------
-- Admin
---------------------------------------------------------------------------

local function CleanClasses(list)
    if not istable(list) then return {} end
    local out, seen = {}, {}
    for _, name in ipairs(list) do
        if PS:IsLoadoutKey(name) and not seen[name] then
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

-- Admin actions return ok, message key, message args, opts.
-- opts.catalog = true rebuilds and rebroadcasts the catalog / daily store.
PS.AdminActions = PS.AdminActions or {}
local ADMIN_ACTIONS = PS.AdminActions
PS.CleanName = CleanName

function ADMIN_ACTIONS.update(ply, data)
    local item = PS.Catalog[data.id]
    if not item then return false, "err.unknown_item" end
    local price = CleanPrice(data.price)
    if not price then return false, "err.invalid_price" end
    local classes = CleanClasses(data.classes)
    local rarity = C.Rarities[data.rarity] and data.rarity or item.rarity

    if item.custom then
        local src = PS.Overrides.custom[item.id]
        if not src then return false, "err.unknown_item" end
        local model = data.model and PS:SanitizeModel(data.model)
        if data.model and not model then return false, "err.invalid_model" end
        if model and model ~= src.model and not util.IsValidModel(model) then
            return false, "err.model_missing", { model }
        end
        src.name    = CleanName(data.name) or src.name
        src.model   = model or src.model
        src.price   = price
        src.rarity  = rarity
        src.classes = classes
        PS.Overrides.items[item.id] = data.enabled == false and { disabled = true } or nil
    else
        local o = { price = price, classes = classes, rarity = rarity ~= item.base_rarity and rarity or nil }
        if data.enabled == false then o.disabled = true end
        PS.Overrides.items[item.id] = o
    end
    return true, "ok.saved", { item.name }, { catalog = true, save = true }
end

function ADMIN_ACTIONS.reset(ply, data)
    local item = PS.Catalog[data.id]
    if not item then return false, "err.unknown_item" end
    if item.custom then return false, "err.custom_no_default" end
    PS.Overrides.items[item.id] = nil
    return true, "ok.reset", { item.name }, { catalog = true, save = true }
end

function ADMIN_ACTIONS.add(ply, data)
    local name  = CleanName(data.name)
    local model = PS:SanitizeModel(data.model)
    local price = CleanPrice(data.price)
    if not name then return false, "err.enter_name" end
    if not model then return false, "err.invalid_model" end
    if not util.IsValidModel(model) then return false, "err.model_missing", { model } end
    if not price then return false, "err.invalid_price" end
    if table.Count(PS.Overrides.custom) >= 1000 then return false, "err.too_many" end

    local base = "custom_" .. (name:lower():gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", ""):sub(1, 24))
    if base == "custom_" then base = "custom_model" end
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
    if data.enabled == false then PS.Overrides.items[id] = { disabled = true } end
    return true, "ok.added", { name }, { catalog = true, save = true }
end

function ADMIN_ACTIONS.delete(ply, data)
    local item = PS.Catalog[data.id]
    if not item or not item.custom then return false, "err.only_custom_delete" end
    PS.Overrides.custom[item.id] = nil
    PS.Overrides.items[item.id] = nil
    return true, "ok.deleted", { item.name }, { catalog = true, save = true }
end

function ADMIN_ACTIONS.reroll(ply, data)
    local day = PS:GetDay()
    PS.DailyReroll = { day = day, n = (PS.DailyReroll.day == day and PS.DailyReroll.n or 0) + 1 }
    SetMeta("pointshop_daily_reroll", PS.DailyReroll)
    return true, "ok.rerolled", nil, { catalog = true }
end

---------------------------------------------------------------------------
-- Bank (admin: view / give / take / set balances, online or offline by SteamID)
---------------------------------------------------------------------------

local function ValidSteamID(sid)
    return isstring(sid) and sid:match("^STEAM_%d:%d:%d+$") ~= nil
end

local function OnlineBySteamID(sid)
    for _, p in ipairs(player.GetHumans()) do
        if p:SteamID() == sid then return p end
    end
end

local function OfflineSkulls(sid)
    if not PS:EnsureTables() then return nil end
    local v = DB.QueryValue("SELECT skulls FROM horde_ps_players WHERE steamid = ?;", sid)
    return v and tonumber(v) or nil
end

local function SendBankList(ply)
    local list = {}
    for _, p in ipairs(player.GetHumans()) do
        local d = PS:Data(p)
        list[#list + 1] = { name = p:Nick(), steamid = p:SteamID(), skulls = d.skulls, loaded = d.loaded }
    end
    table.sort(list, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
    PS:SendAdminData(ply, "bank", list)
end

function ADMIN_ACTIONS.bank_list(ply)
    SendBankList(ply)
end

function ADMIN_ACTIONS.bank_lookup(ply, data)
    local sid = isstring(data.steamid) and string.Trim(data.steamid):upper() or ""
    if not ValidSteamID(sid) then return false, "err.bad_steamid" end
    local online = OnlineBySteamID(sid)
    local skulls = online and PS:Data(online).skulls or OfflineSkulls(sid)
    PS:SendAdminData(ply, "bank_lookup", { steamid = sid, name = online and online:Nick() or nil, skulls = skulls, found = skulls ~= nil })
end

function ADMIN_ACTIONS.bank(ply, data)
    local sid = isstring(data.steamid) and string.Trim(data.steamid):upper() or ""
    if not ValidSteamID(sid) then return false, "err.bad_steamid" end
    local amount = math.floor(tonumber(data.amount) or -1)
    if amount < 0 or amount > 2000000000 then return false, "err.bad_amount" end
    local mode = data.mode
    if mode ~= "add" and mode ~= "remove" and mode ~= "set" then return false, "err.bad_amount" end

    local online = OnlineBySteamID(sid)
    local name = online and online:Nick() or sid
    local current
    if online then
        local d = PS:Data(online)
        if not d.loaded then return false, "err.target_not_loaded" end
        current = d.skulls
    else
        current = OfflineSkulls(sid)
        if current == nil then current = math.max(0, math.floor(tonumber(C.StartingSkulls) or 0)) end
    end

    local new = current
    if mode == "add" then new = current + amount elseif mode == "remove" then new = current - amount else new = amount end
    new = math.Clamp(new, 0, 2000000000)

    if online then
        PS:AddSkulls(online, new - current)
        PS:Notify(online, "n.balance_changed", { PS:FormatNumber(new - current), PS:FormatNumber(new) })
    else
        if not PS:EnsureTables() then return false, "err.db" end
        DB.Query(DB.Prepare([[
            INSERT INTO horde_ps_players (steamid, skulls) VALUES (?, ?)
            ON CONFLICT(steamid) DO UPDATE SET skulls = excluded.skulls;
        ]], sid, new))
    end

    SendBankList(ply)
    PS:SendAdminData(ply, "bank_lookup", { steamid = sid, name = online and online:Nick() or nil, skulls = new, found = true })
    return true, "ok.bank", { name, PS:FormatNumber(new) }
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
    local ok, key, args = PS:Buy(ply, id)
    PS:SendResult(ply, ok, key, args)
    PS:SyncPlayer(ply)
end)

net.Receive("Horde_PS_Equip", function(_, ply)
    if not IsValid(ply) or Throttle(ply, "equip") then return end
    local class_name = net.ReadString()
    local id = net.ReadString()
    local ok, key, args = PS:Equip(ply, class_name, id)
    PS:SendResult(ply, ok, key, args)
    PS:SyncPlayer(ply)
end)

net.Receive("Horde_PS_Admin", function(len, ply)
    if not IsValid(ply) or Throttle(ply, "admin", 0.15) then return end
    if not C.IsAdmin(ply) then
        PS:SendResult(ply, false, "err.no_access")
        return
    end
    local action = net.ReadString()
    local data = PS:ReadTable() or {}
    local fn = ADMIN_ACTIONS[action]
    if not fn then return end

    local ok, key, args, opts = fn(ply, data)
    if ok == nil then return end
    opts = opts or {}
    if ok then
        if opts.save then PS:SaveOverrides() end
        if opts.catalog then
            PS:Rebuild()
            PS:SendCatalog()
            PS:SendDaily()
            for _, p in ipairs(player.GetHumans()) do PS:SyncPlayer(p) end
        end
        local shown = {}
        for _, a in ipairs(args or {}) do shown[#shown + 1] = istable(a) and tostring(a.en) or tostring(a) end
        log(ply:Nick() .. " (" .. ply:SteamID() .. ") admin action '" .. action .. "': " .. key .. " " .. table.concat(shown, ", "))
    end
    PS:SendResult(ply, ok, key, args)
end)

function PS:Open(ply)
    if not IsValid(ply) or ply:IsBot() then return end
    if not self:Data(ply).loaded then
        if not self:LoadPlayer(ply) then
            self:Notify(ply, "n.db_unavailable")
            return
        end
        if self.LoadContracts then self:LoadContracts(ply) end
    end
    self:SyncAll(ply)
    net.Start("Horde_PS_Open")
    net.Send(ply)
end

concommand.Add("horde_pointshop", function(ply) PS:Open(ply) end)

hook.Remove("ShowSpare2", "Horde_PS_OpenF4")

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
        PS:Notify(target, "n.balance_changed", { PS:FormatNumber(amount), PS:FormatNumber(PS:GetSkulls(target)) })
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
