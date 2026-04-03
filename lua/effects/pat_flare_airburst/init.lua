EFFECT.MatGlow = Material("sprites/light_glow02_add")
EFFECT.MatSpark = Material("effects/laser_tracer")
EFFECT.MatFire = Material("particle/fire")
EFFECT.MatSmoke = Material("particle/particle_smokegrenade")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Normal = data:GetNormal()
    self.Scale = math.max(data:GetScale(), 1)
    self.SpawnTime = CurTime()
    self.DieTime = self.SpawnTime + 1.65
    self.Bursts = {}
    self.Smoke = {}

    for i = 1, 28 do
        local dir = VectorRand():GetNormalized()
        if dir.z < -0.15 then
            dir.z = math.abs(dir.z) * 0.4
            dir:Normalize()
        end

        self.Bursts[i] = {
            dir = dir,
            len = math.Rand(90, 210) * self.Scale,
            width = math.Rand(4, 10) * self.Scale
        }
    end

    for i = 1, 14 do
        self.Smoke[i] = {
            dir = VectorRand():GetNormalized(),
            len = math.Rand(20, 70) * self.Scale,
            size = math.Rand(26, 60) * self.Scale
        }
    end

    self:SetRenderBoundsWS(self.Pos - Vector(420, 420, 420), self.Pos + Vector(420, 420, 420))
end

function EFFECT:Think()
    local now = CurTime()
    if now >= self.DieTime then
        return false
    end

    local frac = math.Clamp((now - self.SpawnTime) / (self.DieTime - self.SpawnTime), 0, 1)
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = self.Pos
        dlight.r = 255
        dlight.g = 50
        dlight.b = 50
        dlight.brightness = 6.5 * (1 - frac * 0.7)
        dlight.Decay = 900
        dlight.Size = (540 - frac * 180) * self.Scale
        dlight.DieTime = now + 0.08
    end

    return true
end

function EFFECT:Render()
    local frac = math.Clamp((CurTime() - self.SpawnTime) / (self.DieTime - self.SpawnTime), 0, 1)
    local fade = math.max(0, 1 - frac * 0.8)
    local burstCol = Color(255, 68, 82, 240 * fade)
    local glowCol = Color(255, 32, 40, 220 * fade)
    local emberCol = Color(255, 215, 215, 195 * fade)
    local baseSize = Lerp(frac, 220, 110) * self.Scale

    render.SetMaterial(self.MatGlow)
    render.DrawSprite(self.Pos, baseSize * 1.45, baseSize * 1.45, burstCol)
    render.DrawSprite(self.Pos, baseSize * 0.92, baseSize * 0.92, glowCol)
    render.DrawSprite(self.Pos, baseSize * 0.3, baseSize * 0.3, emberCol)
    render.DrawSprite(self.Pos + VectorRand() * 4, baseSize * 0.52, baseSize * 0.52, burstCol)

    render.SetMaterial(self.MatFire)
    render.DrawSprite(self.Pos, baseSize * 1.05, baseSize * 1.05, burstCol)
    render.DrawSprite(self.Pos, baseSize * 0.55, baseSize * 0.55, emberCol)

    render.SetMaterial(self.MatSpark)
    for i = 1, #self.Bursts do
        local burst = self.Bursts[i]
        local endPos = self.Pos + burst.dir * burst.len * (0.18 + frac * 1.35)
        render.DrawBeam(self.Pos, endPos, burst.width * fade, 0, 1, burstCol)
    end

    render.SetMaterial(self.MatSmoke)
    for i = 1, #self.Smoke do
        local puff = self.Smoke[i]
        local pos = self.Pos + puff.dir * puff.len * frac * 0.9
        local size = puff.size * (0.9 + frac * 1.9)
        render.DrawSprite(pos, size, size, Color(120, 38, 38, 85 * fade))
    end
end
