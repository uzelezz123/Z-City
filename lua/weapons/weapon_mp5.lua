SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "HK MP5"
SWEP.Author = "Heckler & Koch"
SWEP.Instructions = "Submachine gun chambered in 9x19 mm\n\nRate of fire 800 rounds per minute"
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ur_mp5.mdl"

SWEP.FakePos = Vector(-12, 2.5, 6.8)
SWEP.FakeAng = Angle(0.5, -0.4, 5)
SWEP.AttachmentPos = Vector(1.5,0.4,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "00000"

SWEP.FakeEjectBrassATT = "2"

SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2,10,2)


SWEP.FakeViewBobBone = "CAM_Homefield"
SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.34] = "weapons/arccw_ur/mp5/magout.ogg",
	[0.38] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.51] = "weapons/universal/uni_crawl_l_02.wav",
	[0.62] = "weapons/arccw_ur/mp5/magin.ogg",
	[0.85] = "weapons/universal/uni_crawl_l_05.wav",

}

SWEP.FakeEmptyReloadSounds = {
	[0.22] = "weapons/arccw_ur/mp5/chback.ogg",
	[0.28] = "weapons/arccw_ur/mp5/chlock.ogg",
	[0.4] = "weapons/arccw_ur/mp5/magout.ogg",
	[0.62] = "weapons/arccw_ur/mp5/magin.ogg",

	[0.85] = "weapons/arccw_ur/mp5/chamber.ogg"
}

SWEP.MagModel = "models/bshields/drgordon/weapons/h&k/h&k_mp5a3_30_round_9x19mm_magazine.mdl" 

SWEP.DropMagBone = 45
SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(3.5,0,0)
SWEP.lmagang2 = Angle(0,0,-70)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70
SWEP.FakeMagDropBone = 45

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}
if CLIENT then
	local vector_full = Vector(1,1,1)
	SWEP.FakeReloadEvents = {
		[0.15] = function( self, timeMul )
			self:GetWM():ManipulateBoneScale(53, vector_origin)
			self:GetWM():ManipulateBoneScale(44, vector_full)
			self:GetWM():ManipulateBoneScale(45, vector_origin)
			self:GetWM():ManipulateBoneScale(46, vector_origin)
			self:GetWM():ManipulateBoneScale(47, vector_origin)
		end,
		[0.16] = function( self, timeMul )
			--self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.58 * timeMul)
		end,
		[0.25] = function( self, timeMul )
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.5 * timeMul,nil,nil,function() 
				self:GetWM():ManipulateBoneScale(53, vector_full)
				self:GetWM():ManipulateBoneScale(44, vector_full)
				self:GetWM():ManipulateBoneScale(45, vector_full)
				self:GetWM():ManipulateBoneScale(46, vector_full)
			end)
		end,
		[0.65] = function(self,timeMul)
			if self:Clip1() > 0 then
				self:GetWM():ManipulateBoneScale(44, vector_origin)
				self:GetWM():ManipulateBoneScale(45, vector_origin)
				self:GetWM():ManipulateBoneScale(46, vector_origin)
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul,nil,nil,function() 
					self:GetWM():ManipulateBoneScale(44, vector_origin)
					self:GetWM():ManipulateBoneScale(45, vector_origin)
					self:GetWM():ManipulateBoneScale(46, vector_origin)
				end)
				--self:GetWM():ManipulateBoneScale(44, vector_origin)
				--self:GetWM():ManipulateBoneScale(45, vector_origin)
				--self:GetWM():ManipulateBoneScale(46, vector_origin)
			end
		end,
		[0.50] = function(self,timeMul)
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(25,55,0),nil, true )
				self:GetWM():ManipulateBoneScale(44, vector_origin)
				self:GetWM():ManipulateBoneScale(45, vector_origin)
				self:GetWM():ManipulateBoneScale(46, vector_origin)
			end
		end,
		[0.85] = function(self,timeMul)
			self:GetWM():ManipulateBoneScale(44, vector_origin)
			self:GetWM():ManipulateBoneScale(45, vector_origin)
			self:GetWM():ManipulateBoneScale(46, vector_origin)
		end
	}
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():ManipulateBoneScale(44, vector_origin)
		self:GetWM():ManipulateBoneScale(45, vector_origin)
		self:GetWM():ManipulateBoneScale(46, vector_origin)
		self:GetWM():ManipulateBoneScale(47, vector_origin)
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end



SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false


SWEP.WepSelectIcon2 = Material("vgui/hud/tfa_ins2_mp5a4.png")
SWEP.IconOverride = "vgui/hud/tfa_ins2_mp5a4.png"

SWEP.CustomShell = "9x19"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)

SWEP.LocalMuzzlePos = Vector(14.706,-0.488,3.525)
SWEP.LocalMuzzleAng = Angle(0.4,.09,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weight = 2.5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 20
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 25
SWEP.animposmul = 2
SWEP.Primary.Sound = {"zcitysnd/sound/weapons/mp5k/mp5k_fp.wav", 75, 120, 130}
SWEP.SupressedSound = {"zcitysnd/sound/weapons/mp5k/mp5k_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.Wait = 0.07
SWEP.ReloadTime = 4.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/kryceks_swep/mp5/boltback.wav",
	"none",
	"none",
	"weapons/kryceks_swep/mp5/magout.wav",
	"none",
	"weapons/kryceks_swep/mp5/magin2.wav",
	"none",
	"weapons/kryceks_swep/mp5/boltslap.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "muzzleflash_mp5" -- shared in sh_effects.lua

SWEP.ShellEject = "EjectBrass_9mm"
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.4991, 5.782)

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(-2,0.45,0),
	}
}

SWEP.attPos = Vector(1,0,0)
SWEP.attAng = Angle(-0.02,0,0)

SWEP.Spray = {}
for i = 1, 30 do
	SWEP.Spray[i] = Angle(-0.0, 0, 0) * 1
end

SWEP.Ergonomics = 1
SWEP.Penetration = 7
SWEP.WorldPos = Vector(5, -1, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 30
SWEP.handsAng = Angle(7, 2, 0)
SWEP.DistSound = "zcitysnd/sound/weapons/mp5k/mp5k_dist.wav"

--local to head
SWEP.RHPos = Vector(3,-7,3.5)
SWEP.RHAng = Angle(0,-8,90)
--local to rh
SWEP.LHPos = Vector(11,1.6,-3)
SWEP.LHAng = Angle(-110,-180,5)

local finger1 = Angle(-15,-22, 20)
local finger2 = Angle(0, 10, 0)
local finger3 = Angle(0, -5, -15)
local finger4 = Angle(-10, -35, 0)
local finger5 = Angle(0, 40, 0)

SWEP.ShootAnimMul = 2

function SWEP:AnimHoldPost(model)
	if CLIENT and IsValid(model) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self:Clip1() > 0 and 0 or 0)
		model:ManipulateBonePosition(58,Vector(0 ,1.8*self.shooanim ,0),false)
		--PrintTable(model:GetChildBones())
	end
end


-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(1,-5,0),
	Vector(1,-5,-5),
	Vector(1,-5,0),
	Vector(-5,2,0),
	Vector(-1,2,-6),
	Vector(-1,2,-6),
	Vector(-1,10,-6),
	Vector(-1,12,-15),
	Vector(-1,5,-6),
	Vector(-1,2,-6),
	Vector(-1,2,-6),
	Vector(-1,2,-6),
	Vector(-1,2,-6),
	Vector(1,-5,-5),
	Vector(1,-5,-3),
	Vector(1,-8,-5),
	Vector(1,-2,-5),
	Vector(0,0,-2),
	"reloadend",
	Vector(0,0,0)
}


SWEP.ReloadSlideAnim = {
	0,
	0,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	0,
	0,
	0
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(-80,0,110),
	Angle(-80,0,110),
	Angle(-80,0,110),
	Angle(-80,0,110),
	Angle(-80,0,110),
	Angle(-80,0,110),
	Angle(-80,0,120),
	Angle(-80,0,120),
	Angle(-80,0,120),
	Angle(-80,0,120),	
	Angle(0,0,0),
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-5,0,25),
	Angle(-8,0,20),
	Angle(-5,0,0),
	Angle(5,5,25),
	Angle(-2,5,25),
	Angle(0,5,15),
	Angle(-5,5,5),
	Angle(5,-5,-2),
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