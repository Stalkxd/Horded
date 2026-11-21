-- Anti-AFK.
--
-- A player who gives no input for horde_afk_time seconds gets a warning (chat announcement,
-- on-screen countdown and a flashing taskbar icon). If they stay idle for horde_afk_grace more
-- seconds they are moved to the spectators. Typing !afk does the same thing right away.
--
-- An AFK player is a normal spectator (roaming / chase cam, F light) that can never be brought
-- back by the game: wave end, the break, the Soul Rebooter, Watchtower beacons and admin respawns
-- all skip them. They also stop counting as players for ready-up, skip and map votes and enemy
-- scaling, so they cannot hold the lobby or the trader break hostage.
--
-- With horde_afk_allow_return 1 the player can type !back to leave AFK; they then come back
-- like any dead player (right away in the lobby or a break, at the end of the wave otherwise).
-- Reconnecting also clears AFK, and a reconnect mid-wave waits for the next wave as usual.

util.AddNetworkString("Horde_AFK")

local cv_enabled = CreateConVar("horde_afk_enabled", 1, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Move players who stop playing to the spectators (1 = on, 0 = off).")
local cv_time = CreateConVar("horde_afk_time", 600, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Seconds without any input before a player is warned that they are AFK.", 30)
local cv_grace = CreateConVar("horde_afk_grace", 30, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Seconds after the AFK warning before the player is moved to the spectators.", 5)
local cv_return = CreateConVar("horde_afk_allow_return", 1, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Allow AFK players to type !back to rejoin (1) or keep them spectating until they reconnect (0).")
local cv_admin_immune = CreateConVar("horde_afk_admin_immune", 0, { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE },
    "Admins are never moved to the spectators for being idle (they can still use !afk).")

-- Net message types (client: system/client/core/cl_afk.lua)
local AFK_WARN     = 1 -- you will be moved in N seconds
local AFK_CANCEL   = 2 -- warning cleared, you are active again
local AFK_MOVED    = 3 -- you are now an AFK spectator
local AFK_RETURNED = 4 -- you left AFK
local AFK_ANNOUNCE = 5 -- broadcast chat line about someone

local AFK_TEAM_NORMAL = TEAM_UNASSIGNED

-- ---------------------------------------------------------------------------------------
-- Helpers used by the rest of the gamemode
-- ---------------------------------------------------------------------------------------

function HORDE:IsAFK(ply)
    return IsValid(ply) and ply.Horde_AFK == true
end

-- Every player that still takes part in the game (not AFK).
function HORDE:GetActivePlayers()
    local list = {}
    for _, ply in ipairs(player.GetAll()) do
        if not ply.Horde_AFK then list[#list + 1] = ply end
    end
    return list
end

function HORDE:CountActivePlayers()
    return #HORDE:GetActivePlayers()
end

local function SyncReady()
    net.Start("Horde_PlayerReadySync")
    local sync = {}
    for p, status in pairs(HORDE.player_ready) do
        if IsValid(p) then sync[p:SteamID()] = status end
    end
    net.WriteTable(sync)
    net.Broadcast()
end

-- Text shown to one player, in that player's language (modules/languages/*.lua).
local function T(ply, key, ...)
    local ok, text = pcall(translate.ClientFormat, ply, key, ...)
    if ok and isstring(text) then return text end
    return key
end

-- Chat line about someone. Only the translation key and the number go over the wire, so every
-- client reads it in their own language (system/client/core/cl_afk.lua).
local function Announce(ply, key, num)
    net.Start("Horde_AFK")
    net.WriteUInt(AFK_ANNOUNCE, 3)
    net.WriteEntity(ply)
    net.WriteString(key)
    net.WriteUInt(math.Clamp(math.floor(num or 0), 0, 65535), 16)
    net.Broadcast()
end

local function MarkActive(ply)
    ply.Horde_AFKLastActive = CurTime()
    if ply.Horde_AFKWarnedAt then
        ply.Horde_AFKWarnedAt = nil
        net.Start("Horde_AFK")
        net.WriteUInt(AFK_CANCEL, 3)
        net.Send(ply)
    end
end

-- ---------------------------------------------------------------------------------------
-- Respawn lock. Every Horde respawn goes through Player:Spawn, so blocking it here covers
-- wave end, the break, beacons, the Soul Rebooter, admin commands and anything added later.
-- ---------------------------------------------------------------------------------------

local plymeta = FindMetaTable("Player")
local entmeta = FindMetaTable("Entity")
if not plymeta._Horde_AFKSpawnWrapped then
    plymeta._Horde_AFKSpawnWrapped = true
    local base_spawn = rawget(plymeta, "Spawn") or entmeta.Spawn
    plymeta.Spawn = function(self, ...)
        if self.Horde_AFK then return end
        return base_spawn(self, ...)
    end
end

local function PutIntoSpectate(ply)
    if not IsValid(ply) or ply:Alive() then return end
    ply:SetObserverMode(OBS_MODE_ROAMING)
    ply:SetMoveType(MOVETYPE_OBSERVER)
    ply:SetNoDraw(true)
    ply:DrawShadow(false)
    ply.Horde_SpectatorGhost = true
    ply.Horde_DebuffImmune = true
    if ply.SetNoTarget then ply:SetNoTarget(true) end
end

-- Safety net for anything that brings a player back without Player:Spawn.
hook.Add("PlayerSpawn", "Horde_AFKBlockSpawn", function(ply)
    if not ply.Horde_AFK then return end
    timer.Simple(0, function()
        if not IsValid(ply) or not ply.Horde_AFK or not ply:Alive() then return end
        ply:KillSilent()
        timer.Simple(0.1, function() PutIntoSpectate(ply) end)
    end)
end)

-- Soul Rebooter / beacon checks look at this hook too; make sure AFK players never pass.
hook.Add("Horde_OnPlayerShouldRespawnDuringWave", "Horde_AFKNoRespawn", function(ply)
    if IsValid(ply) and ply.Horde_AFK then return false end
end)

-- ---------------------------------------------------------------------------------------
-- Going AFK / coming back
-- ---------------------------------------------------------------------------------------

function HORDE:SetPlayerAFK(ply, reason)
    if not IsValid(ply) or ply.Horde_AFK then return end

    ply.Horde_AFK = true
    ply.Horde_AFKWarnedAt = nil
    ply:SetNWBool("Horde_AFK", true)
    ply:SetTeam(TEAM_SPECTATOR)

    if HORDE.player_ready then
        HORDE.player_ready[ply] = nil
        SyncReady()
    end

    net.Start("Horde_ForceCloseShop")
    net.Send(ply)

    if ply:Alive() then
        -- Leave their weapons on the floor for the team, like a normal death does.
        local body = ply:WorldSpaceCenter()
        for _, wpn in pairs(ply:GetWeapons()) do
            ply:DropWeapon(wpn, nil, vector_origin)
            if HORDE.SeatDroppedWeapon then HORDE:SeatDroppedWeapon(wpn, body) end
        end
        if HORDE.ClearPlayerDebuffs then
            HORDE:ClearPlayerDebuffs(ply)
        else
            hook.Run("Horde_ResetStatus", ply)
        end
        net.Start("Horde_ClearStatus")
        net.Send(ply)
        ply:KillSilent()
    end
    timer.Simple(0.1, function() PutIntoSpectate(ply) end)

    net.Start("Horde_AFK")
    net.WriteUInt(AFK_MOVED, 3)
    net.WriteBool(cv_return:GetBool())
    net.Send(ply)

    if reason == "command" then
        Announce(ply, "AFK_Announce_WentAFK")
    else
        Announce(ply, "AFK_Announce_MovedIdle")
    end

    HORDE.refresh_living_players = true
    -- If they were the last one standing, the round is lost exactly as if they had died.
    if HORDE.start_game and HORDE.CheckAlivePlayers then
        timer.Simple(0.2, function() HORDE:CheckAlivePlayers() end)
    end
end

function HORDE:ClearPlayerAFK(ply)
    if not IsValid(ply) or not ply.Horde_AFK then return end

    ply.Horde_AFK = nil
    ply.Horde_AFKWarnedAt = nil
    ply.Horde_AFKLastActive = CurTime()
    ply:SetNWBool("Horde_AFK", false)
    ply:SetTeam(AFK_TEAM_NORMAL)

    net.Start("Horde_AFK")
    net.WriteUInt(AFK_RETURNED, 3)
    net.Send(ply)
    Announce(ply, "AFK_Announce_Back")

    if ply:Alive() then return end
    -- Same rules as any dead player: back right away in the lobby or a break, otherwise at
    -- the end of the wave.
    if not HORDE.start_game or (HORDE.current_break_time or 0) > 0 then
        ply:Spawn()
        if HORDE.player_ready then
            HORDE.player_ready[ply] = 0
            SyncReady()
        end
    else
        HORDE:SendNotification(T(ply, "AFK_Notify_RespawnNextWave"), 0, ply)
    end
end

-- ---------------------------------------------------------------------------------------
-- Input tracking
-- ---------------------------------------------------------------------------------------

-- Looking around, scrolling or pressing/releasing a key counts as activity. A key that is
-- merely held down (a stuck +forward bind) does not, so it cannot dodge the AFK check.
hook.Add("StartCommand", "Horde_AFKTrack", function(ply, cmd)
    local buttons = cmd:GetButtons()
    local ang = cmd:GetViewAngles()
    local last = ply.Horde_AFKViewAngles

    if cmd:GetMouseX() ~= 0 or cmd:GetMouseY() ~= 0 or cmd:GetMouseWheel() ~= 0
        or cmd:GetImpulse() ~= 0
        or (ply.Horde_AFKButtons ~= nil and buttons ~= ply.Horde_AFKButtons)
        or (last and (math.abs(math.AngleDifference(ang.p, last.p)) > 0.5
            or math.abs(math.AngleDifference(ang.y, last.y)) > 0.5)) then
        MarkActive(ply)
    end

    ply.Horde_AFKButtons = buttons
    ply.Horde_AFKViewAngles = ang
end)

hook.Add("PlayerInitialSpawn", "Horde_AFKInit", function(ply)
    ply.Horde_AFKLastActive = CurTime()
end)

hook.Add("PlayerDisconnected", "Horde_AFKCleanup", function(ply)
    ply.Horde_AFK = nil
end)

timer.Create("Horde_AFKCheck", 1, 0, function()
    if not cv_enabled:GetBool() then return end
    local now = CurTime()
    local idle_limit = cv_time:GetFloat()
    local grace = cv_grace:GetFloat()

    for _, ply in ipairs(player.GetHumans()) do
        if ply.Horde_AFK then goto continue end
        if cv_admin_immune:GetBool() and ply:IsAdmin() then goto continue end
        if ply:IsTimingOut() then goto continue end

        ply.Horde_AFKLastActive = ply.Horde_AFKLastActive or now
        local idle = now - ply.Horde_AFKLastActive

        if ply.Horde_AFKWarnedAt then
            if now - ply.Horde_AFKWarnedAt >= grace then
                HORDE:SetPlayerAFK(ply, "idle")
            end
        elseif idle >= idle_limit then
            ply.Horde_AFKWarnedAt = now
            net.Start("Horde_AFK")
            net.WriteUInt(AFK_WARN, 3)
            net.WriteUInt(math.Clamp(math.floor(grace), 0, 65535), 16)
            net.Send(ply)
            Announce(ply, "AFK_Announce_Warning", grace)
        end

        ::continue::
    end
end)

-- ---------------------------------------------------------------------------------------
-- Chat commands
-- ---------------------------------------------------------------------------------------

hook.Add("PlayerSay", "Horde_AFKCommands", function(ply, text)
    if not IsValid(ply) then return end
    local cmd = string.lower(string.Trim(text or ""))

    if cmd == "!afk" then
        if ply.Horde_AFK then
            if cv_return:GetBool() then
                HORDE:SendNotification(T(ply, "AFK_Notify_AlreadyAFKBack"), 0, ply)
            else
                HORDE:SendNotification(T(ply, "AFK_Notify_AlreadyAFK"), 0, ply)
            end
        else
            HORDE:SetPlayerAFK(ply, "command")
        end
        return ""
    end

    if cmd == "!back" or cmd == "!unafk" then
        if not ply.Horde_AFK then
            HORDE:SendNotification(T(ply, "AFK_Notify_NotAFK"), 0, ply)
        elseif not cv_return:GetBool() then
            HORDE:SendNotification(T(ply, "AFK_Notify_NoReturn"), 1, ply)
        else
            HORDE:ClearPlayerAFK(ply)
        end
        return ""
    end

    -- Any other chat line means the player is at the keyboard.
    MarkActive(ply)
end)

concommand.Add("horde_afk", function(ply)
    if IsValid(ply) and not ply.Horde_AFK then HORDE:SetPlayerAFK(ply, "command") end
end)

concommand.Add("horde_back", function(ply)
    if IsValid(ply) and ply.Horde_AFK and cv_return:GetBool() then HORDE:ClearPlayerAFK(ply) end
end)
