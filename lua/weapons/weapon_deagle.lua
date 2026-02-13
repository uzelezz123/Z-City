SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Desert Eagle"
SWEP.Author = "Magnum Research/Israel Weapon Industries"
SWEP.Instructions = "Pistol chambered in .50 Magnum"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ud_deagle.mdl"
SWEP.FakeAttachment = "1"
SWEP.FakePos = Vector(-16, 2.55, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0.05,-0.3,0)
SWEP.AttachmentAng = Angle(90,0,0)
SWEP.FakeMagDropBone = 48

--PrintAnims(Entity(1):GetActiveWeapon():GetWM())
SWEP.FakeVPShouldUseHand = true
SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}

function SWEP:PostSetupDataTables()
	self:NetworkVar("Int",0,"DeagleSkin")
	self:NetworkVar("Int",1,"DeagleBodygroup")
	
	if ( CLIENT ) then
		self:NetworkVarNotify( "DeagleSkin", self.OnVarChanged )
		self:NetworkVarNotify( "DeagleBodygroup", self.OnVarChanged )
	end
end

function SWEP:OnVarChanged( name, old, new )
	if !IsValid(self:GetWM()) then return end
	
	if name == "DeagleBodygroup" then
		self:GetWM():SetBodygroup(4,new)
	elseif name == "DeagleSkin" then
		self:GetWM():SetSkin(new)
	end
end
local skins = {
	0,1,3
}
function SWEP:InitializePost()
	local Skin = skins[math.random(#skins)]
	if math.random(0,100) > 99 then
		Skin = math.random(0,1) == 1 and 4 or 2 
	end
	self:SetDeagleSkin(Skin)
	self:SetDeagleBodygroup(math.random(0,1))
end

function SWEP:ModelCreated(model)
	model:SetBodygroup(4,self:GetDeagleBodygroup())
	model:SetSkin(self:GetDeagleSkin())
end

SWEP.FakeReloadSounds = {
	[0.15] = "weapons/universal/uni_crawl_l_03.wav",
	[0.22] = "weapons/arccw_ur/deagle/magout.ogg",
	[0.3] = "weapons/arccw_ur/deagle/magout.ogg",
	--[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.37] = "weapons/universal/uni_pistol_draw_01.wav",
	[0.41] = "weapons/universal/uni_crawl_l_05.wav",
	[0.6] = "weapons/arccw_ur/deagle/magin.ogg",
	--[0.8] = "weapons/arccw_ur/deagle/chamber.ogg",
}

SWEP.FakeEmptyReloadSounds = {
	[0.15] = "weapons/universal/uni_crawl_l_03.wav",
	[0.22] = "weapons/arccw_ur/deagle/magout_old.ogg",
	[0.3] = "weapons/arccw_ur/deagle/magout_old.ogg",
	--[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.37] = "weapons/universal/uni_pistol_draw_01.wav",
	[0.41] = "weapons/universal/uni_crawl_l_05.wav",
	[0.6] = "weapons/arccw_ur/deagle/magin.ogg",
	[0.8] = "weapons/arccw_ur/deagle/chamber.ogg",
}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl" 

SWEP.lmagpos = Vector(1.5,0,0)
SWEP.lmagang = Angle(-15,0,1)
SWEP.lmagpos2 = Vector(0,2.4,0)
SWEP.lmagang2 = Angle(0,0,-105)

if CLIENT then
	local vector_full = Vector(1, 1, 1)

	SWEP.FakeReloadEvents = {
		[0.25] = function(self,timeMul)
			if self:Clip1() < 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1 * timeMul,nil,nil,function()
					self:GetWM():ManipulateBoneScale(48, vector_full)
					for i = 49, 55 do
						self:GetWM():ManipulateBoneScale(i, vector_full)
					end
				end)
			end
		end,
		[0.33] = function( self, timeMul ) 
			self:GetWM():ManipulateBoneScale(48, vector_origin)
			for i = 49, 55 do
				self:GetWM():ManipulateBoneScale(i, vector_origin)
			end
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(0,55,0) )
			end
			if self:Clip1() > 0 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.4 * timeMul,nil,nil,function()
					self:GetWM():ManipulateBoneScale(48, vector_full)
					for i = 49, 55 do
						self:GetWM():ManipulateBoneScale(i, vector_full)
					end
				end)
			end
		end
	}
end

SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/deserteagle.png")
SWEP.IconOverride = "pwb2/vgui/weapons/deserteagle.png"
SWEP.FakeEjectBrassATT = "2"
SWEP.CustomShell = "50ae"
--SWEP.EjectPos = Vector(0,5,5)
--SWEP.EjectAng = Angle(-80,50,0)
SWEP.EjectAddAng = Angle(0,0,0)

SWEP.weight = 1.5

SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(9.8,0,3.7)
SWEP.LocalMuzzleAng = Angle(0,-0.026,0.298)
SWEP.WeaponEyeAngles = Angle(0,0,90)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_57"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".50 Action Express"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Sound = {"weapons/arccw_ur/deagle/fire-01.ogg", 75, 60, 70}
SWEP.SupressedSound = {"weapons/tfa_ins2/usp_tactical/fp_suppressed1.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m1911/handling/m1911_empty.wav", 75, 95, 100, CHAN_WEAPON, 2}
SWEP.Primary.Force = 30
SWEP.Primary.Wait = 0.2
SWEP.ReloadTime = 4.2

function SWEP:PostFireBullet(bullet)
	SlipWeapon(self, bullet)
end

SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb2/weapons/pl14/magout.wav",
	"none",
	"none",
	"pwb2/weapons/pl14/magin.wav",
	"pwb2/weapons/pl14/sliderelease.wav",
	"none",
	"none",
	"none"
}

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-30, 0.0292, 4.5551)
SWEP.RHandPos = Vector(0, -0.5, -1)
SWEP.LHandPos = false
SWEP.Ergonomics = 0.9
SWEP.Penetration = 11
SWEP.SprayRand = {Angle(-0.4, -0.2, 0), Angle(-0.5, 0.2, 0)}
SWEP.AnimShootMul = 4
SWEP.AnimShootHandMul = 2
SWEP.WorldPos = Vector(2.5, -1.5, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-90, -0, 0)
SWEP.lengthSub = 20
SWEP.availableAttachments = {
	sight = {
		["mountType"] = "picatinny",
		["mount"] = Vector(-3, 0.5, 0),
		["mountAngle"] = Angle(0, 0, 0),
	},
	//mount = {
		//[1] = {"mount2", Vector(-5, -0.5, 0), {}},
	//}
}

SWEP.ShockMultiplier = 2

SWEP.DistSound = "weapons/arccw_ur/deagle/fire_dist.ogg"
SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(-2, 2, 4.5)
SWEP.holsteredAng = Angle(20, -90, -90)
SWEP.shouldntDrawHolstered = true

--local to head
SWEP.RHPos = Vector(12,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

local finger1 = Angle(-25,10,25)
local finger2 = Angle(0,25,0)
local finger3 = Angle(31,1,-25)
local finger4 = Angle(-10,-5,-5)
local finger5 = Angle(0,-65,-15)
local finger6 = Angle(2,-2,-22)

local vector_zero = Vector(0,0,0)

function SWEP:AnimHoldPost()
	--self:BoneSet("r_finger0", vector_zero, finger6)
	--self:BoneSet("l_finger0", vector_zero, finger1)
    --self:BoneSet("l_finger02", vector_zero, finger2)
	--self:BoneSet("l_finger1", vector_zero, finger3)
	--self:BoneSet("r_finger1", vector_zero, finger4)
	--self:BoneSet("r_finger11", vector_zero, finger5)
end

SWEP.ShootAnimMul = 7

local vector_one = Vector(1,1,1)

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,(self:Clip1() > 0 or self.reload) and 0 or 3)
		wep:ManipulateBonePosition(44,Vector(0 ,0 ,-1*self.shooanim ),false)
	end
end

SWEP.punchmul = 5
SWEP.punchspeed = 1
SWEP.podkid = 2


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