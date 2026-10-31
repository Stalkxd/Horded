if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
local BaseClass = HORDE_WW.Base(SWEP.Base)
SWEP.Spawnable = true
SWEP.PrintName = "Zap Gun Dual Wield"
SWEP.Trivia_Desc = "A pair of microwave pistols. Left click fires the left gun, right click the right gun. Press your firemode key (or E + R) to join them into the Wave Gun, which cooks every enemy around the impact from the inside."
SWEP.Trivia_Calibre = "Microwave bolt"
SWEP.Trivia_Mechanism = "Semi-automatic / Wave Gun"
SWEP.Slot = 1

SWEP.ViewModel = "models/weapons/black_ops_1/wavegun/c_zapguns.mdl"
SWEP.WorldModel = "models/weapons/black_ops_1/wavegun/w_zapguns.mdl"
SWEP.MirrorVMWM = false
-- Both world models carry the player's hand attachment bones (one per gun),
-- so bone merge them instead of placing them at the right hand by an offset.
SWEP.WorldModelOffset = false

SWEP.Damage = 250
SWEP.DamageMin = 250
SWEP.DamageType = DMG_SHOCK
SWEP.ShootEntity = "obj_wgun_proj"
SWEP.MuzzleVelocity = 3000
SWEP.WW_AimAtCrosshair = true

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 48
SWEP.Primary.Ammo = "CombineHeavyCannon"
SWEP.WW_Clip2Size = 8 -- right gun; see WW_MaxClip2 in sh_mixin.lua
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false
SWEP.Delay = 60 / 360

SWEP.Recoil = 0.8
SWEP.RecoilSide = 0.4
SWEP.AccuracyMOA = 2

SWEP.ShootSound = "weapons/zapwavegun/microwave_shot.wav"
SWEP.WW_MuzzleParticle = "zgun_muzzle"
SWEP.WW_MuzzleAttachment = 2
SWEP.WW_Akimbo = true
SWEP.WW_NoSights = true

SWEP.HoldtypeActive = "duel"
SWEP.HoldtypeSights = "duel"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_DUEL

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = { Source = "raise_first" },
    ["draw"] = { Source = "raise" },
    ["holster"] = { Source = "holster" },
    ["fire"] = { Source = "fire_left" },
    ["fire_right"] = { Source = "fire_right" },
    ["reload"] = { Source = "reload_both", Time = 95 / 45, MagUpTime = 1.5 },
    ["reload_left"] = { Source = "reload_left", Time = 95 / 45, MagUpTime = 1.5 },
    ["reload_right"] = { Source = "reload_right", Time = 95 / 45, MagUpTime = 1.5 },
    ["combine"] = { Source = "combine", Time = 53 / 30 },
    ["separate"] = { Source = "separate", Time = 41 / 30 },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },

    -- Wave Gun (c_wavegun.mdl)
    ["wave_idle"] = { Source = "idle" },
    ["wave_draw"] = { Source = "raise", Time = 0.8 },
    ["wave_holster"] = { Source = "holster" },
    ["wave_fire"] = { Source = "fire" },
    ["wave_reload"] = { Source = "reload", Time = 128 / 40, MagUpTime = 2.4 },
    ["wave_idle_sprint"] = { Source = "sprint_loop" },
    ["wave_exit_sprint"] = { Source = "sprint_out" },
}

SWEP.WW_ZapViewModel = SWEP.ViewModel
SWEP.WW_ZapWorldModel = SWEP.WorldModel
SWEP.WW_WaveViewModel = "models/weapons/black_ops_1/wavegun/c_wavegun.mdl"
SWEP.WW_WaveWorldModel = "models/weapons/black_ops_1/wavegun/w_wavegun.mdl"
SWEP.WW_WaveEntity = "obj_wgun_proj2"
SWEP.WW_WaveVelocity = 2000
SWEP.WW_WaveDelay = 60 / 100
SWEP.WW_WaveCookDamage = 1000
SWEP.WW_WaveSound = "weapons/zapwavegun/microwave_rifle_shot.wav"

-- WWFlag: joined into the Wave Gun. WWState 1 while joining, 2 while splitting, until WWStateEnd.
local STATE_IDLE, STATE_JOIN, STATE_SPLIT = 0, 1, 2

local WAVE_ANIMS = {
    idle = "wave_idle", draw = "wave_draw", ready = "wave_draw", holster = "wave_holster",
    fire = "wave_fire", reload = "wave_reload", idle_sprint = "wave_idle_sprint",
    exit_sprint = "wave_exit_sprint", enter_sprint = "wave_idle_sprint",
}

function SWEP:Hook_TranslateAnimation(key)
    if self:GetWWFlag() then return WAVE_ANIMS[key] or key end
end

-- Swaps the view and world models to match WWFlag. Runs on both server and client.
function SWEP:WW_SyncModel()
    local wave = self:GetWWFlag()
    local vmodel = wave and self.WW_WaveViewModel or self.WW_ZapViewModel
    if self.ViewModel == vmodel then return false end

    self.ViewModel = vmodel
    self.WorldModel = wave and self.WW_WaveWorldModel or self.WW_ZapWorldModel
    self.HoldtypeActive = wave and "ar2" or "duel"
    self.HoldtypeSights = self.HoldtypeActive
    self.AnimShoot = wave and ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2 or ACT_HL2MP_GESTURE_RANGE_ATTACK_DUEL
    self:SetModel(self.WorldModel)
    self:SetHoldType(self.HoldtypeActive)

    local owner = self:GetOwner()
    if IsValid(owner) and owner:IsPlayer() and owner:GetActiveWeapon() == self
            and (SERVER or owner == LocalPlayer()) then
        local vm = owner:GetViewModel()
        if IsValid(vm) then vm:SetModel(vmodel) end
    end

    -- ArcCW keeps its own copy of the world model, so rebuild it with the new one
    if CLIENT and self.WM then
        self:KillModel(self.WM)
        self.WM = nil
    end
    return true
end

if CLIENT then
    -- Other players never run this weapon's Think, so swap the model here for them
    function SWEP:DrawWorldModel(...)
        self:WW_SyncModel()
        return BaseClass.DrawWorldModel(self, ...)
    end
end

function SWEP:WW_ToggleWave()
    if CLIENT then return end
    if self:GetWWState() ~= STATE_IDLE or self:GetReloading() or self:GetPriorityAnim() then return end
    if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
    if self:GetNWState() == ArcCW.STATE_SPRINT then return end

    local anim
    if self:GetWWFlag() then
        self:SetWWFlag(false)
        self:WW_SyncModel()
        self:SetWWState(STATE_SPLIT)
        anim = "separate"
    else
        self:SetWWState(STATE_JOIN)
        anim = "combine"
    end
    local t = self.Animations[anim].Time
    self:SetWWStateEnd(CurTime() + t)
    self:SetNextPrimaryFire(CurTime() + t)
    self:SetNextSecondaryFire(CurTime() + t)
    self:PlayAnimation(anim, 1, false, 0, false, nil, true)
end

-- ArcCW's firemode key joins or splits the guns
function SWEP:Hook_ChangeFiremode()
    self:WW_ToggleWave()
    return true
end

function SWEP:WW_Think()
    if self:WW_SyncModel() and CLIENT then
        -- The model swap restarts the viewmodel, so pick the animation back up
        self:PlayAnimation(self:GetWWState() == STATE_SPLIT and "separate" or "idle", 1, true, 0, false, nil, true)
    end

    local state = self:GetWWState()
    if state ~= STATE_IDLE and CurTime() >= self:GetWWStateEnd() then
        self:SetWWState(STATE_IDLE)
        if state == STATE_JOIN then
            self:SetWWFlag(true)
            self:WW_SyncModel()
            self:PlayAnimation("idle", 1, true, 0, false, nil, true)
        end
    end
end

-- Each gun fires from its own side of the screen towards the crosshair
function SWEP:WW_ProjectileSrc()
    local owner = self:GetOwner()
    if self:GetWWFlag() then return owner:GetShootPos() end
    return owner:GetShootPos() + owner:GetRight() * (self.WW_FiringAlt and 15 or -15)
end

function SWEP:WW_PreSpawnProjectile(ent)
    ent.CookDamage = self.WW_WaveCookDamage
end

function SWEP:WW_PostSpawnProjectile(ent)
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:EnableGravity(false) end
end

function SWEP:Hook_ShouldNotFire()
    if self:GetWWState() ~= STATE_IDLE then return true end
end

-- Joined, one Wave Gun shot uses a round from each gun
function SWEP:WW_ShootWave()
    if self:GetWWState() ~= STATE_IDLE or not self:WW_CanAltFire() then return end
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self:Clip1() <= 0 or self:Clip2() <= 0 then
        self:MyEmitSound(self.ShootDrySound or "weapons/arccw/dryfire.wav", 75, 100, 1, CHAN_ITEM)
        self:SetNextPrimaryFire(CurTime() + 0.3)
        if self:Ammo1() > 0 then self:WW_AkimboReload() end
        return
    end

    self:SetClip1(self:Clip1() - 1)
    self:SetClip2(self:Clip2() - 1)
    self:SetNextPrimaryFire(CurTime() + self.WW_WaveDelay)
    self:SetNextSecondaryFire(CurTime() + self.WW_WaveDelay)
    if SERVER then self:FireRocket(self.WW_WaveEntity, self.WW_WaveVelocity) end

    self:PlayAnimation("wave_fire", 1, true, 0, false)
    if IsFirstTimePredicted() then self:EmitSound(self.WW_WaveSound) end
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
    HORDE_WW.MuzzleParticle(self, "zgun_muzzle", 1)
    self:GetOwner():DoAnimationEvent(self.AnimShoot)
    self:DoRecoil()
end

function SWEP:PrimaryAttack()
    if self:GetWWFlag() then return self:WW_ShootWave() end
    return BaseClass.PrimaryAttack(self)
end

function SWEP:SecondaryAttack()
    if self:GetWWFlag() or self:GetWWState() ~= STATE_IDLE then return end
    self:WW_ShootAlt({
        anim = "fire_right",
        sound = self.ShootSound,
        particle = "zgun_muzzle",
        attachment = 1,
        entity = self.ShootEntity,
    })
end

function SWEP:WW_AkimboReloadAnim(need_l, need_r)
    if self:GetWWFlag() then return "wave_reload" end
    return (need_l and need_r and "reload") or (need_l and "reload_left") or "reload_right"
end

function SWEP:Hook_PreReload()
    -- E + R joins or splits the guns, like the original
    if self:GetOwner():KeyDown(IN_USE) then
        self:WW_ToggleWave()
        return true
    end
    if self:GetWWState() == STATE_IDLE then self:WW_AkimboReload() end
    return true
end

function SWEP:WW_OnHolster()
    -- A half finished join or split is undone, so the weapon comes back out as it was
    local state = self:GetWWState()
    if state == STATE_JOIN then self:SetWWState(STATE_IDLE) end
    if state == STATE_SPLIT then self:SetWWState(STATE_IDLE) end
end
