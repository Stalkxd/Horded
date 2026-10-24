-- Horde Pointshop entry point.
-- Loads the pointshop files in a fixed order (config -> shared -> server/client).
-- Server owners: edit modules/pointshop/core/sh_config.lua, or use the ADMIN tab in-game.

HORDE = HORDE or {}
HORDE.Pointshop = HORDE.Pointshop or {}

local ROOT = "horde/gamemode/modules/pointshop/core/"

local FILES = {
    { "sh_config.lua",    "sh" },
    { "sh_lang.lua",      "sh" },
    { "sh_core.lua",      "sh" },
    { "sv_pointshop.lua", "sv" },
    { "sv_contracts.lua", "sv" },
    { "cl_pointshop.lua", "cl" },
    { "cl_skin.lua",      "cl" },
    { "cl_menu.lua",      "cl" },
    { "cl_tracker.lua",   "cl" },
}

for _, entry in ipairs(FILES) do
    local path, realm = ROOT .. entry[1], entry[2]
    if realm ~= "sv" and SERVER then AddCSLuaFile(path) end
    if realm == "sh" or (realm == "sv" and SERVER) or (realm == "cl" and CLIENT) then
        include(path)
    end
end
