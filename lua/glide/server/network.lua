local commands = {}

commands[Glide.CMD_INPUT_SETTINGS] = function( ply )
    local data = Glide.ReadTable()

    Glide.PrintDev( "Received input data from %s <%s>", ply:Nick(), ply:SteamID() )
    Glide.SetupPlayerInput( ply, data )
end

commands[Glide.CMD_SWITCH_SEATS] = function( ply )
    local seatIndex = net.ReadUInt( 5 )
    Glide.SwitchSeat( ply, seatIndex )
end

commands[Glide.CMD_SET_HEADLIGHTS] = function( ply )
    local toggle = net.ReadBool()
    local veh = ply:GlideGetVehicle()

    if IsValid( veh ) and ply:GlideGetSeatIndex() == 1 and veh.SetHeadlightState then
        veh:ChangeHeadlightState( toggle and 2 or 0 )
    end
end

commands[Glide.CMD_UPLOAD_ENGINE_STREAM_PRESET] = function( ply )
    local veh = net.ReadEntity()

    if not IsValid( veh ) then return end
    if not veh.IsGlideVehicle and veh:GetClass() ~= "glide_engine_stream_chip" then return end

    -- Make sure this player can tool this vehicle
    local tr = ply:GetEyeTrace()
    tr.Entity = veh

    if hook.Run( "CanTool", ply, tr, "glide_engine_stream", {}, 1 ) == false then return end

    local size = net.ReadUInt( 16 )

    if size > Glide.MAX_JSON_SIZE then
        Glide.Print( "Tried to read data that was too big! (%d/%d)", size, Glide.MAX_JSON_SIZE )
        return
    end

    local data = net.ReadData( size )

    data = util.Decompress( data )
    if not data then return end

    data = Glide.FromJSON( data )
    if not data then return end

    Glide.StoreEngineStreamPresetModifier( ply, veh, data )
end

commands[Glide.CMD_UPLOAD_MISC_SOUNDS_PRESET] = function( ply )
    local veh = net.ReadEntity()

    if not IsValid( veh ) then return end
    if not veh.IsGlideVehicle then return end

    -- Make sure this player can tool this vehicle
    local tr = ply:GetEyeTrace()
    tr.Entity = veh

    if hook.Run( "CanTool", ply, tr, "glide_misc_sounds", {}, 1 ) == false then return end

    local size = net.ReadUInt( 16 )

    if size > Glide.MAX_JSON_SIZE then
        Glide.Print( "Tried to read data that was too big! (%d/%d)", size, Glide.MAX_JSON_SIZE )
        return
    end

    local data = net.ReadData( size )

    data = util.Decompress( data )
    if not data then return end

    data = Glide.FromJSON( data )
    if not data then return end

    Glide.StoreMiscSoundsPresetModifier( ply, veh, data )
end

-- Store the last entity the CLIENT told it was aiming at.
-- Used for lag compensation on turrets.
local lastAimEntity = Glide.lastAimEntity or {}

Glide.lastAimEntity = lastAimEntity

commands[Glide.CMD_LAST_AIM_ENTITY] = function( ply )
    local ent = net.ReadEntity()

    if IsValid( ent ) then
        lastAimEntity[ply] = ent
    end
end

-- Safeguard against spam
local cooldowns = {
    [Glide.CMD_INPUT_SETTINGS] = { interval = 1, players = {} },
    [Glide.CMD_SWITCH_SEATS] = { interval = 0.5, players = {} },
    [Glide.CMD_SET_HEADLIGHTS] = { interval = 0.5, players = {} },
    [Glide.CMD_LAST_AIM_ENTITY] = { interval = 0.01, players = {} },
    [Glide.CMD_UPLOAD_ENGINE_STREAM_PRESET] = { interval = 0.4, players = {} },
    [Glide.CMD_UPLOAD_MISC_SOUNDS_PRESET] = { interval = 0.4, players = {} }
}

-- Receive and validate network commands
net.Receive( "glide.command", function( _, ply )
    local id = ply:SteamID()
    local cmd = net.ReadUInt( Glide.CMD_SIZE )

    if not commands[cmd] then
        Glide.Print( "%s <%s> sent a unknown network command! (%d)", ply:Nick(), id, cmd )
        return
    end

    local cooldown = cooldowns[cmd]
    if not cooldown then return end

    local t = RealTime()
    local players = cooldown.players

    if players[id] and players[id] > t then
        Glide.Print( "%s <%s> sent network commands too fast!", ply:Nick(), id )
        return
    end

    players[id] = t + cooldown.interval
    commands[cmd]( ply )
end )

-- Cleanup cooldown/last aim entity entries for this player
hook.Add( "PlayerDisconnected", "Glide.NetCleanup", function( ply )
    local id = ply:SteamID()

    for _, c in pairs( cooldowns ) do
        c.players[id] = nil
    end

    lastAimEntity[ply] = nil
end )

local type = type

--- Send a notification message to the target(s).
function Glide.SendNotification( target, data )
    if type( target ) == "table" and #target == 0 then return end

    Glide.StartCommand( Glide.CMD_NOTIFY )
    Glide.WriteTable( data )
    net.Send( target )
end

--- Send a notification about a button action message to the target(s).
function Glide.SendButtonActionNotification( target, text, icon, inputGroup, inputAction )
    if type( target ) == "table" and #target == 0 then return end

    Glide.StartCommand( Glide.CMD_SHOW_KEY_NOTIFICATION )
    net.WriteString( text )
    net.WriteString( icon )
    net.WriteString( inputGroup )
    net.WriteString( inputAction )
    net.Send( target )
end

--- Let the target client(s) know about a incoming lock-on.
function Glide.SendLockOnDanger( target )
    if type( target ) == "table" and #target == 0 then return end

    Glide.StartCommand( Glide.CMD_INCOMING_DANGER, false )
    net.WriteUInt( Glide.DANGER_TYPE.LOCK_ON, 3 )
    net.Send( target )
end

--- Let the target client(s) know about a incoming missile.
function Glide.SendMissileDanger( target, missile )
    if type( target ) == "table" and #target == 0 then return end

    Glide.StartCommand( Glide.CMD_INCOMING_DANGER, false )
    net.WriteUInt( Glide.DANGER_TYPE.MISSILE, 3 )
    net.WriteUInt( missile:EntIndex(), 32 )
    net.Send( target )
end

--- Apply a camera shake to the target's Glide camera.
function Glide.SendViewPunch( target, force )
    if type( target ) == "table" and #target == 0 then return end

    Glide.StartCommand( Glide.CMD_VIEW_PUNCH, false )
    net.WriteFloat( force )
    net.Send( target )
end

--- Send a notification to a player when they try to use
--- a tool that requires Wiremod, while it's is not installed.
function Glide.ToolCheckMissingWiremod( target )
    if WireLib then return end

    Glide.SendNotification( target, {
        text = "#glide.tool_wiremod_not_available",
        icon = "materials/icon16/cancel.png",
        sound = "glide/ui/radar_alert.wav",
        immediate = true
    } )
end
