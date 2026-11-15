if not ArcCWInstalled then return end

-- Vergil's Yamato (DMC5), remade on ArcCW's melee base from the TFA version.
--
-- Left click slashes in the direction you move (A / D give the side slashes, otherwise the
-- forward slash). Right click is the heavy slash, the uppercut when holding S.
--
-- Abilities cost Concentration, the bar under the crosshair. It fills when your slashes hit
-- and slowly on its own.
--   R                 teleport a short distance, onto the floor only; aimed at an enemy you
--                     launched, it takes you to them in the air and holds them there for a combo
--   S + R             Judgment Cut: a burst of cuts where you aim (no cooldown, only the cost)
--   E + R             Judgment Cut End: needs a full bar, cuts everything around you for 4000,
--                     then a 60 second cooldown
--   E + A / D         dash sideways (a short hop in the air)
--   E + W + click     rapid slash: dash forward through enemies
--   S + right click   uppercut: throws enemies into the air,
--                     keep holding right click to jump up with it
--   +800 run speed while held

local snd = function(name, file, chan)
    sound.Add({ name = name, channel = chan or CHAN_WEAPON, level = 75, pitch = { 95, 105 }, sound = file })
end
snd("ArcCW_DMC5_Yamato.Slash", "weapons/yamato_slash.wav")
snd("ArcCW_DMC5_Yamato.Slash2", "weapons/yamato_slash2.wav")
snd("ArcCW_DMC5_Yamato.Slash3", "weapons/yamato_slash3.wav")
snd("ArcCW_DMC5_Yamato.HitLeft", "weapons/yamato_hitleft.wav")
snd("ArcCW_DMC5_Yamato.HitRight", "weapons/yamato_hitright.wav")
snd("ArcCW_DMC5_Yamato.JudgmentCut", "weapons/yamato_jcn.wav", CHAN_STATIC)
snd("ArcCW_DMC5_Yamato.JudgmentCutEnd", "weapons/yamato_jc.wav", CHAN_STATIC)
snd("ArcCW_DMC5_Yamato.Dash", "weapons/yamato_tele.wav", CHAN_STATIC)

DEFINE_BASECLASS("arccw_base_melee")
SWEP.Base = "arccw_base_melee"
SWEP.Spawnable = true
SWEP.Category = "ArcCW - Melee"
SWEP.AdminOnly = false

SWEP.PrintName = "Yamato"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Vergil's katana. A sword that cuts through anything.\n\nR: teleport. S+R: Judgment Cut. E+R (full bar): Judgment Cut End. E+A/D: dash. E+W+click: rapid slash. S+right click: uppercut."
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
    ["jce_start"] = { Source = "rd", SoundTable = ss("ArcCW_DMC5_Yamato.JudgmentCutEnd") },
    ["jce_end"] = { Source = "cut" },
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
        B = HEAVY, -- S + right click is the uppercut; this is only used in the air
    },
}

-- Concentration (the energy bar): max, start, regen per second, gain per enemy a slash hits,
-- and the cost of every ability
SWEP.YamatoEnergy = {
    max = 100,
    start = 30,
    regen = 1.5,
    per_hit = 3,
    per_ability_hit = 1,
    cost = {
        teleport = 10,
        judgment_cut = 20,
        judgment_cut_end = 100,
        dash = 5,
        rapid_slash = 20,
        launcher = 15,
    },
}

SWEP.YamatoTeleportRange = 350   -- how far the floor teleport reaches
SWEP.YamatoTeleportDrop = 160    -- how far below the aimed point it looks for a floor
SWEP.YamatoComboRange = 600      -- how far the teleport reaches a launched enemy
SWEP.YamatoLaunchWindow = 1.5    -- seconds after the launcher to teleport to the enemy
SWEP.YamatoFreezeTime = 2        -- how long a caught enemy hangs in the air
SWEP.YamatoFreezeMax = 4         -- slashing it keeps it up, but never longer than this
SWEP.YamatoJCEDamage = 4000
SWEP.YamatoJCERadius = 1400
SWEP.YamatoJCECooldown = 60      -- seconds after Judgment Cut End before it can be used again
SWEP.YamatoRunSpeed = 800

SWEP.YamatoNextSkill = 0 -- rapid slash / launcher cooldown
SWEP.YamatoNextCut = 0   -- R abilities cooldown
SWEP.YamatoNextDash = 0
SWEP.YamatoJCEUntil = 0

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

local function IsCharacter(ent)
    return ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()
end

--------------------------------------------------------------------------------------------
-- Concentration
--------------------------------------------------------------------------------------------

function SWEP:Initialize(...)
    self:SetNW2Float("YamatoEnergy", self.YamatoEnergy.start)
    return BaseClass.Initialize(self, ...)
end

function SWEP:YamatoGetEnergy()
    return self:GetNW2Float("YamatoEnergy", 0)
end

function SWEP:YamatoAddEnergy(n)
    if CLIENT then return end
    self:SetNW2Float("YamatoEnergy", math.Clamp(self:YamatoGetEnergy() + n, 0, self.YamatoEnergy.max))
end

-- Whether the ability can be paid for; takes the cost on the server
function SWEP:YamatoSpend(ability)
    local cost = self.YamatoEnergy.cost[ability] or 0
    if self:YamatoGetEnergy() < cost then return false end
    self:YamatoAddEnergy(-cost)
    return true
end

--------------------------------------------------------------------------------------------
-- Invulnerability, launching and holding enemies in the air (server)
--------------------------------------------------------------------------------------------

local Frozen = {}

if SERVER then
    -- Brief invulnerability during abilities, as in the TFA version (no GodEnable, so it can't stick)
    hook.Add("EntityTakeDamage", "ArcCW_DMC5_Yamato_IFrames", function(ent)
        if ent.ArcCW_Yamato_IFrames and ent.ArcCW_Yamato_IFrames > CurTime() then return true end
    end)

    local function Release(ent, data)
        Frozen[ent] = nil
        if not IsValid(ent) then return end
        ent.ArcCW_Yamato_Frozen = nil
        if ent:IsNextBot() then return end
        local phys = ent:GetPhysicsObject()
        if not IsCharacter(ent) and IsValid(phys) then
            phys:EnableMotion(true)
            phys:Wake()
            return
        end
        ent:SetMoveType(data.movetype)
        if ent:IsNPC() then ent:ClearSchedule() end
    end

    hook.Add("Think", "ArcCW_DMC5_Yamato_Frozen", function()
        if next(Frozen) == nil then return end
        local now = CurTime()
        for ent, data in pairs(Frozen) do
            if not IsValid(ent) or now > data.untill or (ent:IsPlayer() and not ent:Alive())
                    or (ent:IsNPC() and ent:Health() <= 0) then
                Release(ent, data)
            elseif ent:IsNextBot() then
                ent:SetPos(data.pos)
                if ent.loco then ent.loco:SetVelocity(vector_origin) end
            end
        end
    end)
end

-- Throws an enemy up and marks it as launched, so a teleport can catch it
function SWEP:YamatoLaunch(ent)
    if CLIENT or not IsValid(ent) or ent.ArcCW_Yamato_Frozen then return end
    local up = Vector(0, 0, 450)
    if ent:IsNextBot() and ent.loco then
        ent.loco:Jump()
        ent.loco:SetVelocity(up)
    elseif IsCharacter(ent) then
        ent:SetGroundEntity(NULL)
        ent:SetPos(ent:GetPos() + Vector(0, 0, 4))
        ent:SetVelocity(up)
    else
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then phys:AddVelocity(up) end
    end
    ent.ArcCW_Yamato_Launched = CurTime() + self.YamatoLaunchWindow
    ent.ArcCW_Yamato_LaunchedBy = self:GetOwner()
end

-- Holds an enemy in the air where it is, unable to move or act, for t seconds
function SWEP:YamatoFreeze(ent, t)
    if CLIENT or not IsValid(ent) then return end
    local data = Frozen[ent]
    if data then
        data.untill = math.min(math.max(data.untill, CurTime() + t), data.start + self.YamatoFreezeMax)
        return
    end
    data = { untill = CurTime() + t, start = CurTime(), pos = ent:GetPos(), movetype = ent:GetMoveType() }
    Frozen[ent] = data
    ent.ArcCW_Yamato_Frozen = true
    ent.ArcCW_Yamato_Launched = nil
    if ent:IsNextBot() then return end
    if IsCharacter(ent) then
        ent:SetVelocity(-ent:GetVelocity())
        ent:SetMoveType(MOVETYPE_NONE)
        if ent:IsNPC() then ent:SetSchedule(SCHED_NPC_FREEZE) end
    else
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
    end
end

function SWEP:YamatoIFrames(t)
    local owner = self:GetOwner()
    if SERVER and IsValid(owner) then
        owner.ArcCW_Yamato_IFrames = math.max(owner.ArcCW_Yamato_IFrames or 0, CurTime() + t)
    end
end

-- Lets the player hang in the air next to a caught enemy for the length of the combo
function SWEP:YamatoHang(t)
    local owner = self:GetOwner()
    if CLIENT or not IsValid(owner) then return end
    if not self.YamatoHangUntil then self.YamatoOldGravity = owner:GetGravity() end
    self.YamatoHangUntil = CurTime() + t
    owner:SetGravity(0.02)
    owner:SetVelocity(-owner:GetVelocity())
end

function SWEP:YamatoStopHang()
    local owner = self:GetOwner()
    if not self.YamatoHangUntil then return end
    self.YamatoHangUntil = nil
    if IsValid(owner) then owner:SetGravity(self.YamatoOldGravity or 1) end
end

--------------------------------------------------------------------------------------------
-- Damage helpers
--------------------------------------------------------------------------------------------

function SWEP:YamatoActive()
    local owner = self:GetOwner()
    return IsValid(owner) and owner:IsPlayer() and owner:Alive() and owner:GetActiveWeapon() == self
end

-- pred: true when called from a predicted hook (both sides), false from a server timer
function SWEP:YamatoAnim(key, pred)
    if not self.Animations[key] then return end
    -- tt (5th) stays false: with it, ArcCW locks attacks for the whole animation, and slash3
    -- is 6.5 seconds long. Every caller sets its own delay instead.
    self:PlayAnimation(key, 1, pred, 0, false)
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
    -- Every hit on an enemy held in the air keeps it up a little longer
    if Frozen[ent] then self:YamatoFreeze(ent, 0.4) end
end

-- Area cut around a point, used by the abilities. Server only. Returns the entities it hit.
function SWEP:YamatoAoE(pos, radius, dmg, energy)
    local hit = {}
    if CLIENT or not self:YamatoActive() then return hit end
    local owner = self:GetOwner()
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if CanDamage(owner, ent) then
            self:YamatoDamage(ent, dmg)
            hit[#hit + 1] = ent
        end
    end
    if energy ~= false then
        self:YamatoAddEnergy(math.min(#hit, 3) * self.YamatoEnergy.per_ability_hit)
    end
    return hit
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
        self:YamatoAddEnergy(math.min(hits, 3) * self.YamatoEnergy.per_hit)
        self:MyEmitSound(self.MeleeHitNPCSound, 75, 100, 1, CHAN_STATIC)
    elseif tr.HitWorld then
        self:MyEmitSound(self.MeleeHitSound, 75, 100, 1, CHAN_STATIC)
        util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    end
end

--------------------------------------------------------------------------------------------
-- Abilities
--------------------------------------------------------------------------------------------

-- E + W + click on the ground: dash forward cutting everything around you, then a wide finisher
function SWEP:YamatoRapidSlash()
    if not self:YamatoSpend("rapid_slash") then return false end
    local owner = self:GetOwner()
    self.YamatoNextSkill = CurTime() + 1
    self:YamatoAnim("hitlift1", true)
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)
    owner:DoAnimationEvent(G1)
    if CLIENT then return true end

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
    return true
end

-- S + right click on the ground: upward cut that throws the enemies it hits into the air.
-- Keep holding right click to jump up with it. Teleport (R) to a launched enemy to catch it.
function SWEP:YamatoLauncher()
    if not self:YamatoSpend("launcher") then return false end
    local owner = self:GetOwner()
    self:YamatoAnim("slash3", true)
    self:SetNextPrimaryFire(CurTime() + 0.6)
    self:SetNextSecondaryFire(CurTime() + 0.6)
    owner:DoAnimationEvent(G2)
    if CLIENT then return true end

    owner:ViewPunch(Angle(-30, -6, -4))
    self:YamatoIFrames(0.25)
    for _, ent in ipairs(self:YamatoAoE(owner:GetPos() + owner:GetForward() * 60, 150, 80)) do
        self:YamatoLaunch(ent)
    end
    timer.Simple(0.2, function()
        if not IsValid(self) or not self:YamatoActive() then return end
        if owner:KeyDown(IN_ATTACK2) then
            owner:SetVelocity(Vector(0, 0, 500))
            self:YamatoAoE(owner:GetPos(), 200, 34)
        end
    end)
    return true
end

-- A launched enemy (still in the launch window) near the crosshair, within combo range
function SWEP:YamatoFindLaunched()
    local owner = self:GetOwner()
    local eye, aim = owner:GetShootPos(), owner:GetAimVector()
    local best, bestdot
    for _, ent in ipairs(ents.FindInSphere(eye, self.YamatoComboRange)) do
        if ent.ArcCW_Yamato_Launched and ent.ArcCW_Yamato_Launched > CurTime()
                and ent.ArcCW_Yamato_LaunchedBy == owner and CanDamage(owner, ent) then
            local center = ent:WorldSpaceCenter()
            local dot = (center - eye):GetNormalized():Dot(aim)
            if dot > 0.9 and (not bestdot or dot > bestdot) then
                local vis = util.TraceLine({ start = eye, endpos = center, mask = MASK_SOLID_BRUSHONLY })
                if not vis.Hit then best, bestdot = ent, dot end
            end
        end
    end
    return best
end

-- Whether the player fits standing at pos
local function Fits(owner, pos)
    local mins, maxs = owner:GetHull()
    local tr = util.TraceHull({ start = pos, endpos = pos, mins = mins, maxs = maxs, filter = owner, mask = MASK_PLAYERSOLID })
    return not tr.Hit
end

-- A floor spot within reach where the player aims, or nil
function SWEP:YamatoFloorSpot()
    local owner = self:GetOwner()
    local eye, aim = owner:GetShootPos(), owner:GetAimVector()
    local tr = util.TraceLine({ start = eye, endpos = eye + aim * self.YamatoTeleportRange, filter = owner, mask = MASK_PLAYERSOLID })
    local flat = Vector(aim.x, aim.y, 0):GetNormalized()
    -- Walk back from the aimed point until there is a floor under it and room to stand
    for back = 16, 160, 24 do
        local point = tr.HitPos - flat * back
        if tr.Hit and tr.HitNormal.z > 0.7 and back == 16 then point = tr.HitPos end
        local down = util.TraceLine({
            start = point + Vector(0, 0, 8), endpos = point - Vector(0, 0, self.YamatoTeleportDrop),
            filter = owner, mask = MASK_PLAYERSOLID,
        })
        if down.Hit and down.HitNormal.z > 0.7 and not down.StartSolid then
            local spot = down.HitPos + Vector(0, 0, 2)
            if Fits(owner, spot) and spot:Distance(owner:GetPos()) > 48 then return spot end
        end
    end
end

-- R: short teleport onto the floor, or into the air next to an enemy you launched
function SWEP:YamatoTeleport()
    local owner = self:GetOwner()
    if CLIENT then return end -- the server moves the player; their view follows

    local target = self:YamatoFindLaunched()
    local dest
    if IsValid(target) then
        local center = target:WorldSpaceCenter()
        local dir = (center - owner:GetShootPos()):GetNormalized()
        local mins, maxs = owner:GetHull()
        local feet = center - dir * (target:BoundingRadius() + 24) - Vector(0, 0, (maxs.z - mins.z) * 0.5)
        if Fits(owner, feet) then dest = feet end
    end
    if not dest then
        target = nil
        dest = self:YamatoFloorSpot()
    end
    if not dest then return end
    if not self:YamatoSpend("teleport") then return end

    self.YamatoNextCut = CurTime() + 0.5
    owner:SetPos(dest)
    owner:SetVelocity(-owner:GetVelocity())
    owner:ViewPunch(Angle(5, 0, 0))
    owner:DoAnimationEvent(ACT_LAND)
    util.ScreenShake(dest, 3, 3, 0.2, 300)
    self:MyEmitSound("ArcCW_DMC5_Yamato.Dash", 75, 100, 1, CHAN_STATIC)

    if target then
        self:YamatoFreeze(target, self.YamatoFreezeTime)
        self:YamatoHang(self.YamatoFreezeTime)
        local ang = (target:WorldSpaceCenter() - owner:GetShootPos()):Angle()
        owner:SetEyeAngles(Angle(ang.p, ang.y, 0))
    end
end

-- S + R: Judgment Cut, a burst of cuts at the spot you aim at
function SWEP:YamatoJudgmentCut()
    if not self:YamatoSpend("judgment_cut") then return end
    local owner = self:GetOwner()
    self:YamatoAnim("jc", true)
    self:SetNextPrimaryFire(CurTime() + 0.3)
    self:SetNextSecondaryFire(CurTime() + 0.3)
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

-- E + R with a full bar: Judgment Cut End. Six seconds of build-up (you are invulnerable and
-- can't attack, but can still move), then everything around you takes 4000. Nobody is frozen.
-- The cooldown is kept on the player, so dropping and picking up a new sword doesn't reset it
function SWEP:YamatoJCECooldownLeft()
    local owner = self:GetOwner()
    if not IsValid(owner) then return 0 end
    return math.max(0, owner:GetNW2Float("ArcCW_Yamato_JCEReady", 0) - CurTime())
end

function SWEP:YamatoJudgmentCutEnd()
    if self:YamatoGetEnergy() < self.YamatoEnergy.cost.judgment_cut_end then return end
    if self:YamatoJCECooldownLeft() > 0 then return end
    self:YamatoSpend("judgment_cut_end")
    local owner = self:GetOwner()
    local now = CurTime()
    if SERVER then owner:SetNW2Float("ArcCW_Yamato_JCEReady", now + 6.2 + self.YamatoJCECooldown) end
    self.YamatoJCEUntil = now + 6.2
    self.YamatoNextCut = now + 6.2
    self.YamatoNextSkill = now + 6.2
    self:YamatoAnim("jce_start", true)
    self:SetNextPrimaryFire(now + 6.2)
    self:SetNextSecondaryFire(now + 6.2)
    if CLIENT then return end

    self:YamatoIFrames(6.2)
    util.ScreenShake(owner:GetPos(), 5, 5, 0.3, 300)
    owner:ScreenFade(SCREENFADE.IN, Color(160, 150, 255, 90), 0.3, 0)

    local fx = {}
    self.YamatoJCEProps = fx
    local function spawn(key, model, col, mat, scale, offset)
        if not IsValid(owner) then return end
        local ent = ents.Create("prop_dynamic")
        if not IsValid(ent) then return end
        ent:SetModel(model)
        ent:SetPos(owner:GetPos() + (offset or vector_origin))
        ent:SetAngles(Angle(0, 0, 0))
        ent:SetColor(col)
        if mat then ent:SetMaterial(mat) end
        ent:SetParent(owner)
        ent:SetNotSolid(true)
        ent:Spawn()
        ent:SetRenderMode(RENDERMODE_TRANSALPHA)
        if scale then ent:SetModelScale(scale[1], scale[2]) end
        fx[key] = ent
        return ent
    end
    local function color(key, a)
        local ent = fx[key]
        if IsValid(ent) then
            local c = ent:GetColor()
            ent:SetColor(Color(c.r, c.g, c.b, a))
        end
    end
    local function kill(key)
        if IsValid(fx[key]) then fx[key]:Remove() end
        fx[key] = nil
    end
    local function at(t, fn)
        timer.Simple(t, function()
            if IsValid(self) and self.YamatoJCEProps == fx and self:YamatoActive() then fn() end
        end)
    end
    local function slashfx()
        util.ScreenShake(owner:GetPos(), 50, 5, 0.3, 3000)
        owner:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 40), 0.1, 0)
    end

    spawn("shell", "models/hunter/misc/shell2x2a.mdl", Color(29, 0, 255, 200), "models/shiny", { 20, 0.2 })
    spawn("ring", "models/hunter/tubes/circle2x2.mdl", Color(160, 150, 255, 255), "models/props_combine/portalball001_sheet", { 30, 0.2 }, Vector(0, 0, -30))

    at(0.2, function()
        kill("shell")
        spawn("clouds", "models/3dsky/moving_clouds_01a.mdl", Color(0, 54, 204, 200))
    end)
    at(4.2, function()
        kill("clouds")
        spawn("fog", "models/3dsky/r_skyfog.mdl", Color(255, 255, 255, 100))
    end)
    -- The eleven cuts, 0.03s apart, while the ring fades and the fog flickers
    local ringfade = { [3] = 200, [4] = 150, [5] = 100, [6] = 50 }
    local fogfade = { [2] = 250, [9] = 200, [10] = 150, [11] = 100 }
    for i = 1, 11 do
        at(4.21 + (i - 1) * 0.03, function()
            slashfx()
            spawn("cut" .. i, "models/dmc5/cut" .. i .. ".mdl", Color(48, 103, 255, 200))
            if ringfade[i] then color("ring", ringfade[i]) end
            if i == 7 then kill("ring") end
            if fogfade[i] then color("fog", fogfade[i]) end
        end)
        at(4.61 + (i - 1) * 0.03, function() color("cut" .. i, 100) end)
    end
    at(4.53, function()
        slashfx()
        color("fog", 50)
    end)
    at(5, function() self:YamatoAnim("jce_end", false) end)
    at(6, function()
        kill("fog")
        self:YamatoAoE(owner:GetPos(), self.YamatoJCERadius, self.YamatoJCEDamage, false)
        spawn("flash", "models/hunter/misc/shell2x2a.mdl", Color(29, 0, 255, 150), "models/shiny", { 20, 1 })
    end)
    at(6.05, function() color("flash", 100) end)
    at(6.1, function() color("flash", 50) end)
    timer.Simple(6.15, function()
        if IsValid(self) and self.YamatoJCEProps == fx then self:YamatoCleanupJCE() end
    end)
end

function SWEP:YamatoCleanupJCE()
    for _, ent in pairs(self.YamatoJCEProps or {}) do
        if IsValid(ent) then ent:Remove() end
    end
    self.YamatoJCEProps = nil
end

--------------------------------------------------------------------------------------------
-- Input
--------------------------------------------------------------------------------------------

-- Directional swings plus the E-combo abilities on left click
function SWEP:Bash(melee2)
    local state = self:GetState()
    if state == ArcCW.STATE_SIGHTS or state == ArcCW.STATE_CUSTOMIZE
            or (state == ArcCW.STATE_SPRINT and not self:CanShootWhileSprint()) then
        return
    end
    if self:GetNextPrimaryFire() > CurTime() or self:GetPriorityAnim() then return end
    if CurTime() < self.YamatoJCEUntil then return end

    local owner = self:GetOwner()
    local dir = MoveDir(owner)
    if not melee2 and owner:KeyDown(IN_USE) and owner:IsOnGround() and CurTime() > self.YamatoNextSkill then
        if owner:KeyDown(IN_FORWARD) and self:YamatoRapidSlash() then return end
    end
    if melee2 and dir == "B" and owner:IsOnGround() and self:YamatoLauncher() then return end

    local set = melee2 and self.YamatoSwings.secondary or self.YamatoSwings.primary
    local swing = set[dir] or set.F
    local n = #swing.anims
    local anim = swing.anims[math.Clamp(math.floor(util.SharedRandom("ArcCW_Yamato", 1, n + 1)), 1, n)]

    self.Primary.Automatic = true
    self:YamatoAnim(anim, true)
    self:SetNextPrimaryFire(CurTime() + swing.time)
    self:SetNextSecondaryFire(CurTime() + swing.time)
    owner:DoAnimationEvent(swing.gesture)
    owner:SetAnimation(PLAYER_ATTACK1)
    if SERVER then owner:ViewPunch(Angle(1, (dir == "L" and -5) or (dir == "R" and 5) or 2, 0)) end

    self:SetTimer(swing.hit, function()
        if IsValid(self) then self:YamatoSlash(swing) end
    end)
end

-- R is handled in Think on the press, not held
function SWEP:Reload() end

function SWEP:Think()
    local owner = self:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        local now = CurTime()
        local busy = now < self.YamatoJCEUntil

        -- R abilities
        if not busy and owner:KeyPressed(IN_RELOAD) then
            if owner:KeyDown(IN_BACK) and not owner:KeyDown(IN_USE) then
                self:YamatoJudgmentCut() -- no cooldown, only the cost
            elseif now >= self.YamatoNextCut and self:GetNextPrimaryFire() <= now then
                if owner:KeyDown(IN_USE) then
                    self:YamatoJudgmentCutEnd()
                else
                    self:YamatoTeleport()
                end
            end
        end

        -- E + A / D: sideways dash, a long one on the ground and a short hop in the air.
        -- Only on a fresh press of E or A / D, so holding them while running never repeats it.
        local pressed = owner:KeyPressed(IN_USE) or owner:KeyPressed(IN_MOVELEFT) or owner:KeyPressed(IN_MOVERIGHT)
        if not busy and pressed and owner:KeyDown(IN_USE) and now > self.YamatoNextDash then
            local side = (owner:KeyDown(IN_MOVELEFT) and -1) or (owner:KeyDown(IN_MOVERIGHT) and 1) or nil
            if side and self:YamatoGetEnergy() >= self.YamatoEnergy.cost.dash then
                self:YamatoSpend("dash")
                owner:SetLocalVelocity(owner:GetRight() * side * (owner:IsOnGround() and 3700 or 700))
                self.YamatoNextDash = now + 0.5
                if SERVER then
                    owner:ViewPunch(Angle(0, 10 * side, 0))
                    self:MyEmitSound("ArcCW_DMC5_Yamato.Dash", 75, 100, 1, CHAN_STATIC)
                end
            end
        end

        if SERVER then
            -- Concentration regen
            local last = self.YamatoLastRegen or now
            self.YamatoLastRegen = now
            -- only while the sword is out: a long gap means it was put away
            if now - last > 0 and now - last < 0.5 then self:YamatoAddEnergy(self.YamatoEnergy.regen * (now - last)) end

            -- End the air hang when the combo is over or the player lands
            if self.YamatoHangUntil and (now > self.YamatoHangUntil or owner:IsOnGround()) then
                self:YamatoStopHang()
            end
        end
    end
    return BaseClass.Think(self)
end

--------------------------------------------------------------------------------------------
-- Run speed, holster, cleanup
--------------------------------------------------------------------------------------------

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
    -- Judgment Cut End can't be cancelled by switching weapons
    if CurTime() < self.YamatoJCEUntil and self:YamatoActive() then return false end
    local done = BaseClass.Holster(self, ...)
    if done ~= false then
        self:YamatoSetSpeed(false)
        self:YamatoStopHang()
    end
    return done
end

function SWEP:OnRemove(...)
    self:YamatoSetSpeed(false)
    self:YamatoStopHang()
    if SERVER then self:YamatoCleanupJCE() end
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

--------------------------------------------------------------------------------------------
-- Concentration bar
--------------------------------------------------------------------------------------------

if CLIENT then
    local BAR_W, BAR_H, SEGMENTS = 300, 12, 10

    function SWEP:DrawHUD()
        if BaseClass.DrawHUD then BaseClass.DrawHUD(self) end

        local max = self.YamatoEnergy.max
        local energy = self:YamatoGetEnergy()
        local frac = math.Clamp(energy / max, 0, 1)
        local x = math.floor(ScrW() * 0.5 - BAR_W * 0.5)
        local y = math.floor(ScrH() * 0.86)
        local full = energy >= self.YamatoEnergy.cost.judgment_cut_end
        local cd = self:YamatoJCECooldownLeft()
        local pulse = full and (0.75 + 0.25 * math.sin(CurTime() * 6)) or 1

        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(x - 3, y - 3, BAR_W + 6, BAR_H + 6)
        surface.SetDrawColor(40, 30, 80, 200)
        surface.DrawRect(x, y, BAR_W, BAR_H)
        surface.SetDrawColor(110 * pulse, 90 * pulse, 255 * pulse, 235)
        surface.DrawRect(x, y, math.floor(BAR_W * frac), BAR_H)
        surface.SetDrawColor(180, 170, 255, 60)
        surface.DrawRect(x, y, math.floor(BAR_W * frac), math.floor(BAR_H * 0.35))

        surface.SetDrawColor(0, 0, 0, 200)
        for i = 1, SEGMENTS - 1 do
            surface.DrawRect(x + math.floor(BAR_W * i / SEGMENTS), y, 2, BAR_H)
        end

        local col = Color(200, 190, 255, 255)
        draw.SimpleText("CONCENTRATION", "DermaDefaultBold", x, y - 5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(math.floor(energy), "DermaDefaultBold", x + BAR_W, y - 5, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        if cd > 0 then
            draw.SimpleText("JUDGMENT CUT END  " .. math.ceil(cd) .. "s", "DermaDefaultBold", ScrW() * 0.5, y + BAR_H + 6,
                Color(150, 140, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        elseif full then
            draw.SimpleText("E + R   JUDGMENT CUT END", "DermaDefaultBold", ScrW() * 0.5, y + BAR_H + 6,
                Color(220, 210, 255, 255 * pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end
end
