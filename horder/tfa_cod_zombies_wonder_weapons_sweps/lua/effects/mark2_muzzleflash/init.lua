function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	
	local own
	if IsValid(self.WeaponEnt) then
		own = self.WeaponEnt:GetOwner()
	end
	if !IsValid(own) then
		own = self.WeaponEnt:GetParent()
	end
	
	if IsValid(own) and own:IsPlayer() then
		if own ~= LocalPlayer() or own:ShouldDrawLocalPlayer() then
			self.WeaponEnt = data:GetEntity()
			if !IsValid(self.WeaponEnt) then return end
		else
			self.WeaponEnt = own:GetViewModel()
			if !IsValid(self.WeaponEnt) then return end
		end
	end
	
	ParticleEffectAttach("raygun2_muzzle", PATTACH_POINT_FOLLOW, self.WeaponEnt, 1)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

--[[local AddVel = Vector()
local ang

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end
	self.Attachment = data:GetAttachment()
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)

	if IsValid(self.WeaponEnt.Owner) then
		if self.WeaponEnt.Owner == LocalPlayer() then
			if self.WeaponEnt.Owner:ShouldDrawLocalPlayer() then
				ang = self.WeaponEnt.Owner:EyeAngles()
				ang:Normalize()
				--ang.p = math.max(math.min(ang.p,55),-55)
				self.Forward = ang:Forward()
			else
				self.WeaponEnt = self.WeaponEnt.Owner:GetViewModel()
			end
			--ang.p = math.max(math.min(ang.p,55),-55)
		else
			ang = self.WeaponEnt.Owner:EyeAngles()
			ang:Normalize()
			self.Forward = ang:Forward()
		end
	end

	self.Forward = self.Forward or data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.vOffset = self.Position
	dir = self.Forward

	if IsValid(LocalPlayer()) then
		AddVel = LocalPlayer():GetVelocity()
	end

	AddVel = AddVel * 0.05
	self.vOffset = self.Position
	dir = self.Forward
	AddVel = AddVel * 0.05
	local dot = dir:GetNormalized():Dot(EyeAngles():Forward())
	local dotang = math.deg(math.acos(math.abs(dot)))
	local halofac = math.Clamp(1 - (dotang / 90), 0, 1)

	if CLIENT and not IsValid(ownerent) then
		ownerent = LocalPlayer()
	end

	local dlight = DynamicLight(ownerent:EntIndex())

	if (dlight) then
		dlight.pos = self.vOffset - ownerent:EyeAngles():Right() * 5 + 1.05 * ownerent:GetVelocity() * FrameTime()
		dlight.r = 25
		dlight.g = 255
		dlight.b = 75
		dlight.brightness = 5
		dlight.Decay = 1000
		dlight.Size = 96
		dlight.DieTime = CurTime() + 0.5
	end

	local emitter = ParticleEmitter(self.vOffset)
	local sparticle = emitter:Add("particle/particle_glow_04_additive", self.vOffset)

	if (sparticle) then
		sparticle:SetVelocity(dir * 4 + 1.05 * AddVel)
		sparticle:SetLifeTime(0)
		sparticle:SetDieTime(0.08)
		sparticle:SetStartAlpha(math.Rand(200, 255))
		sparticle:SetEndAlpha(0)
		--particle:SetStartSize( 8 * (halofac*0.8+0.2), 0, 1)
		--particle:SetEndSize( 0 )
		sparticle:SetStartSize(4 * (halofac * 0.8 + 0.2), 0, 1)
		sparticle:SetEndSize(12 * (halofac * 0.8 + 0.2), 0, 1)
		local r = math.Rand(-10, 10) * 3.14 / 180
		sparticle:SetRoll(r)
		sparticle:SetRollDelta(r / 5)
		sparticle:SetColor(0, 255, 63)
		sparticle:SetLighting(false)
		sparticle.FollowEnt = self.WeaponEnt
		sparticle.Att = self.Attachment
		TFA.Particles.RegisterParticleThink(sparticle, TFA.Particles.FollowMuzzle)
		sparticle:SetPos(vector_origin)
	end

	for i = 1, 1 do
		local particle = emitter:Add("particle/particle_glow_04_additive", self.vOffset)

		if (particle) then
			particle:SetVelocity(dir * 4 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.10)
			particle:SetStartAlpha(math.Rand(225, 255))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(6 * (halofac * 0.8 + 0.2), 0, 1)
			particle:SetEndSize(12 * (halofac * 0.8 + 0.2))
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(-40, 40)))
			particle:SetColor(33, 255, 0)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFA.Particles.RegisterParticleThink(particle, TFA.Particles.FollowMuzzle)
		end
	end

	for i = 0, 5 do
		local particle = emitter:Add("particle/fire", self.vOffset + (dir * 0.6 * i))

		if (particle) then
			particle:SetVelocity((dir * 19 * i) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.075)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( math.max(5.4 - 0.55 * i,1) )
			--particle:SetEndSize( 0 )
			particle:SetStartSize(math.max(6 - 0.65 * i, 1) * 0.55)
			particle:SetEndSize(math.max(5.4 - 0.55 * i, 1) * 1.25)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(-40, 40)))
			particle:SetColor(127, 255, 0)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFA.Particles.RegisterParticleThink(particle, TFA.Particles.FollowMuzzle)
			particle:SetPos(vector_origin)
		end
	end


	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
]]