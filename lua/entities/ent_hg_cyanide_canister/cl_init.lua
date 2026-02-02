include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

local tbl = {}
local oldtbl = {}
local sendtime = CurTime() + 1
net.Receive("cyanide_debug",function()
	table.CopyFromTo(tbl,oldtbl)
	tbl = net.ReadTable()
	sendtime = CurTime() + 1
end)
hook.Add("HUDPaint","cyanide_debug",function()
	if not tbl then return end
	
	for i,tbl2 in ipairs(tbl) do
		if not tbl2 then continue end
		if not oldtbl[i] then continue end

		local pos = tbl2[1]
		local oldpos = oldtbl[i][1]
		local lerp = 1 - (sendtime - CurTime())
		local poss = LerpVector(lerp,oldpos,pos):ToScreen()
		
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect(poss.x,poss.y,10,10)
	end
end)