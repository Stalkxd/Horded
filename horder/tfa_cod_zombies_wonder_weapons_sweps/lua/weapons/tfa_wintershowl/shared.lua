SWEP.Base				= "tfa_gun_base"
SWEP.Category				= "TFA Wonder Weapons" --The category.  Please, just choose something generic or something I've already done if you plan on only doing like one swep.
SWEP.SubCategory			= "Black Ops"
SWEP.Manufacturer = nil --Gun Manufactrer (e.g. Hoeckler and Koch )
SWEP.Author				= "Raven" --Author Tooltip
SWEP.Contact				= "Steam" --Contact Info Tooltip
SWEP.Purpose				= "Freeze the undead with this cool gun, and yes that was a bad joke." --Purpose Tooltip
SWEP.Instructions				= "" --Instructions Tooltip
SWEP.Spawnable				= true --Can you, as a normal user, spawn this?
SWEP.AdminSpawnable			= true --Can an adminstrator spawn this?  Does not tie into your admin mod necessarily, unless its coded to allow for GMod's default ranks somewhere in its code.  Evolve and ULX should work, but try to use weapon restriction rather than these.
SWEP.DrawCrosshair			= true		-- Draw the crosshair?
SWEP.DrawCrosshairIS = false --Draw the crosshair in ironsights?
SWEP.PrintName				= "Winter's Howl"		-- Weapon name (Shown on HUD)
SWEP.Slot				= 1				-- Slot in the weapon selection menu.  Subtract 1, as this starts at 0.
SWEP.SlotPos				= 4			-- Position in the slot
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.Weight				= 30			-- This controls how "good" the weapon is for autopickup.
SWEP.Type					= "Wonder Weapon"

--SWEP.customboboffset = Vector(0,0,0)

game.AddAmmoType( {
	name = "Ice",
	dmgtype = DMG_VEHICLE,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0
} )
if CLIENT then
	language.Add("Ice_ammo", "Ice")
end

--[[WEAPON HANDLING]]--
SWEP.Primary.Sound = Sound( "Weapon_Freezegun.Shoot" ) -- This is the sound of the weapon, when you shoot.
SWEP.Primary.SilencedSound = nil -- This is the sound of the weapon, when silenced.
SWEP.Primary.PenetrationMultiplier = 1 --Change the amount of something this gun can penetrate through
SWEP.Primary.Damage = 1000 -- Damage, in standard damage points.
SWEP.Primary.NumShots = 1 --The number of shots the weapon fires.  SWEP.Shotgun is NOT required for this to be >1.
SWEP.Primary.Automatic = false -- Automatic/Semi Auto
SWEP.Primary.Delay = 0.5
SWEP.Primary.RPM = 181 -- This is in Rounds Per Minute / RPM
SWEP.FiresUnderwater = false

-- nZombies Stuff
SWEP.NZWonderWeapon		= true	-- Is this a Wonder-Weapon? If true, only one player can have it at a time. Cheats aren't stopped, though.
--SWEP.NZRePaPText		= "your text here"	-- When RePaPing, what should be shown? Example: Press E to your text here for 2000 points.
SWEP.NZPaPName				= "Winter's Fury"
--SWEP.NZPaPReplacement 	= ""	-- If Pack-a-Punched, replace this gun with the entity class shown here.
SWEP.NZPreventBox		= false	-- If true, this gun won't be placed in random boxes GENERATED. Users can still place it in manually.
SWEP.NZTotalBlackList	= false	-- if true, this gun can't be placed in the box, even manually, and can't be bought off a wall, even if placed manually. Only code can give this gun.
SWEP.nzPaPCamo			= "models/weapons/black_ops_1/camos/camo_packapunch_large.vmt"

-- Max Ammo function
SWEP.Primary.MaxAmmo = 24

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
    self.Primary_TFA.ClipSize = 9
	self.Primary_TFA.MaxAmmo = 36
	self.Primary_TFA.Damage = 2000 -- nZombies fucked with this last time. Not sure if it still does.
    self:GetStat("Primary.MaxAmmo")
    self:GetStat("Primary.Damage")
    return true
end

SWEP.Ispackapunched = false
-- Selective Fire Stuff

SWEP.SelectiveFire = false --Allow selecting your firemode?
SWEP.DisableBurstFire = false --Only auto/single?
SWEP.OnlyBurstFire = false --No auto, only burst/single?
SWEP.DefaultFireMode = "" --Default to auto or whatev
SWEP.FireModeName = nil --Change to a text value to override it

--Ammo Related
SWEP.Primary.ClipSize = 6 -- This is the size of a clip
SWEP.Primary.DefaultClip = 30 -- This is the number of bullets the gun gives you, counting a clip as defined directly above.
SWEP.Primary.Ammo = "Ice" -- What kind of ammo.  Options, besides custom, include pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, and AirboatGun.
SWEP.Primary.AmmoConsumption = 1 --Ammo consumed per shot
SWEP.DisableChambering = true
--Pistol, buckshot, and slam like to ricochet. Use AirboatGun for a light metal peircing shotgun pellets

--Recoil Related
SWEP.Primary.KickUp            = 0.2                -- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown            = 0.2                   -- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal            = 0               -- This is the maximum sideways recoil (no real term)
SWEP.Primary.StaticRecoilFactor = 0.5     --Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.
--Firing Cone Related
SWEP.Primary.Spread = 0.015 --This is hip-fire acuracy.  Less is more (1 is horribly awful, .0001 is close to perfect)
SWEP.Primary.IronAccuracy = 0 -- Ironsight accuracy, should be the same for shotguns
--Unless you can do this manually, autodetect it.  If you decide to manually do these, uncomment this block and remove this line.
SWEP.Primary.SpreadMultiplierMax = nil--How far the spread can expand when you shoot. Example val: 2.5
SWEP.Primary.SpreadIncrement = nil --What percentage of the modifier is added on, per shot.  Example val: 1/3.5
SWEP.Primary.SpreadRecovery = nil--How much the spread recovers, per second. Example val: 3
--Range Related
SWEP.Primary.Range = -1 -- The distance the bullet can travel in source units.  Set to -1 to autodetect based on damage/rpm.
SWEP.Primary.RangeFalloff = -1 -- The percentage of the range the bullet damage starts to fall off at.  Set to 0.8, for example, to start falling off after 80% of the range.
--Penetration Related
SWEP.MaxPenetrationCounter = 0 --The maximum number of ricochets.  To prevent stack overflows.
--Misc
SWEP.IronRecoilMultiplier = 0 --Multiply recoil by this factor when we're in ironsights.  This is proportional, not inversely.
SWEP.CrouchAccuracyMultiplier = 0 --Less is more.  Accuracy * 0.5 = Twice as accurate, Accuracy * 0.1 = Ten times as accurate
--Movespeed
SWEP.MoveSpeed = 1 --Multiply the player's movespeed by this.
SWEP.IronSightsMoveSpeed = 0.8 --Multiply the player's movespeed by this when sighting.
--[[PROJECTILES]]--
--SWEP.ProjectileEntity = "obj_whowl_proj" --Entity to shoot
SWEP.ProjectileVelocity = 100 --Entity to shoot's velocity
SWEP.ProjectileModel = nil --Entity to shoot's model
--[[VIEWMODEL]]--
SWEP.ViewModel			= "models/weapons/black_ops_1/freezegun/v_freezegun.mdl" --Viewmodel path
SWEP.ViewModelFOV			= 60		-- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip			= false		-- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands = true --Use gmod c_arms system.
SWEP.VMPos = Vector(0,0,0) --The viewmodel positional offset, constantly.  Subtract this from any other modifications to viewmodel position.
SWEP.VMAng = Vector(0,0,0) --The viewmodel angular offset, constantly.   Subtract this from any other modifications to viewmodel angle.
SWEP.VMPos_Additive = true --Set to false for an easier time using VMPos. If true, VMPos will act as a constant delta ON TOP OF ironsights, run, whateverelse
SWEP.CenteredPos = nil --The viewmodel positional offset, used for centering.  Leave nil to autodetect using ironsights.
SWEP.CenteredAng = nil --The viewmodel angular offset, used for centering.  Leave nil to autodetect using ironsights.
SWEP.Bodygroups_V = nil --{
	--[0] = 1,
	--[1] = 4,
	--[2] = etc.
--}
--[[WORLDMODEL]]--
SWEP.WorldModel			= "models/weapons/black_ops_1/freezegun/w_freezegun.mdl" -- Weapon world model path
SWEP.Bodygroups_W = nil --{
--[0] = 1,
--[1] = 4,
--[2] = etc.
--}
SWEP.HoldType = "revolver" -- This is how others view you carrying the weapon. Options include:
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive
-- You're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles
SWEP.Offset = {
	Pos = {
		Up = 0,
		Right = 0,
		Forward = 0
	},
	Ang = {
		Up = 0,
		Right = 0,
		Forward = 0
	},
	Scale = 1
} --Procedural world model animation, defaulted for CS:S purposes.
SWEP.ThirdPersonReloadDisable = false --Disable third person reload?  True disables.
--[[SCOPES]]--
SWEP.IronSightsSensitivity = 1 --Useful for a RT scope.  Change this to 0.25 for 25% sensitivity.  This is if normal FOV compenstaion isn't your thing for whatever reason, so don't change it for normal scopes.
SWEP.BoltAction = false --Unscope/sight after you shoot?
SWEP.Scoped = false --Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875 --Percentage you have to be sighted in to see the scope.
SWEP.BoltTimerOffset = 0.25 --How long you stay sighted in after shooting, with a bolt action.
SWEP.ScopeScale = 0.5 --Scale of the scope overlay
SWEP.ReticleScale = 0.7 --Scale of the reticle overlay
--GDCW Overlay Options.  Only choose one.
SWEP.Secondary.UseACOG = false --Overlay option
SWEP.Secondary.UseMilDot = false --Overlay option
SWEP.Secondary.UseSVD = false --Overlay option
SWEP.Secondary.UseParabolic = false --Overlay option
SWEP.Secondary.UseElcan = false --Overlay option
SWEP.Secondary.UseGreenDuplex = false --Overlay option
if surface then
	SWEP.Secondary.ScopeTable = nil --[[
		{
			scopetex = surface.GetTextureID("scope/gdcw_closedsight"),
			reticletex = surface.GetTextureID("scope/gdcw_acogchevron"),
			dottex = surface.GetTextureID("scope/gdcw_acogcross")
		}
	]]--
end
--[[SHOTGUN CODE]]--
SWEP.Shotgun = false --Enable shotgun style reloading.
SWEP.ShotgunEmptyAnim = false --Enable emtpy reloads on shotguns?
SWEP.ShotgunEmptyAnim_Shell = true --Enable insertion of a shell directly into the chamber on empty reload?
SWEP.ShellTime = .35 -- For shotguns, how long it takes to insert a shell.
--[[SPRINTING]]--
SWEP.RunSightsPos = Vector(0, 0, 0) --Change this, using SWEP Creation Kit preferably
SWEP.RunSightsAng = Vector(0, 0, 0) --Change this, using SWEP Creation Kit preferably
--[[IRONSIGHTS]]--
SWEP.data = {}
SWEP.data.ironsights = 1 --Enable Ironsights
SWEP.Secondary.IronFOV = 85 -- How much you 'zoom' in. Less is more!  Don't have this be <= 0.  A good value for ironsights is like 70.
SWEP.IronSightsPos = Vector(-4.65, 2.0, 0.0)
SWEP.IronSightsAng = Vector(1.0, -0.12, -0.0)
SWEP.InspectPos = nil--Vector(0,0,0) --Replace with a vector, in style of ironsights position, to be used for inspection
SWEP.InspectAng = nil--Vector(0,0,0) --Replace with a vector, in style of ironsights angle, to be used for inspection
--[[VIEWMODEL ANIMATION HANDLING]]--
SWEP.AllowViewAttachment = true --Allow the view to sway based on weapon attachment while reloading or drawing, IF THE CLIENT HAS IT ENABLED IN THEIR CONVARS.
--[[VIEWMODEL BLOWBACK]]--
SWEP.BlowbackEnabled = false --Enable Blowback?
SWEP.BlowbackVector = Vector(0,-1,0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil --Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = false --Do we recover from blowback when empty?
SWEP.Blowback_Shell_Enabled = true --Shoot shells through blowback animations
SWEP.Blowback_Shell_Effect = "ShellEject"--Which shell effect to use
--[[VIEWMODEL PROCEDURAL ANIMATION]]--
SWEP.DoProceduralReload = false--Animate first person reload using lua?
SWEP.ProceduralReloadTime = 1 --Procedural reload time?
--[[HOLDTYPES]]--
SWEP.IronSightHoldTypeOverride = "" --This variable overrides the ironsights holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
SWEP.SprintHoldTypeOverride = "" --This variable overrides the sprint holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
--[[ANIMATION]]--

SWEP.StatusLengthOverride = {} --Changes the status delay of a given animation; only used on reloads.  Otherwise, use SequenceLengthOverride or one of the others
SWEP.SequenceLengthOverride = {} --Changes both the status delay and the nextprimaryfire of a given animation
SWEP.SequenceRateOverride = {} --Like above but changes animation length to a target
SWEP.SequenceRateOverrideScaled = {} --Like above but scales animation length rather than being absolute

SWEP.ProceduralHoslterEnabled = nil
SWEP.ProceduralHolsterTime = 0.3
SWEP.ProceduralHolsterPos = Vector(3, 0, -5)
SWEP.ProceduralHolsterAng = Vector(-40, -30, 10)

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation
--MDL Animations Below
--[[SWEP.IronAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_To_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_To_Iron_Dry",
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_Iron_Dry"
	}, --Looping Animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Iron_To_Idle", --Number for act, String/Number for sequence
		["value_empty"] = "Iron_To_Idle_Dry",
		["transition"] = true
	}, --Outward transition
	["shoot"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Fire_Iron", --Number for act, String/Number for sequence
		["value_last"] = "Fire_Iron_Last",
		["value_empty"] = "Fire_Iron_Dry"
	} --What do you think
}]]

SWEP.SprintAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SPRINT_ENTER, --Number for act, String/Number for sequence
		["value_empty"] = ACT_VM_SPRINT_ENTER,
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SPRINT_IDLE, --Number for act, String/Number for sequence
		["value_empty"] = ACT_VM_SPRINT_IDLE,
		["is_idle"] = true
	},--looping animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SPRINT_LEAVE, --Number for act, String/Number for sequence
		["value_empty"] = ACT_VM_SPRINT_LEAVE,
		["transition"] = true
	} --Outward transition
}
--[[EFFECTS]]--
--Attachments
SWEP.MuzzleAttachment			= "1" 		-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellAttachment			= "2" 		-- Should be "2" for CSS models or "shell" for hl2 models
SWEP.MuzzleFlashEnabled = true --Enable muzzle flash
SWEP.MuzzleAttachmentRaw = nil --This will override whatever string you gave.  This is the raw attachment number.  This is overridden or created when a gun makes a muzzle event.
SWEP.AutoDetectMuzzleAttachment = false --For multi-barrel weapons, detect the proper attachment?
SWEP.MuzzleFlashEffect = nil --Change to a string of your muzzle flash effect.  Copy/paste one of the existing from the base.
SWEP.SmokeParticle = nil --Smoke particle (ID within the PCF), defaults to something else based on holdtype; "" to disable
SWEP.EjectionSmokeEnabled = true --Disable automatic ejection smoke
--Shell eject override
SWEP.LuaShellEject = false --Enable shell ejection through lua?
SWEP.LuaShellEjectDelay = 0 --The delay to actually eject things
SWEP.LuaShellEffect = nil --The effect used for shell ejection; Defaults to that used for blowback
--Tracer Stuff
SWEP.TracerName 		= nil 	--Change to a string of your tracer name.  Can be custom. There is a nice example at https://github.com/garrynewman/garrysmod/blob/master/garrysmod/gamemodes/base/entities/effects/tooltracer.lua
SWEP.TracerCount 		= 3 	--0 disables, otherwise, 1 in X chance
--Impact Effects
SWEP.ImpactEffect = nil--Impact Effect
SWEP.ImpactDecal = nil--Impact Decal
--[[EVENT TABLE]]--
SWEP.EventTable = {} --Event Table, used for custom events when an action is played.  This can even do stuff like playing a pump animation after shooting.
--example:
--SWEP.EventTable = {
--	[ACT_VM_RELOAD] = {
--		{ ["time"] = 0.1, ["type"] = "lua", ["value"] = function( wep, viewmodel ) end, ["client"] = true, ["server"] = true},
--		{ ["time"] = 0.1, ["type"] = "sound", ["value"] = Sound("x") }
--	}
--}
--[[RENDER TARGET]]--
SWEP.RTMaterialOverride = nil -- Take the material you want out of print(LocalPlayer():GetViewModel():GetMaterials()), subtract 1 from its index, and set it to this.
SWEP.RTOpaque = false -- Do you want your render target to be opaque?
SWEP.RTCode = nil--function(self) return end --This is the function to draw onto your rendertarget
--[[AKIMBO]]--
SWEP.Akimbo = false --Akimbo gun?  Alternates between primary and secondary attacks.
SWEP.AnimCycle = 0 -- Start on the right
--[[ATTACHMENTS]]--
SWEP.VElements = nil --Export from SWEP Creation Kit.  For each item that can/will be toggled, set active=false in its individual table
SWEP.WElements = nil --Export from SWEP Creation Kit.  For each item that can/will be toggled, set active=false in its individual table
SWEP.Attachments = {
	--[MDL_ATTACHMENT] = = { offset = { 0, 0 }, atts = { "si_eotech" }, sel = 0 }
	--Sorry for kind-of copying your syntax, Spy, but it makes it easier on the users and you did an excellent job.  The internal code's all mine anyways.
	--sel allows you to have an attachment pre-selected, and is used internally by the base to show which attachment is selected in each category.
}
SWEP.AttachmentDependencies = {}--{["si_acog"] = {"bg_rail"}}
SWEP.AttachmentExclusions = {}--{ ["si_iron"] = {"bg_heatshield"} }

DEFINE_BASECLASS( SWEP.Base )

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local own = self:GetOwner()
	local shootpos, aimvec = own:GetShootPos(), own:GetAimVector()
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	own:SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapons/wintershowl/plr/shot_plr_fnt.ogg")
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay) -- Just regular SWEP stuff
	self:SetStatus(TFA.GetStatus("shooting"))
	self:SetStatusEnd(CurTime() + self.Primary.Delay - 0.05)
	self:TakePrimaryAmmo(1)
	own:ViewPunch(Angle( math.Rand(-self.Primary.KickHorizontal, self.Primary.KickHorizontal), math.Rand(-self.Primary.KickUp, self.Primary.KickDown), 0))
	
	if SERVER then
		local orb1 = ents.Create("obj_whowl_proj") -- Launch the projectile. Purely visual.
		orb1:SetPos(shootpos)
		orb1:SetAngles(own:EyeAngles())
		orb1:Spawn()
		local phys = orb1:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocityInstantaneous(aimvec * 1000)
		end
	end
	-- Now this is where the magic happens
	local dmg = DamageInfo()
	dmg:SetDamageType(bit.bor(DMG_VEHICLE, DMG_REMOVENORAGDOLL))
	dmg:SetAttacker(own)
	dmg:SetInflictor(self)
	dmg:SetDamage(self.Primary_TFA.Damage)
	dmg:SetDamageForce(vector_origin)
	
	for k, v in pairs(ents.FindInCone(shootpos, aimvec, 512, 0.9)) do 
		if v:Health() <= 0 then continue end -- Ignore the dead
		
		local dmgFilter = v:GetInternalVariable("m_hDamageFilter") -- Ignore anything that filters out freeze damage.
		if IsValid(dmgFilter) and !dmgFilter:PassesDamageFilter(dmg) then continue end
		
		if !v:IsPlayer() and !v:IsNPC() and !v:IsNextBot() then continue end -- and uninteresting entities.
		if v:IsPlayer() and (v == self.Owner or !hook.Run("PlayerShouldTakeDamage", v, own)) then continue end -- Don't hit the owner and avoid friendly fire.
		if HORDE and v:IsPlayer() then continue end -- Horde: never freeze players
		if TFAWW_Resists and TFAWW_Resists(v) then -- Horde: bosses and elites take the damage but don't freeze
			if SERVER then v:TakeDamageInfo(dmg) end
			continue
		end
		--tr.endpos = v:WorldSpaceCenter()
		--local tr1 = util.TraceLine(tr)
		--if tr1.Hit then continue end -- Don't hit objects behind cover.
		
		if v:Health() > self.Primary_TFA.Damage + 1 then
			v:SetMaterial("models/weapons/black_ops_1/freeze_gun/rus_ter_ice_slush")
			ParticleEffectAttach("frost_char_cloud", PATTACH_POINT_FOLLOW, v, 2)
			
			if SERVER then
				v:SetNW2Float( "IceStaffSlow", 8 )
				v:TakeDamageInfo(dmg)
				tfaww_icestaffed[v:EntIndex()] = v
				
				if v.RestoreSpeed == nil then
					if v:IsNextBot() then
						v.RestoreSpeed = v.loco:GetDesiredSpeed()
						v:SetDesiredSpeed(v.RestoreSpeed*0.25)
					elseif v:IsNPC() then
						v:SetPlaybackRate(0.5)
					else
						v.RestoreSpeed = v:GetMaxSpeed()
						v:SetMaxSpeed(v.RestoreSpeed*0.25)
						v:ConCommand("pp_mat_overlay hud/freeze_screen")
					end
				end
			end
		elseif v:Health() > 1 then
			v:SetMaterial("models/weapons/black_ops_1/freeze_gun/rus_ter_ice_slush")
			ParticleEffectAttach("frost_char_cloud", PATTACH_POINT_FOLLOW, v, 2)
			local eff = EffectData()
			eff:SetEntity(v)
			eff:SetAttachment(v:LookupAttachment("chest"))
			util.Effect("wintershowl_freeze", eff)
			
			if SERVER then
				v:SetNW2Float( "IceStaffSlow", math.Rand(3,5) )
				if not HORDE then v:SetHealth(1) end
				v.LastIceAttacker = self.Owner
				v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				tfaww_icestaffed[v:EntIndex()] = v
				
				if v:IsNextBot() then
					v.BehaveThread = coroutine.create(function() -- Cripple the nextbot
						coroutine.wait(6)
						v.BehaveThread = oldThread
					end)
					v.loco:SetDesiredSpeed(0)
				elseif v:IsNPC() then
					v:SetSchedule(SCHED_NPC_FREEZE)
				else
					v:Freeze(true)
				end
			end
		end
	end
end


function SWEP:PreDrawViewModel( vm )
	BaseClass.PreDrawViewModel(self, vm)
	if self.Ispackapunched then
		vm:SetSubMaterial(0, self.nzPaPCamo)
	else
		vm:SetSubMaterial(0, nil)
	end
end

--[[
CurVMPos = Vector(1, 0, -0.2)
CurVMAng = Vector(1, 0, 0)

function SWEP:Think2()
   BaseClass.Think2(self)
		if (self.Owner:GetVelocity():Length2DSqr() > 7000) and !self:GetIronSights() and !(self:GetStatus() == TFA.Enum.STATUS_RELOADING) then
			CurVMPos = Lerp(0.1, CurVMPos, Vector(-1.5, 0, -2.1))
			CurVMAng = Lerp(0.2, CurVMAng, Vector(1, 0, -2))
			--self.BobScaleCustom = 1
		else
			CurVMPos = Lerp(0.1, CurVMPos, Vector(1, 0, -0.2))
			CurVMAng = Lerp(0.2, CurVMAng, Vector(0, 0, 0))
		end
	self.VMPos = CurVMPos --The viewmodel positional offset, constantly.  Subtract this from any other modifications to viewmodel position.
	self.VMAng = CurVMPos --The viewmodel angular offset, constantly.   Subtract this from any other modifications to viewmodel angle.
end]]