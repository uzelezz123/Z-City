if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Mug"
SWEP.Instructions = "A small mug typically used to hold liquids.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "melee"

SWEP.WorldModel = "models/props_junk/garbage_coffeemug001a.mdl"
SWEP.WorldModelReal = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModelExchange = "models/props_junk/garbage_coffeemug001a.mdl"

SWEP.weaponPos = Vector(0,0.4,-3.5)
SWEP.weaponAng = Angle(0,-90,90)

SWEP.BreakBoneMul = 0.25

SWEP.AnimList = {
    ["idle"] = "vm_knifeonly_idle",
    ["deploy"] = "vm_knifeonly_raise",
    ["attack"] = "vm_knifeonly_stab",
    ["attack2"] = "vm_knifeonly_swipe",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_mug.png")
	SWEP.IconOverride = "vgui/icons/ico_mug.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.NoHolster = true

SWEP.AttackPos = Vector(0,0,0)
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 15
SWEP.DamageSecondary = 12

SWEP.PenetrationPrimary = 1.3
SWEP.PenetrationSecondary = 1

SWEP.MaxPenLen = 4

SWEP.PainMultiplier = 0.5

SWEP.PenetrationSizePrimary = 1
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 6
SWEP.StaminaSecondary = 3

SWEP.AttackLen1 = 45
SWEP.AttackLen2 = 30

SWEP.HoldPos = Vector(-8, 1, -2)

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
	addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -4 or 0)
	addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -1 or 0)
	addPosLerp.y = addPosLerp.y + (self:GetBlocking() and 8.5 or 0)
	addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -30 or 0)

    return true
end

SWEP.AttackHit = "GlassBottle.ImpactHard"
SWEP.Attack2Hit = "GlassBottle.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "GlassBottle.ImpactSoft"

function SWEP:PrimaryAttackAdd(ent,trace)
    if SERVER and ent and math.random(1,2) == 2 then -- я либо забыл это добавить либо ктото убрал если шо простите
        self:PrecacheGibs()
        self:GibBreakServer(trace.HitNormal * -100)
        self:GetOwner():EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
        self:Remove()
    end
end

function SWEP:CustomAttack2()
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()

    ent.localshit = Vector(0,0,0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = self.DamagePrimary * 0.7
    ent.MaxSpeed = 1100
    ent.DamageType = self.DamageType
    ent.AttackHit = "GlassBottle.ImpactHard"
    ent.AttackHitFlesh = "Flesh.ImpactHard"
    ent:PrecacheGibs()

    ent.func = function(data)
        if ent.removed then return end
        ent.removed = true
        timer.Simple(0, function()
            ent:GibBreakServer(vector_origin)
            ent:EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
            ent:Remove()
        end)
    end

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:ViewPunch(self.ViewPunch1 * 0.6)
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 45
SWEP.AttackRads2 = 0

SWEP.SwingAng = -85
SWEP.SwingAng2 = 0