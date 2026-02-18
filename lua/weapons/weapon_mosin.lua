do return end -- until you find a good model
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Mosin-Nagant M38"
SWEP.Author = "Izhevsk Machine-Building Plant"
SWEP.Instructions = "Bolt-action rifle chambered in 7.62x54 mm"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"
SWEP.WorldModelFake = "models/weapons/zcity/c_mosin.mdl"
SWEP.FakeScale = 1

SWEP.FakePos = Vector(-7, 2.7, 6)
SWEP.FakeAng = Angle(0.25, 0, 0)

SWEP.FakeAttachment = "shell"
SWEP.AttachmentPos = Vector(-0.1,-0.3,2)
SWEP.AttachmentAng = Angle(90,0,0)
SWEP.FakeBodyGroups = "000000000"
SWEP.BarrelLength = 40
SWEP.SUPBarrelLenght = 47
SWEP.OpenBolt = true
SWEP.CantFireFromCollision = false // 2 спусковых крючка все дела

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30


SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("vgui/hud/tfa_ins2_i_mosin")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "entities/arc9_eft_mosin_infantry.png"

SWEP.LocalMuzzlePos = Vector(27, 0.5, 4)
SWEP.LocalMuzzleAng = Angle(.3,0,0)
SWEP.WeaponEyeAngles = Angle(-0.7,0.1,0)

SWEP.CustomShell = "762x54"

SWEP.ReloadSound = "weapons/tfa_ins2/k98/m40a1_boltlatch.wav"
SWEP.CockSound = "weapons/tfa_ins2/k98/m40a1_boltlatch.wav"
SWEP.DistSound = "mosin/mosin_dist.wav"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "RifleShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x54 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0

sound.Add({
	name = "Mosin-Nagant_Shoot",
	sound = {
		"weapons/easternfront/mosin/m44_fp - copy (2).wav",
		"weapons/easternfront/mosin/mn91_30_fp - copy (3).wav",
		"weapons/easternfront/mosin/mn91_30_fp - copy.wav",
		"weapons/easternfront/mosin/mn91_30_fp.wav"
	},
})

SWEP.Primary.Sound = {"Mosin-Nagant_Shoot", 80, 90, 110}
SWEP.SupressedSound = {"mosin/mosin_suppressed_fp.wav", 80, 90, 100}
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor1", Vector(22.55,1,-0.5), {}},
		[2] = {"supressor6", Vector(22.55,1,-0.5), {}},
		[3] = {"supressor7", Vector(23.5,0.4,-0.8), {}},
		["mountAngle"]=Angle(0,0,37.5),
	},
	sight = {
		["mountType"] = "kar98mount",
		["mountAngle"] = Angle(0,0,35),
		["mount"] = Vector(5, 1.5, 0.125),
	},
}

SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 1
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 1
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, 0.6288, 4.8672)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 7
SWEP.WorldPos = Vector(0.2, -0.5, 0)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(9, 8, -8)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_Fire_end",
	["finish_empty"] = "Base_Reload_End",
	["finish"] = "Base_Reload_End",
	["insert"] = "Base_Reload_Insert",
	["start"] = "Base_Reload_Start",
	["start_empty"] = "base_reload_start_empty",
	["cycle"] = "base_Fire_end",
}

local math = math
local math_random = math.random
local vecfull = Vector(1,1,1)

local function HideMag(model, unhide)
	if !IsValid(model) then return end

	local vec = unhide and vecfull or vector_origin

	for i = 100, 106 do
		model:ManipulateBoneScale(i, vec)
	end
end

local function HideMag2(model, unhide)
	if !IsValid(model) then return end

	local vec = unhide and vecfull or vector_origin

	model:ManipulateBoneScale(101, vec)
end

local function SetModelAmmo(model, self)
	if !IsValid(model) then return end

	model:SetBodygroup(1, math.Clamp(self:Clip1(), 0, self.Primary.ClipSize))
end

function SWEP:ModelCreated(model)
	HideMag(model, false)
	SetModelAmmo(model, self)
end

SWEP.AnimsEvents = {
	["Base_Reload_Start"] = {
		[0.3] = function(self)
			SetModelAmmo(self:GetWM(), self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_back.wav", 45, math_random(95, 105))
			HideMag2(self:GetWM(), true)
		end,
		[0.4] = function(self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_forward.wav", 45, math_random(95, 105))
		end,
	},
	["base_reload_start_empty"] = {
		[0.3] = function(self)
			SetModelAmmo(self:GetWM(), self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_back.wav", 45, math_random(95, 105))
			HideMag2(self:GetWM(), true)
		end,
	},
	["Base_Reload_Insert"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bullet_insert_"..math_random(5)..".wav", 45, math_random(95, 105))
			HideMag2(self:GetWM(), true)
		end,
		[0.2] = function(self)
			if CLIENT then
				self:SetClip1(self:Clip1() + 1)
			end
			SetModelAmmo(self:GetWM(), self)
		end
	},
	["Base_Reload_End"] = {
		[0.2] = function(self)
			SetModelAmmo(self:GetWM(), self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_forward.wav", 45, math_random(95, 105))
			HideMag2(self:GetWM(), false)
		end,
		[0.3] = function(self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_forward.wav", 45, math_random(95, 105))
		end,
		[0.5] = function(self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_close.wav", 45, math_random(95, 105))
			HideMag2(self:GetWM(), false)
		end,
	},
	["base_Fire_end"] = {
		[0.2] = function(self)
			SetModelAmmo(self:GetWM(), self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_back.wav", 45, math_random(95, 105))
		end,
		[0.4] = function(self)
			self:RejectShell(self.ShellEject)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_forward.wav", 45, math_random(95, 105))
		end,
		[0.55] = function(self)
			SetModelAmmo(self:GetWM(), self)
			self:EmitSound("weapons/easternfront/mosin/handling/mosin_bolt_close.wav", 45, math_random(95, 105))
		end
	}
}

SWEP.stupidgun = false

function SWEP:InitializePost()
	self.AnimStart_Insert = 0
	self.AnimStart_Draw = 0
end

function SWEP:AnimationPost()
end

function SWEP:GetAnimPos_Insert(time)
	return 0
end

function SWEP:GetAnimPos_Draw(time)
	return 0
end

local function cock(self,time)
	if SERVER then
		self:Draw(true, true)
	end

	if self:Clip1() == 0 then
		self.drawBullet = nil
	end

	if CLIENT and LocalPlayer() == self:GetOwner() then return end

	net.Start("hgwep draw")
		net.WriteEntity(self)
		net.WriteBool(self.drawBullet)
		net.WriteFloat(CurTime())
	net.Broadcast()

	self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait
	

	local ply = self:GetOwner()

	self.reloadCoolDown = CurTime() + time
end


SWEP.GunCamPos = Vector(6,-12,-5)
SWEP.GunCamAng = Angle(190,-5,-95)

local vector_full = Vector(1,1,1)

local function reloadFunc(self)
	if CLIENT then return end

	self:SetNetVar("shootgunReload",CurTime() + 1.1)

	if self.MagIndex then
		self:GetWM():ManipulateBoneScale(self.MagIndex, vector_full)
	end

	self:PlayAnim(self.AnimList["insert"] or "reload_insert", 1, false, function() 
		self:InsertAmmo(1) 
		if self.MagIndex then
			self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin)
		end

		local key = hg.KeyDown(self:GetOwner(), IN_RELOAD)
		--print("reload",key)

		if key and self:CanReload() then
			reloadFunc(self)
			return
		end

		if !self.drawBullet then
			cock(self,1)
			self:PlayAnim(self.AnimList["finish_empty"] or "bolt_close_0", 1, false, function(self) self:SetNetVar("shootgunReload", 0) end, false, true) 
		else
			self:PlayAnim(self.AnimList["finish"] or "bolt_close_0", 1, false, function(self) self:SetNetVar("shootgunReload", 0) end, false, true) 
		end
	end, false, true)
end

SWEP.FakeEjectBrassATT = "shell"

function SWEP:Reload(time)
	--print(self:GetNetVar("shootgunReload",0))
	local ply = self:GetOwner()
	--if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end
	if self.AnimStart_Draw > CurTime() - 0.5 then return end
	if not self:CanUse() then return end
	if self.reloadCoolDown > CurTime() then return end
	if self.Primary.Next > CurTime() then return end
	if self:GetNetVar("shootgunReload",0) > CurTime() then return end

	if self.drawBullet == false and SERVER then
		cock(self,1.5)
		self:SetNetVar("shootgunReload",CurTime() + 1.3)
		self:PlayAnim(self.AnimList["cycle"] or "cycle_0", 1.5, false, nil, false, true)
		return
	end

	if not self:CanReload() then return end

	if SERVER then
		self:SetNetVar("shootgunReload",CurTime() + 1.1)
		self:PlayAnim((self.drawBullet == nil and self.AnimList["start_empty"] or self.AnimList["start"]) or "bolt_open_0",1,false,function()
			if self.drawBullet then
				self:SetClip1(self:Clip1() - 1)
				ply:GiveAmmo(1, self:GetPrimaryAmmoType(), true)
			end
			reloadFunc(self)
		end,
		false,true)
	end
end

function SWEP:CanPrimaryAttack()
	return not (self:GetNetVar("shootgunReload",0) > CurTime())
end

-- Inspect Assault

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(4,4,15),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(-6,-15,-15),
	Angle(1,15,-45),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(0,0,0),
	Angle(0,0,0)
}