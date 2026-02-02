local areHeadlightsOn = false

--- Check if the current vehicle's spot is dark,
--- then request to toggle the headlights.
local function AutoToggleHeadlights()
    local vehicle = Glide.currentVehicle
    if not IsValid( vehicle ) then return end

    local c = render.ComputeLighting( vehicle:GetPos(), Vector( 0, 0, 1 ) )
    local avg = ( c[1] * 0.2126 ) + ( c[2] * 0.7152 ) + ( c[3] * 0.0722 ) -- Luminosity method
    local shouldBeOn = Either( areHeadlightsOn, avg < 1.3, avg < 0.2 )

    if areHeadlightsOn ~= shouldBeOn then
        areHeadlightsOn = shouldBeOn

        if shouldBeOn and not Glide.Config.autoHeadlightOn then return end
        if not shouldBeOn and not Glide.Config.autoHeadlightOff then return end

        Glide.StartCommand( Glide.CMD_SET_HEADLIGHTS )
        net.WriteBool( shouldBeOn )
        net.SendToServer()
    end
end

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.AutoToggleHeadlights", function( vehicle, seatIndex )
    if seatIndex > 1 then return end
    if not vehicle.GetHeadlightState then return end

    areHeadlightsOn = vehicle:GetHeadlightState() > 0
    timer.Create( "Glide.AutoToggleHeadlights", 1, 0, AutoToggleHeadlights )
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.AutoToggleHeadlights", function()
    timer.Remove( "Glide.AutoToggleHeadlights" )
end )
