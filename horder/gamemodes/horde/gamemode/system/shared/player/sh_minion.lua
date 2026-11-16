HORDE = HORDE or {}

HORDE.MinionKinds = HORDE.MinionKinds or {
    ["npc_turret_floor"]          = { turret = true },
    ["npc_vj_horde_sniper_turret"]= { turret = true },
    ["npc_vj_horde_shotgun_turret"]= { turret = true },
    ["npc_vj_horde_rocket_turret"]= { turret = true, physgun_straighten = true },
    ["npc_vj_horde_laser_turret"] = { turret = true, physgun_straighten = true },
    ["horde_watchtower"]          = { turret = true, structure = true },
    ["horde_engi_dispenser"]      = { turret = true, structure = true },
}

function HORDE:RegisterMinionKind(class, data)
    self.MinionKinds = self.MinionKinds or {}
    self.MinionKinds[class] = data or {}
end

function HORDE:GetMinionKind(ent)
    if not IsValid(ent) then return nil end
    return self.MinionKinds[ent:GetClass()]
end

function HORDE:IsTurretMinion(ent)
    if not IsValid(ent) then return false end
    local kind = self.MinionKinds[ent:GetClass()]
    if kind and kind.turret then return true end
    return ent.Horde_TurretMinion == true
end

local function RawOwner(ent)
    if not IsValid(ent) then return nil end
    local owner = ent:GetNWEntity("HordeOwner")
    if IsValid(owner) and owner:IsPlayer() then
        return owner
    end
    if SERVER then
        if IsValid(ent.Horde_Owner) and ent.Horde_Owner:IsPlayer() then
            return ent.Horde_Owner
        end
        local o = ent:GetOwner()
        if IsValid(o) and o:IsPlayer() then
            return o
        end
    end
    return nil
end

function HORDE:GetMinionOwner(ent)
    return RawOwner(ent)
end

function HORDE:IsMinion(ent)
    return RawOwner(ent) ~= nil
end

function HORDE:GetMapBuildableRelation(ent)
    if not IsValid(ent) then return nil end
    if not (self.IsMapBuildable and self:IsMapBuildable(ent)) then return nil end
    return ent.Horde_MapRelation
end

function HORDE:IsMinionOf(ent, ply)
    if not IsValid(ply) then return false end
    return RawOwner(ent) == ply
end

-- IsFriendlyUnit, IsEnemy and IsPlayerOrMinion run for every entity that
-- ents.FindInSphere returns in damage, debuff and aura loops, so they are among
-- the most called functions on the server. They read the entity table once
-- (each ent.Field read otherwise goes through the Lua Entity __index) and do
-- the cheap Lua checks before the networked-variable lookups. The answers are
-- the same as the plain versions above.

-- The map buildable relation, without the IsMapBuildable call chain. Horde_MapRelation
-- is only ever set on map buildables, so the buildable check only runs when it is set.
local function MapRelation(ent, t)
    local relation = t.Horde_MapRelation
    if relation == nil then return nil end
    if t.Horde_MapBuildable == true or ent:GetNWBool("Horde_MapBuildable", false) then
        return relation
    end
    return nil
end

-- True when any of the owner sources is a player. Unlike RawOwner, this only
-- needs a yes or no, so it can check the Lua field before the engine calls.
local function HasPlayerOwner(ent, t)
    if SERVER then
        local o = t.Horde_Owner
        if o ~= nil and IsValid(o) and o:IsPlayer() then return true end
        o = ent:GetOwner()
        if IsValid(o) and o:IsPlayer() then return true end
    end
    local owner = ent:GetNWEntity("HordeOwner")
    return IsValid(owner) and owner:IsPlayer()
end

function HORDE:IsFriendlyUnit(ent)
    if not IsValid(ent) then return false end
    if ent:IsPlayer() then return ent:Alive() end
    local t = ent:GetTable()
    local relation = MapRelation(ent, t)
    if relation ~= nil then
        return relation ~= (self.HammerRelation and self.HammerRelation.ENEMY)
    end
    return HasPlayerOwner(ent, t)
end

function HORDE:IsEnemy(ent)
    if not IsValid(ent) then return false end
    if ent:IsPlayer() then return false end
    if not (ent:IsNPC() or ent:IsNextBot()) then return false end
    local t = ent:GetTable()
    local relation = MapRelation(ent, t)
    if relation ~= nil then
        return relation == (self.HammerRelation and self.HammerRelation.ENEMY)
    end
    return not HasPlayerOwner(ent, t)
end

-- IsEnemy for a caller that has already checked that ent is a valid NPC or
-- nextbot, such as the wonder weapons' target filter.
function HORDE:IsEnemyNPC(ent)
    local t = ent:GetTable()
    local relation = MapRelation(ent, t)
    if relation ~= nil then
        return relation == (self.HammerRelation and self.HammerRelation.ENEMY)
    end
    return not HasPlayerOwner(ent, t)
end

HORDE.IsPlayerOrMinion = HORDE.IsFriendlyUnit

function HORDE:IsPlayerMinion(ent)
    return self:IsMinion(ent)
end
