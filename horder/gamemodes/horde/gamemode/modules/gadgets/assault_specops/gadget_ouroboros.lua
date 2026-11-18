GADGET.PrintName = "Ouroboros"
GADGET.Description =
[[Ouroboros nervous system assistant.
Removes body regulations to increase combat capabilities.

When you have more than 50% health, you lose 1 health per second.
When you have less than 50% health, you gain 2 health per second.
For each 1% health missing, increase your damage by 0.8%.]]
GADGET.Icon = "items/gadgets/ouroboros.png"
GADGET.Duration = 0
GADGET.Cooldown = 0
GADGET.Params = {
    [1] = {value = 5},
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnSetGadget = function (ply, gadget)
    if CLIENT then return end
    if gadget ~= "gadget_ouroboros" then return end
    local id = ply:SteamID()
    timer.Create("Horde_Ouroboros_Effect" .. id, 1, 0, function ()
        if not ply:IsValid() then timer.Remove("Horde_Ouroboros_Effect" .. id) return end
        local half = ply:GetMaxHealth() * 0.5
        if ply:Health() > half then
            ply:SetHealth(ply:Health() - 1)
        elseif ply:Health() < half then
            ply:SetHealth(ply:Health() + 2)
        end
    end)
end

GADGET.Hooks.Horde_OnUnsetGadget = function (ply, gadget)
    if CLIENT then return end
    if gadget ~= "gadget_ouroboros" then return end
    local id = ply:SteamID()
    timer.Remove("Horde_Ouroboros_Effect" .. id)
end

GADGET.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if ply:Horde_GetGadget() ~= "gadget_ouroboros" then return end
    -- The bonus grows with missing health, as the description says: +0.8% per 1% missing,
    -- so +40% at the 50% the gadget pulls you towards and +80% at most. It used to grow with
    -- current health instead, giving the biggest bonus (+80%, more with max health boosts)
    -- at full health.
    local max_hp = ply:GetMaxHealth()
    if max_hp <= 0 then return end
    local missing = 1 - math.Clamp(ply:Health() / max_hp, 0, 1)
    bonus.increase = bonus.increase + 0.8 * missing
end
