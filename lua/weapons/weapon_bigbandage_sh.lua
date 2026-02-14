if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Большой бинт"
SWEP.Instructions = "Марлевый бинт, способный помочь остановить легкое кровотечение. Поскольку бинт находится без упаковки, маловероятно, что он стерилен.\n\nПКМ — использовать на другом человеке."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.modeValuesdef = {
	[1] = {150, true},
}

SWEP.ModelScale = 1.1
SWEP.offsetVec = Vector(3, -4.5, 0)
SWEP.offsetAng = Angle(90, 90, 0)
SWEP.Category = "ZCity Medicine"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_bandage")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_bandage.png"
	SWEP.BounceWeaponIcon = false
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:NPCHeal(owner, 0.25, "snd_jack_hmcd_bandage.wav")
	end
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)

	self.ModelScale = 1.1
	self.modeValues = {
		[1] = 150,
	}
end

local math = math
function SWEP:Think()
	self:SetHold(self.HoldType)
	self.ModelScale = math.Clamp((self.modeValues[1] / (self.modeValuesdef[1][1] * 0.8)) * 1.1, 0.5, 1.1)
end

SWEP.isFirstDeploy = true
function SWEP:Deploy()
	if SERVER or CLIENT and self:IsLocal() then
		self:EmitSound(self.DeploySnd,50,math.random(90,110))
	end

	if self.DeployAdd then self:DeployAdd() end

	if self.isFirstDeploy then
		local owner = self:GetOwner()
		if IsValid(owner) and owner.Profession == "doctor" then
			self.modeValuesdef = {
				[1] = {150, true},
			}
			self.modeValues = {
				[1] = 150,
			}
		end
		self.isFirstDeploy = false
	end

	return true
end

if SERVER then
	function SWEP:Heal(ent, mode, bone)
		local owner = self:GetOwner()
		if owner:IsNPC() then
			self:NPCHeal(owner, 0.25, "snd_jack_hmcd_bandage.wav")
		end
	
		local org = ent.organism
		if not org then return end
	
		local done = self:Bandage(ent, bone)
		if self.modeValues[1] <= 0 and self.ShouldDeleteOnFullUse then
			self:GetOwner():SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
		
		return done
	end
end