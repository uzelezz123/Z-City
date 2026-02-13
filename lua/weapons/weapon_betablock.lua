if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Beta-Blocker"
SWEP.Instructions = "Beta blockers can help in stressful situations, will reduce your panic and adrenaline. Very useful in combat at certain doses. RMB to inject into someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_pills.mdl"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_painpills")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_painpills.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(2.5, -2.5, 0)
SWEP.offsetAng = Angle(-30, 20, 180)
SWEP.modeNames = {
    [1] = "beta-blocker"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	local owner = self:GetOwner()
	if owner:IsNPC() then
		self:SetHold("melee")
		owner:SetHealth(math.Clamp(owner:Health() + (owner:GetMaxHealth() * 0.1), 0, owner:GetMaxHealth() * 2))
		owner:EmitSound("snd_jack_hmcd_pillsuse.wav", 75, math.random(95, 105))
		self:Remove()
	end

    self.modeValues = {
        [1] = 1
    }
end

SWEP.modeValuesdef = {
    [1] = 1
}

SWEP.DeploySnd = "snd_jack_hmcd_pillsbounce.wav"
SWEP.FallSnd = "snd_jack_hmcd_pillsbounce.wav"

SWEP.showstats = false

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
    if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end
    local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 - hold / 2, 10))
    self:BoneSet("r_forearm", vector_origin, Angle(-5, -hold / 2.5, -hold / 1.5))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

if SERVER then
    function SWEP:Heal(ent, mode)
        local org = ent.organism
        if not org then return end
        self:SetBodygroup(1, 1)
        local owner = self:GetOwner()
        local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
        entOwner:EmitSound("snd_jack_hmcd_pillsuse.wav", 60, math.random(95, 105))
        org.adrenalineAdd = math.Approach(org.adrenalineAdd, -4, self.modeValues[1] * 2)
        self.modeValues[1] = 0
        if self.modeValues[1] == 0 then
            owner:SelectWeapon("weapon_hands_sh")
            self:Remove()
        end
    end
end
