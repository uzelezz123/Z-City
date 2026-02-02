include("shared.lua")
function ENT:Draw()
	self:DrawModel()
	--local pos,_ = LocalToWorld(Vector(55,0,0),angle_zero,self:GetPos(),self:GetAngles())
	--debugoverlay.Line(pos,pos + self:GetVelocity():GetNormalized()*16,5,color_white,true)
end