local IsValid = IsValid

function ENT:SocketInit()
    self.socketCount = #self.Sockets
    Glide.TrackVehicleSockets( self )
end

local function AttemptConnection( plug, phys, dt )
    local receptacle = plug.attemptReceptacle
    local plugVeh = plug.vehicle
    local receptacleVeh = receptacle.vehicle

    -- Make sure the the other vehicle is still valid,
    -- otherwise stop the attempt.
    if not IsValid( receptacleVeh ) then
        plug.attemptReceptacle = nil
        return
    end

    -- Make sure the plug is still in range of the receptacle,
    -- otherwise stop the attempt.
    local plugPos = plugVeh:LocalToWorld( plug.offset )
    local receptaclePos = receptacleVeh:LocalToWorld( receptacle.offset )
    local distFactor = receptaclePos:Distance( plugPos ) / 80

    if distFactor > 1 then
        plug.attemptReceptacle = nil
        return
    end

    -- If we're close enough, connect now
    if distFactor < 0.02 then
        plug.attemptReceptacle = nil
        Glide.SocketConnect( plug, receptacle, receptacle.forceLimit or 80000 )

        return
    end

    -- Try to push the plug towards the receptacle
    local dir = receptaclePos - plugPos
    dir:Normalize()

    local force = dir * ( plug.connectForce or 700 )

    force = force - phys:GetVelocityAtPoint( plugPos ) * ( plug.connectDrag or 15 )
    distFactor = 1 - distFactor

    phys:ApplyForceOffset( force * distFactor * phys:GetMass() * dt, plugPos )
end

function ENT:SocketThink( dt, time )
    local phys = self:GetPhysicsObject()
    if not IsValid( phys ) then return end

    for _, socket in ipairs( self.Sockets ) do

        -- If this is a plug socket that has a nearby receptacle...
        if
            not socket.isReceptacle and
            socket.attemptReceptacle and
            time > ( socket.nextAttemptTime or 0 )
        then
            -- Try to connect to it
            AttemptConnection( socket, phys, dt )
        end

        -- Check if the socket constrain has been broken
        if socket.constraint == NULL then
            socket.constraint = nil

            -- Prevent reconnecting right away
            if not socket.isReceptacle then
                socket.nextAttemptTime = time + 3
            end

            self:UpdateSocketCount()
            self:OnSocketDisconnect( socket )
        end

    end
end

function ENT:DisconnectAllSockets()
    for _, socket in ipairs( self.Sockets ) do
        if IsValid( socket.constraint ) then
            socket.constraint:Remove()
        end
    end
end

function ENT:UpdateSocketCount()
    local connectedReceptacles = 0

    for _, socket in ipairs( self.Sockets ) do
        if socket.isReceptacle and IsValid( socket.constraint ) then
            connectedReceptacles = connectedReceptacles + 1
        end
    end

    self:SetConnectedReceptacleCount( connectedReceptacles )
end
