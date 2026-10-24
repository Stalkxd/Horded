local PS = HORDE.Pointshop
local C  = PS.Config

PS.Catalog      = PS.Catalog or {}   -- [id] = item
PS.CatalogOrder = PS.CatalogOrder or {}

PS.MAX_PRICE      = 10000000
PS.MAX_NAME_LEN   = 48
PS.MAX_MODEL_LEN  = 160
PS.MAX_SLOTS      = 256

if SERVER then
    for _, name in ipairs({
        "Horde_PS_Open",
        "Horde_PS_Catalog",
        "Horde_PS_Player",
        "Horde_PS_Daily",
        "Horde_PS_Contracts",
        "Horde_PS_Request",
        "Horde_PS_Buy",
        "Horde_PS_Equip",
        "Horde_PS_Claim",
        "Horde_PS_Result",
        "Horde_PS_Notify",
        "Horde_PS_Admin",
        "Horde_PS_AdminData",
        "Horde_PS_Config",
        "Horde_PS_Sell",
        "Horde_PS_Spin",
        "Horde_PS_SpinResult",
    }) do
        util.AddNetworkString(name)
    end
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

function PS:GetRarity(key)
    return C.Rarities[key] or C.Rarities[C.DefaultRarity]
end

function PS:GetItem(id)
    return self.Catalog[id]
end

-- Current "pointshop day" index; changes once per day at the configured reset hour.
function PS:GetDay(t)
    return math.floor(((t or os.time()) + (tonumber(C.ResetUTCOffset) or 0) * 3600) / 86400)
end

function PS:SecondsUntilReset(t)
    t = t or os.time()
    local offset = (tonumber(C.ResetUTCOffset) or 0) * 3600
    return (self:GetDay(t) + 1) * 86400 - offset - t
end

-- Classes sorted by their Horde order.
function PS:GetClassList()
    local list = {}
    for name, class in pairs(HORDE.classes or {}) do
        list[#list + 1] = class
    end
    table.sort(list, function(a, b)
        if (a.order or 0) == (b.order or 0) then return a.name < b.name end
        return (a.order or 0) < (b.order or 0)
    end)
    return list
end

-- Loadout keys are class names ("Medic") or subclass names ("Hatcher").
-- A subclass's parent class, or the name itself for a base class.
function PS:ParentClass(name)
    local sub = HORDE.subclasses and HORDE.subclasses[name]
    if sub and sub.ParentClass then return sub.ParentClass end
    return name
end

function PS:IsLoadoutKey(name)
    if not isstring(name) then return false end
    return (HORDE.classes and HORDE.classes[name] ~= nil) or (HORDE.subclasses and HORDE.subclasses[name] ~= nil and HORDE.classes[self:ParentClass(name)] ~= nil)
end

-- Base class first, then its subclasses by Horde's sort order.
function PS:GetSubclasses(class_name)
    local list = { class_name }
    local subs = {}
    for name, sub in pairs(HORDE.subclasses or {}) do
        if sub.ParentClass == class_name then subs[#subs + 1] = sub end
    end
    table.sort(subs, function(a, b)
        if (a.SortOrder or 0) == (b.SortOrder or 0) then return a.PrintName < b.PrintName end
        return (a.SortOrder or 0) < (b.SortOrder or 0)
    end)
    for _, sub in ipairs(subs) do list[#list + 1] = sub.PrintName end
    return list
end

-- Class / subclass name in a language (sh_lang.lua has the translations).
function PS:ClassName(name, lang)
    lang = lang or self:LangId()
    local t = self.ClassNames and self.ClassNames[lang]
    if t and t[name] then return t[name] end
    local class = HORDE.classes and HORDE.classes[name]
    if class then return class.display_name or class.name end
    return tostring(name)
end

function PS:ClassDisplayName(name)
    return self:ClassName(name)
end

-- { en = ..., ru = ... } so server messages show class names in each client's language.
function PS:ClassNameArg(name)
    local out = {}
    for _, l in ipairs(self.Languages or { { id = "en" } }) do out[l.id] = self:ClassName(name, l.id) end
    return out
end

-- item.classes is nil (every class) or a set of class / subclass names.
-- A class name also allows that class's subclasses.
function PS:CanClassUse(item, key)
    if not item then return false end
    if not item.classes or table.IsEmpty(item.classes) then return true end
    if item.classes[key] then return true end
    local parent = self:ParentClass(key)
    return parent ~= key and item.classes[parent] == true
end

function PS:ClassesText(item)
    if not item.classes or table.IsEmpty(item.classes) then return self.L and self:L("all_classes") or "All classes" end
    local names, seen = {}, {}
    for _, class in ipairs(self:GetClassList()) do
        for _, key in ipairs(self:GetSubclasses(class.name)) do
            if item.classes[key] then
                names[#names + 1] = self:ClassName(key)
                seen[key] = true
            end
        end
    end
    for name in pairs(item.classes) do
        if not seen[name] then names[#names + 1] = self:ClassName(name) end
    end
    return table.concat(names, ", ")
end

function PS:DailyPrice(price, discount)
    return math.max(0, math.floor(price * (100 - discount) / 100))
end

-- Backpack size, always within 1 .. PS.MAX_SLOTS.
function PS:SlotCount()
    return math.Clamp(math.floor(tonumber(C.InventorySlots) or 64), 1, self.MAX_SLOTS)
end

-- Refund for selling an owned skin: C.SellPercent of what it costs in the store right now
-- (daily discounts included, so a discounted skin can never be sold for a profit).
function PS:SellPrice(id)
    local price = self:GetPrice(id)
    if not price then return 0 end
    local pct = math.Clamp(math.floor(tonumber(C.SellPercent) or 0), 0, 100)
    return math.max(0, math.floor(price * pct / 100))
end

function PS:FormatNumber(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local neg = s:sub(1, 1) == "-"
    if neg then s = s:sub(2) end
    s = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if s:sub(1, 1) == "," then s = s:sub(2) end
    return (neg and "-" or "") .. s
end

function PS:FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60)
end

function PS:SanitizeModel(model)
    if not isstring(model) then return nil end
    model = string.lower(string.Trim(model)):gsub("\\", "/")
    if #model == 0 or #model > self.MAX_MODEL_LEN then return nil end
    if not model:match("^models/[%w_%-%./]+%.mdl$") or model:find("..", 1, true) then return nil end
    return model
end

---------------------------------------------------------------------------
-- Deterministic RNG (so the daily store / contracts survive restarts and
-- never touch the global math.random state).
---------------------------------------------------------------------------

local RNG = {}
RNG.__index = RNG

function PS:NewRNG(seed)
    local state = math.floor(math.abs(tonumber(seed) or 1)) % 2147483647
    if state <= 0 then state = 1 end
    local rng = setmetatable({ state = state }, RNG)
    for _ = 1, 4 do rng:Next() end
    return rng
end

-- Park-Miller minimal standard generator; stays within double precision.
function RNG:Next()
    self.state = (self.state * 48271) % 2147483647
    return self.state
end

function RNG:Range(lo, hi)
    if hi <= lo then return lo end
    return lo + (self:Next() % (hi - lo + 1))
end

function RNG:Pick(list)
    if #list == 0 then return nil, nil end
    local i = self:Range(1, #list)
    return list[i], i
end

---------------------------------------------------------------------------
-- Casino (slot machine) rules, shared so the CASINO tab shows exactly what the
-- server pays. The server rolls the reels; clients only animate the result.
---------------------------------------------------------------------------

function PS:CasinoSymbols()
    local list = {}
    for _, s in ipairs(C.CasinoSymbols or {}) do
        if isstring(s.id) and (tonumber(s.weight) or 0) > 0 then list[#list + 1] = s end
    end
    return list
end

function PS:CasinoSymbol(id)
    for _, s in ipairs(C.CasinoSymbols or {}) do
        if s.id == id then return s end
    end
end

-- reels: three symbol ids. Returns the payout multiplier and the combination key
-- ("three:<id>", "special2", "special1") or nil for a loss.
function PS:CasinoEvaluate(reels)
    local a, b, c = reels[1], reels[2], reels[3]
    if a == b and b == c then
        local s = self:CasinoSymbol(a)
        if s then return tonumber(s.pay) or 0, "three:" .. a end
    end
    local special = C.CasinoSpecial
    local n = 0
    for i = 1, 3 do if reels[i] == special then n = n + 1 end end
    if n == 2 and (tonumber(C.CasinoSpecialTwo) or 0) > 0 then return tonumber(C.CasinoSpecialTwo), "special2" end
    if n == 1 and (tonumber(C.CasinoSpecialOne) or 0) > 0 then return tonumber(C.CasinoSpecialOne), "special1" end
    return 0, nil
end

-- Every winning combination with its multiplier and probability (highest payout first),
-- plus the overall return-to-player (0..1) and hit rate.
function PS:CasinoPaytable()
    local syms = self:CasinoSymbols()
    local total = 0
    for _, s in ipairs(syms) do total = total + s.weight end
    local combos, by_key = {}, {}
    local rtp, hit = 0, 0
    if total <= 0 then return combos, 0, 0 end
    for _, a in ipairs(syms) do
        for _, b in ipairs(syms) do
            for _, c in ipairs(syms) do
                local p = (a.weight / total) * (b.weight / total) * (c.weight / total)
                local mult, key = self:CasinoEvaluate({ a.id, b.id, c.id })
                if key and mult > 0 then
                    rtp = rtp + p * mult
                    hit = hit + p
                    local e = by_key[key]
                    if not e then
                        e = { key = key, mult = mult, p = 0, symbol = key:match("^three:(.+)$") }
                        by_key[key] = e
                        combos[#combos + 1] = e
                    end
                    e.p = e.p + p
                end
            end
        end
    end
    table.sort(combos, function(x, y)
        if x.mult == y.mult then return x.key < y.key end
        return x.mult > y.mult
    end)
    return combos, rtp, hit
end

-- Quick bet buttons inside the current min / max limits.
function PS:CasinoBets()
    local lo, hi = math.max(1, math.floor(tonumber(C.CasinoMinBet) or 1)), math.floor(tonumber(C.CasinoMaxBet) or 0)
    local list, seen = {}, {}
    for _, v in ipairs(C.CasinoBets or {}) do
        v = math.floor(tonumber(v) or 0)
        if v >= lo and v <= hi and not seen[v] then
            seen[v] = true
            list[#list + 1] = v
        end
    end
    if #list == 0 and hi >= lo then
        list[1] = lo
        if hi > lo then list[2] = hi end
    end
    table.sort(list)
    return list
end

---------------------------------------------------------------------------
-- Catalog
-- Merges config items, admin-made custom items and admin overrides into
-- PS.Catalog. Runs on the server; clients receive the result.
---------------------------------------------------------------------------

local function ToClassSet(list)
    if not istable(list) then return nil end
    local set = {}
    for k, v in pairs(list) do
        if isstring(v) then set[v] = true elseif isstring(k) and v == true then set[k] = true end
    end
    if table.IsEmpty(set) then return nil end
    return set
end
PS.ToClassSet = ToClassSet

function PS:BuildCatalog(overrides)
    overrides = overrides or {}
    local item_over = overrides.items or {}
    local catalog, order = {}, {}

    local function add(src, custom)
        if not isstring(src.id) or not isstring(src.model) or catalog[src.id] then return end
        local item = {
            id         = src.id,
            name       = tostring(src.name or src.id),
            model      = src.model,
            base_price = math.Clamp(math.floor(tonumber(src.price) or 0), 0, self.MAX_PRICE),
            rarity     = C.Rarities[src.rarity] and src.rarity or C.DefaultRarity,
            base_rarity = C.Rarities[src.rarity] and src.rarity or C.DefaultRarity,
            base_classes = ToClassSet(src.classes),
            custom     = custom or nil,
            enabled    = true,
        }
        item.price   = item.base_price
        item.classes = item.base_classes

        local o = item_over[item.id]
        if istable(o) then
            if tonumber(o.price) then item.price = math.Clamp(math.floor(tonumber(o.price)), 0, self.MAX_PRICE) end
            if o.classes ~= nil then item.classes = ToClassSet(o.classes) end
            if o.rarity and C.Rarities[o.rarity] then item.rarity = o.rarity end
            if o.disabled then item.enabled = false end
            item.overridden = true
        end

        catalog[item.id] = item
        order[#order + 1] = item.id
    end

    for _, src in ipairs(C.Items or {}) do add(src, false) end
    for _, src in SortedPairs(overrides.custom or {}) do add(src, true) end

    self.Catalog, self.CatalogOrder = catalog, order
    return catalog
end

-- Items that can show up in the store (enabled, priced).
function PS:GetStoreItems()
    local list = {}
    for _, id in ipairs(self.CatalogOrder) do
        local item = self.Catalog[id]
        if item and item.enabled then list[#list + 1] = item end
    end
    return list
end

---------------------------------------------------------------------------
-- Net helpers (compressed JSON tables)
---------------------------------------------------------------------------

function PS:WriteTable(tbl)
    local data = util.Compress(util.TableToJSON(tbl or {}))
    net.WriteUInt(#data, 32)
    net.WriteData(data, #data)
end

function PS:ReadTable()
    return HORDE:ReadCompressedJSON()
end
