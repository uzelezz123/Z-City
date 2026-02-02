local cache = {}

function Glide.GetCachedIcon( path )
    if cache[path] then
        return cache[path]
    end

    cache[path] = Material( path, "smooth" )

    return cache[path]
end

local ScrH = ScrH
local Floor = math.floor

local SetColor = surface.SetDrawColor
local SetMaterial = surface.SetMaterial
local DrawTexturedRectRotated = surface.DrawTexturedRectRotated

local COLOR_WHITE = Color( 255, 255, 255, 255 )

function Glide.DrawWeaponCrosshair( x, y, icon, size, color )
    size = Floor( ScrH() * size )
    color = color or COLOR_WHITE

    if not cache[icon] then
        cache[icon] = Material( icon, "smooth" )
    end

    SetMaterial( cache[icon] )
    SetColor( color:Unpack() )
    DrawTexturedRectRotated( x, y, size, size, 0 )
end

function Glide.DrawIcon( x, y, icon, size, color, angle )
    if not cache[icon] then
        cache[icon] = Material( icon, "smooth" )
    end

    SetMaterial( cache[icon] )
    SetColor( color:Unpack() )
    DrawTexturedRectRotated( x, y, size, size, angle or 0 )
end

local MAT_BACKGROUND = Material( "glide/weapon_name.png", "smooth" )

function Glide.DrawWeaponSelection( name, icon )
    local sw, sh = ScrW(), ScrH()
    local size = sh * 0.15
    local y = sh * 0.2

    SetMaterial( MAT_BACKGROUND )
    SetColor( 255, 255, 255 )
    DrawTexturedRectRotated( sw * 0.5, y, size, size, 0 )

    draw.SimpleText( name, "GlideSelectedWeapon", sw * 0.5, y + size * 0.06, color_white, 1 )

    if not cache[icon] then
        cache[icon] = Material( icon, "smooth" )
    end

    SetMaterial( cache[icon] )
    DrawTexturedRectRotated( sw * 0.5, y - size * 0.1, size * 0.3, size * 0.3, 0 )
end

local DrawRect = surface.DrawRect
local GetCachedIcon = Glide.GetCachedIcon

local THEME_COLOR = Glide.THEME_COLOR

function Glide.DrawHealthBar( x, y, w, h, health, icon )
    icon = GetCachedIcon( icon or "materials/glide/icons/cogs.png" )

    SetColor( 20, 20, 20, 240 )
    DrawRect( x, y, w, h )

    SetColor( THEME_COLOR:Unpack() )
    DrawRect( x + 1, y + 1, h - 2, h - 2 )

    SetMaterial( icon )
    SetColor( 255, 255, 255, 255 )
    DrawTexturedRectRotated( x + h * 0.5, y + h * 0.5, h * 0.9, h * 0.9, 0 )

    local padding = 1 + Floor( h * 0.13 )

    x = x + h + padding
    y = y + padding
    w = w - h - padding * 2
    h = h - padding * 2

    SetColor( 255 * ( 1 - health ), 255 * health, 0, 255 )
    DrawRect( x, y, w * health, h )
end

local VEHICLE_ICONS = {
    [Glide.VEHICLE_TYPE.CAR] = "materials/glide/icons/car.png",
    [Glide.VEHICLE_TYPE.MOTORCYCLE] = "materials/glide/icons/motorcycle.png",
    [Glide.VEHICLE_TYPE.HELICOPTER] = "materials/glide/icons/helicopter.png",
    [Glide.VEHICLE_TYPE.PLANE] = "materials/glide/icons/plane.png",
    [Glide.VEHICLE_TYPE.TANK] = "materials/glide/icons/tank.png",
    [Glide.VEHICLE_TYPE.BOAT] = "materials/glide/icons/boat.png"
}

function Glide.GetVehicleIcon( vehicleType )
    return VEHICLE_ICONS[vehicleType] or VEHICLE_ICONS[1]
end

local DrawHealthBar = Glide.DrawHealthBar

function Glide.DrawVehicleHealth( x, y, w, h, vehicleType, chassisHealth, engineHealth )
    local colW = w * 0.49

    DrawHealthBar( x, y, colW, h, chassisHealth, VEHICLE_ICONS[vehicleType] or VEHICLE_ICONS[1] )
    DrawHealthBar( x + w - colW, y, colW, h, engineHealth )
end

do
    local segments = 64
    local circleMesh = Mesh()
    local meshMatrix = Matrix()
    local meshVector = Vector()

    mesh.Begin( circleMesh, MATERIAL_POLYGON, segments + 2 )

    mesh.Position( meshVector )
    mesh.TexCoord( 0, 0.5, 0.5 )
    mesh.Color( 255, 255, 255, 255 )
    mesh.AdvanceVertex()

    for i = 0, segments do
        local a = math.rad( ( i / segments ) * -360 )
        local x, y = math.sin( a ), math.cos( a )

        meshVector:SetUnpacked( x, y, 0 )

        mesh.Position( meshVector )
        mesh.TexCoord( 0, x / 2 + 0.5, y / 2 + 0.5 )
        mesh.Color( 255, 255, 255, 255 )
        mesh.AdvanceVertex()
    end

    mesh.End()

    local meshMaterial = CreateMaterial( "GlideCircleMesh", "UnlitGeneric", {
        ["$basetexture"] = "color/white",
        ["$model"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    } )

    local PushModelMatrix = cam.PushModelMatrix
    local PopModelMatrix = cam.PopModelMatrix
    local SetRenderMaterial = render.SetMaterial

    function Glide.DrawFilledCircle( r, x, y, color )
        meshVector:SetUnpacked( color.r / 255, color.g / 255, color.b / 255 )

        meshMaterial:SetVector( "$color", meshVector )
        meshMaterial:SetFloat( "$alpha", color.a / 255 )

        SetRenderMaterial( meshMaterial )

        meshVector:SetUnpacked( x, y, 0 )
        meshMatrix:SetTranslation( meshVector )

        meshVector:SetUnpacked( r, r, r )
        meshMatrix:SetScale( meshVector )

        PushModelMatrix( meshMatrix, true )
        circleMesh:Draw()
        PopModelMatrix()
    end
end

local SetStencilEnable = render.SetStencilEnable
local ClearStencil = render.ClearStencil
local SetStencilTestMask = render.SetStencilTestMask
local SetStencilWriteMask = render.SetStencilWriteMask
local SetStencilPassOperation = render.SetStencilPassOperation
local SetStencilZFailOperation = render.SetStencilZFailOperation
local SetStencilCompareFunction = render.SetStencilCompareFunction
local SetStencilReferenceValue = render.SetStencilReferenceValue
local SetStencilFailOperation = render.SetStencilFailOperation

local Rad = math.rad
local Sin = math.sin
local Cos = math.cos
local DrawPoly = surface.DrawPoly
local DrawFilledCircle = Glide.DrawFilledCircle

function Glide.DrawOutlinedCircle( r, x, y, thickness, color, blockStart, blockEnd )
    SetStencilEnable( true )

    -- Reset stencil state
    ClearStencil()
    SetStencilTestMask( 255 )
    SetStencilWriteMask( 255 )

    -- Don't modify the stencil buffer if the pixel passes or fails
    SetStencilPassOperation( 1 ) -- STENCILOPERATION_KEEP
    SetStencilZFailOperation( 1 ) -- STENCILOPERATION_KEEP

    -- Make all pixels we draw now fail the compare function, since we're just doing a mask
    SetStencilCompareFunction( 1 ) -- STENCILCOMPARISONFUNCTION_NEVER

    -- Replace stencil buffer values with a "1"
    -- on a filled circle smaller than our main circle.
    SetStencilReferenceValue( 1 )
    SetStencilFailOperation( 3 ) -- STENCILOPERATION_REPLACE
    DrawFilledCircle( r - thickness, x, y, COLOR_WHITE )

    -- Block parts of the outer circle if we have block angles
    if blockStart and blockEnd then
        blockStart = Rad( blockStart )
        blockEnd = Rad( blockEnd )

        SetColor( 255, 255, 255, 255 )

        local a = blockStart
        local segments = 10
        local markR = r * 1.1
        local step = ( blockEnd - blockStart ) / segments
        local poly = { { x = x, y = y } }

        for i = 0, segments do
            poly[i + 2] = {
                x = x - Sin( a ) * markR,
                y = y + Cos( a ) * markR
            }

            a = a + step
        end

        poly[#poly + 1] = { x = x, y = y }

        DrawPoly( poly )
    end

    -- We don't want to change the mask anymore
    SetStencilFailOperation( 1 ) -- STENCILOPERATION_KEEP

    -- Only allow pixels that don't match the reference value to pass
    SetStencilCompareFunction( 6 ) -- STENCILCOMPARISONFUNCTION_NOTEQUAL

    DrawFilledCircle( r, x, y, color )
    SetStencilEnable( false )
end
