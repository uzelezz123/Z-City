AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_blimp"
ENT.PrintName = "Blimp (Xero)"

if SERVER then
    ENT.ChassisMass = 3500
    ENT.ChassisModel = "models/gta5/vehicles/blimp/blimp_body.mdl"

    ENT.ExplosionEffectFlags = 1

    function ENT:CreateFeatures()
        self:SetSubMaterial( 5, "models/gta5/vehicles/blimp2" )

        self:CreateSeat( Vector( 74, 11, -100 ), nil, Vector( 80, 80, -100 ), true )
        self:CreateSeat( Vector( 74, -11, -100 ), nil, Vector( 80, -80, -100 ), true )
        self:CreateSeat( Vector( 28, 11, -100 ), nil, Vector( 30, 80, -100 ), true )
        self:CreateSeat( Vector( 28, -11, -100 ), nil, Vector( 30, -80, -100 ), true )
    end
end
