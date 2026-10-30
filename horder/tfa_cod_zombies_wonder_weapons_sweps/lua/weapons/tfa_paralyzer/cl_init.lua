include("shared.lua")

DEFINE_BASECLASS(SWEP.Base)

function SWEP:SyncMeter(ply)
	if self:VMIV() and ply:IsPlayer() then
		local clip = self.Primary.DefaultClip - self:Ammo1()
		local fix,fix1,fix2 = 70, 70, -74
		self.ViewModelBoneMods["tag_control_dial_1"].angle = Angle(math.Truncate(clip*0.01)*-36 + fix,0,0)
		self.ViewModelBoneMods["tag_control_dial_2"].angle = Angle(math.Truncate(clip*0.1)*-36 + fix1,0,0)
		self.ViewModelBoneMods["tag_control_dial_3"].angle = Angle(clip*-36 + fix2,0,0)
	end
end

function SWEP:Think2()
	local own = self:GetOwner()
	self:SyncMeter(own)
	
	if own:KeyReleased(IN_ATTACK) then
		self:StopParticles()
	end
end
/*
function SWEP:OnRemove()
	local own = self:GetOwner()
	if IsValid(own) then
		local vm = own:GetViewModel()
		local bone1 = vm:LookupBone("tag_control_dial_1")
		local bone2 = vm:LookupBone("tag_control_dial_2")
		local bone3 = vm:LookupBone("tag_control_dial_3")
		if !bone1 then return end
		vm:ManipulateBoneAngles(bone1,angle_zero)
		vm:ManipulateBoneAngles(bone2,angle_zero)
		vm:ManipulateBoneAngles(bone3,angle_zero)
	end
end
*/
SWEP.Glow = Material("models/weapons/black_ops_2/slowgun/mtl_t6_wpn_zmb_slowgun_glow.vmt")
SWEP.DefaultGlow = Vector(0.3, 0.3, 1)
SWEP.PAPGlow = Vector(0.15, 1, 0.2)
local overheated = Vector(1, 0.05, 0.05)
function SWEP:PreDrawViewModel(vm, wep, ply)
	BaseClass.PreDrawViewModel(self, vm)
    self.GlowLevel = 1 - (self:Ammo1() / (self.Primary.MaxAmmo - 15))
    self.Glow:SetVector("$emissiveblendtint", LerpVector(self.GlowLevel, (self.Ispackapunched and self.PAPGlow or self.DefaultGlow), overheated))
end