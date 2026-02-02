teams = {
	[0] = {
		color = Color(255, 0, 0),
		name = "Terrorists",
	},
	[1] = {
		color = Color(0, 0, 255),
		name = "Counter Terrorists",
	}
}

local team_GetPlayers = team.GetPlayers
function zb:BalancedChoice(first, second)
	local team0, team1 = team_GetPlayers(first), team_GetPlayers(second)
	return (#team0 > #team1 and second) or (#team1 > #team0 and first) or first
end

local player_GetAll = player.GetAll
function zb:AutoBalance()
	local mode = CurrentRound()

	if mode.OverrideBalance and mode:OverrideBalance() then return end

	for i, ply in ipairs(player_GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:SetTeam(TEAM_UNASSIGNED)
	end

	for i, ply in RandomPairs(player_GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:SetTeam(zb:BalancedChoice(0, 1))
	end
end