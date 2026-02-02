if SERVER then
    AddCSLuaFile()
end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Chair leg"
SWEP.Instructions = "Someone's savagely ripped out chair leg, quite suitable as a cold weapon. Better than nothing i guess.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/tfa_nmrih/w_me_hatchet.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/gibs/furniture_gibs/furniture_chair01a_gib02.mdl"
SWEP.weaponPos = Vector(0, 0, 2)
SWEP.weaponAng = Angle(5, -90, 0)
SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)
SWEP.basebone = 94
SWEP.BreakBoneMul = .2
SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/icons/ico_chair_leg.png")
    SWEP.IconOverride = "vgui/icons/ico_chair_leg.png"
    SWEP.BounceWeaponIcon = false
end
SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false
SWEP.NoHolster = true
SWEP.HoldPos = Vector(-15, 0, 0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.AttackPos = Vector(0, 0, 0)
SWEP.HoldType = "melee"
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 8
SWEP.DamageSecondary = 7
SWEP.PenetrationPrimary = 0.9
SWEP.PenetrationSecondary = 0.7
SWEP.MaxPenLen = 2
SWEP.PainMultiplier = .35
SWEP.PenetrationSizePrimary = 1
SWEP.PenetrationSizeSecondary = 2
SWEP.StaminaPrimary = 7
SWEP.StaminaSecondary = 6
SWEP.AttackLen1 = 40
SWEP.AttackLen2 = 27
SWEP.AttackHit = "Wood.ImpactHard"
SWEP.Attack2Hit = "Wood.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Wood.ImpactSoft"

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackTimeLength = 0.1
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 55
SWEP.AttackRads2 = 65

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0