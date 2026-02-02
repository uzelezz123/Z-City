-- Files under `lua/glide/autoload/` runs after
-- all Glide files have been included.

-- You can safely access the `Glide` global table in here.
-- Glide.Print( "Hello from the %s extension!", "example" )

--[[----------------------------------------
    Example: Add panel on the extensions page
------------------------------------------]]

-- To show a custom panel on the Config. "Extensions" tab,
-- add a function to the "GlideConfigExtensions" list.
-- Replace `MyAddonExample` with the name of your addon.
--[[
list.Set( "GlideConfigExtensions", "MyAddonExample", function( config, panel )

    -- `config` is a alias to `Glide.Config`.
    -- It has some functions that you can use to
    -- populate the panel with your own settings.

    config.CreateButton( panel, "A button", function()
        chat.AddText( "Button pressed!" )
    end )

    config.CreateToggle( panel, "A toggle", false, function( value )
        chat.AddText( "Toggle value: " .. tostring( value ) )
    end )

    config.CreateHeader( panel, "Custom header" )

    config.CreateSlider(
        panel,
        "A slider",
        5, -- start value
        1, -- min. value
        10, -- max. value
        2, -- number of decimal digits
        function( value )
            chat.AddText( "Slider value: " .. tostring( value ) )
        end
    )

    local options = {
        "Option 1", "Option 2", "Option 3"
    }

    local selectedOption = 2

    config.CreateCombo( panel, "A combo box", options, selectedOption, function( index )
        chat.AddText( "Selected option: " .. options[index] )
    end )
end )
]]

--[[----------------------------------------
    Example: Custom input groups and actions
------------------------------------------]]

-- You can create a new input group like this:
-- Glide.SetupInputGroup( "example_controls" )

-- Then, add a input action to be triggered when a key is pressed like this:
-- Glide.AddInputAction( "example_controls", "drop_bomb", KEY_SPACE )

-- Input groups and actions show up on the settings page,
-- so you should add display names for them too.
--[[
if CLIENT then
    -- Group strings should follow this format: "glide.input.your_group_id_here"
    language.Add( "glide.input.example_controls", "Example Controls" )

    -- Action strings should follow this format: "glide.input.your_action_id_here"
    language.Add( "glide.input.drop_bomb", "Drop bomb" )
end
]]

-- To make this new input group work, on the SERVER side of your vehicle's class,
-- you should add this function:
--[[
    function ENT:GetInputGroups( seatIndex )
        return { "general_controls", "aircraft_controls", "example_controls" }
    end
]]

-- If you're sitting on the vehicle, exit and then enter it again. When the
-- spacebar key is pressed, `ENT:OnSeatInput` should now receive a "drop_bomb" action.
--[[
    function ENT:OnSeatInput( seatIndex, action, pressed )
        if action == "drop_bomb" then
            -- Do your own thing here.
        else
            -- Otherwise let the base class handle this.
            BaseClass.OnSeatInput( self, seatIndex, action, pressed )
        end
    end
]]
