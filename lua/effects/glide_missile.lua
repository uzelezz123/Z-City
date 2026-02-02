local RandomFloat = math.Rand

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = data:GetScale()
    local spinSpeed = data:GetColor() / 10

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    self:Rocket( emitter, origin, normal, scale )
    self:Smoke( emitter, origin, normal, scale, spinSpeed )

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

local RandomInt = math.random

local FLAME_MATERIAL = "glide/effects/flamelet"
local SMOKE_MATERIAL = "particle/smokesprites_000"

function EFFECT:Rocket( emitter, origin, normal, scale )
    local p = emitter:Add( FLAME_MATERIAL .. RandomInt( 1, 5 ), origin + normal * 16 )

    if p then
        local size = RandomFloat( 8, 10 ) * scale

        p:SetDieTime( 0.03 )
        p:SetStartAlpha( 255 )
        p:SetEndAlpha( 200 )
        p:SetStartSize( size )
        p:SetEndSize( size )
        p:SetRoll( RandomFloat( -1, 1 ) )
        p:SetColor( 255, 255, 255 )
        p:SetLighting( false )
    end

    for i = 1, 5 do
        p = emitter:Add( SMOKE_MATERIAL .. RandomInt( 1, 5 ), origin + normal * i * 16 )

        if p then
            p:SetDieTime( 0.05 )
            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 100 )
            p:SetStartSize( RandomFloat( 4, 7 ) * scale )
            p:SetEndSize( RandomFloat( 8, 15 ) * scale )

            p:SetAirResistance( 100 )
            p:SetVelocity( normal * RandomFloat( 300, 400 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )
            p:SetColor( 255, 150, 70 )
            p:SetLighting( false )
        end
    end
end

local Sin = math.sin
local Cos = math.cos
local CurTime = CurTime

local WORLD_UP = Vector( 0, 0, 1 )

function EFFECT:Smoke( emitter, origin, normal, scale, spinSpeed )
    origin = origin + normal * 60

    local right = normal:Cross( WORLD_UP )
    local up = right:Cross( normal )
    local t = CurTime() * spinSpeed

    local velDir = normal + ( right * Cos( t ) * 0.15 ) + ( up * Sin( t ) * 0.15 )
    velDir:Normalize()

    for i = 1, 10 do
        local p = emitter:Add( SMOKE_MATERIAL .. RandomInt( 9 ), origin + normal * i * 16 )

        if p then
            p:SetDieTime( RandomFloat( 0.5, 1.0 ) )
            p:SetStartAlpha( 80 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( RandomFloat( 4, 10 ) * scale )
            p:SetEndSize( RandomFloat( 30, 60 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetAirResistance( 100 )
            p:SetVelocity( velDir * RandomFloat( 400, 600 ) * scale )
            p:SetColor( 40, 40, 40 )
        end
    end
end
