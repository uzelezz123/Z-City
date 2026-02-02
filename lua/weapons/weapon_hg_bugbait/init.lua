AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.ENT = "ent_hg_bugbait"

function SWEP:CreateSpoon(entownr)
end

function SWEP:Deploy( wep )
	self:PlayAnim("deploy")
end

function SWEP:InitAdd()
	self:PlayAnim("deploy")
end

function SWEP:ThinkAdd()
	self:AddStep()
	self:SetHold(self.HoldType)
	self.lastOwner = self:GetOwner()
	self.thrown = false
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

	if self.ReadyToThrow and ( ( self.IsLowThrow and self:KeyDown(IN_ATTACK) ) or not self.IsLowThrow and self:KeyDown(IN_ATTACK2) ) and not self.InThrowing and not self.SpoonTime then
		self.SpoonTime = CurTime()
		self:CreateSpoon(self:GetOwner())
		self.Spoon = false
		self:SetShowSpoon(false)
	end
	if self.SpoonTime and self.Debug then
		self:GetOwner():ChatPrint(self.SpoonTime - CurTime())
	end
end

function SWEP:Holster( wep )
	if SERVER then
		self:PlayAnim("idle")
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
		end

		return true
	end
end

if SERVER then
    function SWEP:OnRemove() end

	function SWEP:OnDrop()
		timer.Simple(0.2,function()
			if IsValid(self) and self.ReadyToThrow then
				if self.Spoon then
					self:CreateSpoon(self:GetOwner())
					self.Spoon = false
					self:SetShowSpoon(false)
				end
				self:Throw(0, self.SpoonTime or CurTime(),nil,Vector(0,0,0),Angle(0,0,0))
			end
		end)
	end
end

function SWEP:PickupFunc(ply)
    local wep = ply:GetWeapon(self:GetClass())
    if IsValid(wep) and wep.count < 3 and wep != self then
        
        wep.count = wep.count + self.count
		self.count = 0
        
        return true
    end
    return false
end

function SWEP:Reload()
	local time = CurTime()
	if self.SqueezeCD > time then return end

	self:PlayAnim("special", 0.6)
	self:EmitSound("weapons/mmod/bugbait/bugbait_squeeze1.wav",90)
	self.SqueezeCD = time + 2

	local SelfPos = self:GetPos()
	hg.EmitAISound(SelfPos, 512, 16, 512)

	for _, npc in ipairs(ents.FindInSphere(SelfPos, 512)) do
		if IsValid(npc) and npc:IsNPC() and npc:GetClass() == "npc_antlion" then
			npc:AddRelationship("player D_LI 99")
			npc:SetLastPosition(SelfPos)
			npc:SetSchedule(SCHED_FORCED_GO_RUN)
			npc:EmitSound("npc/antlion/distract1.wav", 80, math.random(90, 110))
			npc.SatisfactionEndTime = CurTime() + 60

			if not npc.SatisfactionEndTime then
				hook.Add("Think", npc:EntIndex(), function()
					if npc.SatisfactionEndTime < CurTime() or not IsValid(npc) then
						npc:AddRelationship("player D_HT 99")
						npc.SatisfactionEndTime = nil
						hook.Remove("Think", npc:EntIndex())
					end
				end)
			end
		end
	end
end