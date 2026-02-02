local Camera = Glide.Camera or {}

Glide.Camera = Camera

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.ActivateCamera", function( vehicle, seatIndex )
    Camera:Activate( vehicle, seatIndex )
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.DeactivateCamera", function()
    Camera:Deactivate()
end )

Camera.lastAimEntity = NULL
Camera.lastAimPos = Vector()

Camera.viewAngles = Angle()
Camera.isInFirstPerson = false
Camera.FIRST_PERSON_DSP = 30

function Glide.GetCameraAimPos()
    return Camera.lastAimPos
end

local Config = Glide.Config

function Camera:Activate( vehicle, seatIndex )
    Config = Glide.Config

    self.user = LocalPlayer()
    self.vehicle = vehicle
    self.seatIndex = seatIndex

    self.fov = 80
    self.origin = Vector()
    self.angles = vehicle:GetAngles()

    self.isActive = false
    self.isUsingDirectMouse = false
    self.allowRolling = false

    self.centerStrength = 0
    self.lastMouseMoveTime = 0
    self.traceFraction = 1
    self.trailerFraction = 0

    self.punchAngle = Angle()
    self.punchVelocity = Angle()
    self.shakeOffset = Vector()

    self:SetFirstPerson( self.isInFirstPerson )

    hook.Add( "Think", "GlideCamera.Think", function()
        if self.isActive then return self:Think() end
    end )

    hook.Add( "HG_CalcView", "GlideCamera.CalcView", function()
        //if self.isActive then return self:CalcView() end
    end, HOOK_HIGH )

    hook.Add( "CreateMove", "GlideCamera.CreateMove", function( cmd )
        if self.isActive then return self:CreateMove( cmd ) end
    end, HOOK_HIGH )

    hook.Add( "HG.InputMouseApply", "GlideCamera.InputMouseApply", function( tbl )
        self:InputMouseApply( tbl )
    end, HOOK_HIGH )

    hook.Add( "PlayerBindPress", "GlideCamera.PlayerBindPress", function( ply, bind )
        if ply == self.user and ( bind == "+right" or bind == "+left" ) then return false end
    end )

    timer.Create( "GlideCamera.CheckState", 0.2, 0, function()
        self.isActive = self:ShouldBeActive()

        local seat = self.user:GetVehicle()

        if IsValid( seat ) and not self.seat then
            self.seat = seat
            self.angles = seat:GetAngles() + Angle( 0, 90, 0 )
            self.angles[3] = 0
        end
    end )
end

function Camera:Deactivate()
    timer.Remove( "GlideCamera.CheckState" )

    hook.Remove( "Think", "GlideCamera.Think" )
    hook.Remove( "CalcView", "GlideCamera.CalcView" )
    hook.Remove( "CreateMove", "GlideCamera.CreateMove" )
    hook.Remove( "HG.InputMouseApply", "GlideCamera.InputMouseApply" )
    hook.Remove( "PlayerBindPress", "GlideCamera.PlayerBindPress" )

    if IsValid( self.vehicle ) then
        self.vehicle.isLocalPlayerInFirstPerson = false
    end

    if IsValid( self.user ) then
        self.user:SetDSP( 1 )
        //self.user:SetEyeAngles( Angle() )
    end

    self.isActive = false
    self.user = nil
    self.vehicle = nil
    self.seatIndex = nil
    self.seat = nil
end

function Camera:IsFixed()
    local fixedMode = Config.fixedCameraMode
    if fixedMode < 1 then return false end

    -- Fixed on first person only
    if fixedMode == 1 and self.isInFirstPerson then return true end

    -- Fixed on third person only
    if fixedMode == 2 and not self.isInFirstPerson then return true end

    -- Fixed on both first and third person
    return fixedMode > 2
end

function Camera:SetFirstPerson( enable )
    local angles = self.angles
    local wasFixed = self:IsFixed()

    self.isInFirstPerson = enable
    self.centerStrength = 0
    self.lastMouseMoveTime = 0

    local muffleSound = self.isInFirstPerson
    local vehicle = self.vehicle

    if IsValid( vehicle ) then
        vehicle.isLocalPlayerInFirstPerson = enable
        muffleSound = muffleSound and vehicle:AllowFirstPersonMuffledSound( self.seatIndex )

        if self:IsFixed() ~= wasFixed then
            if wasFixed then
                self.angles = vehicle:LocalToWorldAngles( angles )
            else
                self.angles = vehicle:WorldToLocalAngles( angles )
            end
        end
    end

    if IsValid( self.user ) then
        self.user:SetDSP( muffleSound and self.FIRST_PERSON_DSP or 1 )
    end
end

local IsValid = IsValid

function Camera:ShouldBeActive()
    if not IsValid( self.vehicle ) then
        return false
    end

    if not self.user:Alive() then
        return false
    end

    if self.user:GetViewEntity() ~= self.user then
        return false
    end

    if pace and pace.Active then
        return false
    end

    return true
end

local Abs = math.abs

function Camera:ViewPunch( pitch, yaw, roll )
    if not self.isActive then return end

    pitch = self.isInFirstPerson and pitch * 2 or pitch
    if Abs( pitch ) < Abs( self.punchVelocity[1] ) then return end

    self.punchVelocity[1] = pitch
    self.punchVelocity[2] = yaw or 0
    self.punchVelocity[3] = roll or 0

    self.punchAngle[1] = 0
    self.punchAngle[2] = 0
    self.punchAngle[3] = 0
end

local RealTime = RealTime
local FrameTime = FrameTime

local Cos = math.cos
local Clamp = math.Clamp
local IsKeyDown = input.IsKeyDown

local ExpDecay = Glide.ExpDecay
local ExpDecayAngle = Glide.ExpDecayAngle

local CAMERA_TYPE = Glide.CAMERA_TYPE
local MOUSE_FLY_MODE = Glide.MOUSE_FLY_MODE
local MOUSE_STEER_MODE = Glide.MOUSE_STEER_MODE

function Camera:DoEffects( t, dt, speed )
    -- Update view punch
    local vel, ang = self.punchVelocity, self.punchAngle

    ang[1] = ExpDecay( ang[1], 0, 6, dt ) + vel[1]
    ang[2] = ExpDecay( ang[2], 0, 6, dt ) + vel[2]

    local decay = self.isInFirstPerson and 8 or 10
    vel[1] = ExpDecay( vel[1], 0, decay, dt )
    vel[2] = ExpDecay( vel[2], 0, decay, dt )

    -- Update FOV depending on speed
    speed = speed - 400

    local fov = ( self.isInFirstPerson and Config.cameraFOVInternal or Config.cameraFOVExternal ) + Clamp( speed * 0.01, 0, 15 )
    local keyZoom = self.user:KeyDown( IN_ZOOM )

    self.fov = ExpDecay( self.fov, keyZoom and 20 or fov, keyZoom and 5 or 2, dt )

    -- Apply a small shake
    if self.mode == CAMERA_TYPE.CAR then
        local mult = Clamp( speed * 0.0005, 0, 1 ) * Config.shakeStrength

        self.shakeOffset[2] = Cos( t * 1.5 ) * 4 * mult
        self.shakeOffset[3] = ( ( Cos( t * 2 ) * 1.8 ) + ( Cos( t * 30 ) * 0.4 ) ) * mult
    end
end

function Camera:Think()
    local vehicle = self.vehicle

    if not IsValid( vehicle ) then
        self:Deactivate()
        return
    end

    -- Toggle first person
    local isSwitchKeyDown = self.user:KeyDown( IN_DUCK ) and not vgui.CursorVisible()

    if self.isSwitchKeyDown ~= isSwitchKeyDown then
        self.isSwitchKeyDown = isSwitchKeyDown

        if isSwitchKeyDown then
            self:SetFirstPerson( not self.isInFirstPerson )
        end
    end

    local t = RealTime()
    local dt = FrameTime()

    self.traceFraction = ExpDecay( self.traceFraction, 1, 2, dt )
    self.trailerFraction = ExpDecay( self.trailerFraction, vehicle:GetConnectedReceptacleCount() > 0 and 1 or 0, 2, dt )

    local angles = self.angles
    local velocity = vehicle:GetVelocity()
    local speed = Abs( velocity:Length() )
    local mode = vehicle:GetCameraType( self.seatIndex )
    local freeLook = IsKeyDown( Config.binds.general_controls.free_look )

    self.mode = mode
    self:DoEffects( t, dt, speed )

    if self:IsFixed() then
        if mode == CAMERA_TYPE.AIRCRAFT then
            self.isUsingDirectMouse = Config.mouseFlyMode == MOUSE_FLY_MODE.DIRECT and self.seatIndex == 1 and not freeLook

        elseif mode ~= CAMERA_TYPE.TURRET then
            self.isUsingDirectMouse = Config.mouseSteerMode == MOUSE_STEER_MODE.DIRECT and self.seatIndex == 1 and not freeLook
        end

        return
    end

    local vehicleAngles = vehicle:GetAngles()
    local decay, rollDecay = 3, 3

    if mode == CAMERA_TYPE.TURRET then
        self.centerStrength = 0
        self.allowRolling = false
        decay = 0

    elseif mode == CAMERA_TYPE.AIRCRAFT then
        self.isUsingDirectMouse = Config.mouseFlyMode == MOUSE_FLY_MODE.DIRECT and self.seatIndex == 1 and not freeLook
        self.allowRolling = Config.mouseFlyMode ~= MOUSE_FLY_MODE.AIM

        -- Only make the camera angles point towards the vehicle's
        -- forward direction while moving.
        decay = ( self.isUsingDirectMouse or self.isInFirstPerson ) and 6 or Clamp( ( speed - 5 ) * 0.01, 0, 1 ) * 3
        decay = decay * self.centerStrength

    else
        self.isUsingDirectMouse = Config.mouseSteerMode == MOUSE_STEER_MODE.DIRECT and self.seatIndex == 1 and not freeLook

        if self.isUsingDirectMouse then
            self.allowRolling = self.isInFirstPerson

            -- Make the camera angles always point towards
            -- the vehicle's forward direction.
            decay = 6 * self.centerStrength
            rollDecay = 8

        elseif self.isInFirstPerson then
            self.allowRolling = true

            -- Only make the camera angles point towards the vehicle's
            -- forward direction while moving.
            decay = Clamp( ( speed - 5 ) * 0.002, 0, 1 ) * 8 * self.centerStrength
            rollDecay = 8
        else
            self.allowRolling = false

            vehicleAngles = velocity:Angle()
            vehicleAngles[1] = vehicleAngles[1] + 5 * self.trailerFraction
            vehicleAngles[3] = 0

            -- Only make the camera angles point towards the vehicle's
            -- forward direction while moving.
            decay = Clamp( ( speed - 10 ) * 0.002, 0, 1 ) * 4 * self.centerStrength
        end
    end

    if self.allowRolling then
        -- Roll the camera so it stays "upright" relative to the vehicle
        vehicleAngles[3] = vehicleAngles[3] * vehicle:GetForward():Dot( angles:Forward() )
    end

    angles[1] = ExpDecayAngle( angles[1], vehicleAngles[1], decay, dt )
    angles[2] = ExpDecayAngle( angles[2], vehicleAngles[2], decay, dt )
    angles[3] = ExpDecayAngle( angles[3], self.allowRolling and vehicleAngles[3] or 0, rollDecay, dt )

    -- Recenter if using "Control movement directly" mouse setting,
    -- or if some time has passed since last time we moved the mouse.
    if
        self.isUsingDirectMouse or (
            Config.enableAutoCenter and
            mode ~= CAMERA_TYPE.TURRET and
            t > self.lastMouseMoveTime + Config.autoCenterDelay and
            ( Config.mouseFlyMode ~= MOUSE_FLY_MODE.AIM or mode == CAMERA_TYPE.CAR or self.seatIndex > 1 ) and
            ( Config.mouseSteerMode ~= MOUSE_STEER_MODE.AIM or self.seatIndex > 1 )
        )
    then
        self.centerStrength = ExpDecay( self.centerStrength, 1, 2, dt )
    end
end

local TraceLine = util.TraceLine

function Camera:CalcView()
    local vehicle = self.vehicle
    if not IsValid( vehicle ) then return end

    local user = self.user
    local angles = self.angles

    if self:IsFixed() then
        -- Force to stay behind the vehicle while
        -- using direct mouse flying/steering mode.
        if self.isUsingDirectMouse then
            angles[1] = 0
            angles[2] = 0
        end

        angles[3] = 0
        angles = vehicle:LocalToWorldAngles( angles )
    end

    if self.isInFirstPerson then
        local localEyePos = vehicle:WorldToLocal( user:EyePos() )
        local localPos = vehicle:GetFirstPersonOffset( self.seatIndex, localEyePos )
        self.origin = vehicle:LocalToWorld( localPos )
    else
        local fraction = self.traceFraction
        local offset = self.shakeOffset + vehicle.CameraOffset * Vector( Config.cameraDistance, 1, Config.cameraHeight ) * fraction
        local startPos = vehicle:LocalToWorld( vehicle.CameraCenterOffset + vehicle.CameraTrailerOffset * self.trailerFraction )

        angles = angles + vehicle.CameraAngleOffset

        local endPos = startPos
            + angles:Forward() * offset[1] * ( 1 + self.trailerFraction * vehicle.CameraTrailerDistanceMultiplier )
            + angles:Right() * offset[2]
            + angles:Up() * offset[3]

        local dir = endPos - startPos
        dir:Normalize()

        -- Make sure the camera stays outside of walls
        local tr = TraceLine( {
            start = startPos,
            endpos = endPos + dir * 10,
            mask = 16395 -- MASK_SOLID_BRUSHONLY
        } )

        if tr.Hit then
            endPos = tr.HitPos - dir * 10

            if tr.Fraction < fraction then
                self.traceFraction = tr.Fraction
            end
        end

        self.origin = endPos
    end

    -- Update aim position and entity
    local origin = self.origin

    local tr = TraceLine( {
        start = origin,
        endpos = origin + angles:Forward() * 50000,
        filter = { user, vehicle }
    } )

    self.lastAimEntity = tr.Entity
    self.lastAimPos = tr.HitPos

    -- Make the player's EyeAngles look at the same spot as the camera
    local aimDir = self.lastAimPos - user:EyePos()
    aimDir:Normalize()
    self.viewAngles = aimDir:Angle()

    return {
        origin = origin,
        angles = angles + self.punchAngle,
        fov = self.fov,
        drawviewer = not self.isInFirstPerson
    }
end

function Camera:CreateMove( cmd )
    //cmd:SetViewAngles( self.viewAngles )
end

function Camera:InputMouseApply( tbl )
    local x, y = tbl.x, tbl.y
    local vehicle = self.vehicle
    if not IsValid( vehicle ) then return end
    if self.isUsingDirectMouse then return end

    local sensitivity = Config.lookSensitivity
    local lookX = ( Config.cameraInvertX and -x or x ) * 0.05 * sensitivity
    local lookY = ( Config.cameraInvertY and -y or y ) * 0.05 * sensitivity

    if Abs( lookX ) + Abs( lookY ) > 0.1 then
        self.lastMouseMoveTime = RealTime()
        self.centerStrength = 0
    end

    local angles = self.allowRolling and vehicle:WorldToLocalAngles( self.angles ) or self.angles

    angles[1] = Clamp( angles[1] + lookY, -80, 60 )
    angles[2] = ( angles[2] - lookX ) % 360
    
    self.angles = self.allowRolling and vehicle:LocalToWorldAngles( angles ) or angles
end
