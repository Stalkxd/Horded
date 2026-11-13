-- Horde killfeed (client side). Replaces the GMod death notices and looks like them (same
-- font, icon in the middle, no background), with these changes: at most 3 lines, so a wave
-- of zombies dying doesn't fill the screen; players white, enemies red; and the player who
-- assisted is shown after the killer with a "+".
local MAX_LINES = 3

local COLOR_PLAYER = Color(255, 255, 255)
local COLOR_ENEMY = Color(250, 50, 50)
local FONT = "ChatFont"

local lines = {}

-- Turn the GMod notices off. The engine still sends them; they just aren't drawn.
local function DisableDefault(gm)
    if not gm then return end
    gm.AddDeathNotice = function() end
    gm.DrawDeathNotice = function() end
end
DisableDefault(GM)
DisableDefault(GAMEMODE)
hook.Add("Initialize", "Horde_KillfeedDisableDefault", function() DisableDefault(GAMEMODE) end)

local function Phrase(name)
    if string.sub(name, 1, 1) == "#" then return language.GetPhrase(string.sub(name, 2)) end
    return name
end

net.Receive("Horde_Killfeed", function()
    local line = {
        killer = net.ReadString(),
        killer_player = net.ReadBool(),
        assist = net.ReadString(),
        icon = net.ReadString(),
        victim = net.ReadString(),
        victim_player = net.ReadBool(),
        time = CurTime(),
    }
    line.killer = Phrase(line.killer)
    line.victim = Phrase(line.victim)
    if killicon.Exists and not killicon.Exists(line.icon) then line.icon = "default" end

    lines[#lines + 1] = line
    while #lines > MAX_LINES do table.remove(lines, 1) end
end)

local cvar_time = GetConVar("hud_deathnotice_time")

-- Same layout as GMod: icon centered on x, killer to the left, victim to the right
local function DrawLine(x, y, line, lifetime)
    local w, h = killicon.GetSize(line.icon)
    if not w or not h then return y end

    local alpha = math.Clamp((line.time + lifetime - CurTime()) * 255, 0, 255)
    local white = ColorAlpha(COLOR_PLAYER, alpha)

    -- Lowered a bit so the icon sits level with the names
    killicon.Draw(x, y + math.floor(h * 0.3), line.icon, alpha)

    local mid = y + h / 2
    local left = x - w / 2 - 16
    if line.assist ~= "" then
        surface.SetFont(FONT)
        draw.SimpleText(line.assist, FONT, left, mid, white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        left = left - surface.GetTextSize(line.assist)
        draw.SimpleText(" + ", FONT, left, mid, white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        left = left - surface.GetTextSize(" + ")
    end
    if line.killer ~= "" then
        draw.SimpleText(line.killer, FONT, left, mid,
            line.killer_player and white or ColorAlpha(COLOR_ENEMY, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText(line.victim, FONT, x + w / 2 + 16, mid,
        line.victim_player and white or ColorAlpha(COLOR_ENEMY, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    return math.ceil(y + h * 0.85)
end

hook.Add("HUDPaint", "Horde_Killfeed", function()
    if #lines == 0 or GetConVarNumber("cl_drawhud") == 0 then return end
    local lifetime = cvar_time and cvar_time:GetFloat() or 6
    local now = CurTime()
    for i = #lines, 1, -1 do
        if now - lines[i].time > lifetime then table.remove(lines, i) end
    end

    local x, y = math.floor(ScrW() * 0.85), math.floor(ScrH() * 0.04)
    for _, line in ipairs(lines) do
        y = DrawLine(x, y, line, lifetime)
    end
end)
