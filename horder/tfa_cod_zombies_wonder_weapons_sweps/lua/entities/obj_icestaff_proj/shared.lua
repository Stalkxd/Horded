AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

ENT.Damage = 300
ENT.Charge = 0

function ENT:Initialize()
	--self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:EnableCustomCollisions(true)
	
	if SERVER then
		self:SetMoveType(MOVETYPE_FLY) -- Using QPhysics instead of VPhysics.
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetSolid(SOLID_BBOX)
		self:SetModel("models/error.mdl")
		self:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		
		self.DamageInfo = DamageInfo()
		self.DamageInfo:SetDamage( math.max( (self.Charge-1)*5000000, 0) + self.Damage )
		self.DamageInfo:SetDamageType(bit.bor(DMG_VEHICLE, DMG_REMOVENORAGDOLL))
		self.DamageInfo:SetAttacker(self.Owner)
		self.DamageInfo:SetInflictor(self)
		
		self:EmitSound("weapons/originstaffs/ice/flux/icestaff_flux.ogg", 76)
		self.UltSound = CreateSound(self, "weapons/originstaffs/ice/storm/ice_staff_storm.wav")
	end
	
	self.LifeTime = CurTime() + 0.2
	
	self:SetNoDraw(true)
	self:DrawShadow(false)
	ParticleEffectAttach( "originstaff_ice_proj", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function ENT:TestCollision( startpos, delta, isbox, extents, mask )
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
end

function ENT:StartTouch(ent)
	local data = self:GetTouchTrace()
	
	if ent == self.Owner then return false end
	if ent:GetCollisionGroup() == COLLISION_GROUP_PROJECTILE then return false end
	if self:GetMoveType() == MOVETYPE_NONE then return false end
	
	ParticleEffect("originstaff_ice_impact", self:GetPos(), self:GetAngles())
	if SERVER then self:FreezeNearby(64) end
	
	if self.Charge > 1 then 
		util.Decal("GlassBreak", self:GetPos(), data.HitPos + data.HitNormal*16, self)
		if SERVER then self:UltimateAbility(data.HitPos) end
		return true
	end
	
	self:Remove()
	
	return true
end

function ENT:Think()
	if self.LifeTime and CurTime() > self.LifeTime then 
		if SERVER then
			if self:GetMoveType() != MOVETYPE_NONE then 
				SafeRemoveEntity(self)
				return 
			end
			SafeRemoveEntityDelayed(self, 1)
		end
		if self.UltSound then self.UltSound:FadeOut(1) end
		return true
	end
	
	if SERVER and self.Charge > 1 and self:GetMoveType() == MOVETYPE_NONE then
		self:FreezeNearby(128)
		self:NextThink(CurTime()+0.5)
		return true
	end
end

function ENT:OnRemove()
	if self.UltSound then self.UltSound:Stop() end
	self:StopParticles()
end