AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_swift"
ENT.PrintName = "Swift Deluxe"

if SERVER then
    ENT.ChassisMass = 700
    ENT.ChassisModel = "models/gta5/vehicles/swiftdeluxe/swiftdeluxe_body.mdl"
end
