if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "'Uber' Norepinephrine"
SWEP.Instructions = "An experimental combat stimulant refined from early Fury-13 samples with uncertain origin, nicknamed as 'Fury-16'.\n\nInstead of modifying your body, it forces it to burn through every resource for a massive speed boost. Functions by flooding the system with synthetic noradrenaline, inducing extreme vasoconstriction and cardiac output."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("entities/zcity/fury16.png")
	SWEP.IconOverride = "entities/zcity/fury16.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AdminOnly = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(3, -2.5, -1)
SWEP.offsetAng = Angle(-30, 20, -90)
SWEP.ModelScale = 0.75
SWEP.Color = Color(0, 90, 255)
SWEP.modeNames = {
	[1] = "fury-13"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

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

function SWEP:NPCHeal(npc, mul, snd)
	if not npc then npc = self:GetOwner() end

	if npc:IsNPC() then
		self:SetHold("melee")
		if not mul then mul = 0.3 end
		npc:SetHealth(math.Clamp(npc:Health() + (npc:GetMaxHealth() * 1 * mul), 0, npc:GetMaxHealth() * math.Clamp(2 * mul, 2, 100)))
		npc:EmitSound(snd or "snd_jack_hmcd_needleprick.wav", 80, math.random(95, 105))
		npc:SetPlaybackRate(6)
		npc:SetKeyValue("m_flPlaybackSpeed", 6)

		if SERVER then
			self:Remove()
		end
	end
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:NPCHeal(owner, 20, "snd_jack_hmcd_needleprick.wav")
	end
end

if SERVER then
	function SWEP:Heal(ent, mode)
		if ent:IsNPC() then
			self:NPCHeal(ent, 20, "snd_jack_hmcd_needleprick.wav")
		end

		local org = ent.organism
		if not org then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 80, math.random(115, 120))

		if org.berserk >= 0.4 then
			ent:Kill()
		end

		if org.noradrenaline >= 1 then
			--ent:Kill()
		end

		org.noradrenaline = org.noradrenaline + 1.25

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