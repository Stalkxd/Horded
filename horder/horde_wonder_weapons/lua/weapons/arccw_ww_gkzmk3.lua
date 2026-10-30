if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
SWEP.Spawnable = true
SWEP.PrintName = "GKZ-45 Mk3"
SWEP.Trivia_Desc = "Two hand cannons. Left click fires a slow GKZ orb, right click fires fast Mk3 bolts. Shoot a bolt into the orb to make a black hole."
SWEP.Trivia_Calibre = "Energy cell"
SWEP.Trivia_Mechanism = "Semi-automatic / Automatic"
SWEP.Slot = 1

SWEP.ViewModel = "models/weapons/tfa_bo3/gkzmk3/c_gkzmk3.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/mk3/w_mk3.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(3.5, 1.2, -1.5),
    ang = Angle(-5, 0, 180),
}
SWEP.ActivePos = Vector(0, 0, -0.5)

SWEP.Damage = 120
SWEP.DamageMin = 120
SWEP.DamageType = DMG_BLAST
SWEP.ShootEntity = "bo3_ww_gkz"
SWEP.ShootEntityModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.MuzzleVelocity = 1400
SWEP.WW_AimAtCrosshair = true

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 90
SWEP.Primary.Ammo = "Battery"
SWEP.Secondary.ClipSize = 15
SWEP.Secondary.DefaultClip = 15
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Delay = 60 / 95
SWEP.WW_AltDelay = 60 / 260
SWEP.WW_AltVelocity = 4000

SWEP.Recoil = 0.7
SWEP.RecoilSide = 0.3
SWEP.AccuracyMOA = 3

SWEP.ShootSound = "TFA_BO3_GKZ.Shoot"
SWEP.WW_MuzzleParticle = "bo3_gkz_muzzleflash"
SWEP.WW_MuzzleAttachment = 2
SWEP.WW_Akimbo = true
SWEP.WW_NoSights = true

SWEP.HoldtypeActive = "duel"
SWEP.HoldtypeSights = "duel"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_DUEL

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = {
        Source = "draw_first",
        SoundTable = { { s = "TFA_BO3_MK3.First", t = 0 }, { s = "TFA_BO3_GKZ.First", t = 0 } },
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = { { s = "weapon_bo3_cloth.short", t = 0 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = { { s = "weapon_bo3_cloth.short", t = 2 / 30 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["fire"] = { Source = "fire_lh" },
    ["fire_right"] = { Source = "fire_rh" },
    ["reload"] = {
        Source = "reload",
        Time = 2,
        MagUpTime = 1.5,
        SoundTable = { { s = "TFA_BO3_MK3.Reload", t = 0 }, { s = "TFA_BO3_GKZ.Reload", t = 0 } },
    },
    ["reload_left"] = {
        Source = "reload_lh",
        Time = 1.5,
        MagUpTime = 1.1,
        SoundTable = { { s = "TFA_BO3_GKZ.Reload", t = 0 } },
    },
    ["reload_right"] = {
        Source = "reload_rh",
        Time = 1.5,
        MagUpTime = 1.1,
        SoundTable = { { s = "TFA_BO3_MK3.Reload", t = 0 } },
    },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

-- The GKZ orb comes out of the left gun, the Mk3 bolts out of the right one
function SWEP:WW_ProjectileSrc()
    local owner = self:GetOwner()
    return owner:GetShootPos() + owner:GetRight() * (self.WW_FiringAlt and 12 or -12)
end

function SWEP:WW_PostSpawnProjectile(ent)
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:EnableGravity(false) end
end

function SWEP:Hook_PostFireBullets()
    if IsFirstTimePredicted() then
        self:EmitSound("TFA_BO3_GKZ.Act")
        self:EmitSound("TFA_BO3_GKZ.Gears")
    end
end

function SWEP:SecondaryAttack()
    local clip = self:Clip2()
    self:WW_ShootAlt({
        anim = "fire_right",
        sound = "TFA_BO3_MK3.Shoot",
        particle = "bo3_mk3_muzzleflash",
        attachment = 1,
        entity = "bo3_ww_mk3",
        velocity = self.WW_AltVelocity,
        delay = self.WW_AltDelay,
    })
    if self:Clip2() < clip and IsFirstTimePredicted() then
        self:EmitSound("TFA_BO3_MK3.Act")
        self:EmitSound("TFA_BO3_MK3.Decay")
    end
end

function SWEP:Hook_PreReload()
    self:WW_AkimboReload()
    return true
end
