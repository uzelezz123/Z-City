AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Rotor"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.PhysgunDisabled = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true
ENT.WantsTranslucency = true

if not SERVER then return end

local TRACE_MINS = Vector( -10, -10, -1 )
local TRACE_MAXS = Vector( 10, 10, 1 )

function ENT:Initialize()
    -- Should the rotor hit things?
    self.enableTrace = true

    -- How far can the rotor's trace hit?
    self.radius = 100

    -- How fast should the rotor spin at the max. spin multiplier?
    self.maxSpinSpeed = 2000

    -- Rotor will be placed automatically
    -- at this position, relative to the parent.
    self.offset = Vector()

    -- Set default models
    self.modelSlow = "models/hunter/blocks/cube025x7x025.mdl"
    self.modelFast = "models/hunter/plates/plate7.mdl"

    -- Prepare spin variables
    self.baseAngles = Angle()
    self.spinAngle = 0
    self.spinAxis = "Up"
    self.spinMultiplier = 0

    -- Prepare damage & trace variables
    self.rotorHealth = 400
    self.hitSoundCD = 0
    self.traceAngle = 0

    self.traceData = {
        filter = { self, self:GetParent() },
        mask = MASK_SOLID,
        collisiongroup = COLLISION_GROUP_NONE,
        mins = TRACE_MINS,
        maxs = TRACE_MAXS
    }

    self:SetModel( self.modelSlow )
    self:SetSolid( SOLID_NONE )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    --self:DrawShadow( false )
    self:Repair()
end

function ENT:SetupRotor( offset, radius, modelSlow, modelFast )
    self.offset = offset
    self.radius = radius
    self.modelSlow = modelSlow
    self.modelFast = modelFast
    self:SetModel( modelSlow )
end

function ENT:SetBaseAngles( angles )
    self.baseAngles = angles
end

function ENT:SetSpinAngle( ang )
    self.spinAngle = ang
end

local VALID_AXIS = {
    ["Up"] = Vector( 0, 0, 1 ),
    ["Right"] = Vector( 1, 0, 0 ),
    ["Forward"] = Vector( 0, 1, 0 )
}

local AXIS_IDS = {
    [1] = "Right",
    [2] = "Up",
    [3] = "Forward"
}

function ENT:SetSpinAxis( axis )
    if AXIS_IDS[axis] then
        axis = AXIS_IDS[axis]
    end

    assert( VALID_AXIS[axis] ~= nil, "Invalid rotor spin axis! Must be one of these: Up, Right, Forward" )

    self.spinAxis = axis
    self.traceAngle = 0
    self.spinAngle = 0
end

function ENT:Repair()
    self.rotorHealth = 400
end

function ENT:Destroy()
    local eff = EffectData()
    eff:SetOrigin( self:GetPos() )
    eff:SetNormal( Vector( 0, 0, 1 ) )
    eff:SetMagnitude( 8 )
    eff:SetScale( 1 )
    eff:SetRadius( ( self.radius / 200 ) * 50 )
    util.Effect( "HunterDamage", eff )

    self:EmitSound( "Breakable.MatMetal" )
    self:Remove()
end

local CurTime = CurTime
local FrameTime = FrameTime
local TraceHull = util.TraceHull

function ENT:Think()
    -- Destroy when under water
    if self:WaterLevel() > 0 then
        self:Destroy()
        return
    end

    local dt = FrameTime()

    self.spinAngle = ( self.spinAngle + self.maxSpinSpeed * self.spinMultiplier * dt ) % 360

    -- Set position/angles relative to the parent
    local parent = self:GetParent()

    if IsValid( parent ) then
        local angles = parent:LocalToWorldAngles( self.baseAngles )
        angles:RotateAroundAxis( angles[self.spinAxis]( angles ), self.spinAngle )

        self:SetLocalPos( self.offset )
        self:SetAngles( angles )

        -- Pretty colors
        self:SetColor( parent:GetColor() )

        -- Do collision detection
        if self.enableTrace and self.spinMultiplier > 0.2 then
            self:CheckRotorClearance( dt, parent )
        end
    end

    self:NextThink( CurTime() )

    return true
end

local GetDevMode = Glide.GetDevMode

--- Check if the rotor blades are hitting things.
function ENT:CheckRotorClearance( dt, parent )
    -- The trace will use a spinning angle separate from the model
    self.traceAngle = ( self.traceAngle + dt * 1600 ) % 360

    local ang = parent:LocalToWorldAngles( self.baseAngles )
    ang:RotateAroundAxis( ang[self.spinAxis]( ang ), self.traceAngle )

    local dir = self.spinAxis == "Forward" and ang:Right() or ang:Forward()
    local data = self.traceData
    local origin = self:GetPos()

    -- Trace towards the angle direction
    data.start = origin
    data.endpos = origin + dir * self.radius

    if GetDevMode() then
        debugoverlay.Line( data.start, data.endpos, 0.05, Color( 255, 0, 0 ), true )
    end

    local tr = TraceHull( data )

    if tr.Hit and not tr.HitSky and not tr.HitNoDraw and tr.HitTexture ~= "**empty**" then
        self:OnRotorHit( tr.Entity, tr.HitPos, origin )
        return
    end

    -- Another trace on the opposite direction
    data.endpos = origin - dir * self.radius

    tr = TraceHull( data )

    if tr.Hit and not tr.HitSky and not tr.HitNoDraw and tr.HitTexture ~= "**empty**" then
        self:OnRotorHit( tr.Entity, tr.HitPos, origin )
        return
    end
end

local IsValid = IsValid
local DamageInfo = DamageInfo

--- Make an entity take damage from this rotor.
local function DoDamage( rotor, victim, damage, force )
    if not victim.TakeDamageInfo then return end

    local driver = rotor:GetParent():GetDriver()
    local attacker = IsValid( driver ) and driver or rotor

    local dmg = DamageInfo()
    dmg:SetDamage( damage )
    dmg:SetAttacker( attacker )
    dmg:SetInflictor( rotor )
    dmg:SetDamageType( DMG_SLASH )
    dmg:SetDamageForce( force )
    dmg:SetDamagePosition( rotor:GetPos() )
    victim:TakeDamageInfo( dmg )
end

local Effect = util.Effect
local PlaySoundSet = Glide.PlaySoundSet

--- Called when the rotor's trace hits something.
function ENT:OnRotorHit( ent, pos, origin )
    self.rotorHealth = self.rotorHealth - 1

    local parent = self:GetParent()

    if IsValid( parent ) then
        local dmg = DamageInfo()
        dmg:SetDamage( 1 )
        dmg:SetAttacker( ent )
        dmg:SetInflictor( self )
        dmg:SetDamageType( 268435456 ) -- DMG_DIRECT
        dmg:SetDamagePosition( origin )
        parent:TakeDamageInfo( dmg )
    end

    if self.rotorHealth < 0 then
        self:Destroy()

        if IsValid( parent ) then
            parent:TakeEngineDamage( 0.8 )
        end

        return
    end

    local dir = pos - origin
    dir:Normalize()

    local effectName = "ManhackSparks"

    if IsValid( ent ) then
        local isOrganism = ent:IsPlayer() or ent:IsNPC()

        DoDamage( self, ent, ( isOrganism and 80 or 5 ) * self.spinMultiplier, dir * 50000 )

        if isOrganism then
            -- Do some flesh-related hit effects
            effectName = "bloodspray"
            PlaySoundSet( "Glide.Rotor.Slice", ent )

        elseif ent.GetPhysicsObject then
            -- Push the entity away
            local phys = ent:GetPhysicsObject()

            if IsValid( phys ) then
                phys:ApplyForceOffset( dir * 10000, pos )
            end
        end
    end

    -- Emit particle effects
    local effectData = EffectData()
    effectData:SetOrigin( pos )
    effectData:SetNormal( -dir )
    Effect( effectName, effectData, true, true )

    -- Play sound, but not too frequently
    local t = CurTime()

    if t > self.hitSoundCD then
        self.hitSoundCD = t + 0.2
        PlaySoundSet( "Glide.Rotor.Collision", self )
    end
end
