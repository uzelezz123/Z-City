if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Mannitol"
SWEP.Instructions = "Mannitol is used intravenously to reduce acutely raised intracranial pressure until more definitive treatment can be applied, e.g., after head trauma. While mannitol injection is the mainstay for treating high pressure in the skull after a bad brain injury, it is no better than hypertonic saline as a first-line treatment. In treatment-resistant cases, hypertonic saline works better. Intra-arterial infusions of mannitol can transiently open the blood-brain barrier by disrupting tight junctions."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl"
SWEP.Model = "models/weapons/w_models/w_jyringe_jroj.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_manitol.png")
	SWEP.IconOverride = "vgui/icons/ico_manitol.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(5, -1.5, -2.5)
SWEP.offsetAng = Angle(90, 00, -90)
SWEP.modeNames = {
	[1] = "adrenaline"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	local owner = self:GetOwner()
	if owner:IsNPC() then
		self:SetHold("melee")
		owner:SetHealth(math.Clamp(owner:Health() + (owner:GetMaxHealth() * 0.1), 0, owner:GetMaxHealth() * 2))
		owner:EmitSound("snd_jack_hmcd_needleprick.wav", 75, math.random(95, 105))
		self:Remove()
	end

	self.modeValues = {
		[1] = 1
	}
end

SWEP.modeValuesdef = {
	[1] = 1
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

SWEP.showstats = false

function SWEP:Animation()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, (-55*hold/65) + hold / 2, 0))
    self:BoneSet("r_forearm", vector_origin, Angle(-hold / 6, -hold / 0.8, (-20*hold/100)))
end

if SERVER then
	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))
		org.mannitol = math.Approach(org.mannitol, 4, self.modeValues[1] * 2)
		self.modeValues[1] = 0

		if self.poisoned2 then
			org.poison4 = CurTime()

			self.poisoned2 = nil
		end

		if self.modeValues[1] == 0 then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
end