ENT.Type			= "anim"
ENT.PrintName		= "Sphere Lightning"
ENT.Author			= "Hidden"
ENT.Spawnable		= false
ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

function ENT:SetupDataTables(dt)
	self:NetworkVar("Int", 0, "Charge")
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
		
		if self:GetCharge() > 1 then self:EmitSound("weapons/originstaffs/lightning/lightning_ball_01.wav") end
	end
    self:SetNoDraw(true)
    self:DrawShadow(false)
	ParticleEffectAttach(self:GetCharge() > 1 and "originstaff_lightning_ultimate" or "originstaff_lightning_proj", PATTACH_ABSORIGIN_FOLLOW, self, 0)
 
	
	self.LifeTime = CurTime() + math.max(5, (self:GetCharge()-1) * 5)
end

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
end