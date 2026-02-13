SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "PL-15"
SWEP.Author = "Kalashnikov Concern"
SWEP.Instructions = "The PL-15 is a semi-automatic pistol produced by Russian company Kalashnikov Concern. It was designed for use by law enforcement in Russia with a focus on ergonomics. Chambered in 9x19 mm."
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.WorldModelFake = "models/weapons/arc9/darsu_eft/c_pl15.mdl"
SWEP.FakeScale = 1.07
SWEP.FakePos = Vector(-17.5, 4.5, 6.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "111110101"
SWEP.FakeReloadSounds = {
	[0.23] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",
	[0.75] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.91] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav"
}

SWEP.stupidgun = true

SWEP.FakeEmptyReloadSounds = {
	[0.2] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",
	[0.67] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.74] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[0.97] = "zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav"
}
SWEP.MagModel = "models/weapons/arc9/darsu_eft/mods/mag_pl15.mdl"

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(0,0,0)
SWEP.lmagang2 = Angle(0,0,0)

SWEP.FakeMagDropBone = 50
local vector_full = Vector(1,1,1)

SWEP.FakeReloadEvents = {
	[0.15] = function( self, timeMul ) 
		if CLIENT then
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 2.5 * timeMul)
			self:GetWM():ManipulateBoneScale(50, vector_full)
			self:GetWM():ManipulateBoneScale(93, vector_full)
			self:GetWM():ManipulateBoneScale(94, vector_full)
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(93, vector_origin)
				self:GetWM():ManipulateBoneScale(94, vector_origin)
			end
		end
	end,
	[0.3] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			hg.CreateMag( self, Vector(0,0,-35) )
			self:GetWM():ManipulateBoneScale(50, vector_origin)
			self:GetWM():ManipulateBoneScale(93, vector_origin)
			self:GetWM():ManipulateBoneScale(94, vector_origin)
		end
	end,
	[0.55] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetWM():ManipulateBoneScale(50, vector_full)
			self:GetWM():ManipulateBoneScale(93, vector_full)
			self:GetWM():ManipulateBoneScale(94, vector_full)
		end
	end,
}

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}

SWEP.FakeVPShouldUseHand = false

SWEP.FakeViewBobBone = "Camera_animated"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_Spine4"
SWEP.ViewPunchDiv = 1

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_pl15.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/arc9_eft_pl15.png"

SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(4.3,2,-22)
SWEP.EjectAng = Angle(-45,0,90)
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.weight = 1

SWEP.ScrappersSlot = "Secondary"

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 24
SWEP.Primary.Sound = {"weapons/darsu_eft/pl15/pl_fire_indoor_distant.wav", 75, 90, 100}
SWEP.SupressedSound = {"zcitysnd/sound/weapons/m9/m9_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 23
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 3.6
SWEP.ReloadSoundes = {
	"none",
	"weapons/tfa_ins2/usp_tactical/magout.wav",
	"weapons/tfa_ins2/browninghp/magin.wav",
	"pwb/weapons/fnp45/sliderelease.wav",
	"none",
	"none"
}
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, -0.1, 4.1)
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.3
SWEP.Penetration = 7
SWEP.WorldPos = Vector(-0.1, -0.7, -0.5)
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LocalMuzzlePos = Vector(11,0.25,3.6)
SWEP.LocalMuzzleAng = Angle(0.2,0.0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.handsAng = Angle(-1, 10, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.125, -0.1, 0)
SWEP.lengthSub = 5
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, -1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor6", Vector(0,0,0), {}},
		[2] = {"supressor4", Vector(0,0.1,0), {}},
		["mount"] = Vector(-0.251,0.2,0.03),
	},
}

SWEP.RHandPos = Vector(3, -1, 0)
SWEP.LHandPos = false

--local to head
SWEP.RHPos = Vector(10,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)
SWEP.ShootAnimMul = 4

function SWEP:DrawPost()
	local wep = self:GetWM()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,(self:Clip1() > 0 or self.reload) and 0 or 1)
		wep:ManipulateBonePosition(95, Vector(0, 1.5 * self.shooanim, 0), false)
		wep:ManipulateBoneScale(101, self.shooanim > 0.1 and vector_origin or vector_full)
		if self:Clip1() < 1 and self.shooanim > 0.1 then
			self:GetWM():ManipulateBoneScale(93, vector_origin)
			self:GetWM():ManipulateBoneScale(94, vector_origin)
		end
	end
end

--RELOAD ANIMS PISTOL

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(-3,-1,-5),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-2,-1,-3),
	"fastreload",
	Vector(0,0,0),
	"reloadend",
	"reloadend",
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(30,-10,0),
	Angle(60,-20,0),
	Angle(70,-40,0),
	Angle(90,-30,0),
	Angle(40,-20,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
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
	Vector(-2,0,0),
	Vector(-1,0,0),
	Vector(0,0,0)
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
	Angle(15,2,20),
	Angle(15,2,20),
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(5,15,15),
	Angle(-5,21,14),
	Angle(-5,21,14),
	Angle(5,20,13),
	Angle(5,22,13),
	Angle(1,22,13),
	Angle(1,21,13),
	Angle(2,22,12),
	Angle(-5,21,16),
	Angle(-5,22,14),
	Angle(-4,23,13),
	Angle(7,22,8),
	Angle(7,12,3),
	Angle(2,6,1),
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