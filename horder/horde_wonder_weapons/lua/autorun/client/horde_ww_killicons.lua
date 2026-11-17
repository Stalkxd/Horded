-- Kill feed icons for the wonder weapons. They use the same pictures as the weapon selection
-- and shop icons (materials/arccw/weaponicons/<class>). Projectiles and puddles get the icon of
-- the weapon that fired them, since the kill feed shows the entity that dealt the damage.
local WEAPONS = {
    "arccw_ww_deathmachine",
    "arccw_ww_dg4",
    "arccw_ww_gauntlet",
    "arccw_ww_gkzmk3",
    "arccw_ww_keepersword",
    "arccw_ww_kt4",
    "arccw_ww_scavenger",
    "arccw_ww_sliquifier",
    "arccw_ww_zapguns",
    "arccw_ww_zmbbow",
    "arccw_ww_zodsword",
}

local ENTITIES = {
    obj_scavenger_proj = "arccw_ww_scavenger",
    obj_wgun_proj = "arccw_ww_zapguns",
    obj_wgun_proj2 = "arccw_ww_zapguns",
    obj_sliquifier_proj = "arccw_ww_sliquifier",
    obj_sliquifier_puddle = "arccw_ww_sliquifier",
    bo3_ww_mk3 = "arccw_ww_gkzmk3",
    bo3_ww_gkz = "arccw_ww_gkzmk3",
    bo3_ww_gkzmk3_bh = "arccw_ww_gkzmk3",
    bo3_ww_zmbbow = "arccw_ww_zmbbow",
    bo3_ww_mirg = "arccw_ww_kt4",
    bo3_ww_mirg_puddle = "arccw_ww_kt4",
    bo3_status_effect_spores = "arccw_ww_kt4",
    bo3_special_dg4 = "arccw_ww_dg4",
    bo3_special_dg4clone = "arccw_ww_dg4",
    bo3_special_keepersword = "arccw_ww_keepersword",
}

local color = Color(255, 255, 255, 255)

for _, class in ipairs(WEAPONS) do
    killicon.Add(class, "arccw/weaponicons/" .. class, color)
end

for ent, class in pairs(ENTITIES) do
    killicon.Add(ent, "arccw/weaponicons/" .. class, color)
end
