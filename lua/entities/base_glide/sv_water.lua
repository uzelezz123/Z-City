function ENT:WaterInit()
    self:SetWaterState( 0 )

    local offsets = self:GetBuoyancyOffsets()
    local points = {}

    for i, offset in ipairs( offsets ) do
        points[i] = {
            offset = offset,
            isUnderWater = false
        }
    end

    self.buoyancyPoints = points
    self.buoyancyPointsCount = #points
end

--- Calculate local positions on the vehicle where buoyancy forces are applied.
--- Children classes can safely override this function
--- if they want to manually specify these offsets.
function ENT:GetBuoyancyOffsets()
    local phys = self:GetPhysicsObject()
    if not IsValid( phys ) then return {} end

    local center = phys:GetMassCenter()
    local mins, maxs = phys:GetAABB()
    local size = ( maxs - mins ) * 0.5

    local spacingX = self.BuoyancyPointsXSpacing
    local spacingY = self.BuoyancyPointsYSpacing

    center[3] = center[3] - self.BuoyancyPointsZOffset

    return {
        center + Vector( size[1] * spacingX, size[2] * spacingY, 0 ), -- Front left
        center + Vector( size[1] * spacingX, size[2] * -spacingY, 0 ), -- Front right
        center + Vector( size[1] * -spacingX, size[2] * spacingY, 0 ), -- Rear left
        center + Vector( size[1] * -spacingX, size[2] * -spacingY, 0 ) -- Rear right
    }
end

local IsUnderWater = Glide.IsUnderWater
local GetDevMode = Glide.GetDevMode

function ENT:WaterThink( selfTbl )
    -- Update buoyancy points
    local underWaterPoints = 0

    for _, point in ipairs( selfTbl.buoyancyPoints ) do
        point.isUnderWater = IsUnderWater( self:LocalToWorld( point.offset ) )

        if point.isUnderWater then
            underWaterPoints = underWaterPoints + 1
        end
    end

    local waterState = underWaterPoints < 1 and 0 or (
        underWaterPoints > selfTbl.buoyancyPointsCount * 0.5 and 2 or 1
    )

    if self:WaterLevel() > 2 then
        waterState = 3
    end

    self:SetWaterState( waterState )

    -- If necessary, kick passengers when underwater
    if selfTbl.FallWhileUnderWater and waterState > 2 and self:GetPlayerCount() > 0 then
        self:RagdollPlayers( 3 )
    end

    -- Draw buoyancy debug overlays, if `developer` cvar is active
    if GetDevMode() then
        for _, point in ipairs( selfTbl.buoyancyPoints ) do
            debugoverlay.Cross( self:LocalToWorld( point.offset ), 4, 0.1, Color( 50, point.isUnderWater and 255 or 150, 255 ), true )
        end
    end

end

local Abs = math.abs
local Clamp = math.Clamp

local mass, linearImp, angularImp

local function AddForceOffset( outLin, outAng, phys, dt, pos, f )
    linearImp, angularImp = phys:CalculateForceOffset( f * mass, pos )

    outLin[1] = outLin[1] + linearImp[1] / dt
    outLin[2] = outLin[2] + linearImp[2] / dt
    outLin[3] = outLin[3] + linearImp[3] / dt

    outAng[1] = outAng[1] + angularImp[1] / dt
    outAng[2] = outAng[2] + angularImp[2] / dt
    outAng[3] = outAng[3] + angularImp[3] / dt
end

local function AddForce( out, f )
    out[1] = out[1] + f[1] * mass
    out[2] = out[2] + f[2] * mass
    out[3] = out[3] + f[3] * mass
end

local function LimitInputWithAngle( value, ang, maxAng )
    if ang > maxAng then
        value = value * ( 1 - Clamp( ( ang - maxAng ) / 20, 0, 1 ) )
    end

    return value
end

local CurTime = CurTime
local Cos = math.cos
local TraceLine = util.TraceLine

local ray = {}
local traceData = { mask = MASK_WATER, output = ray }
local worldUp = Vector( 0, 0, 1 )
local fw, rt, vel, speed

--- Simulate boat physics.
function ENT:SimulateBoat( phys, dt, outLin, outAng, throttle, steer )
    if self:IsPlayerHolding() then return end

    -- Don't apply any of the other forces
    -- if no buoyancy points are under water.
    if self:GetWaterState() < 1 then return end

    mass = phys:GetMass()
    fw = self:GetForward()
    rt = fw:Cross( worldUp )

    vel = phys:GetVelocity()
    speed = self:WorldToLocal( phys:GetPos() + vel )[1]

    local params = self.BoatParams

    -- Buoyancy forces
    local upDrag = -params.waterLinearDrag[3]
    local upDepth = params.buoyancyDepth
    local pointVel, offset, buoyancyForce

    for _, point in ipairs( self.buoyancyPoints ) do
        if point.isUnderWater then
            offset = self:LocalToWorld( point.offset )
            pointVel = phys:GetVelocityAtPoint( offset )

            -- Check how far from the surface this point is
            traceData.start = offset + worldUp * upDepth
            traceData.endpos = offset

            TraceLine( traceData )

            buoyancyForce = params.buoyancy * ( 1 - ray.Fraction )
            buoyancyForce = buoyancyForce + worldUp:Dot( pointVel ) * upDrag

            AddForceOffset( outLin, outAng, phys, dt, offset, worldUp * buoyancyForce )
        end
    end

    local tightTurn = self:GetInputBool( 1, "handbrake" )

    -- Drag forces
    AddForce( outLin, fw * Clamp( speed, -500, 500 ) * -params.waterLinearDrag[1] * ( tightTurn and 2 or 1 ) )
    AddForce( outLin, rt * rt:Dot( vel ) * -params.waterLinearDrag[2] * ( tightTurn and 2 or 1 ) )

    local angDrag = params.waterAngularDrag
    local angVel = phys:GetAngleVelocity()

    outAng[1] = outAng[1] + angVel[1] * angDrag[1] * mass
    outAng[2] = outAng[2] + angVel[2] * angDrag[2] * mass
    outAng[3] = outAng[3] + angVel[3] * angDrag[3] * mass

    -- Try to align the boat towards the direction of movement
    if not tightTurn then
        vel:Normalize()
        outAng[3] = outAng[3] - vel:Dot( rt ) * params.alignForce * mass
    end

    -- Turbulance
    local t = CurTime()
    outAng[1] = outAng[1] + Cos( t * 1.5 ) * params.turbulanceForce * mass
    outAng[2] = outAng[2] + Cos( t * 2 ) * params.turbulanceForce * 2 * mass

    -- Engine forces
    local angles = self:GetAngles()

    if throttle > 0 and speed < params.maxSpeed then
        AddForce( outLin, fw * params.engineForce * throttle )

        -- Apply pitch up force, but only up to a point
        throttle = LimitInputWithAngle( throttle, Abs( angles[1] ), 10 )
        outAng[2] = outAng[2] - params.engineLiftForce * mass * throttle

    elseif throttle < 0 and speed > params.maxSpeed * -0.25 then
        AddForce( outLin, fw * params.engineForce * throttle )
    end

    -- Steering forces
    steer = steer * Clamp( ( Abs( speed ) - 20 ) / 200, 0, 1 )

    if speed < 0 then
        steer = -steer
    end

    outAng[3] = outAng[3] - params.turnForce * steer * mass

    -- Apply the roll force, but only up to a point
    steer = LimitInputWithAngle( steer, Abs( angles[3] ), 30 )
    outAng[1] = outAng[1] + params.rollForce * steer * mass * ( tightTurn and 2 or 1 )
end
