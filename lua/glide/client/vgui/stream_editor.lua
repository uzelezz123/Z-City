Glide.PRESET_DATA_DIR = "glide_presets/"

function Glide.EnsurePresetDataDir()
    if not file.Exists( Glide.PRESET_DATA_DIR, "DATA" ) then
        file.CreateDir( Glide.PRESET_DATA_DIR )
    end
end

concommand.Add(
    "glide_engine_stream_editor",
    function() Glide:OpenSoundEditor() end,
    nil,
    "Opens the engine sound editor for Glide cars/motorcycles/tanks."
)

function Glide:OpenSoundEditor()
    if IsValid( self.frameStreamEditor ) then
        self.frameStreamEditor:Close()
        self.frameStreamEditor = nil

        return
    end

    local frame = vgui.Create( "Glide_EngineStreamEditor" )
    frame:Center()
    frame:MakePopup()

    self.frameStreamEditor = frame
end

local L = Glide.GetLanguageText
local UL = StyledTheme.GetUpperLanguagePhrase
local ScaleSize = StyledTheme.ScaleSize
local dimensions = StyledTheme.dimensions
local colors = StyledTheme.colors

local PANEL = {}

function PANEL:Init()
    local editorW = ScaleSize( 1200 )
    local editorH = ScaleSize( 800 )

    self:SetIcon( "styledstrike/icons/speaker.png" )
    self:SetTitle( L"stream_editor.title" )
    self:SetSize( editorW, editorH )
    self:SetMinimumSize( editorW, editorH * 0.8 )
    self:SetSizable( true )
    self:SetDraggable( true )
    self:SetScreenLock( true )
    self:SetDeleteOnClose( true )

    StyledTheme.Apply( self, "DFrame" )

    self.menuPanel = vgui.Create( "DMenuBar", self )

    StyledTheme.Apply( self.menuPanel )

    -- File menu options
    local fileMenu = self.menuPanel:AddMenu( UL"file" )

    fileMenu:AddOption( L"stream_editor.new", function()
        self:OnClickNew()
    end ):SetIcon( "icon16/page_white_add.png" )

    fileMenu:AddOption( L"stream_editor.open", function()
        self:OnClickOpen()
    end ):SetIcon( "icon16/folder.png" )

    fileMenu:AddOption( L"stream_editor.save", function()
        self:OnClickSave()
    end ):SetIcon( "icon16/disk.png" )

    fileMenu:AddOption( L"stream_editor.close", function()
        if self.activeTabId then
            self:CloseTabById( self.activeTabId )
        end
    end ):SetIcon( "icon16/cross.png" )

    fileMenu:AddOption( L"stream_editor.export_code", function()
        self:OnClickExportCode()
    end ):SetIcon( "icon16/script_go.png" )

    fileMenu:AddOption( L"stream_editor.import_json_static", function()
        self:OnClickImportJSON()
    end ):SetIcon( "icon16/folder.png" )

    -- Layer menu options
    local layerMenu = self.menuPanel:AddMenu( L"stream_editor.layers" )

    layerMenu:AddOption( L"stream_editor.add_layer", function()
        self:OnClickAddLayer()
    end ):SetIcon( "icon16/sound_add.png" )

    layerMenu:AddOption( L"stream_editor.remove_all_layers", function()
        self:OnClickRemoveAllLayers()
    end ):SetIcon( "icon16/sound_delete.png" )

    -- Size limit tracker
    self.maxSizeLabel = vgui.Create( "DLabel", self.menuPanel )
    self.maxSizeLabel:SetMouseInputEnabled( true )
    self.maxSizeLabel:SetCursor( "up" )
    self.maxSizeLabel:SetTooltip( L( "stream_editor.size_tooltip" ) )
    self.maxSizeLabel:SetContentAlignment( 6 )
    self.maxSizeLabel:Dock( RIGHT )
    self.maxSizeLabel._progress = 0

    StyledTheme.Apply( self.maxSizeLabel )

    local DrawRect = StyledTheme.DrawRect
    local DrawIcon = StyledTheme.DrawIcon

    self.maxSizeLabel.Paint = function( s, w, h )
        DrawRect( 0, 0, w, h, colors.buttonBorder )

        w, h = w - 2, h - 2

        DrawRect( 1, 1, w, h, colors.entryBackground )
        DrawRect( 1, 1, w * s._progress, h, colors.accent )

        local size = math.floor( h * 0.75 )
        DrawIcon( "icon16/cd.png", h * 0.2, ( h * 0.5 ) - ( size * 0.5 ), size, size )
    end

    self.maxLayersLabel = vgui.Create( "DLabel", self.menuPanel )
    self.maxLayersLabel:SetMouseInputEnabled( true )
    self.maxLayersLabel:SetCursor( "up" )
    self.maxLayersLabel:SetTooltip( L( "stream_editor.size_tooltip" ) )
    self.maxLayersLabel:SetContentAlignment( 6 )
    self.maxLayersLabel:Dock( RIGHT )
    self.maxLayersLabel:DockMargin( 0, 0, ScaleSize( 8 ), 0 )
    self.maxLayersLabel._progress = 0

    StyledTheme.Apply( self.maxLayersLabel )

    self.maxLayersLabel.Paint = function( s, w, h )
        DrawRect( 0, 0, w, h, colors.buttonBorder )

        w, h = w - 2, h - 2

        DrawRect( 1, 1, w, h, colors.entryBackground )
        DrawRect( 1, 1, w * s._progress, h, colors.accent )

        local size = math.floor( h * 0.75 )
        DrawIcon( "icon16/sound.png", h * 0.2, ( h * 0.5 ) - ( size * 0.5 ), size, size )
    end

    self:UpdateStats( 0, 0 )

    -- Tabs container
    self.tabContainer = vgui.Create( "DHorizontalScroller", self )
    self.tabContainer:SetTall( dimensions.buttonHeight * 0.8 )
    self.tabContainer:Dock( TOP )
    self.tabContainer:DockPadding( 0, 0, 0, 0 )
    self.tabContainer:DockMargin( 0, ScaleSize( 6 ), 0, 0 )

    StyledTheme.Apply( self.tabContainer )

    self.contentContainer = vgui.Create( "Panel", self )
    self.contentContainer:Dock( FILL )
    self.contentContainer:DockPadding( 0, 0, 0, 0 )
    self.contentContainer:DockMargin( 0, 0, 0, 0 )

    self.OriginalClose = self.Close
    self.Close = function( s )
        local unsavedTabs = 0

        for _, tab in pairs( self.tabs ) do
            if tab.panel.isUnsaved then
                unsavedTabs = unsavedTabs + 1
            end
        end

        if unsavedTabs > 0 then
            local query = string.format( L"stream_editor.unsaved_query", unsavedTabs )

            Derma_Query( query, L"stream_editor.close", L"yes", function()
                if IsValid( s ) then
                    s:CopyActiveStreamPresetData()
                    s:OriginalClose()
                end
            end, L"no" )
        else
            s:CopyActiveStreamPresetData()
            s:OriginalClose()
        end
    end

    self.OnStartClosing = function()
        if IsValid( self.fileBrowser ) then
            self.fileBrowser:Remove()
        end

        self:SaveTabs()
    end

    self.tabs = {}
    self.lastTabId = 0
    self.activeTabId = nil
    self:LoadTabs()
end

function PANEL:OnShortcut( code )
    if code == KEY_S then
        self:OnClickSave()

    elseif code == KEY_O then
        self:OnClickOpen()

    elseif code == KEY_N then
        self:OnClickNew()

    elseif code == KEY_W then
        if self.activeTabId then
            self:CloseTabById( self.activeTabId )
        end
    end
end

function PANEL:SaveTabs()
    local data = { tabs = {} }
    local tabs = data.tabs

    for id, tab in SortedPairs( self.tabs ) do
        local panel = tab.panel

        if IsValid( panel ) then
            tabs[#tabs + 1] = panel.filePath

            if id == self.activeTabId then
                data.activePath = tab.panel.filePath
            end
        end
    end

    data = Glide.ToJSON( data )
    Glide.SaveDataFile( "glide_stream_editor_tabs.json", data )
end

function PANEL:LoadTabs()
    local data = Glide.FromJSON( Glide.LoadDataFile( "glide_stream_editor_tabs.json" ) )
    if type( data.tabs ) ~= "table" then return end

    for _, path in ipairs( data.tabs ) do
        if file.Exists( path, "GAME" ) then
            local panel, id = self:AddTab()
            panel:LoadPath( path )

            if path == data.activePath then
                self:SetActiveTabById( id )
            end
        end
    end
end

function PANEL:CopyActiveStreamPresetData()
    local panel = self:GetActiveTab()
    if not panel then return end

    Glide.lastStreamPresetData = panel:GetJSONData()
end

function PANEL:IsAnyTabOpen()
    local panel = self:GetActiveTab()

    if not panel then
        Derma_Message( L"stream_editor.no_open_files", L"error", L"ok" )
        return false
    end

    return true
end

function PANEL:OnClickNew()
    local panel, id = self:AddTab()
    self:SetActiveTabById( id )
    panel:LoadJSON( nil )
end

function PANEL:OnClickOpen()
    Glide.EnsurePresetDataDir()

    if IsValid( self.fileBrowser ) then
        self.fileBrowser:Remove()
    end

    self.fileBrowser = StyledTheme.CreateFileBrowser()
    self.fileBrowser:SetTitle( L"stream_editor.open" )
    self.fileBrowser:SetExtensionFilter( { "json" } )
    self.fileBrowser:SetBasePath( "data/" )
    self.fileBrowser:NavigateTo( Glide.PRESET_DATA_DIR )

    self.fileBrowser.OnConfirmPath = function( path )
        local panel, id = self:AddTab()
        self:SetActiveTabById( id )
        panel:LoadPath( path )
    end
end

function PANEL:OnClickSave()
    Glide.EnsurePresetDataDir()

    if not self:IsAnyTabOpen() then
        return
    end

    local panel = self:GetActiveTab()
    if not panel then return end

    local data = panel:GetJSONData()

    local function WriteFile( path )
        local dir = string.GetPathFromFilename( path )

        if not file.Exists( dir, "DATA" ) then
            file.CreateDir( dir )
        end

        Glide.SaveDataFile( path, data )

        if file.Exists( path, "DATA" ) then
            notification.AddLegacy( string.format( L"stream_editor.saved", path ), NOTIFY_GENERIC, 5 )

            if IsValid( panel ) then
                panel:MarkAsSaved( "data/" .. path )
            end
        else
            notification.AddLegacy( L"stream_editor.err_save", NOTIFY_ERROR, 5 )
        end
    end

    local path = panel.filePath

    if string.StartsWith( path, "data_static/" ) then
        path = Glide.PRESET_DATA_DIR .. string.GetFileFromFilename( path )
    else
        path = string.sub( path, 6 ) -- Remove "data/"
    end

    if IsValid( self.fileBrowser ) then
        self.fileBrowser:Remove()
    end

    self.fileBrowser = StyledTheme.CreateFileBrowser()
    self.fileBrowser:SetTitle( L"stream_editor.save" )
    self.fileBrowser:SetExtensionFilter( { "json" } )
    self.fileBrowser:SetBasePath( "data/" )
    self.fileBrowser:NavigateTo( string.GetPathFromFilename( path ) )
    self.fileBrowser:EnableSaveMode( string.GetFileFromFilename( path ) )
    self.fileBrowser.entryName:SetPlaceholderText( L"stream_editor.enter_file_name" )

    self.fileBrowser.OnConfirmPath = function( newPath )
        newPath = string.Trim( newPath )
        newPath = string.sub( newPath, 6 ) -- Remove "data/"

        if string.len( newPath ) == 0 or newPath == string.GetFileFromFilename( newPath ) then
            Derma_Message( L"stream_editor.enter_file_name", L"error", L"ok" )
            return
        end

        local ext = string.Right( newPath, 5 )

        if ext ~= ".json" then
            newPath = newPath .. ".json"
        end

        WriteFile( newPath )
    end
end

function PANEL:OnClickImportJSON()
    if IsValid( self.fileBrowser ) then
        self.fileBrowser:Remove()
    end

    self.fileBrowser = StyledTheme.CreateFileBrowser()
    self.fileBrowser:SetTitle( L"stream_editor.import_json_static" )
    self.fileBrowser:SetExtensionFilter( { "json" } )
    self.fileBrowser:SetBasePath( "data_static/" )
    self.fileBrowser:NavigateTo( "glide/stream_presets" )

    self.fileBrowser.OnConfirmPath = function( path )
        local panel, id = self:AddTab()
        self:SetActiveTabById( id )
        panel:LoadPath( path )
    end
end

function PANEL:OnClickExportCode()
    if not self:IsAnyTabOpen() then
        return
    end

    local panel = self:GetActiveTab()
    if not panel then return end

    local lines = {
        "function ENT:OnCreateEngineStream( stream )"
    }

    local function Add( str, ... )
        lines[#lines + 1] = str:format( ... )
    end

    for k, default in pairs( Glide.DEFAULT_STREAM_PARAMS ) do
        local value = panel.stream[k]

        if value ~= default then
            Add( [[    stream.%s = %s]], k, value )
        end
    end

    Add( "" )

    local layers = panel.stream.layers

    for id, layer in pairs( layers ) do
        Add( [[    stream:AddLayer( "%s", "%s", {]], id, layer.path )

        for _, c in ipairs( layer.controllers ) do
            Add( [[        { "%s", %s, %s, "%s", %s, %s },]], c[1], c[2], c[3], c[4], c[5], c[6] )
        end

        Add( layer.redline and "    }, true )\n" or "    } )\n" )
    end

    Add( "end" )

    self:ShowExportFrame( table.concat( lines, "\n" ), L"stream_editor.export_code", L"stream_editor.export_help" )
end

function PANEL:OnClickAddLayer()
    if not self:IsAnyTabOpen() then
        return
    end

    local panel = self:GetActiveTab()
    if not panel then return end

    if panel.reachedResourceLimits then
        Derma_Message( L"stream_editor.resource_limit", L"error", L"ok" )
        return
    end

    if IsValid( self.fileBrowser ) then
        self.fileBrowser:Remove()
    end

    self.fileBrowser = StyledTheme.CreateFileBrowser()
    self.fileBrowser:SetTitle( L"stream_editor.open_audio" )
    self.fileBrowser:SetIcon( "icon16/sound.png" )
    self.fileBrowser:SetExtensionFilter( { "ogg", "wav", "mp3" } )
    self.fileBrowser:SetBasePath( "sound/" )

    self.fileBrowser.OnConfirmPath = function( path )
        path = string.sub( path, 7 ) -- remove "sound/"
        Glide.lastAudioFolderPath = string.GetPathFromFilename( path )

        panel = self:GetActiveTab()
        if panel then
            panel:AddLayer( nil, path )
        end
    end

    if Glide.lastAudioFolderPath then
        self.fileBrowser:NavigateTo( Glide.lastAudioFolderPath )
    end
end

function PANEL:OnClickRemoveAllLayers()
    if not self:IsAnyTabOpen() then
        return
    end

    Derma_Query( L"stream_editor.remove_all_layers_query", L"stream_editor.remove_all_layers", L"yes", function()
        local panel = self:GetActiveTab()
        if panel then
            panel:ClearLayers()
        end
    end, L"no" )
end

function PANEL:AddTab()
    self.lastTabId = self.lastTabId + 1

    local tab = { id = self.lastTabId }

    tab.button = vgui.Create( "Styled_StreamEditorTabButton" )
    tab.button:SetText( "*" )
    tab.button:Dock( LEFT )
    tab.button:DockMargin( 0, 0, 0, 0 )
    tab.button.tab = tab

    self.tabContainer:AddPanel( tab.button )

    tab.panel = vgui.Create( "Styled_StreamEditorTab", self.contentContainer )
    tab.panel:Dock( FILL )
    tab.panel:DockMargin( 0, 0, 0, 0 )
    tab.panel:DockPadding( 0, 0, 0, 0 )
    tab.panel:SetVisible( false )
    tab.panel.tab = tab

    StyledTheme.Apply( tab.panel )

    self.tabs[tab.id] = tab

    if #self.tabs == 1 then
        self:SetActiveTab( tab )
    end

    return tab.panel, tab.id
end

function PANEL:GetActiveTab()
    local id = self.activeTabId
    if not id then return end

    local tab = self.tabs[id]
    if not tab then return end

    return tab.panel, tab.button, id
end

function PANEL:SetActiveTab( targetTab )
    for id, tab in pairs( self.tabs ) do
        if tab == targetTab then
            self:SetActiveTabById( id )
            break
        end
    end
end

function PANEL:SetActiveTabById( targetId )
    local isThisOne, activePanel

    for id, t in pairs( self.tabs ) do
        isThisOne = id == targetId

        t.button.isSelected = isThisOne
        t.panel:SetVisible( isThisOne )
        t.panel:StopEngine()

        if isThisOne then
            self.activeTabId = id
            activePanel = t.panel
        end
    end

    if activePanel then
        activePanel:UpdateStats()
        activePanel:InvalidateEnginePanel()
    else
        self:UpdateStats( 0, 0 )
    end
end

function PANEL:CloseTabById( id, force )
    local tab = self.tabs[id]
    if not tab then return end

    if not force and tab.panel.isUnsaved then
        local query = string.format( L"stream_editor.unsaved_file_query", tab.button.text )

        Derma_Query( query, L"stream_editor.close", L"yes", function()
            self:CloseTabById( id, true )
        end, L"no" )

        return
    end

    tab.panel:Remove()
    tab.button:Remove()

    self.tabs[id] = nil

    if id == self.activeTabId then
        self:SetLastTabAsActive()
    end
end

function PANEL:SetLastTabAsActive()
    local largestId = 0

    for id, _ in pairs( self.tabs ) do
        if id > largestId then
            largestId = id
        end
    end

    self.activeTabId = nil
    self:SetActiveTabById( largestId )
end

function PANEL:UpdateStats( dataSize, layerCount )
    local maxDataSize = Glide.MAX_JSON_SIZE

    self.maxSizeLabel._progress = math.Clamp( dataSize / maxDataSize, 0, 1 )
    self.maxSizeLabel:SetText( string.NiceSize( dataSize ) .. " / " .. string.NiceSize( maxDataSize ) .. " " )
    self.maxSizeLabel:SizeToContentsX( ScaleSize( 30 ) )

    local maxLayerCount = Glide.MAX_STREAM_LAYERS

    self.maxLayersLabel._progress = math.Clamp( layerCount / maxLayerCount, 0, 1 )
    self.maxLayersLabel:SetText( layerCount .. " / " .. maxLayerCount .. " " )
    self.maxLayersLabel:SizeToContentsX( ScaleSize( 30 ) )
end

function PANEL:ShowExportFrame( code, titleText, helpText )
    if IsValid( self.frameExport ) then
        self.frameExport:Close()
    end

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( titleText )
    frame:SetIcon( "icon16/script_go.png" )
    frame:SetSize( ScaleSize( 800 ), ScaleSize( 600 ) )
    frame:SetDraggable( true )
    frame:SetDeleteOnClose( true )
    frame:Center()
    frame:MakePopup()

    StyledTheme.Apply( frame )
    self.frameExport = frame

    frame.OnClose = function()
        self.frameExport = nil
    end

    local labelHelp = vgui.Create( "DLabel", frame )
    labelHelp:SetFont( "Trebuchet18" )
    labelHelp:SetText( helpText )
    labelHelp:SetTextColor( Color( 255, 255, 255 ) )
    labelHelp:Dock( TOP )
    labelHelp:SetContentAlignment( 5 )

    StyledTheme.Apply( labelHelp )

    local entryCode = vgui.Create( "DTextEntry", frame )
    entryCode:Dock( FILL )
    entryCode:DockMargin( dimensions.framePadding, dimensions.framePadding, dimensions.framePadding, dimensions.framePadding )
    entryCode:SetMultiline( true )
    entryCode:SetValue( code )
    entryCode.AllowInput = function() return true end

    StyledTheme.Apply( entryCode )

    local buttonCopy = vgui.Create( "DButton", frame )
    buttonCopy:SetText( L"stream_editor.copy_clipboard" )
    buttonCopy:Dock( BOTTOM )

    StyledTheme.Apply( buttonCopy )

    buttonCopy.DoClick = function()
        SetClipboardText( code )
        frame:Close()
    end
end

function PANEL:PaintOver( w, h )
    if self.activeTabId == nil then
        draw.SimpleText( "#glide.stream_editor.no_open_files", "StyledTheme_Small", w * 0.5, h * 0.5, colors.buttonText, 1, 1 )
    end
end

function PANEL:OnKeyCodePressed( code )
    local control = input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL )

    if control and code ~= KEY_LCONTROL and code ~= KEY_RCONTROL then
        self:OnShortcut( code )
    end
end

vgui.Register( "Glide_EngineStreamEditor", PANEL, "DFrame" )

local TAB_BUTTON = {}

AccessorFunc( TAB_BUTTON, "iconPath", "Icon", FORCE_STRING )

function TAB_BUTTON:Init()
    self.textWidth = 0
    self.textHeight = 0

    self.isSelected = false
    self.animHover = 0

    self:SetCursor( "hand" )
    self:SetIcon( "icon16/bullet_black.png" )
    self:SetText( "Tab" )
end

function TAB_BUTTON:SetText( text )
    surface.SetFont( "StyledTheme_Small" )

    self.text = text
    self.textWidth, self.textHeight = surface.GetTextSize( text )
    self:InvalidateLayout()
end

function TAB_BUTTON:SetIcon( iconPath )
    self.iconPath = iconPath
end

function TAB_BUTTON:OnMousePressed( keyCode )
    -- self -> DDragBase -> DHorizontalScroller -> Glide_EngineStreamEditor
    local frame = self:GetParent():GetParent():GetParent()
    local tabId = self.tab.id

    if keyCode == MOUSE_LEFT then
        frame:SetActiveTabById( tabId )

    elseif keyCode == MOUSE_RIGHT then

        local menu = DermaMenu()
        menu:AddOption( UL"close", function() frame:CloseTabById( tabId ) end )
        menu:Open()

    elseif keyCode == MOUSE_MIDDLE then
        frame:CloseTabById( tabId )
    end
end

function TAB_BUTTON:PerformLayout( _, h )
    local padding = dimensions.menuPadding * 2
    local iconSize = 0

    if self.iconPath then
        iconSize = math.floor( h * 0.5 )
        padding = iconSize + dimensions.menuPadding * 3
    end

    self:SetWide( self.textWidth + padding )
end

local DrawRect = StyledTheme.DrawRect
local DrawIcon = StyledTheme.DrawIcon

function TAB_BUTTON:Paint( w, h )
    self.animHover = Lerp( FrameTime() * 10, self.animHover, self:IsHovered() and 1 or 0 )

    DrawRect( 0, 0, w, h, self.isSelected and colors.buttonPress or colors.buttonBorder )
    DrawRect( 1, 1, w - 2, h - 1, colors.panelBackground )
    DrawRect( 1, 1, w - 2, h - 1, colors.buttonHover, self.animHover )

    local padding = dimensions.menuPadding
    local iconSize = 0

    if self.iconPath then
        iconSize = math.floor( h * 0.5 )
        DrawIcon( self.iconPath, padding, ( h * 0.5 ) - ( iconSize * 0.5 ), iconSize, iconSize )
        padding = iconSize + padding * 2
    end

    draw.SimpleText( self.text, "StyledTheme_Small", padding, h * 0.5, colors.buttonText, 0, 1 )
end

vgui.Register( "Styled_StreamEditorTabButton", TAB_BUTTON, "DPanel" )
