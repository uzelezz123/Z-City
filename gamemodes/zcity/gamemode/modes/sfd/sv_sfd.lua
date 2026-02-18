local MODE = MODE

MODE.name = "superfighters"
MODE.PrintName = "Superfighters 3D"
MODE.LootSpawn = true
MODE.GuiltDisabled = true
MODE.randomSpawns = true
MODE.noBoxes = true

MODE.GuiltDisabled = true
MODE.ForBigMaps = false
MODE.Chance = 0.01

local radius = nil
local mapsize = 7500
-- MODE.MapSize = mapsize

util.AddNetworkString("supfight_start")
util.AddNetworkString("supfight_end")

function MODE:CanLaunch()
    return false//(zb.GetWorldSize() >= ZBATTLE_BIGMAP)
end

function MODE:Intermission()
	game.CleanUpMap()

	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end
		
		ApplyAppearance(ply)
		ply:SetupTeam(0)
	end

	local rndpoints = zb.GetMapPoints("RandomSpawns")
	zonepoint = table.Random(rndpoints)

	net.Start("supfight_start")
		net.WriteVector(zonepoint.pos)
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {
	}
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		AlivePlyTbl[#AlivePlyTbl + 1] = ply
	end
	return AlivePlyTbl
end

function MODE:ShouldRoundEnd()
	return (#zb:CheckAlive(true) <= 1)
end

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		local hands = ply:Give("weapon_hands_sh")

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory",inv)

		ply:Give("weapon_walkie_talkie")

		ply:SelectWeapon("weapon_hands_sh")

		if ply.organism then
			ply.organism.recoilmul = 0.25
			ply.organism.superfighter = true
		end

		timer.Simple(0.1,function()
			ply.noSound = false
		end)

		ply:SetSuppressPickupNotices(false)
		zb.GiveRole(ply, "Superfighter", Color(190,15,15))
	end
end

function MODE:GiveWeapons()
end

function MODE:GiveEquipment()
end

MODE.LootTable = {
	{50, {
		{4,"weapon_leadpipe"},
		{3,"weapon_hg_crowbar"},
		{2,"weapon_tomahawk"},
		{2,"weapon_hatchet"},
		{1,"weapon_hg_axe"},
		{1,"weapon_hg_crossbow"},
	}},
	{50, {
		{9,"*ammo*"},
		{9,"weapon_hk_usp"},
		{8,"weapon_revolver357"},
		{8,"weapon_deagle"},
		{8,"weapon_doublebarrel_short"},
		{8,"weapon_doublebarrel"},
		{8,"weapon_remington870"},
		{8,"weapon_glock18c"},
		{7,"weapon_mp5"},
		{6,"weapon_xm1014"},

		{6,"ent_armor_vest3"},
		{5,"ent_armor_helmet1"},

		{5,"weapon_mp7"},
		{5,"weapon_sks"},

		{5,"ent_armor_vest4"},

		{5,"weapon_hg_molotov_tpik"},
		{5,"weapon_hg_pipebomb_tpik"},
		{5,"weapon_claymore"},
		{5,"weapon_hg_f1_tpik"},
		{5,"weapon_traitor_ied"},
		{5,"weapon_hg_slam"},
		{5,"weapon_hg_legacy_grenade_shg"},
		{5,"weapon_hg_grenade_tpik"},

		{5,"weapon_ptrd"},
		{5,"weapon_akm"},
		-- {5,"weapon_pkm"},
		-- {5,"weapon_hk21"},
		{5,"weapon_m98b"},
		{2,"weapon_hg_rpg"},
		{3,"weapon_sr25"},
	}},
}

function MODE:RoundThink()
	if (self.nextBoxesThink or 0) < CurTime() then
		self.nextBoxesThink = CurTime() + 2

		hook.Run("Boxes Think")
	end
end

function MODE:PlayerDeath(ply)
end

function MODE:CanSpawn()
end

function MODE:EndRound()
	timer.Simple(2,function()
		net.Start("supfight_end")
		local ent = zb:CheckAlive(true)[1]
		net.WriteEntity(IsValid(ent) and ent:Alive() and ent or NULL)
		net.Broadcast()
	end)
end