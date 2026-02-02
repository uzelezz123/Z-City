-- All armed GTAV helicopters have a minigun and (optionally)
-- homing missiles, so let's code that into a single base class.

ENT.Type = "anim"
ENT.Base = "base_glide_heli"

ENT.PrintName = "GTAV Armed Helicopter"
ENT.Author = "StyledStrike"

if CLIENT then
    ENT.MinigunFireLoop = ")glide/weapons/mg_shoot_loop.wav"
    ENT.MinigunSpinLoop = "glide/weapons/minigun_loop.wav"

    ENT.MinigunFireStop = ")glide/weapons/mg_shoot_stop.wav"
    ENT.MinigunSpinStop = "glide/weapons/minigun_end.wav"

    ENT.BulletOffsets = {}
    ENT.BulletAngles = {}
    ENT.MissileOffsets = {}
end

if SERVER then
    ENT.BulletDamageMultiplier = 0.6
end

DEFINE_BASECLASS( "base_glide_heli" )

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Bool", "FiringMinigun" )
end
