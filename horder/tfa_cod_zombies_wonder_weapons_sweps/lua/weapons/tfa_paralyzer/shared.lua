AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

SWEP.Base					= "tfa_gun_base"
SWEP.Category               = "TFA Wonder Weapons" -- The category.  Please, just choose something generic or something I've already done if you plan on only doing like one swep.
SWEP.SubCategory			= "Black Ops II"
SWEP.Manufacturer			= nil -- Gun Manufactrer (e.g. Hoeckler and Koch )
SWEP.Author					= "Deika, Hidden & Matsilagi" -- Author Tooltip
SWEP.Contact				= "" -- Contact Info Tooltip
SWEP.Purpose				= "When the trigger's pulled they can't even come close enough to hit you!" -- Purpose Tooltip
SWEP.Instructions			= "" -- Instructions Tooltip
SWEP.Spawnable				= true -- Can you, as a normal user, spawn this?
SWEP.AdminSpawnable			= false -- Can an adminstrator spawn this?  Does not tie into your admin mod necessarily, unless its coded to allow for GMod's default ranks somewhere in its code.  Evolve and ULX should work, but try to use weapon restriction rather than these.
SWEP.DrawCrosshair			= true      -- Draw the crosshair?
SWEP.DrawCrosshairIS		= false -- Draw the crosshair in ironsights?
SWEP.PrintName				= "Paralyzer"       -- Weapon name (Shown on HUD)
SWEP.Slot					= 4             -- Slot in the weapon selection menu.  Subtract 1, as this starts at 0.
SWEP.SlotPos				= 7            -- Position in the slot
SWEP.AutoSwitchTo			= true      -- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true      -- Auto switch from if you pick up a better weapon
SWEP.Weight					= 30            -- This controls how "good" the weapon is for autopickup.
SWEP.Type					= "Wonder Weapon"

SWEP.DrawAmmo = false

-- [[WEAPON HANDLING]] --
SWEP.Primary.Sound = Sound("") -- This is the sound of the weapon, when you shoot.
SWEP.Primary.SilencedSound = nil -- This is the sound of the weapon, when silenced.
SWEP.Primary.PenetrationMultiplier = 1 -- Change the amount of something this gun can penetrate through
-- the LESSER this value is, the BETTER is penetration
-- this is basically multiplier for next values
-- you don't need to uncomment these if you are not going to modify them!

-- nZombies Stuff
SWEP.NZWonderWeapon		= true	-- Is this a Wonder-Weapon? If true, only one player can have it at a time. Cheats aren't stopped, though.
--SWEP.NZRePaPText		= "your text here"	-- When RePaPing, what should be shown? Example: Press E to your text here for 2000 points.
SWEP.NZPaPName				= "Petrifier"
--SWEP.NZPaPReplacement 	= ""	-- If Pack-a-Punched, replace this gun with the entity class shown here.
SWEP.NZPreventBox		= false	-- If true, this gun won't be placed in random boxes GENERATED. Users can still place it in manually.
SWEP.NZTotalBlackList	= false	-- if true, this gun can't be placed in the box, even manually, and can't be bought off a wall, even if placed manually. Only code can give this gun.

-- Max Ammo function
SWEP.Primary.MaxAmmo = 115

function SWEP:NZMaxAmmo()

	local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo

    if SERVER then
        self.Owner:SetAmmo( self:GetStat("Primary.MaxAmmo"), ammo_type )
		self:SetClip1( self:GetStat("Primary_TFA.ClipSize") )
    end
end

-- PaP Function
function SWEP:OnPaP()
    self:ClearStatCache()
    self.Ispackapunched = true
    self.Primary_TFA.ClipSize = -1
	self.Primary_TFA.DefaultClip = 150
	self.Primary_TFA.MaxAmmo = 150
    self:GetStat("Primary.MaxAmmo")
    return true
end

SWEP.Ispackapunched = false

SWEP.Primary.Damage = 115 -- Damage, in standard damage points.
SWEP.Primary.DamageTypeHandled = true -- true will handle damagetype in base
SWEP.Primary.DamageType = DMG_SLASH -- See DMG enum.  This might be DMG_SHOCK, DMG_BURN, DMG_BULLET, etc.  Leave nil to autodetect.  DMG_AIRBOAT opens doors.
SWEP.Primary.Force = nil -- Force value, leave nil to autocalc
SWEP.Primary.Knockback = nil -- Autodetected if nil; this is the velocity kickback
SWEP.Primary.HullSize = 0 -- Big bullets, increase this value.  They increase the hull size of the hitscan bullet.
SWEP.Primary.NumShots = 1 -- The number of shots the weapon fires.  SWEP.Shotgun is NOT required for this to be >1.
SWEP.Primary.Automatic = true -- Automatic/Semi Auto
SWEP.Primary.RPM = 100 -- This is in Rounds Per Minute / RPM
SWEP.Primary.RPM_Semi = nil -- RPM for semi-automatic or burst fire.  This is in Rounds Per Minute / RPM
SWEP.Primary.RPM_Burst = nil -- RPM for burst fire, overrides semi.  This is in Rounds Per Minute / RPM
SWEP.Primary.DryFireDelay = nil -- How long you have to wait after firing your last shot before a dryfire animation can play.  Leave nil for full empty attack length.  Can also use SWEP.StatusLength[ ACT_VM_BLABLA ]
SWEP.Primary.BurstDelay = nil -- Delay between bursts, leave nil to autocalculate

SWEP.Primary.LoopSound = nil -- Looped fire sound, unsilenced
SWEP.Primary.LoopSoundSilenced = nil -- Looped fire sound, silenced
SWEP.Primary.LoopSoundTail = nil -- Loop end/tail sound, unsilenced
SWEP.Primary.LoopSoundTailSilenced = nil -- Loop end/tail sound, silenced
SWEP.Primary.LoopSoundAutoOnly = false -- Play loop sound for full-auto only? Fallbacks to Primary.Sound for semi/burst if true

-- WORLD/THIRDPERSON/NPC FIRING SOUNDS! Fallbacks to first person sound if not defined.

SWEP.Primary.Sound_World = nil -- This is the sound of the weapon, when you shoot.
SWEP.Primary.SilencedSound_World = nil -- This is the sound of the weapon, when silenced.

SWEP.Primary.LoopSound_World = nil -- Looped fire sound, unsilenced
SWEP.Primary.LoopSoundSilenced_World = nil -- Looped fire sound, silenced
SWEP.Primary.LoopSoundTail_World = nil -- Loop end/tail sound, unsilenced
SWEP.Primary.LoopSoundTailSilenced_World = nil -- Loop end/tail sound, silenced

SWEP.ViewModelPunchPitchMultiplier = nil -- Default value is 0.5
SWEP.ViewModelPunchPitchMultiplier_IronSights = nil -- Default value is 0.09

SWEP.ViewModelPunch_MaxVertialOffset = nil -- Default value is 3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights = nil -- Default value is 1.95
SWEP.ViewModelPunch_VertialMultiplier = nil -- Default value is 1
SWEP.ViewModelPunch_VertialMultiplier_IronSights = nil -- Default value is 0.25

SWEP.ViewModelPunchYawMultiplier = nil -- Default value is 0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = nil -- Default value is 0.25

SWEP.CanJam = false -- whenever weapon cam jam
SWEP.JamChance = 0.04 -- the (maximal) chance the weapon will jam. Newly spawned weapon will never jam on first shot for example.
-- Default value is 0.04 (4%)
-- Maxmial value is 1, means weapon will always jam when factor become 100
-- Also remember that there is a minimal factor before weapon can jam
-- This number is not treated "as-is" but as basic value that needs to be concluded as chance
-- You don't really need to cry over it and trying to balance it, TFA Base will do the job for you
-- (TFA Base will calculate the best value between 0 and JamChance based on current JamFactor of the weapon)
SWEP.JamFactor = 0.06 -- How to increase jam factor after each shot.
-- When factor reach 100 it will mean that on each shot there will be SWEP.Primary.JamChance chance to jam
-- When factor reach 50 it will mean that on each shot there will be SWEP.Primary.JamChance / 2 chance to jam
-- and so on
-- Default value is 0.06, means weapon will jam with SWEP.Primary.JamChance chance right after 1666 shots

-- These settings are good for Assault Rifles, however, not good for anything else.
-- Suggested stats:

SWEP.FiresUnderwater = false
-- Miscelaneous Sounds
SWEP.IronInSound = nil -- Sound to play when ironsighting in?  nil for default
SWEP.IronOutSound = nil -- Sound to play when ironsighting out?  nil for default
-- Silencing
SWEP.CanBeSilenced = false -- Can we silence?  Requires animations.
SWEP.Silenced = false -- Silenced by default?
-- Selective Fire Stuff
SWEP.SelectiveFire = false -- Allow selecting your firemode?
SWEP.DisableBurstFire = false -- Only auto/single?
SWEP.OnlyBurstFire = false -- No auto, only burst/single?
SWEP.BurstFireCount = nil -- Burst fire count override (autocalculated by the clip size if nil)
SWEP.DefaultFireMode = "" -- Default to auto or whatev
SWEP.FireModeName = nil -- Change to a text value to override it
SWEP.FireSoundAffectedByClipSize = false -- Whenever adjuct pitch (and proably other properties) of fire sound based on current clip / maxclip
-- This is always false when either:
-- Weapon has no primary clip
-- Weapon's clip is smaller than 4 rounds
-- Weapon is a shotgun
-- Ammo Related
SWEP.Primary.ClipSize = -1 -- This is the size of a clip
SWEP.Primary.DefaultClip = 115 -- This is the number of bullets the gun gives you, counting a clip as defined directly above.
SWEP.Primary.Ammo = "Coolant" -- What kind of ammo.  Options, besides custom, include pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, and AirboatGun.
SWEP.Primary.AmmoConsumption = 1 -- Ammo consumed per shot
-- Pistol, buckshot, and slam like to ricochet. Use AirboatGun for a light metal peircing shotgun pellets
SWEP.DisableChambering = true -- Disable round-in-the-chamber

-- Recoil Related
SWEP.Primary.KickUp = 0 -- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown = 0 -- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal = 0 -- This is the maximum sideways recoil (no real term)
SWEP.Primary.StaticRecoilFactor = 0.5 -- Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.

-- Firing Cone Related
SWEP.Primary.Spread = .01 -- This is hip-fire acuracy.  Less is more (1 is horribly awful, .0001 is close to perfect)
SWEP.Primary.IronAccuracy = .005 -- Ironsight accuracy, should be the same for shotguns

-- Unless you can do this manually, autodetect it.  If you decide to manually do these, uncomment this block and remove this line.
SWEP.Primary.SpreadMultiplierMax = nil -- How far the spread can expand when you shoot. Example val: 2.5
SWEP.Primary.SpreadIncrement = nil -- What percentage of the modifier is added on, per shot.  Example val: 1/3.5
SWEP.Primary.SpreadRecovery = nil -- How much the spread recovers, per second. Example val: 3

-- Range Related

-- DEPRECATED. Automatically converted to RangeFalloffLUT table
SWEP.Primary.Range = -1 -- The distance the bullet can travel in source units.  Set to -1 to autodetect based on damage/rpm.
SWEP.Primary.RangeFalloff = -1 -- The percentage of the range the bullet damage starts to fall off at.  Set to 0.8, for example, to start falling off after 80% of the range.

-- Use these if you don't want/understand how to use LUT below. These values are automatically converted to RangeFalloffLUT table
SWEP.Primary.FalloffMetricBased = false -- Set to true if you set up values below
SWEP.Primary.FalloffByMeter = nil -- How much damage points will bullet loose when travel
SWEP.Primary.MinRangeStartFalloff = nil -- How long will bullet travel in Meters before starting to lose damage?
SWEP.Primary.MaxFalloff = nil -- Maximal amount of damage to be lost



-- Penetration Related
SWEP.MaxPenetrationCounter = 4 -- The maximum number of ricochets.  To prevent stack overflows.

-- Misc
SWEP.IronRecoilMultiplier = 0.5 -- Multiply recoil by this factor when we're in ironsights.  This is proportional, not inversely.
SWEP.CrouchAccuracyMultiplier = 0.5 -- Less is more.  Accuracy * 0.5 = Twice as accurate, Accuracy * 0.1 = Ten times as accurate

-- Movespeed
SWEP.MoveSpeed = 0.85 -- Multiply the player's movespeed by this.
SWEP.IronSightsMoveSpeed = 0.75 -- Multiply the player's movespeed by this when sighting.

-- PROJECTILES
SWEP.Primary.Projectile = nil -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 0 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel = nil -- Entity to shoot's model

-- VIEWMODEL
SWEP.ViewModel			= "models/weapons/black_ops_2/paralyzer/c_slowgun.mdl" --Viewmodel path
SWEP.ViewModelFOV           = 80        -- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip          = false     -- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands = true -- Use gmod c_arms system.
SWEP.VMPos = Vector(0, -0.603, -1.407)
SWEP.VMAng = Vector(2.111, 0, 0)
SWEP.VMPos_Additive = true -- Set to false for an easier time using VMPos. If true, VMPos will act as a constant delta ON TOP OF ironsights, run, whateverelse
SWEP.CenteredPos = nil -- The viewmodel positional offset, used for centering.  Leave nil to autodetect using ironsights.
SWEP.CenteredAng = nil -- The viewmodel angular offset, used for centering.  Leave nil to autodetect using ironsights.
SWEP.Bodygroups_V = nil -- {
	-- [0] = 1,
	-- [1] = 4,
	-- [2] = etc.
-- }

SWEP.AllowIronSightsDoF = false -- whenever allow DoF effect on viewmodel when zoomed in with iron sights

SWEP.IronSightsReloadEnabled = nil -- Enable ADS reload animations support (requires animations to be enabled in SWEP.Animations)
SWEP.IronSightsReloadLock = true -- Lock ADS state when reloading

-- WORLDMODEL
SWEP.WorldModel			= "models/weapons/black_ops_2/paralyzer/w_slowgun.mdl" -- Weapon world model path
SWEP.Bodygroups_W = nil -- {
-- [0] = 1,
-- [1] = 4,
-- [2] = etc.
-- }

SWEP.HoldType = "crossbow" -- This is how others view you carrying the weapon. Options include:
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive
-- You're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles

SWEP.Offset = {
	Pos = {
		Up = 0,
		Right = 0,
		Forward = 0
	},
	Ang = {
		Up = -1,
		Right = -2,
		Forward = 178
	},
	Scale = 1
} -- Procedural world model animation, defaulted for CS:S purposes.

SWEP.ThirdPersonReloadDisable = false -- Disable third person reload?  True disables.

-- SCOPES
SWEP.IronSightsSensitivity = 1 -- Useful for a RT scope.  Change this to 0.25 for 25% sensitivity.  This is if normal FOV compenstaion isn't your thing for whatever reason, so don't change it for normal scopes.
SWEP.BoltAction = false -- Unscope/sight after you shoot?
SWEP.Scoped = false -- Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875 -- Percentage you have to be sighted in to see the scope.
SWEP.BoltTimerOffset = 0.25 -- How long you stay sighted in after shooting, with a bolt action.
SWEP.ScopeScale = 0.5 -- Scale of the scope overlay
SWEP.ReticleScale = 0.7 -- Scale of the reticle overlay
-- GDCW Overlay Options.  Only choose one.
SWEP.Secondary.UseACOG = false -- Overlay option
SWEP.Secondary.UseMilDot = false -- Overlay option
SWEP.Secondary.UseSVD = false -- Overlay option
SWEP.Secondary.UseParabolic = false -- Overlay option
SWEP.Secondary.UseElcan = false -- Overlay option
SWEP.Secondary.UseGreenDuplex = false -- Overlay option
if surface then
	SWEP.Secondary.ScopeTable = nil --[[
		{
			scopetex = surface.GetTextureID("scope/gdcw_closedsight"),
			reticletex = surface.GetTextureID("scope/gdcw_acogchevron"),
			dottex = surface.GetTextureID("scope/gdcw_acogcross")
		}
	]] --
end
-- [[SHOTGUN CODE]] --
SWEP.Shotgun = false -- Enable shotgun style reloading.
SWEP.ShotgunEmptyAnim = false -- Enable emtpy reloads on shotguns?
SWEP.ShotgunEmptyAnim_Shell = true -- Enable insertion of a shell directly into the chamber on empty reload?
SWEP.ShotgunStartAnimShell = false -- shotgun start anim inserts shell
SWEP.ShellTime = .35 -- For shotguns, how long it takes to insert a shell.
-- [[SPRINTING]] --
SWEP.RunSightsPos = Vector(0, 0, 0) -- Change this, using SWEP Creation Kit preferably
SWEP.RunSightsAng = Vector(0, 0, 0) -- Change this, using SWEP Creation Kit preferably
-- [[CROUCHING]] --
-- Viewmodel offset when player is crouched
-- SWEP.CrouchPos = Vector(0, 0, 0)
-- SWEP.CrouchAng = Vector(0, 0, 0)
-- [[IRONSIGHTS]] --
SWEP.data = {}
SWEP.data.ironsights = 0 -- Enable Ironsights
SWEP.Secondary.IronFOV = 70 -- How much you "zoom" in. Less is more!  Don't have this be <= 0.  A good value for ironsights is like 70.
-- SWEP.IronViewModelFOV = 65 -- Target viewmodel FOV when aiming down the sights.
SWEP.IronSightsPos = Vector(0, 0, 0) -- Change this, using SWEP Creation Kit preferably
SWEP.IronSightsAng = Vector(0, 0, 0) -- Change this, using SWEP Creation Kit preferably
-- [[INSPECTION]] --
SWEP.InspectPos = nil -- Vector(0, 0, 0) -- Replace with a vector, in style of ironsights position, to be used for inspection
SWEP.InspectAng = nil -- Vector(0, 0, 0) -- Replace with a vector, in style of ironsights angle, to be used for inspection
-- [[VIEWMODEL BLOWBACK]] --
SWEP.BlowbackEnabled = false -- Enable Blowback?
SWEP.BlowbackVector = Vector(0, -1, 0) -- Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackAngle = nil -- Angle(0, 0, 0)
SWEP.BlowbackCurrentRoot = 0 -- Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 -- Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil -- Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true -- Only do blowback on ironsights
SWEP.Blowback_PistolMode = false -- Do we recover from blowback when empty?
SWEP.Blowback_Shell_Enabled = true -- Shoot shells through blowback animations
SWEP.Blowback_Shell_Effect = "ShellEject" -- Which shell effect to use
SWEP.BlowbackAllowAnimation = nil -- Allow playing shoot animation with blowback?
-- [[VIEWMODEL PROCEDURAL ANIMATION]] --
SWEP.DoProceduralReload = false -- Animate first person reload using lua?
SWEP.ProceduralReloadTime = 1 -- Procedural reload time?
-- [[HOLDTYPES]] --
SWEP.IronSightHoldTypeOverride = "" -- This variable overrides the ironsights holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
SWEP.SprintHoldTypeOverride = "" -- This variable overrides the sprint holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
-- [[ANIMATION]] --

SWEP.StatusLengthOverride = {} -- Changes the status delay of a given animation; only used on reloads.  Otherwise, use SequenceLengthOverride or one of the others
SWEP.SequenceLengthOverride = {} -- Changes both the status delay and the nextprimaryfire of a given animation
SWEP.SequenceTimeOverride = {} -- Like above but changes animation length to a target
SWEP.SequenceRateOverride = {} -- Like above but scales animation length rather than being absolute

SWEP.ProceduralHolsterEnabled = nil
SWEP.ProceduralHolsterTime = 0.3
SWEP.ProceduralHolsterPos = Vector(3, 0, -5)
SWEP.ProceduralHolsterAng = Vector(-40, -30, 10)

SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH -- TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 -- Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 -- Start an idle this far early into the end of another animation
-- MDL Animations Below

SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_HYBRID -- LOCOMOTION_ANI = mdl, LOCOMOTION_HYBRID = ani + lua, LOCOMOTION_LUA = lua only

SWEP.SprintAnimation = {
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SPRINT_IDLE, --Number for act, String/Number for sequence
		["is_idle"] = true
	}
}

SWEP.ViewModelBoneMods = {
	["tag_control_dial_1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["tag_control_dial_2"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["tag_control_dial_3"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
}

SWEP.Walk_Mode = TFA.Enum.LOCOMOTION_LUA -- LOCOMOTION_ANI = mdl, LOCOMOTION_HYBRID = ani + lua, LOCOMOTION_LUA = lua only

SWEP.Customize_Mode = TFA.Enum.LOCOMOTION_LUA -- LOCOMOTION_ANI = mdl, LOCOMOTION_HYBRID = ani + lua, LOCOMOTION_LUA = lua only

-- [[EFFECTS]] --
-- Attachments
SWEP.MuzzleAttachment           = "1"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellAttachment            = "2"       -- Should be "2" for CSS models or "shell" for hl2 models
SWEP.MuzzleFlashEnabled = false -- Enable muzzle flash
SWEP.MuzzleAttachmentRaw = nil -- This will override whatever string you gave.  This is the raw attachment number.  This is overridden or created when a gun makes a muzzle event.
SWEP.AutoDetectMuzzleAttachment = false -- For multi-barrel weapons, detect the proper attachment?
SWEP.MuzzleFlashEffect = nil -- Change to a string of your muzzle flash effect.  Copy/paste one of the existing from the base.
SWEP.SmokeParticle = "" -- Smoke particle (ID within the PCF), defaults to something else based on holdtype; "" to disable
SWEP.EjectionSmokeEnabled = true -- Disable automatic ejection smoke
-- Shell eject override
SWEP.LuaShellEject = false -- Enable shell ejection through lua?
SWEP.LuaShellEjectDelay = 0 -- The delay to actually eject things
SWEP.LuaShellModel = nil -- The model to use for ejected shells
SWEP.LuaShellScale = nil -- The model scale to use for ejected shells
SWEP.LuaShellYaw = nil -- The model yaw rotation ( relative ) to use for ejected shells
-- Tracer Stuff
SWEP.TracerName         = nil   -- Change to a string of your tracer name.  Can be custom. There is a nice example at https://github.com/garrynewman/garrysmod/blob/master/garrysmod/gamemodes/base/entities/effects/tooltracer.lua
SWEP.TracerCount        = 3     -- 0 disables, otherwise, 1 in X chance
-- Impact Effects
SWEP.ImpactEffect = nil -- Impact Effect
SWEP.ImpactDecal = nil -- Impact Decal
-- [[EVENT TABLE]] --
SWEP.EventTable = {} -- Event Table, used for custom events when an action is played.  This can even do stuff like playing a pump animation after shooting.
-- example:
-- SWEP.EventTable = {
--  [ACT_VM_RELOAD] = {
--																				-- ifp is IsFirstTimePredicted()
--      { ["time"] = 0.1, ["type"] = "lua", ["value"] = function( wep, viewmodel, ifp ) end, ["client"] = true, ["server"] = true},
--      { ["time"] = 0.1, ["type"] = "sound", ["value"] = Sound("x") }
--  }
-- }
-- [[RENDER TARGET]] --
SWEP.RTMaterialOverride = nil -- Take the material you want out of print(LocalPlayer():GetViewModel():GetMaterials()), subtract 1 from its index, and set it to this.
SWEP.RTOpaque = false -- Do you want your render target to be opaque?
SWEP.RTCode = nil -- function(self) return end -- This is the function to draw onto your rendertarget
SWEP.RTBGBlur = true -- Draw background blur when 3D scope is active?
-- [[AKIMBO]] --
SWEP.Akimbo = false -- Akimbo gun?  Alternates between primary and secondary attacks.
SWEP.AnimCycle = 1 -- Start on the right
SWEP.AkimboHUD = true -- Draw holographic HUD for both weapons?
-- [[ATTACHMENTS]] --
SWEP.VElements = nil -- Export from SWEP Creation Kit.  For each item that can/will be toggled, set active=false in its individual table
SWEP.WElements = nil -- Export from SWEP Creation Kit.  For each item that can/will be toggled, set active=false in its individual table
SWEP.Attachments = {
	-- [ORDER] = = { atts = { "si_eotech" }, sel = 0 }
	-- sel allows you to have an attachment pre-selected, and is used internally by the base to show which attachment is selected in each category.
}
SWEP.AttachmentDependencies = {} -- {["si_acog"] = {"bg_rail", ["type"] = "OR"}} -- type could also be AND to require multiple
SWEP.AttachmentExclusions = {} -- { ["si_iron"] = { [1] = "bg_heatshield"} }

DEFINE_BASECLASS(SWEP.Base)

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local own = self:GetOwner()
	self.Owner = own
	local vm = own:GetViewModel()
	
	if self:GetStatus() != TFA.Enum.STATUS_SHOOTING then
		self:EmitSound("weapons/slowgun/v3/fire.ogg", 75, 100, 1, CHAN_WEAPON)
		self:EmitSound("weapons/slowgun/v3/loop.wav", 75, 100, 1, CHAN_ITEM)
		self:CallOnClient("RenderIntakeParticles")
	end
	
	if self:Ammo1() <= 1 then -- Weapon's too hot
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:StopParticles()
		vm:StopParticles()
		self:StopSound("weapons/slowgun/v3/loop.wav")
		self:SetNextPrimaryFire(CurTime() + 5)
		self:EmitSound("weapons/slowgun/v3/stop.ogg", 75, 100, 1, CHAN_ITEM)
		--return
	end
	self:TakePrimaryAmmo(1)
	
	if timer.Exists(own:EntIndex().."jetgun_reload") then -- Stop cooling down
		timer.Pause(own:EntIndex().."jetgun_reload")
	end
	
	local shootpos = own:GetShootPos()
	local aimvec = own:GetAimVector()
	
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(500)
	dmginfo:SetDamageType(DMG_REMOVENORAGDOLL)
	dmginfo:SetAttacker(own)
	dmginfo:SetInflictor(self)
	
	local pushforce = -80
	if own:EyeAngles().pitch < 45 then
		own:SetVelocity(aimvec*-10)
	else
		own:SetVelocity(aimvec*pushforce)
	end
	
	if SERVER then
	
		for k, v in pairs(ents.FindInCone(own:GetShootPos(), own:GetAimVector(), 300, 0.8)) do
			
			if v:IsPlayer() and v != own then
				if !v:OnGround() then
					v:SetVelocity(own:GetAimVector()*-pushforce)
				end
				continue
			end
			
			if v:Health() <= 0 or (!v:IsNPC() and !v:IsNextBot()) then continue end
			
			if !timer.Exists(v:EntIndex().."paralyzerrestore") then
				timer.Create(v:EntIndex().."paralyzerrestore", 5, 1, function()
					if IsValid(v) then
						v:StopParticles()
						v:SetPlaybackRate(1)
						v.CurrentPlaybackRate = 1
						if v:IsNextBot() then
							v.loco:SetDesiredSpeed(v.RestoreSpeed)
						end
					end
				end)
				if v:IsNextBot() then
					v.RestoreSpeed = v.loco:GetDesiredSpeed()
				end
				v.CurrentPlaybackRate = 1
				ParticleEffectAttach("cod_ww_paralyzer_character", PATTACH_POINT_FOLLOW, v, 2)
			else
				timer.Start(v:EntIndex().."paralyzerrestore")
				v.CurrentPlaybackRate = math.Clamp(v.CurrentPlaybackRate - 0.05, 0.1, 1)
				v:SetPlaybackRate(v.CurrentPlaybackRate)
				if v:IsNextBot() then
					v.loco:SetDesiredSpeed(math.Clamp(v.loco:GetDesiredSpeed() - 8, 1, v.RestoreSpeed or 100))
					if v.loco:GetDesiredSpeed() < 10 then
						if v:Health() <= dmginfo:GetDamage() then
							ParticleEffect("wgun_pop", v:WorldSpaceCenter(), angle_zero, nil)
							timer.Remove(v:EntIndex().."paralyzerrestore")
						end
						v:TakeDamageInfo(dmginfo)
					end
					continue
				end
				if v.CurrentPlaybackRate <= 0.1 then
					if v:Health() <= dmginfo:GetDamage() then
						ParticleEffect("wgun_pop", v:WorldSpaceCenter(), angle_zero, nil)
						timer.Remove(v:EntIndex().."paralyzerrestore")
					end
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	
	end
	self:SetStatus(TFA.GetStatus("shooting"))
	self:SetStatusEnd(CurTime() + 0.2)
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
	self:SetNextPrimaryFire(CurTime() + 0.15)
	timer.Pause(own:EntIndex().."paralyzer_reload")
end

function SWEP:Think()
	BaseClass.Think(self)
	local own = self:GetOwner()
	local index = own:EntIndex()
	local vm = own:GetViewModel()
	
	if own:KeyReleased(IN_ATTACK) then
		if timer.Exists(index.."paralyzer_reload") then
			timer.UnPause(index.."paralyzer_reload")
		else
			timer.Create(index.."paralyzer_reload", 0.2, 0, function()
				if !IsValid(own) then 
					timer.Remove(index.."paralyzer_reload") 
					return 
				end
				if self:Ammo1() == self.Primary.DefaultClip then -- We're done here, pause the timer
					timer.Pause(index.."paralyzer_reload")
				end
				
				own:SetAmmo(math.Clamp(self:Ammo1() + 1, 0, self.Primary_TFA.DefaultClip), self.Primary_TFA.Ammo, true) -- Cool down
			end)
		end
		if self:GetStatus() == TFA.Enum.STATUS_SHOOTING then
			self:SendWeaponAnim(ACT_VM_IDLE)
			self:StopParticles()
			vm:StopParticles()
			self:EmitSound("weapons/slowgun/v3/stop.ogg", 75, 100, 1, CHAN_ITEM)
		end
	end
	
	
end

function SWEP:RenderIntakeParticles()
	local own = self:GetOwner()
	
	if self:IsFirstPerson() then
		ParticleEffectAttach( "cod_ww_paralyzer_muzzle", PATTACH_POINT_FOLLOW, own:GetViewModel(), 1 )
	else
		ParticleEffectAttach( "cod_ww_paralyzer_muzzle_3rd", PATTACH_POINT_FOLLOW, self, 1 )
	end
	
end

function SWEP:OnRemove()
	--BaseClass.OnRemove(idk)
	local own = self.Owner
	self:StopSound("weapons/slowgun/v3/loop.wav")
	timer.Remove(own:EntIndex().."paralyzer_reload")
end