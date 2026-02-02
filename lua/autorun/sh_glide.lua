Glide = Glide or {}

-- Vehicle types
Glide.VEHICLE_TYPE = {
    UNDEFINED = 0,
    CAR = 1,
    MOTORCYCLE = 2,
    HELICOPTER = 3,
    PLANE = 4,
    TANK = 5,
    BOAT = 6
}

-- Max. seats a single vehicle can have
Glide.MAX_SEATS = 10

-- Explosions are only transmitted to nearby players
Glide.MAX_EXPLOSION_DISTANCE = 15000

-- Explosion types
Glide.EXPLOSION_TYPE = {
    MISSILE = 0,
    VEHICLE = 1,
    TURRET = 2
}

-- Used to notify clients about incoming lock-on/missiles
Glide.DANGER_TYPE = {
    LOCK_ON = 1,
    MISSILE = 2
}

-- Enable lock-on for these entity classes
Glide.LOCKON_WHITELIST = {
    ["base_glide"] = true,
    ["base_glide_car"] = true,
    ["base_glide_tank"] = true,
    ["base_glide_aircraft"] = true,
    ["base_glide_heli"] = true,
    ["base_glide_plane"] = true,
    ["base_glide_boat"] = true,
    ["base_glide_motorcycle"] = true,
    ["prop_vehicle_prisoner_pod"] = true
}

-- Mouse flying control modes
Glide.MOUSE_FLY_MODE = {
    AIM = 0,        -- Point-to-aim
    DIRECT = 1,     -- Control movement directly
    CAMERA = 2      -- Free camera
}

-- Mouse steering control modes
Glide.MOUSE_STEER_MODE = {
    DISABLED = 0,   -- Use keyboard only
    AIM = 1,        -- Steer towards aim direction
    DIRECT = 2      -- Control movement directly
}

-- Default color for vehicle lights
Glide.DEFAULT_HEADLIGHT_COLOR = Color( 255, 231, 176 )
Glide.DEFAULT_TURN_SIGNAL_COLOR = Color( 255, 164, 45 )
Glide.DEFAULT_SIREN_COLOR_A = Color( 255, 0, 0 )
Glide.DEFAULT_SIREN_COLOR_B = Color( 0, 0, 255 )

if SERVER then
    -- Surface grip multipliers for wheels
    Glide.SURFACE_GRIP = {
        [MAT_DIRT] = 0.9,
        [MAT_SNOW] = 0.8,
        [MAT_SAND] = 0.9,
        [MAT_FOLIAGE] = 0.9,
        [MAT_SLOSH] = 0.8,
        [MAT_GRASS] = 0.9,
        [MAT_GLASS] = 0.9
    }

    -- Surface rolling resistance multipliers for wheels
    Glide.SURFACE_RESISTANCE = {
        [MAT_DIRT] = 0.2,
        [MAT_SAND] = 0.2,
        [MAT_SNOW] = 0.2,
        [MAT_GRASS] = 0.15,
        [MAT_FOLIAGE] = 0.15
    }
end

if CLIENT then
    Glide.THEME_COLOR = Color( 56, 113, 179 )

    -- Vehicle camera types
    Glide.CAMERA_TYPE = {
        CAR = 0,
        TURRET = 1,
        AIRCRAFT = 2
    }

    -- Surfaces that can generate tire roll marks
    Glide.ROLL_MARK_SURFACES = {
        [MAT_DIRT] = true,
        [MAT_SNOW] = true,
        [MAT_SAND] = true,
        [MAT_FOLIAGE] = true,
        [MAT_GRASS] = true
    }

    -- Wheel surface sounds
    Glide.WHEEL_SOUNDS = {}

    Glide.WHEEL_SOUNDS.ROLL_VOLUME = {
        [MAT_METAL] = 1,
        [MAT_GRATE] = 1,
        [MAT_WOOD] = 1,
        [MAT_SNOW] = 0.7
    }

    Glide.WHEEL_SOUNDS.ROLL = {
        [MAT_DIRT] = "glide/wheels/roll_dirt.wav",
        [MAT_GRATE] = "glide/wheels/roll_metal.wav",
        [MAT_SNOW] = "glide/wheels/roll_dirt.wav",
        [MAT_PLASTIC] = "physics/plastic/plastic_barrel_scrape_rough_loop1.wav",
        [MAT_METAL] = "glide/wheels/roll_metal.wav",
        [MAT_SAND] = "glide/wheels/roll_dirt.wav",
        [MAT_FOLIAGE] = "glide/wheels/roll_dirt.wav",
        [MAT_SLOSH] = "glide/wheels/roll_road_wet.wav",
        [MAT_GRASS] = "glide/wheels/roll_dirt.wav",
        [MAT_VENT] = "ambient/machines/wall_ambient_loop1.wav",
        [MAT_WOOD] = "glide/wheels/roll_wood.wav"
    }

    Glide.WHEEL_SOUNDS.ROLL_SLOW = {
        [MAT_DEFAULT] = "glide/wheels/roll_road_slow.wav",
        [MAT_CONCRETE] = "glide/wheels/roll_road_slow.wav",
        [MAT_TILE] = "glide/wheels/roll_road_slow.wav",
        [MAT_GRASS] = "glide/wheels/roll_dirt_slow.wav",
        [MAT_DIRT] = "glide/wheels/roll_dirt_slow.wav",
        [MAT_SAND] = "glide/wheels/roll_dirt_slow.wav",
        [MAT_SNOW] = "glide/wheels/roll_dirt_slow.wav"
    }

    Glide.WHEEL_SOUNDS.SIDE_SLIP = {
        [MAT_DEFAULT] = "glide/wheels/side_skid_road_1.wav",
        [MAT_CONCRETE] = "glide/wheels/side_skid_road_1.wav",
        [MAT_TILE] = "glide/wheels/side_skid_road_1.wav",
        [MAT_DIRT] = "glide/wheels/side_skid_dirt.wav",
        [MAT_SNOW] = "physics/body/body_medium_scrape_smooth_loop1.wav",
        [MAT_PLASTIC] = "physics/plastic/plastic_barrel_scrape_smooth_loop1.wav",
        [MAT_SAND] = "physics/body/body_medium_scrape_rough_loop1.wav",
        [MAT_FOLIAGE] = "physics/cardboard/cardboard_box_scrape_rough_loop1.wav",
        [MAT_SLOSH] = "glide/wheels/side_skid_road_wet.wav",
        [MAT_GRASS] = "glide/wheels/side_skid_dirt.wav",
        [MAT_VENT] = "physics/metal/metal_box_scrape_smooth_loop1.wav",
        [MAT_WOOD] = "glide/wheels/side_skid_road_1.wav",
        [MAT_GLASS] = "physics/metal/metal_grenade_scrape_rough_loop1.wav"
    }

    Glide.WHEEL_SOUNDS.FORWARD_SLIP = {
        [MAT_DEFAULT] = "glide/wheels/torque_skid_road.wav",
        [MAT_DIRT] = "physics/body/body_medium_scrape_smooth_loop1.wav",
        [MAT_SNOW] = "physics/body/body_medium_scrape_smooth_loop1.wav",
        [MAT_PLASTIC] = "physics/plastic/plastic_barrel_scrape_smooth_loop1.wav",
        [MAT_SAND] = "physics/body/body_medium_scrape_rough_loop1.wav",
        [MAT_FOLIAGE] = "physics/cardboard/cardboard_box_scrape_rough_loop1.wav",
        [MAT_SLOSH] = "glide/wheels/side_skid_road_wet.wav",
        [MAT_GRASS] = "physics/body/body_medium_scrape_smooth_loop1.wav",
        [MAT_VENT] = "physics/metal/metal_box_scrape_smooth_loop1.wav",
        [MAT_WOOD] = "glide/wheels/side_skid_wood.wav",
        [MAT_GLASS] = "physics/metal/metal_grenade_scrape_rough_loop1.wav"
    }
end

if SERVER then
    -- Damage multiplier convars
    CreateConVar( "glide_bullet_damage_multiplier", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Damage multiplier for bullets hitting Glide vehicles.", 0, 10 )
    CreateConVar( "glide_blast_damage_multiplier", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Damage multiplier for explosions hitting Glide vehicles.", 0, 10 )
    CreateConVar( "glide_physics_damage_multiplier", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Damage multiplier taken by Glide vehicles after colliding against things that are not the world.", 0, 10 )
    CreateConVar( "glide_world_physics_damage_multiplier", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Damage multiplier taken by Glide vehicles after colliding against the world.", 0, 10 )
end

-- Toggles
CreateConVar( "glide_pacifist_mode", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "When set to 1, disables VSWEPs and vehicle turrets.", 0, 1 )
CreateConVar( "glide_allow_gravity_gun_punt", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "When set to 1, allows players to push vehicles with the Gravity Gun.", 0, 1 )

-- Sandbox limits
cleanup.Register( "glide_vehicles" )
cleanup.Register( "glide_standalone_turrets" )
cleanup.Register( "glide_missile_launchers" )
cleanup.Register( "glide_projectile_launchers" )

CreateConVar( "sbox_maxglide_vehicles", "5", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Max. number of Glide vehicles that one player can have", 0 )
CreateConVar( "sbox_maxglide_standalone_turrets", "5", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Max. number of Glide Turrets that one player can have", 0 )
CreateConVar( "sbox_maxglide_missile_launchers", "5", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Max. number of Glide Missile Launchers that one player can have", 0 )
CreateConVar( "sbox_maxglide_projectile_launchers", "5", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Max. number of Glide Projectile Launchers that one player can have", 0 )
CreateConVar( "sbox_maxglide_engine_stream_chips", "3", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Max. number of Glide Engine Stream Chips that one player can have", 0 )

-- Turret tool convars
CreateConVar( "glide_turret_explosive_allow", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Allows Glide Turrets to use explosive bullets.", 0, 1 )
CreateConVar( "glide_turret_max_damage", "50", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum damage dealt per bullet for Glide Turrets.", 0 )
CreateConVar( "glide_turret_min_delay", "0.02", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Minimum delay allowed for Glide Turrets.", 0, 1 )

-- Missile launcher tool convars
CreateConVar( "glide_missile_launcher_min_delay", "0.5", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Minimum delay allowed for Glide Missile Launchers.", 0.1, 5 )
CreateConVar( "glide_missile_launcher_max_lifetime", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum missile flight time allowed for Glide Missile Launchers.", 1 )
CreateConVar( "glide_missile_launcher_max_radius", "500", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum radius from explosions created by Glide Missile Launchers.", 10 )
CreateConVar( "glide_missile_launcher_max_damage", "200", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum damage dealt by explosions from Glide Missile Launchers.", 1 )

-- Projectile launcher tool convars
CreateConVar( "glide_projectile_launcher_min_delay", "0.5", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Minimum delay allowed for Glide Projectile Launchers.", 0.1, 5 )
CreateConVar( "glide_projectile_launcher_max_lifetime", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum projectile flight time allowed for Glide Projectile Launchers.", 1 )
CreateConVar( "glide_projectile_launcher_max_radius", "500", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum radius from explosions created by Glide Projectile Launchers.", 10 )
CreateConVar( "glide_projectile_launcher_max_damage", "200", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum damage dealt by explosions from Glide Projectile Launchers.", 1 )

-- Gib convars
CreateConVar( "glide_gib_lifetime", "8", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Lifetime of Glide Gibs, 0 for no despawning.", 0 )
CreateConVar( "glide_gib_enable_collisions", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "When set to 0, gibs wont collide with players/props.", 0, 1 )

-- Ragdoll convars
CreateConVar( "glide_ragdoll_enable", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "When set to 0, players will not be ragdolled when unsuccessfully falling out of vehicles.", 0, 1 )
CreateConVar( "glide_ragdoll_max_time", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "The max. amount of time a player can stay ragdolled. Set to 0 for infinite.", 0 )

list.Set( "ContentCategoryIcons", "Glide", "materials/glide/icons/car.png" )

do
    local COLOR_TAG = Color( 255, 255, 255 )
    local COLOR_SV = Color( 3, 169, 244 )
    local COLOR_CL = Color( 222, 169, 9 )

    function Glide.Print( str, ... )
        MsgC( COLOR_TAG, "[", SERVER and COLOR_SV or COLOR_CL, "Glide", COLOR_TAG, "] ", string.format( str, ... ), "\n" )
    end
end

do
    local isDeveloperActive = false

    function Glide.GetDevMode()
        return isDeveloperActive
    end

    -- Using `cvars.AddChangeCallback` was unreliable serverside,
    -- so we will check it periodically instead.
    local cvarDeveloper = GetConVar( "developer" )
    isDeveloperActive = cvarDeveloper:GetBool()

    timer.Create( "Glide.CheckDeveloperConvar", 1, 0, function()
        isDeveloperActive = cvarDeveloper:GetBool()
    end )
end

function Glide.PrintDev( str, ... )
    if Glide.GetDevMode() then
        Glide.Print( str, ... )
    end
end

function Glide.ValidateNumber( v, min, max, default )
    return math.Clamp( tonumber( v ) or default, min, max )
end

function Glide.SetNumber( t, k, v, min, max, default )
    t[k] = Glide.ValidateNumber( v, min, max, default )
end

function Glide.ToJSON( t, prettyPrint )
    return util.TableToJSON( t, prettyPrint )
end

function Glide.FromJSON( s )
    if type( s ) ~= "string" or s == "" then
        return {}
    end

    return util.JSONToTable( s ) or {}
end

function Glide.LoadDataFile( path )
    return file.Read( path, "DATA" )
end

function Glide.SaveDataFile( path, data )
    Glide.Print( "%s: writing %s", path, string.NiceSize( string.len( data ) ) )
    file.Write( path, data )
end

do
    local EntityMeta = FindMetaTable( "Entity" )
    local IsVehicle = EntityMeta.IsVehicle

    --- Override `Entity:IsVehicle` to return `true` on Glide vehicles.
    function EntityMeta:IsVehicle()
        return self.IsGlideVehicle or IsVehicle( self )
    end
end

function Glide.IncludeDir( dirPath, doInclude, doTransfer )
    local files = file.Find( dirPath .. "*.lua", "LUA" )
    local path

    for _, fileName in ipairs( files ) do
        path = dirPath .. fileName

        if doInclude then
            Glide.PrintDev( "Including file: %s", path )
            include( path )
        end

        if doTransfer then
            AddCSLuaFile( path )
        end
    end
end

if SERVER then
    resource.AddWorkshop( "3389728250" )

    -- Shared files
    Glide.IncludeDir( "glide/", true, true )

    -- Server-only files
    Glide.IncludeDir( "glide/server/", true, false )

    -- Client-only files
    AddCSLuaFile( "includes/modules/styled_theme.lua" )
    AddCSLuaFile( "includes/modules/styled_theme_tabbed_frame.lua" )
    AddCSLuaFile( "includes/modules/styled_theme_file_browser.lua" )

    Glide.IncludeDir( "glide/client/", false, true )
    Glide.IncludeDir( "glide/client/vgui/", false, true )
end

if CLIENT then
    -- Shared files
    Glide.IncludeDir( "glide/", true, false )

    -- UI theme library
    require( "styled_theme" )
    require( "styled_theme_tabbed_frame" )
    require( "styled_theme_file_browser" )

    StyledTheme.RegisterFont( "GlideSelectedWeapon", 0.018, {
        font = "Roboto",
        weight = 500,
    } )

    StyledTheme.RegisterFont( "GlideNotification", 0.022, {
        font = "Roboto",
        weight = 500,
    } )

    StyledTheme.RegisterFont( "GlideHUD", 0.022, {
        font = "Roboto",
        weight = 400,
    } )

    -- Client-only files
    Glide.IncludeDir( "glide/client/", true, false )
    Glide.IncludeDir( "glide/client/vgui/", true, false )
end

-- Automatically include files under
-- `lua/glide/autoload/`, on both server and client.
Glide.IncludeDir( "glide/autoload/", true, true )

Glide.InitializeVSWEPS()
