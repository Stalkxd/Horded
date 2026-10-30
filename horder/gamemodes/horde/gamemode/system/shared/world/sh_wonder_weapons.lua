-- Horde balance data for the wonder weapons addon (horde_wonder_weapons, ArcCW remakes of the
-- CoD Zombies and Black Ops 3 wonder weapons). Their projectiles come from nZombies and can kill
-- most targets in one hit, so under Horde every damage event from them is capped instead.
--   cap  = the most damage one hit (or one tick) can deal, before Horde perk bonuses
HORDE.WonderWeapons = {
    arccw_ww_scavenger = { cap = 2500 },
    arccw_ww_zapguns = { cap = 250 },
    arccw_ww_sliquifier = { cap = 400 },
    arccw_ww_zodsword = { cap = 700 },
    arccw_ww_deathmachine = { cap = 100 },
    arccw_ww_gauntlet = { cap = 500 },
    arccw_ww_gkzmk3 = { cap = 350 },
    arccw_ww_keepersword = { cap = 700 },
    arccw_ww_kt4 = { cap = 600 },
    arccw_ww_dg4 = { cap = 1200 },
    arccw_ww_zmbbow = { cap = 600 },
}

-- Projectiles and lingering effects, for when their damage cannot be traced back to a weapon.
HORDE.WonderWeaponEntities = {
    obj_scavenger_proj = "arccw_ww_scavenger",
    obj_wgun_proj = "arccw_ww_zapguns",
    obj_sliquifier_proj = "arccw_ww_sliquifier",
    obj_sliquifier_puddle = "arccw_ww_sliquifier",
    bo3_ww_mk3 = "arccw_ww_gkzmk3",
    bo3_ww_gkz = "arccw_ww_gkzmk3",
    bo3_ww_gkzmk3_bh = "arccw_ww_gkzmk3",
    bo3_ww_zmbbow = "arccw_ww_zmbbow",
    bo3_ww_mirg = "arccw_ww_kt4",
    bo3_ww_mirg_puddle = "arccw_ww_kt4",
    bo3_status_effect_spores = "arccw_ww_kt4",
    bo3_special_dg4 = "arccw_ww_dg4",
    bo3_special_dg4clone = "arccw_ww_dg4",
    bo3_special_keepersword = "arccw_ww_keepersword",
}

-- Used for pack entities that are not listed above.
HORDE.WONDER_WEAPON_FALLBACK_CAP = 300

-- For pack code: true for bosses and elites (Weeper, Hulk, Yeti, Lesion...), which shrug off
-- control effects such as shrinking, freezing, mind control, lifting and pulling.
-- Clients read the networked flag set below, so effect visuals agree with the server.
function HORDE:WonderWeaponResists(ent)
    if not IsValid(ent) or ent:IsPlayer() then return false end
    if ent:GetNW2Bool("Horde_WonderResist") then return true end
    if CLIENT then return false end
    if ent.Horde_IsElite and ent:Horde_IsElite() then return true end
    local boss = ent.Horde_GetBossProperties and ent:Horde_GetBossProperties()
    if boss and boss.is_boss then return true end
    return string.find(ent:GetClass(), "boss", 1, true) ~= nil
end

if not SERVER then return end

-- Elite and boss flags are set right after an enemy spawns, so check on the next tick
hook.Add("OnEntityCreated", "Horde_WonderWeaponResistFlag", function(ent)
    timer.Simple(0, function()
        if IsValid(ent) and (ent:IsNPC() or ent:IsNextBot()) and HORDE:WonderWeaponResists(ent) then
            ent:SetNW2Bool("Horde_WonderResist", true)
        end
    end)
end)

local function IsPackEntity(class)
    return string.StartWith(class, "bo3_")
end

local function ResolveWonderWeapon(dmginfo)
    local inflictor = dmginfo:GetInflictor()
    if not IsValid(inflictor) then return end

    if inflictor:IsPlayer() then
        local wpn = inflictor:GetActiveWeapon()
        if IsValid(wpn) and HORDE.WonderWeapons[wpn:GetClass()] then return wpn:GetClass() end
        return
    end

    local class = inflictor:GetClass()
    if HORDE.WonderWeapons[class] then return class end

    -- BO3 projectiles keep the weapon that fired them
    if IsValid(inflictor.Inflictor) and HORDE.WonderWeapons[inflictor.Inflictor:GetClass()] then
        return inflictor.Inflictor:GetClass()
    end

    if not HORDE.WonderWeaponEntities[class] and not IsPackEntity(class) then return end

    return HORDE.WonderWeaponEntities[class] or false
end

-- Called from HORDE:ApplyDamage before perk bonuses are added.
function HORDE:CapWonderWeaponDamage(dmginfo)
    local class = ResolveWonderWeapon(dmginfo)
    if class == nil then return end
    local cap = class and HORDE.WonderWeapons[class].cap or HORDE.WONDER_WEAPON_FALLBACK_CAP
    if dmginfo:GetDamage() > cap then
        dmginfo:SetDamage(cap)
    end
end

local function WonderOwner(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then return ent end
    local owner = ent:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then return owner end
    if IsValid(ent.Inflictor) and ent.Inflictor:IsWeapon() then
        owner = ent.Inflictor:GetOwner()
        if IsValid(owner) and owner:IsPlayer() then return owner end
    end
end

local function IsWonderSource(ent)
    if not IsValid(ent) then return false end
    if ent:IsPlayer() then
        local wpn = ent:GetActiveWeapon()
        return IsValid(wpn) and HORDE.WonderWeapons[wpn:GetClass()] ~= nil
    end
    local class = ent:GetClass()
    return HORDE.WonderWeapons[class] ~= nil or HORDE.WonderWeaponEntities[class] ~= nil or IsPackEntity(class)
end

-- Wonder weapons only affect enemies. The packs ask this hook before pushing, freezing or
-- zapping a player, and the engine asks it before any damage to a player.
hook.Add("PlayerShouldTakeDamage", "Horde_WonderWeaponNoFriendlyFire", function(ply, attacker)
    if not IsWonderSource(attacker) then return end
    local owner = WonderOwner(attacker)
    if owner and owner ~= ply then return false end
end)

hook.Add("EntityTakeDamage", "Horde_WonderWeaponNoFriendlyFire", function(target, dmginfo)
    if not target:IsPlayer() then return end
    local attacker, inflictor = dmginfo:GetAttacker(), dmginfo:GetInflictor()
    if not IsWonderSource(inflictor) and not IsWonderSource(attacker) then return end
    local owner = WonderOwner(attacker) or WonderOwner(inflictor)
    if owner and owner ~= target then return true end
end)

-- For pack code: true when a wonder weapon effect from attacker must skip ent
function HORDE:WonderWeaponIgnores(ent, attacker)
    if not IsValid(ent) or not ent:IsPlayer() then return false end
    local owner = WonderOwner(attacker)
    return owner ~= ent
end
