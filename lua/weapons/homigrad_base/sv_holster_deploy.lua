local CurTime = CurTime

--!! fix ts shit
--SWEP.endedholster = false
function SWEP:Holster(wep)--
	--[[if self.endedholster == true then
		return true
	end]]

	--self.endedholster = false

	--[[if wep.deploy ~= nil then
		return true
	end

	if self.holster ~= nil then return false end]]

	if self.deploy then
		self:SetDeploy(0)
		self.deploy = nil
	end

	self.reload = nil

	do return true end --!!

	local time = CurTime()
	if IsValid(wep) then
		self:SetHolsterWep(wep)
	end

	if self.holster and self.holster - time < 0 then
		self:Holster_End()
	end

	if self.reload then
		self.reload = nil
		self.StaminaReloadTime = nil
	end

	self.holster = time + self.CooldownHolster / self.Ergonomics
	self:SetHolster(self.holster)

	--self.endedholster = true

	return true
end

local vecZero = Vector(0, 0, 0)
function SWEP:Holster_End()
	local owner = self:GetOwner()
	local wep = IsValid(self:GetHolsterWep()) and self:GetHolsterWep() or owner:GetWeapon("weapon_hands_sh")
	
	if IsValid(wep) then
		owner:SetActiveWeapon(wep)
		wep:Deploy()
		if wep.holster then
			wep.holster = nil
			wep:SetHolster(0)
		end
		self:SetHolsterWep(NULL)
	end

	if not IsValid(owner) or owner:GetActiveWeapon() ~= self then
		self.holster = nil
		self:SetHolster(0)
	end

	--self.endedholster = false
end

local gamemod = engine.ActiveGamemode()
local hg_slings = ConVarExists("hg_slings") and GetConVar("hg_slings") or CreateConVar("hg_slings", 0, FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE, "Toggle sling system", 0, 1)
hook.Add("PlayerSwitchInFake","slingDrop",function(ply,oldWeapon,newWeapon)
	if not hg_slings:GetBool() then return end
	if oldWeapon == newWeapon then return end
	if zb.CROUND and zb.CROUND == "hmcd" or gamemod == "sandbox" then
		local inv = ply:GetNetVar("Inventory")

		if SERVER and not oldWeapon.bigNoDrop and oldWeapon.weaponInvCategory == 1 and not inv["Weapons"]["hg_sling"] then
			timer.Simple(0,function()
				if oldWeapon:GetOwner() == ply then
					hg.drop(ply, oldWeapon, newWeapon)
				end
			end)
			
			if not IsValid(ply.FakeRagdoll) then return true end
		end
	end
end)

SWEP.Initialzed = false
function SWEP:Deploy()
	local time = CurTime()
	if SERVER and self.Initialzed and not self:GetOwner().noSound then
		timer.Simple(self.CooldownDeploy / self.Ergonomics * 0.4, function()
			if IsValid(self) and IsValid(self:GetOwner()) then
				self:GetOwner():EmitSound(self.DeploySnd[1], 65)
			end
		end)
	end
    self.Initialzed = true

	self.holster = nil
	self:SetHolster(0)
	
	self.deploy = time + self.CooldownDeploy / self.Ergonomics
	self:SetDeploy(self.deploy)

	--self.endedholster = false

	return true
end

function SWEP:Deploy_End()
	self.deploy = nil
	self:SetDeploy(0)
end