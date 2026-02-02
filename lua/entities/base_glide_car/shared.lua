ENT.Type = "anim"
ENT.Base = "base_glide"

ENT.PrintName = "Glide Car"
ENT.Author = "StyledStrike"
ENT.AdminOnly = false
ENT.Editable = true

-- Change vehicle type
ENT.VehicleType = Glide.VEHICLE_TYPE.CAR

-- Should we prevent players from editing these NW variables?
ENT.UneditableNWVars = {}

-- Should this vehicle use the siren system?
ENT.CanSwitchSiren = false

-- Does this vehicle have headlights?
ENT.CanSwitchHeadlights = true

-- Does this vehicle have turn signals?
ENT.CanSwitchTurnSignals = true

-- Can this vehicle drive over water?
ENT.IsAmphibious = false

DEFINE_BASECLASS( "base_glide" )

--- Override this base class function.
function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    -- Setup default network variables. Do not override
    -- these slots when creating your own on child classes!
    self:NetworkVar( "Bool", "IsRedlining" )
    self:NetworkVar( "Bool", "IsHonking" )
    self:NetworkVar( "Int", "SirenState" )

    self:NetworkVar( "Int", "Gear" )
    self:NetworkVar( "Float", "Steering" )
    self:NetworkVar( "Float", "EngineRPM" )
    self:NetworkVar( "Float", "EngineThrottle" )

    self:NetworkVar( "Float", "Fuel" )
    self:NetworkVar( "Float", "MaxFuel" )

    -- All DT variables below this comment are editable properties
    self:NetworkVar( "Vector", "TireSmokeColor", { KeyName = "TireSmokeColor", Edit = { type = "VectorColor", order = 0, category = "#glide.editvar.wheels" } } )

    local order = 0
    local uneditable = self.UneditableNWVars

    -- We add a bunch of floats here so, this utility function helps.
    local function AddFloatVar( key, min, max, category )
        order = order + 1

        local editData = Either( uneditable[key] == true or category == nil, nil, {
            KeyName = key,
            --Edit = { type = "Float", order = order, min = min, max = max, category = category }
        } )

        self:NetworkVar( "Float", key, editData )
    end

    local function AddBoolVar( key, category )
        order = order + 1

        self:NetworkVar( "Bool", key, {
            KeyName = key,
            --Edit = { type = "Bool", order = order, category = category }
        } )
    end

    -- Steering parameters
    AddFloatVar( "MaxSteerAngle", 10, 80, "#glide.editvar.steering" )
    AddFloatVar( "SteerConeChangeRate", 2, 20, "#glide.editvar.steering" )
    AddFloatVar( "SteerConeMaxSpeed", 100, 5000, "#glide.editvar.steering" )
    AddFloatVar( "SteerConeMaxAngle", 0.05, 0.9, "#glide.editvar.steering" )
    AddFloatVar( "CounterSteer", 0, 1, "#glide.editvar.steering" )

    -- Fake engine parameters
    AddBoolVar( "TurboCharged", "#glide.editvar.engine" )
    AddBoolVar( "FastTransmission", "#glide.editvar.engine" )

    AddFloatVar( "MinRPM", 500, 5000, "#glide.editvar.engine" )
    AddFloatVar( "MaxRPM", 6000, 30000, "#glide.editvar.engine" )
    AddFloatVar( "MinRPMTorque", 10, 20000, "#glide.editvar.engine" )
    AddFloatVar( "MaxRPMTorque", 10, 20000, "#glide.editvar.engine" )
    AddFloatVar( "DifferentialRatio", 0.05, 4, "#glide.editvar.engine" )
    AddFloatVar( "TransmissionEfficiency", 0.3, 1, "#glide.editvar.engine" )
    AddFloatVar( "PowerDistribution", -1, 1, "#glide.editvar.engine" )

    -- Make wheel parameters available as network variables too
    AddFloatVar( "WheelRadius", 10, 40, "#glide.editvar.wheels" )
    AddFloatVar( "BrakePower", 500, 5000, "#glide.editvar.wheels" )

    AddFloatVar( "SuspensionLength", 5, 50, "#glide.editvar.suspension" )
    AddFloatVar( "SpringStrength", 100, 5000, "#glide.editvar.suspension" )
    AddFloatVar( "SpringDamper", 100, 10000, "#glide.editvar.suspension" )

    AddFloatVar( "ForwardTractionMax", 1000, 10000, "#glide.editvar.traction" )
    AddFloatVar( "ForwardTractionBias", -1, 1, "#glide.editvar.traction" )

    AddFloatVar( "SideTractionMultiplier", 5, 100, "#glide.editvar.traction" )
    AddFloatVar( "SideTractionMaxAng", 5, 90, "#glide.editvar.traction" )
    AddFloatVar( "SideTractionMax", 100, 5000, "#glide.editvar.traction" )
    AddFloatVar( "SideTractionMin", 100, 5000, "#glide.editvar.traction" )

    if SERVER then
        -- Callback used to change the wheel radius
        self:NetworkVarNotify( "WheelRadius", self.OnWheelRadiusChange )

        -- Callback used to update the power distribution among wheels
        self:NetworkVarNotify( "PowerDistribution", self.OnPowerDistributionChange )
    end

    if CLIENT then
        -- Callback used to play gear change sounds
        self:NetworkVarNotify( "Gear", self.OnGearChange )
    end
end

--- Implement this base class function.
function ENT:UpdatePlayerPoseParameters( ply )
    ply:SetPlaybackRate( 1 )

    if CLIENT and ply == self:GetDriver() then
        ply:SetPoseParameter( "vehicle_steer", self:GetSteering() )
        ply:InvalidateBoneCache()
    end

    return true
end

--- Override this base class function.
function ENT:IsReversing()
    return self:GetGear() == -1
end

if CLIENT then
    ENT.CameraOffset = Vector( -230, 0, 50 )
    ENT.CameraAngleOffset = Angle( 4, 0, 0 )

    -- Setup how far away players can hear sounds and update misc. features
    ENT.MaxSoundDistance = 4000
    ENT.MaxMiscDistance = 5000

    -- Sounds
    ENT.StartSound = "Glide.Engine.CarStart"
    ENT.StartTailSound = "Glide.Engine.CarStartTail"
    ENT.ExhaustPopSound = "Glide.ExhaustPop.Sport"
    ENT.StartedSound = ""
    ENT.StoppedSound = "glide/engines/shut_down_1.wav"

    ENT.ExternalGearSwitchSound = "Glide.GearSwitch.External"
    ENT.InternalGearSwitchSound = "Glide.GearSwitch.Internal"
    ENT.HornSound = ")glide/horns/police_horn_1.wav"

    ENT.SirenLoopSound = ")glide/alarms/police_siren_3.wav"
    ENT.SirenLoopAltSound = ")glide/horns/police_horn_2.wav"
    ENT.SirenInterruptSound = "Glide.Wail.Interrupt"
    ENT.SirenVolume = 0.8

    ENT.TurboLoopSound = "glide/engines/turbo_spin.wav"
    ENT.TurboBlowoffSound = "glide/engines/turbo_blowoff.wav"
    ENT.TurboVolume = 0.95
    ENT.TurboBlowoffVolume = 0.3
    ENT.TurboPitch = 100

    ENT.ReverseSound = ""
    ENT.BrakeReleaseSound = ""
    ENT.BrakeSqueakSound = ""

    ENT.BrakeLoopSound = ""
    ENT.BrakeLoopVolume = 0.6

    -- Exhaust positions
    ENT.ExhaustOffsets = {}
    ENT.ExhaustAlpha = 50

    -- Strips/lines where smoke particles are spawned when the engine is damaged
    ENT.EngineSmokeStrips = {}

    -- How much does the engine smoke gets shot up?
    ENT.EngineSmokeMaxZVel = 100

    -- How long is the on/off cycle for sirens?
    ENT.SirenCycle = 0.8

    -- Offsets and timings for strobe lights.
    -- This should contain a table of tables, where each looks like this:
    --
    -- { offset = Vector( 0, 0, 0 ), time = 0 }, -- Blinks at the start of the cycle
    -- { offset = Vector( 0, 0, 0 ), time = 0.5, duration = 0.5 }, -- Blinks in the middle of the cycle, for half of the cycle's duration
    -- { bodygroup = 123 = time = 0 } -- If given a `bodygroup` ID, toggle that too. You can also omit `offset` to not draw a sprite.
    ENT.SirenLights = {}

    -- Children classes should override this
    -- function to add engine sounds to the stream.
    function ENT:OnCreateEngineStream( _stream ) end

    -- Children classes should override this function
    -- to update animations (the steering wheel for example).
    function ENT:OnUpdateAnimations()
        self:SetPoseParameter( "vehicle_steer", self:GetSteering() )
        self:InvalidateBoneCache()
    end
end

if SERVER then
    ENT.CollisionParticleSize = 0.9
    ENT.AngularDrag = Vector( -0.5, -0.5, -4 ) -- Roll, pitch, yaw

    -- How long does it take for the vehicle to start up?
    ENT.StartupTime = 0.6

    -- How much force to apply when trying to turn while doing a burnout?
    ENT.BurnoutForce = 25

    -- How much force to apply when the driver tries to unflip the vehicle?
    ENT.UnflipForce = 6

    -- How much force to apply when the driver tries to spin the airborne vehicle?
    ENT.AirControlForce = Vector( 0.8, 0.3, 0.2 ) -- Roll, pitch, yaw

    -- How fast can the driver spin the vehicle while airborne?
    ENT.AirMaxAngularVelocity = Vector( 150, 200, 150 ) -- Roll, pitch, yaw

    --- Returns which inputs applies air control forces.
    --- Should return a roll, pitch and yaw input.
    function ENT:GetAirInputs()
        return self:GetInputFloat( 1, "steer" ), self:GetInputFloat( 1, "lean_pitch" ), 0
    end

    --- Returns a list of available gears and gear ratios for this vehicle.
    --- This has to be a function because children classes couldn't remove
    --- existing keys if this list was defined on the ENT table.
    function ENT:GetGears()
        return {
            [-1] = 2.5, -- Reverse
            [0] = 0, -- Neutral (this number has no effect)
            [1] = 2.8,
            [2] = 1.7,
            [3] = 1.2,
            [4] = 0.9,
            [5] = 0.75,
            [6] = 0.7
        }
    end

    --- Override this base class function.
    function ENT:GetInputGroups( seatIndex )
        return seatIndex > 1 and { "general_controls" } or { "general_controls", "land_controls" }
    end

    -- Save these network variables when using the duplicator
    ENT.DuplicatorNetworkVariables = {
        HeadlightColor = true,
        TireSmokeColor = true,
        WheelRadius = true,

        MaxSteerAngle = true,
        SteerConeChangeRate = true,
        SteerConeMaxSpeed = true,
        SteerConeMaxAngle = true,
        CounterSteer = true,

        BrakePower = true,
        SuspensionLength = true,
        SpringStrength = true,
        SpringDamper = true,

        ForwardTractionMax = true,
        ForwardTractionBias = true,

        SideTractionMultiplier = true,
        SideTractionMaxAng = true,
        SideTractionMin = true,
        SideTractionMax = true,

        MinRPM = true,
        MaxRPM = true,
        MinRPMTorque = true,
        MaxRPMTorque = true,
        DifferentialRatio = true,
        TransmissionEfficiency = true,
        PowerDistribution = true,

        TurboCharged = true,
        FastTransmission = true
    }
end
