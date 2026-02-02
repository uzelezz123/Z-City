local IsValid = IsValid
local surfaceFX = {}

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local velocity = data:GetStart()
    local matId = data:GetSurfaceProp()
    local scale = data:GetScale()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    if surfaceFX[matId] then
        self:DoSurface( emitter, origin, velocity, scale, surfaceFX[matId] )
    else
        self:DoSmoke( emitter, origin, velocity, scale, data:GetEntity() )
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

local RandomInt = math.random
local RandomFloat = math.Rand
local Config = Glide.Config

local debrisGravity = Vector( 0, 0, 0 )
local debrisVelocity = Vector( 0, 0, 0 )

function EFFECT:DoSurface( emitter, origin, velocity, scale, fx )
    local p
    local lifetime = fx.lifetime * ( Config.reduceTireParticles and 0.4 or 1 )

    for _ = 1, 5 do
        p = emitter:Add( fx.mat, origin )

        if p then
            p:SetDieTime( lifetime * RandomFloat( 0.8, 1.2 ) )
            p:SetStartAlpha( fx.alpha )
            p:SetEndAlpha( 0 )
            p:SetStartSize( fx.minSize * scale * RandomFloat( 0.9, 1.1 ) )
            p:SetEndSize( fx.maxSize * scale * RandomFloat( 0.8, 1.5 ) )
            p:SetRoll( RandomFloat( -1, 1 ) )

            debrisGravity[3] = fx.gravity or -200

            debrisVelocity[1] = 0
            debrisVelocity[2] = 0
            debrisVelocity[3] = fx.upVelocity * scale
            debrisVelocity:Add( velocity * RandomFloat( 0.2, 0.8 ) )

            p:SetAirResistance( fx.resistance or 50 )
            p:SetGravity( debrisGravity )
            p:SetVelocity( debrisVelocity )
            p:SetLighting( true )
            p:SetCollide( true )
        end
    end
end

local SMOKE_MAT = "glide/effects/tire_particles/tire_slip_forward_"
local SMOKE_GRAVITY = Vector( 0, 0, 60 )
local DEFAULT_COLOR = Vector( 0, 0, 0 )

function EFFECT:DoSmoke( emitter, origin, velocity, scale, vehicle )
    local color = ( IsValid( vehicle ) and vehicle.GetTireSmokeColor ) and vehicle:GetTireSmokeColor() or DEFAULT_COLOR
    local r, g, b = color:Unpack()

    r = r * 255
    g = g * 255
    b = b * 255

    local p
    local count = math.floor( scale )
    local lifetime = Config.reduceTireParticles and 0.4 or 1

    for _ = 1, count do
        p = emitter:Add( SMOKE_MAT .. RandomInt( 4 ), origin )

        if p then
            p:SetDieTime( RandomFloat( 2, 3 ) * lifetime )
            p:SetStartAlpha( 70 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 5 + RandomFloat( 1, 2 ) * scale )
            p:SetEndSize( 50 + RandomFloat( 2, 8 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            p:SetAirResistance( 100 )
            p:SetGravity( SMOKE_GRAVITY * RandomFloat( 0.5, 1 ) )
            p:SetVelocity( velocity * RandomFloat( 0.2, 0.6 ) )
            p:SetColor( r, g, b )
            p:SetLighting( true )
            p:SetCollide( true )
        end
    end
end

surfaceFX[MAT_GRASS] = {
    mat = Material( "glide/effects/tire_particles/grass_debris" ),
    lifetime = 0.8,
    alpha = 255,
    minSize = 3,
    maxSize = 1,
    upVelocity = 15
}

surfaceFX[MAT_FOLIAGE] = surfaceFX[MAT_GRASS]

surfaceFX[MAT_SAND] = {
    mat = Material( "glide/effects/tire_particles/sand" ),
    lifetime = 1.2,
    alpha = 150,
    minSize = 3,
    maxSize = 6,
    gravity = 10,
    upVelocity = 1
}

surfaceFX[MAT_DIRT] = {
    mat = Material( "glide/effects/tire_particles/dirt" ),
    lifetime = 1,
    alpha = 180,
    minSize = 2,
    maxSize = 0.5,
    gravity = -300,
    upVelocity = 18,
    resistance = 200
}

surfaceFX[MAT_SNOW] = {
    mat = Material( "glide/effects/tire_particles/snow" ),
    lifetime = 0.8,
    alpha = 100,
    minSize = 2,
    maxSize = 4,
    gravity = -100,
    upVelocity = 5,
    resistance = 100
}

surfaceFX[MAT_SLOSH] = {
    mat = Material( "glide/effects/tire_particles/water" ),
    lifetime = 0.3,
    alpha = 100,
    minSize = 1,
    maxSize = 4,
    gravity = -600,
    upVelocity = 20,
    resistance = 30
}
