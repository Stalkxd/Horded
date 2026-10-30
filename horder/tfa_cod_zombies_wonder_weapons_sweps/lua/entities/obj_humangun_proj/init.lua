AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	if bit.band(mask, self.PhysicsSolidMask) == 0 then return false end
	if bit.band(mask, CONTENTS_MONSTER) > 0 then return true end
end


function ENT:StartTouch(ent)
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	if ent == self.Owner then return false end
	
	local c = ent:GetClass()
	
	if ent:IsNPC() and ent:GetHullType() != HULL_HUMAN then 
		ent:TakeDamage(200,self.Owner,self.Weapon)
		
		ParticleEffect(self.CollidePCF, data.HitPos, angle_zero)
		self:EmitSound("weapons/humangun/projectile/impact_0"..math.random(0,1)..".ogg", 70)
		self:EmitSound("weapons/humangun/growl_0"..math.random(2,3)..".ogg", 70, 100, 1, CHAN_WEAPON)
		
		self:Remove()
		return true 
	end
	
	if ent:IsPlayer() then
		self:EmitSound("weapons/humangun/projectile/impact_0"..math.random(0,1)..".ogg", 70)
		self:EmitSound("weapons/humangun/growl_0"..math.random(2,3)..".ogg", 70, 100, 1, CHAN_WEAPON)
		
		if timer.Exists(ent:EntIndex().."vr11_instakill_decay") then
			timer.Remove(ent:EntIndex().."vr11_instakill_decay")
		end
		ent:SetNW2Bool("vr11_instakill", self:GetUpgraded())
		ent:SetNW2Bool("vr11_invisplayer", true)
		ent:SetNoTarget( true )
		
		ParticleEffectAttach(self.AuraPCF, PATTACH_POINT_FOLLOW, ent, 3)
		
		if ent.SetTargetPriority then
			ent:SetTargetPriority(TARGET_PRIORITY_NONE)
		end
		timer.Create(ent:EntIndex().."vr11_instakill_decay", 10, 1, function() 
			if !IsValid(ent) then return end
			ent:SetNW2Bool("vr11_instakill", false)
			ent:SetNW2Bool("vr11_invisplayer", false)
			ent:SetNoTarget( false )
			
			ent:StopParticles()
			
			if engine.ActiveGamemode():lower() == "nzombies" then
				if IsValid(nzPowerUps.ActivePlayerPowerUps[ent]) then
					if !nzPowerUps:IsPlayerPowerupActive(ent, "zombieblood") then
						ent:SetTargetPriority(TARGET_PRIORITY_PLAYER)
					end
				else
					ent:SetTargetPriority(TARGET_PRIORITY_PLAYER)
				end
			end
		end)
		self:Remove()
	elseif c == "nextbot_vrill_human" and self:GetUpgraded() then
		ent:Explode()
		self:Remove()
	elseif c == "nz_zombie_boss_romero" then
		if ent:WaterLevel() == 0 then
			ent:DirectorCalm()
		elseif self:GetUpgraded() then
			ent:TakeDamage(ent:Health(), self.Owner, self)
		end
		ParticleEffect(self.CollidePCF, data.HitPos, angle_zero)
		self:EmitSound("weapons/humangun/projectile/impact_0"..math.random(0,1)..".ogg", 70)
		self:Remove()
	elseif string.find(c, "nz_zombie_boss") then
		ent:TakeDamage(self:GetUpgraded() and math.max(ent:GetMaxHealth()/3, 2000) or math.max(ent:GetMaxHealth()/6, 1000), self.Owner, self)
		ParticleEffect(self.CollidePCF, data.HitPos, angle_zero)
		self:EmitSound("weapons/humangun/projectile/impact_0"..math.random(0,1)..".ogg", 70)
		self:Remove()
	elseif c != "nextbot_vrill_human" then
		if ent:IsNextBot() or ent:IsNPC() then
			ParticleEffect(self.CollidePCF, data.HitPos, angle_zero)
			local nb = ents.Create("nextbot_vrill_human")
			nb:SetPos(ent:GetPos())
			nb:SetAngles(ent:GetAngles())
			nb:SetUpgraded(self:GetUpgraded())
			nb:Spawn()
			nb.Owner = self.Owner
			SafeRemoveEntity(ent)
			--BroadcastLua("AddVRAura("..ent:EntIndex()..")")
			ParticleEffect(self.CollidePCF, data.HitPos, angle_zero)
			self:EmitSound("weapons/humangun/projectile/impact_0"..math.random(0,1)..".ogg", 70)
			self:EmitSound("weapons/humangun/growl_0"..math.random(2,3)..".ogg", 70, 100, 1, CHAN_WEAPON)
			self:Remove()
		end
	end
	if ent:IsWorld() then
		ParticleEffect(self.CollidePCF, data.HitPos, angle_zero)
		self:EmitSound("weapons/humangun/projectile/impact_0"..math.random(0,1)..".ogg", 70)
		self:EmitSound("weapons/humangun/growl_0"..math.random(2,3)..".ogg", 70, 100, 1, CHAN_WEAPON)
		self:Remove()
	end
	return true
end

function ENT:Think()
	if CurTime() > self.LifeTime then
		self:Remove()
	end
end