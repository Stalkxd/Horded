if not CLIENT then return end

local PS = HORDE.Pointshop
local C  = PS.Config

PS.Player    = PS.Player or { loaded = false, skulls = 0, inventory = {}, owned = {}, equipped = {}, admin = false }
PS.Daily     = PS.Daily or { day = 0, deals = {}, reset_at = 0 }
PS.Contracts = PS.Contracts or { list = {}, reset_at = 0 }

-- Called after any state update; the open menu listens to this.
local function Changed(what)
    hook.Run("Horde_PS_Updated", what)
end

net.Receive("Horde_PS_Catalog", function()
    local list = PS:ReadTable()
    if not istable(list) then return end
    local catalog, order = {}, {}
    for _, item in ipairs(list) do
        if isstring(item.id) then
            catalog[item.id] = item
            order[#order + 1] = item.id
        end
    end
    PS.Catalog, PS.CatalogOrder = catalog, order
    Changed("catalog")
end)

net.Receive("Horde_PS_Player", function()
    local data = PS:ReadTable()
    if not istable(data) then return end
    local p = PS.Player
    p.loaded    = data.loaded == true
    p.skulls    = tonumber(data.skulls) or 0
    p.inventory = istable(data.inventory) and data.inventory or {}
    p.equipped  = istable(data.equipped) and data.equipped or {}
    p.admin     = data.admin == true
    p.owned = {}
    for _, id in ipairs(p.inventory) do p.owned[id] = true end
    Changed("player")
end)

net.Receive("Horde_PS_Daily", function()
    local day = net.ReadUInt(32)
    local left = net.ReadUInt(32)
    local deals = {}
    for i = 1, net.ReadUInt(8) do
        deals[i] = { id = net.ReadString(), discount = net.ReadUInt(7) }
    end
    PS.Daily = { day = day, deals = deals, reset_at = RealTime() + left }
    Changed("daily")
end)

net.Receive("Horde_PS_Contracts", function()
    local left = net.ReadUInt(32)
    local list = PS:ReadTable()
    PS.Contracts = { list = istable(list) and list or {}, reset_at = RealTime() + left }
    Changed("contracts")
end)

-- UI sound helper (respects the Settings toggle).
PS.SoundConVar   = CreateClientConVar("horde_ps_sounds", "1", true, false, "Pointshop interface sounds")
PS.SpinConVar    = CreateClientConVar("horde_ps_autospin", "1", true, false, "Rotate pointshop model previews")
PS.KeyConVar     = CreateClientConVar("horde_ps_menu_key", "0", true, false, "Key code that toggles the pointshop (0 = none)")

function PS:Sound(path)
    if self.SoundConVar:GetBool() then surface.PlaySound(path) end
end

local function ReadArgs()
    local args = PS:ReadTable()
    return istable(args) and args or {}
end

net.Receive("Horde_PS_Result", function()
    local ok, key = net.ReadBool(), net.ReadString()
    local args = ReadArgs()
    local msg = PS:L(key, unpack(args))
    PS:Sound(ok and "buttons/button14.wav" or "buttons/button10.wav")
    if PS.UI and PS.UI.Toast and IsValid(PS.Menu) then
        PS.UI.Toast(msg, ok)
    elseif msg ~= "" then
        chat.AddText(Color(200, 28, 28), "[" .. PS:L("title_b") .. "] ", color_white, msg)
    end
end)

net.Receive("Horde_PS_Notify", function()
    local key = net.ReadString()
    local msg = PS:L(key, unpack(ReadArgs()))
    if HORDE.PlayNotification then
        HORDE:PlayNotification(msg, 0)
    else
        chat.AddText(Color(200, 28, 28), "[" .. PS:L("title_b") .. "] ", color_white, msg)
    end
    if IsValid(PS.Menu) and PS.UI and PS.UI.Toast then PS.UI.Toast(msg, true) end
end)

-- Admin-only data (bank balances, contract templates).
PS.AdminData = PS.AdminData or {}
net.Receive("Horde_PS_AdminData", function()
    local kind = net.ReadString()
    local data = PS:ReadTable()
    PS.AdminData[kind] = istable(data) and data or {}
    Changed("admin_" .. kind)
end)

net.Receive("Horde_PS_Open", function()
    PS:OpenMenu()
end)

---------------------------------------------------------------------------
-- Client helpers / requests
---------------------------------------------------------------------------

function PS:GetDailyDeal(id)
    for _, deal in ipairs(self.Daily.deals) do
        if deal.id == id then return deal end
    end
end

function PS:GetPrice(id)
    local item = self.Catalog[id]
    if not item then return 0, 0 end
    local deal = self:GetDailyDeal(id)
    if deal then return self:DailyPrice(item.price, deal.discount), deal.discount end
    return item.price, 0
end

function PS:Owns(id)
    return self.Player.owned[id] == true
end

function PS:GetEquipped(class_name)
    local id = self.Player.equipped[class_name]
    local item = id and self:Owns(id) and self.Catalog[id]
    if item and self:CanClassUse(item, class_name) then return item end
end

-- Classes an item is currently equipped on.
function PS:EquippedOn(id)
    local list = {}
    for _, class in ipairs(self:GetClassList()) do
        if self.Player.equipped[class.name] == id then list[#list + 1] = class.display_name or class.name end
    end
    return list
end

function PS:LocalClassName()
    local ply = LocalPlayer()
    local class = IsValid(ply) and ply.Horde_GetClass and ply:Horde_GetClass()
    return class and class.name or nil
end

function PS:RequestBuy(id)
    net.Start("Horde_PS_Buy")
    net.WriteString(id)
    net.SendToServer()
end

function PS:RequestEquip(class_name, id)
    net.Start("Horde_PS_Equip")
    net.WriteString(class_name)
    net.WriteString(id or "")
    net.SendToServer()
end

function PS:RequestClaim(index)
    net.Start("Horde_PS_Claim")
    net.WriteUInt(index, 8)
    net.SendToServer()
end

function PS:RequestAdmin(action, data)
    net.Start("Horde_PS_Admin")
    net.WriteString(action)
    self:WriteTable(data or {})
    net.SendToServer()
end

function PS:RequestSync()
    net.Start("Horde_PS_Request")
    net.SendToServer()
end

concommand.Add("horde_pointshop_toggle", function()
    if IsValid(PS.Menu) then PS.Menu:Remove() else RunConsoleCommand("horde_pointshop") end
end)

---------------------------------------------------------------------------
-- Custom open/close key (Settings tab). Polled so it also works in singleplayer.
---------------------------------------------------------------------------

local key_was_down = false
local chat_open = false
hook.Add("StartChat", "Horde_PS_Chat", function() chat_open = true end)
hook.Add("FinishChat", "Horde_PS_Chat", function() chat_open = false end)

hook.Add("Think", "Horde_PS_MenuKey", function()
    local key = PS.KeyConVar:GetInt()
    if key <= 0 then key_was_down = false return end
    local down = input.IsButtonDown(key)
    if down and not key_was_down and not chat_open and not gui.IsGameUIVisible() then
        local focus = vgui.GetKeyboardFocus()
        if IsValid(PS.Menu) then
            -- Don't close while typing in a text field or binding a key.
            if not (IsValid(focus) and (focus:GetClassName() == "TextEntry" or focus.Binding)) and not PS.Binding then
                PS.Menu:Remove()
            end
        elseif not IsValid(focus) then
            RunConsoleCommand("horde_pointshop")
        end
    end
    key_was_down = down
end)
