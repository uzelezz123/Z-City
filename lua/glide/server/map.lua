Glide.MAP_SURFACE_OVERRIDES = {}

-- Load surface material overrides for this map
hook.Add( "InitPostEntity", "Glide.LoadMapOverrides", function()
    local path = "data_static/glide/surface_overrides/" .. game.GetMap() .. ".json"
    local data = file.Read( path, "GAME" )
    if not data then return end

    Glide.Print( "Found material surface overrides at: %s", path )

    data = Glide.FromJSON( data )

    local overrides = Glide.MAP_SURFACE_OVERRIDES
    local StartsWith = string.StartsWith

    for originalMat, overrideMat in pairs( data ) do
        if type( originalMat ) ~= "string" or not StartsWith( originalMat, "MAT_" ) then
            Glide.Print( "Ignoring invalid original surface ID: %s", originalMat )

        elseif type( overrideMat ) ~= "string" or not StartsWith( overrideMat, "MAT_" ) then
            Glide.Print( "Ignoring invalid override surface ID: %s", overrideMat )

        else
            local k = _G[originalMat]
            local v = _G[overrideMat]

            if not k then
                Glide.Print( "Original surface ID does not exist: %s", originalMat )

            elseif not v then
                Glide.Print( "Override surface ID does not exist: %s", overrideMat )
            else
                overrides[k] = v
            end
        end
    end
end )
