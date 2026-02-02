AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Projectile Launcher"
ENT.Category = "Glide"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

if not SERVER then return end

local ENT_VARS = {
    ["projectileSpeed"] = true,
    ["projectileGravity"] = true,
    ["projectileLifetime"] = true,
    ["reloadDelay"] = true,
    ["explosionRadius"] = true,
    ["explosionDamage"] = true,
    ["smokeColor"] = true,
    ["projectileModel"] = true,
    ["projectileScale"] = true
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
    self:SetProjectileSpeed( self.projectileSpeed )
    self:SetProjectileGravity( self.projectileGravity )
    self:SetProjectileLifetime( self.projectileLifetime )
    self:SetReloadDelay( self.reloadDelay )
    self:SetExplosionRadius( self.explosionRadius )
    self:SetExplosionDamage( self.explosionDamage )
end

local function MakeSpawner( ply, data )
    if IsValid( ply ) and not ply:CheckLimit( "glide_projectile_launchers" ) then return end

    local ent = ents.Create( data.Class )
    if not IsValid( ent ) then return end

    ent:SetPos( data.Pos )
    ent:SetAngles( data.Angle )
    ent:SetCreator( ply )
    ent:Spawn()
    ent:Activate()

    ply:AddCount( "glide_projectile_launchers", ent )
    cleanup.Add( ply, "glide_projectile_launchers", ent )

    for k, v in pairs( data ) do
        if ENT_VARS[k] then ent[k] = v end
    end

    return ent
end

duplicator.RegisterEntityClass( "glide_projectile_launcher", MakeSpawner, "Data" )

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

    self.projectileSpeed = 10000
    self.projectileGravity = 700
    self.projectileLifetime = 5

    self.reloadDelay = 1
    self.explosionRadius = 350
    self.explosionDamage = 100
    self.smokeColor = Vector( 80, 80, 80 )

    self.projectileModel = "models/props_phx/misc/flakshell_big.mdl"
    self.projectileScale = 1

    self.isFiring = false
    self.nextShoot = 0

    if WireLib then
        WireLib.CreateSpecialInputs( self,
            { "Fire", "Delay", "Damage", "Radius" },
            { "NORMAL", "NORMAL", "NORMAL", "NORMAL" }
        )
    end
end

local CurTime = CurTime
local FireProjectile = Glide.FireProjectile

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

        local projectile = FireProjectile( pos, ang, self:GetCreator(), parent )
        projectile.radius = self.explosionRadius
        projectile.damage = self.explosionDamage
        projectile.lifeTime = t + self.projectileLifetime
        projectile:SetProjectileSpeed( self.projectileSpeed )
        projectile:SetProjectileGravity( self.projectileGravity )
        projectile:SetSmokeColor( self.smokeColor )

        projectile:SetModel( self.projectileModel )
        projectile:SetModelScale( self.projectileScale )
    end

    self:NextThink( t )

    return true
end

local cvarMaxLifetime = GetConVar( "glide_projectile_launcher_max_lifetime" )
local cvarMinDelay = GetConVar( "glide_projectile_launcher_min_delay" )
local cvarMaxRadius = GetConVar( "glide_projectile_launcher_max_radius" )
local cvarMaxDamage = GetConVar( "glide_projectile_launcher_max_damage" )

function ENT:SetProjectileSpeed( speed )
    self.projectileSpeed = math.Clamp( speed, 1, 20000 )
end

function ENT:SetProjectileGravity( gravity )
    self.projectileGravity = math.Clamp( gravity, 1, 2000 )
end

function ENT:SetProjectileLifetime( time )
    self.projectileLifetime = math.Clamp( time, 1, cvarMaxLifetime and cvarMaxLifetime:GetFloat() or 10 )
end

function ENT:SetReloadDelay( delay )
    self.reloadDelay = math.Clamp( delay, cvarMinDelay and cvarMinDelay:GetFloat() or 0.5, 5 )
end

function ENT:SetExplosionRadius( radius )
    self.explosionRadius = math.Clamp( radius, 50, cvarMaxRadius and cvarMaxRadius:GetFloat() or 500 )
end

function ENT:SetExplosionDamage( damage )
    self.explosionDamage = math.Clamp( damage, 1, cvarMaxDamage and cvarMaxDamage:GetFloat() or 200 )
end

function ENT:SetSmokeColor( r, g, b )
    local color = self.smokeColor
    color[1] = math.Clamp( r, 0, 255 )
    color[2] = math.Clamp( g, 0, 255 )
    color[3] = math.Clamp( b, 0, 255 )
end

function ENT:SetProjectileModel( model )
    if not Glide.IsValidModel( model ) then return end

    local modelData = list.Get( "GlideProjectileModels" )[model]
    if not modelData then return end

    self.projectileModel = model
end

function ENT:SetProjectileScale( scale )
    self.projectileScale = math.Clamp( scale, 0.5, 3 )
end

function ENT:TriggerInput( name, value )
    if name == "Fire" then
        self.isFiring = value > 0

    elseif name == "Delay" then
        self:SetReloadDelay( value )

    elseif name == "Damage" then
        self:SetExplosionDamage( value )

    elseif name == "Radius" then
        self:SetExplosionRadius( value )
    end
end
