--[[
    Utility logic to process "synchronized" entity modifiers.

    Once a modifier is set on a entity, the server sends it's
    data to be processed here.
    
    Our job is to apply the modifier data to the target entity,
    as long as the modifier is active.
]]

Glide.syncedModifierRegistry = Glide.syncedModifierRegistry or {}
local syncedModifierRegistry = Glide.syncedModifierRegistry

--- 
--- Register a receiver for synchronized modifier data coming from the server.
---
--- `onApply` will be called when the target entity with the
--- modifier `name` becomes valid locally, and
--- it provides the `data` table received from the server.
---
--- `onRemove` will be called when the modifier is
--- removed from the target entity.
---
function Glide.RegisterSyncedModifierReceiver( name, onApply, onRemove )
    syncedModifierRegistry[name] = {
        onApply = onApply,
        onRemove = onRemove
    }
end

Glide.entModifierStates = Glide.entModifierStates or {}
local entModifierStates = Glide.entModifierStates

local pairs = pairs
local Entity = Entity
local IsValid = IsValid

timer.Create( "Glide.ApplySynchronizedModifiers", 0.5, 0, function()
    for entIndex, state in pairs( entModifierStates ) do
        state.ent = Entity( entIndex )

        -- When the target entity becomes valid,
        -- apply all modifiers associated with this entity.
        if IsValid( state.ent ) then
            for name, mod in pairs( state.mods ) do
                -- Check if we haven't applied the data yet
                if not mod.applied then
                    mod.applied = true

                    local receiver = syncedModifierRegistry[name]

                    if receiver then
                        receiver.onApply( state.ent, mod.json )
                    end

                    Glide.PrintDev( "Synchronized modifier '%s' on entity #%d", name, entIndex )
                end
            end
        end
    end
end )

net.Receive( "glide.sync_entity_modifier", function()
    local entIndex = net.ReadUInt( MAX_EDICT_BITS )
    local name = net.ReadString()
    local hasData = net.ReadBool()

    if hasData then
        local size = net.ReadUInt( 16 )
        local json = net.ReadData( size )

        json = util.Decompress( json )

        -- We store modifiers per entity index
        local state = entModifierStates[entIndex]

        -- If we aren't tracking this entity index yet,
        -- start doing it now.
        if not state then
            state = { ent = NULL, mods = {} }
            entModifierStates[entIndex] = state
            Glide.PrintDev( "Started tracking modifiers for entity #%d", entIndex )
        end

        -- Store the modifier we just received
        state.mods[name] = {
            applied = false,
            json = json
        }

        Glide.PrintDev( "Received modifier '%s' for entity #%d", name, entIndex )
    else
        -- Make sure we are tracking this entity index
        local state = entModifierStates[entIndex]
        if not state then return end

        -- Make sure this modifier is active on this entity
        if not state.mods[name] then return end

        if IsValid( state.ent ) then
            -- Run the `onRemove` receiver callback
            local receiver = syncedModifierRegistry[name]

            if receiver then
                receiver.onRemove( state.ent )
            end
        end

        -- Remove the modifier from the entity state
        state.mods[name] = nil
        Glide.PrintDev( "Removed modifier '%s' for entity #%d", name, entIndex )

        -- If there are no active modifiers left
        -- stop tracking this entity index.
        if table.Count( state.mods ) < 1 then
            entModifierStates[entIndex] = nil
            Glide.PrintDev( "Stopped tracking modifiers for entity #%d", entIndex )
        end
    end
end )

--------------------------------------------------

--[[
    Synchronized modifier: Engine Stream Preset
]]

Glide.RegisterSyncedModifierReceiver(
    "glide_engine_stream",
    function( ent, data )
        ent.streamJSONOverride = data

        if ent.stream then
            ent.stream:Destroy()
            ent.stream = nil
        end
    end,
    function( ent )
        ent.streamJSONOverride = nil
    end
)

--[[
    Synchronized modifier: Misc. Sounds Preset
]]

local function RestoreMiscSounds( ent )
    -- Stop existing sounds
    local sounds = ent.sounds

    if sounds then
        for k, snd in pairs( sounds ) do
            snd:Stop()
            sounds[k] = nil
        end
    end

    -- Restore original sounds
    if ent._originalSounds then
        for k, path in pairs( ent._originalSounds ) do
            ent[k] = path
        end
    end
end

Glide.RegisterSyncedModifierReceiver(
    "glide_misc_sounds",
    function( ent, data )
        RestoreMiscSounds( ent )

        -- Apply custom sounds
        data = Glide.FromJSON( data )
        ent._originalSounds = ent._originalSounds or {}

        for k, path in pairs( data ) do
            ent._originalSounds[k] = ent[k]
            ent[k] = path
        end
    end,
    function( ent )
        RestoreMiscSounds( ent )
    end
)
