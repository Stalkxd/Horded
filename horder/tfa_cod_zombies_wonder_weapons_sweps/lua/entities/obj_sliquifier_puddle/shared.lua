ENT.Type			= "anim"
ENT.PrintName		= "Sliquifier puddle"
ENT.Author			= "Hidden"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable 		= false

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Upgraded")
	self:NetworkVar( "Bool", 1, "Funny")
end

ENT.Mat = Material("effects/fxt6_slickgun_decal_01")
ENT.Color = Color(192, 0, 192, 255)
ENT.ParticleSuffix = ""


function ENT:Initialize()
	if self:GetFunny() then
		self.ParticleSuffix = "_white"
		self.Color = Color(192, 192, 192, 255)
	elseif self:GetUpgraded() then
		self.ParticleSuffix = "_pap"
		self.Color = Color(0, 255, 0, 255)
	end
	
	if SERVER then
		self:SetModel("models/hunter/plates/plate2x2.mdl")
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		
		if self:WaterLevel() > 1 then SafeRemoveEntity(self) return end
		
		--self:EnableCustomCollisions(true)
		self:SetTrigger(true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetBuoyancyRatio(0)
		end
		
		self.LifeTime = CurTime() + 20
	end
	if CLIENT then
		self.Mat = Material("effects/fxt6_slickgun_decal_0"..math.random(0,1))
		
		ParticleEffectAttach("slipgun_floorgoo"..self.ParticleSuffix, PATTACH_ABSORIGIN_FOLLOW, self, 1)
		
		self.LifeTime = CurTime() + 21
	end
	
	self:DrawShadow(false)
end