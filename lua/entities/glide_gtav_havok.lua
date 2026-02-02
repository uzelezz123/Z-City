AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Havok"

ENT.MaxChassisHealth = 900
ENT.MainRotorOffset = Vector( 0, 0, 32 )
ENT.TailRotorOffset = Vector( -146.5, 5.5, 1 )

ENT.CanSwitchHeadlights = true

if CLIENT then
    ENT.CameraOffset = Vector( -400, 0, 60 )

    ENT.ExhaustPositions = {
        Vector( -30, 0, -17 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -30, 0, -20 ), angle = Angle( 300, 0, 0 ), scale = 0.5 }
    }

    ENT.Headlights = {
        { offset = Vector( 58, 0, -41 ), fovScale = 1.2 }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 57.8, 6.7, -41 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 57.8, -6.7, -41 ), dir = Vector( 1, 0, 0 ) }
    }

    ENT.DistantSoundPath = "glide/helicopters/distant_loop_1.wav"
    ENT.RotorBeatInterval = 0.09
    ENT.BassSoundVol = 0.7

    ENT.EngineSoundPath = "gtav/havok/prop.wav"
    ENT.EngineSoundLevel = 80
    ENT.EngineSoundVolume = 1

    ENT.JetSoundPath = "gtav/havok/jet.wav"
    ENT.JetSoundLevel = 75
    ENT.JetSoundVolume = 0.5
end

if SERVER then
    ENT.ChassisMass = 500
    ENT.ChassisModel = "models/gta5/vehicles/havok/havok_body.mdl"

    ENT.MainRotorRadius = 125
    ENT.TailRotorRadius = 22

    ENT.MainRotorModel = "models/gta5/vehicles/havok/havok_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/havok/havok_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/havok/havok_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/havok/havok_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/havok_gib1.mdl",
        "models/gta5/vehicles/gibs/havok_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -10, -15, -10 )

    ENT.HelicopterParams = {
        pushUpForce = 350,
        pitchForce = 800,
        yawForce = 900,
        rollForce = 800,
        uprightForce = 900
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 28, 0, -30 ), nil, Vector( 28, 60, -60 ), true )
    end
end
