local plymeta = FindMetaTable("Player")

function plymeta:Horde_AddReactiveArmor()
    if self.Horde_ReactiveArmor == 1 then return end

    self.Horde_ReactiveArmor = 1
    net.Start("Horde_SyncStatus")
        net.WriteUInt(HORDE.Status_ReactiveArmor, 8)
        net.WriteUInt(1, 8)
    net.Send(self)
end

function plymeta:Horde_RemoveReactiveArmor()
    if not self:IsValid() then return end
    if self.Horde_ReactiveArmor == 0 then return end
    self.Horde_ReactiveArmor = 0
    net.Start("Horde_SyncStatus")
        net.WriteUInt(HORDE.Status_ReactiveArmor, 8)
        net.WriteUInt(0, 8)
    net.Send(self)
end

function plymeta:Horde_GetReactiveArmor()
    return self.Horde_ReactiveArmor or 0
end

function plymeta:Horde_SetReactiveArmorEnabled(enabled)
    self.Horde_ReactiveArmorEnabled = enabled
end

function plymeta:Horde_GetReactiveArmorEnabled()
    return self.Horde_ReactiveArmorEnabled or nil
end

-- Values come from the perk so the description and the behaviour stay in sync.
local function ReactiveParam(i, fallback)
    local perk = HORDE.perks and HORDE.perks["heavy_reactive_armor"]
    local param = perk and perk.Params and perk.Params[i]
    return (param and param.value) or fallback
end

function plymeta:Horde_ReactiveArmorTimerName()
    return "Horde_RestockReactiveArmor" .. self:EntIndex()
end

-- Runs after evasion, resistances and damage reduction, so the threshold is checked
-- against the damage the hit would really deal. Any hit above the threshold is negated.
hook.Add("Horde_OnPlayerDamageTakenPost", "Horde_ReactiveArmorDamage", function (ply, dmginfo, bonus)
    if not ply:IsValid() or not ply:Horde_GetReactiveArmorEnabled() then return end
    if ply:Horde_GetReactiveArmor() ~= 1 then return end
    if dmginfo:GetAttacker() == ply then return end
    if dmginfo:GetDamage() <= ReactiveParam(1, 25) then return end

    dmginfo:SetDamage(0)

    local dmg = DamageInfo()
    dmg:SetAttacker(ply)
    dmg:SetInflictor(ply)
    dmg:SetDamageType(DMG_BLAST)
    dmg:SetDamage(100)
    util.BlastDamageInfo(dmg, ply:GetPos(), 150)
    local effectdata = EffectData()
    effectdata:SetOrigin(ply:GetPos())
    util.Effect("Explosion", effectdata)

    ply:Horde_RemoveReactiveArmor()
    ply:SetArmor(math.max(0, ply:Armor() - ply:GetMaxArmor() * ReactiveParam(3, 0.25)))

    local name = ply:Horde_ReactiveArmorTimerName()
    timer.Remove(name)
    timer.Create(name, ReactiveParam(2, 6), 1, function ()
        if not IsValid(ply) or not ply:Horde_GetReactiveArmorEnabled() then return end
        ply:Horde_AddReactiveArmor()
    end)
end)

hook.Add("Horde_ResetStatus", "Horde_ReactiveArmorReset", function(ply)
    ply.Horde_ReactiveArmor = 0
    ply.Horde_ReactiveArmorEnabled = nil
end)
