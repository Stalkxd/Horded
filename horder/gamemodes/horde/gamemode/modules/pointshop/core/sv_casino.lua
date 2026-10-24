if not SERVER then return end

local PS = HORDE.Pointshop
local C  = PS.Config

---------------------------------------------------------------------------
-- Casino (slot machine). The server checks the bet, rolls the reels and pays out;
-- the client only plays the animation for the result it is sent.
---------------------------------------------------------------------------

local function log(msg)
    MsgC(Color(220, 40, 40), "[Horde Pointshop] ", color_white, msg .. "\n")
end

local function RollSymbol(syms, total)
    local r = math.random() * total
    for _, s in ipairs(syms) do
        r = r - s.weight
        if r < 0 then return s.id end
    end
    return syms[#syms].id
end

function PS:CasinoSpin(ply, bet)
    local d = self:Data(ply)
    if not C.CasinoEnabled then return false, "err.casino_off" end
    if not d.loaded then return false, "err.not_loaded" end
    local lo, hi = math.floor(tonumber(C.CasinoMinBet) or 1), math.floor(tonumber(C.CasinoMaxBet) or 0)
    if not bet or bet < lo or bet > hi then
        return false, "err.casino_bet", { self:FormatNumber(lo), self:FormatNumber(hi) }
    end
    if d.skulls < bet then return false, "err.not_enough", { self:FormatNumber(bet - d.skulls) } end

    local syms = self:CasinoSymbols()
    local total = 0
    for _, s in ipairs(syms) do total = total + s.weight end
    if total <= 0 then return false, "err.casino_off" end

    local reels = { RollSymbol(syms, total), RollSymbol(syms, total), RollSymbol(syms, total) }
    local mult, combo = self:CasinoEvaluate(reels)
    local win = math.max(0, math.floor(bet * mult))

    d.skulls = math.Clamp(d.skulls - bet + win, 0, 2000000000)
    self:SaveSkulls(ply)
    return true, reels, win, combo, mult
end

net.Receive("Horde_PS_Spin", function(_, ply)
    if not IsValid(ply) or PS.Throttle(ply, "spin", 0.5) then return end
    local bet = net.ReadUInt(32)
    local ok, reels, win, combo, mult = PS:CasinoSpin(ply, bet)
    if not ok then
        PS:SendResult(ply, false, reels, win)
        return
    end

    net.Start("Horde_PS_SpinResult")
    for i = 1, 3 do net.WriteString(reels[i]) end
    net.WriteUInt(bet, 32)
    net.WriteUInt(win, 32)
    net.WriteString(combo or "")
    net.Send(ply)
    PS:SyncPlayer(ply)

    local announce = tonumber(C.CasinoAnnounce) or 0
    if announce > 0 and mult >= announce then
        log(ply:Nick() .. " (" .. ply:SteamID() .. ") won " .. win .. " in the casino (bet " .. bet .. ")")
        -- Delayed so the winner sees the reels stop before the announcement.
        local nick, amount = ply:Nick(), PS:FormatNumber(win)
        timer.Simple(2.5, function()
            for _, p in ipairs(player.GetHumans()) do PS:Notify(p, "n.casino_big", { nick, amount }) end
        end)
    end
    hook.Run("Horde_PS_CasinoSpin", ply, bet, win, reels)
end)
