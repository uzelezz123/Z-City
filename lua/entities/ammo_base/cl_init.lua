include("shared.lua")
function ENT:Draw()
	self:DrawModel()
end

--[[function ENT:Draw()

	self:DrawModel()
	--ragdoll:GetBoneMatrix(ragdoll:LookupBone("ValveBiped.Bip01_Spine")):GetTranslation()

	local ent = ents.FindByClass("prop_ragdoll")[1]

	local hull = 10
	local mins,maxs = -Vector(hull,hull,0),Vector(hull,hull,36)

	local startpos = ent:GetPos()
	local dir = ent:GetUp()
	local len = 128

	local offset = VectorRand(-32,32)
	local newpos = startpos + offset

	local t = {}
	t.start = startpos
	t.endpos = newpos
	t.filter = ent
	t.mask = MASK_PLAYERSOLID

	local tr = util.TraceLine( t )
	
	if not tr.Hit then
		local t = {}
		t.start = startpos + offset
		t.endpos = startpos + offset
		t.maxs = maxs
		t.mins = mins
		t.filter = ent--{Entity(1),Entity(1).FakeRagdoll,self}
		t.mask = MASK_PLAYERSOLID
		local tr = util.TraceHull( t )
		
		local clr = color_white
		if ( not tr.Hit ) then
			render.DrawWireframeBox( tr.HitPos, Angle( 0, 0, 0 ), mins, maxs, clr, true )
		end
	end
end--]]--visual fakegetup