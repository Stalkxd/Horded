EFFECT.Life      = 0.085
EFFECT.HeatSize  = 0.70
EFFECT.FlashSize = 0.70

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	--self.WeaponEntOG = self.WeaponEnt
	self.Attachment = 1
	
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
			self.Attachment = 2
		else
			self.WeaponEnt = own:GetViewModel()
			if !IsValid(self.WeaponEnt) then return end
		end
	end
	
	ParticleEffectAttach("originstaff_revive_muzzle", PATTACH_POINT_FOLLOW, self.WeaponEnt, self.Attachment)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end