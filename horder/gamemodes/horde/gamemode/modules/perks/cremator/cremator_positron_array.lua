PERK.PrintName = "Positron Array"
PERK.Description = "Immune to Fire damage.\nAbsorb {1} of Fire damage taken as health.\nFire from players heals {2} health per hit."
PERK.Icon = "materials/perks/positron_array.png"
PERK.Params = {
    [1] = {value = 0.06, percent = true},
    [2] = {value = 1},
}

PERK.Hooks = {}
PERK.OwnerHooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("cremator_positron_array") then return end
    if not HORDE:IsFireDamage(dmginfo) then return end
    bonus.resistance = bonus.resistance + 1.00

    local damage = dmginfo:GetDamage()
    if damage <= 0 then return end

    -- Fire from your own or a teammate's weapons (blaster, flamethrower...) only heals
    -- a flat 1 health per hit, so you can't sustain yourself by shooting your own fire.
    local attacker = dmginfo:GetAttacker()
    local heal
    if IsValid(attacker) and attacker:IsPlayer() then
        heal = 1
    else
        heal = math.max(1, damage * 0.06)
    end
    HORDE:OnPlayerHeal(ply, HealInfo:New({amount = heal, healer = ply}))
end
