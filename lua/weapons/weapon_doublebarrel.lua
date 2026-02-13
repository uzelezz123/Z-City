SWEP.Base = "weapon_doublebarrel_short"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "IZh-43" -- сам ты дабл баррел
SWEP.Author = "Izhevsk Mechanical Plant"
SWEP.Instructions = "IZh-43 is a side by side smoothbore shotgun chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"

SWEP.WepSelectIcon2 = Material("entities/tfa_ins2_doublebarrel.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/tfa_ins2_doublebarrel.png"

SWEP.SprayRand = {Angle(-0.2, -0.4, 0), Angle(-0.4, 0.4, 0)}

SWEP.cameraShakeMul = 1
SWEP.FakeBodyGroups = "0000"
SWEP.addSprayMul = 1
SWEP.ScrappersSlot = "Primary"
SWEP.CustomShell = "12x70"
SWEP.weight = 4
SWEP.addweight = 2
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 16
SWEP.Primary.Spread = Vector(0.01, 0.01, 0.01)
SWEP.Primary.Force = 12
SWEP.Primary.Sound = {"weapons/tfa_ins2/doublebarrel/doublebarrel_fire.wav", 80, 100, 75}
SWEP.Primary.Wait = 0
SWEP.OpenBolt = true

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
		self:GetWM():SetPoseParameter("long",1)
	end
end

SWEP.CanEpicRun = false

SWEP.LocalMuzzlePos = Vector(37.893,0.388,1.648)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.RHandPos = Vector(-15, -2, 4)
SWEP.LHandPos = Vector(-15, -2, 4)

SWEP.IsPistol = false
SWEP.podkid = 0.5
SWEP.punchmul = 4
SWEP.punchspeed = 1
SWEP.animposmul = 2

SWEP.AnimShootMul = 0.5
SWEP.AnimShootHandMul = 0.2

SWEP.attPos = Vector(0, 0.2, 0)
SWEP.attAng = Angle(0, 0, 0)

SWEP.Ergonomics = 0.8

SWEP.ZoomPos = Vector(-26, 0.3414, 2.4255)
--SWEP.IsPistol = false
--local to head
SWEP.RHPos = Vector(3,-4.5,3.5)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(15,-0.9,-3.3)
SWEP.LHAng = Angle(-110,-90,-90)


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