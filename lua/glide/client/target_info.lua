local TEXT_COLOR = Color( 255, 255, 255, 255 )
local BG_COLOR = Color( 20, 20, 20, 230 )

local Floor = math.floor
local Clamp = math.Clamp

local GetTextSize = surface.GetTextSize
local DrawRoundedBox = draw.RoundedBoxEx
local DrawSimpleText = draw.SimpleText

local DrawRect = surface.DrawRect
local SetColor = surface.SetDrawColor

local function DrawPlayerTag( ply, health, pos )
    pos = pos:ToScreen()

    local nick = ply:Nick()
    local screenH = ScrH()

    local color = TEXT_COLOR
    local returnedColor, returnedName = hook.Run( "Glide_PlayerTagColor", ply, nick, health )
    if returnedColor and IsColor( returnedColor ) then
        color = returnedColor
    end
    if returnedName and isstring( returnedName ) then
        nick = returnedName
    end

    surface.SetFont( "GlideSelectedWeapon" )

    local w, h = GetTextSize( nick )
    local minW = Floor( screenH * 0.15 )
    local padding = Floor( screenH * 0.004 )

    w = Clamp( w, minW, screenH ) + padding * 2
    h = h + padding * 2

    local x = pos.x - w * 0.5
    local y = pos.y - h * 1.5

    DrawRoundedBox( screenH * 0.005, x, y, w, h, BG_COLOR, true, true, false, false )
    DrawSimpleText( nick, "GlideSelectedWeapon", x + w * 0.5, y + h * 0.5, color, 1, 1 )

    if health < 0 then return x, y + h, w end

    y = y + h
    h = h * 0.25

    SetColor( 0, 0, 0, 255 )
    DrawRect( x, y, w, h )

    SetColor( 255 * ( 1 - health ), 255 * health, 0, 255 )
    DrawRect( x, y, w * health, h )

    return x, y + h, w
end

local IsValid = IsValid
local FrameTime = FrameTime
local LocalPlayer = LocalPlayer
local SetAlphaMultiplier = surface.SetAlphaMultiplier

local Config = Glide.Config
local Camera = Glide.Camera
local lastTarget, alpha = NULL, 0

hook.Add( "HUDDrawTargetID", "Glide.HUDDrawTargetID", function()
    do return end
    if not Config.showCustomHealth then return end
    local localPly = LocalPlayer()

    if Camera.isActive then
        local target = Camera.lastAimEntity

        if IsValid( target ) and ( target:IsPlayer() or target.IsGlideVehicle ) and target ~= localPly then
            lastTarget = target
            alpha = 1
        end
    else
        -- If the camera is not active, only return Glide vehicles
        local target = localPly:GetEyeTrace().Entity

        if IsValid( target ) and target.IsGlideVehicle then
            lastTarget = target
            alpha = 1
        end
    end

    if not IsValid( lastTarget ) then
        alpha = 0
        return
    end

    alpha = alpha - FrameTime()

    if alpha < 0 then
        lastTarget = NULL
        return
    end

    SetAlphaMultiplier( alpha )

    if lastTarget.IsGlideVehicle then
        local health = lastTarget:GetChassisHealth() / lastTarget.MaxChassisHealth
        local driver = lastTarget:GetDriver()
        local pos = lastTarget:GetPos()
        local h = ScrH() * 0.02

        pos[3] = pos[3] + lastTarget:OBBMaxs()[3]

        if IsValid( driver ) and driver ~= localPly then
            local x, y, w = DrawPlayerTag( driver, -1, pos )
            Glide.DrawHealthBar( x, y, w, h, health, Glide.GetVehicleIcon( lastTarget.VehicleType ) )

        elseif Glide.Config.showEmptyVehicleHealth then
            pos = pos:ToScreen()

            local w = ScrH() * 0.15
            local x = pos.x - w * 0.5
            local y = pos.y - h * 0.5

            Glide.DrawHealthBar( x, y, w, h, health, Glide.GetVehicleIcon( lastTarget.VehicleType ) )
        end

    elseif lastTarget:IsPlayer() then
        DrawPlayerTag( lastTarget, Clamp( lastTarget:Health() / 100, 0, 1 ), lastTarget:EyePos() )
    end

    SetAlphaMultiplier( 1 )

    return false
end, HOOK_HIGH )
