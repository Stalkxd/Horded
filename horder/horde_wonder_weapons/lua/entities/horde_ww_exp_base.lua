AddCSLuaFile()

-- Replacement for the TFA explosive base the Black Ops 3 projectiles were written against.
-- The projectiles only call Initialize from it and use the networked sound helpers.
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Horde wonder weapon projectile"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DefaultModel = "models/dav0r/hoverball.mdl"
ENT.Delay = 3

function ENT:Initialize()
    local mdl = self:GetModel()
    if not mdl or mdl == "" or mdl == "models/error.mdl" then
        self:SetModel(self.DefaultModel)
    end

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end

    self.killtime = CurTime() + self.Delay
    self:DrawShadow(false)
end

function ENT:Think()
    if SERVER and self.killtime and self.killtime < CurTime() then
        self:Remove()
        return false
    end
    self:NextThink(CurTime())
    return true
end

-- The server already sends EmitSound to every client in range.
function ENT:EmitSoundNet(snd, ...)
    if CLIENT then return end
    self:EmitSound(snd, ...)
end

function ENT:StopSoundNet(snd)
    self:StopSound(snd)
end
