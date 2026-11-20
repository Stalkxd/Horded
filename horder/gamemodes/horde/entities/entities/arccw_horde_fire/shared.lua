ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Fire Particle"
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Model = "models/Items/AR2_Grenade.mdl"

ENT.FireTime = 5

ENT.Armed = false

ENT.NextDamageTick = 0

ENT.Ticks = 0

ENT.ArcCW_Killable = false

AddCSLuaFile()

-- The fire pool burns everything in range on a timer. It used to rely on Touch, which
-- didn't reliably fire on this small physics model, so molotovs dealt no damage.
ENT.BurnRadius = 140
ENT.BurnDamage = 25
ENT.BurnInterval = 0.5

function ENT:BurnArea()
    local owner = self:GetOwner()
    local has_owner = IsValid(owner) and owner:IsPlayer()
    local now = CurTime()
    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.BurnRadius)) do
        local is_player = ent:IsPlayer() and ent:Alive()
        -- Players only take hits from a pool whose thrower is still here, so the
        -- damage stays theirs (teammates are protected by friendly fire rules).
        if ((is_player and has_owner) or (not is_player and HORDE:IsEnemy(ent)))
            and (ent.Horde_MolotovNextBurn or 0) <= now then
            -- Overlapping pools don't stack: each target burns once per interval.
            ent.Horde_MolotovNextBurn = now + self.BurnInterval - 0.05
            local d = DamageInfo()
            d:SetDamage(self.BurnDamage)
            d:SetAttacker(has_owner and owner or self)
            d:SetInflictor(self)
            d:SetDamageType(DMG_BURN)
            d:SetDamagePosition(ent:GetPos())
            ent:TakeDamageInfo(d)
        end
    end
end

function ENT:Initialize()
    if SERVER then
        self:SetModel( self.Model )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:PhysicsInit(SOLID_VPHYSICS)
        self:DrawShadow( false )
        self:SetCollisionBounds(Vector(-150,-150,-100), Vector(150,150,100))
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        self:SetTrigger(true)
        self:UseTriggerBounds(true, 24)

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetBuoyancyRatio(0)
        end

        self.SpawnTime = CurTime()
        self:Detonate()

        self.FireTime = math.Rand(4.5, 5.5)
    end

    local owner = self:GetOwner()
    self.has_burner = nil
    if owner and owner:Horde_GetGadget() == "gadget_hydrogen_burner" then
        self.has_burner = true
    end
end

local fired = {
    "sprites/flamelet1",
    "sprites/flamelet2",
    "sprites/flamelet3",
    "sprites/flamelet4",
    "sprites/flamelet5",
}
local function GetFireParticle()
    return fired[math.random(#fired)]
end

function ENT:Think()
    if !self.SpawnTime then self.SpawnTime = CurTime() end

    if CLIENT then
        local emitter = ParticleEmitter(self:GetPos())

        if !self:IsValid() or self:WaterLevel() > 2 then return end
        if !IsValid(emitter) then return end

        for i = 1,10 do
            local fire = emitter:Add(GetFireParticle(), self:GetPos() + (VectorRand() * 30))
            fire:SetVelocity( VectorRand() * 500 * VectorRand() )
            fire:SetGravity( Vector(0, 0, 1000) )
            fire:SetDieTime( math.Rand(0.2, 0.5) )
            fire:SetStartAlpha( 255 )
            fire:SetEndAlpha( 0 )
            fire:SetStartSize( 0 )
            fire:SetEndSize( 50 )
            fire:SetRoll( math.Rand(-180, 180) )
            fire:SetRollDelta( math.Rand(-0.2,0.2) )
            if self.has_burner then
                fire:SetColor( 0, 135, 255 )
            else
                fire:SetColor( 255, 255, 255 )
            end
            fire:SetAirResistance( 150 )
            local pos = VectorRand() * math.random(20,100)
            pos.z = 0
            fire:SetPos( self:GetPos() + pos )
            fire:SetLighting( false )
            fire:SetCollide(true)
            fire:SetBounce(0.75)
            fire:SetNextThink( CurTime() + FrameTime() )
            fire:SetThinkFunction( function(pa)
                if !pa then return end
                local col1 = Color(255, 135, 0)
                if self.has_burner then
                    col1 = Color(0, 135, 255)
                end
                local col2 = Color(0, 0, 0)

                local col3 = col1
                local d = pa:GetLifeTime() / pa:GetDieTime()
                col3.r = Lerp(d, col1.r, col2.r)
                col3.g = Lerp(d, col1.g, col2.g)
                col3.b = Lerp(d, col1.b, col2.b)

                pa:SetColor(col3.r, col3.g, col3.b)
                pa:SetNextThink( CurTime() + FrameTime() )
            end )
        end

        emitter:Finish()

        self.Ticks = self.Ticks + 1
    else

        if self:GetVelocity():LengthSqr() <= 32 and not self._hordeMoveTypePending then
            self._hordeMoveTypePending = true
            local fire = self
            timer.Simple(0, function()
                if not IsValid(fire) then return end
                fire._hordeMoveTypePending = nil
                if fire:GetVelocity():LengthSqr() <= 32 then
                    fire:SetMoveType( MOVETYPE_NONE )
                end
            end)
        end

        if self.NextDamageTick > CurTime() then return end

        if self:WaterLevel() > 2 then self:Remove() return end

        self.NextDamageTick = CurTime() + 0.25

        if self.SpawnTime + self.FireTime <= CurTime() then self:Remove() return end

        if (self.NextBurn or 0) <= CurTime() then
            self.NextBurn = CurTime() + self.BurnInterval
            self:BurnArea()
        end
    end
end

function ENT:OnRemove()
    if !self.FireSound then return end
    self.FireSound:Stop()
end

function ENT:Detonate()
    if !self:IsValid() then return end

    self.Armed = true

    if self.Order and self.Order != 1 then return end

    self.FireSound = CreateSound(self, "arccw_go/molotov/fire_loop_1.wav")
    self.FireSound:Play()

    self.FireSound:ChangePitch(80, self.FireTime)

    timer.Simple(self.FireTime - 1, function()
        if !IsValid(self) then return end

        self.FireSound:ChangeVolume(0, 1)
    end)

    timer.Simple(self.FireTime, function()
        if !IsValid(self) then return end

        self:Remove()
    end)
end

function ENT:Draw()
end
