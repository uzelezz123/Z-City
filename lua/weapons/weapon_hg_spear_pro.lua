if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Pro Spear"
SWEP.Instructions = "Spear of some slug creature...\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/distac/pro_spear.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_fubar.mdl"
SWEP.WorldModelExchange = "models/distac/pro_spear.mdl"
SWEP.ViewModel = ""

SWEP.NoHolster = false -- надо чтобы на спине показывался

SWEP.HoldType = "revolver"

SWEP.weight = 2
SWEP.HoldPos = Vector(-11,3,-1)
SWEP.HoldAng = Angle(0,-8,0)

SWEP.AttackTime = 0.5
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 1.2
SWEP.ViewPunch1 = Angle(0,2,-5)

SWEP.Attack2Time = 0.5
SWEP.AnimTime2 = 1.3
SWEP.WaitTime2 = 1.2
SWEP.ViewPunch2 = Angle(0,2,-5)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-35)
SWEP.weaponAng = Angle(90,90,0)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 35
SWEP.DamageSecondary = 35

SWEP.BreakBoneMul = 10

SWEP.PenetrationPrimary = 25
SWEP.PenetrationSecondary = 25

SWEP.MaxPenLen = 25

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 3

SWEP.StaminaPrimary = 8
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 45

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Shove",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_pro_spear.png")
	SWEP.IconOverride = "vgui/icons/ico_pro_spear.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Concrete.ImpactHard"
SWEP.Attack2Hit = "Concrete.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)

if SERVER then
    function SWEP:CustomAttack2()
        local ent = ents.Create("ent_throwable")
        ent.WorldModel = self.WorldModelExchange or self.WorldModel
        
        local ply = self:GetOwner()

        ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
        ent:SetAngles(ply:EyeAngles())
        ent:SetOwner(self:GetOwner())
        ent:Spawn()

        ent.localshit = Vector(50,0,0)
        ent.wep = self:GetClass()
        ent.owner = ply
        ent.damage = 50
        ent.uglublenie = 35
        ent.returndamage = 35
        ent.returnblood = 100
        ent.PenetrationSize = 25
        ent.Penetration = 45
        ent.AeroDrag = true

        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
            phys:AddAngleVelocity(Vector(0,0,0))
        end

        //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
        ply:SelectWeapon("weapon_hands_sh")
        ply:ViewPunch(Angle(0, 0, -8))

        self:Remove()

        return true
    end
end

function SWEP:CanSecondaryAttack()
    local owner = self:GetOwner()
    local org = owner.organism
    if CLIENT and owner ~= LocalPlayer() then return end
    if org and org.stamina and org.stamina[1] < self.StaminaSecondary then return false end
    return true
end

SWEP.AttackTimeLength = 0.2
SWEP.Attack2TimeLength = 0.2

SWEP.AttackRads = 2
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.95