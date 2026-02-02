SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "PM-9"
SWEP.Author = "john rainworld"
SWEP.Instructions = "A homemade gun. Chambered in 9x19 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/pm9v2.mdl"

SWEP.WepSelectIcon2 = Material("entities/zcity/pm9.png")
SWEP.IconOverride = "entities/zcity/pm9.png"

SWEP.weaponInvCategory = 2
SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(0,3,2)
SWEP.EjectAng = Angle(-80,-90,0)

SWEP.IsPistol = true
SWEP.podkid = 0.5

SWEP.ScrappersSlot = "Secondary"

SWEP.Primary.ClipSize = 19
SWEP.Primary.DefaultClip = 19
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"weapons/tfa_ins2/m1911/m1911_fire.wav", 75, 90, 100}
SWEP.Primary.SoundEmpty = {"weapons/tfa_ins2/m1911/m1911_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 35
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 4.5
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
	"none",
	"weapons/tfa_ins2/browninghp/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 0.1224, 1.7109)
SWEP.RHandPos = Vector(-5, -0.5, -1)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.05, -0.05, 0), Angle(-0.07, 0.07, 0)}
SWEP.Ergonomics = 0.7
SWEP.Penetration = 6
SWEP.WorldPos = Vector(5.5, -1, -4.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.shouldntDrawHolstered = true
SWEP.weight = 0.85

SWEP.LocalMuzzlePos = Vector(8,0.15,1)
SWEP.LocalMuzzleAng = Angle(1.5,0.002,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

--local to head
SWEP.RHPos = Vector(8,-5,3)
SWEP.RHAng = Angle(0,-2,90)
--local to rh
SWEP.LHPos = Vector(4.5,-2,-2.5)
SWEP.LHAng = Angle(-5,0,-90)

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(4.2,0,0), {}},
		["mount"] = Vector(8.3,1.1,-0.1),
	},
    magwell = {
        [1] = {"mag1",Vector(4.3,-2.5,0), {}}
    },
	sight = {
		["mountType"] = {"picatinny","pistolmount"},
		["mount"] = {["picatinny"] = Vector(-2.5, 2.15, 0), ["pistolmount"] = Vector(-6.2, .5, 0.025)},
		["mountAngle"] = Angle(0,0,0),
	},
	underbarrel = {
		["mount"] = Vector(16.8, -0.35, 0.3),
		["mountAngle"] = Angle(0, 0, 90),
		["mountType"] = "picatinny_small"
	},
	mount = {
		["picatinny"] = {
			"mount4",
			Vector(-1.5, -.1, 0),
			{},
			["mountType"] = "picatinny",
		}
	},
	grip = {
		["mount"] = Vector(23.5, 1.4, 0.1), 
		["mountType"] = "picatinny"
	}
}

local finger1 = Angle(-20, 40, 10)
local finger2 = Angle(10, -15, 10)
local finger3 = Angle(10, -70, 10)
local finger4 = Angle(-10, -10, 30)
local finger5 = Angle(10, -30, 10)
local finger6 = Angle(-20, 0, -10)

function SWEP:AnimHoldPost(model)

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
	Vector(5,0,5),
	Vector(-2,1,1),
	Vector(-2,1,1),
	Vector(-2,1,1),
	Vector(0,0,0),
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
	Angle(0,25,45),
	Angle(15,25,45),
	Angle(-15,25,45),
	Angle(0,0,-25),
	Angle(0,0,-45),
	Angle(-35,0,-25),
	Angle(-35,2,-24),
	Angle(-15,0,-45),
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