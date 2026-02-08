if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "M67"
SWEP.Instructions = 
[[M67 fragmentation grenade is used by many countries around the world since 1968. It has a pyrotechnic delay of 4-5.5 seconds.

LMB - High ready
While high ready:
RMB to remove spoon.

RMB - Low ready
While low ready:
LMB to remove spoon.
]]--"тильда двуеточее три"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "camera"
SWEP.ViewModel = ""
SWEP.WorkWithFake = true

SWEP.Spoonsound = false --выставите в ручную на гранатах это... должно быть по сути на ргд, f1 и китайском аналоге ргд

SWEP.WorldModel = "models/weapons/tfa_ins2/w_m67.mdl"
SWEP.WorldModelReal = "models/weapons/zcity/c_m67.mdl"
SWEP.WorldModelExchange = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/tfa_ins2_m67")
	SWEP.IconOverride = "vgui/hud/tfa_ins2_m67"
	SWEP.BounceWeaponIcon = false
end


SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 4
SWEP.SlotPos = 4

SWEP.setlh = true
SWEP.setrh = true

SWEP.ENT = "ent_hg_grenade_m67"

SWEP.AnimsEvents = {
	["pullbackhigh"] = {
		[0.35] = function(self)
			self:EmitSound("weapons/m67/handling/m67_pinpull.wav",65)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.55] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",65)
		end,
	},
	["pullbacklow"] = {
		[0.35] = function(self)
			self:EmitSound("weapons/m67/handling/m67_pinpull.wav",65)
			--
			--self:GetWM():ManipulateBoneScale(47, vector_full)
		end,
		[0.55] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",65)
		end,
	},
}

SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "draw", 1, false },
    ["attack"] = { "throw", 0.8, false, false, function(self)

		if CLIENT then return end
		--local tr = self:GetEyeTrace()
		--self:Tie(tr)
		
		self:Throw(1200, self.SpoonTime or CurTime(),nil,Vector(2,4,0),Angle(-40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end
			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.65 },
	["attack2"] = { "lowthrow", 0.8, false, false, function(self)
		--local tr = self:GetEyeTrace()
		--self:Tie(tr)
		if CLIENT then return end
		self:Throw(600, self.SpoonTime or CurTime(),nil,Vector(0,4,-6),Angle(40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.IsLowThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end

			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.6 },
	["pullbackhigh"] = {"pullbackhigh", 1.5, false, false, function(self) 
		self:SetShowPin(false)
		--self:PlayAnim("attack")
		self.ReadyToThrow = true
	end,0.8},
	["pullbacklow"] = {"pullbacklow", 1.5, false, false, function(self) 
		--self:PlayAnim("attack2")
		self:SetShowPin(false)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end,0.8},
	["idle"] = {"draw", 1, false,false,function(self)
	end}
}

SWEP.HoldPos = Vector(2,0.2,-1.5)
SWEP.HoldAng = Angle(0,0,0)

SWEP.ViewBobCamBase = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 120

SWEP.CallbackTimeAdjust = 0.1

function SWEP:Deploy( wep )
	self:PlayAnim("deploy")
end

function SWEP:Holster( wep )
	if SERVER then
		--self:PlayAnim("idle")
		self:SetShowSpoon(true)
		self:SetShowGrenade(true)
		self:SetShowPin(true)
		if self.ReadyToThrow then
			if self.Spoon then
				self:CreateSpoon(self:GetOwner())
				self.Spoon = false
				self:SetShowSpoon(false)
			end
			self:Throw(0, self.SpoonTime or CurTime(),nil,Vector(0,0,0),Angle(0,0,0))
			self:Remove()
		end

		return true
	end
end

if SERVER then
    function SWEP:OnRemove() end

	function SWEP:OnDrop()
		timer.Simple(0.2,function()
			if self.ReadyToThrow then
				if self.Spoon then
					self:CreateSpoon(self:GetOwner())
					self.Spoon = false
					self:SetShowSpoon(false)
				end
				self.ReadyToThrow = false
				self:Throw(0, self.SpoonTime or CurTime(),nil,Vector(0,0,0),Angle(0,0,0))
				self:Remove()
			end
		end)
	end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 1, "ShowSpoon")
	self:NetworkVar("Bool", 2, "ShowGrenade")
	self:NetworkVar("Bool", 3, "ShowPin")
end

function SWEP:PickupFunc(ply)
    local wep = ply:GetWeapon(self:GetClass())
    if IsValid(wep) and wep.count < 3 and wep != self then
        
        wep.count = wep.count + self.count
		self.count = 0
        self:Remove()
        
        return true
    end
    return false
end

function SWEP:Throw(mul, time, nosound, throwPosAdjust, throwAngAdjust)
	if not self.ENT then return end

	local owner = self.Thrower or self:GetOwner()
	local ent = ents.Create(self.ENT)
	local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or IsValid(owner) and owner
	throwPosAdjust = throwPosAdjust or Vector(0,0,5)
	throwAngAdjust = throwAngAdjust or Angle(0,0,0)
	local ang = IsValid(entOwner) and owner:EyeAngles() or self:GetAngles()
	local hand = IsValid(entOwner) and owner:EyePos() + ang:Forward() * throwPosAdjust[1] + ang:Right() * throwPosAdjust[2] + ang:Up() * throwPosAdjust[3] or self:GetPos()

	if IsValid(entOwner) then
		ent:SetOwner(entOwner or game.GetWorld())
	end
	
	ent.team = owner:Team()
	ent.steamid = owner:SteamID()

	if not nosound and IsValid(entOwner) then
		entOwner:EmitSound(self.throwsound or "weapons/m67/m67_throw_01.wav", 90, math.random(95, 105))
	end

	if SERVER and IsValid(owner) and owner:IsPlayer() then
		local playerClass = owner.PlayerClassName
		if playerClass == "terrorist" or playerClass == "nationalguard" or
		   playerClass == "commanderforces" or playerClass == "swat" then
			timer.Simple(0.1, function()
				if IsValid(owner) and hg and hg.GetPlayerClassPhrases then
					local classPhrases = hg.GetPlayerClassPhrases(owner, "grenade_throw")
					if classPhrases and #classPhrases > 0 then
						local randomPhrase = classPhrases[math.random(#classPhrases)]
						local ent_char = hg.GetCurrentCharacter(owner)
						local muffed = owner.armors and owner.armors["face"] == "mask2"
						
						if IsValid(ent_char) then
							ent_char:EmitSound(randomPhrase, muffed and 75 or 85, owner.VoicePitch or 100, 1, CHAN_AUTO, 0, muffed and 14 or 0)
						else
							owner:EmitSound(randomPhrase, muffed and 75 or 85, owner.VoicePitch or 100, 1, CHAN_AUTO, 0, muffed and 14 or 0)
						end
						
						owner.lastPhr = randomPhrase
					end
				end
			end)
		end
	end

	if IsValid(owner) then
		owner:ViewPunch(Angle(3,0,0))
		owner:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE, true)
	end
	ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	timer.Simple(0.15,function()
		if IsValid(ent) then
			ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
		end
	end)
	ent:Spawn()
	ent:SetPos(hand + (IsValid(owner) and self:GetAngles():Forward() * 5 or vector_origin))
	local angThrow = IsValid(owner) and owner:EyeAngles() or self:GetAngles()
	angThrow:RotateAroundAxis(angThrow:Forward(),throwAngAdjust[1])
	angThrow:RotateAroundAxis(angThrow:Right(),throwAngAdjust[2])
	angThrow:RotateAroundAxis(angThrow:Up(),throwAngAdjust[3])
	ent:SetAngles(angThrow)
	local phys = ent:GetPhysicsObject()
	if phys then 
		real_ent = hg.GetCurrentCharacter(owner)
		phys:SetVelocity(IsValid(real_ent) and (owner:GetAimVector() * mul/1.5) + real_ent:GetVelocity() or Vector(0,0,0)) 
	end
	if owner:IsOnGround() then
		owner:SetVelocity(owner:GetVelocity() - owner:GetVelocity()/2)
	end
	ent.timer = time
	ent.owner = self.lastOwner
	ent.owner2 = self.lastOwner

	--self.removed = true
	if IsValid(owner) then
		self:ThrowAdd()
	end

	self.Thrower = nil
end

function SWEP:ThrowAdd()
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace( self:GetOwner())
end

function SWEP:KeyDown(key_enum)
	local owner = IsValid(self:GetOwner()) and self:GetOwner() or nil
	if not owner or not owner:IsPlayer() then return false end
	return self:GetOwner():KeyDown(key_enum)
end

if CLIENT then
	function SWEP:DrawHUD()
		--PrintBones(self:GetWM())
		--if GetViewEntity() ~= LocalPlayer() then return end
		--if LocalPlayer():InVehicle() then return end
       --local tr = self:GetEyeTrace()
       --local toScreen = tr.HitPos:ToScreen()

       --surface.SetDrawColor(255,255,255,155)
       --surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
	end
end

function SWEP:SecondaryAttack()
	if self.ReadyToThrow or self.CoolDown > CurTime() then return end

	local owner = self:GetOwner()
	if not hg.CanUseLeftHand(owner) or not hg.CanUseRightHand(owner) then return end

	self.CoolDown = CurTime() + 2
	self:PlayAnim("pullbacklow")
	self.Thrower = self:GetOwner()
end

function SWEP:InitAdd()
	self:PlayAnim("deploy")
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	self.IsLowThrow = false
	self.ReadyToThrow = false
	self.Spoon = true
	self.InThrowing = false
	self.SpoonTime = false
	self.count = 1
	self:InitAdd()
	if SERVER then
		self:SetShowSpoon(true)
		self:SetShowGrenade(true)
		self:SetShowPin(true)
	end
end
local vec_remove = Vector(0,0,0)
local vec_show = Vector(1,1,1)

SWEP.ItemsBones = {
	["Grenade"] = {57},
	["Spoon"] = {58},
	["Pin"] = {59,60,61},
}

local IDItems = {
	"Grenade",
	"Spoon",
	"Pin"
}
function SWEP:DrawPostPostModel()

end
function SWEP:DrawPostWorldModel()
	for i = 1, #IDItems do
		local IDItem = IDItems[i]
		for j = 1, #self.ItemsBones[ IDItem ] do
			local item = self.ItemsBones[ IDItem ][ j ]
			self:GetWM():ManipulateBoneScale( item, self[ "GetShow"..IDItem ]() and vec_show or vec_remove )
		end
	end
	self:DrawPostPostModel()
end

function SWEP:AddStep() end

function SWEP:ThinkAdd()
	self:AddStep()
	self:SetHold(self.HoldType)
	self.lastOwner = self:GetOwner()
	if not SERVER then return end

	if not self.timeToBoom then
		local ent = scripted_ents.GetStored(self.ENT)--scripted_ents.Get("ent_"..string.sub(self:GetClass(),8))
		
		self.timeToBoom = ent.timeToBoom or 5
	end

	if self.ReadyToThrow and ( ( self.IsLowThrow and not self:KeyDown(IN_ATTACK2) ) or not self.IsLowThrow and not self:KeyDown(IN_ATTACK) ) and not self.InThrowing then
		self:PlayAnim(self.IsLowThrow and "attack2" or "attack")
		self.InThrowing = true
		self:SetShowGrenade(false)
		if self.Spoon then
			self.SpoonTime = CurTime()
			self:CreateSpoon(self:GetOwner())
			self.Spoon = false
			self:SetShowSpoon(false)
		end
	end

	if self.ReadyToThrow and 
		(self.NoSpoon or ( ( ( self.IsLowThrow and self:KeyDown(IN_ATTACK) ) or not self.IsLowThrow and self:KeyDown(IN_ATTACK2) ) ))
		and not self.InThrowing and not self.SpoonTime then
		self.SpoonTime = CurTime()
		self:CreateSpoon(self:GetOwner())
		self.Spoon = false
		self:SetShowSpoon(false)
	end
	if self.SpoonTime and self.Debug then
		self:GetOwner():ChatPrint(self.SpoonTime - CurTime())
	end
	if self.SpoonTime and self.SpoonTime + self.timeToBoom < CurTime() and not self.InThrowing then
		self.InThrowing = true
		self:SetShowGrenade(false)
		self:Throw(0, self.SpoonTime or CurTime(),nil,Vector(0,0,0),Angle(0,0,0))
		self:Remove()
	end
end

SWEP.spoon = "models/weapons/arc9/darsu_eft/skobas/m67_skoba.mdl"

function SWEP:CreateSpoon(entownr)
	local entasd
	if not self.spoon then return end
	if IsValid(entownr) then
		local hand = entownr:GetBoneMatrix(entownr:LookupBone("ValveBiped.Bip01_R_Hand"))

		entasd = ents.Create("ent_hg_spoon")
		entasd:SetModel(self.spoon)
		entasd:SetPos(hand:GetTranslation())
		entasd:SetAngles(hand:GetAngles())
		entasd:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		entasd:Spawn()

		if self.Spoonsound then
			entasd:EmitSound("m9/m9_fp.wav", 70, 150)
		end
		
		entownr:EmitSound("weapons/m67/m67_spooneject.wav",65)

		if self.SpoonSounds then
			for k,v in ipairs(self.SpoonSounds) do
				self:GetOwner():EmitSound(v[1],v[2])
			end
		end

		hg.EmitAISound(hand:GetTranslation(), 96, 5, 8)
	else
		entasd = ents.Create("ent_hg_spoon")
		entasd:SetModel(self.spoon)
		entasd:SetPos(self:GetPos())
		entasd:SetAngles(self:GetAngles())
		entasd:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		entasd:Spawn()

		if self.Spoonsound then
			entasd:EmitSound("m9/m9_fp.wav", 70, 150)
		end

		entasd:EmitSound("weapons/m67/m67_spooneject.wav",65)

		if self.SpoonSounds then
			for k,v in ipairs(self.SpoonSounds) do
				self:GetOwner():EmitSound(v[1],v[2])
			end
		end

		hg.EmitAISound(self:GetPos(), 96, 5, 8)
	end

	return entasd
end

SWEP.CoolDown = 0

function SWEP:PrimaryAttack()
	if self.ReadyToThrow or self.CoolDown > CurTime() then return end

	local owner = self:GetOwner()
	if not hg.CanUseLeftHand(owner) or not hg.CanUseRightHand(owner) then return end

	self.CoolDown = CurTime() + 2
	self:PlayAnim("pullbackhigh")
	self.Thrower = self:GetOwner()
end

function SWEP:Reload()
end
