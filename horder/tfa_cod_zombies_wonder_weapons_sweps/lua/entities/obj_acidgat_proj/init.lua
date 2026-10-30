AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Think()
	if self.Exploded then return end
	
	if CurTime() > self:GetLifeTime() then
		self:Explosion()
		return
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
	
	if TFAWW_Resists and TFAWW_Resists(tgt) then -- Horde: bosses and elites aren't stunned
	elseif tgt:IsNextBot() then
		local oldThread = tgt.BehaveThread
		tgt.BehaveThread = coroutine.create(function() -- Make the nextbot do nothing for 3 seconds
			coroutine.wait(3.2)
			tgt.BehaveThread = oldThread
		end)
		--tgt.loco:SetDesiredSpeed(0)
	elseif tgt:IsNPC() then
		tgt:SetSchedule(SCHED_NPC_FREEZE)
	end
	
	self:EmitSound(self.CollideSound)
	
	if engine.ActiveGamemode() == "nzombies" and self.Upgraded then
		self:SetTargetPriority(TARGET_PRIORITY_PLAYER)
		UpdateAllZombieTargets(self)
	end
end

function ENT:Explosion()
	if self.Exploded then return end
	self.Exploded = true
	
	ParticleEffect("acidgat_explode", self:GetPos(), angle_zero, nil)
	self:EmitSound(")weapons/us_bomb_explo_2.ogg", 100, 100, 0.8, CHAN_WEAPON)
	self:EmitSound("weapons/blundergat/acidgat_explo-0"..math.random(1,4)..".mp3", 80) -- visual and sound effects
	util.ScreenShake(self:GetPos(), 1, 8, 0.3, 512)
	
	local parent = self:GetParent()
	if self.Upgraded and IsValid(parent) and parent:GetInternalVariable("m_takedamage") == 2 then
		if not HORDE then parent:SetHealth(1) end
	end
	
	local dmg = DamageInfo() -- determine damage
	dmg:SetDamageType(DMG_ACID)
	dmg:SetInflictor(self)
	dmg:SetAttacker(self.Owner)
	dmg:SetDamage(self.Upgraded and 1500 or 500)
	
	util.BlastDamage(self, self.Owner, self:GetPos(), 128, 30) -- do damage
	for k,v in pairs(ents.FindInSphere(self:GetPos(), 128)) do
		if !v:IsPlayer() then
			v:TakeDamageInfo(dmg)
		end
	end
	SafeRemoveEntity(self)
end

function ENT:OnRemove()
	self:StopSound(self.FuseSound)
	local parent = self:GetParent()
	if IsValid(parent) and parent:IsNPC() then
		parent:SetCondition(COND.NPC_UNFREEZE)
	end
end