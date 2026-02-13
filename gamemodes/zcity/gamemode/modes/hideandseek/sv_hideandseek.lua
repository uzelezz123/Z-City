MODE.name = "hideandseek"
MODE.PrintName = "Hide & Seek"

--MODE.ForBigMaps = false
MODE.ROUND_TIME = 635

MODE.Chance = 0.10

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
	local numSEEKERS = 1

	if numPlayers <= 5 then
		numSEEKERS = 1
	elseif numPlayers >= 6 and numPlayers <= 9 then
		numSEEKERS = 2
	elseif numPlayers == 10 or numPlayers == 11 then
		numSEEKERS = 3
	elseif numPlayers >= 12 then -- возвращение великой elseif таблицы
		numSEEKERS = 4
	end

	shuffle(players)

	-- Set Seekers
	for i = 1, numSEEKERS do
		if IsValid(players[i]) then 
			players[i]:SetTeam(0) 
		end
	end

	-- Set Hiders`
	for i = numSEEKERS + 1, numPlayers do
		if IsValid(players[i]) then 
			players[i]:SetTeam(1)
		end
	end
end

util.AddNetworkString("hs_start")
function MODE:Intermission()
	game.CleanUpMap()
    math.randomseed(os.time()) -- Potential bug reported by Seekers where they couldn't become a hider. Hopefully this will fix :)
    self:AssignTeams()
	
	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or ply:Team() == 0 then ply:KillSilent() continue end
		ply:SetupTeam(ply:Team())
	end

	net.Start("hs_start")
	net.Broadcast()

end

function MODE:CheckAlivePlayers()
	local seekPlayers = {}
	local hidePlayers = {}

	for _, ply in ipairs(team.GetPlayers(0)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(seekPlayers, ply)
		end
	end

	for _, ply in ipairs(team.GetPlayers(1)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(hidePlayers, ply)
		end
	end

	return {seekPlayers, hidePlayers}
end





function MODE:ShouldRoundEnd()
	if zb.ROUND_START + 45 > CurTime() then return end

	local aliveTeams = self:CheckAlivePlayers()
	local endround, winner = zb:CheckWinner(aliveTeams)
	return endround
end


local swatSpawned = false

function MODE:RoundStart()
    swatSpawned = false 
end

local tblweps = {
	[0] = { 
		{"weapon_akm", {"holo15","grip3","laser4"} }, 
		{"weapon_ak74u", {"holo15","grip3","laser4"} },
		{"weapon_remington870", {} },
		{"weapon_m16a2", {"holo14"} },
		{"weapon_uzi", {"optic2","grip3","supressor7"} }
	},
	[1] = {
		--"weapon_hands_sh" -- hell nah
	}
}

local tblotheritems = {
	[0] = { 
		"weapon_medkit_sh", 
		"weapon_tourniquet",
		"weapon_walkie_talkie",
        "weapon_melee",
	},
	[1] = { 
		"weapon_bigconsumable", 
		"weapon_bandage_sh",
		"weapon_painkillers",

	}
}

local hideOtherItem = {
		"weapon_ducttape", --TODO: Make Hammer and Duct Tape random chance
		"weapon_hammer"
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
	local points = zb.GetMapPoints( "HIDESEEK_HIDER" )
	local points2 = zb.GetMapPoints( "HIDESEEK_SEEKER" )
	local plramount = zb:CheckPlaying()
    return (#points > 1) and (#points2 > 0) and (#plramount > 2)
end

function MODE:GiveEquipment()
	timer.Simple(0.5,function()
		local seekPlayers = {} 

		for i, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end

			-- Seekers
			if ply:Team() == 0 then
				timer.Create("SEEKSpawn" .. ply:EntIndex(), 40, 1, function()
					if !IsValid(ply) or ply:Team() == TEAM_SPECTATOR then return end
					ply:Spawn()
					ply:SetSuppressPickupNotices(true)
					ply.noSound = true

					ply:SetupTeam(ply:Team())

					ply:SetPlayerClass("seeker")

					local inv = ply:GetNetVar("Inventory")
					inv["Weapons"]["hg_sling"] = true
					ply:SetNetVar("Inventory",inv)

					hg.AddArmor(ply, tblarmors[ply:Team()][math.random(#tblarmors[ply:Team()])]) 

					zb.GiveRole(ply, "Seeker", Color(228, 49, 49))

					table.insert(seekPlayers, ply) 

					local wep = tblweps[ply:Team()][math.random(#tblweps[ply:Team()])]

					local gun = ply:Give(wep[1])

					if IsValid(gun) and gun.GetMaxClip1 then
						hg.AddAttachmentForce(ply,gun,wep[2])
						ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
					else
						print("WTH???")
					end

					local gun = ply:Give("weapon_browninghp")
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
			-- Hider
			else
				ply:SetSuppressPickupNotices(true)
				ply.noSound = true

				--ply:SetPlayerClass("hider")

				zb.GiveRole(ply, "Hider", Color(91,237,71))

				for _, item in ipairs(tblotheritems[ply:Team()]) do
					ply:Give(item)
				end

				local randItem = hideOtherItem[math.random(#hideOtherItem)]
				ply:Give(randItem)

				local hands = ply:Give("weapon_hands_sh")
				ply.noSound = false
			end

			timer.Simple(0.5,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function MODE:RoundThink()
    if not swatSpawned and (CurTime() - zb.ROUND_BEGIN) >= 342 then
        local deadPlayers = {}

        for _, ply in player.Iterator() do
            if not ply:Alive() and ply:Team() != TEAM_SPECTATOR then
                table.insert(deadPlayers, ply)
            end
        end

		local startpos = self.TPoints and #self.TPoints > 0 and self.TPoints[1].pos or zb:GetRandomSpawn()

		for i = 1, math.min(4, #deadPlayers) do
            local ply = deadPlayers[i]

            //if self.TPoints and #self.TPoints > 0 then
                ply:Spawn()
				ply:SetTeam(2)
				if !startpos then
					startpos = ply:GetPos()
				else
					hg.tpPlayer(startpos, ply, i, 0)
				end

                ply:SetPlayerClass("swat")
				zb.GiveRole(ply, "SWAT", Color(0,0,122))
				local gun = ply:Give("weapon_ar15")
                ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
                ply:Give("weapon_medkit_sh")
                ply:Give("weapon_tourniquet")
                ply:Give("weapon_walkie_talkie")
                ply:Give("weapon_hg_flashbang_tpik")
                hg.AddArmor(ply, "ent_armor_helmet1")
                hg.AddArmor(ply, "ent_armor_vest4")

                local hands = ply:Give("weapon_hands_sh")
                ply:SelectWeapon("weapon_hands_sh")
            //end
        end

        swatSpawned = true
    end
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HIDESEEK_SEEKER" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HIDESEEK_HIDER" ))
end

function MODE:CanSpawn()
end

util.AddNetworkString("hs_roundend")
function MODE:EndRound()
	for k,ply in player.Iterator() do
		if timer.Exists("SEEKSpawn"..ply:EntIndex()) then
			timer.Remove("SEEKSpawn"..ply:EntIndex())
		end
	end
	if timer.Exists("SEEKSpawn") then
		timer.Remove("SEEKSpawn")
	end

	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	timer.Simple(2,function()
		net.Start("hs_roundend")
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