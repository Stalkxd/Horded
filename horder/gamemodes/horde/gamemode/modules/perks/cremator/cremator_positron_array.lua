PERK.PrintName = "Positron Array"
PERK.Description = "Immune to Fire damage.\nAbsorb {1} of Fire damage taken as health.\nFire from players heals {2} health per hit, up to {3} health per second."
PERK.Icon = "materials/perks/positron_array.png"
PERK.Params = {
    [1] = {value = 0.06, percent = true},
    [2] = {value = 1},
    [3] = {value = 3},
}

-- Fire from players (your own molotov, blaster or flamethrower, or a teammate's) heals
-- a flat 1 health per hit, and all of it together heals at most 3 health per second.
-- Without the cap, standing in your own molotov or a teammate's flamethrower stream
-- (12 hits a second) would refill your health.
local PLAYER_FIRE_HEAL = 1
local PLAYER_FIRE_HEAL_PER_SECOND = 3

local function HealFromPlayerFire(ply)
    local now = CurTime()
    if (ply.Horde_PositronHealWindowEnd or 0) <= now then
        ply.Horde_PositronHealWindowEnd = now + 1
        ply.Horde_PositronHealWindowAmount = 0
    end
    if ply.Horde_PositronHealWindowAmount >= PLAYER_FIRE_HEAL_PER_SECOND then return end
    ply.Horde_PositronHealWindowAmount = ply.Horde_PositronHealWindowAmount + PLAYER_FIRE_HEAL
    HORDE:OnPlayerHeal(ply, HealInfo:New({amount = PLAYER_FIRE_HEAL, healer = ply}))
end

PERK.Hooks = {}
PERK.OwnerHooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("cremator_positron_array") then return end
    if not HORDE:IsFireDamage(dmginfo) then return end
    bonus.resistance = bonus.resistance + 1.00

    local damage = dmginfo:GetDamage()
    if damage <= 0 then return end

    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
        HealFromPlayerFire(ply)
    else
        HORDE:OnPlayerHeal(ply, HealInfo:New({amount = math.max(1, damage * 0.06), healer = ply}))
    end
end

-- Teammates' fire never damages you, so it doesn't reach Horde_OnPlayerDamageTaken.
-- It still heals, sharing the same cap.
PERK.OwnerHooks.Horde_OnPlayerFriendlyFireTaken = function (ply, dmginfo)
    if not ply:Horde_GetPerk("cremator_positron_array") then return end
    if not HORDE:IsFireDamage(dmginfo) then return end
    HealFromPlayerFire(ply)
end
