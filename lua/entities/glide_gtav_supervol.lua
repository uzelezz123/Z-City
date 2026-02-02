AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Super Volito"

ENT.MainRotorOffset = Vector( -31, 0, 65 )
ENT.TailRotorOffset = Vector( -287, 6, 49 )

if CLIENT then
    ENT.CameraOffset = Vector( -700, 0, 150 )

    ENT.ExhaustPositions = {
        Vector( -110, 13, 35 ),
        Vector( -110, -13, 35 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -35, 0, 53 ), angle = Angle( 300, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( -287, 0, 54 ), blinkTime = 0 },
        { offset = Vector( 20, 21, 25 ), blinkTime = 0.1 },
        { offset = Vector( 20, -21, 25 ), blinkTime = 0.6 }
    }

    ENT.RotorBeatInterval = 0.09
end

if SERVER then
    ENT.ChassisMass = 600
    ENT.ChassisModel = "models/gta5/vehicles/supervol/supervol_body.mdl"

    ENT.MainRotorRadius = 205
    ENT.TailRotorRadius = 40

    ENT.MainRotorModel = "models/gta5/vehicles/supervol/supervol_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/supervol/supervol_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/supervol/supervol_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/supervol/supervol_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/supervol_gib1.mdl",
        "models/gta5/vehicles/gibs/supervol_gib2.mdl"
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 60, 14, -30 ), nil, Vector( 70, 80, -30 ), true )
        self:CreateSeat( Vector( 60, -14, -30 ), nil, Vector( 70, -80, -30 ), true )
        self:CreateSeat( Vector( -5, 16, -35 ), nil, Vector( 10, 90, -30 ), true )
        self:CreateSeat( Vector( -5, -16, -35 ), nil, Vector( 10, -90, -30 ), true )
    end
end
