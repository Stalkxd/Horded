if not CLIENT then return end

local PS  = HORDE.Pointshop
local C   = PS.Config
local UI  = PS.UI
local COL = UI.Col
local S   = UI.S

local function L(...) return PS:L(...) end

PS.CasinoHistory = PS.CasinoHistory or {}

---------------------------------------------------------------------------
-- Symbols
---------------------------------------------------------------------------

local icon_cache = {}
local function SymbolIcon(sym)
    if not sym or not sym.icon then return nil end
    local mat = icon_cache[sym.icon]
    if mat == nil then
        mat = Material(sym.icon, "smooth mips")
        if mat:IsError() then mat = false end
        icon_cache[sym.icon] = mat
    end
    return mat or nil
end

local function SymbolName(sym)
    if not sym then return "?" end
    if PS:LangId() == "ru" and sym.name_ru then return sym.name_ru end
    return sym.name or sym.id
end

-- Draws a symbol centred on (x, y).
local function DrawSymbol(id, x, y, size, col)
    local sym = PS:CasinoSymbol(id)
    local mat = SymbolIcon(sym)
    if mat then
        surface.SetMaterial(mat)
        surface.SetDrawColor(col or COL.white)
        surface.DrawTexturedRect(x - size / 2, y - size / 2, size, size)
    else
        UI.Text(PS:Upper(SymbolName(sym)), "HordePS_BodyBold", x, y, col or COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function RandomSymbol()
    local syms = PS:CasinoSymbols()
    local total = 0
    for _, s in ipairs(syms) do total = total + s.weight end
    local r = math.random() * total
    for _, s in ipairs(syms) do
        r = r - s.weight
        if r < 0 then return s.id end
    end
    return syms[#syms] and syms[#syms].id or "?"
end

local function ComboText(key)
    if not key then return "" end
    local sym = key:match("^three:(.+)$")
    if sym then return L("casino_three", SymbolName(PS:CasinoSymbol(sym))) end
    local special = SymbolName(PS:CasinoSymbol(C.CasinoSpecial))
    if key == "special2" then return L("casino_special2", special) end
    if key == "special1" then return L("casino_special1", special) end
    return key
end

---------------------------------------------------------------------------
-- Spin state (kept in PS.CasinoSpin so it survives a menu rebuild)
---------------------------------------------------------------------------

local STRIP_LEN = { 16, 22, 28 }

-- Fills spin.strips: the symbols each reel scrolls through, ending on the result.
-- Layout per reel: { filler, previous centre, random..., result, filler }.
local function EnsureStrips(spin)
    if spin.strips then return end
    local prev = PS.CasinoLastReels or {}
    spin.strips = {}
    for i = 1, 3 do
        local strip = { RandomSymbol(), prev[i] or RandomSymbol() }
        for _ = 1, STRIP_LEN[i] do strip[#strip + 1] = RandomSymbol() end
        strip[#strip + 1] = spin.reels[i]
        strip[#strip + 1] = RandomSymbol()
        spin.strips[i] = strip
    end
    spin.stopped = {}
end

local function Busy()
    if PS.CasinoWaiting and RealTime() - PS.CasinoWaiting < 3 then return true end
    return not PS:CasinoRevealed()
end

-- Reel position (1-based strip index, fractional) for reel i at the current time.
local function ReelPos(spin, i)
    local strip = spin.strips[i]
    local first, last = 2, #strip - 1
    local p = math.Clamp((RealTime() - spin.start) / PS.CasinoReelStops[i], 0, 1)
    local eased = 1 - (1 - p) ^ 3
    return first + (last - first) * eased, p >= 1
end

-- Reels that take part in the win, for highlighting.
local function WinningReels(spin)
    local set = {}
    if not spin or not spin.combo then return set end
    if spin.combo:match("^three:") then
        set[1], set[2], set[3] = true, true, true
    else
        for i = 1, 3 do if spin.reels[i] == C.CasinoSpecial then set[i] = true end end
    end
    return set
end

---------------------------------------------------------------------------
-- Tab
---------------------------------------------------------------------------

local function Card(parent, title, sub)
    local p = vgui.Create("DPanel", parent)
    p.Paint = function(_, w, h)
        UI.GradV(0, 0, w, h, COL.panel, COL.bg2)
        UI.Outline(0, 0, w, h, COL.border)
        if title then UI.Heading(title, S(16), S(14), w - S(32), sub and sub() or nil) end
    end
    return p
end

function PS.BuildCasino(root)
    local W, H = root:GetSize()
    local pad = S(16)
    local ST = PS.MenuState

    if not C.CasinoEnabled then
        root.Paint = function(_, w, h)
            UI.Text(L("casino_off"), "HordePS_Header", w / 2, h / 2, COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        return
    end

    local bets = PS:CasinoBets()
    if not table.HasValue(bets, ST.casino_bet) then ST.casino_bet = bets[math.min(2, #bets)] or bets[1] end

    local lw = math.floor((W - pad * 3) * 0.6)
    local rw = W - pad * 3 - lw

    ---------------------------------------------------------------- machine
    local machine = Card(root, L("casino_title"), function()
        return L("casino_sub", PS:FormatNumber(C.CasinoMinBet), PS:FormatNumber(C.CasinoMaxBet))
    end)
    machine:SetPos(pad, pad)
    machine:SetSize(lw, H - pad * 2)
    local mh = machine:GetTall()

    local controlsH = S(150)
    local bannerH = S(56)
    local top = S(56)
    local reelsH = math.min(mh - top - controlsH - bannerH - S(24), math.floor((lw - S(64)) / 3 * 1.5))
    local cell = math.floor(reelsH / 3)
    reelsH = cell * 3
    local gap = S(12)
    local reelW = math.min(math.floor((lw - S(48) - gap * 2) / 3), math.floor(cell * 1.4))
    local rx = math.floor((lw - (reelW * 3 + gap * 2)) / 2)

    -- Frame behind the reels with the payline markers.
    local frame = vgui.Create("DPanel", machine)
    frame:SetPos(rx - S(10), top - S(4))
    frame:SetSize(reelW * 3 + gap * 2 + S(20), reelsH + S(16))
    frame.Paint = function(_, w, h)
        UI.Box(0, 0, w, h, Color(10, 10, 10))
        UI.Outline(0, 0, w, h, COL.red_dark, 2)
        local cy = S(8) + cell * 1.5
        draw.NoTexture()
        surface.SetDrawColor(COL.red)
        surface.DrawPoly({ { x = 0, y = cy - S(8) }, { x = S(8), y = cy }, { x = 0, y = cy + S(8) } })
        surface.DrawPoly({ { x = w, y = cy - S(8) }, { x = w, y = cy + S(8) }, { x = w - S(8), y = cy } })
    end

    for i = 1, 3 do
        local reel = vgui.Create("DPanel", machine)
        reel:SetPos(rx + (i - 1) * (reelW + gap), top + S(4))
        reel:SetSize(reelW, reelsH)
        reel.Paint = function(_, w, h)
            -- Drum: brighter in the middle, darker at the top and bottom edges.
            UI.GradV(0, 0, w, h / 2, Color(14, 14, 14), Color(46, 46, 46))
            UI.GradV(0, h / 2, w, h / 2, Color(46, 46, 46), Color(14, 14, 14))

            local spin = PS.CasinoSpin
            local size = math.floor(cell * 0.62)
            if spin then
                EnsureStrips(spin)
                local strip = spin.strips[i]
                local pos, stopped = ReelPos(spin, i)
                local base = math.floor(pos)
                for j = base - 1, base + 2 do
                    local id = strip[j]
                    if id then
                        local y = h / 2 + (j - pos) * cell
                        local win = stopped and PS:CasinoRevealed() and j == #strip - 1 and WinningReels(spin)[i]
                        if win then
                            local pulse = 0.5 + 0.5 * math.sin(RealTime() * 6)
                            UI.Box(S(4), y - cell / 2 + S(4), w - S(8), cell - S(8), Color(200, 28, 28, 60 + 60 * pulse))
                        end
                        DrawSymbol(id, w / 2, y, size, (j == math.floor(pos + 0.5)) and COL.white or Color(150, 150, 150))
                    end
                end
            else
                local last = PS.CasinoLastReels
                for r = -1, 1 do
                    local id = last and r == 0 and last[i] or nil
                    if not id then
                        reel.Idle = reel.Idle or { RandomSymbol(), RandomSymbol(), RandomSymbol() }
                        id = reel.Idle[r + 2]
                    end
                    DrawSymbol(id, w / 2, h / 2 + r * cell, size, r == 0 and COL.white or Color(150, 150, 150))
                end
            end

            -- Glass shading so the top and bottom rows fade out.
            UI.GradV(0, 0, w, cell * 0.9, Color(0, 0, 0, 200), Color(0, 0, 0, 0))
            UI.GradV(0, h - cell * 0.9, w, cell * 0.9, Color(0, 0, 0, 0), Color(0, 0, 0, 200))
            UI.Box(0, h / 2 - cell / 2, w, 1, ColorAlpha(COL.red, 90))
            UI.Box(0, h / 2 + cell / 2, w, 1, ColorAlpha(COL.red, 90))
            UI.Outline(0, 0, w, h, COL.border)
        end
    end

    -- Result banner
    local banner = vgui.Create("DPanel", machine)
    banner:SetPos(S(16), top + reelsH + S(24))
    banner:SetSize(lw - S(32), bannerH)
    banner.Paint = function(_, w, h)
        local spin = PS.CasinoSpin
        if Busy() then
            local dots = string.rep(".", math.floor(RealTime() * 3) % 4)
            UI.Text(PS:Upper(L("casino_spinning")) .. dots, "HordePS_Header", w / 2, h / 2, COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif spin and spin.win > 0 and spin.win == spin.bet then
            UI.Text(L("casino_push"), "HordePS_Header", w / 2, h / 2 - S(8), COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            UI.Text(ComboText(spin.combo), "HordePS_Small", w / 2, h - S(6), COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        elseif spin and spin.win > 0 then
            local big = (tonumber(C.CasinoAnnounce) or 0) > 0 and spin.win >= spin.bet * C.CasinoAnnounce
            local pulse = 0.5 + 0.5 * math.sin(RealTime() * 5)
            UI.GradH(0, 0, w / 2, h, Color(0, 0, 0, 0), Color(150, 18, 18, 90 + 60 * pulse))
            UI.GradH(w / 2, 0, w / 2, h, Color(150, 18, 18, 90 + 60 * pulse), Color(0, 0, 0, 0))
            local title = big and (PS:Upper(L("casino_jackpot")) .. "  ") or ""
            UI.TextShadow(title .. L("casino_win", PS:FormatNumber(spin.win)), "HordePS_Big", w / 2, h / 2 - S(8), COL.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            UI.Text(ComboText(spin.combo), "HordePS_Small", w / 2, h - S(6), COL.red_light, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        elseif spin then
            UI.Text(L("casino_lose"), "HordePS_Header", w / 2, h / 2, COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            UI.Text(L("casino_hint"), "HordePS_Body", w / 2, h / 2, COL.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- Bet buttons
    local controls = vgui.Create("DPanel", machine)
    controls:SetPos(S(16), mh - controlsH - S(12))
    controls:SetSize(lw - S(32), controlsH)
    controls.Paint = function(_, w)
        UI.Text(PS:Upper(L("casino_bet")), "HordePS_Small", 0, 0, COL.muted)
    end
    local cw = controls:GetWide()
    local bgap = S(6)
    local bw = math.floor((cw - bgap * (#bets - 1)) / math.max(1, #bets))
    for k, amount in ipairs(bets) do
        local b = vgui.Create("DButton", controls)
        b:SetText("")
        b:SetPos((k - 1) * (bw + bgap), S(20))
        b:SetSize(bw, S(40))
        b.Paint = function(s, w, h)
            local active = ST.casino_bet == amount
            local afford = PS.Player.skulls >= amount
            if active then
                UI.GradV(0, 0, w, h, COL.red, COL.red_dark)
            else
                UI.GradV(0, 0, w, h, s:IsHovered() and COL.slot_hi or COL.panel2, COL.bg2)
            end
            UI.Outline(0, 0, w, h, active and COL.red_light or COL.border)
            UI.Price(amount, "HordePS_BodyBold", w / 2, h / 2, afford and COL.white or COL.dim, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function()
            if Busy() then return end
            PS:Sound("ui/buttonclick.wav")
            ST.casino_bet = amount
        end
    end

    local spin_b = UI.Button(controls, L("casino_spin"), "red", function()
        if Busy() or not ST.casino_bet then return end
        if PS.CasinoSpin then PS.CasinoLastReels = PS.CasinoSpin.reels end
        PS:Sound("ambient/levels/labs/coinslot1.wav")
        PS:RequestSpin(ST.casino_bet)
    end)
    spin_b:SetLabelFont("HordePS_Header")
    spin_b:SetPos(0, S(72))
    spin_b:SetSize(cw, S(64))
    spin_b.Think = function(s)
        local bet = ST.casino_bet or 0
        local ok = PS.Player.loaded and bet > 0 and PS.Player.skulls >= bet and not Busy()
        s:SetEnabled(ok)
        if Busy() then
            s:SetLabel(L("casino_spinning"))
        elseif PS.Player.skulls < bet then
            s:SetLabel(L("err.not_enough", PS:FormatNumber(bet - PS.Player.skulls)))
        else
            s:SetLabel(L("casino_spin") .. "  ·  " .. PS:FormatNumber(bet) .. " " .. PS:Currency())
        end
    end

    -- Sounds and history as the reels stop.
    machine.Think = function()
        local spin = PS.CasinoSpin
        if not spin or not spin.strips or spin.logged then return end
        for i = 1, 3 do
            local _, stopped = ReelPos(spin, i)
            if stopped and not spin.stopped[i] then
                spin.stopped[i] = true
                PS:Sound("buttons/lightswitch2.wav")
            end
        end
        if PS:CasinoRevealed() then
            spin.logged = true
            if spin.win > 0 then
                local big = (tonumber(C.CasinoAnnounce) or 0) > 0 and spin.win >= spin.bet * C.CasinoAnnounce
                PS:Sound(big and "ambient/alarms/warningbell1.wav" or "items/suitchargeok1.wav")
            else
                PS:Sound("buttons/button10.wav")
            end
            table.insert(PS.CasinoHistory, 1, { reels = spin.reels, bet = spin.bet, win = spin.win })
            while #PS.CasinoHistory > 12 do table.remove(PS.CasinoHistory) end
        end
    end

    ---------------------------------------------------------------- paytable
    local combos, rtp, hit = PS:CasinoPaytable()
    local histH = math.floor((H - pad * 2) * 0.34)

    local pay = Card(root, L("casino_paytable"))
    pay:SetPos(pad * 2 + lw, pad)
    pay:SetSize(rw, H - pad * 3 - histH)
    local pw, ph = pay:GetSize()
    local pfoot = S(40)
    local pp = pay.Paint
    pay.Paint = function(s, w, h)
        pp(s, w, h)
        UI.Box(S(16), h - pfoot, w - S(32), 1, COL.border)
        UI.Text(L("casino_rtp", string.format("%.1f", rtp * 100)) .. "  ·  " .. L("casino_hit", string.format("%.1f", hit * 100)), "HordePS_Small", w / 2, h - pfoot / 2, COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local list = UI.Scroll(pay)
    list:SetPos(S(12), S(52))
    list:SetSize(pw - S(24), ph - S(52) - pfoot - S(4))
    local rowH = S(48)
    for _, combo in ipairs(combos) do
        local row = list:Add("DPanel")
        row:Dock(TOP)
        row:DockMargin(0, 0, S(4), S(4))
        row:SetTall(rowH)
        row.Paint = function(_, w, h)
            UI.GradH(0, 0, w, h, COL.panel2, COL.bg2)
            local isize = h - S(14)
            local x = S(8) + isize / 2
            local icons
            if combo.symbol then
                icons = { combo.symbol, combo.symbol, combo.symbol }
            elseif combo.key == "special2" then
                icons = { C.CasinoSpecial, C.CasinoSpecial, false }
            else
                icons = { C.CasinoSpecial, false, false }
            end
            for _, id in ipairs(icons) do
                if id then
                    DrawSymbol(id, x, h / 2, isize)
                else
                    UI.Text("?", "HordePS_Header", x, h / 2, COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                x = x + isize + S(4)
            end
            local tx = S(16) + (isize + S(4)) * 3
            UI.Text(ComboText(combo.key), "HordePS_Body", tx, h / 2 - S(9), COL.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            UI.Text(L("casino_odds", PS:FormatNumber(math.max(1, math.Round(1 / combo.p)))), "HordePS_Small", tx, h / 2 + S(10), COL.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local rare = combo.mult >= 100
            UI.Text("×" .. PS:FormatNumber(combo.mult), "HordePS_Price", w - S(12), h / 2, rare and COL.red_light or COL.white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    ---------------------------------------------------------------- history
    local hist = Card(root, L("casino_history"))
    hist:SetPos(pad * 2 + lw, H - pad - histH)
    hist:SetSize(rw, histH)
    local hp = hist.Paint
    hist.Paint = function(s, w, h)
        hp(s, w, h)
        local y = S(54)
        local lineH = S(26)
        local shown = 0
        for _, e in ipairs(PS.CasinoHistory) do
            if y + lineH > h - S(8) then break end
            local isize = S(20)
            for i = 1, 3 do DrawSymbol(e.reels[i], S(16) + isize / 2 + (i - 1) * (isize + S(4)), y + lineH / 2, isize) end
            UI.Price(e.bet, "HordePS_Small", S(110), y + lineH / 2, COL.muted)
            local delta = e.win - e.bet
            local txt = (delta >= 0 and "+" or "−") .. PS:FormatNumber(math.abs(delta))
            UI.Text(txt, "HordePS_BodyBold", w - S(16), y + lineH / 2, delta > 0 and COL.red_light or (delta == 0 and COL.text or COL.dim), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            y = y + lineH
            shown = shown + 1
        end
        if shown == 0 then
            UI.Text(L("casino_none"), "HordePS_Small", w / 2, (h + S(40)) / 2, COL.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    root.Refresh = function() end
end
