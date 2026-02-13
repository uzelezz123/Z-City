--ents.Reg(nil,"weapon_m4super")
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "GAMBLER SHOTGUN"
SWEP.Author = "Remington Arms and Gambling HELL"
SWEP.Instructions = "Afraid?"
SWEP.Category = "Weapons - Other"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ud_870.mdl"


SWEP.FakePos = Vector(-7, 3.6, 8.2)
SWEP.FakeAng = Angle(0, 0.1, 2)

SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-8.5,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeBodyGroups = "000000000"

SWEP.FakeBodyGroupsPresets = {
	"000000000"
}

SWEP.FakeViewBobBone = "CAM_Homefield"
SWEP.FakeReloadSounds = {
	[0.25] = "weapons/ak74/ak74_magout.wav",
	[0.34] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.85] = "weapons/ak74/ak74_magin.wav",
	[0.95] = "weapons/universal/uni_crawl_l_05.wav",

}

SWEP.FakeEmptyReloadSounds = {

	[0.25] = "weapons/ak74/ak74_magout.wav",
	[0.34] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.65] = "weapons/ak74/ak74_magin.wav",
	[0.75] = "weapons/universal/uni_crawl_l_05.wav",

	[0.91] = "weapons/ak74/ak74_boltback.wav",
	[0.96] = "weapons/ak74/ak74_boltrelease.wav",
}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30


SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_shotgun.png")
SWEP.IconOverride = "vgui/wep_jack_hmcd_shotgun.png"

SWEP.LocalMuzzlePos = Vector(27.739,0.09,5.098)
SWEP.LocalMuzzleAng = Angle(0.2,-0.0,0)
SWEP.WeaponEyeAngles = Angle(-0.7,0.1,0)

SWEP.CustomShell = "12x70"

SWEP.ReloadSound = "weapons/remington_870/870_shell_in_1.wav"
SWEP.CockSound = "pwb2/weapons/ithaca37stakeout/pump.wav"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = Vector(0.01, 0.01, 0.01)
SWEP.Primary.Sound = {"zcitysnd/sound/weapons/firearms/shtg_remington870/remington_fire_01.wav", 80, 90, 100}
SWEP.SupressedSound = {"toz_shotgun/toz_suppressed_fp.wav", 65, 90, 100}
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor5", Vector(8.5,0,0), {}},
	},
	sight = {
		["mountType"] = "picatinny",
		["mount"] = Vector(-18, 1.15, 0),
	},
}

--models/weapons/tfa_ins2/upgrades/att_suppressor_12ga.mdl
SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 8
SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, 0.0571, 5.6841)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 7
SWEP.WorldPos = Vector(1.5, -1, 1.5)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)



SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reload_empty",
	["finish_empty"] = "sgreload_finish_empty",
	["finish"] = "sgreload_finish",
	["insert"] = "sgreload_insert",
	["start"] = "sgreload_start",
	["cycle"] = "cycle",
}
SWEP.AnimsEvents = {
	["sgreload_insert"] = {
		[0.0] = function(self)
			self:EmitSound("weapons/arccw_ud/870/shell-insert-0"..math.random(1,3)..".ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.8] = function(self)
			--self:GetWM():ManipulateBoneScale(47, vector_origin)
		end,
	},
	["cycle"] = {
		[0.0] = function(self)
			self:EmitSound("weapons/arccw_ud/870/rack_1.ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.1] = function(self)
			self:EmitSound("weapons/arccw_ud/870/eject.ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.2] = function(self)
			self:EmitSound("weapons/arccw_ud/870/rack_2.ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end
	},
	["sgreload_finish_empty"] = {
		[0.0] = function(self)
			self:EmitSound("weapons/arccw_ud/870/rack_1.ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.3] = function(self)
			self:EmitSound("weapons/arccw_ud/870/rack_2.ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end
	}
}

function SWEP:AnimHoldPost()
end

function SWEP:ModelCreated(model)
	model:ManipulateBoneScale(57, vector_origin)
	model:ManipulateBoneScale(58, vector_origin)
	model:SetBodyGroups(self:GetRandomBodygroups() or "0000000000200")
end

function SWEP:PostSetupDataTables()
	self:NetworkVar("String",0,"RandomBodygroups")
	self:NetworkVar("String",1,"Chamber")
	if ( CLIENT ) then
		self:NetworkVarNotify( "RandomBodygroups", self.OnVarChanged )
		self:NetworkVarNotify( "Chamber", self.OnChamber )
	end
end

function SWEP:OnVarChanged( name, old, new )
	if !IsValid(self:GetWM()) then return end

	self:GetWM():SetBodyGroups(new)
end

function SWEP:OnChamber( name, old, new )
	self.Chamber = new
end

function SWEP:InitializePost()
	self:SetRandomBodygroups(table.Random(self.FakeBodyGroupsPresets))
	self.AnimStart_Insert = 0
	self.AnimStart_Draw = 0

	self:SetupShotgun()
end

function SWEP:SetupShotgun()
	self.TubeMax = self.Primary.ClipSize
	self.Tube = {}

	for i = 1, self.TubeMax do
		self.Tube[i] = "12/70 gauge"
	end

	self.Tube[self.TubeMax] = "Nothing"
	
	if SERVER then
		self:SetChamber("12/70 gauge")
	end
end

local ammoTypes = {
	["12/70 gauge"] = 1,
	["12/70 beanbag"] = 2,
	["12/70 Slug"] = 3,
	["12/70 RIP"] = 4,
	["12/70 Blank"] = 5
}

function SWEP:NextBullet()

	self:SetChamber(self.Tube[1])
	self:Draw(true)

	for i = 1, self.TubeMax do
		if not self.Tube[i+1] then
			self.Tube[i] = "Nothing"
		else
			self.Tube[i] = self.Tube[i+1]
		end
	end

	self.Primary.Ammo = (self:GetChamber() != "Nothing" and self:GetChamber()) or (self.RealAmmoType or self.Primary.Ammo)
	if SERVER then
		net.Start("syncAmmoChanges")
			net.WriteEntity(self)
			net.WriteInt(ammoTypes[self.Primary.Ammo], 4)
		net.Broadcast()
	end

	if SERVER then
		net.Start("hgwep draw")
			net.WriteEntity(self)
			net.WriteBool(self.drawBullet)
			net.WriteFloat(CurTime())
		net.Broadcast()
		--print("------")
		--PrintTable(self.Tube)
		--print("------")
	end
end

function SWEP:LoadBullet(strBullet)
	
	for i = self.TubeMax, 1, -1 do
		if self.Tube[i-1] then
			self.Tube[i] = self.Tube[i-1]
		end
	end
	self.Tube[1] = "Nothing"
	if self.Tube[1] == "Nothing" then
		self.Tube[1] = strBullet
	end
	--PrintTable(self.Tube)
end

local ang1 = Angle(0, -10, 0)
local ang2 = Angle(0, -10, 0)

function SWEP:AnimationPost()
end

function SWEP:GetAnimPos_Insert(time)
	return 0
end

function SWEP:GetAnimPos_Draw(time)
	return 0
end

local function cock(self,time)
	if SERVER then
		self:NextBullet()
	end
	if CLIENT and LocalPlayer() == self:GetOwner() then return end

	self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait

	local ply = self:GetOwner()

	self.reloadCoolDown = CurTime() + time
end

SWEP.AllwaysChangeAmmo = true

SWEP.GunCamPos = Vector(6,-12,-5)
SWEP.GunCamAng = Angle(190,-5,-95)

local vector_full = Vector(1,1,1)

function SWEP:InsertAmmo(need)
	local owner = self:GetOwner()
	local primaryAmmo = self:GetPrimaryAmmoType()
	if !owner.GetAmmoCount then self:SetClip1(self:GetMaxClip1()) return end
	local primaryAmmoCount = owner:GetAmmoCount(primaryAmmo)
	need = need or self:GetMaxClip1() - self:Clip1()
	need = math.min(primaryAmmoCount, need)
	need = math.min(need, self:GetMaxClip1())
	self:SetClip1(self:Clip1() + need)
	owner:SetAmmo(primaryAmmoCount - need, primaryAmmo)

	if need > 0 then
		self:LoadBullet(self.RealAmmoType or self.Primary.Ammo)
	end

	if SERVER then
		net.Start("hg_insertAmmo")
			net.WriteEntity(self)
			net.WriteInt(self:Clip1(),10)
		net.Broadcast()
	end
end

local function reloadFunc(self)
	if CLIENT then return end

	self:SetNetVar("shootgunReload",CurTime() + 1.1)

	if self.MagIndex then
		self:GetWM():ManipulateBoneScale(self.MagIndex, vector_full)
	end
	
	self:PlayAnim(self.AnimList["insert"] or "sgreload_insert", 1, false, function() 
		self:InsertAmmo(1)
		if self.MagIndex then
			self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin)
		end
		
		local key = hg.KeyDown(self:GetOwner(), IN_RELOAD)
		--print("reload",key)
		
		if key and self:CanReload() then
			reloadFunc(self)
			return
		end

		if self:GetChamber() == "Nothing" then
			cock(self,1)
			self:PlayAnim(self.AnimList["finish_empty"] or "sgreload_finish_empty", 1,false,function(self) self:SetNetVar("shootgunReload",0) self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin) end,false,true) 
		else
			self:PlayAnim(self.AnimList["finish"] or "sgreload_finish", 1,false,function(self) self:SetNetVar("shootgunReload",0) self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin) end,false,true) 
		end
	end, false, true)
end

SWEP.FakeEjectBrassATT = "2"

function SWEP:Reload(time)
	--print(self:GetNetVar("shootgunReload",0))
	local ply = self:GetOwner()
	if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end
	if self.AnimStart_Draw > CurTime() - 0.5 then return end
	if not self:CanUse() then return end
	if self.reloadCoolDown > CurTime() then return end
	if self.Primary.Next > CurTime() then return end
	if self:GetNetVar("shootgunReload",0) > CurTime() then return end

	if self.drawBullet == false and SERVER then
		cock(self,1)
		self:SetNetVar("shootgunReload",CurTime() + 0.5)
		self:PlayAnim(self.AnimList["cycle"] or "cycle", 1, false, nil, false, true)
		return
	end
	--print("----")
	--PrintTable(self.Tube)
	if self.Tube[self.TubeMax] != "Nothing" or not self:CanReload() then return end

	if SERVER then
		self:SetNetVar("shootgunReload",CurTime() + 1.1)
		self:PlayAnim(self.AnimList["start"] or "sgreload_start",1,false,function() 
			reloadFunc(self)
		end,
		false,true)
	end
end
--self.RealAmmoType

function SWEP:PrimaryShootPre()
	self.Primary.Ammo = (self:GetChamber() != "Nothing" and self:GetChamber()) or (self.RealAmmoType or self.Primary.Ammo)
	if SERVER then
		net.Start("syncAmmoChanges")
			net.WriteEntity(self)
			net.WriteInt(ammoTypes[self.Primary.Ammo], 4)
		net.Broadcast()
	end
	local ply = self:GetOwner()
	if SERVER and self:GetChamber() != "Nothing" and ply.suiciding then
		ply:AddNaturalAdrenaline(1.5)
		ply.organism.fearadd = ply.organism.fearadd + 0.5
	end
end

function SWEP:CanPrimaryAttack()
	return not (self:GetNetVar("shootgunReload",0) > CurTime())
end


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