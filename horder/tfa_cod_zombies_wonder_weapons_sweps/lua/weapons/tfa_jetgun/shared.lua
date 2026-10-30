AddCSLuaFile("cl_init.lua")

SWEP.Base              		= "tfa_gun_base"
SWEP.Category               = "TFA Wonder Weapons" -- The category.  Please, just choose something generic or something I've already done if you plan on only doing like one SWEP.
SWEP.SubCategory			= "Black Ops II"
SWEP.Manufacturer			= nil -- Gun Manufactrer (e.g. Hoeckler and Koch )
SWEP.Author             	= "Hidden" -- Author Tooltip
SWEP.Contact                = "" -- Contact Info Tooltip
SWEP.Purpose                = "The old afterburner was hot and inefficient. Tubes linking the intake directly to the exaust fixed that." -- Purpose Tooltip
SWEP.Instructions           = "" 		-- Instructions Tooltip
SWEP.Spawnable              = true		-- Can you, as a normal user, spawn this?
SWEP.AdminSpawnable         = false		-- Can an adminstrator spawn this?  Does not tie into your admin mod necessarily, unless its coded to allow for GMod's default ranks somewhere in its code.  Evolve and ULX should work, but try to use weapon restriction rather than these.
SWEP.DrawCrosshair          = true      -- Draw the crosshair?
SWEP.DrawCrosshairIS		= false		-- Draw the crosshair in ironsights?
SWEP.PrintName              = "Thrustodyne Aeronautics Model 23"       -- Weapon name (Shown on HUD)
SWEP.Slot              		= 4         -- Slot in the weapon selection menu.  Subtract 1, as this starts at 0.
SWEP.SlotPos                = 12        -- Position in the slot
SWEP.AutoSwitchTo           = true      -- Auto switch to if we pick it up
SWEP.AutoSwitchFrom         = true      -- Auto switch from if you pick up a better weapon
SWEP.Weight             	= 30        -- This controls how "good" the weapon is for autopickup.
SWEP.Type					= "Wonder Weapon"

SWEP.DrawAmmo = false

-- [[WEAPON HANDLING]] --
SWEP.Primary.Sound = Sound("") -- This is the sound of the weapon, when you shoot.
SWEP.Primary.SilencedSound = nil -- This is the sound of the weapon, when silenced.
SWEP.Primary.PenetrationMultiplier = 1 -- Change the amount of something this gun can penetrate through
-- the LESSER this value is, the BETTER is penetration
-- you don't need to uncomment these if you are not going to modify them!

game.AddAmmoType({
	name = "Coolant",
	dmgtype = DMG_SLASH,
})

-- nZombies Stuff
SWEP.NZWonderWeapon		= true	-- Is this a Wonder-Weapon? If true, only one player can have it at a time. Cheats aren't stopped, though.
--SWEP.NZRePaPText		= "your text here"	-- When RePaPing, what should be shown? Example: Press E to your text here for 2000 points.
SWEP.NZPaPName			= "Scramjet Model 3200"
--SWEP.NZPaPReplacement 	= ""	-- If Pack-a-Punched, replace this gun with the entity class shown here.
SWEP.NZPreventBox		= false	-- If true, this gun won't be placed in random boxes GENERATED. Users can still place it in manually.
SWEP.NZTotalBlackList	= false	-- if true, this gun can't be placed in the box, even manually, and can't be bought off a wall, even if placed manually. Only code can give this gun.

-- Max Ammo function
SWEP.Primary.MaxAmmo = 160

function SWEP:NZMaxAmmo()

	local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo

    if SERVER then
        self.Owner:SetAmmo( self:GetStat("Primary.MaxAmmo"), ammo_type )
		self:SetClip1( self:GetStat("Primary_TFA.ClipSize") )
    end
end

-- PaP Function
function SWEP:OnPaP()
    --self:ClearStatCache()
    self.Ispackapunched = true
    --self.Primary_TFA.ClipSize = -1
	--self.Primary_TFA.DefaultClip = 200
	--self.Primary_TFA.MaxAmmo = 200
    --self:GetStat("Primary.MaxAmmo")
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
SWEP.JamFactor = 0.06 -- How to increase jam factor after each shot.

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
SWEP.Primary.DefaultClip = 160 -- This is the number of bullets the gun gives you, counting a clip as defined directly above.
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
SWEP.MoveSpeed = 0.9 -- Multiply the player's movespeed by this.
SWEP.IronSightsMoveSpeed = 0.75 -- Multiply the player's movespeed by this when sighting.

-- PROJECTILES
SWEP.Primary.Projectile = nil -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 0 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel = nil -- Entity to shoot's model

-- VIEWMODEL
SWEP.ViewModel          = "models/weapons/black_ops_2/jetgun/v_jetgun.mdl" -- Viewmodel path
SWEP.ViewModelFOV           = 68        -- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip          = false     -- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands = true -- Use gmod c_arms system.
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
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
SWEP.WorldModel         = "models/weapons/black_ops_2/jetgun/w_jetgun.mdl" -- Weapon world model path
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
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, -- Sequence or act
		["value"] = ACT_VM_SPRINT_ENTER, -- Number for act, String/Number for sequence
		["value_empty"] = ACT_VM_SPRINT_ENTER,
		["transition"] = true
	}, -- Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, -- Sequence or act
		["value"] = ACT_VM_SPRINT_IDLE, -- Number for act, String/Number for sequence
		["value_empty"] = ACT_VM_SPRINT_IDLE,
		["is_idle"] = true
	}, -- looping animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, -- Sequence or act
		["value"] = ACT_VM_SPRINT_LEAVE, -- Number for act, String/Number for sequence
		["value_empty"] = ACT_VM_SPRINT_LEAVE,
		["transition"] = true
	} -- Outward transition
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

DEFINE_BASECLASS( SWEP.Base )

function SWEP:SetupDataTables(omfg)
	BaseClass.SetupDataTables( self, omfg )
	self:NetworkVarTFA( "Int", "RPM" )
	self:NetworkVarTFA( "Bool", "Shredding" )
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local own = self:GetOwner()
	self.Owner = own
	
	self:SetRPM(math.Clamp(self:GetRPM() + 4, 0, 110)) -- Start warming and spinning up
	
	if self:GetStatus() != TFA.Enum.STATUS_SHOOTING then
		self:SendWeaponAnim(ACT_VM_PULLBACK)
		self:EmitSound("weapons/jetgun/rattle/jetgun_rattle_start.mp3", 75, 100, 1, CHAN_WEAPON)
	end
	
	if timer.Exists(own:EntIndex().."jetgun_reload") then -- Stop cooling down
		timer.Pause(own:EntIndex().."jetgun_reload")
	end
	
	local shootpos = own:GetShootPos()
	local aimvec = own:GetAimVector()
	
	self:CallOnClient("RenderIntakeParticles")
	
	if SERVER then
	
		if self:Ammo1() <= 3 then -- Weapon's too hot, gotta throw it away
		
			local prop = ents.Create("prop_physics")
			prop:SetModel(self.WorldModel)
			prop:SetPos(shootpos)
			prop:SetAngles(own:EyeAngles() + Angle(0, -70, 8))
			prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			prop:Spawn()
			prop:SetOwner(own)
			prop:EmitSound("weapons/jetgun/rattle/jetgun_rattle_stop.mp3")
			prop:Ignite(2)
			local phys = prop:GetPhysicsObject()
			if IsValid( phys ) then
				phys:ApplyForceCenter( aimvec * 4000 )
			end
			timer.Simple(2,function()
				local eff = EffectData()
				eff:SetOrigin(prop:GetPos())
				eff:SetMagnitude(1)
				util.Effect("Explosion", eff)
				prop:Remove()
			end)
			local oldwep = own:GetPreviousWeapon()
			if oldwep then
				own:SelectWeapon(oldwep)
			end
			own:StripWeapon("tfa_jetgun")
			return
		end
		
		if self:GetShredding() then -- We're spinning fast enough, pull 'em in and shred 'em!
			self:TakePrimaryAmmo(self.Ispackapunched and 2 or 3)
			own:SetVelocity(aimvec*16)
			for k, v in pairs(ents.FindInSphere(shootpos+aimvec*200, 200)) do
				if v == own or (v:IsPlayer() and !hook.Run("PlayerShouldTakeDamage", v, own)) then continue end
				if v:IsNextBot() then
					v.loco:SetVelocity((own:GetPos() - v:GetPos()) * 4)
				elseif v:GetMoveType() < 7 then
					v:SetVelocity((own:GetPos() - v:GetPos()) * 4)
				end
			end
			
			local grindpos, grindbox = shootpos + aimvec*36, Vector(10,10,10)
			
			local dmg = DamageInfo()
			--dmg:SetDamage(100000000)
			dmg:SetDamageType(bit.bor(DMG_CRUSH, DMG_SLASH))
			dmg:SetAttacker(own)
			dmg:SetInflictor(self)
			
			debugoverlay.Box( grindpos, -grindbox, grindbox, 0.25, color_transparent)
			for k, v in ipairs(ents.FindInBox(grindpos - grindbox, grindpos + grindbox)) do
				if v == own then continue end
				dmg:SetDamage( math.min(v:GetMaxHealth()/2, v:Health() + 1) )
				v:TakeDamageInfo(dmg)
			end
			
			--dmg:SetDamage(500000)
			dmg:SetDamageType(DMG_BURN)
			dmg:SetDamageForce(aimvec*-10000)
			
			local tr = util.QuickTrace( own:WorldSpaceCenter(), aimvec * -128, own )
			if tr.Hit then
				dmg:SetDamage( math.min(tr.Entity:GetMaxHealth()/5, tr.Entity:Health() + 1) )
				tr.Entity:TakeDamageInfo(dmg)
			end
		end
	
	end
	self:SetStatus(TFA.GetStatus("shooting"))
	self:SetStatusEnd(CurTime() + 0.15)
	
	self:SetNextPrimaryFire(CurTime() + 0.1)
	--self:PreventHolster(CurTime()+0.2)
	timer.Pause(own:EntIndex().."jetgun_reload")
end

function SWEP:Think()
	BaseClass.Think(self)
	local own = self:GetOwner()
	local index = own:EntIndex()
	
	if own:KeyReleased(IN_ATTACK) then
	
		if timer.Exists(index.."jetgun_reload") then
			timer.UnPause(index.."jetgun_reload")
		else
			timer.Create(index.."jetgun_reload", 0.15, 0, function()
				if !IsValid(self) then return end
				if self:Ammo1() == self.Primary_TFA.DefaultClip and self:GetRPM() == 0 then -- We're done here, pause the timer
					timer.Pause(index.."jetgun_reload")
				end
				self:SetRPM(math.Clamp(self:GetRPM() - 8, 0, 150)) -- Slow down
				own:SetAmmo(math.Clamp(self:Ammo1() + 1, 0, self.Primary_TFA.DefaultClip), self.Primary_TFA.Ammo, true) -- Cool down
			end)
		end
		
		self:SetShredding(false)
		
		if self:GetStatus() == TFA.Enum.STATUS_SHOOTING then
			own:StopSound("Weapon_Jetgun.FullLoop")
			self:SendWeaponAnim(ACT_VM_PULLBACK_LOW)
			self:StopParticles()
			self:EmitSound("weapons/jetgun/jetgun_off.mp3", 75, 100, 1, CHAN_WEAPON) -- Stop rattling
			self:EmitSound("weapons/jetgun/rattle/jetgun_rattle_stop.mp3", 75, 100, 1, CHAN_ITEM) -- Stop rattling
		end
		
	end
	
	if own:KeyDown(IN_ATTACK) then
		if self:GetShredding() then
			self:CallOnClient("RenderExaustLight")
		elseif self:GetRPM() >= 45 then
			self:SetShredding(true)
			self:EmitSound("weapons/jetgun/jetgun_on.mp3", 75, 100, 1, CHAN_ITEM)
			--self:LoopingSoundStart()
			self:EmitSound("Weapon_Jetgun.Loop_1stperson")
			self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
			self:CallOnClient("RenderExaustParticles")
		end
	end
end

function SWEP:RenderIntakeParticles()
	local own = self:GetOwner()
	if IsValid(own) then
		ParticleEffectAttach( "jetgun_muzzle", PATTACH_POINT_FOLLOW, self:IsFirstPerson() and own:GetViewModel() or self, 1 )
		ParticleEffect("jetgun_mistfloor", own:WorldSpaceCenter(), Angle(0, own:GetAngles().y, 0), own)
	end
end

function SWEP:RenderExaustParticles()
	if self:IsFirstPerson() then
		return
	end
	
	ParticleEffectAttach( "jetgun_exaust", PATTACH_POINT_FOLLOW, self, 2 )
end

function SWEP:RenderExaustLight()
	local own = self:GetOwner()
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = own:WorldSpaceCenter() - own:GetAimVector() * 32
		dynlight.Size = 96
		dynlight.Decay = 128
		dynlight.R = 50
		dynlight.G = 80
		dynlight.B = 255
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.05
end

function SWEP:OnRemove()
	--BaseClass.OnRemove(idk)
	local own = self.Owner or self:GetOwner()
	/*
	if self.LoopingSound then
		self.LoopingSound:Stop()
		--self.LoopingSoundBack:Stop()
	end
	*/
	own:StopSound("Weapon_Jetgun.FullLoop")
	own:StopSound("Weapon_Jetgun.Loop_1stperson")
	timer.Remove(own:EntIndex().."jetgun_reload")
end