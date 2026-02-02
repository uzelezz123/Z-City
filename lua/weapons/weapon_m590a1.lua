SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Mossberg 590A1"
SWEP.Author = "O.F. Mossberg & Sons"
SWEP.Instructions = "Pump-action shotgun chambered in 12/70 caliber"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/pwb/weapons/w_m590a1.mdl"
SWEP.WorldModelFake = "models/weapons/zcity/c_m590.mdl"
//SWEP.FakeScale = 1.5
//PrintAnims(Entity(1):GetActiveWeapon():GetWM())
--PrintTable(Entity(1):GetActiveWeapon():GetWM():GetAttachments())
--uncomment for funny
SWEP.FakePos = Vector(-6, 2, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
//SWEP.MagIndex = 41
SWEP.FakeAttachment = "muzzle"
SWEP.AttachmentPos = Vector(2,0,0)
SWEP.AttachmentAng = Angle(0,0,0)
//SWEP.MagIndex = 6
//MagazineSwap
--Entity(1):GetActiveWeapon():GetWM():AddLayeredSequence(Entity(1):GetActiveWeapon():GetWM():LookupSequence("delta_foregrip"),1)
SWEP.FakeReloadSounds = {
	[0.25] = "weapons/ak74/ak74_magout.wav",
	[0.34] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.85] = "weapons/ak74/ak74_magin.wav",
	[0.95] = "weapons/universal/uni_crawl_l_05.wav",
	--[0.95] = "weapons/ak74/ak74_boltback.wav"
}

SWEP.FakeEmptyReloadSounds = {
	--[0.22] = "weapons/ak74/ak74_magrelease.wav",
	[0.25] = "weapons/ak74/ak74_magout.wav",
	[0.34] = "weapons/ak74/ak74_magout_rattle.wav",
	[0.65] = "weapons/ak74/ak74_magin.wav",
	[0.75] = "weapons/universal/uni_crawl_l_05.wav",
	--[0.95] = "weapons/ak74/ak74_boltback.wav",
	[0.91] = "weapons/ak74/ak74_boltback.wav",
	[0.96] = "weapons/ak74/ak74_boltrelease.wav",
}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"
SWEP.FakeReloadEvents = {
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30

--SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("pwb/sprites/m590a1.png")
SWEP.IconOverride = "entities/tfa_ins2_wpn_mossberg590.png"

SWEP.LocalMuzzlePos = Vector(25,0.09,5.098)
SWEP.LocalMuzzleAng = Angle(0.2,-0.0,0)
SWEP.WeaponEyeAngles = Angle(-0.7,0.1,0)

SWEP.CustomShell = "12x70"
--SWEP.EjectPos = Vector(-0,8,4)
--SWEP.EjectAng = Angle(0,-90,0)
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
		["mount"] = Vector(-1.6,0,0),
		[1] = {"supressor5", Vector(0,0,0), {}},
	},
	sight = {
		["mountType"] = "picatinny",
		["mount"] = Vector(-22.5, 0.75, 0.1),
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
SWEP.ZoomPos = Vector(0, 0, 6.68)
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

--local to head
--SWEP.RHPos = Vector(1,-5,3.4)
--SWEP.RHAng = Angle(0,-15,90)
----local to rh
--SWEP.LHPos = Vector(18,-0.8,-3.6)
--SWEP.LHAng = Angle(-100,-180,0)

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload_start",
	["reload_empty"] = "base_reload_start_empty",
	["finish_empty"] = "base_reload_end",
	["finish"] = "base_reload_end",
	["insert"] = "base_reload_insert",
	["start"] = "base_reload_start",
	["cycle"] = "base_fire_cock_2",
}
SWEP.AnimsEvents = {
	["base_reload_insert"] = {
		[0.0] = function(self, mdl)
			self:EmitSound("weapons/arccw_ud/870/shell-insert-0"..math.random(1,3)..".ogg")
			mdl:ManipulateBoneScale(mdl:LookupBone("Shell"), Vector(1, 1, 1))
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.8] = function(self, mdl)
			--self:GetWM():ManipulateBoneScale(47, vector_origin)
		end,
	},
	["base_reload_end"] = {
		[0.0] = function(self, mdl)
			mdl:ManipulateBoneScale(mdl:LookupBone("Shell"), vector_origin)
		end,
	},
	["base_fire_cock_2"] = {
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
	}
}

SWEP.stupidgun = true

--[[SWEP.BMerge = nil
function SWEP:SetupBoneMerge(mdl)
	if not mdl then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local vm = self:GetWeaponEntity()
	if not IsValid(vm) then return end

	if not IsValid(self.BMerge) then
		self.BMerge = ClientsideModel(mdl, RENDERGROUP_VIEWMODEL)
		if IsValid(self.BMerge) then
			self.BMerge:SetPos(vm:GetPos())
			self.BMerge:SetAngles(vm:GetAngles())
			self.BMerge:AddEffects(EF_BONEMERGE)
			self.BMerge:SetNoDraw(true)
			self.BMerge:SetParent(vm)
			self.BMerge:SetupBones()
			self.BMerge:DrawModel()
		end
	end
end

function SWEP:DrawPost() --!! оно на груди не видно а еще целится невозможно
	local owner = self:GetOwner()
	if IsValid(owner) and owner.GetActiveWeapon and IsValid(owner:GetActiveWeapon()) then
		if owner:GetActiveWeapon() ~= nil and owner:GetActiveWeapon() ~= NULL and owner:GetActiveWeapon() ~= self then return end
	end
	if not IsValid(self.BMerge) then
		self:SetupBoneMerge("models/weapons/upgrades/a_standard_m590.mdl")
	else
		self.BMerge:SetupBones()
		self.BMerge:DrawModel()
	end
end]]

function SWEP:ModelCreated(mdl)
	mdl:ManipulateBoneScale(mdl:LookupBone("Shell"), vector_origin)
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

SWEP.MagIndex = 73
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
		--self:GetOwner():ChatPrint(tostring(self.drawBullet))
		--self:PlaySnd(self.CockSound or "weapons/shotgun/shotgun_cock.wav",true,CHAN_AUTO)
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

SWEP.InspectAnimLH = {
	Vector(0,0,0)
}

SWEP.InspectAnimLHAng = {
	Angle(0,0,0)
}

SWEP.InspectAnimRH = {
	Vector(0,0,0)
}

SWEP.InspectAnimRHAng = {
	Angle(0,0,0)
}

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(-5,9,5),
	Angle(-5,9,14),
	Angle(-5,9,16),
	Angle(-6,10,15),
	Angle(-5,9,16),
	Angle(-10,15,-15),
	Angle(-2,22,-15),
	Angle(0,25,-32),
	Angle(0,24,-45),
	Angle(0,22,-55),
	Angle(0,20,-56),
	Angle(0,0,0)
}
