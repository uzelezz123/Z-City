CreateConVar( "glide_input_pitch", "0", FCVAR_USERINFO + FCVAR_UNREGISTERED, "Transmit this pitch input to the server.", -1, 1 )
CreateConVar( "glide_input_yaw", "0", FCVAR_USERINFO + FCVAR_UNREGISTERED, "Transmit this yaw input to the server.", -1, 1 )
CreateConVar( "glide_input_roll", "0", FCVAR_USERINFO + FCVAR_UNREGISTERED, "Transmit this roll input to the server.", -1, 1 )

local MouseInput = Glide.MouseInput or {}

Glide.MouseInput = MouseInput

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.ActivateMouseInput", function()
    MouseInput:Activate()
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.DeactivateMouseInput", function()
    MouseInput:Deactivate()
end )

local Config = Glide.Config

function MouseInput:Activate()
    local vehicle = Glide.currentVehicle

    if not IsValid( vehicle ) or Glide.currentSeatIndex > 1 then
        self:Deactivate()
        return
    end

    -- If the local player is the pilot of a aircraft, with direct mouse flying enabled...

    if Glide.IsAircraft( vehicle ) and Config.mouseFlyMode == Glide.MOUSE_FLY_MODE.DIRECT then
        -- Activate mouse flying controls.
        self:Prepare()

        hook.Add( "HUDPaint", "Glide.DrawMouseInput", function()
            self:DrawFlyingHUD()
        end )

        hook.Add( "HG.InputMouseApply", "Glide.UpdateMouseInput", function( tbl )
            self:ApplyFlyingInput( tbl )
        end )

        return
    end

    -- If the local player is not on a aircraft, with direct mouse steering enabled...
    if
        not Glide.IsAircraft( vehicle )
        and Config.mouseSteerMode == Glide.MOUSE_STEER_MODE.DIRECT
        and vehicle:GetCameraType( 1 ) == Glide.CAMERA_TYPE.CAR
    then
        -- Activate mouse steering controls.
        self:Prepare()

        hook.Add( "HG.InputMouseApply", "Glide.UpdateMouseInput", function( tbl )
            self:ApplySteeringInput( tbl )
        end )

        return
    end

    -- If none of the checks above returned early,
    -- then no mouse input should be active client-side.
    self:Deactivate()
end

function MouseInput:Prepare()
    self.mouse = { 0, 0 }
    self.freeLook = false
    self:Reset()

    self.cvarPitch = GetConVar( "glide_input_pitch" )
    self.cvarYaw = GetConVar( "glide_input_yaw" )
    self.cvarRoll = GetConVar( "glide_input_roll" )

    hook.Add( "Think", "Glide.UpdateMouseInput", function()
        local freeLook = input.IsKeyDown( Config.binds.general_controls.free_look ) or vgui.CursorVisible()

        if self.freeLook ~= freeLook then
            self.freeLook = freeLook
            self:Reset()
        end
    end )
end

function MouseInput:Deactivate()
    hook.Remove( "HG.InputMouseApply", "Glide.UpdateMouseInput" )
    hook.Remove( "Think", "Glide.UpdateMouseInput" )
    hook.Remove( "HUDPaint", "Glide.DrawMouseInput" )
end

function MouseInput:Reset()
    self.mouse[1] = 0
    self.mouse[2] = 0

    if not self.cvarPitch then return end

    self.cvarPitch:SetFloat( 0 )
    self.cvarYaw:SetFloat( 0 )
    self.cvarRoll:SetFloat( 0 )
end

local Abs = math.abs
local Clamp = math.Clamp

local function ProcessInput( axis, mouse, deadzone )
    if axis == 0 then return 0 end

    local value = mouse[axis]
    if Abs( value ) < deadzone then return 0 end

    return value
end

function MouseInput:ApplyFlyingInput( tbl )
    local x, y = tbl.x, tbl.y
    if self.freeLook then return end

    x = Config.mouseInvertX and -x or x
    y = Config.mouseInvertY and -y or y

    local mouse = self.mouse
    local deadzone = Config.mouseDeadzone

    mouse[1] = Clamp( mouse[1] + x * Config.mouseSensitivityX * 0.01, -1, 1 )
    mouse[2] = Clamp( mouse[2] - y * Config.mouseSensitivityY * 0.01, -1, 1 )

    local pitch = ProcessInput( Config.pitchMouseAxis, mouse, deadzone )
    local yaw = ProcessInput( Config.yawMouseAxis, mouse, deadzone )
    local roll = ProcessInput( Config.rollMouseAxis, mouse, deadzone )

    self.cvarPitch:SetFloat( pitch )
    self.cvarYaw:SetFloat( yaw )
    self.cvarRoll:SetFloat( roll )
end

local ExpDecay = Glide.ExpDecay

function MouseInput:ApplySteeringInput( tbl )
    local x = tbl.x
    if self.freeLook then return end

    local mouse = self.mouse

    mouse[1] = Clamp( mouse[1] + x * Config.mouseSteerSensitivity * 0.01, -1, 1 )
    mouse[1] = ExpDecay( mouse[1], 0, Config.mouseSteerDecayRate, FrameTime() )
    mouse[2] = 0

    -- Make low values "ramp up" slightly faster
    local steer = math.pow( Abs( mouse[1] ), 0.8 )
    if mouse[1] < 0 then steer = -steer end

    self.cvarPitch:SetFloat( steer )
end

local ScrW, ScrH = ScrW, ScrH
local SetColor = surface.SetDrawColor
local SetMaterial = surface.SetMaterial

local DrawRect = surface.DrawRect
local DrawTexturedRectRotated = surface.DrawTexturedRectRotated

local MAT_BACKGROUND = Material( "glide/mouse_area.png", "smooth" )
local MAT_JOYSTICK = Material( "glide/mouse_joystick.png", "smooth" )

function MouseInput:DrawFlyingHUD()
    if not Config.mouseShow then return end
    if self.freeLook then return end

    local sw, sh = ScrW(), ScrH()
    local size = sh * 0.1

    local x = sw * 0.5
    local y = sh * 0.9

    SetColor( 50, 50, 50, 180 )

    local deadzoneSize = size * Config.mouseDeadzone

    DrawRect( x - size * 0.5, y - deadzoneSize * 0.5, size, deadzoneSize )
    DrawRect( x - deadzoneSize * 0.5, y - size * 0.5, deadzoneSize, size )

    SetColor( 255, 255, 255, 255 )
    SetMaterial( MAT_BACKGROUND )
    DrawTexturedRectRotated( x, y, size, size, 0 )

    size = size * 0.25

    local mouse = self.mouse

    SetMaterial( MAT_JOYSTICK )
    DrawTexturedRectRotated( x + mouse[1] * size * 2, y - mouse[2] * size * 2, size, size, 0 )
end
