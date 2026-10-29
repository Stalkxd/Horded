-- Kills with Jötunn (and Inferno while it is ignited) burst into ice or fire.
-- The burst grows with the killed enemy's max health; killing an elite or a boss
-- fully applies Frostbite or Ignite to the enemies caught in it.
HORDE.MeleeKillBursts = {
    arccw_horde_jotuun = {
        dmgtype = DMG_REMOVENORAGDOLL,
        status = HORDE.Status_Frostbite,
        effect = "horde_jotuun_ice_explosion",
    },
    arccw_horde_inferno_blade = {
        dmgtype = DMG_BURN,
        status = HORDE.Status_Ignite,
        effect = "horde_blaster_flame_explosion",
        active = function(wpn) return wpn.Charged end,
    },
}

HORDE.MeleeKillBurst_RadiusMin = 120
HORDE.MeleeKillBurst_RadiusMax = 400
HORDE.MeleeKillBurst_DamageMin = 25
HORDE.MeleeKillBurst_DamageMax = 500
HORDE.MeleeKillBurst_DamagePerHealth = 0.2
HORDE.MeleeKillBurst_BuildupPerDamage = 0.3

local bursting = false

local function MeleeKillBurst(victim, attacker, wpn, burst)
    local max_health = math.max(victim:GetMaxHealth(), 1)
    local radius = math.Clamp(HORDE.MeleeKillBurst_RadiusMin + math.sqrt(max_health) * 4,
        HORDE.MeleeKillBurst_RadiusMin, HORDE.MeleeKillBurst_RadiusMax)
    local damage = math.Clamp(max_health * HORDE.MeleeKillBurst_DamagePerHealth,
        HORDE.MeleeKillBurst_DamageMin, HORDE.MeleeKillBurst_DamageMax)
    local strong = victim:Horde_IsElite() or victim:Horde_GetBossProperties() ~= nil
    local buildup = strong and 100 or damage * HORDE.MeleeKillBurst_BuildupPerDamage
    local pos = victim:GetPos() + victim:OBBCenter()

    local e = EffectData()
    e:SetOrigin(pos)
    e:SetScale(radius / 300)
    e:SetEntity(attacker)
    util.Effect(burst.effect, e, true, true)

    bursting = true
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if ent == victim or not IsValid(ent) then continue end
        if not (ent:IsNPC() or ent:IsNextBot()) or ent:Health() <= 0 then continue end
        if HORDE:IsPlayerOrMinion(ent) == true then continue end

        ent:Horde_AddDebuffBuildup(burst.status, buildup, attacker)

        local dmg = DamageInfo()
            dmg:SetDamage(damage)
            dmg:SetDamageType(burst.dmgtype)
            dmg:SetAttacker(attacker)
            dmg:SetInflictor(wpn)
            dmg:SetDamagePosition(ent:GetPos() + ent:OBBCenter())
            dmg:SetDamageCustom(HORDE.DMG_SPLASH)
        ent:TakeDamageInfo(dmg)
    end
    bursting = false
end

hook.Add("Horde_OnEnemyKilled", "Horde_MeleeKillBursts", function(victim, killer, wpn)
    if bursting then return end
    if not IsValid(victim) or not IsValid(killer) or not killer:IsPlayer() then return end
    if not IsValid(wpn) or not wpn:IsWeapon() then return end
    local burst = HORDE.MeleeKillBursts[wpn:GetClass()]
    if not burst then return end
    if burst.active and not burst.active(wpn) then return end
    MeleeKillBurst(victim, killer, wpn, burst)
end)
