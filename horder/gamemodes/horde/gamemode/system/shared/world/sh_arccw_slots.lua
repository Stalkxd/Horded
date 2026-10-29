-- Lets attachments from one weapon pack fit the matching slot on weapons from the other packs.
-- Each group lists slot names that mean the same thing in different packs; a weapon slot that
-- accepts any name in a group is widened to accept the whole group.
-- MW3/COD4 perks ("mw3_perk", "mw3_pro") are left out on purpose: they stay on MW3/COD4 weapons only,
-- and those weapons do not pick up CS:GO/MW2 perks either.
HORDE.ArcCWSlotGroups = {
    { "tac", "bo1_tacprimary", "bo1_tacall" },
    { "tac_pistol", "bo1_tacpistol" },
    { "fcg", "bo1_fcg" },
    { "go_ammo", "ammo_bullet", "mw3_ammo", "ammo_pap" },
    { "horde_go_shotgun_ammo", "ammo_shotgun", "ammo_pap_sg" },
    { "go_perk", "perk" },
}

local slot_to_group = {}
for _, group in ipairs(HORDE.ArcCWSlotGroups) do
    for _, name in ipairs(group) do
        slot_to_group[name] = group
    end
end

local function WidenSlot(slot)
    local names = slot.Slot
    if isstring(names) then names = { names } end
    if not istable(names) then return end

    local out, have = {}, {}
    for _, name in ipairs(names) do
        out[#out + 1] = name
        have[name] = true
    end

    for _, name in ipairs(names) do
        local group = slot_to_group[name]
        if group then
            for _, other in ipairs(group) do
                if not have[other] then
                    have[other] = true
                    out[#out + 1] = other
                end
            end
        end
    end
    if #out > #names then slot.Slot = out end
end

hook.Add("PreRegisterSWEP", "Horde_ArcCWCrossPackSlots", function(swep, class)
    if not istable(swep) or not istable(swep.Attachments) then return end
    if not string.StartWith(class or "", "arccw_") then return end
    for _, slot in pairs(swep.Attachments) do
        if istable(slot) then WidenSlot(slot) end
    end
end)
