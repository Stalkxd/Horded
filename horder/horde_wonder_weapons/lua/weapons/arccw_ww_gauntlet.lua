if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
SWEP.Spawnable = true
SWEP.PrintName = "Gauntlet of Siegfried"
SWEP.Trivia_Desc = "A dragon whelp on your arm. Left click breathes fire that sets enemies alight. Right click is a dashing punch through everything in front of you. Recharges on its own."
SWEP.Trivia_Calibre = "Dragon fire"
SWEP.Trivia_Mechanism = "Whelp"
SWEP.Slot = 4

SWEP.ViewModel = "models/weapons/tfa_bo3/gauntlet/c_gauntlet.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/gauntlet/w_gauntlet.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(4, 1, -1),
    ang = Angle(-5, 0, 180),
}
SWEP.ActivePos = Vector(0, -6, -1.5)

SWEP.Damage = 20
SWEP.DamageMin = 20
SWEP.DamageType = DMG_BURN
SWEP.Distance = 400
SWEP.HullSize = 16
SWEP.TracerNum = 0
SWEP.Penetration = 0

SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Ammo = "none"
SWEP.Delay = 60 / 700
SWEP.WW_NoReload = true
SWEP.WW_NoSights = true
SWEP.WW_Regen = 12
SWEP.WW_RegenDelay = 0.5

SWEP.WW_DashCost = 20
SWEP.WW_DashDamage = 500
SWEP.WW_DashSpeed = 1000
SWEP.WW_DashTime = 0.4

SWEP.Recoil = 0.1
SWEP.RecoilSide = 0.1
SWEP.AccuracyMOA = 40
SWEP.HipDispersion = 100

SWEP.ShootSound = ""
SWEP.WW_MuzzleParticle = "bo3_gauntlet_flame"
SWEP.WW_MuzzleAttachment = 1

SWEP.Firemodes = {
    { Mode = 2 },
}

SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "pistol"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

-- No "idle" entry on purpose: the model's 23 second idle has the dragon fly off the arm and
-- hover beside the screen. Without it the arm holds the last pose, with the dragon in place.
SWEP.Animations = {
    ["ready"] = { Source = "draw_first" },
    ["draw"] = {
        Source = "draw",
        SoundTable = { { s = "weapon_bo3_cloth.short", t = 0 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = { { s = "weapon_bo3_cloth.short", t = 2 / 30 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["fire"] = { Source = "fire" },
    ["punch"] = { Source = "melee" },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

SWEP.WW_LoopSounds = { "TFA_BO3_GAUNTLET.ShootLoop" }

function SWEP:Hook_BulletHit(hit)
    local ent = hit.tr.Entity
    if IsValid(ent) then
        HORDE_WW.Debuff(ent, HORDE and HORDE.Status_Ignite, 8, self:GetOwner())
    end
    return hit
end

function SWEP:Hook_PostFireBullets()
    if SERVER and not self.WW_FireLooping then
        self.WW_FireLooping = true
        self:WW_ServerSound("TFA_BO3_GAUNTLET.ShootIn")
        self:WW_ServerSound("TFA_BO3_GAUNTLET.ShootLoop")
    end
    self.WW_LastShot = CurTime()
    if SERVER then self:WW_SelfBurn() end
end

-- Like Horde's flamethrowers, fire splashing close to a Cremator burns them too, so
-- their fire perks (fire damage healing them) work with the Gauntlet. Nobody else is
-- burned by their own Gauntlet.
SWEP.WW_SelfBurnRange = 96
SWEP.WW_SelfBurnInterval = 0.2

function SWEP:WW_SelfBurn()
    local owner = self:GetOwner()
    if not owner.Horde_GetCurrentSubclass or owner:Horde_GetCurrentSubclass() ~= "Cremator" then return end
    if (self.WW_NextSelfBurn or 0) > CurTime() then return end
    self.WW_NextSelfBurn = CurTime() + self.WW_SelfBurnInterval

    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * self.Distance,
        filter = { owner, self },
        mask = MASK_SHOT_HULL,
    })
    if not tr.Hit or tr.HitPos:Distance(owner:WorldSpaceCenter()) > self.WW_SelfBurnRange then return end

    local dmg = DamageInfo()
    dmg:SetAttacker(owner)
    dmg:SetInflictor(self)
    dmg:SetDamage(self.Damage)
    dmg:SetDamageType(DMG_BURN)
    dmg:SetDamagePosition(owner:WorldSpaceCenter())
    owner:TakeDamageInfo(dmg)
end

-- WWFlag: dashing, WWStateEnd: when the dash ends
function SWEP:SecondaryAttack()
    -- The dash works while sprinting too
    if self:GetWWFlag() or not self:WW_CanAltFire(true) then return end
    if self:GetNextPrimaryFire() > CurTime() then return end
    local owner = self:GetOwner()
    if not owner:IsOnGround() or self:Clip1() < self.WW_DashCost then return end

    self:SetClip1(self:Clip1() - self.WW_DashCost)
    self:SetWWFlag(true)
    self:SetWWStateEnd(CurTime() + self.WW_DashTime)
    local ang = owner:EyeAngles()
    self:SetWWVec(Angle(0, ang.y, 0):Forward())
    local t = self:GetAnimKeyTime("punch")
    self:PlayAnimation("punch", 1, true, 0, false, nil, true)
    self:SetNextPrimaryFire(CurTime() + t)
    self:SetNextSecondaryFire(CurTime() + t)
    owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST)
    self.WW_DashHit = {}

    if IsFirstTimePredicted() then
        self:EmitSound("TFA_BO3_GAUNTLET.Poof")
        HORDE_WW.MuzzleParticle(self, "bo3_gauntlet_dash", 6)
    end
end

function SWEP:WW_DashDamage()
    local owner = self:GetOwner()
    local hit = self.WW_DashHit or {}
    self.WW_DashHit = hit
    -- A wide reach in front of the player, since they stop on the first zombie they run into
    local center = owner:WorldSpaceCenter() + self:GetWWVec() * 40
    for _, ent in ipairs(ents.FindInSphere(center, 80)) do
        if hit[ent] or not HORDE_WW.IsHostile(owner, ent) then continue end
        if not owner:Visible(ent) then continue end
        hit[ent] = true
        local dmg = DamageInfo()
        dmg:SetAttacker(owner)
        dmg:SetInflictor(self)
        dmg:SetDamage(self.WW_DashDamage)
        dmg:SetDamageType(DMG_CLUB)
        dmg:SetDamagePosition(ent:WorldSpaceCenter())
        dmg:SetDamageForce(ent:GetUp() * 15000 + self:GetWWVec() * 15000)
        local to = ent:WorldSpaceCenter() - owner:GetShootPos()
        HORDE_WW.TraceHit(ent, dmg, owner:GetShootPos(), to, to:Length() + 32)
        ent:EmitSound("TFA_BO3_GAUNTLET.Hit")
    end
end

function SWEP:WW_Think()
    local owner = self:GetOwner()

    if self:GetWWFlag() then
        if SERVER then self:WW_DashDamage() end
        if CurTime() >= self:GetWWStateEnd() then self:SetWWFlag(false) end
    end

    if SERVER and self.WW_FireLooping and (not owner:KeyDown(IN_ATTACK) or self:Clip1() <= 0
            or CurTime() > (self.WW_LastShot or 0) + 0.2) then
        self.WW_FireLooping = false
        self:WW_StopServerSound("TFA_BO3_GAUNTLET.ShootLoop")
        self:WW_ServerSound("TFA_BO3_GAUNTLET.ShootOut")
    end
end

function SWEP:WW_MoveVelocity(ply, mv)
    if not self:GetWWFlag() or not ply:IsOnGround() then return end
    return self:GetWWVec() * self.WW_DashSpeed
end

function SWEP:WW_LockMovement()
    return self:GetWWFlag()
end

function SWEP:WW_OnHolster()
    self:SetWWFlag(false)
    self.WW_FireLooping = false
end
