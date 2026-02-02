local colors = StyledTheme.colors
local dimensions = StyledTheme.dimensions
local ScaleSize = StyledTheme.ScaleSize
local ApplyTheme = StyledTheme.Apply
local L = Glide.GetLanguageText

local PANEL = {}

function PANEL:Init()
    self.headerHeight = ScaleSize( 32 )
    self.footerHeight = ScaleSize( 24 )
    self.controllerHeight = ScaleSize( 32 )
    self.listHeaderHeight = ScaleSize( 30 )
    self.padding = ScaleSize( 6 )
    self.controllerPanels = {}
    self.columns = {}

    self:SetTall( ScaleSize( 100 ) )
    self:Dock( TOP )
    self:DockMargin( 0, 0, 0, dimensions.scrollPadding )
    self:DockPadding( self.padding, self.headerHeight, self.padding, self.padding )

    local panelFooter = vgui.Create( "Panel", self )
    panelFooter:SetTall( self.footerHeight )
    panelFooter:Dock( BOTTOM )

    local buttonRemove = vgui.Create( "DButton", panelFooter )
    buttonRemove:SetText( L"stream_editor.remove_layer" )
    buttonRemove:SetIcon( "icon16/sound_delete.png" )
    buttonRemove:Dock( RIGHT )

    self.buttonRemove = buttonRemove
    ApplyTheme( buttonRemove )
    buttonRemove:SetFont( "StyledTheme_Tiny" )

    buttonRemove.DoClick = function()
        self:OnClickRemove()
    end

    local buttonAdd = vgui.Create( "DButton", panelFooter )
    buttonAdd:SetText( L"stream_editor.add_controller" )
    buttonAdd:SetIcon( "icon16/cog_add.png" )
    buttonAdd:Dock( RIGHT )
    buttonAdd:DockMargin( 0, 0, self.padding, 0 )

    self.buttonAdd = buttonAdd
    ApplyTheme( buttonAdd )
    buttonAdd:SetFont( "StyledTheme_Tiny" )

    buttonAdd.DoClick = function()
        self:OnClickAddController()
    end

    local buttonChange = vgui.Create( "DButton", panelFooter )
    buttonChange:SetText( L"stream_editor.change_audio" )
    buttonChange:SetIcon( "icon16/sound_add.png" )
    buttonChange:Dock( RIGHT )
    buttonChange:DockMargin( 0, 0, self.padding, 0 )

    self.buttonChange = buttonChange
    ApplyTheme( buttonChange )
    buttonChange:SetFont( "StyledTheme_Tiny" )

    buttonChange.DoClick = function()
        self:OnClickChangeAudio()
    end

    local checkRevLimiter = StyledTheme.CreateFormToggle( panelFooter, L"stream_editor.rev_limiter", false, function( value )
        if self.layerData then
            self.layerData.redline = value
            self:OnChanged()
        end
    end )

    checkRevLimiter:SetFont( "StyledTheme_Tiny" )
    checkRevLimiter:Dock( LEFT )
    checkRevLimiter:DockMargin( 0, 0, 0, 0 )
    self.checkRevLimiter = checkRevLimiter

    local checkMute = StyledTheme.CreateFormToggle( panelFooter, L"stream_editor.mute", false, function( value )
        if self.layerData then
            self.layerData.isMuted = value
        end
    end )

    checkMute:SetFont( "StyledTheme_Tiny" )
    checkMute:Dock( LEFT )
    checkMute:DockMargin( self.padding, 0, 0, 0 )
    self.checkMute = checkMute
end

function PANEL:OnChanged()
    self.editorTab:MarkAsUnsaved()
end

function PANEL:OnClickRemove()
    self.editorTab:RemoveLayer( self.id )
end

function PANEL:OnClickAddController()
    local controllers = self.controllers
    if not controllers then return end

    controllers[#controllers + 1] = {
        "throttle", 0, 1, "volume", 0, 1
    }

    self:SetControllers( controllers )
    self:OnChanged()
end

function PANEL:OnClickRemoveController( index )
    local controllers = self.controllers
    if not controllers then return end

    if controllers[index] then
        table.remove( controllers, index )
        self:SetControllers( controllers )
        self:OnChanged()
    end
end

function PANEL:OnClickChangeAudio()
    local fileBrowser = StyledTheme.CreateFileBrowser()
    fileBrowser:SetTitle( L"stream_editor.open_audio" )
    fileBrowser:SetIcon( "icon16/sound.png" )
    fileBrowser:SetExtensionFilter( { "ogg", "wav", "mp3" } )
    fileBrowser:SetBasePath( "sound/" )

    fileBrowser.OnConfirmPath = function( path )
        if not IsValid( self ) then return end

        path = string.sub( path, 7 ) -- remove "sound/"
        Glide.lastAudioFolderPath = string.GetPathFromFilename( path )

        local layer = self.layerData

        if IsValid( layer.channel ) then
            layer.channel:Stop()
        end

        layer.path = path
        layer.channel = nil
        layer.isLoaded = false

        self.path = path
        self:OnChanged()
    end

    if Glide.lastAudioFolderPath then
        fileBrowser:NavigateTo( Glide.lastAudioFolderPath )
    end
end

function PANEL:SetLayerData( tab, id, path, data )
    self.editorTab = tab
    self.id = id
    self.path = path
    self.layerData = data

    self.checkRevLimiter:SetChecked( data.redline == true )
    self:SetControllers( data.controllers )
end

local BG_COLORS = {
    Color( 62, 84, 117 ),
    Color( 45, 62, 87 )
}

local DrawRect = StyledTheme.DrawRect

local function PaintController( s, w, h )
    DrawRect( 0, 0, w, h, BG_COLORS[( s._index % 2 ) + 1] )
end

function PANEL:SetControllers( controllers )
    for _, panel in ipairs( self.controllerPanels ) do
        if IsValid( panel ) then panel:Remove() end
    end

    table.Empty( self.controllerPanels )

    self.controllers = controllers
    if not controllers then return end

    local totalHeight = self.headerHeight + self.listHeaderHeight + self.footerHeight + self.padding * 3
    local controllerHeight = self.controllerHeight
    local padding = self.padding
    local separator = ScaleSize( 4 )
    local iconSize = ScaleSize( 18 )

    for i, params in ipairs( controllers ) do
        local panel = vgui.Create( "Panel", self )
        panel:SetTall( controllerHeight )
        panel:Dock( TOP )
        panel:DockMargin( 0, i == 1 and padding + self.listHeaderHeight or 0, 0, 0 )
        panel:DockPadding( 0, 2, 0, 2 )
        panel.Paint = PaintController
        panel._index = i

        self.controllerPanels[i] = panel
        totalHeight = totalHeight + controllerHeight

        -- Controller input type
        local comboIn = vgui.Create( "DComboBox", panel )
        comboIn:Dock( LEFT )
        comboIn:AddChoice( "throttle" )
        comboIn:AddChoice( "rpmFraction" )
        comboIn:SetValue( params[1] )

        ApplyTheme( comboIn )

        comboIn.OnSelect = function( _, _, value )
            params[1] = value
            self:OnChanged()
        end

        -- Controller input minimum value
        local sliderIMin = vgui.Create( "DNumSlider", panel )
        sliderIMin:SetMin( 0 )
        sliderIMin:SetMax( 1 )
        sliderIMin:SetDecimals( 3 )
        sliderIMin:Dock( LEFT )
        sliderIMin.Label:SetVisible( false )
        sliderIMin:SetValue( params[2] )

        ApplyTheme( sliderIMin )

        sliderIMin.OnValueChanged = function( _, value )
            params[2] = math.Round( value, 3 )
            self:OnChanged()
        end

        local imgIMin = vgui.Create( "DImage", sliderIMin )
        imgIMin:SetWide( iconSize )
        imgIMin:SetImage( "icon16/bullet_arrow_down.png" )
        imgIMin:SetKeepAspect( true )
        imgIMin:Dock( LEFT )
        imgIMin:DockMargin( separator, separator, 0, separator )

        -- Controller input maximum value
        local sliderIMax = vgui.Create( "DNumSlider", panel )
        sliderIMax:SetMin( 0 )
        sliderIMax:SetMax( 1 )
        sliderIMax:SetDecimals( 3 )
        sliderIMax:Dock( LEFT )
        sliderIMax.Label:SetVisible( false )
        sliderIMax:SetValue( params[3] )

        ApplyTheme( sliderIMax )

        sliderIMax.OnValueChanged = function( _, value )
            params[3] = math.Round( value, 3 )
            self:OnChanged()
        end

        local imgIMax = vgui.Create( "DImage", sliderIMax )
        imgIMax:SetWide( iconSize )
        imgIMax:SetImage( "icon16/bullet_arrow_up.png" )
        imgIMax:SetKeepAspect( true )
        imgIMax:Dock( LEFT )
        imgIMax:DockMargin( separator, separator, 0, separator )

        -- Controller output type
        local comboOut = vgui.Create( "DComboBox", panel )
        comboOut:Dock( LEFT )
        comboOut:DockMargin( separator, 0, 0, 0 )
        comboOut:AddChoice( "volume" )
        comboOut:AddChoice( "pitch" )
        comboOut:SetValue( params[4] )

        ApplyTheme( comboOut )

        comboOut.OnSelect = function( _, _, value )
            params[4] = value
            self:OnChanged()
        end

        -- Controller output minimum value
        local sliderOMin = vgui.Create( "DNumSlider", panel )
        sliderOMin:SetMin( 0 )
        sliderOMin:SetMax( 2.5 )
        sliderOMin:SetDecimals( 3 )
        sliderOMin:Dock( LEFT )
        sliderOMin.Label:SetVisible( false )
        sliderOMin:SetValue( params[5] )

        ApplyTheme( sliderOMin )

        sliderOMin.OnValueChanged = function( _, value )
            params[5] = math.Round( value, 3 )
            self:OnChanged()
        end

        local imgOMin = vgui.Create( "DImage", sliderOMin )
        imgOMin:SetWide( iconSize )
        imgOMin:SetImage( "icon16/bullet_arrow_down.png" )
        imgOMin:Dock( LEFT )
        imgOMin:DockMargin( separator, separator, 0, separator )

        -- Controller input maximum value
        local sliderOMax = vgui.Create( "DNumSlider", panel )
        sliderOMax:SetMin( 0 )
        sliderOMax:SetMax( 2.5 )
        sliderOMax:SetDecimals( 3 )
        sliderOMax:Dock( LEFT )
        sliderOMax.Label:SetVisible( false )
        sliderOMax:SetValue( params[6] )

        ApplyTheme( sliderOMax )

        sliderOMax.OnValueChanged = function( _, value )
            params[6] = math.Round( value, 3 )
            self:OnChanged()
        end

        local imgOMax = vgui.Create( "DImage", sliderOMax )
        imgOMax:SetWide( iconSize )
        imgOMax:SetImage( "icon16/bullet_arrow_up.png" )
        imgOMax:Dock( LEFT )
        imgOMax:DockMargin( separator, separator, 0, separator )

        -- Remove controller
        local buttonRemove = vgui.Create( "DButton", panel )
        buttonRemove:SetText( "" )
        buttonRemove:SetTooltip( L"stream_editor.remove_controller" )
        buttonRemove:SetIcon( "icon16/cog_delete.png" )
        buttonRemove:SetWide( ScaleSize( 28 ) )
        buttonRemove:Dock( RIGHT )
        buttonRemove:DockMargin( 0, 0, 0, 0 )

        ApplyTheme( buttonRemove )

        buttonRemove.DoClick = function()
            self:OnClickRemoveController( i )
        end
    end

    self:SetTall( totalHeight )
    self:InvalidateLayout()
end

function PANEL:PerformLayout( w )
    local buttonPadding = ScaleSize( 8 )

    self.buttonRemove:SizeToContentsX( buttonPadding )
    self.buttonAdd:SizeToContentsX( buttonPadding )
    self.checkRevLimiter:SizeToContentsX( buttonPadding )
    self.buttonChange:SizeToContentsX( buttonPadding )
    self.checkMute:SizeToContentsX( buttonPadding )

    -- panelWidth - leftPadding - removeControllerButton - layerPadding
    local listW = w - 2 - ScaleSize( 28 ) - self.padding * 2

    local columns = {
        { label = L"stream_editor.col.input_type", width = listW * 0.1 },
        { label = L"stream_editor.col.input_min", width = listW * 0.2 },
        { label = L"stream_editor.col.input_max", width = listW * 0.2 },
        { label = L"stream_editor.col.output_type", width = listW * 0.1 },
        { label = L"stream_editor.col.output_min", width = listW * 0.2 },
        { label = L"stream_editor.col.output_max", width = listW * 0.2 }
    }

    self.columns = columns

    for _, row in ipairs( self.controllerPanels ) do
        for i, col in ipairs( row:GetChildren() ) do
            if columns[i] then
                col:SetWide( columns[i].width )
            end
        end
    end
end

local COLOR_HEADER = Color( 60, 60, 60 )
local COLOR_LIST_HEADER = Color( 40, 40, 40, 255 )
local SimpleText = draw.SimpleText

function PANEL:Paint( w, h )
    local headerHeight = self.headerHeight
    local padding = self.padding

    DrawRect( 0, 0, w, h, colors.entryBorder )
    DrawRect( 0, 0, w, headerHeight, COLOR_HEADER )

    if self.layerData then
        surface.SetDrawColor( 13, 122, 13 )
        surface.DrawRect( 1, 1, ( w - 2 ) * self.layerData.volume, headerHeight - 2 )

        SimpleText( self.id, "StyledTheme_Small", padding, headerHeight * 0.5, colors.buttonText, 0, 1 )
        SimpleText( self.path, "StyledTheme_Small", w - padding, headerHeight * 0.5, colors.buttonText, 2, 1 )
    end

    local x = padding
    local y = headerHeight + padding
    local listHeaderHeight = self.listHeaderHeight

    w = w - padding * 2

    DrawRect( x, y, w, listHeaderHeight, COLOR_LIST_HEADER )

    if #self.controllerPanels == 0 then
        SimpleText( "#glide.stream_editor.no_controllers", "StyledTheme_Small", x + w * 0.5, y + listHeaderHeight * 0.5, colors.buttonText, 1, 1 )
        return
    end

    for _, col in ipairs( self.columns ) do
        SimpleText( col.label, "StyledTheme_Tiny", x + col.width * 0.5, y + listHeaderHeight * 0.5, colors.buttonText, 1, 1 )
        x = x + col.width
    end
end

vgui.Register( "Styled_StreamEditorLayer", PANEL, "DPanel" )
