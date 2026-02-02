if CLIENT then
    list.Set( "GlideCategories", "GTAV_Helicopters", {
        name = "GTA:V Helicopters",
        icon = "glide/icons/helicopter.png"
    } )
end

if SERVER then
    resource.AddWorkshop( 3389795738 )
end

hook.Add( "InitPostEntity", "GTAVHelicopters.GlideCheck", function()
    if Glide then
        if SERVER then
            local whitelist = Glide.LOCKON_WHITELIST

            whitelist["glide_gtav_armed_heli"] = true
            whitelist["glide_gtav_blimp"] = true
            whitelist["glide_gtav_polmav"] = true
            whitelist["glide_gtav_skylift"] = true
            whitelist["glide_gtav_swift"] = true
        end

        return
    end

    timer.Simple( 5, function()

        local BASE_ADDON_NAME = "Glide // Styled's Vehicle Base"
        local SUB_ADDON_NAME = "Glide // GTAV: Helicopters"

        local colorHighlight = Color( 255, 0, 0 )
        local colorText = Color( 255, 200, 200 )

        local function Print( ... )
            if SERVER then MsgC( ..., "\n" ) end
            if CLIENT then chat.AddText( ... ) end
        end

        Print(
            colorHighlight, SUB_ADDON_NAME,
            colorText, " is installed, but ",
            colorHighlight, BASE_ADDON_NAME,
            colorText, " is missing! Please install the base addon."
        )

    end )
end )
