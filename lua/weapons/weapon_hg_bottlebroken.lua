if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Broken Bottle"
SWEP.Instructions = "Broken beer bottle, looks like someone was too drunk.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "knife"

SWEP.WorldModel = "models/props_junk/glassbottle01a_chunk01a.mdl"
SWEP.WorldModelReal = "models/weapons/salat/reanim/c_s&wch0014.mdl"
SWEP.WorldModelExchange = "models/props_junk/glassbottle01a_chunk01a.mdl"

SWEP.SuicidePos = Vector(-10, 1, -11)
SWEP.SuicideAng = Angle(-40, 0, 0)
SWEP.SuicideCutVec = Vector(-1, 5, 4)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicideSound = "snd_jack_hmcd_knifestab.wav"
SWEP.SuicideNoLH = true

SWEP.BreakBoneMul = 0.1

SWEP.AnimTime1 = 1.0
SWEP.AttackTime = 0.2
SWEP.WaitTime1 = 0.5

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_botle_broken.png")
	SWEP.IconOverride = "vgui/icons/ico_botle_broken.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.NoHolster = true

SWEP.DamagePrimary = 9

SWEP.PenetrationPrimary = 1.3

SWEP.StaminaPrimary = 15

SWEP.BleedMultiplier = 1.5

SWEP.AttackLen1 = 40

SWEP.AttackHit = "GlassBottle.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_knifestab.wav"

SWEP.DeploySnd = "GlassBottle.ImpactSoft"

SWEP.DamageType = DMG_SLASH
SWEP.PainMultiplier = .4
SWEP.MaxPenLen = 0.7
SWEP.PenetrationSizePrimary = 1.2

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab",
    ["attack2"] = "midslash1",
    ["duct_cut"] = "cut",
    ["inspect"] = "inspect"
}

SWEP.HoldPos = Vector(-4,0,-1)
SWEP.HoldAng = Angle(0,0,0)
SWEP.weaponPos = Vector(-0,0.5,1)
SWEP.weaponAng = Angle(0,3,99)
SWEP.basebone = 39

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackPos = Vector(-3,8,-20)

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER and ent and math.random(1, self:IsEntSoft(ent) and 30 or 10) == 1 then
        self:PrecacheGibs()
        self:GibBreakServer(trace.HitNormal * -100)
        self:GetOwner():EmitSound("physics/glass/glass_pottery_break" .. math.random(1, 4) .. ".wav")
        self:Remove()
    end
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 65
SWEP.AttackRads2 = 0

SWEP.SwingAng = -35
SWEP.SwingAng2 = 0