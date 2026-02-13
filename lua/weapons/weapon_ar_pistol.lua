SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AR-15"
SWEP.Author = "Colt's Manufacturing Company"
SWEP.Instructions = "This steel/polymer AR-15 semi-automatic pistol is in 5.56x45 caliber. With a barrel shorter than the 16-inch legal length for a rifle, and a pistol buffer tube or stabilizing brace in place of a stock, it provides a compact and powerful alternative to its longer-barreled counterparts. The pistol's compact size allows it to be used in small spaces, while its versatility and customizability have carved a niche for itself in the civilian market. A testament to the versatility of the AR platform, the AR-15 pistol symbolizes the balance between personal defense and recreational shooting.\n\nALT+E to change stance (+walk,+use)"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ud_m16.mdl"
SWEP.WepSelectIcon2 = Material("entities/zcity/arpistol.png")
SWEP.IconOverride = "entities/zcity/arpistol.png"
SWEP.FakePos = Vector(-10, 3, 6)
SWEP.FakeAng = Angle(0, 0, 0.1)
SWEP.AttachmentPos = Vector(-8.1,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "0112255300230"
SWEP.ZoomPos = Vector(0, -0.0027, 4.6866)
SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2,10,6)

SWEP.FakeReloadSounds = {
	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.29] = "weapons/arccw_ud/m16/grab.ogg",
	[0.34] = "weapons/arccw_ud/m16/magout.ogg",
	[0.38] = "weapons/ak74/ak74_magout_rattle.wav",

	[0.64] = "weapons/arccw_ud/m16/grab.ogg",
	[0.64] = "weapons/arccw_ud/m16/magin.ogg",
	[0.81] = "weapons/universal/uni_crawl_l_03.wav",
	[0.99] = "weapons/universal/uni_crawl_l_04.wav",

}

SWEP.FakeEmptyReloadSounds = {

	[0.22] = "weapons/universal/uni_crawl_l_03.wav",
	[0.29] = "weapons/arccw_ud/m16/magout_empty.ogg",
	[0.32] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.59] = "weapons/arccw_ud/m16/grab.ogg",
	[0.62] = "weapons/arccw_ud/m16/magin.ogg",

	[0.83] = "weapons/arccw_ud/m16/magtap.ogg",
	[1.01] = "weapons/universal/uni_crawl_l_04.wav",
}

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_20",
	["reload_empty"] = "reload_empty_20",
}

SWEP.weaponInvCategory = 1
SWEP.bigNoDrop = true
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.CustomShell = "556x45"

SWEP.punchmul = 2
SWEP.punchspeed = 1

SWEP.StartAtt = {"ironsight3"}

SWEP.ShockMultiplier = 3

SWEP.ScrappersSlot = "Primary"

SWEP.LocalMuzzlePos = Vector(20,0,2.5)
SWEP.LocalMuzzleAng = Angle(-0.2,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 44
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 44
SWEP.Primary.Sound = {"rifle_win1892/win1892_fire_01.wav", 75, 90, 100}
SWEP.SupressedSound = {"m4a1/m4a1_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.Wait = 0.12
SWEP.ReloadTime = 3.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb2/weapons/m4a1/ru-556 clip out 1.wav",
	"none",
	"none",
	"pwb2/weapons/m4a1/ru-556 clip in 2.wav",
	"none",
	"pwb2/weapons/m4a1/ru-556 bolt back.wav",
	"pwb2/weapons/m4a1/ru-556 bolt forward.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle2" -- shared in sh_effects.lua

SWEP.HoldType = "rpg"

SWEP.RHandPos = Vector(2, -1, 1)
SWEP.LHandPos = false
SWEP.AimHands = Vector(-2, 0.45, -5.9)
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7
SWEP.WorldPos = Vector(0, -0.8, -1.1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(-1.2,0.35,0),
	},
	sight = {
		["empty"] = {
			"empty",
			{
				[1] = "null"
			},
		},
		["mountType"] = {"picatinny","ironsight"},
		["mount"] = {ironsight = Vector(-12, 1.3, 0.05), picatinny = Vector(-14, 1.3, 0.05)},
		["removehuy"] = {
			[1] = "null"
		}
	}
}

SWEP.weight = 3

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(3,9.5,-16.5)
SWEP.lmagang2 = Angle(0,0,-90)
SWEP.FakeMagDropBone = 52

if CLIENT then
	local vector_full = Vector(1,1,1)
	SWEP.MagModel = "models/weapons/arccw/c_ud_m16.mdl"
	SWEP.FakeReloadEvents = {	
		[0.15] = function(self,timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(52, vector_origin)
				self:GetWM():ManipulateBoneScale(55, vector_full)
			end
		end,

		[0.25] = function(self,timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(52, vector_full)
				self:GetWM():ManipulateBoneScale(55, vector_full)
			end
		end,
		[0.30] = function(self,timeMul)
			if self:Clip1() < 1 then
				local ent = hg.CreateMag( self, Vector(0,0,-12), self.FakeBodyGroups or "0", true)
				for i = 0, ent:GetBoneCount() - 1 do
					ent:ManipulateBoneScale(i, vector_origin)
				end
				ent:ManipulateBoneScale(52, vector_full)
				ent:ManipulateBoneScale(55, vector_full)

				self:GetWM():ManipulateBoneScale(52, vector_origin)
				self:GetWM():ManipulateBoneScale(55, vector_origin)
				--self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end,
		[0.50] = function(self,timeMul)
			self:GetWM():ManipulateBoneScale(52, vector_full)
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(55, vector_origin)
			end
		end,
		[0.85] = function(self,timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(55, vector_origin)
			end
		end
	}
end

function SWEP:ModelCreated(model)
	model:ManipulateBoneScale(55, vector_origin)
	model:SetBodyGroups(self.FakeBodyGroups)
end

SWEP.ShootAnimMul = 3
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0,0,0)
	local vec = self.vec
	if CLIENT and IsValid(wep) then
		self.shooanim = Lerp(FrameTime()*15,self.shooanim or 0,self.ReloadSlideOffset)
		vec[1] = 0*self.shooanim
		vec[2] = 0*self.shooanim
		vec[3] = -2*self.shooanim
		wep:ManipulateBonePosition(46,vec,false)
	end
end

SWEP.lengthSub = 5
SWEP.holsteredPos = Vector(5, 8, -4)
SWEP.holsteredAng = Angle(-150, -10, 180)

--local to head
SWEP.RHPos = Vector(3,-6,3.5)
SWEP.RHAng = Angle(0,-12,90)
--local to rh
SWEP.LHPos = Vector(15,1,-3.3)
SWEP.LHAng = Angle(-110,-180,0)

SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.FakeMagDropBone = 52

SWEP.FakeEjectBrassATT = "2"

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