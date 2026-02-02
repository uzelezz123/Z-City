wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}
wOS.DynaBase.PreservedModels = wOS.DynaBase.PreservedModels or {}

local function FIX_MODEL_ACTIVITIES( path )
    if not path then return end

	local new_path = string.Replace(path, "models/", "wos/dynabase/fixedmodels/")
	new_path = string.Replace( new_path, ".mdl", WOS_DYNABASE_FILE_EXTENSION )
    if file.Exists( new_path, "DATA" ) and not wOS.DynaBase.ReloadFixedModels then return "data/" .. new_path end

	local mdl_file = file.Open( path, "r", "GAME" )
    if not mdl_file then return end

	local str = ""
	local sanitary_str = ""
	for i=0, mdl_file:Size() do
		local byte = mdl_file:ReadByte()
		if not byte then continue end
		str = str .. string.char( byte )
		if byte == 0 then
			sanitary_str = sanitary_str .. string.char( 35 )
		else
			sanitary_str = sanitary_str .. string.char( byte )
		end
	end
	local _start, _end = string.find( sanitary_str, "ACT_" )
	while _start do
		local act_name = "WDB_"
		for i=0, 3 do 
			str = string.SetChar( str, _start + i, act_name[i + 1] )
		end
		_start, _end = string.find( sanitary_str, "ACT_", _end )
	end


	local dt = string.Explode("/", new_path)
	dt = dt[#dt]
	
	local file_path = string.Left( path, #path - #dt - 1 )

	file.CreateDir( file_path )
	file.Write( new_path, str )

    return "data/" .. new_path
end

function wOS.DynaBase:FixActivities( data )
    if not data then return end
    
    if data.Shared and ( not self.PreservedModels[ data.Shared ] or wOS.DynaBase.ReloadFixedModels ) then
        local path = FIX_MODEL_ACTIVITIES( data.Shared )
        if path then
            self.PreservedModels[ data.Shared ] = path
        end
    end

    if data.Male and ( not self.PreservedModels[ data.Male ] or wOS.DynaBase.ReloadFixedModels ) then
        local path = FIX_MODEL_ACTIVITIES( data.Male )
        if path then
            self.PreservedModels[ data.Male ] = path
        end    
    end

    if data.Female and ( not self.PreservedModels[ data.Female ] or wOS.DynaBase.ReloadFixedModels ) then
        local path = FIX_MODEL_ACTIVITIES( data.Female )
        if path then
            self.PreservedModels[ data.Female ] = path
        end    
    end

    if data.Zombie and ( not self.PreservedModels[ data.Zombie ] or wOS.DynaBase.ReloadFixedModels ) then
        local path = FIX_MODEL_ACTIVITIES( data.Zombie )
        if path then
            self.PreservedModels[ data.Zombie ] = path
        end
    end

end

concommand.Add( "wos_dynabase_debug_reloadfixedmodels", function()
	wOS.DynaBase.ReloadFixedModels = true
    for name, data in pairs( wOS.DynaBase:GetAllSources() ) do
        if not data.PreventActivities then continue end
        wOS.DynaBase:FixActivities( data )      
    end
	wOS.DynaBase.ReloadFixedModels = false
end )

file.CreateDir("wos/dynabase/fixedmodels")


local function FixConflictingBases()
    for _, addon in ipairs( engine.GetAddons() ) do
        if addon.wsid == "2916561591" then
            game.MountGMA( addon.file )
            RunConsoleCommand( "r_flushlod" )
            break
        end
    end
end
hook.Add( "InitLoadAnimations", "wOS.DynaBase.FixConflictingBases", FixConflictingBases )

concommand.Add( "wos_dynabase_fixconflicts", function()
    FixConflictingBases()
    print( "[wOS-DynaBase] Conflicting bases have been unloaded for this session. Double check by running the wos_dynabase_help command!\n\nNote: The addon may still be mounted when you restart your game.")
end )
