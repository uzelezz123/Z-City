local CurTime, timer, math, table, Angle, Vector, IsValid, LerpAngle, LerpVector = CurTime, timer, math, table, Angle, Vector, IsValid, LerpAngle, LerpVector
local math_random, math_Rand = math.random, math.Rand

--\\ Lootable npcs
	local lootNPCs = { --// Loot goes here (you need to add npc here to enable NPC organism functionality)
		["npc_metropolice"] = {
			"weapon_hg_stunstick",
			"weapon_medkit_sh",
			"weapon_bandage_sh",
			"weapon_handcuffs",
			"weapon_walkie_talkie"
		},
		["npc_combine_s"] = {
			"weapon_melee",
			"weapon_hg_hl2nade_tpik",
			"weapon_bandage_sh",
			"weapon_handcuffs"
		},
		["npc_citizen"] = {
			"weapon_smallconsumable",
			"weapon_bandage_sh",
			"weapon_painkillers"
		}
	}

	local funcspawnNPCs = { --// Custom on NPC spawn function goes here
		["npc_combine_s"] = function(ent)
			ent.organism.CantCheckPulse = true

			--// Armor
			ent.armors = {}
			ent.armors["torso"] = "cmb_armor"
			ent.armors["head"] = "cmb_helmet"
			ent:SyncArmor()
		end,
		["npc_metropolice"] = function(ent)
			--// Armor
			ent.armors = {}
			ent.armors["torso"] = "metrocop_armor"
			ent.armors["head"] = "metrocop_helmet"
			ent:SyncArmor()
		end
	}

	local nameNPCs = { --// NPC name and color goes here (visible while looking at & while looting)
		["npc_metropolice"] = {"Metrocop", Vector(0, 100, 255) / 255},
		["npc_combine_s"] = {"Combine", Vector(0, 180, 180) / 255},
		["npc_citizen"] = {"Refugee", Vector(255, 155, 0) / 255}
	}

	local hg_organismnpcs = CreateConVar("hg_organismnpcs", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "NPCs will have organism system like the players", 0, 1)
	hook.Add("OnEntityCreated", "npcorg", function(ent)
		if !hg_organismnpcs:GetBool() then return end
		if not IsValid(ent) then return end

		local class = ent:GetClass()
		if ent:IsNPC() and lootNPCs[class] then
			hg.organism.Add(ent)
			hg.organism.Clear(ent.organism)
			ent.organism.fakePlayer = true

			if funcspawnNPCs[class] then
				funcspawnNPCs[class](ent)
			end

			if nameNPCs[class] then
				ent:SetNWString("PlayerName", nameNPCs[class][1])
				ent:SetNWVector("PlayerColor", nameNPCs[class][2])
				ent.GetPlayerName = function()
					return nameNPCs[class][1]
				end
			end
		end
	end)

	--[[hook.Add("EntityTakeDamage", "npcdmg", function(ent, dmgInfo)
		if ent:IsNPC() then
			hg.organism.AddWound(ent, tr, bone, dmgInfo, dmgPos, hook_info.bleed, inputHole, outputHole)
		end
	end)--]]

	hook.Add("CreateEntityRagdoll", "npcloot", function(ent, rag)
		local loot = lootNPCs[ent:GetClass()]

		rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		if IsValid(ent) and IsValid(rag) and ent:IsNPC() and loot then
			rag.inventory = {}
			rag.inventory.Weapons = {}
		
			if ent.organism then
				local newOrg = hg.organism.Add(rag)
				table.Merge(newOrg, ent.organism)
		
				hook.Run("RagdollDeath", ent, rag)
		
				table.Merge(zb.net.list[rag], zb.net.list[ent])
		
				newOrg.alive = false
				newOrg.owner = rag
				rag:CallOnRemove("organism", hg.organism.Remove, rag)
				newOrg.owner.fullsend = true
				hg.send_bareinfo(newOrg)
			
				ent.organism = nil
			end

			rag.armors = ent.armors
			
			for k, wep in pairs(loot) do
				local weapon = weapons.Get(wep)
				if rag.inventory.Weapons and rag.inventory.Weapons[wep] then return end
				rag.inventory.Weapons = rag.inventory.Weapons or {}
				rag.inventory.Weapons[wep] = weapon and weapon.GetInfo and weapon:GetInfo() or true
				rag:SetNetVar("Inventory", rag.inventory)
			end
		end
	end)
--//

--\\ Force enable npc serverside ragdolls
	RunConsoleCommand("ai_serverragdolls", "1")
--//

--\\ Extract bugbait from dead antlion guards
	hook.Add("PlayerUse", "extractbugbait", function(ply, ent)
		if IsValid(ent) and ent:GetClass() == "prop_ragdoll" and ent:GetModel() == "models/antlion_guard.mdl" then
			if not ent.bugbait then
				ent.bugbait = true

				local bugbait = ply:Give("weapon_hg_bugbait")
				ply:SelectWeapon(bugbait)
				ent:EmitSound("npc/barnacle/barnacle_pull2.wav", 80, math_random(90, 110))
			end
		end
	end)
--//

--\\ Zombies & barnacles twitching (inspired by workshop addon)
	local ZT_Scale = 0.7

	local zombieClasses = {
		"npc_zombie",
		"npc_zombine",
		"npc_zombie_torso",
		"npc_fastzombie",
		"npc_fastzombie_torso",
		"npc_poisonzombie"
	}
	local headcrabClasses = {
		"npc_headcrab",
		"npc_headcrab_fast",
		"npc_headcrab_black"
	}
	local barnacleClass = "npc_barnacle"

	local function lerpSmoothDiv(startValue, endValue, progress)
		return startValue + (endValue - startValue) * progress
	end

	local hg_zombtwitching = CreateConVar("hg_zombtwitching", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Zombies & barnacle will twitch and deformate", 0, 1)
	local function applySmoothLerp(npc, boneID, startAngles, endAngles, startPosition, endPosition, startScale, endScale, duration)
		local startTime = CurTime()
		if not IsValid(npc) then return end

		timer.Create("SmoothLerp_" .. npc:EntIndex() .. "_" .. boneID, 0.02, math.ceil(duration / 0.02), function()
			if not IsValid(npc) then
				timer.Remove("SmoothLerp_" .. npc:EntIndex() .. "_" .. boneID)
				return
			end

			local elapsedTime = CurTime() - startTime
			local progress = math.Clamp(elapsedTime / duration, 0, 1)

			local currentAngles = LerpAngle(progress, startAngles, endAngles)
			local currentPosition = LerpVector(progress, startPosition, endPosition)
			local currentScale = Vector(
				lerpSmoothDiv(startScale.x, endScale.x, progress),
				lerpSmoothDiv(startScale.y, endScale.y, progress),
				lerpSmoothDiv(startScale.z, endScale.z, progress)
			)

			npc:ManipulateBoneAngles(boneID, currentAngles)
			npc:ManipulateBonePosition(boneID, currentPosition)
			npc:ManipulateBoneScale(boneID, currentScale)

			if progress == 0 then
				timer.Remove("SmoothLerp_" .. npc:EntIndex() .. "_" .. boneID)
			end
		end)
	end

	local vector_1 = Vector(1, 1, 1)
	local function applyTwitchEffect(npc, params)
		if not IsValid(npc) then return end

		local bonesToModify = math_random(3)
		for _ = 1, bonesToModify do
			local boneID = math_random(0, npc:GetBoneCount() - 1)
			if boneID == 0 then continue end

			local startAngles = npc:GetManipulateBoneAngles(boneID) or angle_zero
			local endAngles = startAngles + Angle(
				math_Rand(-params.twitchRotRange, params.twitchRotRange),
				math_Rand(-params.twitchRotRange, params.twitchRotRange),
				math_Rand(-params.twitchRotRange, params.twitchRotRange)
			) * ZT_Scale

			local startPosition = npc:GetManipulateBonePosition(boneID) or vector_origin
			local endPosition = startPosition + Vector(
				math_Rand(-params.twitchOffsetRange, params.twitchOffsetRange),
				math_Rand(-params.twitchOffsetRange, params.twitchOffsetRange),
				math_Rand(0, params.twitchOffsetRange)
			) * ZT_Scale

			local startScale = npc:GetManipulateBoneScale(boneID) or vector_1
			local endScale = startScale + Vector(
				math_Rand(-params.twitchScaleRange, params.twitchScaleRange),
				math_Rand(-params.twitchScaleRange, params.twitchScaleRange),
				math_Rand(-params.twitchScaleRange, params.twitchScaleRange)
			) * ZT_Scale * 0.95

			local duration = math_Rand(0.5, 2)
			applySmoothLerp(npc, boneID, startAngles, endAngles, startPosition, endPosition, startScale, endScale, duration)
		end
	end

	local function applyBoneModifications(npc, params)
		if not IsValid(npc) then return end

		for boneID = 0, npc:GetBoneCount() - 1 do
			if boneID == 0 then continue end

			if math_Rand(0, 1) > 0.2 then continue end

			local targetAngles = Angle(
				math_Rand(-params.rotRange, params.rotRange),
				math_Rand(-params.rotRange, params.rotRange),
				math_Rand(-params.rotRange, params.rotRange)
			) * ZT_Scale
			local targetPosition = Vector(
				math_Rand(-params.offsetRange, params.offsetRange),
				math_Rand(-params.offsetRange, params.offsetRange),
				math_Rand(0, params.offsetRange)
			) * ZT_Scale
			local targetScale = Vector(
				1 + math_Rand(-params.scaleRange, params.scaleRange),
				1 + math_Rand(-params.scaleRange, params.scaleRange),
				1 + math_Rand(-params.scaleRange, params.scaleRange)
			) * ZT_Scale

			npc:ManipulateBoneAngles(boneID, targetAngles)
			npc:ManipulateBonePosition(boneID, targetPosition)
			npc:ManipulateBoneScale(boneID, targetScale)
		end
	end

	local function handleNPCSpawn(npc)
		if not IsValid(npc) then return end
		local class = npc:GetClass()

		local params = {}
		if table.HasValue(zombieClasses, class) then
			params = {
				rotRange = 15,
				scaleRange = 0.04,
				offsetRange = 2,
				twitchRotRange = 10,
				twitchOffsetRange = 0.5,
				twitchScaleRange = 0.02
			}
		elseif table.HasValue(headcrabClasses, class) then
			params = {
				rotRange = 12,
				scaleRange = 0.03,
				offsetRange = 1.5,
				twitchRotRange = 8,
				twitchOffsetRange = 0.3,
				twitchScaleRange = 0.01
			}
		elseif class == barnacleClass then
			params = {
				rotRange = 10,
				scaleRange = 0.02,
				offsetRange = 1,
				twitchRotRange = 6,
				twitchOffsetRange = 0.2,
				twitchScaleRange = 0.005
			}
		else
			return
		end

		applyBoneModifications(npc, params)
		applyTwitchEffect(npc, params)

		timer.Create("ZombTwitch_" .. npc:EntIndex(), math_random(12) / 4, 0, function()
			if not IsValid(npc) or not hg_zombtwitching:GetBool() then
				timer.Remove("ZombTwitch_" .. npc:EntIndex())
				return
			end

			applyTwitchEffect(npc, params)
		end)
	end

	hook.Add("OnEntityCreated", "ZombTwitch", function(ent)
		if IsValid(ent) and ent:IsNPC() and hg_zombtwitching:GetBool() then
			timer.Simple(0, function()
				handleNPCSpawn(ent)
			end)
		end
	end)
--\\

--\\ Tough NPCs
	local hg_toughnpcs = CreateConVar("hg_toughnpcs", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Toggle more health for npcs", 0, 1)
	local npcToBuff = {
		["npc_metropolice"] = 100,
		["npc_combine_s"] = 150,
		["npc_citizen"] = 100,
		["npc_kleiner"] = 100,
		["npc_magnusson"] = 100,
		["npc_eli"] = 100,
		["npc_odessa"] = 100,
		["npc_breen"] = 100,
		["npc_zombie"] = 120,
		["npc_fastzombie"] = 90,
		["npc_headcrab"] = 50,
		["npc_headcrab_fast"] = 40,
		["npc_headcrab_black"] = 70,
		["npc_fastzombie_torso"] = 80,
		["npc_zombie_torso"] = 110,
		["npc_manhack"] = 50,
		["npc_antlion_grub"] = 20,
	}
	hook.Add("OnEntityCreated", "toughnpcs", function(ent)
		timer.Simple(0.2, function()
			if hg_toughnpcs:GetBool() and IsValid(ent) and ent:IsNPC() and npcToBuff[ent:GetClass()] then
				ent:SetHealth(npcToBuff[ent:GetClass()])
				ent:SetMaxHealth(npcToBuff[ent:GetClass()])
				ent:SetPlaybackRate(2)
				ent:SetKeyValue("m_flPlaybackSpeed", 2)
			end
		end)
	end)
--//

--\\ Fall damage for NPCs
	local vecforce = Vector(5000, 5000, -30000)
	hook.Add("Think", "NPCFallDamageTracker", function()
		if not hg_organismnpcs:GetBool() then return end
		for _, npc in ipairs(ents.GetAll()) do
			if not IsValid(npc) then continue end
			if not npc:IsNPC() or not lootNPCs[npc:GetClass()] then continue end

			local zPos = npc:GetPos().z
			if npc:IsOnGround() then
				if npc.falling then
					local fallVel = (npc.topZ - zPos) / 39.37
					if fallVel > 0 then
						if fallVel >= 10 then
							local world = IsValid(game.GetWorld()) and game.GetWorld() or npc

							local d = DamageInfo()
							d:SetDamage(fallVel * fallVel)
							d:SetDamageForce(vecforce)
							d:SetDamageType(DMG_FALL)
							d:SetAttacker(world)
							d:SetInflictor(world)

							npc:TakeDamageInfo(d)
							if fallVel >= 30 then
								npc:EmitSound("player/pl_pain"..math_random(5, 7)..".wav", 75, math_random(95, 105))
							end
							npc:EmitSound(math_random() == 2 and "player/pl_fallpain1.wav" or "player/pl_fallpain3.wav", 75, math_random(95, 105))
						end

						npc.falling = false
					end
				end
			else
				if not npc.falling then
					npc.falling = true
					npc.topZ = zPos
				elseif npc:GetPos().z > npc.topZ then
					npc.topZ = zPos
				end
			end
		end
	end)
--//