local MODE = MODE
MODE.name = "hmcd"
MODE.PrintName = "Homicide"

--\\
MODE.TraitorExpectedAmtBits = 13
--//

--\\Sub Roles
MODE.ConVarName_SubRole_Traitor_SOE = "hmcd_subrole_traitor_soe"
MODE.ConVarName_SubRole_Traitor = "hmcd_subrole_traitor"

if(CLIENT)then
	MODE.ConVar_SubRole_Traitor_SOE = CreateClientConVar(MODE.ConVarName_SubRole_Traitor_SOE, "traitor_custom", true, true, "Select traitor role in State of Emergency homicide mode")
	MODE.ConVar_SubRole_Traitor = CreateClientConVar(MODE.ConVarName_SubRole_Traitor, "traitor_custom", true, true, "Select murder role in Standard homicide modes")
end

--\\Loadout
local HeroWeaponData = {
	["weapon_px4beretta"] = {extraClips = 0},
	["weapon_glock17"] = {extraClips = 0},
	["weapon_hk_usp"] = {extraClips = 0},
	["weapon_remington870"] = {extraClips = 0, sling = true},
	["weapon_kar98"] = {extraClips = 0, sling = true},
	["weapon_vpo209"] = {extraClips = 0},
	["weapon_vpo136"] = {extraClips = 0},
	["weapon_mosin"] = {extraClips = 0, sling = true},
}

local HeroUpgradeData = {
	["hero_px4_silencer"] = {parent = "weapon_px4beretta", type = "attachment", attachment = "supressor4"},
	["hero_px4_ammo"] = {parent = "weapon_px4beretta", type = "ammo", extraClips = 1},
	["hero_glock_silencer"] = {parent = "weapon_glock17", type = "attachment", attachment = "supressor4"},
	["hero_glock_rmr"] = {parent = "weapon_glock17", type = "attachment", attachment = "holo16"},
	["hero_glock_laser"] = {parent = "weapon_glock17", type = "attachment", attachment = "laser3"},
	["hero_glock_ammo"] = {parent = "weapon_glock17", type = "ammo", extraClips = 1},
	["hero_usp_silencer"] = {parent = "weapon_hk_usp", type = "attachment", attachment = "supressor4"},
	["hero_usp_ammo"] = {parent = "weapon_hk_usp", type = "ammo", extraClips = 1},
	["hero_remington_sight"] = {parent = "weapon_remington870", type = "attachment", attachment = "holo16"},
	["hero_remington_ammo"] = {parent = "weapon_remington870", type = "ammo", extraClips = 1},
	["hero_kar98_scope"] = {parent = "weapon_kar98", type = "attachment", attachment = "optic12"},
	["hero_kar98_ammo"] = {parent = "weapon_kar98", type = "ammo", extraClips = 1},
	["hero_vpo209_silencer"] = {parent = "weapon_vpo209", type = "attachment", attachment = "supressor1"},
	["hero_vpo209_optic"] = {parent = "weapon_vpo209", type = "attachment", attachment = "holo16"},
	["hero_vpo209_ammo"] = {parent = "weapon_vpo209", type = "ammo", extraClips = 1},
	["hero_vpo136_silencer"] = {parent = "weapon_vpo136", type = "attachment", attachment = "supressor1"},
	["hero_vpo136_optic"] = {parent = "weapon_vpo136", type = "attachment", attachment = "holo16"},
	["hero_vpo136_ammo"] = {parent = "weapon_vpo136", type = "ammo", extraClips = 1},
	["hero_mosin_silencer"] = {parent = "weapon_mosin", type = "attachment", attachment = "supressor1"},
	["hero_mosin_scope"] = {parent = "weapon_mosin", type = "attachment", attachment = "optic12"},
	["hero_mosin_ammo"] = {parent = "weapon_mosin", type = "ammo", extraClips = 1},
}

local function ParseLoadoutString(dataStr)
	local loadout = {}
	if dataStr and dataStr ~= "" then
		local ok, parsed = pcall(util.JSONToTable, dataStr)
		if ok and istable(parsed) then
			loadout = parsed
		end
	end
	return loadout
end

local LegacyTraitorLoadout = {
	skillset = "none",
	weapons = {
		"weapon_p22",
		"weapon_p22_silencer",
		"weapon_buck200knife",
		"weapon_hg_rgd_tpik",
		"weapon_adrenaline",
		"weapon_hg_shuriken",
		"weapon_hg_smokenade_tpik",
		"weapon_traitor_ied",
		"weapon_traitor_poison1",
		"weapon_traitor_suit",
		"weapon_hg_jam",
		"weapon_walkie_talkie"
	}
}

local TraitorSkillsetSubRoles = {
	["infiltrator"] = "traitor_infiltrator",
	["assassin"] = "traitor_assasin",
	["chemist"] = "traitor_chemist",
}

local function ApplyTraitorLoadout(ply)
	local loadout = ParseLoadoutString(ply:GetInfo("hmcd_traitor_loadout"))
	local weaponsEmpty = not istable(loadout.weapons) or #loadout.weapons == 0
	if (not loadout.skillset and weaponsEmpty) or (loadout.skillset == "none" and weaponsEmpty) then loadout = LegacyTraitorLoadout end

	local skillset = loadout.skillset or "none"
	local weaponsList = loadout.weapons or {}
	ply.SubRole = TraitorSkillsetSubRoles[skillset] or ply.SubRole

	ply.organism.stamina.max = 220
	ply.organism.recoilmul = 1

	if skillset == "infiltrator" then
		-- Infiltrator specifics
	elseif skillset == "assassin" then
		ply.organism.recoilmul = 0.8
		ply.organism.stamina.max = 300
	elseif skillset == "chemist" then
		if CleanChemicalsOfPlayer then CleanChemicalsOfPlayer(ply) end
	end

	local inv = ply:GetNetVar("Inventory", {})
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_flashlight"] = true
	ply:SetNetVar("Inventory", inv)

	for _, wep in pairs(weaponsList) do
		if wep == "weapon_p22_silencer" then
			timer.Simple(0.5, function()
				if IsValid(ply) and ply:HasWeapon("weapon_p22") then
					local w = ply:GetWeapon("weapon_p22")
					if hg and hg.AddAttachmentForce then hg.AddAttachmentForce(ply, w, "supressor4") end
				end
			end)
		elseif wep == "weapon_pl15_silencer" then
			timer.Simple(0.5, function()
				if IsValid(ply) and ply:HasWeapon("weapon_pl15") then
					local w = ply:GetWeapon("weapon_pl15")
					if hg and hg.AddAttachmentForce then hg.AddAttachmentForce(ply, w, "supressor4") end
				end
			end)
		elseif wep == "weapon_p22_ammo" then
			timer.Simple(0.5, function()
				if IsValid(ply) and ply:HasWeapon("weapon_p22") then
					local w = ply:GetWeapon("weapon_p22")
					if IsValid(w) and w:GetPrimaryAmmoType() >= 0 then
						ply:GiveAmmo(w:GetMaxClip1(), w:GetPrimaryAmmoType(), true)
					end
				end
			end)
		else
			local w = ply:Give(wep)
			if wep == "weapon_zoraki" then
				timer.Simple(1, function() if IsValid(w) then w:ApplyAmmoChanges(2) end end)
			end
		end
	end
end

local function ApplyHeroLoadout(ply)
	local loadout = ParseLoadoutString(ply:GetInfo("hmcd_hero_loadout"))
	local weaponsList = istable(loadout.weapons) and loadout.weapons or {}
	local selectedWeapon = "weapon_px4beretta"

	for _, weaponId in ipairs(weaponsList) do
		if HeroWeaponData[weaponId] then
			selectedWeapon = weaponId
			break
		end
	end

	ply.organism.recoilmul = 1

	local inv = ply:GetNetVar("Inventory", {})
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_flashlight"] = true
	if HeroWeaponData[selectedWeapon] and HeroWeaponData[selectedWeapon].sling then
		inv["Weapons"]["hg_sling"] = true
	end
	ply:SetNetVar("Inventory", inv)

	local weapon = ply:Give(selectedWeapon)
	if not IsValid(weapon) then
		return
	end

	if weapon:GetPrimaryAmmoType() >= 0 then
		local baseInfo = HeroWeaponData[selectedWeapon]
		local baseClips = baseInfo and baseInfo.extraClips or 0
		if baseClips > 0 then
			ply:GiveAmmo(weapon:GetMaxClip1() * baseClips, weapon:GetPrimaryAmmoType(), true)
		end
	end

	local attachments = {}

	for _, weaponId in ipairs(weaponsList) do
		if weaponId == "weapon_walkie_talkie" then
			ply:Give("weapon_walkie_talkie")
			continue
		end

		if string.StartWith(weaponId, "ent_armor_") then
			if hg and hg.AddArmor then
				hg.AddArmor(ply, weaponId)
			end
			continue
		end

		local upgradeInfo = HeroUpgradeData[weaponId]
		if not upgradeInfo or upgradeInfo.parent ~= selectedWeapon then
			continue
		end

		if upgradeInfo.type == "ammo" then
			if weapon:GetPrimaryAmmoType() >= 0 then
				ply:GiveAmmo(upgradeInfo.amount or weapon:GetMaxClip1() * (upgradeInfo.extraClips or 0), weapon:GetPrimaryAmmoType(), true)
			end
		elseif upgradeInfo.type == "attachment" and upgradeInfo.attachment then
			attachments[#attachments + 1] = upgradeInfo.attachment
		end
	end

	if #attachments > 0 then
		timer.Simple(0.5, function()
			if not IsValid(ply) or not ply:HasWeapon(selectedWeapon) then
				return
			end
			local activeWeapon = ply:GetWeapon(selectedWeapon)
			if not IsValid(activeWeapon) then
				return
			end
			for _, attachmentId in ipairs(attachments) do
				if hg and hg.AddAttachmentForce then
					hg.AddAttachmentForce(ply, activeWeapon, attachmentId)
				end
			end
		end)
	end
end

MODE.ApplyTraitorLoadout = ApplyTraitorLoadout
MODE.ApplyHeroLoadout = ApplyHeroLoadout
--//

--; TODO
--; Инженер - шахид бомба + иеды

MODE.SubRoles = {
	--=\\Traitor
	--==\\
	--; https://youtu.be/zP7ux8WsYYI?si=S-Uw2EAehGR5WD3D
	["traitor_custom"] = {
		Name = "Loadout",
		Description = [[You are the custom traitor.
Your abilities and loadout are based on your selected preset or loadout.]],
		Objective = "Use your loadout to murder everyone here.",
		SpawnFunction = function(ply)
			ApplyTraitorLoadout(ply)
		end,
	},
	["traitor_default"] = {
		Name = "Defoko",
		Description = [[Default.
You've prepared for a long time.
You are equipped with various weapons, poisons and explosives, grenades and your favourite heavy duty knife and a zoraki signal pistol to help you kill.]],
		Objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		SpawnFunction = function(ply)
			local wep = ply:Give("weapon_zoraki")
			
			timer.Simple(1, function()
				wep:ApplyAmmoChanges(2)
			end)
			
			ply:Give("weapon_buck200knife")	
			ply:Give("weapon_hg_rgd_tpik")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_shuriken")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_suit")
			ply:Give("weapon_hg_jam")
			-- ply:Give("weapon_traitor_poison2")
			-- ply:Give("weapon_traitor_poison3")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_default_soe"] = {
		Name = "Defoko",
		Description = [[Default.
You've prepared a long time for this moment.
You are equipped with various weapons, poisons and explosives, grenades and your favourite heavy duty knife and silenced pistol with an additional mag to help you kill.]],
		Objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		SpawnFunction = function(ply)
			if not IsValid(ply) then return end
			local p22 = ply:Give("weapon_p22")
			if not IsValid(p22) then return end
			ply:GiveAmmo(p22:GetMaxClip1() * 1, p22:GetPrimaryAmmoType(), true)
			
			hg.AddAttachmentForce(ply, p22, "supressor4")
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory",inv)
		end,
	},
	--==//
	
	--==\\
	["traitor_infiltrator"] = {
		Name = "Infiltrator",
		Description = [[Can break people's necks from behind.
Can completely disguise as other players if they're in ragdoll.
Has no weapons or tools except knife, epipen and smoke grenade.
For people who like to play chess.]],
		Objective = "You're an expert in diversion. Be discreet and kill one by one",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_infiltrator_soe"] = {
		Name = "Infiltrator",
		Description = [[Can break people's necks from behind.
Can completely disguise as other players if they're in ragdoll.
Has smoke grenade, walkie-talkie, knife, taser with 2 additional shooting heads and epipen.
For people who like to play chess.]],
		Objective = "You're an expert in diversion. Be discreet and kill one by one",
		SpawnFunction = function(ply)
			local taser = ply:Give("weapon_taser")
			
			ply:GiveAmmo(taser:GetMaxClip1() * 2, taser:GetPrimaryAmmoType(), true)
			ply:Give("weapon_sogknife")
			-- ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	--==//
	
	--==\\
	--; СДЕЛАТЬ ЕМУ ЛУТ ДРУГИХ ИГРОКОВ ДАЖЕ ПОКА У НИХ НЕТ ПУШКИ В РУКАХ
	--; Сделать ему вырубание по вагус нерву
	["traitor_assasin"] = {
		Name = "Assasin",
		Description = [[Can quickly disarm people from any angle.
Disarms faster from behind.
Disarms faster from front if the victim is in ragdoll.
Proficient in shooting from guns.
Has additional stamina (+ 80 units compared to other traitors).
Equipped with walkie-talkie.
For people who like to play checkers.]],
		Objective = "You're an expert in guns and in disarmament. Disarm gunman and use his weapon against others",
		SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")	
			-- ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.8
			ply.organism.stamina.max = 300
			--local inv = ply:GetNetVar("Inventory", {}) // WHY SOMEONE COMMENTED THIS
			--inv["Weapons"]["hg_flashlight"] = true
			
			--ply:SetNetVar("Inventory", inv) // BUT NOT THIS???
		end,
	},
	["traitor_assasin_soe"] = {
		Name = "Assasin",
		Description = [[Can quickly disarm people from any angle.
Disarms faster from behind.
Disarms faster from front if the victim is in ragdoll.
Proficient in shooting from guns.
Has additional stamina (+ 80 units compared to other traitors).
Equipped with walkie-talkie, knife, epipen and flashlight.
For people who like to play checkers.]],
		Objective = "You're an expert in guns and in disarmament. Disarm gunman and use his weapon against others",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_walkie_talkie")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.4
			ply.organism.stamina.max = 300
			--local inv = ply:GetNetVar("Inventory", {}) // WHY SOMEONE COMMENTED THIS
			--inv["Weapons"]["hg_flashlight"] = true
			
			--ply:SetNetVar("Inventory", inv) // BUT NOT THIS???
		end,
	},
	--==//
	
	--==\\
	["traitor_chemist"] = {
		Name = "Chemist",
		Description = [[Has multiple chemical agents and epipen and knife.
Resistant to a certain degree to all chemical agents mentioned.
Can detect presence and potency of chemical agents in the air.]],
		Objective = "You're a chemist who decided to use his knowledge to hurt others. Poison everything.",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			ply:Give("weapon_traitor_poison4")
			ply:Give("weapon_traitor_poison_consumable")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
			CleanChemicalsOfPlayer(ply)
		end,
	},
	--==//
	-- ["traitor_demoman"] = {
		-- Name = "Demoman",
		-- Description = [[Has many explosives.
-- Can rig certain items with bombs
-- (Radio, certain consumables, etc.)]],
		-- Objective = "You're the ultimate chemist who decided to use knowledge to hurt others.",
		-- SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")
			-- ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_hg_pipebomb_tpik")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_traitor_ied")
			-- ply:Give("weapon_walkie_talkie")
			
			-- ply.organism.stamina.max = 220
			-- local inv = ply:GetNetVar("Inventory", {})
			-- inv["Weapons"]["hg_flashlight"] = true
			
			-- ply:SetNetVar("Inventory", inv)
		-- end,
	-- },
	["traitor_zombie"] = {
		Name = "Zombie",
		Description = [[Can infect other players silently.
Infected players can be cured by a doctor.
If all players are cured zombie will lose.
Instead of dying will be randomly transported to another infected player's body.
Has no weapons or any tools.
Despite being zombie, still bears appearance of a normal human.]],
		Objective = "You're the zombie. Infect everyone to win. Avoid doctor.",
		SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")	
			-- ply:Give("weapon_adrenaline")
			
			-- ply.organism.stamina.max = 220
			-- local inv = ply:GetNetVar("Inventory", {})
			-- inv["Weapons"]["hg_flashlight"] = true
			
			-- ply:SetNetVar("Inventory", inv)
		end,
	},
	--=//
}
--//

--\\Professions
MODE.ProfessionsRoundTypes = {
	["standard"] = true,
	["soe"] = true,
}

MODE.Professions = {
	["doctor"] = {
		Name = "Doctor",
		SpawnFunction = function(ply)	--; TODO MAKE IT WORK
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["huntsman"] = {
		Name = "Huntsman",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["engineer"] = {
		Name = "Engineer",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["cook"] = {
		Name = "Cook",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["builder"] = {
		Name = "Builder",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
}
--//

--\\
--; Названия перменных чуть чуть конченные получились, нужно будет подумать как улучшить
--; ужас
MODE.FadeScreenTime = 1.5
MODE.DefaultRoundStartTime = 6
MODE.RoleChooseRoundStartTime = 10

MODE.RoleChooseRoundTypes = {
	["standard"] = {
		TraitorDefaultRole = "traitor_custom",
		Traitor = {
			["traitor_custom"] = true,
			["traitor_default"] = true,
			["traitor_infiltrator"] = true,
			["traitor_chemist"] = true,
			["traitor_assasin"] = true,
			--; ОБЪЕДЕНИТЬ ХИМИКА И ДИВЕРСАНТА!!! наверное
			-- ["traitor_demoman"] = true,
		},
		Professions = {
			["doctor"] = {
				Chance = 1,
			},
			["huntsman"] = {
				Chance = 1,
			},
			["engineer"] = {
				Chance = 1,
			},
			["cook"] = {
				Chance = 1,
			},
			["builder"] = {
				Chance = 1,
			},
		},
	},
	["soe"] = {
		TraitorDefaultRole = "traitor_custom",
		Traitor = {
			["traitor_custom"] = true,
			["traitor_default_soe"] = true,
			["traitor_infiltrator_soe"] = true,
			-- ["traitor_chemist_soe"] = true,
			["traitor_assasin_soe"] = true,
			-- ["traitor_demoman_soe"] = true,
		},
		Professions = {
			["doctor"] = {
				Chance = 1,
			},
			["huntsman"] = {
				Chance = 1,
			},
			["engineer"] = {
				Chance = 1,
			},
			["cook"] = {
				Chance = 1,
			},
		},
	},
}
--//

MODE.Roles = {}
MODE.Roles.soe = {
	traitor = {
		name = "Traitor",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Innocent",
		color = Color(158,0,190)
	},

	innocent = {
		name = "Innocent",
		color = Color(0,120,190)
	},
}

MODE.Roles.standard = {
	traitor = {
		objective = "You've been preparing for this for a long time. Kill everyone.",
		name = "Murderer",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Bystander",
		color = Color(158,0,190)
	},

	innocent = {
		name = "Bystander",
		color = Color(0,120,190)
	},
}

MODE.Roles.wildwest = {
	traitor = {
		objective = "You've been preparing for this for a long time. Kill everyone.",
		name = "Murderer",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Bystander",
		color = Color(159,85,0)
	},

	innocent = {
		name = "Bystander",
		color = Color(159,85,0)
	},
}

MODE.Roles.gunfreezone = {
	traitor = {
		name = "Murderer",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Innocent",
		color = Color(0,120,190)
	},

	innocent = {
		name = "Innocent",
		color = Color(0,120,190)
	},
}

MODE.Roles.supermario = {
	traitor = {
		objective = "You're the evil Mario! Jump around and take down everyone.",
		name = "Traitor Mario",
		color = Color(190,0,0)
	},

	gunner = {
		objective = "You're the hero Mario! Use your jumping ability to stop the traitor.",
		name = "Hero Mario",
		color = Color(158,0,190)
	},

	innocent = {
		objective = "You're a bystander Mario, survive and avoid the traitor's traps!",
		name = "Innocent Mario",
		color = Color(0,120,190)
	},
}

function MODE.GetPlayerTraceToOther(ply, aim_vector, dist)
	local trace = hg.eyeTrace(ply, dist, nil, aim_vector)
	
	if(trace)then
		local aim_ent = trace.Entity
		local other_ply = nil
		
		if(IsValid(aim_ent))then
			if(aim_ent:IsPlayer())then
				other_ply = aim_ent
			elseif(aim_ent:IsRagdoll())then
				if(IsValid(aim_ent.ply))then
					other_ply = aim_ent.ply
				end
			end
		end
		
		return aim_ent, other_ply, trace
	else
		return nil
	end
end