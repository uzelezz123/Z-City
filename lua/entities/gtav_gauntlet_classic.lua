AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Gauntlet Classic"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/gauntlet_classic/chassis.mdl"

if CLIENT then
    ENT.CameraOffset = Vector( -240, 0, 60 )

    Glide.AddSoundSet( "Glide.GautletClassic.ExhaustPop", 75, 95, 105, {
        "glide/streams/gauntlet_classic/exhaust_pop_1.wav",
        "glide/streams/gauntlet_classic/exhaust_pop_2.wav",
        "glide/streams/gauntlet_classic/exhaust_pop_3.wav"
    } )

    ENT.StartedSound = "glide/streams/gauntlet_classic/start.wav"
    ENT.ExhaustPopSound = "Glide.GautletClassic.ExhaustPop"
    ENT.HornSound = "glide/horns/car_horn_med_9.wav"

    ENT.ExhaustOffsets = {
        { pos = Vector( -98, 13, 3 ) },
        { pos = Vector( -98, 19, 3 ) },
        { pos = Vector( -98, -13, 3 ) },
        { pos = Vector( -98, -19, 3 ) }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 108, 0, 12 ), angle = Angle(), width = 50 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 75, 0, 20 ), angle = Angle() }
    }

    ENT.Headlights = {
        { offset = Vector( 102, 25, 14 ) },
        { offset = Vector( 102, -25, 14 ) }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 104, 33, 13.5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 104, 25.5, 13.5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 104, -33, 13.5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 104, -25.5, 13.5 ), dir = Vector( 1, 0, 0 ) },

        { type = "taillight", offset = Vector( -100, 19, 18 ), dir = Vector( -1, 0, 0 ) },
        { type = "taillight", offset = Vector( -100, -19, 18 ), dir = Vector( -1, 0, 0 ) },

        { type = "brake", offset = Vector( -100, 34.2, 18 ), dir = Vector( -1, 0, 0 ), signal = "left" },
        { type = "brake", offset = Vector( -100, -34.2, 18 ), dir = Vector( -1, 0, 0 ), signal = "right" },

        { type = "reverse", offset = Vector( -99, 27, 6 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -99, -27, 6 ), dir = Vector( -1, 0, 0 ) },

        { type = "brake", offset = Vector( -100, 24.5, 18 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "brake", offset = Vector( -100, 29.4, 18 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "brake", offset = Vector( -100, -24.5, 18 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "brake", offset = Vector( -100, -29.4, 18 ), dir = Vector( -1, 0, 0 ), size = 15 },
    }

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "gauntlet_classic" )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 30 )
    ENT.AngularDrag = Vector( -0.5, -0.5, -5 ) -- Roll, pitch, yaw
    ENT.BurnoutForce = 28

    function ENT:GetGears()
        return {
            [-1] = 2.9, -- Reverse
            [0] = 0, -- Neutral (this number has no effect)
            [1] = 2.8,
            [2] = 1.7,
            [3] = 1.25,
            [4] = 0.95,
            [5] = 0.8
        }
    end

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 10, 0, -8 ) )
    end

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 17, subModelId = 1 }, -- Headlights
        { type = "headlight", bodyGroupId = 16, subModelId = 1 }, -- Tail lights
        { type = "reverse", bodyGroupId = 18, subModelId = 1 },

        { type = "brake", bodyGroupId = 20, subModelId = 1, signal = "left" },
        { type = "brake", bodyGroupId = 21, subModelId = 1, signal = "right" },
        { type = "brake", bodyGroupId = 19, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        self:SetDifferentialRatio( 0.78 )

        self:SetMaxRPM( 12000 )
        self:SetMinRPMTorque( 3300 )
        self:SetMaxRPMTorque( 4000 )

        self:SetForwardTractionMax( 2800 )
        self:SetSideTractionMaxAng( 30 )
        self:SetSideTractionMax( 3000 )
        self:SetSideTractionMin( 1100 )

        self:CreateSeat( Vector( -22, 18, -3 ), Angle( 0, 270, -10 ), Vector( 20, 80, 0 ), true )
        self:CreateSeat( Vector( -8, -18, -3 ), Angle( 0, 270, 5 ), Vector( 20, -80, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 69, 36, 5 ), {
            model = "models/gta5/vehicles/gauntlet_classic/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            steerMultiplier = 1
        } )

        -- Front right
        self:CreateWheel( Vector( 69, -36, 5 ), {
            model = "models/gta5/vehicles/gauntlet_classic/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            steerMultiplier = 1
        } )

        -- Rear left
        self:CreateWheel( Vector( -58, 36, 5 ), {
            model = "models/gta5/vehicles/gauntlet_classic/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 )
        } )

        -- Rear right
        self:CreateWheel( Vector( -58, -36, 5 ), {
            model = "models/gta5/vehicles/gauntlet_classic/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 )
        } )

        self:ChangeWheelRadius( 15 )
    end
end
