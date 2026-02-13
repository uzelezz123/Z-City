--ents.Reg(nil,"weapon_m4super")
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Franchi SPAS-12"
SWEP.Author = "Luigi Franchi S.p.A."
SWEP.Instructions = "Semi-automatic shotgun chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WorldModelFake = "models/weapons/arccw/c_ur_spas12.mdl"

--PrintAnims(Entity(1):GetActiveWeapon():GetWM())
--PrintTable(Entity(1):GetActiveWeapon():GetWM():GetAttachments())
--uncomment for funny
SWEP.FakePos = Vector(-10, 4.15, 3.85)
SWEP.FakeAng = Angle(0.2, 0, 1)

SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(0.4,0.5,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeBodyGroups = "000000002"

SWEP.FakeEjectBrassATT = "2"
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
SWEP.DistSound = "weapons/arccw_ud/870/fire_dist.ogg"


SWEP.WepSelectIcon2 = Material("vgui/hud/tfa_ins2_spas12")
SWEP.IconOverride = "vgui/hud/tfa_ins2_spas12"
SWEP.ScrappersSlot = "Primary"
SWEP.CustomShell = "12x70"

SWEP.weight = 4
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = Vector(0.01, 0.01, 0.01)
SWEP.NumBullet = 8
SWEP.Primary.Sound = {"weapons/arccw_ud/870/fire-01.ogg", 80, 70, 75}
SWEP.Primary.Wait = 0.2
SWEP.HoldType = "rpg"
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.ReloadSound = "weapons/spas12/handling/toz_shell_insert_2.wav"
SWEP.ZoomPos = Vector(-3, 0.3971, 2.3896)
SWEP.RHandPos = Vector(-14, -1, 4)
SWEP.LHandPos = Vector(7, -2, 0)

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor6", Vector(0,0,0), {}},
		[2] = {"supressor5", Vector(1.4,-0.45,0), {}},
		["mount"] = Vector(-0.5,0.3,0),
	}
}

SWEP.LocalMuzzlePos = Vector(27.531,0.388,1.044)
SWEP.LocalMuzzleAng = Angle(0.2,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Ergonomics = 0.9
SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 3
SWEP.OpenBolt = true
SWEP.Penetration = 7
SWEP.WorldPos = Vector(6,-1,-3.8)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, -0.2, 0)
SWEP.lengthSub = 20
SWEP.handsAng = Angle(0, -1, 0)

--local to head
SWEP.RHPos = Vector(1,-6.2,4.2)
SWEP.RHAng = Angle(0,-10,90)
--local to rh
SWEP.LHPos = Vector(17,0,-4)
SWEP.LHAng = Angle(-100,-90,-90)

local ang1 = Angle(0, -20, -25)

function SWEP:AnimationPostPost()
	self:BoneSet("l_finger0", vector_origin, ang1)
end

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reload_empty",
	["finish_empty"] = "sgreload_finish",
	["finish"] = "sgreload_finish",
	["insert"] = "sgreload_insert",
	["start"] = "sgreload_start",
	["cycle"] = "cycle",
}

SWEP.AnimsEvents = {
	["sgreload_start_empty"] = {
		[0.2] = function(self)
			self:EmitSound("weapons/arccw_ud/m1014/breechload.ogg")
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.8] = function(self)
			self:EmitSound("weapons/arccw_ud/m1014/breechclose.ogg")
		end,
		[0.9] = function(self)
			--self:GetWM():ManipulateBoneScale(47, vector_origin)
		end,
	},
	["sgreload_insert"] = {
		[0.0] = function(self)
			self:EmitSound("weapons/arccw_ur/spas12/shell-insert-0"..math.random(1,9)..".ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.8] = function(self)
			--self:GetWM():ManipulateBoneScale(47, vector_origin)
		end,
	},
	["cycle"] = {
		[0.0] = function(self)
			self:EmitSound("weapons/arccw_ur/spas12/forearm_back.ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.3] = function(self)
			self:EmitSound("weapons/arccw_ur/spas12/forearm_forward.ogg")
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end
	}
}

function SWEP:AnimHoldPost()
end

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():ManipulateBoneScale(57, vector_origin)
		self:GetWM():ManipulateBoneScale(58, vector_origin)
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
		--local ent = self:GetWM()
		--ent:SetColor(Color(255,0,0))
	end
end


function SWEP:InitializePost()
	self.AnimStart_Insert = 0
	self.AnimStart_Draw = 0
end

local ang1 = Angle(0, -10, 0)
local ang2 = Angle(0, -10, 0)

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	self.vec = self.vec or Vector(0,0,0)
	local vec = self.vec
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self:Clip1() > 0 and 0 or 0)
		vec[1] = 0
		vec[2] = 4*self.shooanim
		vec[3] = 0
		wep:ManipulateBonePosition(45,vec,false)
		--vec[1] = -1*self.ReloadSlideOffset
		--vec[2] = 0.09*self.ReloadSlideOffset
		--vec[3] = -0.06*self.ReloadSlideOffset
		--wep:ManipulateBonePosition(2,vec,false)
	end
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
	--self:PlaySnd(self.CockSound or "weapons/shotgun/shotgun_cock.wav",true,CHAN_AUTO)

	local ply = self:GetOwner()

	self.reloadCoolDown = CurTime() + time
end


SWEP.GunCamPos = Vector(6,-12,-5)
SWEP.GunCamAng = Angle(190,-5,-95)

local vector_full = Vector(1,1,1)

function SWEP:GetAnimPos_Insert(time)
	return 0
end

function SWEP:GetAnimPos_Draw(time)
	return 0
end

local function reloadFunc(self)
	if not SERVER then return end
	
	self:SetNetVar("shootgunReload",CurTime() + 1.1)

	if self.MagIndex then
		self:GetWM():ManipulateBoneScale(self.MagIndex, vector_full)
	end
	--self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.58)

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
			
			self:PlayAnim(self.AnimList["finish_empty"] or "sgreload_finish_empty", 1,false,function(self)  
				self:SetNetVar("shootgunReload",0) 
				cock(self,1)
				self:PlayAnim(self.AnimList["cycle"] or "cycle", 1,false,nil,false,true) 
			end,false,true) 
		else
			self:PlayAnim(self.AnimList["finish"] or "sgreload_finish", 1, false, function(self) self:SetNetVar("shootgunReload",0) end, false, true)
		end
	end, false, true)
end

function SWEP:Reload(time)
	--print(self:GetNetVar("shootgunReload",0))
	local ply = self:GetOwner()
	if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end
	if self.AnimStart_Draw > CurTime() - 0.5 then return end
	if not self:CanUse() then return end
	if self.reloadCoolDown > CurTime() then return end
	if self.Primary.Next > CurTime() then return end
	if self:GetNetVar("shootgunReload",0) > CurTime() then return end
	--print(self.drawBullet)
	if not self:CanReload() and not self.drawBullet and SERVER then
		cock(self,1)
		self:SetNetVar("shootgunReload",CurTime() + 1.3)
		self:PlayAnim(self.AnimList["cycle"] or "cycle", 1, false, nil, false, true)
		return
	end

	if not self:CanReload() then return end

	if SERVER then
		self:SetNetVar("shootgunReload",CurTime() + 1.1)
		self:PlayAnim(self.AnimList["start"] or "sgreload_start",1,false,function() 
			reloadFunc(self)
		end,
		false,true)
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