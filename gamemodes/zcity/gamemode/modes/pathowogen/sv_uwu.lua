MODE.name = "pathowogen"
MODE.PrintName = "Pathowogen :3"
MODE.start_time = 0
MODE.end_time = 10

MODE.ROUND_TIME = 300

MODE.OverrideSpawn = false
MODE.LootSpawn = false
MODE.ForBigMaps = true
MODE.Chance = 0.05

MODE.randomSpawns = true

MODE.LootOnTime = true

MODE.humans = {}
MODE.furries = {}

local MODE = MODE

util.AddNetworkString("zb_furbriefing")
util.AddNetworkString("zb_furfurbriefing")
util.AddNetworkString("zb_furtraitorbriefing")
util.AddNetworkString("zb_contractortransmit")
util.AddNetworkString("zb_commandertransmit")
util.AddNetworkString("zb_extractionheli")
util.AddNetworkString("zb_extractionpoint")
util.AddNetworkString("zb_traitorextractionpoint")
util.AddNetworkString("ZB_Pathowogen_RoundEnd")

function MODE:CreateTimer(name, delay, repetitions, func)
	self.saved.Timers = self.saved.Timers or {}

	if timer.Exists(name) then
		print("Pathowogen: Attempted to create an already existing timer: " .. name)
		return
	end

	timer.Create(name, delay, repetitions, func)

	self.saved.Timers[name] = true
end

function MODE:CanLaunch()
	return false
end

function MODE:GiveEquipment()
end

function MODE:PlayerInitialSpawn(ply)
	ply:SetTeam(1001)
end

function MODE:CanSpawn(ply)
	if ply:Team() == 0 then return true end

	return false
end

function MODE:FigureOutConsequences()
	local data = {}

	for _, v in ipairs(self.saved.Players or {}) do
		local ply = v.ply

		if !IsValid(ply) then continue end

		local name = v.name
		local role = v.role

		data[ply] = {
			name = name,
			role = role
		}

		data[ply].now = {}
		data[ply].now.name = self.saved.DeathNames[ply] or (ply:GetNWString("PlayerName") or ply:Name()) or "Unknown"
		data[ply].now.alive = self.saved.Escaped[ply] or (ply.PlayerClassName != "commanderforces" and ply:Alive())
		data[ply].now.escaped = self.saved.Escaped[ply]
		data[ply].now.role = role
		if self.saved.Assimilated[ply] or role == "furry" then
			data[ply].now.role = "furry"
		end

		//it's a hack but whatever :3
		if data[ply].now.role == "furry" and data[ply].now.escaped then
			data[ply].now.escaped = false
			data[ply].now.alive = false
		end
	end

	local WinCondition = 0
	if table.Count(self.saved.Escaped) == 0 and #self.humans == 0 then
		WinCondition = 1 // furries win
	elseif #self.furries == 0 or table.Count(self.saved.Escaped) > 0 then
		WinCondition = 2 // humans win
	end

	for k, _ in pairs(self.saved.Escaped) do
		if self.saved.traitors[k] then
			WinCondition = 3 // traitor wins
		end
	end

	net.Start("ZB_Pathowogen_RoundEnd")
		net.WriteUInt(WinCondition, 3)
		net.WriteTable(data)
	net.Broadcast()
end

function MODE:EndRound()
	PrintMessage(HUD_PRINTTALK, "Round ended.")

	for k, _ in pairs(self.saved.Timers or {}) do
		timer.Remove(k)
	end

	self:FigureOutConsequences()
end

function MODE:Intermission()
	game.CleanUpMap()

	-- for k, ply in ipairs(player.GetAll()) do
	-- 	//ply:KillSilent()

	-- 	-- ply:SetupTeam(0)
	-- end
end

MODE.Vehicles = {
	"blackterios_glide_ika_renault_torino_coupe",
	"blackterios_glide_fiat_duna",
	"blackterios_glide_renault_trafic"
}

function MODE:SpawnInterests()
	for k, v in ipairs(zb.Points["SCRAPPERS_BIGBOX"].Points or {}) do
		local random = math.random(1, 5)

		if random == 1 then
			local box = ents.Create("prop_physics")
			box:SetPos(v.pos + Vector(0, 0, 25))
			box:SetModel("models/props_junk/wood_crate002a.mdl")
			box:SetAngles(v.ang)
			box:Spawn()
		elseif random <= 3 then
			local box = ents.Create("prop_physics")
			box:SetPos(v.pos + Vector(0, 0, 25))
			box:SetModel("models/props_junk/wood_crate001a.mdl")
			box:SetAngles(v.ang)
			box:Spawn()
		end
	end

	for k, v in ipairs(zb.Points["SCRAPPERS_SMALLBOX"].Points or {}) do
		local random = math.random(1, 3)

		if random == 1 then
			local box = ents.Create("prop_physics")
			box:SetPos(v.pos + Vector(0, 0, 25))
			box:SetModel("models/props_junk/wood_crate001a.mdl")
			box:SetAngles(v.ang)
			box:Spawn()
		end
	end

	for k, v in ipairs(zb.Points["SCRAPPERS_VEHICLE"].Points or {}) do
		local random = math.random(1, 4)

		if random == 1 then
			local vehicle_class = self.Vehicles[math.random(#self.Vehicles)]

			local veh = ents.Create(vehicle_class)
			veh:SetPos(v.pos + Vector(0, 0, 100))
			veh:SetAngles(v.ang or Angle(0, 0, 0))
			veh:Spawn()
			veh:Activate()
		end
	end
end


function MODE:GetRandomSpawn(ply)
	local spawnpoints

	if zb.Points["Spawnpoint"] and zb.Points["Spawnpoint"].Points and #zb.Points["Spawnpoint"].Points > 0 then
		spawnpoints = zb.Points["Spawnpoint"].Points
	elseif zb.Points["RandomSpawns"] and zb.Points["RandomSpawns"].Points and #zb.Points["RandomSpawns"].Points > 0 then
		spawnpoints = zb.Points["RandomSpawns"].Points
	else
		ply:Spawn()
		return
	end

	local spawn, k = table.Random(spawnpoints)

	if self.spawns[k] then
		self:GetRandomSpawn(ply)
		return
	end

	ply:SetPos(spawn.pos)
	self.spawns[k] = true
end

function MODE:SetupFur(ply) // unused
	ply:SetPlayerClass("furry", {instant = true})

	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")

	local furspawns = {}

	if zb.Points["RandomSpawns"] and zb.Points["RandomSpawns"].Points then
		for _, v2 in ipairs(zb.Points["RandomSpawns"].Points) do // i don't care anymore
			table.insert(furspawns, v2.pos)
		end
	end

	ply:SetPos(zb:FurthestFromEveryone())

	net.Start("zb_furfurbriefing")
	net.Send(ply)
end

function MODE:SetupTraitor(ply)
	ply:Spawn()
	ApplyAppearance(ply,false,false,false,true)

	ply:Give("weapon_adrenaline")

	-- local gun = ply:Give("weapon_hk_usp")
	-- ply:GiveAmmo(gun:GetMaxClip1() * 1,gun:GetPrimaryAmmoType(),true)
	-- hg.AddAttachmentForce(ply,gun,"supressor3")

	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")

	zb.GiveRole(ply, "Operative", Color(121, 5, 69))
	ply:SetPlayerClass()

	net.Start("zb_furtraitorbriefing")
	net.Send(ply)

	self.saved.PlayerCount = self.saved.PlayerCount + 1
end

function MODE:SetupSurvivor(ply)
	ply:Spawn()
	ApplyAppearance(ply,false,false,false,true)

	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")

	zb.GiveRole(ply, "Survivor", Color(230, 74, 74))
	ply:SetPlayerClass()

	net.Start("zb_furbriefing")
	net.Send(ply)

	self.saved.PlayerCount = self.saved.PlayerCount + 1
end

function MODE:RoundStart()
	self.furries = {}
	self.humans = {}

	self.saved.furs = {}
	self.saved.traitors = {}

	self.saved.UWUCopter = nil
	self.saved.ExtractPoint = nil
	self.saved.TraitorExtractPoint = nil

	self.saved.Assimilated = {}
	self.saved.Died = {}
	self.saved.Escaped = {}

	self.saved.DeathNames = {}
	
	self.saved.ContractorEscapee = nil

	// shitcode, change it later (or not i guess)
	self.RoundState = 0

	self.saved.CloseQuarters = false

	local heliPoints = zb.Points["UWU_GlideHeli"].Points or {}
	if #heliPoints <= 0 then
		self.saved.CloseQuarters = true // different game rules without a helicopter
	end

	local points = zb.Points["UWU_DeltaSquad"].Points or {}
	if #points > 0 then
		for k, v in RandomPairs(points) do
			if !self.saved.extractPoint then
				self.saved.extractPoint = v
			elseif !self.saved.traitorExtractPoint then
				self.saved.traitorExtractPoint = v
			else
				break
			end
		end
	end

	self.saved.PlayerCount = 0
	self.saved.Players = {}

	local players = player.GetAll()

	self.saved.furamount = math.max(math.Round(#players / 4), 1)
	for i, ply in RandomPairs(players) do
		if self.saved.furs[ply] or ply:Team() == TEAM_SPECTATOR then continue end

		self.saved.furs[ply] = true

		if table.Count(self.saved.furs) >= self.saved.furamount then
			break
		end
	end

	self.traitoramount = ((#players >= 10) and 1) or 0
	for i, ply in RandomPairs(players) do
		if ply:Team() == TEAM_SPECTATOR then continue end

		if table.Count(self.saved.traitors) >= self.traitoramount then
			break
		end

		if self.saved.traitors[ply] or self.saved.furs[ply] or ply:Team() == TEAM_SPECTATOR then continue end

		self.saved.traitors[ply] = true
	end

	-- self.saved.traitors[Entity(1)] = true
	-- self.saved.furs[Entity(1)] = true

	self.saved.traitorsLookUp = {}
	for ply, _ in pairs(self.saved.traitors) do
		table.insert(self.saved.traitorsLookUp, ply)
	end

	self.spawns = {}

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if self.saved.furs[ply] then continue end

		local role = "survivor"

		if self.saved.traitors[ply] then
			role = "traitor"
		end

		if role == "survivor" then
			self:SetupSurvivor(ply)
		elseif role == "traitor" then
			self:SetupTraitor(ply)
		end

		self:GetRandomSpawn(ply)

		table.insert(self.saved.Players, {
			ply = ply,
			name = ply:GetNWString("PlayerName") or ply:Name() or "Unknown",
			role = role
		})
	end

	local furspawns = {}

	if zb.Points["RandomSpawns"] and zb.Points["RandomSpawns"].Points then
		for _, v2 in ipairs(zb.Points["RandomSpawns"].Points) do // i don't care anymore
			table.insert(furspawns, v2.pos)
		end
	end

	for ply, _ in pairs(self.saved.furs) do  // set them up later from everyone else so that they spawn the furthest from everyone
		ply:SetPlayerClass("furry", {instant = true})

		ply:Give("weapon_hands_sh")
		ply:SelectWeapon("weapon_hands_sh")

		self:GetRandomSpawn(ply)

		net.Start("zb_furfurbriefing")
		net.Send(ply)

		table.insert(self.saved.Players, {
			ply = ply,
			name = ply:GetNWString("PlayerName") or ply:Name() or "Unknown",
			role = "furry"
		})
	end

	local fuelsystem = GetConVar("sv_simfphys_fuel")
	if fuelsystem then
		fuelsystem:SetBool(true)
	end

	local fuelmul = GetConVar("sv_simfphys_fuelscale")
	if fuelmul then
		fuelmul:SetFloat(0.01)
	end

	self:SpawnInterests()
end

function MODE:CanPlayerSuicide(ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply:ChatPrint("nuh uh!!!")
		return false
	end
end

function MODE:BroadcastCommander(text)
	local players = table.Copy(self.humans)
	for ply, _ in pairs(self.saved.traitors or {}) do // it's bad... i guess? >w<
		table.RemoveByValue(players, ply)
	end

	net.Start("zb_commandertransmit")
		net.WriteString(text)
	net.Send(players)
end

function MODE:BroadcastContractor(text)
	if self.saved.ContractorEscapee then return end

	for _, v in ipairs(self.saved.traitorsLookUp) do
		if !IsValid(v) then continue end
		if !v:Alive() then continue end
		if v.PlayerClassName == "furry" then continue end

		net.Start("zb_contractortransmit")
			net.WriteString(text)
		net.Send(self.saved.traitorsLookUp or {})
	end
end

local DeltaGuns = {
	[0] = "weapon_m16a2",
	[1] = "weapon_m16a2",
	[2] = "weapon_m16a2",
	[3] = "weapon_spas12",
	[4] = "weapon_m60"
}

function MODE:SpawnDeltaSquad(count)
	local spawned = 0
	local SpawnedPlayers = {}

	for i, ply in RandomPairs(player.GetAll()) do
		if ply:Alive() or ply:Team() == TEAM_SPECTATOR or ply.afkTime2 > 60 then continue end
		if spawned >= count then break end

		ply:Spawn()

		ply:SetPlayerClass("commanderforces")
		local gun = ply:Give("weapon_m9beretta")
		ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_naloxone")
		ply:Give("weapon_painkillers")
		ply:Give("weapon_melee")

		local gunString = DeltaGuns[i % 5]

		gun = ply:Give(gunString)

		local clipAmount = 3

		if gunString == "weapon_m60" then
			clipAmount = 1
		end

		ply:GiveAmmo(gun:GetMaxClip1() * clipAmount,gun:GetPrimaryAmmoType(),true)

		-- if self.saved.CloseQuarters then
		-- 	hg.AddAttachmentForce(ply,gun,"optic7")
		-- else
		-- 	hg.AddAttachmentForce(ply,gun,"holo15")
		-- end

		hg.AddArmor(ply, {"helmet6", "vest8", "headphones1", "mask2"})

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon(gun)

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
		ply.organism.recoilmul = 0.8

		ply:SetNetVar("CurPluv", "pluvberet")

		zb.GiveRole(ply, "Delta Squad", Color(79, 10, 10))

		spawned = spawned + 1
		table.insert(SpawnedPlayers, ply)
	end

	net.Start("zb_commandertransmit")
		net.WriteString("Don't forget: you're here to extract the survivors still remaining in this area. Don't even try to return to base without at least one of them.")
	net.Send(SpawnedPlayers)

	return SpawnedPlayers
end

function MODE:SpawnSquadHelicopter()
	if IsValid(self.saved.UWUCopter) then return end
	local heliPoints = zb.Points["UWU_GlideHeli"].Points or {}

	if #heliPoints > 0 then
		self:CreateTimer("UWUCopter", math.random(240, 300), 1, function()
			local squad = self:SpawnDeltaSquad(5)

			print("delta squad:")
			PrintTable(squad)

			if #squad == 0 then
				self:BroadcastCommander("Sorry, the extraction isn't coming. You're doomed. Better kill yourself.")
			else
				self:BroadcastCommander("The extraction helicopter is now in your area. Find it and try to signal to it somehow.")

				local heli = self:SpawnGlideHelicopter()
				self.saved.UWUCopter = heli

				for _, v in ipairs(squad) do
					local seat = heli:GetFreeSeat()

					if seat then
						v:EnterVehicle(seat)
					end
				end
			end
		end)
	end
end

function MODE:InitiateCQExtraction()
	local spawnPoint = self.saved.extractPoint

	if spawnPoint then
		self:CreateTimer("CQExtract", math.random(120, 180), 1, function()
			local squad = self:SpawnDeltaSquad(5)

			print("delta squad:")
			PrintTable(squad)

			if #squad == 0 then
				self:BroadcastCommander("Sorry, the extraction isn't coming. You're doomed. Better kill yourself.")
			else
				self:BroadcastCommander("The Delta Squad is here. Find them, and then follow them for your extraction.")

				self.saved.ExtractPoint = spawnPoint.pos

				self:BringPlayers(squad, spawnPoint.pos, spawnPoint.ang)

				local players = table.Copy(self.humans)
				for ply, _ in pairs(self.saved.traitors or {}) do
					table.RemoveByValue(players, ply)
				end

				table.Add(players, squad)

				net.Start("zb_extractionpoint")
					net.WriteVector(self.saved.ExtractPoint)
				net.Send(players)
			end
		end)
	end
end


function MODE:InitiateTraitorExtraction()
	local spawnPoint = self.saved.traitorExtractPoint

	if spawnPoint then
		self.saved.TraitorExtractPoint = spawnPoint.pos

		for _, v in ipairs(self.saved.traitorsLookUp) do
			if !IsValid(v) then continue end
			if !v:Alive() then continue end
			if v.PlayerClassName == "furry" then continue end

			net.Start("zb_traitorextractionpoint")
				net.WriteVector(self.saved.TraitorExtractPoint)
			net.Send(self.saved.traitorsLookUp)
		end
	end
end

function MODE:ShouldRoundEnd()
	MODE.furries = {}
	MODE.humans = {}

	for _, v in player.Iterator() do
		if v:Team() == TEAM_SPECTATOR or !v:Alive() then
			continue
		end

		if v.PlayerClassName != "furry" and v.PlayerClassName != "commanderforces" then
			table.insert(MODE.humans, v)
		elseif v.PlayerClassName != "commanderforces" then
			table.insert(MODE.furries, v)
		end
	end

	if !self.saved.PlayerCount then
		self.saved.PlayerCount = #player.GetAll() - 1
	end

	if !self.saved.FirstCasualty and self.saved.PlayerCount > 3 and #self.humans < self.saved.PlayerCount then
		self.saved.FirstCasualty = true
		self:BroadcastCommander(table.Random(self.FirstCasualtyCommander))
		self:BroadcastContractor(table.Random(self.FirstCasualtyContractor))
	end

	if !self.saved.HalfWay and self.saved.PlayerCount > 6 and self.saved.PlayerCount / 2 >= #self.humans then
		self.saved.HalfWay = true

		if self.saved.CloseQuarters then
			self:BroadcastCommander(table.Random(self.HalfWayExtractCommander))

			self:InitiateCQExtraction()
		else
			self:BroadcastCommander(table.Random(self.HalfWayHeliCommander))

			if !IsValid(self.saved.UWUCopter) then
				self:SpawnSquadHelicopter()
			end
		end

		self:BroadcastContractor(table.Random(self.HalfWayContractor))
	end

	if !self.saved.ThreeLeft and self.saved.PlayerCount > 6 and #self.humans <= 3 then
		self.saved.ThreeLeft = true
		self:BroadcastCommander(table.Random(self.ThreeLeftCommander))
		self:BroadcastContractor(table.Random(self.ThreeLeftContractor))
	end

	if !self.saved.TwoLeft and self.saved.PlayerCount > 6 and #self.humans <= 2 then
		self.saved.TwoLeft = true
		self:BroadcastCommander(table.Random(self.TwoLeftCommander))
		self:BroadcastContractor(table.Random(self.TwoLeftContractor))
	end

	if !self.saved.OneLeft and self.saved.PlayerCount > 3 and #self.humans <= 1 then
		self.saved.OneLeft = true

		self:BroadcastCommander(table.Random(self.OneLeftCommander))
		self:BroadcastContractor(table.Random(self.OneLeftContractor))

		if !self.saved.ContractorEscapee then
			self:InitiateTraitorExtraction()
		end
	end

	return #MODE.humans == 0 or #MODE.furries == 0
end

MODE.Lootables = hg.loot_boxes

MODE.LootTable = {
	{30, {
		{15,"weapon_smallconsumable"},
		{12,"weapon_bigconsumable"},
		{8,"weapon_tourniquet"},
		{8,"weapon_bandage_sh"},
		{7,"weapon_ducttape"},
		{6,"weapon_painkillers"},
		{5,"weapon_bloodbag"},
		{5,"weapon_hammer"},
		{4,"weapon_walkie_talkie"},
		{3,"hg_flashlight"},
		{2,"weapon_pocketknife"},
		{2,"weapon_medkit_sh"},
		{1,"weapon_bat"},
		{1,"weapon_leadpipe"},
		{0.65,"weapon_hg_extinguisher"},
		{0.65,"ent_armor_mask2"},

		{1,"weapon_matches"},--for dumbasses

		{0.5,"weapon_hg_crowbar"},
		{0.4,"weapon_tomahawk"},
		{0.4,"weapon_hatchet"},
		{0.25,"weapon_hg_axe"},
		{0.25,"weapon_hg_sledgehammer"},
		{0.27, "ent_armor_helmet2"},
	}},
	{16, {
		{8,"hg_sling"},
		{8,"*ammo*"},
		{8,"*sight*"},
		{8,"*barrel*"},
		{15,"weapon_mp-80"},
		{10,"weapon_makarov"},
		{9,"weapon_hk_usp"},
		{9,"weapon_glock17"},
		{9,"weapon_cz75"},
		{9,"weapon_px4beretta"},
		{9,"weapon_m9beretta"},
		{7,"weapon_browninghp"},
		{7,"weapon_fn45"},
		--{7,"weapon_ab10"},
		{7,"weapon_pm9"},
		{7,"weapon_tec9"},
		{7,"weapon_revolver2"},
		--{6,"weapon_revolver357"},
		{6,"weapon_deagle"},
		{6,"weapon_colt9mm"},
		{5,"weapon_doublebarrel_short"},
		--{7,"ent_armor_vest6"},
		{5,"ent_armor_vest7"},
		{8, "ent_armor_helmet2"},
		-- Добавил это так как банально через время верхний тир падает РЕЖЕ в раз сто чем этот.
		{0.3,"weapon_smallconsumable"},
		{0.25,"weapon_bigconsumable"},
		{0.24,"weapon_walkie_talkie"},
		{0.23,"weapon_painkillers"},
		{0.2,"weapon_medkit_sh"},
		-- крутая медицина
		{0.2,"weapon_morphine"},
		{0.2,"weapon_mannitol"},
		{0.2,"weapon_naloxone"},
		{0.2,"weapon_fentanyl"},
		{0.2,"weapon_betablock"},
		{0.2,"weapon_adrenaline"},
		-- Как никак полезные инструменты для выбивание барикад и дверей
		{0.15,"weapon_hg_crowbar"},
		{0.15,"weapon_hatchet"},
		{0.1,"weapon_hg_axe"},
		{0.1,"weapon_hg_sledgehammer"},
	}},
	{8, {
		{5,"weapon_doublebarrel"},
		{4,"weapon_remington870"},

		{4,"weapon_glock18c"},
		{4,"weapon_skorpion"},
		{4,"weapon_mac11"},
		{4,"weapon_uzi"},
		{4,"weapon_tmp"},

		{4,"weapon_hg_molotov_tpik"},
		{4,"weapon_hg_pipebomb_tpik"},

		{3,"weapon_kar98"},
		{3,"weapon_ar_pistol"},
		{3,"weapon_draco"},
		{3,"weapon_mp5"},
		--{3,"weapon_xm1014"},

		{3,"ent_armor_vest3"},
		{3,"ent_armor_helmet1"},

		{3,"weapon_hg_grenade_tpik"},
		{3, "weapon_hg_f1_tpik"},

		{2,"weapon_mp7"},
		{2,"weapon_sks"},
		{2,"weapon_ar15"},

		{2,"ent_armor_vest4"},

		{1,"weapon_akmwreked"},
		{1,"weapon_vpo136"},
		{1,"weapon_sr25"},
	}},
	{2, {
		{4, "weapon_m4a1"},
		{4, "weapon_akm"},
		{3, "weapon_ash12"},
		{2, "weapon_m60"},
		{1, "weapon_fury13"}
	}}
}

function MODE:CanPlayerEnterVehicle(ply, ent) -- damdn i forgot about the broken mode hooks lmao
	if ply.PlayerClassName == "furry" then
		if (ply.cantdrivecd or 0) < CurTime() then
			ply:Notify("Uhh, idk how to drive.", 0, "idkdrive", 0)
			ply.cantdrivecd = CurTime() + 10
		end

		return false
	end
end

local killfurries = {
	"One freak less.",
	"Cleansed.",
	"Die, scum!",
	"Not even human!",
	"A raving beast, silenced.",
	"Unholy creature.",
	"Die! Die! Die!",
	"Fucking hate those things.",
	"I'll see you in hell.",
	"I bring god's justice.",
	"One abomination, now dead."
}

function MODE:PlayerDeath(ply, inflictor, att)
	self.saved.DeathNames[ply] = ply:GetNWString("PlayerName") or ply:Name() or "Unknown"

	local most_harm,biggest_attacker = 0,nil
	local last_attacker = nil

	if ply.PlayerClassName != "furry" then return end

	timer.Simple(.1,function()
		for attacker,attacker_harm in pairs(zb.HarmDone[ply] or {}) do
			if not IsValid(attacker) then continue end
			if most_harm < attacker_harm then
				most_harm = attacker_harm
				biggest_attacker = attacker:Name()
				last_attacker = attacker
			end
		end

		if last_attacker then
			if math.random(1, 3) == 1 then
				if last_attacker.PlayerClassName != "furry" then
					last_attacker:Notify(killfurries[math.random(#killfurries)])
				end
			end
		end
	end)
end

function MODE:SpawnGlideHelicopter()
	local heliPoints = zb.Points["UWU_GlideHeli"].Points or {}
	if #heliPoints == 0 then
		print("netu")
		return
	end

	local spawnPoint = table.Random(heliPoints)

	local heli = ents.Create("glide_gtav_cargobob")
	heli:SetPos(spawnPoint.pos + Vector(0, 0, 100))
	heli:SetAngles(spawnPoint.ang or Angle(0, 0, 0))
	heli:Spawn()
	heli:Activate()

	heli:SetColor(Color(26, 32, 32))

	heli:SetEngineState(2)
	heli:SetPower(1)

	heli.OldPhysicsCollide = heli.PhysicsCollide

	heli.PhysicsCollide = function(this, data)
		heli.OldPhysicsCollide(this, data)

		if data.TheirSurfaceProps ~= 76 then -- default_silent
			return
		end

		local phys = this:GetPhysicsObject()
		if not IsValid( phys ) then return end

		local extracted = false
		local players = {}
		--да дурак просто посмотри все сварки и все ентити из сварок удали (ну и проверь там если игрок то екстракт) ок
		// нет сам я не знаю
		-- for _, seat in Glide.EntityPairs( this.seats ) do
		-- 	if !IsValid( seat ) then return end
		-- 	if !seat.GlideSeatIndex then return end

		-- 	local ply = seat:GetDriver()
		-- 	if IsValid(ply) then
		-- 		if ply.PlayerClassName != "furry" and ply.PlayerClassName != "commanderforces" then
		-- 			extracted = true
		-- 		end

		-- 		table.insert(players, ply)
		-- 	end
		-- end

		for i, weld in pairs(constraint.FindConstraints(this, "Weld")) do
			//PrintTable(weld)
			if weld.Ent2:IsRagdoll() then
				local ply = hg.RagdollOwner(weld.Ent2)
				//ply:ChatPrint("fuckyou")
				if ply and !table.HasValue(players, ply) then
					if ply.PlayerClassName != "furry" and ply.PlayerClassName != "commanderforces" then
						extracted = true
					end

					table.insert(players, ply)
				end
			end
			if weld.Ent1:IsRagdoll() then
				local ply = hg.RagdollOwner(weld.Ent1)
				//ply:ChatPrint("fuckyou2")

				if ply and !table.HasValue(players, ply) then
					if ply.PlayerClassName != "furry" and ply.PlayerClassName != "commanderforces" then
						extracted = true
					end

					table.insert(players, ply)
				end
			end
			--hz proverim???
		end

		if extracted then
			for _, v in ipairs(players) do
				if IsValid(v.FakeRagdoll) then
					v.override = false
					v.FakeRagdoll:Remove()
				end
				//v:ChatPrint("You are a stupid furry UwU")
				v:KillSilent()
				timer.Simple(0.1, function()
					v:KillSilent() // awesomesauce
				end)

				self.saved.Escaped[v] = true

				if !self.saved.ContractorEscapee then
					self.saved.ContractorEscapee = true
					self:BroadcastContractor("Someone just escaped! The mission is a failure! Your contract is terminated.")
				end
			end

			timer.Simple(1, function()
				this:Remove()
			end)

			timer.Simple(5, function()
				self:BroadcastCommander("The extraction helicopter just left the area. Sorry pal, i guess you've got left behind.")
			end)
		end
	end

	heli:CallOnRemove("CommanderReply", function()
		if !self.HasExploded then return end

		timer.Simple(5, function()
			self:BroadcastCommander("I have lost contact with the helicopter... Fuck...")
		end)
	end)

	timer.Simple(1, function()
		net.Start("zb_extractionheli")
			net.WriteEntity(heli)
		net.Broadcast()
	end)

	return heli
end

function MODE:ZB_LootMultiplier(ply)
	local furamount = self.saved.furamount

	if ply.PlayerClassName == "furry" then
		return #MODE.humans * 2
	else
		return #MODE.furries * 0.5
	end
end

function MODE:HG_OnAssimilation(ply)
	self.saved.Assimilated[ply] = true
end

MODE.LastExtractThink = 0
MODE.LastDataSave = 0

function MODE:Think()
	local time = CurTime()

	-- self.saved.SavedData = self.saved.SavedData or {}
	-- local data = self.saved.SavedData

	-- if time > self.LastDataSave then
	-- 	local dataTbl = {}
	-- 	dataTbl.time = time
	-- 	dataTbl.players = {}
	-- 	for _, ply in player.Iterator() do
	-- 		if !ply:Alive() then continue end

	-- 		local plyData = {}
	-- 		plyData.pos = ply:GetPos()

	-- 		dataTbl.players[ply:EntIndex()] = plyData
	-- 	end

	-- 	table.insert(data, dataTbl)

	-- 	self.LastDataSave = time + 1
	-- end

	if !self.saved.ExtractPoint and !self.saved.TraitorExtractPoint then return end

	if time > self.LastExtractThink then
		for _, ply in player.Iterator() do
			if !ply:Alive() then continue end
			if ply.PlayerClassName == "furry" or ply.PlayerClassName == "commanderforces" then continue end

			if self.saved.TraitorExtractPoint and self.saved.traitors and self.saved.traitors[ply] then
				if (ply:GetPos() - self.saved.TraitorExtractPoint):LengthSqr() < 40000 then
					if !timer.Exists("zb_pathowogen_long_plyextract_" .. ply:EntIndex()) then
						ply:SetLocalVar("zb_Pathowogen_Extraction", time + 10)
						timer.Create("zb_pathowogen_long_plyextract_" .. ply:EntIndex(), 10, 1, function()
							if (ply:GetPos() - self.saved.TraitorExtractPoint):LengthSqr() < 40000 then
								if IsValid(ply.FakeRagdoll) then
									ply.override = false
									ply.FakeRagdoll:Remove()
								end
								//v:ChatPrint("You are a stupid furry UwU")
								ply:KillSilent()
								self.saved.Escaped[ply] = true
							end
						end)
					end
				elseif ply:GetLocalVar("zb_Pathowogen_Extraction") then
					ply:SetLocalVar("zb_Pathowogen_Extraction", nil)

					if timer.Exists("zb_pathowogen_long_plyextract_" .. ply:EntIndex()) then
						timer.Remove("zb_pathowogen_long_plyextract_" .. ply:EntIndex())
					end
				end
			elseif self.saved.ExtractPoint then
				if (ply:GetPos() - self.saved.ExtractPoint):LengthSqr() < 40000 then
					if !timer.Exists("zb_pathowogen_long_plyextract_" .. ply:EntIndex()) then
						ply:SetLocalVar("zb_Pathowogen_Extraction", time + 10)
						timer.Create("zb_pathowogen_long_plyextract_" .. ply:EntIndex(), 10, 1, function()
							if (ply:GetPos() - self.saved.ExtractPoint):LengthSqr() < 40000 then
								if IsValid(ply.FakeRagdoll) then
									ply.override = false
									ply.FakeRagdoll:Remove()
								end
								//v:ChatPrint("You are a stupid furry UwU")
								ply:KillSilent()
								self.saved.Escaped[ply] = true

								if !self.saved.ContractorEscapee then
									self.saved.ContractorEscapee = true
									self:BroadcastContractor("Someone just escaped! The mission is a failure! Your contract is terminated.")
								end
							end
						end)
					end
				elseif ply:GetLocalVar("zb_Pathowogen_Extraction") then
					ply:SetLocalVar("zb_Pathowogen_Extraction", nil)

					if timer.Exists("zb_pathowogen_long_plyextract_" .. ply:EntIndex()) then
						timer.Remove("zb_pathowogen_long_plyextract_" .. ply:EntIndex())
					end
				end
			end
		end

		self.LastExtractThink = time + 1
	end
end

function MODE:ZB_JoinSpectators(ply)
	if ply:Alive() then return true end
end

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
    if Victim:GetPlayerClass() == Attacker:GetPlayerClass() then
        return 1, true
    end
end