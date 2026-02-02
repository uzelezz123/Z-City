wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}
wOS.DynaBase.WorkshopCache = wOS.DynaBase.WorkshopCache or {}

local w, h = ScrW(),  ScrH()

local male_mat = "icon16/male.png"
local female_mat = "icon16/female.png"
local zombie_mat = "icon16/bug.png"
local shared_mat = "icon16/group.png"

local reanim_mat = "icon16/application_edit.png"
local extend_mat = "icon16/application_add.png"

surface.CreateFont( "wOS.DynaBase.TitleFont", {
	font = "Roboto Cn", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24*(h/1200),
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "wOS.DynaBase.QuestionFont", {
	font = "Roboto Cn", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 108*(h/1200),
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "wOS.DynaBase.DescFont",{
	font = "Roboto Cn", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 18*(h/1200),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "wOS.DynaBase.URLFont",{
	font = "Roboto Cn", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 12*(h/1200),
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = true,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local function GetContainingAddon( mdl )
	mdl = mdl or "models/m_anm.mdl"
	for _, addon in pairs( engine.GetAddons() ) do
		local modelFound = file.Find(mdl, addon.title)
		if #modelFound != 0 then return addon end 
	end
end

local function GetWorkshopInfo( addon, callback )
	if not addon or not callback then return end
	if wOS.DynaBase.WorkshopCache[ addon.wsid ] then 
		callback( wOS.DynaBase.WorkshopCache[ addon.wsid ].Data, wOS.DynaBase.WorkshopCache[ addon.wsid ].Icon )
		return
	end

	steamworks.FileInfo( addon.wsid, function( result )
		if not result then return end
		wOS.DynaBase.WorkshopCache[ addon.wsid ] = {}
		wOS.DynaBase.WorkshopCache[ addon.wsid ].Data = result
		if not result.previewid then return end
		steamworks.Download( result.previewid, true, function( cache )
			if not cache then callback( result, nil ) return end
			local mat = AddonMaterial(cache)

			// Jazztronauts taught me not to trust this little material
			local baseTex = ( mat and mat:GetTexture("$basetexture") ) or nil
			if baseTex == nil then
				mat = AddonMaterial(cache)
			end			
			wOS.DynaBase.WorkshopCache[ addon.wsid ].Icon =  mat
			callback( result, mat )
		end ) 
	end )
end

function wOS.DynaBase:OpenConfigMenu()

	if self.OverFrame then 
		self.OverFrame:Remove()
		self.OverFrame = nil
		gui.EnableScreenClicker( false )
		return 
	end

	self.OverFrame = vgui.Create( "DFrame" )
	self.OverFrame:SetSize( w, h )
	self.OverFrame:Center()
	self.OverFrame.Paint = function() end
	self.OverFrame:SetTitle( "" )
	self.OverFrame:ShowCloseButton( false )
	self.OverFrame:SetDraggable( false )
	
	gui.EnableScreenClicker( true )
	self.AnimMenu = vgui.Create( "DFrame", self.OverFrame )
	self.AnimMenu:SetSize( w*0.4, h*0.5 )
	self.AnimMenu:Center()
	self.AnimMenu:MakePopup()
	self.AnimMenu:SetTitle( "wiltOS Dynamic Animation Manager" )
	self.AnimMenu:ShowCloseButton( true )
	self.AnimMenu:SetDraggable( true )
	self.AnimMenu.OnClose = function( pan )
		self:OpenConfigMenu()
	end

	local aw, ah  = self.AnimMenu:GetSize()

	local sheet = vgui.Create( "DPropertySheet", self.AnimMenu )
	sheet:SetSize(aw*0.9, ah*0.8)
	sheet:SetPos(aw*0.05, ah*0.05)

	////////////////////////////////////////////////////////////////// Server Menu
	local scroll = vgui.Create("DScrollPanel", sheet )
	scroll:SetSize(aw*0.9, ah*0.8)
	local sw, sh = scroll:GetSize()
	sheet:AddSheet( "Server Animations", scroll, "icon16/server.png" )

	//placehold
	local layout2 
	local layout = vgui.Create("DListLayout", scroll)
	layout:SetSize(sw, sh)
	layout:SetPaintBackground(true)
	layout:SetBackgroundColor(Color(100, 100, 100))

	local temp_loaded = {}
	local temp_count = 0
	local drop_check = WOS_DYNABASE_ENFORCECONTENT_CVAR:GetInt() >= 2 and WOS_DYNABASE_LOADORDERENFORCE_CVAR:GetBool() 
	if !drop_check then
		layout:MakeDroppable( "WOS_DYNABASE_DROPPABLE" )
		layout.OnModified = function( pan, opnl )
			local opos = pan.DroppedPan.OrderPos
			local npos = opos
			local children = pan:GetChildren()
			for id, child in ipairs( children ) do
				if child != pan.DroppedPan then continue end
				npos = id
				break
			end

			if WOS_DYNABASE_LOADORDERENFORCE_CVAR:GetBool() and ( npos <= temp_count or opos <= temp_count ) then
				if IsValid( pan.DroppedPan.PreviousPanel ) and pan.DroppedPan.PreviousPanel != pan.DroppedPan then
					pan.DroppedPan:MoveToAfter( pan.DroppedPan.PreviousPanel )
				else
					pan.DroppedPan:MoveToBefore( pan.DroppedPan.ForwardPanel )
				end
				return
			end

			for id, child in ipairs( children ) do
				child.OrderPos = id
				child.PreviousPanel = children[id - 1]
				child.ForwardPanel = children[id + 1]
			end
		end
	end

	local lw, lh = layout:GetSize()
	local fw, fh = lw, lh*0.2
	local iw, ih = fh*0.9, fh*0.9

	local add_pad = lw*0.05

	local order_checker = {}
	local disabled_list = {}
	if WOS_DYNABASE_LOADORDERENFORCE_CVAR:GetBool() and self.EnforceCount >= 1 and self.EnforcedOrder then
		for cnt, name in ipairs( self.EnforcedOrder ) do
			local data = self:GetSource( name )
			if not data then continue end
			temp_loaded[ name ] = true
			temp_count = temp_count + 1
			table.insert( order_checker, data )
		end
	end

	if WOS_DYNABASE_ENFORCECONTENT_CVAR:GetInt() < 2 then

		if self.PlayerOrder and self.PlayerCount > 1 then
			for _, dt in ipairs( self.PlayerOrder ) do
				local name = dt.Name
				local data = self:GetSource( name )
				if not data then continue end
				disabled_list[ name ] = dt.Toggled
				if temp_loaded[ name ] then continue end
				temp_loaded[ name ] = true
				table.insert( order_checker, data )
			end
		end

		for name, data in pairs( self:GetAllSources() ) do
			if temp_loaded[ name ] then continue end
			table.insert( order_checker, data )
		end

	end

	for order, data in ipairs( order_checker ) do
		if WOS_DYNABASE_ENFORCECONTENT_CVAR:GetInt() >= 1 and not data.ServerValid then continue end
		local name  = data.Name
		local frame = vgui.Create( "DPanel", layout )
		local prev_child = layout:GetChild( order - 2 )
		if prev_child then
			frame.PreviousPanel = prev_child
			prev_child.ForwardPanel = frame
		end
		frame:SetSize( fw, fh )
		frame.Icon = data.IconOverwrite
		frame.RegisterName = name
		frame.PreventSort = order <= temp_count
		frame.OrderPos = order
		frame.Toggled = true
		if disabled_list[ name ] != nil then
			frame.Toggled = disabled_list[ name ]
		end

		frame.OnDrop = function( pan )
			layout.DroppedPan = pan
			return pan
		end
		frame.Paint = function( pan, ww, hh )
			draw.RoundedBox( 0, 0, 0, ww, hh, Color( 0, 0, 0, 155 ) )
			draw.RoundedBox( 0, ww*0.005, 0, add_pad, hh, Color( 0, 0, 0, 200 ) )

			surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
			surface.DrawOutlinedRect( 0, 0, ww, hh )
			

			if !drop_check and not pan.PreventSort then
				surface.SetDrawColor( color_white )
				for i=0, 1 do
					surface.DrawRect( ww*0.005 + add_pad*0.2 + i*(add_pad*0.4), hh*0.32, add_pad*0.2, add_pad*0.2 )
				end

				for i=0, 1 do
					surface.DrawRect( ww*0.005 + add_pad*0.2 + i*(add_pad*0.4), hh*0.5, add_pad*0.2, add_pad*0.2 )
				end

				for i=0, 1 do
					surface.DrawRect( ww*0.005 + add_pad*0.2 + i*(add_pad*0.4), hh*0.68, add_pad*0.2, add_pad*0.2 )
				end
			end


			local tx, th = draw.SimpleText( pan.RegisterName, "wOS.DynaBase.TitleFont", hh*0.1 + add_pad + iw + ww*0.01, hh*0.06, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP  )
			tx, th = draw.SimpleText( pan.AddonTitle or "Local File", "wOS.DynaBase.DescFont", hh*0.1 + add_pad + iw + ww*0.01, hh*0.06 + th + hh*0.03, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP  )
				

			surface.SetDrawColor( color_white )
			if not pan.Icon then 
				surface.DrawOutlinedRect( hh*0.05 + add_pad , hh*0.05, iw, ih  )
				draw.SimpleText( "?", "wOS.DynaBase.QuestionFont", hh*0.05 + iw*0.5 + add_pad, hh*0.05 + ih*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER  )
			else
				surface.SetMaterial( pan.Icon )
				surface.DrawTexturedRect( hh*0.05 + add_pad, hh*0.05, iw, ih )
			end
			if pan.Toggled then return end
			draw.RoundedBox( 0, hh*0.05 + add_pad, hh*0.05, iw, ih, Color( 0, 0, 0, 215 ) )			

		end

		local url = vgui.Create( "DButton", frame )
		url:SetPos(fh*0.1 + fw*0.01 + iw + add_pad, fh - fh*0.15)
		url:SetSize(fw*0.43, fh*0.125)
		url:SetColor( color_white ) 
		url:SetFont( "wOS.DynaBase.URLFont" )
		url:SetText( "" )
		url.Paint = function( pan, ww, hh )
			local txt = pan.URL or "No Workshop URL"
			draw.SimpleText( txt, "wOS.DynaBase.URLFont", 0, hh*0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		url:SetDisabled( true )
		url.DoClick = function( pan )
			if not pan.URL then return end
			gui.OpenURL( pan.URL )
		end

		local icon = vgui.Create("DImageButton", frame)
		icon:SetPos(lw*0.01 + add_pad, lw*0.01)
		icon:SetSize(iw, ih)

		local ix, iy = icon:GetPos()

		local validated = vgui.Create("DImage", icon)
		validated:SetPos( -8, -8 )
		validated:SetSize( 16, 16 )
		validated:NoClipping( true )
		validated.UpdateCast = function( pan )
			if !frame.Toggled then
				pan:SetImage( "icon16/delete.png" )
				icon:SetTooltip( "This item is currently disabled"  )
			else
				if data.ServerValid then
					pan:SetImage( "icon16/accept.png" )
					icon:SetTooltip( "This item is registered by the server and client"  )
				else
					pan:SetImage( "icon16/error.png" )		
					icon:SetTooltip( "This item is only registered by the client and may cause unpredictable issues"  )	
				end
			end
		end
		validated:UpdateCast()

		local dock_bar = vgui.Create( "DPanel", frame )
		dock_bar:SetPos(fh*0.1 + fw*0.01 + iw + add_pad , fh - fh*0.42)
		dock_bar:SetSize(fw*0.7, fh*0.2)
		dock_bar:SetPaintBackground( false )

		local thetype = vgui.Create("DImageButton", dock_bar)
		thetype:SetTall( fh*0.2 )
		thetype:SetWide( fh*0.2 )
		thetype:Dock( LEFT )

		if data.Type == WOS_DYNABASE.REANIMATION then
			thetype:SetImage( reanim_mat )
			thetype:SetTooltip( "This addon replaces existing animations" )	
		else
			thetype:SetImage( extend_mat )
			thetype:SetTooltip( "This addon includes new animations" )	
		end

		local div = vgui.Create("DPanel", dock_bar)
		div:SetWide( fh*0.22 )
		div:Dock( LEFT )
		div.Paint = function( pan, ww, hh )
			surface.SetDrawColor( color_white )
			surface.DrawRect( ww*0.45, 0, ww*0.1, hh )
		end
		
		local shared = vgui.Create("DImageButton", dock_bar)
		shared:SetTall( fh*0.2 )
		shared:SetWide( fh*0.2 )
		shared:SetImage( shared_mat )
		shared:Dock( LEFT )
		if data.Shared then
			shared:SetTooltip( "Common / All Gender Animations" )
		else
			shared:SetColor(Color(135, 135, 135, 255))
		end

		local maled = vgui.Create("DImageButton", dock_bar)
		maled:SetTall( fh*0.2 )
		maled:SetWide( fh*0.2 )
		maled:Dock( LEFT )
		maled:SetImage( male_mat )
		if data.Male then
			maled:SetTooltip( "Male Animations" )
		else
			maled:SetColor(Color(125, 125, 125, 125))
		end

		local femaled = vgui.Create("DImageButton", dock_bar)
		femaled:SetTall( fh*0.2 )
		femaled:SetWide( fh*0.2 )
		femaled:Dock( LEFT )
		femaled:SetImage( female_mat )
		if data.Female then
			femaled:SetTooltip( "Female Animations" )
		else
			femaled:SetColor(Color(125, 125, 125, 125))
		end

		local zombied = vgui.Create("DImageButton", dock_bar)
		zombied:SetTall( fh*0.2 )
		zombied:SetWide( fh*0.2 )
		zombied:Dock( LEFT )
		zombied:SetImage( zombie_mat )
		if data.Zombie then
			zombied:SetTooltip( "Zombie Animations" )
		else
			zombied:SetColor(Color(125, 125, 125, 125))
		end

		local mdl = data.Shared
		if not mdl then mdl = data.Male end
		if not mdl then mdl = data.Female end
		if not mdl then mdl = data.Zombie end

		if mdl then
			local function UpdateContent( ndat, mat )
				if ndat and ndat.id then
					frame.AddonTitle = ndat.title
					frame.Description = ndat.description
					frame.ID = ndat.id

					url.URL = "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. ndat.id 
					url:SetDisabled( false )
				end
				frame.Icon = mat
			end
			local addon = GetContainingAddon( mdl )
			GetWorkshopInfo( addon, UpdateContent )
		end


		local check1 = data.Type == WOS_DYNABASE.REANIMATION and WOS_DYNABASE_ENFORCEREANIMATE_CVAR:GetBool()
		local check2 = data.Type == WOS_DYNABASE.EXTENSION and WOS_DYNABASE_ENFORCEEXTENDERS_CVAR:GetBool()
		if !check1 and !check2 then
			local div2 = vgui.Create("DPanel", dock_bar)
			div2:SetWide( fh*0.22 )
			div2:Dock( LEFT )
			div2.Paint = function( pan, ww, hh )
				surface.SetDrawColor( color_white )
				surface.DrawRect( ww*0.45, 0, ww*0.1, hh )
			end

			local toggle = vgui.Create("DButton", dock_bar)
			toggle:SetTall( fh*0.2 )
			if frame.Toggled then
				toggle:SetText( "Unmount Addon" )
			else
				toggle:SetText( "Mount Addon" )
			end
			toggle:SetWide( fw*0.15 )
			toggle:Dock( LEFT )
			toggle.DoClick = function( pan )
				frame.Toggled = !frame.Toggled
				if frame.Toggled then
					pan:SetText( "Unmount Addon" )
				else
					pan:SetText( "Mount Addon" )
				end
				validated:UpdateCast()
			end
		end

		layout:Add( frame )
	end


	////////////////////////////////////////////////////////////////// Local Menu

	-- if WOS_DYNABASE_ENFORCECONTENT_CVAR:GetInt() > 0 then
	-- 	local err = vgui.Create( "DPanel", sheet )
	-- 	err:Dock( FILL )
	-- 	err.Paint = function( pan, ww, hh )
	-- 		draw.SimpleText( "SERVER HAS DISABLED LOCAL ANIMATION CONTENT", "wOS.DynaBase.TitleFont", ww/2, hh*0.4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	-- 		draw.SimpleText( "USE THE SERVER TAB FOR AVAILABILITY", "wOS.DynaBase.TitleFont", ww/2, hh*0.6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )		
	-- 	end
	-- 	sheet:AddSheet( "User Animations", err, "icon16/user.png" )
	-- else

	local core = vgui.Create( "DPanel", sheet )
	core:SetSize(aw*0.9, ah*0.8)
	sheet:AddSheet( "User Animations", core, "icon16/user.png" )

	local create_butt = vgui.Create( "DButton", core )
	create_butt:SetSize( aw*0.9, ah*0.05 )
	create_butt:Dock( TOP )
	create_butt:SetText( "Create User Mount" )

	local scroll2 = vgui.Create("DScrollPanel", core )
	scroll2:SetSize(aw*0.9, ah*0.69)
	scroll2:Dock( TOP )

	local function PopulateEntries()
		if layout2 then layout2:Remove() end

		local sw, sh = aw*0.9, ah*0.73
		layout2 = vgui.Create("DListLayout", scroll2)
		layout2:SetSize(sw, sh)
		layout2:SetPaintBackground(true)
		layout2:SetBackgroundColor(Color(100, 100, 100))
		layout2:MakeDroppable( "WOS_DYNABASE_DROPPABLE_LOCAL" )

		local local_temp_loaded = {}
		local lw, lh = layout2:GetSize()
		local fw, fh = lw, lh*0.13
		local iw, ih = 0, 0

		local add_pad = lw*0.05

		local local_order_checker = {}

		local read = file.Read( "wos/dynabase/usermounts/preference.txt", "DATA" ) or "{}"
		local local_order = util.JSONToTable( read )
		local enabled_check = {}

		if table.Count( local_order ) > 0 then
			for id, dd in ipairs( local_order ) do
				local name = dd.Name
				local data = self:GetUserMount( name )
				if not data then continue end
				local_temp_loaded[ name ] = true
				table.insert( local_order_checker, data )
				if dd.Toggled then enabled_check[ name ] = true end
			end
		end

		for name, data in pairs( self:GetAllUserMounts() ) do
			if local_temp_loaded[ name ] then continue end
			table.insert( local_order_checker, data )
		end

		for order, data in ipairs( local_order_checker ) do
			local name  = data.Name
			local frame = vgui.Create( "DPanel", layout2 )
			frame:SetSize( fw, fh )
			frame.RegisterName = name
			frame.Toggled = enabled_check[ name ]
			frame.Paint = function( pan, ww, hh )
				draw.RoundedBox( 0, 0, 0, ww, hh, Color( 0, 0, 0, 155 ) )
				draw.RoundedBox( 0, ww*0.005, 0, add_pad, hh, Color( 0, 0, 0, 200 ) )

				surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
				surface.DrawOutlinedRect( 0, 0, ww, hh )
				
				surface.SetDrawColor( color_white )
				for i=0, 1 do
					surface.DrawRect( ww*0.005 + add_pad*0.2 + i*(add_pad*0.4), hh*0.32, add_pad*0.2, add_pad*0.2 )
				end

				for i=0, 1 do
					surface.DrawRect( ww*0.005 + add_pad*0.2 + i*(add_pad*0.4), hh*0.5, add_pad*0.2, add_pad*0.2 )
				end

				for i=0, 1 do
					surface.DrawRect( ww*0.005 + add_pad*0.2 + i*(add_pad*0.4), hh*0.68, add_pad*0.2, add_pad*0.2 )
				end

				local tx, th = draw.SimpleText( pan.RegisterName, "wOS.DynaBase.TitleFont", hh*0.1 + add_pad + iw + ww*0.01, hh*0.06, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP  )					
			end

			local dock_bar = vgui.Create( "DPanel", frame )
			dock_bar:SetPos(fh*0.1 + fw*0.01 + iw + add_pad , fh - fh*0.42)
			dock_bar:SetSize(fw*0.7, fh*0.35)
			dock_bar:SetPaintBackground( false )

			local validated = vgui.Create("DImageButton", dock_bar )
			validated:SetTall( fh*0.35 )
			validated:SetWide( fh*0.35 )
			validated:Dock( LEFT )
			validated.UpdateCast = function( pan )
				if !frame.Toggled then
					pan:SetImage( "icon16/delete.png" )
					pan:SetTooltip( "This item is currently disabled"  )
				else
					pan:SetImage( "icon16/accept.png" )
					pan:SetTooltip( "This item is currently enabled"  )
					pan:CheckModelValidity()
				end
			end
			validated.CheckModelValidity = function( pan )
				for _, mdl in ipairs( pan.Models ) do
					if file.Exists( mdl, "GAME" ) then continue end
					pan:SetImage( "icon16/error.png" )
					pan:SetTooltip( "This item is missing models"  )
					return
				end
			end

			local div = vgui.Create("DPanel", dock_bar)
			div:SetWide( fh*0.22 )
			div:Dock( LEFT )
			div.Paint = function( pan, ww, hh )
				surface.SetDrawColor( color_white )
				surface.DrawRect( ww*0.45, 0, ww*0.1, hh )
			end
			
			local mdls = {}

			local shared = vgui.Create("DImageButton", dock_bar)
			shared:SetTall( fh*0.35 )
			shared:SetWide( fh*0.35 )
			shared:SetImage( shared_mat )
			shared:Dock( LEFT )
			if data.Shared then
				table.insert( mdls, data.Shared )
				shared:SetTooltip( "Common / All Gender Animations" )
			else
				shared:SetColor(Color(135, 135, 135, 255))
			end

			local maled = vgui.Create("DImageButton", dock_bar)
			maled:SetTall( fh*0.35 )
			maled:SetWide( fh*0.35 )
			maled:Dock( LEFT )
			maled:SetImage( male_mat )
			if data.Male then
				table.insert( mdls, data.Male )
				maled:SetTooltip( "Male Animations" )
			else
				maled:SetColor(Color(125, 125, 125, 125))
			end

			local femaled = vgui.Create("DImageButton", dock_bar)
			femaled:SetTall( fh*0.35 )
			femaled:SetWide( fh*0.35 )
			femaled:Dock( LEFT )
			femaled:SetImage( female_mat )
			if data.Female then
				table.insert( mdls, data.Female )
				femaled:SetTooltip( "Female Animations" )
			else
				femaled:SetColor(Color(125, 125, 125, 125))
			end

			local zombied = vgui.Create("DImageButton", dock_bar)
			zombied:SetTall( fh*0.35 )
			zombied:SetWide( fh*0.35 )
			zombied:Dock( LEFT )
			zombied:SetImage( zombie_mat )
			if data.Zombie then
				table.insert( mdls, data.Zombie )
				zombied:SetTooltip( "Zombie Animations" )
			else
				zombied:SetColor(Color(125, 125, 125, 125))
			end

			validated.Models = mdls
			validated:UpdateCast()

			local div2 = vgui.Create("DPanel", dock_bar)
			div2:SetWide( fh*0.22 )
			div2:Dock( LEFT )
			div2.Paint = function( pan, ww, hh )
				surface.SetDrawColor( color_white )
				surface.DrawRect( ww*0.45, 0, ww*0.1, hh )
			end

			local toggle = vgui.Create("DButton", dock_bar)
			toggle:SetTall( fh*0.2 )
			if frame.Toggled then
				toggle:SetText( "Unmount" )
			else
				toggle:SetText( "Mount" )
			end
			toggle:SetWide( fw*0.1 )
			toggle:Dock( LEFT )
			toggle.DoClick = function( pan )
				frame.Toggled = !frame.Toggled
				if frame.Toggled then
					pan:SetText( "Unmount" )
				else
					pan:SetText( "Mount" )
				end
				validated:UpdateCast()
			end

			local div3 = vgui.Create("DPanel", dock_bar)
			div3:SetWide( fh*0.22 )
			div3:Dock( LEFT )
			div3.Paint = function( pan, ww, hh )
				surface.SetDrawColor( color_white )
				surface.DrawRect( ww*0.45, 0, ww*0.1, hh )
			end

			local edit = vgui.Create("DButton", dock_bar)
			edit:SetTall( fh*0.2 )
			edit:SetWide( fw*0.1 )
			edit:Dock( LEFT )
			edit:SetText(  "Edit" )
			edit.DoClick = function( pan )
				if IsValid( pan.OverFrame ) then pan.OverFrame:Remove() pan.OverFrame = nil end
				pan.OverFrame = vgui.Create( "DPanel" )
				pan.OverFrame:SetPaintBackground( true )
				pan.OverFrame:SetBackgroundColor( Color( 0, 0, 0, 185  ) )
				pan.OverFrame:SetSize( w, h )
				pan.OverFrame:MakePopup()
				pan.OverFrame.RefreshList = function()
					PopulateEntries()
				end

				self:CreateLocalMenu( pan.OverFrame, data )
			end

			local div4 = vgui.Create("DPanel", dock_bar)
			div4:SetWide( fh*0.22 )
			div4:Dock( LEFT )
			div4.Paint = function( pan, ww, hh )
				surface.SetDrawColor( color_white )
				surface.DrawRect( ww*0.45, 0, ww*0.1, hh )
			end

			local delete = vgui.Create("DButton", dock_bar)
			delete:SetTall( fh*0.2 )
			delete:SetWide( fw*0.1 )
			delete:Dock( LEFT )
			delete:SetText(  "Delete" )
			delete.DoClick = function( pan )
				self:DeleteUserMount( name )
				PopulateEntries()
			end

			layout2:Add( frame )
		end
	end
	
	create_butt.DoClick = function(pan) 
		if IsValid( pan.OverFrame ) then pan.OverFrame:Remove() pan.OverFrame = nil end
		pan.OverFrame = vgui.Create( "DPanel" )
		pan.OverFrame:SetPaintBackground( true )
		pan.OverFrame:SetBackgroundColor( Color( 0, 0, 0, 185  ) )
		pan.OverFrame:SetSize( w, h )
		pan.OverFrame:MakePopup()
		pan.OverFrame.RefreshList = function()
			PopulateEntries()
		end

		self:CreateLocalMenu( pan.OverFrame )
	end

	PopulateEntries()


	////////////////////////////////////////////////////////////////// Helper Menu
	local scroll = vgui.Create("DScrollPanel", sheet )
	scroll:SetSize(aw*0.9, ah*0.8)
	scroll.ReloadAddons = function() PopulateEntries() end
	local sw, sh = scroll:GetSize()
	sheet:AddSheet( "Helper Functions", scroll, "icon16/heart.png" )

	local download_butt = vgui.Create( "DButton", scroll )
	download_butt:SetSize( aw*0.9, ah*0.05 )
	download_butt:Dock( TOP )
	download_butt:SetText( "Convert Server to User Mounts (Will overwrite mounts with the same name!)" )
	download_butt.DoClick = function(pan) 
		for name, data in pairs( self:GetAllSources() ) do
			if data.Core then continue end
			if data.PreventActivities then continue end
			self:CreateUserMount( data )
		end
		PopulateEntries()
		chat.AddText( color_white, "[", Color( 0, 175, 255 ), "wOS-DynaBase", color_white, "] All registered server mounts have been added to your user mount list!" )
	end
	hook.Call( "wOS.DynaBase.PopulateHelperFunctions", nil, scroll )


	local savebutt = vgui.Create("DButton", self.AnimMenu )
	savebutt:SetSize(aw*0.9, ah*0.04)
	savebutt:SetPos( aw*0.05, ah*0.86 )
	savebutt:SetText( "Save Animation Settings" )
	sheet.OnActiveTabChanged = function( pan, old, new )
		local txt = new:GetText()
		if txt:find( "User" ) then
			savebutt:SetText( "Save User Settings" )
			savebutt:Show()
		elseif txt:find( "Server" ) then
			savebutt:SetText( "Save Server Settings" )
			savebutt:Show()
		else
			savebutt:Hide()
		end
	end
	savebutt.DoClick = function( pan )
		if sheet:GetActiveTab():GetText():find( "User" ) then
			if not layout2 then return end
			local order = {}
			for _, child in ipairs( layout2:GetChildren() ) do
				table.insert( order, { Name = child.RegisterName, Toggled = child.Toggled } )
			end
			local pref = util.TableToJSON( order )
			file.Write( "wos/dynabase/usermounts/preference.txt", pref )
			self:ReloadLocalAnimations( order )
		else
			self.PlayerOrder = {}
			self.PlayerCount = 0
			for _, child in ipairs( layout:GetChildren() ) do
				table.insert( self.PlayerOrder, { Name = child.RegisterName, Toggled = child.Toggled } )
				self.PlayerCount = self.PlayerCount + 1
			end
			self:ProcessPlayerOrder()
		end
		self:ReloadAnimations()
	end

	local nobutt = vgui.Create("DButton", self.AnimMenu )
	nobutt:SetSize(aw*0.9, ah*0.04)
	nobutt:SetPos( aw*0.05, ah*0.91 )
	nobutt:SetText( "Cancel" )
	nobutt.DoClick = function() self:OpenConfigMenu() end
	//toggle:SetText( "Cancel" )
end