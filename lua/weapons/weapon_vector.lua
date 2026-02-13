SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "KRISS Vector"
SWEP.Author = "Transformational Defense Industries, Inc"
SWEP.Instructions = "Submachine gun chambered in .45 ACP\n\nRate of fire 1500 rounds per minute"
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"
SWEP.WorldModelFake = "models/weapons/tfa_ins2/c_krissv.mdl"

SWEP.FakePos = Vector(-8.5, 3.825, 7.05)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0,-0.15,0.3)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "00000"

SWEP.FakeEjectBrassATT = "2"

SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2,10,2)


SWEP.FakeViewBobBone = "CAM_Homefield"
SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.35] = "weapons/tfa_ins2/krissv/mp5k_magout.wav",
	[0.45] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.51] = "weapons/universal/uni_crawl_l_02.wav",
	[0.79] = "weapons/tfa_ins2/krissv/mp5k_magin.wav",
	[0.85] = "weapons/universal/uni_crawl_l_05.wav",

}
SWEP.FakeEmptyReloadSounds = {
	[0.22] = "weapons/arccw_ur/mp5/chback.ogg",
	[0.28] = "weapons/arccw_ur/mp5/chlock.ogg",
	[0.4] = "weapons/tfa_ins2/krissv/mp5k_magout.wav",
	[0.72] = "weapons/tfa_ins2/krissv/mp5k_magin.wav",

	[0.95] = "weapons/tfa_ins2/krissv/krisschargerelease.wav"
}

SWEP.MagModel = "models/weapons/zcity/glock/a_magazine_glock_extended.mdl" 
SWEP.lmagpos = Vector(-21,4.3,4)
SWEP.lmagang = Angle(-15,0,0)
SWEP.lmagpos2 = Vector(4,18.5,10)
SWEP.lmagang2 = Angle(0,0,5)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70
SWEP.FakeMagDropBone = 70

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reloadempty",
}
if CLIENT then
	local vector_full = Vector(1,1,1)
	SWEP.FakeReloadEvents = {
		[0.16] = function( self, timeMul )
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(71, vector_origin)
			end
			--self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.58 * timeMul)
		end,
		[0.33] = function (self)
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(0,0,-30) )
			end
		end,
		[0.35] = function( self, timeMul )
			if self:Clip1() < 1 then
			--	hg.CreateMag( self, Vector(0,0,-20) )
			--end
			self:GetWM():ManipulateBoneScale(71, vector_origin)
				self:GetWM():ManipulateBoneScale(70, vector_origin)
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1.2 * timeMul,nil,nil,function() 
					self:GetWM():ManipulateBoneScale(70, vector_full)
					self:GetWM():ManipulateBoneScale(71, vector_full)
					--self:GetWM():ManipulateBoneScale(44, vector_full)
					--self:GetWM():ManipulateBoneScale(45, vector_full)
					--self:GetWM():ManipulateBoneScale(46, vector_full)
				end)
			end
		end,
		[0.41] = function(self,timeMul)
			if self:Clip1() > 0 then
				self:GetWM():ManipulateBoneScale(71, vector_origin)
				self:GetWM():ManipulateBoneScale(70, vector_origin)
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul,nil,nil,function() 
					self:GetWM():ManipulateBoneScale(70, vector_full)
					self:GetWM():ManipulateBoneScale(71, vector_full)
					--self:GetWM():ManipulateBoneScale(44, vector_full)
					--self:GetWM():ManipulateBoneScale(45, vector_full)
					--self:GetWM():ManipulateBoneScale(46, vector_full)
				end)
			end
		end
	}
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end
--
SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/vectorsmg.png")
SWEP.IconOverride = "pwb2/vgui/weapons/vectorsmg.png"

SWEP.LocalMuzzlePos = Vector(17.469,0.014,1.617)
SWEP.LocalMuzzleAng = Angle(0,-0.026,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weight = 2.5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.CustomShell = "9x19"
--SWEP.EjectPos = Vector(-4,0,-9)
--SWEP.EjectAng = Angle(0,0,0)
SWEP.WorldPos = Vector(1, -0.8, 0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.Primary.ClipSize = 33
SWEP.Primary.DefaultClip = 33
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ".45 ACP"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 23
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 20
SWEP.animposmul = 2
SWEP.Primary.Sound = {"homigrad/weapons/pistols/p228-1.wav", 75, 120, 130}
SWEP.Primary.Wait = 0.04
SWEP.availableAttachments = {
	sight = {
		["mountType"] = "picatinny",
		["mount"] = Vector(-11, 2.8, -0.28),
		["empty"] = {
			"empty",
			{
				[8] = "pwb2/models/weapons/w_vectorsmg/sight"
			},
		},
		["removehuy"] = {
			[8] = "null"
		},
	},
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(-3.9 + 2,0 +0.6,1.3-1.6),
	}
}

SWEP.ReloadTime = 5.8
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb2/weapons/vectorsmg/magout.wav",
	"none",
	"none",
	"pwb2/weapons/vectorsmg/magin.wav",
	"none",
	"weapons/tfa_ins2/mp7/boltback.wav",
	"pwb2/weapons/vectorsmg/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 0.2448, 5.6292)
SWEP.RHandPos = Vector(-2, -2, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Spray = {}
SWEP.randmul = 0.25
//SWEP.norand = true
--SWEP.addSprayMul = 0.5
for i = 1, 33 do
	SWEP.Spray[i] = Angle(0, math.cos(i * i) * 0.07, 0) * 1
end

SWEP.Ergonomics = 1.1
SWEP.ShootAnimMul = 2

local ang1 = Angle(25, 0, 0)
local ang2 = Angle(0, 60, 0)

function SWEP:AnimHoldPost(model)
	--self:BoneSet("l_finger0", vector_origin, ang1)
	--self:BoneSet("l_finger02", vector_origin, ang2)
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self:Clip1() > 0 and 0 or 0)
		wep:ManipulateBonePosition(72,Vector(0 ,1.8*self.shooanim ,0 ),false)
		--wep:ManipulateBonePosition(1,Vector(-0.5*self.ReloadSlideOffset ,0 ,0.1*self.ReloadSlideOffset),false)
	end
end

SWEP.Penetration = 7
SWEP.lengthSub = 31
SWEP.handsAng = Angle(0, 1, 0)
SWEP.DistSound = "mp5k/mp5k_dist.wav"

--local to head
SWEP.RHPos = Vector(3,-6,4)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(13,-2,-3.5)
SWEP.LHAng = Angle(-40,0,-90)

--RELOAD ANIMS SMG????

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,-5,-4),
	Vector(-15,5,-7),
	Vector(-15,5,-15),
	Vector(0,-5,-4),
	Vector(0,-5,-4),
	Vector(0,0,0),
	"fastreload",
	Vector(2,2,0),
	Vector(2,2,0),
	Vector(2,2,0),
	Vector(-4,2,0),
	Vector(0,0,0),
	"reloadend",
	Vector(0,0,0)
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
	5,
	5,
	5,
	0,
	0,
	0,
	0,
	0,
	0
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(-35,0,0),
	Angle(-55,0,0),
	Angle(-75,0,0),
	Angle(-75,0,0),
	Angle(-75,0,0),
	Angle(-25,0,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(0,25,25),
	Angle(5,25,25),
	Angle(-5,25,25),
	Angle(0,0,-15),
	Angle(0,0,-25),
	Angle(-25,0,-25),
	Angle(-15,0,-15),
	Angle(0,0,0)
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