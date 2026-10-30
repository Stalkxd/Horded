ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Upgraded")
end

function ENT:Initialize()
	self:EnableCustomCollisions(true)
	if SERVER then
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetSolid(SOLID_BBOX)
		self:SetModel("models/error.mdl")
		self:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	end
	
	self:SetNoDraw(true)
	self:DrawShadow(false)
	ParticleEffectAttach( self:GetUpgraded() and "raygun_trail_pap" or "raygun_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	self:EmitSound("weapons/raygun/wpn_ray_loop.wav", 75, 100, 0.5)
	
	self.LifeTime = CurTime() + 8
	self:NextThink(CurTime())
end

function ENT:OnRemove()
	self:StopSound("weapons/raygun/wpn_ray_loop.wav")
end