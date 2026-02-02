AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/mmod/weapons/w_bugbait.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)
	self:SetUseType(USE_TOGGLE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(0.1, function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(3)
		phys:Wake()
	end
end

function ENT:PhysicsCollide(data, physobj)
	if data.DeltaTime > .2 and data.Speed > 120 then self:Detonate(data) end
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end

	ply:PickupObject(self)
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	local Dmg = dmginfo:GetDamage()
	if Dmg >= 1 then
		self:Detonate()
	end
end

function ENT:Think()
	if self:WaterLevel() > 0 then
		self:Detonate()
	end
	self:NextThink(CurTime() + 0.5)
	return true
end

function ENT:Detonate(data)
	local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self:GetOwner() or self
	timer.Simple(.01, function()
		if not IsValid(self) then return end
		for i = 0, 1 do
			if data then
				local effData = EffectData()
				effData:SetOrigin(SelfPos)
				effData:SetMagnitude(0.1)
				effData:SetScale(math.Rand(0.25, 0.65))
				effData:SetRadius(0.1)
				util.Effect("StriderBlood", effData)
				util.Decal("BeerSplash", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
			end
		end
	end)

	hg.EmitAISound(SelfPos, 1024, 16, 512)

	for _, npc in ipairs(ents.FindInSphere(SelfPos, 1024)) do
		if IsValid(npc) and npc:IsNPC() and npc:GetClass() == "npc_antlion" then
			npc:AddRelationship("player D_LI 99")
			npc:SetLastPosition(self:GetPos())
			npc:SetSchedule(SCHED_FORCED_GO_RUN)
			npc:EmitSound("npc/antlion/distract1.wav", 100, math.random(80, 120))
			npc.SatisfactionEndTime = CurTime() + 60

			if not npc.SatisfactionEndTime then
				hook.Add("Think", npc:EntIndex(), function()
					if npc.SatisfactionEndTime < CurTime() or not IsValid(npc) then
						npc:AddRelationship("player D_HT 99")
						npc.SatisfactionEndTime = nil
						hook.Remove("Think", npc:EntIndex())
					end
				end)
			end

			for i, ent in ipairs(ents.FindInSphere(SelfPos, 512)) do
				if ent ~= self:GetOwner() and npc:Visible(ent) and ent:GetClass() ~= "npc_antlion" then
					npc:AddEntityRelationship(ent, D_HT, 99)
				end
			end
		end
	end

	timer.Simple(.02, function()
		if not IsValid(self) then return end
		sound.Play("weapons/mmod/bugbait/bugbait_impact"..(math.random(1, 2) and 1 or 3)..".wav", SelfPos, 80, math.random(95, 105))
	end)

	timer.Simple(.06, function()
		if not IsValid(self) then return end
		self:Remove()
	end)
end