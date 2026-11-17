include("shared.lua")

local auras = auras or {}

-- The parent is often not networked yet when the entity initializes clientside
-- (GetParent() returns NULL), so ownership is checked when drawing instead.
local function IsMyAura(aura)
    local parent = aura:GetParent()
    if not IsValid(parent) then return false end
    local ply = LocalPlayer()
    return parent == ply or parent:GetNWEntity("HordeOwner") == ply
end

function ENT:Initialize()
    auras[self] = true
end

function ENT:OnRemove()
	auras[self] = nil
end

hook.Add( "PreDraw_ImmersionBreakingCircles", "Draw_WardenAuraCircle", function()
	if next(auras) == nil then return end
	for aura in pairs(auras) do
        if not IsValid(aura) then
            auras[aura] = nil
        elseif IsMyAura(aura) and aura:GetIsDisplayingCircleRadius() == 1 then
            HORDE.MaskedSphereRing(aura:GetPos(), aura:GetCircleRadius() + 20, 16, 4, Color(0, 0, 100, 100))
        end
    end
end)
