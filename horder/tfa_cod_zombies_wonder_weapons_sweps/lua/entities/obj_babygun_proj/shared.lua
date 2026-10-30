ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Upgraded")
end

ENT.Timer = 5
function ENT:Initialize()
	--self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:EnableCustomCollisions(true)
	if SERVER then
		self:SetModel("models/error.mdl")
		self:SetSolid(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))
		self:SetTrigger(true)
	end
	
	if self:GetUpgraded() then
		self.Timer = 15
	end
	
	self.LifeTime = CurTime() + 8
	
	self:SetNoDraw(true)
	self:DrawShadow(false)
	
	ParticleEffectAttach( self:GetUpgraded() and "babygun_proj_pap" or "babygun_proj", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end