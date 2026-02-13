SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Šcorpion vz. 61"
SWEP.Author = "Česká zbrojovka"
SWEP.Instructions = "Pistol chambered in 7.65x17 mm\n\nRate of fire 900 rounds per minute"
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"
SWEP.WorldModelFake = "models/weapons/tfa_cod/mwr/c_vz61.mdl"

SWEP.FakePos = Vector(-19.5, 2.969, 9.2)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0,0,0)
SWEP.AttachmentAng = Angle(0,0,90)


SWEP.FakeAttachment = "silencer"


SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.3] = "weapons/tfa_cod/mwr/skorpion/wpfoly_skorpion_reload_clipout_v1.wav",

	[0.65] = "weapons/universal/uni_crawl_l_02.wav",
	[0.82] = "weapons/tfa_cod/mwr/skorpion/wpfoly_skorpion_reload_clipin_v1.wav",
	[0.94] = "weapons/universal/uni_crawl_l_04.wav",
	--[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",

}
SWEP.FakeEmptyReloadSounds = {
	[0.16] = "weapons/universal/uni_crawl_l_03.wav",
	[0.21] = "weapons/tfa_cod/mwr/skorpion/wpfoly_skorpion_reload_clipout_v1.wav",

	[0.42] = "weapons/universal/uni_crawl_l_02.wav",
	[0.76] = "weapons/tfa_cod/mwr/skorpion/wpfoly_skorpion_reload_clipin_v1.wav",
	[0.79] = "weapons/universal/uni_crawl_l_05.wav",
	[0.95] = "weapons/tfa_cod/mwr/skorpion/wpfoly_skorpion_reload_chamber_v1.wav",
	[1.02] = "weapons/universal/uni_crawl_l_04.wav",
	--[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",

}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl"
local vector_full = Vector(1,1,1)

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(1.5,0,0)
SWEP.lmagang2 = Angle(0,90,-30)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 60
SWEP.FakeMagDropBone = 13

SWEP.FakeReloadEvents = {
	
	[0.3] = function( self, timeMul ) 
		if CLIENT and self:Clip1() < 1 then
			hg.CreateMag( self, Vector(0,55,-55) )
			self:GetWM():ManipulateBoneScale(13, vector_origin)
			self:GetWM():ManipulateBoneScale(13, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.2 * timeMul,nil,nil,function() 
				self:GetWM():ManipulateBoneScale(13, vector_full)
				self:GetWM():ManipulateBoneScale(13, vector_full)
			end)
		end 
		if CLIENT and self:Clip1() > 0 then
			self:GetWM():ManipulateBoneScale(13, vector_origin)
			self:GetWM():ManipulateBoneScale(13, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1 * timeMul,nil,nil,function() 
				self:GetWM():ManipulateBoneScale(13, vector_full)
				self:GetWM():ManipulateBoneScale(13, vector_full)
			end)
		end 
	end,
	[0.85] = function(self,timeMul)
	end,
	--[1.00] = function( self ) 
	--	if CLIENT and self:Clip1() > 0 then
	--		self:GetWM():ManipulateBoneScale(57, vector_origin)
	--	end 
	--end,
}

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}


SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.WepSelectIcon2 = Material("pwb/sprites/vz61.png")
SWEP.IconOverride = "entities/tfa_mwr_vz61.png"
SWEP.weight = 1
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.65x17 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 17
SWEP.Primary.Sound = {"hndg_beretta92fs/beretta92_fire1.wav", 75, 90, 100}
SWEP.Primary.Force = 25
SWEP.animposmul = 2
SWEP.Primary.Wait = 0.066
SWEP.ReloadTime = 4.7
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
	"pwb2/weapons/vectorsmg/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 0.0571, 8.4824)
SWEP.RHandPos = Vector(-13.5, -1, 3)
SWEP.LHandPos = false
SWEP.Spray = {}
for i = 1, 20 do
	SWEP.Spray[i] = Angle(-0.02 - math.cos(i) * 0.01, math.cos(i * i) * 0.01, 0) * 1
end

SWEP.LocalMuzzlePos = Vector(-0.192,0.003,7.878)
SWEP.LocalMuzzleAng = Angle(0,-0.021,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.CustomShell = "45acp"
SWEP.EjectPos = Vector(3,13,-1)
SWEP.EjectAng = Angle(-60,-90,0)
SWEP.AnimShootHandMul = 0.01
SWEP.Ergonomics = 1.2
SWEP.Penetration = 1
SWEP.WorldPos = Vector(13, -1, 2.2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 20
SWEP.DistSound = "m9/m9_dist.wav"

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -10)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.attPos = Vector(-3,-1,0)
SWEP.attAng = Angle(0,0,0)

--local to head
SWEP.RHPos = Vector(6,-6.5,3.5)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(6,-1,-2)
SWEP.LHAng = Angle(0,25,-80)

local finger1 = Angle(-15,0,5)
local finger2 = Angle(-15,45,-5)

function SWEP:AnimHoldPost(model)
	--self:BoneSet("l_finger0", vector_zero, finger1)
    --self:BoneSet("l_finger02", vector_zero, finger2)
end

--RELOAD ANIMS SMG????

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,-2,-2),
	Vector(-15,5,-7),
	Vector(-15,5,-15),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	"fastreload",
	Vector(5,0,5),
	Vector(-2,1,5),
	Vector(-2,1,5),
	Vector(-2,1,5),
	Vector(0,0,0),
	"reloadend",
	Vector(0,0,0)
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
	Angle(-75,0,45),
	Angle(-75,0,45),
	Angle(-25,0,45),
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
	Angle(15,25,25),
	Angle(-15,25,25),
	Angle(0,0,-15),
	Angle(0,0,-25),
	Angle(-15,0,-25),
	Angle(-05,0,-15),
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