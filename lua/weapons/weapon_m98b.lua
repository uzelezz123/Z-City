SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Barrett M98B"
SWEP.Author = "Barrett Firearms"
SWEP.Instructions = "Sniper rifle chambered in .338 Lapua Magnum"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/zcity/w_m98b.mdl"

SWEP.WepSelectIcon2 = Material("pwb/sprites/m98b.png")
SWEP.IconOverride = "entities/weapon_pwb_m98b.png"

SWEP.CustomShell = ".338Lapua"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)

SWEP.CanSuicide = false

SWEP.weight = 5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "RifleShellEject"
SWEP.AutomaticDraw = true
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".338 Lapua Magnum"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Damage = 180
SWEP.Primary.Force = 60
SWEP.Primary.Sound = {"homigrad/weapons/rifle/loud_awp.wav", 80, 90, 100}
SWEP.availableAttachments = {
	sight = {
		["empty"] = {
			"empty",
			{
				[1] = "null",
				[2] = "null"
			}
		},
		["mountType"] = "picatinny",
		["mount"] = Vector(-37, 2.2, -0.09),
		["removehuy"] = {
			[1] = "null",
			[2] = "null"
		}
	}
}

SWEP.StartAtt = {"optic6"}

SWEP.LocalMuzzlePos = Vector(32.708,-0.019,7.639)
SWEP.LocalMuzzleAng = Angle(0,-0.029,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 1
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 3
SWEP.addSprayMul = 1
SWEP.ReloadTime = 5.7
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-9, 0.0773, 10.1617)
SWEP.RHandPos = Vector(-12, -2, 4)
SWEP.LHandPos = Vector(6, 1, -2)
SWEP.AimHands = Vector(-3, 1.95, -4.2)
SWEP.SprayRand = {Angle(-0.6, -0.1, 0), Angle(-0.7, 0.1, 0)}
SWEP.Ergonomics = 0.75
SWEP.Penetration = 35
SWEP.ZoomFOV = 20
SWEP.WorldPos = Vector(14, -1, 3.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.handsAng = Angle(4, 0, 0)
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("decals/perekrestie6.png")
SWEP.localScopePos = Vector(-27.5, 5.575, -0.09)
SWEP.scope_blackout = 400
SWEP.rot = 191
SWEP.FOVMin = 2
SWEP.FOVMax = 10
SWEP.FOVScoped = 40
SWEP.blackoutsize = 2500
SWEP.sizeperekrestie = 2048
SWEP.ShockMultiplier = 1

SWEP.punchmul = 2
SWEP.punchspeed = 0.5

SWEP.attPos = Vector(0,2,0)
SWEP.attAng = Angle(0,0,0)

if CLIENT then
	function SWEP:DrawHUDAdd()
	end
end

SWEP.AutomaticDraw = false

SWEP.ReloadDrawTime = 0.2
SWEP.ReloadDrawCooldown = 0.3
SWEP.ReloadInsertTime = 0.1
SWEP.ReloadInsertCooldown = 0.1
SWEP.ReloadInsertCooldownFire = 0.1

SWEP.AnimStart_Draw = 0
SWEP.AnimStart_Insert = 0
SWEP.AnimInsert = 0.5
SWEP.AnimDraw = 1.1

SWEP.ReloadSoundes = {
	"none",
	"weapons/tfa_ins2/ak103/ak103_magout.wav",
	"none",
	"none",
	"weapons/tfa_ins2/ak103/ak103_magin.wav",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "muzzleflash_m79" -- shared in sh_effects.lua

SWEP.CockSound = "snd_jack_hmcd_boltcycle.wav"
SWEP.DontOnReloadSnd = true

SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"

SWEP.lengthSub = 5
local anims = {
	Vector(0,0,0),
	Vector(1,1,-2),
	Vector(1,2,-3),
	Vector(0,2,-3),
	Vector(-1,2,-3),
	Vector(-2,2,-3),
}

function SWEP:AnimationPostPost()
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
	sin = math.max(sin - 0.5, 0) * 1.5
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		wep:ManipulateBonePosition(1,Vector(-5.2*sin , .1*sin, .9*sin ),false)
		wep:ManipulateBoneAngles(1,Angle(0 , -50*math.min(sin*5,1), 0),false)
	end
end

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(2, 8, -12)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.DistSound = "mosin/mosin_dist.wav"
SWEP.bipodAvailable = true

--local to head
SWEP.RHPos = Vector(4,-6.5,4)
SWEP.RHAng = Angle(0,0,90)

--local to rh
SWEP.LHPos = Vector(15,1.5,-3.7)
SWEP.LHAng = Angle(-90,-150,-0)

local finger1 = Angle(-35, -25, 0)
local finger2 = Angle(-0, 10, 0)
local finger3 = Angle(-0, -20, 0)
local angZero = Angle(0, 0, 0)

function SWEP:AnimHoldPost(model)
	self:BoneSet("l_finger0", vector_zero, finger1)

end

SWEP.DistSound = "mosin/mosin_dist.wav"
SWEP.bipodAvailable = true

function SWEP:Initialize_Reload()
	self.LastReload = 0
end

SWEP.dwr_customVolume = 1
SWEP.OpenBolt = false
function SWEP:CanReload()
	if self:LastShootTime() + 0.1 > CurTime() then return end
	local owner = self:GetOwner()
	if !owner.GetAmmoCount then return true end
	if self.ReloadNext or not self:CanUse() or self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) == 0 or self:Clip1() >= self:GetMaxClip1() + (self.drawBullet and not self.OpenBolt and 1 or 0) then --shit
		return
	end
	return true
end

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
end

SWEP.ReloadCooldown = 0.1
local math_min = math.min
function SWEP:ReloadEnd()
	self:InsertAmmo(self:GetMaxClip1() - self:Clip1() + (self.drawBullet ~= nil and not self.OpenBolt and 1 or 0))
	self.ReloadNext = CurTime() + self.ReloadCooldown --я хуй знает чо это
	self:Draw()
end

function SWEP:Step_Reload(time)
	if self:KeyDown(IN_WALK) and self:KeyDown(IN_RELOAD) then
		self.checkingammo = true
	else
		self.checkingammo = false
	end

	local time2 = self.reload
	if time2 and time2 < time then
		self.reload = nil
		self:ReloadEnd()
	end

	if time2 then
		local part = 1 - (time2 - time) / self.ReloadTime

		self:ReloadSounds(part)

		part = math.ease.InOutQuad(part)

		self:AnimationReload(part)
	end

	time2 = self.ReloadNext
	if time2 and time2 < time then
		self.ReloadNext = nil
		self.dwr_reverbDisable = nil
	end
end

if SERVER then return end
--[[net.Receive("hgwep reload", function()
	local self = net.ReadEntity()
	local time = net.ReadFloat()
	if self.Reload then self:Reload(time) end
end)--]]

function SWEP:Reload(time)
	if not time then return end
	self.LastReload = time
	self:ReloadStart()
	self:ReloadStartPost()
	self.reload = time + (self.StaminaReloadTime or self.ReloadTime)
	self.dwr_reverbDisable = true
end

function SWEP:ReloadStart()
	if not self or not IsValid(self:GetOwner()) then return end
	--self:SetHold(self.ReloadHold or self.HoldType)
	--self:GetOwner():SetAnimation(PLAYER_RELOAD)
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,1,-2),
	Vector(0,2,-2),
	Vector(0,3,-2),
	Vector(0,3,-8),
	Vector(-8,-15,-15),
	Vector(-15,-20,-25),
	Vector(-13,-12,-5),
	Vector(-6,6,-3),
	Vector(-1,5,-1),
	Vector(0,4,-1),
	Vector(0,3,-3),
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
	Vector(0,0,5),
	Vector(6,1,5),
	Vector(6,2,5),
	Vector(6,1,0),
	Vector(6,2,0),
	Vector(-1,3,1),
	Vector(-2,3,1),
	Vector(-5,3,1),
	Vector(-2,3,1),
	Vector(-2,2,1),
	Vector(0,0,0),
}

SWEP.ReloadAnimLHAng = {
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
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-15,5,-5),
	Angle(-15,15,-15),
	Angle(-10,15,-15),
	Angle(5,0,-15),
	Angle(9,2,0),
	Angle(4,1,0),
	Angle(7,-1,0),
	Angle(7,2,0),
	Angle(5,2,-5),
	Angle(-10,-1,-0),
	Angle(0,2,0),
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