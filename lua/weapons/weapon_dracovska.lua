SWEP.Base = "weapon_vpo136"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "VSKA Draco"
SWEP.Author = "Century International Arms U.S"
SWEP.Instructions = "DRACO-Pistol chambered in 7.62x39 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 1
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ur_ak.mdl"
SWEP.FakeBodyGroups = "06C12195210000"
SWEP.FakePos = Vector(-12, 2.52, 5.5)
SWEP.FakeAng = Angle(-1, 0.25, 5.5)
SWEP.AttachmentPos = Vector(1.5,2.7,-27.8)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor1", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(-2,0.2,0),
		["mountAngle"] = Angle(0,0,0)
	},
	sight = {
		["mountType"] = {"picatinny", "dovetail"},
		["mount"] = {["dovetail"] = Vector(-25, 2.2, -0.45),["picatinny"] = Vector(-24.5, 2.65, -0.22)},
	},
	mount = {
		["picatinny"] = {
			"mount3",
			Vector(-22.5, 0, -1.26),
			{},
			["mountType"] = "picatinny",
		},
		["dovetail"] = {
			"empty",
			Vector(0, 0, 0),
			{},
			["mountType"] = "dovetail",
		},
	},
	underbarrel = {},
	grip = {},
}

SWEP.IsPistol = false
SWEP.PistolKinda = true
SWEP.bigNoDrop = true
SWEP.punchmul = 2
SWEP.punchspeed = 1

function SWEP:ModelCreated(model)
	model:ManipulateBoneScale(57, vector_origin)
	model:ManipulateBoneScale(58, vector_origin)
	model:SetBodyGroups(self.FakeBodyGroups)
end

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 50
SWEP.Primary.Sound = {"homigrad/weapons/rifle/fal.wav", 85, 90, 100}
SWEP.SupressedSound = {"ak74/ak74_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/ak47/handling/ak47_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 30
SWEP.Primary.Wait = 0.12
SWEP.ReloadTime = 4.8

SWEP.WepSelectIcon2 = Material("entities/zcity/drako.png")
SWEP.IconOverride = "entities/zcity/drako.png"
SWEP.ScrappersSlot = "Primary"
SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny", "dovetail"},
		["mount"] = {["dovetail"] = Vector(-15, 2.5, -0.1),["picatinny"] = Vector(-22, 2.6, -0.05)},
	},
	mount = {
		["picatinny"] = {
			"mount3",
			Vector(-20, -0.1, -1),
			{},
			["mountType"] = "picatinny",
		},
		["dovetail"] = {
			"empty",
			Vector(0, 0, 0),
			{},
			["mountType"] = "dovetail",
		},
	},
	barrel = {
		[1] = {"supressor1", Vector(0,0.4,0), {}},
		[2] = {"supressor8", Vector(0,0,0), {}},
		["mount"] = Vector(-10,-0.1,-0.1),
		["mountAngle"] = Angle(0,-1.5,0)
	},
	grip = {
		["mount"] = Vector(-14.2,-0.1,-9),
		["mountType"] = "ak74u"
	},
}

SWEP.LocalMuzzlePos = Vector(14,-0.2,2.741)
SWEP.LocalMuzzleAng = Angle(-0.4,0,0)
SWEP.ZoomPos = Vector(0, -0.0054, 5.2)

SWEP.Ergonomics = 0.9
SWEP.attPos = Vector(0.25, -2.1, 28)
SWEP.attAng = Angle(0, 0.4, 0)

SWEP.weight = 2.5
SWEP.addweight = -1.5
SWEP.podkid = 0.2
SWEP.animposmul = 1.5