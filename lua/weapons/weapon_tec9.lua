SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "TEC-9"
SWEP.Author = "Intratec"
SWEP.Instructions = "Semi-automatic pistol chambered in 9x19 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/tec9/w_tec9.mdl"

SWEP.WepSelectIcon2 = Material("entities/zcity/tec9.png")
SWEP.IconOverride = "entities/zcity/tec9.png"
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(0,3,2)
SWEP.EjectAng = Angle(-80,-90,0)

SWEP.IsPistol = true

SWEP.weight = 1
SWEP.podkid = 0.5

SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(10.703,-0.007,3.073)
SWEP.LocalMuzzleAng = Angle(0.6,0.002,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 32
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 20
SWEP.Primary.Sound = {"hndg_beretta92fs/beretta92_fire1.wav", 75, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 20
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 4.3
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/mp5k/mp5k_magout.wav",
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
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 0.0245, 3.8013)
SWEP.RHandPos = Vector(-5, -0.5, -1)
SWEP.LHandPos = false
SWEP.OpenBolt = true
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7
function SWEP:ModelCreated(model)
	self.bodyGroups = "00020"
	self:SetBodyGroups("00020")
	model:SetBodyGroups("00020")
end

SWEP.WorldPos = Vector(4, -1, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(0, 4, 4)
SWEP.holsteredAng = Angle(25, -70, -90)
SWEP.shouldntDrawHolstered = true

--local to head
SWEP.RHPos = Vector(8,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(4.5,-2,-2.5)
SWEP.LHAng = Angle(-5,0,-90)

local finger1 = Angle(0,0, 0)

function SWEP:AnimHoldPost(model)
	self:BoneSet("l_finger0", Vector(0, 0, 0), Angle(-5, -10, 0))
	self:BoneSet("l_finger02", Vector(0, 0, 0), Angle(0, 25, 0))
	self:BoneSet("l_finger01", Vector(0, 0, 0), Angle(-25, 40, 0))
	self:BoneSet("l_finger1", Vector(0, 0, 0), Angle(-10, -40, 0))
	self:BoneSet("l_finger11", Vector(0, 0, 0), Angle(-10, -40, 0))
	self:BoneSet("l_finger2", Vector(0, 0, 0), Angle(-5, -50, 0))
	self:BoneSet("l_finger21", Vector(0, 0, 0), Angle(0, -10, 0))
end

--RELOAD ANIMS SMG????

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,-2,-2),
	Vector(-15,5,-7),
	Vector(-15,5,-15),
	Vector(0,0,0),
	Vector(0,0,0),
	"fastreload",
	Vector(0,0,0),
	Vector(5,0,5),
	Vector(-2,1,1),
	Vector(-2,1,1),
	Vector(-2,1,1),
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