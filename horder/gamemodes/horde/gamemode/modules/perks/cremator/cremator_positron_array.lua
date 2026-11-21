PERK.PrintName = "Positron Array"
PERK.Description = "{1} increased Fire damage resistance.\nAbsorb {2} of Fire damage from enemies as health.\nYour own fire doesn't hurt you and heals {3} of its damage, up to {4} health per second."
PERK.Icon = "materials/perks/positron_array.png"
PERK.Params = {
    [1] = {value = 0.25, percent = true},
    [2] = {value = 0.06, percent = true},
    [3] = {value = 0.25, percent = true},
    [4] = {value = 5},
}

-- Enemy fire: +25% Fire resistance on top of the Cremator base perk's 25-50%, and 6% of
-- the hit comes back as health.
-- Your own fire (standing in your molotov, the base perk's self-burn splash from your
-- blaster, flamethrower or Gauntlet): no damage, and 25% of the hit heals you, capped at
-- 5 health per second so a molotov heals about 25 HP, not to full.
-- Teammates' fire is blocked by friendly fire before it gets here and doesn't heal.
local RESISTANCE = 0.25
local ABSORB = 0.06
local SELF_FIRE_HEAL = 0.25
local SELF_FIRE_HEAL_PER_SECOND = 5

local function HealFromOwnFire(ply, damage)
    local now = CurTime()
    if (ply.Horde_PositronHealWindowEnd or 0) <= now then
        ply.Horde_PositronHealWindowEnd = now + 1
        ply.Horde_PositronHealWindowAmount = 0
    end
    local amount = math.min(math.max(1, damage * SELF_FIRE_HEAL),
        SELF_FIRE_HEAL_PER_SECOND - ply.Horde_PositronHealWindowAmount)
    if amount <= 0 then return end
    ply.Horde_PositronHealWindowAmount = ply.Horde_PositronHealWindowAmount + amount
    HORDE:OnPlayerHeal(ply, HealInfo:New({amount = amount, healer = ply}))
end

PERK.Hooks = {}
PERK.OwnerHooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("cremator_positron_array") then return end
    if not HORDE:IsFireDamage(dmginfo) then return end

    local damage = dmginfo:GetDamage()

    if HORDE:IsCrematorSelfFire(ply, dmginfo) then
        -- Immune to your own fire; it heals instead (capped).
        bonus.resistance = bonus.resistance + 1
        if damage > 0 then HealFromOwnFire(ply, damage) end
        return
    end

    bonus.resistance = bonus.resistance + RESISTANCE
    if damage <= 0 then return end

    -- Other players' fire never heals.
    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then return end
    if HORDE:IsPlayerMinion(attacker) or HORDE:IsPlayerMinion(dmginfo:GetInflictor()) then return end

    HORDE:OnPlayerHeal(ply, HealInfo:New({amount = math.max(1, damage * ABSORB), healer = ply}))
end
