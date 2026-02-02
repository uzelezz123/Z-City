if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Pan"
SWEP.Instructions = "A cast iron cooking pan that can pack a deadly punch. Can't protect from bullets.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/props_c17/metalPot002a.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_pipe_lead.mdl"
SWEP.WorldModelExchange = "models/props_c17/metalPot002a.mdl"
SWEP.ViewModel = ""

SWEP.NoHolster = true

SWEP.BreakBoneMul = 0.5

SWEP.HoldType = "melee"
SWEP.TwoHanded = false

SWEP.HoldPos = Vector(-13,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 0.95
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,3)
SWEP.weaponAng = Angle(-90,0,0)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_pan.png")
	SWEP.IconOverride = "vgui/icons/ico_pan.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true


SWEP.AttackHit = "SolidMetal.ImpactHard"
SWEP.Attack2Hit = "SolidMetal.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "SolidMetal.ImpactSoft"

SWEP.AttackPos = Vector(0,0,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 33
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 40
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 36
SWEP.AttackLen2 = 30

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 100
SWEP.AttackRads2 = 0

SWEP.SwingAng = -175
SWEP.SwingAng2 = 0