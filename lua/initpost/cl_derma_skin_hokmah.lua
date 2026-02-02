--\\
	HOKMAH_VGUI = HOKMAH_VGUI or {}
	HOKMAH_VGUI.MainColor = Color(130, 130 ,130)
	HOKMAH_VGUI.SecondaryColor = Color(155,0,0,240)
	HOKMAH_VGUI.BackgroundColor = Color(165,165,165)
--//

--; Adapted from Helix

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end
--//

local gradient = surface.GetTextureID("vgui/gradient-d")
local gradientUp = surface.GetTextureID("vgui/gradient-u")
local gradientLeft = surface.GetTextureID("vgui/gradient-l")
-- local gradientRadial = Material("helix/gui/radial-gradient.png")
local defaultBackgroundColor = Color(30, 30, 30, 200)

local SKIN = {}
derma.DefineSkin("Hokmah", "Hokmah skin.", SKIN)

SKIN.fontCategory = "ZCity_Fixed_Medium_Light"
SKIN.fontCategoryBlur = "ZCity_Fixed_Medium_Light_Blur"
SKIN.fontSegmentedProgress = "ZCity_Fixed_Medium_Light"

SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)

SKIN.Colours.Info = Color(100, 185, 255)
SKIN.Colours.Success = Color(64, 185, 85)
SKIN.Colours.Error = Color(255, 100, 100)
SKIN.Colours.Warning = Color(230, 180, 0)
SKIN.Colours.MenuLabel = color_white
SKIN.Colours.DarkerBackground = Color(0, 0, 0, 77)

SKIN.Colours.Outline = Color(155, 0, 0, 255)
SKIN.Colours.Background = Color(0, 0, 0, 205)

SKIN.Colours.SegmentedProgress = {}
SKIN.Colours.SegmentedProgress.Bar = Color(64, 185, 85)
SKIN.Colours.SegmentedProgress.Text = color_white

SKIN.Colours.Area = {}

SKIN.Colours.Window.TitleActive = Color(0, 0, 0)
SKIN.Colours.Window.TitleInactive = color_white

SKIN.Colours.Button.Normal = color_white
SKIN.Colours.Button.Hover = color_white
SKIN.Colours.Button.Down = Color(180, 180, 180)
SKIN.Colours.Button.Disabled = Color(0, 0, 0, 100)

SKIN.Colours.Label.Default = color_white

function SKIN.tex.Menu_Strip(x, y, width, height, color)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(x, y, width, height)

	surface.SetDrawColor(ColorAlpha(color or HOKMAH_VGUI.MainColor, 175))
	surface.SetTexture(gradient)
	surface.DrawTexturedRect(x, y, width, height)

	surface.SetTextColor(color_white)
end

function SKIN:PaintFrame(panel)
	if (panel.bBackgroundBlur) then
		hg.DrawBlur(panel, 10)
	end

	surface.SetDrawColor(HOKMAH_VGUI.BackgroundColor)
	surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())

	surface.SetDrawColor(30, 30, 30, 150)
	surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())

	if (panel:GetTitle() != "" or panel.btnClose:IsVisible()) then
		surface.SetDrawColor(HOKMAH_VGUI.MainColor)
		surface.DrawRect(0, 0, panel:GetWide(), 24)

		if (panel.bHighlighted) then
			self:DrawImportantBackground(0, 0, panel:GetWide(), 24, ColorAlpha(color_white, 22))
		end
	end

	surface.SetDrawColor(HOKMAH_VGUI.MainColor)
	surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
end

function SKIN:PaintBaseFrame(panel, width, height)
	if (panel.bBackgroundBlur) then
		hg.DrawBlur(panel, 10)
	end
	surface.SetDrawColor(HOKMAH_VGUI.BackgroundColor)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(30, 30, 30, 150)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(HOKMAH_VGUI.MainColor)
	surface.DrawOutlinedRect(0, 0, width, height)
end

function SKIN:DrawImportantBackground(x, y, width, height, color)
	color = color or defaultBackgroundColor

	surface.SetTexture(gradientLeft)
	surface.SetDrawColor(color)
	surface.DrawTexturedRect(x, y, width, height)
end

function SKIN:PaintPanel(panel)
	if(panel.m_bBackground)then
		if(!panel.Blur)then
			hg.DrawBlur(panel, 2, 0.2, 200)
		end
		
		local width, height = panel:GetSize()
		
		if (panel.m_bgColor) then
			surface.SetDrawColor(panel.m_bgColor)
		else
			surface.SetDrawColor(self.Colours.Background)
		end
		
		surface.DrawRect(0, 0, width, height)
		
		if(panel.PostPaintPanel)then
			panel:PostPaintPanel(width, height)
		end
		
		surface.SetDrawColor(self.Colours.Outline)
		surface.DrawOutlinedRect(0, 0, width, height, 1)
	end
end

function SKIN:PaintMenuBackground(panel, width, height, alphaFraction)
	alphaFraction = alphaFraction or 1

	surface.SetDrawColor(ColorAlpha(color_black, alphaFraction * 255))
	surface.SetTexture(gradient)
	surface.DrawTexturedRect(0, 0, width, height)

	hg.DrawBlur(panel, alphaFraction * 15, nil, 200)
end

function SKIN:PaintPlaceholderPanel(panel, width, height, barWidth, padding)
	local size = math.max(width, height)
	barWidth = barWidth or size * 0.05

	local segments = size / barWidth

	for i = 1, segments do
		surface.SetTexture(-1)
		surface.SetDrawColor(0, 0, 0, 88)
		surface.DrawTexturedRectRotated(i * barWidth, i * barWidth, barWidth, size * 2, -45)
	end
end

function SKIN:PaintCategoryPanel(panel, text, color)
	text = text or ""
	color = color or HOKMAH_VGUI.MainColor

	surface.SetFont(self.fontCategoryBlur)

	local textHeight = select(2, surface.GetTextSize(text)) + 6
	local width, height = panel:GetSize()

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(0, textHeight, width, height - textHeight)

	self:DrawImportantBackground(0, 0, width, textHeight, color)

	surface.SetTextColor(color_black)
	surface.SetTextPos(4, 4)
	surface.DrawText(text)

	surface.SetFont(self.fontCategory)
	surface.SetTextColor(color_white)
	surface.SetTextPos(4, 4)
	surface.DrawText(text)

	surface.SetDrawColor(color)
	surface.DrawOutlinedRect(0, 0, width, height)

	return 1, textHeight, 1, 1
end

function SKIN:PaintButton(panel)
	if (panel.m_bBackground) then
		local w, h = panel:GetWide(), panel:GetTall()
		local alpha = 50

		if (panel:GetDisabled()) then
			alpha = 10
		elseif (panel.Depressed) then
			alpha = 180
		elseif (panel.Hovered) then
			alpha = 75
		end

		if (panel:GetParent() and panel:GetParent():GetName() == "DListView_Column") then
			surface.SetDrawColor(color_white)
			surface.DrawRect(0, 0, w, h)
		end

		surface.SetDrawColor(30, 30, 30, alpha)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(180, 180, 180, 2)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		
		if(panel.IsOn)then
			local text = nil
			local draw_on = false
			
			if(!panel.IsOn(panel))then
				surface.SetDrawColor(165, 165, 165, 255)
				
				text = panel.TextOn or "Switch On"
			else
				surface.SetDrawColor(130, 130, 130, 255)
				
				text = panel.TextOff or "Switch Off"
				draw_on = true
			end
			
			surface.DrawRect(0, 0, w, h)
			
			local sides_width = h * 0.25
			
			local poly_top = {
				{x = 0, y = 0},
				{x = w, y = 0},
				{x = w - sides_width, y = sides_width},
				{x = sides_width, y = sides_width},
			}
			
			local poly_right = {
				{x = w, y = 0},
				{x = w, y = h},
				{x = w - sides_width, y = h - sides_width},
				{x = w - sides_width, y = sides_width},
			}
			
			local poly_bottom = {
				{x = w, y = h},
				{x = 0, y = h},
				{x = sides_width, y = h - sides_width},
				{x = w - sides_width, y = h - sides_width},
			}
			
			local poly_left = {
				{x = 0, y = h},
				{x = 0, y = 0},
				{x = sides_width, y = sides_width},
				{x = sides_width, y = h - sides_width},
			}
			
			draw.NoTexture()
			
			if(!panel.IsOn(panel))then
				surface.SetDrawColor(255,255,255,20)
			else
				surface.SetDrawColor(20,20,20,20)
			end
			
			surface.DrawPoly(poly_top)
			
			if(!panel.IsOn(panel))then
				surface.SetDrawColor(255,255,255,20)
			else
				surface.SetDrawColor(20,20,20,20)
			end
			
			surface.DrawPoly(poly_right)
			
			surface.SetDrawColor(20,20,20,20)
			surface.DrawPoly(poly_bottom)
			
			surface.SetDrawColor(20,20,20,20)
			surface.DrawPoly(poly_left)
			-- surface.SetDrawColor(color_black)
			-- surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 153, 0, 255)
				surface.DrawRect(0, 0, width, h)
				surface.SetDrawColor(255,255,255,20)
				surface.DrawRect(0, 0, width, h * 0.25)
			end
			
			local width = 5
			
			-- surface.SetDrawColor(50, 150, 0, 255)
			-- surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
	end
end

local color_red = Color(50, 50, 50)

function SKIN:PaintTextEntry( panel, w, h )
	if ( panel.m_bBackground ) then
		if ( panel:GetDisabled() ) then
			surface.SetDrawColor(30, 30, 30, 100)
		elseif ( panel:HasFocus() ) then
			surface.SetDrawColor(150, 150, 150, 100)
		else
			surface.SetDrawColor(130, 130, 130, 100)
		end
		
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	if(panel.CharactersMin)then
		panel.TextEntryConditionsMet = panel.TextEntryConditionsMet or function(self, amt)
			amt = amt or utf8.len(self:GetValue())
			local met = true

			if(self.CharactersMin and self.CharactersMin > amt)then
				met = false
			end
			
			if(self.CharactersMax and self.CharactersMax < amt)then
				met = false
			end
			
			return met
		end
	
		local add_text = ""
		
		if(panel.CharactersMax)then
			add_text = " → " .. panel.CharactersMax
		end
		
		local amt = utf8.len(panel:GetValue())
		local color = color_white
		
		if(!panel:TextEntryConditionsMet(amt))then
			color = color_red
		end
		
		draw.DrawText(amt .. "/" .. panel.CharactersMin .. add_text, "ZCity_Tiny", w * 1.0, h * 0, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	if ( panel.GetPlaceholderText && panel.GetPlaceholderColor && panel:GetPlaceholderText() && panel:GetPlaceholderText():Trim() != "" && panel:GetPlaceholderColor() && ( !panel:GetText() || panel:GetText() == "" ) ) then
		local oldText = panel:GetText()

		local str = panel:GetPlaceholderText()
		if ( str:StartsWith( "#" ) ) then str = str:sub( 2 ) end
		str = language.GetPhrase( str )

		panel:SetText( str )
		panel:DrawTextEntryText( panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
		panel:SetText( oldText )

		return
	end

	panel:DrawTextEntryText( panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
end

function SKIN:PaintEntityInfoBackground(panel, width, height)
	-- hg.DrawBlur(panel, 1)
	surface.SetDrawColor(HOKMAH_VGUI.BackgroundColor)
	surface.DrawRect(0, 0, width, height)

	-- surface.SetDrawColor(self.Colours.DarkerBackground)
	-- surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintTooltipBackground(panel, width, height)
	-- hg.DrawBlur(panel, 1)
	surface.SetDrawColor(HOKMAH_VGUI.BackgroundColor)
	surface.DrawRect(0, 0, width, height)

	-- surface.SetDrawColor(self.Colours.DarkerBackground)
	-- surface.DrawRect(0, 0, width, height)
end

-- function SKIN:PaintTooltipMinimalBackground(panel, width, height)
	-- surface.SetDrawColor(0, 0, 0, 150 * panel.fraction)
	-- surface.SetMaterial(gradientRadial)
	-- surface.DrawTexturedRect(0, 0, width, height)
-- end

function SKIN:PaintSegmentedProgressBackground(panel, width, height)
end

function SKIN:PaintSegmentedProgress(panel, width, height)
	local font = panel:GetFont() or self.fontSegmentedProgress
	local textColor = panel:GetTextColor() or self.Colours.SegmentedProgress.Text
	local barColor = panel:GetBarColor() or self.Colours.SegmentedProgress.Bar
	local segments = panel:GetSegments()
	local segmentHalfWidth = width / #segments * 0.5

	surface.SetDrawColor(barColor)
	surface.DrawRect(0, 0, panel:GetFraction() * width, height)

	for i = 1, #segments do
		local text = segments[i]
		local x = (i - 1) / #segments * width + segmentHalfWidth
		local y = height * 0.5

		draw.SimpleText(text, font, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SKIN:PaintCharacterCreateBackground(panel, width, height)
	surface.SetDrawColor(40, 40, 40, 255)
	surface.SetTexture(gradient)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintCharacterLoadBackground(panel, width, height)
	surface.SetDrawColor(40, 40, 40, panel:GetBackgroundFraction() * 255)
	surface.SetTexture(gradient)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintCharacterTransitionOverlay(panel, x, y, width, height, color)
	color = color or HOKMAH_VGUI.MainColor

	surface.SetDrawColor(color)
	surface.DrawRect(x, y, width, height)
end

function SKIN:PaintAreaEntry(panel, width, height)
	local color = ColorAlpha(panel:GetBackgroundColor() or self.Colours.Area.Background, panel:GetBackgroundAlpha())

	self:DrawImportantBackground(0, 0, width, height, color)
end

function SKIN:PaintListRow(panel, width, height)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintSettingsRowBackground(panel, width, height)
	local index = panel:GetBackgroundIndex()
	local bReset = panel:GetShowReset()

	if (index == 0) then
		surface.SetDrawColor(30, 30, 30, 45)
		surface.DrawRect(0, 0, width, height)
	end

	if (bReset) then
		surface.SetDrawColor(self.Colours.Warning)
		surface.DrawRect(0, 0, 2, height)
	end
end

function SKIN:PaintVScrollBar(panel, width, height)
end

function SKIN:PaintScrollBarGrip(panel, width, height)
	local parent = panel:GetParent()
	local upButtonHeight = parent.btnUp:GetTall()
	local downButtonHeight = parent.btnDown:GetTall()

	DisableClipping(true)
		if is3d2d then 
			surface.SetDrawColor(255, 255, 255, 200)
		else
			surface.SetDrawColor(30, 30, 30, 200)
		end
		surface.DrawRect(4, -upButtonHeight, width - 8, height + upButtonHeight + downButtonHeight)
	DisableClipping(false)
end

function SKIN:PaintButtonUp(panel, width, height)
end

function SKIN:PaintButtonDown(panel, width, height)
end

function SKIN:PaintComboBox(panel, width, height)
	if(panel.DrawAsPanel)then
		self:PaintPanel(panel)
	end
end

function SKIN:PaintComboDownArrow(panel, width, height)
	surface.SetFont("ZCity_Fixed_Icons_Small")

	local textWidth, textHeight = surface.GetTextSize("r")
	local alpha = (panel.ComboBox:IsMenuOpen() or panel.ComboBox.Hovered) and 200 or 100

	surface.SetTextColor(ColorAlpha(HOKMAH_VGUI.MainColor, alpha))
	surface.SetTextPos(width * 0.5 - textWidth * 0.5, height * 0.5 - textHeight * 0.5)
	surface.DrawText("r")
end

function SKIN:PaintPropertySheet( panel, width, height )

	-- TODO: Tabs at bottom, left, right

	local ActiveTab = panel:GetActiveTab()
	local Offset = 0
	if ( ActiveTab ) then Offset = ActiveTab:GetTall() - 8 end

	--self.tex.Tab_Control( 0, Offset, w, h-Offset )

	hg.DrawBlur(panel)

	surface.SetDrawColor(30, 30, 30, 150)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(255, 0, 0, 150)
	surface.DrawOutlinedRect(0, 0, width, height)
end

function SKIN:PaintTab( panel, w, h )

	if ( panel:IsActive() ) then
		return self:PaintActiveTab( panel, w, h )
	end

	--self.tex.TabT_Inactive( 0, 0, w, h )
end

function SKIN:PaintActiveTab( panel, w, h )

	surface.SetDrawColor(30, 30, 30, 150)
	surface.DrawRect(0, 0, w, h*0.8)
	surface.SetDrawColor(255, 0, 0, 150)
	surface.DrawOutlinedRect(0, 0, w, h*0.8,1)

end

function SKIN:PaintMenu(panel, width, height)
	hg.DrawBlur(panel)

	surface.SetDrawColor(30, 30, 30, 150)
	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintMenuOption(panel, width, height)
	if (panel.m_bBackground and (panel.Hovered or panel.Highlight)) then
		self:DrawImportantBackground(0, 0, width, height, HOKMAH_VGUI.MainColor)
	end
end

function SKIN:PaintChatboxTabButton(panel, width, height)
	if (panel:GetActive()) then
		surface.SetDrawColor(HOKMAH_VGUI.MainColor or Color(75, 119, 190, 255))
		surface.DrawRect(0, 0, width, height)
	else
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, width, height)

		if (panel:GetUnread()) then
			surface.SetDrawColor(ColorAlpha(self.Colours.Warning, Lerp(panel.unreadAlpha, 0, 100)))
			surface.SetTexture(gradient)
			surface.DrawTexturedRect(0, 0, width, height - 1)
		end
	end

	-- border
	surface.SetDrawColor(color_black)
	surface.DrawRect(width - 1, 0, 1, height) -- right
end

function SKIN:PaintChatboxTabs(panel, width, height, alpha)
	surface.SetDrawColor(0, 0, 0, 33)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(0, 0, 0, 100)
	surface.SetTexture(gradient)
	surface.DrawTexturedRect(0, height * 0.5, width, height * 0.5)

	local tab = panel:GetActiveTab()

	if (tab) then
		local button = tab:GetButton()
		local x, _ = button:GetPos()

		-- outline
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, height - 1, x, 1) -- left
		surface.DrawRect(x + button:GetWide(), height - 1, width - x - button:GetWide(), 1) -- right
	end
end

function SKIN:PaintChatboxBackground(panel, width, height)
	hg.DrawBlur(panel, 10)

	if (panel:GetActive()) then
		surface.SetDrawColor(ColorAlpha(HOKMAH_VGUI.MainColor, 120))
		surface.SetTexture(gradientUp)
		surface.DrawTexturedRect(0, panel.tabs.buttons:GetTall(), width, height * 0.25)
	end

	surface.SetDrawColor(color_black)
	surface.DrawOutlinedRect(0, 0, width, height)
end

function SKIN:PaintChatboxEntry(panel, width, height)
	surface.SetDrawColor(0, 0, 0, 66)
	surface.DrawRect(0, 0, width, height)

	panel:DrawTextEntryText(color_white, HOKMAH_VGUI.MainColor, color_white)

	surface.SetDrawColor(color_black)
	surface.DrawOutlinedRect(0, 0, width, height)
end

function SKIN:DrawChatboxPreviewBox(x, y, text, color)
	color = color or HOKMAH_VGUI.MainColor

	local textWidth, textHeight = surface.GetTextSize(text)
	local width, height = textWidth + 8, textHeight + 8

	-- background
	surface.SetDrawColor(color)
	surface.DrawRect(x, y, width, height)

	-- text
	surface.SetTextColor(color_white)
	surface.SetTextPos(x + width * 0.5 - textWidth * 0.5, y + height * 0.5 - textHeight * 0.5)
	surface.DrawText(text)

	-- outline
	surface.SetDrawColor(color.r * 0.5, color.g * 0.5, color.b * 0.5, 255)
	surface.DrawOutlinedRect(x, y, width, height)

	return width
end

function SKIN:DrawChatboxPrefixBox(panel, width, height)
	local color = panel:GetBackgroundColor()

	-- background
	surface.SetDrawColor(color)
	surface.DrawRect(0, 0, width, height)

	-- outline
	surface.SetDrawColor(color.r * 0.5, color.g * 0.5, color.b * 0.5, 255)
	surface.DrawOutlinedRect(0, 0, width, height)
end


function SKIN:PaintChatboxAutocompleteEntry(panel, width, height)
	-- selected background
	if (panel.highlightAlpha > 0) then
		self:DrawImportantBackground(0, 0, width, height, ColorAlpha(HOKMAH_VGUI.MainColor, panel.highlightAlpha * 66))
	end

	-- lower border
	surface.SetDrawColor(200, 200, 200, 33)
	surface.DrawRect(0, height - 1, width, 1)
end

function SKIN:PaintWindowMinimizeButton(panel, width, height)
end

function SKIN:PaintWindowMaximizeButton(panel, width, height)
end

function SKIN:PaintInfoBar(panel, width, height, color)
	-- bar
	surface.SetDrawColor(color.r, color.g, color.b, 250)
	surface.DrawRect(0, 0, width, height)

	-- gradient overlay
	surface.SetDrawColor(230, 230, 230, 8)
	surface.SetTexture(gradientUp)
	surface.DrawTexturedRect(0, 0, width, height)
end

function SKIN:PaintInfoBarBackground(panel, width, height)
	surface.SetDrawColor(230, 230, 230, 15)
	surface.DrawRect(0, 0, width, height)
	surface.DrawOutlinedRect(0, 0, width, height)

	panel.bar:PaintManual()

	DisableClipping(true)
		panel.label:PaintManual()
	DisableClipping(false)
end

function SKIN:PaintInventorySlot(panel, width, height)
	surface.SetDrawColor(35, 35, 35, 85)
	surface.DrawRect(1, 1, width - 2, height - 2)

	surface.SetDrawColor(0, 0, 0, 250)
	surface.DrawOutlinedRect(1, 1, width - 2, height - 2)
end

function SKIN:PaintDeathScreenBackground(panel, width, height, progress)
	surface.SetDrawColor(0, 0, 0, (progress / 0.3) * 255)
	surface.DrawRect(0, 0, width, height)
end

derma.RefreshSkins()