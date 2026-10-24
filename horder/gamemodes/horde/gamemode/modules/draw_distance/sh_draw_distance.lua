HORDE = HORDE or {}
HORDE.DrawDistance = HORDE.DrawDistance or {}

local DD = HORDE.DrawDistance

local FLAGS = FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_SERVER_CAN_EXECUTE

local cv_enabled = CreateConVar("horde_drawdist_enabled", 1, FLAGS,
    "Lets players limit their draw distance, with fog hiding the cutoff (0 = off).", 0, 1)
local cv_min = CreateConVar("horde_drawdist_min", 2000, FLAGS,
    "Shortest draw distance a player may pick, in Hammer units.", 500, 65536)
local cv_max = CreateConVar("horde_drawdist_max", 16000, FLAGS,
    "Longest draw distance a player may pick, in Hammer units.", 500, 65536)
CreateConVar("horde_drawdist_fog_color", "120 124 130", FLAGS,
    "Fog colour \"r g b\" used on maps without their own fog.")

-- 1 Hammer unit is 0.75 inch.
DD.UNITS_TO_METERS = 0.01905

function DD.Enabled()
    return cv_enabled:GetBool()
end

function DD.GetRange()
    local lo, hi = cv_min:GetFloat(), cv_max:GetFloat()
    if hi < lo then lo, hi = hi, lo end
    return lo, hi
end

function DD.GetFogColor()
    local cv = GetConVar("horde_drawdist_fog_color")
    local parts = string.Explode(" ", string.Trim(cv and cv:GetString() or ""))
    local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
    if not (r and g and b) then return 120, 124, 130 end
    return math.Clamp(r, 0, 255), math.Clamp(g, 0, 255), math.Clamp(b, 0, 255)
end
