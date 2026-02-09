MODE.name = "riot"
MODE.PrintName = "Riot"

MODE.OverideSpawnPos = true
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.Chance = 0.03

local riotWeapons = {
    "weapon_leadpipe",
    "weapon_brick",
    "weapon_hammer",
    "weapon_pocketknife",
    "weapon_pan",
    "weapon_hg_shovel",
    "weapon_bat"
}

local riotConsumables = {
    "weapon_bigconsumable",
    "weapon_smallconsumable",
    "weapon_ducttape",
    "weapon_matches",
    "weapon_bandage_sh",
    "weapon_hg_smokenade_tpik",
    "weapon_hg_shuriken"
}

local riotArmorChance = 40

local lawWeapons = {
    "weapon_hg_tonfa",
    "weapon_taser",
    "weapon_walkie_talkie",
    "weapon_handcuffs",
    "weapon_handcuffs_key"
}

local lawArmor = {
    "ent_armor_vest2",
    "ent_armor_helmet3"
}

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
    return 1, true
end

util.AddNetworkString("riot_start")
util.AddNetworkString("riot_roundend")

function MODE:Intermission()
    game.CleanUpMap()


    self.RiotPoints = {}
    table.CopyFromTo(zb.GetMapPoints("RIOT_TDM_LAW"), self.RiotPoints)

    self.LawPoints = {}
    table.CopyFromTo(zb.GetMapPoints("RIOT_TDM_RIOTERS"), self.LawPoints)

	local ctpos
	local tpos
	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local pos
		if ply:Team() == 1 then
			if !ctpos then
				ctpos = #self.LawPoints > 0 and self.LawPoints[1].pos or zb:GetRandomSpawn()
				pos = ctpos
			else
				pos = hg.tpPlayer(ctpos, ply, i, 0)
			end
		end

		if ply:Team() == 0 then
			if !tpos then
				tpos = #self.RiotPoints > 0 and self.RiotPoints[1].pos or zb:GetRandomSpawn()
				pos = tpos
			else
				pos = hg.tpPlayer(tpos, ply, i, 0)
			end
		end

		ply:SetupTeam(ply:Team())

		if pos then
			ply:SetPos(pos)
		end
	end

    net.Start("riot_start")
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


function MODE:EndRound()
    timer.Simple(2,function()
        net.Start("riot_roundend")
        net.Broadcast()
    end)
end


function MODE:ShouldRoundEnd()
    local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
    return endround
end

function MODE:RoundStart()
end


function MODE:GiveEquipment()
    local players = player.GetAll()
    table.Shuffle(players)

    local numPlayers = #players
    local numLawEnforcers = math.max(math.floor(numPlayers / 2) - 1, 1)
    local numRioters = numPlayers - numLawEnforcers

    local pipebomberCount = 0  
    local hasMp80 = false

    for i = 1, numRioters do
        local ply = players[i]
        if ply:Team() == TEAM_SPECTATOR then continue end
    
        ply:SetupTeam(0)

        ply:SetPlayerClass("terrorist")
    
    
        zb.GiveRole(ply, "Rioter", Color(190, 0, 0))
    
        ply:Give("weapon_hands_sh")

        if pipebomberCount < 1 then
            ply:Give("weapon_hg_molotov_tpik")
            pipebomberCount = pipebomberCount + 1
        elseif not hasMp80 then
            ply:Give("weapon_mp-80")
            hasMp80 = true
        end

		ply:SetNetVar("CurPluv", "pluvmajima")

        ply:Give(riotConsumables[math.random(#riotConsumables)])
    
        if math.random(100) <= riotArmorChance then
            hg.AddArmor(ply, "ent_armor_helmet2")
        end
    
        local riotWeapon = riotWeapons[math.random(#riotWeapons)]
        local wep = ply:Give(riotWeapon)

        if IsValid(wep) then
            ply:SelectWeapon(wep:GetClass())
        end
    end
    

    for i = numRioters + 1, numPlayers do
        local ply = players[i]
        if ply:Team() == TEAM_SPECTATOR then continue end

        ply:SetupTeam(1)
        ply:SetPlayerClass("police")

        zb.GiveRole(ply, "Law Enforcement", Color(0, 0, 190))

        local inv = ply:GetNetVar("Inventory")
        inv["Weapons"]["hg_sling"] = true
        ply:SetNetVar("Inventory", inv)


        local hands = ply:Give("weapon_hands_sh")
        ply:SelectWeapon(hands)


        for _, wepName in ipairs(lawWeapons) do
            ply:Give(wepName)
        end

        ply:SetNetVar("CurPluv", "pluvberet")

        hg.AddArmor(ply, "ent_armor_helmet3")
        hg.AddArmor(ply, "ent_armor_vest2")


        if i == numRioters + 1 then
            ply:Give("weapon_ram")
        elseif i == numRioters + 2 then
            local wep = ply:Give("weapon_remington870")

            timer.Simple(1, function()
                if IsValid(wep) then
                    wep:SetRandomBodygroups("000010302")
                    wep:ApplyAmmoChanges(2)
                end
            end)
        end

        ply:SelectWeapon("weapon_hg_tonfa")
    end
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_T" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_CT" ))
end

function MODE:RoundThink()
end


function MODE:CanLaunch()
    local activePlayers = 0

    for _, ply in player.Iterator() do
        if ply:Team() ~= TEAM_SPECTATOR then
            activePlayers = activePlayers + 1
        end
    end


    if activePlayers < 5 then
        return false
    end

    local pointsRioters = zb.GetMapPoints("RIOT_TDM_RIOTERS")
    local pointsLaw = zb.GetMapPoints("RIOT_TDM_LAW")
    return (#pointsRioters > 0) and (#pointsLaw > 0)
end

return MODE
