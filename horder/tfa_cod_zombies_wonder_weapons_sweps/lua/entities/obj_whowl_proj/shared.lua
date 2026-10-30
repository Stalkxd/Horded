
/*-------------------------------------------------*\
|  Copyright © 2017 by Roach, All rights reserved.  |  --Good coding practices sure changed since 2017. No offense Roach.
\*-------------------------------------------------*/
AddCSLuaFile()
AddCSLuaFile("cl_init.lua")
ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.Author			= "Roach"
ENT.Spawnable			= false

ENT.TimeoutPeriod = 0.5


function ENT:OnCollide()
	self:EmitSound("weapons/wintershowl/projectile/impact/impact_0"..math.random(0,3)..".ogg")
    SafeRemoveEntity(self)
end

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
	end
	self:DrawShadow(false)
	
	self:EmitSound("weapons/wintershowl/flux/flux.ogg")
	
	self.TimeoutPeriod = CurTime() + 0.5
end
/*
function ENT:OnRemove()
	
end
*/
function ENT:Think()
	if SERVER and CurTime() > self.TimeoutPeriod then SafeRemoveEntity(self) end
end

function ENT:PhysicsCollide(data, physobj)
	if data.HitEntity:IsWorld() then self:OnCollide() end
	return true
end