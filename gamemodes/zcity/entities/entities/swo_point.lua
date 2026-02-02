ENT.Base = "base_brush"
ENT.Type = "brush"


-- Called when the entity first spawns
function ENT:Initialize()

	local w = self.max.x - self.min.x
	local l = self.max.y - self.min.y
	local h = self.max.z - self.min.z
	self.PointName = self.PointName or "Alpha"

	local min = Vector( 0 - ( w / 2 ), 0 - ( l / 2 ), 0 - ( h / 2 ) )
	local max = Vector( w / 2, l / 2, h / 2 )

	self:DrawShadow( false )
	self:SetCollisionBounds( min, max )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetMoveType( 0 )
	self:SetTrigger( true )

end

hg = hg or {}
hg.smo = hg.smo or {}
-- Called when an entity touches me :D
function ENT:StartTouch( ent )
	local ent = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
	if ( IsValid( ent ) && ent:IsPlayer() && ent:Alive() ) then
		hg.smo[self.PointName] = hg.smo[self.PointName] or {}
		hg.smo[self.PointName][#hg.smo[self.PointName] + 1 or 0] = ent
	end
end

function ENT:EndTouch( ent )
	local ent = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
	if ( IsValid( ent ) && ent:IsPlayer() && ent:Alive() ) then
		hg.smo[self.PointName] = hg.smo[self.PointName] or {}
		table.RemoveByValue( hg.smo[self.PointName], ent )
	end
end


-- Checks to see if we should go to the next map
