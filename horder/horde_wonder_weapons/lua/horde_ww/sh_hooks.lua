-- Hooks the wonder weapon projectiles and weapons rely on.

-- Horde: wonder weapon effects only hit enemies, and control effects skip bosses and elites
function TFAWW_SkipPlayer(ent, attacker)
    return HORDE ~= nil and HORDE.WonderWeaponIgnores ~= nil and HORDE:WonderWeaponIgnores(ent, attacker)
end

function TFAWW_Resists(ent)
    return HORDE ~= nil and HORDE.WonderWeaponResists ~= nil and HORDE:WonderWeaponResists(ent)
end

-- true when a control effect from attacker must not touch ent
function TFAWW_SkipEffect(ent, attacker)
    if not IsValid(ent) or HORDE == nil then return false end
    if ent:IsPlayer() then return true end
    return TFAWW_Resists(ent)
end

local function ActiveWW(ply)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.IsHordeWonderWeapon then return wep end
end

-- Movement for the DG-4 jump slam, the Apothicon Sword leap and the Gauntlet punch dash.
-- Weapons expose WW_MoveVelocity(ply, mv) and return a velocity while the move is active.
hook.Add("SetupMove", "HordeWW_SetupMove", function(ply, mv, cmd)
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    local wep = ActiveWW(ply)
    if not wep or not wep.WW_MoveVelocity then return end
    local vel = wep:WW_MoveVelocity(ply, mv)
    if vel then
        mv:SetVelocity(vel)
    end
end)

hook.Add("StartCommand", "HordeWW_StartCommand", function(ply, cmd)
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    local wep = ActiveWW(ply)
    if not wep or not wep.WW_LockMovement or not wep:WW_LockMovement() then return end
    cmd:RemoveKey(IN_SPEED)
    cmd:RemoveKey(IN_JUMP)
    cmd:RemoveKey(IN_DUCK)
    cmd:ClearMovement()
end)

if SERVER then
    -- Landing from a slam is part of the attack, so it does not hurt
    hook.Add("GetFallDamage", "HordeWW_SlamFallDamage", function(ply, speed)
        local wep = ActiveWW(ply)
        if wep and wep.WW_NoFallDamage and wep:WW_NoFallDamage() then return 0 end
    end)

    hook.Add("PlayerSpawn", "HordeWW_PlayerSpawn", function(ply)
        if ply:GetNW2Bool("DG4Killed") then ply:SetNW2Bool("DG4Killed", false) end
    end)
end

if CLIENT then
    hook.Add("CreateClientsideRagdoll", "HordeWW_Ragdoll", function(ent, ragdoll)
        if not IsValid(ent) or not IsValid(ragdoll) then return end
        if ent:GetNW2Bool("DG4Killed") then
            ParticleEffectAttach("bo3_dg4_zomb", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 0)
        end
    end)
end
