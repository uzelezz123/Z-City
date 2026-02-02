include( "shared.lua" )

local EntityMeta = FindMetaTable( "Entity" )
local getTable = EntityMeta.GetTable

function ENT:Initialize()
    self.isActive = false
    self.modelCD = 0
    self.particleCD = 0

    self.sounds = {}
    self.soundSurface = {}

    self.enableParticles = true
    self.enableSkidmarks = true
end

function ENT:OnRemove()
    self:CleanupSounds()
end

function ENT:CleanupSounds()
    self.lastSkidId = nil
    self.lastRollId = nil

    for _, snd in pairs( self.sounds ) do
        snd:Stop()
    end

    table.Empty( self.sounds )
    table.Empty( self.soundSurface )
end

local Clamp = math.Clamp

function ENT:ProcessSound( vehicle, id, surfaceId, soundSet, altSurface, volume, pitch )
    if not self:GetSoundsEnabled() then return end

    local path = vehicle:OverrideWheelSound( id, surfaceId ) or soundSet[surfaceId]
    local snd = self.sounds[id]

    -- Remove the sound if we're on the air, or the volume is too low,
    -- or we are missing a sound path/alternative sound path for this surface.
    if surfaceId == 0 or volume < 0.01 or ( not path and not altSurface ) then
        if snd then
            snd:Stop()
            self.sounds[id] = nil
        end

        return
    end

    -- Remove the sound if the surface has changed since the last call
    if surfaceId ~= self.soundSurface[id] then
        self.soundSurface[id] = surfaceId

        if snd then
            self.sounds[id] = nil
            snd:Stop()
            snd = nil
        end
    end

    if not snd then
        snd = CreateSound( self, path or soundSet[altSurface] )
        snd:SetSoundLevel( 80 )
        snd:PlayEx( 0, 100 )
        self.sounds[id] = snd
    end

    snd:ChangeVolume( volume )
    snd:ChangePitch( pitch )
end

local WHEEL_SOUNDS = Glide.WHEEL_SOUNDS
local ROLL_VOLUME = Glide.WHEEL_SOUNDS.ROLL_VOLUME
local ROLL_MARK_SURFACES = Glide.ROLL_MARK_SURFACES

local AddSkidMarkPiece = Glide.AddSkidMarkPiece
local AddTireRollPiece = Glide.AddTireRollPiece

local IsValid = IsValid
local CurTime = CurTime
local Abs = math.abs

local Effect = util.Effect
local EffectData = EffectData
local IsUnderWater = Glide.IsUnderWater

local m = Matrix()
local MAT_SLOSH = MAT_SLOSH

function ENT:Think()
    local t = CurTime()

    local selfTbl = getTable( self )
    self:SetNextClientThink( t + 0.01 )

    -- Periodically rotate and resize the wheel model
    if t > selfTbl.modelCD then
        m:SetTranslation( self:GetModelOffset() )
        m:SetAngles( self:GetModelAngle() )
        m:SetScale( self:GetModelScale2() )
        self:EnableMatrix( "RenderMultiply", m )
        selfTbl.modelCD = t + 1
    end

    local parent = self:GetParent()
    if not IsValid( parent ) then return true end
    if not parent.rfMisc then return true end

    -- Stop processing when the "rfMisc" RangedFeature
    -- from our parent vehicle is not active.
    -- (When the player is too far away or out of the PVS).
    local isActive = parent.rfMisc.isActive
    if not isActive then return true end

    local velocity = parent:GetVelocity()
    local speed = Abs( parent:WorldToLocal( parent:GetPos() + velocity )[1] )

    local up = parent:GetUp()
    local surfaceId = self:GetContactSurface()
    local contactPos = self:GetPos() - up * self:GetRadius()

    -- Force water surface when contactPos is under water 
    if surfaceId > 0 and IsUnderWater( contactPos ) then
        surfaceId = MAT_SLOSH
    end

    -- Mute concrete sounds when this wheel is part of a tank
    local muteRollSound = surfaceId == 67 and parent.VehicleType == 5

    -- Fast roll sound
    local fastFactor = speed / 600

    self:ProcessSound( parent, "fastRoll", surfaceId, WHEEL_SOUNDS.ROLL, nil,
        Clamp( fastFactor * 0.75, 0, ROLL_VOLUME[surfaceId] or 0.4 ), 70 + 25 * fastFactor )

    -- Slow roll sound
    local slowFactor = muteRollSound and 0 or 1.02 - fastFactor

    self:ProcessSound( parent, "slowRoll", surfaceId, WHEEL_SOUNDS.ROLL_SLOW, 88,
        slowFactor * fastFactor * 2, 110 - 30 * slowFactor )

    -- Side slip sound
    local sideSlipFactor = muteRollSound and 0 or Abs( self:GetSideSlip() ) - 0.1

    sideSlipFactor = Clamp( sideSlipFactor * 1.5, 0, 0.8 )

    self:ProcessSound( parent, "sideSlip", surfaceId, WHEEL_SOUNDS.SIDE_SLIP, nil,
        sideSlipFactor, 110 - 30 * sideSlipFactor )

    -- Forward slip sound
    local forwardSlip = self:GetForwardSlip() * 0.04
    local forwardSlipFactor = Clamp( Abs( forwardSlip ) - 0.1, 0, 1 )

    self:ProcessSound( parent, "forwardSlip", surfaceId, WHEEL_SOUNDS.FORWARD_SLIP, 88,
        forwardSlipFactor, 100 - forwardSlipFactor * 10 )

    if muteRollSound then
        selfTbl.lastSkidId = nil
        selfTbl.lastRollId = nil

        return true
    end

    if t < selfTbl.particleCD then
        return true
    end

    selfTbl.particleCD = t + 0.05

    -- Emit side slip/tire roll particles
    local particleSize = Clamp( self:GetRadius(), 5, 10 )
    local rollFactor = sideSlipFactor - 0.5

    if ROLL_MARK_SURFACES[surfaceId] or surfaceId == MAT_SLOSH then
        rollFactor = rollFactor + fastFactor
    end

    if rollFactor > 0.1 and selfTbl.enableParticles then
        rollFactor = Clamp( rollFactor, 0, 0.5 )

        local eff = EffectData()
        eff:SetOrigin( contactPos )
        eff:SetStart( velocity )
        eff:SetSurfaceProp( surfaceId )
        eff:SetScale( particleSize * rollFactor )
        eff:SetEntity( parent )
        Effect( "glide_tire_roll", eff )
    end

    if forwardSlipFactor > 0.2 and selfTbl.enableParticles then
        forwardSlipFactor = Clamp( forwardSlipFactor, 0, 1 )

        local eff = EffectData()
        eff:SetOrigin( contactPos )
        eff:SetSurfaceProp( surfaceId )
        eff:SetScale( particleSize * forwardSlipFactor )
        eff:SetNormal( parent:GetForward() * ( forwardSlip > 1 and 1 or -1 ) )
        eff:SetEntity( parent )
        Effect( "glide_tire_slip_forward", eff )
    end

    if surfaceId == MAT_SLOSH then
        selfTbl.lastSkidId = nil
        selfTbl.lastRollId = nil
        return true
    end

    if not selfTbl.enableSkidmarks then return true end

    -- Create skidmarks
    local skidmarkSize = self:GetRadius() * parent.WheelSkidmarkScale

    contactPos = contactPos + velocity * 0.04

    if ROLL_MARK_SURFACES[surfaceId] then
        if Abs( fastFactor ) + forwardSlipFactor + sideSlipFactor > 0.01 then
            selfTbl.lastRollId = AddTireRollPiece( selfTbl.lastRollId, contactPos, velocity, up, skidmarkSize, 1 )
        else
            selfTbl.lastRollId = nil
        end

        -- Don't create skidmarks if this surface uses roll marks
        selfTbl.lastSkidId = nil
        return true
    end

    selfTbl.lastRollId = nil

    local totalSlipFactor = Clamp( forwardSlipFactor + sideSlipFactor, 0, 1 )

    if totalSlipFactor > 0.3 then
        selfTbl.lastSkidId = AddSkidMarkPiece( selfTbl.lastSkidId, contactPos, velocity, up, skidmarkSize, totalSlipFactor )
    else
        selfTbl.lastSkidId = nil
    end

    return true
end
