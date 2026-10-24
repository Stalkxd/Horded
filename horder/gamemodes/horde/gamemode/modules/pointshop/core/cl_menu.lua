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
ST.admin_sub = ST.admin_sub or "items"

local function L(...) return PS:L(...) end

local DEFAULT_PREVIEW = "models/player/group01/male_07.mdl"

local function Clear(panel)
    for _, child in ipairs(panel:GetChildren()) do child:Remove() end
end

local function Truncate(text, font, width)
    surface.SetFont(font)
    if surface.GetTextSize(text) <= width then return text end
    while #text > 1 and surface.GetTextSize(text .. "…") > width do text = PS:DropLastChar(text) end
    return text .. "…"
end

-- What a class / subclass wears without its own pointshop model: the parent class's
-- pointshop model, Horde's class model, or the player's current model.
local function DefaultModelFor(key)
    local parent = PS:ParentClass(key)
    if parent ~= key then
        local inherited = PS:GetEquipped(parent)
        if inherited then return inherited.model end
    end
    local class = HORDE.classes and HORDE.classes[parent]
    if class and class.model and class.model ~= "" then
        return player_manager.TranslatePlayerModel(class.model)
    end
    local ply = LocalPlayer()
    if parent == PS:LocalClassName() and IsValid(ply) and not PS:GetEquipped(key) then
        return ply:GetModel()
    end
    return DEFAULT_PREVIEW
end

local function ConfirmBuy(item)
    local price, discount = PS:GetPrice(item.id)
    local body = L("buy_body", item.name, PS:FormatNumber(price))
    if discount > 0 then body = body .. "\n" .. L("deal_line", discount) end
    body = body .. "\n" .. L("usable_by", PS:ClassesText(item))
    UI.Confirm(L("confirm_purchase"), body, L("buy"), function() PS:RequestBuy(item.id) end)
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
    ST.card_sub = ST.card_sub or {}
    local local_class, local_sub = PS:LocalClassName(), PS:LocalSubclassName()
    if local_class and local_sub and not ST.card_sub[local_class] then ST.card_sub[local_class] = local_sub end
    if not PS:IsLoadoutKey(ST.class) then
        ST.class = (local_class and (ST.card_sub[local_class] or local_class)) or (classes[1] and classes[1].name)
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
        local subs = PS:GetSubclasses(class.name)
        local function CardKey()
            local k = ST.card_sub[class.name]
            return (k and PS:ParentClass(k) == class.name) and k or class.name
        end
        local b = vgui.Create("DButton", row)
        b:SetText("")
        b:SetPos((i - 1) * (cw + gap), 0)
        b:SetSize(cw, rowH)

        -- "^" in the top-right corner: switch this card to one of the class's subclasses.
        local up
        if #subs > 1 then
            up = vgui.Create("DButton", b)
            up:SetText("")
            up:SetSize(S(22), S(20))
            up:SetPos(cw - S(25), S(17))
            up:SetTooltip(L("change_subclass"))
            up.Paint = function(s, w, h)
                if not (b:IsHovered() or s:IsHovered() or b:IsChildHovered()) then return end
                UI.Box(0, 0, w, h, s:IsHovered() and COL.red or Color(0, 0, 0, 180))
                UI.Outline(0, 0, w, h, s:IsHovered() and COL.red_light or COL.border_hi)
                UI.Text("^", "HordePS_Tab", w / 2, h / 2 + S(3), COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            up.DoClick = function()
                PS:Sound("ui/buttonclick.wav")
                local m = UI.Menu()
                local ply = LocalPlayer()
                for _, key in ipairs(subs) do
                    local unlocked = key == class.name or not (IsValid(ply) and ply.Horde_GetSubclassUnlocked) or ply:Horde_GetSubclassUnlocked(key)
                    local label = ((CardKey() == key) and "✓  " or "     ") .. PS:ClassDisplayName(key) .. (unlocked and "" or ("  (" .. L("locked") .. ")"))
                    m:AddOption(label, function()
                        ST.card_sub[class.name] = key
                        ST.class = key
                        root:RebuildBody()
                    end)
                end
                m:Open()
            end
        end

        b.Paint = function(s, w, h)
            local key = CardKey()
            local sel, hov = PS:ParentClass(ST.class or "") == class.name, s:IsHovered() or s:IsChildHovered()
            if sel then
                UI.GradV(0, 0, w, h, Color(150, 18, 18), COL.red_deep)
            else
                UI.GradV(0, 0, w, h, hov and COL.panel2 or COL.panel, COL.bg)
            end
            UI.Outline(0, 0, w, h, sel and COL.red_light or (hov and COL.border_hi or COL.border))
            if sel then UI.Box(0, h - S(3), w, S(3), COL.white) end

            local icon = S(42)
            surface.SetMaterial(UI.KeyIcon(key))
            local c = (sel or hov) and 255 or 165
            surface.SetDrawColor(c, c, c)
            surface.DrawTexturedRect((w - icon) / 2, S(18), icon, icon)

            local name = Truncate(PS:Upper(PS:ClassDisplayName(key)), "HordePS_ItemName", w - S(8))
            UI.TextShadow(name, "HordePS_ItemName", w / 2, S(72), COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local item = PS:GetEquipped(key)
            local inherited = not item and key ~= class.name and PS:GetEquipped(class.name)
            local shown = item or inherited
            local sub = shown and Truncate(shown.name, "HordePS_Small", w - S(8)) or L("default")
            UI.Text(sub, "HordePS_Small", w / 2, S(91), item and UI.RarityColor(item) or COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if class.name == PS:LocalClassName() then
                -- Strip across the top so it never covers the class icon.
                UI.Box(1, 1, w - 2, S(14), COL.white)
                UI.Text(L("playing"), "HordePS_Small", w / 2, S(8), COL.bg, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        b.DoClick = function()
            local key = CardKey()
            if ST.class == key then return end
            PS:Sound("ui/buttonclick.wav")
            ST.class = key
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
            Label(body, L("no_classes"), "HordePS_Header", COL.muted):SetPos(pad, pad)
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
            UI.TextShadow(PS:Upper(PS:ClassDisplayName(class_name)), "HordePS_Big", S(16), S(10), COL.white)
            local it = s.ShowItem
            UI.TextShadow(it and it.name or L("default_model"), "HordePS_Header", S(16), S(52), it and UI.RarityColor(it) or COL.muted)
            if s.Hovering then
                UI.Text(L("preview"), "HordePS_Small", w - S(12), S(14), COL.red_light, TEXT_ALIGN_RIGHT)
            end
            UI.Text(L("drag_rotate"), "HordePS_Small", w / 2, h - S(16), COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Right column
        local rx = pad * 2 + pw
        local rw = bw - rx - pad
        local right = vgui.Create("DPanel", body)
        right:SetPos(rx, pad)
        right:SetSize(rw, bh - pad * 2)
        right.Paint = function(_, w)
            UI.Heading(L("playermodel"), 0, 0, w, L("class_only", PS:ClassDisplayName(class_name)))
        end

        -- Equipped slot card
        local eqH = S(132)
        local eq = Card(right)
        eq:SetPos(0, S(40))
        eq:SetSize(rw, eqH)

        local slot = vgui.Create("HordePS_Slot", eq)
        slot:SetPos(S(10), S(10))
        slot:SetSize(eqH - S(20), eqH - S(20))
        slot:SetItem(equipped, { empty_label = L("slot_default"), badge = equipped and L("badge_equipped") or nil })

        local tx = eqH + S(4)
        local info = vgui.Create("DPanel", eq)
        info:SetPos(tx, S(10))
        info:SetSize(rw - tx - S(10), eqH - S(20))
        info.Paint = function(_, w)
            if equipped then
                local r = PS:GetRarity(equipped.rarity)
                UI.Text(equipped.name, "HordePS_Header", 0, 0, r.color)
                UI.Text(L("rarity_pm", PS:RarityName(equipped.rarity)), "HordePS_Small", 0, S(28), COL.muted)
                UI.Text(L("usable_by", PS:ClassesText(equipped)), "HordePS_Body", 0, S(48), COL.text)
            else
                UI.Text(L("default_model"), "HordePS_Header", 0, 0, COL.white)
                local parent = PS:ParentClass(class_name)
                local inherited = parent ~= class_name and PS:GetEquipped(parent)
                if inherited then
                    UI.Text(L("inherits", PS:ClassDisplayName(parent), inherited.name), "HordePS_Body", 0, S(30), COL.muted)
                else
                    UI.Text(L("no_equipped"), "HordePS_Body", 0, S(30), COL.muted)
                end
            end
        end

        local bwid = S(170)
        local def = UI.Button(info, L("use_default"), "ghost", function()
            PS:RequestEquip(class_name, "")
        end)
        def:SetSize(bwid, S(32))
        def:SetPos(0, eqH - S(20) - S(32))
        def:SetEnabled(equipped ~= nil)

        local browse = UI.Button(info, L("browse_store"), "dark", function()
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
            UI.Heading(L("your_models"), 0, 0, w, L("your_models_sub", #owned, PS:ClassDisplayName(class_name)))
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
                badge = (item and is_eq) and L("badge_equipped") or nil,
                empty_label = L("slot_default"),
                tooltip = item and { { is_eq and L("equipped") or L("click_equip"), "HordePS_Small", COL.red_light } } or nil,
            })
            s.DoClick = function()
                if is_eq then return end
                PS:Sound("ui/buttonclick.wav")
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
                UI.Text(L("none_for_class", PS:ClassDisplayName(class_name)), "HordePS_BodyBold", S(8), h / 2 - S(10), COL.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                UI.Text(L("check_daily"), "HordePS_Body", S(8), h / 2 + S(12), COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
    { "acquired", "sort_oldest" },
    { "newest",   "sort_newest" },
    { "name",     "sort_name" },
    { "rarity",   "sort_rarity" },
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
        for k, key in ipairs(PS:GetSubclasses(class.name)) do
            if PS:CanClassUse(item, key) then
                any = true
                local on = PS.Player.equipped[key] == item.id
                m:AddOption((on and "✓  " or "     ") .. (k > 1 and "   › " or "") .. PS:ClassDisplayName(key), function()
                    PS:RequestEquip(key, on and "" or item.id)
                end)
            end
        end
    end
    if not any then m:AddOption(L("no_class_can")) end
    m:Open()
end

local function BuildInventory(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local per_page = math.max(1, C.SlotsPerPage)
    local slots = PS:SlotCount()
    local pages = math.max(1, math.ceil(slots / per_page))
    local cols = 8
    local rows = math.ceil(per_page / cols)

    local lw = math.floor((W - pad * 3) * 0.66)
    local left = vgui.Create("DPanel", root)
    left:SetPos(pad, pad)
    left:SetSize(lw, H - pad * 2)
    left.Paint = function(_, w)
        UI.Heading(L("backpack"), 0, 0, w, L("slots_used", #PS.Player.inventory, slots))
    end

    local sort = UI.Combo(left)
    sort:SetSize(S(170), S(28))
    sort:SetPos(lw - S(170), 0)
    for _, s in ipairs(INV_SORTS) do sort:AddChoice(L(s[2]), s[1], s[1] == ST.inv_sort) end
    sort.OnSelect = function(_, _, _, value)
        ST.inv_sort = value
        root:RebuildGrid()
    end

    local grid = vgui.Create("DPanel", left)
    grid:SetPos(0, S(44))
    grid:SetSize(lw, left:GetTall() - S(44) - S(52))
    grid.Paint = nil
    -- Mouse wheel flips pages (the slots forward their wheel events here).
    grid.OnMouseWheeled = function(_, delta)
        local page = math.Clamp(ST.inv_page - delta, 1, pages)
        if page ~= ST.inv_page then
            ST.inv_page = page
            PS:Sound("ui/buttonrollover.wav")
            root:RebuildGrid()
        end
        return true
    end

    local nav = vgui.Create("DPanel", left)
    nav:SetPos(0, left:GetTall() - S(42))
    nav:SetSize(lw, S(42))
    nav.Paint = function(_, w, h)
        UI.Text(L("page", ST.inv_page, pages), "HordePS_Tab", w / 2, h / 2, COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
                UI.Text(L("select_item"), "HordePS_Header", w / 2, h / 2 - S(12), COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                UI.Text(L("hint_dbl"), "HordePS_Small", w / 2, h / 2 + S(14), COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                UI.Text(L("hint_right"), "HordePS_Small", w / 2, h / 2 + S(32), COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            return
        end
        details.PaintOver = nil

        local ph = math.floor(dh * 0.45)
        local pv = vgui.Create("HordePS_Preview", details)
        pv:SetPos(S(10), S(10))
        pv:SetSize(dw - S(20), ph)
        pv:SetPlayerModel(item.model)

        local info = vgui.Create("DPanel", details)
        info:SetPos(S(14), ph + S(22))
        info:SetSize(dw - S(28), dh - ph - S(22) - S(184))
        info.Paint = function(_, w)
            local r = PS:GetRarity(item.rarity)
            UI.Text(Truncate(item.name, "HordePS_Big", w), "HordePS_Big", 0, 0, r.color)
            UI.Text(L("rarity_pm", PS:RarityName(item.rarity)), "HordePS_Body", 0, S(42), COL.muted)
            UI.Text(L("usable_by_label"), "HordePS_BodyBold", 0, S(70), COL.white)
            UI.Text(Truncate(PS:ClassesText(item), "HordePS_Body", w), "HordePS_Body", 0, S(90), COL.text)
            local on = PS:EquippedOn(item.id)
            UI.Text(L("equipped_on_label"), "HordePS_BodyBold", 0, S(118), COL.white)
            UI.Text(#on > 0 and Truncate(table.concat(on, ", "), "HordePS_Body", w) or L("nothing"), "HordePS_Body", 0, S(138), #on > 0 and COL.red_light or COL.dim)
        end

        local cur = PS:LocalSubclassName()
        local bw = dw - S(28)
        local b1 = UI.Button(details, cur and L("equip_on", PS:ClassDisplayName(cur)) or L("equip_current"), "red", function()
            PS:RequestEquip(cur, item.id)
        end)
        b1:SetSize(bw, S(38))
        b1:SetPos(S(14), dh - S(180))
        b1:SetEnabled(cur ~= nil and PS:CanClassUse(item, cur) and PS.Player.equipped[cur] ~= item.id)

        local b2 = UI.Button(details, L("equip_on_class"), "dark", function() EquipMenu(item) end)
        b2:SetSize(bw, S(38))
        b2:SetPos(S(14), dh - S(136))

        local b3 = UI.Button(details, L("unequip_all"), "ghost", function()
            -- One request at a time: the server rate-limits equip requests.
            local n = 0
            for _, class in ipairs(PS:GetClassList()) do
                for _, key in ipairs(PS:GetSubclasses(class.name)) do
                    if PS.Player.equipped[key] == item.id then
                        timer.Simple(n * 0.3, function() PS:RequestEquip(key, "") end)
                        n = n + 1
                    end
                end
            end
        end)
        b3:SetSize(bw, S(34))
        b3:SetPos(S(14), dh - S(92))
        b3:SetEnabled(#PS:EquippedOn(item.id) > 0)

        local refund = PS:SellPrice(item.id)
        local selling = (tonumber(C.SellPercent) or 0) > 0
        local b4 = UI.Button(details, selling and L("sell", PS:FormatNumber(refund) .. " " .. PS:Currency()) or L("sell_off"), "ghost", function()
            local body = L("sell_body", item.name, PS:FormatNumber(refund))
            local on = PS:EquippedOn(item.id)
            if #on > 0 then body = body .. "\n" .. L("sell_equipped", table.concat(on, ", ")) end
            UI.Confirm(L("sell_title"), body, L("sell_short"), function()
                ST.inv_selected = nil
                PS:RequestSell(item.id)
            end)
        end)
        b4:SetSize(bw, S(34))
        b4:SetPos(S(14), dh - S(48))
        b4:SetEnabled(selling)
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
            if index > slots then break end
            local item = items[index]
            local col, r = (i - 1) % cols, math.floor((i - 1) / cols)
            local s = vgui.Create("HordePS_Slot", grid)
            s:SetPos(ox + col * (size + gap), r * (size + gap))
            s:SetSize(size, size)
            s.OnMouseWheeled = function(_, delta) return grid:OnMouseWheeled(delta) end
            if item then
                local on = PS:EquippedOn(item.id)
                s:SetItem(item, {
                    show_name = true,
                    selected = ST.inv_selected == item.id,
                    badge = #on > 0 and L("badge_equipped") or nil,
                    tooltip = #on > 0 and { { L("equipped_on", table.concat(on, ", ")), "HordePS_Small", COL.red_light } } or nil,
                })
                s.DoClick = function()
                    PS:Sound("ui/buttonclick.wav")
                    ST.inv_selected = item.id
                    root:RebuildGrid()
                    root:RebuildDetails()
                end
                s.DoDoubleClick = function()
                    local cur = PS:LocalSubclassName()
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
    { "price_asc",  "sort_price_asc" },
    { "price_desc", "sort_price_desc" },
    { "name",       "sort_name" },
    { "rarity",     "sort_rarity" },
}

local function BuyButton(parent, item)
    local b = UI.Button(parent, L("buy"), "red", function() ConfirmBuy(item) end)
    b.Think = function(s)
        local owned = PS:Owns(item.id)
        local full = #PS.Player.inventory >= PS:SlotCount()
        s:SetEnabled(not owned and not full)
        s:SetLabel(owned and L("owned") or (full and L("inv_full") or L("buy")))
    end
    return b
end

local function DailyCard(parent, item, deal, w, h)
    local card = vgui.Create("DPanel", parent)
    card:SetSize(w, h)
    local rc = UI.RarityColor(item)
    local info_h = S(132)

    card.Paint = function(_, pw, ph)
        UI.GradV(0, 0, pw, ph, Color(40, 40, 40), Color(20, 20, 20))
        UI.GradV(0, ph - info_h - S(40), pw, info_h + S(40), Color(0, 0, 0, 0), ColorAlpha(rc, 12))
        UI.Box(0, 0, pw, S(3), COL.red)
        UI.Outline(0, 0, pw, ph, ColorAlpha(rc, 120))

        local y = ph - info_h
        UI.Text(Truncate(item.name, "HordePS_Header", pw - S(24)), "HordePS_Header", S(12), y, rc)
        UI.Text(PS:RarityName(item.rarity) .. " · " .. Truncate(PS:ClassesText(item), "HordePS_Small", pw - S(110)), "HordePS_Small", S(12), y + S(28), COL.muted)

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
        UI.Text(L("daily_deal"), "HordePS_Small", S(10), S(10), COL.white)
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
        badge = PS:Owns(item.id) and L("badge_owned") or (deal and L("badge_daily") or nil),
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
        UI.Heading(L("daily_deals"), 0, 0, w, L("daily_sub", PS:FormatTime(PS.Daily.reset_at - RealTime())))
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
            UI.Text(L("no_deals"), "HordePS_Body", 0, h / 2, COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
        UI.Heading(L("store"), 0, 0, w, L("store_sub"))
    end

    local bar = vgui.Create("DPanel", sp)
    bar:Dock(TOP)
    bar:SetTall(S(36))
    bar:DockMargin(0, 0, 0, S(12))
    bar.Paint = nil

    local class_cb = UI.Combo(bar)
    class_cb:SetPos(0, S(2))
    class_cb:SetSize(S(200), S(30))
    class_cb:AddChoice(L("all_classes"), "all", ST.store_class == "all")
    for _, class in ipairs(PS:GetClassList()) do
        for k, key in ipairs(PS:GetSubclasses(class.name)) do
            class_cb:AddChoice((k > 1 and "   › " or "") .. PS:ClassDisplayName(key), key, ST.store_class == key)
        end
    end

    local sort_cb = UI.Combo(bar)
    sort_cb:SetPos(S(210), S(2))
    sort_cb:SetSize(S(190), S(30))
    for _, s in ipairs(STORE_SORTS) do sort_cb:AddChoice(L(s[2]), s[1], s[1] == ST.store_sort) end

    local search = UI.Entry(bar, L("search"))
    search:SetPos(S(410), S(2))
    search:SetSize(S(240), S(30))
    search:SetValue(ST.store_search or "")
    search:SetUpdateOnType(true)

    local hide = UI.Check(bar, L("hide_owned"), ST.hide_owned)
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
        UI.Text(L("items_count", items_shown), "HordePS_Small", w, h / 2, COL.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
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
                UI.Text(L("no_match"), "HordePS_Body", 0, eh / 2, COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
        PS:Sound("ui/buttonclick.wav")
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
        UI.GradV(0, 0, w, h, Color(44, 44, 44), Color(24, 24, 24))
        UI.Outline(0, 0, w, h, COL.border)
        UI.Box(0, 0, S(5), h, COL.red)
        UI.TextShadow(L("contracts_title"), "HordePS_Big", S(24), S(14), COL.white)
        UI.Text(L("contracts_info"),
            "HordePS_Body", S(24), S(60), COL.text)
        UI.Text(L("new_in", PS:FormatTime(PS.Contracts.reset_at - RealTime())), "HordePS_BodyBold", S(24), S(84), COL.red_light)

        local done, total, earned = 0, #PS.Contracts.list, 0
        for _, c in ipairs(PS.Contracts.list) do
            if c.progress >= c.goal then done = done + 1 end
            if c.claimed then earned = earned + (c.reward or 0) end
        end
        UI.Text(done .. " / " .. total, "HordePS_Huge", w - S(24), S(10), COL.white, TEXT_ALIGN_RIGHT)
        UI.Text(L("completed"), "HordePS_Small", w - S(24), S(64), COL.muted, TEXT_ALIGN_RIGHT)
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
                UI.Text(L("no_contracts"), "HordePS_Body", 0, h / 2, COL.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
                UI.Text(PS:Upper(PS:Localized(c.name) or ""), "HordePS_Header", x, S(12), c.claimed and COL.muted or COL.white)
                UI.Text(PS:Localized(c.desc) or "", "HordePS_Body", x, S(40), COL.muted)

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
                UI.Text(L("reward"), "HordePS_Small", w - S(20), S(14), COL.muted, TEXT_ALIGN_RIGHT)
                UI.Price(c.reward or 0, "HordePS_Price", w - S(20), S(42), c.claimed and COL.dim or COL.white, TEXT_ALIGN_RIGHT)
            end

            local btn
            if c.claimed then
                btn = UI.Button(row, L("claimed"), "ghost")
                btn:SetEnabled(false)
            elseif complete then
                btn = UI.Button(row, L("claim"), "red", function() PS:RequestClaim(c.index or i) end)
                local paint = btn.Paint
                btn.Paint = function(s, w, h)
                    paint(s, w, h)
                    local a = (math.sin(RealTime() * 5) + 1) * 0.5
                    UI.Outline(0, 0, w, h, Color(255, 255, 255, 60 + 120 * a), 2)
                end
            else
                btn = UI.Button(row, L("in_progress"), "ghost")
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
-- SETTINGS
---------------------------------------------------------------------------

local function BuildSettings(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local cw = math.floor((W - pad * 3) / 2)

    -- General
    local gen = Card(root)
    gen:SetPos(pad, pad)
    gen:SetSize(cw, S(250))
    local gpaint = gen.Paint
    gen.Paint = function(s, w, h)
        gpaint(s, w, h)
        UI.Heading(L("general"), S(16), S(14), w - S(32))
        UI.Text(PS:Upper(L("language")), "HordePS_Small", S(16), S(58), COL.muted)
    end

    local lang = UI.Combo(gen)
    lang:SetPos(S(16), S(78))
    lang:SetSize(cw - S(32), S(32))
    local current = PS.LangConVar:GetString()
    lang:AddChoice(L("lang_default"), "", current == "")
    lang:AddChoice(L("lang_auto"), "auto", current == "auto")
    for _, l in ipairs(PS.Languages) do lang:AddChoice(l.name, l.id, current == l.id) end
    lang.OnSelect = function(_, _, _, value)
        RunConsoleCommand("horde_ps_language", value)
        -- Convars update on the next frame; rebuild the whole window in the new language.
        timer.Simple(0.05, function()
            if IsValid(PS.Menu) then PS.Menu:Rebuild() end
        end)
    end

    local snd = UI.Check(gen, L("sounds"), PS.SoundConVar:GetBool(), function(v)
        RunConsoleCommand("horde_ps_sounds", v and "1" or "0")
    end)
    snd:SetPos(S(16), S(130))
    snd:SetSize(cw - S(32), S(30))


    -- Controls
    local ctl = Card(root)
    ctl:SetPos(pad * 2 + cw, pad)
    ctl:SetSize(cw, S(250))
    local cpaint = ctl.Paint
    ctl.Paint = function(s, w, h)
        cpaint(s, w, h)
        UI.Heading(L("controls"), S(16), S(14), w - S(32))
        UI.Text(PS:Upper(L("keybind")), "HordePS_Small", S(16), S(58), COL.muted)
        UI.Text(L("keybind_hint"), "HordePS_Small", S(16), S(126), COL.dim)
        UI.Text("!ps · horde_pointshop · horde_pointshop_toggle", "HordePS_Small", S(16), S(146), COL.dim)
    end

    local binder = UI.Binder(ctl, PS.KeyConVar:GetInt(), function(code)
        RunConsoleCommand("horde_ps_open_key", tostring(code))
    end)
    binder:SetPos(S(16), S(78))
    binder:SetSize(cw - S(32) - S(130), S(36))

    local clear = UI.Button(ctl, L("clear"), "ghost", function()
        RunConsoleCommand("horde_ps_open_key", "0")
        binder:SetValue(0)
    end)
    clear:SetPos(cw - S(16) - S(120), S(78))
    clear:SetSize(S(120), S(36))

    -- HUD: contract tracker
    local hud = Card(root)
    hud:SetPos(pad, pad * 2 + S(250))
    hud:SetSize(cw, S(190))
    local hpaint = hud.Paint
    hud.Paint = function(s, w, h)
        hpaint(s, w, h)
        UI.Heading(L("hud"), S(16), S(14), w - S(32))
        UI.Text(PS:Upper(L("tracker_pos")), "HordePS_Small", S(16), S(100), COL.muted)
    end

    local tracker = UI.Check(hud, L("tracker"), PS.TrackerConVar:GetBool(), function(v)
        RunConsoleCommand("horde_ps_tracker", v and "1" or "0")
    end)
    tracker:SetPos(S(16), S(58))
    tracker:SetSize(cw - S(32), S(30))

    local pos = UI.Combo(hud)
    pos:SetPos(S(16), S(120))
    pos:SetSize(cw - S(32), S(32))
    local cur_pos = PS.TrackerPosConVar:GetString()
    pos:AddChoice(L("pos_right"), "right", cur_pos ~= "left")
    pos:AddChoice(L("pos_left"), "left", cur_pos == "left")
    pos.OnSelect = function(_, _, _, value) RunConsoleCommand("horde_ps_tracker_pos", value) end
end

---------------------------------------------------------------------------
-- ADMIN: ITEMS
---------------------------------------------------------------------------

local function BuildAdminItems(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local lw = S(380)

    local left = vgui.Create("DPanel", root)
    left:SetPos(pad, pad)
    left:SetSize(lw, H - pad * 2)
    left.Paint = function(_, w)
        UI.Heading(L("playermodels"), 0, 0, w, L("n_items", #PS.CatalogOrder))
    end

    local search = UI.Entry(left, L("search"))
    search:SetPos(0, S(40))
    search:SetSize(lw - S(120), S(30))
    search:SetValue(ST.admin_search or "")
    search:SetUpdateOnType(true)

    local add = UI.Button(left, L("new"), "red", function()
        ST.admin_selected = "__new"
        root:RebuildList()
        root:RebuildEditor()
    end)
    add:SetPos(lw - S(110), S(40))
    add:SetSize(S(110), S(30))

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
                    if not item.enabled then tags[#tags + 1] = L("tag_disabled") end
                    if item.custom then tags[#tags + 1] = L("tag_custom") end
                    if item.overridden and not item.custom then tags[#tags + 1] = L("tag_edited") end
                    if item.classes then tags[#tags + 1] = L("tag_classes", table.Count(item.classes)) end
                    UI.Text(table.concat(tags, " · "), "HordePS_Small", x, S(30), COL.muted)
                    UI.Price(item.price, "HordePS_BodyBold", w - S(10), h / 2, COL.white, TEXT_ALIGN_RIGHT)
                end
                row.DoClick = function()
                    PS:Sound("ui/buttonclick.wav")
                    ST.admin_selected = id
                    root:RebuildList()
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
            right.Paint = function(_, w)
                UI.Heading(L("admin_title"), 0, 0, w)
                local y = S(50)
                for i = 1, 5 do
                    UI.Text(L("admin_help" .. i), "HordePS_Body", 0, y, COL.text)
                    y = y + S(26)
                end
                UI.Text("horde_ps_give_skulls <name|steamid|^> <amount>", "HordePS_Small", 0, y + S(6), COL.dim)
            end
        else
            right.Paint = function(_, w)
                UI.Heading(is_new and L("new_pm") or L("edit_pm"), 0, 0, w,
                    is_new and L("added_custom") or (item.custom and L("src_custom", item.id) or L("src_config", item.id)))
            end

            local editable = is_new or item.custom
            local fw = math.floor(rw * 0.56)
            local y = S(44)
            local function Field(label, h)
                local l = Label(right, PS:Upper(label), "HordePS_Small", COL.muted)
                l:SetPos(0, y)
                y = y + S(18)
                local top = y
                y = y + (h or S(32)) + S(10)
                return top
            end

            local name = UI.Entry(right, L("ph_name"))
            name:SetPos(0, Field(L("f_name")))
            name:SetSize(fw, S(32))
            name:SetValue(item and item.name or "")
            name:SetEnabled(editable)

            -- Model path + "+" picker
            local model_top = Field(L("f_model"))
            local model = UI.Entry(right, "models/player/....mdl")
            model:SetPos(0, model_top)
            model:SetSize(fw - S(42), S(32))
            model:SetValue(item and item.model or "")
            model:SetEnabled(editable)

            local pv -- preview, created below
            local pick = UI.Button(right, "+", "red", function()
                UI.ModelPicker(function(path, pname)
                    if not IsValid(model) then return end
                    model:SetValue(path)
                    if string.Trim(name:GetValue()) == "" then name:SetValue(pname) end
                    if IsValid(pv) then pv:SetPlayerModel(path) end
                end)
            end)
            pick:SetLabelFont("HordePS_Header")
            pick:SetPos(fw - S(34), model_top)
            pick:SetSize(S(34), S(32))
            pick:SetTooltip(L("picker_tip"))
            pick:SetEnabled(editable)

            local price_top = Field(L("f_price") .. (item and item.base_price ~= item.price and L("f_price_cfg", item.base_price) or ""))
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
            for _, e in ipairs(rlist) do rarity:AddChoice(PS:RarityName(e.key), e.key, e.key == cur_rarity) end

            local enabled = UI.Check(right, L("avail_store"), not item or item.enabled)
            enabled:SetPos(0, Field(L("f_avail"), S(28)))
            enabled:SetSize(fw, S(28))

            -- Classes and their subclasses ("›"), grouped in columns.
            local keys = {}
            for _, class in ipairs(PS:GetClassList()) do
                for k, key in ipairs(PS:GetSubclasses(class.name)) do keys[#keys + 1] = { key = key, sub = k > 1 } end
            end
            local set = item and item.classes or nil
            local rows = math.ceil(#keys / 3)
            local rowh = S(25)
            local ctop = Field(L("f_usable") .. " · " .. L("subclass_hint"), S(28) + rowh * rows)
            local checks = {}
            local all = UI.Check(right, L("all_classes"), set == nil)
            all:SetPos(0, ctop)
            all:SetSize(fw, S(26))
            local cwid = math.floor(fw / 3)
            for i, e in ipairs(keys) do
                local chk = UI.Check(right, (e.sub and "› " or "") .. PS:ClassDisplayName(e.key), set ~= nil and set[e.key] == true, function(v)
                    if v then all:SetValue(false) end
                end)
                local col, r = math.floor((i - 1) / rows), (i - 1) % rows
                chk:SetPos(col * cwid + (e.sub and S(14) or 0), ctop + S(28) + rowh * r)
                chk:SetSize(cwid - (e.sub and S(14) or 0), rowh)
                checks[e.key] = chk
            end
            all.DoClick = function(s)
                s:SetValue(not s:GetValue())
                PS:Sound("ui/buttonclick.wav")
                if s:GetValue() then for _, chk in pairs(checks) do chk:SetValue(false) end end
            end

            pv = vgui.Create("HordePS_Preview", right)
            pv:SetPos(fw + S(20), S(44))
            pv:SetSize(rw - fw - S(20), rh - S(44) - S(56))
            pv:SetPlayerModel(item and item.model or DEFAULT_PREVIEW)
            model.OnLoseFocus = function(s)
                local m = PS:SanitizeModel(s:GetValue())
                if m and util.IsValidModel(m) then pv:SetPlayerModel(m) end
            end

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
            local save = UI.Button(right, is_new and L("add_pm") or L("save"), "red", function()
                PS:RequestAdmin(is_new and "add" or "update", Gather())
                if is_new then ST.admin_selected = nil end
            end)
            save:SetPos(0, by)
            save:SetSize(S(200), S(40))

            if item and not item.custom then
                local reset = UI.Button(right, L("reset_cfg"), "ghost", function()
                    PS:RequestAdmin("reset", { id = item.id })
                end)
                reset:SetPos(S(210), by)
                reset:SetSize(S(190), S(40))
                reset:SetEnabled(item.overridden == true)
            elseif item and item.custom then
                local del = UI.Button(right, L("delete"), "ghost", function()
                    UI.Confirm(L("delete_title"), L("delete_body", item.name), L("delete"), function()
                        PS:RequestAdmin("delete", { id = item.id })
                        ST.admin_selected = nil
                    end)
                end)
                del:SetPos(S(210), by)
                del:SetSize(S(190), S(40))
            end
        end

        local reroll = UI.Button(right, L("reroll"), "dark", function()
            UI.Confirm(L("reroll"), L("reroll_body"), L("confirm"), function()
                PS:RequestAdmin("reroll", {})
            end)
        end)
        reroll:SetSize(S(230), S(40))
        reroll:SetPos(rw - S(230), rh - S(44))
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
-- ADMIN: BANK
---------------------------------------------------------------------------

local function BuildAdminBank(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local lw = S(460)

    local left = vgui.Create("DPanel", root)
    left:SetPos(pad, pad)
    left:SetSize(lw, H - pad * 2)
    left.Paint = function(_, w, h)
        UI.Heading(L("bank_online"), 0, 0, w, tostring(#(PS.AdminData.bank or {})))
        UI.Heading(L("bank_lookup"), 0, h - S(80), w)
    end

    local refresh = UI.Button(left, L("bank_refresh"), "dark", function() PS:RequestAdmin("bank_list", {}) end)
    refresh:SetSize(S(120), S(28))
    refresh:SetPos(lw - S(120), 0)

    local list = UI.Scroll(left)
    list:SetPos(0, S(40))
    list:SetSize(lw, left:GetTall() - S(40) - S(96))

    local sid = UI.Entry(left, "STEAM_0:1:12345678")
    sid:SetPos(0, left:GetTall() - S(40))
    sid:SetSize(lw - S(130), S(34))

    local find = UI.Button(left, L("find"), "red", function()
        PS:RequestAdmin("bank_lookup", { steamid = sid:GetValue() })
    end)
    find:SetPos(lw - S(120), left:GetTall() - S(40))
    find:SetSize(S(120), S(34))

    local right = Card(root)
    right:SetPos(pad * 2 + lw, pad)
    right:SetSize(W - lw - pad * 3, S(330))

    function root:RebuildList()
        list:Clear()
        for _, p in ipairs(PS.AdminData.bank or {}) do
            local row = vgui.Create("DButton", list)
            row:SetText("")
            row:Dock(TOP)
            row:SetTall(S(46))
            row:DockMargin(0, 0, S(10), S(4))
            row.Paint = function(s, w, h)
                local sel = ST.bank_sel and ST.bank_sel.steamid == p.steamid
                UI.GradV(0, 0, w, h, sel and Color(120, 16, 16) or (s:IsHovered() and COL.panel2 or COL.panel), COL.bg)
                UI.Outline(0, 0, w, h, sel and COL.red_light or COL.border)
                UI.Text(Truncate(p.name or "?", "HordePS_ItemName", w - S(160)), "HordePS_ItemName", S(12), S(6), COL.white)
                UI.Text(p.steamid or "", "HordePS_Small", S(12), S(26), COL.muted)
                if p.loaded then
                    UI.Price(p.skulls or 0, "HordePS_BodyBold", w - S(12), h / 2, COL.white, TEXT_ALIGN_RIGHT)
                else
                    UI.Text(L("bank_loading"), "HordePS_Small", w - S(12), h / 2, COL.dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
            row.DoClick = function()
                PS:Sound("ui/buttonclick.wav")
                ST.bank_sel = { steamid = p.steamid, name = p.name, skulls = p.skulls, found = true, online = true }
                root:RebuildEditor()
            end
        end
    end

    function root:RebuildEditor()
        Clear(right)
        local sel = ST.bank_sel
        local rw = right:GetWide()
        right.Paint = function(s, w, h)
            UI.GradV(0, 0, w, h, COL.panel, COL.bg2)
            UI.Outline(0, 0, w, h, COL.border)
            UI.Heading(L("bank_title"), S(16), S(14), w - S(32))
            if not sel then
                UI.Text(L("bank_select"), "HordePS_Body", S(16), S(64), COL.muted)
                return
            end
            UI.Text(sel.name or sel.steamid or "?", "HordePS_Big", S(16), S(52), COL.white)
            UI.Text((sel.steamid or "") .. (sel.online and "" or (" · " .. L("bank_offline"))), "HordePS_Small", S(16), S(96), COL.muted)
            UI.Text(PS:Upper(L("bank_balance")), "HordePS_Small", w - S(16), S(56), COL.muted, TEXT_ALIGN_RIGHT)
            UI.Price(sel.skulls or 0, "HordePS_Big", w - S(16), S(90), COL.white, TEXT_ALIGN_RIGHT)
            if not sel.found then
                UI.Text(L("bank_notfound"), "HordePS_Small", S(16), S(118), COL.red_light)
            end
            UI.Text(PS:Upper(L("bank_amount")), "HordePS_Small", S(16), S(150), COL.muted)
        end
        if not sel then return end

        local amount = UI.Entry(right, "100")
        amount:SetNumeric(true)
        amount:SetPos(S(16), S(170))
        amount:SetSize(rw - S(32), S(36))
        amount:SetValue(ST.bank_amount or "100")
        amount.OnChange = function(s) ST.bank_amount = s:GetValue() end

        local bw = math.floor((rw - S(32) - S(20)) / 3)
        local function Act(label, mode, style, x)
            local b = UI.Button(right, label, style, function()
                PS:RequestAdmin("bank", { steamid = sel.steamid, mode = mode, amount = tonumber(amount:GetValue()) or 0 })
            end)
            b:SetPos(x, S(222))
            b:SetSize(bw, S(40))
        end
        Act(L("give"), "add", "red", S(16))
        Act(L("take"), "remove", "dark", S(16) + bw + S(10))
        Act(L("set"), "set", "ghost", S(16) + (bw + S(10)) * 2)
    end

    root:RebuildList()
    root:RebuildEditor()
    PS:RequestAdmin("bank_list", {})

    root.Refresh = function(_, what)
        if what == "admin_bank" then
            if ST.bank_sel and ST.bank_sel.online then
                for _, p in ipairs(PS.AdminData.bank or {}) do
                    if p.steamid == ST.bank_sel.steamid then ST.bank_sel.skulls = p.skulls end
                end
            end
            root:RebuildList()
            root:RebuildEditor()
        elseif what == "admin_bank_lookup" then
            local d = PS.AdminData.bank_lookup or {}
            if not d.steamid then return end
            ST.bank_sel = { steamid = d.steamid, name = d.name, skulls = d.skulls or C.StartingSkulls, found = d.found, online = d.name ~= nil }
            root:RebuildEditor()
        end
    end
end

---------------------------------------------------------------------------
-- ADMIN: CONTRACTS
---------------------------------------------------------------------------

local EVENT_KEYS = { kill = "c_event_kill", win = "c_event_win", wave = "c_event_wave" }

local function BuildAdminContracts(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local lw = S(380)
    local data = PS.AdminData.contracts or {}

    local left = vgui.Create("DPanel", root)
    left:SetPos(pad, pad)
    left:SetSize(lw, H - pad * 2)
    left.Paint = function(_, w)
        UI.Heading(L("c_templates"), 0, 0, w, tostring(#(data.templates or {})))
    end

    local add = UI.Button(left, L("new"), "red", function()
        ST.contract_selected = "__new"
        root:RebuildList()
        root:RebuildEditor()
    end)
    add:SetPos(lw - S(110), 0)
    add:SetSize(S(110), S(28))

    local settingsH = S(196)
    local list = UI.Scroll(left)
    list:SetPos(0, S(40))
    list:SetSize(lw, left:GetTall() - S(40) - settingsH - S(10))

    local settings = Card(left)
    settings:SetPos(0, left:GetTall() - settingsH)
    settings:SetSize(lw, settingsH)

    local right = UI.Scroll(root)
    right:SetPos(pad * 2 + lw, pad)
    right:SetSize(W - lw - pad * 3, H - pad * 2)

    function root:RebuildSettings()
        Clear(settings)
        settings.Paint = function(s, w, h)
            UI.GradV(0, 0, w, h, COL.panel, COL.bg2)
            UI.Outline(0, 0, w, h, COL.border)
            UI.Text(PS:Upper(L("c_settings")), "HordePS_BodyBold", S(12), S(10), COL.white)
            UI.Text(L("per_day"), "HordePS_Small", S(12), S(38), COL.muted)
            UI.Text(L("def_reward"), "HordePS_Small", w / 2 + S(4), S(38), COL.muted)
        end
        local half = math.floor((lw - S(32)) / 2)
        local per_day = UI.Entry(settings, "3")
        per_day:SetNumeric(true)
        per_day:SetPos(S(12), S(56))
        per_day:SetSize(half, S(30))
        per_day:SetValue(tostring(data.per_day or C.ContractsPerDay))
        local reward = UI.Entry(settings, "100")
        reward:SetNumeric(true)
        reward:SetPos(lw / 2 + S(4), S(56))
        reward:SetSize(half, S(30))
        reward:SetValue(tostring(data.reward or C.ContractReward))

        local save = UI.Button(settings, L("save_settings"), "dark", function()
            PS:RequestAdmin("contract_settings", { per_day = tonumber(per_day:GetValue()), reward = tonumber(reward:GetValue()) })
        end)
        save:SetPos(S(12), S(98))
        save:SetSize(lw - S(24), S(36))

        local regen = UI.Button(settings, L("regen"), "ghost", function()
            UI.Confirm(L("regen"), L("regen_body"), L("confirm"), function()
                PS:RequestAdmin("contracts_regen", {})
            end)
        end)
        regen:SetPos(S(12), S(144))
        regen:SetSize(lw - S(24), S(36))
    end

    local function Selected()
        for _, t in ipairs(data.templates or {}) do
            if t.id == ST.contract_selected then return t end
        end
    end

    function root:RebuildList()
        list:Clear()
        for _, t in ipairs(data.templates or {}) do
            local row = vgui.Create("DButton", list)
            row:SetText("")
            row:Dock(TOP)
            row:SetTall(S(52))
            row:DockMargin(0, 0, S(10), S(4))
            row.Paint = function(s, w, h)
                local sel = ST.contract_selected == t.id
                local off = t.enabled == false
                UI.GradV(0, 0, w, h, sel and Color(120, 16, 16) or (s:IsHovered() and COL.panel2 or COL.panel), COL.bg)
                UI.Outline(0, 0, w, h, sel and COL.red_light or COL.border)
                local name = (PS:LangId() == "ru" and t.name_ru and t.name_ru ~= "") and t.name_ru or t.name or t.id
                UI.Text(Truncate(name, "HordePS_ItemName", w - S(110)), "HordePS_ItemName", S(12), S(8), off and COL.dim or COL.white)
                local tags = { L(EVENT_KEYS[t.event] or "c_event_kill") }
                if off then tags[#tags + 1] = L("tag_disabled") end
                if t.custom then tags[#tags + 1] = L("tag_custom") end
                if t.overridden then tags[#tags + 1] = L("tag_edited") end
                UI.Text(table.concat(tags, " · "), "HordePS_Small", S(12), S(30), COL.muted)
                UI.Price(tonumber(t.reward) or data.reward or C.ContractReward, "HordePS_BodyBold", w - S(10), h / 2, off and COL.dim or COL.white, TEXT_ALIGN_RIGHT)
            end
            row.DoClick = function()
                PS:Sound("ui/buttonclick.wav")
                ST.contract_selected = t.id
                root:RebuildList()
                root:RebuildEditor()
            end
        end
    end

    function root:RebuildEditor()
        right:Clear()
        local is_new = ST.contract_selected == "__new"
        local t = Selected()
        local rw = right:GetWide() - S(16)

        local holder = vgui.Create("DPanel", right)
        holder:Dock(TOP)
        holder.Paint = nil

        if not is_new and not t then
            holder:SetTall(S(120))
            holder.Paint = function(_, w)
                UI.Heading(L("c_templates"), 0, 0, w)
                UI.Text(L("c_help"), "HordePS_Body", 0, S(50), COL.text)
            end
            return
        end
        t = t or { event = "kill", min = 10, max = 20, step = 5, enabled = true }

        local half = math.floor((rw - S(12)) / 2)
        local y = S(44)
        local function Field(label, x, w)
            local l = Label(holder, PS:Upper(label), "HordePS_Small", COL.muted)
            l:SetPos(x or 0, y)
            return y + S(18)
        end
        local function NextRow(h) y = y + S(18) + (h or S(32)) + S(12) end

        holder.Paint = function(_, w)
            UI.Heading(is_new and L("c_new_title") or L("c_edit"), 0, 0, w,
                is_new and L("added_custom") or ((t.custom and L("src_custom", t.id)) or L("src_config", t.id)))
        end

        local top = Field(L("f_name_en"), 0)
        Field(L("f_name_ru"), half + S(12))
        local name_en = UI.Entry(holder, "Hulk Smasher")
        name_en:SetPos(0, top) name_en:SetSize(half, S(32)) name_en:SetValue(t.name or "")
        local name_ru = UI.Entry(holder, "Крушитель Халков")
        name_ru:SetPos(half + S(12), top) name_ru:SetSize(half, S(32)) name_ru:SetValue(t.name_ru or "")
        NextRow()

        top = Field(L("f_desc_en"))
        local desc_en = UI.Entry(holder, "Destroy %d Hulks.")
        desc_en:SetPos(0, top) desc_en:SetSize(rw, S(32)) desc_en:SetValue(t.desc or "")
        NextRow()

        top = Field(L("f_desc_ru"))
        local desc_ru = UI.Entry(holder, "Уничтожьте Халков: %d.")
        desc_ru:SetPos(0, top) desc_ru:SetSize(rw, S(32)) desc_ru:SetValue(t.desc_ru or "")
        NextRow()

        top = Field(L("f_event"), 0)
        Field(L("f_reward", PS:FormatNumber(data.reward or C.ContractReward)), half + S(12))
        local event = UI.Combo(holder)
        event:SetPos(0, top) event:SetSize(half, S(32))
        for _, e in ipairs({ "kill", "win", "wave" }) do event:AddChoice(L(EVENT_KEYS[e]), e, e == t.event) end
        local reward = UI.Entry(holder, "")
        reward:SetNumeric(true)
        reward:SetPos(half + S(12), top) reward:SetSize(half, S(32))
        reward:SetValue(t.reward and tostring(t.reward) or "")
        NextRow()

        top = Field(L("f_goal"))
        local third = math.floor((rw - S(24)) / 3)
        local function NumEntry(x, v)
            local e = UI.Entry(holder, "1")
            e:SetNumeric(true)
            e:SetPos(x, top) e:SetSize(third, S(32)) e:SetValue(tostring(v or 1))
            return e
        end
        local gmin = NumEntry(0, t.min)
        local gmax = NumEntry(third + S(12), t.max)
        local gstep = NumEntry((third + S(12)) * 2, t.step)
        NextRow()

        top = Field(L("f_enemies"))
        local enemies = UI.Entry(holder, "Hulk, Mutated Hulk")
        enemies:SetPos(0, top) enemies:SetSize(rw - S(210), S(32))
        enemies:SetValue(table.concat(t.enemy or {}, ", "))
        local add_enemy = UI.Combo(holder)
        add_enemy:SetPos(rw - S(200), top) add_enemy:SetSize(S(200), S(32))
        add_enemy:SetValue(L("add_enemy"))
        for _, n in ipairs(data.enemies or {}) do add_enemy:AddChoice(n, n) end
        add_enemy.OnSelect = function(s, _, _, value)
            local cur = string.Trim(enemies:GetValue())
            enemies:SetValue(cur == "" and value or (cur .. ", " .. value))
            s:SetValue(L("add_enemy"))
        end
        NextRow()

        top = Field(L("f_filters"))
        local fw3 = math.floor(rw / 3)
        local elite = UI.Check(holder, L("only_elite"), t.elite == true)
        elite:SetPos(0, top) elite:SetSize(fw3, S(28))
        local boss = UI.Check(holder, L("only_boss"), t.boss == true)
        boss:SetPos(fw3, top) boss:SetSize(fw3, S(28))
        local per_class = UI.Check(holder, L("per_class"), t.per_class == true)
        per_class:SetPos(fw3 * 2, top) per_class:SetSize(fw3, S(28))
        NextRow(S(28))

        local enabled = UI.Check(holder, L("c_enabled"), t.enabled ~= false)
        enabled:SetPos(0, y) enabled:SetSize(rw, S(28))
        y = y + S(40)

        -- Live example of the description
        local example = vgui.Create("DPanel", holder)
        example:SetPos(0, y)
        example:SetSize(rw, S(28))
        example.Paint = function(_, w, h)
            local fmt = (PS:LangId() == "ru" and string.Trim(desc_ru:GetValue()) ~= "") and desc_ru:GetValue() or desc_en:GetValue()
            local ok, txt = pcall(string.format, fmt, tonumber(gmin:GetValue()) or 1, PS:ClassDisplayName(PS:LocalClassName() or "Assault"))
            UI.Text(L("c_example", ok and txt or fmt), "HordePS_Body", 0, h / 2, COL.red_light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        y = y + S(44)

        local function Gather()
            local list = {}
            for part in string.gmatch(enemies:GetValue(), "[^,]+") do
                local n = string.Trim(part)
                if n ~= "" then list[#list + 1] = n end
            end
            local _, ev = event:GetSelected()
            return {
                id = (not is_new) and t.id or nil,
                name = name_en:GetValue(), name_ru = name_ru:GetValue(),
                desc = desc_en:GetValue(), desc_ru = desc_ru:GetValue(),
                event = ev or t.event,
                min = tonumber(gmin:GetValue()), max = tonumber(gmax:GetValue()), step = tonumber(gstep:GetValue()),
                reward = reward:GetValue() ~= "" and tonumber(reward:GetValue()) or nil,
                enemy = list,
                elite = elite:GetValue(), boss = boss:GetValue(), per_class = per_class:GetValue(),
                enabled = enabled:GetValue(),
            }
        end

        local save = UI.Button(holder, L("save"), "red", function()
            PS:RequestAdmin("contract_save", Gather())
            if is_new then ST.contract_selected = nil end
        end)
        save:SetPos(0, y) save:SetSize(S(200), S(40))

        if not is_new and t.config then
            local reset = UI.Button(holder, L("reset_cfg"), "ghost", function()
                PS:RequestAdmin("contract_reset", { id = t.id })
            end)
            reset:SetPos(S(210), y) reset:SetSize(S(190), S(40))
            reset:SetEnabled(t.overridden == true)
        elseif not is_new and t.custom then
            local del = UI.Button(holder, L("delete"), "ghost", function()
                UI.Confirm(L("delete_title"), L("delete_body", t.name or t.id), L("delete"), function()
                    PS:RequestAdmin("contract_delete", { id = t.id })
                    ST.contract_selected = nil
                end)
            end)
            del:SetPos(S(210), y) del:SetSize(S(190), S(40))
        end
        holder:SetTall(y + S(52))
    end

    root:RebuildSettings()
    root:RebuildList()
    root:RebuildEditor()
    PS:RequestAdmin("contracts_get", {})

    root.Refresh = function(_, what)
        if what == "admin_contracts" then
            data = PS.AdminData.contracts or {}
            root:RebuildSettings()
            root:RebuildList()
            root:RebuildEditor()
        end
    end
end

---------------------------------------------------------------------------
-- ADMIN: ECONOMY (playtime reward, backpack size, selling, casino)
---------------------------------------------------------------------------

local function BuildAdminEconomy(root)
    local W = root:GetWide()
    local pad = S(16)
    local cw = math.floor((W - pad * 4) / 3)
    local ch = S(330)
    local fw = cw - S(32)
    local values = {}

    local function Section(x, title, lines)
        local card = Card(root)
        card:SetPos(x, pad)
        card:SetSize(cw, ch)
        local base = card.Paint
        card.Paint = function(s, w, h)
            base(s, w, h)
            UI.Heading(title, S(16), S(14), w - S(32))
            for _, line in ipairs(lines) do
                UI.Text(isfunction(line[1]) and line[1]() or line[1], line[3] or "HordePS_Small", S(16), line[2], line[4] or COL.muted)
            end
        end
        return card
    end

    local function Number(card, key, y)
        local e = UI.Entry(card, tostring(C[key] or 0))
        e:SetNumeric(true)
        e:SetPos(S(16), y)
        e:SetSize(fw, S(30))
        e:SetValue(tostring(C[key] or 0))
        values[key] = function() return tonumber(e:GetValue()) end
        return e
    end

    local function Toggle(card, key, label, y)
        local value = C[key] and true or false
        local c = UI.Check(card, label, value, function(v) value = v end)
        c:SetPos(S(16), y)
        c:SetSize(fw, S(30))
        values[key] = function() return value end
    end

    -- Playtime
    local amount, interval
    local pt = Section(pad, L("eco_playtime"), {
        { PS:Upper(L("eco_pt_amount")), S(100) },
        { PS:Upper(L("eco_pt_interval")), S(160) },
        { PS:Upper(L("eco_pt_afk")), S(220) },
        { function()
            local a, m = tonumber(amount:GetValue()) or 0, math.max(1, tonumber(interval:GetValue()) or 1)
            return L("eco_pt_preview", PS:FormatNumber(math.floor(a * 60 / m)))
        end, S(286), "HordePS_Body", COL.text },
    })
    Toggle(pt, "PlaytimeEnabled", L("eco_pt_enabled"), S(56))
    amount = Number(pt, "PlaytimeAmount", S(118))
    interval = Number(pt, "PlaytimeInterval", S(178))
    Number(pt, "PlaytimeAFKTime", S(238))

    -- Backpack & selling
    local sell
    local bp = Section(pad * 2 + cw, L("eco_backpack"), {
        { PS:Upper(L("eco_slots", PS.MAX_SLOTS)), S(58) },
        { PS:Upper(L("eco_sell")), S(118) },
        { function()
            local pct = math.Clamp(tonumber(sell:GetValue()) or 0, 0, 100)
            return L("eco_sell_example", PS:FormatNumber(math.floor(1000 * pct / 100)))
        end, S(184), "HordePS_Body", COL.text },
        { L("eco_slots_note"), S(220), "HordePS_Small", COL.dim },
    })
    Number(bp, "InventorySlots", S(76))
    sell = Number(bp, "SellPercent", S(136))

    -- Casino
    local _, rtp, hit = PS:CasinoPaytable()
    local cs = Section(pad * 3 + cw * 2, L("eco_casino"), {
        { PS:Upper(L("eco_min_bet")), S(100) },
        { PS:Upper(L("eco_max_bet")), S(160) },
        { L("casino_rtp", string.format("%.1f", rtp * 100)), S(224), "HordePS_Small", COL.text },
        { L("casino_hit", string.format("%.1f", hit * 100)), S(242), "HordePS_Small", COL.text },
        { L("eco_casino_info"), S(272), "HordePS_Small", COL.dim },
        { "sh_config.lua · C.CasinoSymbols", S(290), "HordePS_Small", COL.dim },
    })
    Toggle(cs, "CasinoEnabled", L("eco_casino_enabled"), S(56))
    Number(cs, "CasinoMinBet", S(118))
    Number(cs, "CasinoMaxBet", S(178))

    local save = UI.Button(root, L("eco_save"), "red", function()
        local data = {}
        for key, get in pairs(values) do data[key] = get() end
        PS:RequestAdmin("economy_save", data)
    end)
    save:SetPos(pad, pad * 2 + ch)
    save:SetSize(S(320), S(40))

    root.Refresh = function() end
end

---------------------------------------------------------------------------
-- ADMIN (sub-tabs)
---------------------------------------------------------------------------

local ADMIN_SUBS = {
    { id = "items",     label = "admin_items",     build = BuildAdminItems },
    { id = "bank",      label = "admin_bank",      build = BuildAdminBank },
    { id = "contracts", label = "admin_contracts", build = BuildAdminContracts },
    { id = "economy",   label = "admin_economy",   build = BuildAdminEconomy },
}

local function BuildAdmin(root)
    local W, H = root:GetSize()
    local barH = S(38)

    local bar = vgui.Create("DPanel", root)
    bar:SetPos(0, 0)
    bar:SetSize(W, barH)
    bar.Paint = function(_, w, h)
        UI.Box(0, 0, w, h, Color(22, 22, 22))
        UI.Box(0, h - 1, w, 1, COL.border)
    end

    local page = vgui.Create("DPanel", root)
    page:SetPos(0, barH)
    page:SetSize(W, H - barH)
    page.Paint = nil

    local current
    local function Open(id)
        ST.admin_sub = id
        Clear(page)
        local sub
        for _, s in ipairs(ADMIN_SUBS) do if s.id == id then sub = s end end
        sub = sub or ADMIN_SUBS[1]
        current = vgui.Create("DPanel", page)
        current:SetSize(page:GetSize())
        current.Paint = nil
        sub.build(current)
    end

    local x = S(16)
    for _, sub in ipairs(ADMIN_SUBS) do
        surface.SetFont("HordePS_Button")
        local tw = surface.GetTextSize(PS:Upper(L(sub.label)))
        local b = vgui.Create("DButton", bar)
        b:SetText("")
        b:SetPos(x, S(5))
        b:SetSize(tw + S(32), barH - S(10))
        x = x + tw + S(40)
        b.Paint = function(s, w, h)
            local active = ST.admin_sub == sub.id
            if active then
                UI.GradV(0, 0, w, h, COL.red, COL.red_dark)
            elseif s:IsHovered() then
                UI.Box(0, 0, w, h, Color(255, 255, 255, 12))
            end
            UI.Outline(0, 0, w, h, active and COL.red_light or COL.border)
            UI.Text(PS:Upper(L(sub.label)), "HordePS_Button", w / 2, h / 2, active and COL.white or COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function()
            if ST.admin_sub == sub.id then return end
            PS:Sound("ui/buttonclick.wav")
            Open(sub.id)
        end
    end

    Open(ST.admin_sub)
    root.Refresh = function(_, what)
        if IsValid(current) and current.Refresh then current:Refresh(what) end
    end
end

---------------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------------

local TABS = {
    { id = "loadout",   label = "tab.loadout",   build = BuildLoadout },
    { id = "inventory", label = "tab.inventory", build = BuildInventory },
    { id = "store",     label = "tab.store",     build = BuildStore },
    { id = "contracts", label = "tab.contracts", build = BuildContracts },
    { id = "casino",    label = "tab.casino",    build = function(root) PS.BuildCasino(root) end, casino = true },
    { id = "settings",  label = "tab.settings",  build = BuildSettings },
    { id = "admin",     label = "tab.admin",     build = BuildAdmin, admin = true },
}

local function TabVisible(tab)
    if tab.casino and not C.CasinoEnabled then return false end
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
        -- Plain grey window background.
        UI.GradV(0, 0, pw, ph, Color(36, 36, 36), Color(20, 20, 20))

        -- Header
        UI.GradV(0, 0, pw, headH, Color(44, 44, 44), Color(28, 28, 28))
        UI.Box(0, headH - S(2), pw, S(2), COL.red)
        surface.SetFont("HordePS_Logo")
        local lw = surface.GetTextSize(L("title_a"))
        UI.TextShadow(L("title_a"), "HordePS_Logo", S(20), headH / 2, COL.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        UI.TextShadow(L("title_b"), "HordePS_Logo", S(20) + lw, headH / 2, COL.red_light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Balance
        local bx = pw - S(70)
        UI.Text(PS:Upper(PS:Currency()), "HordePS_Small", bx, headH / 2 + S(12), COL.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        UI.Price(PS:ShownSkulls(), "HordePS_Price", bx, headH / 2 - S(8), COL.white, TEXT_ALIGN_RIGHT)

        -- Tab bar background
        UI.GradV(0, headH, pw, tabH, Color(30, 30, 30), Color(24, 24, 24))
        UI.Box(0, headH + tabH - 1, pw, 1, COL.border)

        local cls = PS:LocalClassName()
        UI.Text(L("playing_as", cls and PS:ClassDisplayName(cls) or "—"), "HordePS_Small", pw - S(20), headH + tabH / 2, COL.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        if not PS.Player.loaded then
            UI.Text(L("loading"), "HordePS_Header", pw / 2, ph / 2, COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    f.PaintOver = function(_, pw, ph)
        UI.Outline(0, 0, pw, ph, COL.border)
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
        PS:Sound("ui/buttonclick.wav")
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
                local label = PS:Upper(L(tab.label))
                local tw = surface.GetTextSize(label)
                local b = vgui.Create("DButton", tabbar)
                b:SetText("")
                b:SetPos(x, 0)
                b:SetSize(tw + S(36), tabH)
                x = x + tw + S(40)
                b.Paint = function(s, bw, bh)
                    local active = ST.tab == tab.id
                    if active then
                        UI.GradV(0, 0, bw, bh, Color(0, 0, 0, 0), Color(150, 18, 18, 200))
                        UI.Box(0, bh - S(3), bw, S(3), COL.red)
                    elseif s:IsHovered() then
                        UI.GradV(0, 0, bw, bh, Color(0, 0, 0, 0), Color(255, 255, 255, 14))
                    end
                    local col = active and COL.white or (s:IsHovered() and COL.text or COL.muted)
                    UI.TextShadow(label, "HordePS_Tab", bw / 2, bh / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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
                    PS:Sound("ui/buttonclick.wav")
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

    -- Rebuild everything (used after a language change).
    function f:Rebuild()
        self:BuildTabs()
        self:SetTab(ST.tab)
    end

    function f:OnDataUpdated(what)
        if what == "player" and self.AdminState ~= PS.Player.admin then
            self.AdminState = PS.Player.admin
            self:BuildTabs()
            if ST.tab == "admin" and not PS.Player.admin then self:SetTab("loadout") end
        end
        -- Economy settings change slot counts, casino limits and which tabs exist.
        if what == "config" then
            self:BuildTabs()
            self:SetTab(ST.tab, true)
            return
        end
        if IsValid(self.Page) and self.Page.Refresh then self.Page:Refresh(what) end
    end

    f.OnKeyCodePressed = function(s, key)
        if PS.Binding then return end
        if key == KEY_ESCAPE then s:Remove() end
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
        PS.Binding = false
    end

    f.AdminState = PS.Player.admin
    f:BuildTabs()
    f:SetTab(ST.tab)
end

hook.Add("Horde_PS_Updated", "Horde_PS_Menu", function(what)
    if IsValid(PS.Menu) then PS.Menu:OnDataUpdated(what) end
end)
