include("shared.lua")

function ENT:Think(engine)
	local ct = CurTime()
		local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetPos()
		dlight.dir = self:GetPos()
		dlight.r = 227
		dlight.g = 233
		dlight.b = 54
		dlight.brightness = 3
		dlight.Decay = 1000
		dlight.Size = 150
		dlight.DieTime = ct + 1
	end
		
	self:NextThink(ct+0.1)
	return true
end