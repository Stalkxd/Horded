PERK.PrintName = "Cremator Base"
PERK.Description = [[
The Cremator builds its offense and defense around Fire damage.
Complexity: EASY

{1} increased Fire damage resistance. ({2} + {3} per level, up to {4}).
Attacks have {5} chance to Ignite enemies.

Ignite base duration is {6} and deals damage over time based on hit damage.
Fire damage has {7} Ignite chance.

Like a Demolition's explosives, your fire burns you too: Fire damage you deal
within {8} units of yourself splashes back up to {9} of it on you.]]
PERK.Params = {
    [1] = {percent = true, base = 0.25, level = 0.01, max = 0.5, classname = HORDE.Class_Cremator},
    [2] = {value = 0.25, percent = true},
    [3] = {value = 0.01, percent = true},
    [4] = {value = 0.5, percent = true},
    [5] = {value = 0.15, percent = true},
    [6] = {value = 4},
    [7] = {value = 1, percent = true},
    [8] = {value = 160},
    [9] = {value = 0.5, percent = true},
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

-- Self-burn: fire the Cremator deals close to themselves splashes back on them, the way a
-- Demolition's own explosions hurt them. Full share at point blank, none at the edge of
-- the radius, then the usual resistances apply (Cremator base 25-50%, Positron Array +25%).
-- Ignite ticks (inflictor is the player) and molotov fire (which already burns whoever
-- stands in it) don't splash.
local SELF_BURN_RADIUS = 160
local SELF_BURN_SHARE = 0.5
local SELF_BURN_INTERVAL = 0.25
local SKIP_INFLICTORS = { arccw_horde_fire = true, entityflame = true }

PERK.OwnerHooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("cremator_base") then return end
    if not HORDE:IsFireDamage(dmginfo) then return end
    local inflictor = dmginfo:GetInflictor()
    if not IsValid(inflictor) or inflictor == ply or SKIP_INFLICTORS[inflictor:GetClass()] then return end
    if HORDE:IsMinion(inflictor) then return end
    if (ply.Horde_CrematorSelfBurnNext or 0) > CurTime() then return end

    local center = ply:WorldSpaceCenter()
    local dist = npc:NearestPoint(center):Distance(center)
    local pos = dmginfo:GetDamagePosition()
    if pos and not pos:IsZero() then dist = math.min(dist, pos:Distance(center)) end
    if dist >= SELF_BURN_RADIUS then return end

    local amount = dmginfo:GetDamage() * SELF_BURN_SHARE * (1 - dist / SELF_BURN_RADIUS)
    if amount < 1 then return end
    ply.Horde_CrematorSelfBurnNext = CurTime() + SELF_BURN_INTERVAL

    timer.Simple(0, function ()
        if not IsValid(ply) or not ply:Alive() then return end
        local d = DamageInfo()
        d:SetAttacker(ply)
        d:SetInflictor(IsValid(inflictor) and inflictor or game.GetWorld())
        d:SetDamage(amount)
        d:SetDamageType(DMG_BURN)
        d:SetDamagePosition(center)
        ply:TakeDamageInfo(d)
    end)
end
