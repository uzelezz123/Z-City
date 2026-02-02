AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_boat"
ENT.PrintName = "Seashark"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/seashark/chassis.mdl"
ENT.CanSwitchHeadlights = false

function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[3] = localEyePos[3] + 5
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -220, 0, 70 )
    ENT.WaterParticlesScale = 0.7

    ENT.PropellerPositions = {
        Vector( -75, 0, -15 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -48, 0, 10 ), angle = Angle( -40, 0, 0 ), scale = 0.8 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -40, 0, 10 ), angle = Angle( 0, 180, 0 ), width = 10 }
    }

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "seashark" )
    end

    local SEAT_1_POSE = {
        ["ValveBiped.Bip01_L_UpperArm"] = Angle( -10, 5, 0 ),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle( 10, 8, -5 ),
        ["ValveBiped.Bip01_L_Thigh"] = Angle( -15, -5, 0 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( -25, 40, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( 15, -5, 0 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( 25, 40, 0 )
    }

    local SEAT_2_POSE = {
        ["ValveBiped.Bip01_L_Thigh"] = Angle( -15, 10, 0 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( -15, 10, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( 15, 10, 0 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( 15, 10, 0 )
    }

    function ENT:GetSeatBoneManipulations( seatIndex )
        return seatIndex > 1 and SEAT_2_POSE or SEAT_1_POSE
    end
end

if SERVER then
    ENT.ChassisMass = 700
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )
    ENT.FallOnCollision = true
    ENT.FallWhileUnderWater = false

    ENT.BuoyancyPointsXSpacing = 0.9
    ENT.BuoyancyPointsYSpacing = 0.7

    ENT.BoatParams = {
        waterAngularDrag = Vector( -1.5, -8, -10 ), -- (Roll, pitch, yaw)

        buoyancyDepth = 20,
        turbulanceForce = 40,
        maxSpeed = 1300,

        engineForce = 400,
        engineLiftForce = 900,

        turnForce = 700,
        rollForce = 80
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( -19, 0, 18 ), Angle( 0, 270, -10 ), Vector( 20, 55, 25 ), true )
        self:CreateSeat( Vector( -30, 0, 22 ), Angle( 0, 270, 0 ), Vector( -80, 55, 25 ), true )
    end
end
