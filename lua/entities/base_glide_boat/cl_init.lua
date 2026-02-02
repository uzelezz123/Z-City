include( "shared.lua" )

DEFINE_BASECLASS( "base_glide" )

ENT.AutomaticFrameAdvance = true

--- Implement this base class function.
function ENT:OnPostInitialize()
    self.streamJSONOverride = nil
end

local GetVolume = Glide.Config.GetVolume

--- Implement this base class function.
function ENT:OnTurnOn()
    if self.StartedSound ~= "" then
        Glide.PlaySoundSet( self.StartedSound, self, GetVolume( "carVolume" ), nil, 85 )
    end
end

--- Implement this base class function.
function ENT:OnTurnOff()
    if self.StoppedSound ~= "" then
        Glide.PlaySoundSet( self.StoppedSound, self, GetVolume( "carVolume" ), nil, 85 )
    end

    self:DeactivateSounds()
end

--- Implement this base class function.
function ENT:OnDeactivateSounds()
    if self.stream then
        self.stream:Destroy()
        self.stream = nil
    end
end

--- Implement this base class function.
function ENT:OnUpdateMisc()
    self:OnUpdateAnimations()
end

local Abs = math.abs
local Clamp = math.Clamp
local FrameTime = FrameTime

--- Implement this base class function.
function ENT:OnUpdateSounds()
    local sounds = self.sounds

    local dt = FrameTime()
    local isHonking = self:GetIsHonking()

    if isHonking and self.HornSound then
        local volume = GetVolume( "hornVolume" )

        if sounds.horn then
            sounds.horn:ChangeVolume( volume )
        else
            local snd = self:CreateLoopingSound( "horn", self.HornSound, 85, self )
            snd:PlayEx( volume, 100 )
        end

    elseif sounds.horn then
        if sounds.horn:GetVolume() > 0 then
            sounds.horn:ChangeVolume( sounds.horn:GetVolume() - dt * 8 )
        else
            sounds.horn:Stop()
            sounds.horn = nil
        end
    end

    self:DoWaterSounds()

    if not self:IsEngineOn() then return end

    local stream = self.stream

    if not stream then
        self.stream = Glide.CreateEngineStream( self )

        if self.streamJSONOverride then
            self.stream:LoadJSON( self.streamJSONOverride )
        else
            self:OnCreateEngineStream( self.stream )
        end

        self.stream:Play()

        return
    end

    stream.firstPerson = self.isLocalPlayerInFirstPerson

    local inputs = stream.inputs

    inputs.rpmFraction = self:GetEnginePower()
    inputs.throttle = Abs( self:GetEngineThrottle() )

    -- Handle damaged engine sounds
    local health = self:GetEngineHealth()

    if health < 0.4 then
        if sounds.runDamaged then
            sounds.runDamaged:ChangePitch( 100 + inputs.rpmFraction * 20 )
            sounds.runDamaged:ChangeVolume( Clamp( ( 1 - health ) + inputs.throttle, 0, 1 ) * 0.5 )
        else
            local snd = self:CreateLoopingSound( "runDamaged", "glide/engines/run_damaged_1.wav", 75, self )
            snd:PlayEx( 0.5, 100 )
        end

    elseif sounds.runDamaged then
        sounds.runDamaged:Stop()
        sounds.runDamaged = nil
    end
end

local Effect = util.Effect
local EffectData = EffectData

local DEFAULT_ANG = Angle()

--- Implement this base class function.
function ENT:OnUpdateParticles()
    self:DoWaterParticles( self:GetEnginePower(), self:GetEngineThrottle() )

    local health = self:GetEngineHealth()
    if health > 0.5 then return end

    local color = Clamp( health * 255, 0, 255 )
    local velocity = self:GetVelocity()
    local scale = 2 - health * 2

    eff = EffectData()

    for _, v in ipairs( self.EngineSmokeStrips ) do
        eff:SetOrigin( self:LocalToWorld( v.offset ) )
        eff:SetAngles( self:LocalToWorldAngles( v.angle or DEFAULT_ANG ) )
        eff:SetStart( velocity )
        eff:SetColor( color )
        eff:SetMagnitude( v.width * 1000 )
        eff:SetScale( scale )
        eff:SetRadius( self.EngineSmokeMaxZVel )
        Effect( "glide_damaged_engine", eff, true, true )
    end
end
