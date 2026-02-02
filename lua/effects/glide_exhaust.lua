local RandomInt = math.random
local RandomFloat = math.Rand

local EXHAUST_SMOKE_MAT = "particle/smokesprites_000"
local EXHAUST_SMOKE_GRAVITY = Vector( 0, 0, 0 )

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = -data:GetAngles():Forward()
    local velocity = data:GetStart()
    local scale = data:GetScale()
    local alpha = data:GetColor()
    local power = data:GetMagnitude() / 1000

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    alpha = ( 1 - power ) * alpha
    power = 0.5 + power * 1.5

    for _ = 1, 3 do
        local p = emitter:Add( EXHAUST_SMOKE_MAT .. RandomInt( 9 ), origin )
        if p then
            p:SetDieTime( 0.6 )
            p:SetStartAlpha( alpha )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 3 * scale )
            p:SetEndSize( 6 * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            EXHAUST_SMOKE_GRAVITY[3] = RandomFloat( 10, 60 ) * scale

            p:SetAirResistance( 150 )
            p:SetGravity( EXHAUST_SMOKE_GRAVITY )
            p:SetVelocity( velocity + normal * RandomInt( 10, 70 ) * scale * power )
            p:SetColor( 10, 10, 10 )
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
