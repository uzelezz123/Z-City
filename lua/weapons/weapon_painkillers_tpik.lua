if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Painkillers"
SWEP.Instructions = "Can be used to relieve pain (thanks Mr. Obvious). RMB to use on someone else."
SWEP.Category = "ZCity Anims items"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/nmrih/items/phalanx/w_phalanx.mdl"
SWEP.WorldModelReal = "models/weapons/nmrih/items/phalanx/v_item_phalanx.mdl"
SWEP.WorldModelExchange = false
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_painpills")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_painpills.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.modeNames = {
	[1] = "painkiller"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1
	}
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.HoldAng = Angle(0,0,0)
SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "anim_draw", 1, false },
    ["attack"] = { "pills", 5, false, false, function(self)
		if CLIENT then return end
		self:Heal(self:GetOwner())
	end },
	["idle"] = {"anim_idle", 5, true}
}

SWEP.HoldPos = Vector(-5,0,-1)
SWEP.HoldAng = Angle(0,0,0)

SWEP.modeValuesdef = {
	[1] = 1,
}

SWEP.CallbackTimeAdjust = 1.8

SWEP.showstats = false

SWEP.DeploySnd = "snd_jack_hmcd_pillsbounce.wav"
SWEP.FallSnd = "snd_jack_hmcd_pillsbounce.wav"

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	--local hold = self:GetHolding()
    --self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 -hold / 2, 10))
    --self:BoneSet("r_forearm", vector_origin, Angle(-5, -hold / 2.5, -hold / 1.5))
--
    --self:BoneSet("l_upperarm", vector_origin, lang1)
    --self:BoneSet("l_forearm", vector_origin, lang2)
end

if SERVER then

	function SWEP:PrimaryAttack()
		self:PlayAnim("attack")
	end

	local rndsounds = {"snd_jack_hmcd_pillsuse.wav"}
	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		if ent ~= self:GetOwner() and not ent.organism.otrub then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound(table.Random(rndsounds), 60, math.random(95, 105))
		org.analgesiaAdd = math.min(org.analgesiaAdd + self.modeValues[1] * 0.3, 4)
		owner:SelectWeapon("weapon_hands_sh")
		self:Remove()
		
		return true
	end
end