include( "shared.lua" )

function ENT:Initialize()
    self:SetPredictable( true )
end

function ENT:OnRemove()
    if self.shootSound then
        self.shootSound:Stop()
        self.shootSound = nil
    end
end

function ENT:UpdateSounds()
    local loopPath = self:GetShootLoopSound()

    if self:GetIsFiring() and loopPath ~= "" then
        if not self.shootSound then
            self.shootSound = CreateSound( self, loopPath )
            self.shootSound:SetSoundLevel( 85 )
            self.shootSound:PlayEx( 1.0, 100 )
        end

    elseif self.shootSound then
        self.shootSound:Stop()
        self.shootSound = nil

        local stopPath = self:GetShootStopSound()

        if stopPath ~= "" then
            self:EmitSound( stopPath, 85, 100, 1.0 )
        end
    end
end
