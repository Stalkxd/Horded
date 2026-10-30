AddCSLuaFile()
AddCSLuaFile("cl_init.lua")
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false

ENT.CollidePCF = "originstaff_fire_impact"	
ENT.Damage = 334
ENT.Charge = 0
--ENT.MoveSpeed = 3500
function ENT:Initialize()
	self:SetModel("models/props_junk/rock001a.mdl")
	self:SetMaterial("models/weapons/black_ops_2/staffs/fire_proj")
	--self:PhysicsInit(SOLID_VPHYSICS)
	self:PhysicsInitBox( Vector(-4, -4, -4), Vector(4, 4, 4) )
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	--self:SetSolid(SOLID_VPHYSICS)
	self:SetSolidFlags(FSOLID_NOT_STANDABLE)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	self:EmitSound("weapons/originstaffs/fire/projectile/loop.wav", 70)
	self.UltSound = CreateSound(self, "weapons/originstaffs/fire/fire_staff_volcano.wav")
	ParticleEffectAttach( "originstaff_fire_proj", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	
	self.PhysTrace = {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetVelocity()*engine.TickInterval(),
		filter = {self, self.Owner},
		mask = MASK_SHOT
	}
	
	self.LifeTime = CurTime() + 4
	
	if CLIENT then return end
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
		phys:Wake()
		phys:AddAngleVelocity(Vector(math.random(-256,256), math.random(-256,256), math.random(-256,256)))	
	else
		self:Remove()
	end
	
	self.DmgInfo = DamageInfo()
	self.DmgInfo:SetDamage( self.Charge > 0 and 300000 or self.Damage)
	self.DmgInfo:SetAttacker(self.Owner)
	self.DmgInfo:SetDamageForce(vector_origin)
	self.DmgInfo:SetDamageType(DMG_BURN)
	self.DmgInfo:SetInflictor(self)
end

function ENT:OnCollide(ent, hitpos)
	if self.DoRemove then return end
	if self.Owner == ent then return true end
	if self:GetMoveType() == MOVETYPE_NONE then return end
	if self.Charge > 1 then self:UltimateAbility(hitpos); return end
	
	self.DoRemove = true
	--self:PhysicsDestroy()
	self.DmgInfo:SetDamagePosition(self:GetPos())
	
	for _,v in pairs(ents.FindInSphere(hitpos,65)) do
		if v:Health() < 1 then continue end
		if v:IsPlayer() and (v == self.Owner or !hook.Run("PlayerShouldTakeDamage",v,self.Owner)) then continue end
		
		--[[if string.StartsWith(v:GetClass(), "nz_zombie_boss") then
			self.DmgInfo:SetDamage(335)
			v:TakeDamageInfo(self.DmgInfo)
			self.DmgInfo:SetDamage(self.Damage)
			continue
		end]]
		
		v:TakeDamageInfo(self.DmgInfo)
	end
	
	self:EmitSound("weapons/originstaffs/fire/projectile/explo/proj_explo_"..math.random(0,2)..".ogg", 360)
	ParticleEffect(self.CollidePCF, hitpos, self:GetAngles())
	
	SafeRemoveEntityDelayed(self,0)
	
	return true
end

function ENT:PhysicsCollide(data)
	self:OnCollide(data.HitEntity, data.HitPos)
end

function ENT:PhysicsUpdate(phys)
	self.PhysTrace.start = self:GetPos()
	self.PhysTrace.endpos = self:GetPos() + self:GetVelocity()*engine.TickInterval()
	
	local tr = util.TraceLine(self.PhysTrace)
	if tr.Hit then
		self:OnCollide(tr.Entity, tr.HitPos)
	end
end

function ENT:Think()
	if self.LifeTime and CurTime() > self.LifeTime then 
		SafeRemoveEntityDelayed(self, 1)
		self.UltSound:FadeOut(1)
	end
	if self.Charge > 1 and self:GetMoveType() == MOVETYPE_NONE then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 128)) do
			if v:IsPlayer() and (v == self.Owner or !hook.Run("PlayerShouldTakeDamage",v,self.Owner)) then continue end
			if v:Health() <= 0 then 
				if v:GetInternalVariable("m_takedamage") > 0 and v.Kill then v:Kill() end
				continue 
			end
			v:TakeDamageInfo(self.DmgInfo)
		end
		self:NextThink(CurTime() + 0.2)
		return true
	end
	
end

function ENT:OnRemove()
	self:StopSound("weapons/originstaffs/fire/projectile/loop.wav")
	if self.UltSound then self.UltSound:Stop() end
	self:StopParticles()
end

function ENT:UltimateAbility(pos)
	if SERVER then
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
	self:SetPos(pos)
	self:SetAngles(Angle(0,math.random(0,270),0))
	self:StopParticles()
	self:StopSound("weapons/originstaffs/fire/projectile/loop.wav")
	self:EmitSound("weapons/originstaffs/fire/upgraded_imp.ogg")
	if self.UltSound then self.UltSound:Play() end
	self.LifeTime = CurTime() + self.Charge * 5
	util.ScreenShake( pos, 3, 4, self.Charge * 5 + 5, 256 )
	ParticleEffectAttach( "originstaff_fire_ultimate", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end