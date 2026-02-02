if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Modified spear"
SWEP.Instructions = "A spear is an effective weapon to attack at a distance.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/distac/spear_wood_knife.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_fubar.mdl"
SWEP.WorldModelExchange = "models/distac/spear_wood_knife.mdl"
SWEP.ViewModel = ""

SWEP.NoHolster = true

SWEP.HoldType = "revolver"

SWEP.weight = 3
SWEP.HoldPos = Vector(-11,5,0)
SWEP.HoldAng = Angle(0,-6,0)

SWEP.AttackTime = 0.7
SWEP.AnimTime1 = 2
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.7
SWEP.AnimTime2 = 2.1
SWEP.WaitTime2 = 1.4
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-35)
SWEP.weaponAng = Angle(90,90,0)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 60
SWEP.DamageSecondary = 15

SWEP.BreakBoneMul = 5

SWEP.PenetrationPrimary = 10
SWEP.PenetrationSecondary = 5

SWEP.MaxPenLen = 20

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 3

SWEP.StaminaPrimary = 30
SWEP.StaminaSecondary = 60

SWEP.AttackLen1 = 105
SWEP.AttackLen2 = 45

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Shove",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_spear_modified.png")
	SWEP.IconOverride = "vgui/icons/ico_spear_modified.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Concrete.ImpactHard"
SWEP.Attack2Hit = "Concrete.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.2
SWEP.Attack2TimeLength = 0.2

SWEP.AttackRads = 2
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.95

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
    ent.damage = 45
    ent.uglublenie = 30
    ent.returndamage = 30
    ent.returnblood = 100
    ent.PenetrationSize = 15
    ent.Penetration = 40

    ent.hitworldfunc = function(ent)
        ent.wep = "weapon_hg_spear"
        ent:SetModel("models/distac/spear_wood.mdl")
        local knife = ents.Create("weapon_pocketknife")
        knife:SetPos(ent:GetPos())
        knife:SetAngles(ent:GetAngles())
        knife:Spawn()
        knife.IsSpawned = true
        knife.init = true
    end

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


function SWEP:CanSecondaryAttack()
    local owner = self:GetOwner()
    local org = owner.organism
    if CLIENT and owner ~= LocalPlayer() then return end
    if org and org.stamina and org.stamina[1] < self.StaminaSecondary then return false end
    return true
end

function SWEP:CanPrimaryAttack()
    return true
end