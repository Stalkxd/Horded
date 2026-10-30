ENT.Type			= "anim"
ENT.PrintName		= "Sliquifier blob"
ENT.Author			= "Hidden"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable 		= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_MONSTER

ENT.BlobParticle = "slipgun_blob"
ENT.ImpactParticle = "slipgun_impact"
ENT.PopParticle = "slipgun_pop"
ENT.ParticleSuffix = ""

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Upgraded")
	self:NetworkVar( "Bool", 1, "Funny")
end

function ENT:Initialize()
	self:EnableCustomCollisions(true)
	if SERVER then
		self:SetModel("models/error.mdl")
		self:SetSolid(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_FLYGRAVITY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))
	end
	
	self:SetNoDraw(true)
	self:DrawShadow(false)
	
	if self:GetFunny() then
		self.ParticleSuffix = "_white" -- Yes, this is what you're thinking.
	elseif self:GetUpgraded() then
		self.ParticleSuffix = "_pap"
	end
	
	ParticleEffectAttach( self.BlobParticle..self.ParticleSuffix, PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	
	self.Exploded = false
	self.CreatedPuddle = false
	self.Stopped = false
	
	self.LifeTime = CurTime() + 4
	
	self.OldTargets = {}
end