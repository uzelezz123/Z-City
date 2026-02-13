--ents.Reg(nil,"weapon_m4super")
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Remington 870"
SWEP.Author = "Remington Arms"
SWEP.Instructions = "Pump-action shotgun chambered in 12/70 caliber"
SWEP.Category = "Weapons - Shotguns"
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
SWEP.FakeBodyGroups = "000000002"

SWEP.FakeBodyGroupsPresets = {
	"000000002",
}

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

SWEP.LocalMuzzlePos = Vector(33.739,0.09,5.098)
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
SWEP.WorldPos = Vector(0.2, -0.5, 1.2)
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

SWEP.stupidgun = true

function SWEP:ModelCreated(model)
	model:ManipulateBoneScale(57, vector_origin)
	model:ManipulateBoneScale(58, vector_origin)
	model:SetBodyGroups(self:GetRandomBodygroups() or "0000000000200")
end

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
	self.AnimStart_Insert = 0
	self.AnimStart_Draw = 0
end

function SWEP:AnimationPost()
	local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()),0,1)
	local sin = 1 - animpos
	if sin >= 0.5 then
		sin = 1 - sin
	else
		sin = sin * 1
	end
	sin = sin * 2
	--sin = math.ease.InOutExpo(sin)
	sin = math.ease.InOutSine(sin)

	if sin > 0 then
		self.LHPos[1] = 18 - sin * 6
		self.RHPos[1] = 1 - sin * 4
		self.inanim = true
	else
		self.inanim = nil
	end

	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		wep:ManipulateBonePosition(4,Vector(0,0,sin * -3),false)
	end
end

function SWEP:GetAnimPos_Insert(time)
	return 0
end

function SWEP:GetAnimPos_Draw(time)
	return 0
end

local function cock(self,time)
	
	if SERVER then
		self:Draw(true)
	end

	if self:Clip1() == 0 then
		self.drawBullet = nil
	end

	if CLIENT and LocalPlayer() == self:GetOwner() then return end

	net.Start("hgwep draw")
		net.WriteEntity(self)
		net.WriteBool(self.drawBullet)
		net.WriteFloat(CurTime())
	net.Broadcast()
	
	self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait
	if CLIENT then self:PlaySnd(self.CockSound or "weapons/shotgun/shotgun_cock.wav",true,CHAN_AUTO) end

	local ply = self:GetOwner()

	self.reloadCoolDown = CurTime() + time
end


SWEP.GunCamPos = Vector(6,-12,-5)
SWEP.GunCamAng = Angle(190,-5,-95)

local vector_full = Vector(1,1,1)

local function reloadFunc(self)
	if not SERVER then return end

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

		if !self.drawBullet then
			cock(self,1)
			self:PlayAnim(self.AnimList["finish_empty"] or "sgreload_finish_empty", 1, false, function(self) self:SetNetVar("shootgunReload", 0) end, false, true) 
		else
			self:PlayAnim(self.AnimList["finish"] or "sgreload_finish", 1, false, function(self) self:SetNetVar("shootgunReload", 0) end, false, true) 
		end
	end, false, true)
end

SWEP.FakeEjectBrassATT = "2"

function SWEP:Reload(time)
	--print(self:GetNetVar("shootgunReload",0))
	if self.AnimStart_Draw > CurTime() - 0.5 then return end
	if not self:CanUse() then return end
	if self.reloadCoolDown > CurTime() then return end
	if self.Primary.Next > CurTime() then return end
	if self:GetNetVar("shootgunReload", 0) > CurTime() then return end
	local ply = self:GetOwner()
	if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end

	if self.drawBullet == false and SERVER then
		cock(self,1)
		self:SetNetVar("shootgunReload",CurTime() + 0.5)
		self:PlayAnim(self.AnimList["cycle"] or "cycle", 1, false, nil, false, true)
		return
	end

	if not self:CanReload() then return end

	if SERVER then
		self:SetNetVar("shootgunReload", CurTime() + 1.1)

		self:PlayAnim(self.AnimList["start"] or "sgreload_start",1,false,function() 
			reloadFunc(self)
		end,
		false, true)
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