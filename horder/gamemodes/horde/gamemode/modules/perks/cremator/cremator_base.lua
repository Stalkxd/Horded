PERK.PrintName = "Cremator Base"
PERK.Description = [[
The Cremator builds its offense and defense around Fire damage.
Complexity: EASY

{1} increased Fire damage resistance. ({2} + {3} per level, up to {4}).
Attacks have {5} chance to Ignite enemies.

Ignite base duration is {6} and deals damage over time based on hit damage.
Fire damage has {7} Ignite chance.

Your fire heals you: Fire damage you deal heals you {8} of it, up to {9} health
per second. Your own fire never hurts you.]]
PERK.Params = {
    [1] = {percent = true, base = 0.25, level = 0.01, max = 0.5, classname = HORDE.Class_Cremator},
    [2] = {value = 0.25, percent = true},
    [3] = {value = 0.01, percent = true},
    [4] = {value = 0.5, percent = true},
    [5] = {value = 0.15, percent = true},
    [6] = {value = 4},
    [7] = {value = 1, percent = true},
    [8] = {value = 0.1, percent = true},
    [9] = {value = 10},
}

PERK.Hooks = {}

PERK.ApplyIgniteChanceBonus = 0.15

PERK.OwnerHooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("cremator_base")  then return end
    if HORDE:IsFireDamage(dmginfo) then
        bonus.resistance = bonus.resistance + ply:Horde_GetPerkLevelBonus("cremator_base")
    end
end

PERK.OwnerHooks.Horde_OnPlayerDebuffApply = function (ply, debuff, bonus)
    if not ply:Horde_GetPerk("cremator_base")  then return end
    if debuff == HORDE.Status_Ignite then
        bonus.apply = 0
        return true
    end
end

PERK.Hooks.Horde_PrecomputePerkLevelBonus = function (ply)
    if SERVER then
        ply:Horde_SetPerkLevelBonus("cremator_base", math.min(0.5, 0.25 + 0.01 * ply:Horde_GetLevel(HORDE.Class_Cremator)))
    end
end

-- Fire heals the Cremator: every hit of Fire damage they deal (flamethrower, blaster,
-- Gauntlet, molotov, Ignite) heals them 10% of the damage, up to 10 health per second.
-- Their own fire never hurts them (sv_damage.lua turns it into the same heal).
-- No perk, range or other condition. Set horde_cremator_heal_debug 1 to print each heal.
local HEAL_SHARE = 0.1
local HEAL_PER_SECOND = 10
local debug_cv = CreateConVar("horde_cremator_heal_debug", "0", FCVAR_ARCHIVE,
    "Print every Cremator fire heal to the server console.")

function HORDE:CrematorFireHeal(ply, damage, source)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    local now = CurTime()
    if (ply.Horde_CrematorHealWindowEnd or 0) <= now then
        ply.Horde_CrematorHealWindowEnd = now + 1
        ply.Horde_CrematorHealWindowAmount = 0
    end
    local amount = math.min(math.max(1, damage * HEAL_SHARE),
        HEAL_PER_SECOND - ply.Horde_CrematorHealWindowAmount)
    if debug_cv:GetBool() then
        print(string.format("[Cremator heal] %s %s dmg=%.1f heal=%.1f hp=%d/%d", ply:Nick(),
            tostring(source), damage, math.max(amount, 0), ply:Health(), ply:GetMaxHealth()))
    end
    if amount <= 0 then return end
    ply.Horde_CrematorHealWindowAmount = ply.Horde_CrematorHealWindowAmount + amount
    HORDE:OnPlayerHeal(ply, HealInfo:New({amount = amount, healer = ply}))
end

PERK.OwnerHooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("cremator_base") then return end
    if not HORDE:IsFireDamage(dmginfo) then return end
    local inflictor = dmginfo:GetInflictor()
    -- Turrets and pets don't heal their owner.
    if IsValid(inflictor) and (inflictor:IsNPC() or inflictor:IsNextBot()) then return end
    HORDE:CrematorFireHeal(ply, dmginfo:GetDamage(), IsValid(inflictor) and inflictor:GetClass() or "?")
end
