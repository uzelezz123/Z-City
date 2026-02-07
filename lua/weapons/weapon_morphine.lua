if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Morphine"
SWEP.Instructions = "A very strong medicine used primarily to lower the pressure and/or as an anesthetic. Morphine dose must be strictly observed, as it can lead to opiate overdose. Contains the maximum daily dose. RMB to inject into someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/morphine_syrette/morphine.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_morphine")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_morphine.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -1.5, 0)
SWEP.offsetAng = Angle(-30, 20, 180)
SWEP.modeNames = {
	[1] = "analgesic"
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1,
	}
end
SWEP.ofsV = Vector(0,8,-3)
SWEP.ofsA = Angle(-90,-90,90)
SWEP.modeValuesdef = {
	[1] = {1, true},
}

SWEP.showstats = true

function SWEP:Animation()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, (-55*hold/65) + hold / 2, 0))
    self:BoneSet("r_forearm", vector_origin, Angle(-hold / 6, -hold / 0.8, (-20*hold/100)))
end

sound.Add( {
	name = "pshiksnd",
	channel = CHAN_AUTO,
	volume = 0.02,
	level = 65,
	pitch = {5555, 5555},
	sound = "snd_jack_sss.wav",
} )

if SERVER then
	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner

		local injected = math.min(FrameTime() * 1, self.modeValues[1])
		org.analgesiaAdd = math.min(org.analgesiaAdd + injected, 4)
		self.modeValues[1] = math.max(self.modeValues[1] - injected, 0)

		owner.injectedinto = owner.injectedinto or {}
		owner.injectedinto[org.owner] = owner.injectedinto[org.owner] or 0
		owner.injectedinto[org.owner] = owner.injectedinto[org.owner] + injected

		if owner.injectedinto[org.owner] > 1 and injected > 0 then
			local dmgInfo = DamageInfo()
			dmgInfo:SetAttacker(owner)
			hook.Run("HomigradDamage", org.owner, dmgInfo, HITGROUP_RIGHTARM, hg.GetCurrentCharacter(org.owner), injected * (zb and zb.MaximumHarm or 1))
		end

		if self.poisoned2 then
			org.poison4 = CurTime()

			self.poisoned2 = nil
		end

		if self.modeValues[1] != 0 then
			entOwner:EmitSound("pshiksnd")
		else
			//owner:SelectWeapon("weapon_hands_sh")
			//self:Remove()
		end
	end
end