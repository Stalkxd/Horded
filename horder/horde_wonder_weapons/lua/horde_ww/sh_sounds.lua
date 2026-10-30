-- Sound scripts used by the wonder weapons, taken from the two TFA packs they came from.
-- Only the sounds the remaining weapons, projectiles and models actually play are kept.
-- The TFA helpers are copied as local functions so the addon works without TFA installed.

local function Prefix(path, prefix)
    if not prefix or prefix == "" then return path end
    if istable(path) then
        local out = {}
        for i, p in ipairs(path) do out[i] = prefix .. p end
        return out
    end
    return prefix .. path
end

local function AddSound(name, channel, volume, level, pitch, wave, prefix)
    sound.Add({
        name = name,
        channel = channel or CHAN_AUTO,
        volume = volume or 1,
        level = level or SNDLVL_NORM,
        pitch = pitch or 100,
        sound = Prefix(wave, prefix),
    })
end

local function AddFireSound(name, wave, wrap, prefix)
    AddSound(name, wrap and CHAN_WEAPON or CHAN_STATIC, 1, 120, { 97, 103 }, wave, prefix)
end

local function AddWeaponSound(name, wave, prefix)
    AddSound(name, CHAN_WEAPON, 1, 80, { 97, 103 }, wave, prefix)
end

AddWeaponSound("weapon_bo3_cloth.med", {"weapons/tfa_bo3/foley/cloth/fly_cloth_med_00.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_01.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_02.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_03.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_04.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_05.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_06.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_07.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_med_08.wav"})
AddWeaponSound("weapon_bo3_cloth.short", {"weapons/tfa_bo3/foley/cloth/fly_cloth_shrt_00.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_shrt_01.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_shrt_02.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_shrt_03.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_shrt_04.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_shrt_05.wav", "weapons/tfa_bo3/foley/cloth/fly_cloth_shrt_06.wav"})
AddWeaponSound("weapon_bo3_gear.rattle", {"weapons/tfa_bo3/foley/gear/gear_rattle_13.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_15.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_16.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_17.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_18.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_19.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_20.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_21.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_22.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_23.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_24.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_25.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_27.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_28.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_29.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_30.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_31.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_32.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_45.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_46.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_47.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_48.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_49.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_50.wav", "weapons/tfa_bo3/foley/gear/gear_rattle_51.wav"})
AddSound ("TFA_BO3_MK2.Impact", CHAN_ITEM, 1, SNDLVL_TALKING, {95,105}, "weapons/tfa_bo3/raygun_mk2/imp_00.wav", "weapons/tfa_bo3/raygun_mk2/imp_01.wav", "weapons/tfa_bo3/raygun_mk2/imp_02.wav",")")
AddFireSound("TFA_BO3_MIRG.Shoot.Charge.1", {"weapons/tfa_bo3/mirg2000/mirg2k_01.wav", "weapons/tfa_bo3/mirg2000/mirg2k_02.wav", "weapons/tfa_bo3/mirg2000/mirg2k_03.wav", "weapons/tfa_bo3/mirg2000/mirg2k_04.wav"}, true, ")")
AddFireSound("TFA_BO3_MIRG.Shoot.Charge.2", {"weapons/tfa_bo3/mirg2000/mirg2k_chrg1_01.wav", "weapons/tfa_bo3/mirg2000/mirg2k_chrg1_02.wav", "weapons/tfa_bo3/mirg2000/mirg2k_chrg1_03.wav", "weapons/tfa_bo3/mirg2000/mirg2k_chrg1_04.wav"}, true, ")")
AddFireSound("TFA_BO3_MIRG.Shoot.Charge.3", {"weapons/tfa_bo3/mirg2000/mirg2k_chrg2_01.wav", "weapons/tfa_bo3/mirg2000/mirg2k_chrg2_02.wav", "weapons/tfa_bo3/mirg2000/mirg2k_chrg2_03.wav", "weapons/tfa_bo3/mirg2000/mirg2k_chrg2_04.wav"}, true, ")")
AddWeaponSound("TFA_BO3_MIRG.MagOut", "weapons/tfa_bo3/mirg2000/fly_mirg_mag_out.wav")
AddWeaponSound("TFA_BO3_MIRG.MagIn", "weapons/tfa_bo3/mirg2000/fly_mirg_mag_in.wav")
AddWeaponSound("TFA_BO3_MIRG.Prime", "weapons/tfa_bo3/mirg2000/fly_mirg_prime.wav")
AddWeaponSound("TFA_BO3_MIRG.Rechamber", "weapons/tfa_bo3/mirg2000/fly_mirg_rechamber.wav")
AddSound ("TFA_BO3_MIRG.Charge1", CHAN_STATIC, 1, SNDLVL_NORM, 100, "weapons/tfa_bo3/mirg2000/wpn_hive_act_00.wav",")")
AddSound ("TFA_BO3_MIRG.Charge2", CHAN_STATIC, 0.5, SNDLVL_IDLE, 100, "weapons/tfa_bo3/mirg2000/fly_lightning_first_flaps.wav",")")
AddSound ("TFA_BO3_MIRG.Charge3", CHAN_WEAPON, 0.1, SNDLVL_IDLE, 100, "weapons/tfa_bo3/mirg2000/wpn_arrow_timer.wav",")")
AddSound ("TFA_BO3_MIRG.Start", CHAN_STATIC, 0.5, SNDLVL_IDLE, 100, {"weapons/tfa_bo3/mirg2000/fly_mirg_start.wav"},")")
AddSound ("TFA_BO3_MIRG.Stop", CHAN_ITEM, 0.5, SNDLVL_IDLE, 100, {"weapons/tfa_bo3/mirg2000/fly_mirg_end_00.wav"},")")
AddSound ("TFA_BO3_MIRG.Slime", CHAN_STATIC, 0.05, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/mirg2000/goo/ww_slime_charged_01.wav", "weapons/tfa_bo3/mirg2000/goo/ww_slime_charged_02.wav"},")")
AddSound ("TFA_BO3_MIRG.ImpactSwt", CHAN_STATIC, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/mirg2000/goo/acid_sizzle_00.wav", "weapons/tfa_bo3/mirg2000/goo/acid_sizzle_01.wav", "weapons/tfa_bo3/mirg2000/goo/acid_sizzle_02.wav", "weapons/tfa_bo3/mirg2000/goo/acid_sizzle_03.wav", "weapons/tfa_bo3/mirg2000/goo/acid_sizzle_04.wav"},")")
AddSound ("TFA_BO3_MIRG.Impact", CHAN_STATIC, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/mirg2000/goo/gooball_explo_empty_0.wav", "weapons/tfa_bo3/mirg2000/goo/gooball_explo_empty_1.wav", "weapons/tfa_bo3/mirg2000/goo/gooball_explo_empty_2.wav", "weapons/tfa_bo3/mirg2000/goo/gooball_explo_empty_3.wav"},")")
AddSound ("TFA_BO3_MIRG.Spore.Infect", CHAN_STATIC, 0.5, SNDLVL_NORM, {95,105}, {"weapons/tfa_bo3/mirg2000/goo/gooball_explo_full_0.wav", "weapons/tfa_bo3/mirg2000/goo/gooball_explo_full_1.wav", "weapons/tfa_bo3/mirg2000/goo/gooball_explo_full_2.wav", "weapons/tfa_bo3/mirg2000/goo/gooball_explo_full_3.wav"},")")
AddSound ("TFA_BO3_MIRG.Spore.Grow", CHAN_STATIC, 0.5, SNDLVL_NORM, {95,105}, {"weapons/tfa_bo3/mirg2000/goo/ww_spores_01.wav", "weapons/tfa_bo3/mirg2000/goo/ww_spores_02.wav", "weapons/tfa_bo3/mirg2000/goo/ww_spores_03.wav", "weapons/tfa_bo3/mirg2000/goo/ww_spores_04.wav", "weapons/tfa_bo3/mirg2000/goo/ww_spores_05.wav"},")")
AddSound ("TFA_BO3_MIRG.Spore.Explode", CHAN_STATIC, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/mirg2000/goo/zmb_spore_eject.wav"},")")
AddWeaponSound("TFA_BO3_DG4.FirstDraw", "weapons/tfa_bo3/dg4/talon_1st_raise.wav")
AddWeaponSound("TFA_BO3_DG4.Draw", "weapons/tfa_bo3/dg4/talon_raise.wav")
AddWeaponSound("TFA_BO3_DG4.Activate", {"weapons/tfa_bo3/dg4/slam/sword_jump_00.wav", "weapons/tfa_bo3/dg4/slam/sword_jump_01.wav"})
AddSound ("TFA_BO3_DG4.Vortex.Start", CHAN_STATIC, 1, SNDLVL_TALKING, 100, "weapons/tfa_bo3/dg4/vortex/talon_vortex_start.wav",")")
AddSound ("TFA_BO3_DG4.Vortex.Loop", CHAN_ITEM, 1, SNDLVL_NORM, 100, "weapons/tfa_bo3/dg4/vortex/talon_vortex_loop.wav",")")
AddSound ("TFA_BO3_DG4.Vortex.End", CHAN_ITEM, 1, SNDLVL_TALKING, 100, "weapons/tfa_bo3/dg4/vortex/talon_vortex_end.wav",")")
AddSound ("TFA_BO3_DG4.Explode", CHAN_STATIC, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/dg4/slam/sword_spark_explode_00.wav", "weapons/tfa_bo3/dg4/slam/sword_spark_explode_01.wav"},")")
AddSound ("TFA_BO3_DG4.Strike", CHAN_STATIC, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/dg4/slam/sword_ground_strike_00.wav", "weapons/tfa_bo3/dg4/slam/sword_ground_strike_01.wav"},")")
AddSound ("TFA_BO3_DG4.Shockwave", CHAN_STATIC, 1, SNDLVL_GUNFIRE, {95,105}, "weapons/tfa_bo3/dg4/slam/wpn_gravity_shockwave.wav",")")
AddSound ("TFA_BO3_DG4.EMP", CHAN_BODY, 0.2, SNDLVL_GUNFIRE, {90,110}, {"weapons/tfa_bo3/dg4/slam/emp_exp_dist_00.wav", "weapons/tfa_bo3/dg4/slam/emp_exp_dist_01.wav", "weapons/tfa_bo3/dg4/slam/emp_exp_dist_02.wav", "weapons/tfa_bo3/dg4/slam/emp_exp_dist_03.wav"},")")
AddSound ("TFA_BO3_DG4.Dist", CHAN_STATIC, 1, SNDLVL_GUNFIRE, {97,103}, {"weapons/tfa_bo3/dg4/slam/concussion_dist_00.wav", "weapons/tfa_bo3/dg4/slam/concussion_dist_01.wav", "weapons/tfa_bo3/dg4/slam/concussion_dist_02.wav"},")")
AddFireSound("TFA_BO3_ZMBBOW.Fire", {"weapons/tfa_bo3/zmbbow/base_bow_fire_00.wav", "weapons/tfa_bo3/zmbbow/base_bow_fire_01.wav", "weapons/tfa_bo3/zmbbow/base_bow_fire_02.wav", "weapons/tfa_bo3/zmbbow/base_bow_fire_03.wav", "weapons/tfa_bo3/zmbbow/base_bow_fire_04.wav", "weapons/tfa_bo3/zmbbow/base_bow_fire_05.wav", "weapons/tfa_bo3/zmbbow/base_bow_fire_06.wav", "weapons/tfa_bo3/zmbbow/base_bow_fire_07.wav"}, true, ")")
AddFireSound("TFA_BO3_ZMBBOW.FullCharge", "weapons/tfa_bo3/zmbbow/bow_fire_full_00.wav", true, ")")
AddWeaponSound("TFA_BO3_ZMBBOW.Draw", "weapons/tfa_bo3/zmbbow/zm_bow_first_raise.wav")
AddWeaponSound("TFA_BO3_ZMBBOW.Reload", "weapons/tfa_bo3/zmbbow/arrow_load.wav")
AddSound ("TFA_BO3_ZMBBOW.PullBack", CHAN_ITEM, 1, SNDLVL_IDLE, 100, {"weapons/tfa_bo3/zmbbow/base_bow_pullback_00.wav", "weapons/tfa_bo3/zmbbow/base_bow_pullback_01.wav"},")")
AddSound ("TFA_BO3_ZMBBOW.DrawLoop", CHAN_WEAPON, 0.1, SNDLVL_IDLE, 100, "weapons/tfa_bo3/zmbbow/bowlauncher_loop_stretch.wav",")")
AddSound ("TFA_BO3_ZMBBOW.Cancel", CHAN_WEAPON, 1, SNDLVL_IDLE, 100, "weapons/tfa_bo3/zmbbow/base_bow_cancel_00.wav",")")
AddSound ("TFA_BO3_ZMBBOW.ExplodeSwt", CHAN_STATIC, 1, SNDLVL_GUNFIRE, {90,110}, {"weapons/tfa_bo3/zmbbow/bow_exp_basic_0.wav", "weapons/tfa_bo3/zmbbow/bow_exp_basic_1.wav", "weapons/tfa_bo3/zmbbow/bow_exp_basic_2.wav"},")")
AddSound ("TFA_BO3_ZMBBOW.Explode", CHAN_STATIC, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/zmbbow/proj_explo_00.wav", "weapons/tfa_bo3/zmbbow/proj_explo_01.wav", "weapons/tfa_bo3/zmbbow/proj_explo_02.wav"},")")
AddSound ("TFA_BO3_ZMBBOW.Impact", CHAN_STATIC, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/zmbbow/upgraded_imp.wav", "weapons/tfa_bo3/zmbbow/proj_explo_01.wav", "weapons/tfa_bo3/zmbbow/proj_explo_02.wav"},")")
AddFireSound("TFA_BO3_GKZ.Shoot", "weapons/tfa_bo3/gkzmk3/wpn_mk3_lh_fire.wav", true, ")")
AddFireSound("TFA_BO3_GKZ.Act", "weapons/tfa_bo3/gkzmk3/wpn_mk3_lh_act.wav", true, ")")
AddFireSound("TFA_BO3_MK3.Shoot", "weapons/tfa_bo3/gkzmk3/wpn_mk3_rh_fire.wav", true, ")")
AddFireSound("TFA_BO3_MK3.Act", "weapons/tfa_bo3/gkzmk3/wpn_mk3_rh_act.wav", true, ")")
AddFireSound("TFA_BO3_MK3.Decay", "weapons/tfa_bo3/gkzmk3/wpn_mk3_rh_fire_decay.wav", true, ")")
AddWeaponSound("TFA_BO3_MK3.First", "weapons/tfa_bo3/gkzmk3/fly_mkiii_reload_rh_first.wav")
AddWeaponSound("TFA_BO3_MK3.Reload", "weapons/tfa_bo3/gkzmk3/fly_mkiii_reload.wav")
AddWeaponSound("TFA_BO3_GKZ.First", "weapons/tfa_bo3/gkzmk3/fly_mkiii_reload_lh_first.wav")
AddWeaponSound("TFA_BO3_GKZ.Reload", "weapons/tfa_bo3/gkzmk3/fly_mkiii_reload_lh_00.wav")
AddWeaponSound("TFA_BO3_GKZ.Gears", "weapons/tfa_bo3/gkzmk3/fly_mkiii_reload_lh_gears.wav")
AddSound ("TFA_BO3_GKZMK3.Orb.End", CHAN_WEAPON, 1, SNDLVL_GUNFIRE, 100, "weapons/tfa_bo3/gkzmk3/wpn_mk3_orb_disappear.wav",")")
AddSound ("TFA_BO3_GKZMK3.Orb.Loop", CHAN_WEAPON, 1, SNDLVL_TALKING, 100, "weapons/tfa_bo3/gkzmk3/wpn_mk3_orb_loop.wav",")")
AddSound ("TFA_BO3_GKZMK3.Orb.Loop2", CHAN_WEAPON, 1, SNDLVL_TALKING, 100, "weapons/tfa_bo3/gkzmk3/wpn_mk3_orb_activated_loop.wav",")")
AddSound ("TFA_BO3_GKZMK3.Orb.Start", CHAN_STATIC, 1, SNDLVL_GUNFIRE, 100, "weapons/tfa_bo3/gkzmk3/wpn_mk3_orb_creation_00.wav",")")
AddSound ("TFA_BO3_GKZMK3.Orb.Damage", CHAN_AUTO, 1, SNDLVL_TALKING, {95,105}, {"weapons/tfa_bo3/gkzmk3/wpn_orb_damage_00.wav", "weapons/tfa_bo3/gkzmk3/wpn_orb_damage_01.wav", "weapons/tfa_bo3/gkzmk3/wpn_orb_damage_02.wav", "weapons/tfa_bo3/gkzmk3/wpn_orb_damage_03.wav"},")")
AddWeaponSound("TFA_BO3_ZODSWORD.Swing", {"weapons/tfa_bo3/zodsword/swing_1_00.wav", "weapons/tfa_bo3/zodsword/swing_1_01.wav", "weapons/tfa_bo3/zodsword/swing_1_02.wav", "weapons/tfa_bo3/zodsword/swing_2_00.wav", "weapons/tfa_bo3/zodsword/swing_2_01.wav", "weapons/tfa_bo3/zodsword/swing_2_02.wav"})
AddWeaponSound("TFA_BO3_ZODSWORD.SwingFoly", {"weapons/tfa_bo3/zodsword/swing_foley_1_00.wav", "weapons/tfa_bo3/zodsword/swing_foley_1_01.wav"})
AddWeaponSound("TFA_BO3_ZODSWORD.GroundStrike", {"weapons/tfa_bo3/zodsword/sword_ground_strike_00.wav", "weapons/tfa_bo3/zodsword/sword_ground_strike_01.wav"})
AddWeaponSound("TFA_BO3_ZODSWORD.SparkExplode", {"weapons/tfa_bo3/zodsword/sword_spark_explode_00.wav", "weapons/tfa_bo3/zodsword/sword_spark_explode_01.wav"})
AddWeaponSound("TFA_BO3_ZODSWORD.Jump", {"weapons/tfa_bo3/zodsword/sword_jump_00.wav", "weapons/tfa_bo3/zodsword/sword_jump_01.wav"})
AddWeaponSound("TFA_BO3_ZODSWORD.Raise", "weapons/tfa_bo3/zodsword/sword_raise.wav")
AddWeaponSound("TFA_BO3_ZODSWORD.Impact", {"weapons/tfa_bo3/zodsword/sword2_imp_00.wav", "weapons/tfa_bo3/zodsword/sword2_imp_01.wav", "weapons/tfa_bo3/zodsword/sword2_imp_02.wav", "weapons/tfa_bo3/zodsword/sword2_imp_03.wav", "weapons/tfa_bo3/zodsword/sword2_imp_04.wav", "weapons/tfa_bo3/zodsword/sword2_imp_05.wav", "weapons/tfa_bo3/zodsword/sword2_imp_06.wav", "weapons/tfa_bo3/zodsword/sword2_imp_07.wav"})
AddWeaponSound("TFA_BO3_KPRSWORD.Swing", {"weapons/tfa_bo3/keepersword/hyperswing_1_00.wav", "weapons/tfa_bo3/keepersword/hyperswing_1_01.wav", "weapons/tfa_bo3/keepersword/hyperswing_1_02.wav", "weapons/tfa_bo3/keepersword/hyperswing_2_00.wav", "weapons/tfa_bo3/keepersword/hyperswing_2_01.wav", "weapons/tfa_bo3/keepersword/hyperswing_2_02.wav"})
AddSound ("TFA_BO3_KPRSWORD.Loop", CHAN_WEAPON, 0.4, SNDLVL_TALKING, 100, "weapons/tfa_bo3/keepersword/sword_looper_close.wav",")")
AddWeaponSound("TFA_BO3_KPRSWORD.Throw", "weapons/tfa_bo3/keepersword/sword_throw.wav")
AddWeaponSound("TFA_BO3_KPRSWORD.Return", "weapons/tfa_bo3/keepersword/sword2_return_01.wav")
AddFireSound("TFA_BO3_GAUNTLET.ShootIn", "weapons/tfa_bo3/gauntlet/wpn_dragon_gauntlet_start.wav", true, ")")
AddFireSound("TFA_BO3_GAUNTLET.ShootLoop", "weapons/tfa_bo3/gauntlet/wpn_dragon_gauntlet_loop.wav", false, ")")
AddFireSound("TFA_BO3_GAUNTLET.ShootOut", "weapons/tfa_bo3/gauntlet/wpn_dragon_gauntlet_stop.wav", false, ")")
AddWeaponSound("TFA_BO3_GAUNTLET.Hit", {"weapons/tfa_bo3/gauntlet/fist_00.wav", "weapons/tfa_bo3/gauntlet/fist_01.wav", "weapons/tfa_bo3/gauntlet/fist_02.wav"})
AddWeaponSound("TFA_BO3_GAUNTLET.Attach", "weapons/tfa_bo3/gauntlet/fly_gaunt_attach.wav")
AddWeaponSound("TFA_BO3_GAUNTLET.Scream", {"weapons/tfa_bo3/gauntlet/fly_gaunt_scream_1.wav", "weapons/tfa_bo3/gauntlet/fly_gaunt_scream_2.wav", "weapons/tfa_bo3/gauntlet/fly_gaunt_scream_3.wav", "weapons/tfa_bo3/gauntlet/fly_gaunt_scream_4.wav", "weapons/tfa_bo3/gauntlet/fly_gaunt_scream_5.wav"})
AddWeaponSound("TFA_BO3_GAUNTLET.Shake", "weapons/tfa_bo3/gauntlet/fly_gaunt_shake.wav")
AddWeaponSound("TFA_BO3_GAUNTLET.Poof", {"weapons/tfa_bo3/gauntlet/wpn_gaunt_poof_00.wav", "weapons/tfa_bo3/gauntlet/wpn_gaunt_poof_01.wav"})
AddWeaponSound("TFA_BO3_MINGN.Equip", "weapons/tfa_bo3/mingun/fly_minigun_up.wav")
AddFireSound("TFA_BO3_MINGN.Start", "weapons/tfa_bo3/mingun/wpn_vulcan_fire_start_plr.wav", true, ")")
AddFireSound("TFA_BO3_MINGN.Loop", "weapons/tfa_bo3/mingun/wpn_vulcan_fire_loop_plr.wav", false, ")")
AddFireSound("TFA_BO3_MINGN.Stop", "weapons/tfa_bo3/mingun/wpn_vulcan_fire_stop_plr.wav", false, ")")
AddSound ("TFA_BO3_MINGN.SpinStart", CHAN_ITEM, 0.5, SNDLVL_NORM, 100, "weapons/tfa_bo3/mingun/wpn_vulcan_start_plr.wav",")")
AddSound ("TFA_BO3_MINGN.SpinLoop", CHAN_ITEM, 0.5, SNDLVL_IDLE, 100, "weapons/tfa_bo3/mingun/wpn_vulcan_loop_plr.wav",")")
AddSound ("TFA_BO3_MINGN.SpinStop", CHAN_ITEM, 0.5, SNDLVL_NORM, 100, "weapons/tfa_bo3/mingun/wpn_vulcan_stop_plr.wav",")")
AddWeaponSound("TFA_BO3_STAFFS.MeleeHit", {"weapons/tfa_bo3/staffs/shared/knife_blade_imp_00.wav", "weapons/tfa_bo3/staffs/shared/knife_blade_imp_01.wav", "weapons/tfa_bo3/staffs/shared/knife_blade_imp_02.wav"})
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
