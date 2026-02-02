do
    -- Code provided by Wiremod.
    local minForce, maxForce = -400000000, 400000000

    -- Timer resolves issue with table not existing until next tick on Linux.
    hook.Add( "InitPostEntity", "Glide.GetForceLimit", function()
        timer.Simple( 0, function()
            local maxVelocity = physenv.GetPerformanceSettings().MaxVelocity

            -- Ensure at least the default MaxVelocity value
            if maxVelocity < 4000 then
                maxVelocity = 4000
            end

            maxForce = 100000 * maxVelocity
            minForce = -maxForce
        end )
    end )

    local Clamp = math.Clamp

    --- Ensures that the force is within the range
    --- of a float, to prevent physics engine crashes.
    function Glide.ClampForce( v )
        v[1] = Clamp( v[1], minForce, maxForce )
        v[2] = Clamp( v[2], minForce, maxForce )
        v[3] = Clamp( v[3], minForce, maxForce )
    end
end

do
    -- Filter entity duplication data
    local REQUIRED_KEYS = {
        ["DT"] = true,
        ["Pos"] = true,
        ["Angle"] = true,
        ["Mins"] = true,
        ["Maxs"] = true,
        ["Base"] = true,
        ["Class"] = true,
        ["BaseClass"] = true,
        ["PhysicsObjects"] = true,
        ["Model"] = true,
        ["EntityMods"] = true, -- Entity modifiers (colors, materials, etc.)
        ["BuildDupeInfo"] = true -- Required for parenting to work
    }

    function Glide.FilterEntityCopyTable( data, nwFields, entFields )
        nwFields = nwFields or {}
        entFields = entFields or {}

        for k, v in pairs( data ) do
            if k == "DT" then
                for name, _ in pairs( v ) do
                    if not nwFields[name] then
                        v[name] = nil -- We do not want to save this
                    end
                end

            elseif not REQUIRED_KEYS[k] and not entFields[k] then
                data[k] = nil -- We do not want to save this
            end
        end
    end

    -- Save Wiremod dupe data, when available
    function Glide.PreEntityCopy( ent )
        duplicator.ClearEntityModifier( ent, "WireDupeInfo" )

        if not WireLib then return end

        local info = WireLib.BuildDupeInfo( ent )

        if info then
            duplicator.StoreEntityModifier( ent, "WireDupeInfo", info )
        end
    end

    local function EntityLookup( createdEntities )
        return function( id, default )
            if id == nil then return default end
            if id == 0 then return game.GetWorld() end

            local ent = createdEntities[id]
            if IsValid( ent ) then
                return ent
            else
                return default
            end
        end
    end

    -- Restore Wiremod dupe data, when available
    function Glide.PostEntityPaste( ply, ent, createdEntities )
        if not WireLib then return end

        local mods = ent.EntityMods
        if not mods then return end

        local info = mods.WireDupeInfo
        if type( info ) ~= "table" then return end

        WireLib.ApplyDupeInfo( ply, ent, info, EntityLookup( createdEntities ) )
    end
end

do
    -- Sideways traction logic
    local x

    function Glide.TractionRamp( slipAngle, sideTractionMaxAng, sideTractionMax, sideTractionMin )
        sideTractionMaxAng = sideTractionMaxAng / 90 -- Convert max slip angle to the 0-1 range
        x = ( slipAngle - sideTractionMaxAng ) / ( 1 - sideTractionMaxAng )

        return slipAngle < sideTractionMaxAng and sideTractionMax or ( sideTractionMax * ( 1 - x ) ) + ( sideTractionMin * x )
    end
end

-- Find and register all entities that are children of `base_glide`
-- (or any of it's children classes) on the duplicator/entity limit system.
-- Also make them spawnable on Starfall.
hook.Add( "InitPostEntity", "Glide.RegisterEntityClasses", function()
    local IsBasedOn = scripted_ents.IsBasedOn
    local RegisterEntityClass = duplicator.RegisterEntityClass

    local isStarfallAvailable = SF ~= nil
    local starfallData = { {} }

    for class, _ in pairs( scripted_ents.GetList() ) do
        if IsBasedOn( class, "base_glide" ) then
            RegisterEntityClass( class, Glide.VehicleFactory, "Data" )

            if isStarfallAvailable then
                list.Set( "starfall_creatable_sent", class, starfallData )
            end
        end
    end
end )

-- Call a hook when a player finishes loading into the server
-- and is ready to receive network events.
hook.Add( "ClientSignOnStateChanged", "Glide.TriggerOnPlayerLoad", function( user, _, new )
    if new ~= SIGNONSTATE_FULL then return end

    -- We can only retrieve the player entity after this hook runs, so lets use a timer.
    -- It could have been 0 seconds, its just higher here to put less strain on the network.
    timer.Simple( 3, function()
        local ply = Player( user )

        if IsValid( ply ) and not ply:IsBot() then
            ply.GlideLoaded = true
            hook.Run( "Glide_OnPlayerLoad", ply )
        end
    end )
end )

local IsValid = IsValid

function Glide.CanSpawnVehicle( ply )
    if hook.Run( "Glide_CanSpawnVehicle", ply ) == false then return false end

    if not IsValid( ply ) then return false end
    if not ply:CheckLimit( "glide_vehicles" ) then return false end

    return true
end

function Glide.VehicleFactory( ply, data )
    if not Glide.CanSpawnVehicle( ply ) then return end

    local ent = ents.Create( data.Class )
    if not IsValid( ent ) then return end

    ent:SetPos( data.Pos )
    ent:SetAngles( data.Angle )
    ent:SetCreator( ply )
    ent:Spawn()
    ent:Activate()

    ply:AddCount( "glide_vehicles", ent )
    cleanup.Add( ply, "glide_vehicles", ent )

    return ent
end

--- Check if a player can lock the vehicle by either
--- being it's creator or being a CPPI friend of the creator.
function Glide.CanLockVehicle( ply, vehicle )
    local creator = vehicle:GetCreator()

    if creator == ply then
        return true
    end

    if CPPI then
        if vehicle:CPPIGetOwner() == ply then
            return true
        end

        if vehicle:CPPICanPhysgun( ply ) then
            return true
        end
    end

    return hook.Run( "Glide_CanLockVehicle", ply, vehicle ) or false
end

--- Check if a player can enter a locked vehicle.
function Glide.CanEnterLockedVehicle( ply, vehicle )
    return hook.Run( "Glide_CanEnterLockedVehicle", ply, vehicle ) or Glide.CanLockVehicle( ply, vehicle )
end

--- Make a player switch to another seat
--- while inside a Glide vehicle.
function Glide.SwitchSeat( ply, seatIndex )
    if hook.Run( "Glide_CanSwitchSeat", ply, seatIndex ) == false then return end

    hook.Run( "Glide_PreSwitchSeat", ply, seatIndex )

    local vehicle = ply:GlideGetVehicle()
    if not IsValid( vehicle ) then return end

    local seat = vehicle.seats[seatIndex]
    if not IsValid( seat ) then
        ply:EmitSound( "player/suit_denydevice.wav", 50, 100, 1.0, 6, 0, 0 )
        return
    end

    if IsValid( seat:GetDriver() ) then
        ply:EmitSound( "player/suit_denydevice.wav", 50, 100, 1.0, 6, 0, 0 )
        return
    end

    ply.switchingseat = true
    ply:ExitVehicle()
    ply:SetAllowWeaponsInVehicle( false )
    timer.Simple(0.1, function()
        ply:EnterVehicle( seat )
        ply.switchingseat = nil
    end)

    hook.Run( "Glide_PostSwitchSeat", ply, seatIndex )
end

--- Finds and returns all human players near a certain position.
function Glide.GetNearbyPlayers( pos, radius )
    radius = radius * radius

    local found, count = {}, 0

    for _, ply in ipairs( player.GetHumans() ) do
        local dist = pos:DistToSqr( ply:GetPos() )

        if dist < radius then
            count = count + 1
            found[count] = ply
        end
    end

    return found, count
end
