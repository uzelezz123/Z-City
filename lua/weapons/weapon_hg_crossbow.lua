SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Homemade Crossbow"
SWEP.Author = "Unknown"
SWEP.Instructions = "A rather weighty homemade crossbow that shoots red-hot armature.\nHas very high damage"
SWEP.Category = "Weapons - Other"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.WorldModelFake = "models/weapons/c_crossbow.mdl"

SWEP.FakePos = Vector(-11, 8.2, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0.5,-1.2,-6.5)
SWEP.AttachmentAng = Angle(0,0,0)


SWEP.FakeVPShouldUseHand = true

SWEP.CantFireFromCollision = true // 2 спусковых крючка все дела

SWEP.AnimList = {
	["idle"] = "idle_is",
	["reload"] = "reload",
	["reload_empty"] = "reload",
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 40

SWEP.FakeReloadSounds = {}

SWEP.FakeEmptyReloadSounds = {
	[0.18] = "weapons/universal/uni_crawl_l_03.wav",
	--[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.62] = "weapons/tfa_hl2r/crossbow/reload1.wav",
	[0.75] = "weapons/tfa_hl2r/crossbow/bolt_load2.wav",
	[0.84] = "weapons/universal/uni_crawl_l_04.wav",
	--[0.92] = "weapons/m45/m45_boltrelease.wav",
}

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(-10,0,0)
SWEP.lmagpos2 = Vector(0,3.5,0.3)
SWEP.lmagang2 = Angle(0,0,-110)

SWEP.GunCamPos = Vector(2.2,-17,-3)
SWEP.GunCamAng = Angle(180,0,-90)

SWEP.MagModel = "models/weapons/zcity/w_glockmag.mdl"

if CLIENT then
	SWEP.FakeReloadEvents = {
		[0.84] = function(self) self:GetWM():SetSkin(1) end
	}
end

SWEP.FakeMagDropBone = "glock_mag"
SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_crossbow")
SWEP.IconOverride = "vgui/wep_jack_hmcd_crossbow"
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = ""
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Armature"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 1
SWEP.Primary.Sound = {"weapons/crossbow/fire1.wav", 75, 90, 100}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = 0.1
SWEP.ReloadTime = 3
SWEP.DeploySnd = {"weapons/crossbow/crossbow_deploy.wav", 55, 100, 110}
SWEP.HolsterSnd = {"snds_jack_gmod/ez_weapons/amsr/in.wav", 45, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-4, 2.22, 6.8796)
SWEP.RHandPos = Vector(0,0,0)
SWEP.LHandPos = Vector(13,0,0)
SWEP.Ergonomics = 0.8
SWEP.WorldPos = Vector(0,1.1,-1)
SWEP.WorldAng = Angle(2, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0,0,2)
SWEP.attAng = Angle(-90,0,0)
SWEP.lengthSub = 25
SWEP.DistSound = ""
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(5, 11, -4)
SWEP.holsteredAng = Angle(-150, -10, 180)

SWEP.OpenBolt = true
SWEP.SprayRand = {Angle(-0.05, -0.01, 0), Angle(-0.1, 0.01, 0)}
SWEP.SprayRandOnly = true
SWEP.scopedef = true

SWEP.mat = Material("effects/arc9/rt")
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_30mm_march_tactical_3-24x42_marks.png")
SWEP.sizeperekrestie = 4200

SWEP.handsAng = Angle(-5, -1, 0)

SWEP.localScopePos = Vector(-14,-0.365,2.39)
SWEP.scope_blackout = 330
SWEP.rot = 0
SWEP.FOVMin = 6
SWEP.FOVMax = 15
SWEP.perekrestieSize = false
SWEP.blackoutsize = 3100

SWEP.ReloadSound = "weapons/crossbow/reload1.wav"
SWEP.ReloadSoundes = {
	"none",
	"weapons/tfa_hl2r/crossbow/crossbow_deploy.wav",
	"none",	
	"weapons/tfa_hl2r/crossbow/bolt_load2.wav",
	"none",
	"weapons/tfa_hl2r/ar2/weapon_movement1.wav",
	"none",
	"none",
	"none"
}
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 5
SWEP.addSprayMul = 2

SWEP.Penetration = 40

SWEP.weight = 3

SWEP.RestPosition = Vector(21, -1, 2)

function SWEP:Shoot(override)
	if not self:CanPrimaryAttack() then return false end
	if not self:CanUse() then return false end
	if self:Clip1() == 0 then return end
	local primary = self.Primary
	if not self.drawBullet then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		return false
	end
	local owner = self:GetOwner()
	if primary.Next > CurTime() then return false end
	if (primary.NextFire or 0) > CurTime() then return false end
	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	primary.Automatic = weapons.Get(self:GetClass()).Primary.Automatic
	
	local tr,pos,ang = self:GetTrace(true)
	local owner = self:GetOwner()
	
	if SERVER then
		local dist, point = util.DistanceToLine(pos, pos - ang:Forward() * 50, owner:EyePos())

		--if(GetGlobalBool("PhysBullets_ReplaceDefault", false))then
		local bullet = {}
			-- bullet.Num = 1
		bullet.Pos = point
		bullet.Dir = ang:Forward()
		bullet.Speed = 310
			-- bullet.Force = ammotype.Force or primary.Force
		bullet.Damage = 500
		bullet.Force = 80
			-- bullet.Size = 0.5
			-- bullet.Spread = ammotype.Spread or self.Primary.Spread or 0
		bullet.AmmoType = "Armature"
		bullet.Attacker = owner.suiciding and Entity(0) or owner
		bullet.IgnoreEntity = not owner.suiciding and (owner.InVehicle and owner:InVehicle() and owner:GetVehicle() or hg.GetCurrentCharacter(owner)) or nil
			-- bullet.Callback = bulletHit
			-- bullet.TracerName = self.Tracer or "nil"
			-- bullet.Speed = ammotype.Speed
			-- bullet.Distance = ammotype.Distance or 56756
		bullet.Penetration = 10

		hg.PhysBullet.CreateBullet(bullet)
			-- self:FireBullets(bullet)
		--else
		--	local projectile = ents.Create("crossbow_projectile")
		--	projectile:SetPos(point)
		--	projectile:SetAngles(ang)
		--	projectile:Spawn()
		--	projectile.Penetration = -(-self.Penetration)
--
		--	local phys = projectile:GetPhysicsObject()
		--	if IsValid(phys) then
		--		phys:SetVelocity(self:GetOwner():GetVelocity() + ang:Forward() * 9000)
		--	end
		--end
	end

	self:EmitShoot()
	self:PrimarySpread()
	self:TakePrimaryAmmo(1)
	self:GetWM():SetSkin(0)
	self:PlayAnim("fire",1,false,nil,false,false,true)
end
SWEP.dort = true

if CLIENT then
	function SWEP:DrawHUDAdd()
		//self:DoRT()
	end

	function SWEP:ReloadStart()
		if not self or not IsValid(self:GetOwner()) then return end
		hook.Run("HGReloading", self)
		--self:SetHold(self.ReloadHold or self.HoldType)
		--self:GetOwner():SetAnimation(PLAYER_RELOAD)
	end

	function SWEP:ReloadEnd()
		self:GetWeaponEntity():SetBodygroup(1,0)
		self:SetBodygroup(1,0)

		self:InsertAmmo(1)
		self.ReloadNext = CurTime() + self.ReloadCooldown
		self:Draw()
	end

	function SWEP:ModelCreated(model)
		model:SetSubMaterial(2,"effects/arc9/rt")
		model:SetSkin(self:Clip1() < 1 and 0 or 1)
	end

	function SWEP:OwnerChanged()
		if !IsValid(self:GetWM()) then return end
		
		self:PlayAnim( self:Clip1() < 1 and "idle_empty" or "idle_is",10,nil,nil,nil,true)
		self:GetWM():SetSkin(self:Clip1() < 1 and 0 or 1)
	end
end
SWEP.NoWINCHESTERFIRE = true

function SWEP:AnimHoldPost(model)

end

SWEP.LocalMuzzlePos = Vector(25.041,2.587,3.508)
SWEP.LocalMuzzleAng = Angle(2.264,0,0)
SWEP.WeaponEyeAngles = Angle(-2,0,0)

SWEP.CanSuicide = true

--local to head
SWEP.RHPos = Vector(5.5,-7.5,4)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(14,-1,-5)
SWEP.LHAng = Angle(-90,-90,-90)

local finger1 = Angle(-15,0,5)
local finger2 = Angle(-15,45,-5)

--RELOAD ANIMS PISTOL

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-7,10,-10),
	Vector(-2,-5,0),
	Vector(1,-9,5),
	Vector(1,-7,0),
	"reloadend",
	Vector(-4,-1,0),
	Vector(0,0,0),
	Vector(0,0,0)
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(-180,180,0),
	Angle(-180,180,-45),
	Angle(-180,180,15),
	Angle(-185,185,15),
	Angle(-2,5,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-5,16,1),
	Angle(-3,14,2),
	Angle(12,15,-1),
	Angle(-5,14,0),
	Angle(0,16,0),
	Angle(0,-2,-2),
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