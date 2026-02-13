SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "M60"
SWEP.Author = "Saco Defense"
SWEP.Instructions = "Machine gun chambered in 7.62x51 mm\n\nRate of fire 550 rounds per minute"
SWEP.Category = "Weapons - Machineguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"
SWEP.WorldModelFake = "models/weapons/zcity/v_mm60.mdl"

SWEP.FakePos = Vector(-12, 2.32, 7.3)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0,-1,-6.5)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.MagIndex = 53


SWEP.FakeVPShouldUseHand = true
SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reload_empty",
}

SWEP.RestPosition = Vector(25, -1, 4)

SWEP.GunCamPos = Vector(6,-17,-4)
SWEP.GunCamAng = Angle(190,0,-90)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 40

SWEP.FakeReloadSounds = {
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
	[0.15] = "weapons/m249/m249_shoulder.wav",
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
SWEP.FakeReloadEvents = {
	[0.73] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			--hg.CreateMag( self )
			self:GetWM():SetBodygroup(1,1)
		end 
	end,
}

function SWEP:PostFireBullet(bullet)
	--self:GetWM():SetBodygroup(1,math.min(self:Clip1()-1,1))
	local owner = self:GetOwner()
	if ( SERVER or self:IsLocal2() ) and owner:OnGround() then
		if IsValid(owner) and owner:IsPlayer() then
			owner:SetVelocity(owner:GetVelocity() - owner:GetVelocity()/0.45)
		end
	end
end

SWEP.FakeMagDropBone = "magazine"

SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/m60.png")
SWEP.IconOverride = "pwb2/vgui/weapons/m60.png"

SWEP.CustomShell = "762x51"
SWEP.CustomSecShell = "m60len"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)

SWEP.CanSuicide = false

SWEP.LocalMuzzlePos = Vector(30.382,0.213,3.722)
SWEP.LocalMuzzleAng = Angle(0.15,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weight = 5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x51 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 65
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 65
SWEP.Primary.Sound = {"homigrad/weapons/rifle/hmg2.wav", 75, 100, 110}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/fnfal/handling/fnfal_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.11
SWEP.ReloadTime = 14.9
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

SWEP.PPSMuzzleEffect = "muzzleflash_m24" -- shared in sh_effects.lua

SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-9, 0.2677, 7.235)
SWEP.RHandPos = Vector(-4, -2, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.ShellEject = "EjectBrass_762Nato"
SWEP.Spray = {}
for i = 1, 200 do
	SWEP.Spray[i] = Angle(-0.05 - math.cos(i) * 0.04, math.cos(i * i) * 0.05, 0) * 2
end

SWEP.ShockMultiplier = 2

--local to head
SWEP.RHPos = Vector(7,-7,5)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(4,-0,-9)
SWEP.LHAng = Angle(-20,0,-90)

local ang1 = Angle(20, -20, 0)
local ang2 = Angle(0, 60, 0)

function SWEP:AnimHoldPost()
	self:BoneSet("l_finger0", vector_origin, ang1)
	self:BoneSet("l_finger02", vector_origin, ang2)
	if not self.reload then
		self:GetWM():SetBodygroup(1,math.min(self:Clip1()-1,1))
	end
end

SWEP.Ergonomics = 0.6
SWEP.OpenBolt = true
SWEP.Penetration = 20
SWEP.WorldPos = Vector(4, 0, 0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, -0.1, 0)
SWEP.AimHands = Vector(0, 1.75, -4.2)
SWEP.lengthSub = 15
SWEP.DistSound = "m249/m249_dist.wav"
SWEP.bipodAvailable = true
SWEP.bipodsub = 15
SWEP.RecoilMul = 0.3

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
	"reloadend",
	Vector(-2,-3,1),
	Vector(-1,-1,0),
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
	Angle(10,4,0),
	Angle(10,2,0),
	Angle(0,15,0),
	Angle(5,15,0),
	Angle(-15,15,0),
	Angle(-15,5,0),
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