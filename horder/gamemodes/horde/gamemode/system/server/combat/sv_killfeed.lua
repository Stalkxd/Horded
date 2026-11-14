-- Horde killfeed (server side). Replaces the GMod death notices: every kill is sent with
-- the killer, the player who assisted, the weapon and the victim. cl_killfeed.lua draws it.
util.AddNetworkString("Horde_Killfeed")

-- Name of an entity, and whether it is a player (white) or not (red). A minion counts as
-- its owner, so a turret kill shows the engineer; a dying minion shows its own name in white.
local function Who(ent, as_victim)
    if not IsValid(ent) then return nil end
    if ent:IsPlayer() then return ent:Nick(), true end
    local owner = HORDE:GetMinionOwner(ent)
    if IsValid(owner) and owner:IsPlayer() then
        if as_victim then return "#" .. ent:GetClass(), true end
        return owner:Nick(), true, owner
    end
    local name = ent.Horde_GetName and ent:Horde_GetName()
    if not name or name == "" then name = "#" .. ent:GetClass() end
    return name, false
end

local function KillIcon(attacker, inflictor)
    if IsValid(inflictor) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
        local wpn = inflictor:GetActiveWeapon()
        if IsValid(wpn) then return wpn:GetClass() end
    end
    if IsValid(inflictor) then return inflictor:GetClass() end
    if IsValid(attacker) then return attacker:GetClass() end
    return "default"
end

local function Send(victim, attacker, inflictor)
    local victim_name, victim_player = Who(victim, true)
    if not victim_name then return end

    local killer_name, killer_player, owner = Who(attacker)
    local killer = (owner or attacker)
    if killer == victim or (IsValid(attacker) and attacker:IsWorld()) then
        killer_name, killer = nil, nil
    end

    local assist = victim.Horde_Assist
    local assist_name = ""
    if IsValid(assist) and assist:IsPlayer() and assist ~= killer and assist ~= victim then
        assist_name = assist:Nick()
    end

    net.Start("Horde_Killfeed")
        net.WriteString(killer_name or "")
        net.WriteBool(killer_player == true)
        net.WriteString(assist_name)
        net.WriteString(KillIcon(attacker, inflictor))
        net.WriteString(victim_name)
        net.WriteBool(victim_player == true)
    net.Broadcast()
end

hook.Add("OnNPCKilled", "Horde_Killfeed", function(victim, attacker, inflictor)
    Send(victim, attacker, inflictor)
end)

hook.Add("PlayerDeath", "Horde_Killfeed", function(victim, inflictor, attacker)
    Send(victim, attacker, inflictor)
end)
