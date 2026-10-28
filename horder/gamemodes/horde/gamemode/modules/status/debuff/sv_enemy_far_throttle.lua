if CLIENT then return end

-- Server-side "AI LOD": wave enemies far from every player run VJ Base's heavy
-- AI pass (enemy search, relationship checks) less often. They keep chasing the
-- enemy they already have; once a player comes back in range they return to
-- their normal rate. Engine NPCs and NPCs without the VJ field are left alone.

local cv_enable = CreateConVar("horde_npc_far_throttle", "1", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Run the heavy AI pass less often for enemies far from every player.")
local cv_dist   = CreateConVar("horde_npc_far_throttle_distance", "2500", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Distance from the closest alive player beyond which an enemy is throttled.")
local cv_time   = CreateConVar("horde_npc_far_throttle_process_time", "3", { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Seconds between heavy AI passes for a throttled enemy (VJ Base NextProcessTime).")

local CHECK_INTERVAL = 1
-- Enemies must come this much closer than the threshold before they are
-- un-throttled, so one walking along the edge doesn't flip every second.
local HYSTERESIS     = 250

local throttled_count = 0

local function IsBoss(ent)
    return ent:GetVar("is_boss") == true
end

local function Restore(ent)
    if ent.Horde_FarThrottled then
        ent.Horde_FarThrottled = nil
        ent.NextProcessTime = ent.Horde_BaseNextProcessTime
    end
end

timer.Create("Horde_EnemyFarThrottle", CHECK_INTERVAL, 0, function()
    local spawned = HORDE.spawned_enemies
    if not spawned then return end

    local enabled = cv_enable:GetBool()
    local ply_pos = {}
    if enabled then
        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() then ply_pos[#ply_pos + 1] = ply:GetPos() end
        end
    end

    local far_d   = math.max(0, cv_dist:GetFloat())
    local far_sqr = far_d * far_d
    local near_d  = math.max(0, far_d - HYSTERESIS)
    local near_sqr = near_d * near_d
    local far_time = math.max(0.1, cv_time:GetFloat())

    local count = 0
    for idx in pairs(spawned) do
        local ent = Entity(idx)
        if IsValid(ent) and ent.NextProcessTime ~= nil then
            if ent.Horde_BaseNextProcessTime == nil then
                ent.Horde_BaseNextProcessTime = ent.NextProcessTime
            end

            local far = false
            if enabled and #ply_pos > 0 and not IsBoss(ent) then
                local pos = ent:GetPos()
                local closest = math.huge
                for i = 1, #ply_pos do
                    local d = pos:DistToSqr(ply_pos[i])
                    if d < closest then closest = d end
                end
                far = closest > (ent.Horde_FarThrottled and near_sqr or far_sqr)
            end

            if far then
                ent.Horde_FarThrottled = true
                ent.NextProcessTime = math.max(ent.Horde_BaseNextProcessTime, far_time)
                count = count + 1
            else
                Restore(ent)
            end
        end
    end
    throttled_count = count
end)

concommand.Add("horde_npc_far_throttle_status", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    local total = 0
    for idx in pairs(HORDE.spawned_enemies or {}) do
        if IsValid(Entity(idx)) then total = total + 1 end
    end
    print(string.format("[Horde Throttle] enabled=%s distance=%d throttled=%d of %d alive enemies",
        tostring(cv_enable:GetBool()), cv_dist:GetInt(), throttled_count, total))
end)
