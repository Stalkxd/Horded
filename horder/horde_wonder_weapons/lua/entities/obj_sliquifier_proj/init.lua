AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.MaxChain = 12

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
end

function ENT:StartTouch(ent)
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	if self:GetMoveType() == MOVETYPE_NONE then return false end
	
	if ent:IsWorld() then
		if data.HitNormal.z >= 0.5 then
			self:ExplodeGround(data.HitPos - data.HitNormal*3, data.HitNormal)
		else
			self:ExplodeWall(data.HitPos, data.HitNormal)
		end
	elseif HORDE_WW.IsHostile(self.Owner, ent) then
		self:ExplodeEnemy(ent)
	elseif ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
		-- Fly through teammates and their minions instead of wasting the shot on them
		return false
	else
		self:ExplodeWall(data.HitPos, data.HitNormal)
	end
	
	return true
end

function ENT:ExplodeGround(pos, normal)
	self:CreatePuddle(pos, normal)
	self.CreatedPuddle = true
	self:StopParticles()
	self:SetMoveType(MOVETYPE_NONE)
	
	self:EmitSound("weapons/slipgun/slipgun_splash_0"..math.random(0,1)..".ogg")
	ParticleEffect( self.ImpactParticle..self.ParticleSuffix, pos, angle_zero )
	
	self:ExplodeCommon(pos)
end
function ENT:ExplodeWall(pos, normal)
	self:EmitSound("weapons/slipgun/slipgun_splash_0"..math.random(0,1)..".ogg")
	ParticleEffect( self.ImpactParticle..self.ParticleSuffix, pos, angle_zero )
	
	local oldvel = self:GetVelocity()
	local vFlipped = oldvel - 2*(oldvel * normal)*normal
	self:SetVelocity(-oldvel/2)
	
	self:ExplodeCommon(pos)
end
function ENT:ExplodeEnemy(ent)
	self.Exploded = true
	
	local tr = util.QuickTrace(ent:GetPos(), -vector_up*64, ent)
	self.CreatedPuddle = true
	if tr.HitWorld then
		self:CreatePuddle(tr.HitPos + tr.HitNormal, tr.HitNormal)
	end
	
	self:SplashTarget(ent)
	timer.Create(self:EntIndex().."sliquifier", 0.5, self.MaxChain-1, function()
		self:SplashNearbyTarget(self.LastSplashPos)
	end)
	
	self:StopParticles()
	self:SetMoveType(MOVETYPE_NONE)
end

-- A floor or wall hit splashes the nearest enemy, once. It used to do nothing
-- until the goo had already burst on an enemy, so most near misses did no damage.
function ENT:ExplodeCommon(pos)
	if self.Exploded then return end
	
	local closestent = self:FindNearestTarget(pos)
	if IsValid(closestent) then
		local tr = util.QuickTrace(closestent:GetPos(), -vector_up*64, closestent)
		if tr.HitWorld and !self.CreatedPuddle then
			self:CreatePuddle(tr.HitPos, tr.HitNormal)
			self.CreatedPuddle = true
		end
		
		self:SplashTarget(closestent)
		timer.Create(self:EntIndex().."sliquifier", 0.5, self.MaxChain-1, function()
			self:SplashNearbyTarget(self.LastSplashPos)
		end)
	end
	self.Exploded = true
end

function ENT:FindNearestTarget(pos)
	local closestent = {Distance = 16641, Entity = nil}
	for k, v in pairs(ents.FindInSphere(pos, 128)) do
		if HORDE_WW.IsHostile(self.Owner, v) then
			local dist = v:WorldSpaceCenter():DistToSqr(pos)
			if dist < closestent.Distance then
				closestent.Distance = dist
				closestent.Entity = v
			end
		end
	end
	return closestent.Entity
	
	--[[local nearbyents = {}
	for k, v in pairs(ents.FindInSphere(pos, 128)) do
		if (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then
			table.insert(nearbyents, v:GetPos():DistToSqr(pos), v)
		end
	end
	for i = 0, table.maxn(nearbyents) do
		if IsValid(nearbyents[i*i]) then
			return nearbyents[i*i]
		end
	end]]
end

function ENT:FindNearbyTarget(pos)
	for k, v in pairs(ents.FindInSphere(pos, 128)) do
		if HORDE_WW.IsHostile(self.Owner, v) and !self.OldTargets[v:GetCreationID()] then
			return v
		end
	end
end

function ENT:Think()
	if CurTime() > self.LifeTime then
		self:Remove()
		return
	end
end

function ENT:SplashTarget(tgt)
	ParticleEffectAttach(self.PopParticle..self.ParticleSuffix, PATTACH_ABSORIGIN_FOLLOW, tgt, 1)
	tgt:EmitSound("weapons/slipgun/zmb_slip_imp_0"..math.random(0,1)..".ogg")
	
	self.LastSplashPos = tgt:WorldSpaceCenter()
	table.insert(self.OldTargets, tgt:GetCreationID(), tgt)
	
	self:DamageTarget(tgt)
end

-- Hits land on the target's body with the shooter as attacker, so hit markers
-- and damage number addons show them.
function ENT:DamageTarget(tgt)
	if !IsValid(self.Owner) then return end
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(5500000)
	dmginfo:SetAttacker(self.Owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_ACID)
	dmginfo:SetDamagePosition(tgt:WorldSpaceCenter())
	dmginfo:SetReportedPosition(self:GetPos())
	dmginfo:SetDamageForce(vector_up * 100)
	tgt:TakeDamageInfo(dmginfo)
end

function ENT:SplashNearbyTarget(pos)
	local closestent = self:FindNearbyTarget(pos)
	
	if IsValid(closestent) then
		ParticleEffectAttach(self.PopParticle..self.ParticleSuffix, PATTACH_ABSORIGIN_FOLLOW, closestent, 1)
		closestent:EmitSound("weapons/slipgun/zmb_slip_imp_0"..math.random(0,1)..".ogg")
		
		self.LastSplashPos = closestent:WorldSpaceCenter()
		table.insert(self.OldTargets, closestent:GetCreationID(), closestent)
		
		self:DamageTarget(closestent)
		
		self.LifeTime = CurTime() + 0.6
	else
		timer.Remove(self:EntIndex().."sliquifier")
		--self:Remove()
	end
end

function ENT:CreatePuddle(pos, normal)
	local puddle = ents.Create("obj_sliquifier_puddle")
	puddle:SetPos(pos)
	puddle:SetAngles(normal:Angle() + Angle(90,0,0))
	puddle.Owner = self.Owner
	puddle:SetUpgraded(self:GetUpgraded())
	puddle:SetFunny(self:GetFunny())
	puddle:Spawn()
	puddle:Activate()
end

function ENT:OnRemove()
	timer.Remove(self:EntIndex().."sliquifier")
end