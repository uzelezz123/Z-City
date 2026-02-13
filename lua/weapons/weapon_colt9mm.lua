SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Colt 9mm SMG"
SWEP.Author = "Colt's Manufacturing Company"
SWEP.Instructions = "AR15 pistol chambered in 9x19 mm\n\nALT+E to change stance (+walk,+use)"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ud_m16.mdl"
SWEP.FakePos = Vector(-13, 3, 6)
SWEP.FakeAng = Angle(0, 0, 0.1)
SWEP.AttachmentPos = Vector(3.8,2.1,-27.8)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "0360242C00000"
SWEP.ZoomPos = Vector(0, 0.16, 4.8)
SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2,10,4)

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
	["reload"] = "reload_9mm",
	["reload_empty"] = "reload_empty_9mm",
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mpistol" -- shared in sh_effects.lua

SWEP.CustomShell = "9x19"

SWEP.ScrappersSlot = "Primary"

SWEP.WepSelectIcon2 = Material("entities/zcity/colt9mm.png")
SWEP.IconOverride = "entities/zcity/colt9mm.png"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.FakeEjectBrassATT = "2"
SWEP.Primary.ClipSize = 32
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"m16a4/m16a4_fp.wav", 75, 120, 130}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 3.3
SWEP.bigNoDrop = true
SWEP.podkid = 0.1

SWEP.punchmul = 2
SWEP.punchspeed = 1

SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/mp5k/mp5k_magout.wav",
	"none",
	"none",
	"weapons/tfa_ins2/browninghp/magin.wav",
	"weapons/tfa_ins2/browninghp/maghit.wav",
	"weapons/tfa_ins2/browninghp/boltback.wav",
	"none",
	"weapons/tfa_ins2/browninghp/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}


SWEP.LocalMuzzlePos = Vector(17,0,2)
SWEP.LocalMuzzleAng = Angle(-0.2,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.RHandPos = Vector(2, -1, 1)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.00, -0.02, 0), Angle(-0.01, 0.02, 0)}
SWEP.Ergonomics = 0.9
SWEP.Penetration = 7
SWEP.WorldPos = Vector(5, -0.8, -1.1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 2
SWEP.attPos = Vector(-10.25, -2.1, 28)
SWEP.attAng = Angle(0, 0.4, 0)

SWEP.weight = 2.5
SWEP.addweight = -1.5
SWEP.PistolKinda = true

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(3,9.5,-16.5)
SWEP.lmagang2 = Angle(0,0,-90)
SWEP.FakeMagDropBone = 52

if CLIENT then
	local vector_full = Vector(1,1,1)
	SWEP.MagModel = "models/weapons/arccw/c_ud_m16.mdl"
	SWEP.FakeReloadEvents = {	
		[0.15] = function(self, timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(52, vector_origin)
				self:GetWM():ManipulateBoneScale(55, vector_full)
			end
		end,

		[0.25] = function(self, timeMul)
			if self:Clip1() > 1 then
				self:GetWM():ManipulateBoneScale(52, vector_full)
				self:GetWM():ManipulateBoneScale(55, vector_full)
			end
		end,
		[0.30] = function(self, timeMul)
			if self:Clip1() < 1 then
				local ent = hg.CreateMag( self, Vector(0,45,-12), self.FakeBodyGroups or "0", true)
				for i = 0, ent:GetBoneCount() - 1 do
					ent:ManipulateBoneScale(i, vector_origin)
				end
				ent:ManipulateBoneScale(52, vector_full)
				--ent:ManipulateBoneScale(55, vector_full)

				self:GetWM():ManipulateBoneScale(52, vector_origin)
				self:GetWM():ManipulateBoneScale(55, vector_origin)
				--self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end,
		[0.50] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(52, vector_full)
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(55, vector_origin)
			end
		end,
		[0.85] = function(self, timeMul)
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
		vec[1] = 0 * self.shooanim
		vec[2] = 0 * self.shooanim
		vec[3] = -2 * self.shooanim
		wep:ManipulateBonePosition(46,vec,false)
	end
end

SWEP.lengthSub = 5
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredPos = Vector(5, 8, -6)
SWEP.holsteredAng = Angle(-150, -10, 180)

--local to head
SWEP.RHPos = Vector(3,-6,3.5)
SWEP.RHAng = Angle(0,-12,90)
--local to rh
SWEP.LHPos = Vector(15,1,-3.3)
SWEP.LHAng = Angle(-110,-180,0)

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