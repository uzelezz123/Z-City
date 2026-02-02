hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties

SetGlobalBool("AbnormaltiesEnabled", true)
util.AddNetworkString("Abnormalties(ShowTranslation)")
util.AddNetworkString("Abnormalties(ShowMessage)")
util.AddNetworkString("Abnormalties(SendOpenedPage)")

--\\Settings
	--=\\Other
		PLUGIN.ZoneCheckCD = 3
		PLUGIN.StandartZoneRadius = 70
		PLUGIN.MaxZoneRadius = 500
		PLUGIN.HotZonePoints = 500
		PLUGIN.HotChars = PLUGIN.HotChars or {}
		PLUGIN.HotWords = PLUGIN.HotWords or {}
		PLUGIN.Zones = PLUGIN.Zones or {}
		PLUGIN.HotZones = PLUGIN.HotZones or {}
		PLUGIN.ConsequencesMul = 1
		PLUGIN.ConsequencesMulBeforeHot = 0.2
	--=//

	--=\\SQL
		-- PLUGIN.SQLSaveCD
	--=//
--//

--\\SQL
	-- PLUGIN.LoadConsequences(Entity(1))
	-- print()
	
	function PLUGIN.LoadConsequences(ply, dont_create_data)
		local consequences = PLUGIN.GetConsequences(ply, function(ply, consequences, knowledge, stats, registered)
			if(registered)then
				ply.AbnormaltiesReady = true
			end
			
			if(ply.AbnormaltiesStoredAddConsequences or ply.AbnormaltiesStoredConsequences)then
				if(ply.AbnormaltiesStoredConsequences)then
					PLUGIN.SetConsequences(ply, ply.AbnormaltiesStoredConsequences)
				else
					PLUGIN.SetConsequences(ply, consequences + ply.AbnormaltiesStoredAddConsequences)
				end
				
				ply.AbnormaltiesStoredConsequences = nil
				ply.AbnormaltiesStoredAddConsequences = nil
			else
				ply:SetNWInt("AbnormaltiesConsequences", consequences)
			end
			
			if(ply.AbnormaltiesStoredKnowledge)then
				table.Merge(knowledge, ply.AbnormaltiesStoredKnowledge)
				
				ply.AbnormaltiesStoredKnowledge = nil
			end
			
			ply.AbnormaltiesKnowledge = knowledge
			local steam_id_64 = ply:SteamID64()
			PLUGIN.PlayerStats[steam_id_64] = PLUGIN.PlayerStats[steam_id_64] or {}
			
			for stat_name, stat_value in pairs(PLUGIN.PlayerStats[steam_id_64]) do
				if(stats[stat_name])then
					if(PLUGIN.PlayerStatsToAddAfterLoad[stat_name])then
						PLUGIN.PlayerStats[steam_id_64][stat_name] = PLUGIN.PlayerStats[steam_id_64][stat_name] or 0
						PLUGIN.PlayerStats[steam_id_64][stat_name] = stats[stat_name] + PLUGIN.PlayerStats[steam_id_64][stat_name]
					else
						PLUGIN.PlayerStats[steam_id_64][stat_name] = stats[stat_name]
					end
				end
			end
		end, dont_create_data)
		
		if(consequences != false)then
			ply.AbnormaltiesReady = true
			
			ply:SetNWInt("AbnormaltiesConsequences", consequences)
		end
	end

	hook.Add("DatabaseConnected", "AbnormaltiesSQL", function()
		local query = mysql:Create("abnormalties_player_info")
			query:Create("steamid", "VARCHAR(20) NOT NULL")
			query:Create("consequences", "INTEGER NOT NULL")
			query:Create("punishment", "INTEGER NOT NULL DEFAULT 0")
			query:Create("rituals_amt", "INTEGER NOT NULL DEFAULT 0")
			query:Create("knowledge", "TEXT")
			query:PrimaryKey("steamid")
			query:Callback(function(result)
				-- local query = mysql:Alter("abnormalties_player_info")
					-- query:Add("knowledge", "TEXT")
				-- query:Execute()
			end)
		query:Execute()
	end)

	hook.Add("PlayerInitialSpawn", "AbnormaltiesSQL", function(ply)
		PLUGIN.LoadConsequences(ply, true)
	end)
--//

--\\Universal save system
	PLUGIN.PlayerStatsToAddAfterLoad = {
		["rituals_amt"] = true,
	}
	
	PLUGIN.PlayerStats = PLUGIN.PlayerStats or {}
	PLUGIN.PlayerStatsPlayers = PLUGIN.PlayerStatsPlayers or {}
	PLUGIN.PlayerStatsSaveCD = 10

	function PLUGIN.SetPlayerStat(ply, stat_name, value)
		PLUGIN.PlayerStats[ply:SteamID64()] = PLUGIN.PlayerStats[ply:SteamID64()] or {}
		PLUGIN.PlayerStatsPlayers[ply:SteamID64()] = ply
		PLUGIN.PlayerStats[ply:SteamID64()][stat_name] = value
		
		if(!ply.AbnormaltiesReady)then
			PLUGIN.LoadConsequences(ply)
		end
	end

	function PLUGIN.GetPlayerStat(ply, stat_name)
		if(!PLUGIN.PlayerStats[ply:SteamID64()])then
			return nil
		else
			return PLUGIN.PlayerStats[ply:SteamID64()][stat_name]
		end
	end

	hook.Add("Think", "Abnormalties_SQLSave", function()
		for steam_id_64, stats in pairs(PLUGIN.PlayerStats) do
			local ply = PLUGIN.PlayerStatsPlayers[steam_id_64]
			
			if(IsValid(ply))then
				if(ply.AbnormaltiesReady)then
					if(!ply.AbnormaltiesNextStatsSaveTime or ply.AbnormaltiesNextStatsSaveTime <= CurTime())then
						ply.AbnormaltiesNextStatsSaveTime = CurTime() + PLUGIN.PlayerStatsSaveCD
						
						if(next(stats) != nil)then
							local query = mysql:Update("abnormalties_player_info")
								for stat_name, stat_value in pairs(stats) do
									query:Update(stat_name, stat_value)
								end
								
								query:Where("steamid", steam_id_64)
							query:Execute()
						end
					end
				else
					PLUGIN.LoadConsequences(ply)
				end
			else
				PLUGIN.PlayerStats[steam_id_64] = nil
				PLUGIN.PlayerStatsPlayers[steam_id_64] = nil
			end
		end
	end)

	hook.Add("PlayerDisconnected", "Abnormalties_SQLSave", function(ply)
		if(ply.AbnormaltiesReady)then
			local steam_id_64 = ply:SteamID64()
			local stats = PLUGIN.PlayerStats[steam_id_64]
			
			if(stats and next(stats) != nil)then
				local query = mysql:Update("abnormalties_player_info")
					for stat_name, stat_value in pairs(stats) do
						query:Update(stat_name, stat_value)
					end
					
					query:Where("steamid", steam_id_64)
				query:Execute()
			end
			
			PLUGIN.PlayerStats[steam_id_64] = nil
			PLUGIN.PlayerStatsPlayers[steam_id_64] = nil
		end
	end)
--//

--\\Knowledge
	function PLUGIN.SetKnowledge(ply, knowledge)
		if(ply.AbnormaltiesReady)then
			ply.AbnormaltiesKnowledge = knowledge
			
			local query = mysql:Update("abnormalties_player_info")
				query:Update("knowledge", util.TableToJSON(knowledge))
				query:Where("steamid", ply:SteamID64())
			query:Execute()
		else
			ply.AbnormaltiesStoredKnowledge = knowledge
		
			PLUGIN.LoadConsequences(ply)
			
			return false
		end
	end
--//

--\\Consequences
	function PLUGIN.SetConsequences(ply, amt, no_punishment)
		amt = math.Clamp(amt, -500, 500)
		local punishment = PLUGIN.GetPlayerStat(ply, "punishment") or 0
		
		if(!no_punishment)then
			PLUGIN.SetPlayerStat(ply, "punishment", math.min(punishment + 360 * 2, 1000))
		end
		
		if(ply.AbnormaltiesReady)then
			ply:SetNWInt("AbnormaltiesConsequences", amt)
			
			local query = mysql:Update("abnormalties_player_info")
				query:Update("consequences", math.Truncate(amt))
				query:Where("steamid", ply:SteamID64())
			query:Execute()
			
			local knowledge = ply.AbnormaltiesKnowledge
			local knowledge_changed = false
			
			if(!knowledge["consequences"])then
				if(amt <= -20 or amt >= 20)then
					knowledge["consequences"] = true
					knowledge_changed = true
					
					PLUGIN.ShowMessage(ply, "You are now able to read page 8")
				end
			end
			
			if(!knowledge["instabillity"])then
				if(amt <= -300 or amt >= 300)then
					knowledge["instabillity"] = true
					knowledge_changed = true
					
					PLUGIN.ShowMessage(ply, "You are now able to read page 9")
				end
			end
			
			if(!knowledge["positive_instabillity"])then
				if(amt >= 300)then
					knowledge["positive_instabillity"] = true
					knowledge_changed = true
					
					PLUGIN.ShowMessage(ply, "You are now able to read page 13")
					PLUGIN.ShowMessage(ply, "You are now able to read page 15")
				end
			end
			
			if(!knowledge["negative_instabillity"])then
				if(amt <= -300)then
					knowledge["negative_instabillity"] = true
					knowledge_changed = true
					
					PLUGIN.ShowMessage(ply, "You are now able to read page 14")
					PLUGIN.ShowMessage(ply, "You are now able to read page 16")
				end
			end
			
			if(!knowledge["insanity"])then
				if(amt <= -500 or amt >= 500)then
					knowledge["insanity"] = true
					knowledge_changed = true
					
					PLUGIN.ShowMessage(ply, "You are now able to read page 10")
				end
			end
			
			if(knowledge_changed)then
				PLUGIN.SetKnowledge(ply, knowledge)
			end
		else
			ply.AbnormaltiesStoredConsequences = amt
		
			PLUGIN.LoadConsequences(ply)
			
			return false
		end
	end

	-- ulx luarun hg.Abnormalties.SetConsequences(Entity(1), 500)

	function PLUGIN.AddConsequences(ply, amt)
		local stored_amt = ply:GetNWInt("AbnormaltiesConsequences", 0)
		stored_amt = stored_amt + amt
		
		if(PLUGIN.SetConsequences(ply, stored_amt) == false)then
			ply.AbnormaltiesStoredAddConsequences = (ply.AbnormaltiesStoredAddConsequences or 0) + amt
		end
	end

	function PLUGIN.AddConsequencesToZoneChanters(zone, amt_mul)
		for ply, amt in pairs(zone.Chanters) do
			if(IsValid(ply))then
				PLUGIN.AddConsequences(ply, math.min(amt * amt_mul * PLUGIN.ConsequencesMul, 150))
				
				zone.Chanters[ply] = 0
			end
		end
	end

	function PLUGIN.GetConsequences(ply, callback, dont_create_data) --; Load everything from db
		local value = ply:GetNWInt("AbnormaltiesConsequences", false)
		
		if(!ply.AbnormaltiesReady)then
			local query = mysql:Select("abnormalties_player_info")
				query:Select("consequences")
				query:Select("knowledge")
				query:Select("punishment")
				query:Select("rituals_amt")
				query:Where("steamid", ply:SteamID64())
				query:Callback(function(result)
					local consequences = 0
					local knowledge = {}
					local stats = {
						punishment = 0,
						rituals_amt = 0
					}
					local registered = false
				
					if(IsValid(ply))then
						if(istable(result) and result[1])then
							if(result[1].consequences)then
								consequences = tonumber(result[1].consequences)
							end
							
							if(result[1].knowledge)then
								knowledge = util.JSONToTable(result[1].knowledge) or knowledge
							end
							
							if(result[1].punishment)then
								stats.punishment = tonumber(result[1].punishment)
							end
							
							if(result[1].rituals_amt)then
								stats.rituals_amt = tonumber(result[1].rituals_amt)
							end
							
							registered = true
						else
							if(!dont_create_data)then
								local query = mysql:Insert("abnormalties_player_info")
									query:Insert("steamid", ply:SteamID64())
									query:Insert("consequences", 0)
									query:Insert("knowledge", util.TableToJSON({}))
									query:Insert("punishment", 0)
									query:Insert("rituals_amt", 0)
								query:Execute()
								
								registered = true
							end
						end
						
						if(callback)then
							callback(ply, consequences, knowledge, stats, registered)
						end
					end
				end)
			query:Execute()
		
			return false
		end
		
		return value
	end

	--=\\Hooks
		PLUGIN.ConsequencesValidBleedBones = {
			"ValveBiped.Bip01_Pelvis",
			"ValveBiped.Bip01_Spine",
			"ValveBiped.Bip01_Spine1",
			"ValveBiped.Bip01_Spine2",
			"ValveBiped.Bip01_L_Forearm",
			"ValveBiped.Bip01_R_Forearm",
			"ValveBiped.Bip01_L_Hand",
			"ValveBiped.Bip01_R_Hand",
		}

		local function find_valid_bone_random(ent, valid_bones_list)
			local list_copy = table.Copy(valid_bones_list)
			local inital_list_size = #list_copy
			local random_key, random_name = nil, nil
			local bone = nil
			
			for iteration = 1, inital_list_size do
				random_name, random_key = table.Random(list_copy)
				bone = ent:LookupBone(random_name)
				
				if(bone)then
					return bone
				else
					list_copy[random_key] = nil
				end
			end
			
			return 1
		end
		
		hook.Add("PlayerPostThink", "Abnormalties_Consequences", function(ply)
			if(ply.AbnormaltiesReady)then
				ply.AbnormaltiesConsequencesLastThink = ply.AbnormaltiesConsequencesLastThink or CurTime()
				local delta_time = CurTime() - ply.AbnormaltiesConsequencesLastThink
				ply.AbnormaltiesConsequencesLastThink = CurTime()
				local consequences = PLUGIN.GetConsequences(ply)
				local abs_consequences = math.abs(consequences)
				local punishment = PLUGIN.GetPlayerStat(ply, "punishment") or 0
				local punishment_mul = math.min(punishment / 360, 1)
				
				if(punishment_mul > 0 and ply:Alive())then
					local pulse = ply.organism.pulse
					local max_pulse = 100
					local bleeding_chance = math.max(pulse / max_pulse - 1, 0)
					local bleeding_add_power = bleeding_chance * 2
					local headache_time = math.Clamp(550 - (abs_consequences), 85, 130)
					local pulse_spike_time = math.max(100 - (abs_consequences), 25)
					
					if(ply.AbnormaltiesHealGrace)then
						if(ply.AbnormaltiesHealGrace <= CurTime())then
							ply.AbnormaltiesHealGrace = nil
						end
						
						abs_consequences = abs_consequences / 10
					end
					
					if(ply.armors)then
						if(ply.armors["torso"] == "ego_equalizer")then
							abs_consequences = abs_consequences / 4
						end
					end
					
					if(abs_consequences >= 20)then
						--; Mild headaches
						
						ply.AbnormaltiesConsequencesLastHeadacheTime = ply.AbnormaltiesConsequencesLastHeadacheTime or CurTime()
						ply.AbnormaltiesConsequencesHeadacheRandomTime = ply.AbnormaltiesConsequencesHeadacheRandomTime or math.Rand(-10, 10)
						
						if(ply.AbnormaltiesConsequencesLastHeadacheTime + headache_time + ply.AbnormaltiesConsequencesHeadacheRandomTime <= CurTime())then
							ply.AbnormaltiesConsequencesLastHeadacheTime = CurTime()
							ply.AbnormaltiesConsequencesHeadacheRandomTime = math.Rand(-10, 10)
							local disorientation_amt = math.Clamp(2 + (abs_consequences / 100) * 1 * punishment_mul, 2, 6)
							
							if(ply.organism.painkiller and ply.organism.painkiller > 0.2)then
								ply.organism.disorientation = (ply.organism.disorientation or 0) + disorientation_amt - ply.organism.painkiller
							else
								ply.organism.disorientation = (ply.organism.disorientation or 0) + disorientation_amt
							end
						end
					end
					
					if(abs_consequences >= 50)then
						--; Bleeding then heartbeat is high
						--; Negligible Screen distortion(will scale with consequences for later)
						
						if(consequences > 0)then
							if(bleeding_chance > 0)then
								ply.AbnormaltiesConsequencesDamagePower = ply.AbnormaltiesConsequencesDamagePower or 0
								
								if(math.random(1, 100) <= bleeding_chance * 100)then
									ply.AbnormaltiesConsequencesDamagePower = ply.AbnormaltiesConsequencesDamagePower + delta_time * bleeding_add_power
								end
								
								if(ply.AbnormaltiesConsequencesDamagePower >= 1 and (!ply.AbnormaltiesConsequencesDamagePowerCDTime or ply.AbnormaltiesConsequencesDamagePowerCDTime <= CurTime()))then
									ply.AbnormaltiesConsequencesDamagePower = 0
									ply.AbnormaltiesConsequencesDamagePowerCDTime = CurTime() + 0.06
									ply.AbnormaltiesDoNotCountEqualizers = true
									local damage = DamageInfo()
									
									damage:SetDamage(bleeding_chance * 25)
									damage:SetDamageType(DMG_SONIC)
									damage:SetAttacker(ply)
									ply:TakeDamageInfo(damage)
								end
							end
						else
							if(bleeding_chance > 0)then
								ply.AbnormaltiesConsequencesBleedingPower = ply.AbnormaltiesConsequencesBleedingPower or 0
								
								if(math.random(1, 100) <= bleeding_chance * 100)then
									ply.AbnormaltiesConsequencesBleedingPower = ply.AbnormaltiesConsequencesBleedingPower + delta_time * bleeding_add_power
								end
								
								if(ply.AbnormaltiesConsequencesBleedingPower >= 1 and (!ply.AbnormaltiesConsequencesBleedingPowerCDTime or ply.AbnormaltiesConsequencesBleedingPowerCDTime <= CurTime()))then
									ply.AbnormaltiesConsequencesBleedingPower = 0
									ply.AbnormaltiesConsequencesBleedingPowerCDTime = CurTime() + 0.5
									
									hg.organism.AddWoundManual(ply, bleeding_chance * 20, vector_origin, AngleRand(), find_valid_bone_random(ply, PLUGIN.ConsequencesValidBleedBones), CurTime())
								end
							end
						end
					end
					
					if(abs_consequences >= 100)then
						--; Random bleedings
						--; (Random heartbeat spikes)
						--; Loss of consciousness at high enough heartbeat
						--; Heavy headaches
						--; Stamina loss
						--; Increased weapon wielding shivers
						
						ply.AbnormaltiesConsequencesLastPulseSpikeTime = ply.AbnormaltiesConsequencesLastPulseSpikeTime or CurTime()
						ply.AbnormaltiesConsequencesPulseSpikeRandomTime = ply.AbnormaltiesConsequencesPulseSpikeRandomTime or math.Rand(-10, 10)
						
						if(ply.AbnormaltiesConsequencesLastPulseSpikeTime + pulse_spike_time + ply.AbnormaltiesConsequencesPulseSpikeRandomTime <= CurTime())then
							ply.AbnormaltiesConsequencesLastPulseSpikeTime = CurTime()
							ply.AbnormaltiesConsequencesHeadacheRandomTime = math.Rand(-10, 10)
							ply.organism.pulse = (ply.organism.pulse or 0) + math.min((abs_consequences / 100) * 20 * punishment_mul, 75)
							-- ply:ChatPrint(ply.organism.pulse)
						end
					end
					
					if(abs_consequences >= 150)then
						--; Massive headaches
						--; Loss of control
						--; Random vocal synthesizer sounds
					end
					
					if(consequences >= 300)then
						--; Benefits
						
						if(!ply.AbnormaltiesNextBenefitsTime or ply.AbnormaltiesNextBenefitsTime <= CurTime())then
							ply.AbnormaltiesNextBenefitsTime = CurTime() + 1
							ply.Abnormalties_Equalizers = (ply.Abnormalties_Equalizers or 0) + 2 * punishment_mul
						end
					end
					
					if(consequences <= -300)then
						--; Benefits
						
						if(!ply.AbnormaltiesNextBenefitsTime or ply.AbnormaltiesNextBenefitsTime <= CurTime())then
							ply.AbnormaltiesNextBenefitsTime = CurTime() + 1
							ply.Abnormalties_Blood = (ply.Abnormalties_Blood or 0) + 100 * punishment_mul
						end
					end
				end
				
				if(!ply.AbnormaltiesConsequencesNextPunishmentReduceTime)then
					ply.AbnormaltiesConsequencesNextPunishmentReduceTime = CurTime() + 1
				end
				
				if(ply.AbnormaltiesConsequencesNextPunishmentReduceTime <= CurTime())then
					ply.AbnormaltiesConsequencesNextPunishmentReduceTime = CurTime() + 1
					punishment = math.max(math.Truncate(punishment - 1), 0)
					
					PLUGIN.SetPlayerStat(ply, "punishment", punishment)
				end
			end
		end)
	--=//
--//

--\\??
	function PLUGIN.ShowTranslation(ply, abnormalty)
		net.Start("Abnormalties(ShowTranslation)")
			
			for abnormalty_name, amt in pairs(abnormalty) do
				if(amt != 0)then
					net.WriteString(abnormalty_name)
					net.WriteUInt(amt, 32)
				end
			end
			
			net.WriteString("")
		net.Send(ply)
	end

	function PLUGIN.ShowMessage(ply, msg)
		net.Start("Abnormalties(ShowMessage)")
			net.WriteString(msg)
		net.Send(ply)
	end

	function PLUGIN.ShowMessageInSphere(msg, pos, radius)
		for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
			if(ent:IsPlayer())then
				net.Start("Abnormalties(ShowMessage)")
					net.WriteString(msg)
				net.Send(ent)
			end
		end
	end

	function PLUGIN.ShowMessageToAll(msg)
		for _, ply in player.Iterator() do
			PLUGIN.ShowMessage(ply, msg)
		end
	end
	
	function PLUGIN.ShowMessageToAllExcept(msg, ply_exception)
		for _, ply in player.Iterator() do
			if(ply != ply_exception)then
				PLUGIN.ShowMessage(ply, msg)
			end
		end
	end
--//

--\\Ritual
	function PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
		zone.PhrasesAbnormalties = {}
		zone.PhrasesAbnormalties_Swap = {}
	end

	function PLUGIN.AddPhraseAbnormaltyToZone(zone, abnormalty_name, amt)
		zone.PhrasesAbnormalties = zone.PhrasesAbnormalties or {}
		zone.PhrasesAbnormalties[#zone.PhrasesAbnormalties + 1] = {abnormalty_name, amt}
	
		if(#zone.PhrasesAbnormalties >= 10 * 2)then
			zone.PhrasesAbnormalties_Swap = zone.PhrasesAbnormalties_Swap or {}
			zone.PhrasesAbnormalties = zone.PhrasesAbnormalties_Swap
			zone.PhrasesAbnormalties_Swap = {}
		elseif(#zone.PhrasesAbnormalties >= 10)then
			zone.PhrasesAbnormalties_Swap = zone.PhrasesAbnormalties_Swap or {}
			zone.PhrasesAbnormalties_Swap[#zone.PhrasesAbnormalties_Swap + 1] = {abnormalty_name, amt}
		end
	end

	function PLUGIN.CompareZonePhrasesToPattern(zone, pattern, amt)
		zone.PhrasesAbnormalties = zone.PhrasesAbnormalties or {}
		local phrases_amt = #zone.PhrasesAbnormalties
		
		if(phrases_amt >= amt)then
			local pattern_key, pattern_item = nil, nil
			
			for phrase_key = phrases_amt - amt + 1, phrases_amt do
				pattern_key, pattern_item = next(pattern, pattern_key)
				
				if(!pattern_item)then
					pattern_key, pattern_item = next(pattern, nil)
				end
				
				local phrase_info = zone.PhrasesAbnormalties[phrase_key]
				
				if(phrase_info[1] != pattern_item[1] or phrase_info[2] < pattern_item[2])then
					return false
				end
			end
			
			return true
		end
		
		return false
	end
	
	function PLUGIN.FindPlyInZone(zone, caller, caller_priority, check_function)
		local best_ply = nil
		local best_dist = math.huge

		for _, ent in ipairs(ents.FindInSphere(zone.Pos, zone.Radius)) do
			if(ent:IsPlayer() and ent:Alive())then
				if(!check_function or check_function(ent))then
					local dist_sqr = zone.Pos:DistToSqr(ent:GetPos())
				
					if(caller == ent)then
						dist_sqr = dist_sqr / (caller_priority or 2)
					end
				
					if(dist_sqr < best_dist)then
						best_dist = dist_sqr
						best_ply = ent
					end
				end
			end
		end
		
		return best_ply
	end
	
	function PLUGIN.FindEntInZone(zone, caller, check_function)
		local best_ent = nil
		local best_dist = math.huge

		for _, ent in ipairs(ents.FindInSphere(zone.Pos, zone.Radius)) do
			if(check_function(ent))then
				local dist_sqr = zone.Pos:DistToSqr(ent:GetPos())
				
				if(dist_sqr < best_dist)then
					best_dist = dist_sqr
					best_ent = ent
				end
			end
		end
		
		return best_ent
	end
--//

--\\
	function PLUGIN.TranslateWordsToAbnormalty(text)
		local abnormalty = {}
		-- local abnormalty_count = 0
		local words = {}
		local chars = {}
		local word = ""
		local blank = 0
		local longest_blank = 0
		local cursor = 1
		local uselessness = 6
		local next_char = utf8.GetChar(text, cursor)
		
		while(next_char != "")do
			local char_abnormalty = PLUGIN.CharInfo[next_char]
			
			if(char_abnormalty)then
				if(!chars[next_char])then
					chars[next_char] = true
					uselessness = math.max(uselessness - 1, 0)
				end
				
				local abnormalty_amt = #char_abnormalty
				
				for i = 1, abnormalty_amt do
					abnormalty[char_abnormalty[i][1]] = math.max((abnormalty[char_abnormalty[i][1]] or 0) + char_abnormalty[i][2], 0)
				end
			end
			
			if(next_char == " ")then
				if(#word != 0)then
					words[#words + 1] = word
					local special_word_info = PLUGIN.SpecialWords[word]
					
					if(special_word_info)then
						for abnormalty_name, amt in pairs(special_word_info) do
							abnormalty[abnormalty_name] = math.max((abnormalty[abnormalty_name] or 0) + amt, 0)
						end
					end
					
					word = ""
				end
				
				blank = blank + 1
			else
				if(longest_blank < blank)then
					longest_blank = blank
				end
				
				blank = 0
				word = word .. next_char
			end
			
			cursor = cursor + 1
			next_char = utf8.GetChar(text, cursor)
		end
		
		if(#word != 0)then
			words[#words + 1] = word
			local special_word_info = PLUGIN.SpecialWords[word]
			
			if(special_word_info)then
				for abnormalty_name, amt in pairs(special_word_info) do
					abnormalty[abnormalty_name] = math.max((abnormalty[abnormalty_name] or 0) + amt, 0)
				end
			end
		end
		
		return abnormalty, words, longest_blank, uselessness, chars
	end

	function PLUGIN.GetZoneAbnormalty(zone, abnormalty_name)
		return zone.Abnormalties[abnormalty_name] and zone.Abnormalties[abnormalty_name] or 0
	end

	function PLUGIN.GetZoneOrPlyBlood(zone, ply)
		return (zone.Blood or 0) + (ply.Abnormalties_Blood or 0)
	end
	
	function PLUGIN.RemoveZoneOrPlyBlood(zone, ply, amt)
		local non_satisfied_amt = amt
		
		if(zone.Blood)then
			local old_amt = zone.Blood
			zone.Blood = math.max(zone.Blood - non_satisfied_amt, 0)
			local lost_amt = old_amt - zone.Blood
			non_satisfied_amt = non_satisfied_amt - lost_amt
		end
		
		if(ply.Abnormalties_Blood)then
			local old_amt = ply.Abnormalties_Blood
			ply.Abnormalties_Blood = math.max(ply.Abnormalties_Blood - non_satisfied_amt, 0)
			local lost_amt = old_amt - ply.Abnormalties_Blood
			non_satisfied_amt = non_satisfied_amt - lost_amt
		end

		return non_satisfied_amt
	end

	function PLUGIN.GetZoneOrPlyEqualizers(zone, ply)
		return (zone.Equalizers or 0) + (ply.Abnormalties_Equalizers or 0)
	end

	function PLUGIN.RemoveZoneOrPlyEqualizers(zone, ply, amt)
		local non_satisfied_amt = amt
		
		if(zone.Equalizers)then
			local old_amt = zone.Equalizers
			zone.Equalizers = math.max(zone.Equalizers - non_satisfied_amt, 0)
			local lost_amt = old_amt - zone.Equalizers
			non_satisfied_amt = non_satisfied_amt - lost_amt
		end
		
		if(ply.Abnormalties_Equalizers)then
			local old_amt = ply.Abnormalties_Equalizers
			ply.Abnormalties_Equalizers = math.max(ply.Abnormalties_Equalizers - non_satisfied_amt, 0)
			local lost_amt = old_amt - ply.Abnormalties_Equalizers
			non_satisfied_amt = non_satisfied_amt - lost_amt
		end

		return non_satisfied_amt
	end

	--=\\??
		function PLUGIN.DoWithinZones(pos, func)
			local found_zone = false

			for zone_id, zone in ipairs(PLUGIN.Zones) do
				local zone_pos = zone.Pos
				local zone_radius = zone.Radius
				local zone_radius_sqr = zone_radius * zone_radius
				
				if(pos:DistToSqr(zone_pos) <= zone_radius_sqr)then
					found_zone = true
					
					func(zone_id, zone)
				end
			end
			
			return found_zone
		end

		function PLUGIN.AddBloodToHotZones(pos, amt)
			for zone_id, _ in pairs(PLUGIN.HotZones) do
				local zone = PLUGIN.Zones[zone_id]
				
				if(zone)then
					amt = amt or 1
					local zone_pos = zone.Pos
					local zone_radius = zone.Radius
					local zone_radius_sqr = zone_radius * zone_radius
					local dist_sqr = pos:DistToSqr(zone_pos)
					
					if(dist_sqr <= zone_radius_sqr)then
						zone.Blood = (zone.Blood or 0) + amt
					end
				end
			end
		end

		function PLUGIN.AnalyseWordsAndAddToHotZone(text, pos, ply)
			text = PLUGIN.String.StringLower(text)
			local abnormalty, words, longest_blank, uselessness, chars = PLUGIN.TranslateWordsToAbnormalty(text)
			local abnormalty_count = 0
			local words_amt = #words

			for abnormalty_name, amt in pairs(abnormalty) do
				if(amt != 0)then
					abnormalty_count = abnormalty_count + 1
				end
			end

			if(abnormalty_count == 1)then
				if(uselessness == 0)then
					local points_to_add = 0
				
					for key = 1, words_amt do
						local word = words[key]
						PLUGIN.HotWords[word] = PLUGIN.HotWords[word] or {}
						local time_elapsed = CurTime() - (PLUGIN.HotWords[word].LastTime or CurTime())
						points_to_add = math.min(time_elapsed, 20) + words_amt / 5 + 5
						PLUGIN.HotWords[word] = PLUGIN.HotWords[word] or {}
						PLUGIN.HotWords[word].Count = (PLUGIN.HotWords[word].Count or 0) + 1
						PLUGIN.HotWords[word].LastTime = CurTime()
					end
					
					local found_zone = PLUGIN.DoWithinZones(pos, function(zone_id, zone)
						zone.Chanters[ply] = (zone.Chanters[ply] or 0) + 1 * PLUGIN.ConsequencesMulBeforeHot
						zone.Points = zone.Points + points_to_add
						zone.Radius = math.min(zone.Radius + points_to_add / 10, PLUGIN.MaxZoneRadius)
						
						if(zone.Points > PLUGIN.HotZonePoints)then
							if(!PLUGIN.HotZones[zone_id])then
								PLUGIN.HotZones[zone_id] = true
								
								PLUGIN.ShowMessageInSphere("Zone grew enough to start phrase accumulation and rituals", zone.Pos, zone.Radius)
							end
							
							for abnormalty_name, amt in pairs(abnormalty) do
								zone.Abnormalties[abnormalty_name] = (zone.Abnormalties[abnormalty_name] or 0) + amt
								
								hook.Run("Abnormalties_HotZoneAbnormaltyAdded", zone_id, abnormalty_name, amt, ply)
							end
						end
					end)

					if(!found_zone)then
						PLUGIN.Zones[#PLUGIN.Zones + 1] = {
							Pos = pos,
							Radius = PLUGIN.StandartZoneRadius,
							Points = 0,
							Words = {},
							Abnormalties = {},
							Vars = {},
							Chanters = {[ply] = 1 * PLUGIN.ConsequencesMulBeforeHot},
						}
					end
					
					for char, _ in pairs(chars) do
						PLUGIN.HotChars[char] = CurTime() + 60 * 10
					end
				end
			end
			
			return abnormalty, uselessness
		end
	--=//
	
	--=\\Testing
		--[[
			ulx luarun hg.Abnormalties.TestZone(Entity(1), Entity(1):GetPos(), {['ritual'] = 10}, 50)
			ulx luarun hg.Abnormalties.AddPhraseAbnormaltyToZone(hg.Abnormalties.Zones[1], 'help', 1)
			ulx luarun hg.Abnormalties.AddPhraseAbnormaltyToZone(hg.Abnormalties.Zones[1], 'ritual', 1)
			ulx luarun =hg.Abnormalties.CompareZonePhrasesToPattern(hg.Abnormalties.Zones[1], {{'help', 1}, {'ritual', 1}}, 5)
		]]
		
		--; ulx luarun hg.Abnormalties.FindValidPhrase('ritual', 40, '')
		
		function PLUGIN.FindValidPhrase(abnormalty_name, tries, text_start)
			local text = text_start or ""
			
			for try = 1, tries do
				local abnormalties, words, longest_blank, uselessness, chars = PLUGIN.TranslateWordsToAbnormalty(text)
				local abnormalty_count = 0

				for abnormalty_name, amt in pairs(abnormalties) do
					if(amt != 0)then
						abnormalty_count = abnormalty_count + 1
					end
				end
				
				if(uselessness == 0 and abnormalty_count == 1)then
					return text, true
				else
					local best_char = "a"
					local best_char_goodness = -math.huge
				
					for char, char_info in pairs(PLUGIN.CharInfo) do
						local char_goodness = 0
						
						for _, char_abnormalty_info in ipairs(char_info) do
							char_abnormalty_name = char_abnormalty_info[1]
							char_amt = char_abnormalty_info[2]
							
							if(char_abnormalty_name == abnormalty_name)then
								if(char_amt == -1)then
									char_goodness = char_goodness - 1
								elseif(char_amt == 1)then
									char_goodness = char_goodness + 1
								end
							else
								if(abnormalties[char_abnormalty_name] and abnormalties[char_abnormalty_name] > 0)then
									if(char_amt == -1)then
										char_goodness = char_goodness + 1
									elseif(char_amt == 1)then
										char_goodness = char_goodness - 1
									end
								end
							end
						end
						
						if((char_goodness == best_char_goodness and math.random(1, 2) == 1) or char_goodness > best_char_goodness)then
							best_char_goodness = char_goodness
							best_char = char
						end
					end
					
					text = text .. best_char
				end
			end
			
			return text, false
		end

		function PLUGIN.TestZone(ply, pos, abnormalty, points_to_add)
			local found_zone = PLUGIN.DoWithinZones(pos, function(zone_id, zone)
				zone.Chanters[ply] = (zone.Chanters[ply] or 0) + 1
				zone.Points = zone.Points + points_to_add
				zone.Radius = math.min(zone.Radius + points_to_add / 10, PLUGIN.MaxZoneRadius)
				
				if(zone.Points > PLUGIN.HotZonePoints)then
					if(!PLUGIN.HotZones[zone_id])then
						PLUGIN.HotZones[zone_id] = true
						
						PLUGIN.ShowMessageInSphere("Zone grew enough to start phrase accumulation and rituals", zone.Pos, zone.Radius)
					end
					
					for abnormalty_name, amt in pairs(abnormalty) do
						zone.Abnormalties[abnormalty_name] = (zone.Abnormalties[abnormalty_name] or 0) + amt
						
						hook.Run("Abnormalties_HotZoneAbnormaltyAdded", zone_id, abnormalty_name, amt, ply)
					end
				end
			end)

			if(!found_zone)then
				PLUGIN.Zones[#PLUGIN.Zones + 1] = {
					Pos = pos,
					Radius = PLUGIN.StandartZoneRadius,
					Points = 0,
					Words = {},
					Abnormalties = {},
					Vars = {},
					Chanters = {[ply] = 1},
				}
			end
		end
		
		hook.Add("Abnormalties_HotZoneAbnormaltyAdded", "Abnormalties", function(zone_id, abnormalty_name, amt, ply)
			local zone = PLUGIN.Zones[zone_id]
			
			if(amt > 0)then
				PLUGIN.AddPhraseAbnormaltyToZone(zone, abnormalty_name, amt)
			end
		end)
	--=//

	function PLUGIN.RandomizeCharInfos()
		PLUGIN.Randomized = true
		
		PLUGIN.CreateRandomCharInfo(65 + 32, 90 + 32)
		PLUGIN.CreateRandomCharInfo(1040 + 32, 1071 + 32)
		
		hook.Run("Abnormalties_RandomizeCharInfos")
	end
--//

--\\Special Equipment
	hook.Add("PreHomigradDamage", "Abnormalties_SpecialEquipment", function(ply, dmg, hitgroup, ent, harm)
		if(ply.armors)then
			if(ply.armors["torso"] == "ego_equalizer")then
				if(dmg:IsDamageType(DMG_BULLET + DMG_BUCKSHOT))then
					dmg:ScaleDamage(0.4)
				elseif(dmg:IsDamageType(DMG_SLASH + DMG_CLUB + DMG_GENERIC))then
					dmg:ScaleDamage(0.5)
				end
			end
		end
	end)
	
	hook.Add("PreTraceOrganBulletDamage", "Abnormalties_SpecialEquipment", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
		local ply = org.owner
		
		if(IsValid(ply) and ply.armors)then
			if(ply.armors["torso"] == "ego_equalizer")then
				if(dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT))then
					hook_info.dmg = hook_info.dmg * 0.005
				elseif(dmgInfo:IsDamageType(DMG_SLASH + DMG_CLUB + DMG_GENERIC))then
					hook_info.dmg = hook_info.dmg * 0.1
				end
			end
		end
	end)
	
	hook.Add("PreHomigradDamageBulletBleedAdd", "Abnormalties_SpecialEquipment", function(ent, org, dmgInfo, hitgroup, harm, hitBoxs, inputHole, hook_info)
		local ply = org.owner
		
		if(IsValid(ply) and ply.armors)then
			if(ply.armors["torso"] == "ego_equalizer")then
				if(dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT))then
					hook_info.bleed = hook_info.bleed * 0.1
				elseif(dmgInfo:IsDamageType(DMG_SLASH + DMG_CLUB + DMG_GENERIC))then
					hook_info.bleed = hook_info.bleed * 1.2
				end
			end
		end
	end)
--//

--\\??
	local function coroutine_think_func()
		for zone_id, _ in ipairs(PLUGIN.HotZones) do
			
			
			coroutine.yield()
		end
		
		hook.Remove("Think", "temp_Abnormalties")
		
		PLUGIN.NextZoneCheck = CurTime() + PLUGIN.ZoneCheckCD
	end

	local coroutine_think = nil

	hook.Add("Think", "Abnormalties", function()
		if(!PLUGIN.NextZoneCheck or PLUGIN.NextZoneCheck <= CurTime())then
			PLUGIN.NextZoneCheck = CurTime() + 100
			
			hook.Add("Think", "temp_Abnormalties", function()
				if not coroutine_think or not coroutine.resume(coroutine_think) then
					coroutine_think = coroutine.create(coroutine_think_func)
					
					coroutine.resume(coroutine_think)
				end
			end)
		end
	end)

	hook.Add("PostCleanupMap", "Abnormalties", function()
		PLUGIN.HotWords = {}
		PLUGIN.Zones = {}
		PLUGIN.HotZones = {}
		
		PLUGIN.RandomizeCharInfos()
		
		for _, ply in player.Iterator() do
			ply.Abnormalties_PhraseAmtToShow = nil
			ply.Abnormalties_Blood = 0
			ply.Abnormalties_Equalizers = 0
		end
	end)

	if(!PLUGIN.Randomized)then
		PLUGIN.RandomizeCharInfos()
	end

	hook.Add("PlayerSay", "Abnormalties", function(ply, text, team_chat)
		if(GetGlobalBool("AbnormaltiesEnabled", false) and IsValid(ply))then
			if(ply:Alive())then
				-- local id = data.userid
				-- local text = data.text
				-- local ply = Player(id)
				
				if(!ply.AbnormaltiesNextRequestStats or ply.AbnormaltiesNextRequestStats <= CurTime())then
					if(text == "/zoneabno")then
						if(ply.AbnormaltiesReady)then
							local knowledge = ply.AbnormaltiesKnowledge
							
							if(knowledge["instabillity"])then
								local found_zone = PLUGIN.DoWithinZones(ply:GetPos(), function(zone_id, zone)
								PLUGIN.ShowMessage(ply, [[

	Zone Points: ]] .. math.Round(zone.Points or 0) .. [[

	Zone Radius: ]] .. math.Round(zone.Radius or 0) .. [[
	
	Distance to centre: ]] .. math.Round(ply:GetPos():Distance(zone.Pos)) .. [[
	
	Zone Blood: ]] .. math.Round(zone.Blood or 0) .. [[
								]])
								end)
								
								if(!found_zone)then
									PLUGIN.ShowMessage(ply, "No zones found")
								end
							else
								PLUGIN.ShowMessage(ply, "Your words seem to fade into the nothingness")
							end
						else
							PLUGIN.LoadConsequences(ply)
						end
						
						ply.AbnormaltiesNextRequestStats = CurTime() + 2
						
						return nil --; return
					end
					
					if(text == "/myabno")then
						if(ply.AbnormaltiesReady)then
							local knowledge = ply.AbnormaltiesKnowledge
							
							if(knowledge["consequences"])then
								PLUGIN.ShowMessage(ply, [[

	Balance: ]] .. math.Round(PLUGIN.GetConsequences(ply) or 0) .. [[

	ABNO Blood: ]] .. math.Round(ply.Abnormalties_Blood or 0) .. [[

	ABNO Equalizers: ]] .. math.Round(ply.Abnormalties_Equalizers or 0) .. [[
								]])
							else
								PLUGIN.ShowMessage(ply, "Your words seem to fade into the nothingness")
							end
						else
							PLUGIN.LoadConsequences(ply)
						end
						
						ply.AbnormaltiesNextRequestStats = CurTime() + 2
						
						return nil --; return
					end
				end
				
				local cmd_find_phrase = "/findphrase"
				
				if(string.StartsWith(text, cmd_find_phrase))then
					if(!ply.AbnormaltiesNextFindPhrase or ply.AbnormaltiesNextFindPhrase <= CurTime())then
						if(ply.AbnormaltiesReady)then
							local knowledge = ply.AbnormaltiesKnowledge
							
							if(knowledge["insanity"])then
								local abnormalty_name = string.Trim(string.sub(text, #cmd_find_phrase + 1))
								local phrase, success = PLUGIN.FindValidPhrase(abnormalty_name, 40, "")
								
								PLUGIN.ShowMessage(ply, "Something whispers:")
								PLUGIN.ShowMessage(ply, phrase)
							else
								PLUGIN.ShowMessage(ply, "Your words seem to fade into the nothingness")
							end
						else
							PLUGIN.LoadConsequences(ply)
						end
						
						ply.AbnormaltiesNextFindPhrase = CurTime() + 10
						
						return nil --; return
					end
				end
				
				local abnormalty, uselessness = PLUGIN.AnalyseWordsAndAddToHotZone(text, ply:GetPos(), ply)
				ply.Abnormalties_RecentPhrase = ply.Abnormalties_RecentPhrase or text
				ply.Abnormalties_RecentPhraseAmt = (ply.Abnormalties_RecentPhraseAmt or 0) + 1
				
				if(ply.Abnormalties_RecentPhrase != text)then
					ply.Abnormalties_RecentPhrase = text
					ply.Abnormalties_RecentPhraseAmt = 0
				end
				
				ply.Abnormalties_PhraseAmtToShow = ply.Abnormalties_PhraseAmtToShow or 6
				
				if(ply.Abnormalties_RecentPhraseAmt == ply.Abnormalties_PhraseAmtToShow)then
					if(uselessness == 0)then
						PLUGIN.ShowTranslation(ply, abnormalty)
						
						ply.Abnormalties_PhraseAmtToShow = 2
					else
						PLUGIN.ShowMessage(ply, "There is no meaning in these letters...")
					end
				end
			end
		end
	end)

	hook.Add("HomigradDamage", "Abnormalties_Equalizers", function(ply, dmg, hitgroup, ent, harm)
		if(!ply.AbnormaltiesDoNotCountEqualizers)then
			if(!IsValid(ply.FakeRagdoll))then
				ply.Abnormalties_Equalizers = (ply.Abnormalties_Equalizers or 0) + dmg:GetDamage() * 1
			else
				ply.Abnormalties_Equalizers = (ply.Abnormalties_Equalizers or 0) + dmg:GetDamage() * 2
			end
		else
			ply.AbnormaltiesDoNotCountEqualizers = false
		end
		
		-- ply:ChatPrint(ply.Abnormalties_Equalizers)
	end)

	hook.Add("HG_BloodParticleStartedDropping", "Abnormalties", function(owner, org, wound, dir, artery)
		if(GetGlobalBool("AbnormaltiesEnabled", false) and IsValid(owner))then
			local ent = owner:IsPlayer() and IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
			local pos, ang = ent:GetBonePosition(ent:LookupBone(wound[4]))
			if not pos then return end
			local trace_data = {
				start = pos,
				endpos = pos + vector_up * (-1000),
				filter = {ent},
			}
			local trace = util.TraceLine(trace_data)
			
			ent.Abnormalties_LastBloodDropPos = ent.Abnormalties_LastBloodDropPos or trace.HitPos
			local additional_point = ent.Abnormalties_LastBloodDropPos:DistToSqr(trace.HitPos) / 300
			ent.Abnormalties_LastBloodDropPos = trace.HitPos
			
			-- PLUGIN.ShowMessageToAll(additional_point)
			
			if(artery)then
				PLUGIN.AddBloodToHotZones(trace.HitPos, 1 + additional_point)
			else
				PLUGIN.AddBloodToHotZones(trace.HitPos, 3 + additional_point)
			end
		end
	end)
--//