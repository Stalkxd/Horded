ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_MOVEABLE + CONTENTS_LADDER + CONTENTS_MONSTER

ENT.TrailSound = "weapons/ubersniper/bomb/projectile_whoosh.wav"
ENT.FuseSound = "weapons/ubersniper/bomb/us_bomb_rampup.ogg"
ENT.FuseDelay = 0.5
ENT.FuseTime = 3.25
ENT.ImpactDamageMult = 0.1 -- share of the weapon's damage dealt when the bolt sticks in an enemy
ENT.CollideSound = "weapons/ubersniper/bomb/projectile_impact.ogg"

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "LifeTime")
	self:NetworkVar( "Bool", 0, "Exploded")
	self:NetworkVar( "Bool", 1, "Upgraded")
end

function ENT:Initialize()
	self:EnableCustomCollisions(true)

	if SERVER then
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_DEFAULT)
		self:SetSolid(SOLID_BBOX)
		self:SetModel("models/weapons/black_ops_1/scavenger/scavenger_projectile.mdl")
		self:SetCollisionBounds(Vector(-2, -2, -2), Vector(2, 2, 2))
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		
		self:SetLifeTime(CurTime() + self.FuseTime)
		
		timer.Simple(self.FuseDelay, function()
			if IsValid(self) then
				self:EmitSound(self.FuseSound, 60, 100, 1, CHAN_AUTO, SND_SHOULDPAUSE)
			end
		end)
	end
end