SWEP.Base = "weapon_base"
SWEP.PrintName = "base_hg"
SWEP.Category = "Other"
SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.ReloadTime = 1
SWEP.ReloadSound = "weapons/smg1/smg1_reload.wav"
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m14/handling/m14_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.1
SWEP.Primary.Next = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.shouldntDrawHolstered = false
hg.weapons = hg.weapons or {}

SWEP.ishgwep = true

SWEP.EyeSprayVel = Angle(0,0,0)

SWEP.ScrappersSlot = "Primary"
--[type_] = {1 = name,2 = dmg,3 = pen,4 = numbullet,5 = RubberBullets,6 = ShockMultiplier,7 = Force},
SWEP.AmmoTypes2 = {
	["12/70 gauge"] = {
		[1] = {"12/70 gauge"},
		[2] = {"12/70 beanbag"},
		[3] = {"12/70 Slug"},
		[4] = {"12/70 RIP"},
		[5] = {"12/70 Blank"}
	},
	["9x19 mm Parabellum"] = {
		[1] = {"9x19 mm Parabellum"},
		[2] = {"9x19 mm Green Tracer"},
		[3] = {"9x19 mm QuakeMaker"}
	}, 
	["5.56x45 mm"] = {
		[1] = {"5.56x45 mm"},
		[2] = {"5.56x45 mm M856"},
		[3] = {"5.56x45 mm AP"}
	},
	["7.62x39 mm"] = {
		[1] = {"7.62x39 mm"},
		[2] = {"7.62x39 mm SP"},
		[3] = {"7.62x39 mm BP gzh"}
	},
	["7.62x51 mm"] = {
		[1] = {"7.62x51 mm"},
		[2] = {"7.62x51 mm M993"}
	},
	["14.5x114mm B32"] = {
		[1] = {"14.5x114mm B32"},
		[2] = {"14.5x114mm BZTM"}
	},
	[".45 ACP"] = {
		[1] = {".45 ACP"},
		[2] = {".45 ACP Hydro Shock"},
	},
	[".50 Action Express"] = {
		[1] = {".50 Action Express"},
		[2] = {".50 Action Express Copper Solid"},
		[3] = {".50 Action Express JHP"}
	},
	["9mm PAK Blank"] = {
		[1] = {"9mm PAK Blank"},
		[2] = {"9mm PAK Flash Defense"},
	},
	["18x45mm Traumatic"] = {
		[1] = {"18x45mm Traumatic"}, -- T
		[2] = {"18x45mm Flash Defense"}, -- LAS
	},
	["23x75 SH10"] = {
		[1] = {"23x75 SH10"},
		[2] = {"23x75 SH25"},
		[3] = {"23x75 Barricade"},
		[4] = {"23x75 Zvezda"},
		[5] = {"23x75 Waver"}
	},
}

function SWEP:OnReloaded()
	if self.newammotype then
		self:ApplyAmmoChanges(self.newammotype)
	end
	hook.Run("OnReloadedWep", self)
end

SWEP.CanSuicide = true

game.AddParticles("particles/tfa_smoke.pcf")
PrecacheParticleSystem("smoke_trail_tfa")
PrecacheParticleSystem("smoke_trail_wild")

local vector_full = Vector(1, 1, 1)

if CLIENT then
	SWEP.HowToUseInstructions = "<font=ZCity_Tiny>"..string.upper( (input.LookupBinding("+use") or "BIND YOUR +USE KEY PLEASE. WRITE \"bind e +use\" IN CONSOLE FOR THE LOVE OF GOD") ).." to pickup</font>"
end
SWEP.StartAtt = {}
function SWEP:Initialize()
	self:SetLastShootTime(0)
	self.LastPrimaryDryFire = 0
	self:Initialize_Spray()
	self:Initialize_Anim()
	self:Initialize_Reload()
	self:SetClip1(self.Primary.DefaultClip)
	self:Draw()

	self.AdditionalPos = Vector(0,0,0)
	self.AdditionalPos2 = Vector(0,0,0)
	self.AdditionalAng = Angle(0,0,0)
	self.AdditionalAng2 = Angle(0,0,0)

	if CLIENT then
		self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>".. self.PrintName .."</font>\n<font=ZCity_SuperTiny><colour=125,125,125>".. self.HowToUseInstructions .."</colour></font>",450)
	end

	self:MapEvents()

	if self:GetOwner():IsNPC() then
		if self.HoldType == "rpg" then
			self.HoldType = "smg"
		end
		self:SetHoldType( self.HoldType )
	end
	
	self.SlotPos = self:IsPistolHoldType() and 1 or 2

	self.deploy = CurTime() + self.CooldownDeploy / self.Ergonomics

	self:ClearAttachments()

	self.AmmoTypes = self.AmmoTypes2[self.Primary.Ammo]

	self:WorldModel_Transform()

	table.insert(hg.weapons,self)
	self.ishgweapon = true

	if SERVER then
		self:SetNetVar("attachments",self.attachments)
	end

	if CLIENT then
		if not IsValid(self.worldModel) then
			self:CreateWorldModel()
		end

		self:CallOnRemove("flashlightRemove", function()
			if self.flashlight and self.flashlight:IsValid() then
				self.flashlight:Remove()
				self.flashlight = nil
			end
		end)
	end

	self:AddCallback("PhysicsCollide", function(ent, data)
		self:PhysicsCollide(ent, data)
	end)

	self.init = false
	
	timer.Simple(0.1,function()
		if IsValid(self) and self.PlayAnim then self:PlayAnim("idle", 0, not self.NoIdleLoop) end
		if self.AmmoTypes and SERVER then
			self:ApplyAmmoChanges(1)
		end
	end)

	if SERVER then hg.SyncWeapons() end
	self:InitializePost()
end

function SWEP:PhysicsCollide(ent, data)
	if !self.CantFireFromCollision and (!self.lastshotfromhit or (self.lastshotfromhit + 0.5 < CurTime())) and data.Speed > 250 and math.random(45) == 1 then
		self:PrimaryAttack()
		self.lastshotfromhit = CurTime()
	end
end

SWEP.WepSelectIcon2 = Material("null")
SWEP.IconOverride = ""

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( self.WepSelectIcon2 )
	if not self.IconEdited then
		self.WepSelectIcon2:SetInt("$flags", 32)
		self.IconEdited = true
	end
	if self.WepSelectIcon2box then
		surface.DrawTexturedRect( x + wide/2 - (wide/1.95)/2, y,  wide/1.95 , wide/1.95 )
	else
		surface.DrawTexturedRect( x, y,  wide , wide/2)
	end

	render.PopFilterMin()
	render.PopFilterMag()

	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )

end

if CLIENT then
	hook.Add("OnGlobalVarSet","hg-weapons",function(key,var)
		if key == "weapons" then
			hg.weapons = var
		end
	end)

	hook.Add("OnNetVarSet","weapons-net-var",function(index,key,var)
		if key == "attachments" then
			local ent = Entity(index)

			ent.attachments = nil
			if ent.modelAtt then
				for atta, model in pairs(ent.modelAtt) do
					if not atta then continue end
					if IsValid(model) then model:Remove() end
					ent.modelAtt[atta] = nil
				end
			end

			ent.attachments = var
		end
	end)
else
	function hg.SyncWeapons()
		SetNetVar("weapons",hg.weapons)
	end
end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:OwnerChanged()
	self.init = true
	self.reload = nil
	
	if CLIENT and IsValid(self.worldModel) then
		--self.worldModel:Remove()
	end

	//self:PlayAnim("idle", 1, not self.NoIdleLoop)

	self:SetClip1(self:Clip1()) -- cuz it's not networked sometimes for whatver reason

	if not IsValid(self:GetOwner()) then
		self.deploy = nil
		self:SetDeploy(0)
	
		self.holster = nil
		self:SetHolster(0)
		
		return
	else
		self.SlotPos = self:IsPistolHoldType() and 1 or 2
	end

	if SERVER then
		self:SetNetVar("attachments",self.attachments)
	end
end

function SWEP:InitializePost()
end

hg.weaponsDead = hg.weaponsDead or {}
function SWEP:OnRemove()
	if SERVER then
		table.RemoveByValue(hg.weapons,self)

		SetNetVar("weapons",hg.weapons)
	end
end

local owner
local CurTime = CurTime
function SWEP:IsZoom()
	local owner = self:GetOwner()
	--print( (owner.armors and (hg.armor.head[owner.armors["head"]] and not hg.armor.head[owner.armors["head"]].cantsight)))
	return self:CanUse() and
		(self:GetButtstockAttack() - CurTime() < -1) and 
		(self:GetOwner():IsPlayer() and self:KeyDown(IN_ATTACK2) and not self:KeyDown(IN_SPEED)) and
		!(self:IsSprinting() and !IsValid(owner.FakeRagdoll)) and
		((IsValid(owner.FakeRagdoll) and self:KeyDown(IN_USE)) or
		(owner:IsOnGround() or owner:InVehicle())) and 
		not owner.suiciding and !(owner.organism and (owner.organism.larm and !self:IsPistolHoldType())
		and owner.organism.rarm and (owner.organism.larm > 0.99 or owner.organism.rarm > 0.99))
		
		-- and owner.posture ~= 1 and owner.posture ~= 3-- and (not IsValid(owner.FakeRagdoll) or self:KeyDown(IN_JUMP))
end

function SWEP:CanUse()
    local owner = self:GetOwner()
	if not IsValid(owner) then return true end
    if owner:IsNPC() then return true end
	if owner.organism and owner.organism.rarmamputated and !self:IsPistolHoldType() then return false end
	return not (self.reload or self.deploy or (owner:IsPlayer() and (self:IsSprinting() or (owner.organism and owner.organism.otrub))))
end

function SWEP:IsSprinting()
	local ply = self:GetOwner()
	return not ply:IsNPC() and self:KeyDown(IN_SPEED) --[[and not (self:KeyDown(IN_ATTACK2) and not self:KeyDown(IN_WALK))]] and ply:GetVelocity():LengthSqr() > 170 * 170 and not IsValid(ply.FakeRagdoll)
end

function SWEP:IsLocal()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:IsLocal2()
	return CLIENT and self:GetOwner() == LocalPlayer() and LocalPlayer() == GetViewEntity()
end
local hg_quietshots = GetConVar("hg_quietshots") or CreateClientConVar("hg_quietshots", "0", true, false, "quieter gun sounds", 0, 1)
local hg_gunshotvolume = GetConVar("hg_gunshotvolume") or CreateClientConVar("hg_gunshotvolume", "1", true, false, "volume of gun sounds", 0, 1)

if CLIENT then
	EmitSound = hg.EmitSound

	hook.Add("InitPostEntity", "just_in_case_wep", function()
		EmitSound = hg.EmitSound
	end)
end

local math_random = math.random
function SWEP:PlaySnd(snd, server, chan, vol, pitch, entity, tripleaffirmative)
	if SERVER and not server then return end
	local owner = self:GetOwner()
	owner = IsValid(owner) and owner or self

	if CLIENT then
		local view = render.GetViewSetup(true)
		local time = owner:GetPos():Distance(view.origin) / 17836
		local playsnd1 = function()
			if not IsValid(self) then return end
			local ent = hg.GetCurrentCharacter(self:GetOwner())

			if type(snd) == "table" then
				local rand = math.random(-5,5)
				EmitSound( snd[1], owner:GetPos(), (entity or owner:EntIndex()) + owner:EntIndex(), CHAN_WEAPON, vol, snd[2] or (self.Supressor and 75 or 75), nil, (pitch or 100) + rand)
				if tripleaffirmative and !hg_quietshots:GetBool() then
					EmitSound( snd[1], owner:GetPos()-vector_up, (entity or owner:EntIndex()) + 1 + owner:EntIndex(), CHAN_WEAPON, vol, snd[2] or (self.Supressor and 75 or 75), nil, (pitch or 100) + rand)
					EmitSound( snd[1], owner:GetPos(), (entity or owner:EntIndex()) + 2 + owner:EntIndex(), CHAN_WEAPON, vol, (snd[2] or (self.Supressor and 75 or 75)) + 1, nil, (pitch or 100) + rand)
				end
				-- self:EmitSound(snd[1], (snd[2] or (self.Supressor and 75 or 75)), (pitch or 100) + rand, vol, CHAN_AUTO)
			else
				local rand = math.random(-5,5)
				EmitSound( snd, owner:GetPos(), (entity or owner:EntIndex()) + owner:EntIndex(), CHAN_WEAPON, vol, (self.Supressor and 75 or 75), nil, (pitch or 100) + rand)
				if tripleaffirmative and !hg_quietshots:GetBool() then
					EmitSound( snd, owner:GetPos()-vector_up, (entity or owner:EntIndex()) + 1 + owner:EntIndex(), CHAN_WEAPON, vol, (self.Supressor and 75 or 75), (pitch or 100) + rand)
					EmitSound( snd, owner:GetPos(), (entity or owner:EntIndex()) + 2 + owner:EntIndex(), CHAN_WEAPON, vol, ((self.Supressor and 75 or 75)) + 1, nil, (pitch or 100) + rand)
				end
				-- self:EmitSound(snd[1], ((self.Supressor and 75 or 75)), (pitch or 100) + rand, vol, CHAN_AUTO)
			end
		end
		if time > 0.1 then
			timer.Simple(time, playsnd1)
		else
			playsnd1()
		end
	else
		if type(snd) == "table" then
			EmitSound(snd[1], owner:GetPos(), owner:EntIndex(), chan or CHAN_ITEM, 1, snd[2] or (self.Supressor and 75 or 75), 0, math_random(snd[3] or 100, snd[4] or 100), 1)
		else
			EmitSound(snd, owner:GetPos(), owner:EntIndex(), chan or CHAN_ITEM, 1, self.Supressor and 75 or 75, 0, 100, 1)
		end
	end
end

hg.PlaySnd = SWEP.PlaySnd

SOUND_LEVEL_GUNFIRE = 150

function SWEP:PlaySndDist(snd)
	if SERVER then return end
	local owner = IsValid(self:GetOwner().FakeRagdoll) and self:GetOwner().FakeRagdoll or self:GetOwner()
	owner = IsValid(owner) and owner or self
	local view = render.GetViewSetup(true)
	local pos = owner:GetPos() + vector_up * 72
	local dist = owner:GetPos():Distance(view.origin)
	local time = dist / 17836
	

	local bRoom = util.IsSkyboxVisibleFromPoint(pos)
	
	timer.Simple(time, function()
		if not IsValid(self) or not IsValid(self:GetOwner()) then return end

		local owner = IsValid(self) and (IsValid(self:GetOwner()) and (IsValid(self:GetOwner().FakeRagdoll) and self:GetOwner().FakeRagdoll or self:GetOwner()) or self)
		owner = IsValid(owner) and owner
		if not owner then return end
		
		local roomMultiplier = bRoom and 1.0 or 0.7
		local suppressorVolume = self.Supressor and (self.DOZVUK and 10 or 60) or 100
		local finalVolume = suppressorVolume * roomMultiplier

		EmitSound(snd, owner:GetPos(), owner:EntIndex(), CHAN_STATIC, 1, finalVolume, 0, 90)

		local farPitch = math.Clamp(100 - (dist / 1000), 75, 95)
		if dist > 1000 then
			EmitSound(snd, owner:GetPos(), owner:EntIndex() + 1, CHAN_STATIC, 1, finalVolume * 1.2, 0, farPitch)
		end
	end)
end

local math_Rand = math.Rand
local matrix, matrixSet
local math_random = math.random
local primary
local weapons_Get = weapons.Get
if SERVER then util.AddNetworkString("hgwep shoot") end

local CantDoIt = {
	"But... There's so much to live for!",
	"I... I can't do it...",
	"There must be another way. This is not it!",
	"I... Cannot bring myself to do this.",
	"What am i even doing? I can't do this."
}
--qol lmao
function SWEP:CanPrimaryAttack()
	local owner = self:GetOwner()
	if !IsValid(owner) then return end

	if owner.PlayerClassName and owner.PlayerClassName == "furry" and owner.suiciding then
		if SERVER then
			owner:Notify(table.Random(CantDoIt), 20, "cantdoit", 0)
		end
		return false
	end

	//local owner = self:GetOwner()
	--[[if owner.suiciding then
		if (owner:GetNetVar("suicide_time",CurTime()) + 8) < CurTime() then if SERVER then owner:SetNetVar("suicide_time",nil) end return true end
		if SERVER and owner:KeyPressed(IN_ATTACK) then owner:SetNetVar("suicide_time",owner:GetNetVar("suicide_time",CurTime()) - 0.5) end
		return false
	end--]]
	return true
end

if SERVER then
	hook.Add("Player Think","huyhuy",function(ply)
		local wep = ply:GetActiveWeapon()
		if (!wep.ishgweapon and !wep.ismelee2) or !wep.CanSuicide then ply.suiciding = false end
	end)
end

function SWEP:PrimaryShootPre()
end

function SWEP:Shoot(override)
	self:PrimaryShootPre()
	if self:GetOwner():IsNPC() then self.drawBullet = true end
	if !override and !self:CanPrimaryAttack() then return false end
	if !override and !self:CanUse() then return false end
	if CLIENT and self:GetOwner() != LocalPlayer() and !override then return false end
	local primary = self.Primary
	if override then self.drawBullet = true end
	
	if !self.drawBullet or (self:Clip1() == 0 and !override) then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false

		return false
	end
	
	if !override and IsValid(self:GetOwner()) and !self:GetOwner():IsNPC() and primary.Next > CurTime() then return false end
	if !override and IsValid(self:GetOwner()) and !self:GetOwner():IsNPC() and (primary.NextFire or 0) > CurTime() then return false end
	
	primary.Next = CurTime() + primary.Wait * 1.1
	primary.RealAutomatic = primary.RealAutomatic or weapons_Get(self:GetClass()).Primary.Automatic
	primary.Automatic = primary.RealAutomatic
	
	if CLIENT then self:SetClip1(self:GetNWInt("Clip1")) end
	
	self:PrimaryShoot()
	self:PrimaryShootPost()
end

function SWEP:PrimaryAttack(broadcast)
	if CLIENT and not IsFirstTimePredicted() then return end
	if CLIENT and not self:IsClient() then return end
	if self:KeyDown(IN_USE) and !IsValid(self:GetOwner().FakeRagdoll) then return false end
	
	local huy = self:Shoot() ~= false
	
	if SERVER and huy then
		net.Start("hgwep shoot", true)
		net.WriteEntity(self)
		net.WriteBool(huy)
		net.WriteBool(broadcast)
		net.Broadcast()
	end
end

function SWEP:PrimaryShootPost()
end

function SWEP:Draw(server,overide)
	if self.drawBullet == false then
		if SERVER and server and not overide then self:RejectShell(self.ShellEject) end
		if CLIENT and not server and not overide then self:RejectShell(self.ShellEject) end
		self.drawBullet = nil
	end

	if self:Clip1() > 0 then self.drawBullet = true end
end

SWEP.AutomaticDraw = true
SWEP.ShootAnimMul = 2
SWEP.shot2 = 0
SWEP.shot = 0
function SWEP:PrimaryShoot()
	local ammotype = hg.ammotypeshuy[self.Primary.Ammo].BulletSettings
	if ammotype.IsBlank then
		self.dwr_reverbDisable = nil
		self.shooanim = self.ShootAnimMul

		if not (CLIENT and self:GetOwner():IsNPC()) then
			self:TakePrimaryAmmo(1)
			if SERVER then self:SetNWInt("Clip1", self:Clip1()) end
		end

		self.drawBullet = false
		if self.AutomaticDraw then self:Draw() end
		self:PlaySnd(self.Primary.SoundEmpty, true, CHAN_AUTO)

		return
	end

	self:EmitShoot()
	--if SERVER or self:IsClient() then
		self:FireBullet()
	--end
	self.dwr_reverbDisable = nil
	self.shooanim = self.ShootAnimMul
	self.shot = self.shot or 0
	self.shot = math.min(3, self.shot + (self.NumBullet or 1))
	self.shot2 = math.min(1, self.shot2 + 1)
	
	if not (CLIENT and self:GetOwner():IsNPC()) then
		self:TakePrimaryAmmo(1)
		if SERVER then self:SetNWInt("Clip1", self:Clip1()) end
	end

	self.drawBullet = false
	if self.AutomaticDraw then self:Draw() end
	self:PrimarySpread()
end

SWEP.SightSlideOffset = 1

function SWEP:PrimaryShootEmpty()
	if CLIENT then return end
	self:PlaySnd(self.Primary.SoundEmpty, true, CHAN_AUTO)
end

SWEP.DistSound = "m4a1/m4a1_dist.wav"
SWEP.NewSoundClose = nil
SWEP.NewSoundDist = nil
SWEP.NewSoundSupressor = nil

if SERVER then
	util.AddNetworkString("resettinnitus")

	hook.Add("PlayerSpawn","ResetTinnitus",function(ply)
		if OverrideSpawn then return end
		net.Start("resettinnitus")
		net.WritePlayer(ply)
		net.Send(ply)
	end)
else
	net.Receive("resettinnitus", function(len, ply)
		local ply = net.ReadPlayer() or ply
		ply.TinnitusFactor = 0
	end)

	hook.Add("Player Think", "TinnitusPadaet", function(ply, ent)
		if (ply.TinnitusFactor or 0) > 0 then
			ply.TinnitusFactor = math.min(math.max((ply.TinnitusFactor or 0) - 0.5, 0),102)
		end
	end)
end

function SWEP:EmitShoot()
	if SERVER then return end
	local snd_new = "sounds_zcity/"..(string.Replace(self:GetClass(),"weapon_","")).."/"
	local snd_close = snd_new.."close.wav"
	local snd_suppressor = snd_new.."supressor.wav"
	local snd_dist = snd_new.."dist.wav"

	local vol = hg_gunshotvolume:GetFloat()
	local ply = self:GetOwner()
	ply = IsValid(ply) and ply or self

	if CLIENT then
		if IsValid(lply) and lply.armors and lply.armors["ears"] == "headphones1" then
			vol = vol / 2
		end
	end

	self.Supressor = (self:HasAttachment("barrel", "supressor") and true) or self.SetSupressor
	
	if CLIENT then
		self.Supressor = self:GetNWBool("Supressor")
	end

	local insideVal = 0
	for i = 1, 4 do
		ply = IsValid(ply) and ply or self
		for j = 1, 4 do
			local dir = Vector(math.sin(math.pi * 0.5 * i), math.cos(math.pi * 0.5 * i), math.sin(math.pi * 0.25 * j))
			dir:Mul(10000)
			local inside = util.QuickTrace(ply:EyePos(), dir, {ply, self, hg.GetCurrentCharacter(ply)})

			--debugoverlay.Line(ply:EyePos(), ply:EyePos() + dir, 1, color_white, true)
			insideVal = insideVal + (inside.Hit and !inside.HitSky and 1 or 0)
		end
	end

	if not self.Supressor and !self.NoWINCHESTERFIRE then
		self:PlaySnd("rifle_win1892/win1892_fire_01.wav", nil, nil, vol * (1 - insideVal / 16), math.Clamp(1 / self.Primary.Force / (self.NumBullet or 1) * 100 * 50,90,150), 55555, true)

		self:PlaySnd("zcitysnd/sound/weapons/firearms/hndg_colt1911/colt_1911_fire1.wav", nil, nil, vol * (insideVal / 16), 150, 51256, true)
		self:PlaySnd("zcitysnd/sound/weapons/firearms/hndg_colt1911/colt_1911_fire1.wav", nil, nil, vol * (insideVal / 16), 80, 50256, true)

		self:PlaySnd("weapons/shoot/shot1.wav", nil, nil, vol * 1, 150, 52256, true)
	end
	
	if (self.Primary.SoundFP or self.Supressor and self.SupressedSoundFP) and (GetViewEntity() == ply or GetViewEntity():GetPos():Distance( self:GetPos() ) < 150) then
		self:PlaySnd((self.Supressor and self.SupressedSoundFP) or self.Primary.SoundFP, nil, nil, vol, nil, 55533, not self.Supressor)
	else
		self:PlaySnd(self.Supressor and (self.SupressedSound or (self:IsPistolHoldType() and "homigrad/weapons/pistols/sil.wav" or "m4a1/m4a1_suppressed_fp.wav")) or self.Primary.Sound, nil, nil, vol, nil, 55533, not self.Supressor)
	end
	if not self.Supressor then
		self:PlaySndDist(self.DistSound, nil, nil, nil, nil, 55511, not self.Supressor)
	end
end

function SWEP:CanSecondaryAttack()
end

function SWEP:SecondaryAttack()
end

PISTOLS_WAIT = 0.1

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:GetInfo()
	if not IsValid(self) then return {self.Primary.ClipSize,hg.ClearAttachments(self.ClassName)} end -- дурак
	return {self:Clip1(),self:GetNetVar("attachments")}
end

function SWEP:SetInfo(info)
	if not info then return end
	self:SetClip1(info[1] or self:GetMaxClip1())
	self.attachments = info[2] or {}
	self:SetNetVar("attachments", self.attachments)
end

local colBlack = Color(0, 0, 0, 125)
local colWhite = Color(255, 255, 255, 255)
local yellow = Color(255, 255, 0)
local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local lerpAmmoCheck = 0
local function LerpColor(lerp, source, set)
	return Lerp(lerp, source.r, set.r), Lerp(lerp, source.g, set.g), Lerp(lerp, source.b, set.b)
end

local col = Color(0, 0, 0)
local col2 = Color(0, 0, 0)
local dynamicmags
local instructions 
if CLIENT then
	surface.CreateFont("AmmoFont",{
		font = "Bahnschrift",
		size = ScreenScale(16),
		extended = true,
		weight = 500,
		antialias = true
	})

	surface.CreateFont("DescFont",{
		font = "Bahnschrift",
		size = ScreenScale(8),
		extended = true,
		shadow = true,
		weight = 500,
		antialias = true
	})

	dynamicmags = CreateClientConVar("hg_dynamic_mags", "0", true, false, "Enables dynamic ammo show when shooting",0,1)
	instructions = CreateClientConVar("hg_instructions","1", true, false, "Enables gun instructions",0,1)
end

function SWEP:DrawHUDAdd()
end

local blur = Material( "pp/blurscreen" )
local function DrawBlurRect(x, y, w, h, dens, alpha)

	local lightness = alpha and 80*math.Clamp(alpha,0,255)/255 or 50

	draw.RoundedBox(0,x,y,w,h,Color(0,0,0,lightness))
   	surface.SetDrawColor(0,0,0)
end

	--local clipsize = (self:GetMaxClip1() + (self.OpenBolt and 0 or 1))
	--local owner = self:GetOwner()
	--local attpos = self:GetMuzzleAtt(nil, true, true).Pos
	--local posX,posY = dynamicmags:GetBool() and attpos:ToScreen().x + 50 or ScrW() - ScrW() / 4, dynamicmags:GetBool() and attpos:ToScreen().y + 90 or ScrH() - ScrH() / 6
	--local sizeX,sizeY =  (clipsize == 1 and ScrH() / 15 or ScrW() / 40) * scale, (clipsize == 1 and ScrH() / 80 or ScrH() / 10) * scale
--
--
	--lerpAmmoCheck = Lerp(owner:KeyDown(IN_RELOAD) and 0.5 or 0.02, lerpAmmoCheck, self:KeyDown(IN_RELOAD) and 1 or (dynamicmags:GetBool() and 0 or 0.0))
	--colBlack.a = 125 * lerpAmmoCheck
	--colWhite.a = 255 * lerpAmmoCheck
	--local ammoLeft = math.ceil(self:Clip1() / clipsize * sizeY)
	--local ammo = owner:GetAmmoCount(self:GetPrimaryAmmoType())
	--local magCount = math.ceil(ammo / clipsize)
--
	--col:SetUnpacked(LerpColor(ammoLeft / sizeY, yellow, color_white))
	--col.a = 255 * lerpAmmoCheck
	--if col.a > 1 then
	--	DrawBlurRect(posX-sizeX*(clipsize ~= 1 and .2 or .3),posY-sizeY*(clipsize ~= 1 and .1 or .7),(sizeX+sizeX*(clipsize ~= 1 and .12 or .2)) * (math.max(math.min(magCount+1,(clipsize ~= 1 and 5 or 4)),1.3)), sizeY + (clipsize ~= 1 and 20 or 60),7,col.a*5)
	--end
	--
	--local color = col
	--surface.SetDrawColor(color)
	--surface.DrawRect(posX,posY - ammoLeft + sizeY, sizeX, ammoLeft, 1)
	--surface.DrawOutlinedRect(posX - 5, posY - 5, sizeX + 10, sizeY + 10, 1)
--
	--local posX,posY = posX + (clipsize == 1 and ScrW() / 40 or ScrW() / 50), posY + (clipsize == 1 and ScrH()/70 or ScrH() / 20)
	--local sizeX,sizeY = sizeX / 2,sizeY / 2
--
	--for i = 1,magCount do
	--	if i > 3 then continue end
	--	local ammoasd = math.min(clipsize,ammo)
	--	ammo = ammo - ammoasd
	--	
	--	local ammoLeft = math.ceil(ammoasd / clipsize * sizeY)
	--	
	--	col2:SetUnpacked(LerpColor(ammoLeft / sizeY, yellow, color_white))
	--	col2.a = 255 * lerpAmmoCheck
	--	surface.SetDrawColor(col2)
	--	surface.DrawRect(posX + (sizeX + 15) * i,posY - ammoLeft + sizeY, sizeX, ammoLeft, 1)
	--	surface.DrawOutlinedRect(posX - 5 + (sizeX + 15) * i,posY - 5, sizeX + 10, sizeY + 10, 1)
	--end
--
	--if magCount > 3 then
	--	draw.SimpleText("+"..magCount-3,"AmmoFont",posX + (sizeX + 15) * 4 + 1, posY + sizeX/2 + 1,Color(0,0,0,255*lerpAmmoCheck),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	--	draw.SimpleText("+"..magCount-3,"AmmoFont",posX + (sizeX + 15) * 4 , posY + sizeX/2,Color(255,255,255,255*lerpAmmoCheck),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	--end
	

	--self.hudinspect = self.hudinspect or 0
	--if instructions:GetBool() and self.hudinspect - (CurTime()-6) > 0 then
	--	self.InfoAlpha = Lerp(FrameTime() * 10,self.InfoAlpha or 0,math.min(self.hudinspect - (CurTime() - 5),1)*255)
	--	local txt = self.Instructions
	--	if not self.InfoMarkup1 then
	--		self.InfoMarkup1 = markup.Parse( "<font=DescFont>"..txt.."</font>", 450 )
	--	end
	--	DrawBlurRect(posX - 5 - self.InfoMarkup1:GetWidth() - ScrW()*0.05, posY - self.InfoMarkup1:GetHeight()/2 - 5, self.InfoMarkup1:GetWidth()+10, self.InfoMarkup1:GetHeight()+10, 8, self.InfoAlpha)
	--	self.InfoMarkup1:Draw(posX- ScrW()*0.05,posY,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER,self.InfoAlpha)
	--end

local scale = 1
local developer = GetConVar("developer")


local function DrawBullet(matIcon, x, y, size, cColor)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		surface.SetDrawColor(cColor)
		surface.SetMaterial(matIcon or matPistolAmmo)
		surface.DrawTexturedRect(x-size/2,y-size,size,size)
	render.PopFilterMin()
end

if CLIENT then
	local scrW, scrH = ScrW(), ScrH()
	local lastShoot = 0
	local StopShowBullet = false
	local WhiteColor = Color(200,200,200,255)

	local coloruse = Color(255,255,255,255)

	local matPistolAmmo = Material("vgui/hud/bullets/low_caliber.png")
	local matRfileAmmo = Material("vgui/hud/bullets/high_caliber.png")
	local matShotgunAmmo = Material("vgui/hud/bullets/buck_caliber.png")
	local lerpAmmoCheck = 0
	local ammoCheck = 0
	local color_bg = Color(0,0,0,150)
	local ammoLongCheck = 0
	SWEP.DrawAmmoMetods = {
		["Default"] = function(self,texture)
			local clipsize = self:GetMaxClip1() + (self.OpenBolt and 0 or 1)
			local clip = self:Clip1()
			local owner = self:GetOwner()
			local shoot = CurTime() - self:LastShootTime()
			local ammo = owner:GetAmmoCount(self:GetPrimaryAmmoType())
			local magCount = self.AnimInsert and ammo or math.ceil(ammo / clipsize)
			local posX = scrW*0.75
			local posX2 = scrW*0.8
			local HudHPos = 0.8
			
			lastShoot = LerpFT(0.5,lastShoot, shoot > 0 and 1 or 0)
			lastShootFor = lastShoot
			self.hudinspect = self.hudinspect or 0
			if self.hudinspect > CurTime() or (clip < clipsize/3 and lastShoot < 0.9 and dynamicmags:GetBool()) or self:KeyDown(IN_RELOAD) then
				ammoCheck = CurTime() + 1	
			end
			ammoLongCheck = LerpFT(0.025,ammoLongCheck, (self:KeyDown(IN_RELOAD) or self.hudinspect > CurTime()) and 5 or 0)
			
			if ammoLongCheck > 4 then
				local text = (
					(clip > clipsize - (self.OpenBolt and 0 or 1) - 1) and "Full" or 
					(clip <= clipsize and clip > clipsize/1.5 ) and "~ Full" or 
					(clip <= clipsize/1.5 and clip > clipsize/3.5) and "~ Half" or 
					(clip <= clipsize/3.5 and clip != 0 ) and "~ Almost Empty" or 
					(clip == 0 and "Empty")
				)
				coloruse.r = 0
				coloruse.g = 0
				coloruse.b = 0
				coloruse.a = 210*math.max(ammoLongCheck-4,0)
				draw.SimpleText(text,"AmmoFont",scrW*0.8 + 2, scrH*HudHPos + scrH*0.05 + 2,coloruse,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				coloruse.r = 255
				coloruse.g = 255
				coloruse.b = 255
				coloruse.a = 210*math.max(ammoLongCheck-4,0)
				draw.SimpleText(text,"AmmoFont",scrW*0.8, scrH*HudHPos + scrH*0.05,coloruse,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			end

			lerpAmmoCheck = LerpFT((ammoCheck > CurTime()) and 0.2 or 0.1, lerpAmmoCheck, ammoCheck > CurTime() and 1 or 0)
			local Yellow = (( clipsize/clip )-1)/(clipsize/5)
			--print(Yellow)
			color_bg.r = 55*Yellow
			--draw.RoundedBox(0,scrW*0.75-(scrH*0.12/2),scrH*0.72,scrH*0.12,scrH*0.18,ColorAlpha(color_black,50))
			color_bg.a = (250*lastShoot) * lerpAmmoCheck
			WhiteColor.a = (150*lastShoot) * lerpAmmoCheck
			local PosLerp = Lerp(math.ease.OutExpo(lerpAmmoCheck),150,0)
			--print(PosLerp)
			if clip > 0 then
				DrawBullet(texture,posX - (scrH*0.16)+(scrH*0.08)*(1+lastShoot) + 2 + PosLerp,scrH*(HudHPos) + 2,scrH*0.08, color_bg)
				DrawBullet(texture,posX - (scrH*0.16)+(scrH*0.08)*(1+lastShoot) + PosLerp,scrH*(HudHPos),scrH*0.08, WhiteColor)
				--if lastShoot < 0.2 then StopShowBullet = true end
			end
			--if StopShowBullet then
			--	lastShootFor = 0 
			--	if lastShoot > 0.6 then
			--		StopShowBullet = false
			--	end
			--else
			--end
			--print(clipsize)
			--print(lastShoot)
			for i = 2, clip do
				if i > 6 and lastShootFor > 0.5 or i > 7 then continue end
				i = i - 1
				local PosAdjust = math.max(PosLerp - i*15,0)
				--print(PosAdjust)
				if i < 2 then
					DrawBullet(texture,posX + 2 + PosAdjust,scrH*((HudHPos) + i*(0.026*lastShoot))+2,scrH*0.08, color_bg)
					DrawBullet(texture,posX + PosAdjust,scrH*((HudHPos) + i*(0.026*lastShoot)),scrH*0.08, WhiteColor)
				else
					color_bg.a = (210 - (20 * i)) * lerpAmmoCheck
					WhiteColor.a = (210 - (20 * i) )* lerpAmmoCheck
					DrawBullet(texture,posX+2 + PosAdjust,scrH*((HudHPos - 0.026) + i*0.026+(0.026*lastShootFor))+2,scrH*0.08, color_bg)
					DrawBullet(texture,posX + PosAdjust,scrH*((HudHPos - 0.026) + i*0.026+(0.026*lastShootFor)),scrH*0.08, WhiteColor)
				end
			end

			if magCount > 0 then
				coloruse.r = 0
				coloruse.g = 0
				coloruse.b = 0
				coloruse.a = 210*lerpAmmoCheck
				draw.SimpleText("+"..magCount,"AmmoFont",posX2 + 2, scrH*HudHPos + 2,coloruse,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				coloruse.r = 255
				coloruse.g = 255
				coloruse.b = 255
				coloruse.a = 210*lerpAmmoCheck
				draw.SimpleText("+"..magCount,"AmmoFont",posX2, scrH*HudHPos,coloruse,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			end
			--draw.SimpleText("lastShoot: "..lastShoot,"Default",0,0)
		end
	}

	SWEP.AmmoDrawMetod = "Default"

	function SWEP:DrawHUD()
		if not IsValid(self:GetOwner()) then return end
		local ammotype = hg.ammotypeshuy[self.Primary.Ammo].BulletSettings and hg.ammotypeshuy[self.Primary.Ammo].BulletSettings.Icon or matPistolAmmo
		self.DrawAmmoMetods[self.AmmoDrawMetod](self,ammotype)
		
		self.isscoping = false
		if self.attachments then
			for plc,att in pairs(self.attachments) do
				if not self:HasAttachment(plc) then continue end
				if hg.attachments[plc][att[1]].sightFunction then
					hg.attachments[plc][att[1]].sightFunction(self)
				end
			end
		end
		self:ChangeFOV()
		self:DrawHUDAdd()
		if self.dort then self:DoRT() end

		self.hudinspect = self.hudinspect or 0

		--[[if developer:GetBool() and LocalPlayer():IsAdmin() then
			local _,tr = self:CloseAnim()
			cam.Start3D()
				render.DrawLine(tr.StartPos,tr.HitPos,color_white,true)
			cam.End3D()
		end--]]
	end
end

if CLIENT then
	local hook_Run = hook.Run
	hook.Add("Think", "homigrad-weapons", function()
		for i,wep in ipairs(hg.weapons) do
			--local wep = ply:GetActiveWeapon()

			if not IsValid(wep) or not wep.Step or (not IsValid(wep:GetOwner()) and wep:GetVelocity():LengthSqr() < 5) then continue end
			--hook_Run("SWEPStep", wep)
			if wep.NotSeen or not wep.shouldTransmit then continue end
			//if (wep.lasttimetick or 0) > CurTime() then continue end
			local owner = wep:GetOwner()
			//wep.lasttimetick = CurTime() + (IsValid(owner) and owner:IsPlayer() and (owner == LocalPlayer() or owner == LocalPlayer():GetNWEntity("spect")) and 0 or 0.1)
			if IsValid(owner) and owner:IsPlayer() then
				wep:Step_HolsterDeploy(CurTime())
				continue
			end
			wep:Step()
		end
	end)

	hook.Add("Player Think", "OwOasss", function(ply)
		local wep = ply:GetActiveWeapon()
		if wep and IsValid(wep) and wep.Step then
			wep:Step()
		end
	end)
end

hook.Add("Player Think", "suicidingaa", function(ply)
	if SERVER then
		ply:SetNWBool("suiciding", ply.suiciding)
	end
	
	if CLIENT then
		ply.suiciding = ply:GetNWBool("suiciding", false)
	end
end)

function SWEP:Think()
	if SERVER then
		self:Step()
	end
end

function SWEP:Step()
	self:CoreStep()
end

local CurTime = CurTime
if CLIENT then
	SWEP.particleEffect = nil

	local vecSmoke = Vector(255, 255, 255)
	function SWEP:MuzzleEffect(time_)
		//local tr, pos, ang = self:GetTrace()
		if self.NoMuzzleEffects then return end
		local att = self:GetMuzzleAtt(gun, true)
		if not att then return end
		local pos, ang = att.Pos, att.Ang

		local owner = self:GetOwner()

		local lastdmg = self.dmgStack
		local lastdmgMul = lastdmg / 100
		
		if time_ < 0.5 and self.SprayI == 0 then
			if not IsValid(self.particleEffect) then
				self.particleEffect = CreateParticleSystemNoEntity("smoke_trail_tfa", pos, ang)
				self.particleEffectCreateTime = CurTime()
			end
		end
		
		if IsValid(self.particleEffect) then
			self.particleEffect:SetControlPoint(0, pos)
			
			if self.particleEffectCreateTime + 2 < CurTime() then
				self.particleEffect:StopEmission()
			end

			if self.particleEffectCreateTime + 4 < CurTime() then
				self.particleEffect:StopEmissionAndDestroyImmediately()
				self.particleEffect = nil
			end

			if IsValid(owner) and owner:IsPlayer() and IsValid(owner:GetActiveWeapon()) and owner:GetActiveWeapon() ~= self and self.shouldntDrawHolstered then
				if IsValid(self.particleEffect) then
					self.particleEffect:StopEmission()
				end
			end
		end
	end
else
	function SWEP:MuzzleEffect(time)
	end
end

if SERVER then
	hook.Add("Player Think", "removesuiciding", function(ply)
		local wep = ply:GetActiveWeapon()
		
		if !ishgweapon(wep) or !wep.CanSuicide or (ply:GetNWFloat("willsuicide", 0) < CurTime() - 1) then
			ply:SetNWFloat("willsuicide", 0)
		end
	end)
end

hook.Add("PlayerSwitchWeapon", "cantswitchwhenithappens", function(ply)
	if ply:GetNWFloat("willsuicide", 0) > 0 then
		return true
	end

	if ply.organism and ply.organism.larmamputated and ply.organism.rarmamputated then
		if SERVER then
			ply:SetActiveWeapon(ply:GetWeapon("weapon_hands_sh"))
		end
		return true
	end
end)

if SERVER then
	concommand.Add("hg_place_bipod", function(ply, cmd, args)
		if CLIENT then return end

		local self = ply:GetActiveWeapon()
		
		if !ishgweapon(self) then return end

		if !self.reload then		
			if self:GetNWBool("IsResting", false) then
				self:SetNWBool("IsResting", false)
			elseif self.restlerp < 0.1 then
				self:RestWeapon()
			end
		end
	end)
end

local vpang1, vpang2 = (Angle(1,-1.5,-1.8) / 1.5), (Angle(-1,1.5,1.8) / 1.5)
local bashvpang = Angle(-10, 0, 0)
function SWEP:CoreStep()
	local owner = self:GetOwner()
	local actwep = owner.GetActiveWeapon and owner:GetActiveWeapon() or nil

	if CLIENT and IsValid(self:GetWeaponEntity()) then self:GetWeaponEntity():SetLOD(0); end

	if self:GetClass() == "weapon_taser" then
		self:WorldModel_Transform()
	end

	if SERVER and (not IsValid(owner) or (IsValid(actwep) and self != actwep)) then
		self:SetNWBool("IsResting", false)

		return
	end

	local dtime = SysTime() - (self.dtimethink or SysTime())
	local time = CurTime()
	
	if IsValid(owner) then
		self:Step_HolsterDeploy(time)
	end
	
	//if SERVER and self.UseCustomWorldModel then
		if self == actwep and (SERVER or (self.shouldTransmit and !self.NotSeen)) then
			self:ChangeGunPos(dtime)
			self:GetAdditionalValues()
		end
	//end

	if CLIENT and IsValid(self:GetWM()) and (self:GetWM():GetSequence() == 0) then self:PlayAnim("idle", 0, not self.NoIdleLoop) end
	
	if SERVER and self.deploy then
		owner.suiciding = false
	end

	if SERVER and !self:IsPistolHoldType() and self:HasAttachment("barrel", "supressor") then
		owner.suiciding = false
	end

	if SERVER then
		local willsuicide = (self.CanSuicide and owner:GetNWFloat("willsuicide", 0) > 0)
		owner.suiciding = (self.CanSuicide and owner:GetNWFloat("willsuicide", 0) > 0) or owner.suiciding
	
		if willsuicide and owner:GetNWFloat("willsuicide", 0) < CurTime() - 0.1 then
			self:PrimaryAttack(true)
			owner:SetNWFloat("willsuicide", 0)
		end
	end

	if SERVER then
		self.Supressor = (self:HasAttachment("barrel", "supressor") and true) or self.SetSupressor
		
		self:SetNWBool("Supressor", self.Supressor and true or false) -- reminder to self: nil is not false
		self:SetNWInt("Clip1", self:Clip1())
	else
		self:SetClip1(self:GetNWInt("Clip1", self:Clip1()))
	end

	--self:CanRest()

	if SERVER then
        if self:GetNWBool("IsResting", false) and self:GetNWVector("OwnerPos"):DistToSqr(self:GetOwner():GetPos()) > 2 * 2 then
            --self:SetNWBool("IsResting", false)
        end

        if self.reload or self:KeyDown(IN_RELOAD) then
            self:SetNWBool("IsResting", false)
        end
    end

	--[[if CLIENT and ((self.cooldown_transform or 0) < CurTime()) then
		self.cooldown_transform = CurTime() + 0.05

		self:CloseAnim(dtime)
	end]]

	--[[if SERVER and ((self.cooldown_transform or 0) < CurTime()) then
		self.cooldown_transform = CurTime() + 0.05

		self:CloseAnim(dtime)

		--self:WorldModel_Transform()
	end]]

	--[[if owner:IsPlayer() then
		local inv = owner:GetNetVar("Inventory")
		
		local noSling = inv and (not inv["Weapons"] or not inv["Weapons"]["hg_sling"])
		
		if not noSling then owner.holdingWeapon = nil end

		if not self.shouldntDrawHolstered and noSling then
			owner.holdingWeapon = owner:GetActiveWeapon() ~= self and self or nil
		end
	end--]]
	
	if not self.reload and self.RevertMag then
		self:RevertMag()
	end

	if CLIENT then
		self.sprayAngles = Lerp(hg.lerpFrameTime2(0.1,dtime),self.sprayAngles or Angle(0,0,0),angle_zero)
	end

	if SERVER then
		if owner.suiciding and not hg.CanSuicide(owner) then
			owner.suiciding = false
		end
	end

	--	if SERVER and self.UseCustomWorldModel then self:WorldModel_Transform() end

	if SERVER and not owner:IsNPC() and self != actwep then
		--local inv = owner:GetNetVar("Inventory",{})

		if not (inv["Weapons"] and inv["Weapons"]["hg_sling"] and not self:IsPistolHoldType()) then
			//hg.drop(owner, self)
			hook.Run("PlayerDropWeapon", owner)
		end
	end

	if SERVER and not owner:IsNPC() and owner.organism and (not owner.organism.canmove or ((owner.organism.stun - CurTime()) > 0) or (owner.organism.larm == 1 and owner.organism.rarm == 1)) and IsValid(actwep) and self == actwep then
		self:RemoveFake()
		
		local inv = owner:GetNetVar("Inventory",{})
		if not (inv["Weapons"] and inv["Weapons"]["hg_sling"] and not self:IsPistolHoldType()) then
			//hg.drop(owner, self)
			hook.Run("PlayerDropWeapon", owner)
		else
			hook.Run("PlayerDropWeapon", owner)
			//owner:SetActiveWeapon(owner:GetWeapon("weapon_hands_sh"))
		end

		return
	end
	
	if CLIENT then
		local time2 = time - self:LastShootTime()

		self:MuzzleEffect(time2)
	end

	if not IsValid(owner) or (IsValid(actwep) and self != actwep) then return end

	self:Step_Inspect(time)
	self:Step_Reload(time)
	self:ClearAnims()
	-- self:Animation(time)

	if CLIENT then
		if self.Primary.Next + 1 < time then 
			//self.dmgStack = 0
			--self.dmgStack2 = Lerp(hg.lerpFrameTime(0.001,dtime), self.dmgStack2, 0)
		end
	end

	local stam = (owner.organism ~= nil and owner.organism.stamina and owner.organism.stamina[1]) or 180
	if owner:GetNWFloat("InLegKick",0) <= CurTime() and (!(IsValid(owner.FakeRagdoll) or IsValid(owner.FakeRagdollOld)) or false--[[self:Clip1() <= 0]]) and self:KeyDown(IN_ATTACK) and self:KeyDown(IN_USE) and ((self:GetButtstockAttack() + 1 * ((math.max(0, (self.weight - 3)) * 0.2) + 1) * (math.Clamp((180 - stam) / 90, 1, 2))) < CurTime()) and owner:GetVelocity():LengthSqr() < 250 * 250 and (SERVER or IsFirstTimePredicted()) then
		self:SetButtstockAttack(CurTime())
		self:GetOwner():EmitSound("weapons/tfa/melee"..math.random(1,6)..".wav")
		if SERVER then
			//timer.Simple(0.15, function()
				owner:LagCompensation(true)
				local tr = hg.eyeTrace(owner)
				if IsValid(tr.Entity) or tr.Entity:IsWorld() then
					local ent = tr.Entity
					local dmgInfo = DamageInfo()
					dmgInfo:SetDamage(15 * (owner.organism.superfighter and 5 or 1))
                    dmgInfo:SetDamageType((ent:GetClass() == "func_breakable_surf") and DMG_SLASH or DMG_CLUB)
					dmgInfo:SetAttacker(owner)
					dmgInfo:SetInflictor(owner:GetWeapon("weapon_hands_sh"))
					dmgInfo:SetDamagePosition(tr.HitPos - tr.Normal * 5)
					dmgInfo:SetDamageForce(tr.Normal * 55)

					PenetrationGlobal = 5
					MaxPenLenGlobal = 5
					ent:TakeDamageInfo(dmgInfo)

					if ent:IsPlayer() or ent:IsRagdoll() or ent:IsNPC() then
						owner:EmitSound("weapons/tfa/melee_hit_world"..math.random(1,3)..".wav", 65)
					else
						owner:EmitSound("physics/metal/weapon_impact_hard3.wav", 65)
					end

					if ent:IsPlayer() then
						ent:ViewPunch(bashvpang)
					end
			
					local phys = ent:GetPhysicsObject()
					if IsValid(phys) then
						if ent:IsPlayer() then ent:SetVelocity(tr.Normal * 50 * 1.5 * (owner.organism.superfighter and 5 or 1)) end
						phys:ApplyForceOffset(tr.Normal * 5000, tr.HitPos)
						owner:SetVelocity(tr.Normal * 50 * .8 * (owner.organism.superfighter and 2 or 1))
					end
				end

				owner.organism.stamina.subadd = owner.organism.stamina.subadd + 6 * self.weight

				owner:LagCompensation(false)
			//end)
		end
	end

	if self:IsClient() then self:Step_Spray(time, dtime) end
	if self:IsClient() then self:Step_SprayVel(dtime) end
	self.dtimethink = SysTime()
	//self:ThinkAtt()

	--self:Animation()

	if CLIENT then
		if self:IsZoom() then
			if not self.zoomsound then
				//self:PlaySnd({"pwb2/weapons/p90/cloth3.wav",60,80,120},false,CHAN_BODY)
				sound.Play("pwb2/weapons/p90/cloth3.wav", self:GetPos(), 65)
				self.zoomsound = true
				if self:IsClient() then
					--ViewPunch2(vpang1)
				end
			end
		else
			if self.zoomsound then
				sound.Play("pwb2/weapons/matebahomeprotection/mateba_cloth.wav", self:GetPos(), 65)
				//self:PlaySnd({"pwb2/weapons/matebahomeprotection/mateba_cloth.wav",60,80,120},false,CHAN_BODY)
				if self:IsClient() then
					--ViewPunch2(vpang2)
				end
			end
			self.zoomsound = nil
		end
	end

	if SERVER then self:DrawAttachments() end
end

if SERVER then hook.Add("UpdateAnimation", "fuckgmodok", function(ply) ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER) end) end
if CLIENT then
	local nilTbl = {}
	function SWEP:CustomAmmoDisplay()
		return nilTbl
	end
end

function SWEP:GunOverHead(height)
	local tr, pos, ang = self:GetTrace()
	local owner = self:GetOwner()
	local eyepos = hg.eye(owner)
	return eyepos[3] + 10 < (height and height[3] or pos[3]) or eyepos:DistToSqr(height or pos) > 40 * 40
end

local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local hullVec = Vector(2, 2, 2)

function SWEP:DoImpactEffect( tr, nDamageType )
	if CLIENT then return true end
	return false
end

local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)

--local to head
SWEP.RHPos = Vector(7,-7,5)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(15,0,-4)
SWEP.LHAng = Angle(-110,-90,-90)

SWEP.RHPosOffset = Vector(0,0,0)
SWEP.LHPosOffset = Vector(0,0,0)

SWEP.RHAngOffset = Angle(0,0,0)
SWEP.LHAngOffset = Angle(0,0,0)

SWEP.AdditionalPos = Vector(0,0,0)
SWEP.AdditionalPos2 = Vector(0,0,0)
SWEP.AdditionalAng = Angle(0,0,0)
SWEP.AdditionalAng2 = Angle(0,0,0)

SWEP.desiredPos = Vector(0,0,0)
SWEP.desiredAng = Angle(0,0,0)

local funcNil = function() end

hg.postureFunctions2 = {
	[1] = function(self,ply)
		if self:IsZoom() then return end

		if self:IsPistolHoldType() then
			self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] - 4
			self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 3
			self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3]

			self.AdditionalAngPreLerp[1] = self.AdditionalAngPreLerp[1] + 2
			self.AdditionalAngPreLerp[2] = self.AdditionalAngPreLerp[2] + 5
			self.AdditionalAngPreLerp[3] = self.AdditionalAngPreLerp[3] - 20
			return
		end

		local ang = math.Clamp((-ply:EyeAngles()[1]) / 65, -1, 1)
		if ang > 0.8 or ang < -0.95 then return end

		self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 9 * math.Clamp((-ply:EyeAngles()[1] + 75) / 45, 0.5, 1)
		self.AdditionalPosPreLerp[1] = (self.AdditionalPosPreLerp[1] - 2) + 6 * math.Clamp((ply:EyeAngles()[1] - 25) / 25, 0, 1)
		self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + 1.5 * math.Clamp((-ply:EyeAngles()[1] + 75) / 45, 0.2, 1)

		self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] + math.max(10 * ang,0)
		self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] + 5 * ang

		self.AdditionalAngPreLerp[1] = self.AdditionalAngPreLerp[1] + 3
		self.AdditionalAngPreLerp[2] = self.AdditionalAngPreLerp[2] + 5
		self.AdditionalAngPreLerp[3] = self.AdditionalAngPreLerp[3] - 4
	end,
	[2] = function(self,ply)
		self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] - 4
	end,
	[3] = function(self,ply,force)
		if self:IsZoom() and not force then return end
		local isLocal = self:IsLocal2()
		local pistolRun = self:IsPistolHoldType() or self.CanEpicRun

		local epicRunZ = self.EpicRunPos and self.EpicRunPos[3]
		local epicRunY = self.EpicRunPos and self.EpicRunPos[2]
		local epicRunX = self.EpicRunPos and self.EpicRunPos[1]

		local running = ply:GetVelocity():LengthSqr() > 150 * 150

		self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 3 + (pistolRun and (isLocal and (epicRunZ or (running and 6 or 2)) or 4) or (isLocal and -2 or -6 + (ply:GetNW2Float("InLegKick", 0) and 5 or 0)) )
		self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] - 5 + (pistolRun and (isLocal and (epicRunY or (running and 6 or 4)) or 8 + (ply:GetNW2Float("InLegKick", 0) and -5 or 0)) or (isLocal and 8 or 2 + (ply:GetNW2Float("InLegKick", 0) and 8 or 0)) ) + 3 * math.Clamp(-ply:EyeAngles()[1] / 20, self:IsPistolHoldType() and -2 or 0, 0)
		self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + 3 + (pistolRun and (isLocal and (epicRunX or 2) or 0) or 0)
	end,
	[4] = function(self,ply,force)
		if self:IsZoom() and not force then return end
		if self:IsPistolHoldType() then 
			self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 7
			self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] - 3 + 5 * math.Clamp(ply:EyeAngles()[1] / 20, -0.5, 0.5)
			self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + 1
		else
			self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + 1 
			self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 8
			self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] + -2 - 5 * math.Clamp(-ply:EyeAngles()[1] / 20, 0, 0.5)
		end
	end,
	[5] = function(self,ply)
		local add = (hg.GunPositions[ply] and hg.GunPositions[ply][2]) or 0
		self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] - 1 - add
	end,
	[6] = function(self,ply)
		if self:IsZoom() then return end
		if self:IsPistolHoldType() then 
			self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 2
			self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + 6
		else
			self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] - 2
			self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] + -2
			self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + 5
		end
	end,
}

SWEP.AdditionalPosPreLerp = Vector(0,0,0)
SWEP.AdditionalAngPreLerp = Angle(0,0,0)

SWEP.vecSuicidePist = Vector(-7,-7,4)
SWEP.angSuicidePist = Angle(40,100,80)
SWEP.vecSuicidePist2 = Vector(-6,-4,9)
SWEP.angSuicidePist2 = Angle(60,100,80)
SWEP.vecSuicideRifle = Vector(2,-19,-1)
SWEP.angSuicideRifle = Angle(15,100,90)
SWEP.vecSuicideRifle2 = Vector(12, -20, 0)
SWEP.angSuicideRifle2 = Angle(14,118,90)
local function isCrouching(ply)
	return (hg.KeyDown(ply,IN_DUCK)) and ply:OnGround()
end

local angle_huy = Angle(0, 0, 0)

local host_timescale = game.GetTimeScale

SWEP.pitch = 0

SWEP.CloseAnimAddVec = Vector()
SWEP.CloseAnimAddAng = Angle()

local function isSprinting(ply)
	return ply:IsSprinting() and ply:GetVelocity():LengthSqr() > 30000 and ply:OnGround()
end

local bashvpang1, bashvpang2, bashvpang3, bashvpang4 = Angle(-4, -2, 0), Angle(6, 4, 4), Angle(-3, 10, 0), Angle(2, -2, 0)

function SWEP:GetAdditionalValues()
	local ply = self:GetOwner()
	local owner = ply
	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	if !IsValid(ply) or !ply:IsPlayer() then return end
	local dtime = SysTime() - (self.timetick2 or 0) --/ host_timescale:GetFloat()
	
	if SERVER and dtime < 0.1 then return end

	dtime = dtime * game.GetTimeScale()
	

	if CLIENT and not (ply == LocalPlayer() or ply == LocalPlayer():GetNWEntity("spect")) then
		//if dtime > 1 then return end
	end
	
	--[[if CLIENT then
		self.worldModel:SetSequence(9)
		self.worldModel:SetCycle(CurTime()%3 / 3)
	end--]]

	--[[if (self.huytimeUwU or 0) < CurTime() then
		local eyeangs = ply:GetAimVector():Angle()
		local lastView = ply.lastView or eyeangs
		local curView = eyeangs
		//local _, localview = WorldToLocal(vector_origin, curView, vector_origin, lastView)--govno
		local localview = Angle(math.AngleDifference(curView[1], lastView[1]), math.AngleDifference(curView[2], lastView[2]), math.AngleDifference(curView[3], lastView[3]))

		ply.offsetView = (ply.offsetView or angle_zero) + localview * 0.2
		ply.offsetView[1] = math.Clamp(ply.offsetView[1], -2, 2)
		ply.offsetView[2] = math.Clamp(ply.offsetView[2], -5, 5)
		ply.offsetView[3] = 0
		
		ply.lastView = eyeangs
		
		self:SetOffsetView(ply.offsetView)
		ply.offsetView = self:GetOffsetView()
		ply.offsetView = ply.offsetView or Angle()
		ply.offsetView:Zero()
		self.huytimeUwU = CurTime() + (SERVER and engine.AbsoluteFrameTime() or engine.ServerFrameTime())
	end--]]

	self.AdditionalPosPreLerp:Zero()
	self.AdditionalAngPreLerp:Zero()
	self.AdditionalPos2:Zero()
	self.AdditionalAng2 = Angle(0, 0, 0)--:Zero()
	
	--self.AdditionalAng:Zero()
	local add = (hg.GunPositions[ply] and hg.GunPositions[ply][3]) or 0
	self.AdditionalPosPreLerp[2] = (CLIENT and !self:IsLocal2()) and self:IsZoom() and 1 - add or 0
	self.AdditionalPosPreLerp[3] = (CLIENT and !self:IsLocal2()) and self:IsZoom() and -0.5 or 0

	if ply.organism and (ply.organism.larm and !self:IsPistolHoldType()) and ply.organism.rarm and (ply.organism.larm > 0.99 or ply.organism.rarm > 0.99) then
		--ply.posture = 1
		self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 12 * math.Clamp((-ply:EyeAngles()[1] + 75) / 45, 0.5, 1)
		self.AdditionalPosPreLerp[1] = (self.AdditionalPosPreLerp[1] - (ply.organism.rarmamputated and -1 or 6)) + 0 * math.Clamp((ply:EyeAngles()[1] - 25) / 25, 0, 1)
		self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + (ply.organism.rarmamputated and -6 or 3) * math.Clamp((-ply:EyeAngles()[1] + 75) / 45, 0.2, 1)

		if hg.KeyDown(ply, IN_ATTACK2) then
			self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] + 8
			self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] - 3
		end
	end

	if ply.organism and (ply.organism.rarmamputated and self:IsPistolHoldType()) then
		if ply.posture and ply.posture >= 7 then
			ply.posture = 2
		end
		self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] - (isSprinting(ply) and 10 or 4) * (isSprinting(ply) and 1.2 or math.Clamp((-ply:EyeAngles()[1] + 90) / 45, 0.2, 1))
	end

	local huya = false//animpos > (self:IsPistolHoldType() and 0.7 or 0.39)

	--self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] - ((ply.lean or 0) * 2)
	
	local val = math.Clamp((self.deploy and ((self.deploy - CurTime()) * 10) or self.holster and (((self.CooldownDeploy / self.Ergonomics) - (self.holster - CurTime())) * 10) or 0) / (self.CooldownDeploy / self.Ergonomics),0,10)
	--val = math.abs(math.sin(CurTime()))
	--self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - val * 1.5
	--self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] - val * 2 * (self:IsPistolHoldType() and 0.5 or 0.75)
	
	--self.AdditionalAngPreLerp[1] = self.AdditionalAngPreLerp[1] + val / 10 * 40
	--self.AdditionalAngPreLerp[3] = self.AdditionalAngPreLerp[3] + val / 10 * -90
	--self.AdditionalAngPreLerp[2] = self.AdditionalAngPreLerp[2] + val / 10 * -90

	local animpos = self:GetNWFloat("addAttachment")
	animpos = 1 - math.Clamp((animpos + 1 - CurTime()) / 1,0,1)
	if animpos > 0.5 then animpos = 1 - animpos end
	animpos = math.ease.InOutSine(animpos)

	self.AdditionalAngPreLerp[2] = self.AdditionalAngPreLerp[2] + animpos * -80
	self.AdditionalAngPreLerp[1] = self.AdditionalAngPreLerp[1] + animpos * 80
	self.AdditionalAngPreLerp[3] = self.AdditionalAngPreLerp[3] + animpos * -80
	self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] + animpos * -10
	self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] + animpos * -20

	local posture = ((animpos < 0.2 and self:IsSprinting()) or animpos > (self:IsPistolHoldType() and 0.5 or 0.2)) and (self:IsPistolHoldType() and 3 or 4) or ply.posture

	local func = hg.postureFunctions2[ply:GetNW2Float("InLegKick", 0) > CurTime() and 3 or self.reload and 0 or (self:IsSprinting() or huya) and (self:GetButtstockAttack() - CurTime() < -1) and ((ply.posture == 3 and 3) or (ply.posture == 3 and 3) or (self:IsPistolHoldType() and 3 or 3)) or ply.posture] or funcNil

	if not self.inspect then
		func(self, ply, huya)
	end
	
	local willsuicide = ply:GetNWFloat("willsuicide", 0)
	if ply.suiciding then
		ply.startsuicide = ply.startsuicide or CurTime()
		
		local amt = 1

		if willsuicide > 0 then
			amt = 1 - math.max((willsuicide - CurTime()) / 5, 0)
		else
			amt = 1 - math.max((ply.startsuicide - CurTime() + 1), 0)
		end
		
		if self:IsPistolHoldType() then
			if SERVER or self:IsLocal2() then
				self.AdditionalPosPreLerp:Set(self.vecSuicidePist2 * amt)
				self.AdditionalAngPreLerp:Set(self.angSuicidePist2 * amt)
			else
				self.AdditionalPosPreLerp:Set(self.vecSuicidePist * amt)
				self.AdditionalAngPreLerp:Set(self.angSuicidePist * amt)
			end
		else
			if SERVER or self:IsLocal2() then
				self.AdditionalPosPreLerp:Set(self.vecSuicideRifle2 * amt)
				self.AdditionalAngPreLerp:Set(self.angSuicideRifle2 * amt)
			else
				self.AdditionalPosPreLerp:Set(self.vecSuicideRifle * amt)
				self.AdditionalAngPreLerp:Set(self.angSuicideRifle * amt)
			end

			--self.AdditionalAngPreLerp:Set(Angle(0,180,0))
		end
	else
		ply.startsuicide = nil
	end
	
	if true then
		local timea = 0.3 * ((math.max(0, (self.weight - 3)) * 0.2) + 1)// * (math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 1.5))
		local progress = (1 - math.Clamp(self:GetButtstockAttack() - CurTime() + timea * 2, 0, timea * 2) / timea)
		
		if progress > 0 then
			progress = 1 - progress
			progress = math.ease.InOutSine(progress)
		else
			progress = 1 + progress
			progress = math.ease.OutBack(progress)
		end

		local attackprogress = progress
		local attackprogress2 = math.max(0, progress - 0.9) / 0.2

		if progress > 0 then
			if self.vpbuttstock then
				if CLIENT and self:IsLocal() then
					if self:IsPistolHoldType() then
						ViewPunch(bashvpang1)
						timer.Simple(0.1, function()
							ViewPunch(bashvpang2)
						end)
					else
						ViewPunch(bashvpang3)
						timer.Simple(0.1, function()
							ViewPunch(bashvpang4)
						end)
					end
				end

				self.vpbuttstock = false
			end
		else
			self.vpbuttstock = true
		end

		if !self:IsPistolHoldType() then
			self.AdditionalAng2[1] = self.AdditionalAng2[1] + 140 * attackprogress
			self.AdditionalAng2[2] = self.AdditionalAng2[2] + 30 * attackprogress
			self.AdditionalAng2[3] = self.AdditionalAng2[3] - 90 * attackprogress
			self.AdditionalPos2[1] = self.AdditionalPos2[1] + 10 * attackprogress
			self.AdditionalPos2[3] = self.AdditionalPos2[3] - 5 * attackprogress2
			self.AdditionalPos2[2] = self.AdditionalPos2[2] + 3 * attackprogress
		else
			self.AdditionalAng2[2] = self.AdditionalAng2[2] + 140 * attackprogress
			self.AdditionalPos2[3] = self.AdditionalPos2[3] + 1 * attackprogress
			self.AdditionalPos2[1] = self.AdditionalPos2[1] - 5 * attackprogress
			self.AdditionalPos2[1] = self.AdditionalPos2[1] + 10 * attackprogress2
			self.AdditionalPos2[2] = self.AdditionalPos2[2] + 10 * attackprogress
			self.AdditionalPos2[2] = self.AdditionalPos2[2] - 10 * attackprogress2
			self.AdditionalAng2[2] = self.AdditionalAng2[2] - 90 * attackprogress2
			self.setlhik = false
		end
	end

	//self.AdditionalAngPreLerp[1] = self.AdditionalAngPreLerp[1] + ply.offsetView[2]
	//self.AdditionalAngPreLerp[2] = self.AdditionalAngPreLerp[2] - ply.offsetView[1]
	
	local pranktime = CurTime() / 2
	local vellen = (ply:InVehicle()) and 0 or hg.GetCurrentCharacter(ply):GetVelocity():Length()
	self.walkinglerp = Lerp(hg.lerpFrameTime(0.001,dtime), self.walkinglerp or 0, vellen)
	self.huytime = self.huytime or 0
	local walk = math.Clamp(self.walkinglerp / 100,0,1)
	
	self.huytime = self.huytime + walk * dtime * 8 * (ply:OnGround() and 1 or 0.1)
	--if 
	--ply.oldposture = ply.posture
	if self:IsSprinting() then
		--ply.posture = 1
		walk = walk * 2
	end

	--print(self:IsSprinting())
	
	local huy = self.huytime

	local antiMeta = false -- ply.posture == 7 or ply.posture == 8
	--[[if antiMeta then
		self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] - 1 * walk * 3
		self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - 1 * walk * -1
	end]]
	
	local lena = vellen / 150 * (ply:OnGround() and 1 or 0.1)
	local x,y = math.cos(huy) * math.sin(huy) * walk * (antiMeta and 1 or 1) * 1.5, math.sin(huy) * walk * (antiMeta and 1 or 1) * 1.5
	self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - walk * lena
	self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - x * 0.25 * (lena * 3)
	self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] - y * 0.25 * lena
	self.AdditionalPosPreLerp[1] = self.AdditionalPosPreLerp[1] - math.sin(huy) * math.sin(huy) * walk * 1 * lena

	self.AdditionalAngPreLerp[2] = self.AdditionalAngPreLerp[2] + x * 4 * lena
	self.AdditionalAngPreLerp[1] = self.AdditionalAngPreLerp[1] - y * 2 * lena
	self.AdditionalAngPreLerp[3] = self.AdditionalAngPreLerp[3] - y * 3 * lena

	if CLIENT and self:IsLocal2() then
		angle_huy[1] = x / 300
		angle_huy[2] = y / 300
		ViewPunch2(angle_huy)
	end
	
	if CLIENT and self:IsLocal() then
		self.AdditionalAng2[3] = self.AdditionalAng2[3] + angle_difference[2] * 0.5
	end
	
	self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] + math.cos(pranktime) * math.sin(pranktime - 2) * math.cos(pranktime + 1) * 1 -- * (ply.organism and ply.organism.holdingbreath and 0 or 1)
	self.AdditionalPosPreLerp[3] = self.AdditionalPosPreLerp[3] + math.sin(pranktime) * math.sin(pranktime) * math.cos(pranktime + 1) * 0.7 -- * (ply.organism and ply.organism.holdingbreath and 0 or 1)
	
	self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] - (ply:IsFlagSet(FL_ANIMDUCKING) and 1 or 0)

	--self.AdditionalPosPreLerp[2] = self.AdditionalPosPreLerp[2] + (ply.Crouching and isCrouching(ply) and -1 or 0)

	local suiciding = false--ply.suiciding
	local huypitch = ((ply.suiciding and !IsValid(ply.FakeRagdoll)) or huya or (self:IsSprinting() or ((ply.posture == 4 or ply.posture == 3) and not self:IsZoom())))

	self.pitch = Lerp(hg.lerpFrameTime(0.001,dtime), self.pitch, ply:GetNWFloat("InLegKick",0) > CurTime() and 0.5 or suiciding and 1 or huypitch and 0.65 or 0)
	
	if not huypitch then
		local torso = ply:LookupBone("ValveBiped.Bip01_Spine1")
		local tmat = ent:GetBoneMatrix(torso)
		
		if tmat then
			local ang2 = tmat:GetAngles():Forward()
			local dot = math.min((ang2:Dot(ply:GetAimVector()) + 0.5) * 4, 0)
			//dot = dot < -0.5 and dot + 0.5 or 0
			//dot = dot * 3

			self.AdditionalPos2[1] = self.AdditionalPos2[1] + dot * -4
		end
	end

	local skillissue = ply.organism and ply.organism.recoilmul or 1


	local speed_add = math.Clamp(1 / skillissue,0.5,1.5)
	
	if not suiciding and !self.norecoil then
		local mulhuy = (self:IsPistolHoldType() or self.PistolKinda) and 2 or (((ply.posture == 1 and not self:IsZoom()) or ply.posture == 7 or ply.posture == 8) and 2 or 0.75)
		local animpos = self:GetAnimShoot2(0.09 * mulhuy / host_timescale(), true) * 0.5
		animpos = animpos * 0.3 * mulhuy * (self:IsPistolHoldType() and 1 or 1)
		animpos = animpos * math.min((self.Primary.Force2 or self.Primary.Force) / 40,3) * ((self.NumBullet or 1) * 3 or 1) * (self.animposmul or 1) // * 4

		self.AdditionalPos2 = self.AdditionalPos2 - (self.AdditionalAng + self.AdditionalAng2):Forward() * animpos * 7
		//self.AdditionalPos2[3] = self.AdditionalPos2[3] + animpos * ply.offsetView[2] * 0.2
		
		if self.podkid or self:IsPistolHoldType() then
			local animpos2 = self:GetAnimShoot2(0.05 * mulhuy / host_timescale(), true)
			self.AdditionalAng2[2] = self.AdditionalAng2[2] + animpos2 * 20 * (self.podkid or 1)
			self.AdditionalAng2[3] = self.AdditionalAng2[3] + animpos2 * 10 * (self.podkid or 1)
			self.AdditionalAng2[1] = self.AdditionalAng2[1] + animpos2 * -5 * (self.podkid or 1)
			self.AdditionalPos2[2] = self.AdditionalPos2[2] - animpos2 * 1 * (self.podkid or 1)
		end
	end

	if self.GetAnimPos_Draw and CLIENT then
		local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1)
		local sin = 1 - animpos
		if sin >= 0.5 then
			sin = 1 - sin
		else
			sin = sin * 1
		end
		sin = sin * 1.5
		//sin = math.ease.InOutSine(sin)
		sin = math.ease.InOutBack(sin)

		self.AdditionalPos2[2] = self.AdditionalPos2[2] - sin * 5
		self.AdditionalAng2[1] = self.AdditionalAng2[1] + sin * 5
		self.AdditionalAng2[2] = self.AdditionalAng2[2] + sin * 10
		
		if self:IsLocal2() then
			ViewPunch2(Angle(-sin / 50, sin / 50, 0))
		end

		--self.weaponAng[2] = self.weaponAng[2] + sin * 5
		--self.weaponAng[3] = self.weaponAng[3] + sin * -25
	end

	if ply.lean then
		self.AdditionalPos2[3] = self.AdditionalPos2[3] + ply.lean * 2
	end

	self.AdditionalPos = Lerp(hg.lerpFrameTime(0.001,dtime) * self.Ergonomics * speed_add, self.AdditionalPos, self.AdditionalPosPreLerp)
	self.AdditionalAng = Lerp(hg.lerpFrameTime(0.001,dtime) * self.Ergonomics * speed_add, self.AdditionalAng, self.AdditionalAngPreLerp + self.weaponAng)

	self:CloseAnim(dtime)
	local animpos = self.lerpaddcloseanim

	self.CloseAnimAddVec = Vector(0, 0, 0)
	self.CloseAnimAddAng = Angle(0, 0, 0)
	
	if not ply:InVehicle() and not huya and not self:IsSprinting() and self.closeanimtr then
		self.CloseAnimAddVec[3] = self.CloseAnimAddVec[3] + animpos * 5 * 0.5
		self.CloseAnimAddVec[2] = self.CloseAnimAddVec[2] + animpos * -25 * 0.5
		self.CloseAnimAddVec[1] = self.CloseAnimAddVec[1] + animpos * -self.closeanimdis * 1
		local dot = self.closeanimtr.Normal:Dot(self.closeanimtr.HitNormal)
		local cross = self.closeanimtr.Normal:Cross(self.closeanimtr.HitNormal)
		self.CloseAnimAddAng[3] = self.CloseAnimAddAng[3] - animpos * 35
	end
	
	self.AdditionalPos2:Add(self.CloseAnimAddVec)
	self.AdditionalAng2:Add(self.CloseAnimAddAng)
	
	self.timetick2 = SysTime()
end

function SWEP:ShouldDoZManip()
	return !self.reload
end

function SWEP:AnimHands() end

vector_temp = Vector(0, 0, 0)

local addvec = Vector(0,0,0)
local addvec2 = Vector(0,0,0)

if SERVER then
	hook.Add("Player Think", "sethuynyis", function(ply)
		local dtime = CurTime() - (ply.lastcalley or (CurTime() - 10))
		if dtime < 0.1 then return end
		ply.lastcalley = CurTime()

		local org = ply.organism

		local power = org.pain and ((org.pain > 50 or org.blood < 2900 or org.o2[1] < 5) and 0.3) or ((org.pain > 20 or org.blood < 4200 or org.o2[1] < 10) and 0.5) or 1
		power = power * org.consciousness

		ply:SetNWFloat("power", power)
	end)
end

function SWEP:InUse()
	local ply = self:GetOwner()
	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	local org = ply.organism

	local power = ply:GetNWFloat("power", 1)

	if power < 0.4 and ent != ply then
		return false
	end

	return ( (not ply.InVehicle || !ply:InVehicle()) && self:KeyDown(IN_USE)) || (ply.InVehicle && ply:InVehicle() && not self:KeyDown(IN_USE)) || (self.reload and self.reload > 0) || (IsValid(ply.OldRagdoll))
end

local veczero = Vector(0, 0, 0)
function SWEP:SetHandPos(noset)
	self.addvec = self.addvec or veczero
	self.rhandik = self.setrhik
	self.lhandik = self.setlhik
	
	local ply = self:GetOwner()

    if not IsValid(ply) or not IsValid(self.worldModel) then return end
    if not ply.shouldTransmit or ply.NotSeen then return end

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	local inuse = self:InUse()

	//if (ent ~= ply and not (inuse)) and (self.lerped_positioning and self.lerped_positioning < 0.2) then return end
	
	if (ent ~= ply and not (inuse)) then
		--self.lhandik = self:IsPistolHoldType() and !self:KeyDown(IN_FORWARD) and !self:KeyDown(IN_BACK)//self.weight > 1 and (self.lerped_angle and self.lerped_angle > 0.5)
		self.lhandik = false
	end

	--ply:SetIK(false)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	//ent:SetupBones()

	if not self.handPos or not self.handAng then return end

	local should = self:ShouldUseFakeModel()

	/*if IsValid(self:GetWeaponEntity()) then
		self:AnimHands()
	end*/

	//self.lhandik = self.setlhik != false and !(ply.organism and ply.organism.larm == 1 or ply.organism.larmdislocation)
	local rh, lh = ply:LookupBone("ValveBiped.Bip01_R_Hand"), ply:LookupBone("ValveBiped.Bip01_L_Hand")
	
	local rhmat = ent:GetBoneMatrix(rh)
	local lhmat = ent:GetBoneMatrix(lh)

	ply.rhold = rhmat
	ply.lhold = lhmat

	if not rhmat or not lhmat then return end

	if !should then
		local vec1, ang1 = -(-self.handPos), -(-self.handAng)

		vec1:Add(ang1:Up() * -1)
		local lhang = -(-ang1)
		lhang:RotateAroundAxis(ang1:Forward(),-90)
	
		local vec2, ang2 = LocalToWorld(self.LHPos, self.LHAng, vec1, lhang)
		
		local vec1, ang1 = LocalToWorld(self.RHPosOffset, self.RHAngOffset, vec1, ang1)
		local vec2, ang2 = LocalToWorld(self.LHPosOffset, self.LHAngOffset, vec2, ang2)
	
		rhmat:SetTranslation(vec1 - addvec2)
		rhmat:SetAngles(ang1)
	
		if SERVER or CLIENT and self:IsLocal() then
			addvec = LerpFT(0.1, addvec, VectorRand(-0.03,0.03) * (ply.organism and ply.organism.holdingbreath and 0 or 1) * ((ent.organism and (ent.organism.adrenaline or 0) + (36.6 - (ent.organism.temperature or 36.6)) or 0) + 3) / 5)
			addvec2 = LerpFT(0.05 * ((ent.organism and (ent.organism.adrenaline or 0) + (36.6 - (ent.organism.temperature or 36.6)) or 0) + 1) * 15, addvec2, addvec)
		end

		if not ply.holdingWeapon or ply.holdingWeapon ~= self then
			hg.bone_apply_matrix(ent, rh, rhmat)
			--ent:SetBoneMatrix(rh, rhmat)
			
			if GetViewEntity() == self:GetOwner() then hg.set_holdrh(ent, self.hold_type or (self:IsPistolHoldType() and "pistol_hold2" or "ak_hold")) end
		end
		
		if (( hg.CanUseLeftHand(ply) and self.lhandik )) and self.attachments and vec2 and addvec2 and ang2 then
			lhmat:SetTranslation(vec2 + addvec2)
			lhmat:SetAngles(ang2)
			
			//if ply.organism and ply.organism.larm == 1 or ply.organism.larmdislocation then
			//	lhmat:SetTranslation(vec2 + addvec2 - vector_up * 10 * (math.sin(CurTime()) + 1))
			//end

			//if self.WorldModelFake then
				--lhmat = self:GetWM():GetBoneMatrix(self:GetWM():LookupBone("ValveBiped.Bip01_L_Hand"))
			--end

			hg.bone_apply_matrix(ent, lh, lhmat)
			
			--ent:SetBoneMatrix(lh, lhmat)
			
			local hold = self.hold_type or (self:IsPistolHoldType() and "pistol_hold2" or "ak_hold")
			hold = self.attachments.grip and #self.attachments.grip ~= 0 and hg.attachments.grip[self.attachments.grip[1]].hold or hold
			
			if GetViewEntity() == self:GetOwner() then hg.set_hold(ent, hold) end
		end
	else
		local wpn = self
		local mdl = self:GetWM()

		local TPIKBonesLHDict = hg.TPIKBonesLHDict
		local TPIKBonesRHDict = hg.TPIKBonesRHDict
		local TPIKBonesRHDictTranslate = hg.TPIKBonesRHDictTranslate
		local canuseright = hg.CanUseRightHand(ply) and wpn.rhandik
		local canuseleft = hg.CanUseLeftHand(ply) and wpn.lhandik

		local addvec_fem = (ThatPlyIsFemale(ply) and ply:GetAimVector():Angle():Right() * 0.2 or ply:GetAimVector():Angle():Right() * 0)
		if self.stupidgun then
			addvec_fem:Add(ply:GetAimVector():Angle():Right() * 0.3)
		end

		local angs = ply:EyeAngles()
		for bone1 = 0, mdl:GetBoneCount() - 1 do
			local name = mdl:GetBoneName(bone1)
			
			if !(TPIKBonesLHDict[name] or TPIKBonesRHDict[name]) then continue end
			if (TPIKBonesLHDict[name] and (!canuseleft or !self.lhandik)) then continue end
			if (TPIKBonesRHDict[name] and (!canuseright or !self.rhandik)) then continue end
			--[[if ent.organism and ent.organism.rarmamputated then
				name = TPIKBonesRHDictTranslate[name]

				if !name then continue end
			end--]]

			//if name != "ValveBiped.Bip01_L_Hand" then continue end
			--print(name)
			local wm_boneindex = bone1
			if !wm_boneindex then continue end
			local wm_bonematrix = mdl:GetBoneMatrix(wm_boneindex)
			if !wm_bonematrix then continue end
			
			local ply_boneindex = ent:LookupBone(TPIKBonesRHDict[name] or TPIKBonesLHDict[name] or name)
			if !ply_boneindex then continue end
			local ply_bonematrix = ent:GetBoneMatrix(ply_boneindex)
			if !ply_bonematrix then continue end
			
			wm_bonematrix:SetTranslation(wm_bonematrix:GetTranslation() + (TPIKBonesLHDict[name] and addvec_fem or vector_origin))
			
			--[[if ent.organism and ent.organism.rarmamputated then
				local mirrormat = mdl:GetBoneMatrix(mdl:LookupBone("ValveBiped.Bip01_R_Hand"))
				
				local pos = wm_bonematrix:GetTranslation()
				local mirrorpos = mirrormat:GetTranslation() - angs:Right() * 1
				
				pos = pos + angs:Right() * -(pos - mirrorpos):Dot(angs:Right())
				wm_bonematrix:SetTranslation(pos)
			end--]]

			ent:SetBoneMatrix(ply_boneindex, wm_bonematrix)
			if ply:LookupBone(ply:GetBoneName(ply_boneindex)) then ply:SetBoneMatrix(ply_boneindex, wm_bonematrix) end
		end
		//rhmat = self:GetWM():GetBoneMatrix(self:GetWM():LookupBone("ValveBiped.Bip01_R_Hand"))
	end

	if self:HasAttachment("grip") and hg.CanUseLeftHand(ply) and self.lhandik then
		local huy = (not self.reload or self.reload - 1 < CurTime()) and not ply.suiciding

		local model = self:GetAttachmentModel("grip")
		
		local inf = self:GetAttachmentInfo("grip")
		if not inf.ShouldtUseLHand then
			if inf and inf.LHandPos and IsValid(model) then
				local infpos, infang = inf.LHandPos, inf.LHandAng
				vec2, ang2 = LocalToWorld(infpos, infang, model:GetPos(), model:GetAngles())
			end

			self.lerphand = LerpFT(0.1, self.lerphand or 0, huy and 0 or 1)

			local newmat = ent:GetBoneMatrix(lh)
			local oldpos, oldang = newmat:GetTranslation(), newmat:GetAngles()
			lhmat:SetTranslation(LerpVector(self.lerphand, (vec2 or vector_origin) + (addvec2 or vector_origin), (oldpos or vector_origin)))
			lhmat:SetAngles(LerpAngle(self.lerphand, (ang2 or angle_zero), (oldang or angle_zero)))

			hg.bone_apply_matrix(ent, lh, lhmat)

			if self.lerphand < 0.1  then
				local hold = self.hold_type or (self:IsPistolHoldType() and "pistol_hold2" or "ak_hold")
				hold = self.attachments.grip and #self.attachments.grip ~= 0 and hg.attachments.grip[self.attachments.grip[1]].hold or hold

				if GetViewEntity() == self:GetOwner() then hg.set_hold(ent, hold) end
			end
		end
	end

	if !should then self:AnimationRender() end
	self:AnimHoldPost(self:GetWeaponEntity())

	//self.rhmat = rhmat
	//self.lhmat = lhmat

	return rhmat, lhmat
end

function SWEP:GetTracerOrigin()
	return select(2,self:GetTrace())
end

function SWEP:OnVarChanged(name, old, new)
	//if CLIENT and name == "OffsetView" then
		//self:GetOwner().offsetView = new
	//end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "Holster" )
	self:NetworkVar( "Float", 1, "Deploy" )
	self:NetworkVar( "Entity", 2, "HolsterWep" )
	self:NetworkVar( "Angle", 3, "OffsetView" )
	self:NetworkVar( "Float", 4, "ButtstockAttack" )

	//if (SERVER) then
		//self:NetworkVarNotify( "OffsetView", self.OnVarChanged )
	//end

	if(self.PostSetupDataTables)then
		self:PostSetupDataTables()
	end
end

SWEP.tries = 10

if SERVER then
    util.AddNetworkString("hg_animation")
elseif CLIENT then
    net.Receive("hg_animation",function()
        local tbl = net.ReadTable()
        local ent = net.ReadEntity()
        local sendtoclient = net.ReadBool()
        if IsValid(ent) and ent.PlayAnim and ( sendtoclient and sendtoclient or !ent:IsLocal()) then
            ent:PlayAnim(tbl.anim,tbl.time,tbl.cycling,tbl.callback,tbl.reverse)
        end
    end)
end

function SWEP:GetWM()
	return IsValid(self.worldModel) and self.worldModel//self:GetWeaponEntity()
end

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reload_empty",
}

//PrintAnims(Entity(1):GetActiveWeapon():GetWM())
//Entity(1):GetActiveWeapon():PlayAnim("idle", 1, false, nil, false, false)
function SWEP:PlayAnim(anim, time, cycling, callback, reverse, sendtoclient)
    --time = time * (self.StaminaReloadMul or 1)
	if SERVER then
        net.Start("hg_animation")
            local netTbl = {
                anim = anim,
                time = time,
                cycling = cycling,
                --callback = callback,
                reverse = reverse
            }
            net.WriteTable(netTbl) 
            net.WriteEntity(self)
            net.WriteBool(sendtoclient or false)
        net.SendPVS(self:GetPos())
		
		self.callback = callback
		--print(self.callback)
		timer.Create("AnimCallback"..self:EntIndex(), time or 0, 1, function()
			if not self.callback then return end
			self.callback(self)
			--self.callback = nil
		end)

		return
	end

    if not IsValid(self:GetWM()) then
		if self.tries > 0 then
			timer.Simple(0.01,function()
                if not IsValid(self) then return end
				self.tries = self.tries - 1
				
				self:PlayAnim(anim, time, cycling, callback, reverse)
			end)
		else
			self.tries = 10
		end

		return
	end
	
	local mdl = self:GetWM()
	self.tries = 10
	self.seq = self.AnimList[anim] or anim
	mdl:SetSequence(self.seq)
    self.animtime = CurTime() + time
    self.animspeed = time
    self.cycling = cycling
    self.reverseanim = reverse
    if callback then
        self.callback = callback
    end

	if self.AnimsEvents and self.AnimsEvents[self.seq] then
		local Time = time
		for k,v in pairs(self.AnimsEvents[self.seq]) do
			self.VM_TimerEvents = self.VM_TimerEvents or {}

			local TimerName = "VM_Events_ZC-Base" .. self:EntIndex() .. self.seq .. k
			local TimerID = #self.VM_TimerEvents + 1
			local seq = self.seq
			if k < 0 then v(self) continue end
			timer.Create(TimerName, Time * k, 1, function()
				if not IsValid(self) then return end
				if seq != self.seq then self:VM_RemoveAllEvents() end
				v(self, mdl)
				self.VM_TimerEvents[TimerID] = nil
			end)

			self.VM_TimerEvents[TimerID] = TimerName
		end
	end
end

if CLIENT then
	function SWEP:VM_RemoveAllEvents()
		for k,v in ipairs(self.VM_TimerEvents) do
			timer.Remove(v)
		end
		table.Empty(self.VM_TimerEvents)
	end

	function PrintPosParameters(ent)
		for i=0, ent:GetNumPoseParameters() - 1 do
			local min, max = ent:GetPoseParameterRange( i )
			print( ent:GetPoseParameterName( i ) .. ' ' .. min .. " / " .. max )
		end
	end
end

hook.Add( "EntityEmitSound", "WeaponDropSound", function( t )
	--print(string.find(t.SoundName,"physics/metal/weapon_impact_*"))
	if string.find(t.SoundName,"physics/metal/weapon_impact_*") then
		t.SoundName = "weapon_impact_soft"..math_random(1,3)..".wav"
		t.Pitch = t.Pitch - 10
		return true
	end 
end)

--[[
["Entity"]      =       Entity [0][worldspawn]
["Flags"]       =       0
["OriginalSoundName"]   =       physics/metal/weapon_impact_hard2.wav
["Pitch"]       =       98
["Pos"] =       805.196838 -249.144257 -139.931976
["SoundLevel"]  =       75
["SoundName"]   =       physics/metal/weapon_impact_hard2.wav
["SoundTime"]   =       0
["Volume"]      =       0.599609375
["Ambient"]     =       false
["Channel"]     =       0
["DSP"] =       0
]]

hook.Add("PreRegisterSWEP", "precachemodels", function(self, class)
	if self.ishgwep or self.Base == "homigrad_base" then
		if self.WorldModel then util.PrecacheModel( self.WorldModel ) end
		if self.WorldModelFake then util.PrecacheModel( self.WorldModelFake ) end

		hg.PrecacheSoundsSWEP(self)
	end
end)

function SWEP:IsResting()
    return self:GetNWBool("IsResting")
end

function SWEP:CanRest()
    if !self.RestPosition then return end
	if SERVER then
		self:WorldModel_Transform()
	end
    local pos, ang = self.desiredPos, self:GetOwner():EyeAngles()--self:GetTrace(true, nil, nil, true)
    local pos, _ = LocalToWorld(self.RestPosition, angle_zero, pos, ang)
	
    local tr = {}
    local vec = vector_up--ang:Up()
    tr.start = pos + vec * 10
    tr.endpos = pos + vec * -30
    tr.filter = {self, self:GetOwner(), hg.GetCurrentCharacter(self:GetOwner())}

    --debugoverlay.Line(tr.start, tr.endpos, 1, color_white)

    local trace = util.TraceLine(tr)
	--print(pos + vec * 10)
    if trace.Hit and !trace.StartSolid then--and trace.HitPos[3] > (self:GetOwner():EyePos()[3] - 32)/*and trace.HitNormal:Dot(ang:Up()) > 0.9*/ then
        return true, trace
    end
end

function SWEP:RestWeapon()
    if CLIENT then return end
	
    if self:IsResting() then return end
    local can, trace = self:CanRest()

    if !can then return end
    local bon = trace.Entity:TranslatePhysBoneToBone(trace.PhysicsBone)
    bon = bon == -1 and 0 or bon

    local mat = trace.Entity:IsWorld() and Matrix() or trace.Entity:GetBoneMatrix(bon)

    local lpos, _ = WorldToLocal(trace.HitPos, angle_zero, mat:GetTranslation(), mat:GetAngles())

    self:SetNWBool("IsResting", true)
    self:SetNWVector("RestPos", lpos)
    self:SetNWEntity("RestEntity", trace.Entity)
    self:SetNWInt("RestPBone", bon)
    local ang = self:GetOwner():EyeAngles()
    ang[1] = 0
	local _, lang = WorldToLocal(vector_origin, ang, vector_origin, mat:GetAngles())
    self:SetNWAngle("RestAng", lang)

	self:SetNWVector("OwnerPos", self:GetOwner():GetPos())
	self:SetNWVector("EntPos", trace.HitPos)
end

hook.Add("HG.InputMouseApply", "restrictMouseMovement", function(tbl)
    local wep = lply:GetActiveWeapon()

    if ishgweapon(wep) then
        if wep:IsResting() then
			local restent = wep:GetNWEntity("RestEntity")

            local restbone = wep:GetNWInt("RestPBone")
            restbone = restbone == -1 and 0 or restbone

            local mat = restent:IsWorld() and Matrix() or restent:GetBoneMatrix(restbone)

            local posa, anga = mat:GetTranslation(), mat:GetAngles()

			local _, anga = LocalToWorld(vector_origin, wep:GetNWAngle("RestAng"), vector_origin, mat:GetAngles())

            local restrict_pitch1 = 15
            local restrict_pitch2 = 30
            local restrict_yaw = 30

            if math.AngleDifference(tbl.angle.pitch + tbl.y / 50, anga[1]) > restrict_pitch1 then
                tbl.angle.pitch = anga[1] - math.Clamp(math.AngleDifference(anga[1], tbl.angle.pitch - tbl.y / 50), -restrict_pitch1, restrict_pitch1)
            end

            if math.AngleDifference(tbl.angle.pitch + tbl.y / 50, anga[1]) < -restrict_pitch2 then
                tbl.angle.pitch = anga[1] - math.Clamp(math.AngleDifference(anga[1], tbl.angle.pitch - tbl.y / 50), -restrict_pitch2, restrict_pitch2)
            end

            if math.abs(math.AngleDifference(tbl.angle.yaw - tbl.x / 50, anga[2])) > restrict_yaw then
                tbl.angle.yaw = anga[2] - math.Clamp(math.AngleDifference(anga[2], tbl.angle.yaw + tbl.x / 50), -restrict_yaw, restrict_yaw)
            end

            --tbl.angle.pitch = math.Clamp(tbl.angle.pitch + tbl.y / 50, anga[1] - restrict_pitch, anga[1] + restrict_pitch) - tbl.y / 50
            --tbl.angle.yaw = math.Clamp(tbl.angle.yaw - tbl.x / 50, anga[2] - restrict_yaw, anga[2] + restrict_yaw) + tbl.x / 50
        end
    end
end)

hook.Add("HG_MovementCalc_2", "moveWithWeapon", function(mul, ply, cmd, mv)
	local wep = ply:GetActiveWeapon()

    if ishgweapon(wep) then
        if wep:IsResting() then
            local restent = wep:GetNWEntity("RestEntity")

            if !IsValid(restent) and !restent:IsWorld() then
                wep:SetNWBool("IsResting", false)

                return
            end

            local restbone = wep:GetNWInt("RestPBone")
            restbone = restbone == -1 and 0 or restbone

            local mat = restent:IsWorld() and Matrix() or restent:GetBoneMatrix(restbone)

            local posa, anga = mat:GetTranslation(), mat:GetAngles()
			
			local _, ango = LocalToWorld(vector_origin, wep:GetNWAngle("RestAng"), vector_origin, anga)
			
			wep.ownerpos2 = wep:GetNWVector("OwnerPos") + ango:Right() * math.AngleDifference(ply:EyeAngles()[2], ango[2]) * 0.5 + ango:Forward() * (math.abs(math.AngleDifference(ply:EyeAngles()[2], ango[2])) * 0.2 - math.min(15, math.abs(math.AngleDifference(ply:EyeAngles()[1], ango[1]))) * 0.25)

            local restpos = LocalToWorld(wep:GetNWVector("RestPos"), angle_zero, posa, anga)

			if restpos:DistToSqr(ply:GetPos()) > 128 * 128 then
				wep:SetNWBool("IsResting", false)

                return
			end

            mv:SetSideSpeed((wep.ownerpos2 - ply:GetPos() + (restpos - wep:GetNWVector("EntPos"))):Dot(ply:EyeAngles():Right()) * 10)
            mv:SetForwardSpeed((wep.ownerpos2 - ply:GetPos() + (restpos - wep:GetNWVector("EntPos"))):Dot(ply:EyeAngles():Forward()) * 10)
			
			if restpos[3] < ply:EyePos()[3] - 40 then
				wep:SetNWBool("IsResting", false)

				return
			end

            if ply:EyeAngles()[1] < -10 or restpos[3] < ply:EyePos()[3] - 40 then
                mv:AddKey(IN_DUCK)
            else
                mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_DUCK)))
            end
        end
    end
end)