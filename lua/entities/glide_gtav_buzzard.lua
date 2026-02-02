AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Buzzard"

ENT.MainRotorOffset = Vector( 0, 0, 92 )
ENT.TailRotorOffset = Vector( -232, 5, 65 )

ENT.CanSwitchHeadlights = true

if CLIENT then
    ENT.CameraOffset = Vector( -550, 0, 150 )

    ENT.ExhaustPositions = {
        Vector( -100, 0, 25 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 0, 0, 75 ), angle = Angle( 330, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( -245, 0, 124 ), blinkTime = 0 },
        { offset = Vector( 86, 0, 7.5 ), blinkTime = 0.5 }
    }

    ENT.StrobeLightColors = {
        Color( 255, 255, 255 ),
        Color( 255, 255, 255 )
    }

    ENT.Headlights = {
        { offset = Vector( 83, 0, 29 ), texture = "glide/effects/headlight_circle" }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 82, 0, 29 ), dir = Vector( 1, 0, 0 ) }
    }

    ENT.StartSound = "glide/helicopters/start_2.wav"
    ENT.DistantSoundPath = "glide/helicopters/distant_loop_1.wav"
    ENT.TailSoundPath = "glide/helicopters/tail_rotor_2.wav"

    ENT.JetSoundPath = "glide/helicopters/jet_1.wav"
    ENT.JetSoundLevel = 65
    ENT.JetSoundVolume = 0.15

    ENT.BassSoundSet = "Glide.MilitaryRotor.Bass"
    ENT.MidSoundSet = "Glide.MilitaryRotor.Mid"
    ENT.HighSoundSet = "Glide.MilitaryRotor.High"

    ENT.BassSoundVol = 1.0
    ENT.MidSoundVol = 0.7
    ENT.HighSoundVol = 0.4

    function ENT:AllowFirstPersonMuffledSound( seatIndex )
        return seatIndex < 3
    end
end

if SERVER then
    ENT.ChassisMass = 500
    ENT.ChassisModel = "models/gta5/vehicles/buzzard/buzzard_body.mdl"

    ENT.MainRotorRadius = 183
    ENT.TailRotorRadius = 37

    ENT.MainRotorModel = "models/gta5/vehicles/buzzard/buzzard_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/buzzard/buzzard_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/buzzard/buzzard_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/buzzard/buzzard_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/buzzard_gib1.mdl",
        "models/gta5/vehicles/gibs/buzzard_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -12, -15, -15 )

    ENT.HelicopterParams = {
        pushUpForce = 300,
        pitchForce = 800,
        yawForce = 1200,
        rollForce = 800,
        uprightForce = 900
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 38, 18, 4 ), nil, Vector( 50, 100, 0 ), true )
        self:CreateSeat( Vector( 38, -18, 4 ), nil, Vector( 50, -100, 0 ), true )
        self:CreateSeat( Vector( 0, 15, -8 ), Angle( 0, 0, 0 ), Vector( 0, 100, 0 ), true )
        self:CreateSeat( Vector( 0, -15, -8 ), Angle( 0, 180, 0 ), Vector( 0, -100, 0 ), true )
    end
end
