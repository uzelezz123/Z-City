SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "TT-33"
SWEP.Author = "Tula Arms Plant"
SWEP.Instructions = "An semi-automatic Soviet pistol chambered in 7.62x25 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_elite_single.mdl"
SWEP.WorldModelFake = "models/weapons/zcity/c_tt33.mdl"
-- SWEP.GetDebug = true
SWEP.FakeScale = 1.2

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_tt33.png")
SWEP.IconOverride = "entities/arc9_eft_tt33.png"
SWEP.WepSelectIcon2box = true

SWEP.FakeAttachment = "muzzle"
SWEP.FakePos = Vector(-15, 2.5, 9)
SWEP.FakeAng = Angle(-1, 0, 0)
SWEP.AttachmentPos = Vector(1.35,1.5,0.5)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.MagIndex = nil

SWEP.FakeEjectBrassATT = "shell"

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reloadempty",
}

SWEP.CustomShell = "10mm"
SWEP.EjectAng = Angle(0,0,0)

SWEP.weight = 1
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(-1,0.5,7.5)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x25 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 35
SWEP.Primary.Sound = {"weapons/easternfront/tt33/tt33_fp - copy (2).wav", 75, 90, 100}
SWEP.SupressedSound = {"m9/m9_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m1911/handling/m1911_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 35
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 3.5
SWEP.FakeReloadSounds = {
	[0.3] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",
	[0.70] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
}

SWEP.FakeEmptyReloadSounds = {
	[0.3] = "weapons/tfa_ins2/usp_tactical/magout.wav",
	[0.5] = "weapons/universal/uni_pistol_draw_01.wav",
	[0.65] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.75] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[0.9] = "weapons/m45/m45_boltrelease.wav",
}

SWEP.AnimsEvents = {
	["reload_empty"] = {
		[0.2] = function(self)
			local ent = hg.CreateMag( self, Vector(0,-45,-12), "0", true)
			local phys = ent:GetPhysicsObject()

			if IsValid(phys) then
				phys:AddAngleVelocity(Vector(-250,0,0))
			end
		end,
	},
}

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.UseCustomWorldModel = true
SWEP.WorldPos = Vector(2, -0.8, 2.6)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -0.0576, 8.208) -- use hg_setzoompos to set correct zoompos
SWEP.RHandPos = Vector(-13.5, 0, 3)
SWEP.LHandPos = false
SWEP.attPos = Vector(0, -2, -0.5)
SWEP.attAng = Angle(0, 0, 0)
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, 1, -7)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
        ["mount"] = Vector(-1.2,0.73,0),
    }
}

--local to head
SWEP.RHPos = Vector(12,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

SWEP.ShootAnimMul = 3
SWEP.SightSlideOffset = 0.8

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 50
SWEP.FakeMagDropBone = "vm_mag"

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(-12.7,0,-2.4)
SWEP.lmagang2 = Angle(90,0,-110)

local magvec = Vector(0, -0.1, 0)
function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 1)
		wep:ManipulateBonePosition(97, Vector(0, 1.5 * self.shooanim, 0), false)
		wep:ManipulateBonePosition(95, magvec, false)
	end
end

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(6,0,5),
	Angle(15,0,14),
	Angle(16,0,16),
	Angle(4,0,12),
	Angle(-6,0,-2),
	Angle(-15,7,-15),
	Angle(-16,18,-35),
	Angle(-17,17,-42),
	Angle(-18,16,-44),
	Angle(-14,10,-46),
	Angle(-2,2,-4),
	Angle(0,0,0)
}