ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "ent_hg_slam"
ENT.Spawnable = false
ENT.WorldModel = "models/mmod/weapons/w_slam.mdl"

ENT.SoundFar = {"iedins/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"}
ENT.Sound = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"}
ENT.SoundWater = "iedins/water/ied_water_detonate_01.wav"
ENT.BlastDis = 3
ENT.BlastDamage = 70

--local developer = GetConVar("developer")
ENT.offsetPos = Vector(-2.25, 1.38, 0)
ENT.offsetAng = Angle(-90, 180, 0)

function ENT:Think()
    local tr = {}
    local pos, ang = self:GetPos(), self:GetAngles()
    local pos, ang = LocalToWorld(self.offsetPos, self.offsetAng, pos, ang)
    tr.start = pos
    tr.endpos = tr.start + ang:Forward() * 700
    tr.filter = self
    tr.collisiongroup = COLLISION_GROUP_NONE
    local tr = util.TraceLine(tr)

    -- if developer:GetBool() then
    --    debugoverlay.Line(pos, tr.HitPos, 1, color_white, true)
    -- end

    self.TraceStart = pos
    self.TraceHitPos = tr.HitPos

    if SERVER then
        local beepSnd = math.abs(math.sin(CurTime() * 8))
        self.Played = self.Played or false
        if self.Safety > CurTime() and beepSnd > 0.9 and not self.Played then
            self.Played = true
            self:EmitSound("buttons/button24.wav",60,100 + (25 * (3-(self.Safety - CurTime()))) )
        elseif beepSnd < 0.9 then
            self.Played = false
        end
    end

    if SERVER and tr.Hit and tr.Entity:GetVelocity():LengthSqr() > 1 and self.Safety < CurTime() then
        self:ActivateExplosive()
    end

    if CLIENT and not self.HookAdded and self:GetNWFloat("Safety",CurTime()) < CurTime() then
        self:CreateLaserHook()
    end

    self:NextThink(CurTime())
    return true
end