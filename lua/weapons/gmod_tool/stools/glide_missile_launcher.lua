TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_missile_launcher.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" }
}

TOOL.ClientConVar = {
    delay = 1,
    lifetime = 5,
    radius = 350,
    damage = 100,

    missile_model = "models/glide/weapons/homing_rocket.mdl",
    missile_model_scale = 1
}

local function IsGlideMissileLauncher( ent )
    return IsValid( ent ) and ent:GetClass() == "glide_missile_launcher"
end

if SERVER then
    function TOOL:Deploy()
        Glide.ToolCheckMissingWiremod( self:GetOwner() )
    end

    function TOOL:UpdateMissileLauncher( ent )
        local delay = self:GetClientNumber( "delay" )
        local lifetime = self:GetClientNumber( "lifetime" )
        local radius = self:GetClientNumber( "radius" )
        local damage = self:GetClientNumber( "damage" )

        local missileModel = self:GetClientInfo( "missile_model" )
        local missileScale = self:GetClientNumber( "missile_model_scale" )

        ent:SetReloadDelay( delay )
        ent:SetMissileLifetime( lifetime )
        ent:SetExplosionRadius( radius )
        ent:SetExplosionDamage( damage )
        ent:SetMissileModel( missileModel )
        ent:SetMissileScale( missileScale )
    end
end

function TOOL:LeftClick( trace )
    local ent = trace.Entity

    if IsGlideMissileLauncher( ent ) then
        if SERVER then
            self:UpdateMissileLauncher( ent )
        end

        return true
    end

    local ply = self:GetOwner()
    if not ply:CheckLimit( "glide_missile_launchers" ) then return false end

    if SERVER then
        local normal = trace.HitNormal
        local pos = trace.HitPos + normal * 5

        ent = duplicator.CreateEntityFromTable( ply, {
            Class = "glide_missile_launcher",
            Pos = pos,
            Angle = normal:Angle() + Angle( 90, 0, 0 )
        } )

        if not IsValid( ent ) then return false end

        undo.Create( self.Name )
        undo.AddEntity( ent )
        undo.SetPlayer( ply )
        undo.Finish()

        self:UpdateMissileLauncher( ent )
    end

    return true
end

function TOOL:RightClick( trace )
    local ent = trace.Entity
    if not IsGlideMissileLauncher( ent ) then return false end

    if SERVER then
        local ply = self:GetOwner()
        local delay = ent.reloadDelay
        local lifetime = ent.missileLifetime
        local radius = ent.explosionRadius
        local damage = ent.explosionDamage

        ply:ConCommand( "glide_missile_launcher_delay " .. delay )
        ply:ConCommand( "glide_missile_launcher_lifetime " .. lifetime )
        ply:ConCommand( "glide_missile_launcher_radius " .. radius )
        ply:ConCommand( "glide_missile_launcher_damage " .. damage )
    end

    return true
end

local cvarMinDelay = GetConVar( "glide_missile_launcher_min_delay" )
local cvarMaxLifetime = GetConVar( "glide_missile_launcher_max_lifetime" )
local cvarMaxRadius = GetConVar( "glide_missile_launcher_max_radius" )
local cvarMaxDamage = GetConVar( "glide_missile_launcher_max_damage" )

local conVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_missile_launcher.desc" )
    panel:ToolPresets( "glide_missile_launcher", conVarsDefault )

    panel:AddControl( "slider", {
        Label = "#tool.glide_missile_launcher.delay",
        command = "glide_missile_launcher_delay",
        type = "float",
        min = cvarMinDelay and cvarMinDelay:GetFloat() or 0.5,
        max = 50
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_missile_launcher.lifetime",
        command = "glide_missile_launcher_lifetime",
        type = "float",
        min = 1,
        max = cvarMaxLifetime and cvarMaxLifetime:GetFloat() or 10
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_missile_launcher.radius",
        command = "glide_missile_launcher_radius",
        min = 50,
        max = cvarMaxRadius and cvarMaxRadius:GetFloat() or 500
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_missile_launcher.damage",
        command = "glide_missile_launcher_damage",
        min = 1,
        max = cvarMaxDamage and cvarMaxDamage:GetFloat() or 200
    } )

    local models = {}

    for path, _ in pairs( list.Get( "GlideProjectileModels" ) ) do
        models[path] = { convar = path }
    end

    panel:PropSelect( "#tool.glide_missile_launcher.missile_model", "glide_missile_launcher_missile_model", models, 4 )
    panel:NumSlider( "#tool.glide_missile_launcher.missile_model_scale", "glide_missile_launcher_missile_model_scale", 0.5, 3, 1 )
end
