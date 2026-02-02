TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_make_amphibious.name"

TOOL.Information = {
    { name = "left" },
    { name = "reload" }
}

TOOL.ClientConVar = {
    max_speed = 1000,
    buoyancy_offset_z = -10,
    max_buoyancy_depth = 15,

    water_linear_drag_x = 0.2,
    water_linear_drag_y = 1.5,
    water_linear_drag_z = 0.02,

    water_roll_drag = 5,
    water_pitch_drag = 20,
    water_yaw_drag = 15,

    engine_force = 500,
    engine_lift_force = 200,
    turbulance_force = 80,
    turn_force = 1200,
    roll_force = 150
}

local function IsGlideCar( ent )
    return IsValid( ent ) and ent.IsGlideVehicle and ent.VehicleType == Glide.VEHICLE_TYPE.CAR
end

local function GetGlideCar( trace )
    local ent = trace.Entity

    if IsGlideCar( ent ) then
        return ent
    end

    return false
end

if SERVER then
    Glide.StoreMakeAmphibiousModifier, Glide.ClearMakeAmphibiousModifier = Glide.RegisterSyncedModifier(
        "glide_make_amphibious",
        function( _ply, ent, unfilteredData )
            -- Make sure this entity is a Glide vehicle that supports this modifier
            if not IsGlideCar( ent ) then return end

            -- Validate data
            local data = {}
            local SetNumber = Glide.SetNumber

            SetNumber( data, "maxSpeed", unfilteredData.maxSpeed, 200, 2000, 1000 )
            SetNumber( data, "buoyancyOffsetZ", unfilteredData.buoyancyOffsetZ, -30, 30, -15 )
            SetNumber( data, "maxBuoyancyDepth", unfilteredData.maxBuoyancyDepth, 5, 30, 15 )

            SetNumber( data, "waterLinearDragX", unfilteredData.waterLinearDragX, 0.01, 2.0, 0.2 )
            SetNumber( data, "waterLinearDragY", unfilteredData.waterLinearDragY, 0.01, 2.0, 1.5 )
            SetNumber( data, "waterLinearDragZ", unfilteredData.waterLinearDragZ, 0.01, 2.0, 0.02 )

            SetNumber( data, "waterRollDrag", unfilteredData.waterRollDrag, 0.1, 30, 5 )
            SetNumber( data, "waterPitchDrag", unfilteredData.waterPitchDrag, 0.1, 30, 20 )
            SetNumber( data, "waterYawDrag", unfilteredData.waterYawDrag, 0.1, 30, 15 )

            SetNumber( data, "engineForce", unfilteredData.engineForce, 100, 5000, 500 )
            SetNumber( data, "engineLiftForce", unfilteredData.engineLiftForce, 10, 500, 200 )
            SetNumber( data, "turbulanceForce", unfilteredData.turbulanceForce, 10, 200, 80 )
            SetNumber( data, "turnForce", unfilteredData.turnForce, 100, 4000, 1200 )
            SetNumber( data, "rollForce", unfilteredData.rollForce, 10, 1000, 150 )

            -- Apply data
            ent.IsAmphibious = true
            ent.BuoyancyPointsXSpacing = 0.9
            ent.BuoyancyPointsYSpacing = 0.9
            ent.BuoyancyPointsZOffset = data.buoyancyOffsetZ

            local params = ent.BoatParams

            params.waterLinearDrag = Vector(
                data.waterLinearDragX, -- Forward drag
                data.waterLinearDragY, -- Right drag
                data.waterLinearDragZ  -- Up drag
            )

            params.waterAngularDrag = Vector(
                -data.waterRollDrag,
                -data.waterPitchDrag,
                -data.waterYawDrag
            )

            params.buoyancy = 6
            params.buoyancyDepth = data.maxBuoyancyDepth

            params.turbulanceForce = data.turbulanceForce
            params.alignForce = 800
            params.maxSpeed = data.maxSpeed

            params.engineForce = data.engineForce
            params.engineLiftForce = data.engineLiftForce
            params.turnForce = data.turnForce
            params.rollForce = data.rollForce

            ent:WaterInit()

            return data
        end
    )
end

if CLIENT then
    Glide.RegisterSyncedModifierReceiver(
        "glide_make_amphibious",
        function( ent, _data )
            ent.IsAmphibious = true
        end,
        function( ent )
            ent.IsAmphibious = false
        end
    )
end

function TOOL:LeftClick( trace )
    local vehicle = GetGlideCar( trace )
    if not vehicle then return false end

    if SERVER then
        local owner = self:GetOwner()
        if not IsValid( owner ) then return end

        Glide.StoreMakeAmphibiousModifier( owner, vehicle, {
            maxSpeed = self:GetClientNumber( "max_speed" ),
            buoyancyOffsetZ = self:GetClientNumber( "buoyancy_offset_z" ),
            maxBuoyancyDepth = self:GetClientNumber( "max_buoyancy_depth" ),

            waterLinearDragX = self:GetClientNumber( "water_linear_drag_x" ),
            waterLinearDragY = self:GetClientNumber( "water_linear_drag_y" ),
            waterLinearDragZ = self:GetClientNumber( "water_linear_drag_z" ),

            waterRollDrag = self:GetClientNumber( "water_roll_drag" ),
            waterPitchDrag = self:GetClientNumber( "water_pitch_drag" ),
            waterYawDrag = self:GetClientNumber( "water_yaw_drag" ),

            engineForce = self:GetClientNumber( "engine_force" ),
            engineLiftForce = self:GetClientNumber( "engine_lift_force" ),
            turbulanceForce = self:GetClientNumber( "turbulance_force" ),
            turnForce = self:GetClientNumber( "turn_force" ),
            rollForce = self:GetClientNumber( "roll_force" )
        } )
    end

    return true
end

function TOOL:RightClick( _trace )
    return false
end

function TOOL:Reload( trace )
    local vehicle = GetGlideCar( trace )
    if not vehicle then return false end

    if SERVER then
        vehicle.IsAmphibious = false
        vehicle:WaterInit()

        Glide.ClearMakeAmphibiousModifier( vehicle )
    end

    return true
end

local conVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_make_amphibious.desc" )
    panel:ToolPresets( "glide_make_amphibious", conVarsDefault )

    local AddSlider = function( field, min, max )
        panel:AddControl( "slider", {
            Label = field,
            command = "glide_make_amphibious_" .. field,
            type = "float",
            min = min,
            max = max
        } )
    end

    AddSlider( "max_speed", 200, 2000 )
    AddSlider( "buoyancy_offset_z", -30, 30 )
    AddSlider( "max_buoyancy_depth", 5, 30 )

    AddSlider( "water_linear_drag_x", 0.01, 2.0 )
    AddSlider( "water_linear_drag_y", 0.01, 2.0 )
    AddSlider( "water_linear_drag_z", 0.01, 2.0 )

    AddSlider( "water_pitch_drag", 0.1, 30 )
    AddSlider( "water_yaw_drag", 0.1, 30 )
    AddSlider( "water_roll_drag", 0.1, 30 )

    AddSlider( "engine_force", 100, 5000 )
    AddSlider( "engine_lift_force", 10, 500 )
    AddSlider( "turbulance_force", 10, 200 )
    AddSlider( "turn_force", 100, 4000 )
    AddSlider( "roll_force", 10, 1000 )
end
