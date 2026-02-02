local IsValid = IsValid

function Glide.CreateTurret( vehicle, offset, angles )
    local turret = ents.Create( "glide_vehicle_turret" )

    if not turret or not IsValid( turret ) then
        vehicle:Remove()
        error( "Failed to spawn turret! Vehicle removed!" )
        return
    end

    vehicle:DeleteOnRemove( turret )

    if vehicle.turretCount then
        vehicle.turretCount = vehicle.turretCount + 1
    end

    turret:SetParent( vehicle )
    turret:SetLocalPos( offset )
    turret:SetLocalAngles( angles )
    turret:Spawn()

    return turret
end

function Glide.FireMissile( pos, ang, attacker, parent, target )
    if not IsValid( attacker ) and IsValid( parent ) then
        attacker = parent:GetCreator()
    end

    local missile = ents.Create( "glide_missile" )
    missile:SetPos( pos )
    missile:SetAngles( ang )
    missile:Spawn()
    missile:SetupMissile( attacker, parent )

    if IsValid( target ) then
        missile:SetTarget( target )
    end

    return missile
end

function Glide.FireProjectile( pos, ang, attacker, parent )
    if not IsValid( attacker ) and IsValid( parent ) then
        attacker = parent:GetCreator()
    end

    local projectile = ents.Create( "glide_projectile" )
    projectile:SetPos( pos )
    projectile:SetAngles( ang )
    projectile:Spawn()
    projectile:SetupProjectile( attacker, parent )

    return projectile
end

do
    local RandomFloat = math.Rand
    local Effect = util.Effect
    local TraceHull = util.TraceHull
    local EffectData = EffectData

    local pos, ang
    local attacker, inflictor, length
    local damage, spread, explosionRadius

    local ray, rayWater = {}, {}

    local traceData = {
        mins = Vector( -1, -1, -1 ),
        maxs = Vector( 1, 1, 1 ),
        output = ray
    }

    local waterTraceData = {
        mask = MASK_WATER,
        mins = Vector( -1, -1, -1 ),
        maxs = Vector( 1, 1, 1 ),
        output = rayWater
    }

    function Glide.FireBullet( params, traceFilter )
        pos = params.pos
        ang = params.ang

        attacker = params.attacker
        inflictor = params.inflictor or attacker
        spread = params.spread or 0.3

        if params.isExplosive then
            length = params.length or 8000
            damage = 125//params.damage or 25
            explosionRadius = params.explosionRadius or 180
        else
            length = params.length or 30000
            damage = 100//params.damage or 20
        end

        ang[1] = ang[1] + RandomFloat( -spread, spread )
        ang[2] = ang[2] + RandomFloat( -spread, spread )

        local dir = ang:Forward()

        traceData.start = pos
        traceData.endpos = pos + dir * length
        traceData.filter = traceFilter

        -- The trace result is stored on `ray`
        TraceHull( traceData )

        if ray.Hit then
            length = length * ray.Fraction

            waterTraceData.start = traceData.start
            waterTraceData.endpos = traceData.endpos

            -- The trace result is stored on `rayWater`
            TraceHull( waterTraceData )

            if rayWater.Hit then
                local eff = EffectData()
                eff:SetOrigin( rayWater.HitPos )
                eff:SetScale( 13 )

                if bit.band( rayWater.Contents, CONTENTS_SLIME ) == 0 then
                    eff:SetFlags( 0 )
                end

                Effect( "watersplash", eff )
            end
        end

        if params.isExplosive then
            if ray.Hit and not ray.HitSky then
                Glide.CreateExplosion( inflictor, attacker, ray.HitPos, explosionRadius, damage, ray.HitNormal, Glide.EXPLOSION_TYPE.TURRET )
            end

        elseif IsValid( inflictor ) then
            inflictor:FireBullets( {
                Attacker = attacker,
                Damage = damage,
                Force = damage * 2,
                Distance = length,
                Dir = dir,
                Src = pos,
                HullSize = 2,
                Spread = Vector( 0.002, 0.002, 0 ),
                IgnoreEntity = inflictor,
                TracerName = "MuzzleFlash",
                AmmoType = "7.62x51 mm"
            } )
        end

        local eff = EffectData()
        eff:SetOrigin( pos )
        eff:SetStart( pos + dir * length )
        eff:SetScale( params.scale or 1 )
        eff:SetFlags( ray.Hit and 1 or 0 )
        eff:SetEntity( inflictor )

        local color = params.tracerColor

        if color then
            -- Use some unused EffectData fields for the RGB components
            eff:SetColor( 1 )
            eff:SetRadius( color.r )
            eff:SetHitBox( color.g )
            eff:SetMaterialIndex( color.b )
        else
            eff:SetColor( 0 )
        end

        Effect( "glide_tracer", eff )

        local shellDir = params.shellDirection

        if shellDir then
            eff = EffectData()
            eff:SetAngles( shellDir:Angle() )
            eff:SetOrigin( pos - dir * 30 )
            eff:SetEntity( inflictor )
            eff:SetMagnitude( 1 )
            eff:SetRadius( 5 )
            eff:SetScale( 1 )
            Effect( "RifleShellEject", eff )
        end
    end
end

do
    local BlastDamage = util.BlastDamage
    local GetNearbyPlayers = Glide.GetNearbyPlayers

    --- Utility function to deal damage and send a explosion event to nearby players.
    function Glide.CreateExplosion( inflictor, attacker, origin, radius, damage, normal, explosionType )
        if not IsValid( inflictor ) then return end

        if not IsValid( attacker ) then
            attacker = inflictor
        end

        -- Deal damage
        BlastDamage( inflictor, attacker, origin, radius, damage )

        -- Let nearby players handle sounds and effects client side
        local targets, count = GetNearbyPlayers( origin, Glide.MAX_EXPLOSION_DISTANCE )

        -- Always let the attacker see/hear it too, if they are a player
        if attacker:IsPlayer() then
            count = count + 1
            targets[count] = attacker
        end

        if count == 0 then return end

        Glide.StartCommand( Glide.CMD_CREATE_EXPLOSION, true )
        net.WriteVector( origin )
        net.WriteVector( normal )
        net.WriteUInt( explosionType, 2 )
        net.Send( targets )

        util.ScreenShake( origin, explosionType == 2 and 0.5 or 5, 0.5, 1.0, 1500, true )
    end
end

do
    local TraceLine = util.TraceLine
    local ray = {}
    local traceData = { output = ray }

    --- Returns true if the target entity can be locked on from a starting position and direction.
    --- Part of that includes checking if the dot product between `normal` and
    --- the direction towards the target entity is larger than `threshold`.
    --- `attacker` is the player who is trying to lock-on.
    --- Set `includeEmpty` to true to include vehicles without a driver.
    --- `traceFilter` is a optional list of entities/classes to ignore when performing visibility checks.
    function Glide.CanLockOnEntity( ent, origin, normal, threshold, maxDistance, attacker, includeEmpty, traceFilter )
        if not includeEmpty and ent.GetDriver and ent:GetDriver() == NULL then
            return false -- Don't lock on empty seats
        end

        maxDistance = maxDistance * maxDistance

        local entPos = ent:LocalToWorld( ent:OBBCenter() )
        local diff = entPos - origin

        -- Is the entity too far away?
        if diff:LengthSqr() > maxDistance then return false end
        if not ent:TestPVS( origin ) then return false end

        -- Is the entity within the field of view threshold?
        diff:Normalize()
        local dot = diff:Dot( normal )
        if dot < threshold then return false end

        -- Check if other addons don't want the `attacker` to lock on this entity
        if hook.Run( "Glide_CanLockOn", ent, attacker ) == false then
            return false
        end

        traceData.start = origin
        traceData.endpos = entPos
        traceData.filter = traceFilter

        -- The trace result is stored on `ray`
        TraceLine( traceData )

        if not ray.Hit then return true, dot end

        -- Check if the trace hit the target directly
        if ray.Entity == ent then return true, dot end

        -- Check if the trace hit the target's parent
        return IsValid( ray.Entity ) and ent:GetParent() == ray.Entity, dot
    end
end

local EntityMeta = FindMetaTable( "Entity" )
local getClass = EntityMeta.GetClass
local getParent = EntityMeta.GetParent

local AllEnts = ents.Iterator
local WHITELIST = Glide.LOCKON_WHITELIST

local function IsLockableEntity( ent, skipParentCheck )
    if ent == NULL then return false end

    local class = getClass( ent )

    -- Checks for parent vehicles, like for example glide
    if class == "prop_vehicle_prisoner_pod" and not skipParentCheck then
        local parent = getParent( ent )

        -- Check directly against NULL as getParent returns a clean NULL object and it's faster than IsValid
        if parent ~= NULL then
            if IsLockableEntity( parent, true ) then
                return false
            end
            return true
        end
    end

    if WHITELIST[class] then
        return true
    end

    if ent:IsVehicle() then
        return true
    end

    if ent.IsVJBaseSNPC_TankChassis then
        return true
    end

    if ent.BaseClass and WHITELIST[ent.BaseClass.ClassName] then
        return true
    end

    return false
end

local CanLockOnEntity = Glide.CanLockOnEntity

--- Finds all entities that we can lock on with `Glide.CanLockOnEntity`,
--- then returns which one has the largest dot product between `normal` and the direction towards it.
function Glide.FindLockOnTarget( origin, normal, threshold, maxDistance, attacker, traceFilter, entFilter )
    local largestDot = 0
    local canLock, dot, target

    local includeEmpty = attacker:GetInfoNum( "glide_homing_launcher_lock_on_empty", 0 )
    includeEmpty = includeEmpty and includeEmpty > 0 -- Could be nil

    local ignore = {}

    if entFilter then
        for _, ent in ipairs( entFilter ) do
            ignore[ent] = true
        end
    end

    for _, e in AllEnts() do
        if e ~= attacker and not ignore[e] and IsLockableEntity( e ) then
            canLock, dot = CanLockOnEntity( e, origin, normal, threshold, maxDistance, attacker, includeEmpty, traceFilter )

            if canLock and dot > largestDot then
                largestDot = dot
                target = e
            end
        end
    end

    return target
end
