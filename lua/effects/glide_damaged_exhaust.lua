local Clamp = math.Clamp
local RandomInt = math.random
local RandomFloat = math.Rand

local EXHAUST_SMOKE_MAT = "particle/smokesprites_000"
local EXHAUST_SMOKE_GRAVITY = Vector( -50, 0, 0 )

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = data:GetNormal()
    local health = data:GetColor() / 255
    local power = data:GetMagnitude() / 1000
    local velocity = data:GetStart()
    local scale = data:GetScale()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    local color = 200 * Clamp( health * 2, 0, 1 )
    local alpha = 150 * Clamp( 1 - health, 0, 1 )
    local gravity = 1 - power * 3

    for _ = 1, 3 do
        local p = emitter:Add( EXHAUST_SMOKE_MAT .. RandomInt( 9 ), origin )
        if p then
            p:SetDieTime( 0.8 )
            p:SetStartAlpha( alpha )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 10 * scale )
            p:SetEndSize( 20 * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            EXHAUST_SMOKE_GRAVITY[3] = RandomFloat( 80, 180 ) * gravity * scale

            p:SetAirResistance( 200 )
            p:SetGravity( EXHAUST_SMOKE_GRAVITY )
            p:SetVelocity( velocity + normal * RandomInt( 0, 200 ) * scale )
            p:SetColor( color, color, color )
            p:SetCollide( true )
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
