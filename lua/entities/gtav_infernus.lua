AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Infernus"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/infernus/chassis.mdl"

function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[1] = localEyePos[1] + 15
    localEyePos[3] = localEyePos[3] + 8
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -240, 0, 50 )
    ENT.HornSound = "glide/horns/car_horn_med_9.wav"

    ENT.EngineSmokeMaxZVel = 5
    ENT.ExhaustOffsets = {
        { pos = Vector( -91, 0, 6 ) },
        { pos = Vector( -90.5, 0, 10 ) },
        { pos = Vector( -90, 0, 13 ) },
        { pos = Vector( -90.5, 3, 10 ) },
        { pos = Vector( -90.5, -3, 10 ) },
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -89, 14, 10 ), angle = Angle( 0, 180, 0 ), width = 15 },
        { offset = Vector( -89, -14, 10 ), angle = Angle( 0, 180, 0 ), width = 15 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -46, 0, 20 ), angle = Angle() }
    }

    ENT.Headlights = {
        { offset = Vector( 80, 30, 15 ) },
        { offset = Vector( 80, -30, 15 ) }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 80, 33.9, 6 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 80, 27.5, 5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 80, -33.9, 6 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 80, -27.5, 5 ), dir = Vector( 1, 0, 0 ) },

        { type = "brake", offset = Vector( -88, 30, 13 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -88, -30, 13 ), dir = Vector( -1, 0, 0 ) },
        { type = "taillight", offset = Vector( -88, 30, 10 ), dir = Vector( -1, 0, 0 ), size = 18 },
        { type = "taillight", offset = Vector( -88, -30, 10 ), dir = Vector( -1, 0, 0 ), size = 18 },

        { type = "reverse", offset = Vector( -91, 36, 5 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -91, -36, 5 ), dir = Vector( -1, 0, 0 ) },
        { type = "signal_left", offset = Vector( -90, 36, 7 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -90, -36, 7 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
    }

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "infernus" )
    end
end

if SERVER then
    ENT.ChassisMass = 800
    ENT.SpawnPositionOffset = Vector( 0, 0, 30 )
    ENT.BurnoutForce = 35

    ENT.LightBodygroups = {
        { type = "brake", bodyGroupId = 16, subModelId = 1 },
        { type = "reverse", bodyGroupId = 17, subModelId = 1 },
        { type = "headlight", bodyGroupId = 13, subModelId = 1 }, -- Headlights
        { type = "headlight", bodyGroupId = 18, subModelId = 1 }, -- Tail lights
        { type = "signal_left", bodyGroupId = 14, subModelId = 1 },
        { type = "signal_right", bodyGroupId = 15, subModelId = 1 },
    }

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, -15 ) )
    end

    function ENT:CreateFeatures()
        self:SetHeadlightColor( Vector( 1, 1, 1 ) )
        self:SetSteerConeChangeRate( 10 )
        self:SetCounterSteer( 0.2 )

        self:SetDifferentialRatio( 1.3 )
        self:SetMaxRPM( 15000 )
        self:SetMinRPMTorque( 2500 )
        self:SetMaxRPMTorque( 3000 )

        self:SetForwardTractionMax( 3600 )
        self:SetSideTractionMultiplier( 30 )
        self:SetSideTractionMax( 2800 )

        self:CreateSeat( Vector( -12, 18, -18 ), Angle( 0, 270, 2 ), Vector( 20, 80, 0 ), true )
        self:CreateSeat( Vector( 8, -18, -15 ), Angle( 0, 270, 18 ), Vector( 20, -80, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 60, 35.5, 0 ), {
            model = "models/gta5/vehicles/infernus/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            steerMultiplier = 1
        } )

        -- Front right
        self:CreateWheel( Vector( 60, -35.5, 0 ), {
            model = "models/gta5/vehicles/infernus/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            steerMultiplier = 1
        } )

        -- Rear left
        self:CreateWheel( Vector( -60, 38, 0 ), {
            model = "models/gta5/vehicles/infernus/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            modelScale = Vector( 0.4, 1, 1 )
        } )

        -- Rear right
        self:CreateWheel( Vector( -60, -38, 0 ), {
            model = "models/gta5/vehicles/infernus/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.4, 1, 1 )
        } )

        self:ChangeWheelRadius( 15 )
    end
end
