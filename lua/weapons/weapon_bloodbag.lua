if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Bloodbag"
SWEP.Instructions = "A plastic bag containing neccesary instruments to acknowledge blood and transfuse it. Can be used to help with large blood loss."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/zcity/other/bloodbag.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("zcity/hud/wepicons/bloodbag.png")
	SWEP.IconOverride = "zcity/hud/wepicons/bloodbag.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -4, 0)
SWEP.offsetAng = Angle(-30, 20, 180)
SWEP.modeNames = {
	[1] = "blood"
}

SWEP.ofsV = Vector(-1,3,11)
SWEP.ofsA = Angle(-0,-90,90)

function SWEP:SetupDataTablesAdd()
	self:NetworkVar( "Bool", 0, "HasBlood" )
end

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	self.modeValues = {
		[1] = 0
	}

	if SERVER then
		if math.random(2) == 1 then
			self.modeValues[1] = 1
			//local val,index = table.Random(hg.organism.bloodtypes)
			self.bloodtype = "o-"
		end
	end
end

SWEP.modeValuesdef = {
	[1] = {1,true},
}

SWEP.showstats = true

SWEP.modeNames2 = {
	[1] = "take blood",
	[2] = "give blood"
}

function SWEP:GetInfo()
	if not IsValid(self) then
		local modevalues = {}
		for i,val in ipairs(self.modeValuesdef) do
			modevalues[i] = istable(val) and val[1] or val
		end
		return modevalues
	end
	local tblcopy = table.Copy(self.modeValues)
	tblcopy.bloodtype = self.bloodtype or "o-"
	return tblcopy
end

function SWEP:SetInfo(info)
	self:SetNetVar("modeValues",info)
	self.modeValues = info
	self.bloodtype = ""..(self.modeValues.bloodtype or "o-")
	self.modeValues.bloodtype = nil
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:NPCHeal(owner, 0.3, "zcity/healing/bloodbag_spear_0.wav")
	end
end

if SERVER then
	function SWEP:SecondaryAttack()
		if not self:GetOwner():KeyPressed(IN_ATTACK2) then return end
		local ent = hg.eyeTrace(self:GetOwner()).Entity
		if ent:IsPlayer() or ent:IsRagdoll() then
			self.sndcd = CurTime() + 1
			self:GetOwner():EmitSound("zcity/healing/bloodbag_spear_0.wav")
			self:SetNextSecondaryFire(CurTime() + 1)
		end
	end

	function SWEP:PrimaryAttack()
		if not self:GetOwner():KeyPressed(IN_ATTACK) then return end
		self.sndcd = CurTime() + 1
		self:GetOwner():EmitSound("zcity/healing/bloodbag_spear_0.wav")
		self:SetNextPrimaryFire(CurTime() + 1)
	end

	function SWEP:Reload()
		if self:GetOwner():KeyPressed(IN_RELOAD) then
			local mode = self:GetNetVar("mode",2)
			self:SetNetVar("mode",((mode + 1) > 2) and 1 or (mode + 1))
			self:GetOwner():ChatPrint("You have chosen the " .. self.modeNames2[mode] .. " mode")
		end
	end

	SWEP.sndcd = 0

	function SWEP:Think()
		self:SetHold(self.HoldType)

		self.net_cooldown = self.net_cooldown or CurTime()
		local owner = self:GetOwner()
		
		if self:GetNetVar("mode",2) == 2 then
			if self.modeValues[1] != 1 then
				if owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2) then
					local ent = owner:KeyDown(IN_ATTACK) and owner or hg.eyeTrace(self:GetOwner()).Entity
					if not ent.organism then return end
					local ent = hg.GetCurrentCharacter(ent)
					if ent:GetVelocity():LengthSqr() < 25 and ent.organism.blood > 2000 and (not self.bloodtype or ent.organism.bloodtype == self.bloodtype) then
						local old = -(-self.modeValues[1])
						self.modeValues[1] = math.min(self.modeValues[1] + FrameTime() * (math.max(ent.organism.pulse / 70,0.3)) * 0.5,1)
						self.bloodtype = ent.organism.bloodtype

						if ent.organism.furryinfected then
							self.furryinfected = true
						end
						
						if self.poisoned2 then
							ent.organism.poison4 = CurTime()
				
							self.poisoned2 = nil
						end
						
						ent.organism.blood = math.max(ent.organism.blood - (self.modeValues[1] - old) * 500,0)
						if self.sndcd < CurTime() and old ~= self.modeValues[1] then
							owner:EmitSound("zcity/healing/bloodbag_loop_".. math.random(8) ..".wav")
							self.sndcd = CurTime() + 0.7
						end
					end
				end
			end
		else
			if self.modeValues[1] > 0 then
				if owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2) then
					local ent = owner:KeyDown(IN_ATTACK) and owner or hg.eyeTrace(self:GetOwner()).Entity
					if not ent.organism then return end
					local ent = hg.GetCurrentCharacter(ent)
					if ent:GetVelocity():LengthSqr() < 1000 then
						local old = -(-ent.organism.blood)
						local good_type = hg.organism.bloodtypes[self.bloodtype or "o-"][ent.organism.bloodtype or "o-"]

						if self.poisoned2 then
							ent.organism.poison4 = CurTime()
				
							self.poisoned2 = nil
						end

						--print(good_type)
						if good_type then
							ent.organism.blood = math.min(ent.organism.blood + math.min(FrameTime() * 0.5 * (math.max(ent.organism.pulse / 70,0.3)),self.modeValues[1]) * 500, 5200)
						else
							ent.organism.blood = math.min(ent.organism.blood + math.min(FrameTime() * 0.5 * (math.max(ent.organism.pulse / 70,0.3)),self.modeValues[1]) * 200, 5200)
							ent.organism.hemotransfusionshock = ent.organism.hemotransfusionshock + math.min(FrameTime() * 0.5,self.modeValues[1])
						end

						if (self.bloodtype == "c-" or self.furryinfected) and ent.PlayerClassName != "furry" and (ent.organism.blood - old) > 0 then
							ent.organism.furryinfected = true
						end

						self.modeValues[1] = math.max(self.modeValues[1] - (ent.organism.blood - old) / (good_type and 500 or 200),0)
						if self.sndcd < CurTime() and old ~= ent.organism.blood  then
							owner:EmitSound("zcity/healing/bloodbag_loop_".. math.random(8) ..".wav")
							self.sndcd = CurTime() + 0.7
						end
					end
				end
			else
				self.bloodtype = nil
			end
		end

		if self.modeValues[1] < 0.00001 then 
			self.modeValues[1] = 0 
			self:SetHasBlood(false) 
			self:SetBodygroup(1,1)
		else
			self:SetHasBlood(true)
			self:SetBodygroup(1,0)
		end

		if self.net_cooldown < CurTime() then
			self:SetNetVar("modeValues",self.modeValues)
			self:SetNetVar("type",self.bloodtype)
			self.net_cooldown = CurTime() + 0.1
		end
	end
else
	function SWEP:Animation()
		self:SetHold(self.HoldType)
		local owner = self:GetOwner()

		if owner.zmanipstart ~= nil and not owner.organism.larmamputated then return end

		local aimvec = owner:GetAimVector()
		if not aimvec then return end
		local ducking = owner:IsFlagSet(FL_ANIMDUCKING)

		self:BoneSet("r_upperarm", vector_origin, Angle(10, -65 - 20 * aimvec[3] * (ducking and 3 or 1), 10))
	end

	function SWEP:Think()
		local ent = hg.eyeTrace(self:GetOwner()).Entity
		ent = IsValid(ent) and ent.organism and ent or self:GetOwner()
		local mode = self:GetNetVar("mode",2)
		self.modeNames[1] = self:GetNetVar("modeValues", {})[1] == 0 and self.modeNames2[mode] .. " | Recipent: " .. ent.organism.bloodtype or self.modeNames2[mode] .. " | in: "..self:GetNetVar("type","o-").." | recipent: "..ent.organism.bloodtype
	end

	function SWEP:AfterDrawModel(wm,nodraw)
		local set = (self:GetHasBlood() and 0 or 1)//IsValid(self:GetOwner()) and (self:GetHasBlood() and 0 or 1) or (self:GetHasBlood() and 1 or 0)
		if IsValid(wm) and wm:GetBodygroup(0) != set then
			wm:SetBodygroup(0, set)
		end
	end
end