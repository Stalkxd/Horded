if not CLIENT then return end

local PS = HORDE.Pointshop
local C  = PS.Config

PS.UI = PS.UI or {}
local UI = PS.UI

---------------------------------------------------------------------------
-- Palette: black / white / red
---------------------------------------------------------------------------

UI.Col = {
    bg         = Color(8, 8, 8),
    bg2        = Color(16, 16, 16),
    panel      = Color(22, 22, 22),
    panel2     = Color(32, 32, 32),
    slot       = Color(26, 26, 26),
    slot_hi    = Color(42, 42, 42),
    border     = Color(58, 58, 58),
    border_hi  = Color(110, 110, 110),
    red        = Color(200, 28, 28),
    red_dark   = Color(96, 10, 10),
    red_deep   = Color(45, 4, 4),
    red_light  = Color(240, 72, 72),
    white      = Color(242, 242, 242),
    text       = Color(222, 222, 222),
    muted      = Color(145, 145, 145),
    dim        = Color(85, 85, 85),
    shadow     = Color(0, 0, 0, 200),
}
local COL = UI.Col

UI.Mat = {
    grad_r  = Material("gui/gradient"),
    grad_d  = Material("gui/gradient_down"),
    grad_u  = Material("gui/gradient_up"),
    center  = Material("gui/center_gradient"),
    skull   = Material(C.CurrencyIcon, "smooth mips"),
}
local MAT = UI.Mat

local class_icons = {}
function UI.ClassIcon(class)
    local key = class.icon or (class.name .. ".png")
    if class_icons[key] == nil then
        local mat = Material(string.lower(key), "smooth mips")
        if mat:IsError() then mat = Material(string.lower(class.name) .. ".png", "smooth mips") end
        class_icons[key] = mat
    end
    return class_icons[key]
end

---------------------------------------------------------------------------
-- Scaling & fonts
---------------------------------------------------------------------------

function UI.S(x)
    return math.Round(x * math.Clamp(ScrH() / 1080, 0.65, 1.6))
end
local S = UI.S

function UI.CreateFonts()
    local head, body = "Trebuchet MS", "Tahoma"
    surface.CreateFont("HordePS_Logo",     { font = head, size = S(30), weight = 900, extended = true })
    surface.CreateFont("HordePS_Tab",      { font = head, size = S(19), weight = 800, extended = true })
    surface.CreateFont("HordePS_Header",   { font = head, size = S(22), weight = 800, extended = true })
    surface.CreateFont("HordePS_Big",      { font = head, size = S(36), weight = 900, extended = true })
    surface.CreateFont("HordePS_Huge",     { font = head, size = S(48), weight = 900, extended = true })
    surface.CreateFont("HordePS_ItemName", { font = head, size = S(15), weight = 700, extended = true })
    surface.CreateFont("HordePS_Button",   { font = head, size = S(16), weight = 800, extended = true })
    surface.CreateFont("HordePS_Body",     { font = body, size = S(16), weight = 500, extended = true })
    surface.CreateFont("HordePS_BodyBold", { font = body, size = S(16), weight = 800, extended = true })
    surface.CreateFont("HordePS_Small",    { font = body, size = S(13), weight = 500, extended = true })
    surface.CreateFont("HordePS_Price",    { font = head, size = S(20), weight = 900, extended = true })
    surface.CreateFont("HordePS_Strike",   { font = body, size = S(14), weight = 500, strikeout = true, extended = true })
end
UI.CreateFonts()

hook.Add("OnScreenSizeChanged", "Horde_PS_Fonts", function()
    UI.CreateFonts()
    if IsValid(PS.Menu) then PS.Menu:Remove() end
end)

---------------------------------------------------------------------------
-- Drawing helpers
---------------------------------------------------------------------------

function UI.Box(x, y, w, h, col)
    surface.SetDrawColor(col)
    surface.DrawRect(x, y, w, h)
end

function UI.Outline(x, y, w, h, col, t)
    surface.SetDrawColor(col)
    for i = 0, (t or 1) - 1 do
        surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
    end
end

-- Vertical gradient (top colour -> bottom colour).
function UI.GradV(x, y, w, h, top, bottom)
    surface.SetDrawColor(bottom)
    surface.DrawRect(x, y, w, h)
    surface.SetMaterial(MAT.grad_d)
    surface.SetDrawColor(top)
    surface.DrawTexturedRect(x, y, w, h)
end

-- Horizontal gradient (left colour -> right colour).
function UI.GradH(x, y, w, h, left, right)
    surface.SetDrawColor(right)
    surface.DrawRect(x, y, w, h)
    surface.SetMaterial(MAT.grad_r)
    surface.SetDrawColor(left)
    surface.DrawTexturedRect(x, y, w, h)
end

function UI.Text(text, font, x, y, col, ax, ay)
    return draw.SimpleText(text, font, x, y, col or COL.text, ax or TEXT_ALIGN_LEFT, ay or TEXT_ALIGN_TOP)
end

function UI.TextShadow(text, font, x, y, col, ax, ay)
    draw.SimpleText(text, font, x + 1, y + 1, COL.shadow, ax or TEXT_ALIGN_LEFT, ay or TEXT_ALIGN_TOP)
    return draw.SimpleText(text, font, x, y, col or COL.text, ax or TEXT_ALIGN_LEFT, ay or TEXT_ALIGN_TOP)
end

function UI.Skull(x, y, size, col)
    surface.SetMaterial(MAT.skull)
    surface.SetDrawColor(col or COL.white)
    surface.DrawTexturedRect(x, y, size, size)
end

-- Skull icon + amount, vertically centred on y. Returns the drawn width.
function UI.Price(amount, font, x, y, col, align)
    local txt = PS:FormatNumber(amount)
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(txt)
    local icon = math.floor(th * 0.95)
    local gap = S(4)
    local w = icon + gap + tw
    if align == TEXT_ALIGN_RIGHT then x = x - w elseif align == TEXT_ALIGN_CENTER then x = x - w / 2 end
    UI.Skull(x, y - icon / 2, icon, col)
    UI.Text(txt, font, x + icon + gap, y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    return w
end

-- Standard section heading: white title with a red accent bar and fading underline.
function UI.Heading(text, x, y, w, sub)
    UI.Box(x, y, S(4), S(24), COL.red)
    UI.Text(string.upper(text), "HordePS_Header", x + S(12), y + S(12), COL.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    if sub then
        surface.SetFont("HordePS_Header")
        local tw = surface.GetTextSize(string.upper(text))
        UI.Text(sub, "HordePS_Small", x + S(22) + tw, y + S(13), COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    UI.GradH(x, y + S(28), w, 1, COL.red, Color(0, 0, 0, 0))
end

function UI.RarityColor(item)
    return PS:GetRarity(item and item.rarity).color
end

---------------------------------------------------------------------------
-- Button
---------------------------------------------------------------------------

local BUTTON = {}

function BUTTON:Init()
    self:SetText("")
    self.Label = ""
    self.Style = "dark"   -- dark | red | ghost
    self.Font = "HordePS_Button"
    self.Hover = 0
end

function BUTTON:SetLabel(text) self.Label = text end
function BUTTON:SetStyle(style) self.Style = style end
function BUTTON:SetLabelFont(font) self.Font = font end

function BUTTON:Paint(w, h)
    local enabled = self:IsEnabled()
    self.Hover = Lerp(FrameTime() * 14, self.Hover, (enabled and self:IsHovered()) and 1 or 0)
    local hv = self.Hover

    if not enabled then
        UI.Box(0, 0, w, h, COL.panel)
        UI.Outline(0, 0, w, h, COL.border)
        UI.Text(string.upper(self.Label), self.Font, w / 2, h / 2, COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    if self.Style == "red" then
        UI.GradV(0, 0, w, h, Color(225 + 30 * hv, 40 + 30 * hv, 40 + 30 * hv), COL.red_dark)
        UI.Outline(0, 0, w, h, Color(255, 90, 90, 120 + 135 * hv))
    elseif self.Style == "ghost" then
        UI.Box(0, 0, w, h, Color(255, 255, 255, 10 * hv))
        UI.Outline(0, 0, w, h, Color(110 + 100 * hv, 110, 110))
    else
        UI.GradV(0, 0, w, h, Color(48 + 20 * hv, 44, 44), Color(20 + 40 * hv, 16, 16))
        UI.Outline(0, 0, w, h, Color(70 + 130 * hv, 60, 60))
    end
    if self:IsDown() then UI.Box(0, 0, w, h, Color(0, 0, 0, 60)) end
    UI.TextShadow(string.upper(self.Label), self.Font, w / 2, h / 2, COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function BUTTON:OnCursorEntered()
    if self:IsEnabled() then surface.PlaySound("ui/buttonrollover.wav") end
end

vgui.Register("HordePS_Button", BUTTON, "DButton")

function UI.Button(parent, label, style, onclick)
    local b = vgui.Create("HordePS_Button", parent)
    b:SetLabel(label)
    b:SetStyle(style or "dark")
    b.DoClick = function(s)
        surface.PlaySound("ui/buttonclick.wav")
        if onclick then onclick(s) end
    end
    return b
end

---------------------------------------------------------------------------
-- Scroll panel with a thin red scrollbar
---------------------------------------------------------------------------

function UI.Scroll(parent)
    local sp = vgui.Create("DScrollPanel", parent)
    local bar = sp:GetVBar()
    bar:SetWide(S(8))
    bar:SetHideButtons(true)
    bar.Paint = function(_, w, h) UI.Box(0, 0, w, h, COL.bg2) end
    bar.btnGrip.Paint = function(s, w, h)
        UI.Box(S(1), 0, w - S(2), h, s:IsHovered() and COL.red_light or COL.red)
    end
    return sp
end

---------------------------------------------------------------------------
-- Inputs
---------------------------------------------------------------------------

function UI.StyleEntry(entry)
    entry:SetFont("HordePS_Body")
    entry.Paint = function(s, w, h)
        UI.Box(0, 0, w, h, COL.bg)
        UI.Outline(0, 0, w, h, s:HasFocus() and COL.red or COL.border)
        if s:GetValue() == "" and s.Placeholder and not s:HasFocus() then
            UI.Text(s.Placeholder, "HordePS_Body", S(8), h / 2, COL.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        s:DrawTextEntryText(COL.white, COL.red, COL.white)
    end
    return entry
end

function UI.Entry(parent, placeholder)
    local e = vgui.Create("DTextEntry", parent)
    e.Placeholder = placeholder
    return UI.StyleEntry(e)
end

function UI.Combo(parent)
    local cb = vgui.Create("DComboBox", parent)
    cb:SetFont("HordePS_Body")
    cb:SetTextColor(COL.white)
    cb.Paint = function(s, w, h)
        UI.GradV(0, 0, w, h, COL.panel2, COL.bg2)
        UI.Outline(0, 0, w, h, s:IsHovered() and COL.red or COL.border)
    end
    if IsValid(cb.DropButton) then
        cb.DropButton.Paint = function(_, w, h)
            draw.NoTexture()
            surface.SetDrawColor(COL.red)
            local cx, cy, r = w / 2, h / 2, S(4)
            surface.DrawPoly({ { x = cx - r, y = cy - r / 2 }, { x = cx + r, y = cy - r / 2 }, { x = cx, y = cy + r / 2 } })
        end
    end
    local open = cb.OpenMenu
    cb.OpenMenu = function(s, ...)
        open(s, ...)
        if IsValid(s.Menu) then UI.StyleMenu(s.Menu) end
    end
    return cb
end

function UI.StyleMenu(menu)
    menu.Paint = function(_, w, h)
        UI.Box(0, 0, w, h, COL.bg2)
        UI.Outline(0, 0, w, h, COL.red_dark)
    end
    for _, opt in ipairs(menu:GetCanvas():GetChildren()) do
        if opt.SetTextColor then
            opt:SetTextColor(COL.white)
            opt:SetFont("HordePS_Body")
            opt.Paint = function(s, w, h)
                if s:IsHovered() then UI.GradH(0, 0, w, h, COL.red, COL.red_deep) end
            end
        end
    end
end

function UI.Menu()
    local m = DermaMenu()
    local add = m.AddOption
    m.AddOption = function(s, ...)
        local opt = add(s, ...)
        opt:SetTextColor(COL.white)
        opt:SetFont("HordePS_Body")
        opt.Paint = function(o, w, h)
            if o:IsHovered() then UI.GradH(0, 0, w, h, COL.red, COL.red_deep) end
        end
        return opt
    end
    m.Paint = function(_, w, h)
        UI.Box(0, 0, w, h, COL.bg2)
        UI.Outline(0, 0, w, h, COL.red_dark)
    end
    return m
end

function UI.Check(parent, label, value, onchange)
    local p = vgui.Create("DButton", parent)
    p:SetText("")
    p.Value = value and true or false
    p.Label = label
    p.Paint = function(s, w, h)
        local box = h - S(6)
        local y = S(3)
        UI.Box(0, y, box, box, COL.bg)
        UI.Outline(0, y, box, box, s:IsHovered() and COL.red_light or COL.border)
        if s.Value then UI.Box(S(4), y + S(4), box - S(8), box - S(8), COL.red) end
        UI.Text(s.Label, "HordePS_Body", box + S(8), h / 2, s.Value and COL.white or COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    p.DoClick = function(s)
        s.Value = not s.Value
        surface.PlaySound("ui/buttonclick.wav")
        if onchange then onchange(s.Value) end
    end
    p.SetValue = function(s, v) s.Value = v and true or false end
    p.GetValue = function(s) return s.Value end
    return p
end

---------------------------------------------------------------------------
-- Item tooltip (TF2 style hover card)
---------------------------------------------------------------------------

function UI.ShowTooltip(item, lines)
    UI.HideTooltip()
    if not item then return end
    local tip = vgui.Create("DPanel")
    tip:SetDrawOnTop(true)
    tip:SetMouseInputEnabled(false)
    tip:SetKeyboardInputEnabled(false)

    local rarity = PS:GetRarity(item.rarity)
    local rows = {
        { item.name, "HordePS_Header", rarity.color },
        { rarity.name .. " Playermodel", "HordePS_Small", COL.muted },
        { "Usable by: " .. PS:ClassesText(item), "HordePS_Body", COL.text },
    }
    for _, l in ipairs(lines or {}) do rows[#rows + 1] = l end

    local pad, w, h = S(12), S(220), S(10)
    for _, r in ipairs(rows) do
        surface.SetFont(r[2])
        local tw, th = surface.GetTextSize(r[1])
        w = math.max(w, tw + pad * 2)
        r.h = th + S(3)
        h = h + r.h
    end
    tip:SetSize(w, h + pad)

    tip.Paint = function(_, pw, ph)
        UI.Box(0, 0, pw, ph, Color(10, 10, 10, 245))
        UI.GradV(0, 0, pw, S(36), ColorAlpha(rarity.color, 40), Color(0, 0, 0, 0))
        UI.Outline(0, 0, pw, ph, ColorAlpha(rarity.color, 170))
        local y = pad
        for _, r in ipairs(rows) do
            UI.Text(r[1], r[2], pw / 2, y, r[3], TEXT_ALIGN_CENTER)
            y = y + r.h
        end
    end
    tip.Think = function(s)
        local mx, my = input.GetCursorPos()
        local x, y = mx + S(18), my + S(18)
        if x + s:GetWide() > ScrW() then x = mx - s:GetWide() - S(8) end
        if y + s:GetTall() > ScrH() then y = my - s:GetTall() - S(8) end
        s:SetPos(x, y)
    end
    tip:Think()
    UI.Tip = tip
end

function UI.HideTooltip()
    if IsValid(UI.Tip) then UI.Tip:Remove() end
    UI.Tip = nil
end

---------------------------------------------------------------------------
-- Item slot (backpack cell)
---------------------------------------------------------------------------

local SLOT = {}

function SLOT:Init()
    self:SetText("")
    self.Hover = 0
    self.Icon = vgui.Create("ModelImage", self)
    self.Icon:SetMouseInputEnabled(false)
    self.Icon:SetVisible(false)
end

-- opts: { badge = "EQUIPPED", selected = bool, tooltip = { lines }, show_name = bool }
function SLOT:SetItem(item, opts)
    self.Item = item
    self.Opts = opts or {}
    if item then
        self.Icon:SetModel(item.model)
        self.Icon:SetVisible(true)
    else
        self.Icon:SetVisible(false)
    end
    self:InvalidateLayout()
end

function SLOT:PerformLayout(w, h)
    local name_h = (self.Opts and self.Opts.show_name) and S(18) or 0
    local size = math.min(w, h - name_h) - S(8)
    self.Icon:SetSize(size, size)
    self.Icon:SetPos((w - size) / 2, S(4))
end

function SLOT:Paint(w, h)
    local item, opts = self.Item, self.Opts or {}
    self.Hover = Lerp(FrameTime() * 14, self.Hover, self:IsHovered() and 1 or 0)
    local hv = self.Hover

    if not item then
        UI.GradV(0, 0, w, h, COL.slot, COL.bg)
        UI.Outline(0, 0, w, h, Color(40, 40, 40))
        if opts.empty_label then
            UI.Text(opts.empty_label, "HordePS_Small", w / 2, h / 2, COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        return
    end

    local rc = UI.RarityColor(item)
    UI.GradV(0, 0, w, h, Color(40 + 14 * hv, 40 + 8 * hv, 40 + 8 * hv), COL.bg)
    UI.GradV(0, h * 0.45, w, h * 0.55, Color(0, 0, 0, 0), ColorAlpha(rc, 28 + 30 * hv))
    UI.Box(0, h - S(3), w, S(3), rc)

    local border = opts.selected and COL.red_light or Color(60 + 140 * hv, 60 + 40 * hv, 60 + 40 * hv)
    UI.Outline(0, 0, w, h, border, opts.selected and 2 or 1)
end

function SLOT:PaintOver(w, h)
    local item, opts = self.Item, self.Opts or {}
    if not item then return end
    if opts.show_name then
        UI.Box(0, h - S(21), w, S(18), Color(0, 0, 0, 170))
        local name = item.name
        surface.SetFont("HordePS_Small")
        while #name > 3 and surface.GetTextSize(name) > w - S(6) do name = name:sub(1, -2) end
        if name ~= item.name then name = name:sub(1, -2) .. "…" end
        UI.Text(name, "HordePS_Small", w / 2, h - S(12), UI.RarityColor(item), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    if opts.badge then
        surface.SetFont("HordePS_Small")
        local tw, th = surface.GetTextSize(opts.badge)
        UI.Box(S(3), S(3), tw + S(8), th + S(2), opts.badge_col or COL.red)
        UI.Text(opts.badge, "HordePS_Small", S(7), S(4), COL.white)
    end
    if opts.corner then
        UI.Text(opts.corner, "HordePS_Small", w - S(5), S(4), COL.white, TEXT_ALIGN_RIGHT)
    end
end

function SLOT:OnCursorEntered()
    if self.Item then UI.ShowTooltip(self.Item, self.Opts and self.Opts.tooltip) end
end

function SLOT:OnCursorExited()
    UI.HideTooltip()
end

function SLOT:OnRemove()
    if self:IsHovered() then UI.HideTooltip() end
end

vgui.Register("HordePS_Slot", SLOT, "DButton")

---------------------------------------------------------------------------
-- Rotating playermodel preview
---------------------------------------------------------------------------

local PREVIEW = {}
local BaseModelPanel = baseclass.Get("DModelPanel")

function PREVIEW:Init()
    self.Yaw = 25
    self.AutoSpin = true
    self:SetFOV(32)
    self:SetDirectionalLight(BOX_RIGHT, Color(255, 120, 120))
    self:SetDirectionalLight(BOX_LEFT, Color(200, 200, 220))
    self:SetAmbientLight(Color(60, 60, 60))
end

function PREVIEW:SetPlayerModel(mdl)
    if self.Current == mdl then return end
    self.Current = mdl
    self:SetModel(mdl or "models/player/kleiner.mdl")
    local ent = self:GetEntity()
    if not IsValid(ent) then return end
    local seq = ent:LookupSequence("idle_all_01")
    if seq <= 0 then seq = ent:LookupSequence("idle_all") end
    if seq > 0 then ent:ResetSequence(seq) end
    local mn, mx = ent:GetRenderBounds()
    local height = math.max(mx.z - mn.z, 40)
    self.LookCenter = Vector(0, 0, mn.z + height * 0.5)
    self:SetCamPos(Vector(height * 1.95, 0, height * 0.55 + mn.z))
    self:SetLookAt(self.LookCenter)
end

function PREVIEW:OnMousePressed(code)
    if code == MOUSE_LEFT then
        self.Dragging = gui.MouseX()
        self:MouseCapture(true)
    end
end

function PREVIEW:OnMouseReleased()
    self.Dragging = nil
    self:MouseCapture(false)
end

function PREVIEW:LayoutEntity(ent)
    if self.Dragging then
        local mx = gui.MouseX()
        self.Yaw = self.Yaw + (mx - self.Dragging) * 0.6
        self.Dragging = mx
        self.LastDrag = RealTime()
    elseif self.AutoSpin and RealTime() - (self.LastDrag or 0) > 2 then
        self.Yaw = self.Yaw + FrameTime() * 18
    end
    ent:SetAngles(Angle(0, self.Yaw, 0))
    ent:FrameAdvance((RealTime() - (self.LastFrame or RealTime())) * 1)
    self.LastFrame = RealTime()
end

function PREVIEW:Paint(w, h)
    -- Dark stage with a red floor glow.
    UI.GradV(0, 0, w, h, COL.bg, Color(20, 20, 20))
    UI.GradV(0, h * 0.55, w, h * 0.45, Color(0, 0, 0, 0), Color(110, 12, 12, 110))
    surface.SetMaterial(MAT.center)
    surface.SetDrawColor(255, 255, 255, 6)
    surface.DrawTexturedRect(0, 0, w, h)
    if self.Current then BaseModelPanel.Paint(self, w, h) end
    UI.Outline(0, 0, w, h, COL.border)
end

vgui.Register("HordePS_Preview", PREVIEW, "DModelPanel")

---------------------------------------------------------------------------
-- Dialogs & toasts
---------------------------------------------------------------------------

function UI.Confirm(title, body, yes_label, on_yes)
    local parent = IsValid(PS.Menu) and PS.Menu or nil
    local shade = vgui.Create("DPanel", parent)
    if parent then shade:SetSize(parent:GetSize()) else shade:SetSize(ScrW(), ScrH()); shade:MakePopup() end
    shade.Paint = function(_, w, h) UI.Box(0, 0, w, h, Color(0, 0, 0, 190)) end

    local box = vgui.Create("DPanel", shade)
    box:SetSize(S(440), S(190))
    box:Center()
    box.Paint = function(_, w, h)
        UI.GradV(0, 0, w, h, COL.panel2, COL.bg)
        UI.Box(0, 0, w, S(3), COL.red)
        UI.Outline(0, 0, w, h, COL.red_dark)
        UI.Text(string.upper(title), "HordePS_Header", S(18), S(18), COL.white)
    end

    local text = vgui.Create("DLabel", box)
    text:SetFont("HordePS_Body")
    text:SetTextColor(COL.text)
    text:SetWrap(true)
    text:SetText(body)
    text:SetPos(S(18), S(52))
    text:SetSize(S(404), S(70))
    text:SetContentAlignment(7)

    local cancel = UI.Button(box, "Cancel", "ghost", function() shade:Remove() end)
    cancel:SetSize(S(130), S(36))
    cancel:SetPos(S(440) - S(18) - S(130) * 2 - S(10), S(190) - S(54))

    local ok = UI.Button(box, yes_label or "Confirm", "red", function()
        shade:Remove()
        if on_yes then on_yes() end
    end)
    ok:SetSize(S(130), S(36))
    ok:SetPos(S(440) - S(18) - S(130), S(190) - S(54))
    return shade
end

function UI.Toast(msg, ok)
    if not IsValid(PS.Menu) or msg == "" then return end
    local menu = PS.Menu
    local t = vgui.Create("DPanel", menu)
    surface.SetFont("HordePS_BodyBold")
    local tw = surface.GetTextSize(msg)
    t:SetSize(tw + S(40), S(38))
    t:SetPos((menu:GetWide() - t:GetWide()) / 2, menu:GetTall() - S(60))
    t.Born = RealTime()
    t:SetMouseInputEnabled(false)
    t.Paint = function(s, w, h)
        local a = math.Clamp(3.2 - (RealTime() - s.Born), 0, 1)
        if a <= 0 then s:Remove() return end
        surface.SetAlphaMultiplier(a)
        UI.Box(0, 0, w, h, Color(8, 8, 8, 240))
        UI.Box(0, 0, S(4), h, ok and COL.white or COL.red)
        UI.Outline(0, 0, w, h, ok and COL.border_hi or COL.red)
        UI.Text(msg, "HordePS_BodyBold", S(20), h / 2, ok and COL.white or COL.red_light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetAlphaMultiplier(1)
    end
    if IsValid(menu.LastToast) then menu.LastToast:Remove() end
    menu.LastToast = t
end
