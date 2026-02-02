AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Dukes"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/dukes/chassis.mdl"

if CLIENT then
    ENT.CameraOffset = Vector( -270, 0, 50 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -128, 22, -7 ), angle = Angle( 0, -10, 0 ) },
        { pos = Vector( -128, -22, -7 ), angle = Angle( 0, 10, 0 ) }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 108, 0, -2 ), angle = Angle(), width = 40 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 75, 0, 5 ), angle = Angle() }
    }

    ENT.Headlights = {
        { offset = Vector( 102, 25, 2 ) },
        { offset = Vector( 102, -25, 2 ) }
    }

    ENT.LightSprites = {
        { type = "taillight", offset = Vector( -125, 13, 5 ), dir = Vector( -1, 0, 0 ) },
        { type = "taillight", offset = Vector( -125, -13, 5 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -125, 21, 5 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -125, -21, 5 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -125, 27, 5 ), dir = Vector( -1, 0, 0 ), signal = "left" },
        { type = "brake", offset = Vector( -125, -27, 5 ), dir = Vector( -1, 0, 0 ), signal = "right" },

        { type = "headlight", offset = Vector( 106, 29, -1 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 106, 22, -1 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 106, -29, -1 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 106, -22, -1 ), dir = Vector( 1, 0, 0 ) },
    }

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "dukes" )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 19, subModelId = 1 }, -- Headlights
        { type = "headlight", bodyGroupId = 20, subModelId = 1 }, -- Taillights
        { type = "reverse", bodyGroupId = 21, subModelId = 1 },

        { type = "brake", bodyGroupId = 22, subModelId = 1, signal = "left" }, -- Left signal/brake
        { type = "brake", bodyGroupId = 23, subModelId = 1, signal = "right" } -- Right signal/brake
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( -26, 18, -13 ), Angle( 0, 270, -5 ), Vector( 40, 80, 0 ), true )
        self:CreateSeat( Vector( -8, -18, -18 ), Angle( 0, 270, 5 ), Vector( -40, -80, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 66.5, 37, -5 ), {
            model = "models/gta5/vehicles/dukes/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            steerMultiplier = 1
        } )

        -- Front right
        self:CreateWheel( Vector( 66.5, -37, -5 ), {
            model = "models/gta5/vehicles/dukes/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            steerMultiplier = 1
        } )

        -- Rear left
        self:CreateWheel( Vector( -67, 37, -5 ), {
            model = "models/gta5/vehicles/dukes/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            modelScale = Vector( 0.35, 1, 1 )
        } )

        -- Rear right
        self:CreateWheel( Vector( -67, -37, -5 ), {
            model = "models/gta5/vehicles/dukes/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.35, 1, 1 )
        } )

        self:ChangeWheelRadius( 15 )
    end
end
