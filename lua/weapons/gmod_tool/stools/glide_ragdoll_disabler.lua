TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_ragdoll_disabler.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" }
}

local function IsGlideVehicle( ent )
    return IsValid( ent ) and ent.IsGlideVehicle
end

local function GetGlideVehicle( trace )
    local ent = trace.Entity

    if IsGlideVehicle( ent ) then
        return ent
    end

    return false
end

function TOOL:LeftClick( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end

    if SERVER then
        veh.FallOnCollision = false
    end

    return true
end

function TOOL:RightClick( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end

    if SERVER then
        veh.FallOnCollision = true
    end

    return true
end

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_ragdoll_disabler.desc" )
end
