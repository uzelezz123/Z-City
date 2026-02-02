wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}

function wOS.DynaBase:CreateUserMount( data )
	if not data then return end
	if not data.Name then return end
	self.UserMounts[ data.Name ] = data
	
	local mounts = file.Read( "wos/dynabase/usermounts/mounts.txt", "DATA" ) or "{}"
	local local_mounts = util.JSONToTable( mounts )

	local_mounts[ data.Name ] = data
	local_mounts = util.TableToJSON( local_mounts )
	file.Write( "wos/dynabase/usermounts/mounts.txt", local_mounts )
end

function wOS.DynaBase:DeleteUserMount( name )
	if not name then return end
	if not self.UserMounts[ name ] then return end
    self.UserMounts[ name ] = nil

	local mounts = file.Read( "wos/dynabase/usermounts/mounts.txt", "DATA" ) or "{}"
	local local_mounts = util.JSONToTable( mounts )
	local_mounts[ name ] = nil

	local_mounts = util.TableToJSON( local_mounts )
	file.Write( "wos/dynabase/usermounts/mounts.txt", local_mounts )
end

function wOS.DynaBase:GetAllUserMounts()
	return self.UserMounts
end

function wOS.DynaBase:GetUserMount( name )
	return self.UserMounts[ name ] 
end

function wOS.DynaBase:CreateLocalMenu( parent, old_data )
    old_data = old_data or {}
    local w, h = parent:GetSize()

    local frame = vgui.Create( "DFrame", parent )
    frame:SetSize( w*0.5, h*0.4 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( "Create User Mount" )
    frame.OnClose = function()
        parent:Remove()
    end
    frame.OldThink = frame.Think
    frame.Think = function( pan )
        pan:OldThink()
        if parent:HasFocus() then pan:MoveToFront() end
        if not self.AnimMenu then parent:Remove() end 
    end

    local fw, fh = frame:GetSize()

    local addon_list = vgui.Create( "DListView", frame )
    addon_list:SetWide( fw*0.3 )
    addon_list:Dock( LEFT )
    addon_list:SetMultiSelect( false )
    addon_list:AddColumn( "Addon Name" )

    local row = addon_list:AddLine( "Base Game" )
    row.title = "GAME"

    for _, addon in ipairs( engine.GetAddons() ) do
        if not addon.downloaded then continue end
        if not addon.mounted then continue end
        local row = addon_list:AddLine( addon.title )
    end

    local browser = vgui.Create( "DFileBrowser", frame )
    browser:SetTall( fh )
    browser:SetWide( fw*0.4 )
    browser:Dock( LEFT )
    browser:SetPath( "GAME" )
    browser:SetBaseFolder( "models" )
    browser:SetFileTypes( "*.mdl" )
    browser:SetOpen( true )

    addon_list.OnRowSelected = function( pan, i, row )
        browser:SetPath( row.title or row:GetColumnText(1) )
        browser:SetBaseFolder( "models" )
        browser:SetOpen( true )
    end

    local div = vgui.Create( "DPanel", frame )
    div:SetBackgroundColor( Color( 0, 0, 0 ) )
    div:SetWide( fw*0.01 )
    div:Dock( LEFT )

    local creation_frame = vgui.Create( "DPanel", frame )
    creation_frame:SetWide( fw*0.29 )
    creation_frame:SetBackgroundColor( Color( 130, 130, 130 ) )
    creation_frame:Dock( LEFT )
    creation_frame:DockPadding( fw*0.005, 0, fw*0.01, 0 )

    local cw, ch = creation_frame:GetSize()

    local name_lab =  vgui.Create( "DLabel", creation_frame )
    name_lab:SetTextColor( color_white )
    name_lab:SetFont( "wOS.DynaBase.DescFont" )
    name_lab:SetText( "Name of User Mount" )
    name_lab:Dock( TOP )
    name_lab.DefaultCol = name_lab:GetColor()

    local name_ent = vgui.Create( "DTextEntry", creation_frame )
    name_ent:Dock( TOP )
    name_ent:SetFont( "DermaDefaultBold" )
    name_ent:SetText( old_data.Name or "" )
    name_ent:SetPlaceholderText( "Enter name of mount" )
    name_ent:DockMargin( fw*0.01, 0, 0, 0 )
    name_ent.OnGetFocus = function(pan)
        name_lab:SetTextColor( name_lab.DefaultCol )
    end

    local name =  vgui.Create( "DLabel", creation_frame )
    name:SetTextColor( color_white )
    name:SetFont( "wOS.DynaBase.DescFont" )
    name:SetText( "Shared Mounting Model" )
    name:Dock( TOP )
    name:DockMargin( 0, fh*0.02, 0, 0 )

    local share_ent = vgui.Create( "DTextEntry", creation_frame )
    share_ent:Dock( TOP )
    share_ent:SetFont( "DermaDefaultBold" )
    share_ent:SetText( old_data.Shared or "" )
    share_ent:SetPlaceholderText( "Enter path or right click on model in browser" )
    share_ent:DockMargin( fw*0.01, 0, 0, 0 )

    local name =  vgui.Create( "DLabel", creation_frame )
    name:SetTextColor( color_white )
    name:SetFont( "wOS.DynaBase.DescFont" )
    name:SetText( "Male Mounting Model" )
    name:Dock( TOP )
    name:DockMargin( 0, fh*0.02, 0, 0 )

    local male_ent = vgui.Create( "DTextEntry", creation_frame )
    male_ent:Dock( TOP )
    male_ent:SetText( old_data.Male or "" )
    male_ent:SetFont( "DermaDefaultBold" )
    male_ent:SetPlaceholderText( "Enter path or right click on model in browser" )
    male_ent:DockMargin( fw*0.01, 0, 0, 0 )

    local name =  vgui.Create( "DLabel", creation_frame )
    name:SetTextColor( color_white )
    name:SetFont( "wOS.DynaBase.DescFont" )
    name:SetText( "Female Mounting Model" )
    name:Dock( TOP )
    name:DockMargin( 0, fh*0.02, 0, 0 )

    local female_ent = vgui.Create( "DTextEntry", creation_frame )
    female_ent:Dock( TOP )
    female_ent:SetText( old_data.Female or "" )
    female_ent:SetFont( "DermaDefaultBold" )
    female_ent:SetPlaceholderText( "Enter path or right click on model in browser" )
    female_ent:DockMargin( fw*0.01, 0, 0, 0 )

    local name =  vgui.Create( "DLabel", creation_frame )
    name:SetTextColor( color_white )
    name:SetFont( "wOS.DynaBase.DescFont" )
    name:SetText( "Zombie Mounting Model" )
    name:Dock( TOP )
    name:DockMargin( 0, fh*0.02, 0, 0 )

    local zombie_ent = vgui.Create( "DTextEntry", creation_frame )
    zombie_ent:Dock( TOP )
    zombie_ent:SetText( old_data.Zombie or "" )
    zombie_ent:SetFont( "DermaDefaultBold" )
    zombie_ent:SetPlaceholderText( "Enter path or right click on model in browser" )
    zombie_ent:DockMargin( fw*0.01, 0, 0, 0 )

    local cancel = vgui.Create("DButton", creation_frame )
    cancel:SetTall( fh*0.05 )
    cancel:Dock( BOTTOM )
    cancel:SetText( "Cancel" )
    cancel.DoClick = function() frame:Close() end

    local save = vgui.Create("DButton", creation_frame )
    save:SetTall( fh*0.05 )
    save:Dock( BOTTOM )
    save:SetText( "Save User Mount" )
    save.DoClick = function()
        local name = name_ent:GetText()
        if #name < 1 then
            name_lab:SetTextColor( Color( 255, 0, 0 ) )
            surface.PlaySound( "buttons/button10.wav" )
            return
        end

        local tbl = {
            Name = name,
            Shared = ( #share_ent:GetText() > 1 and share_ent:GetText() ) or nil,
            Male = ( #male_ent:GetText() > 1 and male_ent:GetText() ) or nil,
            Female = ( #female_ent:GetText() > 1 and female_ent:GetText() ) or nil,
            Zombie = ( #zombie_ent:GetText() > 1 and zombie_ent:GetText() ) or nil,
        }
        if old_data.Name then
            self:DeleteUserMount( old_data.Name )
        end
        self:CreateUserMount( tbl )
        parent:RefreshList()
        frame:Close()
    end

    function browser:OnRightClick( path, pnl ) -- Called when a file is clicked
        local menu = DermaMenu()
        menu:AddOption( "Set as Shared Mount", function()
            share_ent:SetText( path )
        end ):SetIcon( "icon16/group.png" )

        menu:AddOption( "Set as Male Mount", function()
            male_ent:SetText( path )
        end ):SetIcon( "icon16/male.png" )

        menu:AddOption( "Set as Female Mount", function()
            female_ent:SetText( path )
        end ):SetIcon( "icon16/female.png" )

        menu:AddOption( "Set as Zombie Mount", function()
            zombie_ent:SetText( path )
        end ):SetIcon( "icon16/bug.png" )

        menu:Open()
    end

end

hook.Add( "Initialize", "wOS.DynaBase.LoadUserMounts", function()
	local mounts = file.Read( "wos/dynabase/usermounts/mounts.txt", "DATA" ) or "{}"
	local local_mounts = util.JSONToTable( mounts )		

	for mount, data in pairs( local_mounts ) do
		wOS.DynaBase.UserMounts[ mount ] = data
	end

end )