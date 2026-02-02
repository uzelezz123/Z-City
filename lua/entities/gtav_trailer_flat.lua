AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_trailer"
ENT.PrintName = "Flat Trailer"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/trailer_flat/chassis.mdl"

if CLIENT then
    ENT.LightSprites = {
        { type = "taillight", offset = Vector( -280, 33, 4.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "taillight", offset = Vector( -280, -33, 4.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -280, 41, 4.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -280, -41, 4.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -280, 12, 4.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -280, -12, 4.5 ), dir = Vector( -1, 0, 0 ) },
        { type = "signal_left", offset = Vector( -280, 50, 4.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -280, -50, 4.5 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
    }
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )
    ENT.ChassisMass = 2000

    ENT.IsHeavyVehicle = true
    ENT.SuspensionHeavySound = "Glide.Suspension.CompressTruck"

    ENT.Sockets = {
        { offset = Vector( 213.5, 0, 5 ), id = "TruckSocket", isReceptacle = false }
    }

    ENT.LightBodygroups = {
        { type = "brake", bodyGroupId = 6, subModelId = 1 },
        { type = "reverse", bodyGroupId = 8, subModelId = 1 },
        { type = "headlight", bodyGroupId = 7, subModelId = 1 }, -- Tail lights
        { type = "signal_left", bodyGroupId = 5, subModelId = 1 },
        { type = "signal_right", bodyGroupId = 4, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        local params = {
            model = "models/gta5/vehicles/trailer_flat/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            useModelSize = true,
            springStrength = 500,
            springDamper = 2500,
        }

        -- Left
        self:CreateWheel( Vector( -156, 46, -18 ), params )
        self:CreateWheel( Vector( -217, 46, -18 ), params )

        -- Right
        params.modelAngle = Angle( 0, 270, 0 )
        self:CreateWheel( Vector( -156, -46, -18 ), params )
        self:CreateWheel( Vector( -217, -46, -18 ), params )
    end
end
