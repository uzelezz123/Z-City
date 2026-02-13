local weapon_class = "weapon_bleeding_musket"
local SWEP = {}
SWEP.Primary = {}
SWEP.Secondary = {}

if SERVER then AddCSLuaFile() end

--\\Nets
	if(SERVER)then
		util.AddNetworkString("Abnormalties_ShootWeapon")
	else
		net.Receive("Abnormalties_ShootWeapon", function()
			local wep = net.ReadEntity()
			
			if(IsValid(wep) and wep.Abnormalties_ShootableWeapon)then
				wep:EmitShoot()
				wep:PrimarySpread()
			end
		end)
	end
--//

SWEP.Abnormalties_ShootableWeapon = true
SWEP.Base = "weapon_m4super"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Bleeding Musket"
SWEP.Author = "N/A"
SWEP.Instructions = [[
It does appear that this musket does bleed indeed.
Hold LMB to charge up and shoot a blood projectile.
Shooting requires 1000 of your blood or 2000 of your abnormal blood (sums up).
Applies incredible pain and disorientation through shots.
Dissolves anything what can not experience pain.
Completely ignores armor.
Bullets have high penetration.
60 PAIN
10 DISORIENTATION
or
80 DISSOLVE
[HE]
]]
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/esw/w_long_land_pattern.mdl"
SWEP.ScrappersSlot = "Primary"
SWEP.WepSelectIcon2 = Material("entities/zcity/bloodymusket.png")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "entities/zcity/bloodymusket.png"
SWEP.weight = 3
SWEP.CanSuicide = true
SWEP.weaponInvCategory = 1
SWEP.EjectPos = Vector(0,5,5)
SWEP.EjectAng = Angle(-5,180,0)
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = false
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "20mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = Vector(0.001, 0.001, 0.001)
SWEP.Primary.Damage = 85
SWEP.Primary.Force = 85
SWEP.NumBullet = 1
SWEP.Primary.Sound = {"weapons/awoi/musket_5_fire.wav", 65, 60, 65}
SWEP.SupressedSound = {"weapons/awoi/musket_5_fire.wav", 65, 60, 65}
SWEP.availableAttachments = {
	--[[barrel = {
		[1] = {"supressor1", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(0.8,0.5,0),
	},]]
}

SWEP.PPSMuzzleEffect = "muzzleflash_M3" -- shared in sh_effects.lua

SWEP.ShockMultiplier = 5
SWEP.ShellEject = ""
SWEP.LocalMuzzlePos = Vector(-38,-0.65,0.5)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.handsAng = Angle(0, 0, 0)
SWEP.handsAng2 = Angle(-3, -2, 0)

SWEP.CockSound = "weapons/tfa_ins2/mosin/mosin_boltforward.wav"
SWEP.ReloadSound = "weapons/awoi/musket_reload.wav"

SWEP.ReloadDrawTime = 0.3
SWEP.ReloadDrawCooldown = 0.4
SWEP.ReloadInsertTime = 0.15
SWEP.ReloadInsertCooldown = 0.15
SWEP.ReloadInsertCooldownFire = 0.15
SWEP.OpenBolt = false

SWEP.Primary.Wait = 0.35
SWEP.NumBullet = 1
SWEP.AnimShootMul = 0.5
SWEP.AnimShootHandMul = 0.5
SWEP.ReloadTime = 7
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, 0.733, 1.3301)
SWEP.RHandPos = Vector(-8, -2, 6)
SWEP.LHandPos = Vector(6, -3, 1)
SWEP.AimHands = Vector(-10, 1.8, -6.1)
SWEP.SprayRand = {Angle(0.02, -0.02, 0), Angle(-0.02, 0.02, 0)}
SWEP.Ergonomics = 0.4
SWEP.Penetration = 100
SWEP.ZoomFOV = 20
SWEP.WorldPos = Vector(9.5, -0.4, -3)
SWEP.WorldAng = Angle(0, 180, 0)
SWEP.LocalMuzzleAng = Angle(0, 180, 0)
SWEP.UseCustomWorldModel = true
SWEP.handsAng = Angle(-6, -1, 0)
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("decals/perekrestie8.png", "smooth")
SWEP.localScopePos = Vector(-21, 3.25, -0.2)
SWEP.scope_blackout = 400
SWEP.maxzoom = 3.5
SWEP.rot = 37
SWEP.FOVMin = 3.5
SWEP.FOVMax = 10
SWEP.huyRotate = 25
SWEP.FOVScoped = 40

SWEP.DistSound = "toz_shotgun/toz_dist.wav"--SWEP.DistSound = "weapons/awoi/musket_1_fire.wav"
SWEP.lengthSub = 25
SWEP.ShootAnimMul = 12
SWEP.punchmul = 1
SWEP.punchspeed = 1
SWEP.podkid = 2

SWEP.holsteredPos = Vector(-14, -4, -12)
SWEP.holsteredAng = Angle(320, 0, 0)

SWEP.attPos = Vector(0.5,-3.5,75)
SWEP.attAng = Angle(-0.1,.4,0)

SWEP.bipodAvailable = false
SWEP.bigNoDrop = true

--local to head
-- SWEP.RHPos = Vector(3,-3.8,3)
SWEP.RHPos = Vector(3,-3.8,3)
SWEP.RHAng = Angle(-8,-30,65)

--local to rh
SWEP.LHPos = Vector(17,0,-3.5)
-- SWEP.LHPos = Vector(17,-1,-3.5)
SWEP.LHAng = Angle(-90,-0,-180)

local finger1 = Angle(10, -20, 0)
local finger2 = Angle(-0, 90, 0)
local finger3 = Angle(0, -25, 0)
local finger4 = Angle(0, -10, 0)

function SWEP:AnimHoldPost(model)
	if self.reload then return end

end

function SWEP:PrimaryShootPost()
	local att = self:GetMuzzleAtt(gun, true)
	local eff = EffectData()
	eff:SetOrigin(att.Pos + att.Ang:Up() * -82 + att.Ang:Forward() * -2)
	eff:SetNormal(att.Ang:Forward())
	eff:SetScale(2)
	util.Effect("eff_jack_rockettrust", eff)
end

local anims = {
	Vector(0,0,0),
	Vector(1,0,1),
	Vector(2,1,2),
	Vector(3,2,0),
	Vector(4,3,0),
	Vector(4,4,-1),
}

function SWEP:AnimationPost()
	self:BoneSet("l_finger0", Vector(0, 0, 0), Angle(-10, -25, 0))

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
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-2,0,6),
	Vector(-2,0,6),
	Vector(-1,-2,7),
	Vector(0,-2,8),
	Vector(0,-2,8),
	Vector(0,-2,7),
	Vector(0,0,5),
	Vector(-2,0,6),
	Vector(-2,0,6),
	Vector(-1,-2,7),
	Vector(0,-2,8),
	Vector(0,-2,8),
	Vector(0,-2,7),
	Vector(0,0,5),
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,-25,90),
	Angle(0,-25,90),
	Angle(0,-25,160),
	Angle(0,-25,160),
	Angle(0,-25,160),
	Angle(0,-25,160),
	Angle(0,-25,90),
	Angle(0,-25,90),
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,10,50),
	Angle(0,25,45),
	Angle(0,25,45),
	Angle(5,25,45),
	Angle(3,25,45),
	Angle(0,25,45),
	Angle(0,25,45),
	Angle(5,25,45),
	Angle(3,25,45),
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

--; models/flesh

--\\Locals
	--; https://wiki.facepunch.com/gmod/surface.DrawPoly
	local function draw_Circle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is needed for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end
--//

function SWEP:PostSetupDataTables()
	self:NetworkVar("Float", 2, "Charge")
end

function SWEP:CanShootBlood()
	local ply = self:GetOwner()
	
	if(ply.organism)then
		local blood_total = ply.organism.blood
		ply.Abnormalties_Blood = ply.Abnormalties_Blood or 0
		blood_total = blood_total + ply.Abnormalties_Blood / 2
		
		if(blood_total >= 1000)then
			return true
		end
	else
		return false
	end
end

function SWEP:DrawBlood()
	local ply = self:GetOwner()
	
	if(ply.organism)then
		ply.Abnormalties_Blood = ply.Abnormalties_Blood or 0
		
		if(ply.Abnormalties_Blood >= 2000)then
			ply.organism.pulse = ply.organism.pulse + 15
		else
			ply.organism.pulse = ply.organism.pulse + 40
		end
		
		local blood_required = 1000
		local blood_take = math.min(ply.Abnormalties_Blood / 2, blood_required)
		ply.Abnormalties_Blood = ply.Abnormalties_Blood - blood_take * 2
		blood_required = blood_required - blood_take
		blood_take = math.min(ply.organism.blood, blood_required)
		ply.organism.blood = ply.organism.blood - blood_take
		blood_required = blood_required - blood_take
	end
end

local charge_up = 100
local charge_down = 100

--; ambient/energy/electric_loop.wav
--; physics/metal/metal_box_scrape_rough_loop1.wav
--; physics/concrete/rock_scrape_rough_loop1.wav
--; physics/cardboard/cardboard_box_scrape_rough_loop1.wav
--; ambient/fire/fire_med_loop1.wav
--; ambient/fire/firebig.wav
--; 

function SWEP:DrawPost()
	self.ZLastStep = self.ZLastStep or 0
	
	self:SetMaterial("models/flesh")
	
	if(CurTime() - self.ZLastStep > 0.5)then
		self:SetCharge(0)
	
		local c_sound = self.CSoundCharge
		
		if(c_sound)then
			c_sound:Stop()
			
			self.CSoundCharge = nil
		end
	end
	
	local charge = self:GetCharge()
	
	if(charge > 0)then
		self.ZVisualsTime = (self.ZVisualsTime or 0) + FrameTime() * charge * 10
		local world_model = self.worldModel
		local draw_pos = world_model:GetRenderOrigin()
		local draw_ang = world_model:GetRenderAngles()
		
		if(draw_ang and draw_pos)then
			draw_pos = draw_pos + draw_ang:Forward() * -50
			draw_pos = draw_pos + draw_ang:Right() * 0.7
			draw_pos = draw_pos + draw_ang:Up() * 0.7
			
			draw_ang:RotateAroundAxis(draw_ang:Right(), 90)
			draw_ang:RotateAroundAxis(draw_ang:Up(), self.ZVisualsTime)
			
			if(IsValid(world_model))then
				for i = 1, 2 do
					cam.Start3D2D(draw_pos, draw_ang, 0.005 * charge)
						surface.SetDrawColor(150, 0, 0)
						draw.NoTexture()
						draw_Circle(15, 15, 2, 12)
						draw_Circle(-15, 15, 2, 12)
						draw_Circle(-15, -15, 2, 12)
						draw_Circle(15, -15, 2, 12)
						surface.DrawCircle(0, 0, 50, 150, 0, 0)
					cam.End3D2D()
					
					draw_ang:RotateAroundAxis(draw_ang:Right(), 180)
				end
			end
		end
	end
end

function SWEP:Step()
	self:CoreStep()
	
	self.ZLastStep = CurTime()
	
	if(CLIENT)then
		local world_model = self.worldModel
		
		if(IsValid(world_model))then
			world_model:SetMaterial("models/flesh")
		end
		
		local charge = self:GetCharge()
		local c_sound = self.CSoundCharge
		
		if(charge > 0)then
			if(!c_sound)then
				self.CSoundCharge = CreateSound(self, "physics/cardboard/cardboard_box_scrape_rough_loop1.wav")
				-- self.CSoundCharge = CreateSound(self, "physics/metal/metal_box_scrape_rough_loop1.wav")
				c_sound = self.CSoundCharge
			end
			
			if(!c_sound:IsPlaying())then
				c_sound:Play()
			end
			
			c_sound:ChangePitch(charge * 2)
		else
			if(c_sound)then
				c_sound:Stop()
				
				self.CSoundCharge = nil
			end
		end
	end
	
	local owner = self:GetOwner()
	local shot_charge_changed = false
	
	if(owner:IsPlayer() and owner:GetActiveWeapon() == self)then
		if(owner:KeyDown(IN_ATTACK) and self:CanShootBlood())then
			self.ShotChargeUp = math.min((self.ShotChargeUp or 0) + FrameTime() * charge_up, 100)
			shot_charge_changed = true
			
			if(self.ShotChargeUp >= 100)then
				local pos, ang = self:GetTrace(true, nil, nil, true)
				
				if(SERVER)then
					local dist, point = util.DistanceToLine(pos, pos - ang:Forward() * 20, owner:EyePos())
					local bullet = {}
					bullet.Pos = point
					bullet.Dir = ang:Forward()
					bullet.Speed = 310
					bullet.Damage = 0
					bullet.Force = 100
					bullet.AmmoType = "Blood"
					bullet.Attacker = owner.suiciding and Entity(0) or owner
					bullet.IgnoreEntity = not owner.suiciding and (owner.InVehicle and owner:InVehicle() and owner:GetVehicle() or owner) or nil
					bullet.Penetration = 50
					
					hg.PhysBullet.CreateBullet(bullet)
					self:DrawBlood()
					self:EmitShoot()
					self:PrimarySpread()
					
					net.Start("Abnormalties_ShootWeapon")
						net.WriteEntity(self)
					net.Send(owner)
				end
				
				self.ShotChargeUp = 0
				shot_charge_changed = true
			end
		else
			if(self.ShotChargeUp != 0)then
				self.ShotChargeUp = math.max((self.ShotChargeUp or 0) - FrameTime() * charge_down, 0)
				shot_charge_changed = true
			end
		end
	else
		if(self.ShotChargeUp != 0)then
			self.ShotChargeUp = 0
			shot_charge_changed = true
		end
	end
	
	if(SERVER)then
		if(shot_charge_changed)then
			self:SetCharge(self.ShotChargeUp)
		end
	end
end

function SWEP:Shoot(override)
	--[[
	if not self:CanUse() then return false end
	local primary = self.Primary
	
	if not self.drawBullet then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		return false
	end
	local owner = self:GetOwner()
	-- if primary.Next > CurTime() then return false end
	-- if (primary.NextFire or 0) > CurTime() then return false end
	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	primary.Automatic = weapons.Get(self:GetClass()).Primary.Automatic
	
	local tr,pos,ang = self:GetTrace(true)
	local owner = self:GetOwner()
	
	if(SERVER)then
		local dist, point = util.DistanceToLine(pos, pos - ang:Forward() * 50, owner:EyePos())
		local bullet = {}
		bullet.Pos = point
		bullet.Dir = ang:Forward()
		bullet.Speed = 310
		bullet.Damage = 350
		bullet.Force = 10
		bullet.AmmoType = "Armature"
		bullet.Attacker = owner.suiciding and Entity(0) or owner
		bullet.IgnoreEntity = not owner.suiciding and (owner.InVehicle and owner:InVehicle() and owner:GetVehicle() or owner) or nil
		bullet.Penetration = 10

		hg.PhysBullet.CreateBullet(bullet)
	end

	self:EmitShoot()
	-- self:PrimarySpread()
	-- self:TakePrimaryAmmo(1)
	]]
end

weapons.Register(SWEP, weapon_class)