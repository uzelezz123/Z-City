if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Crowbar"
SWEP.Instructions = "'I think you dropped this back in Black Mesa!'"
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/tfa_nmrih/w_me_crowbar.mdl"
SWEP.WorldModelExchange = "models/weapons/tfa_nmrih/w_me_crowbar.mdl"
SWEP.ViewModel = ""

SWEP.SuicidePos = Vector(9, 12, 18)
SWEP.SuicideAng = Angle(60, -30, 0)
SWEP.SuicideCutVec = Vector(1, 5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = false
SWEP.SuicideNoLH = false
SWEP.SuicideHoldType = "slam"

SWEP.NoHolster = true

SWEP.DamageType = DMG_SLASH
SWEP.HoldAng = Angle()

SWEP.AnimTime1 = 0.6
SWEP.ViewPunch1 = Angle(1, 2, 0)

SWEP.Attack2Time = 0.2
SWEP.AnimTime2 = 0.6
SWEP.WaitTime2 = 0.4
SWEP.ViewPunch2 = Angle(0, 0, -2)

SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 35
SWEP.DamageSecondary = 45

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 5

SWEP.MaxPenLen = 4

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 3.5

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 45

if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/hud/tfa_nmrih_crowbar")
    SWEP.IconOverride = "vgui/hud/tfa_nmrih_crowbar"
    SWEP.BounceWeaponIcon = false
end

SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft2.wav"

SWEP.AttackPos = Vector(0, 0, 0)

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_SLASH
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

SWEP.AttackTimeLength = 0.10
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 65
SWEP.AttackRads2 = 0

SWEP.SwingAng = -15
SWEP.SwingAng2 = 0

SWEP.NoHolster = false
SWEP.weaponInvCategory = 0
SWEP.weight = nil
SWEP.WorldModelReal = "models/weapons/c_crowbar2.mdl"
SWEP.HoldType = "melee"
SWEP.HoldPos = Vector(-7, 0, 0)
SWEP.AttackTime = 0.2
SWEP.WaitTime1 = 0.35
SWEP.basebone = 39
SWEP.weaponPos = Vector(1, 0, 0)
SWEP.weaponAng = Angle(0, 90, 90)
SWEP.StaminaPrimary = 5
SWEP.StaminaSecondary = 10
SWEP.setlh = false
SWEP.AnimList = {
	["idle"] = "Idle",
	["deploy"] = "Draw",
	["attack"] = "Misscenter1",
	["attack2"] = "Hitkill1",
}

function SWEP:PrimaryAttack()
    if hg.KeyDown(self:GetOwner(),IN_USE) then
        local tr = self.Owner:GetEyeTrace()
        if IsValid(tr.Entity) and string.find(string.lower(tr.Entity:GetClass()), "door") and self:GetOwner():GetPos():Distance(tr.Entity:GetPos()) <= 80 then
            local locked = false
            if tr.Entity.GetInternalVariable then
                locked = tr.Entity:GetInternalVariable("m_bLocked")
            end
            if not locked then
                return
            end
            if not self.BreakingDoor then
                self.BreakingDoor = true
                self.BreakStartTime = CurTime()
                self.BreakDuration = math.random(15, 20)
                self.DoorEntity = tr.Entity
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end
            return
        end
    end
    self.BaseClass.PrimaryAttack(self)
end

function SWEP:PrimaryAttackAdd(ent)
    if hgIsDoor(ent) and math.random(10) > 8 then
        hgBlastThatDoor(ent,self:GetOwner():GetAimVector() * 30 + self:GetOwner():GetVelocity())
    end
end

function SWEP:Think()
    if self.BreakingDoor then
        if not (hg.KeyDown(self:GetOwner(),IN_USE) and hg.KeyDown(self:GetOwner(),IN_ATTACK)) then
            self.BreakingDoor = false
        elseif not (IsValid(self.DoorEntity) and self:GetOwner():GetPos():Distance(self.DoorEntity:GetPos()) <= 80) then
            self.BreakingDoor = false
        else
            if not self.NextBreakSound then
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end
            if CurTime() >= self.NextBreakSound then
                if IsValid(self.DoorEntity) then
                    self.DoorEntity:EmitSound("physics/wood/wood_crate_break2.wav", 75, 100)
                end
                self.NextBreakSound = CurTime() + math.Rand(1, 2)
            end
            if CurTime() >= self.BreakStartTime + self.BreakDuration then
                if IsValid(self.DoorEntity) then
                    self.DoorEntity:Fire("Unlock", "", 0)
                    self.DoorEntity:Fire("Open", "", 0)
                end
                self.BreakingDoor = false
            end
        end
    end
    self.BaseClass.Think(self)
end

SWEP.MinSensivity = 0.6