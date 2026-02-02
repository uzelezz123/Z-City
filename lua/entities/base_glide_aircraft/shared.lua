ENT.Type = "anim"
ENT.Base = "base_glide"

ENT.PrintName = "Glide Aircraft"
ENT.Author = "StyledStrike"
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true
ENT.VJ_ID_Aircraft = true

DEFINE_BASECLASS( "base_glide" )

--- Override this base class function.
function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Float", "Power" )
    self:SetPower( 0 )
end

--- Override this base class function.
function ENT:GetPlayerSitSequence( _seatIndex )
    return "sit"
end

if CLIENT then
    -- Set exhaust positions relative to the chassis
    ENT.ExhaustPositions = {}

    -- Offsets and timings for strobe lights.
    -- This should contain a table of tables, where each looks like this:
    --
    -- { offset = Vector( 0, 0, 0 ), blinkTime = 0 },   -- Blinks at the start of the cycle
    -- { offset = Vector( 0, 0, 0 ), blinkTime = 0.5, blinkDuration = 0.5 }, -- Blinks in the middle of the cycle, for half of the cycle
    --
    -- Also note that the table count here should be less than or equal to
    -- the color count on `ENT.StrobeLightColors`.
    ENT.StrobeLights = {}

    ENT.StrobeLightRadius = 80
    ENT.StrobeLightSpriteSize = 30

    ENT.StrobeLightColors = {
        Color( 255, 255, 255 ),
        Color( 255, 0, 0 ),
        Color( 0, 255, 0 )
    }

    --- Override this base class function.
    function ENT:GetCameraType( _seatIndex )
        return 2 -- Glide.CAMERA_TYPE.AIRCRAFT
    end
end

if SERVER then
    ENT.IsHeavyVehicle = true
    ENT.ExplosionRadius = 700
    ENT.SuspensionHeavySound = "Glide.Suspension.CompressBike"

    ENT.CollisionDamageMultiplier = 4

    -- Damaged engine sound
    ENT.DamagedEngineSound = "Glide.Damaged.GearGrind"
    ENT.DamagedEngineVolume = 0.4

    -- Should this vehicle use the landing gear system?
    ENT.HasLandingGear = false

    -- Setting this to a number higher than 0
    -- will enable flare contermeasures.
    ENT.CountermeasureCount = 3

    -- Delay between deployment of countermeasures
    ENT.CountermeasureCooldown = 8

    -- Animations to play when the landing gear state changes
    ENT.LandingGearAnims = {
        [0] = "gear_down",
        [1] = "move_gear_up",
        [2] = "gear_up",
        [3] = "move_gear_down"
    }

    -- Sounds to play when the landing gear state changes
    ENT.LandingGearSounds = {
        -- Sound path (empty to not play), volume, pitch
        [0] = { "", 1.0, 100 },
        [1] = { "glide/aircraft/gear_down.wav", 0.65, 100 },
        [2] = { "physics/metal/metal_barrel_impact_soft4.wav", 0.5, 100 },
        [3] = { "glide/aircraft/gear_down.wav", 0.65, 90 }
    }

    --- Override this base class function.
    function ENT:GetInputGroups( seatIndex )
        return seatIndex > 1 and { "general_controls" } or { "general_controls", "aircraft_controls" }
    end

    -- You can override these on your child classes.
    function ENT:OnLandingGearStateChange( _state ) end

    function ENT:ShouldRotorsSpinFast()
        return self:GetPower() > 0.65
    end

    function ENT:RotorStartSpinningFast( rotor )
        rotor:SetModel( rotor.modelFast == "" and rotor.modelSlow or rotor.modelFast )
    end

    function ENT:RotorStopSpinningFast( rotor )
        rotor:SetModel( rotor.modelSlow )
    end
end
