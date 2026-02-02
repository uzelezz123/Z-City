AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Police Cruiser"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/police/chassis.mdl"
ENT.CanSwitchSiren = true

function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[1] = localEyePos[1] + 5
    localEyePos[3] = localEyePos[3] + 10
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -270, 0, 58 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -114, 24, -14 ) }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 115, 0, 2 ), angle = Angle(), width = 27 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 80, 0, 15 ), angle = Angle() }
    }

    ENT.Headlights = {
        { offset = Vector( 110, 28, 8 ) },
        { offset = Vector( 110, -28, 8 ) }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 113, 30, 4 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 113, -30, 4 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 113, 22.5, 4 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 113, -22.5, 4 ), dir = Vector( 1, 0, 0 ) },

        { type = "brake", offset = Vector( -112, 31, 12 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -112, -31, 12 ), dir = Vector( -1, 0, 0 ) },

        { type = "taillight", offset = Vector( -112, 30, 10 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "taillight", offset = Vector( -112, -30, 10 ), dir = Vector( -1, 0, 0 ), size = 15 },

        { type = "reverse", offset = Vector( -114, 29, 5.8 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -114, -29, 5.8 ), dir = Vector( -1, 0, 0 ) },

        -- Rear turn signals
        { type = "signal_left", offset = Vector( -113, 30, 8 ), dir = Vector( -0.7, 0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -113, -30, 8 ), dir = Vector( -0.7, -0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },

        -- Front turn signals
        { type = "signal_left", offset = Vector( 108, 38, 3.5 ), dir = Vector( 0.7, 0.5, 0 ), color = color_white },
        { type = "signal_right", offset = Vector( 108, -38, 3.5 ), dir = Vector( 0.7, -0.5, 0 ), color = color_white }
    }

    ENT.SirenLights = {
        -- Top-right (blue) lights
        { offset = Vector( -6, -21, 41 ), time = 0, color = Glide.DEFAULT_SIREN_COLOR_B },
        { offset = Vector( -6, -21, 41 ), time = 0.25, color = Glide.DEFAULT_SIREN_COLOR_B },
        { offset = Vector( -6, -11, 41 ), time = 0, color = Glide.DEFAULT_SIREN_COLOR_B },
        { offset = Vector( -6, -11, 41 ), time = 0.25, color = Glide.DEFAULT_SIREN_COLOR_B },

        -- Top-left (red) lights
        { offset = Vector( -6, 21, 41 ), time = 0.5, color = Glide.DEFAULT_SIREN_COLOR_A },
        { offset = Vector( -6, 21, 41 ), time = 0.75, color = Glide.DEFAULT_SIREN_COLOR_A },
        { offset = Vector( -6, 11, 41 ), time = 0.5, color = Glide.DEFAULT_SIREN_COLOR_A },
        { offset = Vector( -6, 11, 41 ), time = 0.75, color = Glide.DEFAULT_SIREN_COLOR_A },

        -- Top bodygroups
        { bodygroup = 30, time = 0, duration = 0.5 },
        { bodygroup = 31, time = 0.5, duration = 0.5 },
        { bodygroup = 32, time = 0, duration = 0.5 },
        { bodygroup = 27, time = 0.5, duration = 0.5 },
        { bodygroup = 28, time = 0, duration = 0.5 },
        { bodygroup = 29, time = 0.5, duration = 0.5 },

        -- Front bodygroups
        { bodygroup = 26, time = 0, duration = 0.5 },
        { bodygroup = 25, time = 0.5, duration = 0.5 },

        -- Front-right sprites
        { offset = Vector( 114, -10, 5 ), dir = Vector( 1, 0, 0 ), time = 0, color = Glide.DEFAULT_SIREN_COLOR_B, lightRadius = 0 },
        { offset = Vector( 114, -10, 5 ), dir = Vector( 1, 0, 0 ), time = 0.25, color = Glide.DEFAULT_SIREN_COLOR_B, lightRadius = 0 },

        -- Front-left sprites
        { offset = Vector( 114, 10, 5 ), dir = Vector( 1, 0, 0 ), time = 0.5, color = Glide.DEFAULT_SIREN_COLOR_A, lightRadius = 0 },
        { offset = Vector( 114, 10, 5 ), dir = Vector( 1, 0, 0 ), time = 0.75, color = Glide.DEFAULT_SIREN_COLOR_A, lightRadius = 0 }
    }

    ENT.ExhaustPopSound = ""

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "police_cruiser" )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 17, subModelId = 1 }, -- Headlights
        { type = "headlight", bodyGroupId = 23, subModelId = 1 }, -- Tail light left
        { type = "headlight", bodyGroupId = 24, subModelId = 1 }, -- Tail light right

        { type = "brake", bodyGroupId = 15, subModelId = 1 }, -- Brake left
        { type = "brake", bodyGroupId = 16, subModelId = 1 }, -- Brake right
        { type = "reverse", bodyGroupId = 22, subModelId = 1 },

        { type = "signal_left", bodyGroupId = 18, subModelId = 1 }, -- Front
        { type = "signal_right", bodyGroupId = 19, subModelId = 1 }, -- Front
        { type = "signal_left", bodyGroupId = 20, subModelId = 1 }, -- Rear
        { type = "signal_right", bodyGroupId = 21, subModelId = 1 }, -- Rear
    }

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255, 255 )
    end

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 5, 0, -15 ) )
    end

    function ENT:CreateFeatures()
        self:SetCounterSteer( 0.4 )
        self:SetDifferentialRatio( 0.6 )
        self:SetPowerDistribution( -0.7 )
        self:SetTransmissionEfficiency( 0.75 )

        self:SetMaxRPMTorque( 4400 )
        self:SetBrakePower( 2500 )

        self:CreateSeat( Vector( -7, 20, -13 ), Angle( 0, 270, -5 ), Vector( 40, 80, 0 ), true )
        self:CreateSeat( Vector( 12, -20, -12 ), Angle( 0, 270, 15 ), Vector( -40, -80, 0 ), true )
        self:CreateSeat( Vector( -32, 20, -12 ), Angle( 0, 270, 15 ), Vector( -40, -80, 0 ), true )
        self:CreateSeat( Vector( -32, -20, -12 ), Angle( 0, 270, 15 ), Vector( -40, -80, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 75, 38, -5 ), {
            model = "models/gta5/vehicles/police/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            steerMultiplier = 1
        } )

        -- Front right
        self:CreateWheel( Vector( 75, -38, -5 ), {
            model = "models/gta5/vehicles/police/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            steerMultiplier = 1
        } )

        -- Rear left
        self:CreateWheel( Vector( -60, 38, -5 ), {
            model = "models/gta5/vehicles/police/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            modelScale = Vector( 0.35, 1, 1 )
        } )

        -- Rear right
        self:CreateWheel( Vector( -60, -38, -5 ), {
            model = "models/gta5/vehicles/police/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.35, 1, 1 )
        } )

        self:ChangeWheelRadius( 16 )
    end
end
