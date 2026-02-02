--[[
    This file contains utility functions to setup and play sets of sounds.

    They act just like soundscripts (the ones added with `sound.Add`), however
    this version allows you to override the volume, pitch and sound level when playing.
]]

local soundSets = Glide.soundSets or {}

Glide.soundSets = soundSets

function Glide.AddSoundSet( id, level, minPitch, maxPitch, paths )
    soundSets[id] = {
        paths = paths,
        level = level or 70,
        channel = CHAN_STATIC,

        minPitch = minPitch or 100,
        maxPitch = maxPitch or 100
    }
end

local IsEntity = isentity
local EmitSound = EmitSound
local RandomInt = math.random
local RandomFloat = math.Rand

--- Get a random sound from a sound set.
--- If the sound set does not exist, then the `id` will be returned.
function Glide.GetRandomSound( id )
    local set = soundSets[id]

    if not set then
        return id
    end

    return set.paths[RandomInt( #set.paths )]
end

local dummySet = { paths = {}, level = 80, minPitch = 100, maxPitch = 100 }

--- Play a random sound from a sound set.
--- If the sound set does not exist, then the `id` will be treated as a sound path.
function Glide.PlaySoundSet( id, source, volume, pitch, level, filter )
    local set = soundSets[id]

    if not set then
        dummySet.paths[1] = id
        set = dummySet
    end

    pitch = pitch or RandomFloat( set.minPitch, set.maxPitch )
    level = level or set.level
    volume = volume or 1

    local path = set.paths[RandomInt( #set.paths )]

    if IsEntity( source ) then
        source:EmitSound( path, level, pitch, volume, set.channel, 0, 0, filter )
    else
        EmitSound( path, source, 0, set.channel, volume, level, 0, pitch, 0, filter )
    end
end

----------------------------------------

--[[
    Add a few sound sets used throughout the addon.
]]

----- Weapon sounds

Glide.AddSoundSet( "Glide.MissileLaunch", 90, 95, 105, {
    ")glide/weapons/missile_launch_1.wav",
    ")glide/weapons/missile_launch_2.wav",
    ")glide/weapons/missile_launch_3.wav"
} )

Glide.AddSoundSet( "Glide.FlareLaunch", 90, 95, 105, {
    ")glide/weapons/flare_deploy1.wav",
    ")glide/weapons/flare_deploy2.wav"
} )

Glide.AddSoundSet( "Glide.InsurgentShoot", 90, 95, 105, {
    ")glide/weapons/insurgent_shoot_1.wav",
    ")glide/weapons/insurgent_shoot_2.wav",
    ")glide/weapons/insurgent_shoot_3.wav"
} )

----- Explosion sounds

Glide.AddSoundSet( "Glide.Explosion.PreImpact", 95, 90, 110, {
    "glide/explosions/pre_impact_1.wav",
    "glide/explosions/pre_impact_2.wav",
    "glide/explosions/pre_impact_3.wav"
} )

Glide.AddSoundSet( "Glide.Explosion.Impact", 95, 90, 110, {
    "glide/explosions/impact_1.wav",
    "glide/explosions/impact_2.wav",
    "glide/explosions/impact_3.wav",
    "glide/explosions/impact_4.wav"
} )

Glide.AddSoundSet( "Glide.Explosion.Metal", 90, 90, 110, {
    "glide/explosions/metal_impact_3.wav",
    "glide/explosions/metal_impact_4.wav",
    "glide/explosions/metal_impact_5.wav"
} )

-- These stereo sounds are spatialized with the ")" flag.
-- https://developer.valvesoftware.com/wiki/Soundscripts#Spatial_Stereo
Glide.AddSoundSet( "Glide.Explosion.Distant", 140, 95, 105, {
    ")glide/explosions/explosion_dist_1.wav",
    ")glide/explosions/explosion_dist_2.wav",
    ")glide/explosions/explosion_dist_3.wav",
    ")glide/explosions/explosion_dist_4.wav",
    ")glide/explosions/explosion_dist_5.wav",
    ")glide/explosions/explosion_dist_6.wav",
    ")glide/explosions/explosion_dist_7.wav",
    ")glide/explosions/explosion_dist_8.wav",
    ")glide/explosions/explosion_dist_9.wav"
} )

----- Suspension sounds

Glide.AddSoundSet( "Glide.Suspension.Down", 70, 100, 120, {
    "glide/suspension/pneumatic_down_1.wav",
    "glide/suspension/pneumatic_down_2.wav",
    "glide/suspension/pneumatic_down_3.wav"
} )

Glide.AddSoundSet( "Glide.Suspension.Up", 70, 100, 120, {
    "glide/suspension/pneumatic_up_1.wav",
    "glide/suspension/pneumatic_up_2.wav",
    "glide/suspension/pneumatic_up_3.wav"
} )

Glide.AddSoundSet( "Glide.Suspension.CompressHeavy", 75, 100, 120, {
    "glide/suspension/compress_heavy_1.wav",
    "glide/suspension/compress_heavy_2.wav",
    "glide/suspension/compress_heavy_3.wav"
} )

Glide.AddSoundSet( "Glide.Suspension.CompressBike", 70, 120, 130, {
    "glide/suspension/pneumatic_down_1.wav",
    "glide/suspension/pneumatic_down_2.wav",
    "glide/suspension/pneumatic_down_3.wav"
} )

Glide.AddSoundSet( "Glide.Suspension.CompressTruck", 80, 100, 120, {
    "glide/suspension/compress_truck_1.wav",
    "glide/suspension/compress_truck_2.wav",
    "glide/suspension/compress_truck_3.wav",
    "glide/suspension/compress_truck_4.wav"
} )

Glide.AddSoundSet( "Glide.Suspension.Stress", 85, 100, 110, {
    "glide/suspension/stress_1.wav",
    "glide/suspension/stress_2.wav",
    "glide/suspension/stress_3.wav"
} )

Glide.AddSoundSet( "Glide.Brakes.Squeak", 85, 95, 105, {
    "glide/wheels/brake_squeak_1.wav",
    "glide/wheels/brake_squeak_2.wav",
    "glide/wheels/brake_squeak_3.wav"
} )

----- Engine gear switch sounds

Glide.AddSoundSet( "Glide.GearSwitch.Internal", 70, 98, 102, {
    "glide/internal_gear_change_1.wav",
    "glide/internal_gear_change_2.wav",
    "glide/internal_gear_change_3.wav",
    "glide/internal_gear_change_4.wav",
    "glide/internal_gear_change_5.wav",
    "glide/internal_gear_change_6.wav"
} )

Glide.AddSoundSet( "Glide.GearSwitch.External", 70, 98, 102, {
    "glide/external_gear_change_1.wav",
    "glide/external_gear_change_2.wav",
    "glide/external_gear_change_3.wav",
    "glide/external_gear_change_4.wav",
    "glide/external_gear_change_5.wav"
} )

Glide.AddSoundSet( "Glide.ExhaustPop.Sport", 75, 98, 102, {
    "glide/engines/back_fire_pop_4.wav",
    "glide/engines/back_fire_pop_6.wav"
} )

----- Engine startup sounds

Glide.AddSoundSet( "Glide.Engine.CarStart", 70, 95, 105, {
    "glide/engines/start_1.wav",
    "glide/engines/start_2.wav"
} )

Glide.AddSoundSet( "Glide.Engine.CarStartTail", 70, 95, 105, {
    "glide/engines/start_tail_1.wav",
    "glide/engines/start_tail_2.wav",
    "glide/engines/start_tail_3.wav",
    "glide/engines/start_tail_4.wav"
} )

Glide.AddSoundSet( "Glide.Engine.BikeStart1", 70, 95, 105, {
    "glide/engines/start_bike_1.wav"
} )

Glide.AddSoundSet( "Glide.Engine.BikeStart2", 70, 95, 105, {
    "glide/engines/start_bike_2.wav"
} )

Glide.AddSoundSet( "Glide.Engine.TruckStart", 85, 95, 105, {
    "glide/engines/start_truck.wav"
} )

----- Engine damage sounds

Glide.AddSoundSet( "Glide.Damaged.GearGrind", 80, 80, 90, {
    "glide/engines/gear_grind_1.wav",
    "glide/engines/gear_grind_2.wav",
    "glide/engines/gear_grind_3.wav",
    "glide/engines/gear_grind_4.wav",
    "glide/engines/gear_grind_5.wav",
    "glide/engines/gear_grind_6.wav",
} )

Glide.AddSoundSet( "Glide.Damaged.ExhaustPop", 85, 90, 100, {
    "glide/engines/back_fire_pop_1.wav",
    "glide/engines/back_fire_pop_2.wav",
    "glide/engines/back_fire_pop_3.wav"
} )

-- These stereo sounds are spatialized with the ")" flag.
-- https://developer.valvesoftware.com/wiki/Soundscripts#Spatial_Stereo
Glide.AddSoundSet( "Glide.Damaged.AircraftEngine", 90, 95, 105, {
    ")glide/aircraft/engine_fail_1.wav",
    ")glide/aircraft/engine_fail_2.wav",
    ")glide/aircraft/engine_fail_3.wav",
    ")glide/aircraft/engine_fail_4.wav",
    ")glide/aircraft/engine_fail_5.wav"
} )

Glide.AddSoundSet( "Glide.Damaged.AircraftEngineBreakdown", 80, 95, 105, {
    "glide/aircraft/breakdown_1.wav",
    "glide/aircraft/breakdown_2.wav",
    "glide/aircraft/breakdown_3.wav",
    "glide/aircraft/breakdown_4.wav",
    "glide/aircraft/breakdown_5.wav"
} )

----- Vehicle collision sounds

Glide.AddSoundSet( "Glide.Collision.VehicleScrape", 70, 80, 120, {
    "glide/collisions/metal_scrape_1.wav",
    "glide/collisions/metal_scrape_2.wav"
} )

Glide.AddSoundSet( "Glide.Collision.VehicleSoft", 75, 80, 120, {
    "glide/collisions/car_light_1.wav",
    "glide/collisions/car_light_2.wav",
    "glide/collisions/car_light_3.wav",
    "glide/collisions/car_light_4.wav"
} )

Glide.AddSoundSet( "Glide.Collision.VehicleHard", 75, 80, 120, {
    "glide/collisions/car_heavy_1.wav",
    "glide/collisions/car_heavy_2.wav",
    "glide/collisions/car_heavy_3.wav",
    "glide/collisions/car_heavy_4.wav",
    "glide/collisions/car_heavy_5.wav",
    "glide/collisions/car_heavy_6.wav",
    "glide/collisions/car_heavy_7.wav",
    "glide/collisions/car_heavy_8.wav"
} )

Glide.AddSoundSet( "Glide.Collision.AgainstPlayer", 75, 80, 120, {
    "glide/collisions/body_1.wav",
    "glide/collisions/body_2.wav",
    "glide/collisions/body_3.wav",
    "glide/collisions/body_4.wav",
    "glide/collisions/body_5.wav",
    "glide/collisions/body_6.wav"
} )

Glide.AddSoundSet( "Glide.Collision.BoatHard", 75, 80, 120, {
    "glide/collisions/boat_heavy_1.wav",
    "glide/collisions/boat_heavy_2.wav",
    "glide/collisions/boat_heavy_3.wav"
} )

Glide.AddSoundSet( "Glide.Collision.BoatLandOnWater", 80, 90, 110, {
    ")glide/collisions/land_on_water_1.wav",
    ")glide/collisions/land_on_water_2.wav",
    ")glide/collisions/land_on_water_3.wav",
    ")glide/collisions/land_on_water_4.wav"
} )

----- Collision sounds for exploded vehicle gibs

Glide.AddSoundSet( "Glide.Collision.GibSoft", 70, 80, 120, {
    "vehicles/v8/vehicle_impact_medium1.wav",
    "vehicles/v8/vehicle_impact_medium2.wav",
    "vehicles/v8/vehicle_impact_medium3.wav",
    "vehicles/v8/vehicle_impact_medium4.wav"
} )

Glide.AddSoundSet( "Glide.Collision.GibHard", 70, 80, 120, {
    "vehicles/v8/vehicle_impact_heavy1.wav",
    "vehicles/v8/vehicle_impact_heavy2.wav",
    "vehicles/v8/vehicle_impact_heavy3.wav",
    "vehicles/v8/vehicle_impact_heavy4.wav"
} )

----- Siren sounds

-- These stereo sounds are spatialized with the ")" flag.
-- https://developer.valvesoftware.com/wiki/Soundscripts#Spatial_Stereo
Glide.AddSoundSet( "Glide.Wail.Interrupt", 90, 95, 105, {
    ")glide/alarms/wail_interrupt_1.wav",
    ")glide/alarms/wail_interrupt_2.wav",
    ")glide/alarms/wail_interrupt_3.wav",
    ")glide/alarms/wail_interrupt_4.wav",
    ")glide/alarms/wail_interrupt_5.wav"
} )

----- Helicopter rotor sounds

Glide.AddSoundSet( "Glide.Rotor.Collision", 80, 90, 95, {
    "physics/metal/metal_computer_impact_bullet1.wav",
    "physics/metal/metal_computer_impact_bullet2.wav",
    "physics/metal/metal_computer_impact_bullet3.wav"
} )

Glide.AddSoundSet( "Glide.Rotor.Slice", 80, 90, 100, {
    "ambient/machines/slicer2.wav",
    "ambient/machines/slicer3.wav"
} )

-- Generic

Glide.AddSoundSet( "Glide.GenericRotor.Bass", 110, 100, 100, {
    "glide/helicopters/rotor_generic/bass_1.wav",
    "glide/helicopters/rotor_generic/bass_2.wav",
    "glide/helicopters/rotor_generic/bass_3.wav",
    "glide/helicopters/rotor_generic/bass_4.wav",
    "glide/helicopters/rotor_generic/bass_5.wav",
    "glide/helicopters/rotor_generic/bass_6.wav"
} )

Glide.AddSoundSet( "Glide.GenericRotor.Mid", 90, 100, 100, {
    "glide/helicopters/rotor_generic/mid_1.wav",
    "glide/helicopters/rotor_generic/mid_2.wav",
    "glide/helicopters/rotor_generic/mid_3.wav",
    "glide/helicopters/rotor_generic/mid_4.wav",
    "glide/helicopters/rotor_generic/mid_5.wav",
    "glide/helicopters/rotor_generic/mid_6.wav",
    "glide/helicopters/rotor_generic/mid_7.wav",
    "glide/helicopters/rotor_generic/mid_8.wav"
} )

Glide.AddSoundSet( "Glide.GenericRotor.High", 80, 100, 100, {
    "glide/helicopters/rotor_generic/high_1.wav",
    "glide/helicopters/rotor_generic/high_2.wav",
    "glide/helicopters/rotor_generic/high_3.wav",
    "glide/helicopters/rotor_generic/high_4.wav",
    "glide/helicopters/rotor_generic/high_5.wav",
    "glide/helicopters/rotor_generic/high_6.wav",
    "glide/helicopters/rotor_generic/high_7.wav",
    "glide/helicopters/rotor_generic/high_8.wav"
} )

--- Military

Glide.AddSoundSet( "Glide.MilitaryRotor.Bass", 110, 100, 100, {
    "glide/helicopters/rotor_military/bass_1.wav",
    "glide/helicopters/rotor_military/bass_2.wav",
    "glide/helicopters/rotor_military/bass_3.wav",
    "glide/helicopters/rotor_military/bass_4.wav",
    "glide/helicopters/rotor_military/bass_5.wav",
    "glide/helicopters/rotor_military/bass_6.wav"
} )

Glide.AddSoundSet( "Glide.MilitaryRotor.Mid", 90, 100, 100, {
    "glide/helicopters/rotor_military/mid_1.wav",
    "glide/helicopters/rotor_military/mid_2.wav",
    "glide/helicopters/rotor_military/mid_3.wav",
    "glide/helicopters/rotor_military/mid_4.wav",
    "glide/helicopters/rotor_military/mid_5.wav",
    "glide/helicopters/rotor_military/mid_6.wav",
    "glide/helicopters/rotor_military/mid_7.wav",
    "glide/helicopters/rotor_military/mid_8.wav",
    "glide/helicopters/rotor_military/mid_9.wav"
} )

Glide.AddSoundSet( "Glide.MilitaryRotor.High", 80, 100, 100, {
    "glide/helicopters/rotor_military/high_1.wav",
    "glide/helicopters/rotor_military/high_2.wav",
    "glide/helicopters/rotor_military/high_3.wav",
    "glide/helicopters/rotor_military/high_4.wav",
    "glide/helicopters/rotor_military/high_5.wav",
    "glide/helicopters/rotor_military/high_6.wav",
    "glide/helicopters/rotor_military/high_7.wav",
    "glide/helicopters/rotor_military/high_8.wav",
    "glide/helicopters/rotor_military/high_9.wav"
} )

--- Heavy

Glide.AddSoundSet( "Glide.HeavyRotor.Bass", 110, 100, 100, {
    "glide/helicopters/rotor_heavy/bass_1.wav",
    "glide/helicopters/rotor_heavy/bass_2.wav",
    "glide/helicopters/rotor_heavy/bass_3.wav",
    "glide/helicopters/rotor_heavy/bass_4.wav",
    "glide/helicopters/rotor_heavy/bass_5.wav",
    "glide/helicopters/rotor_heavy/bass_6.wav"
} )

Glide.AddSoundSet( "Glide.HeavyRotor.Mid", 90, 100, 100, {
    "glide/helicopters/rotor_heavy/mid_1.wav",
    "glide/helicopters/rotor_heavy/mid_2.wav",
    "glide/helicopters/rotor_heavy/mid_3.wav",
    "glide/helicopters/rotor_heavy/mid_4.wav",
    "glide/helicopters/rotor_heavy/mid_5.wav",
    "glide/helicopters/rotor_heavy/mid_6.wav",
    "glide/helicopters/rotor_heavy/mid_7.wav",
    "glide/helicopters/rotor_heavy/mid_8.wav"
} )

Glide.AddSoundSet( "Glide.HeavyRotor.High", 80, 100, 100, {
    "glide/helicopters/rotor_heavy/high_1.wav",
    "glide/helicopters/rotor_heavy/high_2.wav",
    "glide/helicopters/rotor_heavy/high_3.wav",
    "glide/helicopters/rotor_heavy/high_4.wav",
    "glide/helicopters/rotor_heavy/high_5.wav",
    "glide/helicopters/rotor_heavy/high_6.wav",
    "glide/helicopters/rotor_heavy/high_7.wav",
    "glide/helicopters/rotor_heavy/high_8.wav",
    "glide/helicopters/rotor_heavy/high_9.wav"
} )

--- Hunter

Glide.AddSoundSet( "Glide.HunterRotor.Bass", 110, 100, 100, {
    "glide/helicopters/rotor_hunter/bass_1.wav",
    "glide/helicopters/rotor_hunter/bass_2.wav",
    "glide/helicopters/rotor_hunter/bass_3.wav",
    "glide/helicopters/rotor_hunter/bass_4.wav",
    "glide/helicopters/rotor_hunter/bass_5.wav",
    "glide/helicopters/rotor_hunter/bass_6.wav"
} )

Glide.AddSoundSet( "Glide.HunterRotor.Mid", 90, 100, 100, {
    "glide/helicopters/rotor_hunter/mid_1.wav",
    "glide/helicopters/rotor_hunter/mid_2.wav",
    "glide/helicopters/rotor_hunter/mid_3.wav",
    "glide/helicopters/rotor_hunter/mid_4.wav",
    "glide/helicopters/rotor_hunter/mid_5.wav",
    "glide/helicopters/rotor_hunter/mid_6.wav",
    "glide/helicopters/rotor_hunter/mid_7.wav",
    "glide/helicopters/rotor_hunter/mid_8.wav",
    "glide/helicopters/rotor_hunter/mid_9.wav"
} )

Glide.AddSoundSet( "Glide.HunterRotor.High", 80, 100, 100, {
    "glide/helicopters/rotor_hunter/high_1.wav",
    "glide/helicopters/rotor_hunter/high_2.wav",
    "glide/helicopters/rotor_hunter/high_3.wav",
    "glide/helicopters/rotor_hunter/high_4.wav",
    "glide/helicopters/rotor_hunter/high_5.wav",
    "glide/helicopters/rotor_hunter/high_6.wav",
    "glide/helicopters/rotor_hunter/high_7.wav",
    "glide/helicopters/rotor_hunter/high_8.wav",
    "glide/helicopters/rotor_hunter/high_9.wav"
} )

----- Plane sounds

Glide.AddSoundSet( "Glide.Plane.ControlSurface", 80, 95, 105, {
    "glide/aircraft/rudder_move_1.wav",
    "glide/aircraft/rudder_move_2.wav",
    "glide/aircraft/rudder_move_3.wav"
} )
