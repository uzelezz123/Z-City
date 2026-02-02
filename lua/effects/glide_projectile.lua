local FrameTime = FrameTime
local RandomVec = VectorRand
local RandomInt = math.random
local RandomFloat = math.Rand
local Max = math.max

local SMOKE_MATERIAL = "particle/smokesprites_000"
local r, g, b = 0, 0, 0

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = data:GetScale()
    local color = data:GetStart()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    r, g, b = color[1], color[2], color[3]

    local step = 1000 * Max( FrameTime(), 0.03 )

    for i = 1, 8 do
        local p = emitter:Add( SMOKE_MATERIAL .. RandomInt( 9 ), origin + normal * i * step )

        if p then
            p:SetDieTime( RandomFloat( 0.5, 1 ) )
            p:SetStartAlpha( 100 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( RandomFloat( 5, 10 ) * scale )
            p:SetEndSize( RandomFloat( 30, 50 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )
            p:SetRollDelta( RandomFloat( -4, 4 ) )

            p:SetAirResistance( 100 )
            p:SetVelocity( RandomVec() * RandomFloat( -100, 100 ) * scale )
            p:SetColor( r, g, b )
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
