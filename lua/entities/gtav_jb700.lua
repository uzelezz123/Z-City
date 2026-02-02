AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "JB 700"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/jb700/chassis.mdl"

function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[1] = localEyePos[1] + 15
    localEyePos[3] = localEyePos[3] + 8
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -240, 0, 45 )
    ENT.HornSound = "glide/horns/car_horn_med_3.wav"

    ENT.ExhaustOffsets = {
        { pos = Vector( -106, 16.5, -13 ), angle = Angle( -30, 0, 0 ) },
        { pos = Vector( -106, -16.5, -13 ), angle = Angle( -30, 0, 0 ) }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 85, 0, 0 ), width = 30 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 55, 0, 20 ), angle = Angle() }
    }

    ENT.Headlights = {
        { offset = Vector( 78, 30, 10 ), texture = "glide/effects/headlight_circle2" },
        { offset = Vector( 78, -30, 10 ), texture = "glide/effects/headlight_circle2" }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 75, 30, 7 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 75, -30, 7 ), dir = Vector( 1, 0, 0 ) },
        { type = "taillight", offset = Vector( -106, 28, 7 ), dir = Vector( -1, 0, 0 ), size = 16 },
        { type = "taillight", offset = Vector( -106, -28, 7 ), dir = Vector( -1, 0, 0 ), size = 16 },
        { type = "brake", offset = Vector( -106, 28, 7 ), dir = Vector( -1, 0, 0 ), size = 30 },
        { type = "brake", offset = Vector( -106, -28, 7 ), dir = Vector( -1, 0, 0 ), size = 30 },
        { type = "signal_left", offset = Vector( -106, 28, 11.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -106, -28, 11.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_left", offset = Vector( 84, 33, -1.5 ), dir = Vector( 0.7, 0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( 84, -33, -1.5 ), dir = Vector( 0.7, -0.5, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR }
    }

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "jb700" )
    end
end

if SERVER then
    sound.Add( {
        name = "Glide.JB700.Fire",
        channel = CHAN_STATIC,
        volume = 1.0,
        level = 75,
        pitch = { 95, 105 },
        sound = {
            "glide/weapons/jb700/fire_1.wav",
            "glide/weapons/jb700/fire_2.wav",
        }
    } )

    ENT.ChassisMass = 800
    ENT.SpawnPositionOffset = Vector( 0, 0, 30 )
    ENT.BurnoutForce = 20

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 10, subModelId = 1 }, -- Headlights
        { type = "brake_or_taillight", bodyGroupId = 13, subModelId = 1 }, -- Tail lights
        { type = "signal_left", bodyGroupId = 11, subModelId = 1 },
        { type = "signal_right", bodyGroupId = 12, subModelId = 1 }
    }

    function ENT:GetSpawnColor()
        return Color( 78, 81, 88 )
    end

    function ENT:CreateFeatures()
        self:CreateWeapon( "base", {
            Spread = 0.5,
            Damage = 40,
            TracerScale = 0.5,
            SingleShotSound = "Glide.JB700.Fire",
            FireDelay = 0.25,
            ProjectileOffsets = {
                Vector( 72, 30, 16 ),
                Vector( 72, -30, 16 )
            }
        } )

        self:SetSuspensionLength( 8 )
        self:SetCounterSteer( 0.4 )
        self:SetSpringStrength( 600 )

        self:CreateSeat( Vector( -38, 14, -17 ), Angle( 0, 270, 5 ), Vector( 20, 80, 0 ), true )
        self:CreateSeat( Vector( -18, -14, -12 ), Angle( 0, 270, 25 ), Vector( 20, -80, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 56, 32, -3.5 ), {
            model = "models/gta5/vehicles/jb700/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            modelScale = Vector( 0.35, 1, 1 ),
            steerMultiplier = 1
        } )

        -- Front right
        self:CreateWheel( Vector( 56, -32, -3.5 ), {
            model = "models/gta5/vehicles/jb700/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.35, 1, 1 ),
            steerMultiplier = 1
        } )

        -- Rear left
        self:CreateWheel( Vector( -56, 32, -3.5 ), {
            model = "models/gta5/vehicles/jb700/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            modelScale = Vector( 0.35, 1, 1 )
        } )

        -- Rear right
        self:CreateWheel( Vector( -56, -32, -3.5 ), {
            model = "models/gta5/vehicles/jb700/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.35, 1, 1 )
        } )

        self:ChangeWheelRadius( 15 )
    end
end
