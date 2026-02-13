SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "O.S.I.P.R."
SWEP.Author = "Universal Union"
SWEP.Instructions = "O.S.I.P.R. (Overwatch Standard Issue Pulse Rifle) is a Dark Energy/pulse-powered assault rifle.\n\nRate of fire 600 rounds per minute"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_irifle.mdl"

SWEP.FakePos = Vector(26, -5.9, 8.8)
SWEP.FakeAng = Angle(0, 180, 0)
SWEP.AttachmentPos = Vector(0,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeEjectBrassATT = "punch"

SWEP.FakeReloadSounds = {
	[0.17] = "weapons/hmcd_ar2/ar2_rotate.wav",
	[0.35] = "weapons/hmcd_ar2/ar2_magout.wav",
	[0.75] = "weapons/hmcd_ar2/ar2_magin.wav",
	[0.85] = "weapons/hmcd_ar2/ar2_push.wav"
	--[0.82] = "weapons/ar2/ar2_reload_rotate.wav",
	--[0.92] = "weapons/ar2/ar2_reload_push.wav"
}
SWEP.FakeEmptyReloadSounds = {
	[0.17] = "weapons/hmcd_ar2/ar2_rotate.wav",
	[0.35] = "weapons/hmcd_ar2/ar2_magout.wav",
	[0.75] = "weapons/hmcd_ar2/ar2_magin.wav",
	[0.82] = "weapons/hmcd_ar2/ar2_reload_rotate.wav",
	[0.92] = "weapons/hmcd_ar2/ar2_reload_push.wav"
}
SWEP.MagModel = "models/Items/combine_rifle_cartridge01.mdl"
SWEP.FakeMagDropBone = 1
local vector_full = Vector(1,1,1)
local vecPochtiZero = Vector(0.01,0.01,0.01)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 50

SWEP.internalholo = Vector(15, 0, 0)
SWEP.holo = Material("effects/sun_textures/birthshock")
SWEP.colorholo = Color(79, 255, 255)
SWEP.internalholosize = 0.8
SWEP.holo_size = 0.5

if CLIENT then
	SWEP.FakeReloadEvents = {
		[0.4] = function( self, timeMul )
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(0,0,-15) )
				self:GetWM():ManipulateBoneScale(1, vecPochtiZero)
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.8 * timeMul)

			end 
		end,
		[0.6] = function( self, timeMul )
			if self:Clip1() < 1 then

				self:GetWM():ManipulateBoneScale(1, vector_full)
			else

			end 
			self.AnimList["idle"] = "idle"
			self.AnimList["reload"] = "reload"
		end,
	}
end

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reloadempty",
}

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(5,1,-1)
SWEP.lmagang2 = Angle(0,-90,0)

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pulse"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 50
SWEP.Primary.Spread = 0 
SWEP.Primary.Force = 50
SWEP.Primary.Sound = {"weapons/hmcd_ar2/fire1.wav", 85, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/mk18/handling/mk18_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.ShootEffect = 5
SWEP.ShellEject = true
SWEP.MuzzleEffectType = 0
SWEP.CustomShell = "Pulse"
SWEP.EjectPos = Vector(5,20,-4)
SWEP.EjectAng = Angle(15,-90,0)
SWEP.ScrappersSlot = "Primary"
SWEP.weight = 3.5
SWEP.NoWINCHESTERFIRE = true
SWEP.punchmul = 0.5
SWEP.punchspeed = 1
--SWEP.podkid = 1.1

SWEP.PPSMuzzleEffect = "new_ar2_muzzle" -- shared in sh_effects.lu

SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_ar2")
SWEP.IconOverride = "vgui/wep_jack_hmcd_ar2"

SWEP.availableAttachments = {
}

SWEP.Primary.Wait = 0.1
SWEP.ReloadTime = 4
SWEP.ReloadSoundes = {
	"none",
	"none",
	"none",
	"none",
	"weapons/ar2/ar2_magout.wav",
	"none",
	"none",
	"weapons/ar2/ar2_magin.wav",
	"none",
	"weapons/ar2/ar2_reload_rotate.wav",
	"none",
	"weapons/ar2/ar2_push.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(3, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 1.767, 6.4546)
SWEP.Spray = {}
for i = 1, 30 do
	SWEP.Spray[i] = Angle(-0.06 - math.cos(i) * 0.03, math.cos(i * i) * 0.04, 0) * 2
end

SWEP.DeploySnd = {"weapons/ar2/ar2_deploy.wav", 75, 100, 110}

SWEP.Ergonomics = 0.8
SWEP.HaveModel = "models/weapons/arccw/w_irifle.mdl"
SWEP.Penetration = 17
SWEP.WorldPos = Vector(15, -0.5, -1.5)
SWEP.WorldAng = Angle(0, 180, 0)
SWEP.UseCustomWorldModel = true
--https://youtu.be/I7TUHPn_W8c?list=RDEMAfyWQ8p5xUzfAWa3B6zoJg  wizards
SWEP.attPos = Vector(0, 0.7, 0)
SWEP.attAng = Angle(0.2, 0.7, 90)
SWEP.lengthSub = 20
SWEP.DistSound = "weapons/newsndw/fire1.wav"

SWEP.LocalMuzzlePos = Vector(-9.963,-0.818,3.582)
SWEP.LocalMuzzleAng = Angle(0.4,180,0)
SWEP.WeaponEyeAngles = Angle(0,180,0)

SWEP.rotatehuy = 180

--local to head
SWEP.RHPos = Vector(4,-8.5,5)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(10.5,-3,-9)
SWEP.LHAng = Angle(0-10,0,-90)

local finger1 = Angle(45,-25,50)

function SWEP:AnimHoldPost(model)
	--self:BoneSet("l_finger0", vector_zero, finger1)
end

function SWEP:PrimaryShootPost()
	if CLIENT then
		if self:Clip1() == 0 then self:PlayAnim(self:Clip1() >= 1 and (self:Clip1() > 1 and "fire1_is" or "fire_midempty_is" ) or "fire_last_ironsight", 1) end
		
		if self:Clip1() < 2 then
			self.AnimList["idle"] = "idle_midempty"
			self.AnimList["reload"] = "reload_midempty"
		end
		if self:Clip1() < 1 then
			self.AnimList["idle"] = "idle_empty"
		end
	end
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,1,-2),
	Vector(0,2,-2),
	Vector(0,3,-2),
	Vector(0,3,-8),
	Vector(-8,15,-15),
	Vector(-15,20,-25),
	Vector(-13,12,-5),
	Vector(-6,6,-3),
	Vector(-1,5,-1),
	Vector(0,4,-1),
	"fastreload",
	Vector(0,3,-3),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
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
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-25,15,-15),
	Angle(-25,15,-25),
	Angle(-10,15,-25),
	Angle(15,0,-25),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,-5),
	Angle(0,25,-40),
	Angle(0,25,-45),
	Angle(0,25,-25),
	Angle(0,25,-25),
	Angle(0,0,2),
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