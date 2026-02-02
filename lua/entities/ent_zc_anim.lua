AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Animated Model"
ENT.Category = "ZCity Other"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true -- Must be set on client

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", false, "WhiteListToSee" )

	if SERVER then
		self:SetWhiteListToSee(false)
	end

end

function ENT:Think()
	--if self:GetWhiteListToSee() and !self.Ent:SetNetVar("CanSeeUserID",{})[lply:UserID()] and lply:Alive() then self:SetNoDraw(true) return end
	self:NextThink( CurTime() )

	return true
end



function ENT:Draw( flags )
	if self:GetWhiteListToSee() and !self:GetNetVar("CanSeeUserID",{})[lply:UserID()] and lply:Alive() then return end
	self:SetRenderBounds( self:GetModelBounds() )

	self:DrawModel( flags )

end