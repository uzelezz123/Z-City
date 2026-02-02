local MODE = MODE
local vgui_color_main = Color(155, 0, 0, 255)
local vgui_color_bg = Color(50, 50, 50, 255)
local vgui_color_ready = Color(0, 150, 50, 255)
local vgui_color_notready = Color(0, 50, 0, 255)

-- surface.CreateFont("RoleSelection_Main", {
	-- font = "Roboto",
	-- extended = false,
	-- size = ScreenScale(10),
	-- weight = 500,
	-- blursize = 0,
	-- scanlines = 0,
	-- antialias = true,
	-- underline = false,
	-- italic = false,
	-- strikeout = false,
	-- symbol = false,
	-- rotary = false,
	-- shadow = false,
	-- additive = false,
	-- outline = false,
-- })
local function set_role(role, mode)
	if mode == "soe" then
		RunConsoleCommand(MODE.ConVarName_SubRole_Traitor_SOE, role)
	else
		RunConsoleCommand(MODE.ConVarName_SubRole_Traitor, role)
	end
end

local function screen_scale_2(num)
	return ScreenScale(num) / (ScrW() / ScrH())
end

--\\SubRole View Panel
local PANEL = {}

function PANEL:Construct()
	self:SetSkin(hg.GetMainSkin())
	
	self.Title = self.Title or "No title"
	local width, height = self:GetSize()
	local dock_bottom = 5
	
	local label_name = vgui.Create("DLabel", self)
	label_name.ZRolePanel = self
	local label_name_height = 50--height / 5
	height = height - label_name_height - dock_bottom
	label_name:SetText("")
	label_name:SetSkin(hg.GetMainSkin())
	label_name:DockMargin(0, 0, 0, dock_bottom)
	label_name:Dock(TOP)
	label_name:SetHeight(label_name_height)
	label_name:SetMouseInputEnabled(true)
	label_name.Paint = function(sel, w, h)
		if((self.Mode == "soe" and MODE.ConVar_SubRole_Traitor_SOE:GetString() == self.Role) or (self.Mode != "soe" and MODE.ConVar_SubRole_Traitor:GetString() == self.Role))then
			surface.SetDrawColor(vgui_color_main)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 3)
		end
		
		surface.SetFont("ZB_InterfaceMedium")

		local tw, th = surface.GetTextSize(self.Title)
		
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
		surface.DrawText(self.Title)
	end
	
	label_name.DoClick = function(sel)
		set_role(self.Role, self.Mode or "soe")
	end
	
	local text_description = vgui.Create("RichText", self)
	text_description.ZRolePanel = self
	text_description:SetText(self.Description)
	text_description:SetSkin(hg.GetMainSkin())
	text_description:Dock(FILL)
	text_description.PerformLayout = function(sel)
		if(sel:GetFont() != "ZB_InterfaceSmall")then
			sel:SetFontInternal("ZB_InterfaceSmall")
		end
		
		sel:SetFGColor(color_white)
	end
	text_description.Paint = function(sel, w, h)
		
	end
end

function PANEL:PaintOver(w, h)

end

local tex_gradient = surface.GetTextureID("vgui/gradient-d")
local mata = Material("vgui/traitor_icons/traitor_icon.png")

local rolesmaterials = {
	["traitor_default_soe"] = Material("vgui/traitor_icons/traitor_icon.png"),
}

local glow = Material("homigrad/vgui/models/circle.png")

function PANEL:PostPaintPanel(w, h)
	/*if((self.Mode == "soe" and MODE.ConVar_SubRole_Traitor_SOE:GetString() == self.Role) or (self.Mode != "soe" and MODE.ConVar_SubRole_Traitor:GetString() == self.Role))then
		local y_start = 0
		
		surface.SetDrawColor(vgui_color_main)
		//surface.SetTexture(tex_gradient)
		surface.SetMaterial(mata)
		surface.DrawTexturedRect(0, -100, w, h + 200)
	end*/
	if rolesmaterials[self.Role] then
		//surface.SetDrawColor(vgui_color_main)
		//surface.SetMaterial(rolesmaterials[self.Role])
		//surface.DrawTexturedRect(0, -100, w, h + 200)

		--[[ --whatever
        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)
        render.SetStencilReferenceValue(0)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.ClearStencil()
        
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilFailOperation(STENCIL_REPLACE)

		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(glow)
		local x, y = self:ScreenToLocal(gui.MouseX() - 0, gui.MouseY() - 0)
		draw.Circle( x, y, 200, 16 )

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_EQUAL)

		surface.SetDrawColor(Color(255, 0, 0, 50))
		surface.SetMaterial(rolesmaterials[self.Role])
		surface.DrawTexturedRect(0, -100, w, h + 200)

		render.SetStencilEnable( false )--]]
	end
end

derma.DefineControl("HMCD_RolePanel", "", PANEL, "DPanel")
--||Sub role carousel
local PANEL = {}

function PANEL:Construct()
	self:SetSkin(hg.GetMainSkin())
	
	self.RolesIDsList = self.RolesIDsList or MODE.RoleChooseRoundTypes["standard"].Traitor
	local width, height = self:GetSize()
	local dock_bottom = 5
	
	local hscroll = vgui.Create("ZHorizontalScroller", self)
	local hscroll_height = height - 50
	height = height - hscroll_height
	hscroll:SetHeight(hscroll_height)
	hscroll:SetSkin(hg.GetMainSkin())
	hscroll:DockMargin(0, 0, 0, dock_bottom)
	hscroll:Dock(TOP)
	hscroll:SetOverlap(-10)
	-- hscroll:SetUseLiveDrag(true)
	-- hscroll:InvalidateParent(false)
	for role_id, _ in pairs(self.RolesIDsList) do
		local role_info = MODE.SubRoles[role_id]
		local role_name = role_info.Name
		local role_description = role_info.Description
		
		local role_panel = vgui.Create("HMCD_RolePanel", hscroll)
		role_panel.Title = role_name
		role_panel.Description = role_description
		role_panel.Role = role_id
		role_panel.Mode = self.Mode or "soe"
		role_panel:SetWidth(ScreenScale(170))
		-- role_panel:SetHeight(hscroll_height)
		-- role_panel:InvalidateParent(false)
		role_panel:Construct()
		
		hscroll:AddPanel(role_panel)
	end
	
	local button_ready = vgui.Create("DButton", self)
	button_ready:Dock(FILL)
	button_ready:SetSkin(hg.GetMainSkin())
	button_ready:SetText("APPLY")
	button_ready.DoClick = function(sel)
		//if(sel.Clicked)then
			if(IsValid(VGUI_HMCD_RolePanelList))then
				VGUI_HMCD_RolePanelList:Remove()
			end
		//end
		
		//sel.Clicked = true
		
		//net.Start("HMCD(StartPlayersRoleSelection)")
		//net.SendToServer()
	end
	button_ready.Paint = function(sel, w, h)
		if(sel.Clicked)then
			surface.SetDrawColor(vgui_color_ready)
		else
			surface.SetDrawColor(vgui_color_notready)
		end
		
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 10)
		surface.DrawRect(0, 0, w, h * 0.45)
		surface.SetDrawColor(color_black)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

function PANEL:Paint()
	
end

derma.DefineControl("HMCD_RolePanelList", "", PANEL, "DPanel")
--//

--\\Manual Click detection
local delta = 0
hook.Add("CreateMove", "HMCD_RolePanelClick", function(cmd)
	local dlta = (input.WasMousePressed(MOUSE_WHEEL_DOWN) and -1) or (input.WasMousePressed(MOUSE_WHEEL_UP) and 1) or 0

	delta = LerpFT(0.05, delta, dlta)
	local delta = delta * 2

	if(math.abs(delta) > 0.01)then
		local hovered_panel = vgui.GetHoveredPanel()

		local parent_panel = IsValid(hovered_panel) and hovered_panel:GetParent()
		local parent_panel2 = IsValid(parent_panel) and parent_panel:GetParent()
		local parent_panel3 = IsValid(parent_panel2) and parent_panel2:GetParent()
		local parent_panel4 = IsValid(parent_panel3) and parent_panel3:GetParent()
		local parent_panel5 = IsValid(parent_panel4) and parent_panel4:GetParent()

		if IsValid(hovered_panel) and hovered_panel.OnMouseWheeled then
			hovered_panel:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel) and parent_panel.OnMouseWheeled then
			parent_panel:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel2) and parent_panel2.OnMouseWheeled then
			parent_panel2:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel3) and parent_panel3.OnMouseWheeled then
			parent_panel3:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel4) and parent_panel4.OnMouseWheeled then
			parent_panel4:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel5) and parent_panel5.OnMouseWheeled then
			parent_panel5:OnMouseWheeled(delta)
		end
	end

	if(input.WasMousePressed(MOUSE_LEFT))then
			-- print("Left mouse button was pressed")
		local hovered_panel = vgui.GetHoveredPanel()
		
		if(IsValid(hovered_panel) and IsValid(hovered_panel.ZRolePanel))then
			set_role(hovered_panel.ZRolePanel.Role, hovered_panel.ZRolePanel.Mode)
		end
	end
end)
--//

--\\https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dhorizontalscroller.lua
local PANEL = {}

AccessorFunc( PANEL, "m_iOverlap",			"Overlap" )
AccessorFunc( PANEL, "m_bShowDropTargets",	"ShowDropTargets", FORCE_BOOL )

function PANEL:Init()

	self.Panels = {}
	self.OffsetX = 0
	self.FrameTime = 0

	self.pnlCanvas = vgui.Create( "DDragBase", self )
	self.pnlCanvas:SetDropPos( "6" )
	self.pnlCanvas:SetUseLiveDrag( false )
	self.pnlCanvas.OnModified = function() self:OnDragModified() end

	self.pnlCanvas.UpdateDropTarget = function( Canvas, drop, pnl )
		if ( !self:GetShowDropTargets() ) then return end
		DDragBase.UpdateDropTarget( Canvas, drop, pnl )
	end

	self.pnlCanvas.OnChildAdded = function( Canvas, child )

		local dn = Canvas:GetDnD()
		if ( dn ) then

			child:Droppable( dn )
			child.OnDrop = function()

				local x, y = Canvas:LocalCursorPos()
				local closest, id = self.pnlCanvas:GetClosestChild( x, Canvas:GetTall() / 2 ), 0

				for k, v in pairs( self.Panels ) do
					if ( v == closest ) then id = k break end
				end

				table.RemoveByValue( self.Panels, child )
				table.insert( self.Panels, id, child )

				self:InvalidateLayout()

				return child

			end
		end

	end

	self:SetOverlap( 0 )

	self.btnLeft = vgui.Create( "DButton", self )
	self.btnLeft:SetText( "" )
	self.btnLeft.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonLeft", panel, w, h ) end

	self.btnRight = vgui.Create( "DButton", self )
	self.btnRight:SetText( "" )
	self.btnRight.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonRight", panel, w, h ) end

end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:ScrollToChild( panel )

	-- make sure our size is all good
	self:InvalidateLayout( true )

	local x, y = self.pnlCanvas:GetChildPosition( panel )
	local w, h = panel:GetSize()

	x = x + w * 0.5
	x = x - self:GetWide() * 0.5

	self:SetScroll( x )

end

function PANEL:SetScroll( x )

	self.OffsetX = x
	self:InvalidateLayout( true )

end

function PANEL:SetUseLiveDrag( bool )
	self.pnlCanvas:SetUseLiveDrag( bool )
end

function PANEL:MakeDroppable( name, allowCopy )
	self.pnlCanvas:MakeDroppable( name, allowCopy )
end

function PANEL:AddPanel( pnl )

	table.insert( self.Panels, pnl )

	pnl:SetParent( self.pnlCanvas )
	self:InvalidateLayout( true )

end

function PANEL:Clear()
	self.pnlCanvas:Clear()
	self.Panels = {}
end

function PANEL:OnMouseWheeled( dlta )

	self.OffsetX = self.OffsetX + dlta * -30
	self:InvalidateLayout( true )

	return true

end

function PANEL:Think()

	-- Hmm.. This needs to really just be done in one place
	-- and made available to everyone.
	local FrameRate = VGUIFrameTime() - self.FrameTime
	self.FrameTime = VGUIFrameTime()

	if ( self.btnRight:IsDown() ) then
		self.OffsetX = self.OffsetX + ( 500 * FrameRate )
		self:InvalidateLayout( true )
	end

	if ( self.btnLeft:IsDown() ) then
		self.OffsetX = self.OffsetX - ( 500 * FrameRate )
		self:InvalidateLayout( true )
	end

	if ( dragndrop.IsDragging() ) then

		local x, y = self:LocalCursorPos()

		if ( x < 30 ) then
			self.OffsetX = self.OffsetX - ( 350 * FrameRate )
		elseif ( x > self:GetWide() - 30 ) then
			self.OffsetX = self.OffsetX + ( 350 * FrameRate )
		end

		self:InvalidateLayout( true )

	end

end

function PANEL:PerformLayout()

	local w, h = self:GetSize()

	self.pnlCanvas:SetTall( h )

	local x = 0

	for k, v in pairs( self.Panels ) do
		if ( !IsValid( v ) ) then continue end
		if ( !v:IsVisible() ) then continue end

		v:SetPos( x, 0 )
		v:SetTall( h )
		if ( v.ApplySchemeSettings ) then v:ApplySchemeSettings() end

		x = x + v:GetWide() - self.m_iOverlap

	end

	self.pnlCanvas:SetWide( x + self.m_iOverlap )

	if ( w < self.pnlCanvas:GetWide() ) then
		self.OffsetX = math.Clamp( self.OffsetX, 0, self.pnlCanvas:GetWide() - self:GetWide() )
	else
		self.OffsetX = 0
	end

	self.pnlCanvas.x = self.OffsetX * -1

	self.btnLeft:SetSize( 15, 15 )
	self.btnLeft:AlignLeft( 4 )
	self.btnLeft:AlignBottom( 5 )

	self.btnRight:SetSize( 15, 15 )
	self.btnRight:AlignRight( 4 )
	self.btnRight:AlignBottom( 5 )

	self.btnLeft:SetVisible( self.pnlCanvas.x < 0 )
	self.btnRight:SetVisible( self.pnlCanvas.x + self.pnlCanvas:GetWide() > self:GetWide() )

end

function PANEL:OnDragModified()
	-- Override me
end

derma.DefineControl( "ZHorizontalScroller", "", PANEL, "Panel" )
--//