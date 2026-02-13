SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "FN P90"
SWEP.Author = "FN Herstal"
SWEP.Instructions = "Submachine gun chambered in 5.7x28 mm\n\nRate of fire 1000 rounds per minute"
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
SWEP.WorldModelFake = "models/weapons/tfa_ins2/c_mwr_p90.mdl"
SWEP.FakePos = Vector(-2.5, 3.65, 7.6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0,2.2,-28)
SWEP.AttachmentAng = Angle(0,0,90)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "00000000000"
SWEP.ZoomPos = Vector(0, 0.35, 7.6)

SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2,12,10)

SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.FakeEjectBrassATT = "2"
SWEP.FakeViewBobBone = "CAM_Homefield"

SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.31] = "weapons/tfa_ins2/mwr_p90/wpfoly_p90_reload_clipout_v1.wav",
	[0.4] = "weapons/universal/uni_crawl_l_02.wav",
	[0.65] = "weapons/tfa_ins2/mwr_p90/wpfoly_p90_reload_clipin_v1.wav",
	[0.79] = "weapons/tfa_ins2/mwr_p90/wpfoly_p90_reload_hit_v1.wav",
	[0.99] = "weapons/universal/uni_crawl_l_04.wav",
}

SWEP.FakeEmptyReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.31] = "weapons/tfa_ins2/mwr_p90/wpfoly_p90_reload_clipout_v1.wav",
	[0.4] = "weapons/universal/uni_crawl_l_02.wav",
	[0.65] = "weapons/tfa_ins2/mwr_p90/wpfoly_p90_reload_clipin_v1.wav",
	[0.75] = "weapons/tfa_ins2/mwr_p90/wpfoly_p90_reload_hit_v1.wav",
	[0.92] = "weapons/tfa_ins2/mwr_p90/wpfoly_p90_reload_chamber_v1.wav",
	[1.01] = "weapons/universal/uni_crawl_l_04.wav",
}

SWEP.MagModel = "models/weapons/tfa_ins2/c_mwr_p90.mdl"
SWEP.lmagpos = Vector(-3.2,-3,-12)
SWEP.lmagang = Angle(0,0,90)
SWEP.lmagpos2 = Vector(-16,3.4,3)
SWEP.lmagang2 = Angle(0,0,0)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 20

SWEP.FakeMagDropBone = 14

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}

if CLIENT then
	local vector_full = Vector(1,1,1)
	SWEP.FakeReloadEvents = {
		[0.15] = function( self, timeMul )
			self:GetWM():ManipulateBoneScale(14, vector_full)
			self:GetWM():ManipulateBoneScale(15, vector_full)
		end,
		[0.45] = function(self,timeMul)
			if IsValid(self) and IsValid(self:GetOwner()) and IsValid(self:GetWM()) and self:Clip1() < 1 then
				local ent = hg.CreateMag( self, Vector(0,10,5) )
				for i = 0, ent:GetBoneCount() - 1 do
					ent:ManipulateBoneScale(i, vector_origin)
				end

				ent:ManipulateBoneScale(14, vector_full)
				ent:ManipulateBoneScale(15, vector_full)
			end
			self:GetWM():ManipulateBoneScale(14, vector_origin)
			self:GetWM():ManipulateBoneScale(15, vector_origin)
		end,
		[0.55] = function(self,timeMul)

			self:GetWM():ManipulateBoneScale(14, vector_full)
			self:GetWM():ManipulateBoneScale(15, vector_full)

			self:UpdateMagazineBodygroup( math.min(self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) + self:Clip1(),50) )
		end,
		[0.85] = function(self,timeMul)
			self:GetWM():ManipulateBoneScale(14, vector_full)
			self:GetWM():ManipulateBoneScale(15, vector_full)
		end
	}
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		--self:GetWM():ManipulateBoneScale(14, vector_full)
		--self:GetWM():ManipulateBoneScale(15, vector_full)
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
		self:UpdateMagazineBodygroup()
	end
end
SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.7x28 mm"

SWEP.CustomShell = "57x28"

SWEP.ScrappersSlot = "Primary"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 32
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 25
SWEP.Primary.Sound = {"weapons/tfa_ins2/mwr_p90/p90_fire1.wav", 75, 120, 130}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m14/handling/m14_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.05
SWEP.ReloadTime = 4.2
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb2/weapons/p90/magout.wav",
	"none",
	"pwb2/weapons/p90/magin.wav",
	"pwb2/weapons/p90/bolt.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"

SWEP.LocalMuzzlePos = Vector(17,0.5,4)
SWEP.LocalMuzzleAng = Angle(-0.2,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.HoldType = "rpg"

SWEP.RHandPos = Vector(-12, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 10
SWEP.Spray = {}
for i = 1, 50 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.01, math.cos(i * 8) * 0.02, 0) * 1
end

SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/p90.png")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "pwb2/vgui/weapons/p90.png"

SWEP.Ergonomics = 1.1
SWEP.WorldPos = Vector(-7, 0, 0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0.25, -2.1, 28)
SWEP.attAng = Angle(0, 0.4, 0)
SWEP.lengthSub = 30
SWEP.handsAng = Angle(-10, 8, 0)
SWEP.DistSound = "mp5k/mp5k_dist.wav"

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"dovetail","picatinny"},
		["mount"] = {["picatinny"] = Vector(-5, 3, 0.09)},
	},
	mount = {
		["picatinny"] = {
			"empty",
			Vector(0, 0, 0),
			{},
			["mountType"] = "picatinny",
		},
	},
	barrel = {
		[1] = {"supressor1", Vector(0,0.6,0.1), {}},
		[2] = {"supressor8", Vector(0,0,0), {}},
		["mount"] = Vector(-1.6,0.1,-0.2),
	}
}

SWEP.weight = 2.5

SWEP.RHPos = Vector(6,-7.5,3.5)
SWEP.RHAng = Angle(0,-10,90)
SWEP.LHPos = Vector(5,0,-3.5)
SWEP.LHAng = Angle(-15,-10,-90)

SWEP.ShootAnimMul = 3

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(2, 8, -4)
SWEP.holsteredAng = Angle(210, 0, 180)

function SWEP:OnReloaded()
	self.BaseClass.OnReloaded(self)

	if CLIENT then
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdateMagazineBodygroup()
			end
		end)
	end
end

function SWEP:SetClip1(amount)
	self.BaseClass.SetClip1(self, amount)

	if CLIENT then
		self:UpdateMagazineBodygroup()
	end
end

function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	if CLIENT then
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdateMagazineBodygroup()
			end
		end)
	end
end

function SWEP:PrimaryShoot()
	self.BaseClass.PrimaryShoot(self)

	if CLIENT then
		self:UpdateMagazineBodygroup()
	end
end

function SWEP:UpdateMagazineBodygroup(overideClip)
	if CLIENT and IsValid(self:GetWM()) then
		local clipSize = self.Primary.ClipSize
		local currentAmmo = overideClip or self:Clip1()

		local bodygroup = math.SnapTo( currentAmmo / 5, 1 )

		self:GetWM():SetBodygroup(1, bodygroup)
	end
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0,0,0)
	local vec = self.vec
	if CLIENT and IsValid(wep) then
		self.shooanim = Lerp(FrameTime()*15,self.shooanim or 0,self.ReloadSlideOffset)
		vec[1] = 0*self.shooanim
		vec[2] = 1*self.shooanim
		vec[3] = 0*self.shooanim
		wep:ManipulateBonePosition(8,vec,false)

		--self:UpdateMagazineBodygroup()
	end
end

local lfang2 = Angle(0, -15, -1)
local lfang1 = Angle(-5, -5, -5)
local lfang0 = Angle(-12, -16, 20)
local vec_zero = Vector(0,0,0)
local ang_zero = Angle(0,0,0)
function SWEP:AnimHoldPost()

end

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-5,0,5),
	Vector(-6,2,7),
	Vector(-5,4,1),
	Vector(-5,4,-7),
	Vector(-5,4,-15),
	Vector(-6,2,7),
	Vector(-5,0,5),
	Vector(-5,0,5),
	Vector(-4,0,4),
	Vector(-4,0,3),
	Vector(-3,0,3),
	"fastreload",
	Vector(12,4,2),
	Vector(8,4,2),
	Vector(-8,4,2),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,-90,90),
	Angle(0,-90,90),
	Angle(0,-90,90),
	Angle(0,-90,90),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}

SWEP.ReloadSlideAnim = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	3,
	3,
	0,
	0,
	0,
	0
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(25,35,25),
	Angle(25,35,26),
	Angle(25,35,27),
	Angle(25,35,26),
	Angle(25,35,25),
	Angle(25,35,24),
	Angle(25,35,25),
	Angle(-5,-15,-15),
	Angle(-10,-5,-15),
	Angle(15,-15,-15),
	Angle(0,24,-23),
	Angle(0,25,-22),
	Angle(-15,24,-25),
	Angle(-15,25,-23),
	Angle(5,0,2),
	Angle(0,0,0),
}

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