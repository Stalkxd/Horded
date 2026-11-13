-- Horde killfeed (client side). Replaces the GMod death notices with a short list in the
-- top right corner: at most 3 lines, so a wave of zombies dying doesn't fill the screen.
-- Players are white, enemies red, and the player who assisted is shown after a "+".
local MAX_LINES = 3
local LIFETIME = 6
local FADE = 0.5
local PAD_X, PAD_Y, GAP = 8, 4, 6

local COLOR_PLAYER = Color(255, 255, 255)
local COLOR_ENEMY = Color(255, 60, 60)
local COLOR_PLUS = Color(180, 180, 180)
local COLOR_BG = Color(0, 0, 0, 160)

surface.CreateFont("Horde_Killfeed", { font = "Arial", size = 18, weight = 700, extended = true })

local lines = {}

-- Turn the GMod notices off. The engine still sends them; they just aren't drawn.
local function DisableDefault(gm)
    if not gm then return end
    gm.AddDeathNotice = function() end
    gm.DrawDeathNotice = function() end
end
DisableDefault(GM)
hook.Add("Initialize", "Horde_KillfeedDisableDefault", function() DisableDefault(GAMEMODE) end)
DisableDefault(GAMEMODE)

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

local function TextWidth(text)
    if text == "" then return 0 end
    return (surface.GetTextSize(text))
end

hook.Add("HUDPaint", "Horde_Killfeed", function()
    if #lines == 0 then return end
    local now = CurTime()
    for i = #lines, 1, -1 do
        if now - lines[i].time > LIFETIME then table.remove(lines, i) end
    end

    surface.SetFont("Horde_Killfeed")
    local _, text_h = surface.GetTextSize("W")
    local x_right = ScrW() - 16
    local y = ScrH() * 0.04

    for _, line in ipairs(lines) do
        local alpha = math.Clamp((LIFETIME - (now - line.time)) / FADE, 0, 1)
        local icon_w, icon_h = killicon.GetSize(line.icon)
        icon_w, icon_h = icon_w or 32, icon_h or 32
        local row_h = math.max(text_h, icon_h) + PAD_Y * 2

        local killer_w = TextWidth(line.killer)
        local assist_text = line.assist ~= "" and (" + " .. line.assist) or ""
        local assist_w = TextWidth(assist_text)
        local victim_w = TextWidth(line.victim)
        local width = PAD_X * 2 + icon_w + victim_w + GAP
        if killer_w > 0 or assist_w > 0 then width = width + killer_w + assist_w + GAP end

        local x = x_right - width
        draw.RoundedBox(4, x, y, width, row_h, ColorAlpha(COLOR_BG, COLOR_BG.a * alpha))

        local text_y = y + (row_h - text_h) / 2
        local cx = x + PAD_X
        if killer_w > 0 then
            draw.SimpleText(line.killer, "Horde_Killfeed", cx, text_y,
                ColorAlpha(line.killer_player and COLOR_PLAYER or COLOR_ENEMY, 255 * alpha))
            cx = cx + killer_w
        end
        if assist_w > 0 then
            surface.SetFont("Horde_Killfeed")
            local plus_w = TextWidth(" + ")
            draw.SimpleText(" + ", "Horde_Killfeed", cx, text_y, ColorAlpha(COLOR_PLUS, 255 * alpha))
            draw.SimpleText(line.assist, "Horde_Killfeed", cx + plus_w, text_y, ColorAlpha(COLOR_PLAYER, 255 * alpha))
            cx = cx + assist_w
        end
        if killer_w > 0 or assist_w > 0 then cx = cx + GAP end

        killicon.Draw(cx + icon_w / 2, y + (row_h - icon_h) / 2, line.icon, 255 * alpha)
        cx = cx + icon_w + GAP

        draw.SimpleText(line.victim, "Horde_Killfeed", cx, text_y,
            ColorAlpha(line.victim_player and COLOR_PLAYER or COLOR_ENEMY, 255 * alpha))

        y = y + row_h + 4
    end
end)
