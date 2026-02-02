if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Battering Ram"
SWEP.Instructions = "A powerful and heavy weapon that can crush doors. Use it to break down barricades and get through tight spaces.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Damage = 35
SWEP.DamageType = DMG_CLUB
SWEP.WorldModel = "models/weapons/custom/w_batram.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_sledge.mdl"
SWEP.WorldModelExchange = "models/weapons/custom/w_batram.mdl"
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""

SWEP.HoldType = "slam"
SWEP.weight = 1.5

SWEP.HoldPos = Vector(-13,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 48

SWEP.PenetrationPrimary = 7

SWEP.MaxPenLen = 9

SWEP.PenetrationSizePrimary = 4

SWEP.StaminaPrimary = 55

SWEP.AttackTime = 0.5
SWEP.AnimTime1 = 1.4
SWEP.WaitTime1 = 1
SWEP.AttackLen1 = 60
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-6)
SWEP.weaponAng = Angle(0,0,-90)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Shove",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_ram")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_ram"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
	addPosLerp.z = addPosLerp.z + (self:GetBlocking() and 5 or 0)
	addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -4 or 0)
	addPosLerp.y = addPosLerp.y + (self:GetBlocking() and 2 or 0)
	addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -30 or 0)
    return true
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttackAdd(ent,trace)
    if hgIsDoor(ent) and math.random(5) > 3 then
        hgBlastThatDoor(ent,self:GetOwner():GetAimVector() * 50 + self:GetOwner():GetVelocity())
    end

    local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone)

	if phys and not ent:IsRagdoll() then
        local pushvec = trace.Normal * 1000
        local pushpos = trace.HitPos
        
        phys:ApplyForceOffset(pushvec, pushpos)
    end

    if ent:IsConstrained() and math.random(5) > 3 then
        constraint.RemoveAll( ent )
        ent:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav")
    end
end

--function SWEP:DrawPostWorldModel()
--    local model = self:GetWM()
--    
--    if not IsValid(model) then return end--

--end

SWEP.AttackTimeLength = 0.01
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 0
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.85