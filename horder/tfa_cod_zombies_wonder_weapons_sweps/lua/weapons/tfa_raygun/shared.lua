--SWEP.Firstdraw = 1
SWEP.BlowbackEnabled = false --Enable Blowback?
SWEP.BlowbackVector = Vector(0,-1,0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil --Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = false --Do we recover from blowback when empty?
SWEP.Blowback_Shell_Enabled = false
SWEP.Blowback_Shell_Effect = "nil"-- ShotgunShellEject shotgun or ShellEject for a SMG    
--SWEP.MuzzleFlashEffect = "raygun_sparks"
SWEP.TracerCount 		= 0 	--0 disables, otherwise, 1 in X chance
SWEP.Primary.Delay			= 0.34
 
SWEP.UseHands				= true
SWEP.DisableChambering		= true
SWEP.Type					= "Wonder Weapon"
SWEP.Category				= "TFA Wonder Weapons"
SWEP.SubCategory			= "World at War"
SWEP.Author					= "Hidden & Raven"
SWEP.Contact				= ""
SWEP.Purpose				= "Make sure your teammates revive you because you have the Ray Gun. Other than that, shoot zombies."
SWEP.Instructions				= ""
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "Ray Gun"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 1				-- Slot in the weapon selection menu
SWEP.SlotPos				= 3			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= false	-- Should the weapon icon bounce?
if CLIENT then
	SWEP.WepSelectIcon			= surface.GetTextureID( "vgui/hud/tfa_raygun" )
end
SWEP.DrawCrosshair			= true		-- set false if you want no crosshair
SWEP.Weight				= 30			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "pistol"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles
SWEP.Primary.HullSize = 150
SWEP.SelectiveFire		= false
SWEP.CanBeSilenced		= false
SWEP.ViewModelFOV			= 64
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/world_at_war/raygun/v_raygun.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/world_at_war/raygun/w_raygun.mdl"	-- Weapon world model
SWEP.Base				= "tfa_gun_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false
SWEP.Primary.Knockback = 20

SWEP.Primary.Sound			= Sound("raygun_fire.wav")		-- Script that calls the primary fire sound
SWEP.Primary.RPM			= 181			-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 20		-- Size of a clip
SWEP.Primary.DefaultClip		= 180		-- Bullets you start with

-- nZombies Stuff
SWEP.NZWonderWeapon		= false	-- Is this a Wonder-Weapon? If true, only one player can have it at a time. Cheats aren't stopped, though.
--SWEP.NZRePaPText		= "your text here"	-- When RePaPing, what should be shown? Example: Press E to your text here for 2000 points.
SWEP.NZPaPName				= "Porter's X2 Ray Gun"
--SWEP.NZPaPReplacement 	= ""	-- If Pack-a-Punched, replace this gun with the entity class shown here.
SWEP.NZPreventBox		= false	-- If true, this gun won't be placed in random boxes GENERATED. Users can still place it in manually.
SWEP.NZTotalBlackList	= false	-- if true, this gun can't be placed in the box, even manually, and can't be bought off a wall, even if placed manually. Only code can give this gun.
SWEP.nzPaPCamo			= "models/weapons/world_at_war/camos/pap_camo.vmt"

-- Max Ammo function
SWEP.Primary.MaxAmmo = 160

function SWEP:NZMaxAmmo()

	local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo

    if SERVER then
        self:GetOwner():SetAmmo( self:GetStat("Primary.MaxAmmo"), ammo_type )
		self:SetClip1( self:GetStat("Primary_TFA.ClipSize") )
    end
end

-- PaP Function
function SWEP:OnPaP()
    self:ClearStatCache()
    self.Ispackapunched = true 
    self.Primary_TFA.ClipSize = 40
	self.Primary_TFA.MaxAmmo = 200
    self:GetStat("Primary.MaxAmmo")
    return true
end

SWEP.Ispackapunched = false
--Recoil Related
SWEP.Primary.KickUp			= 0.19				-- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown			= 0.11				-- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal			= 0.2					-- This is the maximum sideways recoil (no real term)
SWEP.Primary.StaticRecoilFactor = 0.3 	--Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.

SWEP.Primary.Automatic			= true		-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "Battery"			-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet. Use AirboatGun for a light metal peircing shotgun pellets

SWEP.Secondary.IronFOV			= 80		-- How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}				--The starting firemode
SWEP.data.ironsights			= 1

SWEP.Primary.NumShots	= nil		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 115	-- Base damage per bullet
SWEP.Primary.Spread		= .021	-- Define from-the-hip accuracy 1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = .01 -- Ironsight accuracy, should be the same for shotguns

-- Enter iron sight info and bone mod info below
SWEP.IronSightsPos = Vector(-5.15, 0.602, 1.45)
SWEP.IronSightsAng = Vector(-2.3, 0.05, 0)
SWEP.RunSightsPos = Vector (4.76, 0, -0.201)
SWEP.RunSightsAng = Vector (-5, 4.4, 9.1)
SWEP.InspectPos = Vector(5.92, 0, -1.441)
SWEP.InspectAng = Vector(13.199, 26.6, 10)

SWEP.customboboffset = Vector(0,0,0)

SWEP.ViewModelBoneMods = {
	["tag_view"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
--[[
SWEP.Offset = {
        Pos = {
        Up = 0,
        Right = 0,
        Forward = -2,
        },
        Ang = {
        Up = 0,
        Right = -9,
        Forward = 180,
        },
		Scale = 1.0
}
]]
SWEP.VMPos = Vector(0, 6, 0.4) --The viewmodel positional offset, constantly.  Subtract this from any other modifications to viewmodel position.
SWEP.VMAng = Vector(1.5, 0, 0) --The viewmodel angular offset, constantly.   Subtract this from any other modifications to viewmodel angle.

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Idle_Mode = TFA.Enum.IDLE_LUA --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation


CurVMPos = Vector(1, 0, -0.2)
CurVMAng = Vector(1, 0, 0)

DEFINE_BASECLASS( SWEP.Base )

function SWEP:PreDrawViewModel( vm )
	BaseClass.PreDrawViewModel(self, vm)
	if self.Ispackapunched then
		vm:SetSubMaterial(0, self.nzPaPCamo)
		vm:SetSubMaterial(1, "models/weapons/black_ops_1/wavegun/mtl_zombie_teleporter_glow.vmt")
	else
		vm:SetSubMaterial(0, nil)
		vm:SetSubMaterial(1, nil)
	end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local own = self:GetOwner()
	local shootpos = own:GetShootPos() + VectorRand(-4, 4)
	local aimvec = own:GetAimVector()
	
	if SERVER then
		local proj = ents.Create("obj_rgun_proj")
		
		proj:SetPos(shootpos)
		proj:SetAngles(own:EyeAngles())
		proj:SetUpgraded(self.Ispackapunched)
		proj:SetOwner(own)
		proj:Spawn()
		proj:Activate()
		proj:SetVelocity(aimvec*3000)
	end
	
	if self:GetIronSights() then
		shootpos = shootpos + aimvec*38 - own:GetUp()*6
	else
		shootpos = shootpos + aimvec*38 - own:GetUp()*7 + own:GetRight()*13
	end
	ParticleEffect( self.Ispackapunched and "raygun_muzzle_pap" or "raygun_muzzle", shootpos, own:EyeAngles() + Angle(90,0,0))
	
	own:ViewPunch(Angle(-2, 0, 0))
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	own:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound("weapons/raygun/wpn_ray_fire.mp3", 75)
	self:EmitSound("weapons/raygun/wpn_ray_flux.ogg", 75, 100, 0.3, CHAN_ITEM)
	
	self:SetStatus(TFA.GetStatus("shooting"))
	self:SetStatusEnd(CurTime() + self.Primary.Delay - 0.05)
	
	own:SetVelocity( (own:GetAimVector()* -self.Primary.Knockback) )
	self:TakePrimaryAmmo(1)
end