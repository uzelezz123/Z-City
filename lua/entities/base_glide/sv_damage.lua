function ENT:Repair()
    self:SetIsEngineOnFire( false )
    self:SetChassisHealth( self.MaxChassisHealth )
    self:SetEngineHealth( 1.0 )
    self:UpdateHealthOutputs()
end

function ENT:Explode( attacker, inflictor )
    if self.hasExploded then return end
    if not IsValid( self ) then return end

    local creator = Glide.GetEntityCreator( self )
    local phys = self:GetPhysicsObject()

    -- Don't let stuff like collision/damage events
    -- call this again, to prevent infinite loops.
    self.hasExploded = true
    self:SetChassisHealth( 0 )

    attacker = attacker or self:GetDriver() or self:GetCreator() or self
    inflictor = IsValid( inflictor ) and inflictor or self

    -- Damage blast & effects
    Glide.CreateExplosion( inflictor, attacker, self:GetPos(), self.ExplosionRadius, 200, Vector( 0, 0, 1 ), Glide.EXPLOSION_TYPE.VEHICLE )

    -- Damage passengers
    for _, ply in ipairs( self:GetAllPlayers() ) do
        ply:TakeDamage( 999, attacker, inflictor )
    end

    local SetEntityCreator = Glide.SetEntityCreator

    -- Spawn wheel gibs
    if self.wheels and IsValid( phys ) then
        local vehPos = self:GetPos()

        for _, w in Glide.EntityPairs( self.wheels ) do
            if IsValid( w ) and not w:GetNoDraw() then
                local gibPos = w:GetPos()
                local gib = ents.Create( "glide_gib" )
                gib:SetPos( gibPos )
                gib:SetAngles( w:GetAngles() )
                gib:SetModel( w:GetModel() )
                gib:Spawn()
                gib:CopyVelocities( self )

                SetEntityCreator( gib, creator )

                local gibPhys = gib:GetPhysicsObject()
                if IsValid( gibPhys ) then
                    local dir = gibPos - vehPos
                    dir:Normalize()
                    gibPhys:AddVelocity( dir * 300 )
                end
            end
        end
    end

    -- If the `ExplosionGibs` table is empty,
    -- just spawn a gib using this vehicle's model.
    if #self.ExplosionGibs == 0 then
        local gib = ents.Create( "glide_gib" )
        gib:SetPos( self:GetPos() )
        gib:SetAngles( self:GetAngles() )
        gib:SetModel( self:GetModel() )
        gib:Spawn()
        gib:CopyVelocities( self )
        gib:SetOnFire()

        SetEntityCreator( gib, creator )

        for _, v in ipairs( gib:GetBodyGroups() ) do
            gib:SetBodygroup( v.id, 1 )
        end
    else
        -- Spawn gibs given by the `ExplosionGibs` table
        for k, v in ipairs( self.ExplosionGibs ) do
            local gib = ents.Create( "glide_gib" )
            gib:SetPos( self:GetPos() )
            gib:SetAngles( self:GetAngles() )
            gib:SetModel( v )
            gib:Spawn()
            gib:CopyVelocities( self )

            SetEntityCreator( gib, creator )

            if k == 1 then
                gib:SetOnFire()
            end
        end
    end

    self:Remove()
end

function ENT:TakeEngineDamage( amount )
    self:SetEngineHealth( math.max( self:GetEngineHealth() - amount, 0 ) )
end

local IsValid = IsValid

local cvarBullet = GetConVar( "glide_bullet_damage_multiplier" )
local cvarBlast = GetConVar( "glide_blast_damage_multiplier" )

function ENT:OnTakeDamage( dmginfo )
    if self.hasExploded then return end

    local health = self:GetChassisHealth()
    local amount = dmginfo:GetDamage()

    if dmginfo:IsDamageType( 64 ) then -- DMG_BLAST
        amount = amount * self.BlastDamageMultiplier * cvarBlast:GetFloat()

        local phys = self:GetPhysicsObject()

        if IsValid( phys ) then
            local damagePos = dmginfo:GetDamagePosition()
            local damageForce = dmginfo:GetDamageForce() * phys:GetMass() * self.BlastForceMultiplier

            phys:ApplyForceOffset( damageForce, damagePos )
        end

    elseif dmginfo:IsDamageType( 2 ) then -- DMG_BULLET
        amount = amount * self.BulletDamageMultiplier * cvarBullet:GetFloat()
    end

    health = health - amount

    self:SetChassisHealth( health )
    self:TakeEngineDamage( ( amount / self.MaxChassisHealth ) * self.EngineDamageMultiplier )
    self:UpdateHealthOutputs()

    self.lastDamageAttacker = dmginfo:GetAttacker()
    self.lastDamageInflictor = dmginfo:GetInflictor()

    if health / self.MaxChassisHealth < 0.18 and self:WaterLevel() < 3 and self.CanCatchOnFire then
        self:SetIsEngineOnFire( true )
    end

    if health < 1 then
        self:Explode( self.lastDamageAttacker, self.lastDamageInflictor )
    end
end

local RealTime = RealTime
local DamageInfo = DamageInfo
local GetWorld = game.GetWorld

local Clamp = math.Clamp
local RandomInt = math.random
local PlaySoundSet = Glide.PlaySoundSet

local cvarCollision = GetConVar( "glide_physics_damage_multiplier" )
local cvarWorldCollision = GetConVar( "glide_world_physics_damage_multiplier" )

function ENT:PhysicsCollide( data )
    if data.TheirSurfaceProps == 76 then -- default_silent
        return
    end

    local velocityChange = data.OurNewVelocity - data.OurOldVelocity
    local surfaceNormal = data.HitNormal

    local speed = velocityChange:Length()
    if speed < 30 then return end

    if self.FallOnCollision then
        self:PhysicsCollideFall( speed, data )
    end

    local ent = data.HitEntity
    local isPlayer = IsValid( ent ) and ent:IsPlayer()
    local t = RealTime()

    if isPlayer then
        -- Don't let players make loud sounds
        speed = 100

    elseif t > self.collisionShakeCooldown then
        self.collisionShakeCooldown = t + 0.5
        Glide.SendViewPunch( self:GetAllPlayers(), Clamp( speed / 1000, 0, 1 ) * 3 )
    end

    local eff = EffectData()
    eff:SetOrigin( data.HitPos )
    eff:SetScale( math.min( speed * 0.02, 6 ) * self.CollisionParticleSize )
    eff:SetNormal( surfaceNormal )
    util.Effect( "glide_metal_impact", eff )

    local isHardHit = speed > 300

    PlaySoundSet( self.SoftCollisionSound, self, speed / 400, nil, isHardHit and 80 or 75 )

    if isHardHit then
        PlaySoundSet( self.HardCollisionSound, self, speed / 400, nil, isHardHit and 80 or 75 )

        if self.IsHeavyVehicle then
            self:EmitSound( "physics/metal/metal_barrel_impact_hard5.wav", 90, RandomInt( 70, 90 ), 1 )
        end

    elseif isPlayer then
        PlaySoundSet( "Glide.Collision.VehicleHard", ent, speed / 1000, RandomInt( 90, 130 ) )

    elseif surfaceNormal:Dot( -data.HitSpeed:GetNormalized() ) < 0.5 then
        PlaySoundSet( "Glide.Collision.VehicleScrape", self, 0.4 )
    end

    if not isPlayer and isHardHit then
        -- `ent:IsWorld` is returning `false` on "Entity [0][worldspawn]",
        -- so I'm comparing against `game.GetWorld` instead.
        local multiplier = ent == GetWorld() and cvarWorldCollision:GetFloat() or cvarCollision:GetFloat()

        local dmg = DamageInfo()
        dmg:SetAttacker( ent )
        dmg:SetInflictor( self )
        dmg:SetDamage( ( speed / 10 ) * self.CollisionDamageMultiplier * multiplier )
        dmg:SetDamageType( 1 ) -- DMG_CRUSH
        dmg:SetDamagePosition( data.HitPos )
        self:TakeDamageInfo( dmg )
    end
end

function ENT:PhysicsCollideFall( speed, data )
    local ent = data.HitEntity

    if IsValid( ent ) then
        if ent:IsPlayer() or ent:IsNPC() then return end
        if ent:GetClass() == "func_breakable" then return end
    end

    local upDot = self:GetUp():Dot( -data.HitSpeed:GetNormalized() )
    local relativeHitPos = self:WorldToLocal( data.HitPos )

    if upDot < -0.5 and relativeHitPos[3] < 0 then
        -- The hit came from below the vehicle
        speed = speed * 0.2

    elseif upDot > 0.5 and relativeHitPos[3] > 0 then
        -- The hit came from above the vehicle
        speed = speed * 5
    end

    if speed < 600 then return end

    local vel = data.OurOldVelocity * 0.5
    vel[3] = vel[3] + 200

    -- Timer to avoid the "likely crashes the game" warning in console
    timer.Simple( 0, function()
        if IsValid( self ) then
            self:RagdollPlayers( nil, vel )
        end
    end )
end
