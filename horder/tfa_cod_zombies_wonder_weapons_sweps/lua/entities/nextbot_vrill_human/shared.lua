if (SERVER) then AddCSLuaFile("shared.lua")end
----------------------------------------------
ENT.Base     	= "base_nextbot"
ENT.Spawnable	= false
ENT.NextScream = 0
ENT.ExplodeTimer = 0
ENT.DieTimer = 0
ENT.RemoveTimer = 0
--ENT.OurHealth = 40
ENT.StuckAttempts = 0
ENT.TargetPos = vector_origin

--local damageareas = {}
local waterareas = {}
local navmeshchecked = false


if CLIENT then language.Add("nextbot_vrill_human","Suited guy") end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")
end

function ENT:Initialize()
	self:SetCollisionBounds(Vector(-8,-8,0), Vector(8,8,72))
	--self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self:SetHealth(150)
	self:SetModel("models/weapons/black_ops_1/vr11/cia_guy.mdl")
	if self.SetTargetPriority then
		self:SetTargetPriority(self:GetUpgraded() and TARGET_PRIORITY_SPECIAL or TARGET_PRIORITY_PLAYER)
	end
	if SERVER then 
		self.loco:SetStepHeight(16)
		self.loco:SetAcceleration(960)
		self.loco:SetDeceleration(960)
		self.loco:SetMaxYawRate(210)
		self.loco:SetAvoidAllowed(true)
		self:SetSolidMask(MASK_NPCSOLID)
	end
	--self.stucktrdata.filter = self
end

function ENT:RunBehaviour()
	ParticleEffectAttach(self:GetUpgraded() and "vr11_aura_pap" or "vr11_aura", PATTACH_POINT_FOLLOW, self, 3)
	self:PlaySequenceAndWait("react")
	
	self.loco:SetDesiredSpeed(180)
	self:StartActivity(ACT_RUN_PROTECTED)
	self:RunToWater(false, {tolerance = 16})
	
	if self:WaterLevel() < 2 then
		if self:GetUpgraded() then
			self.ExplodeTimer = CurTime() + 8.25
		else
			self.DieTimer = CurTime() + 8.25
		end
		self:EmitSound("weapons/humangun/effects/timer.ogg", 70, 100, 1, CHAN_AUTO, SND_SHOULDPAUSE)
	end
		
	while navmesh.IsLoaded() do
		self:StartActivity(ACT_RUN)
		self:RunAimlessly(100,1000, {tolerance = 64})
		coroutine.wait(0.1)
	end 
	self:Explode()
end

function ENT:RunAimlessly(mindist, maxdist, options)
	local pos = VectorRand(-maxdist, maxdist)
	pos = pos + (pos/mindist)
	pos.z = 0
	
	for i = 0, 20 do -- Game would crash if this position was out of bounds every time.
		if util.IsInWorld(self:GetPos() + pos) then
			break
		else
			pos = VectorRand(-maxdist, maxdist)
			pos = pos + (pos/mindist)
			pos.z = 0
		end
	end
	if util.IsInWorld(self:GetPos() + pos) then
		self:MoveToPos(self:GetPos() + pos, options)
		self.TargetPos = self:GetPos() + pos
		return true
	else
		return false
	end
end

function ENT:CheckForWater()
	local tempareas = navmesh.Find( self:GetPos(), 2048, 16, 512 )
	for k, v in pairs(tempareas) do
		if v:IsUnderwater() then
			table.insert(waterareas, v:GetID(), v)
		--elseif v:IsDamaging() then
			--table.insert(waterareas, v:GetID(), v)
		end
	end
end
function ENT:RunToWater(haschecked, options)
	--[[if !table.IsEmpty(damageareas) then
		for k, v in pairs(damageareas) do
			if self:GetRangeSquaredTo(v:GetCenter()) < 2048^2 then
				self:MoveToPos(v:GetCenter())
				self.TargetPos = v:GetCenter()
				return true
			end
		end
	end]]
	if !table.IsEmpty(waterareas) then
		for k, v in pairs(waterareas) do
			if self:GetRangeSquaredTo(v:GetCenter()) < 2048^2 then
				self:MoveToPos(v:GetCenter(), options)
				self.TargetPos = v:GetCenter()
				return true
			end
		end
	end
	
	if !haschecked then
		self:CheckForWater()
		self:RunToWater(true, {tolerance = 16})
	end
end

function ENT:OnNavAreaChanged(old, new)
	if new:IsUnderwater() then
		self.loco:SetDesiredSpeed(128)
	else
		self.loco:SetDesiredSpeed(180)
	end
	
	if self:WaterLevel() == 3 then
		self:StopSound("Weapon_VR11.Scream")
	end
end

function ENT:OnLandOnGround(ent)
	if self:Health() <= 0 then return end
	if self.VerticalSpeed < -340 then
		local backupthread = self.BehaveThread
		self.BehaveThread = coroutine.create(function()
			self.loco:SetDesiredSpeed(0)
			self.loco:SetMaxYawRate(0)
			self:PlaySequenceAndWait("land_hard")
			self:StartActivity(ACT_RUN)
			self.loco:SetDesiredSpeed(180)
			self.loco:SetMaxYawRate(180)
			self.BehaveThread = backupthread
		end)
	elseif self.VerticalSpeed < -256 then
		local backupthread = self.BehaveThread
		self.BehaveThread = coroutine.create(function()
			self.loco:SetDesiredSpeed(8)
			self.loco:SetMaxYawRate(0)
			self:PlaySequenceAndWait("land_light")
			self:StartActivity(ACT_RUN)
			self.loco:SetDesiredSpeed(180)
			self.loco:SetMaxYawRate(210)
			self.BehaveThread = backupthread
		end)
	else
		self:StartActivity(ACT_RUN)
	end
end

function ENT:Think()
	if self.ExplodeTimer != 0 and self.ExplodeTimer < CurTime() then
		self:Explode()
		return
	end
	if self.DieTimer != 0 and self.DieTimer < CurTime() and self:Alive() then
		self:TakeDamage(500)
		return
	end
	if self.RemoveTimer != 0 and self.RemoveTimer < CurTime() then
		self:Remove()
		return
	end
	
	if SERVER then
		if !self:OnGround() and self:Health() > 0 then
			if self.loco:GetVelocity().z < 64 and self:GetActivity() != ACT_HOVER then
				self:StartActivity(ACT_HOVER)
			end
			self.VerticalSpeed = self.loco:GetVelocity().z
		end

		self:Scream()
		if self:WaterLevel() > 1 then
			self:TakeDamage(1)
		end
	end
end


local disappear = bit.bor(DMG_DISSOLVE, DMG_REMOVENORAGDOLL)
local xplodeimmediately = bit.bor(DMG_CRUSH, DMG_FALL, DMG_BLAST, DMG_SONIC, DMG_ALWAYSGIB)
function ENT:OnKilled(dmginfo)
	self:StopSound("Weapon_VR11.Scream")
	self:StopSound("weapons/humangun/effects/timer.ogg")
	
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	
	if dmginfo:IsDamageType(disappear) then 
		self:Remove()
		return 
	end
	if dmginfo:IsDamageType(xplodeimmediately) then 
		self:Explode()
		return 
	end
	self:StopParticles()
	self.BehaveThread = coroutine.create(function()
		if self:WaterLevel() == 3 then
			self:StartActivity(ACT_SWIM)
			self:EmitSound("player/h2odeath.wav")
			ParticleEffectAttach("vr11_drown", PATTACH_POINT_FOLLOW, self, 4)
		else
			self:StartActivity(ACT_DIE_GUTSHOT)
		end
		self.NextScream = CurTime() + 20
		if self:GetUpgraded() then
			self.ExplodeTimer = CurTime() + self:SequenceDuration()
			coroutine.wait(self:SequenceDuration())
		else
			self.ExplodeTimer = CurTime() + 10
			self.RemoveTimer = CurTime() + 7
			if self.SetTargetPriority then
				self:SetTargetPriority(TARGET_PRIORITY_NONE)
			end
			coroutine.wait(7)
		end
	end)
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true
	
	self:StopSound("Weapon_VR11.Scream")
	self:StopSound("weapons/humangun/effects/timer.ogg")
	ParticleEffect("vr11_gore", self:GetPos(), angle_zero)
	self:EmitSound("weapons/humangun/effects/explode_0"..math.random(0,2)..".ogg", 80)
	self:EmitSound("weapons/humangun/effects/us_bomb_explo_2.ogg", 90, 100, 1, CHAN_WEAPON)
	if SERVER then
		for k,v in pairs(ents.FindInSphere(self:GetPos(),256)) do
			if v:IsPlayer() or v == self then continue end
			local dmg = 900
			if self:GetUpgraded() then
				dmg = string.find(v:GetClass(), "nz_zombie_boss") and v:Health()/3 or v:Health()
			end
			v:TakeDamage(dmg, self.Owner, self)
		end
	end
	
	self:Remove()
end

function ENT:Scream()
	if CurTime() < self.NextScream then return end
	self.NextScream = CurTime() + math.random(3,5)
	if self:WaterLevel() == 3 then return end
	self:EmitSound("Weapon_VR11.Scream")
end