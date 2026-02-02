AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Spawnable		= true

if SERVER then
    ENT.TimeBetweenStep = 0.5

    function ENT:Initialize()
        self:SetModel("models/props_junk/PropaneCanister001a.mdl")
        self:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
        self:SetNoDraw(true)
        
        self.CreationTime = CurTime()
        self.Path = {}
        self.PathIndex = 1
        self.OpenDoorIds = {}
        self.TotalLen = 0
        self.TimePassed = 0
        self.Stuck = 0
        
        if IsValid(self.Victim) then
            local ent = hg.GetCurrentCharacter(self.Victim)
            local owner = hg.RagdollOwner(ent) or ent
            
            hg.StunPlayer(owner)

            self:SetPos(ent:GetPos() + vector_up * 32)
        end
    end

    local function fastUseDoor(door, victim)
        local old = door:GetInternalVariable("Speed")
        door:SetSaveValue("Speed", 1000)
        door:Use(victim)
        door:SetSaveValue("Speed", old)
    end

    local function not_visible_to_players(vec, excluded_ent)
        local alive = zb:CheckAlive() -- I really gotta make that function cache values later.

        for i, ply in ipairs(alive) do
            if (ply == excluded_ent) or (ply.FakeRagdoll == excluded_ent) then continue end

            if hg.isVisible(ply:EyePos(), vec, {ply, excluded_ent}, MASK_SOLID_BRUSHONLY) then
                return false
            end
        end

        return true
    end

    function ENT:FindGeneralDirection()
        local alive = zb:CheckAlive()

        local pos = self:GetPos()
        for i, ply in ipairs(alive) do
            pos:Add((pos - ply:GetPos()) * math.max(1, 100 - pos:Distance(ply:GetPos())))
        end

        return (pos - self:GetPos()):GetNormalized()
    end

    local hull = Vector(1, 1, 1)

    local tr = {}
    --tr.mask = MASK_SOLID_BRUSHONLY
    tr.mins = -hull
    tr.maxs = hull
    tr.collisiongroup = COLLISION_GROUP_WEAPON -- world and static stuff
    tr.filter = {false, false, false}

    hook.Add("PostCleanupMap", "filterAdd", function()
        --[[local filta = ents.FindByClass("prop_*")
        local filta2 = ents.FindByClass("func_*")

        table.Add(tr.filter, filta)
        table.Add(tr.filter, filta2)--]]
    end)

    function ENT:FindHidingSpot()
        if (self.NextTimeFind or 0) > CurTime() then return end

        self.NextTimeFind = CurTime() + 0.25
        local paths = {}
        self.PathIndex = 1
        self.StartMoveTime = CurTime()
        --[[tr.filter[1] = self
        tr.filter[2] = self.Victim
        tr.filter[3] = hg.GetCurrentCharacter(self.Victim)--]]
        tr.filter = ents.GetAll()
        tr.filter[1] = self.Victim
        local general_direction = self:FindGeneralDirection()
        general_direction[3] = 0

        local found = false

        for k = 1, 30 do
            paths[k] = paths[k] or {self:GetPos()}

            local path = paths[k]

            for i = 1, 20 do
                if found then break end
                
                local maxa = 8
                for j = 1, maxa do
                    tr.start = path[#path]
                    local ang = j * math.pi / maxa * 2 + math.atan(general_direction[1], general_direction[2])
                    tr.endpos = tr.start + Vector(math.sin(ang) * 250, math.cos(ang) * 250, 0)

                    local trace = util.TraceHull(tr)
        
                    local vec = trace.HitPos

                    if not_visible_to_players(vec, self.Victim) then
                        local index = #path
                        path[index + 1] = vec
                        --path[index + 2] = vec + (path[index + 1] - path[index]):GetNormalized() * 500
                        found = k
                        break
                    end
                end

                tr.start = path[#path]
                tr.endpos = tr.start + LerpVector(math.Rand(0.25, 0.75), Vector(math.random(-5, 5) * 50, math.random(-5, 5) * 50, (k - 15)), general_direction * math.random(0, 5) * 50)

                local trace = util.TraceHull(tr)
                
                --if !trace.Hit then
                    local vec = trace.HitPos
                    path[#path + 1] = vec
                --end
            end
        end

        local path = found and paths[found] or table.Random(paths)
        
        -- simplify path
        self.Path = {}
        local skip = 0
        for i = 1, #path do
            if !hg.isVisible(self.Path[#self.Path], path[i + 1], {self.Victim}, MASK_SOLID_BRUSHONLY) then
                self.Path[#self.Path + 1] = path[i]
            end
        end

        self.OpenDoorIds = {}
        
        for i = 1, #self.Path - 1 do
            local tr = util.QuickTrace(self.Path[i], self.Path[i + 1] - self.Path[i], {self, self.Victim})
            
            if !IsValid(tr.Entity) or !hgIsDoor(tr.Entity) then
                tr = util.QuickTrace(self.Path[i] + (self.Path[i + 1] - self.Path[i]) * 0.5, (self.Path[i + 1] - self.Path[i]):Angle():Right() * 1000, {self, self.Victim})
            end

            if !IsValid(tr.Entity) or !hgIsDoor(tr.Entity) then
                tr = util.QuickTrace(self.Path[i] + (self.Path[i + 1] - self.Path[i]) * 0.5, (self.Path[i + 1] - self.Path[i]):Angle():Right() * -1000, {self, self.Victim})
            end

            if IsValid(tr.Entity) and hgIsDoor(tr.Entity) and !DoorIsOpen2( tr.Entity ) then
                --fastUseDoor(tr.Entity, self.Victim)
                self.OpenDoorIds[i] = tr.Entity
            end
        end
        
        for i = 1, #self.Path - 1 do
            --debugoverlay.Line(self.Path[i], self.Path[i + 1], 5, color_white, true)
        end
        
        if #self.Path <= 2 then
            self.Stuck = self.Stuck + 1
            
            if self.Stuck > 5 then
                self:Remove()
            else
                self:SetPos(self.Victim:GetPos())
            end
        end

        self.TotalLen = self.TotalLen + (self.Path[1] - self.Path[math.Clamp(2, 1, #self.Path)]):Length()
        self.HidingSpot = self.Path[#self.Path]
        self.IsHidingSpotCovered = found
    end

    function ENT:GetAnimpos()
        local i = self.PathIndex
        local p1, p2 = self.Path[i], self.Path[math.min(i + 1, #self.Path)]
        if !p2 or !p1 then return 0 end
        local time = math.max(self.TimeBetweenStep * (p2 - p1):Length() * 0.01, 0.01)
        return (time - math.Clamp(self.StartMoveTime + 1 * time - CurTime(), 0, time)) / time
    end

    function ENT:MovingToPos()
        local len = #self.Path

        if len == 0 then return end
        
        if self.PathIndex > len then
            return self.Path[len]
        end
        
        local i = self.PathIndex
        local p1, p2 = self.Path[i], self.Path[math.min(i + 1, #self.Path)]
        return LerpVector(self:GetAnimpos(), p1, p2)
    end

    function ENT:Think()
        if self.CreationTime + 1 > CurTime() then return end --fuck this shit

        if !self.HidingSpot then
            self:FindHidingSpot()
        end
                
        local i = self.PathIndex

        local door = self.OpenDoorIds[i - 1]
        if IsValid(door) and DoorIsOpen2(door) then
            --fastUseDoor(door, self.Victim)

            self.OpenDoorIds[i - 1] = nil
        end

        local p1, p2 = self.Path[i], self.Path[math.min(i + 1, #self.Path)]
        
        if !p1 or !p2 then return end

        if self:GetAnimpos() >= 1 then
            self.PathIndex = i + 1
            self.StartMoveTime = CurTime()
        end

        if self.PathIndex > #self.Path then
            self:FindHidingSpot()
        end

        local movingpos = self:MovingToPos()

        if movingpos then
            movingpos[3] = self.Victim:GetPos()[3] + 32
            self:SetPos(movingpos)
        end

        if IsValid(self.Victim) then
            local ent = hg.GetCurrentCharacter(self.Victim)
            local owner = hg.RagdollOwner(ent) or ent
            hg.LightStunPlayer(owner, 3)

            if (self.NextTryKill or 0) < CurTime() then
                self.NextTryKill = CurTime() + 1
        
                local not_visible = not_visible_to_players(ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation(), ent)
                --local not_visible = not_visible_to_players(self:GetPos(), ent)
                
                -- head should be the last visible part since we're dragging
                -- the body by head

                if not_visible then
                    ent:Remove()
                    self:Remove()
                end
            end


            if ent != owner then
                local pos = self:GetPos() - vector_up * 16
                --pos[3] = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Foot")):GetTranslation()[3]

                local tr = util.QuickTrace(ent:GetPos(), (p2 - p1):Angle():Forward() * 500, {self, ent})

                local door = tr.Entity
                if IsValid(door) and hgIsDoor(door) and not door:GetNoDraw() and !DoorIsOpen2(door) then
                    fastUseDoor(door, self.Victim)
                end

                local tr = util.QuickTrace(ent:GetPos(), (p2 - p1):Angle():Forward() * -500, {self, ent})

                local door = tr.Entity
                if IsValid(door) and hgIsDoor(door) and not door:GetNoDraw() and DoorIsOpen2(door) then
                    fastUseDoor(door, self.Victim)
                end

                local tr = util.QuickTrace(ent:GetPos(), (p2 - p1):Angle():Right() * 125 + (p2 - p1):Angle():Forward() * -500, {self, ent})

                local door = tr.Entity
                if IsValid(door) and hgIsDoor(door) and not door:GetNoDraw() and DoorIsOpen2(door) then
                    fastUseDoor(door, self.Victim)
                end

                local tr = util.QuickTrace(ent:GetPos(), (p2 - p1):Angle():Right() * -125 + (p2 - p1):Angle():Forward() * -500, {self, ent})

                local door = tr.Entity
                if IsValid(door) and hgIsDoor(door) and not door:GetNoDraw() and DoorIsOpen2(door) then
                    fastUseDoor(door, self.Victim)
                end

                hg.ShadowControl(ent, 13, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
                hg.ShadowControl(ent, 12, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
                --hg.ShadowControl(ent, 14, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
                --hg.ShadowControl(ent, 9, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
                
                --hg.ShadowControl(ent, 1, 0.01, Angle(0, 0, 0), 0, 0, ent:GetPhysicsObjectNum(0):GetPos() + vector_up * 1, 150, 150)
                --hg.ShadowControl(ent, 0, 0.01, Angle(0, 0, 0), 0, 0, ent:GetPhysicsObjectNum(0):GetPos() + vector_up * 1, 150, 150)
            end
        end

        self:NextThink(CurTime())

        return true
    end
end