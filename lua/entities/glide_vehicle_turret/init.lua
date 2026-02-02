AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/editor/axis_helper.mdl" )
    self:SetSolid( SOLID_NONE )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:DrawShadow( false )

    self:SetBulletOffset( Vector( 40, 0, 5 ) )
    self:SetMinPitch( -30 )
    self:SetMaxPitch( 30 )
    self:SetMinYaw( -1 )
    self:SetMaxYaw( -1 )

    local body = ents.Create( "prop_dynamic_override" )
    body:SetModel( "models/props_junk/PopCan01a.mdl" )
    body:SetParent( self )
    body:SetLocalPos( Vector() )
    body:SetLocalAngles( Angle() )
    body:Spawn()
    body:DrawShadow( false )

    self:DeleteOnRemove( body )
    self:SetGunBody( body )
    self:SetFireDelay( 0.05 )

    self:SetSingleShotSound( "" )
    self:SetShootLoopSound( "glide/weapons/turret_mg_loop.wav" )
    self:SetShootStopSound( "glide/weapons/turret_mg_end.wav" )
end

function ENT:SetBodyModel( model, offset )
    local body = self:GetGunBody()

    if IsValid( body ) then
        body:SetModel( model )

        if offset then
            body:SetLocalPos( offset )
        end
    end
end

function ENT:UpdateUser( user )
    if user ~= self:GetGunUser() then
        self:SetGunUser( user )
        self:SetIsFiring( false )
    end
end

local lastAimEntity = Glide.lastAimEntity

--- Get the last reported entity that the player thinks they were aiming at.
function ENT:GetLastAimEntity( ply )
    local ent = lastAimEntity[ply]

    -- Only let this happen once
    lastAimEntity[ply] = nil

    return ent
end
