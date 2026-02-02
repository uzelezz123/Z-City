AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local clr = Color(115, 135, 255)
function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(ONOFF_USE)
	self:DrawShadow(true)
	self:SetColor(clr)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:ActivateAlarm(tr)
	local selfPos = self:GetPos()

	local pitch = math.random(90, 110)
	self:EmitSound(self.Sound, 100, pitch)
	sound.Play(self.Sound, selfPos, 70, pitch)
	sound.Play(self.Sound, selfPos, 100, pitch) -- "npc/stalker/go_alert2a.wav"

	if tr and tr ~= nil then
		self:EmitSound("ambient/water/water_splash"..math.random(3)..".wav", 60)
		for i = 1, 5 do
			local Spark = EffectData()
			Spark:SetOrigin(self:GetPos())
			Spark:SetScale(i)
			Spark:SetNormal(self:GetUp())
			util.Effect("eff_jack_hmcd_fuzeburn",Spark,true,true)
			util.Decal("PaintSplatGreen", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetInflictor() == self then return end
	self:ActivateAlarm()

	for i = 1, 5 do
		local Spark = EffectData()
		Spark:SetOrigin(self:GetPos())
		Spark:SetScale(i)
		Spark:SetNormal(self:GetUp())
		util.Effect("eff_jack_hmcd_fuzeburn",Spark,true,true)
	end
	SafeRemoveEntity(self)
end