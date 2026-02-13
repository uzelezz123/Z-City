if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_grenade_tpik"
SWEP.PrintName = "Molotov Cocktail"
SWEP.Instructions = 
[[A handmade molotov cocktail is an incendiary weapon consisting of a frangible container filled with flammable substances and equipped with a fuse.

LMB - High ready
While high ready:

RMB - Low ready
While low ready:
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

SWEP.WorldModel = "models/weapons/w_molotov.mdl"
SWEP.WorldModelReal = "models/weapons/zcity/c_molotov.mdl" -- переделать или найти нормальную
SWEP.WorldModelExchange = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_molotov")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_molotov.png"
	SWEP.BounceWeaponIcon = false
end


SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 4
SWEP.SlotPos = 4

SWEP.ENT = "ent_hg_molotov"
SWEP.NoSpoon = true

if CLIENT then
	function SWEP:OnRemove()
		if self.idleSnd then
			self:StopLoopingSound(self.idleSnd)
		end
		if IsValid(self.fire) then
			self.fire:StopEmissionAndDestroyImmediately()
		end
	end
end

SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "base_draw", 1, false },
    ["attack"] = { "throw", 0.8, false, false, function(self)
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
			self:PlayAnim("deploy")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.65 },
	["attack2"] = { "lowthrow", 0.8, false, false, function(self)
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

			self:PlayAnim("deploy")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.6 },
	["pullbackhigh"] = {"pullback_high", 1.5, false, false, function(self) 
		self:SetShowPin(false)
		--self:PlayAnim("attack")
		self.ReadyToThrow = true
	end,0.5},
	["pullbacklow"] = {"pullback_low", 1.5, false, false, function(self) 
		--self:PlayAnim("attack2")
		self:SetShowPin(false)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end,0.5},
	["idle"] = {"draw", 1, false,false,function(self)
	end}
}

SWEP.AnimsEvents = {
	["pullback_high"] = {
		[0.01] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_lighter_open.wav",65)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.11] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_lighter_strike.wav",65,100,CHAN_BODY)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.21] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_ignite.wav",65,100,CHAN_ITEM)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.24] = function(self)
			self.idleSnd = self:StartLoopingSound("weapons/molotov/handling/molotov_idle_burn_loop.wav")
			self.Burn = true
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.55] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_lighter_close.wav",65)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine", 0.5)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end
	},
	["pullback_low"] = {
		[0.01] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_lighter_open.wav",65)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.11] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_lighter_strike.wav",65,100,CHAN_BODY)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.21] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_ignite.wav",65,100,CHAN_ITEM)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.24] = function(self)
			self.idleSnd = self:StartLoopingSound("weapons/molotov/handling/molotov_idle_burn_loop.wav")
			self.Burn = true
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.55] = function(self)
			self:EmitSound("weapons/molotov/handling/molotov_lighter_close.wav",65)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine", 0.5)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end
	},
}

SWEP.HoldPos = Vector(2,0.2,-1.5)
SWEP.HoldAng = Angle(0,0,0)
SWEP.NoTrap = true

SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 50

SWEP.CallbackTimeAdjust = 0.1

SWEP.traceLen = 5
--[[
61	Fire_Lighter
62	Liq_base
63	Liq_top
64	Rag_God
65	Bone01
66	Bone02
67	Bone03
68	Bone04
69	Bone05
70	Fire_Rag
71	Spoon

]]
SWEP.ItemsBones = {
	["Grenade"] = {61,62,63,64,65,66,67,68,69,70,71,57},
	["Spoon"] = {0},
	["Pin"] = {58,59,60},
}

SWEP.spoon = false

SWEP.throwsound = "weapons/molotov/handling/molotov_throw_burning.wav"

SWEP.CoolDown = 0

function SWEP:DrawPostPostModel()
	--PrintBones(self:GetWM())
	if self.Burn and not IsValid(self.fire) then
		self.fire = CreateParticleSystem( self:GetWM(), "vFire_Flames_Tiny", PATTACH_POINT_FOLLOW,2 )
	elseif not self:GetShowGrenade() and IsValid(self.fire) then
		self.fire:StopEmissionAndDestroyImmediately()
		self.Burn = false
	end
	
end