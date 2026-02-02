local ScaleSize = StyledTheme.ScaleSize
local colors = StyledTheme.colors
local L = Glide.GetLanguageText

local function OnStreamError( path, errorName )
    Derma_Message( string.format( L"stream_editor.load_error", path, errorName ), L"error", L"ok" )
end

local PANEL = {}

function PANEL:Init()
    local separator = ScaleSize( 4 )

    -- Right-side panel
    local rightPanel = vgui.Create( "Panel", self )
    rightPanel:SetWide( ScaleSize( 200 ) )
    rightPanel:DockMargin( separator, 0, 0, 0 )
    rightPanel:Dock( RIGHT )

    -- Stream parameters panel
    local panelParams = vgui.Create( "DPanel", rightPanel )
    panelParams:DockPadding( 0, 0, 0, 0 )
    panelParams:Dock( FILL )
    panelParams:SetBackgroundColor( colors.scrollBackground )

    StyledTheme.Apply( panelParams )
    StyledTheme.CreateFormHeader( panelParams, L"stream_editor.tab_params", 0, separator )

    local scrollParams = vgui.Create( "DScrollPanel", panelParams )

    StyledTheme.Apply( scrollParams )
    scrollParams:Dock( FILL )
    scrollParams:SetPaintBackground( false )

    self.paramSliders = {}

    local CreateStreamParam = function( key )
        local label = vgui.Create( "DLabel", scrollParams )
        label:SetText( key )
        label:Dock( TOP )
        label:DockMargin( separator, 0, 0, 0 )

        StyledTheme.Apply( label )

        local limits = Glide.STREAM_KV_LIMITS[key]

        local slider = vgui.Create( "DNumSlider", scrollParams )
        slider:SetText( "" )
        slider:SetMin( limits.min )
        slider:SetMax( limits.max )
        slider:SetDecimals( limits.decimals )
        slider:Dock( TOP )
        slider:DockMargin( 0, 0, 0, separator * 4 )

        StyledTheme.Apply( slider )
        slider.Label:SetVisible( false )

        self.paramSliders[key] = slider

        slider.OnValueChanged = function( _, value )
            self.stream[key] = math.Round( value, limits.decimals )
            self:MarkAsUnsaved()
        end
    end

    for k, _ in SortedPairs( Glide.DEFAULT_STREAM_PARAMS ) do
        CreateStreamParam( k )
    end

    -- Simulated engine controls panel
    local engineControls = vgui.Create( "DPanel", rightPanel )
    engineControls:Dock( TOP )
    engineControls:DockMargin( 0, 0, 0, separator )
    engineControls:DockPadding( 0, 0, 0, separator )
    engineControls:SetBackgroundColor( colors.scrollBackground )

    StyledTheme.Apply( engineControls )
    StyledTheme.CreateFormHeader( engineControls, L"stream_editor.tab_engine", 0, separator )

    self.buttonToggleEngine = StyledTheme.CreateFormToggle( engineControls, "", false, function()
        if self.isEngineOn then
            self:StopEngine()
        else
            self:StartEngine()
        end
    end )

    self.buttonToggleEngine:DockMargin( separator, 0, separator, 0 )
    self:UpdateEngineToggleButton()

    local CreateEngineParam = function( name )
        local label = vgui.Create( "DLabel", engineControls )
        label:SetText( name )
        label:Dock( TOP )
        label:DockMargin( separator, separator * 2, 0, 0 )

        StyledTheme.Apply( label )

        local progress = vgui.Create( "DProgress", engineControls )
        progress:SetFraction( 0 )
        progress:SetTall( ScaleSize( 10 ) )
        progress:Dock( TOP )
        progress:DockMargin( separator, 0, separator, separator )

        local slider = vgui.Create( "DNumSlider", engineControls )
        slider:SetText( "" )
        slider:SetMin( 0 )
        slider:SetMax( 1 )
        slider:SetDecimals( 2 )
        slider:Dock( TOP )
        slider:DockMargin( 0, 0, separator, 0 )

        StyledTheme.Apply( slider )
        slider.Label:SetVisible( false )

        return progress, slider, label
    end

    self.rpmProgress, self.rpmSlider, self.rpmLabel = CreateEngineParam( L"stream_editor.rpm" )
    self.throttleProgress, self.throttleSlider = CreateEngineParam( L"stream_editor.throttle" )

    self.rpmSlider.OnValueChanged = function()
        self.manualInput = true
    end

    self.throttleSlider.OnValueChanged = function()
        self.manualInput = true
    end

    self.engineControls = engineControls
    self:InvalidateEnginePanel()

    -- Layers list panel
    self.scrollLayers = vgui.Create( "DScrollPanel", self )
    self.scrollLayers:Dock( FILL )

    StyledTheme.Apply( self.scrollLayers )

    -- Tab data
    self.tab = {}
    self.filePath = nil
    self.isUnsaved = false
    self.isLoadingData = false
    self.reachedResourceLimits = false

    -- self -> Panel -> Glide_EngineStreamEditor
    self.mainEditor = self:GetParent():GetParent()

    -- Simulated engine
    self.isEngineOn = false
    self.manualInput = false
end

function PANEL:OnRemove()
    if self.stream then
        self.stream:Destroy()
        self.stream = nil
    end

    self:StopEngine()
end

function PANEL:Close( errorMsg )
    if errorMsg then
        Derma_Message( errorMsg, L"error", L"ok" )
    end

    self.mainEditor:CloseTabById( self.tab.id, errorMsg ~= nil )
end

function PANEL:MarkAsSaved( path )
    self.isUnsaved = false
    self.filePath = path
    self:UpdateTabButton()
end

function PANEL:MarkAsUnsaved()
    if self.isLoadingData then return end

    self.isUnsaved = true
    self:UpdateTabButton()
    self:UpdateStats()
end

function PANEL:UpdateStats()
    local data = self:GetJSONData() or ""
    local layers = self.stream and self.stream.layers or {}

    local dataSize = #data
    local layerCount = table.Count( layers )

    self.reachedResourceLimits = dataSize >= Glide.MAX_JSON_SIZE or layerCount >= Glide.MAX_STREAM_LAYERS
    self.mainEditor:UpdateStats( dataSize, layerCount )
end

function PANEL:InvalidateEnginePanel()
    local panel = self.engineControls

    timer.Simple( 0.1, function()
        if IsValid( panel ) then
            panel:SizeToChildren( false, true )
        end
    end )
end

function PANEL:LoadPath( path )
    self.filePath = nil

    if not path then
        self:LoadJSON( nil )
        return
    end

    local data = file.Read( path, "GAME" )

    if not data or string.len( path ) == 0 then
        self:Close( L"stream_editor.err_no_data" )
        return
    end

    self.filePath = path
    self:LoadJSON( data )
end

function PANEL:LoadJSON( data )
    self.stream = Glide.CreateEngineStream( LocalPlayer() )
    self.stream.errorCallback = OnStreamError
    self.stream.firstPerson = true

    if not data then
        self.filePath = "data/" .. Glide.PRESET_DATA_DIR .. "untitled.json"
        self:MarkAsUnsaved()
        self:UpdateStreamParamSliders()

        return
    end

    self.isLoadingData = true

    data = Glide.FromJSON( data )
    local keyValues = data.kv or {}

    if type( keyValues ) ~= "table" then
        self:Close( L"stream_editor.err_invalid_data" )
        return
    end

    local layers = data.layers

    if type( layers ) ~= "table" then
        self:Close( L"stream_editor.err_invalid_data" )
        return
    end

    local defaultParams = Glide.DEFAULT_STREAM_PARAMS

    for k, v in pairs( keyValues ) do
        if defaultParams[k] and type( v ) == "number" then
            self.stream[k] = v
        else
            Glide.Print( "Invalid key/value: %s/$s", k, v )
        end
    end

    for id, layer in SortedPairs( layers ) do
        if type( layer ) ~= "table" then
            self:Close( L"stream_editor.err_invalid_data" )
            return
        end

        local p = layer.path
        local c = layer.controllers

        if
            type( id ) == "string" and
            type( p ) == "string" and
            type( c ) == "table"
        then
            self:AddLayer( id, p, c, layer.redline == true )
        else
            self:Close( L"stream_editor.err_invalid_data" )
            return
        end
    end

    self.filePath = self.filePath or "data/" .. Glide.PRESET_DATA_DIR .. "untitled.json"
    self.isUnsaved = false

    self:UpdateTabButton()
    self:UpdateStreamParamSliders()
    self:UpdateStats()

    -- Delay resetting this flag since the stream parameters sliders
    -- seems to take a frame to run `OnValueChanged`.
    timer.Simple( 0, function()
        self.isLoadingData = false
        self:UpdateStats()
    end )
end

function PANEL:GetJSONData()
    if not self.stream then
        return "{}"
    end

    local data = {
        kv = {},
        layers = {}
    }

    for k, default in pairs( Glide.DEFAULT_STREAM_PARAMS ) do
        local value = self.stream[k]

        if value ~= default then
            data.kv[k] = value
        end
    end

    local layers = self.stream.layers

    for id, layer in pairs( layers ) do
        data.layers[id] = {
            path = layer.path,
            controllers = layer.controllers,
            redline = layer.redline
        }
    end

    return util.TableToJSON( data, false )
end

function PANEL:GetFreeLayerID( path )
    local name = string.StripExtension( string.GetFileFromFilename( path ) )
    local layers = self.stream.layers

    local i = 0
    local id = name

    while layers[id] and i < 10000 do
        i = i + 1
        id = name .. i
    end

    return id
end

function PANEL:AddLayer( id, path, controllers, redline )
    id = id or self:GetFreeLayerID( path )
    controllers = controllers or {}

    self.stream:AddLayer( id, path, controllers, redline )

    local layer = self.stream.layers[id]
    local panel = vgui.Create( "Styled_StreamEditorLayer" )

    layer.panel = panel
    self.scrollLayers:AddItem( panel )
    panel:SetLayerData( self, id, path, layer )

    self:MarkAsUnsaved()
end

function PANEL:ClearLayers()
    for id, _ in pairs( self.stream.layers ) do
        self:RemoveLayer( id )
    end
end

function PANEL:RemoveLayer( id )
    local layer = self.stream.layers[id]

    if layer and IsValid( layer.panel ) then
        layer.panel:Remove()
    end

    self.stream:RemoveLayer( id )
    self:MarkAsUnsaved()
end

function PANEL:UpdateTabButton()
    local button = self.tab.button
    button:SetText( string.GetFileFromFilename( self.filePath ) )
    button:SetIcon( self.isUnsaved and "icon16/bullet_blue.png" or nil )

    -- Workaround for DHorizontalScroller not updating the canvas size
    timer.Simple( 0, function()
        if IsValid( button ) then
            button:GetParent():GetParent():InvalidateLayout( true )
        end
    end )
end

function PANEL:UpdateEngineToggleButton()
    local button = self.buttonToggleEngine

    button.isChecked = self.isEngineOn
    button:SetText( button.isChecked and L"stream_editor.stop_engine" or L"stream_editor.start_engine" )
    button:SetIcon( button.isChecked and "icon16/control_stop_blue.png" or "icon16/control_play_blue.png" )
    button:SizeToContentsX( ScaleSize( 60 ) )
end

function PANEL:UpdateStreamParamSliders()
    for k, slider in pairs( self.paramSliders ) do
        slider:SetValue( self.stream[k] or Glide.DEFAULT_STREAM_PARAMS[k] )
    end
end

function PANEL:StartEngine()
    self.rpmProgress:SetFraction( 0 )
    self.throttleProgress:SetFraction( 0 )

    self.rpmSlider:SetValue( 0 )
    self.throttleSlider:SetValue( 0 )

    self.isEngineOn = true
    self.manualInput = false
    self.stream:Play()

    -- Fake engine constants
    self.minRPM = 2000
    self.maxRPM = 15000

    self.flywheelMass = 50
    self.flywheelRadius = 0.5

    self.flywheelFriction = -5000
    self.flywheelTorque = 10000

    -- Fake engine variables
    self.throttle = 0
    self.angularVelocity = 0
    self.isRedlining = false
    self:UpdateEngineToggleButton()
end

function PANEL:StopEngine()
    self.isEngineOn = false
    self:UpdateEngineToggleButton()

    if self.stream then
        self.stream:Pause()
    end
end

local TAU = math.pi * 2

function PANEL:GetEngineRPM()
    return self.angularVelocity * 60 / TAU
end

function PANEL:SetEngineRPM( rpm )
    self.angularVelocity = rpm * TAU / 60
end

function PANEL:Accelerate( torque, dt )
    -- Calculate moment of inertia
    local radius = self.flywheelRadius
    local inertia = 0.5 * self.flywheelMass * radius * radius

    -- Calculate angular acceleration using Newton's second law for rotation
    local angularAcceleration = torque / inertia -- Ah, the classic F = m * a

    -- Calculate new angular velocity after delta time
    self.angularVelocity = self.angularVelocity + angularAcceleration * dt
end

local IsKeyDown = input.IsKeyDown

function PANEL:Think()
    if not self.isEngineOn then return end

    local dt = FrameTime()
    local rpm = self:GetEngineRPM()
    local isRedlining = false

    if rpm < self.minRPM then
        self:SetEngineRPM( self.minRPM + 1 )

    elseif rpm > self.maxRPM then
        self:SetEngineRPM( self.maxRPM - 1 )
        isRedlining = true
    end

    local throttle

    if self.manualInput then
        throttle = self.throttleSlider:GetValue()

        local rpmFraction = self.rpmSlider:GetValue()

        self:SetEngineRPM( self.minRPM + ( self.maxRPM - self.minRPM ) * rpmFraction )

        -- Disable manual input from the sliders if we press W
        if IsKeyDown( 33 ) then
            self.manualInput = false
        end
    else
        throttle = IsKeyDown( 33 ) and 1 or 0

        self:Accelerate( self.flywheelFriction + self.flywheelTorque * self.throttle, dt )
    end

    self.throttle = math.Approach( self.throttle, throttle, dt * ( throttle > self.throttle and 3 or 2 ) )

    isRedlining = isRedlining and throttle > 0

    if self.isRedlining ~= isRedlining then
        self.isRedlining = isRedlining
        self.rpmLabel:SetColor( isRedlining and Color( 255, 0, 0 ) or color_white )
    end

    local rpmFraction = ( rpm - self.minRPM ) / ( self.maxRPM - self.minRPM )

    self.rpmProgress:SetFraction( rpmFraction )
    self.throttleProgress:SetFraction( self.throttle )

    local inputs = self.stream.inputs

    inputs.rpmFraction = rpmFraction
    inputs.throttle = self.throttle

    self.stream.isRedlining = isRedlining
end

function PANEL:PaintOver( _, h )
    local canvas = self.scrollLayers.pnlCanvas

    if #canvas:GetChildren() == 0 then
        draw.SimpleText( "#glide.stream_editor.no_layers", "StyledTheme_Small", canvas:GetWide() * 0.5, h * 0.5, colors.buttonText, 1, 1 )
    end
end

vgui.Register( "Styled_StreamEditorTab", PANEL, "Panel" )
