if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base_melee"
SWEP.Spawnable = true
SWEP.PrintName = "Keeper Sword"
SWEP.Trivia_Desc = "Slashes set enemies on fire. Right click throws the sword, which hunts down nearby enemies and flies back to you."
SWEP.Trivia_Mechanism = "Slashing Weapon"
SWEP.Slot = 0

SWEP.ViewModel = "models/weapons/tfa_bo3/keepersword/c_keepersword.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/keepersword/w_keepersword.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(3, 1.2, 0),
    ang = Angle(0, 0, 180),
}
SWEP.ActivePos = Vector(0, -6, -1.5)

SWEP.MeleeDamage = 220
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeRange = 90
SWEP.MeleeAttackTime = 0.25
SWEP.MeleeTime = 0.95
SWEP.MaxHits = 4

SWEP.MeleeSwingSound = "TFA_BO3_KPRSWORD.Swing"
SWEP.MeleeMissSound = "TFA_BO3_ZODSWORD.SwingFoly"
SWEP.MeleeHitSound = "TFA_BO3_STAFFS.MeleeHit"
SWEP.MeleeHitNPCSound = "TFA_BO3_ZODSWORD.Impact"

SWEP.WW_Regen = 6
SWEP.WW_ThrowCost = 20
SWEP.WW_ThrowModel = "models/weapons/tfa_bo3/keepersword/keepersword_projectile.mdl"

SWEP.Attachments = HORDE_WW.Slots("tag_weapon", nil, nil, true)

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = { Source = "draw_first" },
    ["draw"] = {
        Source = "draw",
        SoundTable = { { s = "weapon_bo3_cloth.med", t = 0 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["holster"] = { Source = "holster" },
    ["bash"] = {
        Source = "slash",
        Time = 1,
        SoundTable = { { s = "TFA_BO3_ZODSWORD.SwingFoly", t = 0 }, { s = "TFA_BO3_KPRSWORD.Swing", t = 0.2 } },
    },
    ["throw"] = { Source = "throw", SoundTable = { { s = "TFA_BO3_KPRSWORD.Throw", t = 0 } } },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

function SWEP:Hook_PreBash()
    if IsFirstTimePredicted() then
        HORDE_WW.MuzzleParticle(self, "bo3_keepersword_trail_vm", 2)
    end
end

function SWEP:Hook_HordePostCleaving(info)
    local owner = self:GetOwner()
    for _, ent in ipairs(info.cleave or {}) do
        HORDE_WW.Debuff(ent, HORDE and HORDE.Status_Ignite, 35, owner)
        if SERVER then
            local bleeds = ent.GetBloodColor and ent:GetBloodColor() ~= DONT_BLEED and ent:GetBloodColor() ~= BLOOD_COLOR_MECH
            ParticleEffect(bleeds and "bo3_keepersword_hit_flesh" or "bo3_keepersword_hit", ent:WorldSpaceCenter(), owner:EyeAngles())
        end
    end
end

-- Called by the thrown sword when it flies back into the player
function SWEP:WW_SwordReturned()
    self:SetWWFlag(false)
    self.WW_ThrownSword = nil
end

function SWEP:SecondaryAttack()
    if self:GetWWFlag() then return end
    if not self:WW_CanAltFire() then return end
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self:Clip1() < self.WW_ThrowCost then return end

    local owner = self:GetOwner()
    self:SetClip1(self:Clip1() - self.WW_ThrowCost)
    self:SetWWFlag(true)
    self:PlayAnimation("throw", 1, true, 0, false, nil, true)
    local t = self:GetAnimKeyTime("throw")
    self:SetNextPrimaryFire(CurTime() + t)
    self:SetNextSecondaryFire(CurTime() + t)
    owner:SetAnimation(PLAYER_ATTACK1)

    if CLIENT then return end
    local ent = ents.Create("bo3_special_keepersword")
    if not IsValid(ent) then
        self:SetWWFlag(false)
        return
    end
    local ang = owner:EyeAngles()
    ent:SetPos(owner:GetShootPos())
    ent:SetAngles(Angle(0, ang.y, 0))
    ent:SetOwner(owner)
    ent:SetModel(self.WW_ThrowModel)
    ent:SetAttacker(owner)
    ent:SetInflictor(self)
    ent:Spawn()
    ent:SetModel(self.WW_ThrowModel)
    ent:SetOwner(owner)
    self.WW_ThrownSword = ent
end

-- The sword can be lost (removed by map cleanup or its lifetime), so never lock the throw forever
function SWEP:WW_Think()
    if SERVER and self:GetWWFlag() and not IsValid(self.WW_ThrownSword) then
        self:WW_SwordReturned()
    end
end
