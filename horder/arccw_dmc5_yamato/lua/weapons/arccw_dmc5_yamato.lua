if not ArcCWInstalled then return end

-- Vergil's Yamato (DMC5), remade on ArcCW's melee base from the TFA version.
-- Kept: the model, the slash animations and sounds. Removed: every special ability of the
-- TFA weapon (R teleport, E+R Judgment Cut End, S+R Judgment Cut, E+strafe dash, E+W+click
-- rapid slash, E+S+click launcher, the 800 run speed on deploy), so it is a plain sword.

sound.Add({ name = "ArcCW_DMC5_Yamato.Slash", channel = CHAN_WEAPON, level = 75, sound = "weapons/yamato_slash.wav" })
sound.Add({ name = "ArcCW_DMC5_Yamato.Slash2", channel = CHAN_WEAPON, level = 75, sound = "weapons/yamato_slash2.wav" })

SWEP.Base = "arccw_base_melee"
SWEP.Spawnable = true
SWEP.Category = "ArcCW - Melee"
SWEP.AdminOnly = false

SWEP.PrintName = "Yamato"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Vergil's katana. A sword that cuts through anything."
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

-- Left click: quick slash. Right click: heavy slash.
SWEP.MeleeDamage = 125
SWEP.Melee2Damage = 260

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeRange = 80
SWEP.MeleeAttackTime = 0.12
SWEP.MeleeTime = 0.6
SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE

SWEP.Melee2 = true
SWEP.Melee2Range = 90
SWEP.Melee2AttackTime = 0.15
SWEP.Melee2Time = 0.95
SWEP.Melee2Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2

-- Swing sounds come from the animations' sound tables; hit sounds are ArcCW's defaults
SWEP.MeleeSwingSound = nil
SWEP.MeleeMissSound = nil

SWEP.Firemodes = {
    { Mode = 1, PrintName = "MELEE" },
}

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "melee"

SWEP.AttachmentElements = {}
SWEP.Attachments = {}

-- Only the plain attacks of the model are used; the ability animations (rd, cut, jc, slash3)
-- are left out with the abilities.
SWEP.Animations = {
    ["idle"] = { Source = "idle" },
    ["draw"] = { Source = "draw" },
    ["ready"] = { Source = "draw" },
    ["bash"] = {
        Source = "slash",
        SoundTable = { { s = "ArcCW_DMC5_Yamato.Slash", t = 0 } },
    },
    ["bash2"] = {
        Source = "slash2",
        SoundTable = { { s = "ArcCW_DMC5_Yamato.Slash2", t = 0 } },
    },
}

SWEP.IronSightStruct = false

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 0, 0)
SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(0, 0, 0)

SWEP.HolsterPos = Vector(0, -3, -2)
SWEP.HolsterAng = Angle(-10, 0, 0)

-- The model plays its swing sounds through animation events, which only the swinging player
-- hears. Those are muted here and the sound tables above play them for everyone instead.
function SWEP:FireAnimationEvent(pos, ang, event, options)
    if event == 5004 or event == 5001 or event == 5011 or event == 5021 or event == 5031 then return true end
end

-- ArcCW runs melee swings on the server only, where a sound emitted inside the predicted
-- attack skips the swinging player. Emitting one tick later reaches everyone, them included.
function SWEP:MyEmitSound(snd, level, pitch, vol, chan)
    if CLIENT or not snd then return end
    if istable(snd) then snd = snd[math.random(#snd)] end
    if not snd or snd == "" then return end
    timer.Simple(0, function()
        if IsValid(self) then
            self:EmitSound(snd, level or 75, pitch or 100, vol or 1, chan or CHAN_AUTO)
        end
    end)
end
