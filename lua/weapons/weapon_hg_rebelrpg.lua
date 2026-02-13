SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "Rebel RPG"
SWEP.Author = "Degtyarev plant"
SWEP.Instructions = "The Rebellion RPG is a portable unguided shoulder-launched anti-tank rocket launcher."
SWEP.Category = "Weapons - Grenade Launchers"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.WorldModelFake = "models/mmod/weapons/c_rpg.mdl"

SWEP.FakePos = Vector(-20, 5, 8)
SWEP.FakeAng = Angle(0, -0.5, 0)
SWEP.AttachmentPos = Vector(0.3,3.8,-13)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "laser"
SWEP.FakeVPShouldUseHand = true

SWEP.WepSelectIcon2 = Material("entities/zcity/rebelrpg.png")
SWEP.IconOverride = "entities/zcity/rebelrpg.png"

SWEP.weight = 6
SWEP.ScrappersSlot = "Primary"

SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(1,2,2)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 20

SWEP.weaponInvCategory = 1
SWEP.ShellEject = ""
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "RPG-7 Projectile"--rpg rounds
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 1
SWEP.Primary.Sound = {"weapons/mmod/rpg/rocketfire1.wav", 75, 90, 100}
SWEP.Primary.Force = 75
SWEP.Primary.Wait = 2
SWEP.ReloadTime = 2.3
SWEP.DeploySnd = {"weapons/ins2rpg7/handling/rpg7_fetch.wav", 75, 100, 110}
SWEP.HolsterSnd = {"weapons/ins2rpg7/handling/rpg7_endgrab.wav", 75, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-9, 0.9409, 6.6108)
SWEP.RHandPos = Vector(0,0,0)
SWEP.LHandPos = false--Vector(13,0,0)
SWEP.Ergonomics = 0.5
SWEP.WorldPos = Vector(-5,-4,0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0,-4,13)
SWEP.attAng = Angle(0,0,0)
SWEP.lengthSub = 25
SWEP.DistSound = "weapons/newsndw/newrpg7_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(12,-9,-12)
SWEP.holsteredAng = Angle(0, 0,-90)
SWEP.OpenBolt = true
SWEP.SprayRand = {Angle(-0.05, -0.01, 0), Angle(-0.1, 0.01, 0)}
SWEP.SprayRandOnly = true
SWEP.Penetration = 10
SWEP.ReloadSound = "weapons/tfa_hl2r/rpg/rpg_reload1.wav"
SWEP.ReloadHold = "pistol"
SWEP.AnimShootMul = 5
SWEP.AnimShootHandMul = 5
SWEP.addSprayMul = 1
SWEP.ReloadTime = 5
SWEP.CanSuicide = false
SWEP.ShootAnimMul = 8
SWEP.punchmul = 8
SWEP.punchspeed = 6
SWEP.podkid = 1
--local to head
SWEP.RHPos = Vector(14,-6,7)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(-6,0,-4.5)
SWEP.LHAng = Angle(-0,0,-100)

SWEP.availableAttachments = {}

function SWEP:InitializePost()
	self.attachments.underbarrel = {[1] = "laserrpg0"}
end

SWEP.NoIdleLoop = true
SWEP.AnimList = {
	["idle"] = "idle01",
	["reload"] = "reload",
	["reload_empty"] = "reload",
}

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

	if primary.Next > CurTime() then return false end
	if (primary.NextFire or 0) > CurTime() then return false end
	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	primary.Automatic = weapons.Get(self:GetClass()).Primary.Automatic

    local gun = self:GetWeaponEntity()
	local tr, pos, ang = self:GetTrace(true)
	self:TakePrimaryAmmo(1)
	if SERVER then
		local projectile = ents.Create("rpg_projectile")
		projectile.owner = self:GetOwner()
		projectile:SetPos(pos + ang:Forward() * (self:GetOwner():GetVelocity():Length()/3) + ang:Right() * -6 + ang:Up() * 2)
		projectile:SetAngles(ang)
		projectile:SetOwner(IsValid(self:GetOwner()) and (self:GetOwner():InVehicle() and self:GetOwner():GetVehicle() or self:GetOwner()) or self)
		projectile:Spawn()
		projectile:SetModel("models/weapons/tfa_hl2r/w_missile_launch.mdl")
		timer.Simple(.1, function()
			if IsValid(projectile) then
				projectile:SetModel("models/weapons/tfa_hl2r/w_missile_launch.mdl")
			end
		end)
		projectile.Penetration = -(-self.Penetration)

		local phys = projectile:GetPhysicsObject()
		if IsValid(phys) then
			local initialVelocity = self:GetOwner():GetVelocity() + ang:Forward() * 5249
			phys:SetVelocity(initialVelocity)
			phys:EnableGravity(false)
			timer.Simple(0.2, function()
				if IsValid(projectile) and IsValid(phys) then
					phys:EnableGravity(true)
				end
			end)
		end
		--for i, ent in ipairs(ents.FindInCone(pos, -ang:Forward(), 128, 0.8)) do
		--	if not ent:IsPlayer() then continue end
		--	if ent == hg.GetCurrentCharacter( self:GetOwner() ) then return end
		--	local d = DamageInfo()
		--	d:SetDamage( 4000 )
		--	d:SetAttacker( self:GetOwner() )
		--	d:SetDamageType( DMG_BURN )
		--	d:SetDamagePosition( pos - ang:Forward() * 10 )
--
		--	ent:TakeDamageInfo( d )
--
		--	d:SetDamage( 400 )
		--	d:SetAttacker( self:GetOwner() )
		--	d:SetDamageType( DMG_CLUB )
		--	d:SetDamagePosition( pos - ang:Forward() * 10 )
--
		--	ent:TakeDamageInfo( d )
		--end
	end

	self:EmitShoot()
	--self:PrimarySpread()
	self:PlayAnim("fire",1,false,nil,false,false,true)
end

if CLIENT then
	local vector_full = Vector(1, 1, 1)
	function SWEP:ReloadStart()
		if not self or not IsValid(self:GetOwner()) then return end
		hook.Run("HGReloading", self)
		self:SetHold(self.ReloadHold or self.HoldType)
		self:GetOwner():SetAnimation(PLAYER_RELOAD)
		if self.ReloadSound then self:GetOwner():EmitSound(self.ReloadSound, 60, 100, 0.8, CHAN_AUTO) end
	end

	function SWEP:ReloadEnd()
		self:InsertAmmo(1)
		self.ReloadNext = CurTime() + self.ReloadCooldown
		self:Draw()
	end

	function SWEP:ModelCreated(model)
		model:ManipulateBoneScale(39, vector_origin)
	end

	SWEP.FakeReloadEvents = {
		[0.15] = function( self, timeMul )
			local wm = self:GetWM()
			wm:ManipulateBoneScale(39, vector_full)
		end,
		[0.75] = function(self, timeMul)
			local wm = self:GetWM()
			wm:ManipulateBoneScale(39, vector_origin)
		end,
	}

	function SWEP:Reload(time)
		if not time then return end
		local ply = self:GetOwner()
		if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end
		self.LastReload = time
		self:ReloadStart()
		self:ReloadStartPost()
		--self.StaminaReloadTime = -- self.ReloadTime * ( IsValid( self:GetOwner() ) and self:GetOwner().organism and self:GetOwner().organism.stamina and 2 -(self:GetOwner().organism.stamina[1] / 180 ) or 1 )
		self.reload = time + (self.StaminaReloadTime or self.ReloadTime) + 0.05
		if self:ShouldUseFakeModel() then
			self:PlayAnim(self:Clip1() == 0 and "reload_empty" or "reload", (self.StaminaReloadTime or self.ReloadTime), false, function()
				self:PlayAnim("idle", 1, not self.NoIdleLoop)
			end)
		end
		self:Step_Reload(CurTime() - 1)
		self.dwr_reverbDisable = true
	end
end
SWEP.NoWINCHESTERFIRE = true

SWEP.CanSuicide = false

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(17,2,3),
	Vector(14,0,3),
	Vector(10,1,3),
	Vector(-1,-2,-7),
	Vector(-1,-2,-7),
	Vector(-1,-1,-7),
	Vector(-1,-1,-7),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(0,5,25),
	Angle(0,5,25),
	Angle(5,5,25),
	Angle(3,5,25),
	Angle(0,0,0)
}

-- Inspect Assault
SWEP.LocalMuzzlePos = Vector(13,-4.5,4)
SWEP.LocalMuzzleAng = Angle(1,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)
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