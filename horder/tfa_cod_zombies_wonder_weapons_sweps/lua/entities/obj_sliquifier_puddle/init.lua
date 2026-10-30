AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.RestoreEnts = {}

function ENT:OnRemove()
	local mins, maxs = self:GetCollisionBounds()
	
	for k, v in ipairs(ents.FindInBox(self:GetPos() + mins, self:GetPos() + maxs)) do
		self:EndTouch(v)
	end
end

function ENT:Think()
	if IsValid(self) and self.LifeTime < CurTime() then
		self:StopParticles()
		SafeRemoveEntity(self)
	end
end

function ENT:Touch( ent )
	if !ent.SliquifierRestore then
		ent.SliquifierRestore = {
			Friction = ent:GetFriction(),
			Acceleration = ent.loco and ent.loco:GetAcceleration(),
			Deceleration = ent.loco and ent.loco:GetDeceleration()
		}
	end
	
	ent:SetFriction(0.1)
	if ent:IsNextBot() then
		ent.loco:SetAcceleration(16)
		ent.loco:SetDeceleration(16)
	end
end

--[[
function ENT:Touch( ent )
	if ent:IsPlayer() then
		ent:SetGroundEntity(nil)
	end
end
]]

function ENT:EndTouch( ent )
	if !IsValid(ent) then return end
	
	local data = ent.SliquifierRestore
	
	if data then
		ent:SetFriction(data.Friction)
		if data.Acceleration then
			ent.loco:SetAcceleration(data.Acceleration)
			ent.loco:SetDeceleration(data.Deceleration)
		end
		ent.SliquifierRestore = nil
	end
end