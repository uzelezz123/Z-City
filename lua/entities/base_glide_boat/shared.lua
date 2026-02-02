ENT.Type = "anim"
ENT.Base = "base_glide"

ENT.PrintName = "Glide Boat"
ENT.Author = "StyledStrike"
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

-- Change vehicle type
ENT.VehicleType = Glide.VEHICLE_TYPE.BOAT
ENT.CanSwitchHeadlights = true

DEFINE_BASECLASS( "base_glide" )

--- Override this base class function.
function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Float", "Steering" )
    self:NetworkVar( "Float", "EngineThrottle" )
    self:NetworkVar( "Float", "EnginePower" )
    self:NetworkVar( "Bool", "IsHonking" )
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

if CLIENT then
    ENT.MaxSoundDistance = 4000
    ENT.MaxMiscDistance = 4000

    -- Sounds
    ENT.StartSound = "Glide.Engine.BikeStart2"
    ENT.StartTailSound = "Glide.Engine.CarStartTail"
    ENT.StartedSound = ""
    ENT.StoppedSound = "glide/engines/shut_down_1.wav"
    ENT.HornSound = "glide/horns/car_horn_med_8.wav"

    --- Override this base class function.
    function ENT:GetCameraType( _seatIndex )
        return 0 -- Glide.CAMERA_TYPE.CAR
    end

    function ENT:AllowFirstPersonMuffledSound( _seatIndex )
        return false
    end

    function ENT:AllowWindSound( _seatIndex )
        return true, 0.8
    end

    -- Strips/lines where smoke particles are spawned when the engine is damaged
    ENT.EngineSmokeStrips = {}
    ENT.EngineSmokeMaxZVel = 40

    -- Children classes can override this function
    -- to update animations (the steering wheel for example).
    function ENT:OnUpdateAnimations()
        self:SetPoseParameter( "vehicle_steer", self:GetSteering() )
        self:InvalidateBoneCache()
    end

    -- Children classes should override this
    -- function to add engine sounds to the stream.
    function ENT:OnCreateEngineStream( _stream ) end
end

if SERVER then
    ENT.ChassisMass = 1000
    ENT.CollisionDamageMultiplier = 0.4
    ENT.SoftCollisionSound = "Glide.Collision.BoatHard"

    -- How long does it take for the vehicle to start up?
    ENT.StartupTime = 0.9

    --- Override this base class function.
    function ENT:GetInputGroups( seatIndex )
        return seatIndex > 1 and { "general_controls" } or { "general_controls", "land_controls" }
    end
end
