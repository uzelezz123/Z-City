EFFECT.Mat = Material("particle/particle_smokegrenade")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Size = 20  
    self.Emitter = ParticleEmitter(self.Position)
    self.LifeTime = 15  

    for i = 1, 60 do  
        local particle = self.Emitter:Add("particle/particle_smokegrenade", self.Position)
        if particle then
            local vel = VectorRand() * 1.5 + Vector(0, 0, math.Rand(50, 80))  
            particle:SetVelocity(vel)
            particle:SetDieTime(math.random(8, 12))  
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(self.Size)
            particle:SetEndSize(self.Size * 2)
            particle:SetRoll(math.Rand(-1, 1))
            particle:SetRollDelta(math.Rand(-1, 1))
            particle:SetColor(0, 255, 0)  
            particle:SetAirResistance(100)  
            particle:SetGravity(Vector(0, 0, 60))  
        end
    end

    self.Emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
