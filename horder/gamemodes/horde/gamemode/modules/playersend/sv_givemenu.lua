if not SERVER then return end

-- Give menu: press +use (E) on a nearby player to open a menu with Money,
-- Skulls and Weapons tabs. Everything is re-checked here on the server; the
-- client only shows what the server sent it.

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

-- Returns true, or false and a short reason the client shows next to the weapon.
local function CanGiveWeapon(giver, target, wpn)
    if not IsValid(wpn) or wpn:GetOwner() ~= giver then return false, "You no longer have it" end
    local class = wpn:GetClass()
    local item = HORDE.items and HORDE.items[class]
    if not item then return false, "Not a shop weapon" end
    if cannot_give_base[wpn.Base] or cannot_give_class[class] then return false, "Can't be given" end
    if item.starter_classes or (HORDE.relic_weapon_subclass and HORDE.relic_weapon_subclass[class]) then
        return false, "Class weapon"
    end
    if target:HasWeapon(class) then return false, "They already have it" end

    local weight = tonumber(item.weight) or 0
    local free = target:Horde_GetWeight() or 0
    if free < weight then
        return false, string.format("Too heavy (needs %d, they have %d free)", weight, free)
    end

    local subclass = target:Horde_GetCurrentSubclass()
    local gunslinger_pistol = subclass == "Gunslinger" and item.category == "Pistol"
    if not gunslinger_pistol and item.whitelist and not item.whitelist[subclass] then
        return false, "Their class can't use it"
    end
    if subclass == "Carcass" then return false, "Their class can't use it" end
    if target:Horde_GetSpellWeapon() then return false, "Their class can't use it" end

    -- Last word goes to the normal pickup rules (Unarmed mode, other addons, ...)
    if hook.Run("PlayerCanPickupWeapon", target, wpn) == false then
        return false, "They can't take it"
    end
    return true
end

local function SendMenu(ply, target)
    local entries = {}
    for _, wpn in ipairs(ply:GetWeapons()) do
        local item = HORDE.items and HORDE.items[wpn:GetClass()]
        -- Only list things that are actually shop weapons; fists, tools and
        -- spell weapons would just clutter the list.
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

hook.Add("KeyPress", "Horde_GiveMenu_Use", function(ply, key)
    if key ~= IN_USE or not IsActivePlayer(ply) then return end
    local target = FindUseTarget(ply)
    if not IsActivePlayer(target) then return end
    if not HORDE:AllowNetRequest(ply, "give_menu_open", 0.5) then return end
    SendMenu(ply, target)
end)

local function TransferCurrency(ply, target, kind, amount)
    if kind == GIVE_MONEY then
        if HORDE.budget_mode then
            HORDE:SendNotification("Money is shared in Budget mode. Transfers are disabled.", 1, ply)
            return
        end
        if (ply:Horde_GetMoney() or 0) < amount then
            HORDE:SendNotification("Not enough money!", 1, ply)
            return
        end
        ply:Horde_AddMoney(-amount)
        target:Horde_AddMoney(amount)
        HORDE:SendNotification(string.format("Gave $%d to %s", amount, target:Nick()), 0, ply)
        HORDE:SendNotification(string.format("%s gave you $%d", ply:Nick(), amount), 0, target)
    else
        if (ply:Horde_GetSkullTokens() or 0) < amount then
            HORDE:SendNotification("Not enough skull tokens!", 1, ply)
            return
        end
        ply:Horde_AddSkullTokens(-amount)
        target:Horde_AddSkullTokens(amount)
        HORDE:SendNotification(string.format("Gave %d skulls to %s", amount, target:Nick()), 0, ply)
        HORDE:SendNotification(string.format("%s gave you %d skulls", ply:Nick(), amount), 0, target)
    end
    ply:Horde_SyncEconomy()
    target:Horde_SyncEconomy()
end

local function TransferWeapon(ply, target, class)
    local wpn = ply:GetWeapon(class)
    local ok, reason = CanGiveWeapon(ply, target, wpn)
    if not ok then
        HORDE:SendNotification("Can't give that: " .. (reason or "not allowed"), 1, ply)
        return
    end
    local name = ItemName(HORDE.items[class], wpn)

    -- Drop it (refunds the giver's weight through PlayerDroppedWeapon), move it
    -- onto the receiver and have them pick it up (charges their weight through
    -- WeaponEquip). The weapon entity is kept, so clip and attachments carry over.
    ply:DropWeapon(wpn)
    if not IsValid(wpn) then return end
    wpn:SetPos(target:WorldSpaceCenter())
    if target:PickupWeapon(wpn) and wpn:GetOwner() == target then
        HORDE:SendNotification(string.format("Gave %s to %s", name, target:Nick()), 0, ply)
        HORDE:SendNotification(string.format("%s gave you %s", ply:Nick(), name), 0, target)
        return
    end

    -- Pickup failed for some engine reason: hand it back to the giver.
    wpn:SetPos(ply:WorldSpaceCenter())
    if not ply:PickupWeapon(wpn) then
        HORDE:SendNotification(string.format("Couldn't give %s; it was dropped on the ground.", name), 1, ply)
    else
        HORDE:SendNotification(string.format("Couldn't give %s to %s.", name, target:Nick()), 1, ply)
    end
end

net.Receive("Horde_GiveMenu_Give", function(_, ply)
    if not HORDE:AllowNetRequest(ply, "give_menu_give", 0.3) then return end
    local target = net.ReadEntity()
    local kind = net.ReadUInt(2)
    if not IsActivePlayer(ply) or not IsActivePlayer(target) or target == ply then return end
    if not InRange(ply, target, GIVE_RANGE_KEEP) then
        HORDE:SendNotification("You are too far away from " .. target:Nick() .. ".", 1, ply)
        return
    end

    if kind == GIVE_MONEY or kind == GIVE_SKULLS then
        local amount = net.ReadUInt(32)
        if not amount or amount <= 0 or amount > MAX_AMOUNT then
            HORDE:SendNotification("Invalid amount!", 1, ply)
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

    -- Refresh the giver's menu with the new balances and weight.
    if IsActivePlayer(target) then SendMenu(ply, target) end
end)
