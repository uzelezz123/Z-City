AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("cyanide_debug")
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
local ents_FindInSphere, CurTime, ipairs, table, math, VectorRand = ents.FindInSphere, CurTime, ipairs, table, math, VectorRand
function ENT:Think()
	if self.spawntime + 10 > CurTime() then return end
	--if util.PointContents(self:GetPos()) --если в воде добавить проверку потом
	if (#self.particles < self.totalparticles) and ((math.Round(CurTime() - self.spawntime) % 3) == 0) then
		table.insert(self.particles,{self:GetPos(),VectorRand(-5,5),CurTime() + 60})
	end

	if (#self.particles == self.totalparticles) and not self.particles[#self.particles] then
		return
	end

	for i,tbl in ipairs(self.particles) do
		if not tbl then continue end
		local pos,vel,time = tbl[1],tbl[2],tbl[3]
		if time < CurTime() then self.particles[i] = false continue end
		
		tbl[2] = vel - vector_up * 0.2

		local tr = util.TraceLine({start = pos,endpos = pos + vel,filter = self,mask = bit.bor(MASK_SOLID_BRUSHONLY,CONTENTS_WATER)})
		
		tbl[1] = (tr.Hit and tr.HitPos or pos + vel)
		
		local velLen = vel:Length()
		if tr.Hit then
			local vec = vel:Angle()
			vec:RotateAroundAxis(tr.HitNormal,180)
			tbl[2] = -vec:Forward() * velLen
		end

		for i,ent in ipairs(ents_FindInSphere(pos,64)) do
			if (not ent.organism) or ent.organism.poison3 or ent.organism.holdingbreath then continue end
			if not ent.organism.owner:IsPlayer() then continue end
			if util.TraceLine({start = pos,endpos = ent:GetPos(),filter = {self,ent},mask = MASK_SOLID_BRUSHONLY}).Hit then continue end
			
			if (ent.organism.owner.armors["face"] != "mask2") and ent.PlayerClassName ~= "Combine" and (math.random(2) == 1) then
				local mode_hmcd = (zb and zb.modes) and zb.modes["hmcd"]
				
				if mode_hmcd then
					if(ent.SubRole == "traitor_chemist")then
						local ply_cyanide_accumulated = mode_hmcd.AddChemicalToPlayer(ent, "HCN", 10)
						
						if(ply_cyanide_accumulated > 100)then
							ent.organism.poison3 = CurTime()
						end
						
						mode_hmcd.NetworkChemicalResistanceOfPlayer(ent)
						
						ent.PassiveAbility_ChemicalAccumulation_NextNetworkTime = CurTime() + 1
						
						-- ent:ChatPrint("cyanide = " .. math.Round(ply_cyanide_accumulated) .. " / " .. "10")
					else
						ent.organism.poison3 = CurTime()
					end
				else
					ent.organism.poison3 = CurTime()
				end
			end
		end
	end
	--[[net.Start("cyanide_debug")
	net.WriteTable(self.particles)
	net.Broadcast()--]]
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	self.particles = {}
	net.Start("cyanide_debug")
	net.WriteTable(self.particles)
	net.Broadcast()
end