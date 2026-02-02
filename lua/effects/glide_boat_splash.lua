local RandomFloat = math.Rand
local FindWaterSurfaceAbove = Glide.FindWaterSurfaceAbove

local gravity = Vector( 0, 0, 0 )
local startVel = Vector( 0, 0, 0 )
local WORLD_UP = Vector( 0, 0, 1 )

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local velocity = data:GetStart() * 0.75
    local normal = data:GetNormal()
    local scale = data:GetScale()
    local magnitude = data:GetMagnitude()
    local length = data:GetRadius()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    -- Try to find a water surface above the origin
    origin = FindWaterSurfaceAbove( origin ) or origin

    local right = WORLD_UP:Cross( normal )
    local p

    for _ = 1, 8 do
        p = emitter:Add( "effects/splash4", origin + right * RandomFloat( -length, length ) )

        if p then
            p:SetDieTime( 0.3 )
            p:SetStartAlpha( 100 * magnitude )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 5 * scale )
            p:SetEndSize( 35 * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            startVel[3] = RandomFloat( 100, 300 ) * scale * magnitude
            gravity[3] = RandomFloat( 800, 1200 ) * -scale

            p:SetAirResistance( 200 )
            p:SetGravity( gravity )
            p:SetVelocity( velocity + startVel + normal * RandomFloat( 150, 350 ) * scale * magnitude )
            p:SetColor( 200, 200, 200 )
            p:SetCollide( false )
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
