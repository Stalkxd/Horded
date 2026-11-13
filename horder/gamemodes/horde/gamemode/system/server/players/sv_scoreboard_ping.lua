-- The engine only refreshes other players' ping on clients every couple of
-- seconds. While a player has the scoreboard open, send them everyone's ping
-- from the server several times a second instead.
util.AddNetworkString("Horde_ScoreboardPingWatch")
util.AddNetworkString("Horde_ScoreboardPing")

local PING_INTERVAL = 0.25
local watchers = {}

net.Receive("Horde_ScoreboardPingWatch", function(_, ply)
    watchers[ply] = net.ReadBool() or nil
end)

hook.Add("PlayerDisconnected", "Horde_ScoreboardPing", function(ply)
    watchers[ply] = nil
end)

timer.Create("Horde_ScoreboardPing", PING_INTERVAL, 0, function()
    if not next(watchers) then return end

    local targets = {}
    for ply in pairs(watchers) do
        if IsValid(ply) then targets[#targets + 1] = ply else watchers[ply] = nil end
    end
    if #targets == 0 then return end

    local humans = player.GetHumans()
    net.Start("Horde_ScoreboardPing", true)
        net.WriteUInt(#humans, 8)
        for _, p in ipairs(humans) do
            net.WriteUInt(p:EntIndex(), 8)
            net.WriteUInt(math.min(p:Ping(), 1023), 10)
        end
    net.Send(targets)
end)
