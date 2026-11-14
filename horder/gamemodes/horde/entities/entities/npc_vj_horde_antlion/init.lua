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
    timer.Simple(0.5, function()
        if not self:IsValid() then return end
        self:Follow(self.Owner)
    end)
    if self.evolutionmaximum then
        local max_stage = 2
        if self.Owner:Horde_GetPerk("hatcher_metamorphosis") then
            max_stage = 3
        end
        self.Evolve_Stage = max_stage
        self.Evolve_Health = 100
    end
end

--[[ Stage roles
	Stage 1-2  "spitter"  : stays at the owner's side and spits bile.
	Stage 3    "skirmisher": spits at range, leaps in and claws enemies that
	                         come within the leash range of the owner.
	Stage 4    "guard"     : melee tank. Charges (lunge) and shoves enemies
	                         inside the leash range, no spit.
	Antlions never chase further than ROLE.leash units from their owner, and a
	pheropod throw marks a focus target they are allowed to chase a bit further. ]]
local ROLES = {
	[1] = {chase = false, range = true,  melee = false, leap = false, leash = 0},
	[2] = {chase = false, range = true,  melee = false, leap = false, leash = 0},
	[3] = {chase = true,  range = true,  melee = true,  leap = true,  leash = 650},
	[4] = {chase = true,  range = false, melee = true,  leap = true,  leash = 750},
}
local FOCUS_LEASH_MULT = 1.5
local FOCUS_TIME = 6
local RECALL_TIME = 3

function ENT:Horde_ApplyRole()
	local role = ROLES[self.Evolve_Stage] or ROLES[1]
	self.Horde_Role = role
	self.HasRangeAttack = role.range
	self.HasMeleeAttack = role.melee
	self.HasLeapAttack = role.leap
	self.DisableChasingEnemy = true -- toggled per think by the leash logic
	-- Spitters strafe to keep facing their target; melee roles run naturally.
	self.ConstantlyFaceEnemy = not role.chase
	self.ConstantlyFaceEnemy_IfVisible = not role.chase
	self.ConstantlyFaceEnemy_IfAttacking = not role.chase

	if self.Evolve_Stage == 3 then
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.MeleeAttackDistance = 70
		self.MeleeAttackDamageDistance = 110
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
		-- Spit only at things out of claw reach.
		self.RangeToMeleeDistance = 250
	elseif self.Evolve_Stage == 4 then
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
		-- The charge: a low, fast lunge into the target that ends in a shove.
		self.AnimTbl_LeapAttack = {ACT_RUN}
		self.LeapDistance = 700
		self.LeapToMeleeDistance = 220
		self.TimeUntilLeapAttackDamage = 0.4
		self.NextLeapAttackTime = 8
		self.LeapAttackDamage = math.Round(self.MeleeAttackDamage * 1.25)
		self.LeapAttackDamageType = DMG_CLUB
		self.LeapAttackDamageDistance = 140
		self.StopLeapAttackAfterFirstHit = false
		self.LeapAttackVelocityForward = 650
		self.LeapAttackVelocityUp = 60
		self.SoundTbl_LeapAttack = {"npc/antlion_guard/angry1.wav","npc/antlion_guard/angry2.wav"}
	end
end

-- Enemy closest to the owner that this antlion can see, within maxDist of the owner.
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
function ENT:Horde_Recall()
	self.Horde_RecallUntil = CurTime() + RECALL_TIME
	self.Horde_FocusTarget = nil
	self.DisableChasingEnemy = true
end

ENT.NextRoleThink = 0
ENT.NextTargetThink = 0
function ENT:Horde_RoleThink()
	local owner = self.Owner
	local role = self.Horde_Role or ROLES[1]
	local now = CurTime()
	local ownerPos = owner:GetPos()

	if (self.Horde_RecallUntil or 0) > now then
		self.DisableChasingEnemy = true
		return
	end

	local focus = self.Horde_FocusTarget
	if IsValid(focus) and (focus:Health() <= 0 or (self.Horde_FocusUntil or 0) < now) then
		focus = nil
		self.Horde_FocusTarget = nil
	end

	-- Target choice: protect the owner. Prefer the pod-marked target, otherwise
	-- swap to whatever is closest to the owner when the current enemy is far away.
	if self.NextTargetThink <= now then
		self.NextTargetThink = now + 1
		local ene = self:GetEnemy()
		if IsValid(focus) then
			if ene ~= focus and self:Visible(focus) then self:ForceSetEnemy(focus, false) end
		else
			local guardRange = role.chase and role.leash or 900
			local eneFar = not IsValid(ene) or ene:GetPos():DistToSqr(ownerPos) > guardRange * guardRange
			if eneFar then
				local t = self:Horde_FindGuardTarget(ownerPos, guardRange)
				if IsValid(t) and t ~= ene then self:ForceSetEnemy(t, false) end
			end
		end
	end

	if not role.chase then
		self.DisableChasingEnemy = true
		return
	end

	-- Leash: chase only while the enemy is near the owner.
	local ene = self:GetEnemy()
	local leash = role.leash
	if IsValid(focus) and ene == focus then leash = leash * FOCUS_LEASH_MULT end
	local canChase = IsValid(ene) and ene:GetPos():DistToSqr(ownerPos) <= leash * leash
	self.DisableChasingEnemy = not canChase
	self.HasLeapAttack = role.leap and canChase
	if role.melee then self.HasMeleeAttack = canChase or (IsValid(ene) and ene:GetPos():DistToSqr(self:GetPos()) < 22500) end

	-- Out of the fight and drifted off: run back to the owner.
	if not canChase and self:GetPos():DistToSqr(ownerPos) > (leash * 0.6) ^ 2 and not self:BusyWithActivity() and not self:IsCurrentSchedule(SCHED_FORCED_GO_RUN) then
		self:SetLastPosition(ownerPos)
		self:SetSchedule(SCHED_FORCED_GO_RUN)
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

	if self.NextRoleThink <= CurTime() then
		self.NextRoleThink = CurTime() + 0.3
		self:Horde_RoleThink()
	end

	-- Teleport back if far away (stuck or left behind), checked every second.
	if self.NextLeashCheck <= CurTime() then
		self.NextLeashCheck = CurTime() + 1
		if self:GetPos():DistToSqr(self.Owner:GetPos()) >= 1000000 then
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
	if self.Horde_Role and not self.Horde_Role.range then return end
	if self.Dead then return end
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
