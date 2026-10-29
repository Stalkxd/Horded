if not ArcCWInstalled then return end
if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/arccw_horde_mjollnir")
    SWEP.DrawWeaponInfoBox	= false
    SWEP.BounceWeaponIcon = false
    killicon.Add("arccw_horde_mjollnir", "vgui/hud/arccw_horde_mjollnir", Color(0, 0, 0, 255))
end

SWEP.Base = "arccw_horde_base_melee"
SWEP.Spawnable = true
SWEP.Category = "Horde - Melee"
SWEP.AdminOnly = false

SWEP.PrintName = "Mjollnir"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Warhammer."
SWEP.Trivia_Manufacturer = "Asgard"
SWEP.Trivia_Calibre = "N/A"
SWEP.Trivia_Mechanism = "Club Weapon"
SWEP.Trivia_Country = "Asgard"
SWEP.Trivia_Year = 2018

SWEP.Slot = 0

SWEP.NotForNPCs = true

SWEP.UseHands = true

SWEP.ViewModel = "models/horde/weapons/v_mjollnir.mdl"
SWEP.WorldModel = "models/horde/weapons/v_mjollnir.mdl"
SWEP.ViewModelFOV = 75

SWEP.DefaultSkin = 0
SWEP.DefaultWMSkin = 0

SWEP.MeleeDamage = 140
SWEP.Melee2Damage = 0

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeRange = 50
SWEP.MeleeAttackTime = 0.15
SWEP.MeleeTime = 0.8
SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE

SWEP.Melee2 = true
SWEP.Melee2Range = 55
SWEP.Melee2AttackTime = 0.1
SWEP.Melee2Time = 0.5
SWEP.Melee2Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2

SWEP.MaximumDurability = 2000
SWEP.MaxHits = 3
SWEP.MeleeBoundingBox = {
    primary = {
        wide = 12,
        tall = 12,
        length = 110,
    },
    secondary = {
        wide = 12,
        tall = 12,
        length = 110,
    },
}

SWEP.MeleeSwingSound = {
    "horde/weapons/mjollnir/swing_1.ogg",
    "horde/weapons/mjollnir/swing_2.ogg"
}
SWEP.MeleeMissSound = {
    "horde/weapons/mjollnir/swing_1.ogg",
    "horde/weapons/mjollnir/swing_2.ogg"
}
SWEP.MeleeHitSound = {
    "horde/weapons/mjollnir/hitwall_1.ogg",
    "horde/weapons/mjollnir/hitwall_2.ogg"
}
SWEP.MeleeHitNPCSound = {
    "horde/weapons/mjollnir/hitflesh_1.ogg",
    "horde/weapons/mjollnir/hitflesh_2.ogg"
}
SWEP.ChargeSound = Sound("horde/weapons/mjollnir/charge.ogg")
SWEP.ChargeLoopSound = Sound("horde/weapons/mjollnir/charge_loop.ogg")
SWEP.ChargeLoopCooldown = 3.5
SWEP.ChargeHitSound = Sound("ambient/explosions/explode_2.wav")

SWEP.NotForNPCs = true

SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "MELEE"
    },
}

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "melee2"

SWEP.Primary.ClipSize = -1

SWEP.AttachmentElements = {
}

SWEP.Attachments = {
}

SWEP.Animations = {
    ["idle"] =  {
        Source = "idle01",
        Time = 0.9
    },
    ["draw"] = {
        Source = "draw",
        Time = 0.8,
    },
    ["bash"] = {
        Source = {"misscenter1", "misscenter2"},
        Time = 0.75,
    },
    ["bash2"] = {
        Source = "hitcenter1",
        Time = 0.8,
    },
}

SWEP.IronSightStruct = false

SWEP.ActivePos = Vector(2, -6, 4)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 20, 0)

SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(35, -30, 0)

SWEP.HolsterPos = Vector(0, -3, -2)
SWEP.HolsterAng = Angle(-10, 0, 0)

SWEP.Charged = nil
SWEP.ChargeEffect = nil

-- Right click stacks up to 3 charges, paid for with Energy. Left click spends them:
-- 1 charge: the next hit discharges lightning (the original charged hit).
-- 2 charges: Thunder Hand, hold left click to fire lightning bolts from the hammer.
-- 3 charges: Thunder Storm, hold left click to call lightning from the sky around you.
-- There are no cooldowns, Energy is the only limit.
SWEP.EnergyMax = 100
SWEP.EnergyRegen = 4
SWEP.ChargeCosts = {20, 30, 50}
SWEP.LightningColor = "0 100 255"

SWEP.BoltDuration = 6
SWEP.BoltInterval = 0.1
SWEP.BoltRange = 1200
SWEP.BoltDamage = 90
SWEP.BoltChainDamage = 60
SWEP.BoltChainRange = 300
SWEP.BoltChainCount = 4

SWEP.StormDuration = 10
SWEP.StormInterval = 0.15
SWEP.StormStrikesPerTick = 2
SWEP.StormRadius = 600
SWEP.StormDamage = 250
SWEP.StormStrikeRadius = 130

SWEP.ThunderSound = Sound("ambient/atmosphere/thunder1.wav")

DEFINE_BASECLASS(SWEP.Base)

function SWEP:GetMjolnirEnergy()
    local energy = self:GetNWFloat("HordeMjolnirEnergy", self.EnergyMax)
    local busy_until = self:GetNWFloat("HordeMjolnirBusyUntil", 0)
    if busy_until > CurTime() then return energy end
    local since = math.max(self:GetNWFloat("HordeMjolnirEnergyTime", 0), busy_until)
    return math.min(self.EnergyMax, energy + math.max(0, CurTime() - since) * self.EnergyRegen)
end

function SWEP:SetMjolnirEnergy(energy)
    self:SetNWFloat("HordeMjolnirEnergy", energy)
    self:SetNWFloat("HordeMjolnirEnergyTime", CurTime())
end

function SWEP:SetMjolnirBusy(duration)
    self:SetMjolnirEnergy(self:GetMjolnirEnergy())
    self:SetNWFloat("HordeMjolnirBusyUntil", CurTime() + duration)
end

function SWEP:SecondaryAttack()
    if self:GetNextSecondaryFire() > CurTime() then return end
    if self:GetNWFloat("HordeMjolnirBusyUntil", 0) > CurTime() then return end
    local level = self:GetNWInt("HordeMjolnirCharge", 0)
    if level >= 3 then return end
    local cost = self.ChargeCosts[level + 1]
    local energy = self:GetMjolnirEnergy()
    if energy < cost then return end

    level = level + 1
    self:SetMjolnirEnergy(energy - cost)
    self:SetNWInt("HordeMjolnirCharge", level)
    self.Charged = true
    self.Mjollner_Charged = true
    self.ChargeLoopCooldown = CurTime() + 1.25
    self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)

    if not IsFirstTimePredicted() then return end
    self:EmitSound(self.ChargeSound, 75, 90 + level * 10)
    if level == 1 then
        local e = EffectData()
        e:SetOrigin(self.Weapon:GetPos())
        e:SetEntity(self.Weapon)
        e:SetRadius(50)
        util.Effect("charged", e)
    end
end

function SWEP:PrimaryAttack()
    if self:GetNWFloat("HordeMjolnirBoltUntil", 0) > CurTime() then return end
    if self:GetNextPrimaryFire() > CurTime() then return end

    local level = self:GetNWInt("HordeMjolnirCharge", 0)
    if level >= 2 then
        local duration = level == 2 and self.BoltDuration or self.StormDuration
        self:SetNWInt("HordeMjolnirCharge", 0)
        self:SetNWInt("HordeMjolnirMode", level)
        self.Charged = nil
        self.Mjollner_Charged = nil
        self:SetNWFloat("HordeMjolnirBoltUntil", CurTime() + duration)
        self:SetMjolnirBusy(duration)
        self.Mjolnir_NextBolt = CurTime()
        if IsFirstTimePredicted() then self:EmitSound(self.ThunderSound, 90) end
        return
    end

    BaseClass.PrimaryAttack(self)
end

function SWEP:Hook_HordePostCleaving(info)
    if not self.Charged then return end
    local attacker = self:GetOwner()
    if !IsValid(attacker) then return end
    local enemy_tr = info.tr.Entity
    local cleave = info.cleave
    local headshot = info.tr.HitGroup

    if SERVER then
        local shock_dmg = 150
        if cleave[1] ~= nil then
            for _, entities in ipairs(cleave) do
                if entities:IsNPC() and entities ~= enemy_tr then
                    self:LSS(entities:GetPos() + entities:OBBCenter())
                end
                for _, ent in pairs(ents.FindInSphere(entities:GetPos(), 100)) do
                    if HORDE:IsPlayerOrMinion(ent) == true then continue end
                    if ent:IsNPC() and ent ~= enemy_tr then
                        if ent.hit_by_shock_dmg_aoe then continue end
                        local dmg = DamageInfo()
                            dmg:SetDamage(shock_dmg)
                            dmg:SetDamageType(DMG_SHOCK)
                            dmg:SetAttacker(attacker)
                            dmg:SetInflictor(self)
                            dmg:SetDamagePosition(ent:GetPos() + ent:OBBCenter())
                            dmg:SetDamageCustom(HORDE.DMG_SPLASH)
                        ent:TakeDamageInfo(dmg)

                        ent.hit_by_shock_dmg_aoe = true
                        timer.Simple(0, function()
                            ent.hit_by_shock_dmg_aoe = nil
                        end)
                    end
                end
            end
        end
        if headshot == 1 then
            shock_dmg = shock_dmg * 2
        end
        if IsValid(enemy_tr) and enemy_tr:IsNPC() then
            local enemy_pos = info.tr.HitPos
            local dmginfo = DamageInfo()
                dmginfo:SetAttacker(attacker)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamageForce(attacker:GetRight() * -4912 + attacker:GetForward() * 9989)
                dmginfo:SetDamageType(DMG_SHOCK)
                dmginfo:SetDamagePosition(enemy_pos)
                dmginfo:SetDamage(shock_dmg)
                dmginfo:SetDamageCustom(HORDE.DMG_SPLASH)
            enemy_tr:TakeDamageInfo(dmginfo)

            self:LSS(enemy_pos)
        end
    end

    if (enemy_tr ~= NULL and !enemy_tr:IsWorld()) or cleave[1] ~= nil then
        self.Charged = nil
        self.Mjollner_Charged = nil
        self:SetNWInt("HordeMjolnirCharge", 0)
        self.Weapon:EmitSound(self.ChargeHitSound)
    end
end

function SWEP:Hook_Think()
    self.Mjollner_Charged = self:GetNWInt("HordeMjolnirCharge", 0) > 0 or nil
    if self.Charged and self.ChargeLoopCooldown - CurTime() <= 0 then
        self.Weapon:EmitSound(self.ChargeLoopSound)
        self.ChargeLoopCooldown = CurTime() + 3.5
    end

    if SERVER and self:GetNWFloat("HordeMjolnirBoltUntil", 0) > CurTime() then
        local owner = self:GetOwner()
        if IsValid(owner) and owner:KeyDown(IN_ATTACK) and (self.Mjolnir_NextBolt or 0) <= CurTime() then
            if self:GetNWInt("HordeMjolnirMode", 2) == 3 then
                self.Mjolnir_NextBolt = CurTime() + self.StormInterval
                for _ = 1, self.StormStrikesPerTick do
                    self:StormStrike(owner)
                end
            else
                self.Mjolnir_NextBolt = CurTime() + self.BoltInterval
                self:FireBolt()
            end
        end
    end
end

function SWEP:Holster(...)
    self:SetNWFloat("HordeMjolnirBoltUntil", 0)
    return BaseClass.Holster(self, ...)
end

function SWEP:IsMjolnirTarget(ent)
    return IsValid(ent) and (ent:IsNPC() or ent:IsNextBot()) and ent:Health() > 0
        and HORDE:IsPlayerOrMinion(ent) ~= true
end

function SWEP:ShockDamage(ent, damage, pos)
    local attacker = self:GetOwner()
    local dmg = DamageInfo()
        dmg:SetDamage(damage)
        dmg:SetDamageType(DMG_SHOCK)
        dmg:SetAttacker(attacker)
        dmg:SetInflictor(self)
        dmg:SetDamagePosition(pos or (ent:GetPos() + ent:OBBCenter()))
        dmg:SetDamageCustom(HORDE.DMG_SPLASH)
    ent:TakeDamageInfo(dmg)
end

function SWEP:Beam(from, to, width, life, noise)
    local LT = ents.Create("info_target")
    local idx = LT:EntIndex()
    LT:SetKeyValue("targetname", "mjolner_beam_" .. idx)
    LT:SetPos(to)
    LT:Spawn()
    LT:Fire("kill", "", life + 0.1)

    local LA = ents.Create("env_laser")
    LA:SetKeyValue("lasertarget", "mjolner_beam_" .. idx)
    LA:SetKeyValue("rendercolor", self.LightningColor)
    LA:SetKeyValue("texture", "sprites/laserbeam.spr")
    LA:SetKeyValue("width", tostring(width))
    LA:SetKeyValue("damage", "0")
    LA:SetKeyValue("spawnflags", "32")
    LA:SetKeyValue("noiseamplitude", tostring(noise or 6))
    LA:SetPos(from)
    LA:SetOwner(self)
    LA:Spawn()
    LA:Fire("kill", "", life)
end

-- Several jagged beams between two points, so one bolt reads as a thick lightning arc.
function SWEP:Lightning(from, to, width, life, count)
    for i = 1, count do
        self:Beam(from, to, i == 1 and width or width * 0.5, life, 4 + i * 4)
    end
end

-- Small blue spark burst at an impact, like the charged hit's discharge.
function SWEP:Burst(pos, count, spread)
    for _ = 1, count do
        self:Beam(pos, pos + VectorRand() * spread, 2, 0.2, 10)
    end
end

function SWEP:FireBolt()
    local owner = self:GetOwner()
    local src = owner:GetShootPos()
    local tr = util.TraceHull({
        start = src,
        endpos = src + owner:GetAimVector() * self.BoltRange,
        filter = {owner, self},
        mins = Vector(-12, -12, -12),
        maxs = Vector(12, 12, 12),
        mask = MASK_SHOT,
    })
    local muzzle = src + owner:GetRight() * 8 - owner:GetUp() * 6 + owner:GetForward() * 20
    self:Lightning(muzzle, tr.HitPos, 6, 0.15, 3)
    self:Burst(tr.HitPos, 4, 40)
    self:EmitSound("ambient/energy/zap" .. math.random(1, 9) .. ".wav", 75, math.random(90, 110))

    local target = tr.Entity
    if not self:IsMjolnirTarget(target) then return end
    self:ShockDamage(target, self.BoltDamage, tr.HitPos)

    local chained = 0
    for _, ent in ipairs(ents.FindInSphere(tr.HitPos, self.BoltChainRange)) do
        if chained >= self.BoltChainCount then break end
        if ent ~= target and self:IsMjolnirTarget(ent) then
            local pos = ent:GetPos() + ent:OBBCenter()
            self:Lightning(tr.HitPos, pos, 3, 0.15, 2)
            self:ShockDamage(ent, self.BoltChainDamage, pos)
            chained = chained + 1
        end
    end
end

function SWEP:StormStrike(owner)
    local center = owner:GetPos()
    local targets = {}
    for _, ent in ipairs(ents.FindInSphere(center, self.StormRadius)) do
        if self:IsMjolnirTarget(ent) then targets[#targets + 1] = ent end
    end

    local pos
    if #targets > 0 then
        pos = targets[math.random(#targets)]:GetPos()
    else
        local offset = VectorRand() * self.StormRadius
        offset.z = 0
        pos = center + offset
    end
    local ground = util.TraceLine({start = pos + Vector(0, 0, 50), endpos = pos - Vector(0, 0, 200), mask = MASK_SOLID_BRUSHONLY})
    if ground.Hit then pos = ground.HitPos end
    local sky = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, 800), mask = MASK_SOLID_BRUSHONLY})

    self:Lightning(sky.HitPos, pos, 14, 0.25, 3)
    self:Burst(pos + Vector(0, 0, 10), 6, self.StormStrikeRadius)
    sound.Play("ambient/atmosphere/thunder" .. math.random(1, 4) .. ".wav", pos, 90, math.random(95, 110))

    for _, ent in ipairs(ents.FindInSphere(pos, self.StormStrikeRadius)) do
        if self:IsMjolnirTarget(ent) then
            self:ShockDamage(ent, self.StormDamage)
            ent:Horde_AddDebuffBuildup(HORDE.Status_Shock, 25, owner)
        end
    end
end

function SWEP:LSS(pos)
    if CLIENT then return end
    local LT = ents.Create("info_target")
    local idx = LT:EntIndex()
    LT:SetKeyValue("targetname","mjolner_target_" .. idx)
    LT:SetPos(pos)
    LT:Fire("kill","",0.5)
    LT:Spawn()

    timer.Simple(0.1, function ()
        for i = 1,50 do
            local LA = ents.Create("env_laser")
            LA:SetKeyValue("lasertarget", "mjolner_target_" .. idx)
            LA:SetKeyValue("rendercolor", "0 100 255")
            LA:SetKeyValue("texture", "sprites/laserbeam.spr")
            LA:SetKeyValue("dissolvetype", "1")
            LA:SetKeyValue("width", "2")
            LA:SetKeyValue("damage", "0")
            LA:SetKeyValue("spawnflags", "32")
            LA:SetKeyValue("noiseamplitude", "10")
            LA:SetOwner(self)
            LA:Spawn()
            LA:Fire("Kill","",0.5)
            LA:SetPos(pos + VectorRand() * 100)
        end
    end)
end

if CLIENT then
    hook.Add("HUDPaint", "Horde_MjolnirEnergy", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        local wpn = ply:GetActiveWeapon()
        if not IsValid(wpn) or wpn:GetClass() ~= "arccw_horde_mjollnir" then return end

        local w, h = 220, 10
        local x, y = ScrW() / 2 - w / 2, ScrH() - 140
        local frac = wpn:GetMjolnirEnergy() / wpn.EnergyMax
        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(x - 2, y - 2, w + 4, h + 4)
        surface.SetDrawColor(60, 140, 255, 230)
        surface.DrawRect(x, y, w * frac, h)

        local level = wpn:GetNWInt("HordeMjolnirCharge", 0)
        for i = 1, 3 do
            if i <= level then
                surface.SetDrawColor(255, 215, 0, 255)
            else
                surface.SetDrawColor(80, 80, 80, 200)
            end
            surface.DrawRect(ScrW() / 2 - 40 + (i - 1) * 30, y - 16, 20, 8)
        end

        local busy = wpn:GetNWFloat("HordeMjolnirBusyUntil", 0) - CurTime()
        if busy > 0 then
            draw.SimpleText(string.format("%.1f", busy), "Trebuchet18", ScrW() / 2, y + h + 4, color_white, TEXT_ALIGN_CENTER)
        end
    end)
end
