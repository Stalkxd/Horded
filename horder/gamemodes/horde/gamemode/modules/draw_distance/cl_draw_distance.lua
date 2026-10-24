if not CLIENT then return end

-- cl_ sorts before sh_, so the shared helpers are filled in after this file loads.
HORDE = HORDE or {}
HORDE.DrawDistance = HORDE.DrawDistance or {}
local DD = HORDE.DrawDistance

local cv_dist = CreateClientConVar("horde_draw_distance", "8000", true, false,
    "How far you can see, in Hammer units. Clamped to the server's horde_drawdist_min/max.", 0, 65536)
local cv_fade = CreateClientConVar("horde_draw_distance_fade", "60", true, false,
    "Percent of the draw distance over which models fade into the fog.", 10, 90)

-- Fog is fully opaque a little before the far plane, so nothing is visibly clipped.
local FOG_END_FRAC = 0.95

function DD.GetDistance()
    if not DD.Enabled() then return nil end
    local lo, hi = DD.GetRange()
    return math.Clamp(cv_dist:GetFloat(), lo, hi)
end

function DD.GetFade()
    return math.Clamp(cv_fade:GetFloat(), 10, 90) / 100
end

local last_start, last_end

hook.Add("SetupWorldFog", "Horde_DrawDistance", function()
    local far = DD.GetDistance()
    if not far then
        last_start, last_end = nil, nil
        return
    end

    local fog_end = far * FOG_END_FRAC
    local fog_start = fog_end * (1 - DD.GetFade())
    local r, g, b = DD.GetFogColor()

    -- The engine has already applied the map's env_fog_controller here. Values that match
    -- what we set last frame are ours, not the map's.
    if render.GetFogMode() ~= MATERIAL_FOG_NONE then
        local map_start, map_end = render.GetFogDistances()
        if map_start ~= last_start or map_end ~= last_end then
            -- The map's own fog already hides everything before our cutoff: leave it alone.
            if map_end > 0 and map_end <= fog_end then
                last_start, last_end = nil, nil
                return
            end
            r, g, b = render.GetFogColor()
        end
    end

    render.FogMode(MATERIAL_FOG_LINEAR)
    render.FogStart(fog_start)
    render.FogEnd(fog_end)
    render.FogMaxDensity(1)
    render.FogColor(r, g, b)
    last_start, last_end = fog_start, fog_end
    return true
end)

-- Hooks returning a view table would skip the gamemode, so zfar is set here instead of
-- in a CalcView hook. If an addon does take over the view, the fog still hides the far
-- distance, only the performance gain from clipping is lost.
local GM = GM or GAMEMODE
local base = baseclass.Get("gamemode_sandbox")

function GM:CalcView(ply, origin, angles, fov, znear, zfar)
    local view = base.CalcView(self, ply, origin, angles, fov, znear, zfar)
    local far = DD.GetDistance()
    if far and istable(view) then
        view.zfar = math.min(view.zfar or zfar or far, far)
    end
    return view
end
