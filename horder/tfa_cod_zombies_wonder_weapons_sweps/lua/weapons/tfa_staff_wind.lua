SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops II"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.7
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Purpose = "Do not fight the inevitable, the storm will take you!"
SWEP.Type_Displayed = "Staff of The Ancients"
SWEP.Author = "FlamingFox & Hidden"
SWEP.Slot = 4
SWEP.SlotPos = 11
SWEP.PrintName = "Staff of Wind"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIronSights = false

--[Model]--
SWEP.ViewModel			= "models/weapons/black_ops_2/staffs/c_staff_wind.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/black_ops_2/staffs/w_staff_wind.mdl"
SWEP.HoldType = "shotgun"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 2
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

--[Gun Related]--
SWEP.Primary.Sound = "weapons/originstaffs/air/shot/air_staff_shot.ogg"
SWEP.Primary.Ammo = "Thumper"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 60
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = 115
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 43
SWEP.Primary.DryFireDelay = 0.5
SWEP.MuzzleFlashEffect = "muzzleflash_windstaff"
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
	units = "inches", -- possible values are "inches", "inch", "hammer", "hu" (are all equal)
	-- everything else is considered to be meters
	lut = { -- providing zero point is not required
		-- without zero point it is considered to be as {range = 0, damage = 1}
		{range = 100, damage = 1},
		{range = 101, damage = 0},
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

SWEP.Primary.KickUp				= 1.2
SWEP.Primary.KickDown 			= 0.5
SWEP.Primary.KickHorizontal		= 0.3
SWEP.Primary.StaticRecoilFactor = 0.45

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
SWEP.Primary.Projectile         = "obj_windstaff_proj" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 3500 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = "models/hunter/blocks/cube025x025x025.mdl" -- Entity to shoot's model

--[Misc]--
SWEP.AmmoTypeStrings = {thumper = "Air Crystal"}
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
SWEP.NZPaPReplacement = "tfa_staff_wind_ult"
SWEP.Primary.MaxAmmo = 60

function SWEP:NZMaxAmmo()
	local own = self:GetOwner()
    local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo

    if SERVER then
        own:SetAmmo( self.Primary.MaxAmmo, ammo_type )
		self:SetClip1( self.Primary.ClipSize )
    end
end

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
		{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("Weapon_OriginStaff_Air.Raise") }
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

function SWEP:PreSpawnProjectile(ent)
	local ply = self:GetOwner()
	ent:SetPos(ply:GetShootPos() + ply:GetForward()*25) --this is so the dust from muzzleflash doesnt collide with projectile lol
end

--fwoosh
function SWEP:PostPrimaryAttack()
	local ply = self:GetOwner()
	if SERVER then
		for k, v in pairs(ents.FindInCone(ply:GetShootPos(), self:GetAimVector(), 250, 0.766)) do --0.766 is the cos of rad(40)
			if v ~= ply and (v:IsNextBot() or v:IsPlayer() or v:IsNPC()) then
				local dmg = DamageInfo()
				dmg:SetDamage(1270) -- Zombie health at round 12 using original CoD:Z formula
				dmg:SetDamageType(DMG_SONIC)
				dmg:SetAttacker(ply)
				dmg:SetDamageForce((ply:GetForward()*300000) + (ply:GetUp()*300000)) 
				v:TakeDamageInfo(dmg) 
			end
		end
	end
end
