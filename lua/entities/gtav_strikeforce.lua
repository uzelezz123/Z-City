AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_plane"
ENT.PrintName = "B-11 Strikeforce"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/strikeforce/chassis.mdl"
ENT.MaxChassisHealth = 1800

ENT.PropOffset = Vector( 114, 0, 3 )

DEFINE_BASECLASS( "base_glide_plane" )

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Bool", "FiringGun" )
end

if CLIENT then
    ENT.CameraOffset = Vector( -600, 0, 150 )

    ENT.WeaponInfo = {
        -- Rename "Missiles" to "Barrage" 
        [3] = { name = "#glide.weapons.barrage_missiles" }
    }

    ENT.CrosshairInfo = {
        { traceOrigin = Vector( 0, 0, -18.5 ) },
        { traceOrigin = Vector( 0, 0, -19 ) },
        { traceOrigin = Vector( 0, 0, -19 ) }
    }

    ENT.ExhaustPositions = {
        Vector( -172, 50, 25 ),
        Vector( -172, -50, 25 )
    }

    ENT.StrobeLights = {
        { offset = Vector( -262, 0, 84 ), blinkTime = 0 },
        { offset = Vector( -12, 291, 9 ), blinkTime = 0.1 },
        { offset = Vector( -12, -291, 9 ), blinkTime = 0.6 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -175, 50, 25 ), angle = Angle( 270, 0, 0 ), scale = 0.7 },
        { offset = Vector( -175, -50, 25 ), angle = Angle( 270, 0, 0 ), scale = 0.7 }
    }

    ENT.StartSound = "glide/aircraft/start_4.wav"
    ENT.DistantSoundPath = "glide/aircraft/jet_stream.wav"
    ENT.PropSoundPath = ""

    ENT.EngineSoundPath = "glide/aircraft/engine_luxor.wav"
    ENT.EngineSoundLevel = 90
    ENT.EngineSoundVolume = 0.45
    ENT.EngineSoundMinPitch = 103
    ENT.EngineSoundMaxPitch = 132

    ENT.ExhaustSoundPath = "glide/aircraft/distant_laser.wav"
    ENT.ExhaustSoundLevel = 90
    ENT.ExhaustSoundVolume = 0.5
    ENT.ExhaustSoundMinPitch = 55
    ENT.ExhaustSoundMaxPitch = 60

    ENT.ThrustSound = "glide/aircraft/thrust_b11.wav"

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.minigunBone = self:LookupBone( "minigun" )
        self.propellerRBone = self:LookupBone( "propeller_r" )
        self.propellerLBone = self:LookupBone( "propeller_l" )

        self.rudderBone = self:LookupBone( "rudder" )
        self.elevatorRBone = self:LookupBone( "elevator_r" )
        self.elevatorLBone = self:LookupBone( "elevator_l" )
        self.aileronRBone = self:LookupBone( "aileron_r" )
        self.aileronLBone = self:LookupBone( "aileron_l" )

        self.propSpin = 0
    end

    local FrameTime = FrameTime
    local ang = Angle()

    function ENT:OnUpdateAnimations()
        if not self.rudderBone then return end

        ang[1] = 0
        ang[2] = self:GetRudder() * -15
        ang[3] = 0

        self:ManipulateBoneAngles( self.rudderBone, ang )

        ang[1] = 0
        ang[2] = self:GetElevator() * -20
        ang[3] = 0

        self:ManipulateBoneAngles( self.elevatorRBone, ang )

        ang[1] = 0
        ang[2] = 0
        ang[3] = self:GetElevator() * -20

        self:ManipulateBoneAngles( self.elevatorLBone, ang )

        local aileron = self:GetAileron()

        ang[1] = 0
        ang[2] = aileron * 15
        ang[3] = 0

        self:ManipulateBoneAngles( self.aileronRBone, ang )

        ang[2] = -ang[2]

        self:ManipulateBoneAngles( self.aileronLBone, ang )

        local power = self:GetPower()

        if power > 0.1 then
            self.propSpin = self.propSpin + FrameTime() * power * 1500
            if self.propSpin > 360 then self.propSpin = 0 end

            ang[1] = self.propSpin
            ang[2] = 0
            ang[3] = 0

            self:ManipulateBoneAngles( self.propellerRBone, ang )
            self:ManipulateBoneAngles( self.propellerLBone, ang )
        end

        if self:GetFiringGun() then
            ang[1] = ( CurTime() * 500 ) % 360
            ang[2] = 0
            ang[3] = 0

            self:ManipulateBoneAngles( self.minigunBone, ang )
        end
    end

    function ENT:OnUpdateMisc()
        BaseClass.OnUpdateMisc( self )

        local sounds = self.sounds

        if self:GetFiringGun() then
            if not sounds.gunFire then
                local gunFire = self:CreateLoopingSound( "gunFire", ")glide/weapons/b11_turret_loop.wav", 95, self )
                gunFire:PlayEx( 1.0, 100 )
            end

        elseif sounds.gunFire then
            sounds.gunFire:Stop()
            sounds.gunFire = nil

            self:EmitSound( ")glide/weapons/b11_turret_loop_end.wav", 95, 100, 1.0 )
        end
    end
end

if SERVER then
    ENT.ChassisMass = 1500
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )
    ENT.BulletDamageMultiplier = 0.5

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/strikeforce/gibs/chassis.mdl",
        "models/gta5/vehicles/strikeforce/gibs/wing_l.mdl",
        "models/gta5/vehicles/strikeforce/gibs/wing_r.mdl"
    }

    ENT.HasLandingGear = true
    ENT.ReverseTorque = 2000
    ENT.SteerConeMaxSpeed = 900

    ENT.PlaneParams = {
        liftAngularDrag = Vector( -30, -60, -100 ), -- (Roll, pitch, yaw)
        maxSpeed = 2000,
        liftSpeed = 1800,
        engineForce = 250,

        pitchForce = 4000,
        yawForce = 3500,
        rollForce = 5000
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 157, 0, 4 ), Angle( 0, 270, 10 ), Vector( -160, 120, 0 ), true )

        self:CreateWeapon( "explosive_cannon", {
            FireDelay = 0.08,
            ProjectileOffsets = {
                Vector( 268, 0, -18.5 )
            }
        } )

        self:CreateWeapon( "homing_launcher", {
            AmmoType = "missile",
            MaxAmmo = 0,
            FireDelay = 1.0,
            ProjectileOffsets = {
                Vector( 50, 122, -24 ),
                Vector( 50, -122, -24 )
            },
        } )

        self:CreateWeapon( "missile_launcher", {
            AmmoType = "barrage",
            MaxAmmo = 6,
            FireDelay = 0.15,
            ReloadDelay = 6.0,
            MissileModel = "models/props_phx/amraam.mdl",
            MissileModelScale = 0.5,
            ProjectileOffsets = {
                Vector( 50, 160, -19 ),
                Vector( 50, -160, -19 ),
                Vector( 50, 197, -15 ),
                Vector( 50, -197, -15 ),
                Vector( 50, 235, -12 ),
                Vector( 50, -235, -12 )
            },
        } )

        local wheelParams = {
            suspensionLength = 38,
            springStrength = 1500,
            springDamper = 6000,
            brakePower = 2000,
            sideTractionMultiplier = 250
        }

        -- Front
        wheelParams.steerMultiplier = 1
        self:CreateWheel( Vector( 180, -12, -25 ), wheelParams )

        -- Rear
        wheelParams.steerMultiplier = 0
        self:CreateWheel( Vector( -13, 85, -25 ), wheelParams ) -- left
        self:CreateWheel( Vector( -13, -85, -25 ), wheelParams ) -- right

        self:ChangeWheelRadius( 12 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end

    function ENT:OnWeaponFire( _weapon, slotIndex )
        -- The explosive cannon is firing, set this entity
        -- variable to `true` (to play a custom sound clientside)
        if slotIndex == 1 then
            self:SetFiringGun( true )
        end

        -- Then let the VSWEP handle the fire logic
        return true
    end

    function ENT:OnWeaponStop()
        self:SetFiringGun( false )
    end
end
