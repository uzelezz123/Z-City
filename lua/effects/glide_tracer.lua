local CurTime = CurTime
local DEFAULT_TRACER_COLOR = Color( 255, 160, 35 )

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local endpos = data:GetStart()
    local scale = data:GetScale()
    local ent = data:GetEntity()

    local dir = endpos - origin
    dir:Normalize()

    local velocity = Vector()

    if IsValid( ent ) then
        velocity = ent:GetVelocity()
    end

    local len = origin:Distance( endpos )

    self.lifeTime = CurTime() + 0.3
    self.traceStart = origin - dir * len * 0.08
    self.traceEnd = endpos + dir * len * 0.08
    self.traceWidth = scale * 15
    self.traceColor = DEFAULT_TRACER_COLOR

    if data:GetFlags() == 1 then
        self.hitSize = scale * 50
    end

    if data:GetColor() > 0 then
        self.traceColor = Color(
            data:GetRadius(),
            data:GetHitBox(),
            data:GetMaterialIndex()
        )
    end

    self:SetRenderBoundsWS( origin, endpos )

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    self:Flash( emitter, origin, endpos, scale, velocity )

    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.lifeTime
end

local TRACE_MATERIAL = Material( "effects/laser_tracer" )
local SMOKE_COLOR = Color( 40, 40, 40 )

local SetMaterial = render.SetMaterial
local DrawBeam = render.DrawBeam

function EFFECT:Render()
    local anim = ( self.lifeTime - CurTime() ) / 0.3

    SetMaterial( TRACE_MATERIAL )

    if anim > 0.9 then
        DrawBeam( self.traceStart, self.traceEnd, self.traceWidth, 1, 0, self.traceColor )
    end

    SMOKE_COLOR.a = 255 * anim

    DrawBeam( self.traceStart, self.traceEnd, self.traceWidth * 6, 1, 0, SMOKE_COLOR )
end

local FLAME_MATERIAL = "glide/effects/flamelet"
local HIT_MATERIAL = "sprites/light_glow02_add"

local RandomInt = math.random
local RandomFloat = math.Rand

function EFFECT:Flash( emitter, origin, endpos, scale, velocity )
    if self.hitSize then
        local p = emitter:Add( HIT_MATERIAL, endpos )

        if p then
            p:SetVelocity( VectorRand() )
            p:SetAirResistance( 600 )

            local size = RandomFloat( 0.8, 1.1 ) * self.hitSize

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 255 )
            p:SetStartSize( size )
            p:SetEndSize( size )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 255, 206, 116 )
            p:SetLighting( false )
            p:SetDieTime( 0.03 )
        end
    end

    for _ = 1, 2 do
        p = emitter:Add( FLAME_MATERIAL .. RandomInt( 5 ), origin )

        if p then
            p:SetVelocity( velocity )
            p:SetAirResistance( 600 )

            local size = RandomFloat( 8, 12 ) * scale

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 255 )
            p:SetStartSize( size )
            p:SetEndSize( size )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 255, 255, 255 )
            p:SetLighting( false )
            p:SetDieTime( 0.03 )
        end
    end
end
