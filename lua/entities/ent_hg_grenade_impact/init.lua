AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:PhysicsCollide(phys, deltaTime)
	if phys.Speed > 20 and not self.Exploded then self:Explode() end
end