AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

DEFINE_BASECLASS( "base_glide_aircraft" )

--- Override this base class function.
function ENT:OnPostInitialize()
    BaseClass.OnPostInitialize( self )

    -- Setup variables used on all planes
    self.powerResponse = 0.15

    self.isGrounded = false
    self.brake = 0
    self.divePitch = 0
end

--- Override this base class function.
function ENT:Repair()
    BaseClass.Repair( self )

    -- Create main propeller, if it doesn't exist
    if not IsValid( self.mainProp ) and self.PropModel ~= "" then
        self.mainProp = self:CreatePropeller( self.PropOffset, self.PropRadius, self.PropModel, self.PropFastModel )
        self.mainProp:SetSpinAngle( math.random( 0, 180 ) )
    end
end

--- Override this base class function.
function ENT:CreateWheel( offset, params )
    -- Tweak default wheel params
    params = params or {}

    params.brakePower = params.brakePower or 800
    params.suspensionLength = params.suspensionLength or 10
    params.springStrength = params.springStrength or 1000
    params.springDamper = params.springDamper or 4000

    -- Let the base class create the wheel
    return BaseClass.CreateWheel( self, offset, params )
end

--- Creates and stores a new propeller entity.
---
--- `radius` is used for collision checking.
--- `slowModel` is the model shown when the propeller is spinning slowly.
--- `fastModel` is the model shown when the propeller is spinning fast.
function ENT:CreatePropeller( offset, radius, slowModel, fastModel )
    local prop = ents.Create( "glide_rotor" )

    if not prop or not IsValid( prop ) then
        self:Remove()
        error( "Failed to spawn propeller! Vehicle removed!" )
        return
    end

    self:DeleteOnRemove( prop )

    prop:SetOwner( self )
    prop:SetParent( self )
    prop:SetLocalPos( offset )
    prop:Spawn()
    prop:SetupRotor( offset, radius, slowModel, fastModel )
    prop:SetSpinAxis( "Forward" )
    prop.maxSpinSpeed = 5000

    self.rotors[#self.rotors + 1] = prop

    return prop
end

--- Override this base class function.
function ENT:TurnOn()
    BaseClass.TurnOn( self )

    self:SetEngineState( 2 )
    self:SetExtraPitch( 1 )
    self.divePitch = 0
end

--- Override this base class function.
function ENT:TurnOff()
    BaseClass.TurnOff( self )

    self:SetEngineState( 0 )
    self:SetExtraPitch( 1 )
    self.divePitch = 0
end

--- Implement this base class function.
function ENT:OnDriverEnter()
    if self:GetEngineHealth() > 0 then
        self:TurnOn()
    end
end

--- Implement this base class function.
function ENT:OnDriverExit()
    self:TurnOff()
    self.brake = 0.1
end

local Abs = math.abs
local Clamp = math.Clamp
local Approach = math.Approach
local ExpDecay = Glide.ExpDecay
local EntityPairs = Glide.EntityPairs

local IsValid = IsValid
local TriggerOutput = WireLib and WireLib.TriggerOutput or nil

local WORLD_DOWN = Vector( 0, 0, -1 )

--- Override this base class function.
function ENT:OnPostThink( dt, selfTbl )
    BaseClass.OnPostThink( self, dt, selfTbl )

    -- Damage the engine when underwater
    if self:WaterLevel() > 2 then
        self:SetPower( 0 )
        self:SetEngineHealth( 0 )
        self:UpdateHealthOutputs()
    end

    selfTbl.inputPitch = ExpDecay( selfTbl.inputPitch, self:GetInputFloat( 1, "pitch" ), 10, dt )
    selfTbl.inputRoll = ExpDecay( selfTbl.inputRoll, self:GetInputFloat( 1, "roll" ), 10, dt )
    selfTbl.inputYaw = ExpDecay( selfTbl.inputYaw, self:GetInputFloat( 1, "yaw" ), 10, dt )

    self:SetElevator( selfTbl.inputPitch )
    self:SetRudder( selfTbl.inputYaw )
    self:SetAileron( selfTbl.inputRoll )

    local power = self:GetPower()
    local throttle = self:GetInputFloat( 1, "throttle" )

    -- If the main propeller was destroyed, turn off and disable power
    if not IsValid( selfTbl.mainProp ) and selfTbl.PropModel ~= "" then
        if self:IsEngineOn() then
            self:TurnOff()
        end

        power = 0
        throttle = 0
    end

    self:SetThrottle( throttle )

    if self:IsEngineOn() then
        local phys = self:GetPhysicsObject()

        if IsValid( phys ) then
            local pitchVel = Clamp( Abs( phys:GetAngleVelocity()[2] / 50 ), -1, 1 ) * 0.1
            local downDot = WORLD_DOWN:Dot( self:GetForward() )

            selfTbl.divePitch = Approach( selfTbl.divePitch, downDot > 0.5 and downDot or 0, dt * 0.5 )
            self:SetExtraPitch( Approach( self:GetExtraPitch(), 1 + pitchVel + ( selfTbl.divePitch * 0.3 ), dt * 0.1 ) )
        end

        if self:GetEngineHealth() > 0 then
            if selfTbl.isGrounded then
                power = Approach( power, 1 + Clamp( throttle, -0.2, 1 ), dt * selfTbl.powerResponse )
            else
                local response = throttle < 0 and selfTbl.powerResponse * 0.75 or selfTbl.powerResponse

                -- Approach towards the idle power plus the throttle input
                power = Approach( power, 1 + throttle, dt * response )

                if throttle < 0 and power < 0.8 then
                    power = 0.8
                end
            end
        else
            -- Turn off
            power = Approach( power, 0, dt * selfTbl.powerResponse * 0.4 )

            if power < 0.1 then
                self:TurnOff()
            end
        end

        self:SetPower( power )

        -- Process damage effects over time
        self:DamageThink( dt )
    else
        -- Approach towards 0 power
        power = ( power > 0 ) and ( power - dt * selfTbl.powerResponse * 0.6 ) or 0

        self:SetPower( power )
        self:SetExtraPitch( Approach( self:GetExtraPitch(), 1, dt * 0.1 ) )

        if throttle > 0 then
            self:TurnOn()
        end
    end

    if TriggerOutput then
        TriggerOutput( self, "Power", power )
    end

    -- Update wheels
    local torque = 0

    if throttle < 0 and selfTbl.forwardSpeed < 100 then
        selfTbl.brake = 0.1

        if selfTbl.forwardSpeed > selfTbl.MaxReverseSpeed then
            torque = -selfTbl.ReverseTorque
        end

    elseif throttle < 0 and selfTbl.forwardSpeed > 0 then
        selfTbl.brake = 1

    else
        selfTbl.brake = 0.5
    end

    local isGrounded = false
    local totalSideSlip = 0
    local state

    for _, w in EntityPairs( self.wheels ) do
        state = w.state

        state.brake = self.brake
        state.torque = torque

        if state.isOnGround then
            isGrounded = true
            totalSideSlip = totalSideSlip + w:GetSideSlip()
        end
    end

    selfTbl.isGrounded = isGrounded

    local inputSteer = selfTbl.inputYaw --self:GetInputFloat( 1, "steer" )
    local sideSlip = Clamp( totalSideSlip / selfTbl.wheelCount, -1, 1 )

    -- Limit the input and the rate of change depending on speed.
    local invSpeedOverFactor = 1 - Clamp( selfTbl.totalSpeed / selfTbl.SteerConeMaxSpeed, 0, 0.9 )
    inputSteer = inputSteer * invSpeedOverFactor

    -- Counter-steer when slipping and going fast
    local counterSteer = Clamp( sideSlip * ( 1 - invSpeedOverFactor ), -0.5, 0.5 )
    inputSteer = Clamp( inputSteer + counterSteer, -1, 1 )

    selfTbl.steerAngle[2] = inputSteer * -selfTbl.MaxSteerAngle

    -- Check if the wings are stalling
    local controllability = Abs( selfTbl.forwardSpeed ) / self.PlaneParams.controlSpeed

    self:SetIsStalling( controllability < 0.75 and self.altitude > 100 )
end

--- Implement this base class function.
function ENT:OnSimulatePhysics( phys, dt, outLin, outAng )
    if self:WaterLevel() < 2 then
        self:SimulatePlane( phys, dt, self.PlaneParams, 1, outLin, outAng )
    end
end
