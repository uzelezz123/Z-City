// That's right, x64 won't work with .dat in this trick. Special thanks to 8Z
WOS_DYNABASE_FILE_EXTENSION = ".dat"
-- if jit.arch == "x64" then
-- 	WOS_DYNABASE_FILE_EXTENSION = ".txt"
-- end

wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}
wOS.DynaBase.DataCachePass = 0
wOS.DynaBase.InitCompleted = false

wOS.DynaBase.Registers = {}
wOS.DynaBase.RegisterCount = 0

wOS.DynaBase.EnforcedOrder = {}
wOS.DynaBase.EnforceCount = 1

wOS.DynaBase.PlayerOrder = {}
wOS.DynaBase.PlayerCount = 1

WOS_DYNABASE = WOS_DYNABASE or {}
WOS_DYNABASE.SHARED = 1
WOS_DYNABASE.MALE = 2
WOS_DYNABASE.FEMALE = 3
WOS_DYNABASE.ZOMBIE = 4
WOS_DYNABASE.MAXCACHE = 1

WOS_DYNABASE.EXTENSION = 1
WOS_DYNABASE.REANIMATION = 2

wOS.DynaBase.DefaultTable = {}
wOS.DynaBase.DefaultTable.Male = { "data/wos/dynabase/local_male" .. WOS_DYNABASE_FILE_EXTENSION, "models/m_wos.mdl" }
wOS.DynaBase.DefaultTable.Female = { "data/wos/dynabase/local_female" .. WOS_DYNABASE_FILE_EXTENSION, "models/f_wos.mdl" }
wOS.DynaBase.DefaultTable.Zombie = { "data/wos/dynabase/local_zombie" .. WOS_DYNABASE_FILE_EXTENSION, "models/z_wos.mdl" }
wOS.DynaBase.DefaultTable.Shared = { "data/wos/dynabase/local_shared" .. WOS_DYNABASE_FILE_EXTENSION }

wOS.DynaBase.FilteredLoadOrder = {}
wOS.DynaBase.FilteredPlayerOrder = {}

wOS.DynaBase.FilteredBlacklist = {}
wOS.DynaBase.FilteredPlayerBlacklist = {}

local flags = {FCVAR_REPLICATED, FCVAR_PROTECTED, FCVAR_ARCHIVE}
WOS_DYNABASE_ENFORCECONTENT_CVAR = CreateConVar( "wos_dynabase_restrict_client_content", "0", flags, "Prevents usage of custom content (animations) that are not registered on the server.\n \t0 = No Restrictions\n \t1 = Registered Addons\n \t2 = Registered and Mounted Addons" )
WOS_DYNABASE_ENFORCEREANIMATE_CVAR = CreateConVar( "wos_dynabase_restrict_client_reanimation", "1", flags, "Prevents clients from being able to customize what re-animations are locally enabled" )
WOS_DYNABASE_ENFORCEEXTENDERS_CVAR = CreateConVar( "wos_dynabase_restrict_client_extension", "1", flags, "Prevents clients from being able to customize what animation extensions are locally enabled" )
WOS_DYNABASE_LOADORDERENFORCE_CVAR = CreateConVar( "wos_dynabase_restrict_server_loadorder", "1", flags, "Enforces the order of animations as registered by the order of wos_dynabase_mountaddon command executions. Addons not specified will be mounted after the initial list" )
WOS_DYNABASE_MOUNTORDERLIST_CVAR = CreateConVar( "wos_dynabase_mountorder", "", flags, "Enforces the order of animations as comma seperated names of registered addons. Addons not specified will be mounted after the initial list unless content enforcement is set to 2. Any addons not installed are simply skipped" )
WOS_DYNABASE_MOUNTBLACKLIST_CVAR = CreateConVar( "wos_dynabase_blacklist", "", flags, "A comma seperated list of the names of blacklisted registered sources" )
WOS_DYNABASE_SHOULDHOTLOAD_CVAR = CreateConVar( "wos_dynabase_live_reload", "1", {FCVAR_ARCHIVE}, "Should animations reload in-game when changes are made automatically? If you are experiencing crashing issues, disable this" )

local function InitializeBase()
	if not wOS.DynaBase.InitCompleted then
		hook.Call( "InitLoadAnimations" )
	end
    wOS.DynaBase:ProcessLoadOrder()
	wOS.DynaBase:ReloadAnimations()

	if SERVER then
		if wOS.DynaBase.InitCompleted and not WOS_DYNABASE_SHOULDHOTLOAD_CVAR:GetBool() then return end
		RunConsoleCommand( "r_flushlod" )
	end

	wOS.DynaBase.InitCompleted = true
end

local function HandleMountOrderList( args )
    if not args or #args < 1 then 
		wOS.DynaBase.EnforceCount = 0
		wOS.DynaBase.EnforcedOrder = nil 
		return 
	end

	wOS.DynaBase.EnforcedOrder = {}
    wOS.DynaBase.EnforceCount = 0

	local tbl = string.Explode( ",", args )
	for _, arg in ipairs( tbl ) do
		if table.HasValue( wOS.DynaBase.EnforcedOrder, arg ) then continue end
		wOS.DynaBase.EnforceCount = wOS.DynaBase.EnforceCount + 1
		wOS.DynaBase.EnforcedOrder[ wOS.DynaBase.EnforceCount ] = arg
	end
end

cvars.AddChangeCallback("wos_dynabase_mountorder", function(_, oldargs, args)

	if SERVER then
		net.Start( "wOS.DynaBase.ForceMountCallback" )
			net.WriteString( oldargs )
			net.WriteString( args )
		net.Broadcast()
	end

	HandleMountOrderList( args )

    if not WOS_DYNABASE_LOADORDERENFORCE_CVAR:GetBool() then return end
	InitializeBase()
    wOS.DynaBase.InitCompleted = true
end)

hook.Add( "CreateTeams", "wOS.DynaBase.InitLoadAnimations", function()
	if wOS.DynaBase.InitCompleted then return end
	if WOS_DYNABASE_LOADORDERENFORCE_CVAR:GetBool() then
		HandleMountOrderList( WOS_DYNABASE_MOUNTORDERLIST_CVAR:GetString() )
	end
	InitializeBase()
end )

function wOS.DynaBase:RegisterSource( data )
	if not data then return end
	if not data.Name then return end
	self.Registers[ data.Name ] = data
	self.RegisterCount = self.RegisterCount + 1

	print( "[wOS-DynaBase] Registered new animation source: " .. data.Name )

	if data.PreventActivities then
		self:FixActivities( data )
	end

	if CLIENT then
		if data.IconOverwrite then
			self.Registers[ data.Name ].IconOverwrite = Material( data.IconOverwrite, "unlitgeneric" )
		end
		return
	end

	if not self.InitCompleted then return end
	net.Start( "wOS.DynaBase.SendRegister" )
		net.WriteString( data.Name )
	net.Broadcast()
end

function wOS.DynaBase:ProcessLoadOrder()
	if self.EnforceCount < 1 then self.FilteredLoadOrder = {} return end

	// Initialize it here so it can fail later
	self.FilteredLoadOrder[ WOS_DYNABASE.MALE ] = {}
	self.FilteredLoadOrder[ WOS_DYNABASE.FEMALE ] = {}
	self.FilteredLoadOrder[ WOS_DYNABASE.ZOMBIE ] = {}
	self.FilteredLoadOrder[ WOS_DYNABASE.SHARED ] = {}

	for _, name in ipairs( self.EnforcedOrder ) do
		local data = self:GetSource( name )
		if not data then continue end

		if data.Shared then
			table.insert( self.FilteredLoadOrder[ WOS_DYNABASE.SHARED ], data.Shared )
		end

		if data.Male then
			table.insert( self.FilteredLoadOrder[ WOS_DYNABASE.MALE ], data.Male )
		end

		if data.Female then
			table.insert( self.FilteredLoadOrder[ WOS_DYNABASE.FEMALE ], data.Female )
		end

		if data.Zombie then
			table.insert( self.FilteredLoadOrder[ WOS_DYNABASE.ZOMBIE ], data.Zombie )
		end
	end
end

function wOS.DynaBase:ProcessPlayerOrder()
	if self.PlayerCount < 1 then 
		self.FilteredPlayerBlacklist = {} 
		self.FilteredPlayerOrder = {} 
		return 
	end

	// Initialize it here so it can fail later
	self.FilteredPlayerOrder[ WOS_DYNABASE.MALE ] = {}
	self.FilteredPlayerOrder[ WOS_DYNABASE.FEMALE ] = {}
	self.FilteredPlayerOrder[ WOS_DYNABASE.ZOMBIE ] = {}
	self.FilteredPlayerOrder[ WOS_DYNABASE.SHARED ] = {}

	self.FilteredPlayerBlacklist[ WOS_DYNABASE.MALE ] = {}
	self.FilteredPlayerBlacklist[ WOS_DYNABASE.FEMALE ] = {}
	self.FilteredPlayerBlacklist[ WOS_DYNABASE.ZOMBIE ] = {}
	self.FilteredPlayerBlacklist[ WOS_DYNABASE.SHARED ] = {}

	for _, dt in ipairs( self.PlayerOrder ) do
		local name = dt.Name
		local data = self:GetSource( name )
		if not data then continue end

		if data.Shared then
			table.insert( ( !dt.Toggled and self.FilteredPlayerBlacklist[ WOS_DYNABASE.SHARED ] ) or self.FilteredPlayerOrder[ WOS_DYNABASE.SHARED ], data.Shared )
		end

		if data.Male then
			table.insert( ( !dt.Toggled and self.FilteredPlayerBlacklist[ WOS_DYNABASE.MALE ] ) or self.FilteredPlayerOrder[ WOS_DYNABASE.MALE ], data.Male )
		end

		if data.Female then
			table.insert( ( !dt.Toggled and self.FilteredPlayerBlacklist[ WOS_DYNABASE.FEMALE ] ) or self.FilteredPlayerOrder[ WOS_DYNABASE.FEMALE ], data.Female )
		end

		if data.Zombie then
			table.insert( ( !dt.Toggled and self.FilteredPlayerBlacklist[ WOS_DYNABASE.ZOMBIE ] ) or self.FilteredPlayerOrder[ WOS_DYNABASE.ZOMBIE ], data.Zombie )
		end
	end
end

function wOS.DynaBase:GetSourceCount()
	return self.RegisterCount
end

function wOS.DynaBase:GetAllSources()
	return self.Registers
end

function wOS.DynaBase:GetSource( name )
	return self.Registers[ name ]
end


// Need to register the base stuff LMAO
wOS.DynaBase:RegisterSource({
	Name = "Base Animations",
	Type = WOS_DYNABASE.REANIMATION,
	IconOverwrite = "wos/dynabase/gmod.png",
	Core = true,
	Male = "models/m_wos.mdl",
	Female = "models/f_wos.mdl",
	Zombie = "models/z_wos.mdl",
})

wOS.DynaBase:RegisterSource({
	Name = "Local Player Animations",
	Type = WOS_DYNABASE.REANIMATION,
	IconOverwrite = "wos/dynabase/local.png",
	Core = true,
	Male = "data/wos/dynabase/local_male" .. WOS_DYNABASE_FILE_EXTENSION,
	Female = "data/wos/dynabase/local_female" .. WOS_DYNABASE_FILE_EXTENSION,
	Zombie = "data/wos/dynabase/local_zombie" .. WOS_DYNABASE_FILE_EXTENSION,
	Shared = "data/wos/dynabase/local_shared" .. WOS_DYNABASE_FILE_EXTENSION,
})
