if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Decompression needle"
SWEP.Instructions = "Needle decompression is used to treat tension pneumothorax. LMB to use on yourself; RMB to use on someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_decompression_needle.png")
	SWEP.IconOverride = "vgui/icons/ico_decompression_needle.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(3, -2.5, -1)
SWEP.offsetAng = Angle(-30, 20, -90)
SWEP.ModelScale = 0.7
SWEP.modeNames = {
	[1] = "analgesia"
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	local owner = self:GetOwner()
	if owner:IsNPC() then
		self:SetHold("melee")
		owner:SetHealth(math.Clamp(owner:Health() + (owner:GetMaxHealth() * 0.15), 0, owner:GetMaxHealth() * 2))
		owner:EmitSound("snd_jack_hmcd_bandage.wav", 75, math.random(95, 105))
		self:Remove()
	end

	self.modeValues = {
		[1] = 1
	}
end

SWEP.modeValuesdef = {
	[1] = 1,
}

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
		local owner = self:GetOwner()
		self:SetBodygroup(1, 1)
		//if ((org.lungsL[2] + org.lungsR[2]) / 2 < 0.5) or org.needle then return end
		
		//if ent != owner and !org.otrub then return end -- meh??
		self:SetBodygroup(1, 1)
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))
		//org.lungsR[2] = 0
		//org.lungsL[2] = 0
		org.needle = 1

		if !(org.lungsR[2] == 1 or org.lungsL[2] == 1) then
			if math.random(2) == 1 then 
				org.lungsR[2] = 1
			else
				org.lungsL[2] = 1
			end
		end
		
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