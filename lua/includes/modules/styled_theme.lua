--[[
    StyledStrike's VGUI theme utilities

    A collection of functions to create common
    UI panels and to apply a custom theme to them.
]]

StyledTheme = StyledTheme or {}

--[[
    Setup color constants
]]
do
    StyledTheme.colors = StyledTheme.colors or {}

    local colors = StyledTheme.colors or {}

    colors.accent = Color( 56, 113, 179 )
    colors.panelBackground = Color( 46, 46, 46, 240 )
    colors.panelDisabledBackground = Color( 90, 90, 90, 255 )
    colors.scrollBackground = Color( 0, 0, 0, 200 )

    colors.labelText = Color( 255, 255, 255, 255 )
    colors.labelTextDisabled = Color( 180, 180, 180, 255 )

    colors.buttonHover = Color( 150, 150, 150, 50 )
    colors.buttonPress = colors.accent
    colors.buttonBorder = Color( 32, 32, 32, 255 )
    colors.buttonText = Color( 255, 255, 255, 255 )
    colors.buttonTextDisabled = Color( 180, 180, 180, 255 )

    colors.entryBackground = Color( 20, 20, 20, 255 )
    colors.entryBorder = Color( 80, 80, 80, 255 )
    colors.entryHighlight = colors.accent
    colors.entryPlaceholder = Color( 150, 150, 150, 255 )
    colors.entryText = Color( 255, 255, 255, 255 )
end

--[[
    Setup dimensions
]]
StyledTheme.dimensions = StyledTheme.dimensions or {}

hook.Add( "StyledTheme_OnResolutionChange", "StyledTheme.UpdateDimensions", function()
    local dimensions = StyledTheme.dimensions
    local ScaleSize = StyledTheme.ScaleSize

    dimensions.framePadding = ScaleSize( 10 )
    dimensions.frameButtonSize = ScaleSize( 36 )

    dimensions.buttonHeight = ScaleSize( 40 )
    dimensions.headerHeight = ScaleSize( 32 )

    dimensions.scrollBarWidth = ScaleSize( 16 )
    dimensions.scrollPadding = ScaleSize( 8 )

    dimensions.formPadding = ScaleSize( 20 )
    dimensions.formSeparator = ScaleSize( 6 )
    dimensions.formLabelWidth = ScaleSize( 300 )

    dimensions.menuPadding = ScaleSize( 6 )
    dimensions.indicatorSize = ScaleSize( 20 )
end )

--[[
    Setup fonts
]]
StyledTheme.BASE_FONT_NAME = "Roboto"
StyledTheme.fonts = StyledTheme.fonts or {}

function StyledTheme.RegisterFont( name, screenSize, data )
    data = data or {}

    data.screenSize = screenSize
    data.font = data.font or StyledTheme.BASE_FONT_NAME
    data.extended = true

    StyledTheme.fonts[name] = data
    StyledTheme.forceUpdateResolution = true
end

StyledTheme.RegisterFont( "StyledTheme_Small", 0.018, {
    weight = 500,
} )

StyledTheme.RegisterFont( "StyledTheme_Tiny", 0.013, {
    weight = 500,
} )

hook.Add( "StyledTheme_OnResolutionChange", "StyledTheme.UpdateFonts", function( _, screenH )
    for name, data in pairs( StyledTheme.fonts ) do
        data.size = math.floor( screenH * data.screenSize )
        surface.CreateFont( name, data )
    end
end )

--[[
    Watch for changes in screen resolution
]]
do
    local screenW, screenH = ScrW(), ScrH()
    local Floor = math.floor

    --- Scales the given size (in pixels) from a 1080p resolution to 
    --- the resolution currently being used by the game.
    function StyledTheme.ScaleSize( size )
        return Floor( ( size / 1080 ) * screenH )
    end

    local function UpdateResolution()
        screenW, screenH = ScrW(), ScrH()
        StyledTheme.forceUpdateResolution = false
        hook.Run( "StyledTheme_OnResolutionChange", screenW, screenH )
    end

    -- Only update resolution on gamemode initialization.
    hook.Add( "Initialize", "StyledTheme.UpdateResolution", UpdateResolution )

    local ScrW, ScrH = ScrW, ScrH

    timer.Create( "StyledTheme.CheckResolution", 2, 0, function()
        if ScrW() ~= screenW or ScrH() ~= screenH or StyledTheme.forceUpdateResolution then
            UpdateResolution()
        end
    end )
end

--[[
    Misc. utility functions
]]
do
    --- Gets a localized language string, with the first character being in uppercase.
    function StyledTheme.GetUpperLanguagePhrase( text )
        text = language.GetPhrase( text )
        return text:sub( 1, 1 ):upper() .. text:sub( 2 )
    end

    local SetDrawColor = surface.SetDrawColor
    local DrawRect = surface.DrawRect

    --- Draw box, using the specified background color.
    --- It allows overriding the alpha while keeping the supplied color table intact.
    function StyledTheme.DrawRect( x, y, w, h, color, alpha )
        alpha = alpha or 1

        SetDrawColor( color.r, color.g, color.b, color.a * alpha )
        DrawRect( x, y, w, h )
    end

    local SetMaterial = surface.SetMaterial
    local MAT_BLUR = Material( "pp/blurscreen" )

    --- Blur the background of a panel.
    function StyledTheme.BlurPanel( panel, alpha, density )
        SetDrawColor( 255, 255, 255, alpha or panel:GetAlpha() )
        SetMaterial( MAT_BLUR )

        MAT_BLUR:SetFloat( "$blur", density or 4 )
        MAT_BLUR:Recompute()

        render.UpdateScreenEffectTexture()

        local x, y = panel:LocalToScreen( 0, 0 )
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end

    local cache = {}

    -- Get a material given a path to a material or .png file.
    function StyledTheme.GetMaterial( path )
        if cache[path] then
            return cache[path]
        end

        cache[path] = Material( path, "smooth ignorez" )

        return cache[path]
    end

    local GetMaterial = StyledTheme.GetMaterial
    local DrawTexturedRect = surface.DrawTexturedRect
    local COLOR_WHITE = Color( 255, 255, 255, 255 )

    --- Draw a icon, using the specified image file path and color.
    --- It allows overriding the alpha while keeping the supplied color table intact.
    function StyledTheme.DrawIcon( path, x, y, w, h, alpha, color )
        color = color or COLOR_WHITE
        alpha = alpha or 1

        SetMaterial( GetMaterial( path ) )
        SetDrawColor( color.r, color.g, color.b, 255 * alpha )
        DrawTexturedRect( x, y, w, h )
    end
end

--[[
    Utility function to apply the theme to existing VGUI panels
]]
do
    local ClassFunctions = {}

    function StyledTheme.Apply( panel, classOverride )
        local funcs = ClassFunctions[classOverride or panel.ClassName]
        if not funcs then return end

        if funcs.Prepare then
            funcs.Prepare( panel )
        end

        if funcs.Paint then
            panel.Paint = funcs.Paint
        end

        if funcs.UpdateColours then
            panel.UpdateColours = funcs.UpdateColours
        end

        if funcs.Close then
            panel.Close = funcs.Close
        end
    end

    local colors = StyledTheme.colors
    local dimensions = StyledTheme.dimensions
    local DrawRect = StyledTheme.DrawRect

    ClassFunctions["DLabel"] = {
        Prepare = function( self )
            self:SetColor( colors.labelText )
            self:SetFont( "StyledTheme_Small" )
        end
    }

    ClassFunctions["DPanel"] = {
        Paint = function( self, w, h )
            DrawRect( 0, 0, w, h, self:GetBackgroundColor() or colors.panelBackground )
        end
    }

    local function CustomMenuAdd( self, class )
        local pnl = self:OriginalAdd( class )

        if class == "DButton" then
            StyledTheme.Apply( pnl )

            timer.Simple( 0, function()
                if not IsValid( pnl ) then return end

                pnl:SetPaintBackground( true )
                pnl:SizeToContentsX( StyledTheme.ScaleSize( 20 ) )
                pnl:DockMargin( 0, 0, dimensions.menuPadding, 0 )
            end )
        end

        return pnl
    end

    ClassFunctions["DMenuBar"] = {
        Prepare = function( self )
            self:SetTall( dimensions.buttonHeight )
            self:DockMargin( 0, 0, 0, 0 )
            self:DockPadding( dimensions.menuPadding, dimensions.menuPadding, dimensions.menuPadding, dimensions.menuPadding )

            self.OriginalAdd = self.Add
            self.Add = CustomMenuAdd
        end,
        Paint = function( self, w, h )
            DrawRect( 0, 0, w, h, self:GetBackgroundColor() or colors.accent )
        end
    }

    local Lerp = Lerp
    local FrameTime = FrameTime

    ClassFunctions["DButton"] = {
        Prepare = function( self )
            self:SetFont( "StyledTheme_Small" )
            self:SetTall( dimensions.buttonHeight )
            self.animHover = 0
            self.animPress = 0
        end,

        Paint = function( self, w, h )
            local dt = FrameTime() * 10
            local enabled = self:IsEnabled()

            self.animHover = Lerp( dt, self.animHover, ( enabled and self.Hovered ) and 1 or 0 )
            self.animPress = Lerp( dt, self.animPress, ( enabled and ( self:IsDown() or self.m_bSelected ) ) and 1 or 0 )

            DrawRect( 0, 0, w, h, ( self.isToggle and self.isChecked ) and colors.buttonPress or colors.buttonBorder )
            DrawRect( 1, 1, w - 2, h - 2, enabled and colors.panelBackground or colors.panelDisabledBackground )
            DrawRect( 1, 1, w - 2, h - 2, colors.buttonHover, self.animHover )
            DrawRect( 1, 1, w - 2, h - 2, colors.buttonPress, self.animPress )
        end,

        UpdateColours = function( self )
            if self:IsEnabled() then
                self:SetTextStyleColor( colors.buttonText )
            else
                self:SetTextStyleColor( colors.buttonTextDisabled )
            end
        end
    }

    ClassFunctions["DBinder"] = ClassFunctions["DButton"]

    ClassFunctions["DTextEntry"] = {
        Prepare = function( self )
            self:SetFont( "StyledTheme_Small" )
            self:SetTall( dimensions.buttonHeight )
            self:SetDrawBorder( false )
            self:SetPaintBackground( false )

            self:SetTextColor( colors.entryText )
            self:SetCursorColor( colors.entryText )
            self:SetHighlightColor( colors.entryHighlight )
            self:SetPlaceholderColor( colors.entryPlaceholder )
        end,

        Paint = function( self, w, h )
            local enabled = self:IsEnabled()

            DrawRect( 0, 0, w, h, ( self:IsEditing() and enabled ) and colors.entryHighlight or colors.entryBorder )
            DrawRect( 1, 1, w - 2, h - 2, enabled and colors.entryBackground or colors.panelDisabledBackground )

            derma.SkinHook( "Paint", "TextEntry", self, w, h )
        end
    }

    ClassFunctions["DComboBox"] = {
        Prepare = function( self )
            self:SetFont( "StyledTheme_Small" )
            self:SetTall( dimensions.buttonHeight )
            self:SetTextColor( colors.entryText )
            self.animHover = 0
        end,

        Paint = function( self, w, h )
            local dt = FrameTime() * 10
            local enabled = self:IsEnabled()

            self.animHover = Lerp( dt, self.animHover, ( enabled and self.Hovered ) and 1 or 0 )

            DrawRect( 0, 0, w, h, ( self:IsMenuOpen() and enabled ) and colors.entryHighlight or colors.buttonBorder )
            DrawRect( 1, 1, w - 2, h - 2, enabled and colors.panelBackground or colors.panelDisabledBackground )
            DrawRect( 1, 1, w - 2, h - 2, colors.buttonHover, self.animHover )
        end
    }

    ClassFunctions["DNumSlider"] = {
        Prepare = function( self )
            StyledTheme.Apply( self.TextArea )
            StyledTheme.Apply( self.Label )
        end
    }

    ClassFunctions["DScrollPanel"] = {
        Prepare = function( self )
            StyledTheme.Apply( self.VBar )

            local padding = dimensions.scrollPadding
            self.pnlCanvas:DockPadding( padding, padding, padding, padding )
            self:SetPaintBackground( true )
        end,

        Paint = function( self, w, h )
            if self:GetPaintBackground() then
                DrawRect( 0, 0, w, h, colors.scrollBackground )
            end
        end
    }

    local Clamp = math.Clamp

    local function AddScroll( self, delta )
        local oldScroll = self.animTargetScroll or self:GetScroll()
        local newScroll = Clamp( oldScroll + delta * 40, 0, self.CanvasSize )

        if oldScroll == newScroll then
            return false
        end

        self:Stop()
        self.animTargetScroll = newScroll

        local anim = self:NewAnimation( 0.4, 0, 0.25, function( _, pnl )
            pnl.animTargetScroll = nil
        end )

        anim.StartPos = oldScroll
        anim.TargetPos = newScroll

        anim.Think = function( a, pnl, fraction )
            pnl:SetScroll( Lerp( fraction, a.StartPos, a.TargetPos ) )
        end

        return true
    end

    local function DrawGrip( self, w, h )
        local dt = FrameTime() * 10

        self.animHover = Lerp( dt, self.animHover, self.Hovered and 1 or 0 )
        self.animPress = Lerp( dt, self.animPress, self.Depressed and 1 or 0 )

        DrawRect( 0, 0, w, h, colors.buttonBorder )
        DrawRect( 1, 1, w - 2, h - 2, colors.panelBackground )
        DrawRect( 1, 1, w - 2, h - 2, colors.buttonHover, self.animHover )
        DrawRect( 1, 1, w - 2, h - 2, colors.buttonPress, self.animPress )
    end

    ClassFunctions["DVScrollBar"] = {
        Prepare = function( self )
            self:SetWide( dimensions.scrollBarWidth )
            self:SetHideButtons( true )
            self.AddScroll = AddScroll

            self.btnGrip.animHover = 0
            self.btnGrip.animPress = 0
            self.btnGrip.Paint = DrawGrip
        end,

        Paint = function( _, w, h )
            DrawRect( 0, 0, w, h, colors.scrollBackground )
        end
    }

    local function FrameSlideAnim( anim, panel, fraction )
        if not anim.StartPos then
            anim.StartPos = Vector( panel.x, panel.y + anim.StartOffset, 0 )
            anim.TargetPos = Vector( panel.x, panel.y + anim.EndOffset, 0 )
        end

        local pos = LerpVector( fraction, anim.StartPos, anim.TargetPos )
        panel:SetPos( pos.x, pos.y )
        panel:SetAlpha( 255 * Lerp( fraction, anim.StartAlpha, anim.EndAlpha ) )
    end

    local function FramePerformLayout( self, w )
        local padding = dimensions.framePadding
        local buttonSize = dimensions.frameButtonSize

        self.btnClose:SetSize( buttonSize, buttonSize )
        self.btnClose:SetPos( w - self.btnClose:GetWide() - padding, padding )

        local iconMargin = 0

        if IsValid( self.imgIcon ) then
            local iconSize = buttonSize * 0.6

            self.imgIcon:SetPos( padding, padding + ( buttonSize * 0.5 ) - ( iconSize * 0.5 ) )
            self.imgIcon:SetSize( iconSize, iconSize )

            iconMargin = iconSize + padding * 0.5
        end

        self.lblTitle:SetPos( padding + iconMargin, padding )
        self.lblTitle:SetSize( w - ( padding * 2 ) - iconMargin, buttonSize )
    end

    ClassFunctions["DFrame"] = {
        Prepare = function( self )
            self._OriginalClose = self.Close
            self.PerformLayout = FramePerformLayout

            StyledTheme.Apply( self.btnClose )
            StyledTheme.Apply( self.lblTitle )

            local padding = dimensions.framePadding
            local buttonSize = dimensions.frameButtonSize

            self:DockPadding( padding, buttonSize + padding * 2, padding, padding )
            self.btnClose:SetText( "X" )

            if IsValid( self.btnMaxim ) then
                self.btnMaxim:Remove()
            end

            if IsValid( self.btnMinim ) then
                self.btnMinim:Remove()
            end

            local anim = self:NewAnimation( 0.4, 0, 0.25 )
            anim.StartOffset = -80
            anim.EndOffset = 0
            anim.StartAlpha = 0
            anim.EndAlpha = 1
            anim.Think = FrameSlideAnim
        end,

        Close = function( self )
            self:SetMouseInputEnabled( false )
            self:SetKeyboardInputEnabled( false )

            if self.OnStartClosing then
                self.OnStartClosing()
            end

            local anim = self:NewAnimation( 0.2, 0, 0.5, function()
                self:_OriginalClose()
            end )

            anim.StartOffset = 0
            anim.EndOffset = -80
            anim.StartAlpha = 1
            anim.EndAlpha = 0
            anim.Think = FrameSlideAnim
        end,

        Paint = function( self, w, h )
            if self.m_bBackgroundBlur then
                Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
            else
                StyledTheme.BlurPanel( self )
            end

            DrawRect( 0, 0, w, h, colors.panelBackground, self:GetAlpha() / 255 )
        end
    }
end

--[[
    Utility functions to create "form" panels.
]]
do
    local colors = StyledTheme.colors
    local dimensions = StyledTheme.dimensions

    function StyledTheme.CreateFormHeader( parent, text, mtop, mbottom )
        mtop = mtop or dimensions.formSeparator
        mbottom = mbottom or dimensions.formSeparator

        local panel = vgui.Create( "DPanel", parent )
        panel:SetTall( dimensions.headerHeight )
        panel:Dock( TOP )
        panel:DockMargin( -dimensions.formPadding, mtop, -dimensions.formPadding, mbottom )
        panel:SetBackgroundColor( colors.scrollBackground )

        StyledTheme.Apply( panel )

        local label = vgui.Create( "DLabel", panel )
        label:SetText( text )
        label:SetContentAlignment( 5 )
        label:SizeToContents()
        label:Dock( FILL )

        StyledTheme.Apply( label )

        return panel
    end

    function StyledTheme.CreateFormLabel( parent, text )
        local label = vgui.Create( "DLabel", parent )
        label:Dock( TOP )
        label:DockMargin( 0, 0, 0, dimensions.formSeparator )
        label:SetText( text )
        label:SetTall( dimensions.buttonHeight )

        StyledTheme.Apply( label )

        return label
    end

    function StyledTheme.CreateFormButton( parent, label, callback )
        local button = vgui.Create( "DButton", parent )
        button:SetText( label )
        button:Dock( TOP )
        button:DockMargin( 0, 0, 0, dimensions.formSeparator )
        button.DoClick = callback

        StyledTheme.Apply( button )

        return button
    end

    function StyledTheme.CreateFormToggle( parent, label, isChecked, callback )
        local button = vgui.Create( "DButton", parent )
        button:SetIcon( isChecked and "icon16/accept.png" or "icon16/cancel.png" )
        button:SetText( label )
        button:Dock( TOP )
        button:DockMargin( 0, 0, 0, dimensions.formSeparator )
        button.isToggle = true
        button.isChecked = isChecked

        StyledTheme.Apply( button )

        button.SetChecked = function( s, value )
            value = value == true
            s.isChecked = value
            button:SetIcon( value and "icon16/accept.png" or "icon16/cancel.png" )
            callback( value )
        end

        button.DoClick = function( s )
            s:SetChecked( not s.isChecked )
        end

        return button
    end

    function StyledTheme.CreateFormSlider( parent, label, default, min, max, decimals, callback )
        local slider = vgui.Create( "DNumSlider", parent )
        slider:SetText( label )
        slider:SetMin( min )
        slider:SetMax( max )
        slider:SetValue( default )
        slider:SetDecimals( decimals )
        slider:Dock( TOP )
        slider:DockMargin( 0, 0, 0, dimensions.formSeparator )

        slider.PerformLayout = function( s )
            s.Label:SetWide( dimensions.formLabelWidth )
        end

        StyledTheme.Apply( slider )

        slider.OnValueChanged = function( _, value )
            callback( decimals == 0 and math.floor( value ) or math.Round( value, decimals ) )
        end

        return slider
    end

    function StyledTheme.CreateFormCombo( parent, text, options, defaultIndex, callback )
        local panel = vgui.Create( "DPanel", parent )
        panel:SetTall( dimensions.buttonHeight )
        panel:SetPaintBackground( false )
        panel:Dock( TOP )
        panel:DockMargin( 0, 0, 0, dimensions.formSeparator )

        local label = vgui.Create( "DLabel", panel )
        label:Dock( LEFT )
        label:DockMargin( 0, 0, 0, 0 )
        label:SetText( text )
        label:SetWide( dimensions.formLabelWidth )

        StyledTheme.Apply( label )

        local combo = vgui.Create( "DComboBox", panel )
        combo:Dock( FILL )
        combo:SetSortItems( false )

        for _, v in ipairs( options ) do
            combo:AddChoice( v )
        end

        if defaultIndex then
            combo:ChooseOptionID( defaultIndex )
        end

        StyledTheme.Apply( combo )

        combo.OnSelect = function( _, index )
            callback( index )
        end
    end

    function StyledTheme.CreateFormBinder( parent, text, defaultKey )
        local panel = vgui.Create( "DPanel", parent )
        panel:SetTall( dimensions.buttonHeight )
        panel:SetPaintBackground( false )
        panel:Dock( TOP )
        panel:DockMargin( 0, 0, 0, dimensions.formSeparator )

        local label = vgui.Create( "DLabel", panel )
        label:Dock( LEFT )
        label:DockMargin( 0, 0, 0, 0 )
        label:SetText( text )
        label:SetWide( dimensions.formLabelWidth )

        StyledTheme.Apply( label )

        local binder = vgui.Create( "DBinder", panel )
        binder:SetValue( defaultKey or KEY_NONE )
        binder:Dock( FILL )

        StyledTheme.Apply( binder )

        return binder
    end
end
