AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Missile Launcher"
ENT.Category = "Glide"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

if not SERVER then return end

local ENT_VARS = {
    ["reloadDelay"] = true,
    ["missileLifetime"] = true,
    ["explosionRadius"] = true,
    ["explosionDamage"] = true,
    ["missileModel"] = true,
    ["missileScale"] = true
}

function ENT:OnEntityCopyTableFinish( data )
    Glide.FilterEntityCopyTable( data, nil, ENT_VARS )
end

function ENT:PreEntityCopy()
    Glide.PreEntityCopy( self )
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
    Glide.PostEntityPaste( ply, ent, createdEntities )

    -- Update parameters in case the limits/console variables are not set to default
    self:SetReloadDelay( self.reloadDelay )
    self:SetMissileLifetime( self.missileLifetime )
    self:SetExplosionRadius( self.explosionRadius )
    self:SetExplosionDamage( self.explosionDamage )
end

local function MakeSpawner( ply, data )
    if IsValid( ply ) and not ply:CheckLimit( "glide_missile_launchers" ) then return end

    local ent = ents.Create( data.Class )
    if not IsValid( ent ) then return end

    ent:SetPos( data.Pos )
    ent:SetAngles( data.Angle )
    ent:SetCreator( ply )
    ent:Spawn()
    ent:Activate()

    ply:AddCount( "glide_missile_launchers", ent )
    cleanup.Add( ply, "glide_missile_launchers", ent )

    for k, v in pairs( data ) do
        if ENT_VARS[k] then ent[k] = v end
    end

    return ent
end

duplicator.RegisterEntityClass( "glide_missile_launcher", MakeSpawner, "Data" )

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

    self.reloadDelay = 1
    self.missileLifetime = 5
    self.explosionRadius = 350
    self.explosionDamage = 100

    self.missileModel = "models/glide/weapons/homing_rocket.mdl"
    self.missileScale = 1

    self.isFiring = false
    self.nextShoot = 0
    self.homingTarget = NULL

    if WireLib then
        WireLib.CreateSpecialInputs( self,
            { "Fire", "Delay", "Damage", "Radius", "Target" },
            { "NORMAL", "NORMAL", "NORMAL", "NORMAL", "ENTITY" }
        )
    end
end

local CurTime = CurTime
local FireMissile = Glide.FireMissile

function ENT:Think()
    local t = CurTime()

    if self.isFiring and t > self.nextShoot then
        self.nextShoot = t + self.reloadDelay

        local dir = self:GetUp()
        local pos = self:GetPos() + dir * 10
        local ang = dir:Angle()

        local parent = self:GetParent()

        if not IsValid( parent ) then
            parent = self
        end

        local missile = FireMissile( pos, ang, self:GetCreator(), parent, self.homingTarget )
        missile.radius = self.explosionRadius
        missile.damage = self.explosionDamage
        missile.lifeTime = t + self.missileLifetime

        missile:SetModel( self.missileModel )
        missile:SetModelScale( self.missileScale )
    end

    self:NextThink( t )

    return true
end

local cvarMinDelay = GetConVar( "glide_missile_launcher_min_delay" )
local cvarMaxLifetime = GetConVar( "glide_missile_launcher_max_lifetime" )
local cvarMaxRadius = GetConVar( "glide_missile_launcher_max_radius" )
local cvarMaxDamage = GetConVar( "glide_missile_launcher_max_damage" )

function ENT:SetReloadDelay( delay )
    self.reloadDelay = math.Clamp( delay, cvarMinDelay and cvarMinDelay:GetFloat() or 0.5, 5 )
end

function ENT:SetMissileLifetime( time )
    self.missileLifetime = math.Clamp( time, 1, cvarMaxLifetime and cvarMaxLifetime:GetFloat() or 10 )
end

function ENT:SetExplosionRadius( radius )
    self.explosionRadius = math.Clamp( radius, 50, cvarMaxRadius and cvarMaxRadius:GetFloat() or 500 )
end

function ENT:SetExplosionDamage( damage )
    self.explosionDamage = math.Clamp( damage, 1, cvarMaxDamage and cvarMaxDamage:GetFloat() or 200 )
end

function ENT:SetMissileModel( model )
    if not Glide.IsValidModel( model ) then return end

    local modelData = list.Get( "GlideProjectileModels" )[model]
    if not modelData then return end

    self.missileModel = model
end

function ENT:SetMissileScale( scale )
    self.missileScale = math.Clamp( scale, 0.5, 3 )
end

function ENT:TriggerInput( name, value )
    if name == "Fire" then
        self.isFiring = value > 0

    elseif name == "Delay" then
        self:SetReloadDelay( value )

    elseif name == "Radius" then
        self:SetExplosionRadius( value )

    elseif name == "Damage" then
        self:SetExplosionDamage( value )

    elseif name == "Target" then
        self.homingTarget = value
    end
end
