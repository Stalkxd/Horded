-- Anti-AFK client side: warning countdown, taskbar flash, AFK banner and chat lines.
-- Server side: system/server/players/sv_afk.lua

local AFK_WARN     = 1
local AFK_CANCEL   = 2
local AFK_MOVED    = 3
local AFK_RETURNED = 4
local AFK_ANNOUNCE = 5

local warn_until    -- CurTime() when the move happens, while a warning is up
local is_afk = false
local can_return = true
local next_flash = 0

local COL_TAG  = Color(255, 170, 0)
local COL_TEXT = Color(230, 230, 230)

surface.CreateFont("Horde_AFKBig", { font = "Trebuchet MS", size = ScreenScale(16), weight = 800, antialias = true })
surface.CreateFont("Horde_AFKSmall", { font = "Trebuchet MS", size = ScreenScale(9), weight = 600, antialias = true })

-- Text in the player's language (modules/languages/*.lua), English if a key is missing.
local function T(key, ...)
    local ok, text = pcall(translate.Format, key, ...)
    if ok and isstring(text) then return text end
    return key
end

local function Flash()
    -- Blinks the Garry's Mod icon on the Windows taskbar while the game is not focused.
    if system.FlashWindow and not system.HasFocus() then
        system.FlashWindow()
    end
end

net.Receive("Horde_AFK", function()
    local kind = net.ReadUInt(3)

    if kind == AFK_WARN then
        local secs = net.ReadUInt(16)
        warn_until = CurTime() + secs
        next_flash = 0
        surface.PlaySound("buttons/blip1.wav")
        chat.AddText(COL_TAG, "[AFK] ", COL_TEXT, T("AFK_Chat_Warning", secs))
        Flash()

    elseif kind == AFK_CANCEL then
        if warn_until then
            chat.AddText(COL_TAG, "[AFK] ", COL_TEXT, T("AFK_Chat_WelcomeBack"))
        end
        warn_until = nil

    elseif kind == AFK_MOVED then
        can_return = net.ReadBool()
        warn_until = nil
        is_afk = true
        Flash()
        if can_return then
            chat.AddText(COL_TAG, "[AFK] ", COL_TEXT, T("AFK_Chat_SpectatingBack"))
        else
            chat.AddText(COL_TAG, "[AFK] ", COL_TEXT, T("AFK_Chat_Spectating"))
        end

    elseif kind == AFK_RETURNED then
        is_afk = false
        warn_until = nil

    elseif kind == AFK_ANNOUNCE then
        local ply = net.ReadEntity()
        local key = net.ReadString()
        local num = net.ReadUInt(16)
        local name = IsValid(ply) and ply:Nick() or T("AFK_Chat_SomePlayer")
        chat.AddText(COL_TAG, "[AFK] ", team.GetColor(IsValid(ply) and ply:Team() or TEAM_UNASSIGNED), name, COL_TEXT, " " .. T(key, num))
    end
end)

hook.Add("HUDPaint", "Horde_AFKWarning", function()
    local w, h = ScrW(), ScrH()

    if warn_until then
        local left = math.max(0, math.ceil(warn_until - CurTime()))
        -- Keep the taskbar icon blinking for as long as the warning is up.
        if CurTime() >= next_flash then
            next_flash = CurTime() + 3
            Flash()
        end
        local pulse = 155 + math.abs(math.sin(CurTime() * 4)) * 100
        draw.SimpleTextOutlined(T("AFK_HUD_Title"), "Horde_AFKBig", w / 2, h * 0.3,
            Color(255, 170, 0, pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
        draw.SimpleTextOutlined(T("AFK_HUD_Countdown", left), "Horde_AFKSmall",
            w / 2, h * 0.3 + ScreenScale(16), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        return
    end

    if is_afk then
        local text = can_return and T("AFK_HUD_BannerBack") or T("AFK_HUD_Banner")
        draw.SimpleTextOutlined(text, "Horde_AFKSmall", w / 2, h * 0.12,
            Color(255, 170, 0, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end
end)
