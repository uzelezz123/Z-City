AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Maverick"

ENT.MainRotorOffset = Vector( 0, 0, 110 )
ENT.TailRotorOffset = Vector( -298, 12, 57 )

if CLIENT then
    ENT.CameraOffset = Vector( -700, 0, 150 )

    ENT.ExhaustPositions = {
        Vector( -30, 14, 85 ),
        Vector( -30, -14, 85 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 0, 0, 80 ), angle = Angle( 300, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( -320, 0, 116 ), blinkTime = 0 },
        { offset = Vector( -212, 51, 84 ), blinkTime = 0.1 },
        { offset = Vector( -212, -51, 84 ), blinkTime = 0.6 }
    }

    ENT.RotorBeatInterval = 0.09
end

if SERVER then
    ENT.ChassisMass = 500
    ENT.ChassisModel = "models/gta5/vehicles/maverick/maverick_body.mdl"

    ENT.MainRotorRadius = 270
    ENT.TailRotorRadius = 40

    ENT.MainRotorModel = "models/gta5/vehicles/maverick/maverick_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/maverick/maverick_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/maverick/maverick_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/maverick/maverick_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/maverick_gib1.mdl",
        "models/gta5/vehicles/gibs/maverick_gib2.mdl"
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 70, 18, -8 ), nil, Vector( 76, 80, 0 ), true )
        self:CreateSeat( Vector( 70, -18, -8 ), nil, Vector( 76, -80, 0 ), true )
        self:CreateSeat( Vector( -35, 21, -8 ), nil, Vector( 20, 90, 0 ), true )
        self:CreateSeat( Vector( -35, -21, -8 ), nil, Vector( -20, -90, 0 ), true )
        self:CreateSeat( Vector( -35, 0, -8 ), nil, Vector( -20, -110, 0 ), true )
    end
end
