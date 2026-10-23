if not CLIENT then return end

local PS  = HORDE.Pointshop
local C   = PS.Config
local UI  = PS.UI
local COL = UI.Col
local S   = UI.S

PS.MenuState = PS.MenuState or {
    tab          = "loadout",
    class        = nil,
    inv_page     = 1,
    inv_sort     = "acquired",
    inv_selected = nil,
    store_class  = "all",
    store_sort   = "price_asc",
    store_search = "",
    hide_owned   = false,
    admin_selected = nil,
    admin_search   = "",
}
local ST = PS.MenuState

local DEFAULT_PREVIEW = "models/player/group01/male_07.mdl"

local function Clear(panel)
    for _, child in ipairs(panel:GetChildren()) do child:Remove() end
end

local function Truncate(text, font, width)
    surface.SetFont(font)
    if surface.GetTextSize(text) <= width then return text end
    while #text > 1 and surface.GetTextSize(text .. "…") > width do text = text:sub(1, -2) end
    return text .. "…"
end

local function DefaultModelFor(class_name)
    local class = HORDE.classes and HORDE.classes[class_name]
    if class and class.model and class.model ~= "" then
        return player_manager.TranslatePlayerModel(class.model)
    end
    local ply = LocalPlayer()
    if class_name == PS:LocalClassName() and IsValid(ply) and not PS:GetEquipped(class_name) then
        return ply:GetModel()
    end
    return DEFAULT_PREVIEW
end

local function ConfirmBuy(item)
    local price, discount = PS:GetPrice(item.id)
    local body = "Buy " .. item.name .. " for " .. PS:FormatNumber(price) .. " " .. C.CurrencyName .. "?"
    if discount > 0 then body = body .. "\nDaily deal: -" .. discount .. "%" end
    body = body .. "\nUsable by: " .. PS:ClassesText(item)
    UI.Confirm("Confirm purchase", body, "Buy", function() PS:RequestBuy(item.id) end)
end

-- Panel with a plain dark background.
local function Card(parent)
    local p = vgui.Create("DPanel", parent)
    p.Paint = function(_, w, h)
        UI.GradV(0, 0, w, h, COL.panel, COL.bg2)
        UI.Outline(0, 0, w, h, COL.border)
    end
    return p
end

local function Label(parent, text, font, col)
    local l = vgui.Create("DLabel", parent)
    l:SetFont(font or "HordePS_Body")
    l:SetTextColor(col or COL.text)
    l:SetText(text)
    l:SizeToContents()
    return l
end

---------------------------------------------------------------------------
-- LOADOUT
---------------------------------------------------------------------------

local function BuildLoadout(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local classes = PS:GetClassList()
    if not ST.class or not (HORDE.classes and HORDE.classes[ST.class]) then
        ST.class = PS:LocalClassName() or (classes[1] and classes[1].name)
    end

    -- Class selector row
    local rowH = S(108)
    local row = vgui.Create("DPanel", root)
    row:SetPos(pad, pad)
    row:SetSize(W - pad * 2, rowH)
    row.Paint = nil

    local n = math.max(#classes, 1)
    local gap = S(4)
    local cw = math.floor((W - pad * 2 - gap * (n - 1)) / n)
    for i, class in ipairs(classes) do
        local b = vgui.Create("DButton", row)
        b:SetText("")
        b:SetPos((i - 1) * (cw + gap), 0)
        b:SetSize(cw, rowH)
        b.Paint = function(s, w, h)
            local sel, hov = ST.class == class.name, s:IsHovered()
            if sel then
                UI.GradV(0, 0, w, h, Color(150, 18, 18), COL.red_deep)
            else
                UI.GradV(0, 0, w, h, hov and COL.panel2 or COL.panel, COL.bg)
            end
            UI.Outline(0, 0, w, h, sel and COL.red_light or (hov and COL.border_hi or COL.border))
            if sel then UI.Box(0, h - S(3), w, S(3), COL.white) end

            local icon = S(44)
            surface.SetMaterial(UI.ClassIcon(class))
            local c = (sel or hov) and 255 or 165
            surface.SetDrawColor(c, c, c)
            surface.DrawTexturedRect((w - icon) / 2, S(10), icon, icon)

            local name = Truncate(string.upper(class.display_name or class.name), "HordePS_ItemName", w - S(8))
            UI.TextShadow(name, "HordePS_ItemName", w / 2, S(68), COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local item = PS:GetEquipped(class.name)
            local sub = item and Truncate(item.name, "HordePS_Small", w - S(8)) or "Default"
            UI.Text(sub, "HordePS_Small", w / 2, S(88), item and UI.RarityColor(item) or COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if class.name == PS:LocalClassName() then
                surface.SetFont("HordePS_Small")
                local tw, th = surface.GetTextSize("PLAYING")
                UI.Box(w - tw - S(10), S(4), tw + S(6), th, COL.white)
                UI.Text("PLAYING", "HordePS_Small", w - S(7), S(4), COL.bg, TEXT_ALIGN_RIGHT)
            end
        end
        b.DoClick = function()
            if ST.class == class.name then return end
            surface.PlaySound("ui/buttonclick.wav")
            ST.class = class.name
            root:RebuildBody()
        end
    end

    local body = vgui.Create("DPanel", root)
    body:SetPos(0, pad + rowH)
    body:SetSize(W, H - pad - rowH)
    body.Paint = nil

    function root:RebuildBody()
        Clear(body)
        local bw, bh = body:GetSize()
        local class_name = ST.class
        if not class_name then
            Label(body, "No classes available.", "HordePS_Header", COL.muted):SetPos(pad, pad)
            return
        end
        local equipped = PS:GetEquipped(class_name)

        -- Preview
        local pw = math.floor((bw - pad * 3) * 0.36)
        local preview = vgui.Create("HordePS_Preview", body)
        preview:SetPos(pad, pad)
        preview:SetSize(pw, bh - pad * 2)
        local function ShowEquipped()
            local cur = PS:GetEquipped(class_name)
            preview:SetPlayerModel(cur and cur.model or DefaultModelFor(class_name))
            preview.ShowItem = cur
        end
        ShowEquipped()
        preview.PaintOver = function(s, w, h)
            UI.TextShadow(string.upper(PS:ClassDisplayName(class_name)), "HordePS_Big", S(16), S(10), COL.white)
            local it = s.ShowItem
            UI.TextShadow(it and it.name or "Default model", "HordePS_Header", S(16), S(52), it and UI.RarityColor(it) or COL.muted)
            if s.Hovering then
                UI.Text("PREVIEW", "HordePS_Small", w - S(12), S(14), COL.red_light, TEXT_ALIGN_RIGHT)
            end
            UI.Text("Drag to rotate", "HordePS_Small", w / 2, h - S(16), COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Right column
        local rx = pad * 2 + pw
        local rw = bw - rx - pad
        local right = vgui.Create("DPanel", body)
        right:SetPos(rx, pad)
        right:SetSize(rw, bh - pad * 2)
        right.Paint = function(_, w)
            UI.Heading("Playermodel", 0, 0, w, PS:ClassDisplayName(class_name) .. " only")
        end

        -- Equipped slot card
        local eqH = S(132)
        local eq = Card(right)
        eq:SetPos(0, S(40))
        eq:SetSize(rw, eqH)

        local slot = vgui.Create("HordePS_Slot", eq)
        slot:SetPos(S(10), S(10))
        slot:SetSize(eqH - S(20), eqH - S(20))
        slot:SetItem(equipped, { empty_label = "DEFAULT", badge = equipped and "EQUIPPED" or nil })

        local tx = eqH + S(4)
        local info = vgui.Create("DPanel", eq)
        info:SetPos(tx, S(10))
        info:SetSize(rw - tx - S(10), eqH - S(20))
        info.Paint = function(_, w)
            if equipped then
                local r = PS:GetRarity(equipped.rarity)
                UI.Text(equipped.name, "HordePS_Header", 0, 0, r.color)
                UI.Text(r.name .. " Playermodel", "HordePS_Small", 0, S(28), COL.muted)
                UI.Text("Usable by: " .. PS:ClassesText(equipped), "HordePS_Body", 0, S(48), COL.text)
            else
                UI.Text("Default model", "HordePS_Header", 0, 0, COL.white)
                UI.Text("No pointshop playermodel equipped for this class.", "HordePS_Body", 0, S(30), COL.muted)
            end
        end

        local bwid = S(170)
        local def = UI.Button(info, "Use default", "ghost", function()
            PS:RequestEquip(class_name, "")
        end)
        def:SetSize(bwid, S(32))
        def:SetPos(0, eqH - S(20) - S(32))
        def:SetEnabled(equipped ~= nil)

        local browse = UI.Button(info, "Browse store", "dark", function()
            ST.store_class = class_name
            PS.Menu:SetTab("store")
        end)
        browse:SetSize(bwid, S(32))
        browse:SetPos(bwid + S(8), eqH - S(20) - S(32))

        -- Owned models for this class
        local owned = {}
        for _, id in ipairs(PS.Player.inventory) do
            local item = PS.Catalog[id]
            if item and PS:CanClassUse(item, class_name) then owned[#owned + 1] = item end
        end

        local gy = S(40) + eqH + S(18)
        local gh = vgui.Create("DPanel", right)
        gh:SetPos(0, gy)
        gh:SetSize(rw, S(34))
        gh.Paint = function(_, w)
            UI.Heading("Your models", 0, 0, w, #owned .. " usable by " .. PS:ClassDisplayName(class_name) .. " · click to equip")
        end

        local sp = UI.Scroll(right)
        sp:SetPos(0, gy + S(40))
        sp:SetSize(rw, right:GetTall() - gy - S(40))

        local grid = vgui.Create("DIconLayout", sp)
        grid:Dock(TOP)
        grid:SetSpaceX(S(8))
        grid:SetSpaceY(S(8))

        local size = S(104)
        local function AddSlot(item)
            local s = grid:Add("HordePS_Slot")
            s:SetSize(size, size + S(18))
            local is_eq = (item and equipped and item.id == equipped.id) or (not item and not equipped)
            s:SetItem(item, {
                show_name = true,
                selected = is_eq,
                badge = (item and is_eq) and "EQUIPPED" or nil,
                empty_label = "DEFAULT",
                tooltip = item and { { is_eq and "Equipped" or "Click to equip", "HordePS_Small", COL.red_light } } or nil,
            })
            s.DoClick = function()
                if is_eq then return end
                surface.PlaySound("ui/buttonclick.wav")
                PS:RequestEquip(class_name, item and item.id or "")
            end
            local enter, exit = s.OnCursorEntered, s.OnCursorExited
            s.OnCursorEntered = function(self)
                enter(self)
                preview:SetPlayerModel(item and item.model or DefaultModelFor(class_name))
                preview.ShowItem = item
                preview.Hovering = true
            end
            s.OnCursorExited = function(self)
                exit(self)
                if IsValid(preview) then
                    preview.Hovering = false
                    ShowEquipped()
                end
            end
        end

        AddSlot(nil)
        for _, item in ipairs(owned) do AddSlot(item) end

        if #owned == 0 then
            local hint = vgui.Create("DPanel", grid)
            hint:SetSize(rw - size - S(30), size + S(18))
            hint.OwnLine = true
            hint.Paint = function(_, w, h)
                UI.Text("You don't own any models for " .. PS:ClassDisplayName(class_name) .. " yet.", "HordePS_BodyBold", S(8), h / 2 - S(10), COL.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                UI.Text("Check the Daily Store for discounted skins.", "HordePS_Body", S(8), h / 2 + S(12), COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    root:RebuildBody()

    root.Refresh = function(_, what)
        if what == "player" or what == "catalog" then root:RebuildBody() end
    end
end

---------------------------------------------------------------------------
-- INVENTORY
---------------------------------------------------------------------------

local INV_SORTS = {
    { "acquired", "Oldest first" },
    { "newest",   "Newest first" },
    { "name",     "Name" },
    { "rarity",   "Rarity" },
}

local function SortedInventory()
    local list = {}
    for i, id in ipairs(PS.Player.inventory) do
        local item = PS.Catalog[id]
        if item then list[#list + 1] = { item = item, i = i } end
    end
    local mode = ST.inv_sort
    table.sort(list, function(a, b)
        if mode == "newest" then return a.i > b.i end
        if mode == "name" then return a.item.name < b.item.name end
        if mode == "rarity" then
            local ra, rb = PS:GetRarity(a.item.rarity).order, PS:GetRarity(b.item.rarity).order
            if ra ~= rb then return ra > rb end
            return a.item.name < b.item.name
        end
        return a.i < b.i
    end)
    local out = {}
    for _, e in ipairs(list) do out[#out + 1] = e.item end
    return out
end

local function EquipMenu(item)
    local m = UI.Menu()
    local any = false
    for _, class in ipairs(PS:GetClassList()) do
        if PS:CanClassUse(item, class.name) then
            any = true
            local on = PS.Player.equipped[class.name] == item.id
            m:AddOption((on and "✓  " or "     ") .. (class.display_name or class.name), function()
                PS:RequestEquip(class.name, on and "" or item.id)
            end)
        end
    end
    if not any then m:AddOption("No class can use this item") end
    m:Open()
end

local function BuildInventory(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local per_page = math.max(1, C.SlotsPerPage)
    local pages = math.max(1, math.ceil(C.InventorySlots / per_page))
    local cols = 8
    local rows = math.ceil(per_page / cols)

    local lw = math.floor((W - pad * 3) * 0.66)
    local left = vgui.Create("DPanel", root)
    left:SetPos(pad, pad)
    left:SetSize(lw, H - pad * 2)
    left.Paint = function(_, w)
        UI.Heading("Backpack", 0, 0, w, #PS.Player.inventory .. " / " .. C.InventorySlots .. " slots used")
    end

    local sort = UI.Combo(left)
    sort:SetSize(S(170), S(28))
    sort:SetPos(lw - S(170), 0)
    for _, s in ipairs(INV_SORTS) do sort:AddChoice(s[2], s[1], s[1] == ST.inv_sort) end
    sort.OnSelect = function(_, _, _, value)
        ST.inv_sort = value
        root:RebuildGrid()
    end

    local grid = vgui.Create("DPanel", left)
    grid:SetPos(0, S(44))
    grid:SetSize(lw, left:GetTall() - S(44) - S(52))
    grid.Paint = nil

    local nav = vgui.Create("DPanel", left)
    nav:SetPos(0, left:GetTall() - S(42))
    nav:SetSize(lw, S(42))
    nav.Paint = function(_, w, h)
        UI.Text("PAGE " .. ST.inv_page .. " / " .. pages, "HordePS_Tab", w / 2, h / 2, COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local prev = UI.Button(nav, "<", "dark", function()
        ST.inv_page = math.max(1, ST.inv_page - 1)
        root:RebuildGrid()
    end)
    prev:SetSize(S(54), S(36))
    prev:SetPos(lw / 2 - S(130), S(3))
    local next_b = UI.Button(nav, ">", "dark", function()
        ST.inv_page = math.min(pages, ST.inv_page + 1)
        root:RebuildGrid()
    end)
    next_b:SetSize(S(54), S(36))
    next_b:SetPos(lw / 2 + S(76), S(3))

    -- Details column
    local dx = pad * 2 + lw
    local dw = W - dx - pad
    local details = Card(root)
    details:SetPos(dx, pad)
    details:SetSize(dw, H - pad * 2)

    function root:RebuildDetails()
        Clear(details)
        local item = ST.inv_selected and PS:Owns(ST.inv_selected) and PS.Catalog[ST.inv_selected]
        local dh = details:GetTall()
        if not item then
            details.PaintOver = function(_, w, h)
                UI.Text("Select an item", "HordePS_Header", w / 2, h / 2 - S(12), COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                UI.Text("Double-click to equip on your current class", "HordePS_Small", w / 2, h / 2 + S(14), COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                UI.Text("Right-click to choose classes", "HordePS_Small", w / 2, h / 2 + S(32), COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            return
        end
        details.PaintOver = nil

        local ph = math.floor(dh * 0.5)
        local pv = vgui.Create("HordePS_Preview", details)
        pv:SetPos(S(10), S(10))
        pv:SetSize(dw - S(20), ph)
        pv:SetPlayerModel(item.model)

        local info = vgui.Create("DPanel", details)
        info:SetPos(S(14), ph + S(22))
        info:SetSize(dw - S(28), dh - ph - S(22) - S(140))
        info.Paint = function(_, w)
            local r = PS:GetRarity(item.rarity)
            UI.Text(Truncate(item.name, "HordePS_Big", w), "HordePS_Big", 0, 0, r.color)
            UI.Text(r.name .. " Playermodel", "HordePS_Body", 0, S(42), COL.muted)
            UI.Text("Usable by:", "HordePS_BodyBold", 0, S(70), COL.white)
            UI.Text(Truncate(PS:ClassesText(item), "HordePS_Body", w), "HordePS_Body", 0, S(90), COL.text)
            local on = PS:EquippedOn(item.id)
            UI.Text("Equipped on:", "HordePS_BodyBold", 0, S(118), COL.white)
            UI.Text(#on > 0 and Truncate(table.concat(on, ", "), "HordePS_Body", w) or "Nothing", "HordePS_Body", 0, S(138), #on > 0 and COL.red_light or COL.dim)
        end

        local cur = PS:LocalClassName()
        local bw = dw - S(28)
        local b1 = UI.Button(details, cur and ("Equip on " .. PS:ClassDisplayName(cur)) or "Equip on current class", "red", function()
            PS:RequestEquip(cur, item.id)
        end)
        b1:SetSize(bw, S(38))
        b1:SetPos(S(14), dh - S(136))
        b1:SetEnabled(cur ~= nil and PS:CanClassUse(item, cur) and PS.Player.equipped[cur] ~= item.id)

        local b2 = UI.Button(details, "Equip on class…", "dark", function() EquipMenu(item) end)
        b2:SetSize(bw, S(38))
        b2:SetPos(S(14), dh - S(92))

        local b3 = UI.Button(details, "Unequip everywhere", "ghost", function()
            for _, class in ipairs(PS:GetClassList()) do
                if PS.Player.equipped[class.name] == item.id then PS:RequestEquip(class.name, "") end
            end
        end)
        b3:SetSize(bw, S(34))
        b3:SetPos(S(14), dh - S(48))
        b3:SetEnabled(#PS:EquippedOn(item.id) > 0)
    end

    function root:RebuildGrid()
        Clear(grid)
        local items = SortedInventory()
        ST.inv_page = math.Clamp(ST.inv_page, 1, pages)
        local gap = S(8)
        local gw, gh = grid:GetSize()
        local size = math.floor(math.min((gw - gap * (cols - 1)) / cols, (gh - gap * (rows - 1)) / rows))
        local ox = math.floor((gw - (size * cols + gap * (cols - 1))) / 2)

        for i = 1, per_page do
            local index = (ST.inv_page - 1) * per_page + i
            if index > C.InventorySlots then break end
            local item = items[index]
            local col, r = (i - 1) % cols, math.floor((i - 1) / cols)
            local s = vgui.Create("HordePS_Slot", grid)
            s:SetPos(ox + col * (size + gap), r * (size + gap))
            s:SetSize(size, size)
            if item then
                local on = PS:EquippedOn(item.id)
                s:SetItem(item, {
                    show_name = true,
                    selected = ST.inv_selected == item.id,
                    badge = #on > 0 and "EQUIPPED" or nil,
                    tooltip = #on > 0 and { { "Equipped on: " .. table.concat(on, ", "), "HordePS_Small", COL.red_light } } or nil,
                })
                s.DoClick = function()
                    surface.PlaySound("ui/buttonclick.wav")
                    ST.inv_selected = item.id
                    root:RebuildGrid()
                    root:RebuildDetails()
                end
                s.DoDoubleClick = function()
                    local cur = PS:LocalClassName()
                    if cur and PS:CanClassUse(item, cur) then PS:RequestEquip(cur, item.id) end
                end
                s.DoRightClick = function() EquipMenu(item) end
            else
                s:SetItem(nil, {})
            end
        end
        prev:SetEnabled(ST.inv_page > 1)
        next_b:SetEnabled(ST.inv_page < pages)
    end

    root:RebuildGrid()
    root:RebuildDetails()

    root.Refresh = function(_, what)
        if what == "player" or what == "catalog" then
            root:RebuildGrid()
            root:RebuildDetails()
        end
    end
end

---------------------------------------------------------------------------
-- DAILY STORE
---------------------------------------------------------------------------

local STORE_SORTS = {
    { "price_asc",  "Price: low to high" },
    { "price_desc", "Price: high to low" },
    { "name",       "Name" },
    { "rarity",     "Rarity" },
}

local function BuyButton(parent, item)
    local b = UI.Button(parent, "Buy", "red", function() ConfirmBuy(item) end)
    b.Think = function(s)
        local owned = PS:Owns(item.id)
        local full = #PS.Player.inventory >= C.InventorySlots
        s:SetEnabled(not owned and not full)
        s:SetLabel(owned and "Owned" or (full and "Inventory full" or "Buy"))
    end
    return b
end

local function DailyCard(parent, item, deal, w, h)
    local card = vgui.Create("DPanel", parent)
    card:SetSize(w, h)
    local rc = UI.RarityColor(item)
    local info_h = S(132)

    card.Paint = function(_, pw, ph)
        UI.GradV(0, 0, pw, ph, Color(30, 22, 22), COL.bg)
        UI.GradV(0, ph - info_h - S(40), pw, info_h + S(40), Color(0, 0, 0, 0), ColorAlpha(rc, 22))
        UI.Box(0, 0, pw, S(3), COL.red)
        UI.Outline(0, 0, pw, ph, ColorAlpha(rc, 120))

        local y = ph - info_h
        UI.Text(Truncate(item.name, "HordePS_Header", pw - S(24)), "HordePS_Header", S(12), y, rc)
        UI.Text(PS:GetRarity(item.rarity).name .. " · " .. Truncate(PS:ClassesText(item), "HordePS_Small", pw - S(110)), "HordePS_Small", S(12), y + S(28), COL.muted)

        local price = PS:DailyPrice(item.price, deal.discount)
        local py = y + S(62)
        local wnew = UI.Price(price, "HordePS_Price", S(12), py, PS.Player.skulls >= price and COL.white or COL.red_light)
        UI.Text(PS:FormatNumber(item.price), "HordePS_Strike", S(22) + wnew, py, COL.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local pv = vgui.Create("HordePS_Preview", card)
    pv:SetPos(S(8), S(10))
    pv:SetSize(w - S(16), h - info_h - S(18))
    pv:SetPlayerModel(item.model)
    pv.PaintOver = function(_, pw)
        local txt = "-" .. deal.discount .. "%"
        surface.SetFont("HordePS_Header")
        local tw, th = surface.GetTextSize(txt)
        UI.GradV(pw - tw - S(24), S(8), tw + S(16), th + S(6), COL.red_light, COL.red_dark)
        UI.Text(txt, "HordePS_Header", pw - S(16), S(11), COL.white, TEXT_ALIGN_RIGHT)
        UI.Text("DAILY DEAL", "HordePS_Small", S(10), S(10), COL.white)
    end

    local b = BuyButton(card, item)
    b:SetSize(w - S(24), S(36))
    b:SetPos(S(12), h - S(46))
    return card
end

local function StoreCard(parent, item, w, h)
    local card = vgui.Create("DPanel", parent)
    card:SetSize(w, h)
    card.Paint = function(_, pw, ph)
        UI.GradV(0, 0, pw, ph, COL.panel, COL.bg)
        UI.Outline(0, 0, pw, ph, COL.border)
        local price, discount = PS:GetPrice(item.id)
        local y = pw - S(8)
        UI.Text(Truncate(item.name, "HordePS_ItemName", pw - S(16)), "HordePS_ItemName", S(8), y, UI.RarityColor(item))
        UI.Text(Truncate(PS:ClassesText(item), "HordePS_Small", pw - S(16)), "HordePS_Small", S(8), y + S(19), COL.muted)
        local wp = UI.Price(price, "HordePS_BodyBold", S(8), y + S(46), PS.Player.skulls >= price and COL.white or COL.red_light)
        if discount > 0 then
            UI.Text("-" .. discount .. "%", "HordePS_Small", S(14) + wp, y + S(46), COL.red_light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    local slot = vgui.Create("HordePS_Slot", card)
    slot:SetPos(S(8), S(8))
    slot:SetSize(w - S(16), w - S(16))
    local deal = PS:GetDailyDeal(item.id)
    slot:SetItem(item, {
        badge = PS:Owns(item.id) and "OWNED" or (deal and "DAILY" or nil),
        badge_col = PS:Owns(item.id) and COL.dim or COL.red,
    })
    slot.DoClick = function()
        if not PS:Owns(item.id) then ConfirmBuy(item) end
    end

    local b = BuyButton(card, item)
    b:SetSize(w - S(16), S(30))
    b:SetPos(S(8), h - S(38))
    return card
end

local function FilteredStore()
    local list = {}
    local search = string.lower(string.Trim(ST.store_search or ""))
    for _, item in ipairs(PS:GetStoreItems()) do
        local visible = (ST.store_class == "all" or PS:CanClassUse(item, ST.store_class))
            and not (ST.hide_owned and PS:Owns(item.id))
            and (search == "" or string.find(string.lower(item.name), search, 1, true) ~= nil)
        if visible then list[#list + 1] = item end
    end
    local mode = ST.store_sort
    table.sort(list, function(a, b)
        if mode == "name" then return a.name < b.name end
        if mode == "rarity" then
            local ra, rb = PS:GetRarity(a.rarity).order, PS:GetRarity(b.rarity).order
            if ra ~= rb then return ra > rb end
            return a.price > b.price
        end
        local pa, pb = PS:GetPrice(a.id), PS:GetPrice(b.id)
        if pa == pb then return a.name < b.name end
        if mode == "price_desc" then return pa > pb end
        return pa < pb
    end)
    return list
end

local function BuildStore(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local sp = UI.Scroll(root)
    sp:SetPos(pad, pad)
    sp:SetSize(W - pad * 2, H - pad * 2)
    local cw = W - pad * 2 - S(16)

    -- Daily deals
    local dh = vgui.Create("DPanel", sp)
    dh:Dock(TOP)
    dh:SetTall(S(40))
    dh.Paint = function(_, w)
        UI.Heading("Daily Deals", 0, 0, w, "Discounted today only · refreshes in " .. PS:FormatTime(PS.Daily.reset_at - RealTime()))
    end

    local deals = {}
    for _, deal in ipairs(PS.Daily.deals) do
        local item = PS.Catalog[deal.id]
        if item and item.enabled then deals[#deals + 1] = { item = item, deal = deal } end
    end

    local dailyH = S(380)
    local drow = vgui.Create("DPanel", sp)
    drow:Dock(TOP)
    drow:SetTall(#deals > 0 and dailyH or S(60))
    drow:DockMargin(0, 0, 0, S(20))
    drow.Paint = nil
    if #deals == 0 then
        drow.Paint = function(_, w, h)
            UI.Text("No daily deals today.", "HordePS_Body", 0, h / 2, COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    else
        local gap = S(12)
        local n = math.max(#deals, 3)
        local w = math.floor((cw - gap * (n - 1)) / n)
        for i, d in ipairs(deals) do
            local card = DailyCard(drow, d.item, d.deal, w, dailyH)
            card:SetPos((i - 1) * (w + gap), 0)
        end
    end

    -- Regular store
    local sh = vgui.Create("DPanel", sp)
    sh:Dock(TOP)
    sh:SetTall(S(40))
    sh.Paint = function(_, w)
        UI.Heading("Store", 0, 0, w, "Every playermodel at its regular price")
    end

    local bar = vgui.Create("DPanel", sp)
    bar:Dock(TOP)
    bar:SetTall(S(36))
    bar:DockMargin(0, 0, 0, S(12))
    bar.Paint = nil

    local class_cb = UI.Combo(bar)
    class_cb:SetPos(0, S(2))
    class_cb:SetSize(S(200), S(30))
    class_cb:AddChoice("All classes", "all", ST.store_class == "all")
    for _, class in ipairs(PS:GetClassList()) do
        class_cb:AddChoice(class.display_name or class.name, class.name, ST.store_class == class.name)
    end

    local sort_cb = UI.Combo(bar)
    sort_cb:SetPos(S(210), S(2))
    sort_cb:SetSize(S(190), S(30))
    for _, s in ipairs(STORE_SORTS) do sort_cb:AddChoice(s[2], s[1], s[1] == ST.store_sort) end

    local search = UI.Entry(bar, "Search…")
    search:SetPos(S(410), S(2))
    search:SetSize(S(240), S(30))
    search:SetValue(ST.store_search or "")
    search:SetUpdateOnType(true)

    local hide = UI.Check(bar, "Hide owned", ST.hide_owned)
    hide:SetPos(S(664), S(4))
    hide:SetSize(S(150), S(28))

    local count = vgui.Create("DPanel", bar)
    count:SetPos(cw - S(200), 0)
    count:SetSize(S(200), S(36))

    local grid = vgui.Create("DIconLayout", sp)
    grid:Dock(TOP)
    grid:SetSpaceX(S(10))
    grid:SetSpaceY(S(10))
    grid:DockMargin(0, 0, 0, S(16))

    local items_shown = 0
    count.Paint = function(_, w, h)
        UI.Text(items_shown .. " items", "HordePS_Small", w, h / 2, COL.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    function root:RebuildGrid()
        grid:Clear()
        local list = FilteredStore()
        items_shown = #list
        local gap = S(10)
        local target = S(168)
        local cols = math.max(1, math.floor((cw + gap) / (target + gap)))
        local w = math.floor((cw - gap * (cols - 1)) / cols)
        for _, item in ipairs(list) do
            grid:Add(StoreCard(grid, item, w, w + S(96)))
        end
        if #list == 0 then
            local empty = grid:Add("DPanel")
            empty:SetSize(cw, S(60))
            empty.Paint = function(_, ew, eh)
                UI.Text("No playermodels match your filters.", "HordePS_Body", 0, eh / 2, COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
        grid:Layout()
        sp:InvalidateLayout()
    end

    class_cb.OnSelect = function(_, _, _, value) ST.store_class = value root:RebuildGrid() end
    sort_cb.OnSelect = function(_, _, _, value) ST.store_sort = value root:RebuildGrid() end
    search.OnValueChange = function(_, value) ST.store_search = value root:RebuildGrid() end
    hide.DoClick = function(s)
        s:SetValue(not s:GetValue())
        ST.hide_owned = s:GetValue()
        surface.PlaySound("ui/buttonclick.wav")
        root:RebuildGrid()
    end

    root:RebuildGrid()

    root.Refresh = function(_, what)
        if what == "catalog" or what == "daily" then
            PS.Menu:SetTab("store", true)
        elseif what == "player" then
            root:RebuildGrid()
        end
    end
    root.Scroll = sp
end

---------------------------------------------------------------------------
-- CONTRACTS
---------------------------------------------------------------------------

local function BuildContracts(root)
    local W, H = root:GetSize()
    local pad = S(16)

    local top = vgui.Create("DPanel", root)
    top:SetPos(pad, pad)
    top:SetSize(W - pad * 2, S(112))
    top.Paint = function(_, w, h)
        UI.GradH(0, 0, w, h, Color(110, 12, 12), COL.bg2)
        UI.Outline(0, 0, w, h, COL.red_dark)
        UI.Box(0, 0, S(5), h, COL.red)
        UI.TextShadow("DAILY CONTRACTS", "HordePS_Big", S(24), S(14), COL.white)
        UI.Text("Complete contracts during a game to earn " .. C.CurrencyName .. ". Finished contracts must be claimed here.",
            "HordePS_Body", S(24), S(60), COL.text)
        UI.Text("New contracts in " .. PS:FormatTime(PS.Contracts.reset_at - RealTime()), "HordePS_BodyBold", S(24), S(84), COL.red_light)

        local done, total, earned = 0, #PS.Contracts.list, 0
        for _, c in ipairs(PS.Contracts.list) do
            if c.progress >= c.goal then done = done + 1 end
            if c.claimed then earned = earned + (c.reward or 0) end
        end
        UI.Text(done .. " / " .. total, "HordePS_Huge", w - S(24), S(10), COL.white, TEXT_ALIGN_RIGHT)
        UI.Text("COMPLETED", "HordePS_Small", w - S(24), S(64), COL.muted, TEXT_ALIGN_RIGHT)
        UI.Price(earned, "HordePS_BodyBold", w - S(24), S(88), COL.white, TEXT_ALIGN_RIGHT)
    end

    local sp = UI.Scroll(root)
    sp:SetPos(pad, pad + S(112) + S(16))
    sp:SetSize(W - pad * 2, H - pad * 2 - S(112) - S(16))

    function root:RebuildList()
        sp:Clear()
        local list = PS.Contracts.list
        if #list == 0 then
            local e = vgui.Create("DPanel", sp)
            e:Dock(TOP)
            e:SetTall(S(60))
            e.Paint = function(_, w, h)
                UI.Text("No contracts available right now.", "HordePS_Body", 0, h / 2, COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            return
        end

        for i, c in ipairs(list) do
            local complete = c.progress >= c.goal
            local row = vgui.Create("DPanel", sp)
            row:Dock(TOP)
            row:SetTall(S(108))
            row:DockMargin(0, 0, S(8), S(10))
            row.Paint = function(_, w, h)
                local state_col = c.claimed and COL.dim or (complete and COL.white or COL.red)
                UI.GradV(0, 0, w, h, complete and not c.claimed and Color(46, 30, 30) or COL.panel, COL.bg)
                UI.Outline(0, 0, w, h, complete and not c.claimed and COL.red_light or COL.border)

                -- Number block
                local bs = h - S(20)
                UI.GradV(S(10), S(10), bs, bs, c.claimed and COL.panel2 or COL.red, c.claimed and COL.bg or COL.red_deep)
                UI.Text("#" .. i, "HordePS_Big", S(10) + bs / 2, S(10) + bs / 2, c.claimed and COL.muted or COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                local x = S(24) + bs
                local right = S(250)
                local tw = w - x - right
                UI.Text(string.upper(c.name or "Contract"), "HordePS_Header", x, S(12), c.claimed and COL.muted or COL.white)
                UI.Text(c.desc or "", "HordePS_Body", x, S(40), COL.muted)

                -- Progress bar
                local by, bh = S(70), S(14)
                UI.Box(x, by, tw, bh, COL.bg)
                local frac = math.Clamp(c.progress / math.max(c.goal, 1), 0, 1)
                if frac > 0 then
                    UI.GradV(x, by, math.max(S(2), tw * frac), bh, complete and COL.white or COL.red_light, complete and COL.muted or COL.red_dark)
                end
                UI.Outline(x, by, tw, bh, COL.border)
                UI.Text(PS:FormatNumber(c.progress) .. " / " .. PS:FormatNumber(c.goal), "HordePS_Small", x + tw, by + bh + S(10), state_col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                -- Reward
                UI.Text("REWARD", "HordePS_Small", w - S(20), S(14), COL.muted, TEXT_ALIGN_RIGHT)
                UI.Price(c.reward or 0, "HordePS_Price", w - S(20), S(42), c.claimed and COL.dim or COL.white, TEXT_ALIGN_RIGHT)
            end

            local btn
            if c.claimed then
                btn = UI.Button(row, "Claimed", "ghost")
                btn:SetEnabled(false)
            elseif complete then
                btn = UI.Button(row, "Claim", "red", function() PS:RequestClaim(i) end)
                local paint = btn.Paint
                btn.Paint = function(s, w, h)
                    paint(s, w, h)
                    local a = (math.sin(RealTime() * 5) + 1) * 0.5
                    UI.Outline(0, 0, w, h, Color(255, 255, 255, 60 + 120 * a), 2)
                end
            else
                btn = UI.Button(row, "In progress", "ghost")
                btn:SetEnabled(false)
            end
            btn:SetSize(S(160), S(34))
            row.PerformLayout = function(s, w, h)
                btn:SetPos(w - S(180), h - S(46))
            end
        end
    end

    root:RebuildList()
    root.Refresh = function(_, what)
        if what == "contracts" then root:RebuildList() end
    end
end

---------------------------------------------------------------------------
-- ADMIN
---------------------------------------------------------------------------

local function BuildAdmin(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local lw = S(380)

    local left = vgui.Create("DPanel", root)
    left:SetPos(pad, pad)
    left:SetSize(lw, H - pad * 2)
    left.Paint = function(_, w)
        UI.Heading("Playermodels", 0, 0, w, #PS.CatalogOrder .. " items")
    end

    local search = UI.Entry(left, "Search…")
    search:SetPos(0, S(40))
    search:SetSize(lw - S(110), S(30))
    search:SetValue(ST.admin_search or "")
    search:SetUpdateOnType(true)

    local add = UI.Button(left, "+ New", "red", function()
        ST.admin_selected = "__new"
        root:RebuildList()
        root:RebuildEditor()
    end)
    add:SetPos(lw - S(100), S(40))
    add:SetSize(S(100), S(30))

    local list = UI.Scroll(left)
    list:SetPos(0, S(80))
    list:SetSize(lw, left:GetTall() - S(80))

    local right = vgui.Create("DPanel", root)
    right:SetPos(pad * 2 + lw, pad)
    right:SetSize(W - lw - pad * 3, H - pad * 2)
    right.Paint = nil

    function root:RebuildList()
        list:Clear()
        local q = string.lower(string.Trim(ST.admin_search or ""))
        for _, id in ipairs(PS.CatalogOrder) do
            local item = PS.Catalog[id]
            if q == "" or string.find(string.lower(item.name .. " " .. item.model .. " " .. item.id), q, 1, true) then
                local row = vgui.Create("DButton", list)
                row:SetText("")
                row:Dock(TOP)
                row:SetTall(S(52))
                row:DockMargin(0, 0, S(10), S(4))
                local icon = vgui.Create("ModelImage", row)
                icon:SetModel(item.model)
                icon:SetSize(S(44), S(44))
                icon:SetPos(S(4), S(4))
                icon:SetMouseInputEnabled(false)
                row.Paint = function(s, w, h)
                    local sel = ST.admin_selected == id
                    UI.GradV(0, 0, w, h, sel and Color(120, 16, 16) or (s:IsHovered() and COL.panel2 or COL.panel), COL.bg)
                    UI.Outline(0, 0, w, h, sel and COL.red_light or COL.border)
                    local x = S(56)
                    UI.Text(Truncate(item.name, "HordePS_ItemName", w - x - S(100)), "HordePS_ItemName", x, S(8), item.enabled and UI.RarityColor(item) or COL.dim)
                    local tags = {}
                    if not item.enabled then tags[#tags + 1] = "DISABLED" end
                    if item.custom then tags[#tags + 1] = "CUSTOM" end
                    if item.overridden and not item.custom then tags[#tags + 1] = "EDITED" end
                    if item.classes then tags[#tags + 1] = table.Count(item.classes) .. " CLASS" .. (table.Count(item.classes) > 1 and "ES" or "") end
                    UI.Text(table.concat(tags, " · "), "HordePS_Small", x, S(30), COL.muted)
                    UI.Price(item.price, "HordePS_BodyBold", w - S(10), h / 2, COL.white, TEXT_ALIGN_RIGHT)
                end
                row.DoClick = function()
                    surface.PlaySound("ui/buttonclick.wav")
                    ST.admin_selected = id
                    root:RebuildEditor()
                end
            end
        end
    end

    function root:RebuildEditor()
        Clear(right)
        local is_new = ST.admin_selected == "__new"
        local item = (not is_new) and PS.Catalog[ST.admin_selected or ""]
        local rw, rh = right:GetSize()

        if not is_new and not item then
            right.Paint = function(_, w, h)
                UI.Heading("Pointshop admin", 0, 0, w)
                local y = S(50)
                for _, line in ipairs({
                    "Select a playermodel on the left to change its price, rarity, class restriction or availability.",
                    "Use \"+ New\" to add any playermodel installed on the server (e.g. a workshop model).",
                    "Default items are defined in gamemode/modules/pointshop/core/sh_config.lua.",
                    "In-game changes are saved in the server database and override the config file.",
                    "Give test currency: horde_ps_give_skulls <name|steamid|^> <amount>",
                }) do
                    UI.Text(line, "HordePS_Body", 0, y, COL.text)
                    y = y + S(26)
                end
            end
        else
            right.Paint = function(_, w)
                UI.Heading(is_new and "New playermodel" or "Edit playermodel", 0, 0, w,
                    is_new and "Added as a custom item" or (item.custom and ("custom · " .. item.id) or ("config · " .. item.id)))
            end

            local editable = is_new or item.custom
            local fw = math.floor(rw * 0.56)
            local y = S(44)
            local function Field(label, h)
                local l = Label(right, string.upper(label), "HordePS_Small", COL.muted)
                l:SetPos(0, y)
                y = y + S(18)
                local top = y
                y = y + (h or S(32)) + S(10)
                return top
            end

            local name = UI.Entry(right, "Display name")
            name:SetPos(0, Field("Name"))
            name:SetSize(fw, S(32))
            name:SetValue(item and item.name or "")
            name:SetEnabled(editable)

            local model = UI.Entry(right, "models/player/....mdl")
            model:SetPos(0, Field("Model path"))
            model:SetSize(fw, S(32))
            model:SetValue(item and item.model or "")
            model:SetEnabled(editable)

            local price_top = Field("Price (" .. C.CurrencyName .. ")" .. (item and item.base_price ~= item.price and (" · config: " .. item.base_price) or ""))
            local price = UI.Entry(right, "0")
            price:SetPos(0, price_top)
            price:SetSize(math.floor(fw / 2) - S(5), S(32))
            price:SetNumeric(true)
            price:SetValue(tostring(item and item.price or 1000))

            local rarity = UI.Combo(right)
            rarity:SetPos(math.floor(fw / 2) + S(5), price_top)
            rarity:SetSize(math.floor(fw / 2) - S(5), S(32))
            local rlist = {}
            for key, r in pairs(C.Rarities) do rlist[#rlist + 1] = { key = key, r = r } end
            table.sort(rlist, function(a, b) return a.r.order < b.r.order end)
            local cur_rarity = item and item.rarity or C.DefaultRarity
            for _, e in ipairs(rlist) do rarity:AddChoice(e.r.name, e.key, e.key == cur_rarity) end

            local enabled = UI.Check(right, "Available in the store", not item or item.enabled)
            enabled:SetPos(0, Field("Availability", S(28)))
            enabled:SetSize(fw, S(28))

            -- Class restriction
            local classes = PS:GetClassList()
            local set = item and item.classes or nil
            local ctop = Field("Usable by", S(28) * (1 + math.ceil(#classes / 3)))
            local checks = {}
            local all = UI.Check(right, "All classes", set == nil)
            all:SetPos(0, ctop)
            all:SetSize(fw, S(28))
            local cwid = math.floor(fw / 3)
            for i, class in ipairs(classes) do
                local chk = UI.Check(right, class.display_name or class.name, set ~= nil and set[class.name] == true, function(v)
                    if v then all:SetValue(false) end
                end)
                chk:SetPos(((i - 1) % 3) * cwid, ctop + S(28) * (1 + math.floor((i - 1) / 3)))
                chk:SetSize(cwid, S(28))
                checks[class.name] = chk
            end
            all.DoClick = function(s)
                s:SetValue(not s:GetValue())
                surface.PlaySound("ui/buttonclick.wav")
                if s:GetValue() then for _, chk in pairs(checks) do chk:SetValue(false) end end
            end

            -- Preview
            local pv = vgui.Create("HordePS_Preview", right)
            pv:SetPos(fw + S(20), S(44))
            pv:SetSize(rw - fw - S(20), rh - S(44) - S(56))
            pv:SetPlayerModel(item and item.model or DEFAULT_PREVIEW)
            model.OnLoseFocus = function(s)
                local m = PS:SanitizeModel(s:GetValue())
                if m and util.IsValidModel(m) then pv:SetPlayerModel(m) end
            end

            -- Actions
            local function Gather()
                local list = {}
                if not all:GetValue() then
                    for cname, chk in pairs(checks) do
                        if chk:GetValue() then list[#list + 1] = cname end
                    end
                end
                local _, rkey = rarity:GetSelected()
                return {
                    id      = item and item.id or nil,
                    name    = name:GetValue(),
                    model   = editable and model:GetValue() or nil,
                    price   = tonumber(price:GetValue()) or 0,
                    rarity  = rkey or cur_rarity,
                    enabled = enabled:GetValue(),
                    classes = list,
                }
            end

            local by = rh - S(44)
            local save = UI.Button(right, is_new and "Add playermodel" or "Save changes", "red", function()
                PS:RequestAdmin(is_new and "add" or "update", Gather())
                if is_new then ST.admin_selected = nil end
            end)
            save:SetPos(0, by)
            save:SetSize(S(200), S(40))

            if item and not item.custom then
                local reset = UI.Button(right, "Reset to config", "ghost", function()
                    PS:RequestAdmin("reset", { id = item.id })
                end)
                reset:SetPos(S(210), by)
                reset:SetSize(S(180), S(40))
                reset:SetEnabled(item.overridden == true)
            elseif item and item.custom then
                local del = UI.Button(right, "Delete", "ghost", function()
                    UI.Confirm("Delete playermodel", "Delete " .. item.name .. "? Players who own it will no longer see it.", "Delete", function()
                        PS:RequestAdmin("delete", { id = item.id })
                        ST.admin_selected = nil
                    end)
                end)
                del:SetPos(S(210), by)
                del:SetSize(S(180), S(40))
            end
        end

        local reroll = UI.Button(right, "Reroll daily store", "dark", function()
            UI.Confirm("Reroll daily store", "Pick new random daily deals for everyone right now?", "Reroll", function()
                PS:RequestAdmin("reroll", {})
            end)
        end)
        reroll:SetSize(S(210), S(40))
        reroll:SetPos(rw - S(210), rh - S(44))
    end

    search.OnValueChange = function(_, value)
        ST.admin_search = value
        root:RebuildList()
    end

    root:RebuildList()
    root:RebuildEditor()
    root.Refresh = function(_, what)
        if what == "catalog" then
            root:RebuildList()
            root:RebuildEditor()
        end
    end
end

---------------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------------

local TABS = {
    { id = "loadout",   label = "Loadout",     build = BuildLoadout },
    { id = "inventory", label = "Inventory",   build = BuildInventory },
    { id = "store",     label = "Daily Store", build = BuildStore },
    { id = "contracts", label = "Contracts",   build = BuildContracts },
    { id = "admin",     label = "Admin",       build = BuildAdmin, admin = true },
}

local function TabVisible(tab)
    return not tab.admin or PS.Player.admin
end

function PS:OpenMenu()
    if IsValid(PS.Menu) then PS.Menu:Remove() end
    UI.HideTooltip()

    local w = math.min(S(1340), ScrW() - S(32))
    local h = math.min(S(860), ScrH() - S(32))
    local headH, tabH = S(64), S(44)

    local f = vgui.Create("EditablePanel")
    f:SetSize(w, h)
    f:Center()
    f:MakePopup()
    f:SetAlpha(0)
    f:AlphaTo(255, 0.15)
    PS.Menu = f

    f.Paint = function(_, pw, ph)
        Derma_DrawBackgroundBlur(f, f.Opened or SysTime())
        UI.GradV(0, 0, pw, ph, COL.bg2, COL.bg)
        UI.GradV(0, ph * 0.6, pw, ph * 0.4, Color(0, 0, 0, 0), Color(70, 6, 6, 70))

        -- Header
        UI.GradH(0, 0, pw, headH, Color(26, 26, 26), Color(70, 8, 8))
        UI.Box(0, headH - S(2), pw, S(2), COL.red)
        surface.SetFont("HordePS_Logo")
        local lw = surface.GetTextSize("HORDE ")
        UI.TextShadow("HORDE ", "HordePS_Logo", S(20), headH / 2, COL.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        UI.TextShadow("POINTSHOP", "HordePS_Logo", S(20) + lw, headH / 2, COL.red_light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Balance
        local bx = pw - S(70)
        UI.Text(string.upper(C.CurrencyName), "HordePS_Small", bx, headH / 2 + S(12), COL.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        UI.Price(PS.Player.skulls, "HordePS_Price", bx, headH / 2 - S(8), COL.white, TEXT_ALIGN_RIGHT)

        -- Tab bar background
        UI.GradV(0, headH, pw, tabH, Color(20, 20, 20), COL.bg)
        UI.Box(0, headH + tabH - 1, pw, 1, COL.border)

        local cls = PS:LocalClassName()
        UI.Text("Playing as: " .. (cls and PS:ClassDisplayName(cls) or "—"), "HordePS_Small", pw - S(20), headH + tabH / 2, COL.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        if not PS.Player.loaded then
            UI.Text("Loading pointshop data…", "HordePS_Header", pw / 2, ph / 2, COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    f.PaintOver = function(_, pw, ph)
        UI.Outline(0, 0, pw, ph, COL.red_dark)
    end
    f.Opened = SysTime()

    -- Drag by header
    local drag = vgui.Create("DPanel", f)
    drag:SetPos(0, 0)
    drag:SetSize(w - S(60), headH)
    drag.Paint = nil
    drag:SetCursor("sizeall")
    drag.OnMousePressed = function(s, code)
        if code ~= MOUSE_LEFT then return end
        local mx, my = gui.MousePos()
        local fx, fy = f:GetPos()
        s.Offset = { mx - fx, my - fy }
        s:MouseCapture(true)
    end
    drag.OnMouseReleased = function(s)
        s.Offset = nil
        s:MouseCapture(false)
    end
    drag.Think = function(s)
        if not s.Offset then return end
        local mx, my = gui.MousePos()
        f:SetPos(math.Clamp(mx - s.Offset[1], 0, ScrW() - w), math.Clamp(my - s.Offset[2], 0, ScrH() - h))
    end

    local close = vgui.Create("DButton", f)
    close:SetText("")
    close:SetSize(S(44), S(44))
    close:SetPos(w - S(54), (headH - S(44)) / 2)
    close.Paint = function(s, cw, ch)
        local hov = s:IsHovered()
        if hov then UI.Box(0, 0, cw, ch, COL.red) end
        UI.Outline(0, 0, cw, ch, hov and COL.red_light or COL.border)
        UI.Text("✕", "HordePS_Header", cw / 2, ch / 2, COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        f:Remove()
    end

    local tabbar = vgui.Create("DPanel", f)
    tabbar:SetPos(S(12), headH)
    tabbar:SetSize(w - S(260), tabH)
    tabbar.Paint = nil

    local content = vgui.Create("DPanel", f)
    content:SetPos(0, headH + tabH)
    content:SetSize(w, h - headH - tabH)
    content.Paint = nil

    function f:BuildTabs()
        Clear(tabbar)
        local x = 0
        for _, tab in ipairs(TABS) do
            if TabVisible(tab) then
                surface.SetFont("HordePS_Tab")
                local tw = surface.GetTextSize(string.upper(tab.label))
                local b = vgui.Create("DButton", tabbar)
                b:SetText("")
                b:SetPos(x, 0)
                b:SetSize(tw + S(40), tabH)
                x = x + tw + S(44)
                b.Paint = function(s, bw, bh)
                    local active = ST.tab == tab.id
                    if active then
                        UI.GradV(0, 0, bw, bh, Color(0, 0, 0, 0), Color(150, 18, 18, 200))
                        UI.Box(0, bh - S(3), bw, S(3), COL.red)
                    elseif s:IsHovered() then
                        UI.GradV(0, 0, bw, bh, Color(0, 0, 0, 0), Color(255, 255, 255, 14))
                    end
                    local col = active and COL.white or (s:IsHovered() and COL.text or COL.muted)
                    UI.TextShadow(string.upper(tab.label), "HordePS_Tab", bw / 2, bh / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    if tab.id == "contracts" then
                        local claimable = 0
                        for _, c in ipairs(PS.Contracts.list) do
                            if not c.claimed and c.progress >= c.goal then claimable = claimable + 1 end
                        end
                        if claimable > 0 then
                            local r = S(9)
                            draw.RoundedBox(r, bw - r * 2 - S(2), S(4), r * 2, r * 2, COL.red)
                            UI.Text(claimable, "HordePS_Small", bw - r - S(2), S(4) + r, COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    end
                end
                b.DoClick = function()
                    if ST.tab == tab.id then return end
                    surface.PlaySound("ui/buttonclick.wav")
                    f:SetTab(tab.id)
                end
            end
        end
    end

    function f:SetTab(id, keep_scroll)
        local tab
        for _, t in ipairs(TABS) do
            if t.id == id and TabVisible(t) then tab = t end
        end
        tab = tab or TABS[1]

        local scroll
        if keep_scroll and IsValid(self.Page) and IsValid(self.Page.Scroll) then
            scroll = self.Page.Scroll:GetVBar():GetScroll()
        end

        ST.tab = tab.id
        UI.HideTooltip()
        Clear(content)
        local page = vgui.Create("DPanel", content)
        page:SetSize(content:GetSize())
        page.Paint = nil
        self.Page = page
        tab.build(page)

        if scroll and IsValid(page.Scroll) then
            local sp = page.Scroll
            sp:InvalidateLayout(true)
            timer.Simple(0, function()
                if IsValid(sp) then sp:GetVBar():SetScroll(scroll) end
            end)
        end
    end

    function f:OnDataUpdated(what)
        if what == "player" then
            if self.AdminState ~= PS.Player.admin then
                self.AdminState = PS.Player.admin
                self:BuildTabs()
                if ST.tab == "admin" and not PS.Player.admin then self:SetTab("loadout") end
            end
        end
        if IsValid(self.Page) and self.Page.Refresh then self.Page:Refresh(what) end
    end

    f.OnKeyCodePressed = function(s, key)
        if key == KEY_F4 or key == KEY_ESCAPE then s:Remove() end
    end
    -- ESC opens the game menu instead of reaching the panel: close when it appears.
    f.GameUIWas = gui.IsGameUIVisible()
    f.Think = function(s)
        local visible = gui.IsGameUIVisible()
        if visible and not s.GameUIWas then
            gui.HideGameUI()
            s:Remove()
            return
        end
        s.GameUIWas = visible
    end
    f.OnRemove = function()
        UI.HideTooltip()
    end

    f.AdminState = PS.Player.admin
    f:BuildTabs()
    f:SetTab(ST.tab)
end

hook.Add("Horde_PS_Updated", "Horde_PS_Menu", function(what)
    if IsValid(PS.Menu) then PS.Menu:OnDataUpdated(what) end
end)
