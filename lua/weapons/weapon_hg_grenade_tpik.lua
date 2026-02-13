if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "M67"
SWEP.Instructions = 
[[M67 fragmentation grenade is used by many countries around the world since 1968. It has a pyrotechnic delay of 4-5.5 seconds.

LMB - High ready
While high ready:
RMB to remove spoon.
Reload to insert pin back.

RMB - Low ready
While low ready:
LMB to remove spoon.
Reload to insert pin back.
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
	["revers_pullbackhigh"] = {"pullbackhigh", 2, false, true, function(self) 
		self:SetShowPin(true)
	end,0.9},
	["revers_pullbacklow"] = {"pullbacklow", 2, false, true, function(self) 
		self:SetShowPin(true)
	end,0.9},
	["idle"] = {"draw", 1, false, false, function(self)
	end}
}

SWEP.HoldPos = Vector(2,0.2,-1.5)
SWEP.HoldAng = Angle(0,0,0)

SWEP.ViewBobCamBase = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 120

SWEP.CallbackTimeAdjust = 0.1
SWEP.NoTrap = true

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

		if self:GetNWBool("PlacedTrap", false) then
			self.count = self.count - 1
			self.Trap = nil
			self:ResetTrap()
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end
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
	--throwPosAdjust[2] = throwPosAdjust[2] + 2
	local _,_,headm = self:GetEyeTrace()
	local eyepos = headm:GetTranslation() or false
	local ang = IsValid(entOwner) and owner:EyeAngles() or self:GetAngles()
	local hand = eyepos and eyepos + ang:Forward() * throwPosAdjust[1] + ang:Right() * (throwPosAdjust[2] + 2) + ang:Up() * throwPosAdjust[3] or self:GetPos()

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
	local colWhite = Color(255, 255, 255, 155)
	local lerpthing = 0
	function SWEP:DrawHUD()
		if GetViewEntity() ~= lply then return end
		if lply:InVehicle() then return end
		if hg.GetCurrentCharacter(lply):IsRagdoll() then return end

		local tr = self:GetEyeTrace()
		local toScreen = tr.HitPos:ToScreen()

		lerpthing = Lerp(0.1, lerpthing, (hg.eyeTrace(lply).Hit and not lply:IsSprinting() and not self.NoTrap) and 1 or 0)
		colWhite.a = 255 * lerpthing
		surface.SetDrawColor(colWhite)
		surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
	end
end

function SWEP:SecondaryAttack()
	if self.ReadyToThrow or self.CoolDown > CurTime() or self:GetNWBool("PlacedTrap", false) then return end

	local owner = self:GetOwner()
	if not hg.CanUseLeftHand(owner) or not hg.CanUseRightHand(owner) then return end

	self.CoolDown = CurTime() + 2
	self:PlayAnim("pullbacklow")
	self.Thrower = self:GetOwner()

	self.TrappingRN = false
	self.ReadyToTrap = false
	self:SetNWBool("PlacedTrap", false)
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
	if IsValid(self.Trap) then return end
	--print(self.ReadyToTrap)
	if self.ReadyToTrap then
		self:PlaceTrap()
	end

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

		entownr:EmitSound("weapons/m67/m67_spooneject.wav", 65)

		if self.SpoonSounds then
			for k,v in ipairs(self.SpoonSounds) do
				self:GetOwner():EmitSound(v[1], v[2], v[3])

				if v[4] then
					local effectData = EffectData()
					effectData:SetOrigin(entasd:GetPos())
					effectData:SetScale(0.04)
					effectData:SetEntity(entasd)
					util.Effect("eff_jack_genericboom", effectData, true, true)
				end
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

		entasd:EmitSound("weapons/m67/m67_spooneject.wav",65)

		if self.SpoonSounds then
			for k,v in ipairs(self.SpoonSounds) do
				self:GetOwner():EmitSound(v[1], v[2], v[3])

				if v[4] then
					local effectData = EffectData()
					effectData:SetOrigin(entasd:GetPos())
					effectData:SetScale(0.04)
					effectData:SetEntity(entasd)
					util.Effect("eff_jack_genericboom", effectData, true, true)
				end
			end
		end

		hg.EmitAISound(self:GetPos(), 96, 5, 8)
	end

	return entasd
end

SWEP.CoolDown = 0

function SWEP:PrimaryAttack()
	if self.ReadyToThrow or self.CoolDown > CurTime() or self:GetNWBool("PlacedTrap", false) then return end

	local owner = self:GetOwner()
	if not hg.CanUseLeftHand(owner) or not hg.CanUseRightHand(owner) then return end

	self.CoolDown = CurTime() + 2
	self:PlayAnim("pullbackhigh")
	self.Thrower = self:GetOwner()

	self.TrappingRN = false
	self.ReadyToTrap = false
	self:SetNWBool("PlacedTrap", false)
end

function SWEP:OwnerChanged()
	if SERVER and self:GetNWBool("PlacedTrap", false) then
		self.count = self.count - 1
		self.Trap = nil
		self:ResetTrap()
		if self.count < 1 then
			if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
				self:GetOwner():SelectWeapon("weapon_hands_sh")
			end
			self:Remove()
		end
	end
end

--// Booby trap stuff
SWEP.lpos = Vector(2,0,0)
SWEP.lang = Angle(0,0,0)

function SWEP:ResetTrap()
	self:PlayAnim("deploy")
	self.ReadyToThrow = false
	self.TrappingRN = false
	self.ReadyToTrap = false
	self:SetNWBool("PlacedTrap", false)
end

function SWEP:PlaceTrap()
	if self.NoTrap then return end

	local time = CurTime()
	if CLIENT then return end

	local ply = self:GetOwner()
	if hg.GetCurrentCharacter(ply):IsRagdoll() then return end

	local entownr
	if IsValid(ply) then
		entownr = hg.GetCurrentCharacter(ply)
	end
	
	if ply:IsSprinting() then
		self:ResetTrap()
	return end

	if not hg.eyeTrace(ply).Hit then
		self:ResetTrap()
	return end

	if not self.startedattack and entownr == ply and not self:GetNWBool("PlacedTrap", false) then
		local tr = hg.eyeTrace(ply)
		local ent = ents.Create(self.ENT)
		local pos,ang = LocalToWorld(self.lpos, self.lang, tr.HitPos, tr.HitNormal:Angle())
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
		ent.owner = self.lastOwner
		ent.owner2 = self.lastOwner
		ent:SetOwner(self.lastOwner)
		
		ent.cons2 = constraint.Weld(ent,tr.Entity,0,tr.PhysicsBone or 0, 200, true, false)
		
		self.Trap = ent
		
		self:SetNWBool("PlacedTrap", true)
	elseif IsValid(self.Trap) then
		local tr = hg.eyeTrace(ply)

		local tr2 = {}
		tr2.start = self.Trap:GetPos()
		tr2.endpos = tr.HitPos
		tr2.filter = self.Trap
		local trace = util.TraceLine(tr2)

		if trace.Hit then return end
		
		local len = tr.HitPos:Distance(self.Trap:GetPos())
		if len < 200 and len > 10 then
			self.Trap.ent = tr.Entity
			self.Trap.lpos = tr.Entity:WorldToLocal(tr.HitPos)
			self.Trap.origlen = tr.HitPos:Distance(self.Trap:GetPos())
			local cons = constraint.CreateKeyframeRope(
				tr.HitPos, 0.05, "cable/cable2", nil,
				self.Trap.ent, self.Trap.lpos, tr.PhysicsBone, self.Trap,
				vector_origin, 0,
				{
					["Slack"] = 50,
					["Collide with world"] = false,
				}
			)

			local ent2 = ents.Create("prop_physics")
			ent2:SetModel("models/hunter/plates/plate.mdl")
			
			ent2:SetMoveType(MOVETYPE_NONE)
			ent2:SetSolid(SOLID_VPHYSICS)
			ent2:Spawn()
			local size = 1
			local pos = self.Trap:GetPos()
			--local dir = (tr.HitPos - pos):GetNormalized() * 1
			ent2:PhysicsInitConvex({
				Vector( tr.HitPos[1], tr.HitPos[2], tr.HitPos[3] ),
				Vector( tr.HitPos[1], tr.HitPos[2], tr.HitPos[3] + size ),
				Vector( tr.HitPos[1] + size, tr.HitPos[2], tr.HitPos[3] ),
				Vector( tr.HitPos[1] + size, tr.HitPos[2], tr.HitPos[3] + size ),
				Vector( pos[1], pos[2], pos[3] ),
				Vector( pos[1], pos[2], pos[3] + size ),
				Vector( pos[1] + size, pos[2], pos[3] ),
				Vector( pos[1] + size, pos[2], pos[3] + size ),
			})			
			ent2:EnableCustomCollisions(true)

			local phys = ent2:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetMass(1)
			end

			ent2.Trap = self.Trap
			ent2:SetNoDraw(true)
			ent2:AddCallback("PhysicsCollide",function()
				if IsValid(ent2.Trap) and ent2.Trap.Arm then
					ent2.Trap:Arm(CurTime() - ent2.Trap.timeToBoom + 1, vector_origin)
				end
			end)

			--[[ broken
			constraint.NoCollide(self.Trap, ent2, 0, 0, false)
			constraint.NoCollide(self.Trap.ent, ent2, 0, 0, false)
			constraint.NoCollide(self.Trap, self.Trap.ent, 0, 0, false)

			constraint.Weld(self.Trap, ent2, 0, 0, 0, true, false)
			constraint.Weld(self.Trap.ent, ent2, 0, 0, 0, true, false)
			]]

			self.Trap.ent2 = ent2
			self.Trap.cons = cons

			--ply:SelectWeapon("weapon_hands_sh")

			self.count = self.count - 1
			self.Trap = nil
			self:ResetTrap()
			self:PlayAnim("deploy")
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end
		end
	else
		self:PlayAnim("deploy")
	end

	--self:PlayAnim("deploy")
	self.TrappingRN = false
	self.ReadyToTrap = false
end

function SWEP:ResetThrow()
	if self.SpoonTime then return end
	self.ReadyToThrow = false
	self:PlayAnim(self.IsLowThrow and "revers_pullbacklow" or "revers_pullbackhigh")
	self.IsLowThrow = false
end

function SWEP:Reload()
	if CLIENT then return end
	if (self.ReloadCD and self.ReloadCD > CurTime()) then return end
	if self.ReadyToThrow then
		self:ResetThrow()
		self.ReloadCD = CurTime() + 1
		return
	end
	if self.NoTrap or (self.TrappingRN or false) then return end

	local ply = self:GetOwner()
	if hg.GetCurrentCharacter(ply):IsRagdoll() then return end

	if ply:IsSprinting() then return end
	if not hg.eyeTrace(ply).Hit then return end

	if self:GetNWBool("PlacedTrap", false) then
		self.ReloadCD = CurTime() + 1
		self:PlaceTrap()
	else
		self.TrappingRN = true
		self:PlayAnim("trapplace")
	end
end