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
    if not IsValid(gun) or not gun.GetTrace then return end
    local pos, ang = gun:GetTrace(true, nil, nil, true)
    local dir = ang:Forward()

    local ammotype = string.lower( string.Replace( gun.Primary and gun.Primary.Ammo or "nil"," ", "") )
    self.bullet = (hg.ammotypes[ammotype] and hg.ammotypes[ammotype].TracerSetings) or tracer
    
    self.SpawnTime = CurTime()
    self.DieTime = CurTime() + 0.1
    self.Pos = pos

    dir:Add(VectorRand(-1,1) / 4)

    self.AddVelocity = VectorRand(-1,1) / 2
    self.Velocity = dir * 25
end

function EFFECT:Think()
    local bullet = self.bullet

    self.Velocity = (self.Velocity or vector_zero)-- - vector_up * 0.05
    
    local vellen = self.Velocity:Length()

    if self.AddVelocity then
        local ang = self.Velocity:Angle()
        local addvel = self.AddVelocity
        
        self.Velocity = self.Velocity + self.AddVelocity
        self.AddVelocity = self.AddVelocity / 4
    end

    local tr = util.QuickTrace(self.Pos,self.Velocity)

    self.Pos = (tr.Hit and tr.HitPos or self.Pos + self.Velocity)
    self:SetPos(self.Pos)

    if tr.Hit then
        local vec = self.Velocity:Angle()
        vec:RotateAroundAxis(tr.HitNormal,180)
        self.Velocity = -vec:Forward() * vellen
        self.Velocity:Mul(0.5)
    end
    
    self.Velocity:Mul(0.3)
    self:NextThink(CurTime() + 0.05)
    return self.DieTime > CurTime()
end

local vecZero = Vector(0,0,0)

function EFFECT:Render()
    local bullet = self.bullet

    local width = bullet.TracerWidth / 6
    
    if tracer.TracerTail then
        render.SetMaterial(tracer.TracerTail)
        render.DrawBeam(self.Pos - self.Velocity, self.Pos, width * self.Velocity:Length() / 5, bullet.TracerTPoint2, bullet.TracerTPoint1, tracer.TracerColor)
    end
end