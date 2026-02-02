--

local CurTime = CurTime

function SWEP:Holster(wep)
	if self.deploy then
		self:SetDeploy(0)
		self.deploy = nil
	end
	self.reload = nil
	do return true end
	local time = CurTime()

	if IsValid(self:GetHolsterWep()) then return true end
	if IsValid(wep) then self:SetHolsterWep(wep) end
	
	--if self.holster and self.holster - time < 0 then self:Holster_End() return true end
	if self.holster then return false end
	
	if self.reload then
		self.reload = nil
		self.StaminaReloadTime = nil
	end
	
	self.deploy = nil
	self:SetDeploy(0)

	self.holster = time + self.CooldownHolster / self.Ergonomics
	self:SetHolster(self.holster)
	
	return false
end

local vecZero = Vector(0, 0, 0)
function SWEP:Holster_End()
	--print(self:GetHolsterWep())
	
	local wep = IsValid(self:GetHolsterWep()) and self:GetHolsterWep() or self:GetOwner():GetWeapon("weapon_hands_sh")
	
	if IsValid(wep) then
		--self:GetOwner():SelectWeapon(wep)
		self:GetOwner():SetActiveWeapon(wep)
		wep:Deploy()
		self:SetHolsterWep(NULL)
	end

	if not IsValid(self:GetOwner()) or self:GetOwner():GetActiveWeapon() ~= self then
		self.holster = nil
		self:SetHolster(0)
	end
end

hook.Add("PlayerSwitchInFake","slingDrop",function(ply,oldWeapon,newWeapon)
	do return end
	if oldWeapon == newWeapon then return end
	local inv = ply:GetNetVar("Inventory")
	
	if SERVER and not oldWeapon.bigNoDrop and oldWeapon.weaponInvCategory == 1 and not inv["Weapons"]["hg_sling"] then
		timer.Simple(0,function()
			if oldWeapon:GetOwner() == ply then
				//hg.drop(ply, oldWeapon, newWeapon)
			end
		end)
		
		if not IsValid(ply.FakeRagdoll) then return true end
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

	return true
end

function SWEP:Deploy_End()
	self.deploy = nil
	self:SetDeploy(0)
end