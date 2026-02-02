AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Thruster"

ENT.MaxChassisHealth = 900

ENT.MainRotorOffset = Vector( 0, 19, 27 )
ENT.TailRotorOffset = Vector( 0, -19, 27 )

function ENT:GetFirstPersonOffset( _seatIndex, localEyePos )
    localEyePos[3] = localEyePos[3] + 45
    return localEyePos
end

function ENT:GetPlayerSitSequence( _seatIndex )
    return "drive_pd"
end

if CLIENT then
    ENT.CameraOffset = Vector( -180, 0, 50 )

    ENT.StartSound = "gtav/thruster/start.wav"

    ENT.ExhaustPositions = {
        Vector( 0, 19, 5 ),
        Vector( 0, -19, 5 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 0, 19, 5 ), scale = 0.2, angle = Angle( 180, 0, 0 ) },
        { offset = Vector( 0, -19, 5 ), scale = 0.2, angle = Angle( 180, 0, 0 ) }
    }

    local POSE_DATA = {
        ["ValveBiped.Bip01_L_UpperArm"] = Angle( -32.53, -3.756, -0.341 ),
        ["ValveBiped.Bip01_L_Forearm"] = Angle( 20.853, -86.215, -7.163 ),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle( 31.966, 21.344, 9.976 ),
        ["ValveBiped.Bip01_R_Forearm"] = Angle( 3.13, -95.128, 0 ),
        ["ValveBiped.Bip01_L_Thigh"] = Angle( -6.212, -4.972, -0.531 ),
        ["ValveBiped.Bip01_L_Foot"] = Angle( 0, -46.395, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( 7.517, -4.909, -0.644 )
    }

    function ENT:GetSeatBoneManipulations()
        return POSE_DATA
    end

    function ENT:AllowFirstPersonMuffledSound()
        return false
    end

    function ENT:AllowWindSound()
        return true, 0.5
    end

    function ENT:OnTurnOff()
        self:EmitSound( "gtav/thruster/stop.wav", 75, 100, 0.5 )
    end

    function ENT:OnActivateSounds()
        self:CreateLoopingSound( "afterburner", "gtav/thruster/afterburner.wav", 80 )
        self:CreateLoopingSound( "thrust", "glide/aircraft/thrust.wav", 80 )
        self:CreateLoopingSound( "jet", "glide/helicopters/jet_2.wav", 70 )

        self.thrustState = 1
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
        local pitch = 50 + Clamp( power, 0, 1.2 ) * 50

        sounds.afterburner:ChangePitch( pitch )
        sounds.afterburner:ChangeVolume( Clamp( power - 0.9, 0, 0.2 ) * 2 )

        sounds.jet:ChangeVolume( Clamp( power, 0, 1 ) * 0.1 )
        sounds.jet:ChangePitch( 60 + Clamp( power, 0, 1 ) * 40 )

        sounds.thrust:ChangeVolume( Clamp( power - 0.9, 0, 1 ) * 0.6 )
        sounds.thrust:ChangePitch( 100 )

        if power < 1 then
            if self.thrustState ~= 1 then
                self.thrustState = 1
                self:EmitSound( "gtav/thruster/thrust_stop.wav", 75, 100, 0.5 )
            end
        else
            self.thrustState = 0
        end
    end

    local Effect = util.Effect
    local EffectData = EffectData

    --- Override the base class `OnUpdateParticles` function.
    function ENT:OnUpdateParticles()
        local power = self:GetPower()
        local eff

        if power > 0.9 then
            eff = EffectData()
            eff:SetEntity( self )
            eff:SetAngles( self:GetUp():Angle() )
            eff:SetScale( 0.15 )
            eff:SetRadius( 0.5 ) -- This is actually a offset for the flare effect
            eff:SetMagnitude( 1 - Clamp( ( 1.2 - power ) / 0.3, 0, 1 ) )

            for _, pos in ipairs( self.ExhaustPositions ) do
                eff:SetOrigin( self:LocalToWorld( pos ) )
                Effect( "glide_afterburner_flame", eff, true )
            end
        end

        local health = self:GetEngineHealth()
        if health > 0.5 then return end

        local velocity = self:GetVelocity()
        local normal = -self:GetUp()

        health = Clamp( health * 255, 0, 255 )

        for _, pos in ipairs( self.ExhaustPositions ) do
            eff = EffectData()
            eff:SetOrigin( self:LocalToWorld( pos ) )
            eff:SetNormal( normal )
            eff:SetColor( health )
            eff:SetMagnitude( power * 1000 )
            eff:SetStart( velocity )
            eff:SetScale( 0.5 )
            Effect( "glide_damaged_exhaust", eff, true, true )
        end
    end
end

if SERVER then
    ENT.ChassisMass = 200
    ENT.ChassisModel = "models/gta5/vehicles/thruster/thruster_body.mdl"

    ENT.IsHeavyVehicle = false
    ENT.MainRotorRadius = 20

    ENT.MainRotorModel = "models/gta5/vehicles/thruster/thruster_rmain.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/thruster/thruster_rmain.mdl"

    ENT.TailRotorModel = ENT.MainRotorModel
    ENT.TailRotorFastModel = ENT.MainRotorFastModel

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/thruster_gib1.mdl",
        "models/gta5/vehicles/gibs/thruster_gib2.mdl",
        "models/gta5/vehicles/gibs/thruster_gib3.mdl"
    }

    ENT.AngularDrag = Vector( -10, -8, -2 )

    ENT.HelicopterParams = {
        turbulanceForce = 60,
        pushUpForce = 170,
        pitchForce = 500,
        yawForce = 150,
        rollForce = 600,
        pushForwardForce = 250
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 17, 0, -38 ), Angle( 0, 270, -5 ), Vector( 20, 60, 0 ), true )
        self.powerResponse = 0.5
    end

    DEFINE_BASECLASS( "base_glide_heli" )

    function ENT:Repair()
        BaseClass.Repair( self )

        -- All "rotors" on this vehicle spin on the Up axis, and have Angle(0,0,0) as the base angle.
        for _, rotor in ipairs( self.rotors ) do
            if IsValid( rotor ) then
                rotor:SetSpinAxis( "Up" )
                rotor:SetBaseAngles( self.MainRotorAngle )
                rotor.enableTrace = false
                rotor.maxSpinSpeed = 2000
            end
        end
    end

    function ENT:OnDriverExit()
        self:TurnOff()
    end

    function ENT:RotorStartSpinningFast( _rotor )
        -- Do nothing
    end
end
