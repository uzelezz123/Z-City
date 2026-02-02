include("shared.lua")
function ENT:Draw()
	self:DrawModel()
	if not IsValid(self.fire) then
		self.fire = CreateParticleSystem( self, "vFire_Flames_Small", PATTACH_POINT_FOLLOW, 1 )
	end
end