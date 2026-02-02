local RandomInt = math.random
local RandomFloat = math.Rand

local FLAME_MAT = "glide/effects/flamelet"
local SMOKE_MAT = "particle/smokesprites_000"
local SMOKE_GRAVITY = Vector( 0, 0, 200 )
local FLAME_GRAVITY = Vector( 0, 0, 80 )

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local velocity = data:GetStart() * 0.8
    local scale = data:GetScale()
    local normal = data:GetAngles():Up()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    local p = emitter:Add( SMOKE_MAT .. RandomInt( 9 ), origin )

    if p then
        p:SetDieTime( 1 )
        p:SetStartAlpha( 100 )
        p:SetEndAlpha( 0 )
        p:SetStartSize( 10 * scale )
        p:SetEndSize( RandomFloat( 60, 80 ) * scale )
        p:SetRoll( RandomFloat( -1, 1 ) )

        p:SetAirResistance( 60 )
        p:SetGravity( SMOKE_GRAVITY + velocity )
        p:SetVelocity( velocity + normal * RandomInt( 20, 50 ) * scale )
        p:SetColor( 20, 20, 20 )
        p:SetCollide( true )
    end

    p = emitter:Add( "particles/fire1", origin + normal * scale * 5 )

    if p then
        p:SetDieTime( RandomFloat( 0.4, 0.6 ) )
        p:SetStartAlpha( 255 )
        p:SetEndAlpha( 255 )
        p:SetStartSize( RandomFloat( 15, 20 ) * scale )
        p:SetEndSize( RandomFloat( 1, 6 ) * scale )
        p:SetRoll( RandomFloat( -100, 100 ) )

        p:SetAirResistance( 5 )
        p:SetGravity( FLAME_GRAVITY + velocity )
        p:SetVelocity( velocity + normal * RandomInt( 50, 70 ) * scale )
        p:SetColor( 255, 255, 255 )
        p:SetCollide( true )
    end

    for _ = 0, 3 do
        p = emitter:Add( FLAME_MAT .. RandomInt( 5 ), origin + VectorRand() * 5 )

        if p then
            p:SetDieTime( RandomFloat( 0.3, 0.5 ) )
            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 255 )
            p:SetStartSize( RandomFloat( 10, 15 ) * scale )
            p:SetEndSize( RandomFloat( 1, 6 ) * scale )
            p:SetRoll( RandomFloat( -100, 100 ) )

            p:SetAirResistance( 5 )
            p:SetGravity( FLAME_GRAVITY + velocity )
            p:SetVelocity( velocity + normal * RandomInt( 35, 45 ) * scale )
            p:SetColor( 255, 255, 255 )
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
