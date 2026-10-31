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
-- Seconds into the swing animation of its second (backhand) hit; nil for one hit
SWEP.WW_SecondHitTime = nil

HORDE_WW.Mixin(SWEP)

-- ArcCW's Bash plays the swing animation on the server only. On a dedicated server
-- the shooter's own game then fought it, so fast clicks broke the animation on their
-- screen, and the swing sounds in its sound table never reached them. This is the same
-- swing with the animation played on both sides like a gun shot, plus the second hit
-- the animation shows.
function SWEP:Bash(melee2)
    if melee2 then return HORDE_WW.Base(self.Base).Bash(self, melee2) end
    local state = self:GetState()
    if state == ArcCW.STATE_SIGHTS or state == ArcCW.STATE_CUSTOMIZE
            or (state == ArcCW.STATE_SPRINT and not self:CanShootWhileSprint()) then
        return
    end
    if self:GetNextPrimaryFire() > CurTime() or self:GetGrenadePrimed() or self:GetPriorityAnim() then return end
    if not self.CanBash and not self:GetBuff_Override("Override_CanBash") then return end

    self:GetBuff_Hook("Hook_PreBash")
    self.Primary.Automatic = true

    local owner = self:GetOwner()
    local mult = self:GetBuff_Mult("Mult_MeleeTime")
    local wait = self.MeleeTime * mult * self:GetBuff_Mult("Mult_MeleeWaitTime")

    local anim = self:SelectAnimation("bash") or "bash"
    anim = self:GetBuff_Hook("Hook_SelectBashAnim", anim) or anim
    self:PlayAnimation(anim, mult, true, 0, true)
    self:SetNextPrimaryFire(CurTime() + wait)
    owner:DoAnimationEvent(self.MeleeGesture or ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)

    local function hit()
        if not IsValid(self) or not IsValid(self:GetOwner()) then return end
        if self:GetOwner():GetActiveWeapon() ~= self then return end
        self:MeleeAttack(false)
    end
    local speed = self:GetBuff_Mult("Mult_MeleeAttackTime") * math.pow(mult, 1.5)
    self:SetTimer(self.MeleeAttackTime * speed, hit)
    if self.WW_SecondHitTime then
        self:SetTimer(self.WW_SecondHitTime * speed, hit)
    end

    self:DoLunge()
end
