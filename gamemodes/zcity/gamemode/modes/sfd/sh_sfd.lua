
local MODE = MODE

hook.Add( "StartCommand", "DisallowShoting", function( ply, mv )
	if zb.CROUND == "superfighters" and (zb.ROUND_START or 0) + 5 > CurTime() then
		mv:RemoveKey(IN_ATTACK)
		mv:RemoveKey(IN_ATTACK2)
	end
end)

function MODE:PlayerCanLegAttack( ply )
	if zb.CROUND == "superfighters" and (zb.ROUND_START or 0) + 5 > CurTime() then
		return false
	end
end