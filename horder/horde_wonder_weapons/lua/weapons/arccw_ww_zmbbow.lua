if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
SWEP.Spawnable = true
SWEP.PrintName = "Wrath of the Ancients"
SWEP.Trivia_Desc = "Ancient bow that fires explosive arrows. Hold left click to draw the string; a fully drawn arrow flies faster and makes a much bigger blast but uses two arrows. Right click lowers the bow."
SWEP.Trivia_Calibre = "Explosive arrow"
SWEP.Trivia_Mechanism = "Bow"
SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/tfa_bo3/zmbbow/c_zmbbow.mdl"
SWEP.WorldModel = "models/weapons/tfa_bo3/zmbbow/w_zmbbow.mdl"
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(10, 10, -5.5),
    ang = Angle(0, 30, -80),
}
SWEP.ViewModelFOV = 65
SWEP.ActivePos = Vector(0, -6, -1.5)

SWEP.Damage = 600
SWEP.DamageMin = 600
SWEP.DamageType = DMG_BLAST
SWEP.ShootEntity = "bo3_ww_zmbbow"
SWEP.ShootEntityModel = "models/weapons/tfa_bo3/zmbbow/zmbbow_projectile.mdl"
SWEP.MuzzleVelocity = 4000

SWEP.Primary.ClipSize = 5 -- one shop ammo purchase buys this many arrows
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Ammo = "XBowBolt"
SWEP.BottomlessClip = true
SWEP.Delay = 60 / 90
SWEP.WW_NoSights = true

SWEP.WW_ChargeRate = 33 / 30
SWEP.WW_ChargeThreshold = 0.01
SWEP.WW_DamageCharge = { 1, 1.5 }
SWEP.WW_VelocityCharge = { 0.25, 1 }

SWEP.Recoil = 0.8
SWEP.RecoilSide = 0.2
SWEP.AccuracyMOA = 0
SWEP.SpeedMult = 0.95

SWEP.ShootSound = ""
SWEP.WW_MuzzleParticle = false

SWEP.HoldtypeActive = "physgun"
SWEP.HoldtypeSights = "physgun"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = { Source = "first_raise", SoundTable = { { s = "TFA_BO3_ZMBBOW.Draw", t = 0 } } },
    ["draw"] = {
        Source = "pullout",
        SoundTable = { { s = "weapon_bo3_cloth.med", t = 0 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = { { s = "weapon_bo3_cloth.med", t = 0 }, { s = "weapon_bo3_gear.rattle", t = 5 / 30 } },
    },
    ["pull"] = { Source = "draw", Time = 0.7 },
    ["pull_loop"] = { Source = "draw_loop" },
    ["cancel"] = { Source = "draw_cancel" },
    ["fire"] = { Source = "fire", Time = 0.53, SoundTable = { { s = "TFA_BO3_ZMBBOW.Reload", t = 0 } } },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

SWEP.WW_LoopSounds = { "TFA_BO3_ZMBBOW.PullBack", "TFA_BO3_ZMBBOW.DrawLoop" }

-- WWState 1 while the string is drawn, WWStateEnd is when drawing began, WWCharge is 0 to 1.
-- WWFlag marks that the looping hold sound has started.
function SWEP:WW_HasArrows()
    return self:HasInfiniteAmmo() or self:Ammo1() > 0
end

function SWEP:PrimaryAttack()
    if self:GetWWState() ~= 0 or not self:WW_CanAltFire() then return end
    if self:GetNextPrimaryFire() > CurTime() then return end
    if not self:WW_HasArrows() then
        self:MyEmitSound(self.ShootDrySound or "weapons/arccw/dryfire.wav", 75, 100, 1, CHAN_ITEM)
        self:SetNextPrimaryFire(CurTime() + 0.3)
        return
    end

    self:SetWWState(1)
    self:SetWWStateEnd(CurTime())
    self:SetWWCharge(0)
    self:SetWWFlag(false)
    self:PlayAnimation("pull", 1, true, 0, false, nil, true)
    if SERVER then self:EmitSound("TFA_BO3_ZMBBOW.PullBack") end
end

function SWEP:WW_StopDraw()
    self:SetWWState(0)
    self:SetWWCharge(0)
    self:SetWWFlag(false)
    if SERVER then
        self:StopSound("TFA_BO3_ZMBBOW.PullBack")
        self:StopSound("TFA_BO3_ZMBBOW.DrawLoop")
    end
end

function SWEP:WW_Cancel()
    self:WW_StopDraw()
    local t = self:GetAnimKeyTime("cancel")
    self:PlayAnimation("cancel", 1, true, 0, false, nil, true)
    self:SetNextPrimaryFire(CurTime() + t)
    self:SetNextSecondaryFire(CurTime() + t)
    if SERVER then self:EmitSound("TFA_BO3_ZMBBOW.Cancel") end
end

function SWEP:WW_Loose()
    local charge = self:GetWWCharge()
    local frac = math.Clamp((charge - self.WW_ChargeThreshold) / (1 - self.WW_ChargeThreshold), 0, 1)
    self.WW_FireCharge = charge
    self.WW_FireSpread = 1 - frac

    self:FireRocket(self.ShootEntity, self.MuzzleVelocity * Lerp(frac, self.WW_VelocityCharge[1], self.WW_VelocityCharge[2]))
    self:WW_StopDraw()

    if not self:HasInfiniteAmmo() and SERVER then
        self:GetOwner():RemoveAmmo(charge >= 1 and 2 or 1, self.Primary.Ammo)
    end

    local t = self:GetAnimKeyTime("fire")
    self:PlayAnimation("fire", 1, true, 0, false, nil, true)
    self:SetNextPrimaryFire(CurTime() + t)
    self:SetNextSecondaryFire(CurTime() + t)
    self:GetOwner():DoAnimationEvent(self.AnimShoot)
    self:DoRecoil()
    if IsFirstTimePredicted() then self:EmitSound("TFA_BO3_ZMBBOW.Fire") end
end

function SWEP:WW_PreSpawnProjectile(ent)
    local charge = self.WW_FireCharge or 0
    local mult = charge >= 1 and self.WW_DamageCharge[2] or self.WW_DamageCharge[1]
    ent:SetCharge(charge)
    ent:SetMult(mult)
    ent.Damage = ent.Damage * mult
    ent.mydamage = ent.mydamage * mult
    ent.damage = ent.damage * mult
end

function SWEP:WW_PostSpawnProjectile(ent, dir)
    -- A half drawn arrow wobbles off course
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:SetVelocity(dir + VectorRand(-80, 80) * (self.WW_FireSpread or 0)) end
end

function SWEP:SecondaryAttack()
    if self:GetWWState() == 1 then self:WW_Cancel() end
end

function SWEP:WW_Think()
    if self:GetWWState() ~= 1 then return end
    local owner = self:GetOwner()

    if self:GetNWState() == ArcCW.STATE_SPRINT or not self:WW_HasArrows() then
        self:WW_Cancel()
        return
    end

    local held = CurTime() - self:GetWWStateEnd()
    local charge = math.min(1, held * self.WW_ChargeRate)
    if charge ~= self:GetWWCharge() then self:SetWWCharge(charge) end

    if not self:GetWWFlag() and held >= 15 / 30 then
        self:SetWWFlag(true)
        if SERVER then self:EmitSound("TFA_BO3_ZMBBOW.DrawLoop") end
    end

    if not owner:KeyDown(IN_ATTACK) then
        if charge >= self.WW_ChargeThreshold then
            self:WW_Loose()
        else
            self:WW_Cancel()
        end
    end
end

-- Hold the drawn pose instead of dropping back to idle while the string is pulled
function SWEP:Hook_TranslateAnimation(key)
    if key == "idle" and self:GetWWState() == 1 then return "pull_loop" end
end

function SWEP:Hook_PreReload()
    return true
end

function SWEP:WW_OnHolster()
    self:WW_StopDraw()
end

if CLIENT then
    function SWEP:WW_HUDText()
        if self:GetWWState() ~= 1 then return end
        local charge = self:GetWWCharge()
        if charge >= 1 then return "Fully drawn" end
        return string.format("Draw %d%%", math.floor(charge * 100))
    end
end
