local lights = {}
local lightCount = 0

function Glide.DrawLight( pos, color, size, brightness )
    lightCount = lightCount + 1
    lights[lightCount] = { pos, color.r, color.g, color.b, size or 70, brightness or 5 }
end

local CurTime = CurTime
local DynamicLight = DynamicLight

hook.Add( "Think", "Glide.DrawLights", function()
    if lightCount < 1 then return end

    local t = CurTime()
    local data, light

    for i = 1, lightCount do
        data = lights[i]
        light = DynamicLight( i )

        if light then
            light.pos = data[1]
            light.r = data[2]
            light.g = data[3]
            light.b = data[4]
            light.dietime = t + 0.25
            light.decay = 5000
            light.size = data[5]
            light.brightness = data[6]
        end
    end

    lightCount = 0
end )

local sprites = {}
local spriteCount = 0

function Glide.DrawLightSprite( pos, dir, size, color, material )
    spriteCount = spriteCount + 1
    sprites[spriteCount] = { pos, size, color, dir, material }
end

local Max = math.max
local Clamp = math.Clamp

local SetMaterial = render.SetMaterial
local DrawSprite = render.DrawSprite
local DepthRange = render.DepthRange

local GetLocalViewLocation = Glide.GetLocalViewLocation
local DEFAULT_MAT = Material( "glide/effects/light_glow" )

hook.Add( "PreDrawEffects", "Glide.DrawSprites", function()
    if spriteCount < 1 then return end

    local pos, ang = GetLocalViewLocation()
    local dir = -ang:Forward()
    local s, dot

    for i = 1, spriteCount do
        s = sprites[i]

        -- Make so the sprite draws over things that are right on top of it,
        -- but does not draw on top of walls when viewed from far away.
        DepthRange( 0.0, Clamp( pos:DistToSqr( s[1] ) / 200000, 0.999, 1 ) )

        -- Make the sprite smaller as the viewer points away from it
        dot = s[4] and dir:Dot( s[4] ) or 1
        dot = ( dot - 0.5 ) * 2
        s[2] = s[2] * Max( 0, dot )

        SetMaterial( s[5] or DEFAULT_MAT )
        DrawSprite( s[1], s[2], s[2], s[3] )

        sprites[i] = nil
    end

    spriteCount = 0
    DepthRange( 0.0, 1.0 )
end )
