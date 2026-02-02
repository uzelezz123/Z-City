--[[
    Keep track of all vehicles with sockets
    for the trailer attachment system.

    This file also has logic to detect
    when two sockets are close to eachother.
]]

--- Utility function to connect two vehicle sockets together.
function Glide.SocketConnect( plug, receptacle, forceLimit )
    local plugVeh = plug.vehicle
    local receptacleVeh = receptacle.vehicle

    -- Make sure both vehicles are valid
    if not IsValid( plugVeh ) then return end
    if not IsValid( receptacleVeh ) then return end

    -- Remove existing plug constaint
    if IsValid( plug.constraint ) then
        plug.constraint:Remove()
    end

    -- Remove existing receptacle constaint
    if IsValid( receptacle.constraint ) then
        receptacle.constraint:Remove()
    end

    -- Try to create a ballsocket constaint
    local constr = constraint.Ballsocket( plugVeh, receptacleVeh, 0, 0, receptacle.offset, forceLimit, 0, 0 )
    if not IsValid( constr ) then return end

    constr.DoNotDuplicate = true
    constr.DisableDuplicator = true

    -- Store constraint on both sockets
    plug.constraint = constr
    receptacle.constraint = constr

    -- Call events on both vehicles
    plugVeh:UpdateSocketCount()
    receptacleVeh:UpdateSocketCount()

    plugVeh:OnSocketConnect( plug, receptacleVeh )
    receptacleVeh:OnSocketConnect( receptacle, plugVeh )
end

local vehiclesWithSockets = Glide.vehiclesWithSockets or {}
Glide.vehiclesWithSockets = vehiclesWithSockets

function Glide.TrackVehicleSockets( vehicle )
    if vehicle.socketCount > 0 then
        vehiclesWithSockets[#vehiclesWithSockets + 1] = vehicle
    end
end

-- Utility function to find the closest socket to `pos` from a table.
do
    local dist, closestDist, closestSocket

    function Glide.FindClosestSocket( pos, radius, idFilter, tbl )
        closestDist = radius * radius
        closestSocket = nil

        for _, socket in ipairs( tbl ) do
            dist = pos:DistToSqr( socket.pos )

            if dist < closestDist and socket.id == idFilter then
                closestDist = dist
                closestSocket = socket
            end
        end

        return closestSocket, closestDist
    end
end

local IsValid = IsValid
local Remove = table.remove

local FindClosestSocket = Glide.FindClosestSocket
local GetDevMode = Glide.GetDevMode

timer.Create( "Glide.UpdateSockets", 0.1, 0, function()
    local vehicleCount = #vehiclesWithSockets
    if vehicleCount == 0 then return end

    local receptacles, plugs = {}, {}
    local rCount, pCount = 0, 0
    local vehicle

    for i = vehicleCount, 1, -1 do
        vehicle = vehiclesWithSockets[i]

        if IsValid( vehicle ) then
            for socketIndex, socket in ipairs( vehicle.Sockets ) do

                -- Update the socket's current world position
                socket.pos = vehicle:LocalToWorld( socket.offset )

                -- We need to know which vehicle owns this socket on the loop below
                socket.index = socketIndex
                socket.vehicle = vehicle

                -- Separate receptacle/plug sockets from this vehicle
                if socket.isReceptacle == true then
                    rCount = rCount + 1
                    receptacles[rCount] = socket
                else
                    pCount = pCount + 1
                    plugs[pCount] = socket
                end

            end
        else
            -- Remove invalid vehicles
            Remove( vehiclesWithSockets, i )
        end
    end

    -- For each plug...
    for _, plug in ipairs( plugs ) do
        vehicle = plug.vehicle

        -- If this plug is not connected yet...
        if not IsValid( plug.constraint ) then
            -- Find the closest receptacle to this plug
            local receptacle = FindClosestSocket( plug.pos, 80, plug.id, receptacles )

            if receptacle then
                -- Let the vehicle with this plug try to connect
                -- with the nearby receptacle.
                plug.attemptReceptacle = receptacle
            end
        end
    end

    -- Draw debug overlays, if `developer` cvar is active
    if not GetDevMode() then return end

    for _, v in ipairs( receptacles ) do
        debugoverlay.Cross( v.pos, 8, 0.1, Color( 255, 145, 0 ), true )
        debugoverlay.Text( v.pos, v.id .. " | isReceptacle: true", 0.1, false )
    end

    for _, v in ipairs( plugs ) do
        debugoverlay.Cross( v.pos, 8, 0.1, Color( 255, 145, 0 ), true )
        debugoverlay.Text( v.pos, v.id .. " | isReceptacle: false", 0.1, false )
    end
end )
