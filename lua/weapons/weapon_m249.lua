SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "M249"
SWEP.Author = "FN Herstal"
SWEP.Instructions = "Machine gun chambered in 5.56x45 mm\n\nRate of fire 775 rounds per minute"
SWEP.Category = "Weapons - Machineguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"
SWEP.WorldModelFake = "models/c_mach_ins2_m249.mdl"
SWEP.FakeAttachment = "1"
SWEP.FakeScale = 1
SWEP.FakePos = Vector(-11.5, 3.53, 9.45)
SWEP.FakeAng = Angle(0.19, 0.04, 0)
SWEP.AttachmentPos = Vector(-0,0.7,0.2)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.FakeEjectBrassATT = "2"




SWEP.FakeVPShouldUseHand = true
SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reload_empty",
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 35

SWEP.FakeReloadSounds = {
	--[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.25] = "weapons/m249/m249_coveropen.wav",
	[0.4] = "weapons/m249/m249_magout_full.wav",
	[0.63] = "weapons/m249/m249_shoulder.wav",
	[0.7] = "weapons/m249/m249_magin.wav",
	[0.75] = "weapons/m249/m249_beltpullout.wav",
	[0.77] = "weapons/m249/m249_fetchmag.wav",
	[0.94] = "weapons/m249/m249_coverclose.wav",
	[1.04] = "weapons/m249/m249_shoulder.wav"
}

SWEP.FakeEmptyReloadSounds = {
	[0.16] = "weapons/m249/m249_shoulder.wav",
	[0.25] = "weapons/m249/m249_boltback.wav",
	[0.28] = "weapons/m249/m249_boltrelease.wav",
	--[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.45] = "weapons/m249/m249_coveropen.wav",
	[0.54] = "weapons/m249/m249_magout.wav",
	[0.73] = "weapons/m249/m249_shoulder.wav",
	[0.8] = "weapons/m249/m249_magin.wav",
	[0.83] = "weapons/m249/m249_beltpullout.wav",
	[0.85] = "weapons/m249/m249_fetchmag.wav",
	[1] = "weapons/m249/m249_coverclose.wav",
	[1.04] = "weapons/m249/m249_shoulder.wav"
}
SWEP.MagModel = "models/weapons/zcity/w_glockmag.mdl"

local function UpdateVisualBullets(mdl,count)
	for i = 1, 16 do
		local boneid = 118 + i
		mdl:ManipulateBoneScale(boneid,i <= count and Vector(1,1,1) or Vector(0,0,0))
	end
end
SWEP.FakeReloadEvents = {
	[0.73] = function( self )
		if CLIENT then
			UpdateVisualBullets(self:GetWM(),20)
		end
	end,
}

SWEP.RestPosition = Vector(10, -1, 4)

function SWEP:PostFireBullet(bullet)
	if CLIENT then
		self:PlayAnim("base_fire_3",1.5,nil,false)
		UpdateVisualBullets(self:GetWM(),self:Clip1())
	end
	local owner = self:GetOwner()
	if ( SERVER or self:IsLocal2() ) and owner:OnGround() then
		if IsValid(owner) and owner:IsPlayer() then
			owner:SetVelocity(owner:GetVelocity() - owner:GetVelocity()/0.45)
		end
	end
	SlipWeapon(self, bullet)
end

SWEP.FakeMagDropBone = "magazine"

SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/m249paratrooper.png")
SWEP.IconOverride = "pwb2/vgui/weapons/m249paratrooper.png"

--"models/weapons/v_m249.mdl"
SWEP.CustomShell = "556x45"
SWEP.CustomSecShell = "m249len"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)

SWEP.CanSuicide = false

SWEP.ScrappersSlot = "Primary"

SWEP.weight = 5

SWEP.LocalMuzzlePos = Vector(23.632,0.400,5.860)
SWEP.LocalMuzzleAng = Angle(0.3,0.02,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.ShockMultiplier = 3

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 44
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 44
SWEP.Primary.Sound = {"m249/m249_fp.wav", 75, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/fnfal/handling/fnfal_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.06
SWEP.ReloadTime = 12.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb/weapons/m249/coverup.wav",
	"none",
	"none",
	"pwb/weapons/m249/boxout.wav",
	"none",
	"pwb/weapons/m249/boxin.wav",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "muzzleflash_m14" -- shared in sh_effects.lua

SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-9, 0.3547, 7.7015)
SWEP.RHandPos = Vector(-5, -2, 0)
SWEP.LHandPos = Vector(7, -2, -2)
--local to head
SWEP.RHPos = Vector(7,-7,5)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(8.5,-2,-6)
SWEP.LHAng = Angle(-20,0,-90)
SWEP.Spray = {}
for i = 1, 150 do
	SWEP.Spray[i] = Angle(-0.03 - math.cos(i) * 0.02, math.cos(i * i) * 0.04, 0) * 2
end

SWEP.Ergonomics = 0.75
SWEP.OpenBolt = true
SWEP.Penetration = 15
SWEP.WorldPos = Vector(4, -0.5, 1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, -1, 0)
SWEP.attAng = Angle(0, -0.2, 0)
SWEP.AimHands = Vector(0, 1.65, -3.65)
SWEP.lengthSub = 15
SWEP.DistSound = "m249/m249_dist.wav"
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(-2,-0.2+1,0),
	},
	sight = {
		["mount"] = Vector(-21, 1.9, -0.15),
		["mountType"] = "picatinny",
	}
}

local vector_one = Vector(1,1,1)
local vector_zero = Vector(0,0,0)

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 3)
		--wep:ManipulateBonePosition(44, Vector(0, 0, -1*self.shooanim), false)
		--self:GetWM():SetBodygroup(0,0)
	end
end

SWEP.punchmul = 15
SWEP.punchspeed = 0.11
SWEP.podkid = 0.05

SWEP.RecoilMul = 0.1

SWEP.bipodAvailable = true
SWEP.bipodsub = 15

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-4,-6,1),
	Vector(0,-7,-5),
	Vector(0,-9,1),
	Vector(-4,-6,1),
	Vector(-4,2,2),
	Vector(-4,4,2),
	Vector(-4,15,-15),
	Vector(-4,4,2),
	Vector(-4,4,2),
	Vector(-4,2,2),
	Vector(0,-9,1),
	Vector(0,-7,-5),
	Vector(-4,-6,1),
	Vector(-2,-3,1),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,0,0),
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,190),
	Angle(0,0,190),
	Angle(0,0,190),
	Angle(0,0,120),
	Angle(0,0,190),
	Angle(0,0,190),
	Angle(0,0,190),
	Angle(0,0,0),
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(10,0,0),
	Angle(10,0,0),
	Angle(0,15,0),
	Angle(5,15,0),
	Angle(-15,15,0),
	Angle(-15,15,0),
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