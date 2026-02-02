--[[
    Utility logic to register "synchronized" entity modifiers.

    Once a modifier is set on a entity, it's data is automatically sent
    to existing players. It will also remember to send to players that
    connect later, until the entity and/or modifier is removed.
]]

util.AddNetworkString( "glide.sync_entity_modifier" )

Glide.activeSyncedModifiers = Glide.activeSyncedModifiers or {}
local activeSyncedModifiers = Glide.activeSyncedModifiers

hook.Add( "PlayerDisconnected", "Glide.CleanupSynchronizeModifierPlayers", function( ply )
    for _, mod in ipairs( activeSyncedModifiers ) do
        mod.synced[ply] = nil
    end
end )

local function PrintModifierError( name, ply, message )
    local str = "Failed to apply modifier '" .. name .. "'"

    if IsValid( ply ) and ply:IsPlayer() then
        str = str .. string.format( " from %s <%s>", ply:Nick(), ply:SteamID() )
    end

    Glide.Print( str .. ": " .. message )
end

local function SendModifierTo( ply, mod )
    local size = #mod.json

    net.Start( "glide.sync_entity_modifier", false )
    net.WriteUInt( mod.entIndex, MAX_EDICT_BITS )
    net.WriteString( mod.name )
    net.WriteBool( true ) -- This modifier was just created/updated
    net.WriteUInt( size, 16 )
    net.WriteData( mod.json )
    net.Send( ply )

    Glide.PrintDev( "Sent synchronized modifier '%s' from entity #%d to %s <%s>", mod.name, mod.entIndex, ply:Nick(), ply:SteamID() )
end

local function BroadcastModifierRemoval( mod )
    net.Start( "glide.sync_entity_modifier", false )
    net.WriteUInt( mod.entIndex, MAX_EDICT_BITS )
    net.WriteString( mod.name )
    net.WriteBool( false ) -- This modifier was just removed
    net.Broadcast()
end

do
    local Remove = table.remove
    local GetHumans = player.GetHumans

    -- We're going to loop through one active modifier at intervals,
    -- so we need this variable to track that loop over time.
    local index = 0
    local count, mod, synced

    timer.Create( "Glide.SynchronizeModifiers", 0.1, 0, function()
        count = #activeSyncedModifiers
        if count < 1 then return end

        index = index + 1

        if index > count then
            index = 1
        end

        mod = activeSyncedModifiers[index]

        -- Remove this modifier entry if the entity is invalid
        if not IsValid( mod.ent ) then
            mod = Remove( activeSyncedModifiers, index )
            BroadcastModifierRemoval( mod )

            return
        end

        synced = mod.synced

        for _, ply in ipairs( GetHumans() ) do
            -- If we have not synced this  entry to this player yet...
            if not synced[ply] and ply.GlideLoaded then
                synced[ply] = true
                SendModifierTo( ply, mod )
            end
        end
    end )
end

--- Register a "synchronized" entity modifier.
---
--- Returns two functions:
---  First, a function that you can call to store data into
---  a entity through this modifier, which in turn gets saved
---  when the entity is duped.
---  Second, a function that you can call to
---  clear the modifier from a entity.
---
--- `onPreApply` is a function called before the modifier is
--- applied to the entity, which you can use to validate the data.
--- It receives the same parameters as the second argument
--- used on `duplicator.RegisterEntityModifier`.
---
--- If you don't return a table on `onPreApply`, the modifier will
--- be considered invalid, and so it won't be applied to the entity.
---
--- To receive the data on the client side, use `Glide.RegisterSyncedModifierReceiver`
--- with the exact same modifier `name` you used here.
---
function Glide.RegisterSyncedModifier( name, onPreApply )
    -- This function will be called when the modifier
    -- `name` is going to be applied to a entity.
    local ApplyModifier = function( ply, ent, data )
        data = onPreApply( ply, ent, data )

        if type( data ) ~= "table" then
            return
        end

        -- Clear existing modifier. This has to be done
        -- due to a bug where, if you apply a modifier,
        -- dupe the entity, and then apply the same modifier again
        -- with different data, that last data won't save on the next dupe.
        duplicator.ClearEntityModifier( ent, name )

        -- Serialize the data to sync later via networking.
        local json = Glide.ToJSON( data )

        if type( json ) ~= "string" then
            PrintModifierError( name, ply, "Could not serialize to JSON" )
            return
        end

        -- If the data is too big, this modifier will not be applied.
        if #json > Glide.MAX_JSON_SIZE then
            PrintModifierError( name, ply, "JSON is too big" )
            return
        end

        -- Store the modifier data
        duplicator.StoreEntityModifier( ent, name, data )

        -- Prepare data for synchronization
        json = util.Compress( json )

        local index = #activeSyncedModifiers + 1

        -- Check if the entity has this modifier already.
        -- If so, override the entry on the `activeSyncedModifiers` list.
        for i, mod in ipairs( activeSyncedModifiers ) do
            if mod.ent == ent and mod.name == name then
                index = i
                break
            end
        end

        activeSyncedModifiers[index] = {
            ent = ent,
            entIndex = ent:EntIndex(),
            name = name,
            json = json,
            synced = {}
        }

        Glide.PrintDev( "Added synchronized modifier '%s' to entity #%d", name, ent:EntIndex() )
    end

    duplicator.RegisterEntityModifier( name, ApplyModifier )

    local RemoveModifier = function( ent )
        duplicator.ClearEntityModifier( ent, name )

        -- Check if the entity has this modifier on our
        -- `activeSyncedModifiers` list. If so, remove it.
        for i, mod in ipairs( activeSyncedModifiers ) do
            if mod.ent == ent and mod.name == name then
                table.remove( activeSyncedModifiers, i )
                BroadcastModifierRemoval( mod )

                break
            end
        end

        Glide.PrintDev( "Removed synchronized modifier '%s' from entity #%d", name, ent:EntIndex() )
    end

    return ApplyModifier, RemoveModifier
end

--------------------------------------------------

--[[
    Synchronized modifier: Engine Stream Preset
]]

Glide.StoreEngineStreamPresetModifier, Glide.ClearEngineStreamPresetModifier = Glide.RegisterSyncedModifier(
    "glide_engine_stream",
    function( ply, ent, data )
        -- Make sure this entity is a Glide vehicle that supports this modifier
        if not Glide.DoesEntitySupportEngineStreamPreset( ent ) then return end

        -- Migrate from the old data format, where the preset was
        -- stored as a string on the `json` key. On the new format,
        -- the preset data is stored on the `data` table directly.
        if type( data.json ) == "string" then
            data = Glide.FromJSON( data.json )
        end

        local success, message = Glide.ValidateStreamData( data )

        if success then
            return data
        else
            PrintModifierError( "glide_engine_stream", ply, message )
        end
    end
)

--[[
    Synchronized modifier: Misc. Sounds Preset
]]

Glide.StoreMiscSoundsPresetModifier, Glide.ClearMiscSoundsPresetModifier = Glide.RegisterSyncedModifier(
    "glide_misc_sounds",
    function( ply, ent, data )
        -- Make sure this entity is a Glide vehicle that supports this modifier
        if not Glide.DoesEntitySupportMiscSoundsPreset( ent ) then return end

        -- Migrate from the old data format, where the preset was
        -- stored as a string on the `json` key. On the new format,
        -- the preset data is stored on the `data` table directly.
        if type( data.json ) == "string" then
            data = Glide.FromJSON( data.json )
        end

        local success, message = Glide.ValidateMiscSoundData( data )

        if success then
            return data
        else
            PrintModifierError( "glide_misc_sounds", ply, message )
        end
    end
)
