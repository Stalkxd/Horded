-- Shared code for the Horde wonder weapons. Both bases (arccw_ww_base and arccw_ww_base_melee)
-- call HORDE_WW.Mixin(SWEP) so guns and swords get the same behaviour on top of their ArcCW base.

HORDE_WW = HORDE_WW or {}

-- Model events that draw the HL2 muzzle flash. Everything else (particles, sounds) is let through,
-- because the original models use particle events for their glow and impact effects.
local MUZZLE_EVENTS = {
    [21] = true, [22] = true, [5001] = true, [5003] = true, [5011] = true,
    [5021] = true, [5031] = true, [6001] = true,
}

-- Perk and charm slots. The perk slot takes CS:GO and Modern Warfare perks (sh_arccw_slots widens
-- "go_perk" to "perk"), and "charm" is the slot name both packs use for charms.
-- charm_only leaves out the perk slot (the swords only take a charm).
function HORDE_WW.Slots(bone, offset, extra, charm_only)
    local slots = {}
    for _, slot in ipairs(extra or {}) do
        slots[#slots + 1] = slot
    end
    if not charm_only then
        slots[#slots + 1] = {
            PrintName = "Perk",
            Slot = {"go_perk", "perk"},
        }
    end
    slots[#slots + 1] = {
        PrintName = "Charm",
        Slot = "charm",
        FreeSlot = true,
        Bone = bone or "tag_weapon",
        Offset = offset or {
            vpos = Vector(2, -1, 1),
            vang = Angle(0, 0, 0),
            wpos = Vector(8, 1.5, -4),
            wang = Angle(-10, 0, 180),
        },
    }
    return slots
end

-- Attaches a particle to the viewmodel in first person, or to the world model otherwise.
-- Runs fn with the shooter included in server sounds and effects. Inside predicted
-- code (a weapon's attack or think) the engine leaves the shooter out, expecting
-- their own client to play them, so server-only sounds were silent for them on a
-- dedicated server while everyone else heard them.
function HORDE_WW.ToEveryone(fn, ...)
    local ply = SERVER and GetPredictionPlayer() or NULL
    if not IsValid(ply) then return fn(...) end
    SuppressHostEvents(NULL)
    local a, b = fn(...)
    SuppressHostEvents(ply)
    return a, b
end

local function emit(ent, snd, ...) ent:EmitSound(snd, ...) end
local function stop(ent, snd) ent:StopSound(snd) end

function HORDE_WW.ServerSound(ent, snd, ...)
    if CLIENT then return end
    HORDE_WW.ToEveryone(emit, ent, snd, ...)
end

function HORDE_WW.StopServerSound(ent, snd)
    if CLIENT then return end
    HORDE_WW.ToEveryone(stop, ent, snd)
end

function HORDE_WW.MuzzleParticle(wep, name, att)
    if not name or name == "" then return end
    local owner = wep:GetOwner()
    if not IsValid(owner) then return end
    local target = wep
    if CLIENT and owner == LocalPlayer() and not owner:ShouldDrawLocalPlayer() then
        target = owner:GetViewModel()
    end
    if not IsValid(target) then return end
    ParticleEffectAttach(name, PATTACH_POINT_FOLLOW, target, att or 1)
end

local function IsHostile(ply, ent)
    if ent == ply or not IsValid(ent) then return false end
    if not (ent:IsNPC() or ent:IsNextBot()) or ent:Health() <= 0 then return false end
    -- Horde minions belong to a player
    if ent:GetNWEntity("HordeOwner"):IsPlayer() then return false end
    return true
end
HORDE_WW.IsHostile = IsHostile

-- Area damage for slams and blasts: enemies in radius that pos can see. Server only.
function HORDE_WW.AreaDamage(wep, pos, radius, damage, dmgtype, onhit)
    if CLIENT then return end
    local ply = wep:GetOwner()
    local tr = { start = pos, filter = { wep, ply }, mask = MASK_SHOT_HULL }
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if not IsHostile(ply, ent) then continue end
        tr.endpos = ent:WorldSpaceCenter()
        if util.TraceLine(tr).HitWorld then continue end

        local dmg = DamageInfo()
        dmg:SetAttacker(ply)
        dmg:SetInflictor(wep)
        dmg:SetDamage(damage)
        dmg:SetDamageType(dmgtype)
        dmg:SetDamagePosition(tr.endpos)
        local dir = tr.endpos - pos
        dir:Normalize()
        dmg:SetDamageForce(ent:GetUp() * 6000 + dir * 10000)
        ent:TakeDamageInfo(dmg)
        if onhit then onhit(ent) end
    end
    util.ScreenShake(pos, 7, 255, 1, radius * 1.5)
end

function HORDE_WW.Debuff(ent, status, amount, attacker)
    if SERVER and HORDE and status and IsValid(ent) and ent.Horde_AddDebuffBuildup then
        ent:Horde_AddDebuffBuildup(status, amount, attacker)
    end
end

-- Base class lookup that walks the registered weapon tables when a function is called, instead of
-- trusting baseclass.Get at load time. The sword base comes from the gamemode, which loads after
-- this addon, so its baseclass table was still empty when the swords were defined.
local function FindBaseFunc(base, key)
    local seen = 0
    while base and seen < 16 do
        -- A missing base (the Horde melee base outside Horde) falls back to plain ArcCW
        local stored = weapons.GetStored(base) or weapons.GetStored("arccw_base")
        if not stored then return end
        local value = rawget(stored, key)
        if value ~= nil then return value end
        base = rawget(stored, "Base")
        seen = seen + 1
    end
end

function HORDE_WW.Base(base)
    return setmetatable({}, {
        __index = function(_, key) return FindBaseFunc(base, key) end,
    })
end

function HORDE_WW.Mixin(SWEP)
    local BaseClass = HORDE_WW.Base(SWEP.Base)

    SWEP.IsHordeWonderWeapon = true
    SWEP.Category = "ArcCW - Horde Wonder Weapons"
    SWEP.NotForNPCs = true
    SWEP.MuzzleEffect = false
    SWEP.WW_LoopSounds = {}

    function SWEP:SetupDataTables()
        BaseClass.SetupDataTables(self)
        -- Slots above the ones ArcCW uses, for weapon specific state
        self:NetworkVar("Int", 24, "WWState")
        self:NetworkVar("Bool", 24, "WWFlag")
        self:NetworkVar("Float", 24, "WWCharge")
        self:NetworkVar("Float", 25, "WWStateEnd")
        self:NetworkVar("Float", 26, "WWRegen")
        self:NetworkVar("Vector", 24, "WWVec")
        self:NetworkVar("Float", 27, "WWLoadTime")
        self:NetworkVar("Int", 25, "WWLoadMask")
    end

    -- ArcCW empties Clip2 when a weapon is created, so the second gun starts loaded here
    function SWEP:Initialize(...)
        local ret = BaseClass.Initialize(self, ...)
        if self.WW_Akimbo then self:SetClip2(self:WW_MaxClip2()) end
        return ret
    end

    -- The second gun's clip size lives in its own field: ArcCW rewrites Secondary.ClipSize to -1
    -- whenever attachments change (it keeps that slot for underbarrel launchers).
    function SWEP:WW_MaxClip2()
        return self.WW_Clip2Size or 0
    end

    function SWEP:FireAnimationEvent(pos, ang, event, options)
        if MUZZLE_EVENTS[event] then return true end
    end

    function SWEP:DoEffects(...)
        if self.WW_ArcCWMuzzle then return BaseClass.DoEffects(self, ...) end
        if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
        HORDE_WW.MuzzleParticle(self, self:WW_GetMuzzleParticle(), self:WW_GetMuzzleAttachment())
    end

    function SWEP:WW_GetMuzzleParticle()
        return self.WW_MuzzleParticle
    end

    function SWEP:WW_GetMuzzleAttachment()
        return self.WW_MuzzleAttachment or 1
    end

    function SWEP:WW_ProjectileSrc()
        return self:GetOwner():GetShootPos()
    end

    -- ArcCW's FireRocket forces the debris collision group, which these projectiles do not expect,
    -- and does not hand over the fields the pack entities read.
    function SWEP:FireRocket(class, vel, ang)
        if CLIENT then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local ent = ents.Create(class)
        if not IsValid(ent) then return end

        ang = ang or (owner:EyeAngles() + self:GetFreeAimOffset())
        local src = self:WW_ProjectileSrc()

        ent:SetPos(src)
        ent:SetAngles(ang)
        ent:SetOwner(owner)
        if self.ShootEntityModel then ent:SetModel(self.ShootEntityModel) end

        local dmg = self:GetBuff("Damage")
        ent.Damage = dmg
        ent.mydamage = dmg
        ent.damage = dmg
        ent.Inflictor = self
        ent.WeaponClass = self:GetClass()
        if ent.SetUpgraded then ent:SetUpgraded(false) end

        self:WW_PreSpawnProjectile(ent)
        -- Projectiles start their own sounds as they spawn
        HORDE_WW.ToEveryone(function()
            ent:Spawn()
            ent:Activate()
        end)
        ent:SetOwner(owner)

        local dir = ang:Forward()
        if self.WW_AimAtCrosshair then
            dir = owner:GetEyeTrace().HitPos - src
            dir:Normalize()
        end
        dir:Mul(vel)

        ent:SetVelocity(dir)
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:SetVelocity(dir)
        end

        ent.ArcCWProjectile = true
        self:WW_PostSpawnProjectile(ent, dir)
        self:GetBuff_Hook("Hook_PostFireRocket", ent)
        return ent
    end

    function SWEP:WW_PreSpawnProjectile(ent) end
    function SWEP:WW_PostSpawnProjectile(ent, dir) end

    function SWEP:Hook_ShouldNotSight()
        if self.WW_NoSights then return true end
    end

    function SWEP:Hook_PreReload()
        if self.WW_NoReload then return true end
    end

    -- Charge for specialist weapons (swords, gauntlet, DG-4, Death Machine) fills back up over time
    function SWEP:WW_ThinkRegen()
        local rate = self.WW_Regen
        if not rate or rate <= 0 then return end
        if self:WW_RegenPaused() then return end
        local max = self:GetMaxClip1()
        if self:Clip1() >= max then
            self:SetWWRegen(0)
            return
        end
        if self.WW_RegenDelay and self:GetNextPrimaryFire() + self.WW_RegenDelay > CurTime() then return end
        local acc = self:GetWWRegen() + rate * FrameTime()
        if acc >= 1 then
            local whole = math.floor(acc)
            self:SetClip1(math.min(max, self:Clip1() + whole))
            acc = acc - whole
        end
        self:SetWWRegen(acc)
    end

    function SWEP:WW_RegenPaused() return false end

    function SWEP:WW_Think() end

    function SWEP:Think()
        BaseClass.Think(self)
        local owner = self:GetOwner()
        if not IsValid(owner) or not owner:IsPlayer() then return end
        if SERVER then self:WW_ThinkRegen() end
        local load = self:GetWWLoadTime()
        if load > 0 and CurTime() >= load then self:WW_AkimboLoad() end
        self:WW_Think()
    end

    -- For sounds only the server starts, like loops, so the shooter hears them too
    function SWEP:WW_ServerSound(snd, ...)
        HORDE_WW.ServerSound(self, snd, ...)
    end

    function SWEP:WW_StopServerSound(snd)
        HORDE_WW.StopServerSound(self, snd)
    end

    function SWEP:WW_StopLoops()
        for _, snd in ipairs(self.WW_LoopSounds) do
            if SERVER then self:WW_StopServerSound(snd) else self:StopSound(snd) end
        end
    end

    function SWEP:Hook_OnHolster()
        self:SetWWLoadTime(0)
        self:WW_StopLoops()
        self:WW_OnHolster()
    end

    function SWEP:WW_OnHolster() end

    function SWEP:OnRemove()
        self:WW_StopLoops()
        if BaseClass.OnRemove then return BaseClass.OnRemove(self) end
    end

    function SWEP:OnDrop()
        self:WW_StopLoops()
        self:WW_OnHolster()
        if BaseClass.OnDrop then return BaseClass.OnDrop(self) end
    end

    -- Same checks ArcCW makes before a primary shot, for attacks bound to the right mouse button
    function SWEP:WW_CanAltFire()
        if IsValid(self:GetHolster_Entity()) or self:GetHolster_Time() > 0 then return false end
        local state = self:GetState()
        if state == ArcCW.STATE_CUSTOMIZE or state == ArcCW.STATE_DISABLE then return false end
        if self:GetPriorityAnim() then return false end
        if self:GetNextSecondaryFire() > CurTime() then return false end
        if self:GetNWState() == ArcCW.STATE_SPRINT and not self:CanShootWhileSprint() then return false end
        return true
    end

    -- Fires the second gun of a dual wield weapon from Clip2.
    -- data: anim, sound, particle, attachment, entity, velocity, delay, gesture
    function SWEP:WW_ShootAlt(data)
        if not self:WW_CanAltFire() then return end
        if self:Clip2() <= 0 then
            self:MyEmitSound(self.ShootDrySound or "weapons/arccw/dryfire.wav", 75, 100, 1, CHAN_ITEM)
            self:SetNextSecondaryFire(CurTime() + 0.25)
            return
        end

        self:SetNextSecondaryFire(CurTime() + (data.delay or self:GetFiringDelay()))
        self:SetClip2(self:Clip2() - 1)

        self.WW_FiringAlt = true
        if SERVER and data.entity then
            self:FireRocket(data.entity, data.velocity or self:GetBuff("MuzzleVelocity"))
        end
        self.WW_FiringAlt = false

        if data.anim then self:PlayAnimation(data.anim, 1, true, 0, false) end
        if data.sound and IsFirstTimePredicted() then self:EmitSound(data.sound) end
        if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
        HORDE_WW.MuzzleParticle(self, data.particle, data.attachment)
        self:GetOwner():DoAnimationEvent(data.gesture or self.AnimShoot)
        self:DoRecoil()
    end

    -- Second gun of the dual wield weapons: fires from Clip2 and shares the primary reserve.
    -- Which guns to fill (WWLoadMask: 1 left, 2 right) and when (WWLoadTime) are networked and
    -- applied in Think, so the load happens on the server even if prediction drops a timer.
    local LOAD_LEFT, LOAD_RIGHT = 1, 2

    function SWEP:WW_AkimboReload()
        if self:GetReloading() or self:GetPriorityAnim() or self:GetWWLoadTime() > 0 then return end
        if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
        if self:Ammo1() <= 0 and not self:HasInfiniteAmmo() then return end

        local need_l = self:Clip1() < self:GetMaxClip1()
        local need_r = self:Clip2() < self:WW_MaxClip2()
        if not need_l and not need_r then return end

        local anim = self:WW_AkimboReloadAnim(need_l, need_r)
        local mult = self:GetBuff_Mult("Mult_ReloadTime")
        local t = self:GetAnimKeyTime(anim) * mult
        self:PlayAnimation(anim, mult, true, 0, false, nil, true)
        self:SetReloading(CurTime() + t)
        self:SetNextPrimaryFire(CurTime() + t)
        self:SetNextSecondaryFire(CurTime() + t)
        self:ExitSights()
        self:GetOwner():DoAnimationEvent(ACT_HL2MP_GESTURE_RELOAD_DUEL)

        local load_at = (self.Animations[anim].MagUpTime or t * 0.75 / mult) * mult
        self:SetWWLoadMask((need_l and LOAD_LEFT or 0) + (need_r and LOAD_RIGHT or 0))
        self:SetWWLoadTime(CurTime() + load_at)
        return true
    end

    function SWEP:WW_AkimboReloadAnim(need_l, need_r)
        local anim = (need_l and need_r and "reload") or (need_l and "reload_left") or "reload_right"
        if not self.Animations[anim] then anim = "reload" end
        return anim
    end

    function SWEP:WW_AkimboLoad()
        local mask = self:GetWWLoadMask()
        self:SetWWLoadTime(0)
        self:SetWWLoadMask(0)
        if CLIENT then return end
        local ply = self:GetOwner()
        local ammo_type = self:GetPrimaryAmmoType()
        local infinite = self:HasInfiniteAmmo()
        local left = infinite and math.huge or ply:GetAmmoCount(ammo_type)
        if bit.band(mask, LOAD_LEFT) ~= 0 then
            local take = math.min(self:GetMaxClip1() - self:Clip1(), left)
            self:SetClip1(self:Clip1() + take)
            left = left - take
        end
        if bit.band(mask, LOAD_RIGHT) ~= 0 then
            local take = math.min(self:WW_MaxClip2() - self:Clip2(), left)
            self:SetClip2(self:Clip2() + take)
            left = left - take
        end
        if not infinite then ply:SetAmmo(left, ammo_type) end
    end

    if CLIENT then
        local col_text = Color(255, 255, 255, 230)
        local col_shadow = Color(0, 0, 0, 200)

        function SWEP:DrawHUD()
            self:WW_DrawOverlay()
            if BaseClass.DrawHUD then BaseClass.DrawHUD(self) end
            local text = self:WW_HUDText()
            if not text then return end
            local x, y = ScrW() * 0.5, ScrH() * 0.5 + 60
            draw.SimpleText(text, "DermaDefaultBold", x + 1, y + 1, col_shadow, TEXT_ALIGN_CENTER)
            draw.SimpleText(text, "DermaDefaultBold", x, y, col_text, TEXT_ALIGN_CENTER)
        end

        function SWEP:WW_DrawOverlay() end

        function SWEP:WW_HUDText() end
    end
end
