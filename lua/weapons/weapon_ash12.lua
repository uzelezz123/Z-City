SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "ASH-12"
SWEP.Author = "Izhmash TsKIB SOO"
SWEP.Instructions = "The ASH-12 is a 12.7×55mm large-caliber assault rifle designed for close-quarters combat. It delivers high stopping power at around 700 rounds per minute."
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/shak_12/ash12/w_mk18.mdl"
SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12.7x55 mm"

SWEP.CustomShell = "50cal"
SWEP.EjectPos = Vector(9,0,3.5)
SWEP.EjectAng = Angle(0,0,0)

SWEP.ScrappersSlot = "Primary"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 70
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 70
SWEP.Primary.Sound = {"weapons/ash12.7/fph12.wav", 85, 100, 110}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/ak74/handling/ak74_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.085
SWEP.ReloadTime = 5.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/akp/ak47/ak47_magout.wav",
	"none",
	"weapons/tfa_ins2/akp/ak47/ak47_magin.wav",
	"weapons/tfa_ins2/akp/aks74u/aks_boltback.wav",
	"weapons/tfa_ins2/akp/aks74u/aks_boltrelease.wav",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1" -- shared in sh_effects.lua

SWEP.LocalMuzzlePos = Vector(12,0,3)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, 0.0054, 5.4373)
SWEP.RHandPos = Vector(-32, -111, 14)
SWEP.LHandPos = Vector(37, -2, -2)
SWEP.Penetration = 11
SWEP.Spray = {}
for i = 1, 30 do
    if i <= 15 then
        SWEP.Spray[i] = Angle(-0.2, 0, 0)
    else
        SWEP.Spray[i] = Angle(0, 0.2, 0)
    end
end

SWEP.WepSelectIcon2 = Material("entities/tfa_pd2_ash12.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/tfa_pd2_ash12.png"

SWEP.Ergonomics = 1
SWEP.WorldPos = Vector(5, -1, -2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(1, -1.5, 0)
SWEP.DistSound = "ak74/ak74_dist.wav"

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"ironsight", "picatinny"},
		["mount"] = {["picatinny"] = Vector(-12, 2, 0), ["ironsight"] = Vector(-14, 2, 0)},
	},
	mount = {
		["picatinny"] = {
			"empty",
			Vector(-12, 2, 0),
			{},
			["mountType"] = "picatinny",
		},
	},
	grip = {
		["mount"] = Vector(11,-1.3,0),
		["mountType"] = "picatinny"
	},
	underbarrel = {
		["mount"] = {["picatinny_small"] = Vector(12, -2.9, -1),["picatinny"] = Vector(14,0.8,0)},
		["mountAngle"] = {["picatinny_small"] = Angle(0, 0, 90),["picatinny"] = Angle(0, 0, 0)},
		["mountType"] = {"picatinny_small","picatinny"},
	}
}

SWEP.StartAtt = {"grip2", "ironsight1"}

SWEP.weight = 3

--local to head
SWEP.RHPos = Vector(6,-8,4)
SWEP.RHAng = Angle(-7,-12,90)
--local to rh
SWEP.LHPos = Vector(10,0.8,-3.7)
SWEP.LHAng = Angle(-120,180,0)

local finger1 = Angle(25,0, 40)

SWEP.ShootAnimMul = 3
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0,0,0)
	local vec = self.vec
	
	if CLIENT and IsValid(wep) then
		self.LHPos = LerpVectorFT(0.2,self.LHPos, self.reload and Vector(0,0.8,-4.7) or Vector(10,0.8,-3.7) )
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self.ReloadSlideOffset)
		vec[1] = -2.1*self.shooanim
		vec[2] = 0.2*self.shooanim
		vec[3] = -0.1*self.shooanim
		wep:ManipulateBonePosition(6,vec,false)
	end
end

local lfang2 = Angle(12, -15, -1)
local lfang1 = Angle(25, 0, -5)
local lfang0 = Angle(-7,15, -30)
local vec_zero = Vector(0,0,0)
local ang_zero = Angle(0,0,0)
function SWEP:AnimHoldPost()
	self:BoneSet("l_finger0", vec_zero, lfang0)
	self:BoneSet("l_finger02", vec_zero, ang_zero)
	self:BoneSet("l_finger1", vec_zero, lfang1)
	self:BoneSet("l_finger2", vec_zero, lfang2)
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-1.5,1.5,-9),
	Vector(-1.5,1.5,-9),
	Vector(-1.5,1.5,-9),
	Vector(-6,7,-9),
	Vector(-15,7,-15),
	Vector(-15,6,-15),
	Vector(-13,5,-5),
	Vector(-1.5,1.5,-9),
	Vector(-1.5,1.5,-9),
	Vector(-1.5,1.5,-9),
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
	Vector(0,0,1),
	Vector(8,1,2),
	Vector(9,4,-4),
	Vector(9,5,-4),
	Vector(8,5,-4),
	Vector(1,5,-3),
	Vector(1,5,-2),
	Vector(0,4,-1),
	Vector(0,5,0),
	"reloadend",
	Vector(-2,2,1),
	Vector(0,0,0),
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
	3,
	3,
	0,
	0,
	0,
	0
}


SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-70,0,110),
	Angle(-50,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-60,0,95),
	Angle(0,0,60),
	Angle(0,0,30),
	Angle(0,0,2),
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
	Angle(15,0,-50),
	Angle(15,0,-50),
	Angle(15,0,-50),
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-15,15,-17),
	Angle(-14,14,-22),
	Angle(-10,15,-24),
	Angle(12,14,-23),
	Angle(11,15,-20),
	Angle(12,14,-19),
	Angle(11,14,-20),
	Angle(7,17,-22),
	Angle(0,14,-21),
	Angle(0,15,-22),
	Angle(0,24,-23),
	Angle(0,25,-22),
	Angle(-15,24,-25),
	Angle(-15,25,-23),
	Angle(5,0,2),
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