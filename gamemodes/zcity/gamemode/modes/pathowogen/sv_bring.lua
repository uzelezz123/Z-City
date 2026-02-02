// ripped straight from ULX :3

local function spiralGrid(rings)
	local grid = {}
	local col, row

	for ring=1, rings do -- For each ring...
		row = ring
		for col=1-ring, ring do -- Walk right across top row
			table.insert( grid, {col, row} )
		end

		col = ring
		for row=ring-1, -ring, -1 do -- Walk down right-most column
			table.insert( grid, {col, row} )
		end

		row = -ring
		for col=ring-1, -ring, -1 do -- Walk left across bottom row
			table.insert( grid, {col, row} )
		end

		col = -ring
		for row=1-ring, ring do -- Walk up left-most column
			table.insert( grid, {col, row} )
		end
	end

	return grid
end
local tpGrid = spiralGrid( 24 )

local MODE = MODE

local vec32 = Vector( 0, 0, 32 )
function MODE:BringPlayers(players, pos, angle)
	local cell_size = 50

	local teleportable_plys = table.Copy(players)

	for i = 1, #tpGrid do
		local c = tpGrid[i][1]
		local r = tpGrid[i][2]

		local target = table.remove( teleportable_plys )
		if not target then break end

		local yawForward = angle.yaw
		local offset = Vector( r * cell_size, c * cell_size, 0 )
		offset:Rotate( Angle( 0, yawForward, 0 ) )

		local t = {}
		t.start = pos + vec32 -- Move them up a bit so they can travel across the ground
		t.filter = players
		t.endpos = t.start + offset

		local tr = util.TraceEntity( t, target )
		if tr.Hit then
			table.insert( teleportable_plys, target )
		else
			if target:InVehicle() then target:ExitVehicle() end
			target:SetPos( t.endpos )
			target:SetEyeAngles( (pos - t.endpos):Angle() )
			target:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end
  	end

	for _, v in ipairs(teleportable_plys) do // a fallback
		v:SetPos(pos)
	end
end