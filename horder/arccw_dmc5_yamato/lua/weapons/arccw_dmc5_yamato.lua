if not ArcCWInstalled then return end

-- Vergil's Yamato (DMC5), remade on ArcCW's melee base from the TFA version.
--
-- Left click slashes in the direction you move (A / D give the side slashes, otherwise the
-- forward slash). Right click is the heavy slash, and the long overhead combo when holding S.
-- Abilities kept from the TFA version:
--   S + R             Judgment Cut: a burst of cuts where you aim
--   E + A / D         dash sideways (a short hop in the air)
--   E + W + click     rapid slash: dash forward through enemies
--   E + S + click     launcher: an upward cut, keep holding click to jump up with it
--   +800 run speed while held
-- Removed: the R teleport and E + R Judgment Cut End.

local snd = function(name, file, chan)
    sound.Add({ name = name, channel = chan or CHAN_WEAPON, level = 75, pitch = { 95, 105 }, sound = file })
end
snd("ArcCW_DMC5_Yamato.Slash", "weapons/yamato_slash.wav")
snd("ArcCW_DMC5_Yamato.Slash2", "weapons/yamato_slash2.wav")
snd("ArcCW_DMC5_Yamato.Slash3", "weapons/yamato_slash3.wav")
snd("ArcCW_DMC5_Yamato.HitLeft", "weapons/yamato_hitleft.wav")
snd("ArcCW_DMC5_Yamato.HitRight", "weapons/yamato_hitright.wav")
snd("ArcCW_DMC5_Yamato.JudgmentCut", "weapons/yamato_jcn.wav", CHAN_STATIC)
snd("ArcCW_DMC5_Yamato.Dash", "weapons/yamato_tele.wav", CHAN_BODY)

DEFINE_BASECLASS("arccw_base_melee")
SWEP.Base = "arccw_base_melee"
SWEP.Spawnable = true
SWEP.Category = "ArcCW - Melee"
SWEP.AdminOnly = false

SWEP.PrintName = "Yamato"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Vergil's katana. A sword that cuts through anything.\n\nS+R: Judgment Cut. E+A/D: dash. E+W+click: rapid slash. E+S+click: launcher."
SWEP.Trivia_Manufacturer = "Sparda"
SWEP.Trivia_Calibre = "N/A"
SWEP.Trivia_Mechanism = "Slashing Weapon"
SWEP.Trivia_Country = "Unknown"
SWEP.Trivia_Year = 2019

SWEP.Slot = 0
SWEP.NotForNPCs = true
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/yamato/yamato.mdl"
SWEP.WorldModel = "models/weapons/w_yamato.mdl"
SWEP.MirrorVMWM = false
SWEP.ViewModelFOV = 85

SWEP.DefaultSkin = 0
SWEP.DefaultWMSkin = 0

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.Melee2 = true
SWEP.MeleeDamage = 125
SWEP.Melee2Damage = 260
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeRange = 80
SWEP.Melee2Range = 90
SWEP.MeleeAttackTime = 0.12
SWEP.Melee2AttackTime = 0.15
SWEP.MeleeTime = 0.6
SWEP.Melee2Time = 0.95
SWEP.MeleeSwingSound = nil
SWEP.MeleeMissSound = nil

SWEP.Firemodes = {
    { Mode = 1, PrintName = "MELEE" },
}

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "melee"

SWEP.AttachmentElements = {}
SWEP.Attachments = {}

SWEP.IronSightStruct = false
SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)
SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 0, 0)
SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(0, 0, 0)
SWEP.HolsterPos = Vector(0, -3, -2)
SWEP.HolsterAng = Angle(-10, 0, 0)

-- The ability animations of Judgment Cut End and the teleport ("rd", "cut") are not used
local ss = function(name) return { { s = name, t = 0 } } end
SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["draw"] = { Source = "draw" },
    ["ready"] = { Source = "draw" },
    ["bash"] = { Source = "slash", SoundTable = ss("ArcCW_DMC5_Yamato.Slash") },
    ["bash2"] = { Source = "slash2", SoundTable = ss("ArcCW_DMC5_Yamato.Slash2") },
    ["slash"] = { Source = "slash", SoundTable = ss("ArcCW_DMC5_Yamato.Slash") },
    ["slash2"] = { Source = "slash2", SoundTable = ss("ArcCW_DMC5_Yamato.Slash2") },
    ["slash3"] = { Source = "slash3", SoundTable = ss("ArcCW_DMC5_Yamato.Slash3") },
    ["hitlift1"] = { Source = "hitlift1", SoundTable = ss("ArcCW_DMC5_Yamato.HitLeft") },
    ["hitlift2"] = { Source = "hitlift2", SoundTable = ss("ArcCW_DMC5_Yamato.HitLeft") },
    ["hitlift3"] = { Source = "hitlift3", SoundTable = ss("ArcCW_DMC5_Yamato.HitLeft") },
    ["hitright1"] = { Source = "hitright1", SoundTable = ss("ArcCW_DMC5_Yamato.HitRight") },
    ["hitright2"] = { Source = "hitright2", SoundTable = ss("ArcCW_DMC5_Yamato.HitRight") },
    ["hitright3"] = { Source = "hitright3", SoundTable = ss("ArcCW_DMC5_Yamato.HitRight") },
    ["jc"] = { Source = "jc", SoundTable = ss("ArcCW_DMC5_Yamato.JudgmentCut") },
}

-- Swings by the direction the player moves in. time = until the next swing, hit = seconds
-- into the swing when it lands, range/radius = reach and width, maxhits = enemies per swing.
local G1, G2 = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2
local FWD = { anims = { "slash" }, dmg = 125, time = 0.6, hit = 0.12, range = 100, radius = 60, maxhits = 4, gesture = G1 }
local HEAVY = { anims = { "slash2" }, dmg = 260, time = 0.95, hit = 0.15, range = 110, radius = 80, maxhits = 8, gesture = G2 }
SWEP.YamatoSwings = {
    primary = {
        F = FWD,
        B = FWD,
        L = { anims = { "hitlift1", "hitlift2", "hitlift3" }, dmg = 90, time = 0.35, hit = 0.05, range = 100, radius = 60, maxhits = 3, gesture = G1 },
        R = { anims = { "hitright1", "hitright2", "hitright3" }, dmg = 90, time = 0.35, hit = 0.05, range = 100, radius = 60, maxhits = 3, gesture = G1 },
    },
    secondary = {
        F = HEAVY,
        L = HEAVY,
        R = HEAVY,
        B = { anims = { "slash3" }, dmg = 400, time = 1.65, hit = 0.2, range = 120, radius = 100, maxhits = 10, gesture = G2 },
    },
}

SWEP.YamatoRunSpeed = 800
SWEP.YamatoNextSkill = 0 -- rapid slash / launcher cooldown
SWEP.YamatoNextCut = 0   -- Judgment Cut cooldown
SWEP.YamatoNextDash = 0

local function MoveDir(owner)
    local l, r = owner:KeyDown(IN_MOVELEFT), owner:KeyDown(IN_MOVERIGHT)
    if l and not r then return "L" end
    if r and not l then return "R" end
    if owner:KeyDown(IN_BACK) then return "B" end
    return "F"
end

local function CanDamage(owner, ent)
    if not IsValid(ent) or ent == owner or ent:IsWeapon() then return false end
    if ent:GetOwner() == owner then return false end
    if ent:IsPlayer() then return ent:Alive() end
    return ent:IsNPC() or ent:IsNextBot() or ent:Health() > 0
end

-- Brief invulnerability during abilities, as in the TFA version (no GodEnable, so it can't stick)
if SERVER then
    hook.Add("EntityTakeDamage", "ArcCW_DMC5_Yamato_IFrames", function(ent)
        if ent.ArcCW_Yamato_IFrames and ent.ArcCW_Yamato_IFrames > CurTime() then return true end
    end)
end

function SWEP:YamatoIFrames(t)
    local owner = self:GetOwner()
    if SERVER and IsValid(owner) then
        owner.ArcCW_Yamato_IFrames = math.max(owner.ArcCW_Yamato_IFrames or 0, CurTime() + t)
    end
end

function SWEP:YamatoActive()
    local owner = self:GetOwner()
    return IsValid(owner) and owner:IsPlayer() and owner:Alive() and owner:GetActiveWeapon() == self
end

-- pred: true when called from a predicted hook (both sides), false from a server timer
function SWEP:YamatoAnim(key, pred)
    if not self.Animations[key] then return end
    self:PlayAnimation(key, 1, pred, 0, true)
end

function SWEP:YamatoDamage(ent, dmg, pos, force)
    local owner = self:GetOwner()
    local info = DamageInfo()
    info:SetAttacker(owner)
    info:SetInflictor(self)
    info:SetDamage(dmg)
    info:SetDamageType(DMG_SLASH)
    info:SetDamagePosition(pos or ent:WorldSpaceCenter())
    info:SetDamageForce(force or (ent:WorldSpaceCenter() - owner:GetPos()):GetNormalized() * 5000)
    ent:TakeDamageInfo(info)
end

-- Area cut around a point, used by the abilities. Server only.
function SWEP:YamatoAoE(pos, radius, dmg)
    if CLIENT or not self:YamatoActive() then return end
    local owner = self:GetOwner()
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if CanDamage(owner, ent) then self:YamatoDamage(ent, dmg) end
    end
end

-- A sword swing: everything damageable in a cone in front of the player, closest first.
function SWEP:YamatoSlash(swing)
    if CLIENT or not self:YamatoActive() then return end
    local owner = self:GetOwner()
    owner:LagCompensation(true)

    local eye, fwd = owner:GetShootPos(), owner:GetAimVector()
    local tr = util.TraceHull({
        start = eye, endpos = eye + fwd * swing.range, filter = owner,
        mins = Vector(-6, -6, -6), maxs = Vector(6, 6, 6), mask = MASK_SHOT_HULL,
    })

    local targets, seen = {}, {}
    local function add(ent)
        if seen[ent] or not CanDamage(owner, ent) then return end
        seen[ent] = true
        targets[#targets + 1] = ent
    end
    if IsValid(tr.Entity) then add(tr.Entity) end
    for _, ent in ipairs(ents.FindInSphere(eye + fwd * swing.range * 0.5, swing.radius + swing.range * 0.5)) do
        if not seen[ent] and CanDamage(owner, ent) then
            local center = ent:WorldSpaceCenter()
            local to = center - eye
            local dist = to:Length()
            if dist <= swing.range + ent:BoundingRadius() and to:GetNormalized():Dot(fwd) > 0.55 then
                local vis = util.TraceLine({ start = eye, endpos = center, mask = MASK_SOLID_BRUSHONLY })
                if not vis.Hit then add(ent) end
            end
        end
    end
    table.sort(targets, function(a, b) return a:GetPos():DistToSqr(eye) < b:GetPos():DistToSqr(eye) end)

    local hits = 0
    for _, ent in ipairs(targets) do
        if hits >= swing.maxhits then break end
        local pos = (ent == tr.Entity) and tr.HitPos or ent:NearestPoint(eye)
        self:YamatoDamage(ent, swing.dmg, pos, fwd * 8000 + owner:GetRight() * math.Rand(-3000, 3000))
        hits = hits + 1
    end

    owner:LagCompensation(false)

    if hits > 0 then
        self:MyEmitSound(self.MeleeHitNPCSound, 75, 100, 1, CHAN_STATIC)
    elseif tr.HitWorld then
        self:MyEmitSound(self.MeleeHitSound, 75, 100, 1, CHAN_STATIC)
        util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    end
end

-- E + W + click on the ground: dash forward cutting everything around you, then a wide finisher
function SWEP:YamatoRapidSlash()
    local owner = self:GetOwner()
    self.YamatoNextSkill = CurTime() + 1
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)
    self:YamatoAnim("hitlift1", true)
    owner:DoAnimationEvent(G1)
    if CLIENT then return end

    local aim = owner:GetAimVector()
    local push = Vector(aim.x * 100, aim.y * 100, aim.z * 0.5) * 1024
    owner:SetVelocity(push)
    owner:ViewPunch(Angle(4, 0, 0))
    self:YamatoIFrames(0.3)

    local steps = { 0.05, 0.07, 0.09, 0.11, 0.13, 0.14, 0.15 }
    local anims = { [0.11] = "hitright1", [0.14] = "hitlift2" }
    for _, t in ipairs(steps) do
        timer.Simple(t, function()
            if not IsValid(self) or not self:YamatoActive() then return end
            self:YamatoAoE(owner:GetPos(), 200, 34)
            if anims[t] then self:YamatoAnim(anims[t], false) end
            if t == 0.15 then owner:SetVelocity(push) end
        end)
    end
    timer.Simple(0.24, function()
        if not IsValid(self) or not self:YamatoActive() then return end
        self:YamatoAnim("slash2", false)
        owner:ViewPunch(Angle(0, -260, 3))
        owner:SetAnimation(PLAYER_ATTACK1)
        self:YamatoAoE(owner:GetPos(), 220, 120)
    end)
end

-- E + S + click on the ground: upward cut, keep holding click to jump up with it
function SWEP:YamatoLauncher()
    local owner = self:GetOwner()
    self.YamatoNextSkill = CurTime() + 1.7
    self:SetNextPrimaryFire(CurTime() + 0.85)
    self:SetNextSecondaryFire(CurTime() + 0.85)
    self:YamatoAnim("slash3", true)
    owner:DoAnimationEvent(G2)
    if CLIENT then return end

    owner:ViewPunch(Angle(-30, -6, -4))
    self:YamatoIFrames(0.25)
    self:YamatoAoE(owner:GetPos(), 150, 80)
    timer.Simple(0.2, function()
        if not IsValid(self) or not self:YamatoActive() then return end
        if owner:KeyDown(IN_ATTACK) then
            owner:SetVelocity(Vector(0, 0, 500))
            self:YamatoAoE(owner:GetPos(), 200, 34)
        end
    end)
end

-- S + R: Judgment Cut, a burst of cuts at the spot you aim at
function SWEP:YamatoJudgmentCut()
    local owner = self:GetOwner()
    self.YamatoNextCut = CurTime() + 1
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:YamatoAnim("jc", true)
    if CLIENT then return end

    local pos = owner:GetEyeTrace().HitPos
    owner:ViewPunch(Angle(1, 2, 2))
    self:YamatoIFrames(0.2)
    util.ScreenShake(pos, 5, 5, 0.3, 300)

    local rings = {}
    for i, look in ipairs({
        { col = Color(120, 110, 255, 250), mat = "models/effects/comball_sphere" },
        { col = Color(29, 0, 255, 150), mat = "models/shiny" },
    }) do
        local ent = ents.Create("prop_dynamic")
        if IsValid(ent) then
            ent:SetModel("models/maxofs2d/hover_rings.mdl")
            ent:SetPos(pos + Vector(0, 0, 80))
            ent:SetAngles(Angle(0, 0, 0))
            ent:SetColor(look.col)
            ent:SetMaterial(look.mat)
            ent:SetRenderMode(RENDERMODE_TRANSALPHA)
            ent:SetNotSolid(true)
            ent:Spawn()
            ent:SetModelScale(0.01, 0)
            rings[i] = ent
        end
    end
    local function scale(s, t)
        for _, ent in pairs(rings) do if IsValid(ent) then ent:SetModelScale(s, t) end end
    end
    timer.Simple(0.01, function()
        if IsValid(self) then self:YamatoAoE(pos, 150, 95) end
        scale(15, 0.005)
    end)
    timer.Simple(0.1, function() scale(0.01, 0.05) end)
    timer.Simple(0.2, function()
        for _, ent in pairs(rings) do if IsValid(ent) then ent:Remove() end end
    end)
end

-- Directional swings plus the E-combo abilities on left click
function SWEP:Bash(melee2)
    local state = self:GetState()
    if state == ArcCW.STATE_SIGHTS or state == ArcCW.STATE_CUSTOMIZE
            or (state == ArcCW.STATE_SPRINT and not self:CanShootWhileSprint()) then
        return
    end
    if self:GetNextPrimaryFire() > CurTime() or self:GetPriorityAnim() then return end

    local owner = self:GetOwner()
    if not melee2 and owner:KeyDown(IN_USE) and owner:IsOnGround() and CurTime() > self.YamatoNextSkill then
        if owner:KeyDown(IN_FORWARD) then return self:YamatoRapidSlash() end
        if owner:KeyDown(IN_BACK) then return self:YamatoLauncher() end
    end

    local set = melee2 and self.YamatoSwings.secondary or self.YamatoSwings.primary
    local swing = set[MoveDir(owner)] or set.F
    local n = #swing.anims
    local anim = swing.anims[math.Clamp(math.floor(util.SharedRandom("ArcCW_Yamato", 1, n + 1)), 1, n)]

    self.Primary.Automatic = true
    self:YamatoAnim(anim, true)
    self:SetNextPrimaryFire(CurTime() + swing.time)
    self:SetNextSecondaryFire(CurTime() + swing.time)
    owner:DoAnimationEvent(swing.gesture)
    owner:SetAnimation(PLAYER_ATTACK1)
    if SERVER then owner:ViewPunch(Angle(1, MoveDir(owner) == "L" and -5 or (MoveDir(owner) == "R" and 5 or 2), 0)) end

    self:SetTimer(swing.hit, function()
        if IsValid(self) then self:YamatoSlash(swing) end
    end)
end

function SWEP:Reload()
    local owner = self:GetOwner()
    if not IsValid(owner) or CurTime() < self.YamatoNextCut then return end
    if self:GetNextPrimaryFire() > CurTime() then return end
    if owner:KeyDown(IN_BACK) then self:YamatoJudgmentCut() end
end

-- E + A / D: sideways dash, a long one on the ground and a short hop in the air
function SWEP:Think()
    local owner = self:GetOwner()
    if IsValid(owner) and owner:KeyDown(IN_USE) and CurTime() > self.YamatoNextDash then
        local side = (owner:KeyDown(IN_MOVELEFT) and -1) or (owner:KeyDown(IN_MOVERIGHT) and 1) or nil
        if side then
            owner:SetLocalVelocity(owner:GetRight() * side * (owner:IsOnGround() and 3700 or 700))
            self.YamatoNextDash = CurTime() + 1
            if SERVER then
                owner:ViewPunch(Angle(0, 10 * side, 0))
                self:MyEmitSound("ArcCW_DMC5_Yamato.Dash", 75, 100, 1, CHAN_BODY)
            end
        end
    end
    return BaseClass.Think(self)
end

-- Run speed while the sword is out, put back when it is put away
function SWEP:YamatoSetSpeed(on)
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if on then
        if not self.YamatoOldRun then self.YamatoOldRun = owner:GetRunSpeed() end
        owner:SetRunSpeed(self.YamatoRunSpeed)
    elseif self.YamatoOldRun then
        owner:SetRunSpeed(self.YamatoOldRun)
        self.YamatoOldRun = nil
    end
end

function SWEP:Deploy(...)
    self:YamatoSetSpeed(true)
    return BaseClass.Deploy(self, ...)
end

function SWEP:Holster(...)
    local done = BaseClass.Holster(self, ...)
    if done ~= false then self:YamatoSetSpeed(false) end
    return done
end

function SWEP:OnRemove(...)
    self:YamatoSetSpeed(false)
    if BaseClass.OnRemove then return BaseClass.OnRemove(self, ...) end
end

-- The model plays its swing sounds through animation events, which only the swinging player
-- hears. Those are muted here and the sound tables above play them for everyone instead.
function SWEP:FireAnimationEvent(pos, ang, event, options)
    if event == 5004 or event == 5001 or event == 5011 or event == 5021 or event == 5031 then return true end
end

-- ArcCW runs melee swings on the server only, where a sound emitted inside the predicted
-- attack skips the swinging player. Emitting one tick later reaches everyone, them included.
function SWEP:MyEmitSound(s, level, pitch, vol, chan)
    if CLIENT or not s then return end
    if istable(s) then s = s[math.random(#s)] end
    if not s or s == "" then return end
    timer.Simple(0, function()
        if IsValid(self) then
            self:EmitSound(s, level or 75, pitch or 100, vol or 1, chan or CHAN_AUTO)
        end
    end)
end
