AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_skylift"
ENT.PrintName = "Skylift (No magnet)"

if SERVER then
    ENT.ChassisModel = "models/gta5/vehicles/skylift/skylift2_body.mdl"
    ENT.HasMagnet = false
end
