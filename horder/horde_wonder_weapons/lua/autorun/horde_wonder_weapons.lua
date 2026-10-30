-- Horde wonder weapons: the Black Ops 3 and CoD Zombies wonder weapons rebuilt on ArcCW.
-- Needs ArcCW. Lives outside the gamemode folder, so it can be installed as its own addon.

HORDE_WW = HORDE_WW or {}

if CLIENT then
    CreateClientConVar("cl_tfa_fx_wonderweapon_dlights", 0, true, false, "Dynamic lights on wonder weapon projectiles (0 or 1).")
end

local files = {
    "horde_ww/sh_mixin.lua",
    "horde_ww/sh_sounds.lua",
    "horde_ww/sh_particles.lua",
    "horde_ww/sh_hooks.lua",
}

for _, path in ipairs(files) do
    AddCSLuaFile(path)
    include(path)
end
