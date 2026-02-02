AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(0.2,function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)
	self:SetUseType(ONOFF_USE)
	self:DrawShadow(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(5)
		phys:Wake()
		phys:EnableMotion(true)
	end
	self.timeToBoom = math.Rand(2,7)
end

function ENT:AddThink()
	if not self.timer then return end
	self.nextthink = self.nextthink or CurTime()
	if self.nextthink > CurTime() then return end
	local time = self.timeToBoom - (CurTime() - self.timer)

	self.nextthink = CurTime() + 0.02
	
	if not self.Exploded and not self.SndStarted then
		self.SndStarted = true
		self.snd = self:StartLoopingSound("snds_jack_gmod/flareburn.wav")
		hg.EmitAISound(self:GetPos(), 256, 5, 8)
	end

	if not self.Exploded then
		local Spark=EffectData()
		Spark:SetOrigin(self:GetPos()+self:GetUp()*7)
		Spark:SetScale(1)
		Spark:SetNormal(self:GetUp())
		util.Effect("eff_jack_hmcd_fuzeburn",Spark,true,true)
	end

	if time < 0 and not self.Exploded then self:Explode() end
	--self:NextThink(CurTime() + 0.5 * math.max(time / (self.timeToBoom * 0.75),0.5))
	--return true
end
function ENT:ExplodeAdd()
	self:StopLoopingSound(self.snd)
end

function ENT:PoopBomb()
	self:StopLoopingSound(self.snd)
	return math.random(1, 100) < 5
end