AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

--ENT.CollidePCF = "tesla_impact"
ENT.MaxChain = 10
ENT.ZAPRANGE = 256
ENT.HasCollided = false

local isNzombies = engine.ActiveGamemode():lower() == "nzombies"

function ENT:Initialize()
	self:EnableCustomCollisions(true)
	self:SetModel("models/error.mdl")
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_FLY)
	self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))
 
	self:SetNoDraw(true)
	self:DrawShadow(false)
	
	self:EmitSound("weapons/tesla_gun/projectile/proj_loop.wav")
	ParticleEffectAttach( self:GetUpgraded() and "tesla_beam_pap" or "tesla_beam", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	
	self.dmginfo = DamageInfo()
	self.dmginfo:SetDamageType(DMG_SHOCK)
	self.dmginfo:SetAttacker(self.Owner)
	self.dmginfo:SetInflictor(self)
	self.dmginfo:SetDamageForce(Vector(2,2,8))
	self.dmginfo:SetDamage(50)
end

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
	
	self:OnCollide(ent, data.HitPos)
	self.HasCollided = true
end

function ENT:OnCollide(ent, pos)
	if self.HasCollided then return end
	self.HasCollided = true
	
	self:StopSound("weapons/tesla_gun/projectile/proj_loop.wav")
	if self:WaterLevel() > 1 then
		self:EmitSound("weapons/tesla_gun/projectile/proj_impact_water.mp3")
	else
		self:EmitSound("weapons/tesla_gun/projectile/proj_impact.mp3")
	end
	--ParticleEffect( self.CollidePCF, pos, self:GetAngles() )
	self:StopParticles()
	
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	if self.Owner:GetPos():DistToSqr(self:GetPos()) < 5184 then
		self.dmginfo:SetDamage(50)
		self.dmginfo:SetDamagePosition(self.Owner:WorldSpaceCenter())
		self.Owner:TakeDamageInfo(self.dmginfo)
	end
	
	if !ent:IsNPC() and !ent:IsNextBot() then
		self.dmginfo:SetDamage(50)
		self.dmginfo:SetDamagePosition(ent:WorldSpaceCenter())
		ent:TakeDamageInfo(self.dmginfo)
	end
	
	self.lastTargetPos = self:GetPos()
	local target = self:FindNearestEntity(self.lastTargetPos)
	
	if !IsValid(target) then
		SafeRemoveEntity(self)
		return
	end
	
	self:Zap(self.lastTargetPos, target)
	self:EmitSound("weapons/tesla_gun/wpn_tesla_flux.mp3", 80)
	
	local killcount = 1
	
	local timername = self:EntIndex().."wunderwaffetimer"
	
	timer.Create(timername, 0.25, self.MaxChain - 1, function()
		target = self:FindNearestEntityCheap(self.lastTargetPos)
		if !IsValid(target) then
			timer.Stop(timername)
			timer.Remove(timername)
			SafeRemoveEntity(self)
			return
		end
		
		self.ZAPRANGE = self.ZAPRANGE - 20
		self:Zap(self.lastTargetPos, target)
		
		if self:WaterLevel() > 1 then
			self:EmitSound("weapons/tesla_gun/projectile/proj_impact_water.mp3")
		else
			self:EmitSound("weapons/tesla_gun/projectile/proj_impact.mp3")
		end
		killcount = killcount + 1
		if killcount == 5 then
			self.Owner:EmitSound("weapons/tesla_gun/happy/happy_0"..math.random(0,3)..".ogg", 75, 100, 1, CHAN_WEAPON )
			killcount = 0
		end
	end)
end

function ENT:Zap(lastTargetPos, target)
	if string.find( target:GetClass(), "boss", 1, true) then
		self.dmginfo:SetDamage(1000)
	else
		self.dmginfo:SetDamage(2147483647)
	end
	
	local att
	if target:GetAttachment(2) then
		att = target:GetAttachment(2).Pos
	else
		att = target:GetPos() + target:OBBCenter()
	end
	util.ParticleTracerEx( "tesla_jump", lastTargetPos, att, true, 1, 1 ) 
	
	if self:GetUpgraded() then
		ParticleEffectAttach( "tesla_electrocute_pap", PATTACH_POINT_FOLLOW, target, 2)
		if target:OnGround() then
			ParticleEffectAttach( "tesla_electrocute1_pap", PATTACH_ABSORIGIN_FOLLOW, target, 0)
		end
		--target:SetNWBool("waffeshockedpap", true)
	else
		ParticleEffectAttach( "tesla_electrocute", PATTACH_POINT_FOLLOW, target, 2)
		if target:OnGround() then
			ParticleEffectAttach( "tesla_electrocute1", PATTACH_ABSORIGIN_FOLLOW, target, 0)
		end
		--target:SetNWBool("waffeshocked", true)
	end
	
	target:EmitSound("weapons/tesla_gun/bounce/bounce_0"..math.random(0,1)..".mp3")
	target:EmitSound("sfx/levels/zombie/maps/asylum/traps/zom_arc/zom_arc_0"..math.random(0,1)..".ogg", 75, 100, 1, CHAN_ITEM)
	
	self.lastTargetPos = att
	self.dmginfo:SetDamagePosition(att)
	target:TakeDamageInfo(self.dmginfo)
end

function ENT:FindNearestEntity(pos)
	local closestent = {Distance = 16641, Entity = nil}
	for k, v in ipairs(ents.FindInSphere(pos, 128)) do
		if (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then
			local dist = v:WorldSpaceCenter():DistToSqr(pos)
			if dist < closestent.Distance then
				closestent.Distance = dist
				closestent.Entity = v
			end
		end
	end
	return closestent.Entity
end

function ENT:FindNearestEntityCheap(pos)
	for k, v in pairs(ents.FindInSphere(pos, self.ZAPRANGE)) do
		if (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then
			return v
		end
	end
end