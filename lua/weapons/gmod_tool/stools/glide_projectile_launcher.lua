TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_projectile_launcher.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" }
}

TOOL.ClientConVar = {
    speed = 10000,
    gravity = 700,
    lifetime = 5,
    delay = 2,
    radius = 350,
    damage = 100,
    r = 60,
    g = 60,
    b = 60,

    projectile_model = "models/props_phx/misc/flakshell_big.mdl",
    projectile_model_scale = 1
}

local function IsGlideProjectileLauncher( ent )
    return IsValid( ent ) and ent:GetClass() == "glide_projectile_launcher"
end

if SERVER then
    function TOOL:Deploy()
        Glide.ToolCheckMissingWiremod( self:GetOwner() )
    end

    function TOOL:UpdateProjectileLauncher( ent )
        local speed = self:GetClientNumber( "speed" )
        local gravity = self:GetClientNumber( "gravity" )
        local lifetime = self:GetClientNumber( "lifetime" )
        local delay = self:GetClientNumber( "delay" )
        local radius = self:GetClientNumber( "radius" )
        local damage = self:GetClientNumber( "damage" )

        local r = self:GetClientNumber( "r", 60 )
        local g = self:GetClientNumber( "g", 60 )
        local b = self:GetClientNumber( "b", 60 )

        local projectileModel = self:GetClientInfo( "projectile_model" )
        local projectileScale = self:GetClientNumber( "projectile_model_scale" )

        ent:SetProjectileSpeed( speed )
        ent:SetProjectileGravity( gravity )
        ent:SetProjectileLifetime( lifetime )
        ent:SetReloadDelay( delay )
        ent:SetExplosionRadius( radius )
        ent:SetExplosionDamage( damage )
        ent:SetSmokeColor( r, g, b )
        ent:SetProjectileModel( projectileModel )
        ent:SetProjectileScale( projectileScale )
    end
end

function TOOL:LeftClick( trace )
    local ent = trace.Entity

    if IsGlideProjectileLauncher( ent ) then
        if SERVER then
            self:UpdateProjectileLauncher( ent )
        end

        return true
    end

    local ply = self:GetOwner()
    if not ply:CheckLimit( "glide_projectile_launchers" ) then return false end

    if SERVER then
        local normal = trace.HitNormal
        local pos = trace.HitPos + normal * 5

        ent = duplicator.CreateEntityFromTable( ply, {
            Class = "glide_projectile_launcher",
            Pos = pos,
            Angle = normal:Angle() + Angle( 90, 0, 0 )
        } )

        if not IsValid( ent ) then return false end

        undo.Create( self.Name )
        undo.AddEntity( ent )
        undo.SetPlayer( ply )
        undo.Finish()

        self:UpdateProjectileLauncher( ent )
    end

    return true
end

function TOOL:RightClick( trace )
    local ent = trace.Entity
    if not IsGlideProjectileLauncher( ent ) then return false end

    if SERVER then
        local ply = self:GetOwner()
        local speed = ent.projectileSpeed
        local gravity = ent.projectileGravity
        local lifetime = ent.projectileLifetime
        local delay = ent.reloadDelay
        local radius = ent.explosionRadius
        local damage = ent.explosionDamage

        ply:ConCommand( "glide_projectile_launcher_speed " .. speed )
        ply:ConCommand( "glide_projectile_launcher_gravity " .. gravity )
        ply:ConCommand( "glide_projectile_launcher_lifetime " .. lifetime )
        ply:ConCommand( "glide_projectile_launcher_delay " .. delay )
        ply:ConCommand( "glide_projectile_launcher_radius " .. radius )
        ply:ConCommand( "glide_projectile_launcher_damage " .. damage )

        local r = ent.smokeColor.r
        local g = ent.smokeColor.g
        local b = ent.smokeColor.b

        ply:ConCommand( "glide_projectile_launcher_r " .. r )
        ply:ConCommand( "glide_projectile_launcher_g " .. g )
        ply:ConCommand( "glide_projectile_launcher_b " .. b )
    end

    return true
end

local cvarMaxLifetime = GetConVar( "glide_projectile_launcher_max_lifetime" )
local cvarMinDelay = GetConVar( "glide_projectile_launcher_min_delay" )
local cvarMaxRadius = GetConVar( "glide_projectile_launcher_max_radius" )
local cvarMaxDamage = GetConVar( "glide_projectile_launcher_max_damage" )

local conVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_projectile_launcher.desc" )
    panel:ToolPresets( "glide_projectile_launcher", conVarsDefault )

    panel:AddControl( "slider", {
        Label = "#tool.glide_projectile_launcher.speed",
        command = "glide_projectile_launcher_speed",
        type = "float",
        min = 1,
        max = 20000
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_projectile_launcher.gravity",
        command = "glide_projectile_launcher_gravity",
        type = "float",
        min = 1,
        max = 2000
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_projectile_launcher.lifetime",
        command = "glide_projectile_launcher_lifetime",
        type = "float",
        min = 1,
        max = cvarMaxLifetime and cvarMaxLifetime:GetFloat() or 10
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_projectile_launcher.delay",
        command = "glide_projectile_launcher_delay",
        type = "float",
        min = cvarMinDelay and cvarMinDelay:GetFloat() or 0.5,
        max = 50
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_projectile_launcher.radius",
        command = "glide_projectile_launcher_radius",
        min = 50,
        max = cvarMaxRadius and cvarMaxRadius:GetFloat() or 500
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_projectile_launcher.damage",
        command = "glide_projectile_launcher_damage",
        min = 1,
        max = cvarMaxDamage and cvarMaxDamage:GetFloat() or 200
    } )

    panel:AddControl( "color", {
        Label = "#tool.glide_projectile_launcher.smoke_color",
        red = "glide_projectile_launcher_r",
        green = "glide_projectile_launcher_g",
        blue = "glide_projectile_launcher_b",
        alpha = nil
    } ).Mixer:SetAlphaBar( false )

    local models = {}

    for path, _ in pairs( list.Get( "GlideProjectileModels" ) ) do
        models[path] = { convar = path }
    end

    panel:PropSelect( "#tool.glide_projectile_launcher.projectile_model", "glide_projectile_launcher_projectile_model", models, 4 )
    panel:NumSlider( "#tool.glide_projectile_launcher.projectile_model_scale", "glide_projectile_launcher_projectile_model_scale", 0.5, 3, 1 )
end
