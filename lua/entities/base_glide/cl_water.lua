local PlaySoundSet = Glide.PlaySoundSet

function ENT:OnWaterStateChange( _, _, state )
    local speed = self:GetVelocity():Length()

    if state > 0 and state < 3 and speed > 10 then
        PlaySoundSet( self.FallOnWaterSound, self, speed / 400 )
    end
end

local Abs = math.abs
local Clamp = math.Clamp
local FrameTime = FrameTime
local ExpDecay = Glide.ExpDecay

--- Children classes have to manually call this function
--- for water sounds to work.
function ENT:DoWaterSounds()
    local dt = FrameTime()
    local sounds = self.sounds

    local localVelocity = self:WorldToLocal( self:GetPos() + self:GetVelocity() )
    local speed = localVelocity:Length()
    local waterState = self:GetWaterState()

    if waterState > 0 and speed > 50 then
        local vol = Clamp( speed / 1000, 0, 1 ) * self.FastWaterVolume
        local pitch = self.FastWaterPitch + ( self.FastWaterPitch * vol * 0.5 )

        if sounds.fastWater then
            sounds.fastWater:ChangeVolume( vol )
            sounds.fastWater:ChangePitch( pitch )
        else
            local snd = self:CreateLoopingSound( "fastWater", self.FastWaterLoop, 85, self )
            snd:PlayEx( vol, pitch )
        end

    elseif sounds.fastWater then
        sounds.fastWater:Stop()
        sounds.fastWater = nil
    end

    if waterState > 0 and speed < 300 then
        local vol = 1 - Clamp( speed / 300, 0, 1 )
        vol = vol * self.CalmWaterVolume

        if sounds.calmWater then
            sounds.calmWater:ChangeVolume( vol )
        else
            local snd = self:CreateLoopingSound( "calmWater", self.CalmWaterLoop, 65, self )
            snd:PlayEx( vol, self.CalmWaterPitch )
        end

    elseif sounds.calmWater then
        sounds.calmWater:Stop()
        sounds.calmWater = nil
    end

    local sideSlide = Clamp( Abs( localVelocity[2] / 500 ), 0, 1 )

    sideSlide = ExpDecay( self.waterSideSlide, waterState > 0 and sideSlide or 0, 4, dt )
    self.waterSideSlide = sideSlide

    if sideSlide > 0.1 then
        sideSlide = sideSlide * self.WaterSideSlideVolume

        if sounds.waterSlide then
            sounds.waterSlide:ChangeVolume( sideSlide )
        else
            local snd = self:CreateLoopingSound( "waterSlide", self.WaterSideSlideLoop, 85, self )
            snd:PlayEx( sideSlide, self.WaterSideSlidePitch )
        end

    elseif sounds.waterSlide then
        sounds.waterSlide:Stop()
        sounds.waterSlide = nil
    end
end

local Effect = util.Effect
local EffectData = EffectData
local IsUnderWater = Glide.IsUnderWater

--- Children classes have to manually call this function
--- for water particles to work.
function ENT:DoWaterParticles( power, throttle )
    local vel = self:GetVelocity()

    -- Propeller "throws water upwards" effect
    if throttle > 0.1 then
        local eff = EffectData()
        local dir = -self:GetForward()

        throttle = ( throttle * 0.5 ) + Clamp( power * 2, 0, 1 ) * 0.5

        for _, offset in ipairs( self.PropellerPositions ) do
            offset = self:LocalToWorld( offset )

            if IsUnderWater( offset ) then
                eff:SetOrigin( offset )
                eff:SetStart( vel )
                eff:SetNormal( dir )
                eff:SetScale( 1 )
                eff:SetMagnitude( throttle )
                Effect( "glide_boat_propeller", eff )
            end
        end
    end

    local waterState = self:GetWaterState()
    local speed = vel:Length()

    if waterState > 0 and speed > 50 then
        local right = self:GetRight()
        local mins, maxs = self:OBBMins(), self:OBBMaxs()

        local pos = Vector( mins[1] * 0.8, 0, mins[3] )
        local magnitude = Clamp( speed / 1000, 0, 1 )
        local scale = self.WaterParticlesScale

        -- Waves left behind the vehicle
        local eff = EffectData()
        eff:SetOrigin( self:LocalToWorld( pos ) )
        eff:SetStart( vel )
        eff:SetScale( scale )
        eff:SetMagnitude( magnitude )
        Effect( "glide_boat_foam", eff )

        if waterState > 1 then
            -- How long is the "strip" of water splashes on each side?
            local length = maxs[1] * 0.75

            -- Right-side water splashes
            pos[1] = 0
            pos[2] = mins[2] * 0.75

            eff:SetOrigin( self:LocalToWorld( pos ) )
            eff:SetScale( scale )
            eff:SetNormal( right )
            eff:SetRadius( length )
            Effect( "glide_boat_splash", eff )

            -- Left-side water splashes
            pos[2] = maxs[2] * 0.75

            eff:SetOrigin( self:LocalToWorld( pos ) )
            eff:SetScale( scale )
            eff:SetNormal( -right )
            eff:SetRadius( length )
            Effect( "glide_boat_splash", eff )
        end
    end
end
