ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable 		= false
ENT.RenderGroup		= RENDERGROUP_BOTH
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
		-- A glowing trail so the shooter can follow the bolt
		util.SpriteTrail(self, 0, Color(255, 90, 40), true, 5, 0, 0.35, 1 / 5 * 0.5, "trails/laser")
		
		timer.Simple(self.FuseDelay, function()
			if IsValid(self) then
				self:EmitSound(self.FuseSound, 60, 100, 1, CHAN_AUTO, SND_SHOULDPAUSE)
			end
		end)
	end
end

if CLIENT then
	local glow = Material("sprites/light_glow02_add")
	local col = Color(255, 70, 30)
	local col_wall = Color(255, 70, 30, 110)

	-- A pulsing glow that beats faster as the fuse runs out, so it is clear where the bolt
	-- landed and when it will go off. The shooter also sees their own bolts through walls.
	function ENT:Draw()
		self:DrawModel()
		if self:GetExploded() then return end
		local left = math.max(self:GetLifeTime() - CurTime(), 0)
		local rate = 3 + (1 - left / self.FuseTime) * 14
		local size = 18 + 10 * math.abs(math.sin(CurTime() * rate))
		local pos = self:GetPos()
		render.SetMaterial(glow)
		render.DrawSprite(pos, size, size, col)
		if self:GetOwner() == LocalPlayer() then
			cam.IgnoreZ(true)
			render.DrawSprite(pos, size * 0.6, size * 0.6, col_wall)
			cam.IgnoreZ(false)
		end
	end

	function ENT:Think()
		if self:GetExploded() then return end
		local light = DynamicLight(self:EntIndex())
		if light then
			light.pos = self:GetPos()
			light.r, light.g, light.b = 255, 70, 30
			light.brightness = 2
			light.decay = 1000
			light.size = 96
			light.dietime = CurTime() + 0.1
		end
	end
end
