AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetModelScale(0.5)
	self:Activate()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)
	self.isbomb = true
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:OnRemove()
end

util.AddNetworkString("bomb_look")
util.AddNetworkString("bomb_enter")

function BombInSite(pos, site)
	local pts = zb.GetMapPoints( "BOMB_ZONE_"..(site == 1 and "A" or "B") )

	local vec1
	local vec2

	if #pts >= 2 then
		vec1 = -(-pts[1].pos)
		vec1[3] = vec1[3] - 256
		vec2 = -(-pts[2].pos)
		vec2[3] = vec2[3] + 256
	end

	return (#pts >= 2 and pos:WithinAABox(vec1, vec2))
end

net.Receive("bomb_enter",function(len, ply)
	if !ply:Alive() then return end
	
	local org = ply.organism

	if !org.canmove then return end

	local txt = net.ReadString()
	local num = tonumber(txt)
	
	--ply:ChatPrint(txt)
	local ent = ply.bomb
	
	if ent.isbomb then
		if not ent.active then
			local isSandbox = engine.ActiveGamemode() == "sandbox"
			if isSandbox or BombInSite(ent:GetPos(), 1) or BombInSite(ent:GetPos(), 2) then
				ent.code = txt
				ply:ChatPrint("The bomb's code is: "..ent.code)
				ent:ActivateBomb()
			else
				ply:ChatPrint("The bomb must be planted on site")
			end
		else
			if ent.code == txt then
				ent:DisableBomb()
				ent:SetNetVar("knowncode", "******")
				ply:ChatPrint("The bomb has been disarmed.")
			else
				local bombtxt = ent.code
				local knownnumbers = ent:GetNetVar("knowncode","******")
				local newknownnumbers = ""

				for i = 1,#bombtxt do
					if (bombtxt[i] == txt[i]) then
						newknownnumbers = newknownnumbers..(txt[i])
					else
						newknownnumbers = newknownnumbers..(knownnumbers[i] == bombtxt[i] and knownnumbers[i] or "*")
					end
				end

				ent:SetNetVar("knowncode", newknownnumbers)
				ply:ChatPrint(newknownnumbers)
			end
		end
	end
end)

function ENT:DisableBomb()
	local activetime = self.ExplodeTime - (self:GetNetVar("timer") - CurTime())
	self:SetNetVar("timer", nil)
	self.addtime = activetime
	self.active = nil

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(true)
	end
end

local offsetPos = Vector(0,0,0)
local offsetAng = Angle(-90,0,180)
function ENT:ActivateBomb()
	self:SetNetVar("timer", CurTime() + self.ExplodeTime - (self.addtime or 0))
	self.active = true

	if self.tbl and not self.activatedonce then
		local siteName
		if BombInSite(self:GetPos(), 1) then
			siteName = "A"
		elseif BombInSite(self:GetPos(), 2) then
			siteName = "B"
		end
		PrintMessage(HUD_PRINTTALK, "Bomb has been planted"
			..(siteName and (" on site "..siteName) or "")
			..".")
		
		hg.UpdateRoundTime(zb.ROUND_TIME + self.ExplodeTime + 1)
	end

	self.activatedonce = true

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	local tr = {}
	tr.start = self:GetPos()
	tr.endpos = tr.start - vector_up * 1000
	tr.filter = self
	tr.mask = MASK_SOLID
	tr.mins = self:OBBMins()
	tr.maxs = self:OBBMaxs()
	
	local trace = util.TraceHull(tr)
	
	local pos, ang = LocalToWorld(offsetPos,offsetAng,trace.HitPos,trace.HitNormal:Angle())

	self:SetPos(pos)
	self:SetAngles(ang)
end

function ENT:Use(activator)
	local isSandbox = engine.ActiveGamemode() == "sandbox"
	--if self:IsPlayerHolding() then return end
	if not isSandbox then
		if not BombInSite(self:GetPos(), 1) and not BombInSite(self:GetPos(), 2) then activator:PickupObject(self) return end
	end
	if self.active then
		if activator:Team() == 0 then
			activator:ChatPrint("The bomb's code is: "..self.code)
			return
		end
	end
	
	activator:PickupObject(self)
	self.user = activator
	activator.bomb = self

	net.Start("bomb_look")
	net.WriteEntity(self)
	net.Send(activator)
end

ENT.nextbeep = 0

function ENT:Think()
	self:NextThink(CurTime())
	if self.active then
		if self:GetNetVar("timer") < CurTime() then
			zb.bombexploded = true
			util.ScreenShake( selfPos, 95, 500, 4, 1000 )
			hg.PropExplosion(self, "Fire", 300, 100)
		end

		--;; WHAT THE FAK YUUUUUUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH
		local timeLeft = self:GetNetVar("timer") - CurTime()
		if timeLeft <= 1.5 and timeLeft > 0 and not self.wtfPlayed and math.random(1, 100) <= 5 then
			self.wtfPlayed = true
			self:EmitSound("snds_jack_gmod/wtfboom.mp3")
		end

		if self.nextbeep < CurTime() and self:GetNetVar("timer") > CurTime() then
			local beep = math.max((self:GetNetVar("timer") - CurTime()) / self.ExplodeTime,0.05)	
			self.nextbeep = CurTime() + beep
			for i, ent in ipairs(ents.FindInSphere(self:GetPos(),32 / beep)) do
				if ent.organism then
					ent.organism.adrenalineAdd = ent.organism.adrenalineAdd + 0.02 / beep
					ent.organism.fear = math.min(ent.organism.fear + 0.02 / beep, 1)
				end
			end
			self:EmitSound("snd_jack_chargecapacitor.wav")
		end

		return true
	end
	
	
	if not self.active and self.wtfPlayed then
		self.wtfPlayed = nil
	end

	if self.user and not self:IsPlayerHolding() then
		net.Start("bomb_look")
		net.WriteEntity(NULL)
		net.Send(self.user)
		self.user.bomb = nil
		self.user = nil
	end

	return true
end
