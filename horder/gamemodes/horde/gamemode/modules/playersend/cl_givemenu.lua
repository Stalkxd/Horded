if not CLIENT then return end

-- Client side of the give menu (see sv_givemenu.lua). The server decides
-- everything; this file only draws what it was sent and sends requests back.

local GIVE_MONEY  = 0
local GIVE_SKULLS = 1
local GIVE_WEAPON = 2

local CLOSE_RANGE = 220

local col_bg      = Color(25, 25, 25, 240)
local col_panel   = Color(40, 40, 40, 230)
local col_crimson = Color(220, 20, 60, 225)
local col_dim     = Color(80, 80, 80, 225)
local col_text    = Color(235, 235, 235)
local col_muted   = Color(160, 160, 160)
local col_bad     = Color(230, 110, 110)

surface.CreateFont("Horde_GiveMenu_Title", { font = "Arial", size = 22, weight = 700, extended = true })
surface.CreateFont("Horde_GiveMenu_Text",  { font = "Arial", size = 18, extended = true })
surface.CreateFont("Horde_GiveMenu_Small", { font = "Arial", size = 15, extended = true })

local frame
local state

local function SendGive(kind, writer)
    if not state or not IsValid(state.target) then return end
    net.Start("Horde_GiveMenu_Give")
        net.WriteEntity(state.target)
        net.WriteUInt(kind, 2)
        writer()
    net.SendToServer()
end

local function StyledButton(parent, text, onclick)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn.Label = text
    btn.Paint = function(self, w, h)
        local c = (not self:IsEnabled()) and col_dim or (self:IsHovered() and col_crimson or Color(60, 60, 60, 230))
        draw.RoundedBox(4, 0, 0, w, h, c)
        draw.SimpleText(self.Label, "Horde_GiveMenu_Text", w / 2, h / 2,
            self:IsEnabled() and col_text or col_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btn.DoClick = function(self)
        surface.PlaySound("UI/buttonclick.wav")
        onclick(self)
    end
    return btn
end

-- Money and Skulls share one layout: balance, amount box, quick picks, Give.
local function BuildCurrencyTab(parent, kind)
    local pnl = vgui.Create("DPanel", parent)
    pnl.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, col_panel) end

    local is_money = kind == GIVE_MONEY
    local balance = is_money and state.money or state.skulls
    local unit = is_money and "$" or ""
    local noun = is_money and "money" or "skulls"

    if is_money and state.budget then
        local lbl = vgui.Create("DLabel", pnl)
        lbl:SetFont("Horde_GiveMenu_Text")
        lbl:SetTextColor(col_muted)
        lbl:SetText("Money is shared in Budget mode, so it can't be given.")
        lbl:SetWrap(true)
        lbl:Dock(TOP)
        lbl:DockMargin(12, 12, 12, 0)
        lbl:SetTall(48)
        return pnl
    end

    local info = vgui.Create("DLabel", pnl)
    info:SetFont("Horde_GiveMenu_Text")
    info:SetTextColor(col_text)
    info:SetText(string.format("You have %s%d %s.", unit, balance, noun))
    info:Dock(TOP)
    info:DockMargin(12, 12, 12, 6)
    info:SetTall(22)

    local entry = vgui.Create("DTextEntry", pnl)
    entry:SetFont("Horde_GiveMenu_Text")
    entry:SetNumeric(true)
    entry:SetPlaceholderText("Amount")
    entry:Dock(TOP)
    entry:DockMargin(12, 0, 12, 6)
    entry:SetTall(30)

    local quick = vgui.Create("DPanel", pnl)
    quick:SetPaintBackground(false)
    quick:Dock(TOP)
    quick:DockMargin(12, 0, 12, 6)
    quick:SetTall(30)
    local picks = is_money and { 100, 500, 1000, 5000 } or { 1, 5, 10, 25 }
    local function add_pick(label, value)
        local b = StyledButton(quick, label, function() entry:SetValue(tostring(value)) end)
        b:Dock(LEFT)
        b:DockMargin(0, 0, 6, 0)
        b:SetWide(70)
        b:SetEnabled(value > 0 and value <= balance)
    end
    for _, v in ipairs(picks) do add_pick(unit .. v, v) end
    add_pick("All", balance)

    local give = StyledButton(pnl, "Give to " .. state.target:Nick(), function()
        local amount = math.floor(tonumber(entry:GetValue()) or 0)
        if amount <= 0 then return end
        if amount > balance then
            notification.AddLegacy("You don't have that many " .. noun .. ".", NOTIFY_ERROR, 3)
            return
        end
        SendGive(kind, function() net.WriteUInt(amount, 32) end)
    end)
    give:Dock(TOP)
    give:DockMargin(12, 6, 12, 12)
    give:SetTall(36)
    give:SetEnabled(balance > 0)

    return pnl
end

local function BuildWeaponsTab(parent)
    local pnl = vgui.Create("DPanel", parent)
    pnl.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, col_panel) end

    local info = vgui.Create("DLabel", pnl)
    info:SetFont("Horde_GiveMenu_Small")
    info:SetTextColor(col_muted)
    local class_name = state.subclass ~= "" and state.subclass or "Unknown class"
    info:SetText(string.format("%s: %s, %d / %d weight free", state.target:Nick(), class_name,
        state.free_weight, state.max_weight))
    info:Dock(TOP)
    info:DockMargin(12, 10, 12, 6)
    info:SetTall(18)

    local scroll = vgui.Create("DScrollPanel", pnl)
    scroll:Dock(FILL)
    scroll:DockMargin(8, 0, 8, 8)

    if #state.weapons == 0 then
        local lbl = scroll:Add("DLabel")
        lbl:SetFont("Horde_GiveMenu_Text")
        lbl:SetTextColor(col_muted)
        lbl:SetText("You have no weapons that can be given.")
        lbl:Dock(TOP)
        lbl:DockMargin(4, 4, 4, 4)
        lbl:SetTall(24)
        return pnl
    end

    for _, w in ipairs(state.weapons) do
        local row = scroll:Add("DPanel")
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 4)
        row:SetTall(46)
        row.Paint = function(_, rw, rh)
            draw.RoundedBox(4, 0, 0, rw, rh, Color(30, 30, 30, 230))
            draw.SimpleText(w.name, "Horde_GiveMenu_Text", 10, 6, col_text)
            local sub = string.format("Weight %d", w.weight)
            if not w.ok and w.reason ~= "" then sub = sub .. "  ·  " .. w.reason end
            draw.SimpleText(sub, "Horde_GiveMenu_Small", 10, 26, w.ok and col_muted or col_bad)
        end

        local btn = StyledButton(row, "Give", function(self)
            self:SetEnabled(false)
            SendGive(GIVE_WEAPON, function() net.WriteString(w.class) end)
        end)
        btn:Dock(RIGHT)
        btn:DockMargin(0, 8, 8, 8)
        btn:SetWide(80)
        btn:SetEnabled(w.ok)
    end

    return pnl
end

local function BuildMenu(active_tab)
    local old_x, old_y
    if IsValid(frame) then
        if active_tab then old_x, old_y = frame:GetPos() end
        frame:Remove()
    end

    frame = vgui.Create("DFrame")
    frame:SetSize(460, 380)
    if old_x then frame:SetPos(old_x, old_y) else frame:Center() end
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(true)
    frame.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, col_bg)
        draw.RoundedBoxEx(6, 0, 0, w, 34, col_crimson, true, true, false, false)
        local name = IsValid(state.target) and state.target:Nick() or "?"
        draw.SimpleText("Give to " .. name, "Horde_GiveMenu_Title", 12, 17, col_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    frame.Think = function(self)
        local lp = LocalPlayer()
        if not IsValid(state.target) or not state.target:Alive() or not IsValid(lp) or not lp:Alive()
            or lp:GetPos():DistToSqr(state.target:GetPos()) > CLOSE_RANGE * CLOSE_RANGE then
            self:Remove()
        end
    end
    frame.OnKeyCodePressed = function(self, code)
        if code == KEY_ESCAPE then self:Remove() end
    end

    local close = StyledButton(frame, "X", function() frame:Remove() end)
    close:SetPos(460 - 34, 3)
    close:SetSize(28, 28)

    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    sheet:DockMargin(4, 10, 4, 4)
    sheet.Paint = function() end

    local tabs = {
        { "Money",   BuildCurrencyTab(sheet, GIVE_MONEY) },
        { "Skulls",  BuildCurrencyTab(sheet, GIVE_SKULLS) },
        { "Weapons", BuildWeaponsTab(sheet) },
    }
    for _, t in ipairs(tabs) do
        local added = sheet:AddSheet(t[1], t[2])
        added.Tab.Paint = function(self, w, h)
            local c = sheet:GetActiveTab() == self and col_crimson or col_panel
            draw.RoundedBoxEx(4, 0, 0, w, h, c, true, true, false, false)
        end
        added.Tab:SetTextColor(col_text)
        if active_tab == t[1] then sheet:SetActiveTab(added.Tab) end
    end
    frame.Sheet = sheet
end

net.Receive("Horde_GiveMenu_Open", function()
    local target = net.ReadEntity()
    local s = {
        target      = target,
        budget      = net.ReadBool(),
        money       = net.ReadUInt(32),
        skulls      = net.ReadUInt(32),
        subclass    = net.ReadString(),
        free_weight = net.ReadUInt(16),
        max_weight  = net.ReadUInt(16),
        weapons     = {},
    }
    for i = 1, net.ReadUInt(8) do
        s.weapons[i] = {
            class  = net.ReadString(),
            name   = net.ReadString(),
            weight = net.ReadUInt(16),
            ok     = net.ReadBool(),
            reason = net.ReadString(),
        }
    end
    if not IsValid(target) then return end

    -- A refresh for the same player keeps the tab you were on.
    local active
    if IsValid(frame) and state and state.target == target and IsValid(frame.Sheet) then
        local tab = frame.Sheet:GetActiveTab()
        active = IsValid(tab) and tab:GetText() or nil
    end
    state = s
    BuildMenu(active)
end)
