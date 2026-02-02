AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Turret"
ENT.Category = "Glide"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", "IsFiring" )
    self:NetworkVar( "String", "ShootLoopSound" )
    self:NetworkVar( "String", "ShootStopSound" )
end

local CurTime = CurTime

function ENT:Think()
    local t = CurTime()

    if SERVER then
        self:NextThink( t )
        self:UpdateTurret( t )
    end

    if CLIENT then
        self:SetNextClientThink( t )
        self:UpdateSounds()
    end

    return true
end

if CLIENT then
    function ENT:OnRemove()
        if self.shootSound then
            self.shootSound:Stop()
            self.shootSound = nil
        end
    end

    function ENT:UpdateSounds()
        local loopPath = self:GetShootLoopSound()

        if self:GetIsFiring() and loopPath ~= "" then
            if not self.shootSound then
                self.shootSound = CreateSound( self, loopPath )
                self.shootSound:SetSoundLevel( 80 )
                self.shootSound:PlayEx( 1.0, 100 )
            end

        elseif self.shootSound then
            self.shootSound:Stop()
            self.shootSound = nil

            local stopPath = self:GetShootStopSound()

            if stopPath ~= "" then
                self:EmitSound( stopPath, 80, 100, 1.0 )
            end
        end
    end
end

if not SERVER then return end

local DUPE_NW_VARS = {
    ["ShootLoopSound"] = true,
    ["ShootStopSound"] = true
}

local ENT_VARS = {
    ["turretDamage"] = true,
    ["turretDelay"] = true,
    ["turretSpread"] = true,
    ["isExplosive"] = true,
    ["tracerColor"] = true
}

function ENT:OnEntityCopyTableFinish( data )
    Glide.FilterEntityCopyTable( data, DUPE_NW_VARS, ENT_VARS )
end

function ENT:PreEntityCopy()
    Glide.PreEntityCopy( self )
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
    Glide.PostEntityPaste( ply, ent, createdEntities )

    -- Update parameters in case the limits/console variables are not set to default
    self:SetTurretExplosive( self.isExplosive )
    self:SetTurretDamage( self.turretDamage )
    self:SetTurretDelay( self.turretDelay )
    self:SetTurretSpread( self.turretSpread )
end

local function MakeSpawner( ply, data )
    if IsValid( ply ) and not ply:CheckLimit( "glide_standalone_turrets" ) then return end

    local ent = ents.Create( data.Class )
    if not IsValid( ent ) then return end

    ent:SetPos( data.Pos )
    ent:SetAngles( data.Angle )
    ent:SetCreator( ply )
    ent:Spawn()
    ent:Activate()

    ply:AddCount( "glide_standalone_turrets", ent )
    cleanup.Add( ply, "glide_standalone_turrets", ent )

    for k, v in pairs( data ) do
        if ENT_VARS[k] then ent[k] = v end
    end

    return ent
end

duplicator.RegisterEntityClass( "glide_standalone_turret", MakeSpawner, "Data" )

function ENT:SpawnFunction( ply, tr )
    if tr.Hit then
        return MakeSpawner( ply, {
            Pos = tr.HitPos,
            Angle = Angle(),
            Class = self.ClassName
        } )
    end
end

function ENT:Initialize()
    self:SetModel( "models/props_junk/PopCan01a.mdl" )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    self:DrawShadow( false )

    self.turretDamage = 5
    self.turretDelay = 0.05
    self.turretSpread = 0.5
    self.isExplosive = false
    self.tracerColor = Color( 255, 160, 35 )

    self.nextShoot = 0
    self.traceFilter = self

    self:SetIsFiring( false )
    self:SetShootLoopSound( ")glide/weapons/mg_shoot_loop.wav" )
    self:SetShootStopSound( ")glide/weapons/mg_shoot_stop.wav" )

    if WireLib then
        WireLib.CreateSpecialInputs( self,
            { "Fire", "Delay", "Damage", "Spread", "TraceColor", "LoopSound", "StopSound" },
            { "NORMAL", "NORMAL", "NORMAL", "NORMAL", "VECTOR", "STRING", "STRING" }
        )
    end
end

local FireBullet = Glide.FireBullet

function ENT:UpdateTurret( t )
    if not self:GetIsFiring() then return end
    if t < self.nextShoot then return end

    local delay = self.turretDelay

    if self.isExplosive then
        delay = math.max( delay, 0.06 )
    end

    self.nextShoot = t + delay

    local dir = self:GetUp()

    FireBullet( {
        pos = self:GetPos() + dir * 5,
        ang = dir:Angle(),
        attacker = self:GetCreator(),
        inflictor = self,
        damage = self.turretDamage,
        spread = self.turretSpread,
        isExplosive = self.isExplosive,
        tracerColor = self.tracerColor,
        scale = 0.5
    }, self.traceFilter )
end

local cvarExplosive = GetConVar( "glide_turret_explosive_allow" )
local cvarMaxDamage = GetConVar( "glide_turret_max_damage" )
local cvarMinDelay = GetConVar( "glide_turret_min_delay" )

function ENT:SetTurretExplosive( bool )
    self.isExplosive = cvarExplosive:GetBool() and bool or false
end

function ENT:SetTurretDamage( damage )
    self.turretDamage = math.Clamp( damage, 1, cvarMaxDamage and cvarMaxDamage:GetFloat() or 50 )
end

function ENT:SetTurretDelay( delay )
    self.turretDelay = math.Clamp( delay, cvarMinDelay and cvarMinDelay:GetFloat() or 0.02, 0.5 )
end

function ENT:SetTurretSpread( spread )
    self.turretSpread = math.Clamp( spread, 0, 5 )
end

function ENT:SetTracerColor( r, g, b )
    local color = self.tracerColor
    color.r = math.Clamp( r, 0, 255 )
    color.g = math.Clamp( g, 0, 255 )
    color.b = math.Clamp( b, 0, 255 )
end

local VALID_AUDIO_EXT = {
    ["wav"] = true,
    ["mp3"] = true,
    ["ogg"] = true,
}

local function IsValidSoundPath( path )
    path = string.Trim( path )

    local ext = string.GetExtensionFromFilename( path )

    if not VALID_AUDIO_EXT[ext] then
        return false
    end

    if not file.Exists( "sound/" .. path, "GAME" ) then
        return false
    end

    return true
end

function ENT:TriggerInput( name, value )
    if name == "Fire" then
        self:SetIsFiring( value > 0 )

    elseif name == "Delay" then
        self:SetTurretDelay( value )

    elseif name == "Damage" then
        self:SetTurretDamage( value )

    elseif name == "Spread" then
        self:SetTurretSpread( value )

    elseif name == "TraceColor" then
        self:SetTracerColor( value[1], value[2], value[3] )

    elseif name == "LoopSound" then
        if IsValidSoundPath( value ) then
            self:SetShootLoopSound( value )
        end

    elseif name == "StopSound" then
        if IsValidSoundPath( value ) then
            self:SetShootStopSound( value )
        end
    end
end
