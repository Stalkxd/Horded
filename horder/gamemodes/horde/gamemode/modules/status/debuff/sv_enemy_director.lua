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
--  * Pathing: chasing VJ enemies keep their path to a control point instead
--    of rebuilding it whenever the player moves (sv_enemy_pathing.lua).
--  * VJ settings: horde enemies never wander, notice players in every
--    direction and keep a long sight range, so they commit to the chase.

local enabled   = CreateConVar("horde_enemy_director", 1, FCVAR_ARCHIVE, "Give idle enemies a target and teleport ones that never find one.")
local far_dist  = CreateConVar("horde_enemy_far_distance", 3000, FCVAR_ARCHIVE, "Enemies further than this from every player think less often.")
local far_think = CreateConVar("horde_enemy_far_think", 0.3, FCVAR_ARCHIVE, "Seconds between VJ think runs for far enemies. 0 turns it off.")
local mid_dist  = CreateConVar("horde_enemy_mid_distance", 1200, FCVAR_ARCHIVE, "Enemies further than this (but closer than horde_enemy_far_distance) from every player think a little less often.")
local mid_think = CreateConVar("horde_enemy_mid_think", 0.05, FCVAR_ARCHIVE, "Seconds between VJ think runs for mid-distance enemies. 0 turns it off.")
local ally_recheck = CreateConVar("horde_enemy_ally_recheck", 5, FCVAR_ARCHIVE, "Seconds between VJ relationship checks of one horde enemy against another. 0 checks them every pass, like plain VJ Base.")

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

-- One shared Think replacement for every enemy, instead of a new closure per
-- enemy. The far-think interval is read from the convar once per director pass.
--
-- Enemies close to a player think every tick. Mid-distance enemies think every
-- horde_enemy_mid_think seconds (about every third tick by default) and far ones
-- every horde_enemy_far_think. VJ's Think is driven by CurTime checks (attack
-- cooldowns, sound timers, enemy timeouts), so a few skipped ticks only delay
-- it slightly. The engine still runs movement and schedules every tick.
local far_interval = far_think:GetFloat()
local mid_interval = mid_think:GetFloat()

local function DirectorThink(self)
    local t = self:GetTable()
    local interval = 0
    if t.Horde_FarFromPlayers then
        interval = far_interval
    elseif t.Horde_MidFromPlayers then
        interval = mid_interval
    end
    if interval > 0 then
        local now = CurTime()
        if now < (t.Horde_NextFarThink or 0) then return end
        t.Horde_NextFarThink = now + interval
    end
    return t.Horde_OrigThink(self)
end

local function WrapThink(ent)
    local orig = ent.Think
    if not orig or orig == DirectorThink then return end
    ent.Horde_OrigThink = orig
    ent.Think = DirectorThink
end

-- VJ creatures call UpdatePoseParamTracking from every Think to turn their
-- head and aim pose parameters towards the enemy, which is most of the
-- math.ApproachAngle cost in the profile. It moves each pose parameter by up
-- to PoseParameterLooking_TurningSpeed degrees per call, so running it every
-- pose_interval seconds with the speed scaled by the time that passed keeps
-- the same turn rate. Human base enemies are left alone because their pose
-- parameters aim their guns.
local pose_think = CreateConVar("horde_enemy_pose_interval", 0.1, FCVAR_ARCHIVE, "Seconds between head and aim pose updates for VJ creature enemies. 0 updates every think.")
local pose_interval = pose_think:GetFloat()
local tick = engine.TickInterval()

local function DirectorPoseTracking(self, resetPoses)
    local t = self:GetTable()
    local orig = t.Horde_OrigPoseTracking
    if pose_interval <= 0 then return orig(self, resetPoses) end

    local now = CurTime()
    if now < (t.Horde_NextPoseT or 0) then return end
    local elapsed = now - (t.Horde_LastPoseT or (now - tick))
    t.Horde_NextPoseT = now + pose_interval
    t.Horde_LastPoseT = now

    local speed = t.PoseParameterLooking_TurningSpeed
    if not speed then return orig(self, resetPoses) end
    -- Capped so a long gap (a far enemy, a pause) does not snap the pose instantly.
    local steps = math.max(1, math.min(elapsed, pose_interval * 2) / tick)
    t.PoseParameterLooking_TurningSpeed = speed * steps
    orig(self, resetPoses)
    t.PoseParameterLooking_TurningSpeed = speed
end

local function WrapPoseTracking(ent)
    if not ent.IsVJBaseSNPC_Creature or ent.IsVJBaseSNPC_Human then return end
    local orig = ent.UpdatePoseParamTracking
    if not orig or orig == DirectorPoseTracking then return end
    ent.Horde_OrigPoseTracking = orig
    ent.UpdatePoseParamTracking = DirectorPoseTracking
end

-- VJ's heavy AI pass (MaintainRelationships) walks every NPC and player in the
-- NPC's relationship list. In Horde that list is mostly other horde enemies, so
-- with N enemies it does about N * N checks every second, just to confirm again
-- that the enemies are friends. The engine keeps the relationship VJ set last,
-- so this checks each fellow horde enemy once, then every horde_enemy_ally_recheck
-- seconds. Players, minions and everything else are still checked every pass.
local ally_interval = ally_recheck:GetFloat()

local function DirectorRelationships(self, ...)
    local t = self:GetTable()
    local orig = t.Horde_OrigRelationships
    local list = t.RelationshipEnts
    local spawned = HORDE.spawned_enemies
    if ally_interval <= 0 or not list or not spawned then return orig(self, ...) end

    local next_check = t.Horde_AllyNextCheck
    if not next_check then
        next_check = setmetatable({}, { __mode = "k" })
        t.Horde_AllyNextCheck = next_check
    end

    local now = CurTime()
    local filtered = {}
    local i = 1
    while i <= #list do
        local ent = list[i]
        if not IsValid(ent) then
            -- Passed on so VJ also clears its memory of it; dropped from the real list here.
            filtered[#filtered + 1] = ent
            table.remove(list, i)
        else
            i = i + 1
            if spawned[ent:EntIndex()] and ent ~= self then
                if now >= (next_check[ent] or 0) then
                    next_check[ent] = now + ally_interval
                    filtered[#filtered + 1] = ent
                end
            else
                filtered[#filtered + 1] = ent
            end
        end
    end

    -- VJ reads the list once at the start, so swap it only for this call.
    t.RelationshipEnts = filtered
    local ok, res = pcall(orig, self, ...)
    t.RelationshipEnts = list
    if not ok then error(res, 0) end
    return res
end

local function WrapRelationships(ent)
    local orig = ent.MaintainRelationships
    if not orig or orig == DirectorRelationships then return end
    ent.Horde_OrigRelationships = orig
    ent.MaintainRelationships = DirectorRelationships
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

    far_interval = far_think:GetFloat()
    mid_interval = mid_think:GetFloat()
    ally_interval = ally_recheck:GetFloat()
    pose_interval = pose_think:GetFloat()

    local now = CurTime()
    local far_sqr = far_dist:GetFloat() ^ 2
    local mid_sqr = mid_dist:GetFloat() ^ 2
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
            WrapPoseTracking(ent)
            if IsVJ(ent) then
                WrapRelationships(ent)
                if HORDE.WrapEnemyPathing then HORDE.WrapEnemyPathing(ent) end
            end
        end

        local pos = ent:GetPos()
        local nearest, nearest_sqr
        for _, ply in ipairs(plys) do
            local d = pos:DistToSqr(ply:GetPos())
            if not nearest_sqr or d < nearest_sqr then nearest, nearest_sqr = ply, d end
        end

        ent.Horde_FarFromPlayers = nearest_sqr ~= nil and nearest_sqr > far_sqr
        -- Bosses keep thinking every tick at mid range.
        ent.Horde_MidFromPlayers = nearest_sqr ~= nil and nearest_sqr > mid_sqr and not IsBossEnemy(ent)

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
