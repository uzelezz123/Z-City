local MODE = MODE

MODE.name = "scugarena"
MODE.PrintName = "Slug Arena"
MODE.LootSpawn = false
MODE.GuiltDisabled = true
MODE.randomSpawns = true

MODE.Chance = 0.01

util.AddNetworkString("scugarena_start")
util.AddNetworkString("scugarena_end")

function MODE:CanLaunch()
    return false
end

function MODE:Intermission()
	game.CleanUpMap()

	for k, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end
		
		ply:SetPlayerClass("Slugcat")
		ply:SetupTeam(0)
	end

	net.Start("scugarena_start")
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {}
	for _, ply in ipairs(player.GetAll()) do
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		AlivePlyTbl[#AlivePlyTbl + 1] = ply
	end
	return AlivePlyTbl
end

function MODE:ShouldRoundEnd()
	return (#self:CheckAlivePlayers() <= 1)
end

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		local hands = ply:Give("weapon_hands_sh")

		local scug = ply:GetNWString("scug")

		if scug == "normal" then
			ply:Give("weapon_hg_spear")
			ply:SelectWeapon("weapon_hg_spear")
		end

		if scug == "saint" then
			ply:Give("weapon_hg_legacy_grenade_impact")
			ply:SelectWeapon("weapon_hg_legacy_grenade_impact")
		end

		timer.Simple(0.1,function()
			ply.noSound = false
		end)

		ply:SetSuppressPickupNotices(false)
	end
end

function MODE:EndRound()
	timer.Simple(2, function()
		net.Start("scugarena_end")
		local ent = self:CheckAlivePlayers()[1]
		if IsValid(ent) then
			ent:GiveExp(math.random(150,200))
			ent:GiveSkill(math.Rand(0.2,0.3))
		end
		net.WriteEntity(IsValid(ent) and ent:Alive() and ent or NULL)
		net.Broadcast()
	end)
end

function MODE:GiveWeapons()
end

function MODE:GiveEquipment()
end




