-- Source pushes a walking player away from the damage inflictor on every hit:
-- impulse = 5 * damage (up to 1000 u/s), pointing from the inflictor's centre
-- to the player. The push is never shown, so when the inflictor is somewhere
-- the player can't see, it reads as being dragged in one direction:
--   * bleeding, shock, hemorrhage and other status ticks use Entity(0), the
--     world, once the enemy that applied them has died, so every tick pushes
--     the player away from the centre of the map;
--   * ticks and bullets from enemies far away (gunners, poison from an enemy
--     that has since walked off) push away from that enemy.
-- With many enemies and debuffs at once (wave 666) these pile up into a steady
-- drift. Horde's own knockback (VJ melee knockback, boss shockwaves, abilities)
-- sets velocity on purpose and is not affected. Explosions keep their push.

local cv_push  = CreateConVar("horde_damage_push", "0", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "1 = keep Source's built-in push on players from every hit. 0 = only explosions push.")
local cv_debug = CreateConVar("horde_damage_push_debug", "0", { FCVAR_SERVER_CAN_EXECUTE },
    "Print every damage push on a player (strength, inflictor, damage type) to the server console.")

local before = {}

local function KeepsPush(dmginfo)
    if cv_push:GetBool() then return true end
    if not dmginfo:IsDamageType(DMG_BLAST) then return false end
    local inflictor = dmginfo:GetInflictor()
    return IsValid(inflictor) and not inflictor:IsWorld()
end

hook.Add("EntityTakeDamage", "Horde_DamagePush_Before", function(target, dmginfo)
    if not target:IsPlayer() then return end
    local stack = before[target]
    if not stack then stack = {}; before[target] = stack end
    stack[#stack + 1] = { vel = target:GetVelocity(), tick = engine.TickCount() }
end)

-- True when the velocity change points straight away from the inflictor, the way
-- the engine push does. Anything else (a perk or weapon that sets velocity from a
-- damage hook) is left alone.
local function LooksLikeEnginePush(target, inflictor, delta)
    if not IsValid(inflictor) and inflictor ~= game.GetWorld() then return false end
    local away = target:WorldSpaceCenter() - (inflictor:WorldSpaceCenter() - Vector(0, 0, 10))
    away.z, delta = 0, Vector(delta.x, delta.y, 0)
    local al, dl = away:Length(), delta:Length()
    if dl < 1 then return true end -- only vertical: the engine lifts a little when hit from above/below
    if al < 0.001 then return false end
    return away:Dot(delta) / (al * dl) > 0.98
end

hook.Add("PostEntityTakeDamage", "Horde_DamagePush_After", function(target, dmginfo, took)
    if not target:IsPlayer() then return end
    local stack = before[target]
    if not stack or #stack == 0 then return end
    local entry = table.remove(stack)
    if entry.tick ~= engine.TickCount() then
        -- Left over from a hit some other hook blocked before this one ran.
        before[target] = nil
        return
    end
    if not target:Alive() then return end

    local delta = target:GetVelocity() - entry.vel
    if delta:LengthSqr() < 1 then return end
    if not LooksLikeEnginePush(target, dmginfo:GetInflictor(), delta) then return end

    local keep = KeepsPush(dmginfo)
    if cv_debug:GetBool() then
        local inflictor = dmginfo:GetInflictor()
        local name = IsValid(inflictor) and inflictor:GetClass() or (inflictor == game.GetWorld() and "worldspawn" or "none")
        local dist = IsValid(inflictor) and math.floor(inflictor:GetPos():Distance(target:GetPos())) or -1
        MsgC(Color(255, 200, 80), "[Horde DamagePush] ",
            string.format("%s pushed %d u/s by %s (%d units away), dmg %.1f type %d%s\n",
                target:Nick(), math.floor(delta:Length()), name, dist,
                dmginfo:GetDamage(), dmginfo:GetDamageType(), keep and "" or " -> cancelled"))
    end
    if keep then return end

    -- Player:SetVelocity adds velocity, so this takes back exactly the push.
    target:SetVelocity(-delta)
end)

hook.Add("PlayerDisconnected", "Horde_DamagePush_Cleanup", function(ply)
    before[ply] = nil
end)

hook.Add("PlayerDeath", "Horde_DamagePush_Reset", function(ply)
    before[ply] = nil
end)
