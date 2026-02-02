include( "shared.lua" )
include( "cl_lights.lua" )
include( "cl_hud.lua" )
include( "cl_water.lua" )
include( "sh_vehicle_compat.lua" )

ENT.AutomaticFrameAdvance = true

function ENT:OnReloaded()
    -- Let UpdateHeadlights recreate the lights
    self.headlightState = 0

    -- Let children classes do their own logic
    self:OnEntityReload()
end

function ENT:Initialize()
    self.isLazyThink = false
    self.lazyThinkCD = 0

    self.sounds = {}
    self.waterSideSlide = 0
    self.isLocalPlayerInFirstPerson = false

    self.weapons = {}
    self.weaponSlotIndex = 0

    -- Create a RangedFeature to handle engine sounds
    self.rfSounds = Glide.CreateRangedFeature( self, self.MaxSoundDistance )
    self.rfSounds:SetTestCallback( "ShouldActivateSounds" )
    self.rfSounds:SetActivateCallback( "ActivateSounds" )
    self.rfSounds:SetDeactivateCallback( "DeactivateSounds" )
    self.rfSounds:SetUpdateCallback( "UpdateSounds" )

    -- Create a RangedFeature to handle misc. features, such as particles and animations
    self.rfMisc = Glide.CreateRangedFeature( self, self.MaxMiscDistance )
    self.rfMisc:SetActivateCallback( "ActivateMisc" )
    self.rfMisc:SetDeactivateCallback( "DeactivateMisc" )
    self.rfMisc:SetUpdateCallback( "UpdateMisc" )

    self:OnPostInitialize()
end

function ENT:OnRemove( fullUpdate )
    if self.lockOnSound then
        self.lockOnSound:Stop()
        self.lockOnSound = nil
    end

    if fullUpdate then return end

    if self.rfSounds then
        self.rfSounds:Destroy()
        self.rfSounds = nil
    end

    if self.rfMisc then
        self.rfMisc:Destroy()
        self.rfMisc = nil
    end
end

function ENT:OnEngineStateChange( _, lastState, state )
    if state == 1 then
        -- If we have a "startup" sound, play it now.
        if self.rfSounds and self.rfSounds.isActive and self.StartSound and self.StartSound ~= "" then
            local snd = self:CreateLoopingSound( "start", Glide.GetRandomSound( self.StartSound ), 70, self )
            snd:PlayEx( 1, 100 )
        end

    elseif lastState ~= 3 and state == 2 then
        self:OnTurnOn()

    elseif state == 0 then
        self:OnTurnOff()
    end
end

local IsValid = IsValid

function ENT:GetWheelSpin( index )
    local wheel = self.wheels and self.wheels[index]

    if IsValid( wheel ) and wheel.GetLastSpin then
        return wheel:GetLastSpin()
    end

    return 0
end

function ENT:GetWheelOffset( index )
    local wheel = self.wheels and self.wheels[index]

    if IsValid( wheel ) and wheel.GetLastOffset then
        return wheel:GetLastOffset()
    end

    return 0
end

--- Create a new looping sound and store it on the slot `id`.
--- This sound will automatically be stopped when the
--- `rfSounds` RangedFeature is deactivated.
function ENT:CreateLoopingSound( id, path, level, parent )
    local snd = self.sounds[id]

    if not snd then
        snd = CreateSound( parent or self, path )
        snd:SetSoundLevel( level )
        self.sounds[id] = snd
    end

    return snd
end

function ENT:ActivateSounds()
    self.waterSideSlide = 0

    -- Let children classes do their own thing
    self:OnActivateSounds()
end

function ENT:DeactivateSounds()
    -- Remove all sounds we've created so far
    local sounds = self.sounds

    for k, snd in pairs( sounds ) do
        snd:Stop()
        sounds[k] = nil
    end

    -- Let children classes cleanup their own sounds
    self:OnDeactivateSounds()
end

function ENT:UpdateSounds()
    if not self.isLazyThink then
        local signal = self:GetTurnSignalState()

        if signal > 0 and self.TurnSignalVolume > 0 then
            local signalBlink = ( CurTime() % self.TurnSignalCycle ) > self.TurnSignalCycle * 0.5

            if self.lastSignalBlink ~= signalBlink then
                self.lastSignalBlink = signalBlink

                if signalBlink and self.TurnSignalTickOnSound ~= "" then
                    self:EmitSound( self.TurnSignalTickOnSound, 65, self.TurnSignalPitch, self.TurnSignalVolume )

                elseif not signalBlink and self.TurnSignalTickOffSound ~= "" then
                    self:EmitSound( self.TurnSignalTickOffSound, 65, self.TurnSignalPitch, self.TurnSignalVolume )
                end
            end
        end

        local sounds = self.sounds

        if sounds.start and self:GetEngineState() ~= 1 then
            sounds.start:Stop()
            sounds.start = nil

            if self.StartTailSound and self.StartTailSound ~= "" then
                Glide.PlaySoundSet( self.StartTailSound, self )
            end
        end
    end

    -- Let children classes handle their own sounds
    self:OnUpdateSounds()
end

local EntityPairs = Glide.EntityPairs

function ENT:ActivateMisc()
    -- Find and store the wheel and seat entities we have
    local wheels = {}
    local seats = {}

    for _, ent in ipairs( self:GetChildren() ) do
        if ent:GetClass() == "glide_wheel" then
            wheels[#wheels + 1] = ent

        elseif ent:IsVehicle() then
            seats[#seats + 1] = ent
        end
    end

    self.wheels = table.Reverse( wheels )
    self.seats = table.Reverse( seats )

    -- Cache player names to display on the HUD
    self.lastNick = {}

    -- Store state for particles and headlights
    self.particleCD = 0
    self.headlightState = nil
    self.activeHeadlights = {}

    -- Let children classes create their own stuff
    self:OnActivateMisc()

    -- Let children classes setup wheels clientside
    for i, w in EntityPairs( self.wheels ) do
        self:OnActivateWheel( w, i )
    end
end

function ENT:DeactivateMisc()
    if self.wheels then
        for _, w in EntityPairs( self.wheels ) do
            w:CleanupSounds()
        end
    end

    if self.engineFireSound then
        self.engineFireSound:Stop()
        self.engineFireSound = nil
    end

    self.wheels = nil
    self.seats = nil
    self.lastNick = nil
    self:RemoveHeadlights()

    -- Let children classes cleanup their own stuff
    self:OnDeactivateMisc()
end

local RealTime = RealTime
local Effect = util.Effect
local DEFAULT_FLAME_ANGLE = Angle()

function ENT:UpdateMisc()
    local t = RealTime()

    -- Keep particles consistent even at high FPS
    if t > self.particleCD and self:WaterLevel() < 3 then
        self.particleCD = t + 0.03
        self:OnUpdateParticles()

        if self:GetIsEngineOnFire() then
            local velocity = self:GetVelocity()
            local eff = EffectData()

            for _, v in ipairs( self.EngineFireOffsets ) do
                eff:SetStart( velocity )
                eff:SetOrigin( self:LocalToWorld( v.offset ) )
                eff:SetAngles( self:LocalToWorldAngles( v.angle or DEFAULT_FLAME_ANGLE ) )
                eff:SetScale( v.scale or 1 )
                Effect( "glide_fire", eff, true, true )
            end
        end
    end

    -- Engine fire sound
    if self:GetIsEngineOnFire() then
        if not self.engineFireSound then
            self.engineFireSound = CreateSound( self, "glide/fire/fire_loop_1.wav" )
            self.engineFireSound:SetSoundLevel( 80 )
            self.engineFireSound:PlayEx( 0.9, 100 )
        end

    elseif self.engineFireSound then
        self.engineFireSound:Stop()
        self.engineFireSound = nil
    end

    -- Update lights and sprites
    self:UpdateLights()

    -- Let children classes do their own stuff
    self:OnUpdateMisc()
end

local LocalPlayer = LocalPlayer

function ENT:Think()
    self:SetNextClientThink( CurTime() )

    -- Run some things less frequently when the
    -- local player is not inside this vehicle.
    local t = RealTime()
    local isLazy = LocalPlayer():GlideGetVehicle() ~= self

    if isLazy and t > self.lazyThinkCD then
        isLazy = false
        self.lazyThinkCD = t + 0.05
    end

    self.isLazyThink = isLazy

    if self.rfSounds then
        self.rfSounds:Think()
    end

    if self.rfMisc then
        self.rfMisc:Think()
    end

    return true
end
