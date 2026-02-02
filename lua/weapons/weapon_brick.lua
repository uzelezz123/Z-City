if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Brick"
SWEP.Instructions = "A heavy construction brick, that can be used as a deadly weapon.\n\nLMB to attack.\nRMB to block.\nRMB + LMB to throw."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/w_brick.mdl"
SWEP.WorldModelReal = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModelExchange = "models/weapons/w_brick.mdl"
SWEP.DontChangeDropped = true

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_brick")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_brick"
	SWEP.BounceWeaponIcon = false
end

SWEP.weaponPos = Vector(0,-1,0)
SWEP.weaponAng = Angle(0,0,0)

SWEP.AttackHit = "Concrete.ImpactHard"
SWEP.Attack2Hit = "Concrete.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Concrete.ImpactHard"

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 6
SWEP.DamageSecondary = 6

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 2

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 15
SWEP.StaminaSecondary = 10

SWEP.AttackTime = 0.25
SWEP.AnimTime1 = 0.7
SWEP.WaitTime1 = 0.5
SWEP.AttackLen1 = 30

SWEP.Attack2Time = 0.1
SWEP.AnimTime2 = 0.5
SWEP.WaitTime2 = 0.4
SWEP.AttackLen2 = 30
SWEP.HP = 20

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER then
		local dmg = self.DamagePrimary
		local owner = self:GetOwner()

		if ent then
            self.HP = self.HP - 1
            if self.HP <= 0 then
                timer.Simple(0,function()
                    local Poof = EffectData()
                    Poof:SetOrigin(trace.HitPos)
                    Poof:SetScale(3)
                    Poof:SetNormal(-trace.HitNormal)
                    util.Effect("eff_jack_hmcd_poof", Poof, true, true)
                end)
                owner:EmitSound("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav",45,140)
                self:Remove()
            end
		end
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
    ent.damage = 9
    ent.MaxSpeed = 700
    ent.DamageType = DMG_CLUB
    ent.AttackHit = "Concrete.ImpactHard"
    ent.AttackHitFlesh = "Flesh.ImpactHard"
    ent.noStuck = true

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 300)
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:ViewPunch(Angle(0, 0, -8))
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and 12 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 25 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -3 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -15 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and -90 or 0)
    addAngLerp.p = addAngLerp.p + (self:GetBlocking() and 90 or 0)
    
    return true
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.001

SWEP.AttackRads = 35
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0