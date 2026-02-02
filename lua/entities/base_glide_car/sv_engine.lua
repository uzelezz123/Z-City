function ENT:EngineInit()
    self:UpdateGearList()

    -- Fake flywheel parameters
    self.flywheelMass = 80
    self.flywheelRadius = 0.5

    self.flywheelFriction = -6000
    self.flywheelTorque = 20000
    self.engineBrakeTorque = 2000

    -- Fake engine variables
    self.flywheelVelocity = 0
    self.clutch = 1
    self.switchCD = 0

    -- Wheel control variables
    self.groundedCount = 0
    self.burnout = 0

    self.frontBrake = 0
    self.rearBrake = 0
    self.availableFrontTorque = 0
    self.availableRearTorque = 0

    self.frontTractionMult = 1
    self.rearTractionMult = 1

    self.avgSideSlip = 0
    self.avgPoweredRPM = 0
    self.avgForwardSlip = 0
end

--- Returns a list of available transmission gears.
--- Unlike `ENT:GetGears()` this will return overrides from
--- the Transmission Editor tool, if they're set.
function ENT:GetGearList()
    local overrideGears = self.EntityMods["glide_transmission_overrides"]

    if type( overrideGears ) == "table" then
        return overrideGears
    end

    return self:GetGears()
end

function ENT:UpdateGearList()
    local gears = self:GetGearList()
    local ClampGearRatio = Glide.ClampGearRatio

    local minGear = 0
    local maxGear = 0
    local gearRatios = {}

    for gear, ratio in pairs( gears ) do
        gearRatios[gear] = ClampGearRatio( ratio )

        if gear < minGear then minGear = gear end
        if gear > maxGear then maxGear = gear end
    end

    if self.minGear ~= minGear or self.maxGear ~= maxGear then
        self:SwitchGear( 0, 0 )
    end

    self.minGear = minGear
    self.maxGear = maxGear
    self.gearRatios = gearRatios

    if WireLib then
        WireLib.TriggerOutput( self, "MaxGear", self.maxGear )
    end
end

--- Override this base class function.
function ENT:OnEntityReload()
    self:UpdateGearList()
end

local EntityPairs = Glide.EntityPairs

function ENT:UpdatePowerDistribution()
    self.shouldUpdatePowerDistribution = false

    local frontCount, rearCount = 0, 0

    -- First, count how many wheels are in the front/rear
    for _, w in EntityPairs( self.wheels ) do
        if w.isFrontWheel then
            frontCount = frontCount + 1
        else
            rearCount = rearCount + 1
        end
    end

    -- Then, use that count to split the front/rear torque between wheels later
    local frontDistribution = 0.5 + self:GetPowerDistribution() * 0.5
    local rearDistribution = 1 - frontDistribution

    frontDistribution = frontDistribution / frontCount
    rearDistribution = rearDistribution / rearCount

    for _, w in EntityPairs( self.wheels ) do
        w.distributionFactor = w.isFrontWheel and frontDistribution or rearDistribution
    end
end

do
    local TAU = math.pi * 2

    function ENT:GetFlywheelRPM()
        return self.flywheelVelocity * 60 / TAU
    end

    function ENT:SetFlywheelRPM( rpm )
        self.flywheelVelocity = rpm * TAU / 60
        self:SetEngineRPM( rpm )
    end

    function ENT:TransmissionToEngineRPM( gear )
        return self.avgPoweredRPM * self.gearRatios[gear] * self:GetDifferentialRatio() * 60 / TAU
    end

    function ENT:GetTransmissionMaxRPM( gear )
        return self:GetFlywheelRPM() / self.gearRatios[gear] / self:GetDifferentialRatio()
    end
end

function ENT:EngineAccelerate( torque, dt )
    -- Calculate moment of inertia
    local radius = self.flywheelRadius
    local inertia = 0.5 * self.flywheelMass * radius * radius

    -- Calculate angular acceleration using Newton's second law for rotation
    local angularAcceleration = torque / inertia -- Ah, the classic F = m * a, a = F / m

    -- Calculate new angular velocity after delta time
    self.flywheelVelocity = self.flywheelVelocity + angularAcceleration * dt
end

local Clamp = math.Clamp

function ENT:SwitchGear( index, cooldown )
    if self:GetGear() == index then return end

    index = Clamp( index, self.minGear, self.maxGear )

    self.switchCD = cooldown or ( index == 1 and 0 or ( self:GetFastTransmission() and 0.15 or 0.3 ) )
    self.clutch = 1
    self:SetGear( index )
end

local Remap = math.Remap

function ENT:GetTransmissionTorque( gear, minTorque, maxTorque )
    local torque = Remap( self:GetFlywheelRPM(), self:GetMinRPM(), self:GetMaxRPM(), minTorque, maxTorque )

    -- Validation
    torque = Clamp( torque, minTorque, maxTorque )

    -- Clutch
    torque = torque * ( 1 - self.clutch )

    -- Gearing, differential & losses
    torque = torque * self.gearRatios[gear] * self:GetDifferentialRatio() * self:GetTransmissionEfficiency()

    return gear == -1 and -torque or torque
end

local Abs = math.abs

function ENT:AutoGearSwitch( throttle )
    -- Are we trying to go backwards?
    if self.forwardSpeed < 100 and self:GetInputFloat( 1, "brake" ) > 0.2 then
        self:SwitchGear( -1, 0 )
        return
    end

    -- Don't switch from reverse gear while still going backwards fast enough
    local currentGear = self:GetGear()
    if currentGear < 0 and self.forwardSpeed < -100 then return end

    -- Don't switch when the wheels are slipping forwards
    if Abs( self.avgForwardSlip ) > 10 then return end

    local gear = Clamp( currentGear, 1, self.maxGear )
    local minRPM, maxRPM = self:GetMinRPM(), self:GetMaxRPM()

    -- Avoid hitting the redline
    maxRPM = maxRPM * 0.98

    -- When accelerating, switch up early when the throttle is low
    if self.forwardAcceleration > 0 then
        maxRPM = maxRPM * ( 0.6 + throttle * 0.4 )
    end

    local gearRPM

    -- Pick the gear that matches better the engine-to-transmission RPM
    for i = 1, self.maxGear do
        gearRPM = self:TransmissionToEngineRPM( i )

        -- If this is the first gear, and it's transmission RPM is below the `minRPM`, OR;
        -- If this gear's transmission RPM is between `minRPM` and `maxRPM`...
        if ( i == 1 and gearRPM < minRPM ) or ( gearRPM > minRPM and gearRPM < maxRPM ) then
            gear = i -- Pick this gear
            break
        end
    end

    -- Only shift one gear down if the RPM is too low
    local threshold = minRPM + ( maxRPM - minRPM ) * ( 0.5 - throttle * 0.3 )
    if gear < currentGear and gear > currentGear - 2 and self:GetEngineRPM() > threshold then return end

    self:SwitchGear( gear )
end

-- These locals are used both on `ENT:EngineClutch` and `ENT:EngineThink`
local inputThrottle, inputBrake, inputHandbrake

function ENT:EngineClutch( dt )
    -- Is the gear switch on cooldown?
    if self.switchCD > 0 then
        self.switchCD = self.switchCD - dt
        inputThrottle = 0
        return 0
    end

    if inputHandbrake then
        return 1
    end

    local absForwardSpeed = Abs( self.forwardSpeed )

    -- Are we airborne while going fast?
    if self.groundedCount < 1 and absForwardSpeed > 30 then
        return 1
    end

    -- Are we trying to break from a backwards velocity?
    if self.forwardSpeed < -50 and inputBrake > 0 and self:GetGear() < 0 then
        return 1
    end

    -- Engage the clutch when moving fast enough
    if absForwardSpeed > 200 then
        return 0
    end

    -- Engage the clutch while the throttle is high
    return inputThrottle > 0.1 and 0 or 1
end

local Max = math.max
local Approach = math.Approach

local gear, rpm, clutch, isRedlining, transmissionRPM, maxRPM
local throttle, gearTorque, availableTorque

local glide_fuelsystem = CreateConVar("glide_fuelsystem", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Enables/disabled fuel system for glide vehicles", 0, 1)

function ENT:EngineThink( dt )
    gear = self:GetGear()

    local amphibiousMode = self.IsAmphibious and self:GetWaterState() > 0

    -- These variables are used both on `ENT:EngineClutch` and `ENT:EngineThink`
    inputThrottle = self:GetInputFloat( 1, "accelerate" )
    inputBrake = self:GetInputFloat( 1, "brake" )
    inputHandbrake = self:GetInputBool( 1, "handbrake" )

    if amphibiousMode then
        self.burnout = 0
        self:BoatEngineThink( dt )
        self:SetIsRedlining( false )

        if inputThrottle > 0 then
            self:SwitchGear( 1, 0 )

        elseif inputBrake > 0 then
            self:SwitchGear( -1, 0 )
        end

    elseif self.burnout > 0 then
        self:SwitchGear( 1, 0 )

        if inputThrottle < 0.1 or inputBrake < 0.1 then
            self.burnout = 0
        end

    elseif not self.inputManualShift then
        self:AutoGearSwitch( inputThrottle )
    end

    -- Reverse the throttle/brake inputs while in reverse gear
    if gear < 0 and not self.inputManualShift then
        inputThrottle, inputBrake = inputBrake, inputThrottle
    end

    -- When the engine is damaged, reduce the throttle
    if self.damageThrottleCooldown and self.damageThrottleCooldown < 0.3 then
        inputThrottle = inputThrottle * 0.3
    end

    -- When the engine is on fire, reduce the throttle
    if self:GetIsEngineOnFire() then
        inputThrottle = inputThrottle * 0.7
    end

    rpm = self:GetFlywheelRPM()

    -- Handle auto-clutch
    clutch = amphibiousMode and 1 or self:EngineClutch( dt )

    -- Do a burnout when holding down the throttle and brake inputs
    if inputThrottle > 0.1 and inputBrake > 0.1 and Abs( self.forwardSpeed ) < 50 then
        self.burnout = Approach( self.burnout, 1, dt * 2 )

        clutch = 0

        -- Allow the driver to spin the car
        local phys = self:GetPhysicsObject()
        local mins, maxs = self:OBBMins(), self:OBBMaxs()
        local burnoutForce = phys:GetMass() * self.BurnoutForce * self.burnout * dt

        burnoutForce = burnoutForce * self.inputSteer * Clamp( Abs( self.avgForwardSlip ) * 0.1, 0, 1 )

        local frontBurnout = self:GetPowerDistribution() > 0
        local dir = frontBurnout and self:GetRight() or -self:GetRight()

        self.frontBrake = frontBurnout and 0 or 0.25
        self.rearBrake = frontBurnout and 0.25 or 0

        self.frontTractionMult = frontBurnout and 0.25 or 2
        self.rearTractionMult = frontBurnout and 2 or 0.25

        for _, w in EntityPairs( self.wheels ) do
            if w.isFrontWheel == frontBurnout then
                local pos = w:GetLocalPos()

                pos[1] = pos[1] > 0 and maxs[1] * 2 or mins[1] * 2
                pos = self:LocalToWorld( pos )

                phys:ApplyForceOffset( dir * burnoutForce, pos )
            end
        end

    elseif inputHandbrake then
        self.frontTractionMult = 1
        self.rearTractionMult = 0.5

        self.frontBrake = 0
        self.rearBrake = 0.5
        self.clutch = 1
        clutch = 1

    else
        -- Automatically apply brakes when not accelerating, on the ground,
        -- with low engine RPM, while on first gear or reverse gear.
        if
            ( gear == -1 or gear == 1 ) and
            inputThrottle < 0.05 and
            inputBrake < 0.1 and
            self.groundedCount > 1 and
            rpm < self:GetMinRPM() * 1.2
        then
            inputBrake = 0.2
        end

        self.frontBrake = inputBrake * 0.5
        self.rearBrake = inputBrake * 0.5

        self.frontTractionMult = 1
        self.rearTractionMult = 1
    end

    clutch = Approach( self.clutch, clutch, dt * ( ( gear < 2 and inputThrottle > 0.1 ) and 6 or 2 ) )

    self.clutch = clutch
    isRedlining = false
    transmissionRPM = 0

    -- If we're not in neutral, convert the avg.
    -- transmission RPM back to the engine RPM.
    if gear ~= 0 then
        transmissionRPM = self:TransmissionToEngineRPM( gear )
        transmissionRPM = gear < 0 and -transmissionRPM or transmissionRPM
        rpm = ( rpm * clutch ) + ( Max( 0, transmissionRPM ) * ( 1 - clutch ) )
    end

    throttle = self:GetEngineThrottle()
    gearTorque = self:GetTransmissionTorque( gear, self:GetMinRPMTorque(), self:GetMaxRPMTorque() )
    availableTorque = gearTorque * throttle

    -- Simulate engine braking
    if transmissionRPM < 0 then
        -- The vehicle is moving against the current gear, do some hard engine braking.
        availableTorque = availableTorque + gearTorque * 2
    else
        -- The vehicle is coasting, apply a custom engine brake torque.
        local engineBrakeTorque = self:GetTransmissionTorque( gear, self.engineBrakeTorque, self.engineBrakeTorque )
        availableTorque = availableTorque - engineBrakeTorque * ( 1 - throttle ) * 0.5
    end

    -- Limit the engine RPM, check if it's redlining
    maxRPM = self:GetMaxRPM()

    if rpm < self:GetMinRPM() then
        rpm = self:GetMinRPM()

    elseif rpm > maxRPM then
        if rpm > maxRPM * 1.2 then
            availableTorque = 0
        end

        rpm = maxRPM

        if gear ~= self.maxGear or self.groundedCount < self.wheelCount then
            isRedlining = true
        end
    end

    self:SetFlywheelRPM( Clamp( rpm, 0, maxRPM ) )

    -- Update the amount of available torque to the transmission
    if self:GetTurboCharged() then
        availableTorque = availableTorque * ( 1 + ( rpm / maxRPM ) * 0.3 )
    end

    if self.burnout > 0 then
        availableTorque = availableTorque + availableTorque * self.burnout * 0.1
    end

    -- Split torque between front and rear wheels
    local front = 0.5 + self:GetPowerDistribution() * 0.5
    local rear = 1 - front

    self.availableFrontTorque = availableTorque * front
    self.availableRearTorque = availableTorque * rear

    if not amphibiousMode then
        -- Accelerate the engine flywheel and update network variables
        throttle = Approach( throttle, inputThrottle, dt * 4 )

        self:EngineAccelerate( self.flywheelFriction + self.flywheelTorque * throttle, dt )
        self:SetEngineThrottle( throttle )
        self:SetIsRedlining( isRedlining and inputThrottle > 0 )
    end

    local fuel = self:GetFuel()

    if fuel <= 0 then
        self:TurnOff()
    else
        fuel = fuel - ((rpm / 7000) * dt) * (glide_fuelsystem:GetBool() and 1 or 0)
        self:SetFuel(math.max(fuel, 0))
    end
end

local ExpDecay = Glide.ExpDecay

function ENT:BoatEngineThink( dt )
    local waterState = self:GetWaterState()
    local speed = self.forwardSpeed

    throttle = 0

    if Abs( speed ) > 20 or waterState > 0 then
        throttle = inputThrottle - inputBrake
    end

    self:SetEngineThrottle( ExpDecay( self:GetEngineThrottle(), Abs( throttle ), 5, dt ) )

    local power = Abs( throttle )

    if throttle < 0 then
        power = power * Clamp( -speed / self.BoatParams.maxSpeed * 4, 0, 1 )
        power = power * 0.4

    elseif waterState > 0 then
        power = power * ( 0.4 + Clamp( Abs( speed ) / self.BoatParams.maxSpeed, 0, 1 ) * 0.6 )
        power = power * ( waterState > 1 and 0.6 or 1 )
    end

    local minRPM = self:GetMinRPM()
    local rpmRange = self:GetMaxRPM() - minRPM
    local currentPower = ( self:GetEngineRPM() - minRPM ) / rpmRange

    currentPower = ExpDecay( currentPower, power, 2 + power * 2, dt )

    self:SetFlywheelRPM( minRPM + rpmRange * currentPower )
end
