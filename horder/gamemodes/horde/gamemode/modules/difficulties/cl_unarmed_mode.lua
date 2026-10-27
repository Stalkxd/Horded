if SERVER then return end

local FALLBACK_COLOR = Color(0, 255, 0)
local cached = {}
local next_scan = 0

local function QualityColor(key)
    if HORDE and HORDE.GetQualityColor and HORDE.Quality and HORDE.Quality[key] then
        return HORDE:GetQualityColor(key)
    end
    return FALLBACK_COLOR
end

hook.Add("PreDrawHalos", "Horde_UnarmedWeaponHalos", function()
    if GetConVarNumber("horde_enable_halo") == 0 then return end

    if CurTime() >= next_scan then
        next_scan = CurTime() + 0.5
        cached = {}
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent:GetNWBool("Horde_UnarmedDrop", false) and not IsValid(ent:GetOwner()) then
                cached[#cached + 1] = ent
            end
        end
    end
    if #cached == 0 then return end

    local groups = {}
    for _, ent in ipairs(cached) do
        if IsValid(ent) then
            local quality = ent:GetNWString("Horde_UnarmedQuality", "Common")
            local list = groups[quality]
            if not list then
                list = {}
                groups[quality] = list
            end
            list[#list + 1] = ent
        end
    end
    for quality, list in pairs(groups) do
        halo.Add(list, QualityColor(quality), 1, 1, 1, true, true)
    end
end)

net.Receive("Horde_UnarmedSyncLooted", function()
    local n = net.ReadUInt(16)
    local t = {}
    for i = 1, n do
        t[net.ReadString()] = true
    end
    if IsValid(LocalPlayer()) then
        LocalPlayer().Horde_UnarmedLooted = t
    end
end)

-- Scavenged weapons are picked up with +use, so tell the player when one is in reach.
local USE_HINT_RANGE_SQR = 96 * 96
hook.Add("HUDPaint", "Horde_UnarmedUseHint", function()
    if not HORDE or not HORDE.unarmed_mode then return end
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:GetNWBool("Horde_UnarmedDrop", false) or IsValid(ent:GetOwner()) then return end
    if ply:GetShootPos():DistToSqr(ent:WorldSpaceCenter()) > USE_HINT_RANGE_SQR then return end

    local key = string.upper(input.LookupBinding("+use") or "E")
    local name = language.GetPhrase(ent.PrintName or ent:GetClass())
    draw.SimpleTextOutlined("[" .. key .. "] Pick up " .. name, "Trebuchet24",
        ScrW() / 2, ScrH() / 2 + 60, QualityColor(ent:GetNWString("Horde_UnarmedQuality", "Common")),
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end)
