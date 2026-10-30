AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
end

function ENT:StartTouch(ent)
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	self:OnCollide(ent, data.HitPos)
end

function ENT:OnCollide(ent, pos)
	if ent == self.Owner then return end
	if self:GetCharge() < 1 then
		local dmg = DamageInfo()
		dmg:SetDamage(1)
		dmg:SetDamageType(DMG_SONIC)
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		ent:TakeDamageInfo(dmg)
		
		ParticleEffect( "originstaff_wind_impact", self:GetPos(), angle_zero )
		SafeRemoveEntity(self)
		return
	end
	
	self:UltimateAbility(pos)
end

function ENT:Think()
	if CurTime() > self.LifeTime then 
		if self:GetMoveType() != MOVETYPE_NONE then 
			SafeRemoveEntity(self)
			return
		end
		self:StopParticles()
		SafeRemoveEntityDelayed(self, 1)
		self.UltSound:FadeOut(1)
		return true
	end
	
	if self:GetMoveType() != MOVETYPE_NONE then return end
	
	for _, v in ipairs(ents.FindInSphere(self:GetPos(), 72)) do
		if v:GetInternalVariable("m_takedamage") < 1 then continue end
		if v:Health() <= 0 then 
			if v.Kill then v:Kill() end
			continue 
		end
		if v:IsPlayer() and (v == self.Owner or !hook.Run("PlayerShouldTakeDamage",v,self.Owner)) then continue end
		
		local dmg = DamageInfo()
		if string.find( v:GetClass(), "boss", 1, true ) then
			dmg:SetDamage( math.max(v:GetMaxHealth()/20, 1000) )
		else
			dmg:SetDamage(2147483000)
		end
		dmg:SetDamageType(DMG_SONIC)
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamageForce(vector_up*10000)
		dmg:SetDamagePosition(self:GetPos())
		v:TakeDamageInfo(dmg)
	end
	for k, p in ipairs(ents.FindInSphere(self:GetPos(), 256)) do
		if p:IsPlayer() and (p == self.Owner or !hook.Run("PlayerShouldTakeDamage",p,self.Owner)) then continue end
		if p.loco then
			p.loco:SetVelocity(2*(self:GetPos()-p:GetPos()))
		else
			p:SetVelocity(2*(self:GetPos()-p:GetPos()))
		end
		--p:SetGroundEntity(nil)
	end
	
end



function ENT:UltimateAbility(pos)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	self:SetAngles(angle_zero)
	if self.UltSound then self.UltSound:Play() end
	self:EmitSound("weapons/originstaffs/air/tornado/airstaff_tornado_imp.ogg")
	util.ScreenShake( pos, 16, 8, self:GetCharge() * 5 + 5, 256 )
	self.LifeTime = CurTime() + self:GetCharge() * 5
	ParticleEffectAttach( "originstaff_wind_ultimate", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function ENT:OnRemove()
	self:StopSound("weapons/originstaffs/fire/projectile/loop.wav")
	if self.UltSound then self.UltSound:Stop() end
	self:StopParticles()
end