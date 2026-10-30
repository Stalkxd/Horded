AddCSLuaFile("shared.lua")
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
	
	if ent == self.Owner or ent:GetNW2Bool("IsInflating") then return false end
	
	self:Explode(ent, data.HitPos, data.HitNormal)
	
	return true
end

function ENT:Think()
	if CurTime() > self.LifeTime then
		self:Remove()
	end
end

function ENT:Explode(ent, pos, normal)
	local own = self.Owner
	-- Horde: the delayed kill uses the weapon as inflictor so it is capped like the zap guns,
	-- and a cooked enemy takes at most CookDamage
	local wep = IsValid(self.Inflictor) and self.Inflictor or self
	local cook = self.CookDamage or 1000
	
	local d = DamageInfo()
	d:SetDamage(1)
	d:SetInflictor(wep)
	d:SetAttacker(own)
	d:SetDamageForce( vector_up * 2048 )
	d:SetDamageType(DMG_ENERGYBEAM)

	for k, v in pairs(ents.FindInSphere(pos, 256)) do
		local dmgFilter = v:GetInternalVariable("m_hDamageFilter")
		if IsValid(dmgFilter) and !dmgFilter:PassesDamageFilter(d) then continue end
		
		if !(v:IsNPC() or v:IsNextBot()) then continue end
		if HORDE_WW and IsValid(own) and !HORDE_WW.IsHostile(own, v) then continue end
		if v:GetNW2Bool("IsInflating") then continue end

		if TFAWW_Resists and TFAWW_Resists(v) then -- Horde: bosses and elites take damage instead of inflating
			d:SetDamage(v:GetMaxHealth()/3)
			v:TakeDamageInfo(d)
			continue
		end
		
		if string.find( v:GetClass(), "boss", 1, true) then
			d:SetDamage( v:GetMaxHealth()/3 )
			if d:GetDamage() < v:Health() then
				v:TakeDamageInfo(d)
				continue
			end
		end
		
		v:SetNW2Bool("IsInflating", true)
		
		v:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		
		if v:IsNextBot() then
			local oldThread = v.BehaveThread
			v.BehaveThread = coroutine.create(function() -- Cripple the nextbot
				coroutine.wait(6)
				v.BehaveThread = oldThread
			end)
			v.loco:SetDesiredSpeed(0)
		elseif v:IsNPC() then
			v:SetSchedule(SCHED_NPC_FREEZE)
		end
		
		timer.Simple(math.Rand(3,4), function()
			if IsValid(v) then
				if v:IsNPC() then v:SetSchedule(SCHED_ALERT_STAND) end
				--[[local d = DamageInfo()
				d:SetInflictor(self)
				d:SetAttacker(own)]]
				if IsValid(wep) then d:SetInflictor(wep) end
				d:SetDamage(math.min(v:Health(), cook))
				v:TakeDamageInfo(d)
				-- Survivors (enemies with more health than a cook) are free to move again
				if IsValid(v) and v:Health() > 0 then
					v:SetNW2Bool("IsInflating", false)
					v:SetCollisionGroup(COLLISION_GROUP_NPC)
				end
			end
		end)
		
		timer.Simple(1,function() if IsValid(v) then v:EmitSound("weapons/zapwavegun/microwave_cooking.ogg", 75, 100, 1, CHAN_AUTO, SND_SHOULDPAUSE) end end)
		
	end
	
	ParticleEffect( self:GetUpgraded() and "wgun_impact_pap" or "wgun_impact", pos, self:GetAngles() )
	self:EmitSound(self.CollideSND)
	
	if !ent:IsNPC() and !ent:IsNextBot() and !ent:IsPlayer() and ent:Health() > 0 then
		d:SetDamage(math.min(ent:Health(), cook))
		ent:TakeDamageInfo(d)
	end
	if ent:IsWorld() then
		SafeRemoveEntity(self)
	end
end