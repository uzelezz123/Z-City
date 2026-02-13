AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local vecZero, vec30 = Vector(0,0,0), Vector(0,0,30)
function ENT:Initialize()
	self:SetModel(self.PhysModel or self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)
	self:SetPos(self:GetPos() + vec30)

	if self.material and !istable(self.material) then
		self.mat = self.material
		self:SetSubMaterial(0,self.material)
	end

	if self.material and istable(self.material) then
		self.mat = table.Random(self.material)
		self:SetSubMaterial(0,self.mat)
	end

	if self.skins then
		self.skin = self.skins[math.random(#self.skins)]
		self:SetSkin(self.skin)
	end

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

function ENT:TakeByPlayer(activator)
	if not activator:IsPlayer() then return end

	local can = hg.AddArmor(activator,self.name, self)
    if can then
		if self.zablevano then
			activator:SetNetVar("zableval_masku", true)
		end

		self:EmitSound("snd_jack_hmcd_disguise.wav", 75, math.random(90,110), 1, CHAN_ITEM)
        self:Remove()
	end
end

function ENT:ApplyData(ply,equipment)
	ply:SetNWString("ArmorMaterials" .. equipment, self.mat)
	ply:SetNWInt("ArmorSkins" .. equipment, self.skin or 0)
end

function ENT:ReciveData(ply,equipment)
	--print(ply,equipment, ply:GetNWString("ArmorMaterials" .. equipment, self.mat))
	self.mat = ply:GetNWString("ArmorMaterials" .. equipment, self.mat)
	self:SetSubMaterial(0,self.mat)

	self.skin = ply:GetNWInt("ArmorSkins" .. equipment, self.skin or 0)
	self:SetSkin(self.skin)
end

hook.Add("ItemsTransfered","TransferMats",function(ply, ragdoll)
	local armors = ply:GetNetVar("Armor",{})
	for k,v in pairs(armors) do
		ragdoll:SetNWString("ArmorMaterials" .. v, ply:GetNWString("ArmorMaterials" .. v))
		ply:SetNWString("ArmorMaterials" .. v, nil)

		ragdoll:SetNWInt("ArmorSkins" .. v, ply:GetNWInt("ArmorSkins" .. v))
		ply:SetNWInt("ArmorSkins" .. v, nil)
	end
end)

hook.Add("ItemTransfer", "TransferMats", function(ply, ent, placement, armor)
	ply:SetNWString("ArmorMaterials" .. armor, ent:GetNWString("ArmorMaterials" .. armor))
	ent:SetNWString("ArmorMaterials" .. armor, nil)

	ply:SetNWInt("ArmorSkins" .. armor, ent:GetNWInt("ArmorSkins" .. armor))
	ent:SetNWInt("ArmorSkins" .. armor, nil)
end)