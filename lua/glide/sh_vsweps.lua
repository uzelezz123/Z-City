--[[
    Validate and load Vehicle Scripted Weapons (VSWEPS).
    Thanks you kirillbrest123, for the idea and code snippets to achieve this.
]]

if SERVER then
    -- Sent all client lua files right away.
    -- (Don't include, but do AddCSLuaFile)
    Glide.IncludeDir( "glide/vsweps/", false, true )
end

Glide.WeaponRegistry = Glide.WeaponRegistry or {}

function Glide.CreateVehicleWeapon( className, data )
    local class = Glide.WeaponRegistry[className]
    assert( class, "Tried to create invalid weapon class: " .. className )

    return setmetatable( data or {}, { __index = class } )
end

local function ValidateTableKey( tbl, key, expectedType )
    local value = tbl[key]

    if value == nil then
        return
    end

    local actualType = type( value )

    assert( actualType == expectedType, "Invalid type for property '" .. key ..
        "' (expected a " .. expectedType .. ", but got a " .. actualType .. ")" )
end

local function RunWeaponScript( path, className )
    local func = CompileFile( path )
    if not func then
        Glide.Print( "Failed to load vehicle weapon script '%s'!", className )
        return
    end
    func()

    -- Set ClassName field
    VSWEP.ClassName = className

    -- Validate client properties
    if CLIENT then
        ValidateTableKey( VSWEP, "Name", "string" )
        ValidateTableKey( VSWEP, "Icon", "string" )
    end

    -- Validate server properties
    if SERVER then
        ValidateTableKey( VSWEP, "FireDelay", "number" )
        ValidateTableKey( VSWEP, "ReloadDelay", "number" )
        ValidateTableKey( VSWEP, "EnableLockOn", "boolean" )
        ValidateTableKey( VSWEP, "LockOnTimeMultiplier", "number" )

        ValidateTableKey( VSWEP, "Spread", "number" )
        ValidateTableKey( VSWEP, "Damage", "number" )
        ValidateTableKey( VSWEP, "TracerScale", "number" )

        ValidateTableKey( VSWEP, "MaxAmmo", "number" )
        ValidateTableKey( VSWEP, "AmmoType", "string" )
        ValidateTableKey( VSWEP, "AmmoTypeShareCapacity", "boolean" )
        ValidateTableKey( VSWEP, "ProjectileOffsets", "table" )
        ValidateTableKey( VSWEP, "SingleShotSound", "string" )
    end
end

local function RefreshInheritance( className )
    -- Ignore the "root" weapon class
    if className == "base" then return end

    -- Validate base weapon class name
    local class = Glide.WeaponRegistry[className]
    local baseClassName = class.Base

    if type( baseClassName ) ~= "string" then
        ErrorNoHalt( className .. ": Invalid base class type! (string expected, got " .. type( baseClassName ) .. ")" )
        return
    end

    -- Make sure base weapon class exists
    local baseClass = Glide.WeaponRegistry[baseClassName]

    if baseClass == nil then
        ErrorNoHalt( className .. ": Invalid base class: " .. baseClassName )
        return
    end

    -- Add a shortcut to access the base class metatable more easily
    class.BaseClass = baseClass

    -- Make this VSWEP use another as it's metatable
    setmetatable( class, { __index = baseClass } )
end

function Glide.ReloadWeaponScript( className )
    local path = "glide/vsweps/" .. className .. ".lua"

    if not file.Exists( path, "LUA" ) then
        Glide.Print( "Vehicle weapon script '%s' does not exist!", className )
        return
    end

    Glide.PrintDev( "Reloading vehicle weapon script '%s'", className )

    local registry = Glide.WeaponRegistry

    -- If this class is on the registry already...
    if registry[className] then
        -- Use it as the VSWEP table
        VSWEP = registry[className]
    else
        -- Otherwise create a new VSWEP table
        VSWEP = {}
    end

    -- Run and validate code
    local success = ProtectedCall( RunWeaponScript, path, className )
    if success then
        registry[className] = VSWEP
    else
        Glide.Print( "Failed to load vehicle weapon script '%s'!", className )
    end

    VSWEP = nil
end

-- Only include weapons after everything else has loaded.
function Glide.InitializeVSWEPS()
    -- Include all lua files inside lua/glide/vsweps/
    local files = file.Find( "glide/vsweps/*.lua", "LUA" )

    for _, fileName in ipairs( files ) do
        Glide.ReloadWeaponScript( string.StripExtension( fileName ) )
    end

    -- Update the class inheritance for all weapons.
    -- This is done AFTER all weapon scripts are loaded, to prevent a race condition
    -- where a weapon would try to use another as a base before it was loaded.
    for className, _ in pairs( Glide.WeaponRegistry ) do
        RefreshInheritance( className )
    end
end

--[[
    Server-side command to reload VSWEP code
]]

if CLIENT then
    return
end

local function CmdReloadWeaponScript( ply, _, args )
    if not ply:IsSuperAdmin() then
        Glide.Print( "You must be a super admin to run this." )
        return
    end

    local classToReload = args[1]

    if type( classToReload ) ~= "string" then
        Glide.Print( "Please give one of the weapon script class names:" )

        for class, _ in pairs( Glide.WeaponRegistry ) do
            Glide.Print( class )
        end

        return
    end

    Glide.ReloadWeaponScript( classToReload )
    RefreshInheritance( classToReload )

    Glide.StartCommand( Glide.CMD_RELOAD_VSWEP, false )
    net.WriteString( classToReload )
    net.Broadcast()
end

local function AutoCompleteCmdReloadWeaponScript( cmd, _, args )
    if #args > 1 then return end

    local partialClass = args[1] and string.Trim( args[1] ) or nil

    if partialClass and partialClass:len() == 0 then
        partialClass = nil
    end

    local files = file.Find( "glide/vsweps/*.lua", "LUA" )
    local filtered = {}

    for _, fileName in ipairs( files ) do
        if not partialClass or string.StartsWith( fileName, partialClass ) then
            filtered[#filtered + 1] = cmd .. " " .. string.StripExtension( fileName )
        end
    end

    return filtered
end

concommand.Add( "glide_reload_weapon_script", CmdReloadWeaponScript, AutoCompleteCmdReloadWeaponScript,
    "Given a Glide weapon script class, this command will reload the code from disk on both the server and client." )
