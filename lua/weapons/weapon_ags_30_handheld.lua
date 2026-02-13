SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "AGS-30"
SWEP.Author = "TODO"
SWEP.Instructions = "Babah"
SWEP.Category = "Weapons - Grenade Launchers"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/escape from tarkov/static/weapons/ags-30.mdl"

SWEP.WepSelectIcon2 = Material("pwb/sprites/hk23e.png")
SWEP.IconOverride = "entities/weapon_pwb_hk23e.png"

SWEP.CustomShell = "762x51"
SWEP.EjectPos = Vector(11,0,19)
SWEP.EjectAng = Angle(0,0,0)
SWEP.EjectAddAng = Angle(0,0,-90)

SWEP.CanSuicide = false

SWEP.ScrappersSlot = "Primary"
SWEP.weight = 5

SWEP.ShockMultiplier = 2
SWEP.NoWINCHESTERFIRE = true

SWEP.LocalMuzzlePos = Vector(0,-31,18.3)
SWEP.LocalMuzzleAng = Angle(0,-90,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Grenade 30x29mm"
SWEP.UsePhysBullets = true
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 65
SWEP.Primary.Spread = Vector(0,0,0)
SWEP.Primary.Force = 125
SWEP.Primary.Sound = {"snds_jack_gmod/ez_weapons/heavy_autoloader.wav", 75, 80, 90}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/fnfal/handling/fnfal_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.2
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
SWEP.ZoomPos = Vector(0, -0.015, 24.5262)

SWEP.RHandPos = Vector(-14, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Spray = {}
for i = 1, 150 do
	SWEP.Spray[i] = Angle(-0.04 - math.cos(i) * 0.03, math.cos(i * i) * 0.05, 0) * 2
end

SWEP.ShellEject = "EjectBrass_762Nato"
SWEP.Ergonomics = 0.5
SWEP.OpenBolt = true
SWEP.Penetration = 20
SWEP.WorldPos = Vector(8.5, -7.2, 15.5)
SWEP.WorldAng = Angle(0, -90, -6)
SWEP.UseCustomWorldModel = true
SWEP.AimHands = Vector(0, 1.8, -4.5)
SWEP.lengthSub = 15
SWEP.DistSound = "snds_jack_gmod/ez_weapons/shotgun_far.wav"
SWEP.bipodAvailable = true
SWEP.bipodsub = 15

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(-24, 18, -25)
SWEP.holsteredAng = Angle(30, 0, 0)

--local to head
SWEP.RHPos = Vector(2,-8,10)
SWEP.RHAng = Angle(0,25,0)
--local to rh
SWEP.LHPos = Vector(11.5,0,-12)
SWEP.LHAng = Angle(-65,-15,-180)

SWEP.availableAttachments = {
    agsmag = {
        [1] = {"agsmag0",Vector(0,0,0), {}},
		["noblock"] = true,
    },
	sight = {
		["mountType"] = {"agsmount"},
		["mount"] = {agsmount = Vector(0, 0, 0)},
		["mountAngle"] = Angle(0,0,0),
		["removehuy"] = {},
	},
}

SWEP.StartAtt = {"agsmag","optic13"}
SWEP.ShootAnimMul = 15


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