if not SERVER then return end

-- Give menu: hold Walk (Alt) and press Use (E) on a nearby player to open a
-- menu with Money, Skulls and Weapons tabs. Everything is re-checked here on
-- the server; the client only shows what the server sent it.

util.AddNetworkString("Horde_GiveMenu_Open")
util.AddNetworkString("Horde_GiveMenu_Give")

local GIVE_RANGE        = 110   -- how close you must be to open the menu
local GIVE_RANGE_KEEP   = 200   -- how far they may drift while the menu is open
local MAX_AMOUNT        = 1000000000

local GIVE_MONEY  = 0
local GIVE_SKULLS = 1
local GIVE_WEAPON = 2

local cannot_give_base = {
    horde_spell_weapon_base = true,
    arccw_horde_base_nade   = true,
}
local cannot_give_class = {
    horde_pheropod      = true,
    horde_carcass       = true,
    weapon_horde_medkit = true,
    horde_slam          = true,
}

-- Text in the player's own language (falls back to English, then to the key).
local function T(ply, key, ...)
    local ok, text = pcall(translate.ClientFormat, ply, key, ...)
    if ok and isstring(text) then return text end
    return key
end

local function ItemName(item, wpn)
    if item and item.name and item.name ~= "" then return item.name end
    if IsValid(wpn) and wpn.PrintName and wpn.PrintName ~= "" then return wpn.PrintName end
    return IsValid(wpn) and wpn:GetClass() or "?"
end

local function IsActivePlayer(p)
    return IsValid(p) and p:IsPlayer() and p:Alive() and p.Horde_Init_Complete
        and p:Team() ~= TEAM_SPECTATOR
end

local function InRange(a, b, range)
    return a:GetPos():DistToSqr(b:GetPos()) <= range * range
end

-- Returns true, or false and a short reason (in the giver's language) that the
-- client shows next to the weapon.
local function CanGiveWeapon(giver, target, wpn)
    if not IsValid(wpn) or wpn:GetOwner() ~= giver then return false, T(giver, "GiveMenu_Reason_NotOwned") end
    local class = wpn:GetClass()
    local item = HORDE.items and HORDE.items[class]
    if not item then return false, T(giver, "GiveMenu_Reason_NotShop") end
    if cannot_give_base[wpn.Base] or cannot_give_class[class] then return false, T(giver, "GiveMenu_Reason_CantGive") end
    -- Relics are tied to one subclass and come back to their owner when dropped.
    if HORDE.relic_weapon_subclass and HORDE.relic_weapon_subclass[class] then
        return false, T(giver, "GiveMenu_Reason_Relic")
    end
    if target:HasWeapon(class) then return false, T(giver, "GiveMenu_Reason_HasIt") end

    local weight = tonumber(item.weight) or 0
    local free = target:Horde_GetWeight() or 0
    if free < weight then
        return false, T(giver, "GiveMenu_Reason_TooHeavy", math.floor(weight), math.floor(free))
    end

    local subclass = target:Horde_GetCurrentSubclass()
    local gunslinger_pistol = subclass == "Gunslinger" and item.category == "Pistol"
    if not gunslinger_pistol and item.whitelist and not item.whitelist[subclass] then
        return false, T(giver, "GiveMenu_Reason_Class")
    end
    if subclass == "Carcass" then return false, T(giver, "GiveMenu_Reason_Class") end
    if target:Horde_GetSpellWeapon() then return false, T(giver, "GiveMenu_Reason_Class") end

    -- Last word goes to the normal pickup rules (Unarmed mode, other addons, ...)
    if hook.Run("PlayerCanPickupWeapon", target, wpn) == false then
        return false, T(giver, "GiveMenu_Reason_CantTake")
    end
    return true
end

local function SendMenu(ply, target)
    local entries = {}
    for _, wpn in ipairs(ply:GetWeapons()) do
        local item = HORDE.items and HORDE.items[wpn:GetClass()]
        -- Only list shop weapons; fists, tools and spell weapons would just
        -- clutter the list.
        if item and not cannot_give_base[wpn.Base] then
            local ok, reason = CanGiveWeapon(ply, target, wpn)
            entries[#entries + 1] = {
                class  = wpn:GetClass(),
                name   = ItemName(item, wpn),
                weight = tonumber(item.weight) or 0,
                ok     = ok,
                reason = reason or "",
            }
        end
    end

    net.Start("Horde_GiveMenu_Open")
        net.WriteEntity(target)
        net.WriteBool(HORDE.budget_mode and true or false)
        net.WriteUInt(math.Clamp(math.floor(ply:Horde_GetMoney() or 0), 0, 4294967295), 32)
        net.WriteUInt(math.Clamp(math.floor(ply:Horde_GetSkullTokens() or 0), 0, 4294967295), 32)
        net.WriteString(target:Horde_GetCurrentSubclass() or "")
        net.WriteUInt(math.Clamp(math.floor(target:Horde_GetWeight() or 0), 0, 65535), 16)
        net.WriteUInt(math.Clamp(math.floor(target:Horde_GetMaxWeight() or 0), 0, 65535), 16)
        net.WriteUInt(#entries, 8)
        for _, e in ipairs(entries) do
            net.WriteString(e.class)
            net.WriteString(e.name)
            net.WriteUInt(math.Clamp(e.weight, 0, 65535), 16)
            net.WriteBool(e.ok)
            net.WriteString(e.reason)
        end
    net.Send(ply)
end

local function FindUseTarget(ply)
    local start = ply:GetShootPos()
    local tr = util.TraceHull({
        start  = start,
        endpos = start + ply:GetAimVector() * GIVE_RANGE,
        mins   = Vector(-6, -6, -6),
        maxs   = Vector(6, 6, 6),
        filter = ply,
        mask   = MASK_SHOT,
    })
    local target = tr.Entity
    if IsValid(target) and target:IsPlayer() and target ~= ply then return target end
end

-- Alt+E: Use pressed while Walk is held (or Walk pressed while Use is held).
hook.Add("KeyPress", "Horde_GiveMenu_Use", function(ply, key)
    if key == IN_USE then
        if not ply:KeyDown(IN_WALK) then return end
    elseif key == IN_WALK then
        if not ply:KeyDown(IN_USE) then return end
    else
        return
    end
    if not IsActivePlayer(ply) then return end
    local target = FindUseTarget(ply)
    if not IsActivePlayer(target) then return end
    if not HORDE:AllowNetRequest(ply, "give_menu_open", 0.5) then return end
    SendMenu(ply, target)
end)

local function TransferCurrency(ply, target, kind, amount)
    if kind == GIVE_MONEY then
        if HORDE.budget_mode then
            HORDE:SendNotification(T(ply, "GiveMenu_Notify_Budget"), 1, ply)
            return
        end
        if (ply:Horde_GetMoney() or 0) < amount then
            HORDE:SendNotification(T(ply, "GiveMenu_Notify_NoMoney"), 1, ply)
            return
        end
        ply:Horde_AddMoney(-amount)
        target:Horde_AddMoney(amount)
        HORDE:SendNotification(T(ply, "GiveMenu_Notify_GaveMoney", amount, target:Nick()), 0, ply)
        HORDE:SendNotification(T(target, "GiveMenu_Notify_GotMoney", ply:Nick(), amount), 0, target)
    else
        if (ply:Horde_GetSkullTokens() or 0) < amount then
            HORDE:SendNotification(T(ply, "GiveMenu_Notify_NoSkulls"), 1, ply)
            return
        end
        ply:Horde_AddSkullTokens(-amount)
        target:Horde_AddSkullTokens(amount)
        HORDE:SendNotification(T(ply, "GiveMenu_Notify_GaveSkulls", amount, target:Nick()), 0, ply)
        HORDE:SendNotification(T(target, "GiveMenu_Notify_GotSkulls", ply:Nick(), amount), 0, target)
    end
    ply:Horde_SyncEconomy()
    target:Horde_SyncEconomy()
end

-- Copy what's installed in an ArcCW weapon so it can follow the gun.
local function ReadArcCWAtts(wpn)
    if not wpn.ArcCW or not istable(wpn.Attachments) then return nil end
    local atts = {}
    for i, slot in pairs(wpn.Attachments) do
        if istable(slot) and slot.Installed then atts[i] = slot.Installed end
    end
    return atts
end

local function ApplyArcCWAtts(wpn, atts)
    if not atts or not IsValid(wpn) or not istable(wpn.Attachments) then return end
    for i, name in pairs(atts) do
        if istable(wpn.Attachments[i]) then wpn.Attachments[i].Installed = name end
    end
    if wpn.AdjustAtts then pcall(wpn.AdjustAtts, wpn) end
    if wpn.NetworkWeapon then pcall(wpn.NetworkWeapon, wpn) end
end

local function TransferWeapon(ply, target, class)
    local wpn = ply:GetWeapon(class)
    local ok, reason = CanGiveWeapon(ply, target, wpn)
    if not ok then
        HORDE:SendNotification(T(ply, "GiveMenu_Notify_Refused", reason or ""), 1, ply)
        return
    end
    local item = HORDE.items[class]
    local name = ItemName(item, wpn)
    local clip1, clip2 = wpn:Clip1(), wpn:Clip2()
    local atts = ReadArcCWAtts(wpn)

    -- Take it off the giver and recount their weight from what they still carry.
    ply:StripWeapon(class)
    timer.Simple(0, function() if IsValid(ply) then ply:Horde_WeightSync() end end)

    -- Give a fresh copy to the receiver. WeaponEquip charges their weight.
    -- Engine pickups of a just-dropped gun can silently fail, so we don't use them.
    local given = target:Give(class, true)
    if not IsValid(given) then given = target:GetWeapon(class) end
    if IsValid(given) then
        if clip1 and clip1 >= 0 then given:SetClip1(clip1) end
        if clip2 and clip2 >= 0 then given:SetClip2(clip2) end
        timer.Simple(0, function() ApplyArcCWAtts(given, atts) end)
        timer.Simple(0, function() if IsValid(target) then target:Horde_WeightSync() end end)
        HORDE:SendNotification(T(ply, "GiveMenu_Notify_GaveWeapon", name, target:Nick()), 0, ply)
        HORDE:SendNotification(T(target, "GiveMenu_Notify_GotWeapon", ply:Nick(), name), 0, target)
        return
    end

    -- Give failed: hand it back to the giver.
    local back = ply:Give(class, true)
    if IsValid(back) then
        if clip1 and clip1 >= 0 then back:SetClip1(clip1) end
        if clip2 and clip2 >= 0 then back:SetClip2(clip2) end
        timer.Simple(0, function() ApplyArcCWAtts(back, atts) end)
    end
    HORDE:SendNotification(T(ply, "GiveMenu_Notify_Failed", name, target:Nick()), 1, ply)
end

net.Receive("Horde_GiveMenu_Give", function(_, ply)
    if not HORDE:AllowNetRequest(ply, "give_menu_give", 0.3) then return end
    local target = net.ReadEntity()
    local kind = net.ReadUInt(2)
    if not IsActivePlayer(ply) or not IsActivePlayer(target) or target == ply then return end
    if not InRange(ply, target, GIVE_RANGE_KEEP) then
        HORDE:SendNotification(T(ply, "GiveMenu_Notify_TooFar", target:Nick()), 1, ply)
        return
    end

    if kind == GIVE_MONEY or kind == GIVE_SKULLS then
        local amount = net.ReadUInt(32)
        if not amount or amount <= 0 or amount > MAX_AMOUNT then
            HORDE:SendNotification(T(ply, "GiveMenu_Notify_BadAmount"), 1, ply)
            return
        end
        TransferCurrency(ply, target, kind, amount)
    elseif kind == GIVE_WEAPON then
        local class = net.ReadString()
        if not class or class == "" or #class > 128 then return end
        TransferWeapon(ply, target, class)
    else
        return
    end

    -- Refresh the giver's menu once weights have been recounted.
    timer.Simple(0.1, function()
        if IsActivePlayer(ply) and IsActivePlayer(target) then SendMenu(ply, target) end
    end)
end)
