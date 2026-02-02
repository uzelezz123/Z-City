AddCSLuaFile()
if CLIENT then
	net.Receive("hgwep shoot", function()
		local self = net.ReadEntity()
		local shoot = net.ReadBool()
		local broadcastAnyways = net.ReadBool()
		
		if not IsValid(self) then return end
		if !broadcastAnyways and self:GetOwner() == LocalPlayer() then return end
		
		if self.Shoot then
			self:Shoot(shoot)
		end
	end)
end

function SWEP:IsClient()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:KeyDown(key)
	return hg.KeyDown(self:GetOwner(),key)
end