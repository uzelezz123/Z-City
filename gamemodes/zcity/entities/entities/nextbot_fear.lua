AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true


local function check_unseen_nav(ent)
    local chosenvec
    local dist = 9999999999999
    local alive = zb:CheckAlive()
    
    for i, nav in ipairs(navmesh.GetAllNavAreas()) do
        local vec = nav:GetCenter() + vector_up * 64
        local flag = true
        for i, ply in ipairs(alive) do
            if ply == ent then continue end

            --if hg.isVisible(ply:EyePos(), vec, {ply, ent}, MASK_VISIBLE) or util.IsInWorld(vec) then
            if nav:IsVisible(ply:EyePos()) then
                flag = false
            end
        end

        if flag then
            local dist2 = vec:DistToSqr(ent:GetPos())
            if dist2 < dist then
                dist = dist2
                chosenvec = vec
            end
        end
    end
    
    return chosenvec
end

function ENT:Initialize()
    self:SetModel( "models/mossman.mdl" )
    self:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
    self:SetNoDraw(true)
    
    self.CreateTime = CurTime()

    if IsValid(self.Victim) then
        local ent = hg.GetCurrentCharacter(self.Victim)
        for i = 0, ent:GetPhysicsObjectCount() - 1 do
            --constraint.NoCollide(self, ent, 0, i, false)
        end

        local owner = hg.RagdollOwner(ent) or ent
        
        hg.StunPlayer(owner)

        self:SetPos(ent:GetPos())
        
        local movepos, shouldremove = check_unseen_nav(owner)

        self.movepos = movepos
        
        if shouldremove then
            ent:Remove()
        end
    end
end

function ENT:RunBehaviour()
	while ( true ) do
		self:StartActivity( ACT_WALK )
		self.loco:SetDesiredSpeed( 400 )
        
        local ent = hg.GetCurrentCharacter(self.Victim)
        local owner = hg.RagdollOwner(ent) or ent
        
        local movepos, shouldremove = check_unseen_nav(owner)

        self.movepos = movepos

        if shouldremove then
            ent:Remove()
        end
        
        if self.movepos then self:MoveToPos(self.movepos) end
        
        hg.LightStunPlayer(owner, 3)

        if self.CreateTime + 20 < CurTime() then
            self:Remove()
        end
        
        --self:SetPos(ent:GetPos())
        self:StartActivity( ACT_IDLE )
		coroutine.wait(0)

		coroutine.yield()
	end
end

function ENT:BehaveUpdate( fInterval )

	if ( !self.BehaveThread ) then return end

	--
	-- Give a silent warning to developers if RunBehaviour has returned
	--
	if ( coroutine.status( self.BehaveThread ) == "dead" ) then

		self.BehaveThread = nil
		Msg( self, " Warning: ENT:RunBehaviour() has finished executing\n" )

		return

	end

	--
	-- Continue RunBehaviour's execution
	--
	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then

		self.BehaveThread = nil
		ErrorNoHalt( self, " Error: ", message, "\n" )

	end

    if IsValid(self.Victim) then
        local ent = hg.GetCurrentCharacter(self.Victim)
        local owner = hg.RagdollOwner(ent) or ent

        local tr = util.QuickTrace(self:GetPos(), self:GetVelocity(), {self, ent})
        if IsValid(tr.Entity) and hgIsDoor(tr.Entity) and tr.Entity:GetInternalVariable( "m_eDoorState" ) == 0 then
            
            tr.Entity:Use(owner)
        end

        if (self.NextTryKill or 0) < CurTime() then
            self.NextTryKill = CurTime() + 1

            local shouldremove = true
            local alive = zb:CheckAlive()
    
            for i, ply in ipairs(alive) do
                if ply == owner then continue end
        
                if hg.isVisible(ply:EyePos(), ent:GetPos(), {ply, ent}, MASK_VISIBLE) then
                    shouldremove = false
                end
            end
    
            if shouldremove then
                ent:Remove()
                self:Remove()
            end
        end


        if ent != owner then
            local pos = self:GetPos() + vector_up * 32
            --[[local bone = ent:LookupBone("ValveBiped.Bip01_R_Foot")
            local ph = ent:TranslateBoneToPhysBone(bone)
            local phys = ent:GetPhysicsObjectNum(ph)

            local target = phys:GetPos()
            local TargetPos = pos
            local vec = TargetPos - target
            local len, mul = vec:Length(), phys:GetMass()
    
            vec:Normalize()

            local avec = vec * len * 8 - phys:GetVelocity()
    
            local Force = avec * mul
            local ForceMagnitude = math.min(Force:Length(), 15000) * (1 / math.max(phys:GetVelocity():Dot(vec) / 1, 1))
    
            Force = Force:GetNormalized() * ForceMagnitude--]]
            
            self.loco:SetDesiredSpeed( 400 - self:GetPos():Distance(ent:GetPos()) )
            hg.ShadowControl(ent, 13, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
            hg.ShadowControl(ent, 12, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
            hg.ShadowControl(ent, 14, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
            hg.ShadowControl(ent, 9, 0.01, Angle(0, 0, 0), 0, 0, pos, 150000, 150)
            hg.ShadowControl(ent, 1, 0.01, Angle(0, 0, 0), 0, 0, ent:GetPhysicsObjectNum(0):GetPos() + vector_up * 1, 150, 150)
            hg.ShadowControl(ent, 0, 0.01, Angle(0, 0, 0), 0, 0, ent:GetPhysicsObjectNum(0):GetPos() + vector_up * 1, 150, 150)
            
            --phys:ApplyForceCenter(Force)
            --hg.ShadowControl(ent, 11, 0.01, Angle(0, 0, 0), 0, 0, self:GetPos(), 15000, 1)

            --
            --if IsValid(phys) then
            --    phys:SetPos(self:GetPos())
            --end
        end
    end
end