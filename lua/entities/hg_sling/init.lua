AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)
	self:SetModelScale(2.5)
	self:SetColor(self.Color)
	self:SetMaterial(self.Material)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(15)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:Use(activator)
	self:TakeByPlayer(activator)
end

function ENT:TakeByPlayer(activator)
	if activator:IsPlayer() then-- and not table.HasValue(activator.inventory.Attachments, self.name) then
		activator.inventory = activator:GetNetVar("Inventory",activator.inventory)
		activator.inventory["Weapons"] = activator.inventory["Weapons"] or {}
		if activator.inventory["Weapons"]["hg_sling"] then return end
		activator.inventory["Weapons"]["hg_sling"] = true
		activator:SetNetVar("Inventory",activator.inventory)
		self:EmitSound("npc/footsteps/softshoe_generic6.wav", 75, math.random(90, 110), 1, CHAN_ITEM)
		self:Remove()
	end
end