if not ArcCWInstalled then return end

-- Base for the wonder weapon swords: Horde's melee base (lag compensated cleaving hits) plus the
-- shared wonder weapon behaviour in horde_ww/sh_mixin.lua. Clip1 is the special attack charge.
-- Horde's melee base (lag compensated cleaving, perk hooks) when running Horde, ArcCW's own
-- melee base anywhere else, so the swords also work in sandbox
SWEP.Base = (HORDE or engine.ActiveGamemode() == "horde") and "arccw_horde_base_melee" or "arccw_base_melee"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.PrintName = "Horde wonder melee base"

SWEP.UseHands = true
SWEP.ViewModelFOV = 65
SWEP.MirrorVMWM = true
SWEP.WorldModelOffset = {
    pos = Vector(-14, 6, -4),
    ang = Angle(-10, 0, 180),
}

SWEP.Trivia_Class = "Wonder Weapon"
SWEP.Trivia_Manufacturer = "Apothicons"
SWEP.Trivia_Country = "Unknown"

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.UseHordeDurability = false
SWEP.WW_NoReload = true
SWEP.WW_NoSights = true
SWEP.WW_Regen = 5

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.Melee2 = false
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2
SWEP.MaxHits = 3
SWEP.MeleeBoundingBox = {
    primary = { wide = 32, tall = 32, length = 95 },
}

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "melee2"
SWEP.IronSightStruct = false

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)
SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 0, 0)
SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(0, 0, 0)
SWEP.HolsterPos = Vector(0, -3, -2)
SWEP.HolsterAng = Angle(-10, 0, 0)
SWEP.CustomizePos = Vector(10, -4, -2)
SWEP.CustomizeAng = Angle(15, 30, 10)

SWEP.Attachments = HORDE_WW.Slots(nil, nil, nil, true)

HORDE_WW.Mixin(SWEP)
