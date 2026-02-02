local RandomFloat = math.Rand
local FindWaterSurfaceAbove = Glide.FindWaterSurfaceAbove

local gravity = Vector( 0, 0, 0 )
local startVel = Vector( 0, 0, 0 )

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local velocity = data:GetStart()
    local normal = data:GetNormal()
    local scale = data:GetScale()
    local power = data:GetMagnitude()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    -- Try to find a water surface above the origin
    local surfacePos, fraction = FindWaterSurfaceAbove( origin )

    if surfacePos then
        -- Move the origin point alongside the normal depending on how deep the propeller is
        origin = surfacePos + normal * ( 1 - fraction ) * 80 * scale
    end

    local p

    for _ = 1, 3 do
        p = emitter:Add( "effects/splash4", origin )

        if p then
            p:SetDieTime( 0.5 )
            p:SetStartAlpha( 100 * power )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 8 * scale )
            p:SetEndSize( 35 * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            startVel[3] = RandomFloat( 300, 500 ) * scale * power
            gravity[3] = RandomFloat( 800, 1200 ) * -scale

            p:SetAirResistance( 200 )
            p:SetGravity( gravity )
            p:SetVelocity( velocity + startVel + normal * RandomFloat( 150, 350 ) * scale )
            p:SetColor( 255, 255, 255 )
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
