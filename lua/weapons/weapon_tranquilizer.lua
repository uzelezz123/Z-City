SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Tranquilizer gun"
SWEP.Instructions = "A Tranquilizer gun (or tranq gun) is a handheld firearm whose ammunition is non-lethal, and used to knock enemies unconscious."
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/fc5/weapons/handguns/m9.mdl"

SWEP.WepSelectIcon2 = Material("vgui/inventory/9mmsidearm_5")
SWEP.IconOverride = "vgui/inventory/9mmsidearm_5"

SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(0,2,4)
SWEP.EjectAng = Angle(-70,-85,0)
SWEP.punchmul = 0
SWEP.punchspeed = 0
SWEP.weight = 0.7

SWEP.ScrappersSlot = "Secondary"
SWEP.AutomaticDraw = false

SWEP.weaponInvCategory = 4
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.NumBullet = 1
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Tranquilizer Darts"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 1
SWEP.Primary.Sound = {"sounds_zcity/fn45/close.wav", 75, 90, 100}
SWEP.SupressedSound = {"zcitysnd/sound/weapons/makarov/makarov_suppressed_tp.wav", 65, 110, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 0
SWEP.Primary.Wait = 0.35
SWEP.ReloadTime = 6
SWEP.CockSound = "pwb/weapons/cz75/slideback.wav"
SWEP.ReloadSoundes = {
	"none",
	"weapons/tfa_ins2/usp_tactical/magout.wav",
	"weapons/tfa_ins2/browninghp/magin.wav",
	"pwb/weapons/fnp45/sliderelease.wav",
	"none",
	"none"
}

SWEP.FakeReloadSounds = {
	[0.35] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",

	[0.70] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",

}

SWEP.FakeEmptyReloadSounds = {
	[0.35] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",

	[0.70] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[1.05] = "zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav",
}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl"
local vector_full = Vector(1,1,1)

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(0,-1,0)
SWEP.lmagang2 = Angle(0,0,0)

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-26, -0.0054, 4.2181)
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 0
SWEP.WorldPos = Vector(2.8, -1.2, -0.8)
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LocalMuzzlePos = Vector(8,0,3.6)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)
SWEP.OpenBolt = true
SWEP.DontOnReloadSnd = true

SWEP.handsAng = Angle(-1, 10, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.125, -0.1, 0)
SWEP.lengthSub = 5
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, -3.5)
SWEP.holsteredAng = Angle(0, 20, 70)
SWEP.shouldntDrawHolstered = true
SWEP.Supressor = true
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		["mount"] = Vector(-2.8,0,4.7),
		["mountAngle"] = Angle(0,0,90),
		["noblock"] = true,
		["cannotremove"] = true, -- blebleble
	}
}

SWEP.StartAtt = {"supressor4"}

SWEP.RHandPos = Vector(3, -1, 0)
SWEP.LHandPos = false

--local to head
SWEP.RHPos = Vector(10,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

local weapons_Get = weapons.Get
function SWEP:Shoot(override)
	--self:GetWeaponEntity():ResetSequenceInfo()
	--self:GetWeaponEntity():SetSequence(1)
	if self:GetOwner():IsNPC() then self.drawBullet = true end
	if not self:CanPrimaryAttack() then return false end
	if not self:CanUse() then return false end
	if CLIENT and self:GetOwner() != LocalPlayer() and not override then return false end
	local primary = self.Primary
	if override then self.drawBullet = override end

	if not self.drawBullet or (self:Clip1() == 0 and not override) then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		return false
	end

	if not self:GetOwner():IsNPC() and primary.Next > CurTime() then return false end
	if not self:GetOwner():IsNPC() and (primary.NextFire or 0) > CurTime() then return false end

	primary.Next = CurTime() + primary.Wait
	primary.RealAutomatic = primary.RealAutomatic or weapons_Get(self:GetClass()).Primary.Automatic
	primary.Automatic = primary.RealAutomatic
	self:PrimaryShoot()
	self:PrimaryShootPost()
end

local vector_zero = Vector(0,0,0)
SWEP.ShootAnimMul = 4

local mat = "models/weapons/arccw/ur_m1911/m45_glow"
local mat2 = "models/weapons/tfa_ins2/nova/weapon_m590a1_dm" -- я незнаю как но это выглядит круто
function SWEP:ModelCreated(model)
	local wep = self:GetWeaponEntity()
	self:SetSubMaterial(0, mat2)
	wep:SetSubMaterial(0, mat2)
	self:SetSubMaterial(2, mat)
	wep:SetSubMaterial(2, mat)
end

local vector_one = Vector(1,1,1)
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		wep:ManipulateBoneScale(2,self:Clip1() > 0 and vector_one or vector_zero)
	end
end

local anims = {
	Vector(1,0,0),
	Vector(2,1,-2),
	Vector(6,1,-2),
	Vector(8,1,-2),
	Vector(8,1,-2),
	Vector(6,1,-2),
	Vector(2,1,-2),
	Vector(1,1,-2),
}
function SWEP:AnimationPost()
	local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()),0,1)
	self.sin = 1 - animpos
	if self.sin >= 0.5 then
		self.sin = 1 - self.sin
	else
		self.sin = self.sin * 1
	end
	if self.sin > 0 then
		self.sin = self.sin * 2
		self.sin = math.ease.InOutSine(self.sin)

		local lohsin = math.floor(self.sin * (#anims))
		local lerp = self.sin * (#anims) - lohsin
		self.RHPosOffset = Lerp(lerp,anims[math.Clamp(lohsin,1,#anims)],anims[math.Clamp(lohsin+1,1,#anims)])
		self.inanim = true
	else
		self.inanim = nil
		self.RHPosOffset[1] = 0
		self.RHPosOffset[2] = 0
		self.RHPosOffset[3] = 0
	end

	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		wep:ManipulateBonePosition(3, Vector(0, 0, -3 * self.sin), false)
		wep:ManipulateBonePosition(8, Vector(0, 0, -3 * self.sin), false)
	end
end

function SWEP:ReloadEnd()
	self:InsertAmmo(self:GetMaxClip1() - self:Clip1() + (self.drawBullet ~= nil and not self.OpenBolt and 1 or 0))
	self.ReloadNext = CurTime() + self.ReloadCooldown --я хуй знает чо это
	self:Draw()
end

--RELOAD ANIMS PISTOL

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(-3,-1,-5),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-2,-1,-3),
	"fastreload",
	Vector(0,0,0),
	"reloadend",
	"reloadend",
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(30,-10,0),
	Angle(60,-20,0),
	Angle(70,-40,0),
	Angle(90,-30,0),
	Angle(40,-20,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
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
	Vector(-2,0,0),
	Vector(-1,0,0),
	Vector(0,0,0)
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
	Angle(0,0,0),
	Angle(15,2,20),
	Angle(15,2,20),
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(5,15,15),
	Angle(-5,21,14),
	Angle(-5,21,14),
	Angle(5,20,13),
	Angle(5,22,13),
	Angle(1,22,13),
	Angle(1,21,13),
	Angle(2,22,12),
	Angle(-5,21,16),
	Angle(-5,22,14),
	Angle(-4,23,13),
	Angle(7,22,8),
	Angle(7,12,3),
	Angle(2,6,1),
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