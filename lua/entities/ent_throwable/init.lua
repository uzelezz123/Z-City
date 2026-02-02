AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(USE_TOGGLE)
	self:DrawShadow(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(2)
		phys:Wake()
		phys:EnableMotion(true)
	end
	self.created = CurTime()
	timer.Simple(0.5,function()
		if not IsValid(self) then return end
		self:SetOwner()
	end)
end

function ENT:Think()
	if not IsValid(self:GetPhysicsObject()) then return end
	local speed = self:GetPhysicsObject():GetVelocity():LengthSqr()
	if self.constrained then return end
	if self.AeroDrag then
		AeroDrag(self, self:GetAngles():Forward(), 10)
	end
	self:SetCollisionGroup(speed < 220000 and COLLISION_GROUP_WEAPON or COLLISION_GROUP_NONE)
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed < 400 then return end
	local pos,_ = LocalToWorld(self.localshit,angle_zero,self:GetPos(),self:GetAngles())
	local tr = {}
	tr.start = pos
	tr.endpos = pos + data.OurOldVelocity:GetNormalized() * 32
	tr.filter = self
	--if util.TraceLine(tr).Entity != data.HitEntity and not self.dont_account_for_placement then return end
	
	if (data.HitEntity:IsRagdoll()) and ((self.DamageType or DMG_SLASH) == DMG_SLASH) then
		self:EmitSound(self.AttackHitFlesh,65)
		local pos,ang = self:GetPos(),self:GetAngles()
		local hitobj = data.HitObject
		local hitent = data.HitEntity
		local bone
		for i=0,hitent:GetBoneCount()-1 do
			if hitent:GetPhysicsObjectNum(hitent:TranslateBoneToPhysBone(i)) == hitobj then
				bone = hitent:TranslateBoneToPhysBone(i)
			end
		end
		
		local tr = {}
		tr.start = self:GetPos()
		tr.endpos = self:GetPos() + data.OurOldVelocity
		tr.filter = self
		local tr = util.TraceLine(tr)
		local bone = tr.PhysicsBone

		local lpos = tr.HitPos - hitent:GetBoneMatrix(hitent:TranslatePhysBoneToBone(bone)):GetTranslation()
		
		timer.Simple(0.05,function()
			if not IsValid(hitent) then return end
			
			local hitent = IsValid(hitent.FakeRagdoll) and hitent.FakeRagdoll or IsValid(hitent:GetNWEntity("RagdollDeath")) and hitent:GetNWEntity("RagdollDeath") or hitent
			
			local pos = hitent:GetBoneMatrix(hitent:TranslatePhysBoneToBone(bone)):GetTranslation() + lpos

			self:SetPos(pos + ang:Forward() * ((self.uglublenie or 1) - 0))
			self:SetAngles(ang)
			constraint.Weld(self,hitent,0,bone,0,true)
		end)
	elseif data.TheirSurfaceProps != 76 then
		if self.func then
			self.func(data)
		end
		self:EmitSound(self.AttackHit,65)
		timer.Simple(0.05,function()
			if !IsValid(self) then return end
			if self.noStuck then self:SetCollisionGroup(COLLISION_GROUP_NONE) return end
			self:SetPos(self:GetPos() + self:GetAngles():Forward() * (self.uglublenie or 1))
			constraint.Weld(data.HitEntity,self,0,0,0,true)
			if data.HitEntity == Entity(0) then
				self:SetMoveType(MOVETYPE_NONE)
				if self.hitworldfunc then
					self.hitworldfunc(self)
				end
			end
			self.constrained = true
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
		end)
	end
	
	self.Penetration = 1
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self.owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamage((self.damage or 20) * math.Clamp((data.Speed / self.MaxSpeed), 0, 1))
	dmginfo:SetDamageForce(data.OurOldVelocity)
	dmginfo:SetDamageType(self.DamageType or DMG_SLASH)
	dmginfo:SetDamagePosition(data.HitPos)
	data.HitEntity:TakeDamageInfo(dmginfo)
end

function ENT:Use(ply)
	if self.created + 0.5 > CurTime() then return end
	if self.wep then
		local wep = ents.Create(self.wep)
		wep:Spawn()
		wep:SetPos(self:GetPos())
		wep:SetAngles(self:GetAngles())
		wep.poisoned2 = self.poisoned2
		self:Remove()

		if constraint.FindConstraint( self, "Weld" ) then
			local tbl = constraint.FindConstraint( self, "Weld" )
			if tbl.Ent2:IsPlayer() or tbl.Ent2:IsRagdoll() then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(self.owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.returndamage or 10)
				dmginfo:SetDamagePosition(self:GetPos())
				dmginfo:SetDamageType(DMG_SLASH)
				self.PainMultiplier = 0.5
				tbl.Ent2:TakeDamageInfo(dmginfo)
				hg.organism.AddWoundManual(tbl.Ent2,self.returnblood or 10,vector_origin,angle_zero,tbl["Bone2"] or 0,CurTime())
			end
		end

		if not hook.Run("PlayerCanPickupWeapon",ply,wep) then wep.IsSpawned = true wep.init = true return end

		ply:PickupWeapon(wep)
	end
end