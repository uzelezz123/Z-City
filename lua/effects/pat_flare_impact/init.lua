EFFECT.MatGlow = Material("sprites/light_glow02_add")
EFFECT.MatSpark = Material("effects/laser_tracer")
EFFECT.MatSmoke = Material("particle/particle_smokegrenade")
EFFECT.MatFire = Material("particle/fire")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Normal = data:GetNormal()
    self.Scale = math.max(data:GetScale(), 1)
    self.SpawnTime = CurTime()
    self.DieTime = self.SpawnTime + 0.52
    self.Rays = {}
    self.Smoke = {}

    local basis = self.Normal:Angle()
    for i = 1, 18 do
        local dir = (self.Normal * math.Rand(0.45, 1.15)
            + basis:Right() * math.Rand(-1.35, 1.35)
            + basis:Up() * math.Rand(-1.35, 1.35)):GetNormalized()

        self.Rays[i] = {
            dir = dir,
            len = math.Rand(28, 86) * self.Scale,
            width = math.Rand(3.5, 7.5) * self.Scale
        }
    end

    for i = 1, 6 do
        self.Smoke[i] = {
            offset = VectorRand() * math.Rand(2, 8) * self.Scale,
            rise = VectorRand() * 12 + self.Normal * math.Rand(10, 26),
            size = math.Rand(18, 34) * self.Scale
        }
    end

    self:SetRenderBoundsWS(self.Pos - Vector(128, 128, 128), self.Pos + Vector(128, 128, 128))
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = math.Clamp((CurTime() - self.SpawnTime) / (self.DieTime - self.SpawnTime), 0, 1)
    local inv = 1 - frac
    local flashCol = Color(255, 80, 90, 220 * inv)
    local glowCol = Color(255, 42, 42, 255 * inv)
    local emberCol = Color(255, 185, 170, 200 * inv)
    local glowSize = Lerp(frac, 78, 22) * self.Scale
    local fireSize = glowSize * 0.78

    render.SetMaterial(self.MatGlow)
    render.DrawSprite(self.Pos, glowSize * 1.15, glowSize * 1.15, flashCol)
    render.DrawSprite(self.Pos + self.Normal * 1.5, glowSize * 0.7, glowSize * 0.7, glowCol)
    render.DrawSprite(self.Pos, glowSize * 0.3, glowSize * 0.3, emberCol)

    render.SetMaterial(self.MatFire)
    render.DrawSprite(self.Pos + self.Normal * 2, fireSize, fireSize, glowCol)
    render.DrawSprite(self.Pos + self.Normal * 4, fireSize * 0.42, fireSize * 0.42, emberCol)

    render.SetMaterial(self.MatSpark)
    for i = 1, #self.Rays do
        local ray = self.Rays[i]
        local endPos = self.Pos + ray.dir * ray.len * (0.18 + frac * 1.1)
        render.DrawBeam(self.Pos, endPos, ray.width * inv, 0, 1, flashCol)
    end

    render.SetMaterial(self.MatSmoke)
    for i = 1, #self.Smoke do
        local puff = self.Smoke[i]
        local pos = self.Pos + puff.offset + puff.rise * frac * 0.45
        local size = puff.size * (0.8 + frac * 1.4)
        render.DrawSprite(pos, size, size, Color(120, 40, 40, 80 * inv))
    end
end