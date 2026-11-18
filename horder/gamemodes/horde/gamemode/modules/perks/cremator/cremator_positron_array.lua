PERK.PrintName = "Positron Array"
PERK.Description = "{1} increased Fire damage resistance.\nAbsorb {2} of Fire damage from enemies as health.\nFire from players hurts you and does not heal."
PERK.Icon = "materials/perks/positron_array.png"
PERK.Params = {
    [1] = {value = 0.25, percent = true},
    [2] = {value = 0.06, percent = true},
}

-- Positron Array used to make the Cremator immune to fire and heal from every fire hit, so
-- standing in your own molotov (or a teammate's) healed you to full. Now fire damages the
-- Cremator again: this perk adds 25% Fire resistance on top of the Cremator base perk's
-- 25-50% (50-75% in total), and only enemy fire heals.
local RESISTANCE = 0.25
local ABSORB = 0.06

PERK.Hooks = {}
PERK.OwnerHooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("cremator_positron_array") then return end
    if not HORDE:IsFireDamage(dmginfo) then return end
    bonus.resistance = bonus.resistance + RESISTANCE

    local damage = dmginfo:GetDamage()
    if damage <= 0 then return end

    -- Molotovs, flamethrowers, the Gauntlet and other player fire never heal
    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then return end
    if HORDE:IsPlayerMinion(attacker) or HORDE:IsPlayerMinion(dmginfo:GetInflictor()) then return end

    HORDE:OnPlayerHeal(ply, HealInfo:New({amount = math.max(1, damage * ABSORB), healer = ply}))
end
