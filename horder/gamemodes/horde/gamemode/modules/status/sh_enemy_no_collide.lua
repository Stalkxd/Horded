CreateConVar("horde_enable_enemy_push", 1, { FCVAR_SERVER_CAN_EXECUTE },
    "Enemies do not collide, but softly push each other away.")

local PUSH_RADIUS    = 52
local MAX_PUSH_SPEED = 90
local PUSH_FORCE     = 45
local PUSH_INTERVAL  = 0.08

local function Horde_IsWaveEnemy(ent)
    if not IsValid(ent) then return false end
    if not (ent:IsNPC() or ent:IsNextBot()) then return false end
    if not HORDE or not HORDE.spawned_enemies then return false end
    return HORDE.spawned_enemies[ent:EntIndex()] == true
end

local PUSH_RADIUS_SQR = PUSH_RADIUS * PUSH_RADIUS
local PUSH_MAX_Z      = 72
local CELL_KEY        = 100003

-- Reused between ticks so the push pass doesn't allocate per enemy.
local push_list, push_n = {}, 0
local push_cells = {}

local function AddPush(a, b, dx, dy, dist)
    local weight = 1 - (dist / PUSH_RADIUS)
    local ux, uy
    if dist < 1 then
        local lo, hi, sign = a.idx, b.idx, 1
        if lo > hi then lo, hi, sign = hi, lo, -1 end
        local ang = ((lo * 53 + hi * 97) % 360) * (math.pi / 180)
        ux, uy = math.cos(ang) * sign, math.sin(ang) * sign
    else
        ux, uy = dx / dist, dy / dist
    end
    a.px, a.py, a.nb = a.px + ux * weight, a.py + uy * weight, a.nb + 1
    b.px, b.py, b.nb = b.px - ux * weight, b.py - uy * weight, b.nb + 1
end

-- Used to run ents.FindInSphere for every enemy 12 times a second. Enemies are
-- already listed in HORDE.spawned_enemies, so bucket their positions into a
-- grid and only compare pairs in neighbouring cells.
local function PushEnemiesApart()
    if not HORDE or not HORDE.spawned_enemies then return end

    local n = 0
    for idx in pairs(HORDE.spawned_enemies) do
        local ent = Entity(idx)
        if IsValid(ent) and (ent:IsNPC() or ent:IsNextBot()) and ent:Health() > 0 then
            n = n + 1
            local e = push_list[n]
            if not e then e = {}; push_list[n] = e end
            local pos = ent:GetPos()
            e.ent, e.idx, e.order = ent, idx, n
            e.x, e.y, e.z = pos.x, pos.y, pos.z
            e.px, e.py, e.nb = 0, 0, 0
        end
    end
    for i = n + 1, push_n do push_list[i] = nil end
    push_n = n
    if n < 2 then return end

    for k in pairs(push_cells) do push_cells[k] = nil end
    local floor = math.floor
    for i = 1, n do
        local e = push_list[i]
        local cx, cy = floor(e.x / PUSH_RADIUS), floor(e.y / PUSH_RADIUS)
        e.cx, e.cy = cx, cy
        local key = cx * CELL_KEY + cy
        local c = push_cells[key]
        if c then c[#c + 1] = e else push_cells[key] = { e } end
    end

    -- Each pair is visited once (lower list index first) and pushes both ways.
    for i = 1, n do
        local a = push_list[i]
        for ix = a.cx - 1, a.cx + 1 do
            for iy = a.cy - 1, a.cy + 1 do
                local c = push_cells[ix * CELL_KEY + iy]
                if c then
                    for j = 1, #c do
                        local b = c[j]
                        if b.order > i and math.abs(a.z - b.z) < PUSH_MAX_Z then
                            local dx, dy = a.x - b.x, a.y - b.y
                            local d2 = dx * dx + dy * dy
                            if d2 < PUSH_RADIUS_SQR then
                                AddPush(a, b, dx, dy, math.sqrt(d2))
                            end
                        end
                    end
                end
            end
        end
    end

    for i = 1, n do
        local e = push_list[i]
        if e.nb > 0 then
            local push_len = math.sqrt(e.px * e.px + e.py * e.py)
            if push_len > 0.001 then
                local push_dir = Vector(e.px / push_len, e.py / push_len, 0)
                local strength = math.min(push_len, 1.0)

                local cur_vel = e.ent:GetVelocity()
                local current_push_speed = cur_vel.x * push_dir.x + cur_vel.y * push_dir.y

                if current_push_speed < MAX_PUSH_SPEED then
                    local add = math.Clamp(MAX_PUSH_SPEED - current_push_speed, 0, PUSH_FORCE * strength)
                    e.ent:SetVelocity(push_dir * add)
                end
            end
        end
    end
end

if SERVER then
    local cv_push = GetConVar("horde_enable_enemy_push")
    timer.Create("Horde_EnemyPush", PUSH_INTERVAL, 0, function()
        if cv_push:GetInt() == 0 then return end
        PushEnemiesApart()
    end)
end

hook.Add("Horde_ShouldCollide", "Horde_EnemyNoCollide", function(ent1, ent2)
    if Horde_IsWaveEnemy(ent1) and Horde_IsWaveEnemy(ent2) then
        return false
    end
end)
