SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Musket"
SWEP.Author = "N/A"
SWEP.Instructions = "A musket is a muzzle-loaded long gun that appeared as a smoothbore weapon in the early 16th century."
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/esw/w_long_land_pattern.mdl"
SWEP.ScrappersSlot = "Primary"
SWEP.WepSelectIcon2 = Material("entities/zcity/musket.png")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "entities/zcity/musket.png"
SWEP.weight = 8
SWEP.CanSuicide = false
SWEP.weaponInvCategory = 1
SWEP.EjectPos = Vector(0,5,5)
SWEP.EjectAng = Angle(-5,180,0)
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Metallic Ball"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = Vector(0.001, 0.001, 0.001)
SWEP.Primary.Damage = 85
SWEP.Primary.Force = 85
SWEP.NumBullet = 3
SWEP.Primary.Sound = {"weapons/awoi/musket_5_fire.wav", 65, 80, 85}
SWEP.SupressedSound = {"weapons/awoi/musket_5_fire.wav", 65, 80, 85}
SWEP.availableAttachments = {
	--[[barrel = {
		[1] = {"supressor1", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(0.8,0.5,0),
	},]]
}

SWEP.PPSMuzzleEffect = "muzzleflash_M3" -- shared in sh_effects.lua

SWEP.ShockMultiplier = 5
SWEP.ShellEject = ""
SWEP.LocalMuzzlePos = Vector(-38,-0.65,0.5)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.handsAng = Angle(0, 0, 0)
SWEP.handsAng2 = Angle(-3, -2, 0)

SWEP.CockSound = "weapons/tfa_ins2/mosin/mosin_boltforward.wav"
SWEP.ReloadSound = "weapons/awoi/musket_reload.wav"

SWEP.ReloadDrawTime = 0.3
SWEP.ReloadDrawCooldown = 0.4
SWEP.ReloadInsertTime = 0.15
SWEP.ReloadInsertCooldown = 0.15
SWEP.ReloadInsertCooldownFire = 0.15
SWEP.OpenBolt = true

SWEP.Primary.Wait = 0.35
SWEP.NumBullet = 1
SWEP.AnimShootMul = 0.5
SWEP.AnimShootHandMul = 0.5
SWEP.ReloadTime = 7
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-26, 0.7351, 1.3413)
SWEP.RHandPos = Vector(-8, -2, 6)
SWEP.LHandPos = Vector(6, -3, 1)
SWEP.AimHands = Vector(-10, 1.8, -6.1)
SWEP.SprayRand = {Angle(0.02, -0.02, 0), Angle(-0.02, 0.02, 0)}
SWEP.Ergonomics = 0.4
SWEP.Penetration = 100
SWEP.ZoomFOV = 20
SWEP.WorldPos = Vector(9.5, -0.4, -3)
SWEP.WorldAng = Angle(0, 180, 0)
SWEP.LocalMuzzleAng = Angle(0, 180, 0)
SWEP.UseCustomWorldModel = true
SWEP.handsAng = Angle(-6, -1, 0)
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("decals/perekrestie8.png", "smooth")
SWEP.localScopePos = Vector(-21, 3.25, -0.2)
SWEP.scope_blackout = 400
SWEP.maxzoom = 3.5
SWEP.rot = 37
SWEP.FOVMin = 3.5
SWEP.FOVMax = 10
SWEP.huyRotate = 25
SWEP.FOVScoped = 40

SWEP.DistSound = "toz_shotgun/toz_dist.wav"--SWEP.DistSound = "weapons/awoi/musket_1_fire.wav"
SWEP.lengthSub = 25
SWEP.ShootAnimMul = 12
SWEP.punchmul = 12
SWEP.punchspeed = 6
SWEP.podkid = 2

SWEP.Ergonomics = 0.4
SWEP.holsteredPos = Vector(-14, -4, -12)
SWEP.holsteredAng = Angle(320, 0, 0)

SWEP.attPos = Vector(0.5,-3.5,75)
SWEP.attAng = Angle(-0.1,.4,0)

SWEP.bipodAvailable = false

--local to head
SWEP.RHPos = Vector(3,-3.8,3)
SWEP.RHAng = Angle(-8,-30,65)

--local to rh
SWEP.LHPos = Vector(17,0,-3.5)
SWEP.LHAng = Angle(-90,-0,-180)

local finger1 = Angle(10, -20, 0)
local finger2 = Angle(-0, 90, 0)
local finger3 = Angle(0, -25, 0)
local finger4 = Angle(0, -10, 0)

function SWEP:AnimHoldPost(model)
	if self.reload then return end

end

function SWEP:PrimaryShootPost()
	local att = self:GetMuzzleAtt(gun, true)
	local eff = EffectData()
	eff:SetOrigin(att.Pos + att.Ang:Up() * -82 + att.Ang:Forward() * -2)
	eff:SetNormal(att.Ang:Forward())
	eff:SetScale(2)
	util.Effect("eff_jack_rockettrust", eff)
end

local anims = {
	Vector(0,0,0),
	Vector(1,0,1),
	Vector(2,1,2),
	Vector(3,2,0),
	Vector(4,3,0),
	Vector(4,4,-1),
}

local fingang = Angle(-10, -25, 0)
function SWEP:AnimationPost()
	self:BoneSet("l_finger0", vector_origin, fingang)

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
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-2,0,6),
	Vector(-2,0,6),
	Vector(-1,-2,7),
	Vector(0,-2,8),
	Vector(0,-2,8),
	Vector(0,-2,7),
	Vector(0,0,5),
	Vector(-2,0,6),
	Vector(-2,0,6),
	Vector(-1,-2,7),
	Vector(0,-2,8),
	Vector(0,-2,8),
	Vector(0,-2,7),
	Vector(0,0,5),
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,-25,90),
	Angle(0,-25,90),
	Angle(0,-25,160),
	Angle(0,-25,160),
	Angle(0,-25,160),
	Angle(0,-25,160),
	Angle(0,-25,90),
	Angle(0,-25,90),
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,10,50),
	Angle(0,25,45),
	Angle(0,25,45),
	Angle(5,25,45),
	Angle(3,25,45),
	Angle(0,25,45),
	Angle(0,25,45),
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