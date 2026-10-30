AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:TestCollision( startpos, delta, isbox, extents, mask ) -- Ensure we only collide with the right things.
	return bit.band(mask, self.PhysicsSolidMask) > 0
end

function ENT:StartTouch(ent)
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	if ent == self.Owner then return false end
	
	for k, v in pairs(ents.FindInSphere(data.HitPos, 128)) do
		if !v:IsNPC() and !v:IsNextBot() and !(v:IsPlayer() and cvars.Bool("nz_shrinkray_shrinkplayers")) then continue end
		if v:GetNW2Bool("IsBaby") then continue end
		if TFAWW_SkipEffect and TFAWW_SkipEffect(v) then continue end -- Horde: not on players, bosses or elites
		
		v:SetModelScale(0.4,0.5)
		v:EmitSound( "weapons/shrinkray/effects/evt_shrink.ogg" )
		ParticleEffectAttach( "babygun_ring", PATTACH_POINT_FOLLOW, v, 1 )
		if v:LookupBone("ValveBiped.Bip01_Head1") ~= nil then
			v:ManipulateBoneScale(v:LookupBone("ValveBiped.Bip01_Head1"),Vector(3.5,3.5,3.5))
		end
		v:SetNW2Bool("IsBaby",true)
		v:SetNW2Bool("ShouldKickBaby",true)
		v:SetNW2Int("backuphealth", v:Health())
		if not HORDE then v:SetHealth(1) end
		v:SetNW2Bool("BabyOnGround",false)
		if v:IsPlayer() then
			v:SetViewOffset(Vector(0,0,25))
		end
		timer.Create("BabyReset"..v:EntIndex(), math.Rand(self.Timer,self.Timer + 0.15), 1, function()
			if v:IsValid() and v:OnGround() and v:GetNW2Bool("IsBaby") then
				v:SetModelScale(1,0.5)
				v:SetHealth(v:GetNW2Int("backuphealth"))
				if v:LookupBone("ValveBiped.Bip01_Head1") ~= nil then
					v:ManipulateBoneScale(v:LookupBone("ValveBiped.Bip01_Head1"),Vector(1,1,1))
				end
				v:SetNW2Bool("IsBaby",false)
				v:SetNW2Bool("ShouldKickBaby",false)
				v:EmitSound( "weapons/shrinkray/effects/evt_unshrink.ogg" )
				ParticleEffectAttach( "babygun_ring_inverted", PATTACH_POINT_FOLLOW, v, 1 )
				if v:IsPlayer() then
					v:SetViewOffset(Vector(0,0,64))
				end
			end
		end)
	end
	
	if ent:IsWorld() then
		self:EmitSound("weapons/shrinkray/plr/wpn_shrink_plr_flux.ogg")
		ParticleEffect( self:GetUpgraded() and "babygun_impact_pap" or "babygun_impact", self:GetPos(), angle_zero, nil )
		SafeRemoveEntity(self)
	end
end

function ENT:Think()
	if CurTime() > self.LifeTime then
		self:Remove()
	end
end