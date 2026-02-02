ENT.Type = "anim"
ENT.Base = "base_glide_aircraft"

ENT.PrintName = "Glide Plane"
ENT.Author = "StyledStrike"
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

-- Change vehicle type
ENT.VehicleType = Glide.VEHICLE_TYPE.PLANE

-- Setup the plane propeller position
ENT.PropOffset = Vector()

DEFINE_BASECLASS( "base_glide_aircraft" )

--- Override this base class function.
function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Float", "Throttle" )
    self:NetworkVar( "Float", "ExtraPitch" )

    self:NetworkVar( "Float", "Elevator" )
    self:NetworkVar( "Float", "Rudder" )
    self:NetworkVar( "Float", "Aileron" )

    self:NetworkVar( "Bool", "IsStalling" )
end

if CLIENT then
    ENT.MaxSoundDistance = 15000

    -- Play this sound at startup
    ENT.StartSound = "glide/aircraft/start_3.wav"

    -- Play this sound from far away
    ENT.DistantSoundPath = "glide/aircraft/distant_stunt.wav"
    ENT.DistantSoundLevel = 120

    -- Play this sound at the propeller
    ENT.PropSoundPath = "glide/aircraft/prop_stunt.wav"
    ENT.PropSoundLevel = 80
    ENT.PropSoundVolume = 0.7
    ENT.PropSoundMinPitch = 62
    ENT.PropSoundMaxPitch = 105

    -- Play these sounds at the engine
    ENT.EngineSoundPath = "glide/aircraft/engine_velum.wav"
    ENT.EngineSoundLevel = 80
    ENT.EngineSoundVolume = 0.6
    ENT.EngineSoundMinPitch = 165
    ENT.EngineSoundMaxPitch = 190

    ENT.ExhaustSoundPath = "glide/aircraft/exhaust_stunt.wav"
    ENT.ExhaustSoundLevel = 80
    ENT.ExhaustSoundVolume = 0.7
    ENT.ExhaustSoundMinPitch = 100
    ENT.ExhaustSoundMaxPitch = 115

    ENT.ThrustSound = ""
    ENT.ThrustSoundLevel = 90
    ENT.ThrustSoundLowVolume = 0.4
    ENT.ThrustSoundHighVolume = 0.7
    ENT.ThrustSoundMinPitch = 80
    ENT.ThrustSoundMaxPitch = 90

    -- Play this sound as the engine health gets depleted
    ENT.EngineRattleSound = "glide/aircraft/rattle.wav"

    -- Play this sound (to passengers only) when the wings are stalling
    ENT.StallHornSound = "glide/ui/stall_beep.wav"
    ENT.StallHornVolume = 1.0

    -- Children classes should override this function
    -- to update animations (the control surfaces for example).
    function ENT:OnUpdateAnimations() end
end

if SERVER then
    ENT.AngularDrag = Vector( -2, -2, -10 ) -- Roll, pitch, yaw
    ENT.DamagedEngineSound = "Glide.Damaged.AircraftEngineBreakdown"
    ENT.DamagedEngineVolume = 1.0

    -- How far can the propeller's blades hit things
    ENT.PropRadius = 50

    -- Slow and fast models for the propeller.
    -- Leave empty to not create the default propeller.
    ENT.PropModel = ""
    ENT.PropFastModel = ""  -- Can be "" to use the slow model

    -- Ground steering variables
    ENT.MaxSteerAngle = 40
    ENT.SteerConeMaxSpeed = 800
    ENT.ReverseTorque = 1000
    ENT.MaxReverseSpeed = -300

    -- Plane drag & force constants
    ENT.PlaneParams = {
        -- These drag forces only apply
        -- when flying at max. liftSpeed.
        liftAngularDrag = Vector( -5, -10, -3 ), -- (Roll, pitch, yaw)
        liftForwardDrag = 0.1,
        liftSideDrag = 3,

        liftFactor = 0.15,       -- How much of the up velocity to negate
        maxSpeed = 1800,        -- Speed limit
        liftSpeed = 1600,       -- Speed required to float
        controlSpeed = 1200,    -- Speed required to have complete control of the plane

        engineForce = 200,
        alignForce = 300,

        pitchForce = 1000,
        yawForce = 500,
        rollForce = 1200
    }
end
