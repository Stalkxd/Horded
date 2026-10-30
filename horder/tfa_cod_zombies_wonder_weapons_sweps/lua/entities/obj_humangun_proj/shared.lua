ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

ENT.HasCollided = false

ENT.CollidePCF = "vr11_impact"
ENT.AuraPCF = "vr11_aura"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")
end

function ENT:Initialize()
	--self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:EnableCustomCollisions(true)
	if SERVER then
		self:SetModel("models/error.mdl")
		self:SetSolid(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetCollisionBounds(Vector(-8, -8, -8), Vector(8, 8, 8))
		self:SetTrigger(true)
		
		self:EmitSound("weapons/humangun/projectile/proj_loop_l.wav")
	end
	
	if self:GetUpgraded() then
		self.CollidePCF = "vr11_impact_pap"
		self.AuraPCF = "vr11_aura_pap"
	end
	
	self.LifeTime = CurTime() + 8
	
	ParticleEffectAttach( self:GetUpgraded() and "vr11_trail_pap" or "vr11_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	self:SetNoDraw(true)
	self:DrawShadow(false)
end

function ENT:OnRemove()
	self:StopSound("weapons/humangun/projectile/proj_loop_l.wav")
end