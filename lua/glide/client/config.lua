local Config = Glide.Config or {}

Glide.Config = Config

--- Reset settings to their default values.
function Config:Reset()
    self.version = 2

    -- Audio settings
    self.carVolume = 1.0
    self.aircraftVolume = 1.0
    self.explosionVolume = 1.0
    self.hornVolume = 1.0
    self.windVolume = 0.7
    self.warningVolume = 0.8
    self.vcVolume = 0.4

    -- Camera settings
    self.lookSensitivity = 1.0
    self.cameraInvertX = false
    self.cameraInvertY = false

    self.cameraDistance = 1.0
    self.cameraHeight = 1.0
    self.cameraFOVInternal = GetConVar( "fov_desired" ):GetFloat()
    self.cameraFOVExternal = GetConVar( "fov_desired" ):GetFloat()

    self.fixedCameraMode = 0
    self.enableAutoCenter = true
    self.autoCenterDelay = 1.5
    self.shakeStrength = 1.0

    -- Mouse settings
    self.mouseFlyMode = Glide.MOUSE_FLY_MODE.AIM
    self.mouseSensitivityX = 1.0
    self.mouseSensitivityY = 1.0
    self.mouseInvertX = false
    self.mouseInvertY = false

    self.pitchMouseAxis = 2 -- Y
    self.yawMouseAxis = 0 -- None
    self.rollMouseAxis = 1 -- X
    self.mouseDeadzone = 0.15
    self.mouseShow = true

    self.mouseSteerMode = Glide.MOUSE_STEER_MODE.DISABLED
    self.mouseSteerSensitivity = 0.5
    self.mouseSteerDecayRate = 1.5

    -- Performance settings
    self.maxSkidMarkPieces = 500
    self.maxTireRollPieces = 400
    self.skidmarkTimeLimit = 15

    self.headlightShadows = true
    self.reduceTireParticles = false

    -- HUD settings
    self.showHUD = true
    self.showPassengerList = true
    self.showCustomHealth = true
    self.showEmptyVehicleHealth = false
    self.showSkybox = true
    self.useKMH = false

    -- Misc. settings
    self.manualGearShifting = false
    self.throttleModifierMode = 0
    self.autoHeadlightOn = true
    self.autoHeadlightOff = true
    self.autoTurnOffLights = true
    self.enableTips = true
end

--- Reset bind actions to their default buttons.
function Config:ResetBinds()
    local binds = {}

    -- Setup default action groups and buttons
    for groupId, actions in pairs( Glide.InputGroups ) do
        binds[groupId] = {}

        for action, button in pairs( actions ) do
            binds[groupId][action] = button
        end
    end

    self.binds = binds
end

-- Utility function to get the button bound to a certain input action.
function Config:GetInputActionButton( action, groupId )
    local group = self.binds[groupId]
    if group then
        return group[action]
    end
end

--- Save settings to disk.
function Config:Save( immediate )
    timer.Remove( "Glide.SaveConfig" )

    if not immediate then
        -- Don't spam when this function gets called in quick succession
        timer.Create( "Glide.SaveConfig", 1, 1, function()
            self:Save( true )
        end )

        return
    end

    local data = Glide.ToJSON( {
        version = self.version,

        -- Audio settings
        carVolume = self.carVolume,
        aircraftVolume = self.aircraftVolume,
        explosionVolume = self.explosionVolume,
        hornVolume = self.hornVolume,
        windVolume = self.windVolume,
        warningVolume = self.warningVolume,
        vcVolume = self.vcVolume,

        -- Camera settings
        lookSensitivity = self.lookSensitivity,
        cameraInvertX = self.cameraInvertX,
        cameraInvertY = self.cameraInvertY,

        cameraDistance = self.cameraDistance,
        cameraHeight = self.cameraHeight,
        cameraFOVInternal = self.cameraFOVInternal,
        cameraFOVExternal = self.cameraFOVExternal,

        fixedCameraMode = self.fixedCameraMode,
        enableAutoCenter = self.enableAutoCenter,
        autoCenterDelay = self.autoCenterDelay,
        shakeStrength = self.shakeStrength,

        -- Mouse settings
        mouseFlyMode = self.mouseFlyMode,
        mouseSensitivityX = self.mouseSensitivityX,
        mouseSensitivityY = self.mouseSensitivityY,
        mouseInvertX = self.mouseInvertX,
        mouseInvertY = self.mouseInvertY,

        mouseSteerMode = self.mouseSteerMode,
        mouseSteerSensitivity = self.mouseSteerSensitivity,
        mouseSteerDecayRate = self.mouseSteerDecayRate,

        pitchMouseAxis = self.pitchMouseAxis,
        yawMouseAxis = self.yawMouseAxis,
        rollMouseAxis = self.rollMouseAxis,
        mouseDeadzone = self.mouseDeadzone,
        mouseShow = self.mouseShow,

        -- Performance settings
        maxSkidMarkPieces = self.maxSkidMarkPieces,
        maxTireRollPieces = self.maxTireRollPieces,
        skidmarkTimeLimit = self.skidmarkTimeLimit,

        headlightShadows = self.headlightShadows,
        reduceTireParticles = self.reduceTireParticles,

        -- Misc. settings
        showHUD = self.showHUD,
        showPassengerList = self.showPassengerList,
        showCustomHealth = self.showCustomHealth,
        showEmptyVehicleHealth = self.showEmptyVehicleHealth,
        showSkybox = self.showSkybox,
        useKMH = self.useKMH,

        manualGearShifting = self.manualGearShifting,
        throttleModifierMode = self.throttleModifierMode,
        autoHeadlightOn = self.autoHeadlightOn,
        autoHeadlightOff = self.autoHeadlightOff,
        autoTurnOffLights = self.autoTurnOffLights,
        enableTips = self.enableTips,

        -- Group-to-action-to-button dictionary
        binds = self.binds
    }, true )

    Glide.SaveDataFile( "glide.json", data )

    hook.Run( "Glide_OnConfigChange" )
end

--- Check if the config. data requires migration to a new version.
function Config:CheckVersion( data )
    if type( data.version ) ~= "number" then
        Glide.Print( "glide.json: Pre-release version or no version found." )
        Glide.Print( "glide.json: Resetting all settings to default." )
        return {}
    end

    local upgraded = false

    if data.version == 1 then
        -- Reset to new default "detach_trailer" bind to avoid conflict with "switch gear up" key
        if type( data.binds ) == "table" and data.binds.land_controls and data.binds.land_controls.detach_trailer then
            data.binds.land_controls.detach_trailer = nil
        end

        upgraded = true
    end

    if upgraded then
        Glide.Print( "glide.json: Upgraded from version %i", data.version )
    else
        Glide.PrintDev( "glide.json: Version %i", data.version )
    end

    return data
end

--- Load settings from disk.
function Config:Load()
    self:Reset()
    self:ResetBinds()

    local data = Glide.FromJSON( Glide.LoadDataFile( "glide.json" ) )
    local SetNumber = Glide.SetNumber

    local LoadBool = function( k, default )
        self[k] = Either( data[k] == nil, default, data[k] == true )
    end

    data = self:CheckVersion( data )

    -- Audio settings
    SetNumber( self, "carVolume", data.carVolume, 0, 1, self.carVolume )
    SetNumber( self, "aircraftVolume", data.aircraftVolume, 0, 1, self.aircraftVolume )
    SetNumber( self, "explosionVolume", data.explosionVolume, 0, 1, self.explosionVolume )
    SetNumber( self, "hornVolume", data.hornVolume, 0, 1, self.hornVolume )
    SetNumber( self, "windVolume", data.windVolume, 0, 1, self.windVolume )
    SetNumber( self, "warningVolume", data.warningVolume, 0, 1, self.warningVolume )
    SetNumber( self, "vcVolume", data.vcVolume, 0, 1, self.vcVolume )

    -- Camera settings
    SetNumber( self, "lookSensitivity", data.lookSensitivity, 0.01, 5, self.lookSensitivity )
    LoadBool( "cameraInvertX", false )
    LoadBool( "cameraInvertY", false )

    SetNumber( self, "cameraDistance", data.cameraDistance, 0.5, 3, self.cameraDistance )
    SetNumber( self, "cameraHeight", data.cameraHeight, 0.25, 2, self.cameraHeight )
    SetNumber( self, "cameraFOVInternal", data.cameraFOVInternal, 30, 120, self.cameraFOVInternal )
    SetNumber( self, "cameraFOVExternal", data.cameraFOVExternal, 30, 120, self.cameraFOVExternal )
    SetNumber( self, "fixedCameraMode", data.fixedCameraMode, 0, 3, self.fixedCameraMode )

    LoadBool( "enableAutoCenter", true )
    SetNumber( self, "autoCenterDelay", data.autoCenterDelay, 0.1, 5, self.autoCenterDelay )
    SetNumber( self, "shakeStrength", data.shakeStrength, 0, 2, self.shakeStrength )

    -- Mouse settings
    self.mouseFlyMode = math.Round( Glide.ValidateNumber( data.mouseFlyMode, 0, 2, self.mouseFlyMode ) )
    LoadBool( "mouseInvertX", false )
    LoadBool( "mouseInvertY", false )
    LoadBool( "mouseShow", true )

    SetNumber( self, "mouseSensitivityX", data.mouseSensitivityX, 0.05, 5, self.mouseSensitivityX )
    SetNumber( self, "mouseSensitivityY", data.mouseSensitivityY, 0.05, 5, self.mouseSensitivityY )
    SetNumber( self, "pitchMouseAxis", data.pitchMouseAxis, 0, 2, self.pitchMouseAxis )
    SetNumber( self, "yawMouseAxis", data.yawMouseAxis, 0, 2, self.yawMouseAxis )
    SetNumber( self, "rollMouseAxis", data.rollMouseAxis, 0, 2, self.rollMouseAxis )
    SetNumber( self, "mouseDeadzone", data.mouseDeadzone, 0, 1, self.mouseDeadzone )

    self.mouseSteerMode = math.Round( Glide.ValidateNumber( data.mouseSteerMode, 0, 2, self.mouseSteerMode ) )
    SetNumber( self, "mouseSteerSensitivity", data.mouseSteerSensitivity, 0.05, 3, self.mouseSteerSensitivity )
    SetNumber( self, "mouseSteerDecayRate", data.mouseSteerDecayRate, 0, 3, self.mouseSteerDecayRate )

    -- Performance settings
    SetNumber( self, "maxSkidMarkPieces", data.maxSkidMarkPieces, 0, 1000, self.maxSkidMarkPieces )
    SetNumber( self, "maxTireRollPieces", data.maxTireRollPieces, 0, 1000, self.maxTireRollPieces )
    SetNumber( self, "skidmarkTimeLimit", data.skidmarkTimeLimit, 3, 300, self.skidmarkTimeLimit )

    LoadBool( "headlightShadows", true )
    LoadBool( "reduceTireParticles", false )

    -- Misc. settings
    LoadBool( "showHUD", true )
    LoadBool( "showPassengerList", true )
    LoadBool( "showCustomHealth", true )
    LoadBool( "showEmptyVehicleHealth", false )
    LoadBool( "showSkybox", true )
    LoadBool( "useKMH", false )

    SetNumber( self, "throttleModifierMode", data.throttleModifierMode, 0, 2, self.throttleModifierMode )
    LoadBool( "manualGearShifting", false )
    LoadBool( "autoHeadlightOn", true )
    LoadBool( "autoHeadlightOff", true )
    LoadBool( "autoTurnOffLights", true )
    LoadBool( "enableTips", true )

    -- Group-to-action-to-button dictionary
    local loadedBinds = type( data.binds ) == "table" and data.binds or {}

    for groupId, actions in pairs( self.binds ) do
        for action, button in pairs( actions ) do
            local loadedGroup = loadedBinds[groupId]

            if type( loadedGroup ) == "table" then
                SetNumber( actions, action, loadedGroup[action], KEY_NONE, BUTTON_CODE_LAST, button )
            end
        end
    end

    hook.Run( "Glide_OnConfigChange" )
end

--- Send the current input settings to the server.
function Config:TransmitInputSettings( immediate )
    timer.Remove( "Glide.TransmitInputSettings" )

    if not immediate then
        -- Don't spam when this function gets called in quick succession
        timer.Create( "Glide.TransmitInputSettings", 1, 1, function()
            self:TransmitInputSettings( true )
        end )

        return
    end

    local data = {
        -- Mouse settings
        mouseFlyMode = self.mouseFlyMode,
        mouseSteerMode = self.mouseSteerMode,
        replaceYawWithRoll = self.mouseFlyMode == Glide.MOUSE_FLY_MODE.DIRECT and self.yawMouseAxis > 0,

        -- Keyboard settings
        manualGearShifting = self.manualGearShifting,
        throttleModifierMode = self.throttleModifierMode,

        -- Misc. settings
        autoTurnOffLights = self.autoTurnOffLights,

        -- Action-key dictionary
        binds = self.binds
    }

    Glide.PrintDev( "Transmitting input data to the server." )

    Glide.StartCommand( Glide.CMD_INPUT_SETTINGS )
    Glide.WriteTable( data )
    net.SendToServer()
end

--- Apply local skid mark limits.
function Config:ApplySkidMarkLimits( immediate )
    timer.Remove( "Glide.ApplySkidMarkLimits" )

    if not immediate then
        -- Don't spam when this function gets called in quick succession
        timer.Create( "Glide.ApplySkidMarkLimits", 1, 1, function()
            self:ApplySkidMarkLimits( true )
        end )

        return
    end

    Glide.SetupSkidMarkMeshes()
end

-- Set settings to default right away, to prevent errors
Config:Reset()
Config:ResetBinds()

if game.SinglePlayer() then
    -- On singleplayer, load settings on InitPostEntity
    hook.Add( "InitPostEntity", "Glide.LoadSettings", function()
        Config:Load()
        Config:TransmitInputSettings()
        Config:ApplySkidMarkLimits()
    end )
else
    -- SetupMove seems like a better time to send network messages
    hook.Add( "SetupMove", "Glide.LoadSettings", function()
        hook.Remove( "SetupMove", "Glide.LoadSettings" )

        Config:Load()
        Config:TransmitInputSettings()
        Config:ApplySkidMarkLimits()
    end )
end

----------

concommand.Add(
    "glide_settings",
    function() Config:OpenFrame() end,
    nil,
    "Opens the Glide settings menu."
)

if engine.ActiveGamemode() == "sandbox" then
    list.Set(
        "DesktopWindows",
        "GlideDesktopIcon",
        {
            title = Glide.GetLanguageText( "settings_window" ),
            icon = "materials/glide/icons/car.png",
            init = function() Config:OpenFrame() end
        }
    )
end

function Config:CloseFrame()
    if IsValid( self.frame ) then
        self.frame:Close()
    end
end

-- Bind some panel creation functions from the theme library
-- into the Config table.
Config.CreateHeader = StyledTheme.CreateFormHeader
Config.CreateButton = StyledTheme.CreateFormButton
Config.CreateToggle = StyledTheme.CreateFormToggle
Config.CreateSlider = StyledTheme.CreateFormSlider
Config.CreateCombo = StyledTheme.CreateFormCombo

-- Utility to create a button binder row.
do
    local function UpdateResetButton( button, currentKey, invalidateLayout )
        local groupId, actionId = button.inputGroupId, button.inputActionId
        button:SetVisible( currentKey ~= Glide.InputGroups[groupId][actionId] )

        if invalidateLayout then
            button:InvalidateParent()
        end
    end

    local OnBinderChange = function( self, value )
        if self._ignoreChange then return end

        if Glide.SEAT_SWITCH_BUTTONS[value] then
            self._ignoreChange = true
            self:SetValue( self.inputLastKey )
            self._ignoreChange = nil

            local msg = Glide.GetLanguageText( "input.reserved_seat_key" ):format( input.GetKeyName( value ) )
            Derma_Message( msg, "#glide.input.invalid_bind", "#glide.ok" )
        else
            self.inputLastKey = value
            self.inputCallback( self.inputActionId, value )
            UpdateResetButton( self.inputResetButton, value, true )
        end
    end

    local OnClickReset = function( self )
        local groupId, actionId = self.inputGroupId, self.inputActionId
        local binder = self.inputBinder

        Derma_Query( "#glide.input.reset_bind_query", "#glide.input." .. actionId, "#glide.yes", function()
            local defaultKey = Glide.InputGroups[groupId][actionId]

            Config.binds[groupId][actionId] = defaultKey
            Config:Save()
            Config:TransmitInputSettings()

            if IsValid( binder ) then
                binder:SetValue( defaultKey or KEY_NONE )
            end

            if IsValid( self ) then
                UpdateResetButton( self, defaultKey, true )
            end
        end, "#glide.no" )
    end

    function Config.CreateBinderButton( parent, actionId, groupId, currentKey, callback )
        local binder = StyledTheme.CreateFormBinder( parent, "#glide.input." .. actionId, currentKey )

        binder.inputActionId = actionId
        binder.inputLastKey = currentKey
        binder.inputCallback = callback
        binder.OnChange = OnBinderChange

        local buttonReset = vgui.Create( "DBinder", binder:GetParent() )
        buttonReset:SetText( "" )
        buttonReset:SetTooltip( "#glide.input.reset_bind" )
        buttonReset:SetIcon( "icon16/arrow_undo.png" )
        buttonReset:Dock( RIGHT )

        StyledTheme.Apply( buttonReset )
        buttonReset:SizeToContents()

        binder.inputResetButton = buttonReset
        buttonReset.inputBinder = binder
        buttonReset.inputGroupId = groupId
        buttonReset.inputActionId = actionId
        buttonReset.DoClick = OnClickReset

        UpdateResetButton( buttonReset, currentKey )

        return binder
    end
end

function Config:OpenFrame()
    if IsValid( self.frame ) then
        self:CloseFrame()
        return
    end

    local frame = vgui.Create( "Styled_TabbedFrame" )
    frame:SetIcon( "glide/icons/car.png" )
    frame:SetTitle( Glide.GetLanguageText( "settings_window" ) )
    frame:Center()
    frame:MakePopup()

    frame.OnClose = function()
        self.lastTabIndex = frame.lastTabIndex
        self.frame = nil
    end

    self.frame = frame

    ----- Go back to last open tab ----- 

    timer.Simple( 0, function()
        if IsValid( self.frame ) then
            self.frame:SetActiveTabByIndex( self.lastTabIndex or 1 )
        end
    end )

    local L = Glide.GetLanguageText
    local CreateHeader = Config.CreateHeader
    local CreateButton = Config.CreateButton
    local CreateToggle = Config.CreateToggle
    local CreateSlider = Config.CreateSlider
    local CreateCombo =  Config.CreateCombo

    ----- Camera settings -----

    local panelCamera = frame:AddTab( "styledstrike/icons/camera.png", L"settings.camera" )

    CreateHeader( panelCamera, L"settings.camera", 0 )

    CreateSlider( panelCamera, L"camera.sensitivity", self.lookSensitivity, 0.01, 5, 2, function( value )
        self.lookSensitivity = value
        self:Save()
    end )

    CreateToggle( panelCamera, L"camera.invert_x", self.cameraInvertX, function( value )
        self.cameraInvertX = value
        self:Save()
    end )

    CreateToggle( panelCamera, L"camera.invert_y", self.cameraInvertY, function( value )
        self.cameraInvertY = value
        self:Save()
    end )

    CreateSlider( panelCamera, L"camera.distance", self.cameraDistance, 0.5, 3, 2, function( value )
        self.cameraDistance = value
        self:Save()
    end )

    CreateSlider( panelCamera, L"camera.height", self.cameraHeight, 0.25, 2, 2, function( value )
        self.cameraHeight = value
        self:Save()
    end )

    CreateSlider( panelCamera, L"camera.fov_internal", self.cameraFOVInternal, 30, 120, 0, function( value )
        self.cameraFOVInternal = value
        self:Save()

        if Glide.Camera.isActive then
            Glide.Camera:SetFirstPerson( true )
        end
    end )

    CreateSlider( panelCamera, L"camera.fov_external", self.cameraFOVExternal, 30, 120, 0, function( value )
        self.cameraFOVExternal = value
        self:Save()

        if Glide.Camera.isActive then
            Glide.Camera:SetFirstPerson( false )
        end
    end )

    CreateSlider( panelCamera, L"camera.shake_strength", self.shakeStrength, 0, 2, 1, function( value )
        self.shakeStrength = value
        self:Save()
    end )

    local autoCenterButton, autoCenterSlider

    local SetupAutoCenterSettings = function()
        if autoCenterButton then autoCenterButton:Remove() end
        if autoCenterSlider then autoCenterSlider:Remove() end
        if self.fixedCameraMode > 2 then return end

        autoCenterButton = CreateToggle( panelCamera, L"camera.autocenter", self.enableAutoCenter, function( value )
            self.enableAutoCenter = value
            self:Save()
        end )

        autoCenterSlider = CreateSlider( panelCamera, L"camera.autocenter_delay", self.autoCenterDelay, 0.1, 5, 2, function( value )
            self.autoCenterDelay = value
            self:Save()
        end )
    end

    local fixedCameraOptions = {
        L"camera.fixed.disabled",
        L"camera.fixed.firstperson",
        L"camera.fixed.thirdperson",
        L"camera.fixed.both"
    }

    CreateCombo( panelCamera, L"camera.fixed", fixedCameraOptions, self.fixedCameraMode + 1, function( value )
        self.fixedCameraMode = value - 1
        self:Save()
        SetupAutoCenterSettings()
    end )

    SetupAutoCenterSettings()

    ----- Mouse settings -----

    local panelMouse = frame:AddTab( "styledstrike/icons/mouse.png", L"settings.mouse" )

    local SizeToChindrenLayout = function( s )
        if #s:GetChildren() > 0 then
            s:SizeToChildren( false, true )
        else
            s:SetTall( 1 )
        end
    end

    -- Mouse steering settings
    CreateHeader( panelMouse, L"mouse.steering_settings", 0 )

    local SetupMouseSteerModeSettings

    CreateCombo( panelMouse, L"mouse.steering_mode", {
        L"mouse.steer_mode_disabled",
        L"mouse.steer_mode_aim",
        L"mouse.steer_mode_direct"
    }, self.mouseSteerMode + 1, function( value )
        self.mouseSteerMode = value - 1
        self:Save()
        self:TransmitInputSettings()

        SetupMouseSteerModeSettings()
        Glide.MouseInput:Activate()
    end )

    local directMouseSteerPanel = vgui.Create( "DPanel", panelMouse )
    directMouseSteerPanel:SetPaintBackground( false )
    directMouseSteerPanel:Dock( TOP )
    directMouseSteerPanel.PerformLayout = SizeToChindrenLayout

    SetupMouseSteerModeSettings = function()
        directMouseSteerPanel:Clear()

        if self.mouseSteerMode ~= Glide.MOUSE_STEER_MODE.DIRECT then return end

        CreateSlider( directMouseSteerPanel, L"mouse.sensitivity_x", self.mouseSteerSensitivity, 0.05, 3, 2, function( value )
            self.mouseSteerSensitivity = value
            self:Save()
        end )

        CreateSlider( directMouseSteerPanel, L"mouse.decay_rate", self.mouseSteerDecayRate, 0, 3, 1, function( value )
            self.mouseSteerDecayRate = value
            self:Save()
        end )

        directMouseSteerPanel:InvalidateLayout()
    end

    SetupMouseSteerModeSettings()

    -- Mouse aircraft settings
    CreateHeader( panelMouse, L"mouse.flying_settings", 0 )

    local SetupFlyMouseModeSettings

    CreateCombo( panelMouse, L"mouse.flying_mode", {
        L"mouse.fly_mode_aim",
        L"mouse.fly_mode_direct",
        L"mouse.fly_mode_camera"
    }, self.mouseFlyMode + 1, function( value )
        self.mouseFlyMode = value - 1
        self:Save()
        self:TransmitInputSettings()

        SetupFlyMouseModeSettings()
        Glide.MouseInput:Activate()
    end )

    local directMouseFlyPanel = vgui.Create( "DPanel", panelMouse )
    directMouseFlyPanel:SetPaintBackground( false )
    directMouseFlyPanel:Dock( TOP )
    directMouseFlyPanel.PerformLayout = SizeToChindrenLayout

    SetupFlyMouseModeSettings = function()
        directMouseFlyPanel:Clear()

        if self.mouseFlyMode ~= Glide.MOUSE_FLY_MODE.DIRECT then return end

        local axisOptions = {
            L"mouse.none",
            L"mouse.x",
            L"mouse.y"
        }

        CreateCombo( directMouseFlyPanel, L"mouse.pitch_axis", axisOptions, self.pitchMouseAxis + 1, function( value )
            self.pitchMouseAxis = value - 1
            self:Save()
        end )

        CreateCombo( directMouseFlyPanel, L"mouse.yaw_axis", axisOptions, self.yawMouseAxis + 1, function( value )
            self.yawMouseAxis = value - 1
            self:Save()
            self:TransmitInputSettings()
        end )

        CreateCombo( directMouseFlyPanel, L"mouse.roll_axis", axisOptions, self.rollMouseAxis + 1, function( value )
            self.rollMouseAxis = value - 1
            self:Save()
        end )

        CreateToggle( directMouseFlyPanel, L"mouse.invert_x", self.mouseInvertX, function( value )
            self.mouseInvertX = value
            self:Save()
        end )

        CreateToggle( directMouseFlyPanel, L"mouse.invert_y", self.mouseInvertY, function( value )
            self.mouseInvertY = value
            self:Save()
        end )

        CreateSlider( directMouseFlyPanel, L"mouse.sensitivity_x", self.mouseSensitivityX, 0.05, 5, 1, function( value )
            self.mouseSensitivityX = value
            self:Save()
        end )

        CreateSlider( directMouseFlyPanel, L"mouse.sensitivity_y", self.mouseSensitivityY, 0.05, 5, 1, function( value )
            self.mouseSensitivityY = value
            self:Save()
        end )

        CreateSlider( directMouseFlyPanel, L"mouse.deadzone", self.mouseDeadzone, 0, 0.5, 2, function( value )
            self.mouseDeadzone = value
            self:Save()
        end )

        CreateToggle( directMouseFlyPanel, L"mouse.show_hud", self.mouseShow, function( value )
            self.mouseShow = value
            self:Save()
        end )

        directMouseFlyPanel:InvalidateLayout()
    end

    SetupFlyMouseModeSettings()

    ----- Keyboard settings -----

    local panelKeyboard = frame:AddTab( "styledstrike/icons/keyboard.png", L"settings.input" )

    local groupList = {}

    -- Display built-in input groups first
    local groupOrder = {
        ["general_controls"] = 1,
        ["land_controls"] = 2,
        ["aircraft_controls"] = 3
    }

    for groupdId, _ in pairs( Glide.InputGroups ) do
        groupList[#groupList + 1] = {
            id = groupdId,
            order = groupOrder[groupdId] or 999
        }
    end

    table.SortByMember( groupList, "order", true )

    -- Create extra panels for some actions
    local extraActionFunctions = {
        ["shift_up"] = function()
            CreateToggle( panelKeyboard, L"input.manual_shift", self.manualGearShifting, function( value )
                self.manualGearShifting = value
                self:Save()
                self:TransmitInputSettings()
            end )
        end,
        ["throttle_modifier"] = function()
            local throttleModOptions = {
                L"input.throttle_mod.hold_to_full",
                L"input.throttle_mod.hold_to_reduce",
                L"input.throttle_mod.tap_to_toggle"
            }

            CreateCombo( panelKeyboard, L"input.throttle_mod_mode", throttleModOptions, self.throttleModifierMode + 1, function( value )
                self.throttleModifierMode = value - 1
                self:Save()
                self:TransmitInputSettings()
            end )
        end
    }

    local binds = self.binds
    local CreateBinderButton = Config.CreateBinderButton

    for _, listData in ipairs( groupList ) do
        local groupId = listData.id
        local groupBinds = binds[groupId]
        local actions = Glide.InputGroups[groupId]

        CreateHeader( panelKeyboard, "#glide.input." .. groupId, 0 )

        local OnChangeGroupBind = function( action, key )
            groupBinds[action] = key
            self:Save()
            self:TransmitInputSettings()
        end

        for action, _ in SortedPairs( actions ) do
            CreateBinderButton( panelKeyboard, action, groupId, groupBinds[action], OnChangeGroupBind )

            if extraActionFunctions[action] then
                extraActionFunctions[action]()
            end
        end
    end

    ----- Audio settings -----

    local panelAudio = frame:AddTab( "styledstrike/icons/speaker.png", L"settings.audio" )

    CreateHeader( panelAudio, L"settings.audio", 0 )

    CreateSlider( panelAudio, L"audio.car_volume", self.carVolume, 0, 1, 1, function( value )
        self.carVolume = value
        self:Save()
    end )

    CreateSlider( panelAudio, L"audio.aircraft_volume", self.aircraftVolume, 0, 1, 1, function( value )
        self.aircraftVolume = value
        self:Save()
    end )

    CreateSlider( panelAudio, L"audio.explosion_volume", self.explosionVolume, 0, 1, 1, function( value )
        self.explosionVolume = value
        self:Save()
    end )

    CreateSlider( panelAudio, L"audio.horn_volume", self.hornVolume, 0, 1, 1, function( value )
        self.hornVolume = value
        self:Save()
    end )

    CreateSlider( panelAudio, L"audio.wind_volume", self.windVolume, 0, 1, 1, function( value )
        self.windVolume = value
        self:Save()
    end )

    CreateSlider( panelAudio, L"audio.warning_volume", self.warningVolume, 0, 1, 1, function( value )
        self.warningVolume = value
        self:Save()
    end )

    CreateSlider( panelAudio, L"audio.voice_chat_reduction", self.vcVolume, 0, 1, 1, function( value )
        self.vcVolume = value
        self:Save()
    end )

    ----- Misc -----

    local panelMisc = frame:AddTab( "styledstrike/icons/cog.png", L"settings.misc" )

    CreateHeader( panelMisc, L"settings.performance", 0 )

    local maxSkidPiecesSlider

    maxSkidPiecesSlider = CreateSlider( panelMisc, L"performance.skid_mark_max", self.maxSkidMarkPieces, 0, 1000, 0, function( value )
        if value < 10 then
            value = 0
            maxSkidPiecesSlider:SetValue( value )
        end

        self.maxSkidMarkPieces = value
        self:Save()
        self:ApplySkidMarkLimits()
    end )

    local maxRollPiecesSlider

    maxRollPiecesSlider = CreateSlider( panelMisc, L"performance.roll_mark_max", self.maxTireRollPieces, 0, 1000, 0, function( value )
        if value < 10 then
            value = 0
            maxRollPiecesSlider:SetValue( value )
        end

        self.maxTireRollPieces = value
        self:Save()
        self:ApplySkidMarkLimits()
    end )

    CreateSlider( panelMisc, L"performance.skid_mark_time", self.skidmarkTimeLimit, 3, 300, 0, function( value )
        self.skidmarkTimeLimit = value
        self:Save()
        self:ApplySkidMarkLimits()
    end )

    CreateToggle( panelMisc, L"performance.headlight_shadows", self.headlightShadows, function( value )
        self.headlightShadows = value
        self:Save()
    end )

    CreateToggle( panelMisc, L"performance.reduce_tire_particles", self.reduceTireParticles, function( value )
        self.reduceTireParticles = value
        self:Save()
    end )

    CreateHeader( panelMisc, L"settings.hud", 0 )

    CreateToggle( panelMisc, L"misc.show_hud", self.showHUD, function( value )
        self.showHUD = value
        self:Save()
    end )

    CreateToggle( panelMisc, L"misc.show_passenger_list", self.showPassengerList, function( value )
        self.showPassengerList = value
        self:Save()
    end )

    CreateToggle( panelMisc, L"misc.show_custom_health", self.showCustomHealth, function( value )
        self.showCustomHealth = value
        self:Save()
    end )

    CreateToggle( panelMisc, L"misc.show_health_empty_vehicles", self.showEmptyVehicleHealth, function( value )
        self.showEmptyVehicleHealth = value
        self:Save()
    end )

    CreateToggle( panelMisc, L"misc.show_skybox", self.showSkybox, function( value )
        self.showSkybox = value
        self:Save()
        Glide.EnableSkyboxIndicator()
    end )

    CreateToggle( panelMisc, L"misc.use_kmh", self.useKMH, function( value )
        self.useKMH = value
        self:Save()
    end )

    CreateHeader( panelMisc, L"settings.misc" )

    CreateToggle( panelMisc, L"misc.auto_headlights_on", self.autoHeadlightOn, function( value )
        self.autoHeadlightOn = value
        self:Save()
    end )

    CreateToggle( panelMisc, L"misc.auto_headlights_off", self.autoHeadlightOff, function( value )
        self.autoHeadlightOff = value
        self:Save()
    end )

    CreateToggle( panelMisc, L"misc.turn_off_headlights", self.autoTurnOffLights, function( value )
        self.autoTurnOffLights = value
        self:Save()
        self:TransmitInputSettings()
    end )

    CreateToggle( panelMisc, L"misc.tips", self.enableTips, function( value )
        self.enableTips = value
        self:Save()
    end )

    CreateHeader( panelMisc, L"settings.reset" )

    CreateButton( panelMisc, L"misc.reset_binds", function()
        Derma_Query( L"misc.reset_binds_query", L"misc.reset_binds", L"yes", function()
            self:CloseFrame()
            self:ResetBinds()
            self:Save()
            self:TransmitInputSettings()

            timer.Simple( 1, function()
                self:OpenFrame()
            end )
        end, L"no" )
    end )

    CreateButton( panelMisc, L"misc.reset_settings", function()
        Derma_Query( L"misc.reset_settings_query", L"misc.reset_settings", L"yes", function()
            self:CloseFrame()
            self:Reset()
            self:Save()
            self:TransmitInputSettings()
            self:ApplySkidMarkLimits()

            timer.Simple( 1, function()
                self:OpenFrame()
            end )
        end, L"no" )
    end )

    ----- Console variables -----
    local NOOP = function() end

    if LocalPlayer():IsSuperAdmin() then
        local panelCVars = frame:AddTab( "styledstrike/icons/feature_list.png", L"settings.cvars" )

        CreateHeader( panelCVars, L"settings.cvars", 0 )

        local cvarList = {
            { name = "sbox_maxglide_vehicles", decimals = 0, min = 0, max = 100 },
            { name = "sbox_maxglide_standalone_turrets", decimals = 0, min = 0, max = 100 },
            { name = "sbox_maxglide_missile_launchers", decimals = 0, min = 0, max = 100 },
            { name = "sbox_maxglide_projectile_launchers", decimals = 0, min = 0, max = 100 },
            { name = "glide_gib_lifetime", decimals = 0, min = 0, max = 60 },
            { name = "glide_gib_enable_collisions", decimals = 0, min = 0, max = 1 },
            { name = "glide_pacifist_mode", decimals = 0, min = 0, max = 1 },
            { name = "glide_allow_gravity_gun_punt", decimals = 0, min = 0, max = 1 },

            { name = "glide_ragdoll_enable", decimals = 0, min = 0, max = 1 },
            { name = "glide_ragdoll_max_time", decimals = 0, min = 0, max = 30 },

            { category = "#tool.glide_turret.name" },
            { name = "glide_turret_max_damage", decimals = 0, min = 0, max = 1000 },
            { name = "glide_turret_min_delay", decimals = 2, min = 0, max = 1 },

            { category = "#tool.glide_missile_launcher.name" },
            { name = "glide_missile_launcher_min_delay", decimals = 2, min = 0.1, max = 5 },
            { name = "glide_missile_launcher_max_lifetime", decimals = 1, min = 1, max = 30 },
            { name = "glide_missile_launcher_max_radius", decimals = 0, min = 10, max = 1000 },
            { name = "glide_missile_launcher_max_damage", decimals = 0, min = 0, max = 1000 },

            { category = "#tool.glide_projectile_launcher.name" },
            { name = "glide_projectile_launcher_min_delay", decimals = 2, min = 0.1, max = 5 },
            { name = "glide_projectile_launcher_max_lifetime", decimals = 1, min = 1, max = 30 },
            { name = "glide_projectile_launcher_max_radius", decimals = 0, min = 10, max = 1000 },
            { name = "glide_projectile_launcher_max_damage", decimals = 0, min = 0, max = 1000 },
        }

        for _, data in ipairs( cvarList ) do
            if data.category then
                CreateHeader( panelCVars, L( "settings.cvars" ) .. ": " ..  language.GetPhrase( data.category ) )
            else
                local cvar = GetConVar( data.name )

                if cvar then
                    local slider = CreateSlider( panelCVars, data.name, cvar:GetFloat(), data.min, data.max, data.decimals, NOOP )
                    slider:SetConVar( data.name )
                end
            end
        end
    end

    ----- Custom extension tabs -----

    local panelExtension = frame:AddTab( "styledstrike/icons/extension.png", L"settings.extensions", "DPanel" )
    panelExtension:SetPaintBackground( false )

    local extensionCallbacks = list.Get( "GlideConfigExtensions" )

    if table.Count( extensionCallbacks ) == 0 then
        CreateHeader( panelExtension, L"settings.no_extensions", 0 )
        return
    end

    local sheet = vgui.Create( "DPropertySheet", panelExtension )
    sheet:Dock( FILL )
    sheet:SetPadding( StyledTheme.ScaleSize( 4 ) )

    sheet.Paint = function( _, w, h )
        StyledTheme.DrawRect( 0, 0, w, h, StyledTheme.colors.panelBackground )
    end

    local GetTabHeight = function( s )
        return s:GetTall()
    end

    local ApplyTabScheme = function( s )
        s.isToggle = true
        s.isChecked = s:IsActive()
        s:SetTextInset( 10, 4 )

        local w, h = s:GetContentSize()
        s:SetSize( w + 10, h + 6 )
    end

    for extensionId, callback in pairs( extensionCallbacks ) do
        local panel = vgui.Create( "DScrollPanel", sheet )

        StyledTheme.Apply( panel )
        callback( self, panel )

        local s = sheet:AddSheet( extensionId, panel )

        StyledTheme.Apply( s.Tab, "DButton" )

        s.Tab.GetTabHeight = GetTabHeight
        s.Tab.ApplySchemeSettings = ApplyTabScheme
        s.Tab:SetFont( "DermaDefault" )
    end
end

local FrameTime = FrameTime
local Approach = math.Approach

local glideVolume = 1

hook.Add( "Tick", "Glide.CheckVoiceActivity", function()
    local isAnyoneTalking = false

    for _, ply in ipairs( player.GetAll() ) do
        if ply:IsVoiceAudible() and ply:VoiceVolume() > 0.05 then
            isAnyoneTalking = true
            break
        end
    end

    glideVolume = Approach(
        glideVolume,
        isAnyoneTalking and Config.vcVolume or 1,
        FrameTime() * ( isAnyoneTalking and 10 or 2 )
    )
end )

-- Calculate the volume multiplier for a specific audio type,
-- depending on settings and how loud the voice chat is.
--
-- audioType must be one of these:
-- "carVolume", "aircraftVolume", "explosionVolume", "hornVolume", "windVolume", "warningVolume"
function Config.GetVolume( audioType )
    return Config[audioType] * glideVolume
end
