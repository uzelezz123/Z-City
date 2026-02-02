AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

DEFINE_BASECLASS( "base_glide_car" )

local EntityMeta = FindMetaTable( "Entity" )
local GetTable = EntityMeta.GetTable

--- Implement this base class function.
function ENT:OnPostInitialize()
    BaseClass.OnPostInitialize( self )

    -- Create a weapon. We'll implement a
    -- custom fire logic on our `ENT:OnWeaponFire`.
    self:CreateWeapon( "base", {
        MaxAmmo = 0,
        FireDelay = 2.0
    } )

    -- Setup variables used on all tanks
    self.isTurningInPlace = false
    self.isCannonInsideWall = false

    self:SetTrackSpeed( 0 )
    self:SetTurretAngle( Angle() )
    self:SetIsAimingAtTarget( false )

    -- Override default NW engine params from the base class
    self.engineBrakeTorque = 40000
    self:SetMinRPMTorque( 40000 )
    self:SetMaxRPMTorque( 35000 )
    self:SetDifferentialRatio( 0.75 )
    self:SetTransmissionEfficiency( 1.0 )
    self:SetPowerDistribution( 0.0 )

    -- Steering parameters
    self:SetMaxSteerAngle( 30 )
    self:SetSteerConeChangeRate( 8 )
    self:SetSteerConeMaxSpeed( 500 )
    self:SetSteerConeMaxAngle( 0.25 )
    self:SetCounterSteer( 0.75 )

    -- Override default NW wheel params from the base class
    local params = {
        -- Suspension
        suspensionLength = 15,
        springStrength = 6000,
        springDamper = 30000,

        -- Brake force
        brakePower = 15000,

        -- Forward traction
        forwardTractionMax = 50000,

        -- Side traction
        sideTractionMultiplier = 800,
        sideTractionMaxAng = 25,
        sideTractionMax = 12000,
        sideTractionMin = 10000
    }

    -- Maximum length of the suspension
    self:SetSuspensionLength( params.suspensionLength )

    -- How strong is the suspension spring
    self:SetSpringStrength( params.springStrength )

    -- Damping coefficient for when the suspension is compressed/expanded
    self:SetSpringDamper( params.springDamper )

    -- Brake coefficient
    self:SetBrakePower( params.brakePower )

    -- Traction parameters
    self:SetForwardTractionMax( params.forwardTractionMax )
    self:SetForwardTractionBias( 0.0 )

    self:SetSideTractionMultiplier( params.sideTractionMultiplier )
    self:SetSideTractionMaxAng( params.sideTractionMaxAng )
    self:SetSideTractionMax( params.sideTractionMax )
    self:SetSideTractionMin( params.sideTractionMin )
end

--- Override this base class function.
function ENT:TurnOff()
    BaseClass.TurnOff( self )

    self.isTurningInPlace = false
end

--- Override this base class function.
function ENT:OnTakeDamage( dmginfo )
    if dmginfo:IsDamageType( 64 ) then -- DMG_BLAST
        local inflictor = dmginfo:GetInflictor()

        -- Increase damage taken by Half-life 2 RPGs
        if IsValid( inflictor ) and inflictor:GetClass() == "rpg_missile" then
            dmginfo:SetDamage( dmginfo:GetDamage() * 2.5 )
        end
    end

    BaseClass.OnTakeDamage( self, dmginfo )
end

function ENT:GetTurretOrigin()
    return self:LocalToWorld( self.TurretOffset )
end

function ENT:GetTurretAimDirection()
    local origin = self:GetTurretOrigin()
    local ang = self:LocalToWorldAngles( self:GetTurretAngle() )

    -- Use the driver's aim position directly when
    -- the turret is aiming close enough to it.
    local driver = self:GetDriver()

    if IsValid( driver ) and self:GetIsAimingAtTarget() then
        local dir = driver:GlideGetAimPos() - origin
        dir:Normalize()
        ang = dir:Angle()
    end

    return ang:Forward()
end

local TraceLine = util.TraceLine

function ENT:GetTurretAimPosition()
    local origin = self:GetTurretOrigin()
    local target = origin + self:GetTurretAimDirection() * 50000
    local tr = TraceLine( self:GetTraceData( origin, target ) )

    if tr.Hit then
        target = tr.HitPos
    end

    return target
end

--- Implement this base class function.
function ENT:OnWeaponFire( weapon, slotIndex )
    -- If this vehicle has more than one weapon,
    -- let the VSWEP class handle the logic.
    if slotIndex > 1 then
        return true
    end

    if self:WaterLevel() > 2 then
        return false
    end

    if self.isCannonInsideWall then
        weapon.nextFire = 0
        return false
    end

    local aimPos = self:GetTurretAimPosition()
    local projectilePos = self:GetProjectileStartPos()

    -- Make the projectile point towards the direction the
    -- turret is aiming at, no matter where it spawned.
    local dir = aimPos - projectilePos
    dir:Normalize()

    local projectile = Glide.FireProjectile( projectilePos, dir:Angle(), self:GetDriver(), self )
    projectile.damage = self.TurretDamage
    projectile:SetMaterial( "phoenix_storms/concrete0" )

    self:EmitSound( self.TurretFireSound, 100, math.random( 95, 105 ), self.TurretFireVolume )

    local eff = EffectData()
    eff:SetOrigin( projectilePos )
    eff:SetNormal( dir )
    eff:SetScale( 1 )
    util.Effect( "glide_tank_cannon", eff )

    local phys = self:GetPhysicsObject()

    if IsValid( phys ) then
        phys:ApplyForceOffset( dir * phys:GetMass() * -self.TurretRecoilForce, projectilePos )
    end

    local driver = self:GetDriver()

    if IsValid( driver ) then
        Glide.SendViewPunch( driver, -0.2 )
    end

    return false
end

local EntityPairs = Glide.EntityPairs

--- Override this base class function.
function ENT:UpdatePowerDistribution()
    -- Let the base class do front/rear power distribution
    BaseClass.UpdatePowerDistribution( self )

    -- Let's also do a left/right power distribution
    local rCount, lCount = 0, 0

    -- First, count how many wheels are in the left/right
    for _, w in EntityPairs( self.wheels ) do
        w.isOnRightSide = w.params.basePos[2] > 0

        if w.isOnRightSide then
            rCount = rCount + 1
        else
            lCount = lCount + 1
        end
    end

    -- Then, use that count to split the torque between left/right side wheels
    local lDistribution = 0.5 + self:GetPowerDistribution() * 0.5
    local rDistribution = 1 - lDistribution

    rDistribution = rDistribution / rCount
    lDistribution = lDistribution / lCount

    for _, w in EntityPairs( self.wheels ) do
        w.sideDistributionFactor = w.isOnRightSide and rDistribution or lDistribution
    end
end

local Abs = math.abs

--- Override this base class function.
function ENT:OnPostThink( dt, selfTbl )
    BaseClass.OnPostThink( self, dt, selfTbl )

    -- Update turret angles, if we have a driver
    local driver = self:GetDriver()

    if IsValid( driver ) and self:WaterLevel() < 2 then
        local newAng, isAimingAtTarget = self:UpdateTurret( driver, dt, self:GetTurretAngle() )

        -- Don't let it shoot while inside walls
        local origin = self:GetTurretOrigin()
        local projectilePos = self:GetProjectileStartPos()
        local tr = TraceLine( self:GetTraceData( origin, projectilePos ) )

        selfTbl.isCannonInsideWall = tr.Hit

        if selfTbl.isCannonInsideWall then
            isAimingAtTarget = false
        end

        self:SetTurretAngle( newAng )
        self:SetIsAimingAtTarget( isAimingAtTarget )
        self:ManipulateTurretBones( newAng )
    end
end

local ExpDecay = Glide.ExpDecay

--- Override this base class function.
function ENT:EngineThink( dt )
    local selfTbl = GetTable( self )

    local inputThrottle = self:GetInputFloat( 1, "accelerate" )
    local inputBrake = self:GetInputFloat( 1, "brake" )
    local inputSteer = self:GetInputFloat( 1, "steer" )
    local amphibiousMode = self.IsAmphibious and self:GetWaterState() > 0

    selfTbl.isTurningInPlace = selfTbl.CanTurnInPlace and not amphibiousMode
        and selfTbl.groundedCount == selfTbl.wheelCount
        and Abs( selfTbl.forwardSpeed ) < 100 and Abs( inputSteer ) > 0.1
        and Abs( inputThrottle + inputBrake ) < 0.1

    if selfTbl.isTurningInPlace then
        self:SetGear( 1 )

        -- Custom engine logic
        local throttle = ExpDecay( self:GetEngineThrottle(), Abs( inputSteer ), 4, dt )

        self:SetEngineThrottle( throttle )

        local minRPM = self:GetMinRPM()
        local rpmRange = self:GetMaxRPM() - minRPM
        local currentPower = ( self:GetEngineRPM() - minRPM ) / rpmRange

        currentPower = ExpDecay( currentPower, throttle * 0.5, 2, dt )

        self:SetFlywheelRPM( minRPM + rpmRange * currentPower )

        local torque = self:GetMaxRPMTorque() * selfTbl.TurnInPlaceTorqueMultiplier * inputSteer * throttle

        selfTbl.availableFrontTorque = torque
        selfTbl.availableRearTorque = -torque
        selfTbl.frontBrake = 0
        selfTbl.rearBrake = 0
    else
        BaseClass.EngineThink( self, dt )
    end
end

--- Override this base class function.
function ENT:UpdateSteering( dt )
    local selfTbl = GetTable( self )

    if selfTbl.isTurningInPlace then
        local inputSteer = ExpDecay( selfTbl.inputSteer, self:GetInputFloat( 1, "steer" ), 4, dt )

        self:SetSteering( inputSteer )
        selfTbl.steerAngle[2] = inputSteer * -70
        selfTbl.inputSteer = inputSteer
    else
        BaseClass.UpdateSteering( self, dt )
    end
end

local Clamp = math.Clamp

local traction, tractionFront, tractionRear
local frontTorque, rearTorque, steerAngle, frontBrake, rearBrake
local groundedCount, rpm, avgRPM, totalSideSlip, totalForwardSlip, totalAngVel, state

--- Override this base class function.
--- On tanks, if `isTurningInPlace` is true, `frontTorque` and `rearTorque`
--- becomes the torque for the right-side track wheels and left-side track wheels respectively.
function ENT:WheelThink( dt )
    local selfTbl = GetTable( self )

    local phys = self:GetPhysicsObject()
    local isAsleep = IsValid( phys ) and phys:IsAsleep()
    local isTurningInPlace = selfTbl.isTurningInPlace

    local maxRPM = self:GetTransmissionMaxRPM( self:GetGear() )
    local inputHandbrake = self:GetInputBool( 1, "handbrake" )

    traction = self:GetForwardTractionBias()
    tractionFront = ( 1 + Clamp( traction, -1, 0 ) ) * selfTbl.frontTractionMult
    tractionRear = ( 1 - Clamp( traction, 0, 1 ) ) * selfTbl.rearTractionMult

    frontTorque = selfTbl.availableFrontTorque
    rearTorque = selfTbl.availableRearTorque
    steerAngle = selfTbl.steerAngle

    frontBrake, rearBrake = selfTbl.frontBrake, selfTbl.rearBrake
    groundedCount, avgRPM, totalSideSlip, totalForwardSlip, totalAngVel = 0, 0, 0, 0, 0

    for _, w in EntityPairs( selfTbl.wheels ) do
        w:Update( self, steerAngle, isAsleep, dt )

        totalSideSlip = totalSideSlip + w:GetSideSlip()
        totalForwardSlip = totalForwardSlip + w:GetForwardSlip()

        rpm = w:GetRPM()
        avgRPM = avgRPM + rpm * w.distributionFactor

        state = w.state
        state.brake = w.isFrontWheel and frontBrake or rearBrake
        state.forwardTractionMult = w.isFrontWheel and tractionFront or tractionRear
        state.sideTractionMult = w.isFrontWheel and selfTbl.frontSideTractionMult or selfTbl.rearSideTractionMult

        if state.isOnGround then
            groundedCount = groundedCount + 1
            totalAngVel = totalAngVel + Abs( state.angularVelocity )

            if isTurningInPlace then
                state.torque = w.sideDistributionFactor * ( w.isOnRightSide and frontTorque or rearTorque )
            else
                state.torque = w.distributionFactor * ( w.isFrontWheel and frontTorque or rearTorque )
            end
        else
            state.torque = 0
        end

        if inputHandbrake and not w.isFrontWheel then
            state.angularVelocity = 0
        end

        if rpm > maxRPM then
            w:SetRPM( maxRPM )
        end
    end

    selfTbl.avgPoweredRPM = avgRPM
    selfTbl.groundedCount = groundedCount
    selfTbl.avgSideSlip = totalSideSlip / selfTbl.wheelCount
    selfTbl.avgForwardSlip = totalForwardSlip / selfTbl.wheelCount

    self:SetTrackSpeed( isAsleep and 0 or totalAngVel / self.wheelCount )
end
