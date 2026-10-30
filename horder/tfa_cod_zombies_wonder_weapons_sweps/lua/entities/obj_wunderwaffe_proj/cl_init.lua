include("shared.lua")

function ENT:Think()
	if self:GetMoveType() == MOVETYPE_NONE then return end
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetPos()
		dlight.dir = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 5
		dlight.Decay = 1000
		dlight.Size = 100
		dlight.DieTime = CurTime() + 1
	end
end