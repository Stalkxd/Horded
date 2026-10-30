ENT.Type			= "anim"
ENT.PrintName		= "Tornado"
ENT.Author			= "Hidden"
ENT.Spawnable		= false
ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER
 
function ENT:SetupDataTables(dt)
	self:NetworkVar("Int", 0, "Charge")
end

function ENT:Initialize()
	self:EnableCustomCollisions(true)
	self:DrawShadow(false)
	if SERVER then
		self:SetModel("models/error.mdl")
		self:SetSolid(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))
	end
	
	self.LifeTime = CurTime() + 0.12
	
	if self:GetCharge() > 0 then
		self.UltSound = CreateSound(self, "weapons/originstaffs/air/tornado/airstaff_tornado.wav")
	end
end

function ENT:Draw()
	
end