function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local dir = data:GetNormal()
    local mag = math.Clamp(data:GetMagnitude(), 0.4, 2.0)
    local count = math.floor(5 * mag)
    local emitter = ParticleEmitter(pos)
    for i = 1, count do
        local p = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos + dir * (i * 0.4))
        if p then
            local spread = VectorRand() * 0.1
            local vel = (dir + spread):GetNormalized() * math.Rand(28, 70)
            p:SetVelocity(vel)
            p:SetAirResistance(28)
            p:SetGravity(Vector(0, 0, math.Rand(2, 8)))
            p:SetDieTime(math.Rand(0.45, 0.95))
            p:SetStartAlpha(math.random(4, 10))
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(4.5, 8))
            p:SetEndSize(math.Rand(14, 24))
            p:SetRoll(math.Rand(-180, 180))
            p:SetRollDelta(math.Rand(-1.2, 1.2))
            p:SetColor(245, 245, 245)
            p:SetLighting(false)
            p:SetCollide(false)
        end
    end
    if math.random(1, 4) == 1 then
        local h = emitter:Add("sprites/heatwave", pos + dir * 1.5)
        if h then
            h:SetVelocity(dir * 60)
            h:SetAirResistance(10)
            h:SetDieTime(0.22)
            h:SetStartAlpha(45)
            h:SetEndAlpha(0)
            h:SetStartSize(8)
            h:SetEndSize(0)
            h:SetRoll(math.Rand(-10, 10))
            h:SetRollDelta(math.Rand(-4, 4))
        end
    end
    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end