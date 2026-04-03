EFFECT.MatBeam = Material("effects/laser_tracer")
EFFECT.MatGlow = Material("sprites/light_glow02_add")
EFFECT.MatFire = Material("particle/fire")

function EFFECT:Init(data)
    self.StartPos = data:GetStart()
    self.EndPos = data:GetOrigin()
    self.Intensity = math.max(data:GetScale(), 1)
    self.VisualSpeed = math.max(data:GetMagnitude(), 260)
    self.SpawnTime = CurTime()
    self.Length = self.StartPos:Distance(self.EndPos)
    self.Duration = math.Clamp(self.Length / self.VisualSpeed, 0.75, 1.75)
    self.DieTime = self.SpawnTime + self.Duration
    self.MaxPathPoints = 14
    self.Path = {}
    self.DropAmount = math.Clamp(self.Length * 0.08, 28, 180)

    self.Color = Color(255, 100, 28)
    self.CoreColor = Color(255, 225, 160)
    self:SetRenderBoundsWS(self.StartPos, self.EndPos)
end

function EFFECT:GetHeadPos(frac)
    local pos = LerpVector(frac, self.StartPos, self.EndPos)
    pos.z = pos.z - self.DropAmount * frac * frac
    return pos
end

function EFFECT:Think()
    local now = CurTime()
    if now >= self.DieTime then
        return false
    end

    local frac = math.Clamp((now - self.SpawnTime) / self.Duration, 0, 1)
    self.HeadPos = self:GetHeadPos(frac)

    self.Path[#self.Path + 1] = self.HeadPos
    if #self.Path > self.MaxPathPoints then
        table.remove(self.Path, 1)
    end

    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = self.HeadPos
        dlight.r = 255
        dlight.g = 125
        dlight.b = 40
        dlight.brightness = 5.5 * self.Intensity
        dlight.Decay = 1700
        dlight.Size = 220 * self.Intensity
        dlight.DieTime = now + 0.06
    end

    return true
end

function EFFECT:Render()
    if not self.HeadPos then return end

    local frac = math.Clamp((CurTime() - self.SpawnTime) / self.Duration, 0, 1)
    local fade = (1 - frac) * 0.15
    local beamCol = Color(self.Color.r, self.Color.g, self.Color.b, 255 * fade)
    local coreCol = Color(self.CoreColor.r, self.CoreColor.g, self.CoreColor.b, 255 * fade)
    local glowSize = (76 + 36 * (1 - frac)) * self.Intensity
    local coreSize = glowSize * 0.42

    local pathCount = #self.Path
    if pathCount >= 2 then
        render.SetMaterial(self.MatBeam)
        render.StartBeam(pathCount)
        for i = 1, pathCount do
            local widthFrac = i / pathCount
            render.AddBeam(self.Path[i], (12 + 26 * widthFrac) * self.Intensity, widthFrac, beamCol)
        end
        render.EndBeam()
    end

    render.SetMaterial(self.MatFire)
    render.DrawSprite(self.HeadPos, glowSize, glowSize, beamCol)
    render.DrawSprite(self.HeadPos + VectorRand() * 2, glowSize * 0.45, glowSize * 0.45, beamCol)

    render.SetMaterial(self.MatGlow)
    render.DrawSprite(self.HeadPos, glowSize * 1.1, glowSize * 1.1, beamCol)
    render.DrawSprite(self.HeadPos, coreSize, coreSize, coreCol)
end
