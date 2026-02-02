AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_armed_heli"
ENT.PrintName = "Annihilator"

ENT.MainRotorOffset = Vector( 0, 0, 110 )
ENT.TailRotorOffset = Vector( -397, 15, 115 )

if CLIENT then
    ENT.CameraOffset = Vector( -800, 0, 180 )
    ENT.MidSoundVol = 0.5

    ENT.ExhaustPositions = {
        Vector( -88, 38, 70 ),
        Vector( -88, -38, 70 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 0, 0, 90 ), angle = Angle( 300, 0, 0 ), scale = 1.5 }
    }

    ENT.WeaponInfo = {
        { name = "#glide.weapons.mgs", icon = "glide/icons/bullets.png" }
    }

    ENT.CrosshairInfo = {
        { iconType = "dot" }
    }

    function ENT:AllowFirstPersonMuffledSound( seatIndex )
        return seatIndex < 3
    end
end

if SERVER then
    ENT.ChassisMass = 800
    ENT.ChassisModel = "models/gta5/vehicles/annihilator/annihilator_body.mdl"

    ENT.MainRotorRadius = 320
    ENT.TailRotorRadius = 64

    ENT.MainRotorModel = "models/gta5/vehicles/annihilator/annihilator_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/annihilator/annihilator_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/annihilator/annihilator_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/annihilator/annihilator_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/annihilator_gib1.mdl",
        "models/gta5/vehicles/gibs/annihilator_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -30, -30, -35 )

    ENT.HelicopterParams = {
        pitchForce = 2500,
        yawForce = 2500,
        rollForce = 1800
    }

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 0.02, replenishDelay = 0 }
    }

    function ENT:CreateFeatures()
        -- Change default material
        self:SetSubMaterial( 0, "models/gta5/vehicles/body_paint2" )

        self:CreateSeat( Vector( 114, 27, 7 ), nil, Vector( 140, 120, 0 ), true )
        self:CreateSeat( Vector( 114, -27, 7 ), nil, Vector( 140, -120, 0 ), true )
        self:CreateSeat( Vector( -28, 19, -2 ), Angle( 0, 270, 0 ), Vector( -30, 90, 0 ), true )
        self:CreateSeat( Vector( -28, -19, -2 ), Angle( 0, 270, 0 ), Vector( -30, -90, 0 ), true )
    end

    function ENT:GetSpawnColor()
        return Color( 30, 30, 30, 255 )
    end

    ENT.BulletOffsets = {
        Vector( 85, -85, 10 ),
        Vector( 85, 85, 10 ),
        Vector( 85, -102, 13 ),
        Vector( 85, 102, 13 )
    }

    ENT.BulletAngles = {
        Angle( 0, 1, 0 ),
        Angle( 0, -1, 0 ),
        Angle( 0, 1.3, 0 ),
        Angle( 0, -1.3, 0 )
    }
end
