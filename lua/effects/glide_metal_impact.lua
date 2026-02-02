local RandomFloat = math.Rand

function EFFECT:Init( data )
    local pos = data:GetOrigin()
    local scale = data:GetScale()
    local normal = data:GetNormal()

    local emitter = ParticleEmitter( pos, false )
    if not IsValid( emitter ) then return end

    local count = math.floor( scale * 20 )

    for _ = 0, count do
        local p = emitter:Add( "effects/spark", pos )

        if p then
            local vel = ( normal * RandomFloat( 10, 150 ) ) + VectorRand() * 30

            p:SetVelocity( vel * scale )
            p:SetDieTime( RandomFloat( 0.4, 0.6 ) )
            p:SetAirResistance( 50 )
            p:SetStartAlpha( 255 )
            p:SetStartSize( 2 * scale )
            p:SetEndSize( 1 )
            p:SetRoll( RandomFloat( -1, 1 ) )
            p:SetColor( 255, 255, 255 )
            p:SetGravity( Vector( 0, 0, -300 ) )
            p:SetCollide( true )
            p:SetBounce( 0.5 )
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
