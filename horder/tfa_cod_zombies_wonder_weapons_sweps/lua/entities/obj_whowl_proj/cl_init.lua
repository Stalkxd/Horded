include("shared.lua")

function ENT:Initialize()
	ParticleEffectAttach( "freeze_geo_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function ENT:Think()
	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetPos()
		dlight.dir = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 4
		dlight.Decay = 1000
		dlight.Size = 150
		dlight.DieTime = CurTime() + 1
	end
end