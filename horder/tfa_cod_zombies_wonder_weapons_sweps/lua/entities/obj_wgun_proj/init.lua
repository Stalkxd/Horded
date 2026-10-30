AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Exploded = false

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
end

function ENT:StartTouch(ent)
	if self.HasCollided then return end
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	self.HasCollided = true
	self:Explode(ent)
	
	return true
end

function ENT:Think()
	if CurTime() > self.LifeTime then
		self:Remove()
	end
end

function ENT:Explode(ent)
	if self.Exploded then return end
	self.Exploded = true
	
	ParticleEffect("raygun_impact_pap", self:GetPos(), angle_zero)
	self:EmitSound("weapons/tesla_gun/projectile/proj_impact.mp3", 85, 100, 1, CHAN_WEAPON)
	
	local dmg = DamageInfo()
	dmg:SetDamageType(DMG_SHOCK)
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamagePosition(self:GetPos())
	--dmg:SetDamageForce( Vector(0,0,0) )
	if string.find( ent:GetClass(), "boss", 1, true) then
		dmg:SetDamage( math.max(ent:GetMaxHealth()/16, 2000) )
	else
		dmg:SetDamage(ent:Health())
	end
	ent:TakeDamageInfo(dmg)
	
	self:Remove()
end