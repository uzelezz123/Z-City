SWEP.Base = "weapon_hg_grenade_tpik"
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
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.WorldModel = "models/mmod/weapons/w_bugbait.mdl"
local av,aa,av2,aa2 = Vector(0,0,0),Angle(0,0,0),Vector(0,0,0),Angle(0,0,0)
SWEP.AnimList = {
	["deploy"] = { "draw", 0.6, false, false },
    ["attack"] = { "throw", 0.6, false, false, function(self)
		if CLIENT then return end
		self:Throw(900, self.SpoonTime or CurTime(),nil,Vector(2,4,0),Angle(-40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.IsLowThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6, function()
			if not IsValid(self) then return end
			self:PlayAnim("deploy")
			self:SetShowGrenade(true)
		end)
	end, 0.65 },
	["attack2"] = { "throw", 0.6, false, false, function(self)
		if CLIENT then return end
		self:Throw(600, self.SpoonTime or CurTime(),nil,Vector(-2,4,0),Angle(40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.IsLowThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6, function()
			if not IsValid(self) then return end
			self:PlayAnim("deploy")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.6 },
	["pullbackhigh"] = {"drawback", 0.2, false, false, function(self)
		self:SetShowPin(false)
		self.ReadyToThrow = true
	end,0.8},
	["pullbacklow"] = {"drawback", 0.2, false, false, function(self)
		self:SetShowPin(false)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end,0.8},
	["idle"] = {"idle01", 1, true,false},
	["special"] = {"squeeze", 1, false,false}
}

SWEP.NoTrap = true
SWEP.HoldPos = Vector(-10,-2,0)
SWEP.HoldAng = Angle(-3,0,5)
SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 100
SWEP.CallbackTimeAdjust = 0.1
SWEP.traceLen = 5
SWEP.ItemsBones = {
	["Grenade"] = {39},
	["Spoon"] = {},
	["Pin"] = {}
}
SWEP.spoon = ""
SWEP.CoolDown = 0
SWEP.SqueezeCD = 0






-- read if cute :3