local CHECK_DIRECTIONS = {
    Vector( 1, 0, 0 ), -- North
    Vector( -1, 0, 0 ), -- South
    Vector( 0, 1, 0 ), -- West
    Vector( 0, -1, 0 ), -- East
    Vector( 0, 0, 1 ) -- Up
}

local traceData = {
    mask = MASK_NPCWORLDSTATIC,
    collisiongroup = COLLISION_GROUP_WORLD
}

local skyboxPlanes = {}

for i = 1, #CHECK_DIRECTIONS do
    local size = 3000

    skyboxPlanes[i] = {
        hit = false,
        alpha = 0,

        v1 = Vector( 0, -size, size ),
        v2 = Vector( 0, -size, -size ),
        v3 = Vector( 0, size, -size ),
        v4 = Vector( 0, size, size )
    }

    local ang = CHECK_DIRECTIONS[i]:Angle()

    skyboxPlanes[i].v1:Rotate( ang )
    skyboxPlanes[i].v2:Rotate( ang )
    skyboxPlanes[i].v3:Rotate( ang )
    skyboxPlanes[i].v4:Rotate( ang )
end

local dirIndex = 0
local planeMat = Material( "glide/effects/skybox_boundary" )
local planeColor = Color( 48, 145, 255 )

local TraceLine = util.TraceLine
local DrawQuad = render.DrawQuad

local SetBlend = render.SetBlend
local SetMaterial = render.SetMaterial
local SetColorModulation = render.SetColorModulation

local function DetectSkybox( isDrawingDepth, isDrawSkybox, isDraw3DSkybox )
    if isDrawingDepth or isDrawSkybox or isDraw3DSkybox then return end

    -- Draw planes where traces have hit the skybox previously
    SetBlend( 1 )
    SetColorModulation( 1, 1, 1 )
    SetMaterial( planeMat )

    local plane, origin

    for i = 1, #skyboxPlanes do
        plane = skyboxPlanes[i]

        if plane.hit then
            origin = plane.origin
            planeColor.a = plane.alpha
            DrawQuad( origin + plane.v1, origin + plane.v2, origin + plane.v3, origin + plane.v4, planeColor )
        end
    end

    -- Check one direction per frame
    dirIndex = dirIndex + 1

    if dirIndex == 5 then
        local vehicle = Glide.currentVehicle

        -- Skip checking the up direction while not piloting an aircraft
        if IsValid( vehicle ) and not Glide.IsAircraft( vehicle ) then
            dirIndex = 1
        end
    end

    if dirIndex > #CHECK_DIRECTIONS then
        dirIndex = 1
    end

    origin = LocalPlayer():GetPos()
    traceData.start = origin
    traceData.endpos = origin + CHECK_DIRECTIONS[dirIndex] * 10000

    local tr = TraceLine( traceData )

    plane = skyboxPlanes[dirIndex]
    plane.origin = tr.HitPos - tr.HitNormal * tr.Fraction * 10
    plane.hit = tr.HitSky
    plane.alpha = 255 * ( 1 - tr.Fraction )
end

function Glide.EnableSkyboxIndicator()
    Glide.DisableSkyboxIndicator()

    for _, plane in ipairs( skyboxPlanes ) do
        plane.alpha = 0
    end

    if not Glide.Config.showSkybox then return end
    if not Glide.currentSeatIndex then return end
    if Glide.currentSeatIndex > 1 then return end

    hook.Add( "PostDrawTranslucentRenderables", "Glide.DetectSkybox", DetectSkybox )
end

function Glide.DisableSkyboxIndicator()
    hook.Remove( "PostDrawTranslucentRenderables", "Glide.DetectSkybox" )
end

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.EnableSkyboxDetection", function()
    Glide.EnableSkyboxIndicator()
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.DisableSkyboxDetection", function()
    Glide.DisableSkyboxIndicator()
end )
