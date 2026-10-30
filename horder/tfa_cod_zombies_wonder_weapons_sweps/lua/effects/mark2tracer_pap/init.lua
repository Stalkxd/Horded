function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	-- Keep the start and end pos - we're going to interpolate between them
	self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	self.EndPos = data:GetOrigin()
	
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
		else
			self.WeaponEnt = own:GetViewModel()
		end
	end
	
	if !IsValid(self.WeaponEnt) or self.WeaponEnt:EntIndex() == -1 then 
		self:Remove()
		return 
	end
end

function EFFECT:Think()
	util.ParticleTracerEx("raygun2_tracer_pap", self.StartPos, self.EndPos, false, self.WeaponEnt:EntIndex(), 1)
	ParticleEffect("raygun2_impact_pap", self.EndPos, angle_zero)
	
	sound.Play("Weapon_Raygun2.Impact", self.EndPos)
	
	return false
end

function EFFECT:Render()
end


--[[EFFECT.Mat = Material("particle/particle_glow_04_additive")
EFFECT.Col1 = Color(33, 255, 0) --Color(225,225,225,225)
EFFECT.Col2 = Color(127, 255, 0)
EFFECT.Speed = 8194
EFFECT.TracerLength = 256

function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	-- Keep the start and end pos - we're going to interpolate between them
	self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	self.EndPos = data:GetOrigin()
	self.Normal = (self.EndPos - self.StartPos):GetNormalized()
	self.Length = (self.EndPos - self.StartPos):Length()
	--self.Alpha = 255
	self.Life = 0
	self.MaxLife = self.Length / self.Speed
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
	self.CurPos = self.StartPos
	
	ParticleEffect("raygun2_impact_pap", self.EndPos, angle_zero)
	
	sound.Play("Weapon_Raygun2.Impact", self.EndPos)
end

function EFFECT:Think()
	self.Life = self.Life + FrameTime() * (1 / self.MaxLife)
	--self.Alpha = 255 * ( 1 - self.Life )

	return self.Life < 1
end

local lerpedcol = Color(225, 225, 225, 225)

function EFFECT:Render()
render.SetMaterial(self.Mat)
lerpedcol.r = Lerp(self.Life, self.Col1.r, self.Col2.r)
lerpedcol.g = Lerp(self.Life, self.Col1.g, self.Col2.g)
lerpedcol.b = Lerp(self.Life, self.Col1.b, self.Col2.b)
lerpedcol.a = Lerp(self.Life, self.Col1.a, self.Col2.a)
local startbeampos = Lerp(self.Life, self.StartPos, self.EndPos)
local endbeampos = Lerp(self.Life + self.TracerLength / self.Length, self.StartPos, self.EndPos)
render.DrawBeam(startbeampos, endbeampos, 8, 0, 1, lerpedcol)
end]]