if CLIENT then return end

-- horde_profile_callers [seconds]
--
-- FProfiler shows which functions take the most time, but not who calls them.
-- This command counts the calls to the small functions that topped the server
-- profile, and samples the file and line of the Lua code that called them, for
-- a few seconds. It then puts everything back and prints the top callers to the
-- console. Run it from the server console, or as a superadmin, during a heavy wave.
--
-- Code that saved one of these functions in a local before the command ran,
-- such as VJ Base's `local math_angApproach = math.ApproachAngle`, still calls
-- the original. Its calls show up under math.Approach instead, because
-- math.ApproachAngle looks math.Approach up on every call.

local SAMPLE_EVERY = 20
local MAX_SECONDS  = 60
local TOP          = 12

local this_file = debug.getinfo(1, "S").short_src

local targets = {
    { name = "math.Round",             tbl = function() return math end,  key = "Round" },
    { name = "math.Approach",          tbl = function() return math end,  key = "Approach" },
    { name = "math.ApproachAngle",     tbl = function() return math end,  key = "ApproachAngle" },
    { name = "HORDE:IsPlayerOrMinion", tbl = function() return HORDE end, key = "IsPlayerOrMinion" },
    { name = "HORDE:IsFriendlyUnit",   tbl = function() return HORDE end, key = "IsFriendlyUnit" },
    { name = "HORDE:IsEnemy",          tbl = function() return HORDE end, key = "IsEnemy" },
    { name = "HORDE:IsEnemyNPC",       tbl = function() return HORDE end, key = "IsEnemyNPC" },
    { name = "HORDE_WW.IsHostile",     tbl = function() return HORDE_WW end, key = "IsHostile" },
}

local running = false

-- The first caller outside this file and outside GMod's math extension, so a
-- call that goes through math.ApproachAngle is put on the code that called it.
local function Caller()
    for level = 3, 10 do
        local info = debug.getinfo(level, "Sl")
        if not info then break end
        local src = info.short_src
        if src ~= "[C]" and src ~= this_file
            and not string.find(src, "includes/extensions/math.lua", 1, true) then
            return src .. ":" .. tostring(info.currentline or 0)
        end
    end
    return "(unknown)"
end

local function Wrap(entry)
    local tbl = entry.tbl()
    local orig = tbl and tbl[entry.key]
    if not isfunction(orig) then return false end

    entry.orig, entry.calls, entry.callers = orig, 0, {}
    local callers = entry.callers
    entry.wrapper = function(...)
        local n = entry.calls + 1
        entry.calls = n
        if n % SAMPLE_EVERY == 0 then
            local where = Caller()
            callers[where] = (callers[where] or 0) + 1
        end
        return orig(...)
    end
    tbl[entry.key] = entry.wrapper
    return true
end

local function Unwrap(entry)
    if not entry.wrapper then return end
    local tbl = entry.tbl()
    if tbl and tbl[entry.key] == entry.wrapper then
        tbl[entry.key] = entry.orig
    end
    entry.wrapper = nil
end

local function Report(out, seconds)
    out(string.format("[Horde] Callers over %.0f seconds (one call in %d sampled):", seconds, SAMPLE_EVERY))
    for _, entry in ipairs(targets) do
        if entry.calls then
            out(string.format("  %s: %d calls, %.0f per second", entry.name, entry.calls, entry.calls / seconds))
            local list = {}
            for where, samples in pairs(entry.callers) do list[#list + 1] = { where, samples } end
            table.sort(list, function(a, b) return a[2] > b[2] end)
            local sampled = math.max(1, math.floor(entry.calls / SAMPLE_EVERY))
            for i = 1, math.min(TOP, #list) do
                out(string.format("      %5.1f%%  %s", list[i][2] / sampled * 100, list[i][1]))
            end
            entry.calls, entry.callers = nil, nil
        end
    end
end

concommand.Add("horde_profile_callers", function(ply, _, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    local function out(msg)
        print(msg)
        if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, msg) end
    end

    if running then
        out("[Horde] horde_profile_callers is already running.")
        return
    end

    local seconds = math.Clamp(tonumber(args[1]) or 10, 1, MAX_SECONDS)
    for _, entry in ipairs(targets) do Wrap(entry) end
    running = true
    out(string.format("[Horde] Counting callers for %d seconds...", seconds))

    local started = SysTime()
    timer.Create("Horde_ProfileCallers", seconds, 1, function()
        for _, entry in ipairs(targets) do Unwrap(entry) end
        running = false
        Report(out, SysTime() - started)
    end)
end, nil, "Count the callers of the functions at the top of the server profile for a few seconds.")
