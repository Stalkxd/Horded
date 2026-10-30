--Origins staffs
if SERVER then
	AddCSLuaFile()

	tfaww_icestaffed = {
		
	}
	timer.Create("tfaww_icestaff_timer", 0.25, 0, function()
		for k, v in pairs(tfaww_icestaffed) do
			if !IsValid(v) or v:Health() <= 0 then
				tfaww_icestaffed[k] = nil
				continue
			end
			
			v:SetNW2Float("IceStaffSlow", math.max(v:GetNW2Float("IceStaffSlow", 1) - 0.25, 0))
			
			if v:GetNW2Float("IceStaffSlow", 0) <= 0 then
				if v:Health() > 1 then
					v:SetMaterial("")
					v:StopParticles()
					if v:IsNextBot() then
						v.loco:SetDesiredSpeed(v.RestoreSpeed)
					elseif v:IsNPC() then
						v:SetPlaybackRate(1)
					elseif v:IsPlayer() then
						v:SetMaxSpeed(v.RestoreSpeed)
						v:ConCommand("pp_mat_overlay ()")
					end
					v.RestoreSpeed = nil
					tfaww_icestaffed[k] = nil
				else
					v:TakeDamage( 2, v.LastIceAttacker )
				end
			end
		end
	end)
end

hook.Add("EntityTakeDamage", "IceStaffBreak", function(target, dmginfo)
	if tfaww_icestaffed[target:EntIndex()] == target and dmginfo:GetDamage() >= target:Health() then
		--[[if target.shattered then -- prevent recursion
			tfaww_icestaffed[target:EntIndex()] = nil
			dmginfo:SetDamageType(bit.bor(DMG_REMOVENORAGDOLL, DMG_VEHICLE))
		else]]
			target:StopParticles()
			target:SetMaterial("")
			ParticleEffectAttach( "frost_break_cloud", PATTACH_ABSORIGIN, target, 0 )
			target:EmitSound("weapons/wintershowl/zombie/shatter/shatter_0"..math.random(0,2)..".ogg")
			target:SetNW2Float("IceStaffSlow", 0)
			--target.shattered = true -- prevent recursion
			tfaww_icestaffed[target:EntIndex()] = nil
			dmginfo:SetDamageType(DMG_VEHICLE)
			
			if target:IsNPC() then
				target:SetSchedule(SCHED_NONE)
			elseif target:IsPlayer() then
				target:Freeze(false)
				target:SetPlaybackRate(1)
				target:ConCommand("pp_mat_overlay ()")
			end
			
			--[[timer.Simple(0, function()
				target:TakeDamageInfo(dmginfo)
			end)
			return true
		end]]
	end
end)
hook.Add("CreateEntityRagdoll","IceStaffRagdoll",function(ent,rag)
	if IsValid(ent) and ent:GetNW2Float("IceStaffSlow", -16) != -16 then
		rag:Remove()
	end
end)
hook.Add("CreateClientsideRagdoll","IceStaffRagdollCL",function(ent,rag)
	if IsValid(ent) and ent:GetNW2Float("IceStaffSlow", -16) != -16 then
		rag:Remove()
	end
end)

--Ray gun
hook.Add("EntityTakeDamage", "RayGunPlayerNerf", function(target, dmg)
	if target:IsPlayer() and IsValid(dmg:GetInflictor()) and dmg:GetInflictor():GetClass() == "obj_rgun_proj" then
		dmg:SetDamage(50)
	end
end)

--Shrink ray

if CLIENT then
	hook.Add("Think","KickBabyGunClient",function()
		--for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 36)) do
		local pos = LocalPlayer():GetPos()
		local mins, maxs = LocalPlayer():GetCollisionBounds()
		mins = mins * 1.2
		maxs = maxs * 1.2
		maxs.z = LocalPlayer():GetStepSize()
		for k, v in pairs(ents.FindInBox(pos + mins, pos + maxs)) do
			if v:GetNW2Bool("IsBaby") and v:GetNW2Bool("ShouldKickBaby") and v != LocalPlayer() then
				--print(v)
				net.Start( "nzBabyKicked", false )
				net.WriteEntity( v )
				net.SendToServer()
			end
		end
	end)
end

local kickSoundTable = {
	["weapons/zmb/mini/kicked/zmb_mini_kicked01.ogg"] = true, 
	["weapons/zmb/mini/kicked/zmb_mini_kicked02.ogg"] = true, 
	["weapons/zmb/mini/kicked/zmb_mini_kicked03.ogg"] = true, 
	["weapons/zmb/mini/kicked/zmb_mini_kicked04.ogg"] = true
}
local babyDieTable = {
	["weapons/zmb/mini/squashed/zmb_mini_squashed01.ogg"] = true, 
	["weapons/zmb/mini/squashed/zmb_mini_squashed02.ogg"] = true, 
	["weapons/zmb/mini/squashed/zmb_mini_squashed03.ogg"] = true, 
	["weapons/zmb/mini/squashed/zmb_mini_squashed04.ogg"] = true
}
local babySizeTable = {
	["weapons/shrinkray/effects/evt_unshrink.ogg"] = true, 
	["weapons/shrinkray/effects/evt_shrink.ogg"] = true
}

local forcemul = 800
if SERVER then
	CreateConVar( "nz_shrinkray_shrinkplayers", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enables/Disables the 31-79 JGb215's ability to shrink players." )
	
	util.AddNetworkString( "nzBabyKicked" )
	net.Receive("nzBabyKicked", function(num, ply)
		local ent = net.ReadEntity()
		
		if !ent:GetNW2Bool("ShouldKickBaby") then return end
		
		local plypos = ply:GetPos()
		local plymins, plymaxs = ply:GetCollisionBounds()
		plymins = plymins * 1.2
		plymaxs = plymaxs * 1.2
		plymaxs.z = ply:GetStepSize()
		local entpos = ply:GetPos()
		local entmins, entmaxs = ent:GetCollisionBounds()
		
		if !util.IsBoxIntersectingBox( plypos + plymins, plypos + plymaxs, entpos + entmins, entpos + entmaxs ) then return end
		
		ent:SetNW2Bool("ShouldKickBaby", false)
		ent:EmitSound(table.GetKeys( kickSoundTable )[math.random(1, 4)] )
		ent:SetGroundEntity(nil)
		local aim = ply:GetForward()
		
		if ent:IsNextBot() then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(5)
			dmginfo:SetDamageForce( Vector(aim.x*forcemul*100, aim.y*forcemul*100, math.random(4000,7000)) )
			dmginfo:SetAttacker(ply)
			
			ent:SetPos(entpos + Vector(0,0,32))
			ent:TakeDamageInfo(dmginfo)
			local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
			if bone ~= nil then
				ent:ManipulateBoneScale(bone,Vector(1,1,1))
			end
			return
		end
		
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:SetLocalAngularVelocity(Angle(math.random(250,500),math.random(0,5),0))
		ent:SetVelocity( Vector(aim.x*forcemul, aim.y*forcemul, math.random(400,550)) )
		timer.Remove("BabyReset"..ent:EntIndex())
		timer.Create("BabyHitGround"..ent:EntIndex(), 0.1, 0, function() 
			if IsValid(ent) and ent:OnGround() then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(5)
				dmginfo:SetAttacker(ply)
				ent:TakeDamageInfo(dmginfo)
				ent:EmitSound(table.GetKeys(babyDieTable)[math.random(1, 4)])
				
				local gib = ents.Create("ent_gib")
				gib:SetPos(ent:GetPos() + vector_up)
				gib:Spawn()
				local phys = gib:GetPhysicsObject()
				if (phys:IsValid()) then
					phys:SetVelocity(Vector(math.random(-50,50),math.random(-50,50),150) * math.random(2,3))
				end
				util.Decal("Blood", ent:GetPos() + Vector(0, 0, 8), ent:GetPos() - Vector(0, 0, 8))
				ent:Remove()
			end
		end)
		
	end)
end

hook.Add("EntityTakeDamage", "BabyHit", function(target, dmginfo)
	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():GetNW2Bool("IsBaby") then
		dmginfo:SetDamage(dmginfo:GetDamage()*0.2)
	end
end)

hook.Add("EntityEmitSound", "BabySounds", function(data)
	-- Validate entity to prevent error
	if not IsValid(data.Entity) or not data.Entity:GetNW2Bool("IsBaby") then
		return
	end

	local bSoundAlreadyExists = babyDieTable[data.OriginalSoundName] or kickSoundTable[data.OriginalSoundName] or babySizeTable[data.OriginalSoundName]
	if !bSoundAlreadyExists then
		data.Pitch = 168
		return true
	end
end)

--V-R11
hook.Add( "EntityTakeDamage", "vr11_insta_hook", function(ent, dmginfo) 
	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker) and attacker:GetNW2Bool("vr11_instakill") then
		-- Horde: a damage boost instead of instakills
		if HORDE then dmginfo:ScaleDamage(1.5) else dmginfo:AddDamage( ent:Health() ) end
	end
end)

hook.Add("RenderScreenspaceEffects", "DrawVR11Overlay", function() 
	if LocalPlayer():GetNW2Bool("vr11_invisplayer") then
		DrawMaterialOverlay( "models/props_lab/tank_glass001", 0.1 )
	end
end)

--Zap Guns
hook.Add("CreateEntityRagdoll", "WaveGunInflate", function(owner, ragdoll)
	if owner:GetNW2Bool("IsInflating") then
		ragdoll.bonescale = 1
		local inflatetimer = tostring("Inflate"..owner:EntIndex())
		
		ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		for i=0, ragdoll:GetPhysicsObjectCount()-1 do
			local phys = ragdoll:GetPhysicsObjectNum(i)
			phys:EnableGravity(false)
			phys:SetVelocity(VectorRand(-16, 16))
		end
		
		if CLIENT then
			timer.Create(inflatetimer, 0.05, 100, function()
				if !ragdoll or !ragdoll.bonescale then return end
				if ragdoll.bonescale >= 2 then
					timer.Stop(inflatetimer)
					timer.Remove(inflatetimer)
					ParticleEffectAttach( "wgun_pop", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1 )
					ragdoll:EmitSound("weapons/zapwavegun/microwave_ding.ogg", 100, math.random(90,110))
					timer.Simple(engine.TickInterval(), function() ragdoll:Remove() end)
				end
				ragdoll.bonescale = ragdoll.bonescale + 0.02
				for i=0, ragdoll:GetBoneCount(), 1 do
					ragdoll:ManipulateBoneScale(i,Vector(ragdoll.bonescale,ragdoll.bonescale,ragdoll.bonescale))
				end
			end)
		end
	end
end)
hook.Add("CreateClientsideRagdoll", "WaveGunInflate", function(owner, ragdoll)
	if owner:GetNW2Bool("IsInflating") then
		ragdoll.bonescale = 1
		local inflatetimer = tostring("Inflate"..owner:EntIndex())
		
		ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		for i=0, ragdoll:GetPhysicsObjectCount()-1 do
			local phys = ragdoll:GetPhysicsObjectNum(i)
			phys:EnableGravity(false)
			phys:SetVelocity(VectorRand(-16, 16))
		end
		
		timer.Create(inflatetimer, 0.05, 100, function()
			if !ragdoll or !ragdoll.bonescale then return end
			if ragdoll.bonescale >= 2 then
				timer.Stop(inflatetimer)
				timer.Remove(inflatetimer)
				--ParticleEffect("wgun_pop", ragdoll:WorldSpaceCenter(), angle_zero, nil)
				ParticleEffectAttach( "wgun_pop", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1 )
				ragdoll:EmitSound("weapons/zapwavegun/microwave_ding.ogg", 100, math.random(90,110))
				timer.Simple(engine.TickInterval(), function() ragdoll:Remove() end)
			end
			ragdoll.bonescale = ragdoll.bonescale + 0.02
			for i=0, ragdoll:GetBoneCount(), 1 do
				ragdoll:ManipulateBoneScale(i,Vector(ragdoll.bonescale,ragdoll.bonescale,ragdoll.bonescale))
			end
		end)
	end
end)