if (SERVER) then AddCSLuaFile() end

ENT.Type = "point"
ENT.PrintName = "bomb_target"
ENT.Category = "cstrike"
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:Initialize()

    --self:DrawShadow( false )
	--self:SetSolid( SOLID_BBOX )
	--self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	--self:SetMoveType( 0 )
	--self:SetTrigger( true )

end