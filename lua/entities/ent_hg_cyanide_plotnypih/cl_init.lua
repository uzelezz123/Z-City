include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

local tbl = {}
local oldtbl = {}
local sendtime = CurTime() + 1
net.Receive("chlorine_gas",function()
	table.CopyFromTo(tbl,oldtbl)
	tbl = net.ReadTable()
	sendtime = CurTime() + 1
end)
local mat = Material("particle/smokesprites_0010")
local colSmoke = Color(255,251,0,52)
hook.Add("PreDrawEffects","chlorine_gas",function()
	if not tbl then return end
	
	for i,tbl2 in ipairs(tbl) do
		if not tbl2 then continue end
		if not oldtbl[i] then continue end

		local pos = tbl2[1]
		local oldpos = oldtbl[i][1]
		local lerp = 1 - (sendtime - CurTime())
		local poss = LerpVector(lerp,oldpos,pos)
		local sizemul = ( 60-(tbl2[3]-CurTime()) )

		render.SetMaterial(mat)
		render.DrawSprite(poss,158 * sizemul/20,128 * sizemul/20,colSmoke)
	end
end)