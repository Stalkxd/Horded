-- Lag compensation helpers.
--
-- Player:LagCompensation(true) rewinds every compensated entity (players and
-- every Horde enemy) to where the shooter saw them. Source only has ONE
-- compensation session for the whole server, so if a weapon turns it on and
-- then errors or returns early, the session never closes: enemies stay stuck
-- at their rewound positions, every later shot from every player prints
-- "Trying to start a new lag compensation session while one is already
-- active!" and hit detection breaks until something turns it off again.
-- Lag makes this worse, because more ticks run while the session is open.

-- Runs fn(...) with ply's lag compensation on and always turns it back off,
-- even if fn errors or returns early. Errors are still printed.
function HORDE:WithLagCompensation(ply, fn, ...)
    local comp = SERVER and IsValid(ply) and ply:IsPlayer()
    if comp then ply:LagCompensation(true) end
    local res = { xpcall(fn, ErrorNoHaltWithStack, ...) }
    if comp then ply:LagCompensation(false) end
    if res[1] then return unpack(res, 2) end
end

if not SERVER then return end

-- The wave director marks its own spawns as lag compensated, but enemies
-- created anywhere else (mitosis children, bioleak, boss summons, unarmed mode
-- spawns, other addons) were not, so hitscan weapons missed them for anyone
-- with ping. Mark every hostile NPC/nextbot once its owner is known.
hook.Add("OnEntityCreated", "Horde_LagCompensateEnemies", function(ent)
    if not (ent:IsNPC() or ent:IsNextBot()) then return end
    timer.Simple(0, function()
        if IsValid(ent) and HORDE:IsEnemy(ent) then
            ent:SetLagCompensated(true)
        end
    end)
end)
