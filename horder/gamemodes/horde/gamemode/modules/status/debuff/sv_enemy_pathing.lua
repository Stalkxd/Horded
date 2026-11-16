if CLIENT then return end

-- Control point pathing for VJ Base enemies.
--
-- How chasing works without this: VJ starts one "go to enemy" schedule
-- (TASK_GET_PATH_TO_ENEMY + TASK_RUN_PATH). While it runs, the engine checks
-- the NPC every AI tick (CAI_BaseNPC::UpdateEnemyPos). Whenever the enemy is
-- more than ~120 units from where the current path ends, it throws the path
-- away and runs a full nodegraph search again (RefindPathToGoal). The 120
-- shrinks towards 0 as the NPC gets close to the end of its path. With a player
-- running around, every chasing enemy rebuilds its path several times a second.
--
-- Before that check the engine asks the NPC's Lua TranslateNavGoal where the
-- enemy "is". VJ answers with the enemy's real position. This file wraps that
-- answer: while an enemy is not close to its target, it keeps answering with
-- the point its current path already leads to (its control point), so the
-- engine sees no difference and keeps walking the path it has. A new point is
-- taken only when:
--   * the NPC is within horde_enemy_path_near of its target (close-range
--     chasing is plain VJ, so fights feel the same),
--   * the target has moved more than horde_enemy_path_repath from the control
--     point (more for far enemies, see FAR_SCALE),
--   * the NPC has got within horde_enemy_path_arrive of the control point,
--   * horde_enemy_path_refresh seconds have passed (twice that for enemies
--     further than horde_enemy_far_distance),
--   * the NPC has barely moved for a while (stuck), or its target changed.
-- New schedules (after an attack, a flinch and so on) also go through this, so
-- they aim at the control point too until one of the above is true.
--
-- Bosses, flying/swimming enemies and non-VJ NPCs are left alone.
-- horde_enemy_path_control 0 turns it all off (plain VJ Base).

local cv_enable  = CreateConVar("horde_enemy_path_control", 1, FCVAR_ARCHIVE, "Enemies follow their current path to a control point instead of rebuilding it every time the player moves. 0 = plain VJ Base.")
local cv_near    = CreateConVar("horde_enemy_path_near", 700, FCVAR_ARCHIVE, "Enemies closer than this to their target chase exactly like plain VJ Base.")
local cv_repath  = CreateConVar("horde_enemy_path_repath", 300, FCVAR_ARCHIVE, "A new path is built once the target is this far from the control point.")
local cv_arrive  = CreateConVar("horde_enemy_path_arrive", 200, FCVAR_ARCHIVE, "A new path is built once the enemy is this close to its control point.")
local cv_refresh = CreateConVar("horde_enemy_path_refresh", 2, FCVAR_ARCHIVE, "Longest time in seconds an enemy keeps one control point (doubled for far enemies). 0 = no time limit.")

-- Far enemies tolerate a larger target move: a quarter of their distance to
-- the target, never less than horde_enemy_path_repath. At 3000 units a player
-- moving 300 units barely changes which way the enemy should walk.
local FAR_SCALE      = 0.25
local STUCK_TIME     = 1.5   -- seconds between stuck samples
local STUCK_DIST_SQR = 32 * 32
local GOAL_MATCH_SQR = 64 * 64
local GOALTYPE_ENEMY = 2

local far_dist = GetConVar("horde_enemy_far_distance")

-- Settings are read once a second by the timer below, not on every call.
local enabled, near_sqr, repath, arrive_sqr, refresh, far_sqr

local function ReadSettings()
    enabled    = cv_enable:GetBool()
    near_sqr   = cv_near:GetFloat() ^ 2
    repath     = cv_repath:GetFloat()
    arrive_sqr = cv_arrive:GetFloat() ^ 2
    refresh    = cv_refresh:GetFloat()
    far_sqr    = (far_dist and far_dist:GetFloat() or 3000) ^ 2
end
ReadSettings()

local stat_held, stat_new = 0, 0
local last_held, last_new = 0, 0

local function IsBoss(ent)
    if ent:GetVar("is_boss") == true then return true end
    local props = ent.Horde_GetBossProperties and ent:Horde_GetBossProperties()
    return props and props.is_boss == true
end

local function ClearPoint(t)
    t.Horde_CP = nil
    t.Horde_CPEnt = nil
end

local function PathTranslateNavGoal(self, ent, goal)
    local t = self:GetTable()
    local real = t.Horde_OrigTranslateNavGoal(self, ent, goal)

    if not enabled or not IsValid(ent) or self:GetCurGoalType() ~= GOALTYPE_ENEMY then
        ClearPoint(t)
        return real
    end

    local target = real or ent:GetPos()
    local my_pos = self:GetPos()
    local now = CurTime()
    local dist_sqr = my_pos:DistToSqr(target)

    -- Stuck check: if the enemy hardly moved since the last sample, drop the point.
    if now >= (t.Horde_CPStuckT or 0) then
        local last = t.Horde_CPStuckPos
        if t.Horde_CP and last and my_pos:DistToSqr(last) < STUCK_DIST_SQR then
            ClearPoint(t)
        end
        t.Horde_CPStuckPos = my_pos
        t.Horde_CPStuckT = now + STUCK_TIME
    end

    local cp = t.Horde_CP
    local keep = cp ~= nil
        and t.Horde_CPEnt == ent
        and dist_sqr > near_sqr
        and now < t.Horde_CPExpire
        and my_pos:DistToSqr(cp) > arrive_sqr

    if keep then
        local allowed = math.max(repath, math.sqrt(dist_sqr) * FAR_SCALE)
        keep = target:DistToSqr(cp) <= allowed * allowed
    end

    if keep then
        stat_held = stat_held + 1
        -- Answer with the exact end of the current path, so the engine's
        -- "has the enemy moved" check measures zero and keeps the path.
        local goal_pos = self:GetGoalPos()
        if goal_pos and goal_pos:DistToSqr(cp) <= GOAL_MATCH_SQR then
            return goal_pos
        end
        return cp
    end

    -- Take a new control point at the target's real position.
    stat_new = stat_new + 1
    t.Horde_CP = target
    t.Horde_CPEnt = ent
    local life = refresh > 0 and refresh or 1e9
    if dist_sqr > far_sqr then life = life * 2 end
    t.Horde_CPExpire = now + life
    return real
end

-- Called by the enemy director once per enemy, next to its other wrappers.
function HORDE.WrapEnemyPathing(ent)
    if not ent.IsVJBaseSNPC or IsBoss(ent) then return end
    if not ent.GetCurGoalType or not ent.GetGoalPos then return end
    local move_type = ent.MovementType
    if move_type == VJ_MOVETYPE_AERIAL or move_type == VJ_MOVETYPE_AQUATIC or move_type == VJ_MOVETYPE_STATIONARY then return end
    local orig = ent.TranslateNavGoal
    if not orig or orig == PathTranslateNavGoal then return end
    ent.Horde_OrigTranslateNavGoal = orig
    ent.TranslateNavGoal = PathTranslateNavGoal
end

timer.Create("Horde_EnemyPathingSettings", 1, 0, function()
    ReadSettings()
    last_held, last_new = stat_held, stat_new
    stat_held, stat_new = 0, 0
end)

concommand.Add("horde_enemy_path_status", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    local total = last_held + last_new
    local msg = string.format("[Horde Pathing] enabled=%s  last second: %d path checks kept the current path, %d took a new point (%.0f%% kept)",
        tostring(enabled), last_held, last_new, total > 0 and last_held / total * 100 or 0)
    if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, msg) else print(msg) end
end)
