include("shared.lua")

ENT.TrailPCF = "originstaff_fire_proj"
function ENT:Initialize()
	ParticleEffectAttach( self.TrailPCF, PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end