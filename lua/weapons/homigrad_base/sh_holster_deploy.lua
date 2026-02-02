AddCSLuaFile()
--
SWEP.CooldownHolster = 0.75
SWEP.HolsterSnd = {"homigrad/weapons/holster_rifle.mp3", 55, 100, 110}
SWEP.CooldownDeploy = 1
SWEP.DeploySnd = {"homigrad/weapons/draw_rifle.mp3", 65, 100, 110}

function SWEP:Step_HolsterDeploy(time)
	if SERVER and (self.holster or self.deploy) then
		--self:SetHolster(self.holster)
		--self:SetDeploy(self.deploy)
	end
	
	self.holster = nil--self:GetHolster() != 0 and self:GetHolster() or nil
	self.deploy = self:GetDeploy() != 0 and self:GetDeploy() or nil
	
	if self.deploy and self.deploy < time then if self.Deploy_End then self:Deploy_End() end end
	
	--if CLIENT then
		--if self.holster and self.holster < time then if self.Holster_End then self:Holster_End() end end
	--end
end

function SWEP:WeaponDeployPost()
end

if SERVER then return end

function SWEP:Holster(wep)
	if not IsFirstTimePredicted() then return end
	if self.deploy then
		self:SetDeploy(0)
		self.deploy = nil
	end
	self.reload = nil
	if self.WorldModelFake then self:PlayAnim("idle", 1, not self.NoIdleLoop) end
	do return true end
	local time = CurTime()
	if self.holster then return true end
	--if self.holster and self.holster - CurTime() < 0 then self:Holster_End() return true end
	
	self.deploy = nil
	self:SetDeploy(0)

	--wep = IsValid(wep) and wep or self:GetOwner():GetWeapon("weapon_hands_sh")
	
	self:SetHolsterWep(wep)

	self.holster = time + self.CooldownHolster / self.Ergonomics
	self:SetHolster(self.holster)

	return true
end

function SWEP:Holster_End()
	if IsValid(self:GetHolsterWep()) then
		input.SelectWeapon(self:GetHolsterWep())
	end

	if not IsValid(self:GetOwner()) or self:GetOwner():GetActiveWeapon() ~= self then
		self:SetHolsterWep(NULL)
		self.holster = nil
		self:SetHolster(0)
	end
end

function SWEP:Deploy()
	--if not IsFirstTimePredicted() then return end
	local time = CurTime()

	if self.MagIndex and IsValid(self:GetWM()) then
		self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin)
	end

	if self.WorldModelFake then self:PlayAnim("idle", 1, not self.NoIdleLoop) end

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