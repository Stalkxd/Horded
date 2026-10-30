-- Horde balance data for the TFA wonder weapon packs (CoD Zombies Wonder Weapons and
-- Black Ops 3 Wonder Weapons). The packs are built for nZombies and kill most targets in one
-- hit, so under Horde every damage event from them is capped instead.
--   cap  = the most damage one hit (or one tick) can deal, before Horde perk bonuses
HORDE.WonderWeapons = {
    tfa_raygun = { cap = 300 },
    tfa_wintershowl = { cap = 150 },
    tfa_vr11 = { cap = 200 },
    tfa_blundergat = { cap = 140 },
    tfa_wavegun = { cap = 250 },
    tfa_acidgat = { cap = 350 },
    tfa_paralyzer = { cap = 60 },
    tfa_jetgun = { cap = 80 },
    tfa_sliquifier = { cap = 400 },
    tfa_shrinkray = { cap = 500 },
    tfa_staff_fire = { cap = 300 },
    tfa_staff_ice = { cap = 200 },
    tfa_staff_lightning = { cap = 250 },
    tfa_staff_wind = { cap = 600 },
    tfa_scavenger = { cap = 2500 },
    tfa_raygun_mark2 = { cap = 250 },
    tfa_thundergun = { cap = 700 },
    tfa_wunderwaffe = { cap = 800 },
    tfa_staff_fire_ult = { cap = 480 },
    tfa_staff_ice_ult = { cap = 320 },
    tfa_staff_lightning_ult = { cap = 400 },
    tfa_staff_wind_ult = { cap = 950 },
    tfa_bo3_gkzmk3 = { cap = 350 },
    tfa_bo3_zmbbow = { cap = 600 },
    tfa_bo3_skullgun = { cap = 120 },
    tfa_bo3_keepersword = { cap = 700 },
    tfa_bo3_zodsword = { cap = 700 },
    tfa_bo3_mirg2000 = { cap = 450 },
    tfa_bo3_gauntlet = { cap = 90 },
    tfa_bo3_idgun = { cap = 1500 },
    tfa_bo3_dg4 = { cap = 1200 },
    tfa_bo3_annihilator_zm = { cap = 2500 },
    tfa_bo3_monkeybomb = { cap = 600 },
    tfa_bo3_lilarnie = { cap = 300 },
    tfa_bo3_matryoshka = { cap = 500 },
    tfa_bo3_gstrike = { cap = 900 },
    tfa_bo3_gersch = { cap = 800 },
}

-- Projectiles and lingering effects, for when their damage cannot be traced back to a weapon.
HORDE.WonderWeaponEntities = {
    obj_rgun_proj = "tfa_raygun",
    obj_whowl_proj = "tfa_wintershowl",
    obj_humangun_proj = "tfa_vr11",
    obj_wgun_proj = "tfa_wavegun",
    obj_wgun_proj2 = "tfa_wavegun",
    obj_acidgat_proj = "tfa_acidgat",
    obj_sliquifier_proj = "tfa_sliquifier",
    obj_sliquifier_puddle = "tfa_sliquifier",
    obj_babygun_proj = "tfa_shrinkray",
    obj_firestaff_proj = "tfa_staff_fire",
    obj_icestaff_proj = "tfa_staff_ice",
    obj_lstaff_proj = "tfa_staff_lightning",
    obj_windstaff_proj = "tfa_staff_wind",
    obj_scavenger_proj = "tfa_scavenger",
    obj_wunderwaffe_proj = "tfa_wunderwaffe",
    obj_blank_proj = "tfa_wunderwaffe",
    bo3_ww_mk3 = "tfa_bo3_gkzmk3",
    bo3_ww_gkz = "tfa_bo3_gkzmk3",
    bo3_ww_gkzmk3_bh = "tfa_bo3_gkzmk3",
    bo3_ww_zmbbow = "tfa_bo3_zmbbow",
    bo3_ww_mirg = "tfa_bo3_mirg2000",
    bo3_ww_mirg_puddle = "tfa_bo3_mirg2000",
    bo3_status_effect_spores = "tfa_bo3_mirg2000",
    bo3_ww_idgun = "tfa_bo3_idgun",
    bo3_status_effect_portalpull = "tfa_bo3_idgun",
    bo3_special_dg4 = "tfa_bo3_dg4",
    bo3_special_dg4clone = "tfa_bo3_dg4",
    bo3_special_keepersword = "tfa_bo3_keepersword",
    bo3_status_effect_skullstun = "tfa_bo3_skullgun",
    bo3_tac_monkeybomb = "tfa_bo3_monkeybomb",
    bo3_tac_lilarnie = "tfa_bo3_lilarnie",
    bo3_tac_lilarnie_squid = "tfa_bo3_lilarnie",
    bo3_tac_matryoshka = "tfa_bo3_matryoshka",
    bo3_tac_matryoshka_mini = "tfa_bo3_matryoshka",
    bo3_tac_gstrike = "tfa_bo3_gstrike",
    bo3_tac_gstrike_mortar = "tfa_bo3_gstrike",
    bo3_tac_gersch = "tfa_bo3_gersch",
}

-- Used for pack entities that are not listed above.
HORDE.WONDER_WEAPON_FALLBACK_CAP = 300

-- The packs cap reserve ammo at nZombies values. Horde lets players carry this many times that.
HORDE.WONDER_WEAPON_AMMO_MULT = 3

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

    -- Upgraded staffs share projectiles with the base staffs, so prefer what the owner holds
    local owner = inflictor:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        local wpn = owner:GetActiveWeapon()
        if IsValid(wpn) and HORDE.WonderWeapons[wpn:GetClass()] then
            local mapped = HORDE.WonderWeaponEntities[class]
            if not mapped or string.StartWith(wpn:GetClass(), mapped) then return wpn:GetClass() end
        end
    end

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
