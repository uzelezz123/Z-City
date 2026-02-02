AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local color_white = Color(255, 255, 255)
function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMaterial(self.ModelMaterial or "")
	self:SetColor(self.Color or color_white)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	self:SetModelScale(self:GetModelScale() * self.ModelScale, 0)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(20)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:Use(activator)
	if activator:IsPlayer() then
		activator:GiveAmmo(self.AmmoCount, self.AmmoType, true)
		self:EmitSound("snd_jack_hmcd_ammobox.wav", 75, math.random(90, 110), 1, CHAN_ITEM)
		self:Remove()
	end
end