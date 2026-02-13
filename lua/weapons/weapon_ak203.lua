SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AK-203"
SWEP.Author = "Izhevsk Machine-Building Plant"
SWEP.Instructions = "An extraordinarily potent instrument of power, this steel 7.62x39mm selective fire, gas-operated rifle with a rotating bolt, capable of firing in either semi-automatic or fully automatic mode, is the epitome of Soviet military might in the mid-20th century. With a cyclic rate of fire of around 600 rounds per minute and a 10-, 20-, or 30-round detachable box magazine, this AKM, designed by the renowned Mikhail Kalashnikov, stands as a symbol of the USSR’s technological progress. Its robust design and reliable performance in harsh conditions underline its reputation as a weapon that has left an indelible mark on global warfare"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ur_ak.mdl"

SWEP.FakePos = Vector(-12, 2.52, 5.5)
SWEP.FakeAng = Angle(-1, 0.25, 5.5)
SWEP.AttachmentPos = Vector(3,3,-26.8)
SWEP.AttachmentAng = Angle(0,-1.5,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "07C000401210000"

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "CAM_Homefield"
SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.34] = "weapons/ak74/ak74_magout.wav",
	[0.38] = "weapons/ak74/ak74_magout_rattle.wav",

	[0.62] = "weapons/ak74/ak74_magin.wav",
	[0.81] = "weapons/universal/uni_crawl_l_03.wav",
	[0.99] = "weapons/universal/uni_crawl_l_04.wav",

}

SWEP.FakeEmptyReloadSounds = {

	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.34] = "weapons/ak74/ak74_magout.wav",
	[0.4] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.62] = "weapons/ak74/ak74_magin.wav",

	[0.83] = "weapons/ak74/ak74_boltback.wav",
	[0.86] = "weapons/ak74/ak74_boltrelease.wav",
	[1.01] = "weapons/universal/uni_crawl_l_04.wav",
}

SWEP.MagModel = "models/weapons/arc9/darsu_eft/mods/mag_ak_magpul_pmag_30_ak_akm_gen_m3_762x39_30.mdl"
SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(0,0,1)
SWEP.lmagang2 = Angle(90,0,-90)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70
SWEP.FakeMagDropBone = 57

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}

local vector_full = Vector(1,1,1)

function SWEP:RevertMag()
	local wm = self:GetWM()

	if IsValid(wm) and wm:GetManipulateBoneScale(55):IsEqualTol(vector_origin, 0.1) then
		wm:ManipulateBoneScale(55, vector_full)
		wm:ManipulateBoneScale(56, vector_full)
		wm:ManipulateBoneScale(57, vector_origin)
		wm:ManipulateBoneScale(58, vector_origin)
	end
end

if CLIENT then
	SWEP.FakeReloadEvents = {
		[0.15] = function( self, timeMul )
			local wm = self:GetWM()
			wm:ManipulateBoneScale(55, vector_origin)
			wm:ManipulateBoneScale(56, vector_origin)
			wm:ManipulateBoneScale(57, vector_full)
			wm:ManipulateBoneScale(58, vector_full)
		end,
		[0.16] = function( self, timeMul )
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.58 * timeMul)
		end,
		[0.27] = function( self, timeMul )
			local wm = self:GetWM()
			wm:ManipulateBoneScale(55, vector_full)
			wm:ManipulateBoneScale(56, vector_full)
			wm:ManipulateBoneScale(58, vector_full)
			wm:ManipulateBoneScale(57, vector_full)
		end,
		
		[0.40] = function(self,timeMul)
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(50,10,10),nil,true )
				self:GetWM():ManipulateBoneScale(57, vector_origin)
				self:GetWM():ManipulateBoneScale(58, vector_origin)
				--self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end,
		[0.85] = function(self,timeMul)
			self:GetWM():ManipulateBoneScale(57, vector_origin)
			self:GetWM():ManipulateBoneScale(58, vector_origin)
		end
	}
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() then
		self:GetWM():ManipulateBoneScale(57, vector_origin)
		self:GetWM():ManipulateBoneScale(58, vector_origin)
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end



SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 50
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 50
SWEP.ShockMultiplier = 2
SWEP.Primary.Sound = {"ak74/ak74_fp.wav", 85, 90, 100}
SWEP.SupressedSound = {"ak74/ak74_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/ak47/handling/ak47_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}



SWEP.WepSelectIcon2 = Material("vgui/icons/ico_ak203.png")
SWEP.IconOverride = "vgui/icons/ico_ak203.png"
SWEP.ScrappersSlot = "Primary"
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor1", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(-2,0.2,0),
		["mountAngle"] = {["picatinny"] = Angle(0, 1.5, 0)},
	},
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-23, 1.15, -0.18)},
		["mountAngle"] = {["picatinny"] = Angle(0, 0, 0)},
	},
	grip = {
		["mount"] = { ["picatinny"] = Vector(4,-0.2,0) },
		["mountType"] = {"picatinny"},
		["mountAngle"] = {["picatinny"] = Angle(0, 1.5, 0)}
	},
	underbarrel = {
		["mount"] = {["picatinny_small"] = Vector(2, -0.5, 0),["picatinny"] = Vector(3,0.2,-0.05)},
		["mountAngle"] = {["picatinny_small"] = Angle(0.9, 0, 0),["picatinny"] = Angle(0, 0, 0)},
		["mountType"] = {"picatinny_small","picatinny"},
		["removehuy"] = {
			["picatinny"] = {
			},
			["picatinny_small"] = {
			}
		}
	},
}

SWEP.Primary.Wait = 0.095
SWEP.ReloadTime = 5.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"none",
	"weapons/tfa_ins2/ak103/ak103_magout.wav",
	"none",
	"weapons/tfa_ins2/ak103/ak103_magin.wav",
	"none",
	"weapons/tfa_ins2/ak103/ak103_boltback.wav",
	"weapons/tfa_ins2/ak103/ak103_boltrelease.wav",
	"none",
	"none",
	"none"
}

SWEP.LocalMuzzlePos = Vector(26.986,-0.2,2.741)
SWEP.LocalMuzzleAng = Angle(-0.4,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1" -- shared in sh_effects.lua

SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.0054, 4.8688)

SWEP.RHandPos = Vector(-12, -1, 4)
SWEP.LHandPos = Vector(7, -3, -2)
SWEP.Spray = {}
for i = 1, 30 do
	SWEP.Spray[i] = Angle(-0.02 - math.cos(i) * 0.03, math.cos(i * i) * 0.02, 0) * 2
end

SWEP.Ergonomics = 1
SWEP.HaveModel = "models/pwb/weapons/w_akm.mdl"
--SWEP.ShellEject = "EjectBrass_338Mag"
SWEP.CustomShell = "762x39"

SWEP.Penetration = 15
SWEP.WorldPos = Vector(5, -1, -1.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
--https://youtu.be/I7TUHPn_W8c?list=RDEMAfyWQ8p5xUzfAWa3B6zoJg
SWEP.attPos = Vector(0.2, -2.6, 27)
SWEP.attAng = Angle(-0, 0.3, 0)
SWEP.lengthSub = 20
SWEP.handsAng = Angle(3, -1, 0)
SWEP.AimHands = Vector(-4, 0.5, -4)
SWEP.DistSound = "ak74/ak74_dist.wav"

SWEP.weight = 4

--local to head
SWEP.RHPos = Vector(3,-6.5,3.5)
SWEP.RHAng = Angle(0,-8,90)
--local to rh
SWEP.LHPos = Vector(15,1.5,-3.5)
SWEP.LHAng = Angle(-110,-180,0)

SWEP.ShootAnimMul = 7

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
	end
end
local lfang4 = Angle(0,70,0)
local lfang3 = Angle(0,-25,0)
local lfang2 = Angle(0,46,0)
local lfang1 = Angle(0,-30,0)
local lfang0 = Angle(0,-7,0)
local vec_zero = Vector(0,0,0)
local l_finger02 = Angle(-10,0,0)
function SWEP:AnimHoldPost()

end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-1.5,1.5,-8),
	Vector(-1.5,1.5,-8),
	Vector(-1.5,1.5,-8),
	Vector(-1,7,-3),
	Vector(-7,15,-15),
	Vector(-7,15,-15),
	Vector(-1,7,-3),
	Vector(-1.5,1.5,-8),
	Vector(-1.5,1.5,-8),
	Vector(-1.5,1.5,-8),
	"fastreload",
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
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
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,2),
	Vector(8,1,2),
	Vector(8,2.5,-2),
	Vector(7,2.5,-2),
	Vector(6,2.5,-2),
	Vector(3,2.5,-2),
	Vector(3,2.5,-1),
	Vector(0,4,-1),
	"reloadend",
	Vector(0,5,0),
	Vector(-2,2,1),
	Vector(0,0,0),
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-80,0,110),
	Angle(-20,0,110),
	Angle(-30,0,110),
	Angle(-20,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-20,0,45),
	Angle(-2,0,-3),
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
	Angle(20,-10,-20),
	Angle(20,0,-20),
	Angle(20,0,-20),
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-15,15,17),
	Angle(-14,14,22),
	Angle(-10,15,24),
	Angle(12,14,23),
	Angle(11,15,20),
	Angle(12,14,19),
	Angle(11,14,20),
	Angle(7,9,21),
	Angle(0,14,-21),
	Angle(0,15,-22),
	Angle(0,18,-23),
	Angle(0,25,-22),
	Angle(-12,24,-25),
	Angle(-15,25,-23),
	-Angle(5,2,2),
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
	5,
	4.5,
	0,
	0,
	0,
	0
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