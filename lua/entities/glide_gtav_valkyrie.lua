AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Valkyrie"

ENT.MainRotorOffset = Vector( 5, 0, 110 )
ENT.TailRotorOffset = Vector( -374, 0, 17 )

DEFINE_BASECLASS( "base_glide_heli" )

if CLIENT then
    ENT.CameraOffset = Vector( -900, 0, 200 )

    ENT.ExhaustPositions = {
        Vector( -120, 15, 50 ),
        Vector( -120, -15, 50 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -10, 0, 90 ), angle = Angle( 300, 0, 0 ) }
    }

    ENT.MidSoundVol = 0.6
    ENT.HighSoundVol = 0.6

    ENT.DistantSoundPath = "glide/helicopters/distant_loop_1.wav"
    ENT.TailSoundPath = "glide/helicopters/tail_rotor_2.wav"

    ENT.JetSoundPath = "glide/helicopters/jet_1.wav"
    ENT.JetSoundLevel = 65
    ENT.JetSoundVolume = 0.15

    function ENT:OnLocalPlayerEnter( seatIndex )
        self:DisableCrosshair()
        self.isUsingTurret = false

        if seatIndex > 2 then
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

    function ENT:AllowFirstPersonMuffledSound( seatIndex )
        return seatIndex < 3
    end

    local CAMERA_TYPE = Glide.CAMERA_TYPE

    function ENT:GetCameraType( seatIndex )
        return seatIndex > 2 and CAMERA_TYPE.TURRET or CAMERA_TYPE.AIRCRAFT
    end
end

if SERVER then
    ENT.ChassisMass = 800
    ENT.ChassisModel = "models/gta5/vehicles/valkyrie/valkyrie_body.mdl"

    ENT.MainRotorRadius = 325
    ENT.TailRotorRadius = 20

    ENT.MainRotorModel = "models/gta5/vehicles/valkyrie/valkyrie_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/valkyrie/valkyrie_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/valkyrie/valkyrie_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/valkyrie/valkyrie_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/valkyrie_gib1.mdl",
        "models/gta5/vehicles/gibs/valkyrie_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -15, -15, -20 )

    ENT.HelicopterParams = {
        pushUpForce = 300,
        pitchForce = 900,
        yawForce = 1200,
        rollForce = 900
    }

    function ENT:CreateFeatures()
        -- Change default material
        self:SetSubMaterial( 0, "models/gta5/vehicles/body_paint2" )

        self:CreateSeat( Vector( 120, 18, -15 ), nil, Vector( 120, 90, -20 ), true )
        self:CreateSeat( Vector( 120, -18, -15 ), nil, Vector( 120, -90, -20 ), true )

        self:CreateSeat( Vector( 0, 25, -25 ), Angle( 0, 0, 0 ), Vector( 50, 120, -20 ), true )
        self:CreateSeat( Vector( 0, -25, -25 ), Angle( 0, 180, 0 ), Vector( 50, -120, -20 ), true )

        -- Tail rotor is "contained" on this helicopter model so, disable the trace
        self.tailRotor.enableTrace = false

        self.leftTurret = Glide.CreateTurret( self, Vector( -1.1, 63.5, -8.5 ), Angle() )
        self.leftTurret:SetModel( "models/gta5/vehicles/turrets/turret_mg_base.mdl" )
        self.leftTurret:SetBodyModel( "models/gta5/vehicles/turrets/turret_mg_rot1.mdl" )
        self.leftTurret:SetMinYaw( 0 )
        self.leftTurret:SetMaxYaw( 180 )

        self.rightTurret = Glide.CreateTurret( self, Vector( -1.1, -63.5, -8.5 ), Angle() )
        self.rightTurret:SetModel( "models/gta5/vehicles/turrets/turret_mg_base.mdl" )
        self.rightTurret:SetBodyModel( "models/gta5/vehicles/turrets/turret_mg_rot1.mdl" )
        self.rightTurret:SetMinYaw( -180 )
        self.rightTurret:SetMaxYaw( 0 )

        self:SetupTurretBarrel( self.leftTurret )
        self:SetupTurretBarrel( self.rightTurret )
    end

    function ENT:GetSpawnColor()
        return Color( 168, 162, 155 )
    end

    function ENT:SetupTurretBarrel( turret )
        turret.spinAngle = Angle()
        turret.spinSpeed = 0

        turret.barrel = ents.Create( "prop_dynamic_override" )
        turret.barrel:SetModel( "models/gta5/vehicles/turrets/turret_mg_rot2.mdl" )
        turret.barrel:SetParent( turret:GetGunBody() )
        turret.barrel:SetLocalPos( Vector( 4, 0, 5 ) )
        turret.barrel:SetLocalAngles( Angle() )
        turret.barrel:Spawn()
        turret.barrel:DrawShadow( false )

        turret:DeleteOnRemove( turret.barrel )
    end

    local FrameTime = FrameTime

    function ENT:UpdateTurretBarrel( turret )
        local dt = FrameTime()

        turret.spinSpeed = Lerp( dt * 10, turret.spinSpeed, turret:GetIsFiring() and 1200 or 0 )
        turret.spinAngle[3] = ( turret.spinAngle[3] + dt * turret.spinSpeed ) % 360
        turret.barrel:SetLocalAngles( turret.spinAngle )
    end

    function ENT:Think()
        BaseClass.Think( self )

        self:UpdateTurretBarrel( self.leftTurret )
        self:UpdateTurretBarrel( self.rightTurret )

        self.leftTurret:UpdateUser( self:GetSeatDriver( 3 ) )
        self.rightTurret:UpdateUser( self:GetSeatDriver( 4 ) )

        return true
    end
end
