--[[
    StyledStrike's VGUI theme utilities

    This file adds a new panel class: the tabbed frame
]]

if not StyledTheme then
    error( "styled_theme.lua must be included first!" )
end

local colors = StyledTheme.colors
local dimensions = StyledTheme.dimensions

local TAB_BUTTON = {}

AccessorFunc( TAB_BUTTON, "iconPath", "Icon", FORCE_STRING )

function TAB_BUTTON:Init()
    self:SetCursor( "hand" )
    self:SetIcon( "icon16/bricks.png" )

    self.isSelected = false
    self.notificationCount = 0
    self.animHover = 0
end

function TAB_BUTTON:OnMousePressed( keyCode )
    if keyCode == MOUSE_LEFT then
        self:GetParent():GetParent():SetActiveTab( self.tab )
    end
end

local Lerp = Lerp
local FrameTime = FrameTime
local DrawRect = StyledTheme.DrawRect
local DrawIcon = StyledTheme.DrawIcon

local COLOR_INDICATOR = Color( 200, 0, 0, 255 )

function TAB_BUTTON:Paint( w, h )
    self.animHover = Lerp( FrameTime() * 10, self.animHover, self:IsHovered() and 1 or 0 )

    DrawRect( 0, 0, w, h, colors.buttonBorder )
    DrawRect( 1, 1, w - 2, h - 2, colors.panelBackground )
    DrawRect( 1, 1, w - 2, h - 2, colors.buttonHover, self.animHover )

    if self.isSelected then
        DrawRect( 1, 1, w - 2, h - 2, colors.buttonPress )
    end

    local iconSize = math.floor( math.max( w, h ) * 0.5 )
    DrawIcon( self.iconPath, ( w * 0.5 ) - ( iconSize * 0.5 ), ( h * 0.5 ) - ( iconSize * 0.5 ), iconSize, iconSize )

    if self.notificationCount > 0 then
        local size = dimensions.indicatorSize
        local margin = math.floor( h * 0.05 )
        local x = w - size - margin
        local y = h - size - margin

        draw.RoundedBox( size * 0.5, x, y, size, size, COLOR_INDICATOR )
        draw.SimpleText( self.notificationCount, "StyledTheme_Tiny", x + size * 0.5, y + size * 0.5, colors.buttonText, 1, 1 )
    end
end

vgui.Register( "Styled_TabButton", TAB_BUTTON, "DPanel" )

local TABBED_FRAME = {}
local ScaleSize = StyledTheme.ScaleSize

function TABBED_FRAME:Init()
    StyledTheme.Apply( self, "DFrame" )

    local w = ScaleSize( 850 )
    local h = ScaleSize( 600 )

    self:SetSize( w, h )
    self:SetSizable( true )
    self:SetDraggable( true )
    self:SetDeleteOnClose( true )
    self:SetScreenLock( true )
    self:SetMinWidth( w )
    self:SetMinHeight( h )

    self.tabList = vgui.Create( "DPanel", self )
    self.tabList:SetWide( ScaleSize( 64 ) )
    self.tabList:Dock( LEFT )
    self.tabList:DockPadding( 0, 0, 0, 0 )
    self.tabList:SetPaintBackground( false )
    --StyledTheme.Apply( self.tabList )

    self.contentContainer = vgui.Create( "DPanel", self )
    self.contentContainer:Dock( FILL )
    self.contentContainer:DockMargin( ScaleSize( 4 ), 0, 0, 0 )
    self.contentContainer:DockPadding( 0, 0, 0, 0 )
    self.contentContainer:SetPaintBackground( false )

    self.tabs = {}
end

function TABBED_FRAME:AddTab( icon, tooltip, panelClass )
    panelClass = panelClass or "DScrollPanel"

    local tab = {}

    tab.button = vgui.Create( "Styled_TabButton", self.tabList )
    tab.button:SetIcon( icon )
    tab.button:SetTall( ScaleSize( 64 ) )
    tab.button:SetTooltip( tooltip )
    tab.button:Dock( TOP )
    tab.button:DockMargin( 0, 0, 0, 2 )
    tab.button.tab = tab

    tab.panel = vgui.Create( panelClass, self.contentContainer )
    tab.panel:Dock( FILL )
    tab.panel:DockMargin( 0, 0, 0, 0 )
    tab.panel:DockPadding( 0, 0, 0, 0 )
    tab.panel:SetVisible( false )

    StyledTheme.Apply( tab.panel )

    if panelClass == "DScrollPanel" then
        local padding = dimensions.formPadding
        tab.panel.pnlCanvas:DockPadding( padding, 0, padding, padding )
    end

    self.tabs[#self.tabs + 1] = tab

    if #self.tabs == 1 then
        self:SetActiveTab( tab )
    end

    return tab.panel
end

function TABBED_FRAME:SetActiveTab( tab )
    for i, t in ipairs( self.tabs ) do
        local isThisOne = t == tab

        t.button.isSelected = isThisOne
        t.panel:SetVisible( isThisOne )

        if isThisOne then
            self.lastTabIndex = i
        end
    end
end

function TABBED_FRAME:SetActiveTabByIndex( index )
    if self.tabs[index] then
        self:SetActiveTab( self.tabs[index] )
    end
end

function TABBED_FRAME:SetTabNotificationCountByIndex( index, count )
    if self.tabs[index] then
        self.tabs[index].button.notificationCount = count
    end
end

vgui.Register( "Styled_TabbedFrame", TABBED_FRAME, "DFrame" )
