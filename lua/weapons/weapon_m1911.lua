SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Colt M1911"
SWEP.Author = "Colt"
SWEP.Instructions = "Pistol chambered in .45 ACP"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_elite_single.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ur_m1911.mdl"
SWEP.GetDebug = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_m1911.png")
SWEP.IconOverride = "entities/arc9_eft_m1911.png"
SWEP.WepSelectIcon2box = true
SWEP.FakeBodyGroups = "00000000"

SWEP.FakeBodyGroupsPresets = {
	"00000000",
	"00000100",
	"11000000",
	"11000100",
}

SWEP.FakeAttachment = "1"
SWEP.FakePos = Vector(-22, 2.2, 9)
SWEP.FakeAng = Angle(0, 0, 3)
SWEP.AttachmentPos = Vector(4.35,1.5,0.5)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.MagIndex = nil

SWEP.FakeEjectBrassATT = "2"

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}

SWEP.CustomShell = "45acp"
SWEP.EjectAng = Angle(0,0,0)

SWEP.weight = 1
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(-3.5,0,6.5)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".45 ACP"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"weapons/newakm/akmm_fp.wav", 75, 90, 100}
SWEP.SupressedSound = {"m9/m9_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m1911/handling/m1911_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 3.5
SWEP.FakeReloadSounds = {
	[0.3] = "weapons/universal/uni_pistol_draw_01.wav",
	[0.45] = "weapons/tfa_ins2/usp_tactical/magout.wav",
	[0.55] = "weapons/universal/uni_crawl_l_03.wav",
	[0.6] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.7] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
}

SWEP.FakeEmptyReloadSounds = {
	[0.33] = "weapons/tfa_ins2/usp_tactical/magout.wav",
	[0.5] = "weapons/universal/uni_pistol_draw_01.wav",
	[0.65] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.75] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[0.85] = "weapons/m45/m45_boltrelease.wav",
}

local vecfull = Vector(1,1,1)

local function HideMag(model, unhide)
	if !IsValid(model) then return end
	local vec = unhide and vecfull or vector_origin
	model:ManipulateBoneScale(56, vec)
	model:ManipulateBoneScale(57, vec)

	for i = 60, 66 do
		model:ManipulateBoneScale(i, vec)
		model:ManipulateBoneScale(i, vec)
	end
end

local function HideMag2(model, unhide)
	if !IsValid(model) then return end
	local vec = unhide and vecfull or vector_origin
	model:ManipulateBoneScale(54, vec)
	model:ManipulateBoneScale(55, vec)

	for i = 60, 66 do
		model:ManipulateBoneScale(i, vec)
		model:ManipulateBoneScale(i, vec)
	end
end

function SWEP:ModelCreated(model)
	HideMag(model)

	model:SetBodyGroups(self:GetRandomBodygroups() or "0")

	if self.AddModelCreated then
		self:AddModelCreated(model)
	end
end

SWEP.AnimsEvents = {
	["reload_empty"] = {
		[0.2] = function(self)
			local ent = hg.CreateMag( self, Vector(0,-45,-12), self:GetRandomBodygroups() or "0", true)
			for i = 0, ent:GetBoneCount() - 1 do
				ent:ManipulateBoneScale(i, vector_origin)
			end

			ent:ManipulateBoneScale(54, Vector(1,1,1))
			ent:ManipulateBoneScale(55, Vector(1,1,1))

			HideMag2(self:GetWM(),false)
			local phys = ent:GetPhysicsObject()

			if IsValid(phys) then
				phys:AddAngleVelocity(Vector(-250,0,0))
			end
		end,
		[0.4] = function(self)
			HideMag2(self:GetWM(),true)
		end
	},
	["reload"] = {
		[-1] = function(self)
			HideMag2(self:GetWM(), false)
		end,

		[0.2] = function(self)
			HideMag(self:GetWM(), true)
			HideMag2(self:GetWM(), true)
		end,

		[0.7] = function(self)
			HideMag2(self:GetWM(), true)
			HideMag(self:GetWM(), false)
		end
	}
}

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.UseCustomWorldModel = true
SWEP.WorldPos = Vector(11, -0.8, 2.6)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(25, -0.05, 7.34)
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
        ["mount"] = Vector(0.5,0.73,0),
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
SWEP.MagModel = "models/weapons/arccw/c_ur_m1911.mdl"

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(-12.7,0,-2.4)
SWEP.lmagang2 = Angle(90,0,-110)

function SWEP:PostSetupDataTables()
	self:NetworkVar("String",0,"RandomBodygroups")
	if ( CLIENT ) then
		self:NetworkVarNotify( "RandomBodygroups", self.OnVarChanged )
	end
end

function SWEP:OnVarChanged( name, old, new )
	if !IsValid(self:GetWM()) then return end

	self:GetWM():SetBodyGroups(new)
end

function SWEP:InitializePost()
	self:SetRandomBodygroups(self.FakeBodyGroupsPresets[math.random(#self.FakeBodyGroupsPresets)])
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,(self:Clip1() > 0 or self.reload) and 0 or 2.2)
		wep:ManipulateBonePosition(50,Vector(0, 0, -0.8*self.shooanim),false)
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