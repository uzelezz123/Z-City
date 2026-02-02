function Glide.HasBaseClass( ent, class )
    local depth = 0
    local base = ent.BaseClass

    while depth < 10 do
        if base and base.ClassName == class then
            return true
        end

        depth = depth + 1

        if base then
            base = base.BaseClass
        else
            break
        end
    end

    return false
end

--- Hides entity, without preventing the entity from being
--- transmitted (like how ENT:SetNoDraw does).
function Glide.HideEntity( ent, hide )
    ent.GlideIsHidden = Either( hide, true, nil )
    ent:SetRenderMode( hide and RENDERMODE_NONE or RENDERMODE_NORMAL )
    ent:SetColor( Color( 255, 255, 255, hide and 0 or 255 ) )

    if hide then
        ent:AddEffects( EF_NOSHADOW )
    else
        ent:RemoveEffects( EF_NOSHADOW )
    end
end

function Glide.IsAircraft( vehicle )
    return vehicle.VehicleType == Glide.VEHICLE_TYPE.HELICOPTER or vehicle.VehicleType == Glide.VEHICLE_TYPE.PLANE
end

function Glide.IsValidModel( model )
    if type( model ) ~= "string" then
        return false
    end

    if model:sub( -4, -1 ) ~= ".mdl" then
        return false
    end

    if not file.Exists( model, "GAME" ) then
        return false
    end

    return true
end

do
    local Band = bit.band
    local PointContents = util.PointContents

    local CONTENTS_SLIME = CONTENTS_SLIME
    local CONTENTS_WATER = CONTENTS_WATER

    function Glide.IsUnderWater( pos )
        local contents = PointContents( pos )

        return Band( contents, CONTENTS_SLIME ) == CONTENTS_SLIME or
            Band( contents, CONTENTS_WATER ) == CONTENTS_WATER
    end
end

do
    local Exp = math.exp

    --- If you ever need `Lerp()`, use this instead.
    --- `Lerp()` is not consistent on different framerates, this is.
    function Glide.ExpDecay( a, b, decay, dt )
        return b + ( a - b ) * Exp( -decay * dt )
    end
end

do
    local function AngleDifference( a, b )
        return ( ( ( ( b - a ) % 360 ) + 540 ) % 360 ) - 180
    end

    Glide.AngleDifference = AngleDifference

    local ExpDecay = Glide.ExpDecay

    function Glide.ExpDecayAngle( a, b, decay, dt )
        return ExpDecay( a, a + AngleDifference( a, b ), decay, dt )
    end
end

do
    local TraceLine = util.TraceLine

    local ray = {}
    local traceData = { mask = MASK_WATER, output = ray }
    local offset = Vector()

    function Glide.FindWaterSurfaceAbove( origin, maxHeight )
        offset[3] = maxHeight or 100

        traceData.start = origin + offset
        traceData.endpos = origin
        TraceLine( traceData )

        if ray.Hit then
            return ray.HitPos, ray.Fraction
        end
    end
end

do
    local pacifistModeCvar = GetConVar( "glide_pacifist_mode" )
    local HookRun = hook.Run

    --- Called by various weapon systems to check
    --- if a player can use a vehicle VSWEP/turret.
    function Glide.CanUseWeaponry( ply )
        if pacifistModeCvar:GetBool() then
            return false
        end

        if HookRun( "Glide_CanUseWeaponry", ply ) == false then
            return false
        end

        return true
    end
end

if CLIENT then
    function Glide.GetLanguageText( id )
        return language.GetPhrase( "glide." .. id )
    end

    local lastViewPos = Vector()
    local lastViewAng = Angle()

    --- Get the cached position/angle of the local player's render view.
    function Glide.GetLocalViewLocation()
        return lastViewPos, lastViewAng
    end

    local EyePos = EyePos
    local EyeAngles = EyeAngles

    -- `PreDrawEffects` seems like a good place to get values from EyePos/EyeAngles reliably.
    -- `PreDrawOpaqueRenderables`/`PostDrawOpaqueRenderables` were being called
    -- twice when there was water, and `PreRender`/`PostRender`
    -- were causing `EyeAngles` to return incorrect angles.
    hook.Add( "PreDrawEffects", "Glide.CachePlayerView", function( bDepth, bSkybox, b3DSkybox )
        if bDepth or bSkybox or b3DSkybox then return end

        lastViewPos = EyePos()
        lastViewAng = EyeAngles()
    end )
end

do
    -- Custom iterator, similar to ipairs, but made to iterate
    -- over a table of entities, while skipping NULL entities.
    local NULL = NULL
    local e

    local function EntIterator( array, i )
        i = i + 1
        e = array[i]

        while e == NULL do
            i = i + 1
            e = array[i]
        end

        if e then
            return i, e
        end
    end

    function Glide.EntityPairs( array )
        return EntIterator, array, 0
    end
end

do
    -- Transmission gears/ratios validator
    Glide.MAX_GEAR = 20
    Glide.MAX_GEAR_RATIO = 20.0

    local Clamp = math.Clamp

    function Glide.ClampGearRatio( ratio )
        return Clamp( ratio, 0.05, Glide.MAX_GEAR_RATIO )
    end

    local Type = type
    local ClampGearRatio = Glide.ClampGearRatio

    function Glide.ValidateTransmissionData( data )
        local cleanData = {
            [0] = 0 -- Neutral, this value does nothing
        }

        -- Check if the data has a valid reverse ratio
        if Type( data[-1] ) == "number" then
            cleanData[-1] = ClampGearRatio( data[-1] )
        end

        -- Check if the data has sequential indexes
        local index = 0
        local max = Glide.MAX_GEAR

        while index < max do
            index = index + 1

            if Type( data[index] ) == "number" then
                cleanData[index] = ClampGearRatio( data[index] )
            else
                break
            end
        end

        return cleanData
    end
end

do
    -- Utility function to make sure a entity is a Glide vehicle
    -- that supports the "glide_engine_stream" modifier.
    local SUPPORTED_VEHICLE_TYPES = {
        [Glide.VEHICLE_TYPE.CAR] = true,
        [Glide.VEHICLE_TYPE.MOTORCYCLE] = true,
        [Glide.VEHICLE_TYPE.TANK] = true,
        [Glide.VEHICLE_TYPE.BOAT] = true
    }

    function Glide.DoesEntitySupportEngineStreamPreset( ent )
        if not IsValid( ent ) then
            return false
        end

        if ent:GetClass() == "glide_engine_stream_chip" then
            return true
        end

        return ent.IsGlideVehicle and SUPPORTED_VEHICLE_TYPES[ent.VehicleType]
    end
end

do
    -- Utility function to make sure a entity is a Glide vehicle
    -- that supports the "glide_misc_sounds" modifier.
    local SUPPORTED_VEHICLE_TYPES = {
        [Glide.VEHICLE_TYPE.CAR] = true,
        [Glide.VEHICLE_TYPE.MOTORCYCLE] = true,
        [Glide.VEHICLE_TYPE.BOAT] = true
    }

    function Glide.DoesEntitySupportMiscSoundsPreset( ent )
        return IsValid( ent ) and ent.IsGlideVehicle and SUPPORTED_VEHICLE_TYPES[ent.VehicleType]
    end
end

-- Max. Engine Stream layers
Glide.MAX_STREAM_LAYERS = 8

-- Default Engine Stream parameters
local DEFAULT_STREAM_PARAMS = {
    pitch = 1,
    volume = 1,
    fadeDist = 1500,

    redlineFrequency = 55,
    redlineStrength = 0.2,

    wobbleFrequency = 25,
    wobbleStrength = 0.13
}

Glide.DEFAULT_STREAM_PARAMS = DEFAULT_STREAM_PARAMS

local STREAM_KV_LIMITS = {
    pitch = { min = 0.5, max = 2, decimals = 2 },
    volume = { min = 0.1, max = 2, decimals = 2 },
    fadeDist = { min = 500, max = 4000, decimals = 0 },

    redlineFrequency = { min = 30, max = 70, decimals = 0 },
    redlineStrength = { min = 0, max = 0.5, decimals = 2 },

    wobbleFrequency = { min = 10, max = 70, decimals = 0 },
    wobbleStrength = { min = 0.0, max = 1.0, decimals = 2 }
}

Glide.STREAM_KV_LIMITS = STREAM_KV_LIMITS

function Glide.ValidateStreamData( data )
    if type( data ) ~= "table" then
        return false, "Preset is not a table!"
    end

    local keyValues = data.kv

    if keyValues then
        if type( keyValues ) ~= "table" then
            return false, "Preset does not have valid key-value data!"
        end

        for k, v in pairs( keyValues ) do
            if not DEFAULT_STREAM_PARAMS[k] or type( v ) ~= "number" then
                data[k] = nil -- If invalid, just remove KV pair
            end

            local limits = STREAM_KV_LIMITS[k]

            if limits and data[k] then
                data[k] = math.Clamp( math.Round( data[k], limits.decimals ), limits.min, limits.max )
            end
        end
    end

    local layers = data.layers

    if type( layers ) ~= "table" then
        return false, "Preset does not have valid layer data!"
    end

    local p, c
    local count, max = 0, Glide.MAX_STREAM_LAYERS

    for id, layer in pairs( layers ) do
        if type( layer ) ~= "table" then
            return false, "Preset does not look like sound preset data!"
        end

        p = layer.path
        c = layer.controllers

        if
            type( id ) ~= "string" or
            type( p ) ~= "string" or
            type( c ) ~= "table"
        then
            return false, "Preset does not look like sound preset data!"
        end

        count = count + 1

        if count >= max then
            return false, "Preset data has too many layers!"
        end
    end

    return true
end

-- Misc. sound categories
Glide.MISC_SOUND_CATEGORIES = {
    {
        label = "#tool.glide_misc_sounds.category.engine",
        acceptGlideSoundPresets = true,
        keys = {
            "StartSound",
            "StartTailSound",
            "StartedSound",
            "StoppedSound",
            "ExhaustPopSound"
        }
    },
    {
        label = "#tool.glide_misc_sounds.category.alarms",
        acceptGlideSoundPresets = false,
        keys = {
            "HornSound",
            "ReverseSound",
            "SirenLoopSound"
        }
    },
    {
        label = "#tool.glide_misc_sounds.category.turbo",
        acceptGlideSoundPresets = false,
        keys = {
            "TurboLoopSound",
            "TurboBlowoffSound"
        }
    },
    {
        label = "#tool.glide_misc_sounds.category.brakes",
        acceptGlideSoundPresets = false,
        keys = {
            "BrakeReleaseSound",
            "BrakeSqueakSound"
        }
    }
}

function Glide.GetAllMiscSoundKeys()
    local keys, i = {}, 0

    for _, category in ipairs( Glide.MISC_SOUND_CATEGORIES ) do
        for _, key in ipairs( category.keys ) do
            i = i + 1
            keys[i] = key
        end
    end

    return keys
end

function Glide.ValidateMiscSoundData( data )
    if type( data ) ~= "table" then
        return false, "Preset is not a table!"
    end

    local validKeys = {}

    for _, category in ipairs( Glide.MISC_SOUND_CATEGORIES ) do
        for _, key in ipairs( category.keys ) do
            validKeys[key] = true
        end
    end

    for k, path in pairs( data ) do
        if not validKeys[k] then
            return false, "Preset contains invalid key(s)!"
        end

        if type( path ) ~= "string" then
            return false, "Preset contains invalid file path(s)!"
        end
    end

    return true
end

