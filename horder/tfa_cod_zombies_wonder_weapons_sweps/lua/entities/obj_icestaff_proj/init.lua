AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:FreezeNearby(radius)
	for k, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
		if v:Health() <= 0 then continue end
		
		local dmgFilter = v:GetInternalVariable("m_hDamageFilter") -- Ignore anything that filters out freeze damage.
		if IsValid(dmgFilter) and !dmgFilter:PassesDamageFilter(self.DamageInfo) then continue end
		
		if !v:IsPlayer() and !v:IsNPC() and !v:IsNextBot() then continue end
		if v:IsPlayer() and (v == self.Owner or !hook.Run("PlayerShouldTakeDamage", v, self.Owner)) then continue end
		
		if v:Health() > self.DamageInfo:GetDamage() + 1 then
			v:SetMaterial("models/weapons/black_ops_1/freeze_gun/rus_ter_ice_slush")
			ParticleEffectAttach("frost_char_cloud", PATTACH_POINT_FOLLOW, v, 2)
			
			if SERVER then
				v:SetNW2Float( "IceStaffSlow", 8 )
				v:TakeDamageInfo(self.DamageInfo)
				tfaww_icestaffed[v:EntIndex()] = v
				
				if v.RestoreSpeed == nil then
					if v:IsNextBot() then
						v.RestoreSpeed = v.loco:GetDesiredSpeed()
						v.loco:SetDesiredSpeed(v.RestoreSpeed*0.25)
					elseif v:IsNPC() then
						v:SetPlaybackRate(0.25)
					else
						v.RestoreSpeed = v:GetMaxSpeed()
						v:SetMaxSpeed(v.RestoreSpeed*0.25)
						v:ConCommand("pp_mat_overlay hud/freeze_screen")
					end
				end
			end
		elseif v:Health() > 1 then
			v:SetMaterial("models/weapons/black_ops_1/freeze_gun/rus_ter_ice_slush")
			ParticleEffectAttach("frost_char_cloud", PATTACH_POINT_FOLLOW, v, 2)
			
			if SERVER then
				v:SetNW2Float( "IceStaffSlow", math.Rand(1,3) )
				if not HORDE then v:SetHealth(1) end
				v.LastIceAttacker = self.Owner
				v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				tfaww_icestaffed[v:EntIndex()] = v
				
				if v:IsNextBot() then
					v.BehaveThread = coroutine.create(function() -- Cripple the nextbot
						coroutine.wait(6)
						v.BehaveThread = oldThread
					end)
					v.loco:SetDesiredSpeed(0)
				elseif v:IsNPC() then
					v:SetSchedule(SCHED_NPC_FREEZE)
				else
					v:Freeze(true)
				end
				v:SetPlaybackRate(0.1)
			end
		end
	end
end

function ENT:UltimateAbility(pos)
	if SERVER then
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
	self:StopParticles()
	self:SetPos(pos)
	self:SetAngles(angle_zero)
	--self:EmitSound("weapons/originstaffs/ice/storm/ice_staff_storm_imp.ogg")
	if self.UltSound then self.UltSound:Play() end
	self.LifeTime = CurTime() + self.Charge * 5
	util.ScreenShake(pos, 3, 4, self.Charge * 5 + 5, 256)
	ParticleEffectAttach("originstaff_ice_ultimate", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end