function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local scale = data:GetScale()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    self:Flare( emitter, origin, scale )
    self:Smoke( emitter, origin, scale )

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

local RandomInt = math.random
local RandomFloat = math.Rand

local FLARE1_MATERIAL = "glide/effects/red_flare"
local FLARE2_MATERIAL = "effects/yellowflare"

function EFFECT:Flare( emitter, origin, scale )
    local p = emitter:Add( FLARE1_MATERIAL, origin )

    if p then
        local size = RandomFloat( 10, 100 ) * scale

        p:SetDieTime( 0.03 )
        p:SetStartAlpha( 255 )
        p:SetEndAlpha( 200 )
        p:SetStartSize( size )
        p:SetEndSize( size )
        p:SetRoll( RandomFloat( -1, 1 ) )
        p:SetColor( 255, 100, 100 )
        p:SetLighting( false )
        p:SetCollide( true )
    end

    p = emitter:Add( FLARE2_MATERIAL, origin )

    if p then
        local size = RandomFloat( 15, 30 ) * scale

        p:SetDieTime( 0.03 )
        p:SetStartAlpha( 255 )
        p:SetEndAlpha( 200 )
        p:SetStartSize( size )
        p:SetEndSize( size )
        p:SetRoll( RandomFloat( -1, 1 ) )
        p:SetColor( 255, 255, 255 )
        p:SetLighting( false )
        p:SetCollide( true )
    end
end

local SMOKE_MATERIAL = "particle/smokesprites_000"
local SMOKE_GRAVITY = Vector( 0, 0, 400 )

function EFFECT:Smoke( emitter, origin, scale )
    local p

    for _ = 1, 8 do
        p = emitter:Add( SMOKE_MATERIAL .. RandomInt( 9 ), origin )

        if p then
            p:SetDieTime( RandomFloat( 0.4, 2 ) )
            p:SetStartAlpha( 80 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( RandomFloat( 5, 10 ) * scale )
            p:SetEndSize( RandomFloat( 20, 40 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetAirResistance( 200 )
            p:SetGravity( SMOKE_GRAVITY )
            p:SetVelocity( VectorRand() * RandomFloat( -100, 100 ) * scale )
            p:SetColor( 200, 30, 20 )
            p:SetCollide( true )
        end
    end

    p = emitter:Add( SMOKE_MATERIAL .. RandomInt( 9 ), origin )

    if p then
        p:SetDieTime( RandomFloat( 0.4, 3 ) )
        p:SetStartAlpha( 50 )
        p:SetEndAlpha( 0 )
        p:SetStartSize( 2 * scale )
        p:SetEndSize( RandomFloat( 50, 80 ) * scale )
        p:SetRoll( RandomFloat( -1, 1 ) )

        p:SetAirResistance( 200 )
        p:SetGravity( SMOKE_GRAVITY )
        p:SetVelocity( VectorRand() * RandomFloat( -100, 100 ) * scale )
        p:SetColor( 20, 20, 20 )
        p:SetCollide( true )
    end
end
