AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Hauler"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/hauler/chassis.mdl"
ENT.MaxChassisHealth = 2000

if CLIENT then
    ENT.CameraOffset = Vector( -500, 0, 140 )
    ENT.CameraTrailerDistanceMultiplier = 0.65

    ENT.StartSound = "Glide.Engine.TruckStart"
    ENT.ExhaustPopSound = ""
    ENT.StartedSound = "glide/engines/start_tail_truck.wav"
    ENT.StoppedSound = "glide/engines/shut_down_truck_1.wav"
    ENT.HornSound = "glide/horns/large_truck_horn_2.wav"

    ENT.ReverseSound = "glide/alarms/reverse_warning.wav"
    ENT.BrakeLoopSound = "glide/wheels/rig_brake_disc_1.wav"
    ENT.BrakeReleaseSound = "glide/wheels/rig_brake_release.wav"
    ENT.BrakeSqueakSound = "Glide.Brakes.Squeak"

    ENT.ExhaustAlpha = 120
    ENT.ExhaustOffsets = {
        { pos = Vector( 45, 47, 128 ), scale = 2 },
        { pos = Vector( 45, -47, 128 ), scale = 2 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 144, 0, -8 ), width = 55 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 144, 0, 8 ), angle = Angle( 90, 0, 0 ) }
    }

    ENT.Headlights = {
        { offset = Vector( 142, 40, -3 ) },
        { offset = Vector( 142, -40, -3 ) }
    }

    ENT.LightSprites = {
        { type = "taillight", offset = Vector( -152, 33, -9.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "taillight", offset = Vector( -152, -33, -9.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -152, 41, -9.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -152, -41, -9.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -152, 12, -9.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -152, -12, -9.5 ), dir = Vector( -1, 0, 0 ) },

        { type = "headlight", offset = Vector( 142, 41, -5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 142, 51, -5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 142, -41, -5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 142, -51, -5 ), dir = Vector( 1, 0, 0 ) },

        { type = "signal_left", offset = Vector( -152, 50, -9.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -152, -50, -9.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
    }

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 50, 0, 0 )
        stream:LoadPreset( "hauler" )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )
    ENT.ChassisMass = 4000
    ENT.IsHeavyVehicle = true

    ENT.SuspensionHeavySound = "Glide.Suspension.CompressTruck"
    ENT.SuspensionDownSound = "Glide.Suspension.Stress"

    ENT.BurnoutForce = 12
    ENT.UnflipForce = 4

    ENT.AirControlForce = Vector( 0.1, 0.05, 0.1 ) -- Roll, pitch, yaw
    ENT.AirMaxAngularVelocity = Vector( 100, 100, 150 ) -- Roll, pitch, yaw

    ENT.LightBodygroups = {
        { type = "brake", bodyGroupId = 13, subModelId = 1 },
        { type = "reverse", bodyGroupId = 14, subModelId = 1 },
        { type = "headlight", bodyGroupId = 15, subModelId = 1 }, -- Tail lights
        { type = "headlight", bodyGroupId = 10, subModelId = 1 },  -- Headlights
        { type = "signal_left", bodyGroupId = 12, subModelId = 1 },
        { type = "signal_right", bodyGroupId = 11, subModelId = 1 }
    }

    ENT.Sockets = {
        { offset = Vector( -60, 0, 0 ), id = "TruckSocket", isReceptacle = true }
    }

    function ENT:GetGears()
        return {
            [-1] = 10, -- Reverse
            [0] = 0, -- Neutral (this number has no effect)
            [1] = 12,
            [2] = 7.5,
            [3] = 5.2,
            [4] = 4,
            [5] = 3.3,
            [6] = 2.9,
            [7] = 2.7
        }
    end

    function ENT:CreateFeatures()
        self.engineBrakeTorque = 4000

        self:SetSuspensionLength( 14 )
        self:SetSpringStrength( 1500 )
        self:SetSpringDamper( 6000 )

        self:SetSideTractionMultiplier( 90 )
        self:SetForwardTractionMax( 6000 )
        self:SetSideTractionMax( 4000 )
        self:SetSideTractionMin( 5500 )

        self:SetDifferentialRatio( 0.3 )
        self:SetPowerDistribution( -0.7 )

        self:SetMinRPM( 600 )
        self:SetMaxRPM( 4500 )
        self:SetMinRPMTorque( 6000 )
        self:SetMaxRPMTorque( 7000 )

        self:SetBrakePower( 6000 )
        self:SetMaxSteerAngle( 40 )
        self:SetSteerConeMaxSpeed( 800 )
        self:SetSteerConeMaxAngle( 0.4 )
        self:SetCounterSteer( 0.2 )

        self:CreateSeat( Vector( 87, 35, 22 ), Angle( 0, 270, -5 ), Vector( 90, 90, 0 ), true )
        self:CreateSeat( Vector( 100, -35, 22 ), Angle( 0, 270, 0 ), Vector( 90, 90, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 105, 49, -22 ), {
            model = "models/gta5/vehicles/hauler/wheel_front.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            useModelSize = true,
            steerMultiplier = 1
        } )

        -- Rear left 1
        self:CreateWheel( Vector( -48, 46, -22 ), {
            model = "models/gta5/vehicles/hauler/wheel_rear.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            useModelSize = true
        } )

        -- Rear left 2
        self:CreateWheel( Vector( -116, 46, -22 ), {
            model = "models/gta5/vehicles/hauler/wheel_rear.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            useModelSize = true
        } )

        -- Front right
        self:CreateWheel( Vector( 105, -49, -22 ), {
            model = "models/gta5/vehicles/hauler/wheel_front.mdl",
            modelAngle = Angle( 0, 270, 0 ),
            useModelSize = true,
            steerMultiplier = 1
        } )

        -- Rear right 1
        self:CreateWheel( Vector( -48, -46, -22 ), {
            model = "models/gta5/vehicles/hauler/wheel_rear.mdl",
            modelAngle = Angle( 0, 270, 0 ),
            useModelSize = true
        } )

        -- Rear right 2
        self:CreateWheel( Vector( -116, -46, -22 ), {
            model = "models/gta5/vehicles/hauler/wheel_rear.mdl",
            modelAngle = Angle( 0, 270, 0 ),
            useModelSize = true
        } )
    end
end
