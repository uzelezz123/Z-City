if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Tomahawk"
SWEP.Instructions = "A single-handed striking tool designed to be used as a melee weapon by military personnel or as a hunting tool. Can break down doors.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Damage = 25
SWEP.HoldType = "melee"

SWEP.Weight = 0
SWEP.weight = 1.5

SWEP.WorldModel = "models/pwb/weapons/w_tomahawk_thrown.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/pwb/weapons/w_tomahawk_thrown.mdl"
SWEP.ViewModel = ""

SWEP.SuicidePos = Vector(-12, -4, -8)
SWEP.SuicideAng = Angle(-0, 30, -50)
SWEP.SuicideCutVec = Vector(-2, -6, 2)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.HoldPos = Vector(-12,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.3
SWEP.AnimTime1 = 1.2
SWEP.WaitTime1 = 0.9
SWEP.ViewPunch1 = Angle(1,1,0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.7
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-2)
SWEP.weaponAng = Angle(0,-90,90)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Attack_Quick",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("pwb/sprites/tomahawk")
	SWEP.IconOverride = "pwb/sprites/tomahawk.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_solid_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end

function SWEP:CustomAttack2()
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = "models/pwb/weapons/w_tomahawk_thrown.mdl"
    
    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles() + Angle(0,0,90))
    ent:Spawn()

    ent.wep = self:GetClass()
    ent.owner = ply
    ent.localshit = Vector(4,6,0)
    ent.damage = 25

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(Vector(0,0,-ent.MaxSpeed) )
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()
    return true
end

function SWEP:PrimaryAttackAdd(ent)
    if hgIsDoor(ent) and math.random(6) > 3 then
        hgBlastThatDoor(ent, self:GetOwner():GetAimVector() * 50 + self:GetOwner():GetVelocity())
    end
end

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 40
SWEP.DamageSecondary = 9

SWEP.PenetrationPrimary = 10
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 3

SWEP.StaminaPrimary = 20
SWEP.StaminaSecondary = 20

SWEP.AttackLen1 = 40
SWEP.AttackLen2 = 30

SWEP.NoHolster = true

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 85
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.4