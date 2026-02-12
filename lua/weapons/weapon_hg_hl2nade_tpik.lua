if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_grenade_tpik"
SWEP.PrintName = "Combine Frag Grenade"
SWEP.Instructions = 
[[The Grenade comes equipped with a red blinking light and a chirping timer that are played when the grenade is thrown, letting both the attacker and the victim know when an active grenade is in their vicinity. Most Combine Soldiers carry at least a few of these and use them to flush out and/or kill enemies.

Reload looking on surface will set tripwire

LMB - High ready
While high ready:
RMB to remove spoon.
Reload to insert pin back.

RMB - Low ready
While low ready:
LMB to remove spoon.
Reload to insert pin back.
]]--"тильда двуеточее три"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "camera"
SWEP.ViewModel = ""
SWEP.WorkWithFake = true

SWEP.WorldModel = "models/Items/grenadeAmmo.mdl"
SWEP.WorldModelReal = "models/weapons/c_grenade.mdl"
SWEP.WorldModelExchange = false

SWEP.ENT = "ent_hg_grenade_hl2grenade"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_grenade")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_grenade"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "draw", 1, false },
    ["attack"] = { "throw", 0.6, false, false, function(self)

		if CLIENT then return end
		--local tr = self:GetEyeTrace()
		--self:Tie(tr)
		
		self:Throw(1200, self.SpoonTime or CurTime(),nil,Vector(2,4,0),Angle(-40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end
			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.65 },
	["attack2"] = { "throw", 0.6, false, false, function(self)
		--local tr = self:GetEyeTrace()
		--self:Tie(tr)
		if CLIENT then return end
		self:Throw(600, self.SpoonTime or CurTime(),nil,Vector(0,4,-6),Angle(40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.IsLowThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end

			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.6 },
	["pullbackhigh"] = {"drawbackhigh", 0.4, false, false, function(self) 
		self:SetShowPin(false)
		--self:PlayAnim("attack")
		self.ReadyToThrow = true
	end,0.8},
	["pullbacklow"] = {"drawbacklow", 0.4, false, false, function(self) 
		--self:PlayAnim("attack2")
		self:SetShowPin(false)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end,0.8},
	["idle"] = {"draw", 1, false,false,function(self)
	end}
}

SWEP.AnimsEvents = {
	["draw"] = {
		[0.35] = function(self)
			self:EmitSound("weapons/m67/handling/m67_pinpull.wav",65)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
	},
	["drawbacklow"] = {
		[0.42] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",65)
		end,
	},
	["drawbackhigh"] = {
		[0.42] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",65)
		end,
	},
}


SWEP.HoldPos = Vector(-8,0,0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.NoTrap = true

SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 50

SWEP.CallbackTimeAdjust = 0.1

SWEP.traceLen = 5

SWEP.ItemsBones = {
	["Grenade"] = {39},
	["Spoon"] = {},
	["Pin"] = {40,41},
}

function SWEP:AddStep()
    if not IsValid(self:GetOwner()) then return end
    if self.SpoonTime then
        local ent = scripted_ents.Get(self.ENT)
        local time = (self.SpoonTime + self.timeToBoom) - CurTime()
        
        self.nextgrenadetick = self.nextgrenadetick or CurTime()
        if self.nextgrenadetick > CurTime() then return end
        
        hg.GetCurrentCharacter(self:GetOwner()):EmitSound("weapons/grenade/tick1.wav",65)

        self.nextgrenadetick = CurTime() + 0.5 * math.max(time / (ent.timeToBoom * 1.5),0.5)
    end
end

SWEP.spoon = "models/weapons/arc9/darsu_eft/skobas/m18_skoba.mdl"

SWEP.CoolDown = 0