TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_material.name"

TOOL.ClientConVar["override"] = "debug/env_cubemap_model"

TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" }
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

local OVERRIDE_MATS = {
    ["models/gta5/vehicles/body_paint"] = true,
    ["models/gta5/vehicles/body_paint2"] = true,
    ["models/gta5/vehicles/halftrack_worn"] = true,
    ["models/gta5/vehicles/rhino/tank_camo"] = true
}

local function SetPaintMaterial( _ply, ent, data )
    if data.MaterialOverride == "" then
        data.MaterialOverride = nil
    end

    -- Make sure this material is in the "allowed" list in multiplayer
    if
        not game.SinglePlayer() and
        not list.Contains( "OverrideMaterials", data.MaterialOverride ) and
        data.MaterialOverride ~= nil
    then
        return false
    end

    -- Find the "body paint" submaterial slot(s)
    local slots = {}

    for i, path in ipairs( ent:GetMaterials() ) do
        if OVERRIDE_MATS[path] then
            slots[#slots + 1] = i - 1
        end
    end

    -- Replace the "body paint" submaterials
    for _, slot in ipairs( slots ) do
        ent:SetSubMaterial( slot, data.MaterialOverride )
    end

    duplicator.StoreEntityModifier( ent, "glide_material", data )

    return true
end

if SERVER then
    duplicator.RegisterEntityModifier( "glide_material", SetPaintMaterial )
end

function TOOL:LeftClick( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end

    if SERVER then
        local path = self:GetClientInfo( "override" )
        SetPaintMaterial( self:GetOwner(), veh, { MaterialOverride = path } )
    end

    return true
end

function TOOL:RightClick( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end

    if SERVER then
        -- Find the first "body paint" submaterial slot
        local slot

        for i, path in ipairs( veh:GetMaterials() ) do
            if OVERRIDE_MATS[path] then
                slot = i - 1
                break
            end
        end

        if slot then
            local path = veh:GetSubMaterial( slot )
            if path == "" then path = "debug/env_cubemap_model" end

            self:GetOwner():ConCommand( "glide_material_override " .. path )
        end
    end

    return true
end

function TOOL:Reload( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end

    if SERVER then
        SetPaintMaterial( self:GetOwner(), veh, { MaterialOverride = "" } )
    end

    return true
end

function TOOL.BuildCPanel( panel )
    panel:AddControl( "Header", { Description = "#tool.glide_material.desc" } )

    local filter = panel:AddControl( "TextBox", { Label = "#spawnmenu.quick_filter_tool" } )
    filter:SetUpdateOnType( true )

    local materials = {}
    local existing = {}

    for _, path in ipairs( list.Get( "OverrideMaterials" ) ) do
        if not existing[path] then
            existing[path] = true
            materials[#materials + 1] = path
        end
    end

    local matList = panel:MatSelect( "glide_material_override", materials, true, 0.25, 0.25 )

    filter.OnValueChange = function( _, txt )
        for _, p in ipairs( matList.Controls ) do
            p:SetVisible( p.Value:lower():find( txt:lower(), nil, true ) )
        end

        matList:InvalidateChildren()
        panel:InvalidateChildren()
    end
end
