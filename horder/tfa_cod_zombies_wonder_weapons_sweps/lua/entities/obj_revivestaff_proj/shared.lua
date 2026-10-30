ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

--ENT.CollidePCF = "originstaff_revive_impact"
--ENT.MoveSpeed = 3000
function ENT:Initialize()
	self:EnableCustomCollisions(true)

	if SERVER then
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetSolid(SOLID_BBOX)
		self:SetModel("models/error.mdl")
		self:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		
		self:EmitSound("weapons/originstaffs/revive/proj_loop.wav", 70)
		
		self.DamageInfo = DamageInfo()
		self.DamageInfo:SetDamage(500)
		self.DamageInfo:SetAttacker(self.Owner)
		self.DamageInfo:SetInflictor(self)
		self.DamageInfo:SetDamageType(DMG_ENERGYBEAM)
	end
	self:SetNoDraw(true)
	self:DrawShadow(false)
	ParticleEffectAttach( "originstaff_revive_proj", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	
	self.LifeTime = CurTime() + 8
end

function ENT:TestCollision( startpos, delta, isbox, extents, mask )
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
end

function ENT:OnRemove()
	self:StopSound("weapons/originstaffs/revive/proj_loop.wav")
	self:StopParticles()
end