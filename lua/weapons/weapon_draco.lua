SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Micro Draco"
SWEP.Author = "ROMARM via Regia Autonomă pentru producţia de Tehnică Militară (RATMIL), Cugir"
SWEP.Instructions = "Shortened DRACO-Pistol chambered in 7.62x39 mm\n\nALT+E to change stance (+walk,+use)"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/draco/w_draco.mdl"

SWEP.WepSelectIcon2 = Material("entities/zcity/drako.png")
SWEP.IconOverride = "entities/zcity/drako.png"

SWEP.CustomShell = "762x39"
--SWEP.EjectPos = Vector(0,10,5)
--SWEP.EjectAng = Angle(-55,80,0)

SWEP.weight = 3
SWEP.addweight = -1.5
SWEP.podkid = 0.25
SWEP.animposmul = 1.5
SWEP.PistolKinda = true

SWEP.IsPistol = false
SWEP.hold_type = "ak_hold"

SWEP.ScrappersSlot = "Primary"

SWEP.ShockMultiplier = 2

SWEP.LocalMuzzlePos = Vector(13.491,-0.022,2.547)
SWEP.LocalMuzzleAng = Angle(-0.7,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

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
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/akp/ak47/ak47_magout.wav",
	"none",
	"weapons/tfa_ins2/akp/ak47/ak47_magin.wav",
	"none",
	"weapons/tfa_ins2/akp/aks74u/aks_boltback.wav",
	"weapons/tfa_ins2/akp/aks74u/aks_boltrelease.wav",
	"none",
	"none",
	"none"
}

function SlipWeapon(self, bullet)
	if CLIENT then return end
	local owner = self:GetOwner()
	local force = -bullet.Dir * bullet.Force * 1
	local pos = self:WorldModel_Transform(true)
	if (owner.posture == 7 or owner.posture == 8) then
		if math.random(5) == 1 then
			timer.Simple(0.05,function()
				owner:DropWeapon(self, nil, force)
				self:SetPos(pos)
				owner:SelectWeapon(owner:GetWeapon("weapon_hands_sh"))
				//owner:ChatPrint("Your hand hurts really bad.")
				if owner.organism then
					//owner.organism.pain = owner.organism.pain + 20
					local dmgInfo = DamageInfo()
					dmgInfo:SetDamage(0.5)
					dmgInfo:SetDamageType(DMG_CLUB)
					hg.organism.input_list.rarmdown(owner.organism, 1, dmgInfo:GetDamage(), dmgInfo, owner:LookupBone("ValveBiped.Bip01_R_Forearm"), vector_up)
				end
			end)
		end
	end
end

function SWEP:PostFireBullet(bullet)
	SlipWeapon(self, bullet)
end

SWEP.PPSMuzzleEffect = "muzzleflash_pistol_rbull" -- shared in sh_effects.lua

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-30, -0.0497, 4.1614)
SWEP.RHandPos = Vector(-5, -1, -1)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.1, -0.2, 0), Angle(-0.2, 0.2, 0)}
SWEP.Ergonomics = 0.8
SWEP.Penetration = 15
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 0.1
SWEP.WorldPos = Vector(5, -1, -1.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attAng = Angle(-0.05, 0.6, 0)
SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny", "dovetail"},
		["mount"] = {["dovetail"] = Vector(-17, 2.5, -0.1),["picatinny"] = Vector(-15, 2.55, 0)},
	},
	mount = {
		["picatinny"] = {
			"mount3",
			Vector(-11, -0.15, -1.05),
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
		[1] = {"supressor1", Vector(0,0,0), {}},
		[2] = {"supressor8", Vector(0,0,0), {}},
		["mount"] = Vector(-4.8,0.4,0.2),
	}
}

function SWEP:ModelCreated(model)
	/*if SERVER then
		if math.random(100) <= 5 then
			net.Start("gdraco")
			net.WriteEntity(self)
			net.Broadcast()
			self.WorldModel = "models/draco/w_gdraco.mdl"
			self.ViewModel = "models/draco/w_gdraco.mdl"
		end
	end*/

	model:SetBodyGroups("01")
end

if SERVER then
	util.AddNetworkString("gdraco")
else
	net.Receive("gdraco", function(len)
		local self = net.ReadEntity()
		self.WorldModel = "models/draco/w_gdraco.mdl"
		self.ViewModel = "models/draco/w_gdraco.mdl"
	end)
end
SWEP.bigNoDrop = true
SWEP.punchmul = 3
SWEP.punchspeed = 1

local recoilAng1 = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
local recoilAng2 = {Angle(-0.015, -0.015, 0), Angle(-0.025, 0.015, 0)}
if SERVER then
	util.AddNetworkString("send_huyhuy2")
else
	net.Receive("send_huyhuy2", function(len)
		local self = net.ReadEntity()
		local twohands = net.ReadBool()
		--print(twohands)
		self.HoldType = twohands and "ar2" or "revolver"
		self.SprayRand = twohands and recoilAng1 or recoilAng2
		self.AnimShootHandMul = twohands and 0.25 or 1

		self.RHPos = not twohands and Vector(9,-5,3) or Vector(3,-5.5,3.5)
		self.RHAng = not twohands and Angle(0,0,90) or Angle(0,-5,90)

		self.LHPos = not twohands and Vector(-1,-2,-3) or Vector(14,0.1,-3.9)
		self.LHAng = not twohands and Angle(-0,0,-100) or Angle(-110,-90,-90)
	end)
end

function SWEP:Step()
	self:CoreStep()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if hg.KeyDown(owner, IN_WALK) and hg.KeyDown(owner, IN_USE) and not self.reload then
		if not self.huybut then
			if SERVER then
				local twohands = self.HoldType == "revolver"
				self.HoldType = twohands and "ar2" or "revolver"
				self.SprayRand = twohands and recoilAng1 or recoilAng2
				self.AnimShootHandMul = twohands and 0.25 or 1
				self.RHPos = not twohands and Vector(9,-5,3) or Vector(3,-5.5,3.5)
				self.RHAng = not twohands and Angle(0,0,90) or Angle(0,-5,90)
		
				self.LHPos = not twohands and Vector(-1,-2,-3) or Vector(14,0.1,-3.9)
				self.LHAng = not twohands and Angle(-0,0,-100) or Angle(-110,-90,-90)
				net.Start("send_huyhuy2")
				net.WriteEntity(self)
				net.WriteBool(twohands)
				net.Broadcast()
			end

			self.huybut = true
		end
	else
		self.huybut = false
	end
end

function SWEP:ReloadStart()
	if not IsValid(self:GetOwner()) then return end
	local twohands = self.HoldType == "revolver"
	self.OldHoldType = self.HoldType
	self.HoldType = "ar2"
	if SERVER then
		net.Start("send_huyhuy2")
			net.WriteEntity(self)
			net.WriteBool(true)
		net.Broadcast()
	end
end

function SWEP:ReloadEnd()
	self:InsertAmmo(self:GetMaxClip1() - self:Clip1() + (self.drawBullet ~= nil and not self.OpenBolt and 1 or 0))
	self.ReloadNext = CurTime() + self.ReloadCooldown --я хуй знает чо это
	self:Draw()
	local Fuck = self.HoldType == self.OldHoldType
	self.HoldType = self.OldHoldType or self.HoldType
	if SERVER then
		net.Start("send_huyhuy2")
			net.WriteEntity(self)
			net.WriteBool(Fuck)
		net.Broadcast()
	end
end

SWEP.lengthSub = 10
SWEP.DistSound = "ak74/ak74_dist.wav"
SWEP.holsteredPos = Vector(5, 7, -4)
SWEP.holsteredAng = Angle(-150, -10, 180)

SWEP.RHPos = Vector(9,-5,3)
SWEP.RHAng = Angle(0,0,90)

SWEP.LHPos = Vector(-1,-2,-3)
SWEP.LHAng = Angle(-0,0,-100)

--RELOAD ANIMS SMG????

local finger1 = Angle(0,-20,0)
local finger2 = Angle(-0, 40, 0)

local finger11 = Angle(-0,20,0)
local finger21 = Angle(-0, 10, 0)

local angZero = Angle(0, 0, 0)

function SWEP:AnimHoldPost(model)
	local th = self.HoldType == "revolver"
	if th then return end
	self:BoneSet("l_finger1", vector_zero, finger11)
	self:BoneSet("l_finger2", vector_zero, finger11)
end

SWEP.ProceduralMagMethod = 0
SWEP.ProceduralMagID = 1
SWEP.ProceduralMagSets = {
	["remove"] = 0,
	["return"] = 1
}
-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(.5,2.5,-7),
	Vector(.5,2.5,-7),
	Vector(.5,2.5,-7),
	"removemag",
	Vector(-6,7,-9),
	Vector(-7,1,-15),
	Vector(-7,1,-15),
	"returnmag",
	Vector(-13,5,-5),
	Vector(.5,2.5,-7),
	Vector(.5,2.5,-7),
	Vector(.5,2.5,-7),
	"fastreload",
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
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
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,1),
	Vector(8,1,2),
	Vector(8,2.5,-3),
	Vector(8,2.5,-3),
	Vector(8,2.5,-3),
	Vector(3,2.5,-3),
	Vector(3,2.5,-2),
	Vector(0,4,-1),
	"reloadend",
	Vector(0,5,0),
	Vector(-2,2,1),
	Vector(0,0,0),
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-80,0,110),
	Angle(-20,0,110),
	Angle(-30,0,110),
	Angle(-20,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-20,0,45),
	Angle(-2,0,-3),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
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
	Angle(20,-10,-60),
	Angle(20,0,-60),
	Angle(20,0,-60),
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-15,15,17),
	Angle(-14,14,22),
	Angle(-10,15,24),
	Angle(12,14,23),
	Angle(11,15,20),
	Angle(12,14,19),
	Angle(11,14,20),
	Angle(7,9,21),
	Angle(0,14,-21),
	Angle(0,15,-22),
	Angle(0,18,-23),
	Angle(0,25,-22),
	Angle(-12,24,-25),
	Angle(-15,25,-23),
	-Angle(5,2,2),
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