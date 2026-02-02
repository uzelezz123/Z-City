SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Kord 6P50"
SWEP.Author = "Degtyarev plant"
SWEP.Instructions = "Heavy machine gun chambered in 12.7x108 mm\n\nRate of fire 650 rounds per minute"
SWEP.Category = "Weapons - Machineguns"
SWEP.Primary.ClipSize = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12.7x108 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 150
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 40
SWEP.Primary.Sound = {"homigrad/weapons/rifle/loud_awp3.wav", 75, 100, 110}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/fnfal/handling/fnfal_empty.wav", 75, 95, 100, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.09
SWEP.ReloadTime = 6
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/kord/kord_gun.mdl"
SWEP.ScrappersSlot = "Primary"
SWEP.weight = 26

SWEP.CanSuicide = false

SWEP.RestPosition = Vector(-15, -1, 5)

SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/pkm.png")
SWEP.IconOverride = "pwb2/vgui/weapons/pkm.png"

SWEP.CustomShell = "50cal"
SWEP.EjectPos = Vector(0,-20,5)
SWEP.EjectAng = Angle(0,90,0)

SWEP.weaponInvCategory = 1
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-9, -0.0152, 6.2041)
SWEP.RHandPos = Vector(4, -2, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.ShellEject = "EjectBrass_762Nato"
SWEP.SprayRand = {Angle(-0.3, -0.9, 0), Angle(-0.3, 0.9, 0)}

SWEP.LocalMuzzlePos = Vector(36.326,0.068,3.133)
SWEP.LocalMuzzleAng = Angle(-0.2,0.1,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Ergonomics = 0.8
SWEP.OpenBolt = true
SWEP.Penetration = 60
SWEP.WorldPos = Vector(35, -1, -5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.3,-0.04,090)
SWEP.AimHands = Vector(0, 1, -3.5)
SWEP.lengthSub = 15
SWEP.DistSound = "m249/m249_dist.wav"
SWEP.bipodAvailable = true
SWEP.bipodsub = 40

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(-13, -4, -10)
SWEP.holsteredAng = Angle(320, 0, 0)

SWEP.RHPos = Vector(7, -10, 5)
SWEP.RHAng = Angle(0, 0, 0)

SWEP.LHPos = Vector(-5, 2, -4)
SWEP.LHAng = Angle(-40, 90, -90)

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny", "dovetail"},
		["mount"] = Vector(-64, 3.7, -0.7),
	},
	mount = {
		["picatinny"] = {
			"mount1",
			Vector(-64, 2, -0.5),
			{},
			["mountType"] = "picatinny",
		},
		["dovetail"] = {
			"empty",
			Vector(0, 0, 0),
			{},
			["mountType"] = "dovetail",
		},
	}
}
