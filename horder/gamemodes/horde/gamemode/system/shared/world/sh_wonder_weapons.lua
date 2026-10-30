-- Horde balance data for the TFA wonder weapon packs (CoD Zombies Wonder Weapons and
-- Black Ops 3 Wonder Weapons). The packs are built for nZombies and kill most targets in one
-- hit, so under Horde every damage event from them is capped instead.
--   cap  = the most damage one hit (or one tick) can deal, before Horde perk bonuses
--   wave = the wave it unlocks on in a 10-wave game; scaled to the max wave count otherwise
HORDE.WonderWeapons = {
    tfa_raygun = { cap = 300, wave = 6 },
    tfa_wintershowl = { cap = 150, wave = 6 },
    tfa_vr11 = { cap = 200, wave = 6 },
    tfa_blundergat = { cap = 140, wave = 6 },
    tfa_wavegun = { cap = 250, wave = 6 },
    tfa_acidgat = { cap = 350, wave = 6 },
    tfa_paralyzer = { cap = 60, wave = 7 },
    tfa_jetgun = { cap = 80, wave = 7 },
    tfa_sliquifier = { cap = 400, wave = 7 },
    tfa_shrinkray = { cap = 500, wave = 7 },
    tfa_staff_fire = { cap = 300, wave = 7 },
    tfa_staff_ice = { cap = 200, wave = 7 },
    tfa_staff_lightning = { cap = 250, wave = 7 },
    tfa_staff_wind = { cap = 600, wave = 7 },
    tfa_scavenger = { cap = 2500, wave = 8 },
    tfa_raygun_mark2 = { cap = 250, wave = 8 },
    tfa_thundergun = { cap = 700, wave = 8 },
    tfa_wunderwaffe = { cap = 800, wave = 8 },
    tfa_staff_fire_ult = { cap = 480, wave = 9 },
    tfa_staff_ice_ult = { cap = 320, wave = 9 },
    tfa_staff_lightning_ult = { cap = 400, wave = 9 },
    tfa_staff_wind_ult = { cap = 950, wave = 9 },
    tfa_bo3_gkzmk3 = { cap = 350, wave = 7 },
    tfa_bo3_zmbbow = { cap = 600, wave = 7 },
    tfa_bo3_skullgun = { cap = 120, wave = 8 },
    tfa_bo3_keepersword = { cap = 700, wave = 8 },
    tfa_bo3_zodsword = { cap = 700, wave = 8 },
    tfa_bo3_mirg2000 = { cap = 450, wave = 8 },
    tfa_bo3_gauntlet = { cap = 90, wave = 9 },
    tfa_bo3_idgun = { cap = 1500, wave = 9 },
    tfa_bo3_dg4 = { cap = 1200, wave = 9 },
    tfa_bo3_annihilator_zm = { cap = 2500, wave = 9 },
    tfa_bo3_monkeybomb = { cap = 600, wave = 6 },
    tfa_bo3_lilarnie = { cap = 300, wave = 7 },
    tfa_bo3_matryoshka = { cap = 500, wave = 7 },
    tfa_bo3_gstrike = { cap = 900, wave = 7 },
    tfa_bo3_gersch = { cap = 800, wave = 8 },
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

function HORDE:GetWonderWeaponUnlockWave(class)
    local data = HORDE.WonderWeapons[class]
    if not data then return 1 end
    local max_waves = HORDE.max_waves or 10
    return math.max(1, math.ceil(data.wave / 10 * max_waves))
end

-- ITEM.CanPurchase for wonder weapon shop items. The shop opens before each wave, so a
-- weapon for wave N can be bought once wave N - 1 is over.
function HORDE.WonderWeaponCanPurchase(ply, item)
    local wave = HORDE:GetWonderWeaponUnlockWave(item.class)
    if (HORDE.current_wave or 0) + 1 < wave then
        return false, item.name .. " unlocks at wave " .. wave .. "."
    end
end

if not SERVER then return end

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
