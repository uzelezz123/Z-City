include( "shared.lua" )

--- Implement this base class function.
function ENT:ShouldActivateSounds()
    return self:GetPower() > 0.1
end

local Clamp = math.Clamp
local Effect = util.Effect
local EffectData = EffectData

--- Implement this base class function.
function ENT:OnUpdateParticles()
    local health = self:GetEngineHealth()
    if health > 0.5 then return end

    local velocity = self:GetVelocity()
    local normal = -self:GetForward()
    local power = self:GetPower()

    health = Clamp( health * 255, 0, 255 )

    for _, pos in ipairs( self.ExhaustPositions ) do
        local eff = EffectData()
        eff:SetOrigin( self:LocalToWorld( pos ) )
        eff:SetNormal( normal )
        eff:SetColor( health )
        eff:SetMagnitude( power * 1000 )
        eff:SetStart( velocity )
        eff:SetScale( 1 )
        Effect( "glide_damaged_exhaust", eff, true, true )
    end
end

local RealTime = RealTime
local DrawLight = Glide.DrawLight
local DrawLightSprite = Glide.DrawLightSprite

--- Implement this base class function.
function ENT:OnUpdateMisc()
    if self:GetDriver() == NULL and self:GetPower() < 0.1 then return end

    -- Update strobe lights
    local t = RealTime()
    local on, pos, color

    t = t % 1

    for i, v in ipairs( self.StrobeLights ) do
        on = t > v.blinkTime and t < v.blinkTime + ( v.blinkDuration or 0.05 )

        if on then
            pos = self:LocalToWorld( v.offset )
            color = self.StrobeLightColors[i]

            if self.StrobeLightRadius > 0 then
                DrawLight( pos, color, self.StrobeLightRadius )
            end

            DrawLightSprite( pos, nil, self.StrobeLightSpriteSize, color )
        end
    end
end
