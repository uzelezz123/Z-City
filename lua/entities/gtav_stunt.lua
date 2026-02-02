AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "Mallard"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/stunt/chassis.mdl"

ENT.PropOffset = Vector( 114, 0, 3 )

if CLIENT then
    ENT.CameraOffset = Vector( -370, 0, 70 )

    ENT.ExhaustPositions = {
        Vector( 70, 0, -28 )
    }

    ENT.StrobeLights = {
        { offset = Vector( -118, 0, 42 ), blinkTime = 0 },
        { offset = Vector( 47, 160, 7.5 ), blinkTime = 0.1 },
        { offset = Vector( 47, -160, 7.5 ), blinkTime = 0.6 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 110, -10, 5 ), angle = Angle( 90, 0, 50 ), scale = 0.5 },
        { offset = Vector( 110, 10, 5 ), angle = Angle( 90, 0, -50 ), scale = 0.5 }
    }

    DEFINE_BASECLASS( "base_glide_plane" )

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.rudderBone = self:LookupBone( "rudder" )
        self.elevatorBone = self:LookupBone( "elevator" )
        self.aileronRBone = self:LookupBone( "aileron_r" )
        self.aileronLBone = self:LookupBone( "aileron_l" )
    end

    local ang = Angle()

    function ENT:OnUpdateAnimations()
        if not self.rudderBone then return end

        ang[1] = 0
        ang[2] = 0
        ang[3] = self:GetElevator() * -25

        self:ManipulateBoneAngles( self.elevatorBone, ang )

        ang[1] = self:GetRudder() * 10
        ang[2] = 0
        ang[3] = 0

        self:ManipulateBoneAngles( self.rudderBone, ang )

        local aileron = self:GetAileron()

        ang[1] = aileron * 2
        ang[2] = aileron * -0.5
        ang[3] = aileron * 15

        self:ManipulateBoneAngles( self.aileronRBone, ang )

        ang[1] = aileron * 2
        ang[2] = aileron * -0.5
        ang[3] = aileron * -15

        self:ManipulateBoneAngles( self.aileronLBone, ang )
    end
end

if SERVER then
    ENT.ChassisMass = 800
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/stunt/gibs/chassis.mdl",
        "models/gta5/vehicles/stunt/gibs/wing_l.mdl",
        "models/gta5/vehicles/stunt/gibs/wing_r.mdl"
    }

    ENT.PropModel = "models/gta5/vehicles/stunt/stunt_prop_slow.mdl"
    ENT.PropFastModel = "models/gta5/vehicles/stunt/stunt_prop_fast.mdl"
    ENT.PropRadius = 35

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( -5, 0, -15 ), Angle( 0, 270, 10 ), Vector( -50, 120, 0 ), true )

        -- Front left
        self:CreateWheel( Vector( 56, 40.7, -40 ), {
            model = "models/gta5/vehicles/stunt/stunt_wheel.mdl",
            modelScale = Vector( 1, 0.4, 1 ),
            enableAxleForces = true,
            radius = 8
        } )

        -- Front right
        self:CreateWheel( Vector( 56, -40.7, -40 ), {
            model = "models/gta5/vehicles/stunt/stunt_wheel.mdl",
            modelScale = Vector( 1, 0.4, 1 ),
            enableAxleForces = true,
            radius = 8
        } )

        -- Rear
        self:CreateWheel( Vector( -145, 0, -8 ), {
            model = "models/gta5/vehicles/stunt/stunt_wheel.mdl",
            modelScale = Vector( 1, 0.4, 1 ),
            steerMultiplier = -1,
            enableAxleForces = true,
            radius = 6
        } )
    end
end
