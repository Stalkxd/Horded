include("shared.lua")
language.Add( "#Coolant_ammo", "Rotor coolant" )

function SWEP:SyncMeter(o)
	local fix1, fix2, vm, clip, rpm = 50, 55, o:GetViewModel(), self:Ammo1(), self:GetRPM()
	if rpm == nil or clip == nil then return end
	vm:ManipulateBoneAngles(4,Angle(0,0,self.Primary_TFA.DefaultClip - clip - fix1))
	vm:ManipulateBoneAngles(5,Angle(0,0,rpm - fix2))
end

function SWEP:Think2()
	local own = self:GetOwner()
	self:SyncMeter(own)
	
	if own:KeyReleased(IN_ATTACK) then
		self:StopParticles()
	end
end

function SWEP:OnRemove()
	local own = self:GetOwner()
	if IsValid(own) then
		local vm = own:GetViewModel()
		vm:ManipulateBoneAngles(4, angle_zero)
		vm:ManipulateBoneAngles(5, angle_zero)
	end
end