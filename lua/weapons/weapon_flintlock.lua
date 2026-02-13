SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Heavy Dragoon Pistol"
SWEP.Author = "N/A"
SWEP.Instructions = "This is a muzzle-loaded flintlock pistol that appeared as self-defense weapon and as a military arm in the early 16th century, using black powder and 20mm caliber."
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 1
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/esw/w_english_dragoon_pistol.mdl"

SWEP.WepSelectIcon2 = Material("entities/zcity/flinthook.png")
SWEP.IconOverride = "entities/zcity/flinthook.png"
SWEP.WepSelectIcon2box = false

SWEP.CustomShell = "50ae"
SWEP.EjectPos = Vector(0,5,5)
SWEP.EjectAng = Angle(-80,50,0)

SWEP.weight = 4

SWEP.ScrappersSlot = "Secondary"
SWEP.PPSMuzzleEffect = "muzzleflash_M3" -- shared in sh_effects.lua

SWEP.LocalMuzzlePos = Vector(-8,-0.65,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)
SWEP.OpenBolt = true

SWEP.weaponInvCategory = 2
SWEP.ShellEject = ""
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.NumBullet = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "20mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 65
SWEP.Primary.Sound = {"weapons/awoi/musket_3_fire.wav", 75, 60, 70}
SWEP.SupressedSound = {"weapons/awoi/musket_3_fire.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m1911/handling/m1911_empty.wav", 75, 95, 100, CHAN_WEAPON, 2}
SWEP.Primary.Force = 80
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.Primary.Spread = Vector(0.012, 0.012, 0.012)

SWEP.ReloadTime = 5
SWEP.ReloadSound = "weapons/awoi/pistol_reload.wav"
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-26, 0.6896, 0.7799)
SWEP.RHandPos = Vector(0, -0.5, -1)
SWEP.LHandPos = false
SWEP.Ergonomics = 0.85
SWEP.Penetration = 1
SWEP.SprayRand = {Angle(-0.7, -0.5, 0), Angle(-0.7, 0.5, 0)}

SWEP.AnimShootMul = 4
SWEP.AnimShootHandMul = 2
SWEP.WorldPos = Vector(10, -0.5, -3.5)
SWEP.WorldAng = Angle(0, 180, 0)
SWEP.LocalMuzzleAng = Angle(0, 180, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0.3, -1, -1)
SWEP.attAng = Angle(-0, -0, 0)
SWEP.lengthSub = 20
SWEP.availableAttachments = {}

SWEP.ShockMultiplier = 2

SWEP.DistSound = "toz_shotgun/toz_dist.wav"--SWEP.DistSound = "weapons/awoi/musket_1_fire.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(5, 7, -4)
SWEP.holsteredAng = Angle(-150, -10, 180)

SWEP.shouldntDrawHolstered = false
SWEP.punchmul = 12
SWEP.punchspeed = 6
SWEP.podkid = 2

--local to head
SWEP.RHPos = Vector(12,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.5)
SWEP.LHAng = Angle(5,9,-100)

SWEP.ShootAnimMul = 7

if CLIENT then
	function SWEP:ReloadStart()
		if not self or not IsValid(self:GetOwner()) then return end
		hook.Run("HGReloading", self)
		self:SetHold(self.ReloadHold or self.HoldType)
		--self:GetOwner():SetAnimation(PLAYER_RELOAD)
		if self.ReloadSound then self:GetOwner():EmitSound(self.ReloadSound, 55, 100, 0.8, CHAN_AUTO) end
	end
end

function SWEP:PrimaryShootPost()
	local att = self:GetMuzzleAtt(gun, true)
	local eff = EffectData()
	eff:SetOrigin(att.Pos + att.Ang:Up() * -4 + att.Ang:Forward() * -1)
	eff:SetNormal(att.Ang:Forward())
	eff:SetScale(2)
	util.Effect("eff_jack_rockettrust", eff)
end

function SWEP:AnimHoldPost()
end

function SWEP:DrawPost()
end

-- RELOAD ANIM MUSKET
SWEP.ReloadAnimLH = {
	Vector(-20,10,-15),
	Vector(-20,10,-15),
	Vector(-10,10,-10),
	Vector(4,0,0),
	Vector(4,0,0),
	Vector(3,-2,0),
	Vector(3,-2,0),
	Vector(3,-2,0),
	Vector(2,-2,0),
	Vector(15,0,0),
	Vector(25,0,0),
	Vector(25,0,-1),
	Vector(25,-2,-1),
	Vector(15,-2,-2),
	Vector(15,-2,-2),
	Vector(10,-2,-1),
	Vector(5,0,-1),
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,-15,20),
	Angle(0,-15,30),
	Angle(0,-25,50),
	Angle(0,-35,60),
	Angle(0,-35,40),
	Angle(0,-25,60),
	Angle(0,-25,40),
	Angle(0,-15,20),
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0)
}

SWEP.ReloadAnimWepAng = {
	Angle(0,10,50),
	Angle(30,5,5),
	Angle(40,5,5),
	Angle(55,25,45),
	Angle(55,25,45),
	Angle(40,25,45),
	Angle(3,25,45),
	Angle(5,25,45),
	Angle(3,25,45),
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