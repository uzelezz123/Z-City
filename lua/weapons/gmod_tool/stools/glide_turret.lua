TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_turret.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" }
}

TOOL.ClientConVar = {
    delay = 0.05,
    damage = 5,
    spread = 0.5,
    sound_preset = "minigun",
    is_explosive = 0,

    tracer_r = 255,
    tracer_g = 160,
    tracer_b = 35
}

local SOUND_PRESETS = {
    ["silent"] = { "", "" },
    ["minigun"] = { ")glide/weapons/mg_shoot_loop.wav", ")glide/weapons/mg_shoot_stop.wav" },
    ["valkyrie_turret"] = { "glide/weapons/turret_mg_loop.wav", "glide/weapons/turret_mg_end.wav" },
    ["hunter_turret"] = { "glide/weapons/turret_hunt_loop.wav", "glide/weapons/turret_hunt_end.wav" },
    ["strikeforce_cannon"] = { ")glide/weapons/b11_turret_loop.wav", ")glide/weapons/b11_turret_loop_end.wav" }
}

local function IsGlideTurret( ent )
    return IsValid( ent ) and ent:GetClass() == "glide_standalone_turret"
end

if SERVER then
    function TOOL:Deploy()
        Glide.ToolCheckMissingWiremod( self:GetOwner() )
    end

    function TOOL:UpdateTurret( ent )
        local presetId = self:GetClientInfo( "sound_preset" )
        local delay = self:GetClientNumber( "delay" )
        local damage = self:GetClientNumber( "damage" )
        local spread = self:GetClientNumber( "spread" )
        local isExplosive = self:GetClientNumber( "is_explosive" ) > 0

        local r = self:GetClientNumber( "tracer_r", 255 )
        local g = self:GetClientNumber( "tracer_g", 160 )
        local b = self:GetClientNumber( "tracer_b", 35 )

        ent:SetTurretExplosive( isExplosive )
        ent:SetTurretDelay( delay )
        ent:SetTurretDamage( damage )
        ent:SetTurretSpread( spread )
        ent:SetTracerColor( r, g, b )

        local preset = SOUND_PRESETS[presetId]

        if preset then
            ent:SetShootLoopSound( preset[1] )
            ent:SetShootStopSound( preset[2] )
        end
    end
end

function TOOL:LeftClick( trace )
    local ent = trace.Entity

    if IsGlideTurret( ent ) then
        if SERVER then
            self:UpdateTurret( ent )
        end

        return true
    end

    local ply = self:GetOwner()
    if not ply:CheckLimit( "glide_standalone_turrets" ) then return false end

    if SERVER then
        local normal = trace.HitNormal
        local pos = trace.HitPos + normal * 5

        ent = duplicator.CreateEntityFromTable( ply, {
            Class = "glide_standalone_turret",
            Pos = pos,
            Angle = normal:Angle() + Angle( 90, 0, 0 )
        } )

        if not IsValid( ent ) then return false end

        undo.Create( self.Name )
        undo.AddEntity( ent )
        undo.SetPlayer( ply )
        undo.Finish()

        self:UpdateTurret( ent )
    end

    return true
end

function TOOL:RightClick( trace )
    local ent = trace.Entity
    if not IsGlideTurret( ent ) then return false end

    if SERVER then
        local loopSound = ent:GetShootLoopSound()
        local presetId = "none"

        for k, v in pairs( SOUND_PRESETS ) do
            if v[1] == loopSound then
                presetId = k
                break
            end
        end

        local ply = self:GetOwner()
        local delay = ent.turretDelay
        local damage = ent.turretDamage
        local spread = ent.turretSpread
        local isExplosive = ent.isExplosive

        ply:ConCommand( "glide_turret_sound_preset " .. presetId )
        ply:ConCommand( "glide_turret_delay " .. delay )
        ply:ConCommand( "glide_turret_damage " .. damage )
        ply:ConCommand( "glide_turret_spread " .. spread )
        ply:ConCommand( "glide_turret_is_explosive " .. ( isExplosive and "1" or "0" ) )

        local r = ent.tracerColor.r
        local g = ent.tracerColor.g
        local b = ent.tracerColor.b

        ply:ConCommand( "glide_turret_tracer_r " .. r )
        ply:ConCommand( "glide_turret_tracer_g " .. g )
        ply:ConCommand( "glide_turret_tracer_b " .. b )
    end

    return true
end

local cvarMaxDamage = GetConVar( "glide_turret_max_damage" )
local cvarMinDelay = GetConVar( "glide_turret_min_delay" )

local conVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_turret.desc" )
    panel:ToolPresets( "glide_turret", conVarsDefault )

    local options = {}

    for k, _ in pairs( SOUND_PRESETS ) do
        options[k] = { glide_turret_sound_preset = k }
    end

    panel:AddControl( "combobox", {
        Label = "#tool.glide_turret.sound_preset",
        Options = options
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_turret.delay",
        command = "glide_turret_delay",
        type = "float",
        min = cvarMinDelay and cvarMinDelay:GetFloat() or 0.02,
        max = 5
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_turret.damage",
        command = "glide_turret_damage",
        min = 1,
        max = cvarMaxDamage and cvarMaxDamage:GetFloat() or 50
    } )

    panel:AddControl( "slider", {
        Label = "#tool.glide_turret.spread",
        command = "glide_turret_spread",
        type = "float",
        min = 0,
        max = 5
    } )

    panel:AddControl( "checkbox", {
        Label = "#tool.glide_turret.explosive",
        command = "glide_turret_is_explosive"
    } )

    panel:AddControl( "color", {
        Label = "#tool.glide_turret.tracer_color",
        red = "glide_turret_tracer_r",
        green = "glide_turret_tracer_g",
        blue = "glide_turret_tracer_b",
        alpha = nil
    } ).Mixer:SetAlphaBar( false )
end
