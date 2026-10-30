ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

ENT.TrailSound = "weapons/ubersniper/bomb/projectile_whoosh.wav"
ENT.FuseSound = "weapons/blundergat/acidgat_fuse.wav"
ENT.CollideSound = "weapons/ubersniper/bomb/projectile_impact.ogg"
ENT.FuseDelay = 0.7
ENT.FuseTime = 3
ENT.Attached = false
ENT.Exploded = false

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "LifeTime")
end

function ENT:Initialize()
	self:EnableCustomCollisions(true)

	if SERVER then
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetSolid(SOLID_BBOX)
		self:SetModel("models/weapons/black_ops_2/blundergat/acidgat_projectile.mdl")
		self:SetCollisionBounds(Vector(-2, -2, -2), Vector(2, 2, 2))
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		
		timer.Simple(self.FuseDelay, function()
			if IsValid(self) then
				self:EmitSound(self.FuseSound, 60)
			end
		end)
		
		self:SetLifeTime( CurTime() + self.FuseTime + math.Rand(0, 1.5) )
		self:NextThink(CurTime())
	end
end