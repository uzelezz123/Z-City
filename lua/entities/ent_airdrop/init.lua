AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local clr = Color(100, 100, 100)
function ENT:Initialize()
	self:SetModel("models/props_junk/wood_crate001a.mdl")
	self:SetMaterial("models/props_pipes/guttermetal01a")
	self:SetColor(clr)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetHealth(100)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	timer.Create("CrateSmokeEffect_" .. self:EntIndex(), 1, 0, function()
		if IsValid(self) then
			local effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			util.Effect("eff_smokweed", effectData)
		end
	end)
end

function ENT:OnTakeDamage(dmginfo)
	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if self:Health() <= 0 then
		self:BreakCrate()
	end
end

function ENT:BreakCrate()
	local contents = self:GetNWString("Contents")
	local items = string.Explode(",", contents)
	for _, item in ipairs(items) do
		local ent = ents.Create(item)
		if IsValid(ent) then
			ent:SetPos(self:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), 10))
			ent:Spawn()
		end
	end
	self:Remove()
end

function ENT:OnRemove()
	if timer.Exists("CrateSmokeEffect_" .. self:EntIndex()) then
		timer.Remove("CrateSmokeEffect_" .. self:EntIndex())
	end
end