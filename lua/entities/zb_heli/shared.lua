ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PrintName = "Helicopter"
ENT.Category = "ZBattle"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = Model("models/hh/veh/heli.mdl")
ENT.AutomaticFrameAdvance = true


--:: мистер поинт самтрите тут врэмичко
// чё за --:: комментарии ты что фрик зачем это почему
ENT.WaitTime = 60

function ENT:SetWaitTime(time)
    self.WaitTime = math.max(5, math.min(600, time)) 
    self.WaitTimeSet = true 
end

function ENT:GetWaitTime()
    return self.WaitTime
end



ENT.SoundTable = {
    {
        t = 0,
        s = "veh1_ext_ster_pan2",
        b = "tag_main_rotor_static",
        v = 149
    },
    {
        t = 0,
        s = "veh1_ext_ster_panclose",
        b = "tag_main_rotor_static",
        v = 149
    },
    {
        t = 0,
        s = "veh/sas1_veh1_ceilingrattles_spot_stat.wav",
        b = "tag_main_rotor_static"
    }
}

ENT.WaitingSounds = {
    {
        t = 0,
        s = "veh/base_move2.wav",
        b = "tag_main_rotor_static",
        v = 80,
        loop = true
    },
    {
        t = 5,
        s = "veh/sas1_veh1_rattles_spot_stat.wav",
        b = "tag_origin",
        v = 60,
        loop = true
    }
}

function ENT:SetupBoneColliders()
    if CLIENT then return end
    self.Colliders = {}

    local hulls = {
        { bone = "tag_body", model = "models/hh/veh/chassis_col.mdl", lpos = Vector(0, 0, -106), lang = Angle(0, 0, 0) },
        { bone = "tag_main_rotor_static", model = "models/props_wasteland/exterior_fence_notbarbed002e.mdl", lpos = Vector(0, 0, 10), lang = Angle(90, 0, 0) },
    }

    for _, h in ipairs(hulls) do
        local bid = self:LookupBone(h.bone or "")
        if not bid then continue end

        local e = ents.Create("prop_physics")
        if not IsValid(e) then continue end

        e:SetModel(h.model)
        e:SetPos(self:GetPos())
        e:SetAngles(self:GetAngles())
        e:Spawn()
        
        e:SetParent(self)
        e:FollowBone(self, bid)
        e:SetCollisionGroup(COLLISION_GROUP_NONE)

        e:SetRenderMode(RENDERMODE_TRANSCOLOR)
        e:SetColor(Color(255, 255, 255, 0))

        if h.lpos then e:SetLocalPos(h.lpos) end
        if h.lang then e:SetLocalAngles(h.lang) end

        local phys = e:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Wake()
        end

        self:DeleteOnRemove(e)
        table.insert(self.Colliders, e)
    end
end

function ENT:GetOptimalLandingDirection()
    local testpos = self:GetPos() + Vector(0, 0, 512)
    local amt = 15
    local best = 0
    local best_dist = math.huge
    local offset = math.Rand(0, 360)

    for i = 1, amt do
        local angle = math.Rand(0, 360)

        local str = util.TraceLine({
            start = testpos,
            endpos = testpos + Angle(0, angle + offset, 0):Forward() * 10000
        })

        if str.HitSky then
            best = angle
            break
        elseif str.Fraction == 1 then
            best = angle
            break
        elseif str.Fraction * 10000 > best_dist then
            best = angle
            best_dist = str.Fraction * 10000
        end
    end

    return best + offset + 180 - 10
end

function ENT:CalculateLandingPosition()
    local tr = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() + Vector(0, 0, 512),
        mask = MASK_VISIBLE_AND_NPCS
    })

    if tr.HitSky then
        self:SetAngles(Angle(0, math.Rand(0, 360), 0))
        return self:GetPos()
    else
        local direction = self:GetOptimalLandingDirection()
        self:SetAngles(Angle(0, direction, 0))
        return self:LocalToWorld(-Vector(107.472321, -70.542793, 20))
    end
end
