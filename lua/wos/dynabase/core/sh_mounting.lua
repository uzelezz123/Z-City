wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}
local added = {}

////////////////////////////////////// BASELINE STUFF //////////////////////////////////////
local model_table = {}
model_table[ WOS_DYNABASE.SHARED  ] = "models/player/wiltos/anim_dynamic_pointer.mdl"
model_table[ WOS_DYNABASE.MALE  ] = "models/player/wiltos/anim_dynamic_maleptr.mdl"
model_table[ WOS_DYNABASE.FEMALE  ] = "models/player/wiltos/anim_dynamic_femaler.mdl"
model_table[ WOS_DYNABASE.ZOMBIE  ] = "models/player/wiltos/anim_dynamic_zombier.mdl"

local model_ext = {}
model_ext[ WOS_DYNABASE.MALE  ] = "_male"
model_ext[ WOS_DYNABASE.FEMALE  ] = "_female"
model_ext[ WOS_DYNABASE.ZOMBIE  ] = "_zombie"

local INCLUDE_MODEL_START = 737
local INCLUDE_MODEL_END_SHARED = 806

// "Hard code the math idiot" says the guy who doesn't realize I'm making it easier on myself to change their names or expand in the future
// I also can't count letters, only numbers?? GENIUS. NICE ONE
local INCLUDE_MODEL_END_MALE = INCLUDE_MODEL_END_SHARED + ( #"_male" )*2
local INCLUDE_MODEL_END_FEMALE = INCLUDE_MODEL_END_SHARED + ( #"_female" )*2 
local INCLUDE_MODEL_END_ZOMBIE = INCLUDE_MODEL_END_SHARED + ( #"_zombie" )*2

////////////////////////////////////////////////////////////////////////////////////////////

function IncludeModel( mdl )
	if not mdl then return end
	if wOS.DynaBase.PreservedModels[ mdl ] then mdl = wOS.DynaBase.PreservedModels[ mdl ] end
	if table.HasValue( added, mdl ) then return end //This isn't needed but let's not bloat the mount file
	table.insert( added, 1, mdl )
end

local function IntToByte( num )
	if not num then return end
	local t = {}
	t[1] = num % 256
	for i=1, 3 do
		t[i+1] = math.modf( num / ( 256^i ) ) % ( 256 )
	end
	return t
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// If you don't know what this does do not mess with it or you're gonna mess up your player model
// There'll be a lot of repeated code here for now while we get some TESTING done
local function WRITE_TO_LOCAL( start, finish, type )
	if not type then return end
	local base_path = model_table[ type  ]
	if not base_path then return end

	local mdl_file = file.Open( base_path, "r", "GAME" )
	local dat = {}
	local str = ""
	for i=0, mdl_file:Size() do
		local byte = mdl_file:ReadByte()
		table.insert( dat, byte )
		if not byte then continue end
		str = str .. string.char( byte )
	end

	
	local endchar = str[finish]
	local tstr = ""
	for i=0, #str do
		if i == start then
			for _, newmodel in ipairs( added ) do
				tstr = tstr .. newmodel .. endchar
			end
		end
		if i >= start and i <= finish then continue end
		local char = str[i]
		tstr = tstr .. char
	end

	local includenum = IntToByte( #added )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 336 + i, string.char( includenum[i] ) )
	end

	local final_line = "models/player/wiltos/anim_dynamic_pointer/."
	local endptr = #tstr - #final_line

	local null_insert = IntToByte( 0 )

    // You can manipulate the list here to remove anything you don't want for this type
	hook.Call( "PreCreateLocalAnimation", nil, type, added )

	local first_num = 60 + ( #added - 1 )*8
	local includenum = IntToByte( first_num )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 680 + i, string.char( includenum[i] ) )
	end

	for i=1, #added - 1 do

		local anim_pos = first_num - 7*i
		for j=1, i do
			anim_pos = anim_pos + #added[j]
		end
		local anim_num = IntToByte( anim_pos )

		local start_pos = 676 + 8*i
		local start_half = string.sub( tstr, 1, start_pos )
		for j=1, 4 do
			start_half = start_half .. string.char( null_insert[j] )
		end
		for j=1, 4 do
			start_half = start_half .. string.char( anim_num[j] )
		end
		endptr = endptr + 8
		tstr = start_half .. string.sub( tstr, start_pos + 1 )
	end


	local endincludeaddr = IntToByte( endptr )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 684 + 8*(#added - 1 ) + i, string.char( endincludeaddr[i] ) )
	end

	for i=0, #added - 1 do
		tstr = tstr .. endchar
	end

	local datalen = IntToByte( #tstr )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 76 + i, string.char( datalen[i] ) )
	end

	local ext = model_ext[ type  ] or "_shared"
	file.Write( "wos/dynabase/local" .. ext .. WOS_DYNABASE_FILE_EXTENSION, tstr )
    hook.Call( "PostCreateLocalAnimation", nil, type, added )
end

// If you don't know what this does do not mess with it or you're gonna mess up your player model
local function WRITE_TO_POINTER( start, finish, type )
	if not type then return end
	local base_path = model_table[ type ]
	if not base_path then return end

	local mdl_file = file.Open( base_path, "r", "GAME" )
	local str = ""
	for i=0, mdl_file:Size() do
		local byte = mdl_file:ReadByte()
		if not byte then continue end
		str = str .. string.char( byte )
	end

	
	local endchar = str[finish]
	local tstr = ""
	for i=0, #str do
		if i == start then
			for _, newmodel in ipairs( added ) do
				tstr = tstr .. newmodel .. endchar
			end
		end
		if i >= start and i <= finish then continue end
		local char = str[i]
		tstr = tstr .. char
	end

	local includenum = IntToByte( #added )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 336 + i, string.char( includenum[i] ) )
	end

	local final_line = "models/player/wiltos/anim_dynamic_pointer/."
	local endptr = #tstr - #final_line

	local null_insert = IntToByte( 0 )

    // You can manipulate the list here to remove anything you don't want for this type
	hook.Call( "PreMountAnimation", nil, type, added )

	local first_num = 60 + ( #added - 1 )*8
	local includenum = IntToByte( first_num )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 680 + i, string.char( includenum[i] ) )
	end

	for i=1, #added - 1 do

		local anim_pos = first_num - 7*i
		for j=1, i do
			anim_pos = anim_pos + #added[j]
		end
		local anim_num = IntToByte( anim_pos )

		local start_pos = 676 + 8*i
		local start_half = string.sub( tstr, 1, start_pos )
		for j=1, 4 do
			start_half = start_half .. string.char( null_insert[j] )
		end
		for j=1, 4 do
			start_half = start_half .. string.char( anim_num[j] )
		end
		endptr = endptr + 8
		tstr = start_half .. string.sub( tstr, start_pos + 1 )
	end


	local endincludeaddr = IntToByte( endptr )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 684 + 8*(#added - 1 ) + i, string.char( endincludeaddr[i] ) )
	end

	for i=0, #added - 1 do
		tstr = tstr .. endchar
	end

	local datalen = IntToByte( #tstr )
	for i=1, 4 do
		tstr = string.SetChar( tstr, 76 + i, string.char( datalen[i] ) )
	end

	local ext = model_ext[ type  ] or ""
	file.Write( "wos/dynabase/anim_dynamic" .. ext .. WOS_DYNABASE_FILE_EXTENSION, tstr )
    hook.Call( "PostMountAnimation", nil, type, added )
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////

local function AdjustMountOrder( tbl, typ )
	if not tbl then return end

	local reference = wOS.DynaBase.FilteredLoadOrder[ typ ]
	local blacklist = wOS.DynaBase.FilteredBlacklist[ typ ]
	local plyref = wOS.DynaBase.FilteredPlayerOrder[ typ ]
	local plyblacklist = wOS.DynaBase.FilteredPlayerBlacklist[ typ ]

	local new_tbl = {}

	if WOS_DYNABASE_ENFORCECONTENT_CVAR:GetInt() > 0 then
		local cust_mount = wOS.DynaBase:GetSource( "Local Player Animations" )
		if cust_mount then
			if typ == WOS_DYNABASE.MALE then
				table.RemoveByValue( tbl, cust_mount.Male )
			elseif typ == WOS_DYNABASE.FEMALE then
				table.RemoveByValue( tbl, cust_mount.Female )
			elseif typ == WOS_DYNABASE.ZOMBIE then
				table.RemoveByValue( tbl, cust_mount.Zombie )
			else
				table.RemoveByValue( tbl, cust_mount.Shared )
			end
		end
	end

	if reference then
		for _, path in ipairs( reference ) do
			path = wOS.DynaBase.PreservedModels[ path ] or path
			if !table.HasValue( tbl, path ) then continue end
			table.insert( new_tbl, path )
			table.RemoveByValue( tbl, path )
		end
	end

	// If we aren't allowed to use any other addon than the ones that are dictated, don't merge any extra models
	if WOS_DYNABASE_ENFORCECONTENT_CVAR:GetInt() >= 2 and reference then return new_tbl end

	if plyref then
		for _, path in ipairs( plyref ) do
			path = wOS.DynaBase.PreservedModels[ path ] or path
			if !table.HasValue( tbl, path ) then continue end
			table.insert( new_tbl, path )
			table.RemoveByValue( tbl, path )
		end
	end

	if plyblacklist then
		for _, path in ipairs( plyblacklist ) do
			path = wOS.DynaBase.PreservedModels[ path ] or path
			table.RemoveByValue( tbl, path )
		end	
	end

	// Add the ones we don't care about now
	table.Add( new_tbl, tbl )

	// Server gets final word what we can use
	if blacklist then
		for _, path in ipairs( blacklist ) do
			path = wOS.DynaBase.PreservedModels[ path ] or path
			table.RemoveByValue( new_tbl, path )
		end	
	end


	return new_tbl
end

function wOS.DynaBase:ReloadAnimations()

	if self.LIVE_RELOAD then
		local seq = LocalPlayer():LookupSequence( "_dynamic_wiltos_enabled_" )
		if seq <= 0 then
			chat.AddText( Color( 255, 0, 0 ), "[wOS-Dynabase] Dynamic Animation Base failed due to conflicting animation base. Enter wos_dynabase_help into console to find the conflict, unsubscribe from the addon, and restart Garry's Mod.\n\nIf you are on someone's server, contact the owner to ensure they do not have a conflicting animation addon as required content." )
			return
		end
	end

	added = table.Copy( self.DefaultTable.Male )
	hook.Call( "PreLoadAnimations", nil, WOS_DYNABASE.MALE, added )
	local ntable = AdjustMountOrder( added, WOS_DYNABASE.MALE )
	added = ntable or added
	WRITE_TO_POINTER( INCLUDE_MODEL_START, INCLUDE_MODEL_END_MALE, WOS_DYNABASE.MALE )
	
	added = table.Copy( wOS.DynaBase.DefaultTable.Female )
	hook.Call( "PreLoadAnimations", nil, WOS_DYNABASE.FEMALE, added )
	ntable = AdjustMountOrder( added, WOS_DYNABASE.FEMALE )
	added = ntable or added
	WRITE_TO_POINTER( INCLUDE_MODEL_START, INCLUDE_MODEL_END_FEMALE, WOS_DYNABASE.FEMALE )

	added = table.Copy( wOS.DynaBase.DefaultTable.Zombie )
	hook.Call( "PreLoadAnimations", nil, WOS_DYNABASE.ZOMBIE, added )
	ntable = AdjustMountOrder( added, WOS_DYNABASE.ZOMBIE )
	added = ntable or added
	WRITE_TO_POINTER( INCLUDE_MODEL_START, INCLUDE_MODEL_END_ZOMBIE, WOS_DYNABASE.ZOMBIE )

	added = table.Copy( wOS.DynaBase.DefaultTable.Shared  )
	hook.Call( "PreLoadAnimations", nil, WOS_DYNABASE.SHARED, added )
	ntable = AdjustMountOrder( added, WOS_DYNABASE.SHARED )
	added = ntable or added
	WRITE_TO_POINTER( INCLUDE_MODEL_START, INCLUDE_MODEL_END_SHARED, WOS_DYNABASE.SHARED )

	if SERVER then
		hook.Call( "PostLoadAnimations" ) --Server doesn't need to worry about render stuff so we load here
		return
	end

	if wOS.DynaBase.InitCompleted and not WOS_DYNABASE_SHOULDHOTLOAD_CVAR:GetBool() then return end
	wOS.DynaBase.ReloadModelBool = true
end

function wOS.DynaBase:ReloadLocalAnimations( order )

	if not order then
		order = file.Read( "wos/dynabase/usermounts/preference.txt", "DATA" ) or "{}"
		order = util.JSONToTable( order )
	end

	local shared_tbl = {}
	local male_tbl = {}
	local female_tbl = {}
	local zombie_tbl = {}

	for _, mount in ipairs( order ) do
		if not mount.Toggled then continue end
		local data = self:GetUserMount( mount.Name )
		if not data then continue end
		
		if data.Shared and not table.HasValue( shared_tbl, data.Shared ) then
			table.insert( shared_tbl, data.Shared )
		end

		if data.Male and not table.HasValue( male_tbl, data.Male ) then
			table.insert( male_tbl, data.Male )
		end

		if data.Female and not table.HasValue( female_tbl, data.Female ) then
			table.insert( female_tbl, data.Female )
		end

		if data.Zombie and not table.HasValue( zombie_tbl, data.Zombie ) then
			table.insert( zombie_tbl, data.Zombie )
		end

	end

	added = male_tbl
	WRITE_TO_LOCAL( INCLUDE_MODEL_START, INCLUDE_MODEL_END_MALE, WOS_DYNABASE.MALE )
	
	added = female_tbl
	WRITE_TO_LOCAL( INCLUDE_MODEL_START, INCLUDE_MODEL_END_FEMALE, WOS_DYNABASE.FEMALE )

	added = zombie_tbl
	WRITE_TO_LOCAL( INCLUDE_MODEL_START, INCLUDE_MODEL_END_ZOMBIE, WOS_DYNABASE.ZOMBIE )

	added = shared_tbl
	WRITE_TO_LOCAL( INCLUDE_MODEL_START, INCLUDE_MODEL_END_SHARED, WOS_DYNABASE.SHARED )
end

file.CreateDir("wos/dynabase/usermounts")