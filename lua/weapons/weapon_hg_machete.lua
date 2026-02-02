if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Machete"
SWEP.Instructions = "A machete is a broad blade used either as an agricultural implement similar to an axe, or in combat like a long-bladed knife.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/tfa_nmrih/w_me_machete.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_machete.mdl"
--SWEP.WorldModelExchange = "models/weapons/tfa_nmrih/w_me_machete.mdl"
SWEP.ViewModel = ""

SWEP.SuicidePos = Vector(20, 1, -27)
SWEP.SuicideAng = Angle(-90, -180, 90)
SWEP.SuicideCutVec = Vector(3, -6, 0)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "weapons/knife/knife_hit1.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.bloodID = 3

SWEP.NoHolster = true

SWEP.HoldType = "melee"

SWEP.DamageType = DMG_SLASH

SWEP.HoldPos = Vector(-15,1,-4)
SWEP.HoldAng = Angle(-2,0,-4)

SWEP.AttackTime = 0.25
SWEP.AnimTime1 = 1.1
SWEP.WaitTime1 = 0.9
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.15
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(1,2,-2)

SWEP.ViewPunchDiv = -50

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(0,0,0)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 30
SWEP.DamageSecondary = 3
SWEP.BleedMultiplier = 1.8
SWEP.PainMultiplier = 1.3

SWEP.PenetrationPrimary = 7
SWEP.PenetrationSecondary = 0

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 0

SWEP.StaminaPrimary = 25
SWEP.StaminaSecondary = 10

SWEP.AttackLen1 = 50
SWEP.AttackLen2 = 35
SWEP.weight = 1.2

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/zcity/machete.png")
	SWEP.IconOverride = "entities/zcity/machete.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "weapons/knife/knife_hit1.wav"
SWEP.Attack2HitFlesh = "physics/flesh/flesh_impact_hard1.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:CanSecondaryAttack()
    local owner = self:GetOwner()
    if owner.organism and owner.organism.larmamputated then return end

    self.DamageType = DMG_CLUB
    self.AttackHit = "physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav"
    self.Attack2Hit = "physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav"
    self.Attack2HitFlesh = "physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav"
    self.setlh = true
    self.HoldType = "duel"
    timer.Simple(0.5,function()
        if IsValid(self) then
            self.setlh = false
            self.HoldType = "slam"
        end
    end)
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "snd_jack_hmcd_knifehit.wav"
    self.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
    self.AttackHitFlesh = "weapons/knife/knife_hit"..math.random(4)..".wav"
    return true
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.05

SWEP.AttackRads = 65
SWEP.AttackRads2 = 35

SWEP.SwingAng = -15
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = true
SWEP.MultiDmg2 = false

function SWEP:SecondaryAttackAdd(ent, trace)
    if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then trace.Entity:SetVelocity(trace.Normal * 70 * (trace.Entity:IsNPC() and 35 or 5)) end
    local phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone or 0)

    if IsValid(phys) then
        phys:ApplyForceOffset(trace.Normal * 42 * 100,trace.HitPos)
    end
end

SWEP.MinSensivity = 0.25