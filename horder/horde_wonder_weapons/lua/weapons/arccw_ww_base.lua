if not ArcCWInstalled then return end

-- Base for the ranged Horde wonder weapons. Shared behaviour lives in horde_ww/sh_mixin.lua.
SWEP.Base = "arccw_base"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.PrintName = "Horde wonder weapon base"

SWEP.UseHands = true
SWEP.ViewModelFOV = 65
SWEP.MirrorVMWM = true
SWEP.WorldModelOffset = {
    pos = Vector(-12, 4, -4),
    ang = Angle(-10, 0, 180),
}

SWEP.Trivia_Class = "Wonder Weapon"
SWEP.Trivia_Manufacturer = "Group 935"
SWEP.Trivia_Country = "Unknown"

SWEP.Range = 100
SWEP.Penetration = 0
SWEP.ChamberSize = 0
SWEP.Recoil = 0.6
SWEP.RecoilSide = 0.3
SWEP.AccuracyMOA = 5
SWEP.HipDispersion = 250
SWEP.MoveDispersion = 150
SWEP.SightTime = 0.25
SWEP.SpeedMult = 0.95
SWEP.SightedSpeedMult = 0.75
SWEP.BarrelLength = 0
SWEP.ShootVol = 110
SWEP.ShootPitch = 100

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false
SWEP.ShellModel = false
SWEP.CaseEffectAttachment = false

SWEP.IronSightStruct = false
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)
SWEP.HolsterPos = Vector(0, -2, -2)
SWEP.HolsterAng = Angle(-15, 15, 0)
SWEP.SprintPos = Vector(0, 0, 0)
SWEP.SprintAng = Angle(0, 0, 0)
SWEP.CustomizePos = Vector(10, -4, -2)
SWEP.CustomizeAng = Angle(15, 30, 10)

SWEP.Firemodes = {
    { Mode = 1 },
}

SWEP.Attachments = HORDE_WW.Slots()

HORDE_WW.Mixin(SWEP)
