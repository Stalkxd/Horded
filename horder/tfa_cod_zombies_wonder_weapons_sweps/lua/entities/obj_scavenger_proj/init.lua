AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Think()
	if CurTime() >= self:GetLifeTime() then
		self:Explosion()
	end
end

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
end

function ENT:StartTouch(ent)
	if self.Attached then return end
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	if ent == self.Owner then return false end
	
	self:Attach(ent, data.HitPos)
	
	return true
end


function ENT:Attach(tgt, pos)
	self.Attached = true
	self:SetLifeTime(CurTime() + self.FuseTime)
	self:SetVelocity(vector_origin)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	if tgt:GetHitBoxCount( 0 ) > 1 then
		local trdata = {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward()*64,
			filter = self
		}
		local tr = util.TraceLine(trdata)
		if tr.Entity == tgt then
			self:FollowBone( tgt, tr.HitBoxBone )
			local bonepos, boneang = tgt:GetBonePosition(tr.HitBoxBone)
			self:SetPos(bonepos)
		else
			local closest = 0
			local dist = 4096
			
			for i = 1, tgt:GetHitBoxCount( 0 ) do
				local boxbone = tgt:GetHitBoxBone( i-1, 0 )
				local bonepos, boneang = tgt:GetBonePosition(boxbone)
				local newdist = bonepos:DistToSqr(pos)
				if newdist < dist then
					closest = boxbone
					dist = newdist
				end
			end
			self:FollowBone( tgt, closest )
			local bonepos, boneang = tgt:GetBonePosition(closest)
			self:SetPos(bonepos)
		end
	end
	self:EmitSound(self.CollideSound)
end

function ENT:Explosion()
	if self:GetExploded() then return end
	self:SetExploded(true)
	
	self:EmitSound(")weapons/ubersniper/bomb/us_bomb_explo.ogg", 120, 100, 1, CHAN_WEAPON)
	if self:GetUpgraded() then
		self:EmitSound(")weapons/ubersniper/bomb/us_bomb_explo_sweet_2.ogg", 90)
		ParticleEffect("ubersniper_pap_base", self:GetPos(), angle_zero, nil)
	else
		self:EmitSound(")weapons/ubersniper/bomb/us_bomb_flux.ogg", 90)
		ParticleEffect("ubersniper_explosion", self:GetPos(), angle_zero, nil)
	end
	util.ScreenShake(self:GetPos(), 1, 8, 0.3, 512)
	
	local dmg = DamageInfo()
	dmg:SetDamageType(DMG_BLAST)
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 256)) do
		dmg:SetDamage(10000)
		if v:IsPlayer() then 
			if !hook.Run("PlayerShouldTakeDamage",v,self.Owner) then continue end
			dmg:SetDamage(50)
		end
		v:TakeDamageInfo(dmg)
	end
	SafeRemoveEntity(self)
end