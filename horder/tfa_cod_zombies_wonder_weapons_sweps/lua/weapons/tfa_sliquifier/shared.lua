SWEP.Firstdraw = 1
SWEP.BlowbackEnabled = true --Enable Blowback?
SWEP.BlowbackVector = Vector(0,-1,0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil --Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = false --Do we recover from blowback when empty?
SWEP.Blowback_Shell_Enabled = false
SWEP.Blowback_Shell_Effect = "nil"-- ShotgunShellEject shotgun or ShellEject for a SMG    
SWEP.TracerCount 		= 0 	--0 disables, otherwise, 1 in X chance
SWEP.Primary.Delay			= 0.35
 
SWEP.UseHands				= true
SWEP.DisableChambering		= true
SWEP.Type					= "Wonder Weapon"
SWEP.Category				= "TFA Wonder Weapons"
SWEP.SubCategory			= "Black Ops II"
SWEP.Author				= "Deika & Hidden"
SWEP.Contact				= ""
SWEP.Purpose				= "A handcrafted piece of junk that will boil the skin off the undead and make a slippery puddle."
SWEP.Instructions				= ""
SWEP.MuzzleAttachment			= "muzzle" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "Sliquifier"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 2				-- Slot in the weapon selection menu
SWEP.SlotPos				= 4			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= true		-- set false if you want no crosshair
SWEP.Weight				= 30			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "ar2"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles
SWEP.Primary.HullSize = 150
SWEP.SelectiveFire		= false
SWEP.CanBeSilenced		= false
SWEP.ViewModelFOV			= 72
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/black_ops_2/sliquifier/c_slipgun.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/black_ops_2/sliquifier/w_slipgun.mdl"	-- Weapon world model
SWEP.Base					= "tfa_gun_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false
--[[
game.AddAmmoType( {
 name = "Unknown Substance",
 dmgtype = DMG_ACID,
 tracer = TRACER_LINE,
 plydmg = 0,
 npcdmg = 0
} )
]]
SWEP.Primary.Sound			= Sound("Weapon_Slipgun.Shoot")		-- Script that calls the primary fire sound
SWEP.Primary.RPM			= 181			-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 10		-- Size of a clip
SWEP.Primary.DefaultClip		= 50		-- Bullets you start with
--Recoil Related
SWEP.Primary.KickUp			= 0.17				-- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown			= 0.13				-- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal			= 0.2					-- This is the maximum sideways recoil (no real term)
SWEP.Primary.StaticRecoilFactor = 0.3 	--Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.

-- nZombies Stuff
SWEP.NZWonderWeapon		= true	-- Is this a Wonder-Weapon? If true, only one player can have it at a time. Cheats aren't stopped, though.
--SWEP.NZRePaPText		= "your text here"	-- When RePaPing, what should be shown? Example: Press E to your text here for 2000 points.
SWEP.NZPaPName				= "Sl1qu1f13r"
--SWEP.NZPaPReplacement 	= ""	-- If Pack-a-Punched, replace this gun with the entity class shown here.
SWEP.NZPreventBox		= false	-- If true, this gun won't be placed in random boxes GENERATED. Users can still place it in manually.
SWEP.NZTotalBlackList	= false	-- if true, this gun can't be placed in the box, even manually, and can't be bought off a wall, even if placed manually. Only code can give this gun.
SWEP.nzPaPCamo			= "models/weapons/black_ops_2/camos/camo_zombies.vmt"

-- Max Ammo function
SWEP.Primary.MaxAmmo = 40

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
    self.Primary_TFA.ClipSize = 12
	self.Primary_TFA.MaxAmmo = 60
    self:GetStat("Primary.MaxAmmo")
    return true
end

SWEP.Ispackapunched = false
-- Selective Fire Stuff

SWEP.Primary.Automatic			= true		-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "Snark"			-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet. Use AirboatGun for a light metal peircing shotgun pellets

SWEP.Secondary.IronFOV			= 75		-- How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}				--The starting firemode
SWEP.data.ironsights			= 1

SWEP.Primary.NumShots	= nil		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 5500000	-- Base damage per bullet
SWEP.Primary.Spread		= .007	-- Define from-the-hip accuracy 1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = .01 -- Ironsight accuracy, should be the same for shotguns

-- Enter iron sight info and bone mod info below
SWEP.IronSightsPos = Vector(-2.65, -3.6, 0.65)
SWEP.IronSightsAng = Vector(-0.19, 0.0, 0)
SWEP.RunSightsPos = Vector (-1.5, 0, 0)
SWEP.RunSightsAng = Vector (-21, 25.0, -24.5)
SWEP.InspectPos = Vector(5.92, 0, -1.441)
SWEP.InspectAng = Vector(13.199, 26.6, 10)

SWEP.customboboffset = Vector(0,0,0)
--[[
SWEP.Offset = {
        Pos = {
        Up = 0,
        Right = 0,
        Forward = -2,
        },
        Ang = {
        Up = 0,
        Right = -10,
        Forward = 180,
        },
		Scale = 1.0
}
]]
SWEP.VMPos = Vector(-0.3, -1.5, 0) --The viewmodel positional offset, constantly.  Subtract this from any other modifications to viewmodel position.
SWEP.VMAng = Vector(0, 0, 0) --The viewmodel angular offset, constantly.   Subtract this from any other modifications to viewmodel angle.

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	self:SetStatus(TFA.GetStatus("shooting"))
	self:SetStatusEnd(CurTime() + self.Primary.Delay - 0.05)
	
	local own = self:GetOwner()
	local aimvec = own:GetAimVector()
	
	local funnyday = (os.date( "%d/%m" ) == "01/04" )
	local muzzlename = "slipgun_muzzle"
	if funnyday then
		muzzlename = muzzlename.."_white"
	elseif self.Ispackapunched then
		muzzlename = muzzlename.."_pap"
	end
	
	if SERVER then
		local orb1 = ents.Create("obj_sliquifier_proj")
		--debugoverlay.Sphere(pos,5) 
		orb1:SetUpgraded(self.Ispackapunched)
		orb1:SetFunny(funnyday)
		orb1:SetPos(own:GetShootPos())
		orb1:SetAngles(angle_zero)
		orb1:SetOwner(own)
		orb1.MaxChain = self.Ispackapunched and 24 or 12
		orb1:Spawn()
		orb1:Activate()
		orb1:SetVelocity(aimvec * 1000 + Vector(0, 0, 64))
	end
	
	ParticleEffectAttach( muzzlename, PATTACH_POINT_FOLLOW, self:IsFirstPerson() and own:GetViewModel() or self, 1 )
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	own:SetAnimation( PLAYER_ATTACK1 )
	self:TakePrimaryAmmo(1)
	if self:Clip1() == 0 then
		self:EmitSound("weapons/slipgun/slipgun_lastshot.ogg", 65, 100, 0.4, CHAN_WEAPON)
	else
		self:EmitSound("weapons/slipgun/slipgun_shot_0"..math.random(0,1)..".ogg", 65, 100, 0.4, CHAN_WEAPON)
	end
	own:ViewPunch(Angle(-2, 0))
end

DEFINE_BASECLASS( SWEP.Base )


function SWEP:PreDrawViewModel( vm )
	BaseClass.PreDrawViewModel(self, vm)
	if self.Ispackapunched then
		vm:SetSubMaterial(0, self.nzPaPCamo)
		vm:SetSubMaterial(1, "models/weapons/black_ops_2/slipgun/mtl_t6_wpn_zmb_slipgun_scroll_p")
	else
		vm:SetSubMaterial(0, nil)
		vm:SetSubMaterial(1, nil)
	end
end