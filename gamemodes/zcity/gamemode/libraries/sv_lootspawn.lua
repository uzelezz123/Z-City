
--size (длина)
--10 biggest, 1 smallest
--можно использовать эти числа чтобы замедлять поиск
--и чем больше места тем больше может заспавнится вещей (и большие вещи)

local loot_boxes = {
    ["models/props_borealis/bluebarrel001.mdl"] = {8,"all"},
    ["models/props_c17/display_cooler01a.mdl"] = {8,"food",true},
    ["models/props_c17/FurnitureCupboard001a.mdl"] = {4,"instruments"},
    ["models/props_c17/FurnitureDrawer001a.mdl"] = {5,"instruments"},
    ["models/props_c17/FurnitureDrawer002a.mdl"] = {2,"instruments"},
    ["models/props_c17/FurnitureDrawer003a.mdl"] = {3,"instruments"},
    ["models/props_c17/FurnitureDresser001a.mdl"] = {10,"weapons"},
    ["models/props_c17/FurnitureFridge001a.mdl"] = {7,"food"},
    ["models/props_c17/furnitureStove001a.mdl"] = {4,"food"},
    ["models/props_c17/FurnitureWashingmachine001a.mdl"] = {6,"all"},
    ["models/props_c17/Lockers001a.mdl"] = {9,"weapons",true},
    ["models/props_c17/oildrum001.mdl"] = {8,"all"},
    ["models/props_combine/breendesk.mdl"] = {3,"instruments",true},
    ["models/props_interiors/VendingMachineSoda01a.mdl"] = {10,"food",true},
    ["models/props_interiors/Furniture_Desk01a.mdl"] = {4,"instruments"},
    ["models/props_junk/cardboard_box001a.mdl"] = {6,"all"},
    ["models/props_junk/cardboard_box001b.mdl"] = {6,"all"},
    ["models/props_junk/cardboard_box002a.mdl"] = {6,"all"},
    ["models/props_junk/cardboard_box002b.mdl"] = {6,"all"},
    ["models/props_junk/cardboard_box003a.mdl"] = {6,"all"},
    ["models/props_junk/cardboard_box003b.mdl"] = {6,"all"},
    ["models/props_junk/cardboard_box004a.mdl"] = {1,"all"},
    ["models/props_junk/TrashBin01a.mdl"] = {7,"trash"},
    ["models/props_trainstation/trashcan_indoor001a.mdl"] = {7,"trash"},
    ["models/props_junk/TrashDumpster01a.mdl"] = {10,"trash",true},
    ["models/props_junk/wood_crate001a.mdl"] = {8,"all"},
    ["models/props_junk/wood_crate001a_damaged.mdl"] = {8,"all"},
    ["models/props_junk/wood_crate002a.mdl"] = {8,"all"},
    ["models/props_lab/filecabinet02.mdl"] = {5,"instruments"},
    ["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {6,"instruments"},
    ["models/props_wasteland/controlroom_storagecloset001a.mdl"] = {10,"weapons"},
    ["models/props_wasteland/controlroom_storagecloset001b.mdl"] = {10,"weapons"},
    ["models/props_wasteland/kitchen_fridge001a.mdl"] = {10,"food",true},
    ["models/props_wasteland/kitchen_counter001c.mdl"] = {9,"food",true},
    ["models/props_c17/SuitCase001a.mdl"] = {3,"instruments"},
    ["models/props_c17/BriefCase001a.mdl"] = {2,"instruments"},
    ["models/props_interiors/Furniture_Vanity01a.mdl"] = {2,"instruments"},
    ["models/props/cs_office/Cardboard_box01.mdl"] = {4,"all"},
    ["models/props/cs_office/Cardboard_box02.mdl"] = {4,"all"},
    ["models/props/cs_office/Cardboard_box03.mdl"] = {4,"all"},
    ["models/props/cs_office/file_cabinet1.mdl"] = {6,"instruments"},
    ["models/props/cs_office/file_cabinet1_group.mdl"] = {8,"instruments",true},
    ["models/props/cs_office/file_cabinet3.mdl"] = {6,"instruments"},
    ["models/props/cs_office/file_cabinet2.mdl"] = {6,"instruments"},
    ["models/props/CS_militia/crate_extrasmallmill.mdl"] = {4,"instruments"},
    ["models/props/de_nuke/file_cabinet1_group.mdl"] = {8,"instruments",true},
    ["models/props/CS_militia/boxes_garage_lower.mdl"] = {10,"all",true},
    ["models/props/CS_militia/footlocker01_closed.mdl"] = {8,"all",true},
    ["models/props/CS_militia/toilet.mdl"] = {4,"all",true},
    ["models/props/CS_militia/crate_extralargemill.mdl"] = {10,"all",true},
    ["models/props/CS_militia/crate_stackmill.mdl"] = {10,"all",true},
    ["models/props/CS_militia/boxes_garage.mdl"] = {10,"all",true},
    ["models/props/CS_militia/boxes_frontroom.mdl"] = {10,"all",true},
    ["models/props/CS_militia/bar01.mdl"] = {10,"all",true},
    ["models/props/cs_assault/washer_box2.mdl"] = {8,"all"},
    ["models/props/cs_assault/washer_box.mdl"] = {8,"all",true},
    ["models/props/cs_assault/dryer_box2.mdl"] = {8,"all",true},
    ["models/props/cs_assault/dryer_box.mdl"] = {8,"all",true},
    ["models/props/cs_assault/box_stack2.mdl"] = {10,"all",true},
    ["models/props/cs_assault/box_stack1.mdl"] = {10,"all",true},
    ["models/props/cs_office/Crates_indoor.mdl"] = {10,"all",true},
    ["models/props/cs_office/Crates_outdoor.mdl"] = {10,"all",true},
    ["models/props_c17/woodbarrel001.mdl"] = {10,"all",true},
    ["models/props/de_inferno/wine_barrel.mdl"] = {10,"all",true},
    ["models/Items/item_item_crate_dynamic.mdl"] = {6,"weapons",true},
    ["models/Items/item_item_crate.mdl"] = {1,"weapons"},
	["models/props_junk/cardboard_box001a_present.mdl"] = {6,"all",true},
    ["models/props_junk/cardboard_box001b_present.mdl"] = {6,"all",true},
    ["models/props_junk/cardboard_box002a_present.mdl"] = {6,"all",true}, -- Кто нибудь сделайте просто проверку на существование данного пропа на карте...
    ["models/props_junk/cardboard_box002b_present.mdl"] = {6,"all",true},
    ["models/props_junk/cardboard_box003a_present.mdl"] = {6,"all",true},
    ["models/props_junk/cardboard_box003b_present.mdl"] = {6,"all",true},
    ["models/props_junk/cardboard_box004a_present.mdl"] = {6,"all",true},
    ["props_c17/woodbarrel001_gleb.mdl"] = {10,"all",true},
    ["models/props_junk/wood_crate001a_damaged.mdl"] = {8,"all"},
    ["models/props_c17/furnituredrawer001c.mdl"] = {5,"instruments"},
    ["models/props_c17/furnituredrawer001a.mdl"] = {5,"instruments"},
    ["models/props_junk/wood_crate001a_half.mdl"] = {4,"all"},
    ["models/props_junk/wood_crate002a_half.mdl"] = {4,"all"},
    ["models/props_junk/wood_crate003a.mdl"] = {8,"all"},
    ["models/props_lab/dogobject_wood_crate001a_damagedmax.mdl"] = {9,"all"},
    ["models/props_wasteland/kitchen_counter001c.mdl"] = {9,"food",true},
    ["models/props/cs_assault/dryer_box.mdl"] = {8,"all",true},
    ["models/props/cs_assault/dryer_box2.mdl"] = {8,"all",true},
    ["models/props/cs_assault/washer_box2.mdl"] = {8,"all",true},
    ["models/props/cs_assault/washer_box.mdl"] = {8,"all",true},
    ["models/props/CS_militia/microwave01.mdl"] = {4,"food",true},
    ["models/props/CS_militia/footlocker01_closed.mdl"] = {8,"all",true},
    ["models/props/CS_militia/stove01.mdl"] = {6,"food",true},
    ["models/props/cs_office/microwave.mdl"] = {4,"food",true},
    ["models/props/cs_office/trash_can.mdl"] = {6,"trash"},
    ["models/props/cs_office/file_cabinet2.mdl"] = {6,"instruments"},
    ["models/props/cs_office/file_cabinet3.mdl"] = {6,"instruments"},
    ["models/props/CS_militia/crate_extrasmallmill.mdl"] = {4,"instruments"},
    ["models/props/CS_militia/boxes_garage_lower.mdl"] = {8,"all",true},
    ["models/props/CS_militia/refrigerator01.mdl"] = {8,"food",true},
    ["models/props/de_nuke/crate_extrasmall.mdl"] = {4,"instruments"},
    ["models/props_wasteland/kitchen_stove001a.mdl"] = {7,"food",true},
    ["models/props_wasteland/kitchen_stove002a.mdl"] = {7,"food",true},
    ["models/props_interiors/furniture_cabinetdrawer02a.mdl"] = {4,"instruments"},
    ["models/props_interiors/furniture_cabinetdrawer01a.mdl"] = {4,"instruments"},
    ["models/props_c17/furniturecupboard001a.mdl"] = {5,"instruments"},
    ["models/weapons/w_suitcase_passenger.mdl"] = {3,"instruments"},
    ["models/props_junk/wood_crate001a_damagedmax.mdl"] = {8,"all"},
	["models/crate.mdl"] = {8,"all"},
}

--[[
	props_junk/cardboard_box001a_present.mdl
props_junk/cardboard_box001b_present.mdl
props_junk/cardboard_box002a_present.mdl
props_junk/cardboard_box002b_present.mdl
props_junk/cardboard_box003a_present.mdl
props_junk/cardboard_box003b_present.mdl
props_junk/cardboard_box004a_present.mdl

props_c17/woodbarrel001_gleb.mdl -- сами понимаете почему здесь...
]]


hg.props = {
	["models/props_c17/shelfunit01a.mdl"] = true,
	["models/props_c17/door01_left.mdl"] = true,
	["models/props_building_details/Storefront_Template001a_Bars.mdl"] = true,
	["models/props_borealis/borealis_door001a.mdl"] = true,
	["models/props_c17/canister01a.mdl"] = true,
	["models/props_c17/canister02a.mdl"] = true,
	["models/props_c17/concrete_barrier001a.mdl"] = true,
	["models/props_c17/FurnitureChair001a.mdl"] = true,
	["models/props_c17/FurnitureCouch001a.mdl"] = true,
	["models/props_c17/FurnitureCouch002a.mdl"] = true,
	["models/props_c17/FurnitureShelf001a.mdl"] = true,
	["models/props_junk/PlasticCrate01a.mdl"] = true,
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_c17/chair02a.mdl"] = true,
	["models/props_interiors/Furniture_chair01a.mdl"] = true,
	["models/props_interiors/Furniture_chair03a.mdl"] = true,
	["models/props_interiors/Furniture_Couch01a.mdl"] = true,
	["models/props_interiors/Furniture_Couch02a.mdl"] = true,
	["models/props_interiors/Furniture_Lamp01a.mdl"] = true,
	["models/props_interiors/pot01a.mdl"] = true,
	["models/props_interiors/pot02a.mdl"] = true,
	["models/props_interiors/refrigerator01a.mdl"] = true,
	["models/props_junk/CinderBlock01a.mdl"] = true,
	["models/props_junk/gascan001a.mdl"] = true,
	["models/props_junk/metal_paintcan001a.mdl"] = true,
	["models/props_junk/MetalBucket01a.mdl"] = true,
	["models/props_junk/MetalBucket02a.mdl"] = true,
	["models/props_junk/metalgascan.mdl"] = true,
	["models/props_junk/plasticbucket001a.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true,
	["models/props_junk/PropaneCanister001a.mdl"] = true,
	["models/props_junk/PushCart01a.mdl"] = true,
	["models/props_junk/sawblade001a.mdl"] = true,
	["models/props_junk/TrashBin01a.mdl"] = true,
	["models/props_junk/wood_pallet001a.mdl"] = true,
	["models/props_wasteland/controlroom_chair001a.mdl"] = true,
	["models/props_wasteland/controlroom_desk001b.mdl"] = true,
	["models/props_wasteland/kitchen_shelf002a.mdl"] = true,
	["models/props_wasteland/kitchen_shelf001a.mdl"] = true,
	["models/props_vehicles/carparts_door01a.mdl"] = true,
	["models/props_c17/metalPot001a.mdl"] = true,
	["models/props_c17/metalPot002a.mdl"] = true,
	["models/props_doors/door03_slotted_left.mdl"] = true,
	["models/props_interiors/VendingMachineSoda01a_door.mdl"] = true,
}

hg.loot_boxes = {}

for name, tbl in pairs(loot_boxes) do
	hg.loot_boxes[string.lower(name)] = tbl
end

local developer = GetConVar("developer")
function hg.GenerateLoot(ply,ent,func)
	local curRound, rtype = CurrentRound()
	
	local should = curRound.LootSpawn
	
	if not (should or (curRound.Lootables and IsValid(ent) and curRound.Lootables[ent:GetModel()])) then
		return
	end

	local traitor_opened = IsValid(ply) and ply.isTraitor
	local low_karma_player = IsValid(ply) and (ply.Karma < 70)
	local very_low_karma_player = IsValid(ply) and (ply.Karma < 30)
	local high_karma_player = IsValid(ply) and (ply.Karma >= zb.MaxKarma)
	local on_ground = not IsValid(ply)

	local time = CurTime() - (zb.ROUND_START or CurTime())
	--print(time)
	
	local mul = hook.Run("ZB_LootMultiplier", ply)

	if !mul then
		mul = traitor_opened and 1.5 or (very_low_karma_player and 0.25 or (low_karma_player and 0.5 or (high_karma_player and 1.25 or 1)))
	end

	if curRound.LootOnTime then
		local div = curRound.LootDivTime or 300
		mul = math.Rand(1, math.Clamp(mul * (time / div), 0.25, 1.75))
		if developer:GetBool() and IsValid(ply) then
			timer.Simple(0,function()
				ply:ChatPrint("sv_lootspawn: MUL = "..mul.." TIME/"..div.." = "..(time/div).." TIME = "..time)
			end)
		end
	end
	--[[
		Weapons
		Ammo
		Armor
		Attachments
		Money
	--]]

	local entName, AmmoCount, Tab
	
	Tab = "Weapons"
	
	//ply.Profession == "doctor"
	//ply.Profession == "engineer"
	//ply.Profession == "huntsman"
	//ply.Profession == "cook"
	
	local tab = curRound.GetLootTable and curRound:GetLootTable()
	
	if not tab then
		local cur = curRound.Type and curRound.Types[rtype] or curRound
		local chances = cur.LootTable or curRound.LootTable or zb.modes["hmcd"].LootTable
		local _, tabs = hg.WeightedRandomSelect(chances, mul)

		tab = tabs
		
		if curRound.name == "pathowogen" and time < 90 then
			tab = chances[1][2]
		end
	end

	--print(tab)

	local _, entName = hg.WeightedRandomSelect(tab)

	if hg.PluvTown.Active and (entName == "weapon_bigconsumable" or entName == "weapon_smallconsumable") then
		entName = "weapon_pluviska"
	end

	-- if curRound and curRound.name == "scrappers" and math.random(100) < 80 then
	-- 	local random = math.random(1, 3)
	-- 	if random > 1 then
	-- 		entName = "ent_scrappers_scrap"
	-- 		Tab = "Money"
			
	-- 		local random = math.random(100)

	-- 		local smallest = 100

	-- 		for k, v in pairs(hg.ScrapChances) do
	-- 			if random <= k and smallest > k then
	-- 				smallest = k
	-- 			end
	-- 		end

	-- 		AmmoCount = table.Random(hg.ScrapChances[smallest])
	-- 	end
	-- end
	
	if entName then
		if (entName == "*ammo*") or string.find(entName, "ent_ammo") then
			Tab = "Ammo"
			
			if !string.find(entName, "ent_ammo") then
				local ammo
				if IsValid(ply) and math.random(3) == 1 then
					for i, wep in RandomPairs(ply:GetWeapons()) do
						if wep:GetMaxClip1() > 0 and hg.ammotypeshuy[wep.Primary.Ammo] then
							ammo = hg.ammotypeshuy[wep.Primary.Ammo].name
							break
						end
					end
				end

				if not ammo then--если все еще не нашло патрон
					ammo = table.Random(hg.ammotypesallowed).name
				end

				if ammo then entName = "ent_ammo_" .. ammo end
				
				if ammo then
					AmmoCount = math.random(hg.ammoents[ammo].Count or 30)
				end
			else
				local tbl = hg.ammotypeshuy[string.Replace(entName, "ent_ammo_", "")]
				AmmoCount = math.random(tbl and hg.ammoents[tbl.name] and hg.ammoents[tbl.name].Count or 30)
			end
		elseif entName == "*attachments*" then
			local tbl = table.GetKeys(table.Random(hg.validattachments))
			local att = tbl[math.random(#tbl)]
			entName = "ent_att_" .. att
			Tab = "Attachments"
		elseif entName == "*sight*" then
			local tbl = table.GetKeys(hg.validattachments.sight)
			local att = tbl[math.random(#tbl)]
			entName = "ent_att_" .. att
			Tab = "Attachments"
		elseif entName == "*barrel*" then
			local tbl = table.GetKeys(hg.validattachments.barrel)
			local att = tbl[math.random(#tbl)]
			entName = "ent_att_" .. att
			Tab = "Attachments"
		end
		
		if not entName then return end
		if string.find(entName,"*") then return end

		if string.find(entName,"ent_armor_") then Tab = "Armor" end

		if func then
			return func(entName, AmmoCount, Tab)
		end
		
		return entName, AmmoCount, Tab
	end
end

local functions = {
    ["Weapons"] = function(ent, wep)
		local weapon = weapons.Get(wep)
		--if not weapon then return end
		if ent.inventory.Weapons and ent.inventory.Weapons[wep] then return end
        ent.inventory.Weapons = ent.inventory.Weapons or {}
		ent.inventory.Weapons[wep] = weapon and weapon.GetInfo and weapon:GetInfo() or true
		--hg.SetAttachment(ent.inventory.Weapons[wep][2],"supressor2",wep)
	end,
    ["Ammo"] = function(ent, ammo, amt)
		if not hg.ammotypes[ammo] then return end
		local ammo = isnumber(ammo) and ammo or game.GetAmmoID(hg.ammotypes[ammo].name)
		if not ammo or ammo == -1 then return end
		ent.inventory.Ammo = ent.inventory.Ammo or {}
		ent.inventory.Ammo[ammo] = ent.inventory.Ammo[ammo] or 0
		ent.inventory.Ammo[ammo] = ent.inventory.Ammo[ammo] + amt
    end,
    ["Armor"] = function(ent, armor)
		ent.armors = ent.armors or {}
		hg.AddArmor(ent, armor)
    end,
    ["Attachments"] = function(ent, att)
		ent.inventory.Attachments = ent.inventory.Attachments or {}
        ent.inventory.Attachments[#ent.inventory.Attachments + 1] = att
    end,
    -- ["Money"] = function(ent, HUY, amt)
    --     ent:SetNetVar("zb_Scrappers_RaidMoney", ent:GetNetVar("zb_Scrappers_RaidMoney", 0) + amt)
    -- end,
}

local functions_break = {
    ["Weapons"] = function(ent, wep)
        local weapon = weapons.Get(wep)
        if not weapon then return end

        local weapon = ents.Create(wep)
        weapon:Spawn()
        weapon:SetPos(ent:GetPos())
        weapon:SetAngles(ent:GetAngles())
		weapon.IsSpawned = true
		weapon.init = true

        if weapon.SetInfo then weapon:SetInfo(ent.inventory.Weapons[wep]) end
    end,
    ["Ammo"] = function(ent, ammo)
		local ammo = isnumber(ammo) and ammo or game.GetAmmoID(hg.ammotypes[ammo].name)
		local tp = hg.ammotypes[game.GetAmmoName(ammo)]
		if !tp then return end
		local ammo = tp.name
		local ent2 = ents.Create("ent_ammo_" .. ammo)
        ent2:Spawn()
        ent2:SetPos(ent:GetPos())
        ent2:SetAngles(ent:GetAngles())
		ent2.AmmoCount = ent.inventory.Ammo[ammo]
    end,
    ["Armor"] = function(ent, armor)
        local ent2 = ents.Create("ent_armor_" .. armor)
        ent2:Spawn()
        ent2:SetPos(ent:GetPos())
        ent2:SetAngles(ent:GetAngles())
    end,
    ["Attachments"] = function(ent, att)
        local ent2 = ents.Create("ent_att_" .. att)
		if !IsValid(ent2) then return end
        ent2:Spawn()
        ent2:SetPos(ent:GetPos())
        ent2:SetAngles(ent:GetAngles())
    end,
    -- ["Money"] = function(ent)
    --     local ent2 = ents.Create("ent_scrappers_scrap")
    --     ent2:Spawn()
    --     ent2:SetPos(ent:GetPos())
    --     ent2:SetAngles(ent:GetAngles())
    -- end,
}

hook.Add("ZB_InventoryChecked", "LootSpawn", function(ply, ent)
	ent:SetNetVar("Inventory", ent.inventory)
	if not IsValid(ent) or ent:IsPlayer() or ent.was_opened or not string.find(ent:GetClass(),"prop_") then return end
	if not hg.loot_boxes[string.lower(ent:GetModel())] then return end
	
	ent.armors = {}
	ent.inventory = {}

	ent.was_opened = true

	local chance = hg.loot_amount[hg.loot_boxes[string.lower(ent:GetModel())][1]] or {0,1}
	local amount = math.random(chance[1],chance[2])
	
	for i = 0,amount-1 do
		local entName, AmmoCount, Tab = hg.GenerateLoot(ply,ent)
		if entName then
			entName = string.Replace(entName,"ent_att_","")
			entName = string.Replace(entName,"ent_armor_","")
			entName = string.Replace(entName,"ent_ammo_","")
			functions[Tab](ent,entName,AmmoCount)
		end
	end

	ent:SetNetVar("Armor", ent.armors)
	ent:SetNetVar("Inventory", ent.inventory)
end)

hg.loot_amount = {
	[1] = {0,1},
	[2] = {0,1},
	[3] = {1,1},
	[4] = {1,1},
	[5] = {1,1},
	[6] = {1,2},
	[7] = {1,2},
	[8] = {2,3},
	[9] = {2,4},
	[10] = {2,5},
}

hook.Add("PropBreak", "LootSpawn", function(ply,ent)
	ent.inventory = ent.inventory or {}
	ent:SetNetVar("Inventory", ent.inventory)
	if not IsValid(ent) or ent:GetClass() ~= "prop_physics" then return end
	if not hg.loot_boxes[string.lower(ent:GetModel())] then return end
	
	hook.Run("ZB_InventoryChecked", ply, ent)

	for tab, tbl in pairs(ent.inventory) do
		for k,v in pairs(tbl) do
			functions_break[tab](ent, k)
		end
	end
end)

local vecHull = Vector(0, 0, 0)
local trCheck = {
	mask = MASK_SOLID,
	mins = -vecHull,
	maxs = vecHull,
}


local function MakeRandomSpawns(basepoints,iterations,maxiterations,tbl)
	if iterations >= maxiterations then return tbl end
	--я приготовил пельмени с говном вместо мяса
	iterations = iterations + 1

	local vecRand = VectorRand(-2048, 2048)
	vecRand[3] = math.random(8) == 1 and math.abs(vecRand[3]) / math.random(2) or 0
	--local trhitwall = util.QuickTrace(basepoints[math.random(#basepoints)],vecRand)

	-- local tr = util.QuickTrace(basepoints[math.random(#basepoints)] + vecRand,-vector_up * 256)

	local start = basepoints[math.random(#basepoints)] + vecRand

	local tr = util.TraceLine( {
		start = start,
		endpos = start + -vector_up * 256,
		mask = bit.bor(MASK_SOLID, MASK_WATER)
	} )
	
	if tr.Hit and not tr.HitSky and not tr.StartedSolid and not (tr.HitTexture == "**studio**" or tr.HitTexture == "**empty**" or tr.HitTexture == "TOOLS/TOOLSNODRAW") and not (tr.MatType == MAT_SLOSH) then
		
		local pos = tr.HitPos + vector_up * 16

		trCheck.start = tr.HitPos
		trCheck.endpos = tr.HitPos + vector_up * 36

		local tr2 = util.TraceLine(trCheck)
		
		if not tr2.Hit and not tr2.StartedSolid and not (tr2.HitTexture == "**studio**") then
			table.insert(basepoints,pos)
			table.insert(tbl,pos)
		end
	end
	
	return MakeRandomSpawns(basepoints,iterations,maxiterations,tbl)
end

local spawns = {}
local tbl = {}

--[[for i, ent in pairs(ents.FindByClass("info_*")) do
	table.insert(spawns, ent:GetPos())
end

local navmeshareas = navmesh.GetAllNavAreas()
for i, k in pairs(navmeshareas) do
	table.insert(spawns,k:GetCenter())
end

table.CopyFromTo(spawns,tbl)

local tbladd = MakeRandomSpawns(tbl,0,500,{})
local tblnew = zb.TranslateVectorsToPoints(tbladd)
table.CopyFromTo(tbladd,spawns)]]--

hook.Add( "InitPostEntity", "some_unique_name", function()
	spawns = {}
	for i, ent in pairs(ents.FindByClass("info_*")) do
		table.insert(spawns, ent:GetPos())
	end

	local navmeshareas = navmesh.GetAllNavAreas()
	for i, k in pairs(navmeshareas) do
		if k:IsUnderwater() then continue end

		table.insert(spawns,k:GetCenter())
	end

	tbl = {}
	table.CopyFromTo(spawns,tbl)

	local tbladd = MakeRandomSpawns(tbl,0,500,{})
	local tblnew = zb.TranslateVectorsToPoints(tbladd)
	table.CopyFromTo(tbladd,spawns)
end )
--zb.SendSpecificPointsToPly(Player(2), "RandomSpawns", true)

spawns = {}
for i, ent in pairs(ents.FindByClass("info_*")) do
	table.insert(spawns, ent:GetPos())
end

local navmeshareas = navmesh.GetAllNavAreas()
for i, k in pairs(navmeshareas) do
	if k:IsUnderwater() then continue end

	table.insert(spawns,k:GetCenter())
end

if #spawns > 0 then
	tbl = {}
	table.CopyFromTo(spawns,tbl)

	local tbladd = MakeRandomSpawns(tbl,0,500,{})
	local tblnew = zb.TranslateVectorsToPoints(tbladd)
		
	zb.SaveMapPoints( "RandomSpawns", tblnew )
	--zb.SendSpecificPointsToPly(Entity(1), "RandomSpawns", true)
	
	table.Add(spawns,tbladd)
end

local hook_Run = hook.Run
hook.Add("PostCleanupMap", "addboxs", function()
	if timer.Exists("SpawnTheBoxes") then timer.Remove("SpawnTheBoxes") end
	timer.Simple(.5,function()
		spawns = {}
		for i, ent in pairs(ents.FindByClass("info_*")) do
			table.insert(spawns, ent:GetPos())
		end
		
		local navmeshareas = navmesh.GetAllNavAreas()
		for i, k in pairs(navmeshareas) do
			if k:IsUnderwater() then continue end

			table.insert(spawns,k:GetCenter())
		end

		tbl = {}
		table.CopyFromTo(spawns,tbl)

		local tbladd = MakeRandomSpawns(tbl,0,500,{})
		local tblnew = zb.TranslateVectorsToPoints(tbladd)
			
		zb.SaveMapPoints( "RandomSpawns", tblnew )
		--zb.SendSpecificPointsToPly(Entity(1), "RandomSpawns", true)

		table.Add(spawns,tbladd)

		timer.Create("SpawnTheBoxes", 8, 0, function() hook_Run("Boxes Think") end)
	end)
end)

if timer.Exists("SpawnTheBoxes") then timer.Remove("SpawnTheBoxes") end
timer.Create("SpawnTheBoxes", 8, 0, function() hook_Run("Boxes Think") end)

local vec = Vector(0, 0, 64)
local vec_dist = Vector(500,500,500)
hook.Add("Boxes Think", "SpawnBoxes", function()
	if zb.ROUND_STATE ~= 1 or not CurrentRound().LootSpawn then return end
	//local spawnPos = table.Random(spawns) + vec

	//local spawnPos = zb:FurthestFromEveryone(spawns) + vec
	local tbl = player.GetAll()
	local ply = tbl[math.random(#tbl)]
	
	local vel = ply:GetVelocity() * math.random(1, 100) + VectorRand(-1024, 1024)
	vel[3] = 0

	local pos = ply:EyePos() 

	local tr = {}
	tr.start = pos
	tr.endpos = pos + vel
	tr.filter = ply
	tr.collisiongroup = COLLISION_GROUP_PLAYER
	local trace = util.TraceLine(tr)
	
	maxcount = 8
	while maxcount > 0 do
		maxcount = maxcount - 1
		local tr = {}
		tr.start = trace.HitPos - trace.Normal * 16
		local rand = VectorRand(-1024, 1024)
		tr.endpos = tr.start + rand
		tr.filter = ply
		tr.collisiongroup = COLLISION_GROUP_PLAYER

		trace = util.TraceLine(tr)
		trace = util.QuickTrace(trace.HitPos, -vector_up * 1024, ply)
	end

	local spawnPos = trace.HitPos + vector_up * 32 - trace.Normal * 10
	
	if not CurrentRound().noBoxes then
		for k, ply in ipairs(ents.FindInBox(spawnPos - vec_dist,spawnPos + vec_dist)) do
			if not ply:IsPlayer() then continue end
			if not ply:Alive() then continue end
			local tr = util.TraceLine({
				start = spawnPos,
				endpos = ply:EyePos(),
				mask = MASK_VISIBLE
			})
			if IsValid(tr.Entity) and tr.Entity == ply then
				--print("Fuck") 
				return
			end
		end
	end

	if (math.random(2) == 1) and not CurrentRound().noBoxes then

		/*if math.random(4) == 1 then
			local huy = ents.Create("prop_physics")
			huy:SetPos(spawnPos)
			local _, randprop = table.Random(hg.props)
			if not util.IsValidProp(randprop) then huy:Remove() return end
			huy:SetModel(randprop)
			huy:Spawn()
			return
		end*/

		local huy = ents.Create("prop_physics")
		huy:SetPos(spawnPos)
		local randprop
		for model, tbl in RandomPairs(math.random(6) == 1 and hg.props or hg.loot_boxes) do
			if !istable(tbl) or !tbl[3] then randprop = model break end
		end
		if not util.IsValidProp(randprop) then huy:Remove() return end
		huy:SetModel(randprop)
		local tr = {}
		tr.start = spawnPos
		tr.endpos = spawnPos
		tr.collisiongroup = COLLISION_GROUP_WORLD
		local trace = util.TraceEntity(tr, huy)
		
		if !trace.Hit then
			huy:Spawn()
		else
			huy:Remove()
		end

		--huy.stats = stats--длина и тип спавна лута (для рп дополнения...)
		return
	end

	local entName, AmmoCount, Tab = hg.GenerateLoot()
	//print(entName)
	if not entName or entName == "" then return end

	local huy = ents.Create(entName)
	if not IsValid(huy) then return end
	huy.IsSpawned = true
	huy:SetPos(spawnPos)
	huy:Spawn()
	huy.init = true

	if AmmoCount then
		huy.AmmoCount = AmmoCount
	end
end)
--[[
for i = 1,100 do
	local entName, AmmoCount, Tab = hg.GenerateLoot()

	if not entName or entName == "" then return end

	local huy = ents.Create(entName)
	if not IsValid(huy) then return end
	huy.IsSpawned = true
	huy:SetPos(table.Random(spawns) + vec)
	huy:Spawn()
	huy.init = true

	if AmmoCount then
		huy.AmmoCount = AmmoCount
	end
end--]]


