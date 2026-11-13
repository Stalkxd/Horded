if not ArcCWInstalled then return end

SWEP.Base = "arccw_ww_base"
local BaseClass = HORDE_WW.Base(SWEP.Base)
SWEP.Spawnable = true
SWEP.PrintName = "Scavenger"
SWEP.Trivia_Desc = "Scoped rifle that fires sticky explosive bolts. They detonate a moment after landing."
SWEP.Trivia_Calibre = "Explosive bolt"
SWEP.Trivia_Mechanism = "Bolt action"
SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/black_ops_1/scavenger/v_scavenger.mdl"
SWEP.WorldModel = "models/weapons/black_ops_1/scavenger/w_scavenger.mdl"
SWEP.MirrorVMWM = false
-- The world model is built on the player's hand bone, so bone merge it
-- instead of placing it by an offset, which held it sideways.
SWEP.WorldModelOffset = false
SWEP.ViewModelFOV = 65

SWEP.Damage = 1500
SWEP.DamageMin = 1500
SWEP.DamageType = DMG_BLAST
SWEP.ShootEntity = "obj_scavenger_proj"
SWEP.MuzzleVelocity = 3600
SWEP.WW_AimAtCrosshair = true

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Ammo = "slam"
SWEP.Delay = 60 / 35

SWEP.Recoil = 2
SWEP.RecoilSide = 0.5
SWEP.AccuracyMOA = 1
SWEP.HipDispersion = 600
SWEP.MoveDispersion = 300

SWEP.ShootSound = "Weapon_Scavenger.Shot"
SWEP.WW_MuzzleParticle = nil

SWEP.SpeedMult = 0.9
SWEP.SightedSpeedMult = 0.6
SWEP.SightTime = 0.3

SWEP.IronSightStruct = {
    Pos = Vector(-3, -7.81, 1),
    Ang = Angle(0, 0, 0),
    Magnification = 3.5, -- 6x was far too close for zombies at shotgun range
    CrosshairInSights = false,
}

SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.Attachments = HORDE_WW.Slots("tag_weapon")

SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["ready"] = { Source = "first_raise" },
    ["draw"] = { Source = "pullout" },
    ["holster"] = { Source = "putaway", Time = 0.6 },
    ["fire"] = { Source = "fire", Time = 60 / 35 },
    ["fire_empty"] = { Source = "fire_last" },
    ["reload"] = {
        Source = "reload",
        MinProgress = 2.1,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
    },
    ["enter_sprint"] = { Source = "sprint_in" },
    ["idle_sprint"] = { Source = "sprint_loop" },
    ["exit_sprint"] = { Source = "sprint_out" },
}

function SWEP:Hook_PostFireBullets()
    if IsFirstTimePredicted() then
        self:EmitSound("Weapon_Scavenger.Ring")
    end
end

if CLIENT then
    local scope_tex = surface.GetTextureID("models/weapons/black_ops_1/scavenger/scope_overlay_scavenger2")

    local function Scoped(self)
        return self:GetState() == ArcCW.STATE_SIGHTS and self:GetSightDelta() < 0.15
    end

    function SWEP:PreDrawViewModel(vm, ...)
        if Scoped(self) then return true end
        return BaseClass.PreDrawViewModel(self, vm, ...)
    end

    function SWEP:WW_DrawOverlay()
        if not Scoped(self) then return end
        local w, h = ScrW(), ScrH()
        local size = h
        local x = (w - size) * 0.5
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, x + 1, h)
        surface.DrawRect(x + size - 1, 0, x + 1, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetTexture(scope_tex)
        surface.DrawTexturedRect(x, 0, size, size)
        -- A clear center dot where the bolt will go
        local cx, cy = math.floor(w * 0.5), math.floor(h * 0.5)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(cx - 3, cy - 3, 6, 6)
        surface.SetDrawColor(255, 60, 30, 255)
        surface.DrawRect(cx - 2, cy - 2, 4, 4)
    end
end
