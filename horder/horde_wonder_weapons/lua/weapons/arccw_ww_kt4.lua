if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
DEFINE_BASECLASS(SWEP.Base)
SWEP.Spawnable = true
SWEP.PrintName = "KT-4"
SWEP.Trivia_Desc = "Fires toxic spores that infect enemies. Hold the trigger to charge up to three shots into one; charged shots leave a toxic puddle."
SWEP.Trivia_Calibre = "Plant spores"
SWEP.Trivia_Mechanism = "Charged"
SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/tfa_bo3/mirg2000/c_mirg2000.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/mirg2000/w_mirg2000.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(4, 1, -0.5),
    ang = Angle(-10, 0, 180),
}
SWEP.ActivePos = Vector(0, -6, -1.5)

SWEP.Damage = 600
SWEP.DamageMin = 600
SWEP.DamageType = DMG_ACID
SWEP.ShootEntity = "bo3_ww_mirg"
SWEP.ShootEntityModel = "models/dav0r/hoverball.mdl"
SWEP.MuzzleVelocity = 3000

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 24
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Delay = 60 / 220

SWEP.Recoil = 1.2
SWEP.RecoilSide = 0.4
SWEP.AccuracyMOA = 2

SWEP.ShootSound = ""
SWEP.WW_MuzzleParticle = "bo3_mirg2k_muzzleflash"

SWEP.IronSightStruct = {
    Pos = Vector(-5.63, -4.5, -0.92),
    Ang = Angle(0, 0, 0),
    Magnification = 1.3,
    CrosshairInSights = false,
}
SWEP.SightTime = 0.35

SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = {
        Source = "draw_first",
        SoundTable = {
            { s = "TFA_BO3_MIRG.Prime", t = 10 / 30 },
            { s = "TFA_BO3_MIRG.Start", t = 10 / 30 },
            { s = "TFA_BO3_MIRG.Rechamber", t = 30 / 30 },
        },
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = { { s = "weapon_bo3_cloth.med", t = 0 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = { { s = "TFA_BO3_MIRG.Stop", t = 0 }, { s = "weapon_bo3_cloth.med", t = 2 / 30 } },
    },
    ["fire"] = { Source = "fire" },
    ["fire_iron"] = { Source = "fire_ads" },
    ["reload"] = {
        Source = "reload",
        MinProgress = 1.3,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        SoundTable = {
            { s = "TFA_BO3_MIRG.Stop", t = 0 },
            { s = "TFA_BO3_MIRG.MagOut", t = 10 / 30 },
            { s = "TFA_BO3_MIRG.MagIn", t = 35 / 30 },
            { s = "TFA_BO3_MIRG.Rechamber", t = 65 / 30 },
            { s = "TFA_BO3_MIRG.Start", t = 65 / 30 },
        },
    },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

SWEP.WW_LoopSounds = { "TFA_BO3_MIRG.Charge2" }

local MAX_STAGE = 3
local STAGE_TIME = 0.7

-- WWState is the charge stage (0 = not charging), WWStateEnd the time charging began.
-- Holding the trigger charges; letting go fires one spore that costs one round per stage.
function SWEP:PrimaryAttack()
    if self.WW_Releasing then return BaseClass.PrimaryAttack(self) end
    if self:GetWWState() > 0 then return end
    if not self:CanPrimaryAttack() then return end
    if self:Clip1() <= 0 then return BaseClass.PrimaryAttack(self) end

    self:SetWWState(1)
    self:SetWWStateEnd(CurTime())
    if SERVER then
        self:EmitSound("TFA_BO3_MIRG.Charge1")
        self:EmitSound("TFA_BO3_MIRG.Charge2")
    end
end

function SWEP:WW_Release()
    local stage = self:GetWWState()
    self.WW_FireStage = stage
    if stage > 1 then self:SetClip1(self:Clip1() - (stage - 1)) end
    self.WW_Releasing = true
    BaseClass.PrimaryAttack(self)
    self.WW_Releasing = false
    self:SetWWState(0)
    if SERVER then self:StopSound("TFA_BO3_MIRG.Charge2") end
end

function SWEP:WW_Think()
    local stage = self:GetWWState()
    if stage <= 0 then return end

    if not self:GetOwner():KeyDown(IN_ATTACK) then
        self:WW_Release()
        return
    end

    local want = math.min(MAX_STAGE, self:Clip1(), 1 + math.floor((CurTime() - self:GetWWStateEnd()) / STAGE_TIME))
    if want > stage then
        self:SetWWState(want)
        if SERVER then self:EmitSound("TFA_BO3_MIRG.Charge3") end
    end
end

function SWEP:WW_PreSpawnProjectile(ent)
    if ent.SetCharge then ent:SetCharge(self.WW_FireStage or 1) end
end

function SWEP:Hook_PostFireBullets()
    if IsFirstTimePredicted() then
        self:EmitSound("TFA_BO3_MIRG.Shoot.Charge." .. math.Clamp(self.WW_FireStage or 1, 1, MAX_STAGE))
    end
end

function SWEP:Hook_PreReload()
    if self:GetWWState() > 0 then return true end
end

function SWEP:WW_OnHolster()
    self:SetWWState(0)
end

if CLIENT then
    function SWEP:WW_HUDText()
        local stage = self:GetWWState()
        if stage > 0 then return "Charge " .. stage .. " / " .. MAX_STAGE end
    end
end
