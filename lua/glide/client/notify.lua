local active

local function SetupNotification()
    active.fade = 0
    active.flash = 1
    active.iconMat = Glide.GetCachedIcon( active.icon )
    active.iconSize = math.floor( ScrH() * 0.035 )
    active.margin = math.floor( ScrH() * 0.03 )
    active.padding = math.floor( ScrH() * 0.01 )

    active.body = markup.Parse(
        string.format( "<font=%s>%s</font>", "GlideNotification", active.text ),
        math.floor( ScrH() * 0.4 )
    )

    local w, h = active.body:Size()

    active.bodyX = active.iconSize + active.padding
    active.w = active.iconSize + w + active.padding * 2
    active.h = h + active.padding * 2

    active.iconSize = active.iconSize * 0.8

    if active.sound then
        EmitSound( active.sound, Vector(), -2, nil, 0.8, nil, nil, 100 )
    end
end

local COLORS = {
    text = Color( 255, 255, 255 ),
    background = Color( 20, 20, 20 ),
    accent = Glide.THEME_COLOR,
    bgAlpha = 0.9
}

local function RenderNotification()
    local dt = FrameTime()

    active.lifetime = active.lifetime - dt

    if active.lifetime < 0 then
        active.fade = active.fade - dt

        if active.fade < 0 then
            active = nil
            return
        end
    else
        active.fade = Lerp( dt * 20, active.fade, 1 )
    end

    local alpha = 255 * active.fade
    local x, y = active.margin, active.margin

    x = x - active.w * ( 1 - active.fade )

    COLORS.background.a = alpha * COLORS.bgAlpha
    surface.SetDrawColor( COLORS.background:Unpack() )
    surface.DrawRect( x, y, active.w, active.h )

    if active.flash > 0 then
        active.flash = active.flash - dt * 3
        surface.SetDrawColor( 146, 184, 255, 255 * active.flash )
        surface.DrawRect( x, y, active.w, active.h )
    end

    surface.SetMaterial( active.iconMat )
    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.DrawTexturedRect( x + active.padding, y + ( active.h * 0.5 ) - ( active.iconSize * 0.5 ), active.iconSize, active.iconSize )

    active.body:Draw( x + active.bodyX, y + active.padding, nil, nil, alpha )
end

local notifications = Glide.notifications or {}
Glide.notifications = notifications

hook.Add( "PostRenderVGUI", "Glide.RenderNotifications", function()
    if active then
        RenderNotification()

    elseif #notifications > 0 then
        active = table.remove( notifications, 1 )
        SetupNotification()
    end
end )

function Glide.Notify( params )
    local index = #notifications + 1

    notifications[index] = {
        text = params.text,
        icon = params.icon or "materials/glide/icons/question.png",
        sound = params.sound or "glide/ui/hud_switch.wav",
        lifetime = params.lifetime or math.Clamp( math.floor( 5 + params.text:len() * 0.05 ), 5, 15 )
    }

    if params.immediate then
        active = table.remove( notifications, index )
        SetupNotification()
    end
end

local givenHints = {}

local function HasGivenHint( text )
    local id = util.MD5( text )

    if givenHints[id] or not Glide.Config.enableTips then
        return true
    end

    givenHints[id] = true

    return false
end

function Glide.ShowTip( text, icon )
    if HasGivenHint( text ) then return end

    if text:sub( 1, 1 ) == "#" then
        text = language.GetPhrase( text )
    end

    Glide.Notify( {
        text = text,
        icon = icon or "materials/glide/icons/car.png"
    } )
end

function Glide.ShowKeyTip( text, key, icon, immediate )
    if not immediate and HasGivenHint( text ) then return end

    if text:sub( 1, 1 ) == "#" then
        text = language.GetPhrase( text )
    end

    local keyName = input.GetKeyName( key )
    if not keyName then return end

    local colorTag = string.format( "<b><color=%d,%d,%d,255>", Glide.THEME_COLOR.r, Glide.THEME_COLOR.g, Glide.THEME_COLOR.b )

    Glide.Notify( {
        text = text:format( colorTag .. keyName:upper() .. "</color></b>" ),
        icon = icon or "materials/glide/icons/car.png",
        immediate = immediate
    } )
end

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.ShowVehicleTips", function( _, seatIndex )
    if seatIndex > 1 then return end

    timer.Simple( 2, function()
        local veh = Glide.currentVehicle
        if not IsValid( veh ) then return end

        if Glide.HasBaseClass( veh, "base_glide_car" ) then
            Glide.ShowKeyTip( "#glide.notify.tip.headlights", Glide.Config.binds["general_controls"]["headlights"] )

        elseif Glide.HasBaseClass( veh, "base_glide_heli" ) and Glide.Config.mouseFlyMode == Glide.MOUSE_FLY_MODE.AIM then
            Glide.ShowTip( "#glide.notify.tip.heli_controls", "materials/glide/icons/helicopter.png" )
        end
    end )
end )
