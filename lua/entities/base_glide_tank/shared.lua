ENT.Type = "anim"
ENT.Base = "base_glide_car"

ENT.PrintName = "Glide Tank"
ENT.Author = "StyledStrike"
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

-- Change vehicle type
ENT.VehicleType = Glide.VEHICLE_TYPE.TANK

-- Tweak max. chassis health
ENT.MaxChassisHealth = 6000

-- Prevent players from editing these NW variables
ENT.UneditableNWVars = {
    WheelRadius = true,
    BrakePower = true,
    SuspensionLength = true,
    SpringStrength = true,
    SpringDamper = true,

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
    ForwardTractionMax = true,
    ForwardTractionBias = true
}

--[[
    Turrets are predictable, so these properties
    should be the same on both SERVER and CLIENT.
]]

-- Position of the turret's origin relative to the vehicle.
ENT.TurretOffset = Vector( 0, 0, 50 )

-- Turret pitch angle limits
ENT.PitchAngMax = -25   -- Pitch up limit (yes, it's negative)
ENT.PitchAngMin = 10    -- Pitch down limit (yes, it's positive)

ENT.MaxYawSpeed = 50        -- Max. turret yaw rotation speed
ENT.YawAcceleration = 1500  -- Turret yaw acceleration

DEFINE_BASECLASS( "base_glide_car" )

--- Override this base class function.
function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Float", "TrackSpeed" )
    self:NetworkVar( "Angle", "TurretAngle" )
    self:NetworkVar( "Bool", "IsAimingAtTarget" )
end

--- Override this base class function.
function ENT:GetFirstPersonOffset()
    return Vector( 0, 0, 90 )
end

--- Override this base class function.
function ENT:GetPlayerSitSequence( _seatIndex )
    return "sit"
end

-- Children classes should override this function
-- to update the turret/cannon bones.
--
-- This exists both on the client and server side,
-- to allow returning the correct bone position
-- when creating the projectile serverside.
function ENT:ManipulateTurretBones( _turretAngle ) end

if CLIENT then
    ENT.WheelSkidmarkScale = 1

    --- Override this base class function.
    function ENT:GetCameraType( _seatIndex )
        return 1 -- Glide.CAMERA_TYPE.TURRET
    end

    -- Track sound parameters
    ENT.TrackSound = ")glide/tanks/tracks_leopard.wav"
    ENT.TrackVolume = 0.7

    -- Turret sounds
    ENT.TurrentMoveSound = "glide/tanks/turret_move.wav"
    ENT.TurrentMoveVolume = 1.0

    -- Change a few engine sounds from the car class
    ENT.StartSound = "Glide.Engine.TruckStart"
    ENT.StartedSound = "glide/engines/start_tail_truck.wav"
end

if SERVER then
    ENT.IsHeavyVehicle = true
    ENT.ChassisMass = 20000

    ENT.BlastDamageMultiplier = 3
    ENT.BlastForceMultiplier = 0.005
    ENT.CollisionDamageMultiplier = 3
    ENT.BulletDamageMultiplier = 0.25

    ENT.UnflipForce = 0.2
    ENT.AirControlForce = Vector( 0.08, 0.03, 0.02 ) -- Roll, pitch, yaw

    ENT.SuspensionHeavySound = "Glide.Suspension.CompressTruck"
    ENT.SuspensionDownSound = "Glide.Suspension.Stress"

    -- Can this tank "turn in place"?
    ENT.CanTurnInPlace = true

    -- How much extra torque to apply when trying to spin in place?
    ENT.TurnInPlaceTorqueMultiplier = 3

    -- Turret parameters
    ENT.TurretFireSound = ")glide/tanks/acf_fire4.mp3"
    ENT.TurretFireVolume = 0.8
    ENT.TurretRecoilForce = 50
    ENT.TurretDamage = 550

    -- Override this base class function.
    function ENT:GetGears()
        return {
            [-1] = 3, -- Reverse
            [0] = 0, -- Neutral (this number has no effect)
            [1] = 3
        }
    end

    -- Children classes should override this function
    -- to set where the cannon projectile is spawned.
    function ENT:GetProjectileStartPos()
        return self:GetPos()
    end
end

local Clamp = math.Clamp
local ExpDecayAngle = Glide.ExpDecayAngle
local AngleDifference = Glide.AngleDifference

function ENT:UpdateTurret( driver, dt, currentAng )
    local aimPos = SERVER and driver:GlideGetAimPos() or Glide.GetCameraAimPos()
    local origin = self:LocalToWorld( self.TurretOffset )
    local targetDir = aimPos - origin
    targetDir:Normalize()

    local targetAng = self:WorldToLocalAngles( targetDir:Angle() )
    local isAimingAtTarget = true

    if targetAng[1] > self.PitchAngMin then
        targetAng[1] = self.PitchAngMin
        isAimingAtTarget = false

    elseif targetAng[1] < self.PitchAngMax then
        targetAng[1] = self.PitchAngMax
        isAimingAtTarget = false
    end

    currentAng[1] = ExpDecayAngle( currentAng[1], targetAng[1], 10, dt )
    currentAng[2] = currentAng[2] + Clamp( AngleDifference( currentAng[2], targetAng[2] ) * self.YawAcceleration * dt, -self.MaxYawSpeed, self.MaxYawSpeed ) * dt

    isAimingAtTarget = isAimingAtTarget and targetDir:Dot( self:LocalToWorldAngles( currentAng ):Forward() ) > 0.99

    return currentAng, isAimingAtTarget
end
