SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Winchester 1894"
SWEP.Author = "Winchester"
SWEP.Instructions = "The Winchester Model 1894 is one of the most famous and popular lever action rifles."
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/w_winchester_1894.mdl"

SWEP.WepSelectIcon2 = Material("vgui/icons/ico_winchester1984.png")
SWEP.IconOverride = "vgui/icons/ico_winchester1984.png"

SWEP.CustomShell = "EjectBrass_57"
SWEP.EjectPos = Vector(0,15,2)
SWEP.EjectAng = Angle(0,-90,0)

SWEP.weight = 3
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "RifleShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".357 Magnum"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Damage = 45
SWEP.Primary.Force = 125
SWEP.Primary.Sound = {"weapons/tfa_ins2/winchester_1894/winchester_fp.wav", 80, 90, 100}
SWEP.availableAttachments = {}

SWEP.PenetrationMultiplier = 2
SWEP.PainMultiplier = 2

SWEP.CanSuicide = true

SWEP.ReloadHold = "pistol"

SWEP.LocalMuzzlePos = Vector(33.042,0.45,1.561)
SWEP.LocalMuzzleAng = Angle(0.1,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 1

SWEP.ReloadDrawTime = 0.2
SWEP.ReloadDrawCooldown = 0.3
SWEP.ReloadInsertTime = 0.1
SWEP.ReloadInsertCooldown = 0.1
SWEP.ReloadInsertCooldownFire = 0.1

SWEP.AnimStart_Draw = 0
SWEP.AnimStart_Insert = 0
SWEP.AnimInsert = 0.3
SWEP.AnimDraw = 0.4

SWEP.CockSound = "snds_jack_gmod/ez_weapons/ssr/open.wav"
SWEP.ReloadSound = "weapons/tfa_ins2/winchester_1894/winchester_round_insert_2.wav"

SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 1
SWEP.addSprayMul = 1
SWEP.ReloadTime = 1
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 0.427, 2.5012)
SWEP.RHandPos = Vector(-12, -2, 4)
SWEP.LHandPos = Vector(15, 1, -2)
SWEP.AimHands = Vector(-3, 1.95, -4.2)
SWEP.SprayRand = {Angle(-0.6, -0.1, 0), Angle(-0.7, 0.2, 0)}
SWEP.Ergonomics = 0.75
SWEP.Penetration = 15
SWEP.ZoomFOV = 20
SWEP.WorldPos = Vector(3, -0.4, -2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.handsAng = Angle(-1, 1, 0)
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("decals/perekrestie6.png")
SWEP.localScopePos = Vector(-27.5, 5.575, -0.09)
SWEP.scope_blackout = 400
SWEP.rot = 191
SWEP.FOVMin = 2
SWEP.FOVMax = 10
SWEP.FOVScoped = 40
SWEP.blackoutsize = 2500
SWEP.sizeperekrestie = 2048
SWEP.ShockMultiplier = 1.5

SWEP.attPos = Vector(8,0.4,0)
SWEP.attAng = Angle(-0.1,0.3,0)

if CLIENT then
	function SWEP:DrawHUDAdd()
	end
end

SWEP.lengthSub = 5

local anims = {
	Vector(0,0,0),
	Vector(-1,0,1),
	Vector(-1,0,1),
	Vector(-0.5,0,1.2),
	Vector(0,0,2),
	Vector(4,0,2),
}

function SWEP:AnimationPost()
	local wep = self:GetWeaponEntity()
	local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()),0,1)
	local sin = 1 - animpos
	if sin >= 0.5 then
		sin = 1 - sin
	else
		sin = sin * 1
	end
	if sin > 0 then
		sin = sin * 2
		sin = math.ease.InOutSine(sin)

		local lohsin = math.floor(sin * (#anims))
		local lerp = sin * (#anims) - lohsin
		
		self.inanim = true
		self.RHPosOffset = Lerp(lerp,anims[math.Clamp(lohsin,1,#anims)],anims[math.Clamp(lohsin+1,1,#anims)])
	else
		self.inanim = nil
		self.RHPosOffset[1] = 0
		self.RHPosOffset[2] = 0
		self.RHPosOffset[3] = 0
	end
	if CLIENT and IsValid(wep) then
		wep:ManipulateBonePosition(4,Vector(0*sin , 0, -4.5*sin ),false)
		wep:ManipulateBoneAngles(5,Angle(0 , -40*math.min(sin*2,1), 0),false)
	end
end

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(5, 9.8, -4)
SWEP.holsteredAng = Angle(-30, 180, 0)

SWEP.DistSound = "mosin/mosin_dist.wav"
SWEP.bipodAvailable = true

--local to head
SWEP.RHPos = Vector(3,-4.8,3)
SWEP.RHAng = Angle(-8,0,65)

--local to rh
SWEP.LHPos = Vector(16,0.5,-3.1)
SWEP.LHAng = Angle(-90,-10,-180)

local finger1 = Angle(-0, -30, 0)
local finger2 = Angle(-0, 20, 0)
local finger3 = Angle(0, -25, 0)
local finger4 = Angle(0, -10, 0)

function SWEP:AnimHoldPost(model)
	self:BoneSet("l_finger0", vector_zero, finger1)
	self:BoneSet("l_finger02", vector_zero, finger2)
	self:BoneSet("l_finger1", vector_zero, finger3)
	self:BoneSet("l_finger11", vector_zero, finger4)
	self:BoneSet("l_finger2", vector_zero, finger3)
	self:BoneSet("l_finger21", vector_zero, finger4)
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-2,11,-15),
	Vector(-2,11,-10),
	Vector(-1,-2,-7),
	Vector(-1,-2,-7),
	Vector(-1,-1,-7),
	Vector(-1,-1,-7),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,-25,170),
	Angle(0,-25,170),
	Angle(0,-25,170),
	Angle(0,-25,170),
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(0,5,25),
	Angle(0,5,25),
	Angle(5,5,25),
	Angle(3,5,25),
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