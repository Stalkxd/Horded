if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
SWEP.Spawnable = true
SWEP.PrintName = "Zap Gun Dual Wield"
SWEP.Trivia_Desc = "A pair of microwave pistols. Left click fires the left gun, right click the right gun."
SWEP.Trivia_Calibre = "Microwave bolt"
SWEP.Trivia_Mechanism = "Semi-automatic"
SWEP.Slot = 1

SWEP.ViewModel = "models/weapons/black_ops_1/wavegun/c_zapguns.mdl"
SWEP.WorldModel = "models/weapons/black_ops_1/wavegun/w_zapguns.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(4.5, 1, -2),
    ang = Angle(-10, 0, 180),
}

SWEP.Damage = 250
SWEP.DamageMin = 250
SWEP.DamageType = DMG_SHOCK
SWEP.ShootEntity = "obj_wgun_proj"
SWEP.MuzzleVelocity = 3000
SWEP.WW_AimAtCrosshair = true

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 48
SWEP.Primary.Ammo = "CombineHeavyCannon"
SWEP.Secondary.ClipSize = 8
SWEP.Secondary.DefaultClip = 8
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
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

-- Each gun fires from its own side of the screen towards the crosshair
function SWEP:WW_ProjectileSrc()
    local owner = self:GetOwner()
    return owner:GetShootPos() + owner:GetRight() * (self.WW_FiringAlt and 15 or -15)
end

function SWEP:WW_PostSpawnProjectile(ent)
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:EnableGravity(false) end
end

function SWEP:SecondaryAttack()
    self:WW_ShootAlt({
        anim = "fire_right",
        sound = self.ShootSound,
        particle = "zgun_muzzle",
        attachment = 1,
        entity = self.ShootEntity,
    })
end

function SWEP:Hook_PreReload()
    self:WW_AkimboReload()
    return true
end
