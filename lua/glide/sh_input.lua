--[[
    Group and enumerate input actions.

    Each input group contains a key-value table of
    action names and the default key that triggers them.
]]

-- Keys reserved for seat switching
Glide.SEAT_SWITCH_BUTTONS = {
    [KEY_1] = 1,
    [KEY_2] = 2,
    [KEY_3] = 3,
    [KEY_4] = 4,
    [KEY_5] = 5,
    [KEY_6] = 6,
    [KEY_7] = 7,
    [KEY_8] = 8,
    [KEY_9] = 9,
    [KEY_0] = 10
}

-- Allow some actions to trigger others
Glide.ACTION_ALIASES = {
    ["attack_alt"] = "attack"
}

Glide.InputGroups = Glide.InputGroups or {}

--- Create/clear a input group.
---
--- Later, you can add actions to this `groupId` string, and then
--- vehicles chose which input groups are activated when a player enters it.
---
--- WARNING: You must call this function with the exact same
--- parameters on both SERVER and CLIENT for this to work properly!
function Glide.SetupInputGroup( groupId )
    assert( type( groupId ) == "string", "Input groupId must be a string!" )

    -- Create a empty actions table for this group
    Glide.InputGroups[groupId] = {}
end

--- Add a new input action to a input group.
---
--- `action` is a unique string, used to save it's button on the config file,
--- and given to some vehicle functions like `ENT:OnSeatInput`.
---
--- `defaultButton` is a `KEY_*` number, used as the default button by the config logic.
---
--- WARNING: You must call this function with the exact same
--- parameters on both SERVER and CLIENT for this to work properly!
function Glide.AddInputAction( groupId, action, defaultButton )
    assert( type( action ) == "string", "Input action must be a string!" )
    assert( type( defaultButton ) == "number", "Input defaultButton must be a number!" )

    local actions = Glide.InputGroups[groupId]

    if not actions then
        ErrorNoHalt( "Invalid input group: " .. tostring( groupId ) )
        return
    end

    if actions[action] then
        ErrorNoHalt( "Input action already exists: " .. tostring( action ) )
        return
    end

    actions[action] = defaultButton
end

--[[
    Inputs that apply to all vehicle types
]]
Glide.SetupInputGroup( "general_controls" )

Glide.AddInputAction( "general_controls", "attack", MOUSE_LEFT )
Glide.AddInputAction( "general_controls", "switch_weapon", KEY_R )
Glide.AddInputAction( "general_controls", "toggle_engine", KEY_I )
Glide.AddInputAction( "general_controls", "headlights", KEY_H )
Glide.AddInputAction( "general_controls", "free_look", KEY_LALT )

--[[
    Inputs that only apply to land vehicle types
]]
Glide.SetupInputGroup( "land_controls" )

Glide.AddInputAction( "land_controls", "steer_left", KEY_A )
Glide.AddInputAction( "land_controls", "steer_right", KEY_D )
Glide.AddInputAction( "land_controls", "accelerate", KEY_W )
Glide.AddInputAction( "land_controls", "brake", KEY_S )
Glide.AddInputAction( "land_controls", "handbrake", KEY_SPACE )
Glide.AddInputAction( "land_controls", "throttle_modifier", KEY_LSHIFT )

Glide.AddInputAction( "land_controls", "horn", KEY_R )
Glide.AddInputAction( "land_controls", "siren", KEY_L )
Glide.AddInputAction( "land_controls", "detach_trailer", KEY_K )

Glide.AddInputAction( "land_controls", "lean_forward", KEY_UP )
Glide.AddInputAction( "land_controls", "lean_back", KEY_DOWN )

Glide.AddInputAction( "land_controls", "signal_left", KEY_LEFT )
Glide.AddInputAction( "land_controls", "signal_right", KEY_RIGHT )

Glide.AddInputAction( "land_controls", "shift_up", KEY_F )
Glide.AddInputAction( "land_controls", "shift_down", KEY_J )
Glide.AddInputAction( "land_controls", "shift_neutral", KEY_M )

--[[
    Inputs that only apply to aircraft vehicle types
]]
Glide.SetupInputGroup( "aircraft_controls" )

Glide.AddInputAction( "aircraft_controls", "attack_alt", KEY_SPACE )
Glide.AddInputAction( "aircraft_controls", "landing_gear", KEY_G )
Glide.AddInputAction( "aircraft_controls", "countermeasures", KEY_F )

Glide.AddInputAction( "aircraft_controls", "pitch_up", KEY_DOWN )
Glide.AddInputAction( "aircraft_controls", "pitch_down", KEY_UP )
Glide.AddInputAction( "aircraft_controls", "yaw_left", KEY_A )
Glide.AddInputAction( "aircraft_controls", "yaw_right", KEY_D )
Glide.AddInputAction( "aircraft_controls", "roll_left", KEY_LEFT )
Glide.AddInputAction( "aircraft_controls", "roll_right", KEY_RIGHT )
Glide.AddInputAction( "aircraft_controls", "throttle_up", KEY_W )
Glide.AddInputAction( "aircraft_controls", "throttle_down", KEY_S )
