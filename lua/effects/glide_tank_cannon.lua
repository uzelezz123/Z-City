function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = data:GetScale()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    self:Explosion( emitter, origin, normal, scale )
    self:Smoke( emitter, origin, normal, scale )

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

local FLAME_MATERIAL = "glide/effects/flamelet"

local RandomInt = math.random
local RandomFloat = math.Rand
local RandomAng = AngleRand

function EFFECT:Explosion( emitter, origin, normal, scale )
    local p

    for _ = 0, 3 do
        p = emitter:Add( FLAME_MATERIAL .. RandomInt( 5 ), origin )

        if p then
            p:SetGravity( normal * RandomInt( 1800, 2200 ) )
            p:SetAngleVelocity( RandomAng() * 0.02 )
            p:SetAirResistance( 600 )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 100 )
            p:SetStartSize( 20 * scale )
            p:SetEndSize( 50 * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 255, 255, 255 )
            p:SetLighting( false )
            p:SetDieTime( 0.05 )
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

local UP = Vector( 0, 0, 1 )
local GRAVITY = Vector( 0, 0, 200 )

function EFFECT:Smoke( emitter, origin, normal, scale )
    local p
    local right = normal:Cross( UP )

    for _ = 0, 10 do
        p = emitter:Add( SMOKE_SPRITES[RandomInt( 1, #SMOKE_SPRITES )], origin )

        if p then
            local size = RandomFloat( 30, 50 ) * scale
            local vel = ( right * RandomInt( -700, 700 ) ) + normal * 200

            p:SetGravity( GRAVITY )
            p:SetVelocity( vel * scale )
            p:SetAngleVelocity( RandomAng() * 0.02 )
            p:SetAirResistance( 300 )

            p:SetStartAlpha( 100 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( size )
            p:SetEndSize( size * RandomFloat( 1.5, 2 ) )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 70, 70, 70 )
            p:SetDieTime( RandomFloat( 0.75, 2 ) * scale )
            p:SetCollide( true )
        end
    end
end
