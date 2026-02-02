EFFECT.Material = Material("particle/water/waterdrop_001a_refract")
EFFECT.Color = Color(255, 255, 255)
EFFECT.Width = 4

local BulletsMinDistance = 5

local tracer = {
	TracerBody = Material("particle/fire"),
	TracerTail = Material("effects/laser_tracer"),
	TracerHeadSize = 1,
	TracerLength = 150,
	TracerWidth = 1.5,
	TracerColor = Color(255, 215, 155),
	TracerTPoint1 = 0.25,
	TracerTPoint2 = 1,
	TracerSpeed = 25000
}

function EFFECT:Init(data)
    local gun = data:GetEntity()
    self.gun = gun
    local ammotype = string.lower( string.Replace( gun.Primary and gun.Primary.Ammo or "nil"," ", "") )
    self.bullet = (hg.ammotypes[ammotype] and hg.ammotypes[ammotype].TracerSetings) or tracer
    self.Speed = self.bullet.TracerSpeed or 25000
    
    self.EndPos = data:GetOrigin()

    self.magnitude = data:GetMagnitude()
    local fireinthehole = IsValid(gun) and (math.Round(self.magnitude) == 1)
    
    local trace = gun.GetTrace and gun:GetTrace(true, nil, nil, true)
    --if not (fireinthehole and gun.GetTrace and trace) then return end
    
    local mpos = ((fireinthehole and gun.GetTrace) and trace) or data:GetStart()
    
    if !mpos then self:Remove() return end

    self.TrueLength = (mpos - self.EndPos):Length()
    self.StartPos = mpos + ((self.EndPos - mpos):GetNormalized() * BulletsMinDistance)

    if self.TrueLength <= BulletsMinDistance then
        self.DieTime = 0
    end

    self.SpawnTime = CurTime()
    self.Length = (self.StartPos - self.EndPos):Length()
    self.DieTime = self.SpawnTime + (self.Length / self.Speed)
    self:SetRenderBoundsWS(self.StartPos, self.EndPos)

    local bullet = self.bullet
    
    local dlight = DynamicLight(self:EntIndex())
	dlight.pos = self.StartPos
	dlight.r = bullet.TracerColor.r
	dlight.g = bullet.TracerColor.g
	dlight.b = bullet.TracerColor.b
	dlight.brightness = 1
	dlight.Decay = 1
	dlight.Size = bullet.TracerHeadSize / 5
	dlight.DieTime = self.DieTime
    
    self.dlight = dlight
end

function EFFECT:Think()
    return (self.DieTime or 0) > CurTime()
end

function EFFECT:Render()
    local bullet = self.bullet
    local fireinthehole = IsValid(self.gun) and (math.Round(self.magnitude) == 1)
    if fireinthehole and self.gun.GetMuzzleAtt then self.StartPos = (self.gun.GetTrace and select(2, self.gun:GetTrace(nil, nil, nil, true))) or self.StartPos end
    if not self.SpawnTime or not self.DieTime then return end
    local delta = (CurTime() - self.SpawnTime) / (self.DieTime - self.SpawnTime)
    local startbeampos = Lerp(delta, self.StartPos, self.EndPos)
    local endbeampos = Lerp(delta + (bullet.TracerLength / self.Length / 2), self.StartPos, self.EndPos)
    
    local width = bullet.TracerWidth
    local headsize = bullet.TracerHeadSize

    local col = bullet.TracerColor
        col.a = 255 * 1

    if bullet.TracerBody then
        render.SetMaterial(bullet.TracerBody)
        local size = math.Clamp(delta,0,1)
        render.DrawSprite(endbeampos, headsize * size, headsize * size, col)
    end

    if bullet.TracerTail then
        render.SetMaterial(bullet.TracerTail)
        render.DrawBeam(startbeampos, endbeampos, width, bullet.TracerTPoint2, bullet.TracerTPoint1, col)
    end
    self.dlight.pos = endbeampos
end