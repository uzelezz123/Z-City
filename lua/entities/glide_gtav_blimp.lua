AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Blimp (Atomic)"

ENT.MainRotorOffset = Vector( -65, 74, -84 )
ENT.TailRotorOffset = Vector( -65, -74, -84 )

DEFINE_BASECLASS( "base_glide_heli" )

if CLIENT then
    ENT.CameraOffset = Vector( -2500, 0, 500 )

    ENT.ExhaustPositions = {
        Vector( -60, 72, -80 ),
        Vector( -60, -72, -80 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -60, 72, -80 ), angle = Angle( 270, 0, 0 ) },
        { offset = Vector( -60, -72, -80 ), angle = Angle( 270, 0, 0 ) }
    }

    ENT.StartSound = "gtav/blimp/start.wav"

    function ENT:OnActivateSounds()
        self:CreateLoopingSound( "high", "gtav/blimp/loop_high.wav", 90 )
        self:CreateLoopingSound( "low", "gtav/blimp/loop_low.wav", 90 )
    end

    local Clamp = math.Clamp

    function ENT:OnUpdateSounds()
        local sounds = self.sounds

        for _, snd in pairs( sounds ) do
            if not snd:IsPlaying() then
                snd:PlayEx( 0, 1 )
            end
        end

        local power = self:GetPower()
        local pitch = 10 + Clamp( power, 0, 1.2 ) * 90

        sounds.low:ChangePitch( pitch )
        sounds.low:ChangeVolume( Clamp( power - 0.2, 0, 1.0 ) )

        sounds.high:ChangeVolume( Clamp( power - 0.9, 0, 0.2 ) * 3 )
        sounds.high:ChangePitch( pitch )
    end
end

if SERVER then
    ENT.ChassisMass = 3500
    ENT.ChassisModel = "models/gta5/vehicles/blimp/blimp_body.mdl"

    ENT.MainRotorRadius = 30
    ENT.TailRotorRadius = ENT.MainRotorRadius

    ENT.MainRotorModel = "models/gta5/vehicles/blimp/blimp_rotor_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/blimp/blimp_rotor_fast.mdl"

    ENT.TailRotorModel = ENT.MainRotorModel
    ENT.TailRotorFastModel = ENT.MainRotorFastModel

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/blimp_gib1.mdl",
        "models/gta5/vehicles/gibs/blimp_gib2.mdl",
        "models/gta5/vehicles/gibs/blimp_gib3.mdl",
        "models/gta5/vehicles/gibs/blimp_gib4.mdl",
        "models/gta5/vehicles/gibs/blimp_gib5.mdl"
    }

    ENT.ExplosionEffectFlags = 0

    ENT.AngularDrag = Vector( -50, -50, -70 )

    ENT.HelicopterParams = {
        basePower = 0.9,

        drag = Vector( 0.6, 0.5, 0.7 ),
        maxFowardDrag = 300,
        maxSideDrag = 200,

        pitchForce = 1000,
        yawForce = 2000,
        rollForce = 700,

        pushForwardForce = 350,
        maxSpeed = 1000,

        uprightForce = 2000,
        maxPitch = 8,
        maxRoll = 15
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 74, 11, -100 ), nil, Vector( 80, 80, -100 ), true )
        self:CreateSeat( Vector( 74, -11, -100 ), nil, Vector( 80, -80, -100 ), true )
        self:CreateSeat( Vector( 28, 11, -100 ), nil, Vector( 30, 80, -100 ), true )
        self:CreateSeat( Vector( 28, -11, -100 ), nil, Vector( 30, -80, -100 ), true )
    end

    function ENT:Repair()
        BaseClass.Repair( self )

        -- All rotors on this vehicle spin on the Forward axis, and have Angle(0,0,0) as the base angle.
        for _, rotor in ipairs( self.rotors ) do
            if IsValid( rotor ) then
                rotor:SetSpinAxis( "Forward" )
            end
        end
    end

    function ENT:Explode()
        if self.hasExploded then return end

        BaseClass.Explode( self )

        local pos = self:GetPos()
        local driver = self:GetDriver()

        util.BlastDamage( self, IsValid( driver ) and driver or self, pos, 800, 500 )

        local fw = self:GetForward()
        local up = self:GetUp()

        local eff = EffectData()
        eff:SetScale( 1 )
        eff:SetNormal( Vector( 0, 0, 1 ) )
        eff:SetFlags( self.ExplosionEffectFlags )

        eff:SetOrigin( pos + ( fw  * 200 ) + ( up * 200 ) )
        util.Effect( "glide_gtav_blimp_explosion", eff )

        eff:SetOrigin( pos - ( fw  * 600 ) + ( up * 200 ) )
        util.Effect( "glide_gtav_blimp_explosion", eff )

        eff:SetOrigin( pos + ( fw  * 700 ) + ( up * 200 ) )
        util.Effect( "glide_gtav_blimp_explosion", eff )
    end

    function ENT:OnDriverExit()
        self:TurnOff()
    end

    function ENT:RotorStartSpinningFast( _rotor )
        -- Do nothing
    end
end
