AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "P-996 LAZER"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/lazer/chassis.mdl"
ENT.MaxChassisHealth = 1600

DEFINE_BASECLASS( "base_glide_plane" )

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Bool", "FiringGun" )
end

if CLIENT then
    ENT.CameraOffset = Vector( -600, 0, 110 )

    ENT.CrosshairInfo = {
        { traceOrigin = Vector( 0, 0, 15 ) },
        { traceOrigin = Vector( 0, 0, -12 ) },
        { traceOrigin = Vector( 0, 0, -12 ) }
    }

    ENT.ExhaustPositions = {
        Vector( -230, 0, 8 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -235, 0, 8 ), angle = Angle( 270, 0, 0 ), scale = 0.9 }
    }

    ENT.StartSound = "glide/aircraft/start_4.wav"
    ENT.DistantSoundPath = "glide/aircraft/jet_stream.wav"

    ENT.PropSoundPath = "glide/aircraft/thrust_b11.wav"
    ENT.PropSoundVolume = 0.5
    ENT.PropSoundLevel = 90
    ENT.PropSoundMinPitch = 80
    ENT.PropSoundMaxPitch = 120

    ENT.EngineSoundPath = "glide/aircraft/engine_luxor.wav"
    ENT.EngineSoundLevel = 90
    ENT.EngineSoundVolume = 0.4
    ENT.EngineSoundMinPitch = 103
    ENT.EngineSoundMaxPitch = 132

    ENT.ExhaustSoundPath = "glide/aircraft/distant_laser.wav"
    ENT.ExhaustSoundLevel = 90
    ENT.ExhaustSoundVolume = 0.5
    ENT.ExhaustSoundMinPitch = 55
    ENT.ExhaustSoundMaxPitch = 60

    ENT.ThrustSound = "glide/aircraft/thrust.wav"
    ENT.ThrustSoundMinPitch = 90
    ENT.ThrustSoundMaxPitch = 100
    ENT.ThrustSoundLowVolume = 0.1
    ENT.ThrustSoundHighVolume = 0.4

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.rudderLBone = self:LookupBone( "rudder_l" )
        self.rudderRBone = self:LookupBone( "rudder_r" )
        self.elevatorRBone = self:LookupBone( "elevator_r" )
        self.elevatorLBone = self:LookupBone( "elevator_l" )
        self.aileronRBone = self:LookupBone( "aileron_r" )
        self.aileronLBone = self:LookupBone( "aileron_l" )
        self.airbrakeRBone = self:LookupBone( "airbrake_r" )
        self.airbrakeLBone = self:LookupBone( "airbrake_l" )

        self.airbrake = 0
    end

    local ang = Angle()
    local ExpDecay = Glide.ExpDecay

    function ENT:OnUpdateAnimations()
        if not self.rudderLBone then return end

        ang[1] = 0
        ang[2] = self:GetRudder() * -15
        ang[3] = 0

        self:ManipulateBoneAngles( self.rudderLBone, ang )
        self:ManipulateBoneAngles( self.rudderRBone, ang )

        ang[1] = 0
        ang[2] = self:GetElevator() * -20
        ang[3] = 0

        self:ManipulateBoneAngles( self.elevatorRBone, ang )
        self:ManipulateBoneAngles( self.elevatorLBone, ang )

        ang[1] = 0
        ang[2] = 0
        ang[3] = self:GetAileron() * -15

        self:ManipulateBoneAngles( self.aileronRBone, ang )
        ang[3] = -ang[3]
        self:ManipulateBoneAngles( self.aileronLBone, ang )

        self.airbrake = ExpDecay( self.airbrake, self:GetThrottle() < 0 and 1 or 0, 6, FrameTime() )

        ang[1] = 0
        ang[2] = 0
        ang[3] = self.airbrake * 20
        self:ManipulateBoneAngles( self.airbrakeRBone, ang )

        ang[1] = 0
        ang[2] = self.airbrake * 20
        ang[3] = 0
        self:ManipulateBoneAngles( self.airbrakeLBone, ang )
    end

    function ENT:OnUpdateMisc()
        BaseClass.OnUpdateMisc( self )

        local sounds = self.sounds

        if self:GetFiringGun() then
            if not sounds.gunFire then
                local gunFire = self:CreateLoopingSound( "gunFire", ")glide/weapons/mg_shoot_loop.wav", 95, self )
                gunFire:PlayEx( 1.0, 100 )
            end

        elseif sounds.gunFire then
            sounds.gunFire:Stop()
            sounds.gunFire = nil

            self:EmitSound( ")glide/weapons/mg_shoot_stop.wav", 95, 100, 1.0 )
        end
    end

    ENT.AfterburnerOrigin = Vector( -220, 0, 8 )

    local Effect = util.Effect

    function ENT:OnUpdateParticles()
        BaseClass.OnUpdateParticles( self )

        local power = self:GetPower()
        if power < 0.5 then return end

        local eff = EffectData()
        eff:SetEntity( self )
        eff:SetOrigin( self:LocalToWorld( self.AfterburnerOrigin ) )
        eff:SetAngles( self:GetAngles() )
        eff:SetScale( 2 )
        eff:SetMagnitude( power )
        Effect( "glide_afterburner", eff, true )

        local throttle = self:GetThrottle()
        if throttle < 0.1 then return end

        eff:SetMagnitude( throttle * power )
        eff:SetRadius( 30 ) -- This is actually a offset for the flare effect
        Effect( "glide_afterburner_flame", eff, true )
    end
end

if SERVER then
    ENT.ChassisMass = 1500
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )
    ENT.BulletDamageMultiplier = 0.7

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/lazer/gibs/chassis.mdl",
        "models/gta5/vehicles/lazer/gibs/wing_l.mdl",
        "models/gta5/vehicles/lazer/gibs/wing_r.mdl",
        "models/gta5/vehicles/lazer/gibs/elevator_l.mdl",
        "models/gta5/vehicles/lazer/gibs/elevator_r.mdl",
        "models/gta5/vehicles/lazer/gibs/extra_3.mdl",
        "models/gta5/vehicles/lazer/gibs/extra_4.mdl"
    }

    ENT.HasLandingGear = true
    ENT.ReverseTorque = 2000
    ENT.SteerConeMaxSpeed = 900

    ENT.PlaneParams = {
        liftAngularDrag = Vector( -20, -70, -100 ), -- (Roll, pitch, yaw)
        maxSpeed = 2400,
        liftSpeed = 1800,
        engineForce = 350,

        pitchForce = 5500,
        yawForce = 3500,
        rollForce = 3500
    }

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255, 255 )
    end

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 165, 0, 2 ), Angle( 0, 270, 10 ), Vector( 190, 120, 0 ), true )

        self:CreateWeapon( "explosive_cannon", {
            FireDelay = 0.08,
            ProjectileOffsets = {
                Vector( 130, 32, 15 ),
                Vector( 130, -32, 15 )
            }
        } )

        local missileOffsets = {
            Vector( 50, 124, -12 ),
            Vector( 50, -124, -12 ),
            Vector( 50, 163, -11 ),
            Vector( 50, -163, -11 )
        }

        self:CreateWeapon( "homing_launcher", {
            MaxAmmo = 2,
            AmmoType = "missile",
            AmmoTypeShareCapacity = true,
            FireDelay = 1.0,
            ReloadDelay = 4.0,
            ProjectileOffsets = missileOffsets
        } )

        self:CreateWeapon( "missile_launcher", {
            MaxAmmo = 2,
            AmmoType = "missile",
            AmmoTypeShareCapacity = true,
            FireDelay = 1.0,
            ReloadDelay = 4.0,
            ProjectileOffsets = missileOffsets
        } )

        local wheelParams = {
            suspensionLength = 30,
            springDamper = 10000,
            brakePower = 2000,
            sideTractionMultiplier = 250
        }

        -- Front
        wheelParams.steerMultiplier = 1
        wheelParams.springStrength = 1600
        self:CreateWheel( Vector( 128, 0, -20 ), wheelParams )

        -- Rear
        wheelParams.steerMultiplier = 0
        wheelParams.springStrength = 1400
        self:CreateWheel( Vector( -30, 52, -20 ), wheelParams ) -- left
        self:CreateWheel( Vector( -30, -52, -20 ), wheelParams ) -- right

        self:ChangeWheelRadius( 12 )

        -- Since the model already has a visual representation
        -- for the wheels, hide the actual wheels.
        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end

    function ENT:OnWeaponStart( _, slotIndex )
        if slotIndex == 1 then
            self:SetFiringGun( true )
        end
    end

    function ENT:OnWeaponStop()
        self:SetFiringGun( false )
    end
end
