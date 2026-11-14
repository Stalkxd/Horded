AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.Model = "models/antlion.mdl"
ENT.StartHealth = 125
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_LARGE

ENT.SightDistance = 10000
ENT.SightAngle = 360
ENT.EnemyXRayDetection = false

ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_COMBINE"}
ENT.FriendlyMinion = true
ENT.CustomBlood_Particle = {}
ENT.BloodDecal = {"YellowBlood"}
ENT.HasMeleeAttack = false
ENT.AnimTbl_MeleeAttack =  {ACT_MELEE_ATTACK1}
ENT.MeleeAttackDistance = 100
ENT.MeleeAttackDamageDistance = 120
ENT.TimeUntilMeleeAttackDamage = 0.8
ENT.NextAnyAttackTime_Melee = false
ENT.MeleeAttackDamage = 30
ENT.MeleeAttackDamageType = DMG_SLASH

ENT.Immune_CombineBall = false
ENT.HasDeathAnimation = false
ENT.HasExtraMeleeAttackSounds = true
ENT.SlowPlayerOnMeleeAttack = false
ENT.SlowPlayerOnMeleeAttack_WalkSpeed = 50
ENT.SlowPlayerOnMeleeAttack_RunSpeed = 70
ENT.SlowPlayerOnMeleeAttackTime = 10
ENT.FootStepTimeRun = 0.2
ENT.FootStepTimeWalk = 0.4
ENT.HasLeapAttack = false
ENT.AnimTbl_LeapAttack = {ACT_JUMP}
ENT.StopLeapAttackAfterFirstHit = true
ENT.LeapAttackAnimationDelay = 0
ENT.LeapDistance = 2000
ENT.LeapToMeleeDistance = 10
ENT.TimeUntilLeapAttackDamage = 1
ENT.NextLeapAttackTime = 5
ENT.NextAnyAttackTime_Leap = 0
ENT.LeapAttackAnimationDecreaseLengthAmount = 0
ENT.LeapAttackDamageDistance = 100
ENT.LeapAttackDamageType = DMG_SLASH
ENT.LeapAttackDamage = 35
ENT.LeapAttackVelocityForward = 100
ENT.LeapAttackVelocityUp = 300
ENT.LeapAttackVelocityRight = 0
ENT.IsGuard = false
ENT.DisableChasingEnemy = true
ENT.DisableWandering = true
ENT.ConstantlyFaceEnemy = true
ENT.ConstantlyFaceEnemy_IfVisible = true
ENT.ConstantlyFaceEnemy_IfAttacking = true

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = {"vjseq_charge_end"}
ENT.RangeAttackEntityToSpawn = "projectile_horde_antlion_bile"
ENT.RangeDistance = 2000
ENT.RangeToMeleeDistance = 0
ENT.TimeUntilRangeAttackProjectileRelease = 0.3
ENT.NextRangeAttackTime = 3
ENT.NextAnyAttackTime_Range = 0.4
ENT.RangeAttackPos_Up = 75

ENT.CanFlinch = 0
ENT.SoundTbl_FootStep = {"npc/antlion/foot1.wav","npc/antlion/foot2.wav","npc/antlion/foot3.wav","npc/antlion/foot4.wav"}
ENT.SoundTbl_Idle = {"npc/antlion/idle1.wav","npc/antlion/idle2.wav","npc/antlion/idle3.wav","npc/antlion/idle4.wav","npc/antlion/idle5.wav"}
ENT.SoundTbl_Alert = {"npc/antlion/attack_double1.wav","npc/antlion/attack_double2.wav","npc/antlion/attack_double3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {""}
ENT.SoundTbl_MeleeAttack = {"npc/antlion/attack_double1.wav"}
ENT.SoundTbl_Pain = {"npc/antlion/pain1.wav"}
ENT.SoundTbl_Death = {"npc/antlion/pain1.wav","npc/antlion/pain2.wav"}
ENT.SoundTbl_LeapAttack = {"npc/antlion/fly.wav"}
ENT.SoundTbl_Impact = {"npc/antlion/shell_impact1.wav","npc/antlion/shell_impact2.wav","npc/antlion/shell_impact3.wav","npc/antlion/shell_impact4.wav"}
ENT.PulseInterval = 5
ENT.LastPulse = CurTime()

ENT.FollowMinDistance = 150
ENT.NextFollowUpdateTime = 0.2
ENT.FollowPlayer = false
ENT.TurningSpeed = 40
ENT.CanChatMessage = false

ENT.AnimTbl_Walk = {ACT_RUN}
ENT.AnimTbl_Run = {ACT_RUN}
ENT.Evolve_Stage = 1
ENT.Base_Health = 100
ENT.Evolve_Health = 0
ENT.Evolve_Health_Max = 100

ENT.LastEvolve = CurTime()
ENT.Horde_Immune_Status_All = true
function ENT:CustomOnInitialize()
	self:SetSkin(0)
	self.NextRangeAttackTime = 2
	self.LastPulse = CurTime()
	self.Owner = self:GetNWEntity("HordeOwner")
	self.properties = self.properties or {level = 1}
	self.level = self.properties.level or 1
	self:SetMaxHealth(self.Base_Health + self.level * 5)
	self:SetModelScale(0.5)
    self:SetModel(self.Model)
    self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	self:SetHealth(self:GetMaxHealth())
	self.MeleeAttackDamage = 30 + self.level * 2
	self.RangeAttackDamage = 25 + self.level
	hook.Run("Horde_OnRaiseAntlion", self.Owner, self)
	self:Horde_ApplyRole()
	self:SetNWInt("Horde_AntlionMode", self.Horde_Mode)
    if self.evolutionmaximum then
        local max_stage = 2
        if self.Owner:Horde_GetPerk("hatcher_metamorphosis") then
            max_stage = 3
        end
        self.Evolve_Stage = max_stage
        self.Evolve_Health = 100
    end
end

--[[ Behaviour

	Stages 1-3 (basic antlions) have three modes. The owner cycles them by
	pressing USE (E) while looking at the antlion:
	  FOLLOW (default): walks beside the owner in formation (two antlions
	                    line up left and right) and spits while moving.
	  GUARD           : holds the spot it was standing on. Spits, and claws
	                    anything that walks into it. Ignores recall.
	  ATTACKER        : hunts on its own with leap, claws and spit. Does not
	                    follow or return to the owner.

	Stage 4 (Antlion Guard) is a melee tank on a leash around the owner. Its
	rush builds speed and damage the longer it runs and plows through anything
	that is not heavy enough to stop it. ]]
local MODE_FOLLOW, MODE_GUARD, MODE_ATTACK = 1, 2, 3
local MODE_NAMES = {
	[MODE_FOLLOW] = "Follow",
	[MODE_GUARD] = "Guard",
	[MODE_ATTACK] = "Attacker",
}
local MODE_NEXT = {
	[MODE_FOLLOW] = MODE_GUARD,
	[MODE_GUARD] = MODE_ATTACK,
	[MODE_ATTACK] = MODE_FOLLOW,
}

local GUARD_LEASH = 750
local FOCUS_LEASH_MULT = 1.5
local FOCUS_TIME = 6
local RECALL_TIME = 3
local PROTECT_RANGE = 900

local CHARGE_MIN_DIST = 250
local CHARGE_MAX_DIST = 900
local CHARGE_COOLDOWN = 8
local CHARGE_MAX_TIME = 5
local CHARGE_RATE_PER_SEC = 0.5   -- speed/damage multiplier gained per second of running
local CHARGE_RATE_PER_PLOW = 0.25 -- and per enemy run over
local CHARGE_RATE_MAX = 2.5

ENT.Horde_Mode = MODE_FOLLOW

function ENT:Horde_IsGuardForm()
	return self.Evolve_Stage >= 4
end

-- Sets attack stats for the current stage and attack switches for the current mode.
function ENT:Horde_ApplyRole()
	local stage = self.Evolve_Stage
	local mode = self.Horde_Mode

	if stage >= 4 then
		self.HasRangeAttack = false
		self.HasMeleeAttack = true
		self.HasLeapAttack = false -- the rush is driven by Horde_ChargeThink
		self.EnemyXRayDetection = false
		self.FindEnemy_CanSeeThroughWalls = false
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- guard shove
		self.MeleeAttackDistance = 110
		self.MeleeAttackDamageDistance = 160
		self.MeleeAttackDamageAngleRadius = 70
		self.TimeUntilMeleeAttackDamage = 0.6
		self.NextMeleeAttackTime = 0.8
		self.MeleeAttackDamageType = DMG_CLUB
		self.HasMeleeAttackKnockBack = true
		self.MeleeAttackKnockBack_Forward1 = 250
		self.MeleeAttackKnockBack_Forward2 = 300
		self.MeleeAttackKnockBack_Up1 = 150
		self.MeleeAttackKnockBack_Up2 = 200
		self.ConstantlyFaceEnemy = false
		self.ConstantlyFaceEnemy_IfVisible = false
		self.ConstantlyFaceEnemy_IfAttacking = false
		self.DisableChasingEnemy = true
		self:Horde_FindChargeAnims()
		return
	end

	local scale = ({0.5, 0.75, 1})[stage] or 1
	self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
	self.MeleeAttackDistance = 40 + 30 * scale
	self.MeleeAttackDamageDistance = 70 + 40 * scale
	self.TimeUntilMeleeAttackDamage = 0.5
	self.NextMeleeAttackTime = 0.6
	self.MeleeAttackDamageType = DMG_SLASH
	self.AnimTbl_LeapAttack = {ACT_JUMP}
	self.LeapDistance = 450
	self.LeapToMeleeDistance = 150
	self.TimeUntilLeapAttackDamage = 0.6
	self.NextLeapAttackTime = 6
	self.LeapAttackDamage = self.MeleeAttackDamage
	self.LeapAttackDamageType = DMG_SLASH
	self.LeapAttackVelocityForward = 250
	self.LeapAttackVelocityUp = 220

	if mode == MODE_ATTACK then
		-- Free hunter: everything on, sees through walls so it keeps hunting.
		self.HasRangeAttack = true
		self.HasMeleeAttack = true
		self.HasLeapAttack = true
		self.RangeToMeleeDistance = 250
		self.DisableChasingEnemy = false
		self.EnemyXRayDetection = true
		self.FindEnemy_CanSeeThroughWalls = true
		self.ConstantlyFaceEnemy = false
		self.ConstantlyFaceEnemy_IfVisible = false
		self.ConstantlyFaceEnemy_IfAttacking = false
	elseif mode == MODE_GUARD then
		-- Turret: stands on its point, spits, claws what touches it.
		self.HasRangeAttack = true
		self.HasMeleeAttack = true
		self.HasLeapAttack = false
		self.RangeToMeleeDistance = 0
		self.DisableChasingEnemy = true
		self.EnemyXRayDetection = false
		self.FindEnemy_CanSeeThroughWalls = false
		self.ConstantlyFaceEnemy = true
		self.ConstantlyFaceEnemy_IfVisible = true
		self.ConstantlyFaceEnemy_IfAttacking = true
	else
		-- Follow: the base's standing spit is off, Horde_FollowThink spits on the move.
		self.HasRangeAttack = false
		self.HasMeleeAttack = false
		self.HasLeapAttack = false
		self.RangeToMeleeDistance = 0
		self.DisableChasingEnemy = true
		self.EnemyXRayDetection = false
		self.FindEnemy_CanSeeThroughWalls = false
		self.ConstantlyFaceEnemy = false
		self.ConstantlyFaceEnemy_IfVisible = false
		self.ConstantlyFaceEnemy_IfAttacking = false
	end
end

function ENT:Horde_SetMode(mode)
	if not MODE_NAMES[mode] then return end
	self.Horde_Mode = mode
	self:SetNWInt("Horde_AntlionMode", mode)
	self.Horde_GuardPos = (mode == MODE_GUARD) and self:GetPos() or nil
	self.Horde_MoveGoal = nil
	self.Horde_FocusTarget = nil
	self.Horde_RecallUntil = 0
	self:Horde_ApplyRole()
	if mode ~= MODE_ATTACK then self:StopMoving() end
end

function ENT:Horde_CycleMode(ply)
	if self:Horde_IsGuardForm() then
		HORDE:SendNotification("The Antlion Guard fights on its own.", 0, ply)
		return
	end
	self:Horde_SetMode(MODE_NEXT[self.Horde_Mode] or MODE_FOLLOW)
	HORDE:SendNotification("Antlion mode: " .. MODE_NAMES[self.Horde_Mode], 0, ply)
	self:EmitSound("npc/antlion/idle" .. math.random(1, 5) .. ".wav", 70, 110)
end

-- USE (E) on your own antlion cycles its mode. Done with an aim cone instead of
-- the engine use trace because the small stages are hard to hit with it.
hook.Add("KeyPress", "Horde_AntlionModeSwitch", function(ply, key)
	if key ~= IN_USE or not IsValid(ply) or not ply:Alive() then return end
	local eye, aim = ply:EyePos(), ply:GetAimVector()
	local best, bestDot = nil, 0.85
	for _, ent in ipairs(ents.FindInSphere(eye, 170)) do
		if ent:GetClass() == "npc_vj_horde_antlion" and ent:GetNWEntity("HordeOwner") == ply then
			local dot = aim:Dot((ent:WorldSpaceCenter() - eye):GetNormalized())
			if dot > bestDot then best, bestDot = ent, dot end
		end
	end
	if IsValid(best) and best.Horde_CycleMode then best:Horde_CycleMode(ply) end
end)

-- Enemy closest to origin that this antlion can see, within maxDist of origin.
function ENT:Horde_FindGuardTarget(origin, maxDist)
	local best, bestDist = nil, maxDist * maxDist
	for _, ent in ipairs(ents.FindInSphere(origin, maxDist)) do
		if ent ~= self and HORDE:IsEnemy(ent) and ent:Health() > 0 then
			local d = ent:GetPos():DistToSqr(origin)
			if d < bestDist and self:Visible(ent) then
				best, bestDist = ent, d
			end
		end
	end
	return best
end

-- Called from the pheropod weapon when the owner holds RMB.
-- Returns false when the antlion refuses to come (holding a guard point).
function ENT:Horde_Recall()
	if not self:Horde_IsGuardForm() and self.Horde_Mode == MODE_GUARD then return false end
	if self.Horde_Charging then self:Horde_EndCharge() end
	self.Horde_RecallUntil = CurTime() + RECALL_TIME
	self.Horde_FocusTarget = nil
	self.Horde_MoveGoal = nil
	self.DisableChasingEnemy = true
	return true
end

-- Run to pos, without restarting the path every think.
function ENT:Horde_MoveTo(pos, tolerance)
	local now = CurTime()
	if self:GetPos():DistToSqr(pos) <= tolerance * tolerance then return end
	local goal = self.Horde_MoveGoal
	local moving = self:IsCurrentSchedule(SCHED_FORCED_GO_RUN)
	if goal and moving and goal:DistToSqr(pos) < 40 * 40 then return end
	if (self.Horde_NextMoveOrder or 0) > now then return end
	self.Horde_NextMoveOrder = now + 0.25
	self.Horde_MoveGoal = pos
	self:SetLastPosition(pos)
	self:SetSchedule(SCHED_FORCED_GO_RUN)
end

-- Bile shot that needs no animation, so it can be used while walking.
-- With aimEnemy set (must be the current enemy) it uses the same spawn point and
-- trajectory solution as the standing range attack, so it is just as accurate.
function ENT:Horde_SpitAt(pos, aimEnemy)
	local projectile = ents.Create(self.RangeAttackEntityToSpawn)
	if not IsValid(projectile) then return end
	local target_pos = pos + Vector(0, 0, 10)
	local start = self:GetPos() + self:GetUp() * self.RangeAttackPos_Up * self:GetModelScale()
	if IsValid(aimEnemy) and self.RangeAttackProjPos then
		local ok, p = pcall(self.RangeAttackProjPos, self, projectile)
		if ok and isvector(p) then start = p end
	end
	projectile.Owner = self
	projectile.BaseDamage = self.RangeAttackDamage
	projectile:SetPos(start)
	projectile:SetAngles((target_pos - start):Angle())
	projectile:SetOwner(self)
	projectile:SetPhysicsAttacker(self)
	projectile:Spawn()
	projectile:Activate()
	local vel
	if IsValid(aimEnemy) and aimEnemy == self:GetEnemy() and self.RangeAttackProjVel then
		local ok, v = pcall(self.RangeAttackProjVel, self, projectile)
		if ok and isvector(v) and v:LengthSqr() > 1 then vel = v end
	end
	if not vel then
		-- Fallback: flat shot with a lift that cancels gravity over the flight time.
		local to = target_pos - start
		local speed = 1500
		local t = math.max(to:Length() / speed, 0.05)
		vel = to / t + Vector(0, 0, 0.5 * physenv.GetGravity():Length() * t)
	end
	local phys = projectile:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetVelocity(vel)
	else
		projectile:SetVelocity(vel)
	end
	projectile:SetAngles(vel:GetNormalized():Angle())
	self:EmitSound("npc/antlion/attack_single" .. math.random(1, 3) .. ".wav", 75, 100)
end

-- Where this antlion walks in Follow mode: beside the owner, relative to where
-- the owner is looking. Two followers take the left and right side (a line).
function ENT:Horde_FormationSlot()
	local owner = self.Owner
	local followers = HORDE:GetPlayerMinions(owner, function(e)
		return e:GetClass() == "npc_vj_horde_antlion" and not e:Horde_IsGuardForm() and e.Horde_Mode == MODE_FOLLOW
	end)
	table.sort(followers, function(a, b) return a:EntIndex() < b:EntIndex() end)
	local index = 1
	for i, e in ipairs(followers) do
		if e == self then index = i break end
	end

	local ang = Angle(0, owner:EyeAngles().y, 0)
	local side = 1 -- alone: right-hand side
	if #followers >= 2 then side = (index % 2 == 1) and -1 or 1 end
	local row = math.floor((index - 1) / 2)
	local offset = ang:Right() * (85 * side) + ang:Forward() * (25 - row * 90)

	local from = owner:GetPos() + Vector(0, 0, 30)
	local tr = util.TraceLine({start = from, endpos = from + offset, mask = MASK_NPCSOLID_BRUSHONLY})
	if tr.Hit then
		return tr.HitPos - offset:GetNormalized() * 25 - Vector(0, 0, 30)
	end
	return owner:GetPos() + offset
end

function ENT:Horde_FollowThink(now)
	self.DisableChasingEnemy = true
	self:Horde_MoveTo(self:Horde_FormationSlot(), 45)

	if (self.Horde_NextSpit or 0) > now then return end
	local ene = self:GetEnemy()
	if not IsValid(ene) or ene:Health() <= 0 then return end
	if ene:GetPos():DistToSqr(self:GetPos()) > self.RangeDistance * self.RangeDistance then return end
	if not self:Visible(ene) then return end
	self.Horde_NextSpit = now + (self.NextRangeAttackTime or 2)
	self:Horde_SpitAt(ene:GetPos() + ene:OBBCenter(), ene)
end

function ENT:Horde_GuardPointThink(now)
	self.DisableChasingEnemy = true
	local point = self.Horde_GuardPos
	if not point then
		point = self:GetPos()
		self.Horde_GuardPos = point
	end
	-- Knocked or pushed off the point: walk back once the current attack is done.
	if not self:BusyWithActivity() then
		self:Horde_MoveTo(point, 50)
	end
end

function ENT:Horde_GuardFormThink(now, focus)
	if self.Horde_Charging then return end
	local ownerPos = self.Owner:GetPos()
	local ene = self:GetEnemy()
	local leash = GUARD_LEASH
	if IsValid(focus) and ene == focus then leash = leash * FOCUS_LEASH_MULT end
	local canChase = IsValid(ene) and ene:Health() > 0 and ene:GetPos():DistToSqr(ownerPos) <= leash * leash
	self.DisableChasingEnemy = not canChase
	self.HasMeleeAttack = canChase or (IsValid(ene) and ene:GetPos():DistToSqr(self:GetPos()) < 200 * 200)

	if canChase and (self.Horde_NextCharge or 0) <= now and not self:BusyWithActivity() then
		local d = ene:GetPos():DistToSqr(self:GetPos())
		if d >= CHARGE_MIN_DIST * CHARGE_MIN_DIST and d <= CHARGE_MAX_DIST * CHARGE_MAX_DIST and self:Visible(ene) then
			self:Horde_StartCharge(ene)
			return
		end
	end

	-- Out of the fight and drifted off: run back to the owner.
	if not canChase and self:GetPos():DistToSqr(ownerPos) > (leash * 0.6) ^ 2 and not self:BusyWithActivity() then
		self:Horde_MoveTo(ownerPos, 150)
	end
end

--[[ Antlion Guard rush
	The guard runs at its target and keeps accelerating. Speed and damage use
	the same multiplier, which grows with time spent running and with every
	enemy run over. Regular enemies are hit, thrown aside and do not stop the
	rush; it then carries on into the next enemy ahead. Only a boss, an elite
	or something with more health than the guard stops it, and only if it
	survives the hit. ]]
-- Finds the guard model's charge animations by name, so it still works if a
-- replacement model names them a little differently.
function ENT:Horde_FindChargeAnims()
	self.Horde_ChargeAct = nil
	self.Horde_ChargeSeqLoop = nil
	self.Horde_ChargeSeqStop = nil
	self.Horde_ChargeSeqHit = nil
	for id, name in pairs(self:GetSequenceList() or {}) do
		local n = string.lower(name)
		if string.find(n, "charge", 1, true) then
			if string.find(n, "loop", 1, true) or string.find(n, "run", 1, true) then
				self.Horde_ChargeSeqLoop = id
			elseif string.find(n, "stop", 1, true) or string.find(n, "end", 1, true) then
				self.Horde_ChargeSeqStop = name
			elseif string.find(n, "hit", 1, true) or string.find(n, "crash", 1, true) then
				self.Horde_ChargeSeqHit = self.Horde_ChargeSeqHit or name
			end
		end
	end
	if self.Horde_ChargeSeqLoop then
		local act = self:GetSequenceActivity(self.Horde_ChargeSeqLoop)
		if act and act > 0 then self.Horde_ChargeAct = act end
	end
end

-- While rushing, the run/walk activity is swapped for the charge animation.
function ENT:TranslateActivity(act)
	if self.Horde_Charging and self.Horde_ChargeAct and (act == ACT_RUN or act == ACT_WALK) then
		return self.Horde_ChargeAct
	end
	local base = self.BaseClass and self.BaseClass.TranslateActivity
	if base then return base(self, act) end
	return act
end

function ENT:Horde_StartCharge(target)
	local now = CurTime()
	if self.Horde_ChargeAct then
		self.Horde_SavedRun, self.Horde_SavedWalk = self.AnimTbl_Run, self.AnimTbl_Walk
		self.AnimTbl_Run = {self.Horde_ChargeAct}
		self.AnimTbl_Walk = {self.Horde_ChargeAct}
	end
	self.Horde_Charging = true
	self.Horde_ChargeStart = now
	self.Horde_ChargeTarget = target
	self.Horde_ChargePlows = 0
	self.Horde_ChargeHit = {}
	self.Horde_ChargeLastPos = self:GetPos()
	self.Horde_ChargeStuckCheck = now + 0.6
	self.Horde_MoveGoal = nil
	self.Horde_NextMoveOrder = 0
	self.HasMeleeAttack = false
	self.DisableChasingEnemy = true
	self:EmitSound("npc/antlion_guard/angry" .. math.random(1, 3) .. ".wav", 90, 100)
end

function ENT:Horde_EndCharge(stopped)
	self.Horde_Charging = false
	if self.Horde_SavedRun then
		self.AnimTbl_Run, self.AnimTbl_Walk = self.Horde_SavedRun, self.Horde_SavedWalk
		self.Horde_SavedRun, self.Horde_SavedWalk = nil, nil
	end
	self.Horde_ChargeTarget = nil
	self.Horde_ChargeHit = nil
	self.Horde_NextCharge = CurTime() + CHARGE_COOLDOWN
	self.Horde_MoveGoal = nil
	self.AnimPlaybackRate = 1
	self:SetPlaybackRate(1)
	self:StopMoving()
	-- Skid to a halt, or the impact animation when something stopped him.
	local endAnim = stopped and self.Horde_ChargeSeqHit or self.Horde_ChargeSeqStop
	if endAnim and not self.Dead then
		self:PlayAnim("vjseq_" .. endAnim, true, false, false)
	end
end

function ENT:Horde_ChargeRate()
	local t = CurTime() - (self.Horde_ChargeStart or CurTime())
	return math.min(CHARGE_RATE_MAX, 1 + t * CHARGE_RATE_PER_SEC + (self.Horde_ChargePlows or 0) * CHARGE_RATE_PER_PLOW)
end

-- Animation speed for the current rate. The charge animation is already fast,
-- so it ramps over a narrower band than the plain run fallback.
function ENT:Horde_ChargeAnimRate(rate)
	if not self.Horde_ChargeAct then return rate end
	return 0.8 + (rate - 1) / (CHARGE_RATE_MAX - 1) * 0.8
end

function ENT:Horde_CanStopCharge(ent)
	if ent:GetVar("is_boss") then return true end
	if ent.is_elite then return true end
	if isfunction(ent.Horde_IsElite) then
		if ent:Horde_IsElite() then return true end
	elseif ent.Horde_IsElite then
		return true
	end
	return ent:GetMaxHealth() > self:GetMaxHealth()
end

function ENT:Horde_NextChargeTarget()
	local myPos, fwd = self:GetPos(), self:GetForward()
	local best, bestDist = nil, 600 * 600
	for _, ent in ipairs(ents.FindInSphere(myPos, 600)) do
		if HORDE:IsEnemy(ent) and ent:Health() > 0 and not self.Horde_ChargeHit[ent] then
			local to = ent:GetPos() - myPos
			local d = to:LengthSqr()
			to.z = 0
			to:Normalize()
			if d < bestDist and fwd:Dot(to) > 0.3 and self:Visible(ent) then
				best, bestDist = ent, d
			end
		end
	end
	return best
end

function ENT:Horde_ChargeThink()
	local now = CurTime()
	local myPos = self:GetPos()
	local rate = self:Horde_ChargeRate()

	-- Run animation speed drives ground speed, so the rate is the speed-up.
	local animRate = self:Horde_ChargeAnimRate(rate)
	self.AnimPlaybackRate = animRate
	self:SetPlaybackRate(animRate)

	if now - self.Horde_ChargeStart > CHARGE_MAX_TIME then return self:Horde_EndCharge() end
	if myPos:DistToSqr(self.Owner:GetPos()) > (GUARD_LEASH * 1.6) ^ 2 then return self:Horde_EndCharge() end
	if self.Horde_ChargeStuckCheck <= now then
		if myPos:DistToSqr(self.Horde_ChargeLastPos) < 20 * 20 then return self:Horde_EndCharge() end
		self.Horde_ChargeLastPos = myPos
		self.Horde_ChargeStuckCheck = now + 0.5
	end

	-- Run over whatever is in front.
	local fwd = self:GetForward()
	for _, ent in ipairs(ents.FindInSphere(myPos + fwd * 70 + Vector(0, 0, 40), 115)) do
		if ent ~= self and HORDE:IsEnemy(ent) and ent:Health() > 0 and not self.Horde_ChargeHit[ent] then
			self.Horde_ChargeHit[ent] = true
			local heavy = self:Horde_CanStopCharge(ent)
			local dir = ent:GetPos() - myPos
			dir.z = 0
			dir:Normalize()

			local dmg = DamageInfo()
			dmg:SetDamage(self.MeleeAttackDamage * 1.25 * rate)
			dmg:SetDamageType(DMG_CLUB)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			dmg:SetDamagePosition(ent:WorldSpaceCenter())
			dmg:SetDamageForce(dir * 20000 * rate + Vector(0, 0, 8000))
			ent:TakeDamageInfo(dmg)
			self:EmitSound("npc/antlion_guard/shove1.wav", 85, math.random(95, 110))

			local alive = IsValid(ent) and ent:Health() > 0
			if alive and heavy then
				-- Something big enough took the hit: the rush ends here.
				util.ScreenShake(myPos, 6, 5, 0.6, 500)
				return self:Horde_EndCharge(true)
			end
			self.Horde_ChargePlows = self.Horde_ChargePlows + 1
			if alive then
				-- Survivor that cannot stop him gets thrown out of the way.
				local side = fwd:Cross(Vector(0, 0, 1)) * (math.random(0, 1) == 0 and -1 or 1)
				ent:SetGroundEntity(NULL)
				ent:SetVelocity(dir * 250 * rate + side * 200 + Vector(0, 0, 250))
			end
		end
	end

	local target = self.Horde_ChargeTarget
	if not IsValid(target) or target:Health() <= 0 or self.Horde_ChargeHit[target] then
		target = self:Horde_NextChargeTarget()
		self.Horde_ChargeTarget = target
		if not IsValid(target) then return self:Horde_EndCharge() end
		self:ForceSetEnemy(target, false)
	end
	self:Horde_MoveTo(target:GetPos(), 0)
end

ENT.NextRoleThink = 0
ENT.NextTargetThink = 0
function ENT:Horde_RoleThink()
	local now = CurTime()
	local ownerPos = self.Owner:GetPos()
	local guardForm = self:Horde_IsGuardForm()
	local mode = self.Horde_Mode
	if self.Horde_Charging then return end

	if (self.Horde_RecallUntil or 0) > now then
		self.DisableChasingEnemy = true
		return
	elseif self.Horde_RecallUntil and self.Horde_RecallUntil > 0 then
		-- Recall just ended: restore the mode's own switches.
		self.Horde_RecallUntil = 0
		self:Horde_ApplyRole()
	end

	local focus = self.Horde_FocusTarget
	if IsValid(focus) and (focus:Health() <= 0 or (self.Horde_FocusUntil or 0) < now) then focus = nil end
	if not IsValid(focus) then
		focus = nil
		self.Horde_FocusTarget = nil
	end

	-- Target choice. A pod-marked target comes first. Otherwise followers and
	-- the Guard protect the owner, a guarding antlion protects its point, and
	-- an attacker picks its own fights.
	if self.NextTargetThink <= now then
		self.NextTargetThink = now + 1
		local ene = self:GetEnemy()
		if focus then
			if ene ~= focus and self:Visible(focus) then self:ForceSetEnemy(focus, false) end
		elseif guardForm or mode ~= MODE_ATTACK then
			local origin, range = ownerPos, PROTECT_RANGE
			if guardForm then
				range = GUARD_LEASH
			elseif mode == MODE_GUARD then
				origin = self:GetPos()
			end
			local eneFar = not IsValid(ene) or ene:Health() <= 0 or ene:GetPos():DistToSqr(origin) > range * range
			if eneFar then
				local t = self:Horde_FindGuardTarget(origin, range)
				if IsValid(t) and t ~= ene then self:ForceSetEnemy(t, false) end
			end
		end
	end

	if guardForm then
		self:Horde_GuardFormThink(now, focus)
	elseif mode == MODE_FOLLOW then
		self:Horde_FollowThink(now)
	elseif mode == MODE_GUARD then
		self:Horde_GuardPointThink(now)
	else
		self.DisableChasingEnemy = false
	end
end

function ENT:Horde_Evolve(health)
    local max_stage = 3
    if self.Owner:IsValid() and self.Owner:Horde_GetPerk("hatcher_metamorphosis") then
        max_stage = 4
    end
    if self.Evolve_Stage == max_stage then return end

    self.Evolve_Health = self.Evolve_Health + health

    if self.Evolve_Health < self.Evolve_Health_Max then return end
    self.Evolve_Stage = math.min(max_stage, self.Evolve_Stage + 1)

	if self.Evolve_Stage == 2 then
		self:SetSkin(1)
		self:SetMaxHealth(self.Base_Health * 1.5 + self.level * 9)
		self:SetHealth(self:GetMaxHealth())
		self:SetModelScale(0.75)
        self:SetModel(self.Model)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self.MeleeAttackDamage = 45 + self.level * 6
		self.RangeAttackDamage = 35 + self.level * 4
		self.NextRangeAttackTime = 2
	elseif self.Evolve_Stage == 3 then
		self:SetSkin(3)
		self:SetMaxHealth(self.Base_Health * 2 + self.level * 25)
		self:SetHealth(self:GetMaxHealth())
		self:SetModelScale(1)
        self:SetModel(self.Model)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self.MeleeAttackDamage = 60 + self.level * 10
		self.RangeAttackDamage = 45 + self.level * 8
		self.Horde_Immune_Break = true
		self.NextRangeAttackTime = 1
	elseif self.Evolve_Stage == 4 then
		self:SetSkin(0)
		self:SetModelScale(1)
		self.Model = "models/antlion_guard.mdl"
		self:SetModel(self.Model)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self:SetMaxHealth(self.Base_Health * 4 + self.level * 50)
		self:SetHealth(self:GetMaxHealth())
		self.MeleeAttackDamage = 70 + self.level * 15
		self.RangeAttackDamage = 45 + self.level * 8
		self.NextRangeAttackTime = 1
		self.Horde_Immune_Status_All = true
		self:StopMoving()
		self.NextWanderTime = CurTime() + 2
		if !self:BusyWithActivity() then
			self:VJ_TASK_FACE_X("TASK_FACE_TARGET")
		end
		self:Activate()

		self.SoundTbl_Idle = {"npc/antlion_guard/growl_idle.wav"}
		self.SoundTbl_Alert = {"npc/antlion_guard/angry1.wav","npc/antlion_guard/angry2.wav","npc/antlion_guard/angry3.wav"}
		self.SoundTbl_MeleeAttack = {"npc/antlion_guard/shove1.wav"}
		self.SoundTbl_MeleeAttackMiss = {""}
		self.SoundTbl_RangeAttack = {"npc/antlion_guard/angry1.wav"}
		self.SoundTbl_Pain = {""}
		self.SoundTbl_Death = {"npc/antlion_guard/antlion_guard_die1.wav","npc/antlion_guard/antlion_guard_die2.wav"}
		self.SoundTbl_FootStep = {"npc/antlion_guard/foot_heavy1.wav","npc/antlion_guard/foot_heavy2.wav"}
	end
	self.Evolve_Health = self.Evolve_Health - self.Evolve_Health_Max
	self:Horde_ApplyRole()
end

function ENT:Horde_IsStage(x)
	return self.Evolve_Stage >= x
end
local attackTimers = {
	[VJ.ATTACK_TYPE_MELEE] = function(self, skipStopAttacks)
		if !skipStopAttacks then
			timer.Create("attack_melee_reset" .. self:EntIndex(), self:GetAttackTimer(self.NextAnyAttackTime_Melee, self.TimeUntilMeleeAttackDamage, self.AttackAnimDuration), 1, function()
				self:StopAttacks()
				self:MaintainAlertBehavior()
			end)
		end
		timer.Create("attack_melee_reset_able" .. self:EntIndex(), self:GetAttackTimer(self.NextMeleeAttackTime), 1, function()
			self.IsAbleToMeleeAttack = true
		end)
	end,
	[VJ.ATTACK_TYPE_RANGE] = function(self, skipStopAttacks)
		if !skipStopAttacks then
			timer.Create("attack_range_reset" .. self:EntIndex(), self:GetAttackTimer(self.NextAnyAttackTime_Range, self.TimeUntilRangeAttackProjectileRelease, self.AttackAnimDuration), 1, function()
				self:StopAttacks()
				self:MaintainAlertBehavior()
			end)
		end
		timer.Create("attack_range_reset_able" .. self:EntIndex(), self:GetAttackTimer(self.NextRangeAttackTime), 1, function()
			self.IsAbleToRangeAttack = true
		end)
	end,
	[VJ.ATTACK_TYPE_LEAP] = function(self, skipStopAttacks)
		if !skipStopAttacks then
			timer.Create("attack_leap_reset" .. self:EntIndex(), self:GetAttackTimer(self.NextAnyAttackTime_Leap, self.TimeUntilLeapAttackDamage, self.AttackAnimDuration), 1, function()
				self:StopAttacks()
				self:MaintainAlertBehavior()
			end)
		end
		timer.Create("attack_leap_reset_able" .. self:EntIndex(), self:GetAttackTimer(self.NextLeapAttackTime), 1, function()
			self.IsAbleToLeapAttack = true
		end)
	end
}

function ENT:BugPulse()
	local r = {190, 190 * 1.5, 190 * 2, 190 * 2}
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), r[self.Evolve_Stage])) do
		if ent:IsPlayer() then
			local healer = self.Owner
			if not IsValid(healer) then
				healer = self
			else
				hook.Run("Horde_OnAntlionPulse", healer, self, ent)
			end
			local healinfo = HealInfo:New({amount=ent:GetMaxHealth() * 0.05, healer=healer})
			HORDE:OnPlayerHeal(ent, healinfo)
			self:SetHealth(math.min(self:GetMaxHealth(), self:Health() + self:GetMaxHealth() * 0.05))
		end
	end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetRadius(r[self.Evolve_Stage])
	util.Effect("horde_antlion_pulse", effectdata)
	self:EmitSound("horde/weapons/spore_launcher/splauncher_impact.ogg", SNDLVL_NORM, 150, VOL_NORM, CHAN_ITEM)
end


ENT.NextUnstuckCheck = 0
function ENT:OverrideMove(inv)
    if(self.NextUnstuckCheck < CurTime() && self:GetMoveVelocity() == vector_origin) then
        local origin = self:GetPos()
        local result = util.TraceHull({
            start = origin,
            endpos = origin,
            mins = self:OBBMins(),
            maxs = self:OBBMaxs(),
            filter = self,
            ignoreworld = true,
        })
        local ent = result.Entity
        if(IsValid(ent) && ent:GetClass() == self:GetClass() && ent:GetMoveVelocity() == vector_origin) then
            -- Two antlions overlapping: step this one sideways to free space
            -- instead of teleporting it onto the owner's head.
            local width = (self:OBBMaxs().x - self:OBBMins().x) * self:GetModelScale()
            for _ = 1, 6 do
                local dir = VectorRand()
                dir.z = 0
                dir:Normalize()
                local try = origin + dir * (width + 8)
                local tr = util.TraceHull({
                    start = origin, endpos = try,
                    mins = self:OBBMins(), maxs = self:OBBMaxs(),
                    filter = {self, ent}, mask = MASK_NPCSOLID,
                })
                if not tr.StartSolid and tr.Fraction >= 1 then
                    self:SetPos(try)
                    break
                end
            end
            ent.NextUnstuckCheck = CurTime() + 1
        end
        self.NextUnstuckCheck = CurTime() + 0.2
    end
end

ENT.NextLeashCheck = 0
function ENT:CustomOnThink()
	if not IsValid(self.Owner) then return end

	if self.Horde_Charging then
		self:Horde_ChargeThink()
	elseif self.NextRoleThink <= CurTime() then
		self.NextRoleThink = CurTime() + 0.2
		self:Horde_RoleThink()
	end

	-- Teleport back if far away (stuck or left behind), checked every second.
	if self.NextLeashCheck <= CurTime() then
		self.NextLeashCheck = CurTime() + 1
		-- Only for antlions that are meant to stay with the owner.
		local tethered = self:Horde_IsGuardForm() or self.Horde_Mode == 1
		if tethered and not self.Horde_Charging and self:GetPos():DistToSqr(self.Owner:GetPos()) >= 1000000 then
			local v = VectorRand() * 20
			v.z = 0
			self:SetPos(self.Owner:GetPos() + v)
		end
	end

	if self.LastPulse <= CurTime() then
		self:BugPulse()
		local t = 5
		if self.Evolve_Stage == 2 then
			t = 4
		elseif self.Evolve_Stage == 3 then
			t = 3
		end
		self.LastPulse = CurTime() + t
	end

	if self.LastEvolve <= CurTime() then
		self.LastEvolve = CurTime() + 1
		local bonus = {increase = 0}
		hook.Run("Horde_OnAntlionSelfEvolve", self.Owner, self, bonus)
		self:Horde_Evolve(10 * (1 + bonus.increase))
	end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if HORDE:IsPoisonDamage(dmginfo) then
		if self.Evolve_Stage == 2 then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.5)
		elseif self.Evolve_Stage >= 3 then
			dmginfo:SetDamage(0)
		end
    end
end

function ENT:Horde_MarkFocus(pos)
	local best, bestDist = nil, 300 * 300
	for _, ent in ipairs(ents.FindInSphere(pos, 300)) do
		if HORDE:IsEnemy(ent) and ent:Health() > 0 then
			local d = ent:GetPos():DistToSqr(pos)
			if d < bestDist then best, bestDist = ent, d end
		end
	end
	if not IsValid(best) then return end
	self.Horde_FocusTarget = best
	self.Horde_FocusUntil = CurTime() + FOCUS_TIME
	self.Horde_RecallUntil = 0
	self:ForceSetEnemy(best, false)
end

function ENT:RangeAttackLocation(pos)
	self:Horde_MarkFocus(pos)
	if self.Dead or self:Horde_IsGuardForm() then return end
	if self.Horde_Mode == 1 then
		-- Followers answer the pod with a walking spit.
		self.Horde_NextSpit = CurTime() + (self.NextRangeAttackTime or 2)
		self:Horde_SpitAt(pos)
		return
	end
	local selfData = self:GetTable()
	selfData.AttackType = VJ.ATTACK_TYPE_RANGE
	selfData.AttackState = VJ.ATTACK_STATE_STARTED
	self:OnRangeAttack("Init", ene)
	self:PlaySoundSystem("BeforeRangeAttack")
	local seed = CurTime()
	selfData.AttackSeed = seed
	local anim, animDur, animType = self:PlayAnim(selfData.AnimTbl_RangeAttack, false, 0, false, selfData.RangeAttackAnimationDelay)
	timer.Create("attack_range_start" .. self:EntIndex(), selfData.TimeUntilRangeAttackProjectileRelease / selfData.AnimPlaybackRate, selfData.RangeAttackReps, function() if selfData.AttackSeed == seed then self:ExecuteRangeAttack() end end)
	if anim != ACT_INVALID then
		selfData.AttackAnim = anim
		selfData.AttackAnimDuration = animDur - (selfData.RangeAttackAnimationDecreaseLengthAmount / selfData.AnimPlaybackRate)
		if animType != ANIM_TYPE_GESTURE then
			selfData.AttackAnimTime = CurTime() + selfData.AttackAnimDuration
		end
	end
	if !selfData.TimeUntilRangeAttackProjectileRelease then
		attackTimers[VJ.ATTACK_TYPE_RANGE](self)
	else
		timer.Create("timer_range_start"..self:EntIndex(), selfData.TimeUntilRangeAttackProjectileRelease / self:GetPlaybackRate(), selfData.RangeAttackReps, function() self:RangeAttackP(pos) end)
	end
end

function ENT:CustomRangeAttackCode_BeforeProjectileSpawn(projectile)
	projectile.Owner = self
	projectile.BaseDamage = self.RangeAttackDamage
end

function ENT:RangeAttackP(pos)
	local selfData = self:GetTable()
	if selfData.Dead or selfData.PauseAttacks or selfData.Flinching or selfData.AttackType == VJ.ATTACK_TYPE_MELEE then return end
	local ene = self:GetEnemy()
	local eneValid = IsValid(ene)
	selfData.AttackType = VJ.ATTACK_TYPE_RANGE
	if !self:OnRangeAttackExecute("Init", ene) then
		local projectile = ents.Create(self.RangeAttackEntityToSpawn)
		local target_pos = pos + Vector(0, 0, 10)
		projectile.Owner = self
		projectile.BaseDamage = self.RangeAttackDamage
		projectile:SetPos(self:GetPos() + self:GetUp()*self.RangeAttackPos_Up)
		projectile:SetAngles((target_pos - projectile:GetPos()):Angle())
		projectile:SetOwner(self)
		projectile:SetPhysicsAttacker(self)
		projectile:Spawn()
		projectile:Activate()
		local phys = projectile:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			local vel = (target_pos - self:GetAttachment(1).Pos) * 1.5
			phys:SetVelocity(vel)
			projectile:SetAngles(vel:GetNormalized():Angle())
		else
			local vel = self:RangeAttackProjVel(projectile)
			projectile:SetVelocity(vel)
			projectile:SetAngles(vel:GetNormalized():Angle())
		end
		self:OnRangeAttackExecute("PostSpawn", ene, projectile)
	end
	if selfData.AttackState < VJ.ATTACK_STATE_EXECUTED then
		if eneValid then
			self:PlaySoundSystem("RangeAttack")
		end
		selfData.AttackState = VJ.ATTACK_STATE_EXECUTED
		if selfData.TimeUntilRangeAttackProjectileRelease then
			attackTimers[VJ.ATTACK_TYPE_RANGE](self)
		end
	end
end
