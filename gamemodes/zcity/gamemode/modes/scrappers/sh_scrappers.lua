local MODE = MODE

MODE.StartingMoney = 1000
MODE.LobbyTime = 120
MODE.RoundTime = 600

zb.Points.SCRAPPERS_EXTRACTION = zb.Points.SCRAPPERS_EXTRACTION or {}
zb.Points.SCRAPPERS_EXTRACTION.Color = Color(196,222,27)
zb.Points.SCRAPPERS_EXTRACTION.Name = "SCRAPPERS_EXTRACTION"

zb.Points.SCRAPPERS_BIGBOX = zb.Points.SCRAPPERS_BIGBOX or {}
zb.Points.SCRAPPERS_BIGBOX.Color = Color(222,167,27)
zb.Points.SCRAPPERS_BIGBOX.Name = "SCRAPPERS_BIGBOX"

zb.Points.SCRAPPERS_SMALLBOX = zb.Points.SCRAPPERS_SMALLBOX or {}
zb.Points.SCRAPPERS_SMALLBOX.Color = Color(222,167,27)
zb.Points.SCRAPPERS_SMALLBOX.Name = "SCRAPPERS_SMALLBOX"

zb.Points.SCRAPPERS_VEHICLE = zb.Points.SCRAPPERS_VEHICLE or {}
zb.Points.SCRAPPERS_VEHICLE.Color = Color(222,27,27)
zb.Points.SCRAPPERS_VEHICLE.Name = "SCRAPPERS_VEHICLE"

zb.Points.SCRAPPERS_SPAWNPOINTS = zb.Points.SCRAPPERS_SPAWNPOINTS or {}
zb.Points.SCRAPPERS_SPAWNPOINTS.Color = Color(222,27,27)
zb.Points.SCRAPPERS_SPAWNPOINTS.Name = "SCRAPPERS_SPAWNPOINTS"

zb.Points.SCRAPPERS_BIGVEHICLE = zb.Points.SCRAPPERS_BIGVEHICLE or {}
zb.Points.SCRAPPERS_BIGVEHICLE.Color = Color(222,27,27)
zb.Points.SCRAPPERS_BIGVEHICLE.Name = "SCRAPPERS_BIGVEHICLE"

zb.Points.SCRAPPERS_APCSPAWN = zb.Points.SCRAPPERS_APCSPAWN or {}
zb.Points.SCRAPPERS_APCSPAWN.Color = Color(222,27,27)
zb.Points.SCRAPPERS_APCSPAWN.Name = "SCRAPPERS_APCSPAWN"

MODE.Vehicles = {
    "sim_fphys_pwhatchback",
    "sim_fphys_pwmoskvich",
    "sim_fphys_pwtrabant",
    "sim_fphys_pwtrabant02",
    "sim_fphys_pwvan",
    "sim_fphys_pwvolga",
    "sim_fphys_pwzaz"
}

MODE.BigVehicles = {
    "sim_fphys_pwavia",
    "sim_fphys_pwgaz52"
}

MODE.WeaponsShopList = {
    ["weapon_glock17"] = {
        price = 1000
    },
    ["weapon_makarov"] = {
        price = 450
    },
    ["weapon_deagle"] = {
        price = 3000
    },
    ["weapon_akm"] = {
        price = 5000
    },
    ["weapon_m4a1"] = {
        price = 5500
    },
    ["weapon_mac11"] = {
        price = 2500
    },
    ["weapon_revolver"] = {
        price = 2000
    },
    ["weapon_m249"] = {
        price = 10000
    },
    ["weapon_p90"] = {
        price = 3000
    },
    ["weapon_remington870"] = {
        price = 3000
    },
    ["weapon_hg_grenade_tpik"] = {
        price = 750
    },
    ["weapon_leadpipe"] = {
        price = 200
    },
    ["weapon_tomahawk"] = {
        price = 500
    },
    ["weapon_vector"] = {
        price = 2500
    },
    ["weapon_mp5"] = {
        price = 2700
    },
    ["weapon_ak74u"] = {
        price = 4200
    },
    ["weapon_asval"] = {
        price = 3600
    },
    ["weapon_sr25"] = {
        price = 12600
    },
    ["weapon_pkm"] = {
        price = 15600
    },
    ["weapon_saiga12"] = {
        price = 3490
    },
    ["weapon_hg_rgd_tpik"] = {
        price = 640
    },
    ["weapon_hatchet"] = {
        price = 580
    },
    ["weapon_fn45"] = {
        price = 1240
    },
}

MODE.MedicineShopList = {
    ["weapon_medkit_sh"] = {
        price = 800,
        slot = 4
    },
    ["weapon_adrenaline"] = {
        price = 250,
        slot = 4
    },
    ["weapon_morphine"] = {
        price = 500,
        slot = 4
    },
    ["weapon_bandage_sh"] = {
        price = 100,
        slot = 4
    },
    ["weapon_tourniquet"] = {
        price = 200,
        slot = 4
    }
}

MODE.AttachmentsShopList = {
    -- Холо и Колим
    ["ent_att_holo1"] = {
        price = 450,
        slot = 0
    },
    ["ent_att_holo2"] = {
        price = 350,
        slot = 0
    },
    ["ent_att_holo3"] = {
        price = 500,
        slot = 0
    },
    ["ent_att_holo5"] = {
        price = 300,
        slot = 0
    },
    ["ent_att_holo6"] = {
        price = 400,
        slot = 0
    },
    ["ent_att_holo7"] = {
        price = 400,
        slot = 0
    },
    ["ent_att_holo8"] = {
        price = 220,
        slot = 0
    },
    ["ent_att_holo13"] = {
        price = 300,
        slot = 0
    },
    -- Оптика
    ["ent_att_optic1"] = {
        price = 600,
        slot = 0
    },
    ["ent_att_optic2"] = {
        price = 900,
        slot = 0
    },
    ["ent_att_optic3"] = {
        price = 1200,
        slot = 0
    },
    ["ent_att_optic4"] = {
        price = 600,
        slot = 0
    },
    ["ent_att_optic5"] = {
        price = 1600,
        slot = 0
    },
    ["ent_att_optic6"] = {
        price = 700,
        slot = 0
    },
    ["ent_att_optic8"] = {
        price = 800,
        slot = 0
    },
    -- Дульники Глушаки
    ["ent_att_supressor1"] = {
        price = 490,
        slot = 0
    },
    ["ent_att_supressor2"] = {
        price = 670,
        slot = 0
    },
    ["ent_att_supressor4"] = {
        price = 270,
        slot = 0
    },
    ["ent_att_supressor5"] = {
        price = 320,
        slot = 0
    },
    -- Рукояти
    ["ent_att_grip1"] = {
        price = 620,
        slot = 0
    },
    ["ent_att_grip2"] = {
        price = 850,
        slot = 0
    },
    ["ent_att_grip3"] = {
        price = 770,
        slot = 0
    },
}

MODE.ArmorShopList = {
    -- Vests
    ["ent_armor_vest1"] = {
        price = 600,
        slot = 0
    },
    ["ent_armor_vest2"] = {
        price = 400,
        slot = 0
    },
    -- Helmets
    ["ent_armor_helmet1"] = {
        price = 400,
        slot = 0
    },
    ["ent_armor_helmet2"] = {
        price = 250,
        slot = 0
    },
    ["ent_armor_helmet3"] = {
        price = 300,
        slot = 0
    },
}

MODE.ShopList = {
    ["Weapons"] = MODE.WeaponsShopList,
    ["Medicine"] = MODE.MedicineShopList,
    ["Attachments"] = MODE.AttachmentsShopList,
    ["Armor"] = MODE.ArmorShopList,
}

function hg.GetItem(item)
    if not item then return end
    item = string.Replace(item,"ent_att_","")
	item = string.Replace(item,"ent_armor_","")

    if weapons.Get(item) then
        return weapons.Get(item)
    elseif hg.GetArmorPlacement(item) then
        return hg.armor[hg.GetArmorPlacement(item)][item]
    elseif hg.IsValidAtt(item) then
        return hg.attachments[hg.GetAttachmentTab(item)][item]
    else
        --if ammo??
    end
end

function hg.GetItemEnt(item)
    if not item then return end
    item = string.Replace(item,"ent_att_","")
	item = string.Replace(item,"ent_armor_","")

    if weapons.Get(item) then
        return weapons.Get(item)
    elseif hg.GetArmorPlacement(item) then
        return scripted_ents.Get("ent_armor_"..item)
    elseif hg.IsValidAtt(item) then
        return scripted_ents.Get("ent_att_"..item)
    else
        --if ammo??
    end
end

function hg.GiveItem(ply,item)
    if not item then return end
    if istable(item) then
        for i,item in pairs(item) do
            hg.GiveItem(ply,item)
        end
        return
    end
    item = string.Replace(item,"ent_att_","")
	item = string.Replace(item,"ent_armor_","")

    if weapons.Get(item) then
        return ply:Give(item)
    elseif hg.GetArmorPlacement(item) then
        hg.AddArmor(ply,item)
    elseif hg.IsValidAtt(item) then
        hg.GiveAttachment(ply,item)
    else
        --if ammo??
    end

    
end