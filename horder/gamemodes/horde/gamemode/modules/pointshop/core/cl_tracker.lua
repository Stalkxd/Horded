if not CLIENT then return end

-- Contract tracker: small HUD panel listing today's contracts and their progress.
-- Toggle / position: SETTINGS tab (horde_ps_tracker, horde_ps_tracker_pos).

local PS  = HORDE.Pointshop
local UI  = PS.UI
local COL = UI.Col

local function Fit(text, font, width)
    surface.SetFont(font)
    if surface.GetTextSize(text) <= width then return text end
    while #text > 1 and surface.GetTextSize(text .. "…") > width do text = PS:DropLastChar(text) end
    return text .. "…"
end

hook.Add("HUDPaint", "Horde_PS_ContractTracker", function()
    if not PS.TrackerConVar:GetBool() then return end
    if GetConVarNumber("horde_enable_client_gui") == 0 then return end
    local list = PS.Contracts and PS.Contracts.list or {}
    if #list == 0 then return end

    local S = UI.S
    local w = S(270)
    local pad = S(10)
    local row_h = S(38)

    local open = {}
    for _, c in ipairs(list) do
        if not c.claimed then open[#open + 1] = c end
    end
    local paused = PS.Contracts.paused
    local h = pad * 2 + S(22) + math.max(1, #open) * row_h + (paused and S(20) or 0)

    local x, y
    if PS.TrackerPosConVar:GetString() == "left" then
        x, y = ScreenScale(6), ScreenScale(68) -- below Horde's wave / info / status stack
    else
        x, y = ScrW() - w - ScreenScale(6), ScreenScale(6)
    end

    draw.RoundedBox(8, x, y, w, h, Color(30, 30, 30, 200))
    UI.Box(x, y + S(8), S(3), S(16), COL.red)

    -- Header: title + reset timer
    UI.Text(PS:L("tracker_title"), "HordePS_BodyBold", x + pad, y + pad, COL.white)
    UI.Text(PS:FormatTime(PS.Contracts.reset_at - RealTime()), "HordePS_Small", x + w - pad, y + pad + S(2), COL.muted, TEXT_ALIGN_RIGHT)

    local cy = y + pad + S(24)
    if #open == 0 then
        UI.Text(PS:L("tracker_all_done"), "HordePS_Small", x + pad, cy + S(10), COL.muted)
    end
    for _, c in ipairs(open) do
        local done = c.progress >= c.goal
        local name = PS:Localized(c.name) or ""
        local count = done and "✓" or (PS:FormatNumber(c.progress) .. " / " .. PS:FormatNumber(c.goal))
        surface.SetFont("HordePS_Small")
        local cw = surface.GetTextSize(count)
        UI.Text(Fit(name, "HordePS_Small", w - pad * 2 - cw - S(8)), "HordePS_Small", x + pad, cy, done and COL.white or COL.text)
        UI.Text(count, "HordePS_Small", x + w - pad, cy, done and COL.white or COL.muted, TEXT_ALIGN_RIGHT)

        local by, bw, bh = cy + S(17), w - pad * 2, S(5)
        UI.Box(x + pad, by, bw, bh, Color(0, 0, 0, 160))
        local frac = math.Clamp(c.progress / math.max(c.goal, 1), 0, 1)
        if frac > 0 then UI.Box(x + pad, by, math.max(S(2), bw * frac), bh, done and COL.white or COL.red) end
        if done then
            UI.Text(PS:L("tracker_claim"), "HordePS_Small", x + pad, by + S(6), COL.red_light)
        end
        cy = cy + row_h
    end

    if paused then
        UI.Text(Fit(PS:L(paused), "HordePS_Small", w - pad * 2), "HordePS_Small", x + pad, cy, COL.red_light)
    end
end)
