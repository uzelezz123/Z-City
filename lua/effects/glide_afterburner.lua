local CurTime = CurTime
local Clamp = math.Clamp
local RandomFloat = math.Rand

local FLARE_MATERIAL = "effects/yellowflare"
local DEFAULT_COLOR = Color( 255, 150, 63 )

function EFFECT:Init( data )
    self.parent = data:GetEntity()
    self.lifetime = CurTime() + 0.15

    if not IsValid( self.parent ) then return end

    local origin = data:GetOrigin()
    local angles = data:GetAngles()

    self.offset = self.parent:WorldToLocal( origin )
    self.angles = self.parent:WorldToLocalAngles( angles )
    self.scale = data:GetScale() * RandomFloat( 0.9, 1.1 )

    DEFAULT_COLOR.a = 255 * Clamp( data:GetMagnitude(), 0, 1 )

    self:SetRenderMode( RENDERMODE_WORLDGLOW )
    self:SetColor( DEFAULT_COLOR )
    self:SetModel( "models/glide/effects/afterburner_base.mdl" )
    self:SetModelScale( self.scale )

    local emitter = ParticleEmitter( origin, false )
    local p = emitter:Add( FLARE_MATERIAL, origin )

    if p then
        local size = RandomFloat( 8, 10 ) * self.scale

        p:SetDieTime( 0.05 )
        p:SetStartAlpha( DEFAULT_COLOR.a )
        p:SetEndAlpha( DEFAULT_COLOR.a * 0.5 )
        p:SetStartSize( size )
        p:SetEndSize( size )
        p:SetRoll( RandomFloat( -1, 1 ) )
        p:SetVelocity( self.parent:GetVelocity() )
        p:SetColor( DEFAULT_COLOR.r, DEFAULT_COLOR.g, DEFAULT_COLOR.b )
        p:SetLighting( false )
    end

    emitter:Finish()
end

function EFFECT:Think()
    return IsValid( self.parent ) and CurTime() < self.lifetime
end

function EFFECT:Render()
    local origin = self.parent:LocalToWorld( self.offset )
    local angles = self.parent:LocalToWorldAngles( self.angles )

    self:SetPos( origin )
    self:SetAngles( angles )
    self:DrawModel()
end
