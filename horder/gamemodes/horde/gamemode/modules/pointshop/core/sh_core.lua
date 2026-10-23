local PS = HORDE.Pointshop
local C  = PS.Config

PS.Catalog      = PS.Catalog or {}   -- [id] = item
PS.CatalogOrder = PS.CatalogOrder or {}

PS.MAX_PRICE      = 10000000
PS.MAX_NAME_LEN   = 48
PS.MAX_MODEL_LEN  = 160

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

function PS:ClassDisplayName(class_name)
    local class = HORDE.classes and HORDE.classes[class_name]
    return class and (class.display_name or class.name) or tostring(class_name)
end

-- item.classes is nil (every class) or a set { [class_name] = true }.
function PS:CanClassUse(item, class_name)
    if not item then return false end
    if not item.classes or table.IsEmpty(item.classes) then return true end
    return item.classes[class_name] == true
end

function PS:ClassesText(item)
    if not item.classes or table.IsEmpty(item.classes) then return self.L and self:L("all_classes") or "All classes" end
    local names = {}
    for _, class in ipairs(self:GetClassList()) do
        if item.classes[class.name] then names[#names + 1] = class.display_name or class.name end
    end
    for name in pairs(item.classes) do
        if not (HORDE.classes and HORDE.classes[name]) then names[#names + 1] = name end
    end
    return table.concat(names, ", ")
end

function PS:DailyPrice(price, discount)
    return math.max(0, math.floor(price * (100 - discount) / 100))
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
