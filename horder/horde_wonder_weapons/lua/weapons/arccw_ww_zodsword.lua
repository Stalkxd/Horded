if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base_melee"
SWEP.Spawnable = true
SWEP.PrintName = "Apothicon Sword"
SWEP.Trivia_Desc = "Slashes shock enemies. Right click leaps forward and slams the ground, shocking everything around the landing."
SWEP.Trivia_Mechanism = "Slashing Weapon"
SWEP.Slot = 0

SWEP.ViewModel = "models/weapons/tfa_bo3/zodsword/c_zodsword.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/zodsword/w_zodsword.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(3, 1.2, 0),
    ang = Angle(0, 0, 180),
}
SWEP.ActivePos = Vector(0, -6, -1.5)

SWEP.MeleeDamage = 120 -- per hit, two hits a swing
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeRange = 90
SWEP.MeleeAttackTime = 0.2
SWEP.WW_SecondHitTime = 17 / 30
SWEP.MeleeTime = 0.95
SWEP.MaxHits = 4

SWEP.MeleeSwingSound = "TFA_BO3_ZODSWORD.Swing"
SWEP.MeleeMissSound = "TFA_BO3_ZODSWORD.SwingFoly"
SWEP.MeleeHitSound = "TFA_BO3_STAFFS.MeleeHit"
SWEP.MeleeHitNPCSound = "TFA_BO3_ZODSWORD.Impact"

SWEP.WW_Regen = 6
SWEP.WW_SlamCost = 20
SWEP.WW_SlamDamage = 400
SWEP.WW_SlamRadius = 150

SWEP.Attachments = HORDE_WW.Slots("tag_weapon", nil, nil, true)

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = { Source = "draw_first", SoundTable = { { s = "TFA_BO3_ZODSWORD.Raise", t = 0 } } },
    ["draw"] = {
        Source = "draw",
        SoundTable = { { s = "weapon_bo3_cloth.med", t = 0 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["holster"] = { Source = "holster" },
    ["bash"] = {
        Source = "slash",
        Time = 1,
        SoundTable = {
            { s = "TFA_BO3_ZODSWORD.SwingFoly", t = 0 }, { s = "TFA_BO3_ZODSWORD.Swing", t = 0.1 },
            { s = "TFA_BO3_ZODSWORD.SwingFoly", t = 12 / 30 }, { s = "TFA_BO3_ZODSWORD.Swing", t = 12 / 30 },
        },
    },
    ["slam_in"] = { Source = "slam_in", SoundTable = { { s = "TFA_BO3_ZODSWORD.Jump", t = 0 } } },
    ["slam_out"] = {
        Source = "slam_out",
        SoundTable = { { s = "TFA_BO3_ZODSWORD.GroundStrike", t = 0 }, { s = "TFA_BO3_ZODSWORD.SparkExplode", t = 0 } },
    },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

local STATE_IDLE, STATE_LEAP, STATE_FALL, STATE_LAND = 0, 1, 2, 3
local LEAP_TIME = 0.3
local up_250 = Vector(0, 0, 250)

function SWEP:Hook_PreBash()
    if IsFirstTimePredicted() then
        HORDE_WW.MuzzleParticle(self, "bo3_zodsword_trail", 2)
    end
end

function SWEP:Hook_HordePostCleaving(info)
    local owner = self:GetOwner()
    for _, ent in ipairs(info.cleave or {}) do
        HORDE_WW.Debuff(ent, HORDE and HORDE.Status_Shock, 30, owner)
    end
end

function SWEP:SecondaryAttack()
    if self:GetWWState() ~= STATE_IDLE then return end
    if not self:WW_CanAltFire() then return end
    if self:GetNextPrimaryFire() > CurTime() then return end
    local owner = self:GetOwner()
    if not owner:IsOnGround() then return end
    if self:Clip1() < self.WW_SlamCost then return end

    self:SetClip1(self:Clip1() - self.WW_SlamCost)
    local ang = owner:EyeAngles()
    self:SetWWVec(Angle(0, ang.y, 0):Forward())
    self:SetWWState(STATE_LEAP)
    self:SetWWStateEnd(CurTime() + LEAP_TIME)
    self:SetNextPrimaryFire(CurTime() + 5)
    self:SetNextSecondaryFire(CurTime() + 5)
    self:PlayAnimation("slam_in", 1, true, 0, false, nil, true)
    owner:SetAnimation(PLAYER_JUMP)
end

function SWEP:WW_Slam()
    local owner = self:GetOwner()
    self:SetWWState(STATE_LAND)
    self:SetWWStateEnd(CurTime() + 0.93)
    self:SetNextPrimaryFire(CurTime() + 0.93)
    self:SetNextSecondaryFire(CurTime() + 0.93)
    self:PlayAnimation("slam_out", 1, true, 0, false, nil, true)
    owner:SetAnimation(PLAYER_ATTACK1)

    if IsFirstTimePredicted() then
        HORDE_WW.MuzzleParticle(self, "bo3_zodsword_slam", 1)
    end

    if SERVER then
        local pos = owner:GetPos() + Vector(0, 0, 8)
        local tr = util.QuickTrace(pos, Vector(0, 0, -32), { owner, self })
        util.Decal("Scorch", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)
        HORDE_WW.AreaDamage(self, owner:WorldSpaceCenter(), self.WW_SlamRadius, self.WW_SlamDamage, DMG_SHOCK, function(ent)
            HORDE_WW.Debuff(ent, HORDE and HORDE.Status_Shock, 60, owner)
            ParticleEffectAttach("bo3_waffe_electrocute", PATTACH_POINT_FOLLOW, ent, 2)
        end)
    end
end

function SWEP:WW_Think()
    local state = self:GetWWState()
    if state == STATE_IDLE then return end
    local owner = self:GetOwner()

    if state == STATE_LEAP and CurTime() >= self:GetWWStateEnd() then
        self:SetWWState(STATE_FALL)
        self:SetWWStateEnd(CurTime() + 3)
    elseif state == STATE_FALL then
        if owner:IsOnGround() or owner:WaterLevel() > 1 or CurTime() >= self:GetWWStateEnd() then
            self:WW_Slam()
        end
    elseif state == STATE_LAND and CurTime() >= self:GetWWStateEnd() then
        self:SetWWState(STATE_IDLE)
    end
end

function SWEP:WW_MoveVelocity(ply, mv)
    local state = self:GetWWState()
    if state == STATE_LEAP then
        ply:SetGroundEntity(NULL)
        return self:GetWWVec() * 350 + up_250
    elseif state == STATE_FALL then
        return mv:GetVelocity() - Vector(0, 0, 1500 * FrameTime())
    end
end

function SWEP:WW_LockMovement()
    local state = self:GetWWState()
    return state == STATE_LEAP or state == STATE_FALL
end

function SWEP:WW_NoFallDamage()
    return self:GetWWState() ~= STATE_IDLE
end

function SWEP:WW_OnHolster()
    self:SetWWState(STATE_IDLE)
end
