MODE.name = "criresp"
MODE.PrintName = "Crisis Response"

MODE.ForBigMaps = false
MODE.ROUND_TIME = 480

MODE.Chance = 0.05

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

function shuffle(tbl)
	local len = #tbl
	for i = len, 2, -1 do
	  local j = math.random(i)
	  tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

function MODE:AssignTeams()
	local players = player.GetAll()
	local numPlayers = #players
	local numSWAT = 1

	if numPlayers <= 4 then
		numSWAT = 1
	elseif numPlayers == 5 then
		numSWAT = 2
	elseif numPlayers == 6 then
		numSWAT = 2
	elseif numPlayers == 7 then
		numSWAT = 3
	elseif numPlayers >= 8 then -- возвращение великой elseif таблицы
		numSWAT = 4
	end

	shuffle(players)

	for i = 1, numSWAT do
		if IsValid(players[i]) then 
			players[i]:SetTeam(0)
		end
	end

	for i = numSWAT + 1, numPlayers do
		if IsValid(players[i]) then 
			players[i]:SetTeam(1)
		end
	end
end

util.AddNetworkString("criresp_start")
function MODE:Intermission()
	game.CleanUpMap()
    
    self:AssignTeams()
	
	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or ply:Team() == 0 then ply:KillSilent() continue end
		ply:SetupTeam(ply:Team())
	end

	net.Start("criresp_start")
	net.Broadcast()

end

function MODE:CheckAlivePlayers()
	local swatPlayers = {}
	local banditPlayers = {}

	for _, ply in ipairs(team.GetPlayers(0)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(swatPlayers, ply)
		end
	end

	for _, ply in ipairs(team.GetPlayers(1)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(banditPlayers, ply)
		end
	end

	return {swatPlayers, banditPlayers}
end





function MODE:ShouldRoundEnd()
	if zb.ROUND_START + 91 > CurTime() then return end
	local aliveTeams = self:CheckAlivePlayers()
	local endround, winner = zb:CheckWinner(aliveTeams)
	return endround
end



function MODE:RoundStart()
    
end

local tblweps = {
	[0] = { 
		{"weapon_m4a1", {"holo15","grip3","laser4"} }, 
		{"weapon_hk416", {"holo15","grip3","laser4"} },
		{"weapon_p90", {} },
		{"weapon_mp7", {"holo14"} },
		{"weapon_m4a1", {"optic2","grip3","supressor7"} }
	},
	[1] = { 
		"weapon_deagle",
		"weapon_glock17",
		"weapon_revolver2",
		"weapon_p22",
		"weapon_revolver2",
		"weapon_hk_usp",
		"weapon_remington870",
		"weapon_mac11",
		"weapon_skorpion",
	}
}

local tblotheritems = {
	[0] = { 
		"weapon_medkit_sh", 
		"weapon_tourniquet",
		"weapon_walkie_talkie",
        "weapon_melee",
		"weapon_handcuffs",
		"weapon_hg_flashbang_tpik"
	},
	[1] = { 
		"weapon_bigconsumable", 
		"weapon_bandage_sh",
		"weapon_painkillers",
        "weapon_sogknife",
		"weapon_ducttape",
		"weapon_hammer"

	}
}


local tblarmors = {
	[0] = { 
		{"ent_armor_vest8","ent_armor_helmet6"} 
	},
	[1] = { 
		{"ent_armor_vest8","ent_armor_helmet6"} 
	}
}

function MODE:CanLaunch()
	local points = zb.GetMapPoints( "HMCD_CRI_CT" )
	local points2 = zb.GetMapPoints( "HMCD_CRI_T" )
	local plramount = zb:CheckPlaying()
    return (#points > 3) and (#points2 > 0) and (#plramount > 5)
end

function MODE:GiveEquipment()
	timer.Simple(0.5,function()
		local swatPlayers = {} 

		for i, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end

			if ply:Team() == 0 then
				timer.Create("SWATSpawn"..ply:EntIndex(), 90, 1, function()
					if !IsValid(ply) or ply:Team() == TEAM_SPECTATOR then return end
					ply:Spawn()
					ply:SetSuppressPickupNotices(true)
					ply.noSound = true

					ply:SetupTeam(ply:Team())

					ply:SetPlayerClass("swat")

					local inv = ply:GetNetVar("Inventory")
					inv["Weapons"]["hg_sling"] = true
					ply:SetNetVar("Inventory",inv)

					hg.AddArmor(ply, tblarmors[ply:Team()][math.random(#tblarmors[ply:Team()])]) 

					zb.GiveRole(ply, "SWAT", Color(0,0,190))

					table.insert(swatPlayers, ply) 

					local wep = tblweps[ply:Team()][math.random(#tblweps[ply:Team()])]
					local gun = ply:Give(wep[1])
					if IsValid(gun) and gun.GetMaxClip1 then
						hg.AddAttachmentForce(ply,gun,wep[2])
						ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
					else
						print("WTH???")
					end

					local gun = ply:Give("weapon_glock17")
					if IsValid(gun) and gun.GetMaxClip1 then
						ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
					end

					for _, item in ipairs(tblotheritems[ply:Team()]) do
						ply:Give(item)
					end

					local hands = ply:Give("weapon_hands_sh")

					ply:SetSuppressPickupNotices(false)
					ply.noSound = false
				end)
			else
				ply:SetSuppressPickupNotices(true)
				ply.noSound = true

				ply:SetPlayerClass("terrorist")

				zb.GiveRole(ply, "Suspect", Color(190,0,0))

				local gun = ply:Give(tblweps[ply:Team()][math.random(#tblweps[ply:Team()])])
				if IsValid(gun) and gun.GetMaxClip1 then
					ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
				else
					print("WTH???")
				end

				for _, item in ipairs(tblotheritems[ply:Team()]) do
					ply:Give(item)
				end

				local hands = ply:Give("weapon_hands_sh")

				ply:SetSuppressPickupNotices(false)
				ply.noSound = false
			end

			timer.Simple(0.5,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end

		timer.Create("SWATSpawn",91,1,function()
			if #swatPlayers > 0 then
				local ramPlayer = swatPlayers[math.random(#swatPlayers)]
				if !IsValid(ramPlayer) or ramPlayer:Team() == TEAM_SPECTATOR then return end
				ramPlayer:Give("weapon_ram")
			end
		end)
	end)
end

function MODE:RoundThink()
end

function MODE:GetTeamSpawn()
	return {zb:GetRandomSpawn()}, {zb:GetRandomSpawn()}
end

function MODE:CanSpawn()
end

util.AddNetworkString("cri_roundend")
function MODE:EndRound()
	for k,ply in player.Iterator() do
		if timer.Exists("SWATSpawn"..ply:EntIndex()) then
			timer.Remove("SWATSpawn"..ply:EntIndex())
		end
	end
	if timer.Exists("SWATSpawn") then
		timer.Remove("SWATSpawn")
	end

	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	timer.Simple(2,function()
		net.Start("cri_roundend")
			net.WriteBool(winner)
		net.Broadcast()
	end)

	for k,ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))
		else
			ply:GiveSkill(-math.Rand(0.05,0.1))
		end
	end
end

function MODE:PlayerDeath(ply)
end