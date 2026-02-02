wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}
wOS.DynaBase.UserMounts = {}

hook.Add( "RenderScene", "wOS.DynaBase.PreventDataAccess", function()
	if wOS.DynaBase.ResumeRendering and wOS.DynaBase.ResumeRendering >= CurTime() then return true end
	if not wOS.DynaBase.ReloadModelBool then return end
	wOS.DynaBase.DataCachePass = wOS.DynaBase.DataCachePass + 1
	return true
end )

hook.Add( "PostRender", "wOS.DynaBase.PreventDataAccess", function()
	if not wOS.DynaBase.ReloadModelBool then return end
	wOS.DynaBase.ReloadModelBool = false
	local val = wOS.DynaBase.DataCachePass
	wOS.DynaBase.DataCachePass = 0
	if not val or val < WOS_DYNABASE.MAXCACHE then
		chat.AddText( Color( 255, 0, 0 ), "[wOS-Dynabase] Can not apply animation selection due to conflicting addons. Please let us know on the Workshop Page or Discord!" )
		return
	end
	RunConsoleCommand( "r_flushlod" )
	hook.Call( "PostLoadAnimations" )
	wOS.DynaBase.ResumeRendering = CurTime() + 0.3
	if not wOS.DynaBase.FIRST_TIME_LOADED then wOS.DynaBase.FIRST_TIME_LOADED = true return end
	chat.AddText( Color( 0, 255, 0 ), "[wOS-Dynabase] Successfully applied animation selection to models!" )
end )

concommand.Add( "wos_dynabase_reloadmodels", function()
	wOS.DynaBase.LIVE_RELOAD = true
	wOS.DynaBase:ReloadAnimations()
	wOS.DynaBase.LIVE_RELOAD = false
end )

///////////////////////////////////////////////////////////////////////////////////////////////////
// Credits to Starlight (Oliver) for the code snippet and also giving it to me every time
// I asked, for the last 3 years
local function FindPotentialBases()

	for _ ,addon in pairs( engine.GetAddons() ) do
		local modelFound = file.Find("models/m_anm.mdl", addon.title)
		if #modelFound != 0 then
			MsgC( Color( 255, 0, 255 ), "\n\tAddon: " .. addon.title .. "\n" )
			MsgC( Color( 255, 0, 255 ), "\tLink: https://steamcommunity.com/sharedfiles/filedetails/?id=" .. addon.wsid .. "\n" )
			return true
		end 
	end

	return false
end
///////////////////////////////////////////////////////////////////////////////////////////////////

concommand.Add( "wos_dynabase_help", function( ply, cmd, args )
	MsgC( Color( 255, 255, 255 ), "------------------ ", Color( 133, 173, 219 ), "wiltOS HELP PRINT", Color( 255, 255, 255 ), " ----------------------\n" )
	MsgC( Color( 255, 255, 255 ), "Installed Animation Base\n" )
	timer.Simple( 0.01, function()
		local found = FindPotentialBases()
		if not found then
			MsgC( Color( 255, 0, 255 ), "\n\tNo Animation Bases found! You must get the Dynamic Animation Manager\n" )
			MsgC( Color( 255, 0, 255 ), "\tWorkshop Link: https://steamcommunity.com/sharedfiles/filedetails/?id=2916561591\n" )
		end
		MsgC( color_white, "\nPlease ensure that the only addon above is ", Color( 0, 255, 0 ), "'[wOS] DynaBase - The Dynamic Animation Manager'\n")
		MsgC( color_white, "If there are more addons, unsubscribe from them and install the Dynamic Animation Manager.\n")
		print("\n")

		local seq = LocalPlayer():LookupSequence( "_dynamic_wiltos_enabled_" )
		local resp = ( seq >= 0 and Color( 0, 255, 0 ) ) or Color( 255, 0, 0 )
		MsgC( color_white, "Sequence Check: ", resp, "\t", seq, "\n" )
		MsgC( color_white, "If the above sequence check is ", Color( 255, 0, 0 ), -1, color_white, " and the addon above points to the correct location,\nensure your model is a ", Color( 0, 255, 0 ), "PLAYER MODEL", color_white, " and not an ", Color( 255, 0, 0 ), "NPC MODEL\n" )
		MsgC( color_white, "Run this commmand again as a default GMod player model. If it still prints ", Color( 255, 0, 0 ), -1, color_white, " your Animation Base may be outdated\n" )

		print( "\n" )
		MsgC( color_white, "Make can find the Dynamic Animation Manager workshop page here: https://steamcommunity.com/sharedfiles/filedetails/?id=2916561591\n")
		MsgC( Color( 255, 255, 255 ), "-----------------------------------------------------------\n" )
	end )
end )

///////////////////////////////////////////////////////////////////////////////////////////////////

concommand.Add( "wos_dynabase_openconfig", function( ply, cmd, args )
	wOS.DynaBase:OpenConfigMenu()
end )

list.Add( "DesktopWindows", {
	icon = "wos/dynabase/widget.png",
	title = "DynaBase Menu",
	init = function() wOS.DynaBase:OpenConfigMenu() end,
})