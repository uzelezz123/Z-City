function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = data:GetScale()
    local isXero = data:GetFlags() == 1

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    self:Explosion( emitter, origin, normal, scale )
    self:Smoke( emitter, origin, normal, scale )
    self:Debris( emitter, origin, normal, scale, isXero )

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

local FLAME_MATERIAL = "glide/effects/flamelet"

local RandomInt = math.random
local RandomFloat = math.Rand

local AngleRand = AngleRand
local VectorRand = VectorRand

function EFFECT:Explosion( emitter, origin, normal, scale )
    for _ = 0, 10 do
        local p = emitter:Add( FLAME_MATERIAL .. RandomInt( 5 ), origin + VectorRand() * RandomInt( 100, 400 ) )

        if p then
            p:SetGravity( normal * RandomInt( 1800, 2200 ) )
            p:SetVelocity( VectorRand() * RandomInt( 1300, 1500 ) * scale )
            p:SetAngleVelocity( AngleRand() * 0.02 )
            p:SetAirResistance( 600 )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( RandomInt( 80, 120 ) * scale )
            p:SetEndSize( RandomInt( 140, 180 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            local col = RandomFloat( 0.5, 1 )

            p:SetColor( 255, 255 * col, 255 * col )
            p:SetLighting( false )
            p:SetDieTime( 0.4 )
        end
    end
end

local SMOKE_SPRITES = {
    "particle/smokesprites_0001",
    "particle/smokesprites_0002",
    "particle/smokesprites_0003",
    "particle/smokesprites_0004",
    "particle/smokesprites_0005",
    "particle/smokesprites_0006",
    "particle/smokesprites_0007",
    "particle/smokesprites_0008",
    "particle/smokesprites_0009",
    "particle/smokesprites_0010",
    "particle/smokesprites_0011",
    "particle/smokesprites_0012",
    "particle/smokesprites_0013",
    "particle/smokesprites_0014",
    "particle/smokesprites_0015",
    "particle/smokesprites_0016"
}

local Vector = Vector

function EFFECT:Smoke( emitter, origin, normal, scale )
    for _ = 0, 5 do
        local p = emitter:Add( SMOKE_SPRITES[RandomInt( 1, #SMOKE_SPRITES )], origin + VectorRand() * RandomInt( 0, 400 )  )

        if p then
            local size = RandomFloat( 400, 520 ) * scale
            local vel = ( normal * RandomInt( 1300, 1500 ) ) + VectorRand() * 1000

            p:SetGravity( Vector( 0, 0, 400 ) )
            p:SetVelocity( vel * scale )
            p:SetAngleVelocity( AngleRand() * 0.01 )
            p:SetAirResistance( 400 )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( size )
            p:SetEndSize( size * 1.5 )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 30, 30, 30 )
            p:SetDieTime( RandomFloat( 0.75, 1.5 ) * scale )
        end
    end
end

local DEBRIS_MATERIAL = "effects/fleck_tile"

local ATOMIC_COLORS = {
    { 255, 255, 255 },
    { 250, 250, 50 },
    { 50, 50, 255 }
}

local XERO_COLORS = {
    { 255, 255, 255 },
    { 250, 50, 50 },
    { 50, 122, 255 }
}

function EFFECT:Debris( emitter, origin, normal, scale, isXero )
    local colors = isXero and XERO_COLORS or ATOMIC_COLORS

    for _ = 0, 30 do
        local p = emitter:Add( DEBRIS_MATERIAL .. RandomInt( 2 ), origin + VectorRand() * RandomInt( 200, 400 ) )

        if p then
            local vel = ( normal * RandomInt( 300, 500 ) ) + VectorRand() * 800

            p:SetGravity( Vector( 0, 0, -500 ) )
            p:SetVelocity( vel * scale )
            p:SetAngleVelocity( AngleRand() * 0.05 )
            p:SetAirResistance( 50 )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 8 * scale )
            p:SetEndSize( 8 * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetDieTime( RandomFloat( 3, 5 ) )
            p:SetCollide( true )
            p:SetBounce( 0.3 )

            local color = colors[RandomInt( #colors )]
            p:SetColor( color[1], color[2], color[3] )
        end
    end
end
