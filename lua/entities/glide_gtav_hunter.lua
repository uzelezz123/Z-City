AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_armed_heli"
ENT.PrintName = "Hunter"

ENT.MainRotorOffset = Vector( 3, 0, 95 )
ENT.TailRotorOffset = Vector( -363, 3, -13 )

DEFINE_BASECLASS( "glide_gtav_armed_heli" )

if CLIENT then
    ENT.CameraOffset = Vector( -950, 0, 200 )

    ENT.ExhaustPositions = {
        Vector( -60, 45, 48 ),
        Vector( -60, -45, 48 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 0, 0, 80 ), angle = Angle( 300, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( -425, 0, -25 ), blinkTime = 0 },
        { offset = Vector( 27, 121, 17 ), blinkTime = 0.1 },
        { offset = Vector( 27, -121, 17 ), blinkTime = 0.6 }
    }

    ENT.DistantSoundPath = "glide/helicopters/distant_loop_1.wav"
    ENT.TailSoundPath = "glide/helicopters/tail_rotor_2.wav"

    ENT.JetSoundPath = "glide/helicopters/jet_1.wav"
    ENT.JetSoundLevel = 65
    ENT.JetSoundVolume = 0.15

    ENT.BassSoundSet = "Glide.HunterRotor.Bass"
    ENT.MidSoundSet = "Glide.HunterRotor.Mid"
    ENT.HighSoundSet = "Glide.HunterRotor.High"

    ENT.BassSoundVol = 1.0
    ENT.MidSoundVol = 0.6
    ENT.HighSoundVol = 1.0

    ENT.WeaponInfo = {
        { name = "#glide.weapons.homing_missiles", icon = "glide/icons/rocket.png" },
        { name = "#glide.weapons.barrage_missiles", icon = "glide/icons/rocket.png" }
    }

    ENT.CrosshairInfo = {
        { iconType = "square", traceOrigin = Vector( 0, 0, -15 ) },
        { iconType = "square", traceOrigin = Vector( 0, 0, -15 ) }
    }

    function ENT:OnLocalPlayerEnter( seatIndex )
        self:DisableCrosshair()
        self.isUsingTurret = false

        if seatIndex > 1 then
            self:EnableCrosshair( {
                iconType = "dot",
                color = Color( 0, 255, 0 )
            } )

            self.isUsingTurret = true
        else
            BaseClass.OnLocalPlayerEnter( self, seatIndex )
        end
    end

    function ENT:OnLocalPlayerExit()
        self:DisableCrosshair()
        self.isUsingTurret = false
    end

    function ENT:UpdateCrosshairPosition()
        if self.isUsingTurret then
            self.crosshair.origin = Glide.GetCameraAimPos()
        else
            BaseClass.UpdateCrosshairPosition( self )
        end
    end

    local CAMERA_TYPE = Glide.CAMERA_TYPE

    function ENT:GetCameraType( seatIndex )
        return seatIndex > 1 and CAMERA_TYPE.TURRET or CAMERA_TYPE.AIRCRAFT
    end
end

if SERVER then
    ENT.ChassisMass = 600
    ENT.ChassisModel = "models/gta5/vehicles/hunter/hunter_body.mdl"

    ENT.MainRotorRadius = 325
    ENT.TailRotorRadius = 35

    ENT.MainRotorModel = "models/gta5/vehicles/hunter/hunter_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/hunter/hunter_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/hunter/hunter_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/hunter/hunter_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/hunter_gib1.mdl",
        "models/gta5/vehicles/gibs/hunter_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -20, -35, -20 )

    ENT.HelicopterParams = {
        pushUpForce = 380,
        pitchForce = 1800,
        yawForce = 1200,
        rollForce = 1700,
        uprightForce = 800
    }

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 1.0, replenishDelay = 0, ammoType = "missile", lockOn = true },
        { maxAmmo = 6, fireRate = 0.15, replenishDelay = 6, ammoType = "barrage" }
    }

    ENT.MissileOffsets = {
        Vector( 50, 80, -15 ),
        Vector( 50, -80, -15 )
    }

    function ENT:CreateFeatures()
        -- Change default material
        self:SetSubMaterial( 5, "models/gta5/vehicles/body_paint2" )

        self:CreateSeat( Vector( 82, 0, 10 ), nil, Vector( 220, 90, -20 ), true )
        self:CreateSeat( Vector( 140, 0, 0 ), nil, Vector( 180, 90, -20 ), true )

        -- Tail rotor is "contained" on this helicopter model so, disable the trace
        self.tailRotor.enableTrace = false

        self.turret = Glide.CreateTurret( self, Vector( 135, 0, -35 ), Angle() )
        self.turret:SetModel( "models/gta5/vehicles/turrets/hunter_mg_base.mdl" )
        self.turret:SetBodyModel( "models/gta5/vehicles/turrets/hunter_mg_gun.mdl", Vector( 0, 0, -20 ) )
        self.turret:SetMinPitch( -50 )
        self.turret:SetBulletOffset( Vector( 60, 0, 0 ) )

        self.turret:SetColor( self:GetColor() )
        self.turret:GetGunBody():SetColor( self:GetColor() )
    end

    function ENT:Think()
        BaseClass.Think( self )

        self.turret:UpdateUser( self:GetSeatDriver( 2 ) )

        return true
    end

    function ENT:GetSpawnColor()
        return Color( 43, 54, 34, 255 )
    end
end
