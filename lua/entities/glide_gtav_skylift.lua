AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Skylift"

ENT.MaxChassisHealth = 1500
ENT.MainRotorOffset = Vector( -128, 0, 180 )
ENT.TailRotorOffset = Vector( -725, 8, 130 )

if CLIENT then
    ENT.CameraOffset = Vector( -1300, 0, 300 )

    ENT.ExhaustPositions = {
        Vector( -80, 50, 120 ),
        Vector( -80, -50, 120 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -130, -50, 120 ), angle = Angle( 300, 90, 0 ), scale = 1.5 },
        { offset = Vector( -130, 50, 120 ), angle = Angle( 300, 270, 0 ), scale = 1.5 }
    }

    ENT.StartSound = "glide/helicopters/start_2.wav"
    ENT.TailSoundPath = "glide/helicopters/prop_1.wav"
    ENT.TailSoundLevel = 70

    ENT.EngineSoundPath = "glide/helicopters/jet_2.wav"
    ENT.EngineSoundLevel = 75
    ENT.EngineSoundVolume = 0.8

    ENT.JetSoundPath = "glide/helicopters/howl_1.wav"
    ENT.JetSoundLevel = 60
    ENT.JetSoundVolume = 0.4

    ENT.DistantSoundPath = "glide/helicopters/distant_loop_1.wav"
    ENT.RotorBeatInterval = 0.088

    ENT.BassSoundVol = 1.0
    ENT.MidSoundVol = 0.8

    function ENT:GetCameraType( seatIndex )
        return seatIndex > 2 and Glide.CAMERA_TYPE.TURRET or Glide.CAMERA_TYPE.AIRCRAFT
    end
end

if SERVER then
    ENT.ChassisMass = 30000
    ENT.ChassisModel = "models/gta5/vehicles/skylift/skylift_body.mdl"

    ENT.SpawnPositionOffset = Vector( 0, 0, 130 )

    ENT.MainRotorRadius = 480
    ENT.TailRotorRadius = 90

    ENT.MainRotorModel = "models/gta5/vehicles/skylift/skylift_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/skylift/skylift_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/skylift/skylift_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/skylift/skylift_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/skylift_gib1.mdl",
        "models/gta5/vehicles/gibs/skylift_gib2.mdl"
    }

    ENT.AngularDrag = Vector( -20, -30, -30 )

    ENT.HelicopterParams = {
        turbulanceForce = 70,
        pushUpForce = 350,
        pitchForce = 3000,
        yawForce = 2000,
        rollForce = 1500,
        maxPitch = 40
    }

    -- Custom stuff
    ENT.HasMagnet = true
    ENT.MagnetOrigin = Vector( -115, 0, -65 )
    ENT.MagnetRadius = 150

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 165, 36, -30 ), nil, Vector( 170, 100, -30 ), true )
        self:CreateSeat( Vector( 165, -36, -30 ), nil, Vector( 170, -100, -30 ), true )
        self:CreateSeat( Vector( 125, 33, -57 ), Angle( 0, 90, 0 ), Vector( 100, 100, -30 ), true )

        self:DropMagnetTarget()
    end

    function ENT:DropMagnetTarget()
        self.grabTarget = NULL
        self.sourcePos = nil
        self.sourceAng = nil

        self.grabAnim = 0
        self.grabOffset = 0
        self.grabAngleOffset = 0

        if IsValid( self.grabWeld ) then
            self.grabWeld:Remove()
        end
    end

    DEFINE_BASECLASS( "base_glide_heli" )

    local CanPickup = function( _ent, _ply )
        return true
    end

    if CPPI then
        CanPickup = function( ent, ply )
            return ent:CPPICanPickup( ply )
        end
    end

    local IsValid = IsValid
    local FindInSphere = ents.FindInSphere

    local CLASS_WHITELIST = {
        ["prop_physics"] = true,
        ["prop_dynamic"] = true
    }

    local function FindGrabbableEnt( origin, radius, grabber, source )
        local targets = FindInSphere( origin, radius )
        local phys

        for _, target in ipairs( targets ) do
            phys = target:GetPhysicsObject()

            if
                target ~= source and
                IsValid( phys ) and
                phys:IsMotionEnabled() and
                not IsValid( target:GetParent() ) and
                CanPickup( target, grabber ) and
                ( CLASS_WHITELIST[target:GetClass()] or target.IsGlideVehicle or target.IsSimfphyscar )
            then
                return target
            end
        end
    end

    local GRAB_SOUND = "physics/metal/metal_solid_strain%d.wav"
    local MOVE_SOUND = "physics/metal/metal_box_strain%d.wav" -- up to 4

    function ENT:OnSeatInput( seatIndex, action, pressed )
        if action ~= "attack" or seatIndex > 1 or not self.HasMagnet then
            BaseClass.OnSeatInput( seatIndex, action, pressed )
            return
        end

        if not pressed then return end

        local driver = self:GetDriver()
        if not IsValid( driver ) then return end

        if IsValid( self.grabTarget ) then
            local phys = self.grabTarget:GetPhysicsObject()

            if IsValid( phys ) then
                phys:Wake()
            end

            self:DropMagnetTarget()
            self:EmitSound( MOVE_SOUND:format( math.random( 4 ) ), 90, 100, 0.8 )

            return
        end

        local target = FindGrabbableEnt( self:LocalToWorld( self.MagnetOrigin ), self.MagnetRadius, driver, self )

        if IsValid( target ) then
            if
                target.VehicleType == Glide.VEHICLE_TYPE.PLANE or
                target.VehicleType == Glide.VEHICLE_TYPE.HELICOPTER
            then
                Glide.SendNotification( driver, {
                    text = "You cannot grab that.",
                    icon = "materials/icon16/cancel.png",
                    immediate = true
                } )

                return
            end

            local mins, maxs = target:GetCollisionBounds()
            local size = maxs - mins
            local volume = size[1] * size[2] * size[3]

            if volume > 30000000 then
                Glide.SendNotification( driver, {
                    text = "That object is too big.",
                    icon = "materials/icon16/cancel.png",
                    immediate = true
                } )

                return
            end

            self.grabTarget = target
            self.grabAnim = 0
            self.sourcePos = target:GetPos()
            self.sourceAng = target:GetAngles()

            self.grabOffset = Vector( 0, 0, -maxs[3] )
            self.grabAngleOffset = Angle( 0, size[1] < size[2] and 90 or 0, 0 )

            self:EmitSound( GRAB_SOUND:format( math.random( 4, 5 ) ), 90, 100, 0.8 )
        end
    end

    local AngleDifference = math.AngleDifference

    function ENT:OnPostThink( dt, selfTbl )
        BaseClass.OnPostThink( self, dt, selfTbl )

        local target = self.grabTarget
        if not IsValid( target ) then return end

        local magnetPos = self:LocalToWorld( self.MagnetOrigin + self.grabOffset )
        local magnetAng = self:LocalToWorldAngles( self.grabAngleOffset )

        if self.grabAnim < 1 then
            self.grabAnim = self.grabAnim + dt

            local a = self.grabAnim ^ 3
            local b = 1 - a

            magnetPos[1] = ( self.sourcePos[1] * b ) + ( magnetPos[1] * a )
            magnetPos[2] = ( self.sourcePos[2] * b ) + ( magnetPos[2] * a )
            magnetPos[3] = ( self.sourcePos[3] * b ) + ( magnetPos[3] * a )

            local fromAng = self.sourceAng

            magnetAng[1] = ( fromAng[1] * b ) + ( fromAng[1] + AngleDifference( magnetAng[1], fromAng[1] ) ) * a
            magnetAng[2] = ( fromAng[2] * b ) + ( fromAng[2] + AngleDifference( magnetAng[2], fromAng[2] ) ) * a
            magnetAng[3] = ( fromAng[3] * b ) + ( fromAng[3] + AngleDifference( magnetAng[3], fromAng[3] ) ) * a

            target:SetPos( magnetPos )
            target:SetAngles( magnetAng )

        elseif self.grabAnim < 2 then
            target:SetPos( magnetPos )
            target:SetAngles( magnetAng )

            self.grabAnim = 2
            self.grabWeld = constraint.Weld( self, target, 0, 0, 0, true )
        end
    end
end
