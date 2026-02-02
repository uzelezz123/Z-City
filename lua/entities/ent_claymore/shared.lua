ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "ent_claymore"
ENT.Spawnable = false
ENT.WorldModel = "models/hoff/weapons/seal6_claymore/w_claymore.mdl"

ENT.SoundFar = {"iedins/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"}
ENT.Sound = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"}
ENT.SoundWater = "iedins/water/ied_water_detonate_01.wav"

ENT.DetectionAngle = 60
ENT.DetectionDistance = 700
ENT.DetectionRays = 5

local developer = GetConVar("developer")
ENT.offsetPos = Vector(0, 2, 11.5)
ENT.offsetAng = Angle(1, 90, 0)

function ENT:Think()
    local pos, ang = self:GetPos(), self:GetAngles()
    local pos, ang = LocalToWorld(self.offsetPos, self.offsetAng, pos, ang)
 
    local halfAngle = self.DetectionAngle / 2
    local angleStep = self.DetectionAngle / (self.DetectionRays - 1)
    local triggered = false

    for i = 0, self.DetectionRays - 1 do
        local rayAngle = Angle(ang.p, ang.y, ang.r)
        rayAngle:RotateAroundAxis(rayAngle:Up(), -halfAngle + i * angleStep)

        local tr = {}
        tr.start = pos
        tr.endpos = tr.start + rayAngle:Forward() * self.DetectionDistance
        tr.filter = self
        tr.mask = MASK_SHOT
        local trace = util.TraceLine(tr)

        --if developer:GetBool() and CLIENT and LocalPlayer():IsAdmin() then
        --    local color = trace.Hit and Color(255, 0, 0) or Color(255, 255, 255)
        --    debugoverlay.Line(pos, trace.HitPos, 1, color, true)
        --end

        if SERVER and trace.Hit and (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or (trace.Entity:IsRagdoll() and trace.Entity:GetVelocity():LengthSqr() > 1)) then
            triggered = true
            break
        end
    end
    
    if SERVER and triggered and self.MotionTriggerIsActivated then
        self:ActivateExplosive()
    end

    self:NextThink(CurTime())
    return true
end