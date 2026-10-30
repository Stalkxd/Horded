if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
SWEP.Spawnable = true
SWEP.PrintName = "Ragnarok DG-4"
SWEP.Trivia_Desc = "Twin gravity spikes. Left click jumps and slams the ground. Right click plants the spikes to make a vortex that crushes enemies around it while it drains the charge; right click again to pull them back."
SWEP.Trivia_Calibre = "Gravity"
SWEP.Trivia_Mechanism = "Specialist"
SWEP.Slot = 4

SWEP.ViewModel = "models/weapons/tfa_bo3/dg4/c_dg4.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/dg4/w_dg4.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(3.5, 1, 0),
    ang = Angle(62.5, 90, -107.5),
}
SWEP.ActivePos = Vector(0, -6, -1.5)

SWEP.Damage = 600
SWEP.DamageMin = 600
SWEP.DamageType = DMG_ENERGYBEAM

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Ammo = "none"
SWEP.WW_NoReload = true
SWEP.WW_NoSights = true
SWEP.WW_Regen = 2
SWEP.WW_RegenDelay = 1

SWEP.WW_SlamCost = 25
SWEP.WW_SlamRadius = 200
SWEP.WW_LeapDamage = 1200
SWEP.WW_PlantCost = 20
SWEP.WW_VortexDamage = 300

SWEP.HoldtypeActive = "duel"
SWEP.HoldtypeSights = "duel"
SWEP.HoldtypeHolstered = "normal"

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = { Source = "draw_first", SoundTable = { { s = "TFA_BO3_DG4.FirstDraw", t = 0 } } },
    ["draw"] = { Source = "draw", SoundTable = { { s = "TFA_BO3_DG4.Draw", t = 0 } } },
    ["holster"] = { Source = "holster" },
    ["slam_in"] = { Source = "slam_in", SoundTable = { { s = "TFA_BO3_DG4.Activate", t = 0 } } },
    ["slam_out"] = { Source = "slam_out", Time = 15 / 30 },
    ["plant"] = { Source = "plant", SoundTable = { { s = "TFA_BO3_DG4.Strike", t = 15 / 40 } } },
    ["raise"] = { Source = "raise" },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

local STATE_IDLE, STATE_LEAP, STATE_FALL, STATE_LAND, STATE_PLANTING, STATE_PLANTED = 0, 1, 2, 3, 4, 5
local up_250 = Vector(0, 0, 250)

local function MarkKill(ent)
    if ent:Health() <= 0 then ent:SetNW2Bool("DG4Killed", true) end
end

function SWEP:WW_Ready()
    if self:GetWWState() ~= STATE_IDLE then return false end
    if not self:WW_CanAltFire() then return false end
    return self:GetNextPrimaryFire() <= CurTime()
end

function SWEP:PrimaryAttack()
    if not self:WW_Ready() then return end
    local owner = self:GetOwner()
    if owner:WaterLevel() > 2 or self:Clip1() < self.WW_SlamCost then return end

    self:SetClip1(self:Clip1() - self.WW_SlamCost)
    local ang = owner:EyeAngles()
    self:SetWWVec(Angle(0, ang.y, 0):Forward())
    self:SetWWState(STATE_LEAP)
    self:SetWWStateEnd(CurTime() + self:GetAnimKeyTime("slam_in"))
    self:SetNextPrimaryFire(CurTime() + 5)
    self:SetNextSecondaryFire(CurTime() + 5)
    self:PlayAnimation("slam_in", 1, true, 0, false, nil, true)
    owner:SetAnimation(PLAYER_JUMP)

    -- Anything standing right on top of the player when they leap gets crushed
    HORDE_WW.AreaDamage(self, owner:GetShootPos(), 60, self.WW_LeapDamage, DMG_ENERGYBEAM, MarkKill)
end

function SWEP:WW_Slam()
    local owner = self:GetOwner()
    local t = self:GetAnimKeyTime("slam_out")
    self:SetWWState(STATE_LAND)
    self:SetWWStateEnd(CurTime() + t)
    self:SetNextPrimaryFire(CurTime() + t)
    self:SetNextSecondaryFire(CurTime() + t)
    self:PlayAnimation("slam_out", 1, true, 0, false, nil, true)
    owner:SetAnimation(PLAYER_ATTACK1)

    if IsFirstTimePredicted() then
        HORDE_WW.MuzzleParticle(self, "bo3_dg4_slam", 1)
    end

    if SERVER then
        for _, snd in ipairs({ "TFA_BO3_DG4.Explode", "TFA_BO3_DG4.Shockwave", "TFA_BO3_DG4.EMP", "TFA_BO3_DG4.Dist" }) do
            self:EmitSound(snd)
        end
        local tr = util.QuickTrace(owner:GetPos() + Vector(0, 0, 8), Vector(0, 0, -32), { owner, self })
        util.Decal("Scorch", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)
        HORDE_WW.AreaDamage(self, owner:GetShootPos(), self.WW_SlamRadius, self:GetBuff("Damage"), DMG_ENERGYBEAM, MarkKill)
    end
end

function SWEP:SecondaryAttack()
    local state = self:GetWWState()
    if state == STATE_PLANTED then
        -- Pull the spikes back early
        if SERVER and IsValid(self.WW_Planted) then self.WW_Planted:Remove() end
        return
    end
    if not self:WW_Ready() or self:Clip1() < self.WW_PlantCost then return end
    local owner = self:GetOwner()
    local tr = util.QuickTrace(owner:GetShootPos(), Vector(0, 0, -128), { owner, self })
    if not tr.HitWorld then return end

    local t = self:GetAnimKeyTime("plant")
    self:SetWWState(STATE_PLANTING)
    self:SetWWStateEnd(CurTime() + t)
    self:SetNextPrimaryFire(CurTime() + t)
    self:SetNextSecondaryFire(CurTime() + t)
    self:PlayAnimation("plant", 1, true, 0, false, nil, true)
end

function SWEP:WW_Plant()
    self:SetWWState(STATE_PLANTED)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    if CLIENT then return end

    local owner = self:GetOwner()
    local tr = util.QuickTrace(owner:GetShootPos(), Vector(0, 0, -128), { owner, self })
    if not tr.HitWorld then
        self:WW_Unplant()
        return
    end

    local ang = owner:EyeAngles()
    local ent = ents.Create("bo3_special_dg4")
    if not IsValid(ent) then
        self:WW_Unplant()
        return
    end
    ent:SetModel("models/hunter/blocks/cube05x1x05.mdl")
    ent:SetPos(tr.HitPos + tr.HitNormal * 15)
    ent:SetAngles(Angle(0, ang.y, 0))
    ent:SetOwner(owner)
    ent:SetTarget(self)
    ent:SetAmmoCount(self:Clip1())
    ent.Damage = self.WW_VortexDamage
    ent.mydamage = self.WW_VortexDamage
    ent.Inflictor = self
    ent.WeaponClass = self:GetClass()
    ent:Spawn()
    ent:SetOwner(owner)
    self.WW_Planted = ent
end

-- Called by the vortex when it ends or is pulled back
function SWEP:WW_Unplant()
    if self:GetWWState() ~= STATE_PLANTED and self:GetWWState() ~= STATE_PLANTING then return end
    self:SetWWState(STATE_IDLE)
    self.WW_Planted = nil
    local owner = self:GetOwner()
    if IsValid(owner) and owner:GetActiveWeapon() == self then
        self:PlayAnimation("raise", 1, true, 0, false, nil, true)
        self:SetNextPrimaryFire(CurTime() + 0.4)
        self:SetNextSecondaryFire(CurTime() + 0.4)
    end
end

function SWEP:WW_RegenPaused()
    return self:GetWWState() == STATE_PLANTED
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
    elseif state == STATE_PLANTING and CurTime() >= self:GetWWStateEnd() then
        self:WW_Plant()
    elseif state == STATE_PLANTED and SERVER and not IsValid(self.WW_Planted) then
        self:WW_Unplant()
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
    local state = self:GetWWState()
    return state == STATE_LEAP or state == STATE_FALL or state == STATE_LAND
end

function SWEP:WW_OnHolster()
    local state = self:GetWWState()
    if state ~= STATE_PLANTED then
        self:SetWWState(STATE_IDLE)
    end
end

if CLIENT then
    function SWEP:WW_HUDText()
        if self:GetWWState() == STATE_PLANTED then return "Vortex active - right click to recall" end
    end
end
