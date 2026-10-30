if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
local BaseClass = HORDE_WW.Base(SWEP.Base)
SWEP.Spawnable = true
SWEP.PrintName = "Death Machine"
SWEP.Trivia_Desc = "Hand held minigun. Hold left or right click to spin the barrels up, then fire. Recharges on its own."
SWEP.Trivia_Calibre = "7.62x51mm"
SWEP.Trivia_Mechanism = "Rotary"
SWEP.Slot = 4

SWEP.ViewModel = "models/weapons/tfa_bo3/mingun/c_mingun.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/mingun/w_mingun.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(-5, 3.5, -3),
    ang = Angle(-10.2, 9.8, -171.8),
}

SWEP.Damage = 25
SWEP.DamageMin = 17
SWEP.RangeMin = 15
SWEP.Range = 45
SWEP.Num = 3
SWEP.Penetration = 4
SWEP.DamageType = DMG_BULLET
SWEP.TracerNum = 3

SWEP.Primary.ClipSize = 300
SWEP.Primary.DefaultClip = 300
SWEP.Primary.Ammo = "none"
SWEP.Delay = 60 / 1200
SWEP.WW_NoReload = true
SWEP.WW_NoSights = true
SWEP.WW_Regen = 3
SWEP.WW_RegenDelay = 1

SWEP.Recoil = 0.25
SWEP.RecoilSide = 0.25
SWEP.AccuracyMOA = 25
SWEP.HipDispersion = 200
SWEP.MoveDispersion = 100
SWEP.SpeedMult = 0.8

SWEP.ShootSound = ""
SWEP.WW_ArcCWMuzzle = true
SWEP.MuzzleEffect = "muzzleflash_minimi"
SWEP.MuzzleEffectAttachment = 1

SWEP.Firemodes = {
    { Mode = 2 },
}

SWEP.HoldtypeActive = "physgun"
SWEP.HoldtypeSights = "physgun"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["draw"] = {
        Source = "draw",
        SoundTable = { { s = "weapon_bo3_cloth.med", t = 0 }, { s = "TFA_BO3_MINGN.Equip", t = 5 / 30 } },
    },
    ["holster"] = { Source = "holster", SoundTable = { { s = "weapon_bo3_cloth.med", t = 2 / 30 } } },
    ["fire"] = { Source = "fire" },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

SWEP.WW_LoopSounds = { "TFA_BO3_MINGN.Loop", "TFA_BO3_MINGN.SpinLoop" }

local SPIN_TIME = 0.4

-- WWCharge is the barrel spin, 0 to 1. WWFlag is set while the barrels are spinning.
function SWEP:Hook_ShouldNotFire()
    if self:GetWWCharge() < 1 then return true end
end

function SWEP:Hook_PostFireBullets()
    if SERVER and not self.WW_FireLooping then
        self.WW_FireLooping = true
        self:EmitSound("TFA_BO3_MINGN.Start")
        self:EmitSound("TFA_BO3_MINGN.Loop")
    end
    self.WW_LastShot = CurTime()
end

function SWEP:WW_CanSpin()
    if self:GetReloading() or self:GetState() == ArcCW.STATE_CUSTOMIZE then return false end
    if self:GetNWState() == ArcCW.STATE_SPRINT then return false end
    if IsValid(self:GetHolster_Entity()) or self:GetHolster_Time() > 0 then return false end
    return true
end

function SWEP:WW_Think()
    local owner = self:GetOwner()
    local held = (owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)) and self:WW_CanSpin()

    if held then
        if not self:GetWWFlag() then
            self:SetWWFlag(true)
            if SERVER then self:EmitSound("TFA_BO3_MINGN.SpinStart") end
        end
        local spin = self:GetWWCharge()
        if spin < 1 then
            spin = math.min(1, spin + FrameTime() / SPIN_TIME)
            self:SetWWCharge(spin)
            if spin >= 1 and SERVER then self:EmitSound("TFA_BO3_MINGN.SpinLoop") end
        end
    elseif self:GetWWFlag() then
        self:SetWWFlag(false)
        self:SetWWCharge(0)
        if SERVER then
            self:StopSound("TFA_BO3_MINGN.SpinLoop")
            self:EmitSound("TFA_BO3_MINGN.SpinStop")
        end
    end

    if SERVER and self.WW_FireLooping and (not owner:KeyDown(IN_ATTACK) or self:Clip1() <= 0
            or CurTime() > (self.WW_LastShot or 0) + 0.15) then
        self.WW_FireLooping = false
        self:StopSound("TFA_BO3_MINGN.Loop")
        self:EmitSound("TFA_BO3_MINGN.Stop")
    end

    if CLIENT then
        local target = held and (self:GetWWCharge() >= 1 and 25 or 12) or 0
        self.WW_SpinSpeed = math.Approach(self.WW_SpinSpeed or 0, target, FrameTime() * 40)
        self.WW_SpinAng = ((self.WW_SpinAng or 0) + self.WW_SpinSpeed * FrameTime() * 60) % 360
    end
end

function SWEP:WW_OnHolster()
    self:SetWWFlag(false)
    self:SetWWCharge(0)
    self.WW_FireLooping = false
    if CLIENT then
        local vm = IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()
        local bone = IsValid(vm) and vm:LookupBone("tag_barrel_spin")
        if bone then vm:ManipulateBoneAngles(bone, angle_zero) end
    end
end

function SWEP:SecondaryAttack() end

if CLIENT then
    function SWEP:PreDrawViewModel(vm, ...)
        local bone = vm:LookupBone("tag_barrel_spin")
        if bone then vm:ManipulateBoneAngles(bone, Angle(0, 0, -(self.WW_SpinAng or 0))) end
        return BaseClass.PreDrawViewModel(self, vm, ...)
    end
end
