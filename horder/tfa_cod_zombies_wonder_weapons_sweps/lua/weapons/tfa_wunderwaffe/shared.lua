SWEP.Gun					= ("weapon_wunderwaffe") --Make sure this is unique.  Specically, your folder name.
if (GetConVar(SWEP.Gun.."_allowed")) != nil then
	if not (GetConVar(SWEP.Gun.."_allowed"):GetBool()) then SWEP.Base = "tfa_blacklisted" SWEP.PrintName = SWEP.Gun return end
end
SWEP.Base				= "tfa_gun_base"
SWEP.Category				= "TFA Wonder Weapons" --The category.  Please, just choose something generic or something I've already done if you plan on only doing like one swep.
SWEP.SubCategory			= "World at War"
SWEP.Manufacturer = nil --Gun Manufactrer (e.g. Hoeckler and Koch )
SWEP.Author				= "Deika & Hidden" --Author Tooltip
SWEP.Contact				= "" --Contact Info Tooltip
SWEP.Purpose				= "Shock the undead with this good old lightning gun." --Purpose Tooltip
SWEP.Instructions			= "" --Instructions Tooltip
SWEP.Spawnable				= true --Can you, as a normal user, spawn this?
SWEP.AdminSpawnable			= true --Can an adminstrator spawn this?  Does not tie into your admin mod necessarily, unless its coded to allow for GMod's default ranks somewhere in its code.  Evolve and ULX should work, but try to use weapon restriction rather than these.
SWEP.DrawCrosshair			= true		-- Draw the crosshair?
SWEP.DrawCrosshairIS 		= false --Draw the crosshair in ironsights?
SWEP.PrintName				= "Wunderwaffe DG-2"		-- Weapon name (Shown on HUD)
SWEP.Slot					= 3				-- Slot in the weapon selection menu.  Subtract 1, as this starts at 0.
SWEP.SlotPos				= 12			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter if enabled in the GUI.
SWEP.DrawWeaponInfoBox		= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   	= false	-- Should the weapon icon bounce?
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.Weight					= 30			-- This controls how "good" the weapon is for autopickup.
SWEP.Primary.Recoil			= 0.5
SWEP.Type					= "Wonder Weapon"
SWEP.Range = GetConVarNumber( "sk_vortigaunt_zap_range",100)*24

--[[WEAPON HANDLING]]--

--Firing related
SWEP.Primary.Sound 			= Sound("weapons/tesla_gun/new/wpn_tesla_flux.mp3")				-- This is the sound of the weapon, when you shoot.
SWEP.Primary.SilencedSound 			= nil				-- This is the sound of the weapon, when silenced.
SWEP.Primary.PenetrationMultiplier = 1 --Change the amount of something this gun can penetrate through
SWEP.Primary.Damage		= 115					-- Damage, in standard damage points.
SWEP.Primary.HullSize = 0 --Big bullets, increase this value.  They increase the hull size of the hitscan bullet.
SWEP.DamageType = nil --See DMG enum.  This might be DMG_SHOCK, DMG_BURN, DMG_BULLET, etc.
SWEP.Primary.NumShots	= nil --The number of shots the weapon fires.  SWEP.Shotgun is NOT required for this to be >1.
SWEP.Primary.Automatic			= true					-- Automatic/Semi Auto
SWEP.Primary.RPM				= 60					-- This is in Rounds Per Minute / RPM
SWEP.FiresUnderwater = false

-- nZombies Stuff
SWEP.NZWonderWeapon		= true	-- Is this a Wonder-Weapon? If true, only one player can have it at a time. Cheats aren't stopped, though.
--SWEP.NZRePaPText		= "your text here"	-- When RePaPing, what should be shown? Example: Press E to your text here for 2000 points.
SWEP.NZPaPName				= "Wunderwaffe DG-3 JZ"
--SWEP.NZPaPReplacement 	= ""	-- If Pack-a-Punched, replace this gun with the entity class shown here.
SWEP.NZPreventBox		= false	-- If true, this gun won't be placed in random boxes GENERATED. Users can still place it in manually.
SWEP.NZTotalBlackList	= false	-- if true, this gun can't be placed in the box, even manually, and can't be bought off a wall, even if placed manually. Only code can give this gun.
SWEP.nzPaPCamo			= "models/weapons/world_at_war/camos/pap_camo.vmt"

-- Max Ammo function
SWEP.Primary.MaxAmmo = 15

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
    self.Primary_TFA.ClipSize = 6
	self.Primary_TFA.MaxAmmo = 30
    self:GetStat("Primary.MaxAmmo")
    return true
end

SWEP.Ispackapunched = false
-- Selective Fire Stuff

SWEP.SelectiveFire		= false --Allow selecting your firemode?
SWEP.DefaultFireMode 	= "Auto" --Default to auto or whatev

--Ammo Related

SWEP.Primary.ClipSize			= 3					-- This is the size of a clip
SWEP.Primary.DefaultClip			= 18				-- This is the number of bullets the gun gives you, counting a clip as defined directly above.
SWEP.Primary.Ammo			= "CombineCannon"					-- What kind of ammo.  Options, besides custom, include pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, and AirboatGun.
SWEP.Primary.AmmoConsumption = 1 --Ammo consumed per shot
SWEP.DisableChambering = true
--Pistol, buckshot, and slam like to ricochet. Use AirboatGun for a light metal peircing shotgun pellets

--Recoil Related
SWEP.Primary.KickUp            = 0.5                -- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown            = 0.3                    -- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal            = 0.2                -- This is the maximum sideways recoil (no real term)
SWEP.Primary.StaticRecoilFactor = 0.5     --Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.

--Firing Cone Related

SWEP.Primary.Spread		= .01					--This is hip-fire acuracy.  Less is more (1 is horribly awful, .0001 is close to perfect)
SWEP.Primary.IronAccuracy = .005	-- Ironsight accuracy, should be the same for shotguns

--[[PROJECTILES]]--

--SWEP.ProjectileEntity = "obj_blank_proj" --Entity to shoot
--SWEP.ProjectileVelocity = 50000 --Entity to shoot's velocity
--SWEP.ProjectileModel = nil --Entity to shoot's model

--[[VIEWMODEL]]--

SWEP.ViewModel			= "models/weapons/world_at_war/wunderwaffe/v_wunderwaffe.mdl" --Viewmodel path
SWEP.ViewModelFOV			= 75		-- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip			= false		-- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.MaterialTable = nil --Make sure the viewmodel and the worldmodel have the same material ids.  Next, fill this in with your desired submaterials.
SWEP.UseHands = true --Use gmod c_arms system.
SWEP.VMPos = Vector(0.25, -3, -1.50)
SWEP.VMAng = Vector(0, 0, 0)

--[[WORLDMODEL]]--

SWEP.WorldModel			= "models/weapons/world_at_war/wunderwaffe/w_wunderwaffe.mdl" -- Weapon world model path

SWEP.WMBodyGroups = nil--{
	--[0] = 1,
	--[1] = 4,
	--[2] = etc.
--}

SWEP.HoldType 				= "ar2"		

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = 0,
        Right = 0,
        Forward = 0,
        },
        Ang = {
        Up = -1,
        Right = -2,
        Forward = 178
        },
		Scale = 1
}





--[[IRONSIGHTS]]--

SWEP.data 				= {}
SWEP.data.ironsights			= 1 --Enable Ironsights
SWEP.Secondary.IronFOV			= 70					-- How much you 'zoom' in. Less is more!  Don't have this be <= 0.  A good value for ironsights is like 70.

SWEP.IronSightsPos = Vector(-5.10, -3.7, 2.0)
SWEP.IronSightsAng = Vector(-1.55, -0.055, 0)
SWEP.RunSightsPos = Vector(0.0, -7.5, 0.0)
SWEP.RunSightsAng = Vector(-20.0, 50.0, -32.0)

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Idle_Mode = TFA.Enum.IDLE_LUA --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation


--[[INSPECTION]]--

--SWEP.InspectPos = Vector(0,0,0) --Replace with a vector, in style of ironsights position, to be used for inspection
--SWEP.InspectAng = Vector(0,0,0) --Replace with a vector, in style of ironsights angle, to be used for inspection



--[[Stuff you SHOULD NOT touch after this]]--

--Allowed VAnimations.  These are autodetected, so not really needed except as an extra precaution.  Do NOT change these, unless absolutely necessary.

SWEP.CanDrawAnimate=true
SWEP.CanDrawAnimateEmpty=false
SWEP.CanDrawAnimateSilenced=false
SWEP.CanHolsterAnimate=true
SWEP.CanHolsterAnimateEmpty=false
SWEP.CanIdleAnimate=true
SWEP.CanIdleAnimateEmpty=false
SWEP.CanIdleAnimateSilenced=false
SWEP.CanShootAnimate=true
SWEP.CanShootAnimateSilenced=false
SWEP.CanReloadAnimate=true
SWEP.CanReloadAnimateEmpty=false
SWEP.CanReloadAnimateSilenced=false
SWEP.CanDryFireAnimate=false
SWEP.CanDryFireAnimateSilenced=false
SWEP.CanSilencerAttachAnimate=false
SWEP.CanSilencerDetachAnimate=false

--Misc

SWEP.ShouldDrawAmmoHUD=false--THIS IS PROCEDURALLY CHANGED AND SHOULD NOT BE TWEAKED.  BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.DefaultFOV=90 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.

--Disable secondary crap

SWEP.Secondary.ClipSize			= 0					-- Size of a clip
SWEP.Secondary.DefaultClip			= 0					-- Default ammo to give...
SWEP.Secondary.Automatic			= false					-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none" -- Self explanitory, ammo type.

--[[EFFECTS]]--
--Attachments
SWEP.MuzzleAttachment			= "1" 		-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellAttachment			= "2" 		-- Should be "2" for CSS models or "shell" for hl2 models
SWEP.MuzzleFlashEnabled = false --Enable muzzle flash
SWEP.MuzzleAttachmentRaw = nil --This will override whatever string you gave.  This is the raw attachment number.  This is overridden or created when a gun makes a muzzle event.
SWEP.AutoDetectMuzzleAttachment = false --For multi-barrel weapons, detect the proper attachment?
SWEP.MuzzleFlashEffect = nil --Change to a string of your muzzle flash effect.  Copy/paste one of the existing from the base.
SWEP.SmokeParticle = nil --Smoke particle (ID within the PCF), defaults to something else based on holdtype; "" to disable
SWEP.EjectionSmokeEnabled = true --Disable automatic ejection smoke

--Convar support

SWEP.ConDamageMultiplier = 1

SWEP.Base				= "tfa_gun_base"

DEFINE_BASECLASS( SWEP.Base )

function SWEP:Initialize()
	BaseClass.Initialize(self)
	if CLIENT then
		self.LoopingSound = CreateSound( self, "weapons/tesla_gun/wpn_tesla_idle_d.wav")
	end
	
	-- First Raise = 9091
	-- Pullout = 9001
	-- Fire = 9061
	-- Finish Reload = 9071
	-- Start Reload = 9081
	self.FuncList = {
		[9001] = function() 
			local own = self:GetOwner()
			local vm = own:GetViewModel()
			local lightpcf = self.Ispackapunched and "tesla_vm_glow_pap" or "tesla_vm_glow"
			
			vm:StopParticles()
			if self:Clip1() > 0 then self.LoopingSound:Play() end
			if self.Ispackapunched then
				for i = 1, math.Round(self:Clip1()/2) do
					ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, i+1) -- Pullout
				end
			else
				for i = 1, self:Clip1() do
					ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, i+1)
				end
			end
			if self:Clip1() > 0 then
				ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, 5)
			end
		end,
		[9061] = function() 
			local own = self:GetOwner()
			local vm = own:GetViewModel()
			local lightpcf = self.Ispackapunched and "tesla_vm_glow_pap" or "tesla_vm_glow"
			
			vm:StopParticles()
			if self.Ispackapunched then
				for i = 1, math.Round(self:Clip1()/2) do
					ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, i+1)
				end
				ParticleEffectAttach( "tesla_mflash_pap", PATTACH_POINT_FOLLOW, vm, 1) -- Fire
			else
				for i = 1, self:Clip1() do
					ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, i+1)
				end
				ParticleEffectAttach( "tesla_mflash", PATTACH_POINT_FOLLOW, vm, 1)
			end
			if self:Clip1() > 0 then
				ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, 5)
			else
				self.LoopingSound:Stop()
			end
		end,
		[9071] = function() 
			local own = self:GetOwner()
			local vm = own:GetViewModel()
			local lightpcf = self.Ispackapunched and "tesla_vm_glow_pap" or "tesla_vm_glow"
			
			vm:StopParticles()
			for i = 1, self.LightNum do
				ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, i+1) --Finish reloading
			end
			if self.LightNum > 0 then
				ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, 5)
			end
			timer.Simple(0.25, function() 
				if IsValid(self) then
					self.LoopingSound:Play()
				end
			end)
		end,
		[9081] = function() 
			local own = self:GetOwner()
			local vm = own:GetViewModel()
			
			vm:StopParticles()
			self.LoopingSound:Stop()
		end,
		[9091] = function() 
			local own = self:GetOwner()
			local vm = own:GetViewModel()
			local lightpcf = self.Ispackapunched and "tesla_vm_glow_pap" or "tesla_vm_glow"
			
			ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, 2)
			ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, 3)
			ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, 4)
			ParticleEffectAttach( lightpcf, PATTACH_POINT_FOLLOW, vm, 5) -- First raise
			timer.Simple(0.25, function() 
				if IsValid(self) then
					self.LoopingSound:Play()
				end
			end)
		end
	}
end

SWEP.LightNum = 3
function SWEP:FireAnimationEvent(pos, ang, event, options)
	local own = self:GetOwner()
	
	self.LightNum = math.Clamp(self:Clip1() + self.Owner:GetAmmoCount(self.Primary.Ammo), 0, 3)
	
	local getfunc = self.FuncList[event]
	if getfunc == nil then return end
	getfunc()
end

function SWEP:PrimaryAttack( old )
	if !self:CanPrimaryAttack() then return	end	
	local own = self:GetOwner()
	if SERVER then
		local orb1 = ents.Create("obj_wunderwaffe_proj")
		orb1:SetPos(own:GetShootPos())
		orb1:SetUpgraded(self.Ispackapunched)
		orb1:SetOwner(own)
		orb1:Spawn()
		orb1:Activate()
		orb1:SetVelocity(own:GetAimVector()*3000)
	end
	self:EmitSound(self:Clip1() > 1 and "weapons/tesla_gun/new/wpn_tesla_fire_st.mp3" or "weapons/tesla_gun/new/wpn_tesla_fire_lst.mp3", 80, 100, 1, CHAN_ITEM)
	self:EmitSound(self.Primary.Sound, 110, 100, 0.5, CHAN_WEAPON)
	--self:EmitSound("weapons/tesla_gun/wpn_tesla_flux.mp3", 75, 100, 1, CHAN_WEAPON)
	self.NextWave = CurTime() + math.random(2, 12)
	--BaseClass.PrimaryAttack( self, old )
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	own:SetAnimation( PLAYER_ATTACK1 )
	self:TakePrimaryAmmo(1)
	own:ViewPunch(Angle(-4, 0, 0))
end


function SWEP:Think2()
	BaseClass.Think2(self)
	
	if self.NextWave == nil then self.NextWave = CurTime() + math.random(2, 12) end
	if CLIENT and self:Clip1() > 0 and self.NextWave < CurTime() then
		self.NextWave = CurTime() + 12
		local own = self:GetOwner()
		local vm = own:GetViewModel()
		
		if self.Ispackapunched then
			ParticleEffectAttach( "tesla_vm_excited_pap", PATTACH_POINT_FOLLOW, vm, 1)
		else
			ParticleEffectAttach( "tesla_vm_excited", PATTACH_POINT_FOLLOW, vm, 1)
		end
		surface.PlaySound("weapons/tesla_gun/effects/effects_0"..math.random(0,2)..".mp3")
	end
end

function SWEP:OnRemove()
	if self.LoopingSound then self.LoopingSound:Stop() end
	BaseClass.OnRemove(self)
end

function SWEP:FinishHolster()
	--self:StopSound("weapons/tesla_gun/wpn_tesla_idle_d.wav")
	if self.LoopingSound then self.LoopingSound:Stop() end
	BaseClass.FinishHolster(self)
end

function SWEP:PreDrawViewModel( vm )
	BaseClass.PreDrawViewModel(self, vm)
	if self.Ispackapunched then
		vm:SetSubMaterial(4, self.nzPaPCamo)
	else
		vm:SetSubMaterial(4, nil)
	end
end