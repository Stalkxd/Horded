--Blundergat
sound.Add({
	name = 			"Weapon_Blundergat.Shoot",
	channel = 		CHAN_USER_BASE+10,
	volume = 		1.0,
	sound = 		"weapons/blundergat/fire.ogg"
})
sound.Add(
{
    name = "Weapon_Blundergat.BarrelOpen",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/blundergat/barreldown.ogg"
})
sound.Add(
{
    name = "Weapon_Blundergat.BarrelClose",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/blundergat/barrelup.ogg"
})
sound.Add(
{
    name = "Weapon_Blundergat.LoadShells",
    channel = CHAN_ITEM,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/blundergat/loadshell.ogg"
})
sound.Add(
{
    name = "Weapon_Blundergat.Hammer",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/blundergat/hammer.ogg"
})

--Jet gun
sound.Add(
{
    name = "Weapon_Jetgun.draw",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/fly_minigun_on.ogg"
})

sound.Add(
{
    name = "Weapon_Jetgun.Loop_3rdperson",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 100,
    sound = "<weapons/jetgun/jetgun_loop_3rd.wav"
})
sound.Add(
{
    name = "Weapon_Jetgun.Loop_1stperson",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 100,
    sound = "weapons/jetgun/jetgun_loop_1st.wav"
})

--Origins staffs
sound.Add(
{
    name = "Weapon_OriginStaff_Fire.Raise",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/originstaffs/1straise_fire.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff_Fire.ChargedLoop",
    channel = CHAN_ITEM,
    volume = 0.9,
    soundlevel = 60,
    sound = "weapons/originstaffs/fire/charge/loop.wav"
})
sound.Add(
{
    name = "Weapon_OriginStaff_Lightning.Raise",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/originstaffs/1straise_lightning.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff_Lightning.ChargedLoop",
    channel = CHAN_ITEM,
    volume = 0.9,
    soundlevel = 60,
    sound = "weapons/originstaffs/lightning/charge/lghtng_charge_loop.wav"
})
sound.Add(
{
    name = "Weapon_OriginStaff_Water.Raise",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/originstaffs/1straise_water.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff_Water.ChargedLoop",
    channel = CHAN_ITEM,
    volume = 0.9,
    soundlevel = 60,
    sound = "weapons/originstaffs/ice/charge/icestaff_charge_lp_01.wav"
})
sound.Add(
{
    name = "Weapon_OriginStaff_Air.Raise",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/originstaffs/1straise_air.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff_Air.ChargedLoop",
    channel = CHAN_ITEM,
    volume = 0.9,
    soundlevel = 60,
    sound = "weapons/originstaffs/air/charge/airstaff_charge_loop.wav"
})
sound.Add(
{
    name = "Weapon_OriginStaff.UpgradedRaise",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/originstaffs/1straise/upgraded_shing.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff.Startreload",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/originstaffs/reload_clipout.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff.Reloading",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/originstaffs/reload_clipin.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff.Finishreload",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/originstaffs/reload_ready.ogg"
})
sound.Add(
{
    name = "Weapon_OriginStaff.Melee",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 60,
    sound = {"weapons/originstaffs/melee/upgraded/staff_melee_upgrd_00.ogg", "weapons/originstaffs/melee/upgraded/staff_melee_upgrd_01.ogg"}
})

--Ray gun
sound.Add(
{
    name = "Weapon_Raygun.Open",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 60,
    sound = "weapons/raygun/wpn_ray_reload_open.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun.Magout",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 60,
    sound = "weapons/raygun/wpn_ray_reload_battery_out.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun.Magin",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 60,
    sound = "weapons/raygun/wpn_ray_reload_battery.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun.Close",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 60,
    sound = "weapons/raygun/wpn_ray_reload_close.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun.Dial",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 50,
    sound = "weapons/raygun/raise/hit.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun.Deny",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 50,
    sound = "weapons/raygun/raise/deny.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun.Switch",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 50,
    sound = "weapons/raygun/raise/activate.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun.GuitarRiff",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 100,
    sound = "weapons/raygun/mus_raygun_stinger.wav"
})

--Ray gun MK 2
sound.Add({
	name = "Weapon_Raygun2.Shoot",
	channel = CHAN_WEAPON,
	volume = 1.0,
    soundlevel = 80,
	sound = {"weapons/raygun_mk2/shot/shot1.ogg", "weapons/raygun_mk2/shot/shot2.ogg", "weapons/raygun_mk2/shot/shot3.ogg"}
})
sound.Add({
	name = "Weapon_Raygun2.Impact",
	channel = CHAN_BODY,
	volume = 1.0,
    soundlevel = 70,
	sound = {"weapons/raygun_mk2/imp/imp_1.ogg", "weapons/raygun_mk2/imp/imp_2.ogg", "weapons/raygun_mk2/imp/imp_3.ogg"}
})

sound.Add(
{
    name = "Weapon_Raygun2.Raise",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/raygun_mk2/reload/raise.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun2.Switch",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/raygun_mk2/reload/switch.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun2.Magin",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/raygun_mk2/reload/putin.ogg"
})
sound.Add(
{
    name = "Weapon_Raygun2.Magout",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/raygun_mk2/reload/pullout.ogg"
})

--Scavenger

--TFA.AddFireSound("Weapon_Scavenger.Shot", {"weapons/ubersniper/shot_st.ogg"}, true, ")")
--TFA.AddFireSound("Weapon_Scavenger.Ring", {"weapons/ubersniper/ringout.ogg"}, false	, ")")

sound.Add(
{
    name = "Weapon_Scavenger.MagOut",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/mag_out.ogg"
})
sound.Add(
{
    name = "Weapon_Scavenger.MagIn",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/mag_in.ogg"
})
--[[sound.Add(
{
    name = "Weapon_Scavenger.BeepRechamber",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/beep_rechamber.ogg"
})
sound.Add(
{
    name = "Weapon_Scavenger.BeepReload",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/beep_reload.ogg"
})]]
sound.Add(
{
    name = "Weapon_Scavenger.BoltUp",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/bolt_up.ogg"
})
sound.Add(
{
    name = "Weapon_Scavenger.BoltBack",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/bolt_back.ogg"
})
sound.Add(
{
    name = "Weapon_Scavenger.BoltForward",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/bolt_forward.ogg"
})
sound.Add(
{
    name = "Weapon_Scavenger.BoltDown",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/bolt_down.ogg"
})
--[[sound.Add(
{
    name = "Weapon_Scavenger.Futz",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/ubersniper/futz.ogg"
})]]
sound.Add(
{
    name = "Weapon_Scavenger.Shot",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 90,
    sound = ")weapons/ubersniper/shot_st.ogg"
})
sound.Add(
{
    name = "Weapon_Scavenger.Ring",
    channel = CHAN_USER_BASE+14,
    volume = 1.0,
    soundlevel = 120,
    sound = ")weapons/ubersniper/ringout.ogg"
})

--Shrink ray
sound.Add(
{
    name = "Weapon_Shrinkray.Idle",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/shrinkray/reload/wpn_shrink_fins_fixed.wav"
})
sound.Add(
{
    name = "Weapon_Shrinkray.Mag_in",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/shrinkray/reload/wpn_shrink_mag_in.ogg"
})
sound.Add(
{
    name = "Weapon_Shrinkray.Mag_out",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/shrinkray/reload/wpn_shrink_mag_out.ogg"
})
sound.Add(
{
    name = "Weapon_Shrinkray.Futz",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/shrinkray/reload/wpn_shrink_futz.ogg"
})
--Playing this one from Lua instead of the model to avoid cutoff. To change it back, copy the sound from Weapon_Shrinkray.Mag_in.
/*
sound.Add(
{
    name = "Weapon_Shrink.Raise",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
	sound = ""
})
*/
sound.Add({
	name = 			"Weapon_Shrink.Shoot",
	channel = 		CHAN_USER_BASE+10,
	volume = 		0.6,
	sound = 		"weapons/shrinkray/plr/wpn_shrink_plr_fire.ogg"
})
sound.Add({
	name = 			"Weapon_Shrink.Flux",
	channel = 		CHAN_ITEM,
	volume = 		0.5,
	sound = 		"weapons/shrinkray/plr/wpn_shrink_plr_flux.ogg"
})
sound.Add({
	name = 			"Weapon_Shrink.FluxPap",
	channel = 		CHAN_ITEM,
	volume = 		0.5,
	sound = 		"weapons/shrinkray/plr/wpn_shrink_plr_flux_upgr.ogg"
})

--Sliquifier
sound.Add(
{
    name = "Weapon_Slipgun.Insert",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 60,
    sound = "weapons/slipgun/reload_insert.ogg"
})
sound.Add(
{
    name = "Weapon_Slipgun.Eject",
    channel = CHAN_WEAPON,
    volume = 0.6,
    soundlevel = 60,
    sound = "weapons/slipgun/reload_eject.ogg"
})
sound.Add(
{
    name = "Weapon_Slipgun.Ready",
    channel = CHAN_WEAPON,
    volume = 0.6,
    soundlevel = 60,
    sound = "weapons/slipgun/reload_plunge.ogg"
})
sound.Add(
{
    name = "Weapon_Slipgun.Raise",
    channel = CHAN_WEAPON,
    volume = 0.6,
    soundlevel = 60,
    sound = "weapons/slipgun/slipgun_raise.ogg"
})

--Paralyzer
sound.Add(
{
    name = "Weapon_Slowgun.Fire",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 80,
    sound = "weapons/slowgun/v3/fire.ogg"
})
sound.Add(
{
    name = "Weapon_Slowgun.Fire.Loop",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 80,
    sound = "weapons/slowgun/v3/loop.wav"
})

sound.Add(
{
    name = "Weapon_Slowgun.Fire.Stop",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 70,
    sound = "weapons/slowgun/v3/stop.ogg"
})
sound.Add(
{
    name = "Weapon_Slowgun.Idle",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/slowgun/reload/loopv2.wav"
})
sound.Add(
{
    name = "Weapon_Slowgun.Ready",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/slowgun/reload/pullout_696.ogg"
})
sound.Add(
{
    name = "Weapon_Slowgun.Lower",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/slowgun/reload/putaway_885.ogg"
})

--Thundergun
sound.Add(
{
    name = "Weapon_Thundergun.Eject",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/thundergun/fly_thundergun_eject.ogg"
})
sound.Add(
{
    name = "Weapon_Thundergun.Lock",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/thundergun/fly_thundergun_cell_slide_lock.ogg"
})
sound.Add(
{
    name = "Weapon_Thundergun.Replace",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/thundergun/fly_thundergun_cell_replace.ogg"
})

sound.Add(
{
    name = "Weapon_Thundergun.SwitchOn",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/thundergun/fly_thundergun_cell_on.ogg"
})
sound.Add({
	name = "Weapon_Thundergun.Shoot",
	channel = CHAN_USER_BASE+10,
	volume = 1.0,
	sound = "weapons/thundergun/fly_thundergun_shoot.ogg"
})

--V-R11
sound.Add(
{
    name = "Weapon_VR11.ArmClose",
    channel = CHAN_ITEM,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/humangun/foley/hg_arm_close.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.ArmOpen",
    channel = CHAN_USER_BASE+10,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/humangun/foley/hg_arm_open.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.BatteryClose",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/humangun/foley/hg_battery_close.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.BatteryEject",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/humangun/foley/hg_battery_eject.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.BatteryInsert",
    channel = CHAN_ITEM,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/humangun/foley/hg_battery_insert.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.BatteryOpen",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/humangun/foley/hg_battery_open.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.Spinner",
    channel = CHAN_WEAPON,
    volume = 0.5,
    soundlevel = 60,
    sound = "weapons/humangun/foley/hg_spinner.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.Shoot",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 100,
    sound = ")weapons/humangun/plr/hg_shot.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.ShootLast",
    channel = CHAN_USER_BASE+15,
    volume = 1.0,
    soundlevel = 60,
    sound = {
		"weapons/humangun/effects/oneshot_00.ogg",
		"weapons/humangun/effects/oneshot_01.ogg",
		"weapons/humangun/effects/oneshot_02.ogg"
	}
})
sound.Add(
{
    name = "Weapon_VR11.LoopStart",
    channel = CHAN_USER_BASE+14,
    volume = 0.25,
    soundlevel = 50,
    sound = "weapons/humangun/loops/loop_start.ogg"
})
sound.Add(
{
    name = "Weapon_VR11.Loop",
    channel = CHAN_USER_BASE+15,
    volume = 0.25,
    soundlevel = 50,
    sound = "weapons/humangun/loops/loop_l.wav"
})
sound.Add(
{
    name = "Weapon_VR11.LoopEnd",
    channel = CHAN_USER_BASE+15,
    volume = 0.25,
    soundlevel = 50,
    sound = "weapons/humangun/loops/loop_end.ogg"
})

sound.Add(
{
    name = "Weapon_VR11.Scream",
    channel = CHAN_VOICE,
    volume = 1.0,
    soundlevel = 80,
    sound = {
		"weapons/humangun/fx_scream1.mp3",
		"weapons/humangun/fx_scream2.mp3",
		"weapons/humangun/fx_scream3.mp3",
		"weapons/humangun/fx_scream4.mp3",
		"weapons/humangun/fx_scream5.mp3",
		"weapons/humangun/fx_scream6.mp3"
	}
})

--Zap Guns
sound.Add(
{
    name = "Weapon_Zapgun.Startreload",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_start.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Startreload_le",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_left_start.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Startreload_ri",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_right_start.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Reloading",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_mag_in.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Reloading_le",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_left_mag_in.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Reloading_ri",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_right_mag_in.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Finishreload",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_end.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Finishreload_le",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_left_end.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Finishreload_ri",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_right_end.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Combine",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_join.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Separate",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_separate.ogg"
})
sound.Add(
{
    name = "Weapon_Zapgun.Fire",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/microwave_shot.wav"
})
sound.Add(
{
    name = "Weapon_Wavegun.Fire",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/microwave_rifle_shot.wav"
})
sound.Add(
{
    name = "Weapon_Wavegun.Startreload",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_rifle_start.ogg"
})
sound.Add(
{
    name = "Weapon_Wavegun.Magout",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_rifle_mag_out.ogg"
})
sound.Add(
{
    name = "Weapon_Wavegun.Magin",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_rifle_mag_in.ogg"
})
sound.Add(
{
    name = "Weapon_Wavegun.Futz",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_rifle_futz.ogg"
})
sound.Add(
{
    name = "Weapon_Wavegun.Ready",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/zapwavegun/wpn_micro_rld_rifle_power_up.ogg"
})

--Winter's Howl
sound.Add(
{
    name = "Weapon_Freezegun.Open",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 50,
    sound = "weapons/wintershowl/reload/fly_freeze_open.ogg"
})
sound.Add(
{
    name = "Weapon_Freezegun.Off",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 50,
    sound = "weapons/wintershowl/reload/fly_freeze_off.ogg"
})
sound.Add(
{
    name = "Weapon_Freezegun.Twist",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 50,
    sound = "weapons/wintershowl/reload/fly_freeze_twist.ogg"
})
sound.Add(
{
    name = "Weapon_Freezegun.Backon",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 50,
    sound = "weapons/wintershowl/reload/fly_freeze_backon.ogg"
})
sound.Add(
{
    name = "Weapon_Freezegun.Finish",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 50,
    sound = "weapons/wintershowl/reload/fly_freeze_finish.ogg"
})

--Wunderwaffe
sound.Add(
{
    name = "Weapon_WunderWaffe.Raise",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/tesla_gun/reload/gr_tesla_start.mp3"
})
sound.Add(
{
    name = "Weapon_WunderWaffe.Loop",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/tesla_gun/wpn_tesla_idle_d.wav"
})
sound.Add(
{
    name = "Weapon_WunderWaffe.FlipOff",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/tesla_gun/reload/tesla_switch_flip_off.mp3"
})
sound.Add(
{
    name = "Weapon_WunderWaffe.HandlePull",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/tesla_gun/reload/tesla_handle_pullback.mp3"
})
sound.Add(
{
    name = "Weapon_WunderWaffe.ClipIn",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/tesla_gun/reload/tesla_clip_in.mp3"
})
sound.Add(
{
    name = "Weapon_WunderWaffe.HandleRelease",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/tesla_gun/reload/tesla_handle_release.mp3"
})
sound.Add(
{
    name = "Weapon_WunderWaffe.FlipOn",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 60,
    sound = "weapons/tesla_gun/reload/tesla_switch_flip_on.mp3"
})