if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
ENT.Author = "Sadsalat"
ENT.Category = "ZCity Other"
ENT.PrintName = "Projectile NoneExplosive Base"
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Model = ""
ENT.HitSound = "weapons/crossbow/hit1.wav"
ENT.FleshHit = "weapons/crossbow/bolt_skewer1.wav"

ENT.Damage = 200
ENT.Force = 0.2
// THE MOST PLUV
if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(1)
			phys:Wake()
		end
	end

	ENT.Hit = false

	function ENT:Hit(ent, hit_pos, phys_bone_id, normal)
		local ply = hg.RagdollOwner(ent) or ent
		local rag = IsValid(ply) and (IsValid(ply:GetNWEntity("RagdollDeath", ply.FakeRagdoll)) and ply:GetNWEntity("RagdollDeath", ply.FakeRagdoll)) or ent:IsRagdoll() and ent or IsValid(ent.FakeRagdoll) and ent.FakeRagdoll
		local org = rag and rag.organism or ent.organism
		rag = rag or ent
		
		if !org then
			self:SetPos(hit_pos)
			self:SetAngles((normal):Angle())
			constraint.Weld(self, rag, 0, rag:IsPlayer() and 0 or phys_bone_id, 0, true, false)
		end

		local mat = ent:GetBoneMatrix(ent:TranslatePhysBoneToBone(phys_bone_id))
		local offset_pos = Vector()
		local offset_ang = Angle()
		
		if(mat)then
			offset_pos, offset_ang = WorldToLocal(hit_pos, (normal):Angle(), mat:GetTranslation(), mat:GetAngles())
		end
		
		local phys = ent:GetPhysicsObjectNum(phys_bone_id or 0)
		if IsValid(phys) then
			phys:ApplyForceOffset(-normal * self.Damage * 200, hit_pos)
		end

		self.HitEntity = ent
		self.phys_bone_id = phys_bone_id
		self.Hit = true

		if org then
			org.LodgedEntities = org.LodgedEntities or {}
			org.LodgedEntities[#org.LodgedEntities + 1] = {
				PhysBoneID = self.phys_bone_id,
				OffsetPos = offset_pos,
				OffsetAng = offset_ang,
				CrossbowBolt = self:GetClass() == "crossbow_projectile",
			}

			net.Start("organism_send")
	
			local tbl = {}
			tbl.LodgedEntities = org.LodgedEntities
			tbl.owner = org.owner
		
			net.WriteTable(tbl)
			net.WriteBool(true)
			net.WriteBool(false)
			net.WriteBool(false)
			net.WriteBool(true)
			net.Broadcast()
		end

		if org then
			SafeRemoveEntity(self)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > .2 and data.Speed > 200 and !self.Hit then
            local dir = data.HitPos - (data.HitPos + self:GetAngles():Forward() * -5)
            --print(dir:GetNormalized())
            local hitNormal = data.HitNormal
            local ApproachAngle = math.deg(math.asin(hitNormal:DotProduct(dir:GetNormalized())))
	        local MaxRicAngle = 10
            --print(ApproachAngle)

            --if ApproachAngle < MaxRicAngle * 1 then 
            --        --[[local effectpoint = self:GetPos()
            --        timer.Simple(.1,function()
            --            local effectdata = EffectData()
            --            effectdata:SetOrigin( effectpoint )
            --            effectdata:SetScale(1)
            --            effectdata:SetMagnitude(2)
            --            effectdata:SetRadius(0.1)
            --            util.Effect( "Sparks", effectdata )
            --        end)
            --        local NewVec = dir:Angle()
            --        NewVec:RotateAroundAxis(hitNormal, 180)
            --        NewVec = NewVec:Forward()
            --        self:SetVelocity(self:GetAngles():Forward() * -1000)]]--
--
            --    return 
            --end

            timer.Simple(.1,function()
                local effectdata = EffectData()
                effectdata:SetOrigin( data.HitPos )
                effectdata:SetScale(0.1)
                effectdata:SetMagnitude(2)
                effectdata:SetRadius(0.1)
                util.Effect( "Sparks", effectdata )
            end)
			self:Hit(data.HitEntity, data.HitPos, 0, data.OurOldVelocity:GetNormalized())
            self:DamagePly(data.HitEntity, data.HitObject:GetMaterial(), data.HitPos) 
            return 
		end
	end

	function AeroDrag(ent, forward, mult, spdReq)
		if(constraint.HasConstraints(ent))then
			return
		end
		
		if ent:IsPlayerHolding() then return end
		local Phys = ent:GetPhysicsObject()
		if not IsValid(Phys) then return end
		local Vel = Phys:GetVelocity()
		local Spd = Vel:Length()
	
		if not spdReq then
			spdReq = 300
		end
	
		if Spd < spdReq then return end
		mult = mult or 1
		local Pos, Mass = Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
		Phys:ApplyForceOffset(Vel * Mass / 6 * mult, Pos + forward)
		Phys:ApplyForceOffset(-Vel * Mass / 6 * mult, Pos - forward)
		Phys:AddAngleVelocity(-Phys:GetAngleVelocity() * Mass / 1000)
	end

    local vecSmoke = Vector(255,255,255)
    function ENT:Think()
		AeroDrag(self, self:GetAngles():Forward(), .6)
        self:NextThink(CurTime() + 0.1)
    end

	function ENT:Use(ply)
	end

	function ENT:OnTakeDamage(dmginfo)
	end
    local fleshmats = {
        ["flesh"] = true,
        ["player"] = true
    }
	function ENT:DamagePly(ent,mat,hitpos)
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self
        local DmgInfo = DamageInfo()
        DmgInfo:SetDamage(self.Damage)
        DmgInfo:SetDamageForce(self:GetAngles():Forward() * self.Force)
        DmgInfo:SetDamagePosition(hitpos)
        DmgInfo:SetDamageType(DMG_BULLET)
        DmgInfo:SetInflictor(self)
        DmgInfo:SetAttacker(self)
        ent:TakeDamageInfo(DmgInfo)
        --print(mat)
        self:EmitSound( fleshmats[mat] and self.FleshHit or self.HitSound)
        util.Decal( fleshmats[mat] and "Impact.Flesh" or "Impact.Concrete", SelfPos + self:GetAngles():Forward() * -5, SelfPos + self:GetAngles():Forward() * 500, self )
        self:Remove()
	end

	function hg.TakeArrow(ent, ply)
		local org = ent.organism
		
		if !IsValid(ent) or !org or !org.LodgedEntities or #org.LodgedEntities == 0 then return end
		
		local i = #org.LodgedEntities
		
		if org.LodgedEntities[i].CrossbowBolt then
			while i > 0 do
				i = i - 1

				if i == 0 or !org.LodgedEntities[i].CrossbowBolt then
					break
				end
			end

			if i == 0 then return end
		end

		table.remove(org.LodgedEntities, i)

		local mat = ent:GetBoneMatrix(ent:TranslatePhysBoneToBone(org.LodgedEntities.PhysBoneID or 0))
		
		if mat then
			local lpos, lang = org.LodgedEntities.OffsetPos, org.LodgedEntities.OffsetAng
			
			for i = 1, 5 do
				hg.organism.AddWoundManual(org.owner, 50, vector_origin, AngleRand(-180, 180), ent:GetBoneName(ent:TranslatePhysBoneToBone(org.LodgedEntities.PhysBoneID or 0)), CurTime() + math.Rand(0, 2))
			end
		end

		ply:GiveAmmo(1, "Arrow", true)
		ply:EmitSound("weapons/bow_deerhunter/arrow_load_0"..math.random(3)..".wav", 55)
		
		net.Start("organism_send")

		local tbl = {}
		tbl.LodgedEntities = org.LodgedEntities
		tbl.owner = org.owner
	
		net.WriteTable(tbl)
		net.WriteBool(true)
		net.WriteBool(false)
		net.WriteBool(false)
		net.WriteBool(true)
		net.Broadcast()

		ent:EmitSound("arrow_tear.wav")
	end

	concommand.Add("hg_takearrow", function(ply, cmd, args)
		if ply.organism and ply.organism.LodgedEntities and ply.organism.canmove then
			hg.TakeArrow(ply, ply)
		end
	end)

	hook.Add("Player Think", "takeArrowFunc", function(ply, ent)
		if ply.organism and ply.organism.canmove and ply:KeyPressed(IN_USE) then
			local tr = hg.eyeTrace(ply)

			local ent = tr.Entity

			hg.TakeArrow(ent, ply)
		end
	end)
elseif CLIENT then
	hook.Add("radialOptions", "takearrow", function()
		local ply = LocalPlayer()
		
		if ply.organism and ply.organism.canmove and ply.organism.LodgedEntities and #ply.organism.LodgedEntities > 0 then
			local points = ply:GetNWInt("CommanderPoints", 0)
			local tbl = {
				function()
					RunConsoleCommand("hg_takearrow")
				end,
				"Take arrow from yourself"
			}
			hg.radialOptions[#hg.radialOptions + 1] = tbl
		end
	end)

	function hg.ProjectilesDraw(ent, ply)
		if !IsValid(arrowasdasd) then
			arrowasdasd = ClientsideModel("models/z_city/nmrih/items/arrow/ammo_arrow_single.mdl")
			arrowasdasd:SetNoDraw(true)
		end

		if !IsValid(arrowasdasd2) then
			arrowasdasd2 = ClientsideModel("models/crossbow_bolt.mdl")
			arrowasdasd2:SetNoDraw(true)
		end

		if ent.organism and ent.organism.LodgedEntities then
			for i, settings in ipairs(ent.organism.LodgedEntities) do
				local arrow = settings.CrossbowBolt and arrowasdasd2 or arrowasdasd

				local mat = ent:GetBoneMatrix(ent:TranslatePhysBoneToBone(settings.PhysBoneID))
				local pos, ang = LocalToWorld(settings.OffsetPos, settings.OffsetAng, mat:GetTranslation(), mat:GetAngles())
	
				arrow:SetPos(pos)
				arrow:SetAngles(ang)

				arrow:SetupBones()
				arrow:DrawModel()
			end

		end
	end

	function ENT:Draw()
		self:DrawModel()
		
		if(self.PostDraw)then
			self:PostDraw()
		end
	end
end