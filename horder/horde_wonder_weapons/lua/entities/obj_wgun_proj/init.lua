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
	dmg:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	dmg:SetDamagePosition(self:GetPos())
	--dmg:SetDamageForce( Vector(0,0,0) )
	-- Horde: a fixed hit from the weapon's damage instead of killing outright
	dmg:SetDamage(self.Damage or 250)
	if not ((ent:IsNPC() or ent:IsNextBot()) and HORDE_WW and IsValid(self.Owner) and not HORDE_WW.IsHostile(self.Owner, ent)) then
		-- Hit along the flight path so headshots count
		local dir = self:GetVelocity()
		if dir:IsZero() then dir = self:GetForward() end
		HORDE_WW.TraceHit(ent, dmg, self:GetPos(), dir)
	end
	
	self:Remove()
end