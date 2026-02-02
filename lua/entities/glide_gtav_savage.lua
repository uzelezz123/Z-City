AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_armed_heli"
ENT.PrintName = "Savage"

ENT.MaxChassisHealth = 1500
ENT.MainRotorOffset = Vector( 0, 0, 120 )
ENT.TailRotorOffset = Vector( -423, 25, 113 )

function ENT:GetFirstPersonOffset( _seatIndex, localEyePos )
    localEyePos[3] = localEyePos[3] - 1
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -800, 0, 200 )

    ENT.ExhaustPositions = {
        Vector( 0, 40, 65 ),
        Vector( 0, -40, 65 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 0, 0, 102 ), angle = Angle( 300, 0, 0 ) }
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
    ENT.MidSoundVol = 0.85
    ENT.HighSoundVol = 0.4

    ENT.WeaponInfo = {
        { name = "#glide.weapons.explosive_cannon", icon = "glide/icons/bullets.png" },
        { name = "#glide.weapons.homing_missiles", icon = "glide/icons/rocket.png" },
        { name = "#glide.weapons.missiles", icon = "glide/icons/rocket.png" }
    }

    ENT.CrosshairInfo = {
        { iconType = "dot", traceOrigin = Vector( 0, 0, -18 ) },
        { iconType = "square" },
        { iconType = "square" }
    }

    function ENT:AllowFirstPersonMuffledSound( seatIndex )
        return seatIndex < 3
    end
end

if SERVER then
    ENT.ChassisMass = 700
    ENT.ChassisModel = "models/gta5/vehicles/savage/savage_body.mdl"
    ENT.HasLandingGear = true

    ENT.MainRotorRadius = 340
    ENT.TailRotorRadius = 75

    ENT.MainRotorModel = "models/gta5/vehicles/savage/savage_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/savage/savage_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/savage/savage_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/savage/savage_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/savage_gib1.mdl",
        "models/gta5/vehicles/gibs/savage_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -10, -25, -30 )

    ENT.HelicopterParams = {
        pushUpForce = 300,
        pitchForce = 1800,
        yawForce = 2500,
        rollForce = 650
    }

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 0.08, replenishDelay = 0, ammoType = "explosive_cannon" },
        { maxAmmo = 0, fireRate = 1.0, replenishDelay = 0, ammoType = "missile", lockOn = true },
        { maxAmmo = 0, fireRate = 1.0, replenishDelay = 0, ammoType = "missile" }
    }

    function ENT:CreateFeatures()
        -- Change default material
        self:SetSubMaterial( 1, "models/gta5/vehicles/army_camouflage_512" )

        self:CreateSeat( Vector( 185, 0, -14 ), nil, Vector( 185, 80, -10 ), true )
        self:CreateSeat( Vector( 135, 0, 6 ), nil, Vector( 135, 80, 10 ), true )
        self:CreateSeat( Vector( -18, -20, 0 ), nil, Vector( 40, -100, -10 ), true )
        self:CreateSeat( Vector( -18, 20, 0 ), nil, Vector( 40, 100, -10 ), true )

        -- Wheels for the landing gear
        local wheelParams = { suspensionLength = 28 }

        self:CreateWheel( Vector( 143, 0, -21 ), wheelParams )
        self:CreateWheel( Vector( -58, 64, -20 ), wheelParams )
        self:CreateWheel( Vector( -58, -64, -20 ), wheelParams )
        self:ChangeWheelRadius( 13 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end

    function ENT:GetSpawnColor()
        return Color( 190, 190, 190, 255 )
    end

    ENT.BulletOffsets = {
        Vector( 260, 0, -18 )
    }

    ENT.BulletAngles = {
        Angle( 0, 0, 0 )
    }

    ENT.MissileOffsets = {
        Vector( 20, 75, 0 ),
        Vector( 20, -75, 0 ),
        Vector( 16, 110, -5 ),
        Vector( 16, -110, -5 )
    }
end
