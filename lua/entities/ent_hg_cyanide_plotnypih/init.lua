AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("chlorine_gas")
function ENT:Initialize()
	self.spawntime = CurTime()
	self.particles = {}
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(1)
		phys:Wake()
		phys:EnableMotion(true)
	end
end
local ents_FindInSphere = ents.FindInSphere
function ENT:Think()
	if self.spawntime + 3 > CurTime() then return end
	if (#self.particles < self.totalparticles) and ((math.Round(CurTime() - self.spawntime) % 2) == 0) then
		table.insert(self.particles,{self:GetPos(),VectorRand(-5,5)+vector_up*5,CurTime() + 60})
	end

	if (#self.particles == self.totalparticles) and not self.particles[#self.particles] then
		return
	end

	for i,tbl in ipairs(self.particles) do
		if not tbl then continue end
		local pos,vel,time = tbl[1],tbl[2],tbl[3]
		if time < CurTime() then self.particles[i] = false continue end
		
		tbl[2] = vel - vector_up * 0.3

		local tr = util.TraceLine({start = pos,endpos = pos + vel,filter = self,mask = MASK_SOLID_BRUSHONLY})
		
		tbl[1] = (tr.Hit and tr.HitPos or pos + vel)
		
		local velLen = vel:Length()
		if tr.Hit then
			local vec = vel:Angle()
			vec:RotateAroundAxis(tr.HitNormal,180)
			tbl[2] = -vec:Forward() * velLen
		end

		for i,ent in ipairs(ents_FindInSphere(pos,124)) do
			if (not ent.organism) then continue end
			if not ent.organism.owner:IsPlayer() then continue end
			if util.TraceLine({start = pos,endpos = ent:GetPos(),filter = {self,ent},mask = MASK_SOLID_BRUSHONLY}).Hit then continue end

			if (ent.organism.owner.armors["face"] != "mask2") and ent.PlayerClassName ~= "Combine" and (math.random(2) == 1) then
				local dmg = DamageInfo()
				dmg:SetDamage(2)
				dmg:SetDamageType(DMG_NERVEGAS)
				dmg:SetInflictor(self)
				dmg:SetAttacker(self)
				ent:TakeDamageInfo(dmg)
			end
		end
	end


	self:NextThink(CurTime() + 1)
	net.Start("chlorine_gas")
		net.WriteTable(self.particles)
	net.Broadcast()
	return true
end

function ENT:OnRemove()
	self.particles = {}
	net.Start("chlorine_gas")
	net.WriteTable(self.particles)
	net.Broadcast()
end