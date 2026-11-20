GADGET.PrintName = "Soul Swapper"
GADGET.Description = "Swap places with the enemy you aim at (up to 1500 units away). Deals 1 damage per 5 units of distance, up to 275. Doesn't work on Elites or bosses."
GADGET.Icon = "items/gadgets/soul_swapper.png"
GADGET.Droppable = false

GADGET.Cooldown =1
GADGET.Active = true
GADGET.Params = {
    [1] = {value = 0, percent = true},
}
GADGET.Hooks = {}

local MAX_RANGE = 1500

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_soul_swapper" then return end
    local shoot = ply:GetShootPos()
    local tr = util.TraceHull({
        start = shoot,
        endpos = shoot + ply:GetAimVector() * MAX_RANGE,
        filter = ply,
        mins = Vector(-8, -8, -8),
        maxs = Vector(8, 8, 8),
        mask = MASK_SHOT_HULL,
    })
    local target = tr.Entity
    -- Any enemy NPC or nextbot (VJ enemies don't always report D_HT), never elites or bosses
    if not HORDE:IsEnemy(target) then return true end
    if target:Horde_IsElite() or target:Horde_GetBossProperties() then return true end

    local ply_pos = ply:GetPos()
    local target_pos = target:GetPos()
    local damage = math.min(math.floor(ply_pos:Distance(target_pos) / 5), 275)

    ply:SetPos(target_pos)
    target:SetPos(ply_pos)
    ply:SetVelocity(-ply:GetVelocity())
    ply:EmitSound("horde/gadgets/energy_shield_on.ogg", 80, 140)

    local dmgi = DamageInfo()
    dmgi:SetDamageType(DMG_BULLET)
    dmgi:SetDamage(damage)
    dmgi:SetInflictor(ply)
    dmgi:SetAttacker(ply)
    dmgi:SetDamagePosition(target:WorldSpaceCenter())
    target:TakeDamageInfo(dmgi)
end
