SWEP.Base = "tfa_bash_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops II"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.7
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Purpose = "Didn't you ever hear the phrase 'A cold day in hell'?"
SWEP.Instructions = "Tap ATTACK1 to shoot, hold to charge the shot. Press ATTACK2 to slash. Slash to cancel a charged shot. Press USE and RELOAD together to switch to and from Sekhmet's Vigor."
SWEP.Type_Displayed = "Staff of The Ancients"
SWEP.Author = "FlamingFox & Hidden"
SWEP.Slot = 4
SWEP.SlotPos = 13
SWEP.PrintName = "Ull's Arrow"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIronSights = false

--[Model]--
SWEP.ViewModel			= "models/weapons/black_ops_2/staffs/c_upg_staff_ice.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/black_ops_2/staffs/w_staff_ice.mdl"
SWEP.HoldType = "shotgun"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 2
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

--[Gun Related]--
SWEP.Primary.Sound = "weapons/originstaffs/ice/shot/ice_staff_shot.ogg"
SWEP.Primary.Ammo = "Ice"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 110
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = 115
SWEP.Primary.NumShots = 5
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.ClipSize = 9
SWEP.Primary.DefaultClip = 99
SWEP.Primary.DryFireDelay = 0.5
SWEP.MuzzleFlashEffect = "muzzleflash_icestaff"
SWEP.MuzzleFlashEffectSilenced = "muzzleflash_revivestaff"
SWEP.DisableChambering = true
SWEP.FiresUnderwater = false

SWEP.Secondary.Sound = "weapons/originstaffs/revive/shot.ogg"
SWEP.Secondary.Ammo = "Vigor"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 4

--[Firemode]--
SWEP.Primary.BurstDelay = nil
SWEP.DisableBurstFire = true
SWEP.SelectiveFire = false
SWEP.OnlyBurstFire = false
SWEP.BurstFireCount = nil

--[LowAmmo]--
SWEP.FireSoundAffectedByClipSize = false
SWEP.LowAmmoSoundThreshold = 0.33 --0.33
SWEP.LowAmmoSound = nil
SWEP.LastAmmoSound = nil

--[Range]--
SWEP.Primary.DisplayFalloff = false
SWEP.Primary.RangeFalloffLUT = {
	bezier = false, -- Whenever to use Bezier or not to interpolate points?
	-- you probably always want it to be set to true
	range_func = "linear", -- function to spline range
	-- "linear" for linear splining.
	-- Possible values are "quintic", "cubic", "cosine", "sinusine", "linear" or your own function
	units = "meters", -- possible values are "inches", "inch", "hammer", "hu" (are all equal)
	-- everything else is considered to be meters
	lut = { -- providing zero point is not required
		-- without zero point it is considered to be as {range = 0, damage = 1}
		{range = 100, damage = 1},
		{range = 100, damage = 0},
	}
}

--[Recoil]--
SWEP.ViewModelPunchPitchMultiplier = 0.5 --0.5
SWEP.ViewModelPunchPitchMultiplier_IronSights = 0.09 --0.09

SWEP.ViewModelPunch_MaxVertialOffset				= 3 --3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights		= 1.95 --1.95
SWEP.ViewModelPunch_VertialMultiplier				= 1 --1
SWEP.ViewModelPunch_VertialMultiplier_IronSights	= 0.25 --0.25

SWEP.ViewModelPunchYawMultiplier = 0.6 --0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = 0.25 --0.25

SWEP.ChangeStateRecoilMultiplier = 1.3 --1.3
SWEP.CrouchRecoilMultiplier = 0.55 --0.65
SWEP.JumpRecoilMultiplier = 2.0 --1.3
SWEP.WallRecoilMultiplier = 1.5 --1.1

--[Spread Related]--
SWEP.Primary.Spread		  = .1
SWEP.Primary.IronAccuracy = .1
SWEP.IronRecoilMultiplier = 0.8

SWEP.Primary.KickUp				= 0.7
SWEP.Primary.KickDown 			= 0.5
SWEP.Primary.KickHorizontal		= 0.3
SWEP.Primary.StaticRecoilFactor = 0.4

SWEP.Primary.SpreadMultiplierMax = 5
SWEP.Primary.SpreadIncrement = 0
SWEP.Primary.SpreadRecovery = 3

SWEP.ChangeStateAccuracyMultiplier = 1.5 --1.5
SWEP.CrouchAccuracyMultiplier = 1.0 --0.5
SWEP.JumpAccuracyMultiplier = 1.0 --2
SWEP.WalkAccuracyMultiplier = 1.0 --1.35

--[Bash]--
SWEP.Secondary.BashDamage = 500
SWEP.Secondary.BashSound = Sound("Weapon_OriginStaff.Melee")
--SWEP.Secondary.BashHitSound = Sound("Weapon_Knife.Hit")
SWEP.Secondary.BashHitSound_Flesh = Sound("Weapon_Knife.Hit")
SWEP.Secondary.BashLength = 65
SWEP.Secondary.BashDelay = 0.2
SWEP.Secondary.BashDamageType = DMG_SLASH
SWEP.Secondary.BashInterrupt = true

--[Iron Sights]--
SWEP.IronBobMult 	 = 0.065
SWEP.IronBobMultWalk = 0.065
SWEP.data = {}
SWEP.data.ironsights = 0
SWEP.Secondary.IronFOV = 75
SWEP.IronSightsPos = Vector(-4.05, -4, -1.25)
SWEP.IronSightsAng = Vector(19.65, -7.15, 2)
SWEP.IronSightTime = 0.45

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellScale = 0
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = "0"
SWEP.EjectionSmokeEnabled = false

--[Jamming]-- RPG
SWEP.CanJam = false
SWEP.JamChance = 0.00
SWEP.JamFactor = 0.00

--[Projectile]--
SWEP.Primary.Projectile         = "obj_icestaff_proj" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 3500 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = nil -- Entity to shoot's model

SWEP.Secondary.Projectile         = "obj_revivestaff_proj" -- Entity to shoot
SWEP.Secondary.ProjectileVelocity = 1000 -- Entity to shoot's velocity
SWEP.Secondary.ProjectileModel    = nil -- Entity to shoot's model

--[Misc]--
SWEP.AmmoTypeStrings = {Ice_ammo = "Ice Crystal"}
SWEP.InspectPos = Vector(0, -4, -5)
SWEP.InspectAng = Vector(15, 15, -15)
SWEP.MoveSpeed = 0.925
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(0, 0, -0)
SWEP.SafetyAng = Vector(-15, 15, -15)
SWEP.SmokeParticle = ""

--[DInventory2]--
SWEP.DInv2_GridSizeX = 2
SWEP.DInv2_GridSizeY = 5
SWEP.DInv2_Volume = nil
SWEP.DInv2_Mass = 16

--[NZombies]--
SWEP.NZPaPName = "Ull's Arrow"
SWEP.Primary.MaxAmmo = 90
SWEP.Secondary.MaxAmmo = 4

function SWEP:NZMaxAmmo()

    local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo
    local ammo_type2 = self:GetSecondaryAmmoType() or self.Secondary.Ammo

    if SERVER then
        self:GetOwner():SetAmmo( self.Primary.MaxAmmo, ammo_type )
		self:SetClip1( self.Primary.ClipSize )
        self:GetOwner():SetAmmo( self.Secondary.MaxAmmo, ammo_type2 )
		self:SetClip2( self.Secondary.ClipSize )
    end
end

function SWEP:OnPaP()
	return true
end

--[Tables]--
SWEP.StatusLengthOverride = {
}

SWEP.SequenceLengthOverride = {
}

SWEP.SequenceRateOverride = {
}

SWEP.StatCache_Blacklist = {
	["HoldType"] = true,
	["Primary.NumShots"] = true,
	["PrintName"] = true
}

SWEP.SprintAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SPRINT_ENTER, --Number for act, String/Number for sequence
	},
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SPRINT_IDLE, --Number for act, String/Number for sequence
		["is_idle"] = true
	},
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SPRINT_LEAVE, --Number for act, String/Number for sequence
	}
}

SWEP.EventTable = {
	[ACT_VM_DRAW_DEPLOYED] = {
		{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("Weapon_OriginStaff_Water.Raise") },
		{ ["time"] = 30 / 30, ["type"] = "sound", ["value"] = Sound("Weapon_OriginStaff.UpgradedRaise") }
	},
	[ACT_VM_RELOAD] = {
		--{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Lever") },
		{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("Weapon_OriginStaff.Startreload") },
		{ ["time"] = 30 / 30, ["type"] = "sound", ["value"] = Sound("Weapon_OriginStaff.Reloading") },
		{ ["time"] = 45 / 30, ["type"] = "sound", ["value"] = Sound("Weapon_OriginStaff.Finishreload") }
	}
}

--[Shit]--
SWEP.AllowViewAttachment = true --Allow the view to sway based on weapon attachment while reloading or drawing, IF THE CLIENT HAS IT ENABLED IN THEIR CONVARS.
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_ANI -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation
SWEP.SprintBobMult = 1

--[Attachments]--
SWEP.ViewModelBoneMods = {
}
--[[
SWEP.Attachments = {
	[1] = {atts = {"tfa_att_staff_revive"}, order = 1}
}

SWEP.AttachmentDependencies     = {}
SWEP.AttachmentExclusions       = {}
SWEP.AttachmentTableOverride    = {}
SWEP.AttachmentIconOverride     = {}
]]
--[Chargeup]-- Credit to DBot for lock-on code i repurposed for this
DEFINE_BASECLASS( SWEP.Base )

SWEP.ChargeStages = 4 --first stage is the inital chargeup, other 3 are normal
SWEP.ChargeStageTime = 0.5
SWEP.InitialChargeUp = 0.5
SWEP.ChargeLoopSound = "Weapon_OriginStaff_Water.ChargedLoop"
SWEP.ChargeSounds = {
	[1] = "weapons/originstaffs/ice/charge/icestaff_charge_001.ogg",
	[2] = "weapons/originstaffs/ice/charge/icestaff_charge_002.ogg",
	[3] = "weapons/originstaffs/ice/charge/icestaff_charge_003.ogg"
}

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	
	self:NetworkVarTFA("Bool", "ChargedUp")
	self:NetworkVarTFA("Int", "ChargeStage")
	self:NetworkVarTFA("Float", "NextCharge")
end

function SWEP:ResetLock()
	self:SetChargedUp(false)
	self:SetChargeStage(0)
	self:SetNextCharge(0)
	self:StopSound(self.ChargeLoopSound)
	self.Primary_TFA.NumShots = 5
end

function SWEP:OnDrop(...)
	self:ResetLock()
	return BaseClass.OnDrop(self,...)
end

function SWEP:OwnerChanged(...)
	self:ResetLock()
	return BaseClass.OwnerChanged(self,...)
end

function SWEP:Holster( ... )
	self:ResetLock()
	return BaseClass.Holster(self,...)
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if not self:CanPrimaryAttack() then return end
	
	--if self.AttachmentCache["tfa_att_staff_revive"] then
	if self:GetSilenced() then
		if self:GetNextSecondaryFire() > CurTime() then return end
		if self:Ammo2() < 1 then return end
		
		self:ChooseShootAnim()
		self:ShootEffectsCustom()
		if IsFirstTimePredicted() then self:EmitSound(self:GetStat("Secondary.Sound")) end
		ply:ViewPunch(Angle(-3,-1,-0.5))
		ply:SetAnimation(PLAYER_ATTACK1)
		
		if SERVER then
			local ent = ents.Create(self:GetStat("Secondary.Projectile"))
			ent:SetOwner(ply)
			ent:SetPos(ply:GetShootPos())
			ent:SetAngles(ply:EyeAngles())
			ent:Spawn()
			ent:Activate()
			ent:SetVelocity(ply:GetAimVector() * self:GetStat("Secondary.ProjectileVelocity"))
		end
		
		self:SetStatus(TFA.GetStatus("shooting"))
		self:SetStatusEnd(CurTime() + 0.75)
		self:SetNextSecondaryFire( CurTime() + 3)
		self:TakeSecondaryAmmo(1)
		
		return
	end
	
	if ply:IsPlayer() then
		if ply:KeyDown(IN_ATTACK) and self:Clip1() >= 3 then
			self:Charging()
		elseif self:Clip1() < 3 then
			self:FakePrimaryAttack()
		end
	else
		BaseClass.PrimaryAttack(self)
	end
end

function SWEP:ChargedAttack()
	self:SetStatus(TFA.GetStatus("idle"))
	self:SetChargedUp(true)
	self:FakePrimaryAttack()
	self:TakePrimaryAmmo((self:GetChargeStage()-1)*2 - 1)
end

function SWEP:FakePrimaryAttack()
	BaseClass.PrimaryAttack(self)
end

function SWEP:Think2(...)
	local own = self:GetOwner()
	if TFA.Enum.ReadyStatus[self:GetStatus()] and not self:GetSprinting() and own:IsPlayer() then
		if own:KeyReleased(IN_ATTACK) and !self:GetSilenced() then
			if self:GetChargeStage() > 1 then
				self:ChargedAttack()
			else
				self:FakePrimaryAttack()
				self:ResetLock()
			end
		end
	else
		self:ResetLock()
	end
	
	if own:KeyDown(IN_USE) and own:KeyDown(IN_RELOAD) and TFA.Enum.ReadyStatus[self:GetStatus()] then
		--[[if self.AttachmentCache["tfa_att_staff_revive"] then
			self:Detach("tfa_att_staff_revive", true)
		else
			self:Attach("tfa_att_staff_revive", true)
		end]]
		self:FlipStaff(!self:GetSilenced())
	end
	
	BaseClass.Think2(self, ...)
end

function SWEP:FlipStaff(tovigor)
	if tovigor then
		self.ViewModelKitOld = self.ViewModelKitOld or self.ViewModel
		self.WorldModelKitOld = self.WorldModelKitOld or self.WorldModel
		self.ViewModel = "models/weapons/black_ops_2/staffs/c_staff_revive.mdl"
		self.WorldModel = self:GetStat("WorldModel_Vigor") or self.WorldModel
		if IsValid(self.OwnerViewModel) then
			self.HoldType = "slam"
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SendViewModelAnim(ACT_VM_PULLBACK_LOW)
			self:ScheduleStatus(TFA.Enum.STATUS_TOGGLE_UNDERBARREL, self:GetActivityLength()*2)
			self:SetNextPrimaryFire(self:GetStatusEnd())
			
			timer.Simple(self.OwnerViewModel:SequenceDuration(), function()
				if !self or !self:GetOwner() or self:GetOwner():GetActiveWeapon() != self then return end
				
				self.OwnerViewModel:SetModel(self.ViewModel)
				self.HoldType = "shotgun"
				self:SendViewModelAnim(ACT_VM_DRAW)
				self:SetSilenced(true)
				self.PrintName = "Sekhmet's Vigor"
			end)
		end
		if self.Offset then self.Offset.Pos.Up = self.Offset.Pos.Up  + 3 end
		--self.Offset.Ang.Forward = self.Offset.Pos.Forward + 90
		self:SetModelScale(-1)
		self:SetNextIdleAnim(-1)
	else
		if self.Offset then self.Offset.Pos.Up = self.Offset.Pos.Up - 3 end
		--self.Offset.Ang.Forward = self.Offset.Ang.Forward - 90
		if self.ViewModelKitOld then
			self.ViewModel = self.ViewModelKitOld
			if IsValid(self.OwnerViewModel) then
				self.HoldType = "slam"
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self:SendViewModelAnim(ACT_VM_HOLSTER)
				self:ScheduleStatus(TFA.Enum.STATUS_TOGGLE_UNDERBARREL, self:GetActivityLength()*2)
				self:SetNextPrimaryFire(self:GetStatusEnd())
				
				timer.Simple(self.OwnerViewModel:SequenceDuration(), function()
					if !self or !self:GetOwner() or self:GetOwner():GetActiveWeapon() != self then return end
					
					self.OwnerViewModel:SetModel(self.ViewModel)
					self.HoldType = "shotgun"
					self:SendViewModelAnim(ACT_VM_PULLBACK_HIGH)
					self:SetSilenced(false)
					self.PrintName = "Ull's Arrow"
				end)
			end
			self.ViewModelKitOld = nil
		end
		if self.WorldModelKitOld then
			self.WorldModel = self.WorldModelKitOld
			self:SetModelScale(1)
			self.ViewModelKitOld = nil
		end
		self:SetNextIdleAnim(-1)
	end
end

function SWEP:Charging()
	if self:GetNextCharge() <= CurTime() then
		if self:GetChargeStage() < self.ChargeStages then
			if self:GetChargeStage() > 0 then
				local snd = self:GetStat("ChargeSounds")
				if IsFirstTimePredicted() then self:EmitSoundNet(snd[self:GetChargeStage()]) end
			end
			
			if self:GetChargeStage() == 0 then
				self:SetNextCharge(CurTime() + self.InitialChargeUp)
			elseif self:GetChargeStage() == 1 then
				self.Primary_TFA.NumShots = 1
				self:SetNextCharge(CurTime() + self.ChargeStageTime)
			else
				self:SetNextCharge(CurTime() + self.ChargeStageTime)
			end
			
			
			self:SetChargeStage(self:GetChargeStage() + 1)

			if self:GetChargeStage() >= self.ChargeStages then
				if IsFirstTimePredicted() then self:EmitSoundNet(self.ChargeLoopSound) end
			end
		end
	end
end

function SWEP:PreSpawnProjectile(ent)
	ent.Charge = math.min(self:GetChargeStage(), self:Clip1()/3 + 1)
	ent.Damage = 600
end

function SWEP:PostSpawnProjectile(ent)
	ent.Owner = self:GetOwner()
	if not self:GetChargedUp() then 
		local aimcone = 12
		local dir
		local ang = self:GetOwner():EyeAngles()
		ang:RotateAroundAxis(ang:Right(), -aimcone / 2 + math.Rand(0, aimcone))
		ang:RotateAroundAxis(ang:Up(), -aimcone / 2 + math.Rand(0, aimcone))
		dir = ang:Forward()
		
		ent:SetVelocity(dir * self:GetStat("Primary.ProjectileVelocity"))
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:SetVelocity(dir * self:GetStat("Primary.ProjectileVelocity"))
		end
	end
	--self:ResetLock()
end

if CLIENT then
	--local WorldModel = ClientsideModel(SWEP.WorldModel)
	local flipang = Angle(180,0,0)
	local flippos = Vector(0,0,21)
	function SWEP:DrawWorldModel(flags)
		--local own = self:GetOwner()
		if self:GetSilenced() then
			self:ManipulateBoneAngles(1, flipang, false)
			self:ManipulateBonePosition(1, flippos, false)
		else
			self:ManipulateBoneAngles(1, angle_zero, false)
			self:ManipulateBonePosition(1, vector_origin, false)
		end
		self:SetBodygroup(3,1)
		self:DrawModel()
	end
	
	function SWEP:PreDrawViewModel(vm, wep, ply)
		BaseClass.PreDrawViewModel(self, vm)
		vm:SetBodygroup( 1, math.Clamp(self:GetChargeStage() - 1, 0, 3) )
	end
end