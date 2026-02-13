AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/mosi/fallout4/props/weapons/melee/knuckles.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:Use(activator)
	self:TakeByPlayer(activator)
end

function ENT:TakeByPlayer(activator)
	if activator:IsPlayer() and not table.HasValue(activator.inventory.Attachments, self.name) then
		activator.inventory = activator:GetNetVar("Inventory",activator.inventory)
		activator.inventory["Weapons"] = activator.inventory["Weapons"] or {}
		if activator.inventory["Weapons"]["hg_brassknuckles"] then return end
		activator.inventory["Weapons"]["hg_brassknuckles"] = true
		activator:SetNetVar("Inventory",activator.inventory)
		self:EmitSound("physics/metal/metal_solid_impact_soft1.wav", 65, math.random(110, 120), 0.6, CHAN_ITEM)
		self:Remove()
	end
end