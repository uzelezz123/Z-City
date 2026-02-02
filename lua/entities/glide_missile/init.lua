AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/glide/weapons/homing_rocket.mdl" )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:DrawShadow( false )

    local phys = self:GetPhysicsObject()

    if IsValid( phys ) then
        phys:Wake()
        phys:SetAngleDragCoefficient( 1 )
        phys:SetDragCoefficient( 0 )
        phys:EnableGravity( false )
        phys:SetMass( 20 )
        phys:SetVelocityInstantaneous( self:GetForward() * 500 )

        self:StartMotionController()
    end

    self.radius = 350
    self.damage = 100
    self.lifeTime = CurTime() + 6
    self.acceleration = 8000
    self.maxSpeed = 4000 -- This appears to be the default limit of the physics engine
    self.turnRate = 50 -- degrees/s
    self.missThreshold = 0.9

    self.target = NULL
    self.speed = 0
    self.aimDir = nil

    self.applyThrust = true
    self.flareExplodeRadius = 200 * 200

    self:SetEffectiveness( 0 )
end

local IsValid = IsValid

function ENT:SetupMissile( attacker, parent )
    -- Set which player created this missile
    self.attacker = attacker

    -- Don't collide with our parent entity
    self:SetOwner( parent )
end

--- Set the target this missile will track.
--- If the target is a player, seat, or a Glide vehicle, this will send
--- a network event to let the target know a missile is coming.
function ENT:SetTarget( target )
    if not target:IsPlayer() then
        -- Just use the target entity
        self.target = target

        -- Let Glide vehicles know about this missile
        if target.IsGlideVehicle then
            Glide.SendMissileDanger( target:GetAllPlayers(), self )

        -- Let players in seats know about this missile
        elseif target:IsVehicle() then
            local driver = target:GetDriver()

            if IsValid( driver ) then
                Glide.SendMissileDanger( driver, self )
            end
        end

        return
    end

    -- Try to target this player's seat
    local seat = target:GetVehicle()

    if IsValid( seat ) then
        -- Try to target this seat's parent
        local parent = seat:GetParent()

        if IsValid( parent ) then
            -- Use the parent as the target
            self.target = parent

            -- Let Glide vehicles know about this missile
            if parent.IsGlideVehicle then
                Glide.SendMissileDanger( parent:GetAllPlayers(), self )
            else
                Glide.SendMissileDanger( target, self )
            end
        else
            -- Use the seat as the target
            self.target = seat
            Glide.SendMissileDanger( target, self )
        end
    else
        -- Use the target player
        self.target = target
        Glide.SendMissileDanger( target, self )
    end
end

function ENT:Explode()
    if self.hasExploded then return end

    -- Don't let stuff like collision events call this again
    self.hasExploded = true

    Glide.CreateExplosion( self, self.attacker, self:GetPos(), self.radius, self.damage, -self:GetForward(), Glide.EXPLOSION_TYPE.MISSILE )

    self.attacker = nil
    self:Remove()
end

function ENT:PhysicsCollide( data )
    -- Silently remove this missile when hitting the skybox
    if data.TheirSurfaceProps == 76 then
        self:Remove()
        return
    end

    self:Explode()
end

function ENT:OnTakeDamage( dmginfo )
    -- Don't explode when other Glide missiles damaged this missile.
    if dmginfo:IsExplosionDamage() then
        local inflictor = dmginfo:GetInflictor()

        if IsValid( inflictor ) and inflictor:GetClass() == "glide_missile" then
            return
        end
    end

    if not self.hasExploded then
        self:Explode()
    end
end

local FrameTime = FrameTime
local Approach = math.Approach
local GetClosestFlare = Glide.GetClosestFlare
local TraceHull = util.TraceHull

local ray = {}

local traceData = {
    output = ray,
    filter = { NULL, NULL },
    mask = MASK_PLAYERSOLID,
    maxs = Vector(),
    mins = Vector()
}

function ENT:Think()
    local t = CurTime()

    if t > self.lifeTime then
        self:Explode()
        return
    end

    self:NextThink( t )

    local phys = self:GetPhysicsObject()

    if not self.applyThrust or not IsValid( phys ) then
        return true
    end

    if self:WaterLevel() > 0 then
        self.applyThrust = false
        phys:EnableGravity( true )
        return true
    end

    local dt = FrameTime()

    self:SetEffectiveness( Approach( self:GetEffectiveness(), 1, dt * 4 ) )

    -- Point towards the target
    local target = self.target
    local myPos = self:GetPos()
    local fw = self:GetForward()

    -- Or towards a nearby flare
    local flare, flareDistSqr = GetClosestFlare( myPos, fw, 1500 )

    if IsValid( flare ) then
        target = flare

        if flareDistSqr < self.flareExplodeRadius then
            self:Explode()
            return
        end
    end

    if IsValid( target ) then
        self:SetHasTarget( target.IsCountermeasure ~= true )

        local targetPos = target:WorldSpaceCenter()
        local dir = targetPos - myPos
        dir:Normalize()

        -- If the target is outside our FOV, stop tracking it
        if math.abs( dir:Dot( fw ) ) < self.missThreshold then
            self.target = nil
            self.aimDir = nil
        else
            -- Let PhysicsSimulate handle this
            self.aimDir = dir
        end
    else
        self:SetHasTarget( false )
    end

    traceData.start = myPos
    traceData.endpos = myPos + self:GetVelocity() * dt * 2
    traceData.filter[1] = self
    traceData.filter[2] = self:GetOwner()

    -- Trace result is stored on `ray`
    TraceHull( traceData )

    if not ray.HitSky and ray.Hit then
        self:Explode()
    end

    return true
end

local ApproachAngle = math.ApproachAngle
local ZERO_VEC = Vector()

function ENT:PhysicsSimulate( phys, dt )
    if not self.applyThrust then return end

    -- Accelerate to reach maxSpeed
    if self.speed < self.maxSpeed then
        self.speed = self.speed + self.acceleration * dt
    end

    if self.aimDir then
        local myAng = self:GetAngles()
        local targetAng = self.aimDir:Angle()
        local rate = self.turnRate * dt

        myAng[1] = ApproachAngle( myAng[1], targetAng[1], rate )
        myAng[2] = ApproachAngle( myAng[2], targetAng[2], rate )
        myAng[3] = ApproachAngle( myAng[3], targetAng[3], rate )

        phys:SetAngles( myAng )
    end

    phys:SetAngleVelocityInstantaneous( ZERO_VEC )
    phys:SetVelocityInstantaneous( self:GetForward() * self.speed )
end
