AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Flare Countermeasure"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.PhysgunDisabled = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

-- Hint for Glide missiles
ENT.IsCountermeasure = true

local CurTime = CurTime

if CLIENT then
    function ENT:Initialize()
        if not self.flareLoop then
            self.flareLoop = CreateSound( self, ")weapons/flaregun/burn.wav" )
            self.flareLoop:SetSoundLevel( 75 )
            self.flareLoop:PlayEx( 0.5, 110 )
        end
    end

    function ENT:OnRemove()
        if self.flareLoop then
            self.flareLoop:Stop()
            self.flareLoop = nil
        end
    end

    local Effect = util.Effect
    local EffectData = EffectData

    function ENT:Think()
        self:SetNextClientThink( CurTime() + 0.03 )

        local eff = EffectData()
        eff:SetOrigin( self:GetPos() )
        eff:SetScale( 1 )
        Effect( "glide_flare", eff )

        return true
    end
end

if not SERVER then return end

function ENT:Initialize()
    self:SetModel( "models/items/flare.mdl" )
    self:PhysicsInitSphere( 4 )
    self:DrawShadow( false )

    local phys = self:GetPhysicsObject()

    if IsValid( phys ) then
        phys:Wake()
        phys:SetAngleDragCoefficient( 1 )
        phys:SetDragCoefficient( 0 )
        phys:EnableGravity( true )
        phys:SetMass( 5 )
    end

    self.lifeTime = CurTime() + 10

    Glide.TrackFlare( self )
end

function ENT:Think()
    local t = CurTime()

    if t > self.lifeTime or self:WaterLevel() > 0 then
        self:Remove()
        return false
    end

    self:NextThink( t )

    -- Custom drag
    local phys = self:GetPhysicsObject()

    if IsValid( phys ) then
        local dt = FrameTime()
        local vel = phys:GetVelocity()

        vel[1] = vel[1] - vel[1] * dt * 0.5
        vel[2] = vel[2] - vel[2] * dt * 0.5
        vel[3] = vel[3] - vel[3] * dt * 2

        phys:SetVelocityInstantaneous( vel )
    end

    return true
end

function ENT:OnTakeDamage()
    self:Remove()
end
