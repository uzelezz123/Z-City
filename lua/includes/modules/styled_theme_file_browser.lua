--[[
    StyledStrike's VGUI theme utilities

    This file adds a new panel class: the file browser
]]

if not StyledTheme then
    error( "styled_theme.lua must be included first!" )
end

function StyledTheme.CreateFileBrowser()
    local frame = vgui.Create( "Styled_FileBrowser" )
    frame:Center()
    frame:MakePopup()

    return frame
end

local FILE_ICONS = {
    ["default"] = "icon16/page_white.png",
    ["lua"] = "icon16/page_white_code.png",

    ["mdl"] = "icon16/page_white_powerpoint.png",
    ["vtf"] = "icon16/page_white_swoosh.png",
    ["vmt"] = "icon16/page_white_code.png",

    ["png"] = "icon16/page_white_picture.png",
    ["jpg"] = "icon16/page_white_picture.png",
    ["gif"] = "icon16/page_white_picture.png",

    ["txt"] = "icon16/page_white_text.png",
    ["md"] = "icon16/page_white_text.png",

    ["conf"] = "icon16/page_white_gear.png",
    ["ini"] = "icon16/page_white_gear.png",
    ["properties"] = "icon16/page_white_gear.png",

    ["wav"] = "icon16/sound.png",
    ["ogg"] = "icon16/sound.png",
    ["mp3"] = "icon16/sound.png",
}

local L = StyledTheme.GetUpperLanguagePhrase
local ScaleSize = StyledTheme.ScaleSize
local BROWSER = {}

function BROWSER:Init()
    local w, h = ScaleSize( 800 ), ScaleSize( 600 )

    self:SetIcon( "icon16/folder.png" )
    self:SetTitle( L"file" )
    self:SetSize( w, h )
    self:SetMinWidth( w )
    self:SetMinHeight( h )
    self:SetSizable( true )
    self:SetDraggable( true )
    self:SetDeleteOnClose( true )
    self:SetScreenLock( true )
    self:SetBackgroundBlur( true )

    local separator = ScaleSize( 8 )

    self.panelHeader = vgui.Create( "DPanel", self )
    self.panelHeader:SetTall( ScaleSize( 40 ) )
    self.panelHeader:Dock( TOP )
    self.panelHeader:DockMargin( 0, 0, 0, separator )
    self.panelHeader:DockPadding( separator, separator, separator, separator )
    self.panelHeader:SetBackgroundColor( StyledTheme.colors.accent )

    self.panelHeader.PerformLayout = function( s )
        local extraNavWidth = ScaleSize( 10 )

        for _, child in ipairs( s:GetChildren() ) do
            child:SizeToContentsX( extraNavWidth )
        end
    end

    self.scrollFiles = vgui.Create( "DScrollPanel", self )
    self.scrollFiles:Dock( FILL )

    self.panelOptions = vgui.Create( "DPanel", self )
    self.panelOptions:SetTall( ScaleSize( 50 ) )
    self.panelOptions:Dock( BOTTOM )
    self.panelOptions:DockMargin( 0, separator, 0, 0 )
    self.panelOptions:DockPadding( separator, separator, separator, separator )
    self.panelOptions:SetPaintBackground( false )

    self.buttonCancel = vgui.Create( "DButton", self.panelOptions )
    self.buttonCancel:SetText( L"cancel" )
    self.buttonCancel:SizeToContentsX( ScaleSize( 60 ) )
    self.buttonCancel:Dock( RIGHT )
    self.buttonCancel:DockMargin( separator, 0, 0, 0 )

    self.buttonCancel.DoClick = function()
        self:Close()
    end

    self:SetBasePath( "/" )
    self:NavigateTo( "/" )
    self:SetExtensionFilter( nil )

    self.OnConfirmPath = function( _path ) end

    StyledTheme.Apply( self, "DFrame" )
    StyledTheme.Apply( self.panelHeader )
    StyledTheme.Apply( self.scrollFiles )
    StyledTheme.Apply( self.buttonCancel )
end

function BROWSER:EnableSaveMode( defaultFileName )
    self.saveMode = true
    self.updateFiles = true

    self.entryName = vgui.Create( "DTextEntry", self.panelOptions )
    self.entryName:SetText( defaultFileName or "untitled.txt" )
    self.entryName:Dock( FILL )

    local DoSave = function()
        local path = self.basePath .. table.concat( self.currentNavigation, "/" ) .. "/" .. self.entryName:GetValue()
        self.OnConfirmPath( self:NormalizePath( path ) )
        self:Close()
    end

    self.entryName.OnEnter = DoSave
    StyledTheme.Apply( self.entryName )

    self.buttonSave = vgui.Create( "DButton", self.panelOptions )
    self.buttonSave:SetText( L"preset.okay" )
    self.buttonSave:SizeToContentsX( ScaleSize( 60 ) )
    self.buttonSave:Dock( RIGHT )
    self.buttonSave:DockMargin( ScaleSize( 8 ), 0, 0, 0 )
    self.buttonSave.DoClick = DoSave

    StyledTheme.Apply( self.buttonSave )
end

function BROWSER:SetBasePath( path )
    self.basePath = path
    self.updateFiles = true
end

function BROWSER:SetExtensionFilter( extensionFilter )
    if extensionFilter then
        local filter = {}

        for _, ext in ipairs( extensionFilter ) do
            filter[ext] = true
        end

        self.extensionFilter = filter
    else
        self.extensionFilter = nil
    end

    self.updateFiles = true
end

function BROWSER:NormalizePath( path )
    path = string.gsub( path, "/+", "/" )

    if path:sub( 1, 1 ) == "/" then
        path = path:sub( 2 )
    end

    return path
end

function BROWSER:NavigateTo( dir )
    dir = self:NormalizePath( dir )

    local nav = { "/" }

    for _, part in ipairs( string.Explode( "/", dir, false ) ) do
        if part ~= "" then
            nav[#nav + 1] = part
        end
    end

    self.updateFiles = true
    self.currentNavigation = nav
end

local BaseClass = baseclass.Get( "DFrame" )

function BROWSER:Think()
    BaseClass.Think( self )

    if not self.updateFiles then return end

    self.updateFiles = false

    -- Update navigation header
    self.panelHeader:Clear()

    local OnClickNav = function( s )
        self:NavigateTo( s._path )
    end

    local pathSoFar = ""
    local separator = ScaleSize( 4 )

    for i, piece in ipairs( self.currentNavigation ) do
        pathSoFar = pathSoFar .. "/" .. piece

        if i == 1 then
            piece = self.basePath
        end

        local item = vgui.Create( "DButton", self.panelHeader )
        item:SetText( piece )
        item:Dock( LEFT )
        item:DockMargin( 0, 0, separator, 0 )
        item.DoClick = OnClickNav
        item._path = pathSoFar

        StyledTheme.Apply( item )
    end

    -- Update file list
    self.scrollFiles:Clear()

    local currentDir = self:NormalizePath( table.concat( self.currentNavigation, "/" ) .. "/" )
    local normalizedDir = self:NormalizePath( self.basePath .. currentDir .. "*" )
    local files, dirs = file.Find( normalizedDir, "GAME", "nameasc" )

    if #self.currentNavigation > 1 then
        local itemUpDir = self.scrollFiles:Add( "Styled_FileBrowserItem" )
        itemUpDir:SetItemName( ".." )
        itemUpDir:SetIconPath( "icon16/arrow_up.png" )
        itemUpDir:SetTall( 28 )
        itemUpDir:Dock( TOP )
        itemUpDir:DockMargin( 0, separator, 0, 0 )
        itemUpDir.onClick = OnClickNav

        local upNavigation = table.Copy( self.currentNavigation )
        table.remove( upNavigation, #upNavigation )
        itemUpDir._path = self:NormalizePath( table.concat( upNavigation, "/" ) .. "/" )
    end

    if dirs then
        for _, name in ipairs( dirs ) do
            local item = self.scrollFiles:Add( "Styled_FileBrowserItem" )
            item:SetItemName( name )
            item:SetTall( 28 )
            item:Dock( TOP )
            item:DockMargin( 0, separator, 0, 0 )
            item.onClick = OnClickNav
            item._path = currentDir .. name
        end
    end

    local OnClickOpen = function( s )
        if self.saveMode then
            self.entryName:SetText( s:GetItemName() )
            return
        end

        local path = self:NormalizePath( s._path )

        self:Close()
        self.OnConfirmPath( self:NormalizePath( self.basePath .. path ) )
    end

    if files then
        local filter = self.extensionFilter
        local itemHeight = ScaleSize( 40 )

        for _, name in ipairs( files ) do
            local ext = string.GetExtensionFromFilename( name )

            if filter == nil or filter[ext] then
                local item = self.scrollFiles:Add( "Styled_FileBrowserItem" )
                item:SetItemName( name )
                item:SetIconPath( FILE_ICONS[ext] or FILE_ICONS.default )
                item:SetTall( itemHeight )
                item:Dock( TOP )
                item:DockMargin( 0, separator, 0, 0 )

                item.onClick = OnClickOpen
                item._path = currentDir .. name
            end
        end
    end
end

vgui.Register( "Styled_FileBrowser", BROWSER, "DFrame" )

local ITEM = {}

AccessorFunc( ITEM, "itemName", "ItemName", FORCE_STRING )
AccessorFunc( ITEM, "iconPath", "IconPath", FORCE_STRING )
AccessorFunc( ITEM, "iconScale", "IconScale", FORCE_NUMBER )

function ITEM:Init()
    self:SetItemName( "Item" )
    self:SetIconPath( "icon16/folder.png" )
    self:SetIconScale( 0.7 )

    self.isPressed = false
    self.animHover = 0
    self.animPress = 0
end

function ITEM:OnMousePressed( keyCode )
    if keyCode == MOUSE_LEFT then
        self.isPressed = true
    end
end

function ITEM:OnMouseReleased( keyCode )
    if keyCode == MOUSE_LEFT and self.isPressed and self.onClick then
        self:onClick()
    end

    self.isPressed = false
end

function ITEM:OnCursorExited()
    self.isPressed = false
end

local Lerp = Lerp
local FrameTime = FrameTime

function ITEM:Think()
    local dt = FrameTime()

    self.animHover = Lerp( dt * 10, self.animHover, self:IsHovered() and 1 or 0 )
    self.animPress = Lerp( dt * 20, self.animPress, self.isPressed and 1 or 0 )
end

local Floor = math.floor
local SimpleText = draw.SimpleText
local DrawIcon = StyledTheme.DrawIcon
local DrawRect = StyledTheme.DrawRect
local colors = StyledTheme.colors

function ITEM:Paint( w, h )
    DrawRect( 0, 0, w, h, colors.buttonBorder )
    DrawRect( 1, 1, w - 2, h - 2, colors.panelBackground )
    DrawRect( 1, 1, w - 2, h - 2, colors.buttonHover, self.animHover )
    DrawRect( 1, 1, w - 2, h - 2, colors.buttonPress, self.animPress )

    local iconSize = Floor( h * self.iconScale )

    DrawIcon( self.iconPath, h * 0.1, ( h * 0.5 ) - ( iconSize * 0.5 ), iconSize, iconSize )
    SimpleText( self.itemName, "DermaDefault", iconSize * 1.3, h * 0.5, colors.buttonText, 0, 1 )
end

vgui.Register( "Styled_FileBrowserItem", ITEM, "Panel" )
