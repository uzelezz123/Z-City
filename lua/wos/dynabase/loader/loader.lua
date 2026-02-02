--[[-------------------------------------------------------------------
	wiltOS Dynamic Animation Base:
			Powered by
						  _ _ _    ___  ____  
				__      _(_) | |_ / _ \/ ___| 
				\ \ /\ / / | | __| | | \___ \ 
				 \ V  V /| | | |_| |_| |___) |
				  \_/\_/ |_|_|\__|\___/|____/ 
											  
 _____         _                 _             _           
|_   _|__  ___| |__  _ __   ___ | | ___   __ _(_) ___  ___ 
  | |/ _ \/ __| '_ \| '_ \ / _ \| |/ _ \ / _` | |/ _ \/ __|
  | |  __/ (__| | | | | | | (_) | | (_) | (_| | |  __/\__ \
  |_|\___|\___|_| |_|_| |_|\___/|_|\___/ \__, |_|\___||___/
                                         |___/             
-------------------------------------------------------------------]]--[[
							  
	Lua Developer: King David
	Contact: http://steamcommunity.com/groups/wiltostech
		
----------------------------------------]]--

wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}

local string = string
local file = file

local function _AddCSLuaFile( lua )

	if SERVER then
		AddCSLuaFile( lua )
	end
	
end

local function _include( load_type, lua )

	if load_type then
		include( lua )
	end
	
end

function wOS.DynaBase:Autoloader()

	_AddCSLuaFile( "wos/dynabase/core/sh_core.lua" )
	_include( SERVER, "wos/dynabase/core/sh_core.lua" )
	_include( CLIENT, "wos/dynabase/core/sh_core.lua" )

	_AddCSLuaFile( "wos/dynabase/core/sh_model_operations.lua" )
	_include( SERVER, "wos/dynabase/core/sh_model_operations.lua" )
	_include( CLIENT, "wos/dynabase/core/sh_model_operations.lua" )
	
	_AddCSLuaFile( "wos/dynabase/core/sh_mounting.lua" )
	_include( SERVER, "wos/dynabase/core/sh_mounting.lua" )
	_include( CLIENT, "wos/dynabase/core/sh_mounting.lua" )

	_AddCSLuaFile( "wos/dynabase/core/cl_net.lua" )
	_include( CLIENT, "wos/dynabase/core/cl_net.lua" )

	_AddCSLuaFile( "wos/dynabase/core/cl_core.lua" )
	_include( CLIENT, "wos/dynabase/core/cl_core.lua" )
	_include( SERVER, "wos/dynabase/core/sv_core.lua" )

	_AddCSLuaFile( "wos/dynabase/core/cl_local_copy.lua" )
	_include( CLIENT, "wos/dynabase/core/cl_local_copy.lua" )

	_AddCSLuaFile( "wos/dynabase/core/cl_config_menu.lua" )
	_include( CLIENT, "wos/dynabase/core/cl_config_menu.lua" )

	for _,source in pairs( file.Find( "wos/dynabase/registers/*", "LUA"), true ) do
		local lua = "wos/dynabase/registers/" .. source
		_AddCSLuaFile( lua )
		_include( SERVER, lua )
		_include( CLIENT, lua )
	end
	
end

wOS.DynaBase:Autoloader()