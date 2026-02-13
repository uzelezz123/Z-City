SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MAC-11"
SWEP.Author = "Military Armament Corporation"
SWEP.Instructions = "Submachine gun chambered in 9x19 mm\n\nRate of fire 1600 rounds per minute"--BRUH TOO LAZY MF TOO LAZY BROOO
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"
SWEP.WorldModelFake = "models/weapons/tfa/zmirli/c_mac10.mdl"

SWEP.FakePos = Vector(-9, 3.15, 9.09)
SWEP.FakeAng = Angle(0, 0, 3.8)
SWEP.AttachmentPos = Vector(0.5,-0.05,-0.45)
SWEP.AttachmentAng = Angle(0,0,90)


SWEP.FakeAttachment = "1"


SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.4] = "weapons/zmirli/mac10/mac10_magout.wav",

	[0.65] = "weapons/universal/uni_crawl_l_02.wav",
	[0.82] = "weapons/zmirli/mac10/mac10_magin.wav",
	[0.94] = "weapons/universal/uni_crawl_l_04.wav",
	--[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",

}
SWEP.FakeEmptyReloadSounds = {
	[0.16] = "weapons/universal/uni_crawl_l_03.wav",
	[0.25] = "weapons/zmirli/mac10/mac10_magout.wav",

	[0.42] = "weapons/universal/uni_crawl_l_02.wav",
	[0.65] = "weapons/zmirli/mac10/mac10_magin.wav",
	[0.72] = "weapons/universal/uni_crawl_l_05.wav",
	[0.84] = "weapons/tfa_ins2/mp7/boltback.wav",
	[1.02] = "weapons/universal/uni_crawl_l_04.wav",
	--[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",

}
SWEP.MagModel = "models/weapons/zcity/w_glockextmag.mdl"
local vector_full = Vector(1,1,1)

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(1.5,1.2,0)
SWEP.lmagang2 = Angle(-90,180,-15)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 60
SWEP.FakeMagDropBone = 55

SWEP.FakeReloadEvents = {
	[0.3] = function( self, timeMul ) 
		if CLIENT and self:Clip1() > 0 then
			--self:GetWM():SetBodygroup(1,1)
			--self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.5 * timeMul)
			self:GetWM():ManipulateBoneScale(57, vector_full)
		end 
	end,
	[0.35] = function( self, timeMul ) 
		if CLIENT and self:Clip1() < 1 then
			hg.CreateMag( self, Vector(0,55,-55) )
			self:GetWM():ManipulateBoneScale(55, vector_origin)
			self:GetWM():ManipulateBoneScale(56, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.8 * timeMul,nil,nil,function() 
				self:GetWM():ManipulateBoneScale(55, vector_full)
				self:GetWM():ManipulateBoneScale(56, vector_full)
			end)
		end 
	end,
	[0.85] = function(self,timeMul)
		if CLIENT and self:Clip1() > 0 then
			local wm = self:GetWM()
			wm:ManipulateBoneScale(55, vector_origin)
			wm:ManipulateBoneScale(56, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.9 * timeMul,nil,nil,function() 
				if !IsValid(wm) then return end
				wm:ManipulateBoneScale(55, vector_full)
				wm:ManipulateBoneScale(56, vector_full)
				wm:ManipulateBoneScale(57, vector_origin)
			end)
		end
	end,
	--[1.00] = function( self ) 
	--	if CLIENT and self:Clip1() > 0 then
	--		self:GetWM():ManipulateBoneScale(57, vector_origin)
	--	end 
	--end,
}

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_tactic",
	["reload_empty"] = "reload_empty",
}

SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/mac11.png")
SWEP.IconOverride = "pwb2/vgui/weapons/mac11.png"

SWEP.CustomShell = "9x19"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)
SWEP.punchmul = 0.5
SWEP.punchspeed = 3
SWEP.weight = 1
SWEP.AnimShootHandMul = 0.01
SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(14.2,0.009,5.144)
SWEP.LocalMuzzleAng = Angle(-0.2,-0.05,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.podkid = 0.5
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		["mount"] = Vector(-3,0.87,-0.05),
	},
}
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 32
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 16
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 16
SWEP.Primary.Sound = {"homigrad/weapons/pistols/mac10-1.wav", 75, 120, 130}
SWEP.SupressedSound = {"mp5k/mp5k_suppressed_tp.wav", 65, 90, 100}
SWEP.Primary.Wait = 0.0375
SWEP.ReloadTime = 3.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb/weapons/uzi/clipout.wav",
	"none",
	"none",
	"pwb/weapons/uzi/clipin.wav",
	"none",
	"none",
	"weapons/tfa_ins2/mp7/boltback.wav",
	"none",
	"pwb2/weapons/vectorsmg/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mpistol" -- shared in sh_effects.lua

SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, 0.1224, 7.1536)
SWEP.RHandPos = Vector(3, -1, 2)
SWEP.LHandPos = false
SWEP.Spray = {}
for i = 1, 32 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.02, math.cos(i ^ 3) * 0.05, 0) * 2
end

function SWEP:ModelCreated(model)
	model:ManipulateBoneScale(57, vector_origin)
end

SWEP.Ergonomics = 1.3
SWEP.OpenBolt = true
SWEP.Penetration = 6
SWEP.WorldPos = Vector(-7, -1.2, 1.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(-4, 5, 3)
SWEP.holsteredAng = Angle(25, -65, -90)
SWEP.shouldntDrawHolstered = true

--local to head
SWEP.RHPos = Vector(12,-5,4)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

--self.SprayI
--45
function SWEP:PrimaryShootPost()
	local owner = self:GetOwner()
	if SERVER and self.SprayI > 25 and (owner.posture == 7 or owner.posture == 8) then
		hg.drop(owner,self,nil,-150)
	end
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0,0,0)
	local vec = self.vec
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self.ReloadSlideOffset)
		vec[1] = 0
		vec[2] = -0.9*self.shooanim
		vec[3] = 0
		wep:ManipulateBonePosition(45,vec,false)
	end
end

--RELOAD ANIMS PISTOL

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,-2,-2),
	Vector(-15,-2,-7),
	Vector(-15,-2,-15),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	"fastreload",
	Vector(5,0,5),
	Vector(-2,1,1),
	Vector(-2,1,1),
	Vector(-2,1,1),
	Vector(0,0,0),
	"reloadend",
	Vector(0,0,0)
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,-40),
	Angle(0,0,-90),
	Angle(0,0,-90),
	Angle(0,0,-60),
	Angle(0,0,-20),
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
	Angle(0,15,15),
	Angle(15,15,15),
	Angle(-5,15,15),
	Angle(0,0,-5),
	Angle(0,0,-15),
	Angle(-25,0,-15),
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