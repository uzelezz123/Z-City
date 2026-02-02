local MODE = MODE

hook.Add("StartCommand", "DisallowShosting", function(ply, mv)
	if zb.CROUND == "scugarena" and (zb.ROUND_START or 0) + 20 > CurTime() then
		mv:RemoveKey(IN_ATTACK)
		mv:RemoveKey(IN_ATTACK2)
	end
end)
