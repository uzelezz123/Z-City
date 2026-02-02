if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Gymnastic Stick"
SWEP.Instructions = "A side-handle baton issued to law enforcement officers for riot control and self-defense. Its long reach and heavy weight make it an effective tool for subduing suspects. The tonfa is typically used in pairs, one in each hand, to block and strike opponents. It is an essential part of a police officer's toolkit, and a powerful weapon in the right hands.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/w_jjife_t.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/weapons/tacint_melee/w_tonfa.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "melee"

SWEP.HoldPos = Vector(-12,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.4
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 1
SWEP.ViewPunch1 = Angle(0,-5,3)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-4)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-8)
SWEP.weaponAng = Angle(0,-90,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 16
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 1.5

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 12
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 55
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}


if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_zac_hmcd_policebaton")
	SWEP.IconOverride = "entities/tacrp_m_tonfa.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false


SWEP.AttackHit = "Plastic_Box.ImpactHard"
SWEP.Attack2Hit = "Plastic_Box.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Plastic_Box.ImpactSoft"

SWEP.AttackPos = Vector(0,0,0)

SWEP.DesiredSilks = {	--; WARNING POINTER
	{SegmentsDesiredAmt = 5, SegmentsDesiredWidth = 0.5, SegmentsDesiredLength = 6, SegmentsDesiredAirResist = 0.5, SegmentsDesiredTrebble = 0.35, EntityOffset = Vector(0, 0, 20), DoCustomEntityOffset = true},
	{SegmentsDesiredAmt = 6, SegmentsDesiredWidth = 0.5, SegmentsDesiredLength = 6, SegmentsDesiredAirResist = 0.5, SegmentsDesiredTrebble = 0.35, EntityOffset = Vector(0.1, 0, 20), DoCustomEntityOffset = true},
	{SegmentsDesiredAmt = 10, SegmentsDesiredWidth = 0.5, SegmentsDesiredLength = 6, SegmentsDesiredAirResist = 0.5, SegmentsDesiredTrebble = 0.35, EntityOffset = Vector(0, 0.1, 20), DoCustomEntityOffset = true},
}


function SWEP:DrawPostWorldModel()
	if(hg.PhysSilk)then
		local model_ent = self.worldModel
		
		if(IsValid(self.worldModel2))then
			model_ent = self.worldModel2
		end
		
		model_ent.Silk_RenderPos = model_ent:GetRenderOrigin()
		model_ent.Silk_RenderAngles = model_ent:GetRenderAngles()
		self.Silks = self.Silks or {}

		for silk_desired_key, silk_desired in ipairs(self.DesiredSilks) do
			if(IsValid(self.Silks[silk_desired_key]))then
				-- self.Silks[silk_desired_key].Pos = self:LocalToWorld(silk_desired.EntityOffset)
			else
				local silk = table.Copy(silk_desired)
				silk.Pos = model_ent:LocalToWorld(silk_desired.EntityOffset)
				silk.Entity = model_ent
				self.Silks[silk_desired_key] = hg.PhysSilk.CreateSilk(silk, true)
			end
		end
	end
end
--[[
function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end
]]