AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_motorcycle"
ENT.PrintName = "Bati 801"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/bati801/chassis.mdl"

DEFINE_BASECLASS( "base_glide_motorcycle" )

-- Override the default first person offset for all seats
function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[3] = localEyePos[3] - 5
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -170, 0, 50 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -40, 2, 22.5 ), scale = 0.8 },
        { pos = Vector( -40, -2, 22.5 ), scale = 0.8 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 15, 0, 0 ), angle = Angle( 40, 0, 0 ), width = 15 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -7, 5, 5 ), angle = Angle( 90, 130, 0 ), scale = 0.4 },
        { offset = Vector( -7, -5, 5 ), angle = Angle( 90, 230, 0 ), scale = 0.4 }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 35, 6, 17.6 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 35, -6, 17.6 ), dir = Vector( 1, 0, 0 ) },
        { type = "brake", offset = Vector( -42, 0, 26 ), dir = Vector( -1, 0, 0 ), size = 35 },
        { type = "taillight", offset = Vector( -42, 0, 26 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "signal_left", offset = Vector( -39, 7.5, 18.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -39, -7.5, 18.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR }
    }

    ENT.Headlights = {
        { offset = Vector( 26, 0, 23 ) }
    }

    ENT.StoppedSound = "glide/engines/shut_down_2.wav"

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "bati801" )
        stream.offset = Vector( 5, 0, 0 )
    end

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.frontBoneId = self:LookupBone( "wheel_front" )
        self.rearBoneId = self:LookupBone( "wheel_rear" )
    end

    local Remap = math.Remap
    local spinAng = Angle()

    function ENT:OnUpdateAnimations()
        -- Call the base class' `OnUpdateAnimations`
        -- to automatically update the steering pose parameter.
        BaseClass.OnUpdateAnimations( self )

        -- Manually update the suspension pose parameters
        self:SetPoseParameter( "suspension_front", Remap( self:GetWheelOffset( 1 ), -9, 0, 0, 1.3 ) )
        self:SetPoseParameter( "suspension_rear", Remap( self:GetWheelOffset( 2 ), -9, 0, 0, 1 ) )
        self:InvalidateBoneCache()

        if not self.frontBoneId then return end

        -- The wheels are part of the model, so we have to
        -- rotate their bones to match the actual wheels.
        spinAng[3] = self:GetWheelSpin( 1 )
        self:ManipulateBoneAngles( self.frontBoneId, spinAng, false )

        spinAng[3] = self:GetWheelSpin( 2 )
        self:ManipulateBoneAngles( self.rearBoneId, spinAng, false )
    end

    local DRIVER_POSE_DATA = {
        ["ValveBiped.Bip01_Spine"] = Angle( 0, 39.5, 0 ),
        ["ValveBiped.Bip01_Spine1"] = Angle( 0, -6.3, 0 ),
        ["ValveBiped.Bip01_Spine2"] = Angle( 0, -24.2, 0 ),

        ["ValveBiped.Bip01_L_UpperArm"] = Angle( -5.822, -15.59, -15.847 ),
        ["ValveBiped.Bip01_L_Forearm"] = Angle( -6.449, 24.56, -29.062 ),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle( 6.756, -6.378, 10.512 ),
        ["ValveBiped.Bip01_R_Forearm"] = Angle( 9.23, 13.152, 58.283 ),

        ["ValveBiped.Bip01_L_Thigh"] = Angle( -5, -7, 0 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( -20, 70, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( 5, -7, 0 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( 20, 70, 0 )
    }

    local FrameTime = FrameTime
    local ExpDecayAngle = Glide.ExpDecayAngle

    function ENT:GetSeatBoneManipulations( seatIndex )
        if seatIndex > 1 then
            return BaseClass.GetSeatBoneManipulations( self, seatIndex )
        end

        local dt = FrameTime()
        local resting = self:GetVelocity():Length() < 50

        local thigh = DRIVER_POSE_DATA["ValveBiped.Bip01_L_Thigh"]
        local calf = DRIVER_POSE_DATA["ValveBiped.Bip01_L_Calf"]

        thigh[1] = ExpDecayAngle( thigh[1], resting and -30 or -5, 5, dt )
        thigh[2] = ExpDecayAngle( thigh[2], resting and 50 or -7, 5, dt )
        thigh[3] = ExpDecayAngle( thigh[3], resting and -5 or 0, 5, dt )

        calf[1] = ExpDecayAngle( calf[1], resting and 5 or -20, 5, dt )
        calf[2] = ExpDecayAngle( calf[2], resting and -40 or 70, 5, dt )

        return DRIVER_POSE_DATA
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )
    ENT.StartupTime = 0.4
    ENT.BurnoutForce = 50
    ENT.TiltForce = 650

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 7, subModelId = 1 },
        { type = "brake_or_taillight", bodyGroupId = 10, subModelId = 1 }
    }

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, -12 ) )
    end

    function ENT:CreateFeatures()
        self:SetHeadlightColor( Vector( 1, 1, 1 ) )

        self:SetSteerConeMaxAngle( 0.25 )
        self:SetForwardTractionMax( 2400 )
        self:SetSideTractionMax( 2700 )

        self:SetSuspensionLength( 8 )
        self:SetSpringStrength( 700 )
        self:SetSpringDamper( 3500 )

        self:SetTransmissionEfficiency( 0.7 )
        self:SetDifferentialRatio( 0.6 )
        self:SetBrakePower( 2000 )

        self:SetMaxRPM( 7000 )
        self:SetMinRPMTorque( 1500 )
        self:SetMaxRPMTorque( 2100 )

        self:CreateSeat( Vector( -24, 0, 19 ), Angle( 0, 270, -35 ), Vector( 0, 60, 0 ), true )
        self:CreateSeat( Vector( -33, 0, 20 ), Angle( 0, 270, -5 ), Vector( 0, -60, 0 ), true )

        self:CreateWheel( Vector( 34, 0, 2.5 ), { steerMultiplier = 1 } ) -- Front
        self:CreateWheel( Vector( -32, 0, 2.5 ) ) -- Rear

        -- Since the model already has a visual representation
        -- for the wheels, hide the actual wheels.
        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

        self:ChangeWheelRadius( 14 )
    end
end
