AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

-- Store the TraceResult on this table instead of
-- creating a new one every time. It's contents are
-- overritten every time a wheel calls `util.TraceHull`.
local ray = Glide.LastWheelTraceResult or {}

-- Keep the same table reference on Lua autorefresh.
-- Prevents errors on existing wheels when updating this file.
Glide.LastWheelTraceResult = ray

if game.SinglePlayer() then
    -- Workaround for updating the TraceResult
    -- table reference after a level transition.
    hook.Add( "InitPostEntity", "Glide.WheelTraceResultWorkaround", function()
        for _, w in ipairs( ents.FindByClass( "glide_wheel" ) ) do
            w.traceData.output = ray
        end
    end )
end

function ENT:Initialize()
    self:SetModel( "models/editor/axis_helper.mdl" )
    self:SetSolid( SOLID_NONE )
    self:SetMoveType( MOVETYPE_VPHYSICS )

    self.params = {
        -- Suspension
        suspensionLength = 10,
        springStrength = 500,
        springDamper = 2000,

        -- Brake force
        brakePower = 3000,

        -- Forward traction
        forwardTractionMax = 2600,

        -- Side traction
        sideTractionMultiplier = 20,
        sideTractionMaxAng = 25,
        sideTractionMax = 2400,
        sideTractionMin = 800,

        -- Other parameters
        radius = 15,
        basePos = Vector(),
        steerMultiplier = 0,
        enableAxleForces = false
    }

    self.state = {
        torque = 0, -- Amount of torque to apply to the wheel
        brake = 0,  -- Amount of brake torque to apply to the wheel
        spin = 0,   -- Wheel spin angle around it's axle axis

        -- Suspension length multiplier
        suspensionLengthMult = 1,

        -- Forward traction multiplier
        forwardTractionMult = 1,

        -- Side traction multiplier
        sideTractionMult = 1,

        isOnGround = false,
        lastFraction = 1,
        lastSpringOffset = 0,
        angularVelocity = 0,
        isDebugging = Glide.GetDevMode()
    }

    -- Used for raycasting, updates with wheel radius
    self.traceData = {
        mins = Vector(),
        maxs = Vector( 1, 1, 1 ),

        -- Output TraceResult to `ray`
        output = ray
    }

    self.contractSoundCD = 0
    self.expandSoundCD = 0

    self:SetupWheel()
end

--- Set the size, models and steering properties to use on this wheel.
function ENT:SetupWheel( t )
    t = t or {}

    local params = self.params

    -- Physical wheel radius, also affects the model size
    params.radius = t.radius or 15

    -- Wheel offset relative to the parent
    params.basePos = t.basePos or self:GetLocalPos()

    -- How much the parent's steering angle affects this wheel
    params.steerMultiplier = t.steerMultiplier or 0

    -- Wheel model
    if type( t.model ) == "string" then
        params.model = t.model
    end

    -- Model rotation and scale
    params.modelScale = t.modelScale or Vector( 0.3, 1, 1 )

    self:SetModelAngle( t.modelAngle or Angle( 0, 0, 0 ) )
    self:SetModelOffset( t.modelOffset or Vector( 0, 0, 0 ) )

    -- Should this wheel have the same size/radius as the model?
    -- If you use this, the `radius` and `modelScale` parameters are going to be overritten.
    -- Requires the `model` parameter to be set previously.
    params.useModelSize = params.model and t.useModelSize == true

    if params.useModelSize then
        self:SetModel( params.model )

        local obbSize = self:OBBMaxs() - self:OBBMins()
        params.baseModelRadius = obbSize[3] * 0.5
        params.radius = params.baseModelRadius
        params.modelScale = Vector( 1, 1, 1 )
    end

    -- Should forces be applied at the axle position?
    -- (Recommended for small vehicles like the Blazer)
    params.enableAxleForces = t.enableAxleForces or false

    -- Should this wheel play sounds?
    self:SetSoundsEnabled( t.disableSounds ~= true )

    -- Repair to update the model and radius
    self:Repair()

    -- Suspension
    params.suspensionLength = t.suspensionLength or params.suspensionLength
    params.springStrength = t.springStrength or params.springStrength
    params.springDamper = t.springDamper or params.springDamper

    -- Brake force
    params.brakePower = t.brakePower or params.brakePower

    -- Forward traction
    params.forwardTractionMax = t.forwardTractionMax or params.forwardTractionMax

    -- Side traction
    params.sideTractionMultiplier = t.sideTractionMultiplier or params.sideTractionMultiplier
    params.sideTractionMaxAng = t.sideTractionMaxAng or params.sideTractionMaxAng
    params.sideTractionMax = t.sideTractionMax or params.sideTractionMax
    params.sideTractionMin = t.sideTractionMin or params.sideTractionMin
end

function ENT:Repair()
    if self.params.model then
        self:SetModel( self.params.model )
    end

    self:ChangeRadius()
end

function ENT:Blow()
    self:ChangeRadius( self.params.radius * 0.8 )
    self:EmitSound( "glide/wheels/blowout.wav", 80, math.random( 95, 105 ), 1 )
end

function ENT:ChangeRadius( radius )
    radius = radius or self.params.radius

    local size = self.params.modelScale * radius * 2
    local obbSize = self:OBBMaxs() - self:OBBMins()
    local scale = Vector( size[1] / obbSize[1], size[2] / obbSize[2], size[3] / obbSize[3] )

    if self.params.useModelSize then
        local s = radius / self.params.baseModelRadius
        scale[1] = s
        scale[2] = s
        scale[3] = s
    end

    self:SetRadius( radius )
    self:SetModelScale2( scale )

    -- Used on util.TraceHull
    self.traceData.mins = Vector( radius * -0.2, radius * -0.2, 0 )
    self.traceData.maxs = Vector( radius * 0.2, radius * 0.2, 1 )
end

do
    local Deg = math.deg
    local Approach = math.Approach

    function ENT:Update( vehicle, steerAngle, isAsleep, dt )
        local state, params = self.state, self.params

        -- Get the wheel rotation relative to the vehicle, while applying the steering angle
        local ang = vehicle:LocalToWorldAngles( steerAngle * params.steerMultiplier )

        -- Rotate the wheel around the axle axis
        state.spin = ( state.spin - Deg( state.angularVelocity ) * dt ) % 360

        ang:RotateAroundAxis( ang:Right(), state.spin )
        self:SetAngles( ang )

        if isAsleep then
            self:SetForwardSlip( 0 )
            self:SetSideSlip( 0 )
        else
            self:SetLastSpin( state.spin )
            self:SetLastOffset( self:GetLocalPos()[3] - params.basePos[3] )
        end

        if isAsleep or not state.isOnGround then
            -- Let the torque spin the wheel's fake mass
            state.angularVelocity = state.angularVelocity + ( state.torque / 20 ) * dt

            -- Slow down eventually
            state.angularVelocity = Approach( state.angularVelocity, 0, dt * 4 )
        end
    end

    local TAU = math.pi * 2

    function ENT:GetRPM()
        return self.state.angularVelocity * 60 / TAU
    end

    function ENT:SetRPM( rpm )
        self.state.angularVelocity = rpm / ( 60 / TAU )
    end
end

local Abs = math.abs
local Clamp = math.Clamp

do
    local CurTime = CurTime
    local PlaySoundSet = Glide.PlaySoundSet

    function ENT:DoSuspensionSounds( change, vehicle )
        if not self:GetSoundsEnabled() then return end

        local t = CurTime()

        if change > 0.01 and t > self.expandSoundCD then
            self.expandSoundCD = t + 0.3
            PlaySoundSet( vehicle.SuspensionUpSound, self, Clamp( Abs( change ) * 15, 0, 0.5 ) )
        end

        if change < -0.01 and t > self.contractSoundCD then
            change = Abs( change )

            self.contractSoundCD = t + 0.3
            PlaySoundSet( change > 0.03 and vehicle.SuspensionHeavySound or vehicle.SuspensionDownSound, self, Clamp( change * 20, 0, 1 ) )
        end
    end
end

local MAP_SURFACE_OVERRIDES = Glide.MAP_SURFACE_OVERRIDES

local PI = math.pi
local TAU = math.pi * 2

local Min = math.min
local Max = math.max
local Atan2 = math.atan2
local Approach = math.Approach
local TraceHull = util.TraceHull
local TractionRamp = Glide.TractionRamp

-- Temporary variables
local pos, ang, fw, rt, up, radius, maxLen
local fraction, contactPos, surfaceId, vel, velF, velR, velU, absVelR
local offset, springForce, damperForce
local surfaceGrip, maxTraction, brakeForce, forwardForce, signForwardForce
local tractionCycle, gripLoss, groundAngularVelocity, angularVelocity = Vector()
local slipAngle, sideForce
local force, linearImp, angularImp
local state, params, traceData

function ENT:DoPhysics( vehicle, phys, traceFilter, outLin, outAng, dt, vehSurfaceGrip, vehSurfaceResistance, vehPos, vehVel, vehAngVel )
    state, params = self.state, self.params

    -- Get the starting point of the raycast, where the suspension connects to the chassis
    pos = phys:LocalToWorld( params.basePos )

    -- Get the wheel rotation relative to the chassis, applying the steering angle if necessary
    ang = vehicle:LocalToWorldAngles( vehicle.steerAngle * params.steerMultiplier )

    -- Store some directions
    fw = ang:Forward()
    rt = ang:Right()
    up = ang:Up()

    -- Do the raycast
    radius = self:GetRadius()
    maxLen = state.suspensionLengthMult * params.suspensionLength + radius

    traceData = self.traceData
    traceData.filter = traceFilter
    traceData.start = pos
    traceData.endpos = pos - up * maxLen

    -- TraceResult gets stored on the `ray` table
    TraceHull( traceData )

    fraction = Clamp( ray.Fraction, radius / maxLen, 1 )
    contactPos = pos - maxLen * fraction * up

    -- Update ground contact NW variables
    surfaceId = ray.Hit and ( ray.MatType or 0 ) or 0
    surfaceId = MAP_SURFACE_OVERRIDES[surfaceId] or surfaceId

    state.isOnGround = ray.Hit
    self:SetContactSurface( surfaceId )

    if state.isDebugging then
        debugoverlay.Cross( pos, 10, 0.05, Color( 100, 100, 100 ), true )
        debugoverlay.Box( contactPos, traceData.mins, traceData.maxs, 0.05, Color( 0, 200, 0 ) )
    end

    -- Update the wheel position and sounds
    self:SetLocalPos( phys:WorldToLocal( contactPos + up * radius ) )
    self:DoSuspensionSounds( fraction - state.lastFraction, vehicle )
    state.lastFraction = fraction

    if not ray.Hit then
        self:SetForwardSlip( 0 )
        self:SetSideSlip( 0 )

        return
    end

    pos = params.enableAxleForces and pos or contactPos

    -- Get the velocity at the wheel position
    vel = phys:GetVelocityAtPoint( pos )

    -- Split that velocity among our local directions
    velF = fw:Dot( vel )
    velR = rt:Dot( vel )
    velU = ray.HitNormal:Dot( vel )
    absVelR = Abs( velR )

    -- Make forward forces be perpendicular to the surface normal
    fw = ray.HitNormal:Cross( rt )

    -- Suspension spring force & damping
    offset = maxLen - ( fraction * maxLen )
    springForce = ( offset * params.springStrength )
    damperForce = ( state.lastSpringOffset - offset ) * params.springDamper
    state.lastSpringOffset = offset

    -- If the suspension spring is going to be fully compressed on the next frame...
    if velU < 0 and offset + Abs( velU * dt ) > params.suspensionLength then
        -- Completely negate the downwards velocity at the local position
        linearImp, angularImp = phys:CalculateVelocityOffset( ( -velU / dt ) * ray.HitNormal, pos )
        vehVel:Add( linearImp )
        vehAngVel:Add( angularImp )

        -- Teleport back up, using phys:SetPos to prevent going through stuff.
        linearImp = phys:CalculateVelocityOffset( ray.HitPos - ( contactPos + ray.HitNormal * velU * dt ), pos )
        vehPos:Add( linearImp / dt )

        -- Remove the damping force, to prevent a excessive bounce.
        damperForce = 0
    end

    force = ( springForce - damperForce ) * up:Dot( ray.HitNormal ) * ray.HitNormal

    -- Rolling resistance
    force:Add( ( vehSurfaceResistance[surfaceId] or 0.05 ) * -velF * fw )

    -- Brake and torque forces
    surfaceGrip = vehSurfaceGrip[surfaceId] or 1
    maxTraction = params.forwardTractionMax * surfaceGrip * state.forwardTractionMult

    -- Grip loss logic
    brakeForce = ( velF > 0 and -state.brake or state.brake ) * params.brakePower * surfaceGrip
    forwardForce = state.torque + brakeForce
    signForwardForce = forwardForce > 0 and 1 or ( forwardForce < 0 and -1 or 0 )

    -- Given an amount of sideways slippage (up to the max. traction)
    -- and the forward force, calculate how much grip we are losing.
    tractionCycle[1] = Min( absVelR, maxTraction )
    tractionCycle[2] = forwardForce
    gripLoss = Max( tractionCycle:Length() - maxTraction, 0 )

    -- Reduce the forward force by the amount of grip we lost,
    -- but still allow some amount of brake force to apply regardless.
    forwardForce = forwardForce - ( gripLoss * signForwardForce ) + Clamp( brakeForce * 0.5, -maxTraction, maxTraction )
    force:Add( fw * forwardForce )

    -- Get how fast the wheel would be spinning if it had never lost grip
    groundAngularVelocity = TAU * ( velF / ( radius * TAU ) )

    -- Add our grip loss to our spin velocity
    angularVelocity = groundAngularVelocity + gripLoss * ( state.torque > 0 and 1 or ( state.torque < 0 and -1 or 0 ) )

    -- Smoothly match our current angular velocity to the angular velocity affected by grip loss
    state.angularVelocity = Approach( state.angularVelocity, angularVelocity, dt * 200 )

    gripLoss = groundAngularVelocity - state.angularVelocity
    self:SetForwardSlip( gripLoss )

    -- Calculate side slip angle
    slipAngle = ( Atan2( velR, Abs( velF ) ) / PI ) * 2
    self:SetSideSlip( slipAngle * Clamp( vehicle.totalSpeed * 0.005, 0, 1 ) * 2 )

    -- Sideways traction ramp
    slipAngle = Abs( slipAngle * slipAngle )
    maxTraction = TractionRamp( slipAngle, params.sideTractionMaxAng, params.sideTractionMax, params.sideTractionMin )
    sideForce = -rt:Dot( vel * params.sideTractionMultiplier * state.sideTractionMult )

    -- Reduce sideways traction force as the wheel slips forward
    sideForce = sideForce * ( 1 - Clamp( Abs( gripLoss ) * 0.1, 0, 1 ) * 0.9 )

    -- Reduce sideways force as the suspension spring applies less force
    surfaceGrip = surfaceGrip * Clamp( springForce / params.springStrength, 0, 1 )

    -- Apply sideways traction force
    force:Add( Clamp( sideForce, -maxTraction, maxTraction ) * surfaceGrip * rt )

    -- Apply an extra, small sideways force that is not clamped by maxTraction.
    -- This helps at lot with cornering at high speed.
    force:Add( velR * params.sideTractionMultiplier * -0.1 * rt )

    -- Apply the forces at the axle/ground contact position
    linearImp, angularImp = phys:CalculateForceOffset( force, pos )

    outLin[1] = outLin[1] + linearImp[1] / dt
    outLin[2] = outLin[2] + linearImp[2] / dt
    outLin[3] = outLin[3] + linearImp[3] / dt

    outAng[1] = outAng[1] + angularImp[1] / dt
    outAng[2] = outAng[2] + angularImp[2] / dt
    outAng[3] = outAng[3] + angularImp[3] / dt
end
