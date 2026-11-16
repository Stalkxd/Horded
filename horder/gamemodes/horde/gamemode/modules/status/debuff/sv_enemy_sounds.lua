if CLIENT then return end

-- Distance-based sound sending for horde enemies.
--
-- VJ Base plays every NPC sound (footsteps, breathing, idle, pain, attacks...)
-- through VJ.EmitSound / VJ.CreateSound with a filter holding every player on
-- the server. Players far away can't hear most of them, but each one is still
-- a network message to every client. With 30+ enemies that is a steady stream
-- of sound messages nobody hears.
--
-- This wraps both functions: for a horde enemy, the sound only goes to players
-- close enough to hear it. The range grows with the sound's level:
--   range = horde_enemy_sound_range * 2 ^ ((level - 75) / 8)
-- so a normal 75 dB sound reaches 2000 units by default, 85 dB about 4750 and
-- 95 dB and up about 11000 (effectively everyone). Bosses, minions and every
-- other entity keep VJ's normal behaviour. horde_enemy_sound_range 0 = off.
--
-- Note: looping sounds made with CreateSound pick their listeners when they
-- start, so a player who walks up during a long breathing loop hears it from
-- the next loop on.

local cv_range = CreateConVar("horde_enemy_sound_range", 2000, FCVAR_ARCHIVE, "Horde enemy sounds at 75 dB are only sent to players within this many units (louder sounds reach further). 0 = send to everyone, like plain VJ Base.")

local filter = RecipientFilter()
local range = cv_range:GetFloat()

local function IsBoss(ent)
    if ent:GetVar("is_boss") == true then return true end
    local props = ent.Horde_GetBossProperties and ent:Horde_GetBossProperties()
    return props and props.is_boss == true
end

-- Returns the filter to use, or nil to keep VJ's own (everyone).
local function NearbyFilter(ent, level)
    if range <= 0 or not IsValid(ent) then return nil end
    local spawned = HORDE.spawned_enemies
    if not spawned or not spawned[ent:EntIndex()] then return nil end
    if ent.Horde_SoundBoss == nil then ent.Horde_SoundBoss = IsBoss(ent) end
    if ent.Horde_SoundBoss then return nil end

    local dist = range * 2 ^ (((level or 75) - 75) / 8)
    local dist_sqr = dist * dist
    local pos = ent:GetPos()
    filter:RemoveAllPlayers()
    for _, ply in ipairs(player.GetHumans()) do
        if ply:EyePos():DistToSqr(pos) <= dist_sqr then filter:AddPlayer(ply) end
    end
    return filter
end

local function Wrap()
    if not VJ or not VJ.EmitSound or not VJ.CreateSound then return false end
    if VJ.Horde_SoundWrapped then return true end
    VJ.Horde_SoundWrapped = true

    local orig_create = VJ.CreateSound
    local orig_emit = VJ.EmitSound

    VJ.CreateSound = function(ent, sdFile, sdLevel, sdPitch)
        local f = NearbyFilter(ent, sdLevel)
        if not f then return orig_create(ent, sdFile, sdLevel, sdPitch) end
        -- Same as VJ's, with our filter. Still made when nobody is near, so
        -- VJ can stop or adjust it as usual.
        sdFile = VJ.PICK(sdFile)
        if not sdFile then return end
        local on_play = ent.OnPlaySound; if on_play then sdFile = on_play(ent, sdFile) end
        local sd = CreateSound(ent, sdFile, f)
        sd:SetSoundLevel(sdLevel or 75)
        sd:PlayEx(1, sdPitch or 100)
        local on_create = ent.OnCreateSound; if on_create then on_create(ent, sd, sdFile) end
        return sd
    end

    VJ.EmitSound = function(ent, sdFile, sdLevel, sdPitch, sdVolume, sdChannel)
        local f = NearbyFilter(ent, sdLevel)
        if not f then return orig_emit(ent, sdFile, sdLevel, sdPitch, sdVolume, sdChannel) end
        sdFile = VJ.PICK(sdFile)
        if not sdFile then return end
        local on_play = ent.OnPlaySound; if on_play then sdFile = on_play(ent, sdFile) end
        if f:GetCount() > 0 then
            ent:EmitSound(sdFile, sdLevel, sdPitch, sdVolume, sdChannel, 0, 1, f)
        end
        local on_emit = ent.OnEmitSound; if on_emit then on_emit(ent, sdFile) end
    end
    return true
end

-- VJ Base loads from addon autorun, after the gamemode, so wrap once it's there.
if not Wrap() then
    hook.Add("InitPostEntity", "Horde_EnemySounds", Wrap)
end

timer.Create("Horde_EnemySoundSettings", 1, 0, function()
    range = cv_range:GetFloat()
end)
