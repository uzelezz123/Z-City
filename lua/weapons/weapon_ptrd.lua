SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "PTRD-41"
SWEP.Author = "Degtyaryov Plant"
SWEP.Instructions = "Single-shot bolt action anti-tank rifle of 1941 pattern. Chambered in 14.5x114mm"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.WorldModelFake = "models/weapons/zcity/c_ptrd41.mdl"
SWEP.FakeScale = 1

SWEP.FakeAttachment = "muzzle"
SWEP.AttachmentPos = Vector(0,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeBodyGroups = "000000000"
SWEP.BarrelLength = 40
SWEP.SUPBarrelLenght = 47
SWEP.OpenBolt = true
SWEP.CantFireFromCollision = false // 2 спусковых крючка все дела

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30


SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_ptrd")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "vgui/wep_jack_hmcd_ptrd"

SWEP.LocalMuzzlePos = Vector(47, 0.5, 4)
SWEP.LocalMuzzleAng = Angle(.3,0,0)
SWEP.WeaponEyeAngles = Angle(-0.7,0.1,0)

SWEP.CustomShell = "762x54"
SWEP.CanSuicide = false

SWEP.ReloadSound = "weapons/tfa_ins2/k98/m40a1_boltlatch.wav"
SWEP.CockSound = "weapons/tfa_ins2/k98/m40a1_boltlatch.wav"
SWEP.DistSound = "mosin/mosin_dist.wav"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "RifleShellEject"
SWEP.AutomaticDraw = true
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "14.5x114mm B32"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Damage = 320
SWEP.Primary.Force = 320
SWEP.Primary.Sound = {"weapons/easternfront/ptrd41/ptrd41_fp.wav", 80, 90, 100}
SWEP.SupressedSound = {"mosin/mosin_suppressed_fp.wav", 80, 90, 100}
SWEP.availableAttachments = {}

SWEP.Primary.Wait = 0.25
SWEP.ReloadTime = 6.5
SWEP.NumBullet = 1
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 1
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.SprayRand = {Angle(0.02, -0.02, 0), Angle(-0.02, 0.02, 0)}
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
SWEP.PPSMuzzleEffect = "pcf_jack_mf_mshotgun" -- shared in sh_effects.lua

-- bipod
SWEP.RestPosition = Vector(15, 2, 5)
SWEP.BipodOffset = Vector(0, -6, -5)

SWEP.ReloadNoPitch = true

local math = math
local math_random = math.random
local vecfull = Vector(1,1,1)

local function HideMag(model, unhide)
	if !IsValid(model) then return end

	local vec = unhide and vecfull or vector_origin

	model:ManipulateBoneScale(100, vec)
end

function SWEP:ModelCreated(model)
	HideMag(model, false)
end

SWEP.AnimsEvents = {
	["deployed_reload"] = {
		[0] = function(self)
			self:EmitSound("weapons/easternfront/ptrd41/handling/bolt_back.wav", 55, math_random(95, 105))
			self:RejectShell(self.ShellEject)
		end,
		[0.2] = function(self)
			self:EmitSound("weapons/universal/uni_crawl_l_03.wav", 45, math_random(95, 105))
			HideMag(self:GetWM(), true)
		end,
		[0.4] = function(self)
			self:EmitSound("weapons/easternfront/ptrd41/handling/bullet_insert_0"..math_random(3)..".wav", 55, math_random(95, 105))
		end,
		[0.6] = function(self)
			self:EmitSound("weapons/easternfront/ptrd41/handling/bolt_close.wav", 55, math_random(95, 105))
		end,
		[0.7] = function(self)
			HideMag(self:GetWM(), false)
			self:EmitSound("weapons/universal/uni_crawl_l_04.wav", 45, math_random(95, 105))
		end,
	}
}

--// Custom reload pos
local idlePos, idleAng = Vector(-6, 11, 8), Angle(0, -45.5, 0)
local reloadPos, reloadAng = Vector(2, 8, 7), Angle(60, 0, 0)
local restVec = Vector(-12, 0, 8)
local bipodZoomPos, zoomPos = Vector(0, 0.5712, 4.9104), Vector(0, 2.7792, 5.8368)

SWEP.FakePos = idlePos
SWEP.FakeAng = idleAng
SWEP.ZoomPos = zoomPos
SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "deployed_reload",
	["reload_empty"] = "deployed_reload",
}

function SWEP:ThinkAdd()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local ft = FrameTime()

	if CLIENT and self:IsResting() then
		local wm = self:GetWM()
		local bone = wm:LookupBone("bipod")
		local posa, anga = self:GetBipodPosAng()
		wm:ManipulateBoneAngles(bone, Angle(anga[2] - owner:EyeAngles()[2], 0, -owner:EyeAngles()[3]))
	end

	if self:IsResting() and self.FakePos ~= restVec and not self.reload then
		self.ZoomPos = bipodZoomPos
		self.AnimList = {
			["idle"] = "deployed_idle",
			["reload"] = "deployed_reload",
			["reload_empty"] = "deployed_reload",
		}

		self.FakePos = LerpVector(ft * 2, self.FakePos, restVec)
		self.FakeAng = LerpAngle(ft * 4, self.FakeAng, angle_zero)
	elseif not self:IsResting() and self.AnimList["idle"] ~= "base_idle" and not self.reload then
		self.ZoomPos = zoomPos
		self.AnimList = {
			["idle"] = "base_idle",
			["reload"] = "deployed_reload",
			["reload_empty"] = "deployed_reload",
		}

		self:PlayAnim("idle", 0.1, false)
	end

	local israg = hg.GetCurrentCharacter(owner):IsRagdoll()

	if self.reload and self.FakePos ~= reloadPos and self.FakeAng ~= reloadAng then
		if not israg then
			self.FakePos = LerpVector(ft * 2, self.FakePos, reloadPos)
		end
		self.FakeAng = LerpAngle(ft * 4, self.FakeAng, israg and angle_zero or reloadAng)
	elseif (not self.reload and (self.FakePos ~= idlePos and self.FakeAng ~= idleAng or self.FakeAng == angle_zero) or not self.reload and israg) and not self:IsResting() then
		self.FakePos = LerpVector(ft * 2, self.FakePos, idlePos)
		self.FakeAng = LerpAngle(ft * 2, self.FakeAng, idleAng)
	end
end

--// Falling on shoot
function SWEP:PrimaryShootPost()
	if CLIENT then return end
	if self:IsResting() then return end

	local owner = self:GetOwner()
	local char = hg.GetCurrentCharacter(owner)
	if not char:IsRagdoll() then
		hg.AddForceRag(owner, 2, owner:EyeAngles():Forward() * -10000, 0.5)
		hg.AddForceRag(owner, 0, owner:EyeAngles():Forward() * -10000, 0.5)

		hg.LightStunPlayer(owner,1)
	end
	
	char:GetPhysicsObjectNum(0):SetVelocity(char:GetVelocity() + owner:EyeAngles():Forward() * -2000)
end

SWEP.stupidgun = false

SWEP.GunCamPos = Vector(6,-12,-5)
SWEP.GunCamAng = Angle(190,-5,-95)

local vector_full = Vector(1,1,1)
SWEP.FakeEjectBrassATT = "shell"
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