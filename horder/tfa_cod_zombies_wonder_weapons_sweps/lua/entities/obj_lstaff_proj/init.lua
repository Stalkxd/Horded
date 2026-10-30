AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.CollidePCF = "originstaff_lightning_impact"

ENT.CollideSND = {
	"weapons/originstaffs/lightning/lightning_flash_0.ogg",
	"weapons/originstaffs/lightning/lightning_flash_1.ogg",
	"weapons/originstaffs/lightning/lightning_flash_2.ogg",
}

ENT.Damage = 1150

function ENT:Think()
	if CurTime() > self.LifeTime then 
		self:Remove()
		return
	end
	
	if self:GetCharge() > 1 then
		for k, v in ipairs(ents.FindInSphere(self:GetPos(), 128)) do
			if v:GetInternalVariable("m_takedamage") < 1 then continue end
			if !v:IsPlayer() and !v:IsNPC() and !v:IsNextBot() then continue end
			if v:IsPlayer() and (v == self.Owner or !hook.Run("PlayerShouldTakeDamage",v,self.Owner)) then continue end
			
			self:ZapTarget(v, true)
		end
		self:NextThink(CurTime()+0.2)
		return true
	end
end

function ENT:ZapTarget(target, fx)
	if target:Health() < 0 then
		if target.Kill then target:Kill() end
		return
	end

	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self.Owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamage(self.Damage + math.max(self:GetCharge() - 1, 0) * 10000)
	dmginfo:SetDamageType(bit.bor(DMG_SHOCK, DMG_DISSOLVE))
	dmginfo:SetDamagePosition(target:WorldSpaceCenter())
	dmginfo:SetDamageForce(Vector(0, 0, 1000))
	
	target:TakeDamageInfo(dmginfo)
	
	if fx then
		util.ParticleTracerEx("originstaff_lightning_ultimate_arc", self:GetPos(), target:WorldSpaceCenter(), true, 1, 1)
		target:EmitSound("weapons/originstaffs/lightning/victim_shocked.mp3")
	end
end

local hitMaxs = Vector(25, 25, 25)

function ENT:StartTouch(ent)
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	if self:GetMoveType() == MOVETYPE_NONE then return false end
	
	ParticleEffect(self.CollidePCF, data.HitPos, self:GetAngles())
	
	if self:GetCharge() > 1 then
		if ent:IsWorld() then
			self:UltimateAbility(data.HitPos)
		end
		return
	end
	
	self:EmitSound(self.CollideSND[math.random(3)], 130)
    self:StopParticles()
    self:SetMoveType(MOVETYPE_NONE)
	
	--for k, v in ipairs(ents.FindInSphere(data.HitPos, 50)) do
	for k, v in ipairs(ents.FindInBox(data.HitPos - hitMaxs, data.HitPos + hitMaxs)) do
		if v:GetInternalVariable("m_takedamage") < 1 then continue end
		if v:IsPlayer() and (v == self.Owner or !hook.Run("PlayerShouldTakeDamage",v,self.Owner)) then continue end
		
		self:ZapTarget(v, false)
	end
	
	SafeRemoveEntity( self )
	return true
end

function ENT:UltimateAbility(pos)
	self:SetMoveType(MOVETYPE_NONE)
	self:EmitSound("weapons/originstaffs/lightning/wpn_lightning_ball_explo.ogg")
	util.ScreenShake(pos, 3, 4, (self:GetCharge()-1) * 5 + 5, 256)
end

function ENT:OnRemove()
	self:StopSound("weapons/originstaffs/lightning/lightning_ball_01.wav")
	self:StopParticles()
end