SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "ČZ 75"
SWEP.Author = "Česká zbrojovka Uherský Brod"
SWEP.Instructions = "Pistol chambered in 9x19 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.WorldModelFake = "models/weapons/tfa_ins2/c_cz75a.mdl"

SWEP.FakePos = Vector(-24, 2.9, 8.65)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-1.5,-0.01,1.08)
SWEP.AttachmentAng = Angle(0,0,90)
SWEP.MagIndex = 53


SWEP.FakeVPShouldUseHand = true
SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reload_empty",
}

SWEP.FakeReloadSounds = {
	[0.3] = "weapons/universal/uni_pistol_draw_01.wav",
	[0.5] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",
	--[0.45] = "weapons/tfa_ins2/usp_tactical/magout.wav",
	--[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.6] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.7] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[0.85] = "weapons/universal/uni_pistol_holster.wav",
	[1.02] = "weapons/universal/uni_crawl_l_02.wav"
	--[1] = "weapons/tfa_ins2/usp_match/usp_match_boltrelease.wav",
	--[0.77] = "weapons/tfa_ins2/usp_match/usp_match_maghit.wav",
	--[0.95] = "weapons/tfa_ins2/usp_match/usp_match_boltrelease.wav",
}

SWEP.FakeEmptyReloadSounds = {
	[0.15] = "weapons/universal/uni_crawl_l_03.wav",
	[0.22] = "weapons/tfa_ins2/usp_tactical/magrelease.wav",
	[0.3] = "weapons/tfa_ins2/usp_tactical/magout.wav",
	--[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.37] = "weapons/universal/uni_pistol_draw_01.wav",
	[0.41] = "weapons/universal/uni_crawl_l_05.wav",
	[0.6] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.8] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[1] = "weapons/tfa_ins2/usp_match/usp_match_boltrelease.wav",
}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl" 

SWEP.lmagpos = Vector(2.,0,0)
SWEP.lmagang = Angle(-10,0,0)
SWEP.lmagpos2 = Vector(0,-1.5,0.7)
SWEP.lmagang2 = Angle(0,0,0)

if CLIENT then
	local vector_full = Vector(1, 1, 1)

	SWEP.FakeReloadEvents = {
		[0.35] = function( self ) 
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(0,0,-50) )
				self:GetWM():ManipulateBoneScale(50, vector_origin)
				self:GetWM():ManipulateBoneScale(51, vector_origin)
				self:GetWM():ManipulateBoneScale(52, vector_origin)
			end
		end,
		[0.15] = function( self, timeMul )
			if self:Clip1() >= 1 then
				--self:GetWM():ManipulateBoneScale(50, vector_origin)
				--self:GetWM():ManipulateBoneScale(51, vector_origin)
				--self:GetWM():ManipulateBoneScale(52, vector_origin)

				self:GetWM():ManipulateBoneScale(53, vector_full)
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end,
		[0.2] = function( self, timeMul )
			if self:Clip1() < 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.5 * timeMul)//, self.MagModel, {Vector(0,0,0), Angle(0,0,0), 49, Vector(0,4.8,-1.8), Angle(-15,-90,180)})
			end
		end,
		[0.36] = function( self )
			if self:Clip1() >= 1 then
				self:GetWM():ManipulateBoneScale(50, vector_full)
				self:GetWM():ManipulateBoneScale(51, vector_full)
				self:GetWM():ManipulateBoneScale(52, vector_full)
			end
		end,
		[0.5] = function( self )
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(50, vector_full)
				self:GetWM():ManipulateBoneScale(51, vector_full)
				self:GetWM():ManipulateBoneScale(52, vector_full)
			end
		end,

		[0.8] = function( self, timeMul )
			if self:Clip1() >= 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1*timeMul)
			end
		end,
		[0.9] = function( self ) 
			self:GetWM():ManipulateBoneScale(53, vector_origin)
		end,

		[1.2] = function( self ) 
			if self:Clip1() >= 1 then
				//self:PlayAnim("idle",1,false)
			end
		end,
	}
end


SWEP.WepSelectIcon2 = Material("pwb/sprites/cz75.png")
SWEP.IconOverride = "entities/weapon_pwb_cz75.png"

SWEP.CustomShell = "9x19"
--SWEP.EjectPos = Vector(0,10,5)
--SWEP.EjectAng = Angle(-55,80,0)
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.weight = 1

SWEP.ScrappersSlot = "Secondary"

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 16
SWEP.Primary.DefaultClip = 16
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"zcitysnd/sound/weapons/firearms/hndg_mkiii/mkiii_fire_01.wav", 75, 90, 100}
SWEP.SupressedSound = {"m9/m9_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 4
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/usp_tactical/magout.wav",
	"weapons/tfa_ins2/browninghp/magin.wav",
	"pwb/weapons/fnp45/sliderelease.wav",
	"none",
	"none",
	"none"
}
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-30, 0.9078, 8.355)
SWEP.RHandPos = Vector(-13.5, 0, 4)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1
SWEP.Penetration = 7
SWEP.WorldPos = Vector(8, -0.4, 3.55)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, -0.9)
SWEP.attAng = Angle(0.02, -0.7, 0)
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(-3, 0, -7)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		[3] = {"supressor3", Vector(0,0,0), {}},

		["mount"] = Vector(1.1,0.2,0),
	},
}

SWEP.LocalMuzzlePos = Vector(-3.44,0.9,7.955)
SWEP.LocalMuzzleAng = Angle(0.7,-0.002,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

--local to head
SWEP.RHPos = Vector(16,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

local finger1 = Angle(-25,10,25)
local finger2 = Angle(0,25,0)
local finger3 = Angle(31,1,-25)
local finger4 = Angle(-10,-5,-5)
local finger5 = Angle(0,-65,-15)
local finger6 = Angle(15,-5,-15)

function SWEP:AnimHoldPost()
	--self:BoneSet("r_finger0", vector_zero, finger6)
	--self:BoneSet("l_finger0", vector_zero, finger1)
    --self:BoneSet("l_finger02", vector_zero, finger2)
	--self:BoneSet("l_finger1", vector_zero, finger3)
	--self:BoneSet("r_finger1", vector_zero, finger4)
	--self:BoneSet("r_finger11", vector_zero, finger5)
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() then
		self:GetWM():SetBodyGroups("01")
	end
end

SWEP.ShootAnimMul = 5


function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,(self:Clip1() > 0 or self.reload) and 0 or 2.2)
		wep:ManipulateBonePosition(44,Vector(0 ,0.8*self.shooanim ,0 ),false)
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