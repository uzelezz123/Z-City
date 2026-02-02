local MODE = MODE

zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.HMCD_TDM_CT = zb.Points.HMCD_TDM_CT or {}
zb.Points.HMCD_TDM_CT.Color = Color(0,0,150)
zb.Points.HMCD_TDM_CT.Name = "HMCD_TDM_CT"

zb.Points.HMCD_TDM_T = zb.Points.HMCD_TDM_T or {}
zb.Points.HMCD_TDM_T.Color = Color(150,95,0)
zb.Points.HMCD_TDM_T.Name = "HMCD_TDM_T"

MODE.PrintName = "Team Deathmatch"

--[[
    ["weapon_hk_usp"] = {
        Type = "Weapon",
        Price = "600",
        Category = "Pistols",
        Attachments = {
            "supressor3", "supressor4"
        }
    },
]]

MODE.BuyItems = {}

local priority = 1
local function AddItemToBUY(ItemName, Type, ItemClass, Price, Category, Attachments, Amount, TeamBased)
    if not MODE.BuyItems[Category] then
        MODE.BuyItems[Category] = {}
        MODE.BuyItems[Category].Priority = priority
        priority = priority + 1
    end

    MODE.BuyItems[Category][ItemName] = {
        Type = Type,
        ItemClass = ItemClass,
        Price = Price,
        Category = Category,
        Attachments = Attachments,
        Amount = Amount,
        TeamBased = TeamBased,
    }
end
-- Weapons
AddItemToBUY( "HK-USP", "Weapon", "weapon_hk_usp", 500, "Pistols", {"supressor3", "supressor4"} )
AddItemToBUY( "Glock-17", "Weapon", "weapon_glock17", 550, "Pistols", {"supressor4", "holo16", "laser3", "laser1"} )
AddItemToBUY( "Glock-18C", "Weapon", "weapon_glock18c", 1400, "Pistols", {"supressor4", "holo16", "laser3", "laser1"} )
AddItemToBUY( "Walter-P22", "Weapon", "weapon_p22", 300, "Pistols", {"supressor4"} )
AddItemToBUY( "Desert Eagle", "Weapon", "weapon_deagle", 900, "Pistols" )
AddItemToBUY( "MR-96", "Weapon", "weapon_revolver2", 750, "Pistols", {"supressor4"} )
AddItemToBUY( "FNX-45", "Weapon", "weapon_fn45", 700, "Pistols", {"supressor4", "holo16", "laser3", "laser1"} )
AddItemToBUY( "Colt M45A1", "Weapon", "weapon_m45", 450, "Pistols", {} )
AddItemToBUY( "Colt M1911", "Weapon", "weapon_m1911", 400, "Pistols", {} )
AddItemToBUY( "Browning Hi-Power", "Weapon", "weapon_browninghp", 700, "Pistols", {} )
AddItemToBUY( "Beretta PX4", "Weapon", "weapon_px4beretta", 400, "Pistols", {"supressor4"} )
AddItemToBUY( "PL-15", "Weapon", "weapon_pl15", 500, "Pistols", {"supressor4"} )
AddItemToBUY( "ČZ 75", "Weapon", "weapon_cz75", 500, "Pistols", {"supressor4"} )
AddItemToBUY( "Colt King Cobra", "Weapon", "weapon_revolver357", 800, "Pistols", {} )

AddItemToBUY( "Ruger 10/22", "Weapon", "weapon_ruger", 1000, "Carbines", {} )
AddItemToBUY( "Mini-14", "Weapon", "weapon_mini14", 2200, "Carbines", {} )

AddItemToBUY( "AKM", "Weapon", "weapon_akm", 3200, "Assault", {"holo6","holo1","holo2","supressor1","optic7"}, nil, 0 )--0 = terrorist, 1 = swat
AddItemToBUY( "M4A1", "Weapon", "weapon_m4a1", 2700, "Assault", {"holo1","holo2","supressor2","holo15","optic8"}, nil, 1 )
AddItemToBUY( "HK416", "Weapon", "weapon_hk416", 3000, "Assault", {"holo1","holo2","supressor2","holo15","optic8"}, nil, 1 )
AddItemToBUY( "AK-74", "Weapon", "weapon_ak74", 2400, "Assault", {"holo6","holo1","holo2","supressor1","supressor8","optic7"}, nil, 0 )

AddItemToBUY( "MP-5", "Weapon", "weapon_mp5", 1500, "Submachine", {"supressor4"} )
AddItemToBUY( "MP-7", "Weapon", "weapon_mp7", 2300, "Submachine", {"holo1","holo2","supressor2","holo15"} )
AddItemToBUY( "MAC-11", "Weapon", "weapon_mac11", 1600, "Submachine", {"supressor4"}, nil, 0 )
AddItemToBUY( "Uzi", "Weapon", "weapon_uzi", 1300, "Submachine", {}, nil, 0 )
AddItemToBUY( "KRISS Vector", "Weapon", "weapon_vector", 2300, "Submachine", {"holo1", "holo2", "supressor4", "holo15"}, nil, 1 )
AddItemToBUY( "P90", "Weapon", "weapon_p90", 2300, "Submachine", {"holo1", "holo2", "supressor4", "holo15"}, nil, 1 )
AddItemToBUY( "Steyr TMP", "Weapon", "weapon_tmp", 2100, "Submachine", {"holo1", "holo2", "supressor4", "holo15"}, nil, 1 )
AddItemToBUY( "Šcorpion vz. 61", "Weapon", "weapon_skorpion", 1200, "Submachine", {}, nil, 0 )

AddItemToBUY( "\"Deer Hunter\" Bow", "Weapon", "weapon_hg_bow", 2000, "Special", {} )

AddItemToBUY( "Remington-870", "Weapon", "weapon_remington870", 1700, "Shotguns", {"holo1","holo2","supressor5","holo15"} )
AddItemToBUY( "SPAS-12", "Weapon", "weapon_spas12", 2200, "Shotguns", {"supressor5"} )
AddItemToBUY( "Sawed-off IZh-43", "Weapon", "weapon_doublebarrel_short", 800, "Shotguns", {}, nil, 0 )
AddItemToBUY( "IZh-43", "Weapon", "weapon_doublebarrel", 1100, "Shotguns", {}, nil, 0 )
AddItemToBUY( "XM-1014", "Weapon", "weapon_xm1014", 2300, "Shotguns", {"holo14", "holo3"} )

AddItemToBUY( "M249", "Weapon", "weapon_m249", 5750, "Heavy", {"holo1","holo2","supressor2","holo15"} )
AddItemToBUY( "M60", "Weapon", "weapon_m60", 7000, "Heavy", {} )
AddItemToBUY( "PKM", "Weapon", "weapon_pkm", 7800, "Heavy", {"optic4"} )
AddItemToBUY( "RPK-74", "Weapon", "weapon_rpk", 3700, "Heavy", {"optic4", "holo6", "holo13", "holo14", "holo6fur"} )

AddItemToBUY( "SR-25", "Weapon", "weapon_sr25", 5500, "Marksman/Sniper", {"supressor7","optic6", "optic2", "grip2"} , nil, 1)
AddItemToBUY( "Karabiner 98k", "Weapon", "weapon_kar98", 2100, "Marksman/Sniper", {"optic12"} )
AddItemToBUY( "SKS", "Weapon", "weapon_sks", 2900, "Marksman/Sniper", {"optic4"}, nil, 0 )
AddItemToBUY( "SVD", "Weapon", "weapon_svd", 5200, "Marksman/Sniper", {"optic4"}, nil, 0 )
AddItemToBUY( "Barrett M98B", "Weapon", "weapon_m98b", 4200, "Marksman/Sniper", {} )

-- Armor
AddItemToBUY( "IIIA Vest", "Armor", "ent_armor_vest3", 450, "Equipment", {} )
AddItemToBUY( "III Vest", "Armor", "ent_armor_vest4", 650, "Equipment", {} )
AddItemToBUY( "IV Vest", "Armor", "ent_armor_vest1", 1000, "Equipment", {} )
AddItemToBUY( "ACH III Helmet", "Armor", "ent_armor_helmet1", 350, "Equipment", {} )
AddItemToBUY( "Ballistic Mask", "Armor", "ent_armor_mask1", 650, "Equipment", {} )

-- Other Shit
AddItemToBUY( "NVG-GPNVG-18", "Armor", "ent_armor_nightvision1", 450, "Equipment", {} )
AddItemToBUY( "Flashlight", "Armor", "hg_flashlight", 250, "Equipment", {} )

-- Melee 
AddItemToBUY( "Machete", "Weapon", "weapon_hg_machete", 300, "Melee", {}, nil, 0 )
AddItemToBUY( "Hatchet", "Weapon", "weapon_hatchet", 300, "Melee", {}, nil, 0 )
AddItemToBUY( "Tomahawk", "Weapon", "weapon_tomahawk", 300, "Melee", {}, nil, 1 )
AddItemToBUY( "Police Tonfa", "Weapon", "weapon_hg_tonfa", 100, "Melee", {}, nil, 1 )
AddItemToBUY( "Battering Ram", "Weapon", "weapon_ram", 100, "Melee", {}, nil, 1 )

-- Medical
AddItemToBUY( "Bandage", "Weapon", "weapon_bandage_sh", 200, "Medical", {} )
AddItemToBUY( "Big Bandage", "Weapon", "weapon_bigbandage_sh", 400, "Medical", {} )
AddItemToBUY( "Medkit", "Weapon", "weapon_medkit_sh", 650, "Medical", {} )
AddItemToBUY( "Tourniquet", "Weapon", "weapon_tourniquet", 150, "Medical", {} )
AddItemToBUY( "Painkillers", "Weapon", "weapon_painkillers", 200, "Medical", {} )
AddItemToBUY( "Morphine", "Weapon", "weapon_morphine", 1000, "Medical", {} )
AddItemToBUY( "Fentanyl", "Weapon", "weapon_fentanyl", 2000, "Medical", {} )
AddItemToBUY( "Epipen", "Weapon", "weapon_adrenaline", 800, "Medical", {} )
AddItemToBUY( "Bloodbag", "Weapon", "weapon_bloodbag", 400, "Medical", {} )
AddItemToBUY( "Mannitol", "Weapon", "weapon_mannitol", 300, "Medical", {} )
AddItemToBUY( "Naloxone", "Weapon", "weapon_naloxone", 100, "Medical", {} )
AddItemToBUY( "Decompression needle", "Weapon", "weapon_needle", 50, "Medical", {} )
AddItemToBUY( "Beta-Blocker", "Weapon", "weapon_betablock", 250, "Medical", {} )

-- Explosive
AddItemToBUY( "M67", "Weapon", "weapon_hg_grenade_tpik", 500, "Explosive", {} )
AddItemToBUY( "RGD-5", "Weapon", "weapon_hg_rgd_tpik", 450, "Explosive", {} )
AddItemToBUY( "Flashbang", "Weapon", "weapon_hg_flashbang_tpik", 250, "Explosive", {} )

--Ammo
AddItemToBUY( "7.62x39mm (30)", "Ammo", "ent_ammo_7.62x39mm", 100, "Ammo", {}, 30)
AddItemToBUY( "7.62x39mm BP (30)", "Ammo", "ent_ammo_7.62x39mmbp", 300, "Ammo", {}, 30)
AddItemToBUY( "7.62x39mm SP (30)", "Ammo", "ent_ammo_7.62x39mmsp", 150, "Ammo", {}, 30)

AddItemToBUY( "7.62x54mm (20)", "Ammo", "ent_ammo_7.62x54mm", 100, "Ammo", {}, 20)

AddItemToBUY( "7.62x51mm (20)", "Ammo", "ent_ammo_7.62x51mm", 150, "Ammo", {}, 20)
AddItemToBUY( "7.62x51mm M993 (20)", "Ammo", "ent_ammo_7.62x51mmm993", 300, "Ammo", {}, 20)

AddItemToBUY( ".338 Lapua Magnum (20)", "Ammo", "ent_ammo_.338lapuamagnum", 350, "Ammo", {}, 20)

AddItemToBUY( "9x19mm (30)", "Ammo", "ent_ammo_9x19mmparabellum", 75, "Ammo", {}, 30)
AddItemToBUY( "9x19mm Green Tracer (30)", "Ammo", "ent_ammo_9x19mmgreentracer", 100, "Ammo", {}, 30)
AddItemToBUY( "9x19mm QuakeMaker (30)", "Ammo", "ent_ammo_9x19mmqm", 150, "Ammo", {}, 30)
AddItemToBUY( "9x17mm (30)", "Ammo", "ent_ammo_9x17mm", 75, "Ammo", {}, 30)
AddItemToBUY( "7.65x17mm (30)", "Ammo", "ent_ammo_7.65x17mm", 75, "Ammo", {}, 30)

AddItemToBUY( "5.56x45mm (30)", "Ammo", "ent_ammo_5.56x45mm", 100, "Ammo", {}, 30)
AddItemToBUY( "5.56x45mm AP (30)", "Ammo", "ent_ammo_5.56x45mmap", 200, "Ammo", {}, 30)
AddItemToBUY( "5.56x45mm M856 (30)", "Ammo", "ent_ammo_5.56x45mmm856", 150, "Ammo", {}, 30)

AddItemToBUY( "5.45x39mm (30)", "Ammo", "ent_ammo_5.45x39mm", 100, "Ammo", {}, 30)

AddItemToBUY( "4.6x30mm (30)", "Ammo", "ent_ammo_4.6x30mm", 100, "Ammo", {}, 30)

AddItemToBUY( "5.7x28mm (30)", "Ammo", "ent_ammo_5.7x28mm", 100, "Ammo", {}, 30)

AddItemToBUY( "12/70 Gauge (12)", "Ammo", "ent_ammo_12/70gauge", 100, "Ammo", {}, 12)
AddItemToBUY( "12/70 Beanbag (12)", "Ammo", "ent_ammo_12/70beanbag", 25, "Ammo", {}, 12)
AddItemToBUY( "12/70 RIP (12)", "Ammo", "ent_ammo_12/70rip", 250, "Ammo", {}, 12)
AddItemToBUY( "12/70 Slug (12)", "Ammo", "ent_ammo_12/70slug", 150, "Ammo", {}, 12)

AddItemToBUY( ".22 Long Rifle (60)", "Ammo", "ent_ammo_.22longrifle", 50, "Ammo", {}, 60)

AddItemToBUY( ".45 ACP (30)", "Ammo", "ent_ammo_.45acp", 75, "Ammo", {}, 30)
AddItemToBUY( ".45 ACP Hydro-Shock (30)", "Ammo", "ent_ammo_.45acphydroshock", 125, "Ammo", {}, 30)

AddItemToBUY( ".50 Action Express (20)", "Ammo", "ent_ammo_.50actionexpress", 75, "Ammo", {}, 20)
AddItemToBUY( ".50 Action Express Copper (20)", "Ammo", "ent_ammo_.50actionexpresscopper", 100, "Ammo", {}, 20)
AddItemToBUY( ".50 Action Express JHP (20)", "Ammo", "ent_ammo_.50actionexpressjhp", 100, "Ammo", {}, 20)

AddItemToBUY( ".357 Magnum (20)", "Ammo", "ent_ammo_.357magnum", 75, "Ammo", {}, 20)
AddItemToBUY( ".38 Special (20)", "Ammo", "ent_ammo_.38special", 75, "Ammo", {}, 20)
AddItemToBUY( ".40 Smith & Wesson (30)", "Ammo", "ent_ammo_.40sw", 75, "Ammo", {}, 30)
AddItemToBUY( ".44 Remington Magnum (20)", "Ammo", "ent_ammo_.44remingtonmagnum", 75, "Ammo", {}, 20)

AddItemToBUY( "Arrow", "Ammo", "ent_ammo_arrow", 25, "Ammo", {}, 5)

function MODE:HG_MovementCalc_2( mul, ply, cmd, mv )
    if (zb.ROUND_START or 0) + 20 > CurTime() and cmd then
        cmd:RemoveKey(IN_ATTACK)
        cmd:RemoveKey(IN_FORWARD)
        cmd:RemoveKey(IN_BACK)
        cmd:RemoveKey(IN_MOVELEFT)
        cmd:RemoveKey(IN_MOVERIGHT)

        if mv then
            mv:RemoveKey(IN_ATTACK)
            mv:RemoveKey(IN_FORWARD)
            mv:RemoveKey(IN_BACK)
            mv:RemoveKey(IN_MOVELEFT)
            mv:RemoveKey(IN_MOVERIGHT)
        end

        if IsValid(ply) and IsValid(ply:GetWeapon("weapon_hands_sh")) then
            cmd:SelectWeapon(ply:GetWeapon("weapon_hands_sh"))
            if SERVER then ply:SelectWeapon("weapon_hands_sh") end
        end
        
        mul[1] = 0
    end
end

function MODE:PlayerCanLegAttack( ply )
	if zb.CROUND == "dm" and (zb.ROUND_START or 0) + 20 > CurTime() then
		return false
	end
end