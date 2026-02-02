SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "PTRD Fun Auto"
SWEP.Author = "Dementiev Alexander Andreevich"
SWEP.Instructions = "Degtyaryov single-shot anti-tank rifle of 1941 pattern"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/gleb/w_ptrd.mdl"
SWEP.ScrappersSlot = "Primary"
SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_ptrd")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "vgui/wep_jack_hmcd_ptrd"
SWEP.weight = 16
SWEP.CanSuicide = false
SWEP.weaponInvCategory = 1
SWEP.EjectPos = Vector(0,5,5)
SWEP.EjectAng = Angle(-5,180,0)
SWEP.AutomaticDraw = true
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 1000
SWEP.Primary.DefaultClip = 1000
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "14.5x114mm B32"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Damage = 120
SWEP.Primary.Force = 120
SWEP.Primary.Sound = {"weapons/ptrd/ptrsfire.wav", 65, 90, 100}
SWEP.SupressedSound = {"weapons/ptrd/ptrsfire.wav", 65, 90, 100}
SWEP.availableAttachments = {
	--[[barrel = {
		[1] = {"supressor1", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(0.8,0.5,0),
	},]]
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mshotgun" -- shared in sh_effects.lua

SWEP.ShockMultiplier = 5

SWEP.LocalMuzzlePos = Vector(74.973,-0.631,4.023)
SWEP.LocalMuzzleAng = Angle(0.1,-0.,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.handsAng = Angle(0, 0, 0)
SWEP.handsAng2 = Angle(-3, -2, 0)

SWEP.CockSound = "snd_jack_hmcd_boltcycle.wav"

SWEP.ReloadSound = "weapons/mosin/round-insert01.wav"

SWEP.ReloadDrawTime = 0.3
SWEP.ReloadDrawCooldown = 0.4
SWEP.ReloadInsertTime = 0.15
SWEP.ReloadInsertCooldown = 0.15
SWEP.ReloadInsertCooldownFire = 0.15
SWEP.OpenBolt = true

SWEP.Primary.Wait = 0.15
SWEP.NumBullet = 1
SWEP.AnimShootMul = 0.8
SWEP.AnimShootHandMul = 4
SWEP.ReloadTime = 2
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 2.2984, 5.5026)
SWEP.RHandPos = Vector(-8, -2, 6)
SWEP.LHandPos = Vector(6, -3, 1)
SWEP.AimHands = Vector(-10, 1.8, -6.1)
SWEP.SprayRand = {Angle(0.02, -0.02, 0), Angle(-0.02, 0.02, 0)}
SWEP.Ergonomics = 0.4
SWEP.Penetration = 100
SWEP.ZoomFOV = 20
SWEP.WorldPos = Vector(4.5, -1, -0.2)
SWEP.WorldAng = Angle(0, 0, 0)
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
SWEP.OpenBolt = true

SWEP.DistSound = "weapons/ptrd/ptrsfire.wav"

SWEP.lengthSub = 45

SWEP.Ergonomics = 0.4
SWEP.holsteredPos = Vector(-16, -3, -24)
SWEP.holsteredAng = Angle(320, 0, 0)

SWEP.attPos = Vector(0.5,-3.5,75)
SWEP.attAng = Angle(-0.1,.4,0)

SWEP.bipodAvailable = true
SWEP.bipodsub = 46

function SWEP:PrimaryShootPost()
	if CLIENT then return end
	if self.bipodPlacement then return end
	local owner = self:GetOwner()
	local char = hg.GetCurrentCharacter(owner)
	if not char:IsRagdoll() then
		hg.AddForceRag(owner, 2, owner:EyeAngles():Forward() * -10000, 0.5)
		hg.AddForceRag(owner, 0, owner:EyeAngles():Forward() * -10000, 0.5)

		hg.LightStunPlayer(owner,1)
	end
	
	char:GetPhysicsObjectNum(0):SetVelocity(char:GetVelocity() + owner:EyeAngles():Forward() * -1000)
end

local anims = {
	Vector(0,0,0),
	Vector(1,0,1),
	Vector(2,1,2),
	Vector(3,2,0),
	Vector(4,3,0),
	Vector(4,4,-1),
}

function SWEP:AnimationPost()
	self:BoneSet("l_finger0", Vector(0, 0, 0), Angle(-10, -25, 0))

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
	Vector(-2,11,-15),
	Vector(-2,11,-10),
	Vector(-1,-7,-7),
	Vector(-1,-7,-7),
	Vector(-1,-5,-7),
	Vector(-1,-5,-7),
	Vector(-1,-5,-3),
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