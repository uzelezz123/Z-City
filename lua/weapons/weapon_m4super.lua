
SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Benelli M4 Super 90"
SWEP.Author = "Benelli Armi S.p.A."
SWEP.Instructions = "Semi-automatic shotgun chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.Spawnable = false
SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/m4super90.png")
SWEP.IconOverride = "pwb2/vgui/weapons/m4super90.png"
SWEP.ReloadSound = "weapons/tfa_ins2/m1014/toz_shell_insert_2.wav"
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/toz_shotgun/handling/toz_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.CustomShell = "12x70"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 16
SWEP.Primary.Spread = Vector(0.01, 0.01, 0.01)
SWEP.Primary.Force = 12
SWEP.Primary.Sound = {"toz_shotgun/toz_fp.wav", 80, 70, 75}
SWEP.Primary.Wait = 0.2
SWEP.NumBullet = 8
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
--[type_] = {1 = name,2 = spread,3 = dmg,4 = pen,5 = numbullet,6 = isrubber,7 = shockmul},

SWEP.addSprayMul = 1

SWEP.weight = 4

SWEP.HoldType = "rpg"
SWEP.ReloadHold = "ar2"
SWEP.ZoomPos = Vector(-1.45, 0.36, 33)
SWEP.RHandPos = Vector(-5, -2, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.SprayRand = {Angle(-0.2, -0.4, 0), Angle(-0.4, 0.4, 0)}
SWEP.Ergonomics = 0.9
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 10
SWEP.AnimStart_Draw = 0
SWEP.AnimStart_Insert = 0
SWEP.AnimInsert = 0.1
SWEP.Penetration = 8
SWEP.ReloadTime = 1
SWEP.AnimInsert = 0.1
SWEP.AnimDraw = 0.4
SWEP.ReloadDrawTime = 0.1
SWEP.ReloadDrawCooldown = 0.1
SWEP.ReloadInsertTime = 0.1
SWEP.ReloadInsertCooldown = 0.25
SWEP.ReloadInsertCooldownFire = 0.1
SWEP.lengthSub = 20
SWEP.handsAng = Angle(-1, 1, 0)
SWEP.attPos = Vector(0,0,-0.3)

SWEP.punchmul = 3
SWEP.punchspeed = 0.7

SWEP.ShockMultiplier = 3

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mshotgun" -- shared in sh_effects.lua

SWEP.LocalMuzzlePos = Vector(25.942,-0.202,3.586)
SWEP.LocalMuzzleAng = Angle(0,-0.024,90.248)
SWEP.WeaponEyeAngles = Angle(0,0,0)

function SWEP:GetAnimPos_Insert(time)
	local animpos1 = math.Clamp(self.AnimStart_Insert + self.AnimInsert - time, 0, self.AnimInsert) / self.AnimInsert
	return animpos1
end

function SWEP:GetAnimPos_Draw(time)
	local animdraw = self.AnimDraw * 1.5
	local animpos1 = math.Clamp(self.AnimStart_Draw + animdraw - time, 0, animdraw) / animdraw
	return animpos1
end

function SWEP:ChangeCameraPassive(value)
	if self.reload then return 1 end
	return value
end

function SWEP:InitializePost()
	self.AnimStart_Insert = 0
	self.AnimStart_Draw = 0

	--self.RHPos = Vector(1,-5,3.4)
	--self.RHAng = Angle(0,-15,90)
	--local to rh
	--self.LHPos = Vector(18,-0.8,-3.6)
	--self.LHAng = Angle(-100,-180,0)
end

function SWEP:CanPrimaryAttack()
	return not (self:GetAnimPos_Draw(CurTime()) > 0)
end

SWEP.reloadCoolDown = 0
if SERVER then
	util.AddNetworkString("hgwep draw")
	function SWEP:Reload(time)
		if not self:CanUse() then return end
		local ply = self:GetOwner()
		if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end
		if self.reloadCoolDown > CurTime() then return end
		if self.Primary.Next > CurTime() then return end
		if self.drawBullet == false then
			self.AnimStart_Draw = CurTime()
			if SERVER then
				self:Draw(true)
			end
			if CLIENT and LocalPlayer() == self:GetOwner() then ViewPunch(AngleRand(0, -10)) end
			net.Start("hgwep draw")
			net.WriteEntity(self)
			net.WriteBool(self.drawBullet)
			net.WriteFloat(CurTime())
			net.Broadcast()
			self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait
			self:PlaySnd(self.CockSound or "weapons/shotgun/shotgun_cock.wav",true,CHAN_AUTO)
			local ply = self:GetOwner()
			if IsValid(ply:GetNetVar("carryent2")) then
				if SERVER then
					local ent = ply:GetNetVar("carryent2")
					ply:SetNetVar("carryent2",NULL)
					ply:SetNetVar("carrybone2",nil)
					ply:SetNetVar("carrymass2",0)
					ply:SetNetVar("carrypos2",nil)
					heldents[ent:EntIndex()] = nil
				end
			end
			self.reloadCoolDown = CurTime() + self.ReloadDrawCooldown
			return
		end

		if self:GetAnimPos_Draw(CurTime()) > 0 then return end
		if not self:CanReload() then return end
		--self:GetOwner():SetPlaybackRate(1)
		self.LastReload = CurTime()
		self:ReloadStart()
		self:ReloadStartPost()
		if not self.DontOnReloadSnd then
			self:PlaySnd(self.ReloadSound or "pwb2/weapons/ksg/shellinsert1.wav",true,CHAN_AUTO)
		end
		local org = self:GetOwner().organism
		self.StaminaReloadTime = self.ReloadTime * ( IsValid( self:GetOwner() ) and org and org.stamina and org.pain and (2 - (self:GetOwner().organism.stamina[1] / 180 ) ) + (( org.pain / 40 ) + (org.larm/3) + (org.rarm/3)) or 1 )
		self.reload = self.LastReload + self.StaminaReloadTime
		self.dwr_reverbDisable = true
		net.Start("hgwep reload")
			net.WriteEntity(self)
			net.WriteFloat(self.LastReload)
			net.WriteInt(self:Clip1(),10)
			net.WriteFloat(self.StaminaReloadTime)
		net.Broadcast()
	end
else
	function SWEP:Reload(time)
		if not time then return end
		if !self:CanReload() then return end
		self.LastReload = time
		self:ReloadStart()
		self:ReloadStartPost()
		--self.StaminaReloadTime = -- self.ReloadTime * ( IsValid( self:GetOwner() ) and self:GetOwner().organism and self:GetOwner().organism.stamina and 2 -(self:GetOwner().organism.stamina[1] / 180 ) or 1 )
		self.reload = time + (self.StaminaReloadTime or self.ReloadTime)
		self.dwr_reverbDisable = true
	end

	function SWEP:ReloadStart()
		if not self or not IsValid(self:GetOwner()) then return end
		--self:SetHold(self.ReloadHold or self.HoldType)
		--self:GetOwner():SetAnimation(PLAYER_RELOAD)
	end

	net.Receive("hgwep draw", function()
		local self = net.ReadEntity()
		local drawBullet = net.ReadBool()
		local time = net.ReadFloat()
		if self and self.Primary then
			self.Primary = self.Primary or {}
			self.AnimStart_Draw = time
			self.drawBullet = drawBullet
			--if self.Draw then self:Draw() end
			self.Primary.Next = time + (self.AnimDraw or 0) + self.Primary.Wait
		end
	end)
end

SWEP.Chocking = true

function SWEP:ReloadEnd()
	local owner = self:GetOwner()
	--owner:SetPlaybackRate(-1)
	self:InsertAmmo(1)
	self.ReloadNext = CurTime() + self.ReloadCooldown
	if SERVER then
		if not self.drawBullet then
			self.AnimStart_Draw = CurTime()
			self:Draw(true)
			net.Start("hgwep draw")
			net.WriteEntity(self)
			net.WriteBool(self.drawBullet)
			net.WriteFloat(CurTime())
			net.Broadcast()
			if self.Chocking then
				self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait
				self:GetOwner():EmitSound(self.CockSound or "weapons/shotgun/shotgun_cock.wav")
			end
		end
	end
end

--[[
function SWEP:ReloadDrawEnd()
	self.reloadDrawing = nil
	self.ReloadNext = CurTime() + self.ReloadDrawCooldown
	self:Draw()
end

function SWEP:ReloadAmmoEnd()
	self.ReloadNext = CurTime()  + self.ReloadInsertCooldown
	self:InsertAmmo(1)
	self.Primary.NextFire = CurTime() + self.ReloadInsertCooldownFire
end
--]]
function SWEP:PrimaryShootPost()
	self.ReloadNext = CurTime() + 0.5
end
local anims = {
	Vector(1,0,0),
	Vector(2,1,-3),
	Vector(6,1,-3),
	Vector(8,1,-3),
	Vector(8,1,-3),
	Vector(8,1,-3),
	Vector(7,1,-3),
	Vector(6,1,-3),
}

function SWEP:AnimationPostPost()
end

function SWEP:AnimationPost()
	local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()),0,1)
	self.sin = 1 - animpos
	if self.sin >= 0.5 then
		self.sin = 1 - self.sin
	else
		self.sin = self.sin * 1
	end
	if self.sin > 0 then
		self.sin = self.sin * 2
		self.sin = math.ease.InOutSine(self.sin)

		local lohsin = math.floor(self.sin * (#anims))
		local lerp = self.sin * (#anims) - lohsin
		self.RHPosOffset = Lerp(lerp,anims[math.Clamp(lohsin,1,#anims)],anims[math.Clamp(lohsin+1,1,#anims)])
		self.inanim = true
	else
		self.inanim = nil
		self.RHPosOffset[1] = 0
		self.RHPosOffset[2] = 0
		self.RHPosOffset[3] = 0
	end
	self:AnimationPostPost()
end

SWEP.UseCustomWorldModel = true
SWEP.WorldPos = Vector(5, -1, 0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.DistSound = "toz_shotgun/toz_dist.wav"

SWEP.ReloadSoundes = {
	"none"
}

local finger1 = Angle(10, -12, -25)
local finger2 = Angle(-10,30,0)
local finger3 = Angle(0,-10,0)

function SWEP:AnimHoldPost(model)
	if self:GetClass() == "weapon_m4super" then
		self:BoneSet("l_finger0", vector_zero, finger1)
		self:BoneSet("l_finger02", vector_zero, finger2)
		self:BoneSet("l_finger1", vector_zero, finger3)
		self:BoneSet("l_finger2", vector_zero, finger3)
	end
end

--local to head
SWEP.RHPos = Vector(3,-5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(15,-1,-3)
SWEP.LHAng = Angle(-110,-90,-90)


-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-2,2,-4),
	Vector(-5,7,-15),
	Vector(-15,7,-15),
	Vector(-15,7,-15),
	Vector(-2,1,-7),
	Vector(-2,1,-7),
	Vector(-2,1,-5),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-2,2,5),
	Angle(-1,5,15),
	Angle(-1,5,15),
	Angle(-1,5,15),
	Angle(0,5,15),
	Angle(0,5,15),
	Angle(-2,2,5)
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