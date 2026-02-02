AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_armed_heli"
ENT.PrintName = "Akula"

ENT.MainRotorOffset = Vector( 22, 0, 120 )
ENT.TailRotorOffset = Vector( -320, 0, 30 )

if CLIENT then
    ENT.CameraOffset = Vector( -750, 0, 200 )

    ENT.ExhaustPositions = {
        Vector( -30, 15, 90 ),
        Vector( -30, -15, 90 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 22, 0, 95 ), angle = Angle( 330, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( -365, 0, 118 ), blinkTime = 0 },
        { offset = Vector( 24, 20, -16 ), blinkTime = 0.1 },
        { offset = Vector( 24, -20, -16 ), blinkTime = 0.6 }
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

    ENT.WeaponInfo = {
        { name = "#glide.weapons.mgs", icon = "glide/icons/bullets.png" }
    }

    ENT.CrosshairInfo = {
        { iconType = "dot", traceOrigin = Vector( 0, 0, -15 ) }
    }

    ENT.MinigunFireLoop = "glide/weapons/turret_mg_loop.wav"
    ENT.MinigunFireStop = "glide/weapons/turret_mg_end.wav"
end

if SERVER then
    ENT.ChassisMass = 600
    ENT.ChassisModel = "models/gta5/vehicles/akula/akula_body.mdl"
    ENT.HasLandingGear = true

    ENT.MainRotorRadius = 295
    ENT.TailRotorRadius = 30

    ENT.MainRotorModel = "models/gta5/vehicles/akula/akula_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/akula/akula_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/akula/akula_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/akula/akula_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/akula_gib1.mdl",
        "models/gta5/vehicles/gibs/akula_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -15, -18, -40 )

    ENT.HelicopterParams = {
        pushUpForce = 270,
        pitchForce = 2000,
        yawForce = 3500,
        rollForce = 1100
    }

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 0.03, replenishDelay = 0 }
    }

    ENT.BulletOffsets = {
        Vector( 220, 0, -15 )
    }

    ENT.BulletAngles = {
        Angle()
    }

    function ENT:CreateFeatures()
        -- Change default material
        self:SetSubMaterial( 1, "models/gta5/vehicles/body_paint2" )

        self:CreateSeat( Vector( 115, 13, 22 ), nil, Vector( 115, 100, 0 ), true )
        self:CreateSeat( Vector( 115, -13, 22 ), nil, Vector( 115, -100, 0 ), true )
        self:CreateSeat( Vector( 64, 13, 30 ), nil, Vector( 64, 120, 0 ), true )
        self:CreateSeat( Vector( 64, -13, 30 ), nil, Vector( 64, -120, 0 ), true )

        -- Tail rotor is "contained" on this helicopter model so, disable the trace
        self.tailRotor.enableTrace = false

        -- Wheels for the landing gear
        local wheelParams = { suspensionLength = 20 }

        self:CreateWheel( Vector( -265, 0, -10 ), wheelParams )
        self:CreateWheel( Vector( 105, 50, -20 ), wheelParams )
        self:CreateWheel( Vector( 105, -50, -20 ), wheelParams )
        self:ChangeWheelRadius( 12 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end

    function ENT:GetSpawnColor()
        return Color( 114, 108, 91 )
    end
end
