local IsValid = IsValid
local surfaceFX = {}

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local matId = data:GetSurfaceProp()
    local scale = data:GetScale()
    local normal = data:GetNormal()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    if surfaceFX[matId] then
        self:DoSurface( emitter, origin, scale, normal, surfaceFX[matId] )
    else
        self:DoSmoke( emitter, origin, scale, normal, data:GetEntity() )
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

function EFFECT:DoSurface( emitter, origin, scale, normal, fx )
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
            debrisVelocity[3] = fx.upVelocity
            debrisVelocity:Add( normal * fx.throwVelocity )

            p:SetAirResistance( 50 )
            p:SetGravity( debrisGravity )
            p:SetVelocity( debrisVelocity * scale * RandomFloat( 0.3, 1.0 ) )
            p:SetLighting( true )
            p:SetCollide( true )
        end
    end
end

local SMOKE_MAT = "glide/effects/tire_particles/tire_slip_forward_"
local SMOKE_GRAVITY = Vector( 0, 0, 60 )
local DEFAULT_COLOR = Vector( 0, 0, 0 )

function EFFECT:DoSmoke( emitter, origin, scale, normal, vehicle )
    local color = ( IsValid( vehicle ) and vehicle.GetTireSmokeColor ) and vehicle:GetTireSmokeColor() or DEFAULT_COLOR
    local r, g, b = color:Unpack()

    r = r * 255
    g = g * 255
    b = b * 255

    local p
    local count = math.floor( scale * 0.5 )
    local lifetime = Config.reduceTireParticles and 0.4 or 1

    for _ = 1, count do
        p = emitter:Add( SMOKE_MAT .. RandomInt( 4 ), origin )

        if p then
            p:SetDieTime( lifetime * RandomFloat( 2, 4 ) )
            p:SetStartAlpha( 50 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( 5 + RandomFloat( 1, 2 ) * scale )
            p:SetEndSize( 40 + RandomFloat( 2, 15 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )

            SMOKE_GRAVITY[1] = RandomFloat( -150, 150 )
            SMOKE_GRAVITY[2] = RandomFloat( -150, 150 )

            p:SetAirResistance( 100 )
            p:SetGravity( SMOKE_GRAVITY * RandomFloat( 0.5, 1 ) )
            p:SetVelocity( normal * RandomFloat( 10, 30 ) * scale )
            p:SetColor( r, g, b )
            p:SetLighting( true )
            p:SetCollide( true )
        end
    end
end

surfaceFX[MAT_GRASS] = {
    mat = Material( "glide/effects/tire_particles/grass_debris" ),
    lifetime = 0.9,
    alpha = 255,
    minSize = 0.9,
    maxSize = 2,
    upVelocity = 12,
    throwVelocity = 30
}

surfaceFX[MAT_FOLIAGE] = surfaceFX[MAT_GRASS]

surfaceFX[MAT_SAND] = {
    mat = Material( "glide/effects/tire_particles/sand" ),
    lifetime = 1,
    alpha = 150,
    minSize = 1.5,
    maxSize = 3,
    gravity = -300,
    upVelocity = 15,
    throwVelocity = 30
}

surfaceFX[MAT_DIRT] = {
    mat = Material( "glide/effects/tire_particles/dirt" ),
    lifetime = 1.5,
    alpha = 150,
    minSize = 2,
    maxSize = 0.8,
    gravity = -400,
    upVelocity = 18,
    throwVelocity = 35
}

surfaceFX[MAT_SNOW] = {
    mat = Material( "glide/effects/tire_particles/snow" ),
    lifetime = 1,
    alpha = 100,
    minSize = 2,
    maxSize = 1.5,
    gravity = -400,
    upVelocity = 18,
    throwVelocity = 35
}

surfaceFX[MAT_SLOSH] = {
    mat = Material( "glide/effects/tire_particles/water" ),
    lifetime = 0.4,
    alpha = 100,
    minSize = 0.5,
    maxSize = 3,
    gravity = -500,
    upVelocity = 10,
    throwVelocity = 35
}
