local CHECK_INTERVAL = 0.08
local CHECK_RADIUS   = 75

local MAX_PLY_SPEED  = 160
local MAX_NPC_SPEED  = 100
local PUSH_FORCE     = 65

local TOUCH_PAD = 4
local function AABBsTouch(mins1, maxs1, mins2, maxs2)
    return (mins1.x - TOUCH_PAD) <= maxs2.x and (maxs1.x + TOUCH_PAD) >= mins2.x
       and (mins1.y - TOUCH_PAD) <= maxs2.y and (maxs1.y + TOUCH_PAD) >= mins2.y
       and (mins1.z - TOUCH_PAD) <= maxs2.z and (maxs1.z + TOUCH_PAD) >= mins2.z
end

local function SafeDirection(posA, posB, seed)
    local dir = posA - posB
    dir.z = 0
    local len = dir:Length()
    if len < 1 then
        local ang = ((seed * 57) % 360) * (math.pi / 180)
        return Vector(math.cos(ang), math.sin(ang), 0), 1
    end
    return dir / len, len
end

-- Only enemies the player really bumps into should push them. Some enemies are
-- made to be walked through or are not there to see: the Plague Platoon boss is
-- an invisible zero-size point at its spawn that lives until the platoon dies,
-- and the spectres have zero-size hulls. Pushing from those shoved players in
-- one direction from nothing visible (always the same direction when standing
-- right on top of the point).
local function BlocksPlayer(ply, ent)
    if ent.Dead then return false end
    if not ent:IsSolid() or ent:GetNoDraw() then return false end
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    if (maxs.x - mins.x) < 2 or (maxs.y - mins.y) < 2 or (maxs.z - mins.z) < 2 then return false end
    if ent:GetRenderMode() ~= RENDERMODE_NORMAL and ent:GetColor().a == 0 then return false end
    if IsValid(ent:GetParent()) then return false end
    if hook.Run("ShouldCollide", ply, ent) == false then return false end
    return true
end

local function UpdatePlayerEnemySeparation()
    if CLIENT then return end

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:Alive() then continue end
        if ply.Horde_GetPhasing and ply:Horde_GetPhasing() then continue end
        if ply:GetMoveType() == MOVETYPE_NOCLIP then continue end

        local pmins, pmaxs = ply:WorldSpaceAABB()
        local ppos = ply:WorldSpaceCenter()
        local combined_push = Vector(0, 0, 0)
        local touching_count = 0

        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), CHECK_RADIUS)) do
            if not IsValid(ent) or ent == ply then continue end
            if not (ent:IsNPC() or ent:IsNextBot()) then continue end
            if ent:Health() <= 0 then continue end
            if HORDE and HORDE.IsEnemy and not HORDE:IsEnemy(ent) then continue end
            if not BlocksPlayer(ply, ent) then continue end

            local emins, emaxs = ent:WorldSpaceAABB()
            if AABBsTouch(pmins, pmaxs, emins, emaxs) then
                local npos = ent:WorldSpaceCenter()
                local dir, dist = SafeDirection(ppos, npos, ent:EntIndex())
                local factor = math.Clamp(1 - (dist / CHECK_RADIUS), 0.25, 1.0)

                combined_push:Add(dir * factor)
                touching_count = touching_count + 1

                local nvel = ent:GetVelocity()
                local nvel_h = Vector(nvel.x, nvel.y, 0)
                local away_dir = -dir
                local cur_speed = nvel_h:Dot(away_dir)

                if cur_speed < MAX_NPC_SPEED then
                    local add = math.Clamp(MAX_NPC_SPEED - cur_speed, 0, PUSH_FORCE * factor)
                    ent:SetVelocity(away_dir * add)
                end
            end
        end

        if touching_count > 0 then
            local push_len = combined_push:Length()
            if push_len > 0.001 then
                local push_dir = combined_push / push_len
                local strength = math.min(push_len, 1.0)

                local pvel = ply:GetVelocity()
                local pvel_h = Vector(pvel.x, pvel.y, 0)
                local cur_speed = pvel_h:Dot(push_dir)

                if cur_speed < MAX_PLY_SPEED then
                    local add = math.Clamp(MAX_PLY_SPEED - cur_speed, 0, PUSH_FORCE * strength)
                    ply:SetVelocity(push_dir * add)
                end
            end
        end
    end
end

if SERVER then
    timer.Create("Horde_PlayerEnemySeparation", CHECK_INTERVAL, 0, UpdatePlayerEnemySeparation)
end
