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

local hg_healanims = ConVarExists("hg_healanims") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE, "Toggle heal/food animations", 0, 1)

function SWEP:Think()
	self:SetBodyGroups("111")
	if not self:GetOwner():KeyDown(IN_ATTACK) and hg_healanims:GetBool() then
		self:SetHolding(math.max(self:GetHolding() - 4, 0))
	end
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
    if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end
    local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 - hold, 10))
    self:BoneSet("r_forearm", vector_origin, Angle(-15, -hold, -hold))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:NPCHeal(owner, 0.1, "snd_jack_hmcd_pillsuse.wav")
	end
end

if SERVER then
	function SWEP:Heal(ent, mode)
		if ent:IsNPC() then
			self:SpawnGarbage(nil, nil, "snd_jack_hmcd_foodbounce.wav")
			self:NPCHeal(ent, 0.1, "snd_jack_hmcd_pillsuse.wav")
		end

        local org = ent.organism
        if not org then return end

		local owner = self:GetOwner()
		if ent == hg.GetCurrentCharacter(owner) and hg_healanims:GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 4, 100))

			if self:GetHolding() < 100 then return end
		end

        local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
        entOwner:EmitSound("snd_jack_hmcd_pillsuse.wav", 60, math.random(95, 105))

        org.adrenalineAdd = math.Approach(org.adrenalineAdd, -4, self.modeValues[1] * 2)

        self.modeValues[1] = 0
        if self.modeValues[1] == 0 then
            owner:SelectWeapon("weapon_hands_sh")
			self:SpawnGarbage(nil, nil, "snd_jack_hmcd_foodbounce.wav")
            self:Remove()
        end
    end
end