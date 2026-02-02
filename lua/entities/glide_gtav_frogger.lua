AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Frogger"

ENT.MainRotorOffset = Vector( -5, 0, 92 )
ENT.TailRotorOffset = Vector( -237, 0, 48.5 )

if CLIENT then
    ENT.CameraOffset = Vector( -650, 0, 150 )

    ENT.ExhaustPositions = {
        Vector( -60, 20, 67 ),
        Vector( -60, -20, 67 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -10, 0, 75 ), angle = Angle( 300, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( 132, 0, -1 ), blinkTime = 0 },
        { offset = Vector( -185, 55, 64 ), blinkTime = 0.1 },
        { offset = Vector( -185, -55, 64 ), blinkTime = 0.6 }
    }
end

if SERVER then
    ENT.ChassisMass = 700
    ENT.ChassisModel = "models/gta5/vehicles/frogger/frogger_body.mdl"

    ENT.MainRotorRadius = 205

    ENT.MainRotorModel = "models/gta5/vehicles/frogger/frogger_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/frogger/frogger_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/frogger/frogger_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/frogger/frogger_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/frogger_gib1.mdl",
        "models/gta5/vehicles/gibs/frogger_gib2.mdl"
    }

    function ENT:CreateFeatures()
        -- Front seats
        self:CreateSeat( Vector( 76, 18, 4 ), nil, Vector( 72, 80, -10 ), true )
        self:CreateSeat( Vector( 76, -18, 4 ), nil, Vector( 72, 80, -10 ), true )

        -- Rear seats
        self:CreateSeat( Vector( 35, 23, 4 ), nil, Vector( 35, 80, -10 ), true )
        self:CreateSeat( Vector( 35, 0, 4 ), nil, Vector( 35, -80, -10 ), true )
        self:CreateSeat( Vector( 35, -23, 4 ), nil, Vector( 35, -80, -10 ), true )

        -- Tail rotor is "contained" on this helicopter model so, disable the trace
        self.tailRotor.enableTrace = false
    end
end
