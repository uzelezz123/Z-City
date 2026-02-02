local CurTime = CurTime
local Clamp = math.Clamp
local RandomFloat = math.Rand

local FLASH_MATERIAL = "glide/effects/afterburner_flash"

function EFFECT:Init( data )
    self.parent = data:GetEntity()
    self.lifetime = CurTime() + 0.1

    if not IsValid( self.parent ) then return end

    local origin = data:GetOrigin()
    local scale = data:GetScale()
    local angles = data:GetAngles()

    self.offset = self.parent:WorldToLocal( origin )
    self.angles = self.parent:WorldToLocalAngles( angles )

    self:SetRenderMode( RENDERMODE_WORLDGLOW )
    self:SetModel( "models/glide/effects/afterburner_flame.mdl" )
    self:SetModelScale( scale * Clamp( data:GetMagnitude(), 0, 1 ) * RandomFloat( 0.9, 1.1 ) )

    origin = origin - angles:Forward() * data:GetRadius()

    local emitter = ParticleEmitter( origin, false )
    local p = emitter:Add( FLASH_MATERIAL, origin )

    if p then
        local size = RandomFloat( 15, 20 ) * scale

        p:SetDieTime( 0.05 )
        p:SetStartAlpha( 230 )
        p:SetEndAlpha( 50 )
        p:SetStartSize( size )
        p:SetEndSize( size * 0.8 )
        p:SetRoll( RandomFloat( -1, 1 ) )
        p:SetVelocity( self.parent:GetVelocity() )
        p:SetColor( 255, 255, 255 )
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
