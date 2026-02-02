AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Speedo"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/speedo/chassis.mdl"

if CLIENT then
    ENT.CameraOffset = Vector( -300, 0, 70 )

    ENT.HornSound = "glide/horns/car_horn_med_1.wav"

    ENT.ExhaustOffsets = {
        { pos = Vector( -110, 40, -19 ) }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 100, 0, -2 ), width = 42 }
    }

    ENT.EngineSmokeMaxZVel = 250

    ENT.EngineFireOffsets = {
        { offset = Vector( 90, 0, 15 ) }
    }

    ENT.Headlights = {
        { offset = Vector( 105, 32, 6.2 ) },
        { offset = Vector( 105, -32, 6.2 ) },
    }

    ENT.LightSprites = {
        { type = "brake", offset = Vector( -118, 37, 20 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -118, -37, 20 ), dir = Vector( -1, 0, 0 ) },
        { type = "taillight", offset = Vector( -118, 38, 20 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "taillight", offset = Vector( -118, -38, 20 ), dir = Vector( -1, 0, 0 ), size = 15 },

        { type = "reverse", offset = Vector( -118, 38, 15 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -118, -38, 15 ), dir = Vector( -1, 0, 0 ) },

        { type = "headlight", offset = Vector( 105, 32, 6.2 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 105, -32, 6.2 ), dir = Vector( 1, 0, 0 ) },

        { type = "signal_left", offset = Vector( -116, 37.3, 26.8 ), dir = Vector( -0.7, 0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -116, -37.3, 26.8 ), dir = Vector( -0.7, -0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },

        { type = "signal_left", offset = Vector( 104, 38.5, 0 ), dir = Vector( 0.7, 0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( 104, -38.5, 0 ), dir = Vector( 0.7, -0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR }
    }

    ENT.ExhaustPopSound = ""

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 60, 0, 0 )
        stream:LoadPreset( "speedo" )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )
    ENT.ChassisMass = 900
    ENT.BurnoutForce = 13

    ENT.AirControlForce = Vector( 0.4, 0.2, 0.1 ) -- Roll, pitch, yaw
    ENT.AirMaxAngularVelocity = Vector( 200, 200, 150 ) -- Roll, pitch, yaw

    ENT.LightBodygroups = {
        { type = "reverse", bodyGroupId = 10, subModelId = 1 },
        { type = "headlight", bodyGroupId = 9, subModelId = 1 },
        { type = "brake_or_taillight", bodyGroupId = 11, subModelId = 1 },
        { type = "signal_left", bodyGroupId = 12, subModelId = 1 },
        { type = "signal_right", bodyGroupId = 13, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        self.engineBrakeTorque = 600

        self:SetSteerConeMaxSpeed( 1000 )
        self:SetForwardTractionBias( -0.15 )
        self:SetForwardTractionMax( 2100 )

        self:SetDifferentialRatio( 0.6 )
        self:SetTransmissionEfficiency( 0.75 )
        self:SetPowerDistribution( 0.8 )
        self:SetBrakePower( 2400 )
        self.engineBrakeTorque = 3000

        self:SetMinRPM( 800 )
        self:SetMaxRPM( 4800 )
        self:SetMinRPMTorque( 3000 )
        self:SetMaxRPMTorque( 3500 )

        self:CreateSeat( Vector( 5, 22, 0 ), Angle( 0, 270, -10 ), Vector( 50, 80, 10 ), true )
        self:CreateSeat( Vector( 25, -22, 0 ), Angle( 0, 270, 5 ), Vector( 50, -80, 10 ), true )

        self:CreateSeat( Vector( -80, -29, 0 ), Angle( 0, 0, 3 ), Vector( -140, -70, 10 ), true )
        self:CreateSeat( Vector( -80, 29, 0 ), Angle( 0, 180, 4 ), Vector( -140, 70, 10 ), true )

        -- Front left
        self:CreateWheel( Vector( 74, 38, -10 ), {
            model = "models/gta5/vehicles/speedo/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            steerMultiplier = 1
        } )

        -- Front right
        self:CreateWheel( Vector( 74, -38, -10 ), {
            model = "models/gta5/vehicles/speedo/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            steerMultiplier = 1
        } )

        -- Rear left
        self:CreateWheel( Vector( -74, 39, -10 ), {
            model = "models/gta5/vehicles/speedo/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 )
        } )

        -- Rear right
        self:CreateWheel( Vector( -74, -39, -10 ), {
            model = "models/gta5/vehicles/speedo/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 )
        } )

        self:ChangeWheelRadius( 18 )
    end
end
