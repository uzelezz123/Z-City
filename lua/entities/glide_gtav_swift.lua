AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Swift"

ENT.MainRotorOffset = Vector( 13, 0, 100 )
ENT.TailRotorOffset = Vector( -336, 14, 61 )

if CLIENT then
    ENT.CameraOffset = Vector( -700, 0, 150 )

    ENT.ExhaustPositions = {
        Vector( -75, 22, 60 ),
        Vector( -75, -22, 60 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 15, 0, 90 ), angle = Angle( 300, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( -350, 0, 132 ), blinkTime = 0 },
        { offset = Vector( 85, 20, 64 ), blinkTime = 0.1 },
        { offset = Vector( 85, -20, 64 ), blinkTime = 0.6 }
    }

    ENT.StrobeLightColors = {
        Color( 255, 255, 255 ),
        Color( 255, 0, 0 ),
        Color( 0, 255, 0 )
    }
end

if SERVER then
    ENT.ChassisMass = 700
    ENT.ChassisModel = "models/gta5/vehicles/swift/swift_body.mdl"

    ENT.HasLandingGear = true
    ENT.MainRotorRadius = 252
    ENT.TailRotorRadius = 55

    ENT.MainRotorModel = "models/gta5/vehicles/swift/swift_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/swift/swift_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/swift/swift_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/swift/swift_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/swift_gib1.mdl",
        "models/gta5/vehicles/gibs/swift_gib2.mdl"
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 108, 15, -2 ), nil, Vector( 105, 70, -5 ), true )
        self:CreateSeat( Vector( 108, -15, -2 ), nil, Vector( 105, -70, -5 ), true )
        self:CreateSeat( Vector( 48, 14, -5 ), nil, Vector( 45, -80, 0 ), true )
        self:CreateSeat( Vector( 48, -14, -5 ), nil, Vector( 45, 80, 0 ), true )

        -- Wheels for the landing gear
        local wheelParams = { suspensionLength = 15 }

        self:CreateWheel( Vector( 155, 0, -10 ), wheelParams )
        self:CreateWheel( Vector( -17, 45, -10 ), wheelParams )
        self:CreateWheel( Vector( -17, -45, -10 ), wheelParams )
        self:ChangeWheelRadius( 13 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end
end
