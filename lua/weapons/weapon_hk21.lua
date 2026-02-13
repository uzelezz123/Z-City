SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "HK21"
SWEP.Author = "Heckler & Koch"
SWEP.Instructions = "Machine gun chambered in 7.62x51 mm\n\nRate of fire 900 rounds per minute. That thing is quite serious if you might ask."
SWEP.Category = "Weapons - Machineguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/pwb/weapons/w_hk23e.mdl"

SWEP.WepSelectIcon2 = Material("pwb/sprites/hk23e.png")
SWEP.IconOverride = "entities/weapon_pwb_hk23e.png"

SWEP.CustomShell = "762x51"
SWEP.CustomSecShell = "mc51len"
--SWEP.EjectPos = Vector(-5,0,-5)
--SWEP.EjectAng = Angle(-45,-80,0)

SWEP.CanSuicide = false

SWEP.ScrappersSlot = "Primary"
SWEP.weight = 5

SWEP.ShockMultiplier = 2

SWEP.LocalMuzzlePos = Vector(22.852,-0.004,7.374)
SWEP.LocalMuzzleAng = Angle(-0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x51 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 65
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 65
SWEP.Primary.Sound = {"homigrad/weapons/rifle/pdr-2.wav", 75, 80, 90}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/fnfal/handling/fnfal_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.066
SWEP.ReloadTime = 7.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb/weapons/hk23e/magout.wav",
	"none",
	"none",
	"pwb/weapons/hk23e/magin.wav",
	"none",
	"none",
	"weapons/tfa_ins2/mp7/boltback.wav",
	"pwb2/weapons/vectorsmg/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-9, 0.1385, 11.5285)
SWEP.RHandPos = Vector(-14, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Spray = {}
for i = 1, 150 do
	SWEP.Spray[i] = Angle(-0.04 - math.cos(i) * 0.03, math.cos(i * i) * 0.05, 0) * 2
end

SWEP.ShellEject = "EjectBrass_762Nato"
SWEP.Ergonomics = 0.6
SWEP.OpenBolt = true
SWEP.Penetration = 20
SWEP.WorldPos = Vector(14, -1, 4)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.AimHands = Vector(0, 1.8, -4.5)
SWEP.lengthSub = 15
SWEP.DistSound = "m249/m249_dist.wav"
SWEP.bipodAvailable = true
SWEP.bipodsub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(-5, 8, -14)
SWEP.holsteredAng = Angle(220, 0, 180)

SWEP.RestPosition = Vector(20, -1, 2)

--local to head
SWEP.RHPos = Vector(6,-7,5)
SWEP.RHAng = Angle(0,-15,90)
--local to rh
SWEP.LHPos = Vector(13.5,0.7,-5.2)
SWEP.LHAng = Angle(-180,190,-230)

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,-2,-8),
	Vector(0,-2,-8),
	Vector(0,-2,-8),
	Vector(0,-2,-9),
	Vector(-8,15,-15),
	Vector(-15,20,-25),
	Vector(-13,12,-5),
	Vector(0,-2,-8),
	Vector(-1,-2,-1),
	Vector(0,-2,-4),
	Vector(0,-2,-3),
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
	Vector(0,0,5),
	Vector(6,1,5),
	Vector(6,2,5),
	Vector(6,1,0),
	Vector(6,2,0),
	Vector(-1,3,1),
	Vector(-2,3,1),
	Vector(-5,3,1),
	Vector(-2,3,1),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-10),
	Angle(0,45,-95),
	Angle(0,45,-60),
	Angle(0,45,-30),
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