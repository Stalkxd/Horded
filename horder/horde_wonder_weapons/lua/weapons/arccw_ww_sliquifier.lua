if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
SWEP.Spawnable = true
SWEP.PrintName = "Sliquifier"
SWEP.Trivia_Desc = "A handcrafted junk gun that boils the undead and leaves a slippery puddle. Kills chain to nearby enemies."
SWEP.Trivia_Calibre = "Unknown substance"
SWEP.Trivia_Mechanism = "Automatic"
SWEP.Slot = 2

SWEP.ViewModel = "models/weapons/black_ops_2/sliquifier/c_slipgun.mdl"
SWEP.WorldModel = "models/weapons/black_ops_2/sliquifier/w_slipgun.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(-2, 0, 0),
    ang = Angle(-10, 0, 180),
}
SWEP.ViewModelFOV = 72
SWEP.ActivePos = Vector(-0.3, -1.5, 0)

SWEP.Damage = 400
SWEP.DamageMin = 400
SWEP.DamageType = DMG_ACID
SWEP.ShootEntity = "obj_sliquifier_proj"
SWEP.MuzzleVelocity = 1000

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Ammo = "Snark"
SWEP.Delay = 0.35

SWEP.Recoil = 0.7
SWEP.RecoilSide = 0.3
SWEP.AccuracyMOA = 3

SWEP.ShootSound = {
    "weapons/slipgun/slipgun_shot_00.ogg",
    "weapons/slipgun/slipgun_shot_01.ogg",
}
SWEP.ShootVol = 65
SWEP.WW_MuzzleParticle = "slipgun_muzzle"

SWEP.Firemodes = {
    { Mode = 2 },
}

SWEP.HoldtypeActive = "ar2"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["ready"] = { Source = "raise_first" },
    ["draw"] = { Source = "raise" },
    ["holster"] = { Source = "lower" },
    ["fire"] = { Source = "fire" },
    ["reload"] = {
        Source = "reload",
        MinProgress = 2.2,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
    },
    ["idle_sprint"] = { Source = "sprint_loop" },
}

function SWEP:WW_PreSpawnProjectile(ent)
    ent:SetAngles(angle_zero)
    ent.MaxChain = 12
end

-- The goo is lobbed slightly upwards rather than flying straight
function SWEP:WW_PostSpawnProjectile(ent)
    local vel = self:GetOwner():GetAimVector() * self:GetBuff("MuzzleVelocity") + Vector(0, 0, 64)
    ent:SetVelocity(vel)
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:SetVelocity(vel) end
end
