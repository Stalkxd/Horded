if CLIENT then return end

-- Enemy director: keeps every horde enemy hunting players, and makes enemies
-- that are far from everyone cheaper to run.
--
--  * Stragglers: an enemy with no target for RETARGET_TIME seconds is handed
--    the nearest player. If it still has none after TELEPORT_TIME and is far
--    away, it is teleported to a spawn point near the players (this catches
--    enemies that keep moving, which the antistuck timer does not).
--  * Far enemies: VJ Base runs most of its per-NPC Lua in ENT:Think. Enemies
--    further than horde_enemy_far_distance from every player only run it every
--    horde_enemy_far_think seconds. The engine still moves them every AI tick.
--  * VJ settings: horde enemies never wander, notice players in every
--    direction and keep a long sight range, so they commit to the chase.

local enabled   = CreateConVar("horde_enemy_director", 1, FCVAR_ARCHIVE, "Give idle enemies a target and teleport ones that never find one.")
local far_dist  = CreateConVar("horde_enemy_far_distance", 3000, FCVAR_ARCHIVE, "Enemies further than this from every player think less often.")
local far_think = CreateConVar("horde_enemy_far_think", 0.3, FCVAR_ARCHIVE, "Seconds between VJ think runs for far enemies. 0 turns it off.")

local CHECK_INTERVAL     = 1.0
local RETARGET_TIME      = 6.0
local TELEPORT_TIME      = 30.0
local TELEPORT_MIN_DIST  = 1500
local SIGHT_DISTANCE     = 10000

local idle_since    = {}
local next_retarget = {}

local function IsVJ(ent)
    return ent.IsVJBaseSNPC == true or ent.Base == "npc_vj_creature_base" or ent.Base == "npc_vj_human_base"
end

local function IsBossEnemy(ent)
    if ent.GetVar and ent:GetVar("is_boss") == true then return true end
    local props = ent.Horde_GetBossProperties and ent:Horde_GetBossProperties()
    return props and props.is_boss == true
end

local function Targetable(ply)
    return ply:Alive() and not ply:IsFlagSet(FL_NOTARGET)
        and not (HORDE.IsPlayerSpectator and HORDE:IsPlayerSpectator(ply))
end

local function HasTarget(ent)
    local target = ent.GetEnemy and ent:GetEnemy()
    if not IsValid(target) then return false end
    if target:IsPlayer() then return Targetable(target) end
    return target:Health() > 0
end

local function ApplyVJSettings(ent)
    if not IsVJ(ent) then return end
    ent.DisableWandering = true
    ent.IdleAlwaysWander = false
    ent.FindEnemy_UseSphere = true
    ent.SightDistance = math.max(ent.SightDistance or 0, SIGHT_DISTANCE)
    if ent.SetMaxLookDistance then ent:SetMaxLookDistance(ent.SightDistance) end
end

local function WrapThink(ent)
    local orig = ent.Think
    if not orig then return end
    ent.Think = function(self)
        if self.Horde_FarFromPlayers then
            local interval = far_think:GetFloat()
            if interval > 0 then
                local now = CurTime()
                if now < (self.Horde_NextFarThink or 0) then return end
                self.Horde_NextFarThink = now + interval
            end
        end
        return orig(self)
    end
end

local function GiveTarget(ent, ply)
    if ent.ForceSetEnemy then
        ent:ForceSetEnemy(ply, false)
    elseif ent:IsNPC() then
        ent:SetEnemy(ply)
        ent:UpdateEnemyMemory(ply, ply:GetPos())
        ent:SetSchedule(SCHED_CHASE_ENEMY)
    end
    if ent.SetLastPosition then ent:SetLastPosition(ply:GetPos()) end
end

local function Forget(ent)
    idle_since[ent] = nil
    next_retarget[ent] = nil
end

timer.Create("Horde_EnemyDirector", CHECK_INTERVAL, 0, function()
    if not HORDE.ScanEnemies then return end

    local plys = {}
    for _, ply in ipairs(player.GetAll()) do
        if Targetable(ply) then plys[#plys + 1] = ply end
    end

    local now = CurTime()
    local far_sqr = far_dist:GetFloat() ^ 2
    local director = enabled:GetBool()

    for _, ent in ipairs(HORDE:ScanEnemies()) do
        if not IsValid(ent) or ent:Health() <= 0 then
            Forget(ent)
            continue
        end

        if not ent.Horde_DirectorSetup then
            ent.Horde_DirectorSetup = true
            ApplyVJSettings(ent)
            WrapThink(ent)
        end

        local pos = ent:GetPos()
        local nearest, nearest_sqr
        for _, ply in ipairs(plys) do
            local d = pos:DistToSqr(ply:GetPos())
            if not nearest_sqr or d < nearest_sqr then nearest, nearest_sqr = ply, d end
        end

        ent.Horde_FarFromPlayers = nearest_sqr ~= nil and nearest_sqr > far_sqr

        if not director or not nearest or ent.Horde_Stunned or HasTarget(ent) then
            idle_since[ent] = nil
            continue
        end

        idle_since[ent] = idle_since[ent] or now
        local idle = now - idle_since[ent]

        if idle >= TELEPORT_TIME and not IsBossEnemy(ent)
            and nearest_sqr > TELEPORT_MIN_DIST * TELEPORT_MIN_DIST
            and HORDE.TeleportEnemyToPlayer and HORDE.TeleportEnemyToPlayer(ent, nearest) then
            idle_since[ent] = nil
            GiveTarget(ent, nearest)
        elseif idle >= RETARGET_TIME and now >= (next_retarget[ent] or 0) then
            next_retarget[ent] = now + RETARGET_TIME
            GiveTarget(ent, nearest)
        end
    end
end)

hook.Add("EntityRemoved", "Horde_EnemyDirectorCleanup", Forget)
