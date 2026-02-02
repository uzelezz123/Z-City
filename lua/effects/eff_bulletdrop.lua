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

local vector_up = Vector(0,0,1)
local vector_zero = Vector(0,0,0)

function EFFECT:Init(data)
    if math.random(1,2) == 1 then self:Remove() return end
    local gun = data:GetEntity()
    local hitpos = data:GetOrigin()
    local dir = data:GetNormal()
    local hitnormal = data:GetStart()
    
    local ammotype = string.lower( string.Replace( gun.Primary and gun.Primary.Ammo or "nil"," ", "") )
    self.bullet = (hg.ammotypes[ammotype] and hg.ammotypes[ammotype].TracerSetings) or tracer

    if !hg.ammotypes[ammotype].TracerSetings or hg.ammotypes[ammotype].TracerSetings.TracerHeadSize < 2 then self:Remove() return end

    self.SpawnTime = CurTime()
    self.DieTime = CurTime() + 3
    self.Pos = hitpos

    local vec = dir:Angle()
    vec:RotateAroundAxis(hitnormal,180)
    local dir2 = -vec:Forward()

    local dot = (dir:Dot(dir2) + 1) / 2

    dir2:Add(VectorRand(-0.25,0.25))
    dir2 = LerpVector(0.05,dir2,hitnormal)
    dir2:Mul(math.random(4,8) * 8 * dot)

    dir2:Add(dir * math.random(2))
    --dir2:Add(vector_up * math.random(2))

    if ammotype and hg.ammotypes[ammotype] and (not hg.ammotypes[ammotype].NoSpin) and (math.random(8) < (data:GetMagnitude() or 1)) then self.AddVelocity = math.random(4) * (data:GetMagnitude() or 1) * (math.random(2) == 1 and -1 or 1) end
    
    self.Velocity = dir2
end

function EFFECT:Think()
    local bullet = self.bullet
    --print(self.Pos,self.Velocity)
    if not self.Pos or not self.Velocity then return end
    self.Velocity = (self.Velocity or vector_zero) - vector_up * 0.05
    
    local vellen = self.Velocity:Length()

    if self.AddVelocity and math.abs(self.AddVelocity) > 0.1 and vellen > 1 then
        local ang = self.Velocity:Angle()
        local addvel = self.AddVelocity
        
        self.Velocity:Add(ang:Right() * addvel / 12)
        self.AddVelocity = addvel * 15 / 16
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

    self.Velocity:Mul(0.999)
    --self:NextThink(CurTime() + 0.1)
    return self.DieTime > CurTime()
end

local vecZero = Vector(0,0,0)

function EFFECT:Render()
    if not self.DieTime then return end
    local bullet = self.bullet

    local width = bullet.TracerWidth
    local headsize = bullet.TracerHeadSize

    if bullet.TracerBody then
        render.SetMaterial(bullet.TracerBody)
        local rand = math.random(16) / 16 * (self.DieTime - CurTime()) / 3
        render.DrawSprite(self.Pos, headsize * rand, headsize * rand, bullet.TracerColor)
    end

    if bullet.TracerTail then
        render.SetMaterial(bullet.TracerTail)
        render.DrawBeam(self.Pos - self.Velocity, self.Pos, width, bullet.TracerTPoint2, bullet.TracerTPoint1, bullet.TracerColor)
    end
end