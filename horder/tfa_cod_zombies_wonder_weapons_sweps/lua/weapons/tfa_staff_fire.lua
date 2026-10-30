SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops II"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.7
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Purpose = "There is no escape from the inferno!"
SWEP.Type_Displayed = "Staff of The Ancients"
SWEP.Author = "FlamingFox & Hidden"
SWEP.Slot = 4
SWEP.SlotPos = 8
SWEP.PrintName = "Staff of Fire"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIronSights = false

--[Model]--
SWEP.ViewModel			= "models/weapons/black_ops_2/staffs/c_staff_fire.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/black_ops_2/staffs/w_staff_fire.mdl"
SWEP.HoldType = "shotgun"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 2
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

game.AddAmmoType( {
 name = "Lava",
 dmgtype = DMG_BURN,
 tracer = TRACER_LINE,
 plydmg = 0,
 npcdmg = 0
} )

--[Gun Related]--
SWEP.Primary.Sound = "weapons/originstaffs/fire/shot/firestaff_shoot.ogg"
SWEP.Primary.Ammo = "Lava"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 80
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = 115
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.ClipSize = 9
SWEP.Primary.DefaultClip = 99
SWEP.Primary.DryFireDelay = 0.5
SWEP.MuzzleFlashEffect = "muzzleflash_firestaff"
SWEP.DisableChambering = true
SWEP.FiresUnderwater = false

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
SWEP.Primary.Spread		  = .05
SWEP.Primary.IronAccuracy = .1
SWEP.IronRecoilMultiplier = 0.8

SWEP.Primary.KickUp				= 0.9
SWEP.Primary.KickDown 			= 0.6
SWEP.Primary.KickHorizontal		= 0.25
SWEP.Primary.StaticRecoilFactor = 0.5

SWEP.Primary.SpreadMultiplierMax = 5
SWEP.Primary.SpreadIncrement = 0
SWEP.Primary.SpreadRecovery = 3

SWEP.ChangeStateAccuracyMultiplier = 1.5 --1.5
SWEP.CrouchAccuracyMultiplier = 1.0 --0.5
SWEP.JumpAccuracyMultiplier = 1.0 --2
SWEP.WalkAccuracyMultiplier = 1.0 --1.35

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
SWEP.Primary.Projectile         = "obj_firestaff_proj" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 2500 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = "models/props_junk/rock001a.mdl" -- Entity to shoot's model

--[Misc]--
SWEP.AmmoTypeStrings = {Lava_ammo = "Fire Crystal"}
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
SWEP.NZPaPReplacement = "tfa_staff_fire_ult"
SWEP.Primary.MaxAmmo = 90

function SWEP:NZMaxAmmo()

    local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo

    if SERVER then
        self:GetOwner():SetAmmo( self.Primary.MaxAmmo, ammo_type )
		self:SetClip1( self.Primary.ClipSize )
    end
end

SWEP.Ispackapunched = false

--[Tables]--
SWEP.StatusLengthOverride = {
}

SWEP.SequenceLengthOverride = {
}

SWEP.SequenceRateOverride = {
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
		{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("Weapon_OriginStaff_Fire.Raise") },
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

SWEP.AttachmentDependencies     = {}
SWEP.AttachmentExclusions       = {}
SWEP.AttachmentTableOverride    = {}
SWEP.AttachmentIconOverride     = {}

--[Chargeup]-- Credit to DBot for lock-on code i repurposed for this
DEFINE_BASECLASS( SWEP.Base )

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() and not game.SinglePlayer() then return end
	num_bullets = num_bullets or 1
	aimcone = aimcone or 0
	
	local own = self:GetOwner()

	self:SetLastGunFire(CurTime())
	if self:GetStatL("Primary.Projectile") then
		if CLIENT then return end
		for _ = 1, num_bullets do
			local ent = ents.Create(self:GetStatL("Primary.Projectile"))
			local pos = own:GetShootPos()
			local ang = own:EyeAngles()

			ent:SetPos(pos + own:GetAimVector()*15)
			ent:SetOwner(own)
			ent:SetAngles(ang)
			ent.damage = self:GetStatL("Primary.Damage")
			ent.mydamage = self:GetStatL("Primary.Damage")
			if self:GetStatL("Primary.ProjectileModel") then
				ent:SetModel(self:GetStatL("Primary.ProjectileModel"))
			end

			ent:Spawn()

			local dir = ang:Forward()
			local right = ang:Right()
			dir:Mul(self:GetStatL("Primary.ProjectileVelocity"))
			
			ent:SetVelocity(dir)
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(dir)
			end

			if self.ProjectileModel then
				ent:SetModel(self:GetStatL("Primary.ProjectileModel"))
			end
			ent:SetOwner(own)
			
			timer.Simple(0.1, function()
				if self:IsValid() and self:OwnerIsValid() then
					local orb2 = ents.Create(self:GetStatL("Primary.Projectile"))
					orb2:SetPos(pos + own:GetAimVector()*15)
					orb2:SetAngles(ang)
					orb2:SetOwner(own)
					orb2.damage = self:GetStatL("Primary.Damage")
					orb2.mydamage = self:GetStatL("Primary.Damage")
					
					if self:GetStatL("Primary.ProjectileModel") then
						orb2:SetModel(self:GetStatL("Primary.ProjectileModel"))
					end
					orb2:Spawn()
						
					if self.ProjectileModel then
						orb2:SetModel(self:GetStatL("Primary.ProjectileModel"))
					end
					
					orb2:SetOwner(own)
					orb2:SetVelocity(dir)
					local phys2 = orb2:GetPhysicsObject()
					if IsValid(phys2) then
						phys2:SetVelocity(dir + right * 700)
					end
				end
			end)
			
			timer.Simple(0.2, function()
				if self:IsValid() and self:OwnerIsValid() then
					local orb3 = ents.Create(self:GetStatL("Primary.Projectile"))
					orb3:SetPos(pos + own:GetAimVector()*15)
					orb3:SetAngles(ang)
					orb3:SetOwner(own)
					orb3:Spawn()
					orb3.damage = self:GetStatL("Primary.Damage")
					orb3.mydamage = self:GetStatL("Primary.Damage")
						
					if self:GetStatL("Primary.ProjectileModel") then
						orb3:SetModel(self:GetStatL("Primary.ProjectileModel"))
					end
					orb3:Spawn()
						
					if self.ProjectileModel then
						orb3:SetModel(self:GetStatL("Primary.ProjectileModel"))
					end

					orb3:SetOwner(own)
					orb3:SetVelocity(dir)
					local phys3 = orb3:GetPhysicsObject()
					if IsValid(phys3) then
						phys3:SetVelocity(dir + right * -700)
					end
				end
			end)
		end
		return
	end
end
