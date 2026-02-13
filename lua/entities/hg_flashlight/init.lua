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
	self:SetModelScale(0.75)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:OnRemove()
end

function ENT:Use(activator)
	self:TakeByPlayer(activator)
end

function ENT:Think()
end

function ENT:TakeByPlayer(activator)
	if activator:IsPlayer() then-- and not table.HasValue(activator.inventory.Attachments, self.name) then
		activator.inventory = activator:GetNetVar("Inventory") or activator.inventory
		activator.inventory["Weapons"]["hg_flashlight"] = true
		activator:SetNetVar("Inventory",activator.inventory)
		activator:SetNetVar("flashlight",self:GetNetVar("enabled"))
		self:EmitSound("physics/metal/weapon_impact_soft" .. math.random(3) .. ".wav", 65, math.random(90, 110), 1, CHAN_ITEM)
		self:Remove()
	end
end