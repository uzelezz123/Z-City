--[[
    A real "vehicle" in this game is actually something like the seats,
    a entity the player gets parented to when they "get on" it.
 
    Players aren't parented to Glide vehicles directly, but we still
    have to implement some functions from the `Vehicle` metatable,
    to prevent errors on other addons.

    You really should not use these functions to control Glide vehicles.
]]
local IS_CLIENT = CLIENT ~= nil

function ENT:GetThirdPersonMode()
    return true
end

function ENT:GetCameraDistance()
    return IS_CLIENT and math.abs( self.CameraOffset[1] ) or 0
end

function ENT:SetCameraDistance( _distance )
    -- NOOP
end

function ENT:SetThirdPersonMode( _enable )
    -- NOOP
end

function ENT:GetPassenger( passenger )
    return IS_CLIENT and self:GetDriver() or self:GetSeatDriver( passenger )
end

function ENT:GetVehicleViewPosition( _role )
    return Vector(), Angle(), 0
end

if CLIENT then
    function ENT:GetAmmo()
        return 0, 0, 0
    end
end

if SERVER then
    function ENT:EnableEngine( enable )
        self:SetEngineHealth( enable and 1 or 0 )
    end

    function ENT:IsEngineEnabled()
        return self:GetEngineHealth() > 0
    end

    function ENT:IsEngineStarted()
        return self:IsEngineOn()
    end

    function ENT:IsValidVehicle()
        return true
    end

    function ENT:CheckExitPoint( _yaw, _distance )
        return self:GetSeatExitPos( 0 )
    end

    function ENT:GetHLSpeed()
        return self.forwardSpeed
    end

    function ENT:GetMaxSpeed()
        return 0
    end

    function ENT:GetSpeed()
        return self.forwardSpeed * 0.0568182 -- Convert to MPH
    end

    function ENT:GetSteeringDegrees()
        return 0
    end

    function ENT:GetRPM()
        return 0
    end

    function ENT:GetThrottle()
        return 0
    end

    function ENT:HasBoost()
        return false
    end

    function ENT:IsBoosting()
        return false
    end

    function ENT:HasBrakePedal()
        return true
    end

    function ENT:IsVehicleBodyInWater()
        return self:WaterLevel() > 2
    end

    local opParams = {}

    function ENT:GetOperatingParams()
        opParams.RPM = 0
        opParams.gear = 0
        opParams.isTorqueBoosting = false
        opParams.speed = self.totalSpeed
        opParams.steeringAngle = 0
        opParams.wheelsInContact = 0

        return opParams
    end

    local vehParams = {
        wheelsPerAxle = 0,
        axleCount = 0,
        axles = {},
        body = {},
        engine = {},
        steering = {}
    }

    function ENT:GetVehicleParams()
        return vehParams
    end

    function ENT:GetPassengerSeatPoint( role )
        local seat = self.seats[role]

        if IsValid( seat ) then
            return seat:GetPos(), seat:GetAngles()
        end
    end

    function ENT:StartEngine( start )
        if start then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end

    function ENT:SetThrottle( _throttle )
        -- NOOP
    end

    function ENT:SetHandbrake( _handbrake )
        -- NOOP
    end

    function ENT:SetSteeringDegrees( _maxSteeringDegrees )
        -- NOOP, Sets the maximum steering degrees of the vehicle
    end

    function ENT:SetHasBrakePedal( _brakePedal )
        -- NOOP
    end

    function ENT:SetMaxReverseThrottle( _maxRevThrottle )
        -- NOOP
    end

    function ENT:SetMaxThrottle( _maxThrottle )
        -- NOOP
    end

    function ENT:SetVehicleParams( _params )
        -- NOOP
    end
end
