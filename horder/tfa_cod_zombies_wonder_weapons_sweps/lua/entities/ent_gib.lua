AddCSLuaFile()

ENT.Type = "anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.NextBleed = math.random(0.05,0.1)

function ENT:Initialize()
	if SERVER then
		local gibs = {"models/Gibs/HGIBS.mdl","models/Gibs/HGIBS_rib.mdl","models/Gibs/HGIBS_scapula.mdl","models/Gibs/HGIBS_spine.mdl"}
		self:SetModel(table.Random(gibs))
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMaterial("models/flesh")
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:EnableMotion( true )
		end
	end
end

function ENT:Bleed()
	if CurTime() < self.NextBleed then return end
	ParticleEffect("blood_impact_red_01",self:GetPos(),self:GetAngles(),self)
	self.NextBleed = CurTime() + math.random(0.05,0.1)
end
function ENT:Think()
	if IsValid(self) then
		self:Bleed()
		if self:WaterLevel() > 1 and SERVER then self:Remove() end 
	end
end

if CLIENT then 

function ENT:Draw()
	self:DrawModel()
end

end

function ENT:PhysicsCollide()
	self:Remove()
end