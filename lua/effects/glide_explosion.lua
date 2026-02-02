local CurTime = CurTime

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = data:GetScale()

    self.size = 1200 * scale
    self.origin = origin
    self.lifeTime = CurTime() + 0.05

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    self:Explosion( emitter, origin, normal, scale )
    self:Smoke( emitter, origin, normal, scale )
    self:Debris( emitter, origin, normal, scale )

    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.lifeTime
end

local GLOW_MAT = Material( "sprites/light_glow02_add" )

function EFFECT:Render()
    render.SetMaterial( GLOW_MAT )
    render.DrawSprite( self.origin, self.size, self.size, Color( 255, 200, 150, 255 ) )
end

local FLAME_MATERIAL = "glide/effects/flamelet"

local RandomInt = math.random
local RandomFloat = math.Rand
local RandomVec = VectorRand
local RandomAng = AngleRand

function EFFECT:Explosion( emitter, origin, normal, scale )
    local count = math.floor( scale * 40 )
    local p, col

    for _ = 0, count do
        p = emitter:Add( FLAME_MATERIAL .. RandomInt( 5 ), origin )

        if p then
            p:SetGravity( normal * RandomInt( 1800, 2200 ) )
            p:SetVelocity( RandomVec() * RandomInt( 1300, 1500 ) * scale )
            p:SetAngleVelocity( RandomAng() * 0.02 )
            p:SetAirResistance( 600 )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( RandomInt( 20, 30 ) * scale )
            p:SetEndSize( RandomInt( 70, 120 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            col = RandomFloat( 0.7, 1 )

            p:SetColor( 255, 255 * col, 255 * col )
            p:SetLighting( false )
            p:SetDieTime( 0.4 )
            p:SetCollide( true )
        end
    end

    for _ = 0, 10 do
        p = emitter:Add( FLAME_MATERIAL .. RandomInt( 1, 5 ), origin )

        if p then
            p:SetVelocity( RandomVec() * RandomInt( 0, 1500 ) * scale )
            p:SetAngleVelocity( RandomAng() * 0.02 )
            p:SetAirResistance( 300 )

            p:SetStartAlpha( 200 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 80 * scale )
            p:SetEndSize( RandomInt( 140, 180 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 255, 255, 200 )
            p:SetDieTime( 0.2 )
            p:SetCollide( true )
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

local GRAVITY = Vector( 0, 0, 400 )
local GRAVITY2 = Vector( 0, 0, 200 )

function EFFECT:Smoke( emitter, origin, normal, scale )
    local count = math.floor( scale * 20 )
    local p

    for _ = 0, count do
        p = emitter:Add( SMOKE_SPRITES[RandomInt( 1, #SMOKE_SPRITES )], origin )

        if p then
            local size = RandomFloat( 100, 120 ) * scale
            local vel = ( normal * RandomInt( 1300, 1500 ) ) + RandomVec() * 1000

            p:SetGravity( GRAVITY )
            p:SetVelocity( vel * scale )
            p:SetAngleVelocity( RandomAng() * 0.02 )
            p:SetAirResistance( 400 )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( size )
            p:SetEndSize( size * RandomFloat( 1.5, 2 ) )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 30, 30, 30 )
            p:SetDieTime( RandomFloat( 0.75, 2 ) * scale )
        end
    end

    count = math.floor( scale * 40 )

    for _ = 0, count do
        p = emitter:Add( SMOKE_SPRITES[RandomInt( 1, #SMOKE_SPRITES )], origin )

        if p then
            local size = RandomFloat( 100, 120 ) * scale

            p:SetGravity( GRAVITY2 )
            p:SetVelocity( RandomVec() * RandomInt( 800, 1500 ) * scale )
            p:SetAngleVelocity( RandomAng() * 0.02 )
            p:SetAirResistance( 350 )

            p:SetStartAlpha( 200 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( size * 0.5 )
            p:SetEndSize( size * 1.5 )
            p:SetRoll( RandomFloat( -0.5, 0.5 ) )

            p:SetColor( 40, 40, 40 )
            p:SetDieTime( RandomFloat( 3, 4 ) * scale )
        end
    end
end

local DEBRIS_MATERIAL = "effects/fleck_tile"
local DECAL_MATERIAL = Material( util.DecalMaterial( "Scorch" ) )

function EFFECT:Debris( emitter, origin, normal, scale )
    if scale > 0.5 then
        local tr = util.TraceLine( {
            start = origin + normal * 100,
            endpos = origin - normal * 100,
            mask = 16395 -- MASK_SOLID_BRUSHONLY
        } )

        if tr and tr.Hit and not tr.HitNonWorld then
            util.DecalEx( DECAL_MATERIAL, tr.Entity, tr.HitPos + tr.HitNormal, tr.HitNormal,
                color_white, RandomFloat( 1, 2 ) * scale, RandomFloat( 1, 2 ) * scale )
        end
    end

    local count = math.floor( scale * 20 )

    for _ = 0, count do
        local p = emitter:Add( DEBRIS_MATERIAL .. RandomInt( 2 ), origin )

        if p then
            local vel = ( normal * RandomInt( 300, 500 ) ) + RandomVec() * 500

            p:SetGravity( Vector( 0, 0, -500 ) )
            p:SetVelocity( vel * scale )
            p:SetAngleVelocity( RandomAng() * 0.02 )
            p:SetAirResistance( 50 )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 3 * scale )
            p:SetEndSize( 3 * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetColor( 0, 0, 0 )
            p:SetDieTime( RandomFloat( 3, 5 ) )
            p:SetCollide( true )
            p:SetBounce( 0.3 )
        end
    end
end
