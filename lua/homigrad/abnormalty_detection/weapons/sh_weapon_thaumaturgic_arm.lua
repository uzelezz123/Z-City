local weapon_class = "weapon_thaumaturgic_arm"
local SWEP = {}
SWEP.Primary = {}
SWEP.Secondary = {}

if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Thaumaturgic Arm"
SWEP.Instructions = [[
Thaumaturgic arm allows for blood drainage right into user for later use in rituals.

Press R + Primary Attack to drain 100 blood from yourself.

Something prevents you from using this weapon rapidly. Your hands are getting tired.

Each primary strike to the human will drain 100 blood from them, if they are not in ragdoll and 300 otherwise, and add 200 blood scaled to the amount (it took / 100) to your abnormal blood

This weapon produces no sound, except then the wall is hit or secondary attack used.

This weapon produces no effects.

Strike power is removed for primary attack.

Only secondary attack does damage.

Bleeding from this weapon is severe.
]]
SWEP.ThaumaturgicArm = true
--Each secondary strike will collapse the victim.

SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
SWEP.WorldModelReal = "models/weapons/gleb/c_knife_t.mdl"
SWEP.WorldModelExchange = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.DontChangeDropped = true
SWEP.modelscale = 0.85
SWEP.modelscale2 = 1

SWEP.BleedMultiplier = 3

SWEP.weaponPos = Vector(-3.0,0.1,-0.2)
SWEP.weaponAng = Angle(0,180,90)
SWEP.attack_ang = Angle(-55,-3,0)
SWEP.HoldPos = Vector(2,2,0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.AttackPos = Vector(0,0,-10)
SWEP.AnimTime1 = 0.8
SWEP.AttackTime = 0.3
SWEP.Attack2Time = 0.3
SWEP.WaitTime1 = 0.6
SWEP.WaitTime2 = 0.5
SWEP.AnimTime2 = 1
SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 0
SWEP.DamageSecondary = 8
SWEP.basebone = 76

SWEP.AttackLen1 = 60
SWEP.AttackLen2 = 50


SWEP.AttackSwing = ""
SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = ""
SWEP.Attack2HitFlesh = "snd_jack_hmcd_slash.wav"
SWEP.DeploySnd = ""

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab_miss",
    ["attack2"] = "midslash1",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_traumatic_arm.png")
	SWEP.IconOverride = "vgui/icons/ico_traumatic_arm.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.BreakBoneMul = 0.1
SWEP.ImmobilizationMul = 2
SWEP.StaminaMul = 0.5
function SWEP:Initialize()
    self.attackanim = 0
    self.sprintanim = 0
    self.animtime = 0
    self.animspeed = 1
    self.reverseanim = false
    self.Initialzed = true
    self:PlayAnim("idle",10,true)

    self:SetAttackLength(self.AttackLen1)
    self:SetAttackWait(0)

    self:SetHold(self.HoldType)

    self:InitAdd()
end

function SWEP:HurtOwner()
	local ent = self:GetOwner()
	local max_blood_take = 100
	local blood_take = 100
	local old_blood = ent.organism.blood
	local new_blood = math.max(ent.organism.blood - blood_take, 0)
	local lost_blood = old_blood - new_blood
	ent.Abnormalties_Blood = (ent.Abnormalties_Blood or 0) + (lost_blood / max_blood_take) * 200
	ent.organism.blood = new_blood
	
	if(hg.Abnormalties)then
		hg.Abnormalties.ShowMessage(ent, tostring(math.Round(ent.Abnormalties_Blood)))
	end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
	addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -1 or 0)
	addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -4 or 0)
	addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -11 or 0)
	addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 120 or 0)
    return true
end

-- function SWEP:StartHurtingSelf()
	-- self.HurtSelf = self:GetOwner()
	
	-- self:SetOwner(game.GetWorld())
-- end

-- function SWEP:StopHurtingSelf()
	-- if(IsValid(self.HurtSelf))then
		-- self:SetOwner(self.HurtSelf)
	-- end

	-- self.HurtSelf = nil
-- end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_SLASH
	
	self:SetAttackLength(self.AttackLen2)
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
	
	if(self:GetOwner():KeyDown(IN_RELOAD) and self:GetOwner():KeyPressed(IN_ATTACK))then
		if(SERVER)then
			self:HurtOwner()
		end
		
		return false
	else
		self:SetAttackLength(self.AttackLen1)
	end
	
    return true
end

hook.Add("EntityTakeDamage", "Abnormalties_Weapon", function(ent, dmg)
	local attacker = dmg:GetAttacker()
	
	if(IsValid(attacker) and attacker:IsPlayer())then
		local wep = attacker:GetActiveWeapon()
		
		if(IsValid(wep) and wep:GetClass() == weapon_class and dmg:GetDamage() <= 3)then
			if((ent:IsPlayer() or ent:GetClass() == "prop_ragdoll") and ent.organism)then
				local max_blood_take = 100
				local blood_take = 300
				
				if(ent:IsPlayer())then
					blood_take = 100
				end
				
				local old_blood = ent.organism.blood
				local new_blood = math.max(ent.organism.blood - blood_take, 0)
				local lost_blood = old_blood - new_blood
				attacker.Abnormalties_Blood = (attacker.Abnormalties_Blood or 0) + (lost_blood / max_blood_take) * 200
				ent.organism.blood = new_blood
				
				if(hg.Abnormalties)then
					hg.Abnormalties.ShowMessage(attacker, tostring(math.Round(attacker.Abnormalties_Blood)))
				end
			end
		end
	end
end)

weapons.Register(SWEP, weapon_class)