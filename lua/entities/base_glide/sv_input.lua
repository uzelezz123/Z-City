--- Resets all input action values for a specific seat.
function ENT:ResetInputs( seatIndex )
    local bools = self.inputBools[seatIndex]

    if bools then
        for action, _ in pairs( bools ) do
            bools[action] = false
        end
    end

    local floats = self.inputFloats[seatIndex]

    if floats then
        for action, _ in pairs( floats ) do
            floats[action] = 0
        end
    end

    self.inputThrottleModifierToggle = false
end

--- Get the action's boolean value from a specific seat.
function ENT:GetInputBool( seatIndex, action )
    local bools = self.inputBools[seatIndex]
    if bools then return bools[action] end

    return false
end

do
    -- Translate these boolean actions to float values.
    local BOOL_TO_FLOAT = {
        ["accelerate"] = { "", "accelerate" },
        ["brake"] = { "", "brake" },
        ["steer"] = { "steer_left", "steer_right" },
        ["pitch"] = { "pitch_up", "pitch_down" },
        ["roll"] = { "roll_left", "roll_right" },
        ["yaw"] = { "yaw_left", "yaw_right" },
        ["throttle"] = { "throttle_down", "throttle_up" },
        ["lean_pitch"] = { "lean_back", "lean_forward" }
    }

    -- Actions affected by the throttle modifier
    local THROTTLE_MOD_ACTIONS = {
        ["accelerate"] = true,
        ["brake"] = true
    }

    local Abs = math.abs
    local Clamp = math.Clamp

    --- Get the action's float value from a specific seat.
    function ENT:GetInputFloat( seatIndex, action )
        local value = 0

        -- Try to get the float value directly
        local floats = self.inputFloats[seatIndex]
        if floats then
            value = floats[action] or 0
        end

        -- Try to convert the boolean actions to a float action
        local bools = self.inputBools[seatIndex]
        if bools then
            local indexes = BOOL_TO_FLOAT[action]
            local boolState = bools[indexes[1]] and -1 or ( bools[indexes[2]] and 1 or 0 )

            value = value + boolState

            if THROTTLE_MOD_ACTIONS[action] and Abs( boolState ) > 0 then
                value = value * self:GetInputThrottleModifier()
            end
        end

        return Clamp( value, -1, 1 )
    end
end

function ENT:SetInputBool( seatIndex, action, pressed )
    local handled = self:OnSeatInput( seatIndex, action, pressed )
    if handled then return end

    local bools = self.inputBools[seatIndex]

    if bools then
        bools[action] = pressed
    end

    if not pressed or seatIndex > 1 then return end

    if action == "switch_weapon" then
        self:SelectWeaponIndex( self:GetWeaponIndex() + 1 )

    elseif action == "headlights" then
        self:ChangeHeadlightState( self:GetHeadlightState() + 1 )

    elseif action == "signal_left" then
        -- If the driver is also holding "signal_right"
        if self:GetInputBool( 1, "signal_right" ) then
            -- Toggle hazard lights
            self:ChangeTurnSignalState( self:GetTurnSignalState() == 3 and 0 or 3 )
        else
            -- Toggle left turn signal
            self:ChangeTurnSignalState( self:GetTurnSignalState() == 1 and 0 or 1 )
        end

    elseif action == "signal_right" then
        -- If the driver is also holding "signal_left"
        if self:GetInputBool( 1, "signal_left" ) then
            -- Toggle hazard lights
            self:ChangeTurnSignalState( self:GetTurnSignalState() == 3 and 0 or 3 )
        else
            -- Toggle right turn signal
            self:ChangeTurnSignalState( self:GetTurnSignalState() == 2 and 0 or 2 )
        end

    elseif action == "detach_trailer" and self.socketCount > 0 then
        self:DisconnectAllSockets()

    elseif action == "throttle_modifier" and self.inputThrottleModifierMode == 2 then
        self.inputThrottleModifierToggle = not self.inputThrottleModifierToggle

        Glide.SendNotification( self:GetAllPlayers(), {
            text = "#glide.notify.reduced_throttle_" .. ( self.inputThrottleModifierToggle and "on" or "off" ),
            icon = "materials/glide/icons/" .. ( self.inputThrottleModifierToggle and "play_next" or "fast_forward" ) .. ".png",
            immediate = true
        } )
    end

    if action == "toggle_engine" then
        if self:GetEngineState() == 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end
end

function ENT:SetInputFloat( seatIndex, action, value )
    local floats = self.inputFloats[seatIndex]

    if floats then
        floats[action] = value
    end
end

function ENT:OnInputMouseWheel( seatIndex, value )
    if seatIndex < 2 then
        self:SelectWeaponIndex( self:GetWeaponIndex() + ( value > 0 and -1 or 1 ) )
    end
end

function ENT:GetInputThrottleModifier()
    local mode = self.inputThrottleModifierMode

    if mode == 2 then
        return self.inputThrottleModifierToggle and 0.7 or 1.0

    elseif mode == 1 then
        return self:GetInputBool( 1, "throttle_modifier" ) and 0.7 or 1.0
    end

    return self:GetInputBool( 1, "throttle_modifier" ) and 1.0 or 0.7
end
