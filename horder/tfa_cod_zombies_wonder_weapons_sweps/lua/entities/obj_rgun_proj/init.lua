AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Exploded = false

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
	--if self:GetCollisionGroup() == COLLISION_GROUP_WEAPON then return true end
end

function ENT:StartTouch(ent)
	--if self.HasCollided then return end
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	--[[if ent == self.Owner then
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetTrigger(true)
		return
	end
	if self:GetCollisionGroup() == COLLISION_GROUP_WEAPON then return false end]]
	
	--self.HasCollided = true
	self:Explode()
	
	return true
end

--[[function ENT:EndTouch(ent)
	if ent == self.Owner then
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self:SetTrigger(false)
	end
end]]

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true
	
	ParticleEffect( self:GetUpgraded() and "raygun_impact_pap" or "raygun_impact", self:GetPos(), angle_zero)
	self:EmitSound("weapons/raygun/wpn_ray_exp.ogg", 85, 100, 1, CHAN_WEAPON)
	self:EmitSound("weapons/raygun/wpn_ray_exp_cl.ogg", 70, 100, 1, CHAN_BODY)
	self:EmitSound("weapons/raygun/wpn_ray_flux.ogg", 80, math.random(70, 75), 0.75, CHAN_ITEM)
	
	local dmg = DamageInfo()
	dmg:SetDamageType(DMG_BLAST)
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamage(self:GetUpgraded() and 600 or 300)
	--dmg:SetDamageForce( Vector(0,0,0) )
	util.BlastDamageInfo(dmg, self:GetPos(), 72)
	
	self:Remove()
end

function ENT:Think()
	if CurTime() > self.LifeTime then
		self:Remove()
	end
end