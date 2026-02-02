--[[
  _____        __                        _____             __ _       
 |  __ \      / _|                      / ____|           / _(_)      
 | |  | | ___| |_ ___ _ __  ___  ___   | |     ___  _ __ | |_ _  __ _ 
 | |  | |/ _ \  _/ _ \ '_ \/ __|/ _ \  | |    / _ \| '_ \|  _| |/ _` |
 | |__| |  __/ |  __/ | | \__ \  __/   | |___| (_) | | | | | | | (_| |
 |_____/ \___|_|\___|_| |_|___/\___|    \_____\___/|_| |_|_| |_|\__, |
                                                                  __/ |
                                                                 |___/ 
]]--


DEFENSE_MUSIC = {}
DEFENSE_WEAPONS = {}
DEFENSE_ATTACHMENTS = {}
DEFENSE_ARMOR = {}
DEFENSE_SUPPORT_ITEMS = {}
DEFENSE_FAILED_MESSAGES = {}
DEFENSE_WAVE_DEFINITIONS = {}


DEFENSE_MUSIC = {
    WAVE = {
        [1] = "music_themes/defense/wave01.wav",
        [2] = "music_themes/defense/wave02.wav",
        [3] = "music_themes/defense/wave03.wav",
        [4] = "music_themes/defense/wave04.wav",
        [5] = "music_themes/exhaustion.mp3",
        [6] = "music_themes/defense/wave02.wav",
        [7] = "music_themes/defense/wave01.wav",
        [8] = "music_themes/defense/wave02.wav",
        [9] = "music_themes/defense/wave03.wav",
        [10] = "music_themes/defense/wave04.wav",
        [11] = "music_themes/exhaustion.mp3",
        [12] = "music_themes/defense/wave02.wav",
    },
    WAITING = {
        [0] = "music_themes/dm/mpdkick.wav",
        [1] = "music_themes/defense/waiting_theme01.wav",
        [2] = "music_themes/defense/waiting_theme02.wav",
        [3] = "music_themes/unnamed.mp3",
        [4] = "music_themes/roll.mp3",
        [5] = "music_themes/defense/waiting_theme02.wav"
    }
}

DEFENSE_WEAPONS = {
    [0] = {
        "weapon_akm",
        "weapon_ar15",
        "weapon_akmwreked",
        "weapon_osipr",
        "weapon_sg552",
        "weapon_ak74u",
        "weapon_mp7",
        "weapon_uzi",
        "weapon_vector",
        "weapon_p90",
        "weapon_m249",
        "weapon_sr25",
        "weapon_svd",
		"weapon_m590a1",
        "weapon_remington870",
        "weapon_xm1014",
    }
}


DEFENSE_ATTACHMENTS = {
    [0] = {
        {""},
    },
}


DEFENSE_ARMOR = {
    [0] = {
        {"vest4", "helmet1"},
    },
}


DEFENSE_LOOTTABLE = {
	{30, {
		{4,"weapon_leadpipe"},
		{3,"weapon_hg_crowbar"},
		{2,"weapon_tomahawk"},
		{2,"weapon_hatchet"},
		{1,"weapon_hg_axe"},
	}},
	{50, {
		{9,"*ammo*"},
		{9,"*sight*"},
		{9,"*barrel*"},
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
		{5,"weapon_pkm"},
		{5,"weapon_hk21"},
		{5,"weapon_hg_crossbow"},
		{5,"weapon_m98b"},
		{5,"weapon_hg_rpg"},
		{5,"weapon_sr25"},
	}},
}


MODE.LootTable = DEFENSE_LOOTTABLE




DEFENSE_WAVE_DEFINITIONS = {
    STANDARD = {
        [1] = {
            {type = "npc_metropolice", weapon = "weapon_hk_usp", health = 60, count = 5, default_weapon = false},
            {type = "npc_metropolice", weapon = "weapon_mp7", health = 60, count = 2, default_weapon = false}
        },
        [2] = {
            {type = "npc_metropolice", weapon = "weapon_hk_usp", health = 60, count = 3, default_weapon = false},
            {type = "npc_metropolice", weapon = "weapon_mp7", health = 60, count = 3, default_weapon = false}
        },
        [3] = {
            {type = "npc_metropolice", weapon = "weapon_mp7", health = 60, count = 3, aggressive = true, default_weapon = false},
            {type = "npc_combine_s", weapon = "weapon_mp7", health = 90, count = 3, default_weapon = false}
        },
        [4] = {
            {type = "npc_combine_s", weapon = "weapon_osipr", health = 90, count = 3, default_weapon = false},
            {type = "npc_combine_s", weapon = "weapon_spas12", health = 90, count = 3, default_weapon = false}
        },
        [5] = {
            {type = "npc_combine_s", weapon = "weapon_osipr", health = 90, count = 4, default_weapon = false},
            {type = "npc_combine_s", weapon = "weapon_spas12", health = 90, count = 3, default_weapon = false, 
             relationship = {class = "npc_metropolice", disposition = D_LI}}
        },
        [6] = {
            {type = "npc_combine_s", weapon = "weapon_osipr", health = 200, count = 4, model = "models/Combine_Super_Soldier.mdl", 
             default_weapon = false, relationship = {class = "npc_metropolice", disposition = D_LI},
             keyvalues = {SquadName = "overwatch", NumGrenades = "3", spawnflags = "260"}},
            {type = "npc_metropolice", weapon = "", health = 50, count = 2, default_weapon = true,
             relationship = {class = "npc_combine_s", disposition = D_LI}}
        }
    },
    
    EXTENDED = {
        [1] = {
            {type = "npc_metropolice", weapon = "weapon_hk_usp", health = 90, count = 4, default_weapon = false},
           {type = "zb_myt_cmb_shield", weapon = "weapon_hk_usp", health = 95, count = 2, default_weapon = true}
        },
        [2] = {
            {type = "zb_metropolice_elite", weapon = "weapon_deagle", health = 100, count = 4, default_weapon = false},
            {type = "zb_myt_cmb_shield", weapon = "weapon_mp7", health = 100, count = 4, default_weapon = false}
        },
        [3] = {
            {type = "zb_metropolice_elite", weapon = "weapon_mp7", health = 120, count = 10, default_weapon = false},
        },
        [4] = {
            {type = "zb_metropolice_elite", weapon = "weapon_deagle", health = 120, count = 3, default_weapon = false},
            {type = "npc_combine_s", weapon = "weapon_mp7", health = 120, count = 5, default_weapon = false},
            {type = "npc_manhack", count = 4}
        },
        [5] = {
            {type = "npc_combine_s", weapon = "weapon_mp7", health = 120, count = 8, default_weapon = false},
            {type = "npc_manhack", count = 2}
        },
        [6] = {
            {type = "beta_unit_synth_soldier", weapon = "", health = 1000, count = 1, boss = true},
            {type = "npc_combine_s", weapon = "weapon_osipr", health = 100, count = 7, default_weapon = false},
            {type = "ej_combine_sniper", count = 2, weapon = "weapon_combinesniper", relationship = {class = "npc_combine_s", disposition = D_LI}}
        },
        [7] = {
            {type = "npc_combine_s", weapon = "weapon_osipr", health = 110, count = 5, default_weapon = false},
            {type = "npc_combine_s", weapon = "weapon_spas12", health = 110, count = 3, default_weapon = false},
            {type = "zb_myt_cmb_wallham", count = 2, health = 200, weapon = "weapon_m249", default_weapon = true}
        },
        [8] = {
            {type = "npc_combine_s", weapon = "weapon_osipr", health = 110, count = 5, default_weapon = false},
            {type = "npc_combine_s", weapon = "weapon_spas12", health = 110, count = 5, default_weapon = false},
            {type = "zb_manhack", count = 2}
        },
        [9] = {
            {type = "beta_unit_combine_sniper", weapon = "weapon_combinesniper", health = 130, count = 3   },
            {type = "zb_myt_cmb_wallham", weapon = "weapon_osipr", health = 150, count = 5, default_weapon = false},
            {type = "zb_myt_cmb_pain", weapon = "weapon_mp7", health = 130, count = 3, default_weapon = false}
        },
        [10] = {
            {type = "beta_unit_synth_brown", weapon = "weapon_osipr", health = 90, count = 5, default_weapon = true},
            {type = "beta_unit_synth_brown", weapon = "weapon_osipr", health = 90, count = 5, default_weapon = true}
        },
        [11] = {
            {type = "beta_unit_combine_assassin", weapon = "weapon_deagle", health = 100, count = 3, default_weapon = true},
            {type = "zb_myt_cmb_wallham", weapon = "weapon_osipr", health = 200, count = 9, default_weapon = false}
        },
        [12] = {
            {type = "zb_combine_juggernaut", weapon = "weapon_m60", health = 2500, count = 1, boss = true},
            {type = "beta_unit_synth_brown", weapon = "weapon_osipr", health = 90, count = 10, weapondefault = true},
            {type = "beta_unit_combine_sniper", weapon = "weapon_m98b", health = 100, count = 4,
             default_weapon = false}
        }
    },
    
    ZOMBIE = {
        [1] = {
            {type = "sent_vj_l4d_cominf", weapon = "", health = 100, count = 8, aggressive = true},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 150, count = 5}
        },
        [2] = {
            {type = "sent_vj_l4d_cominf", weapon = "", health = 125, count = 6},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 175, count = 6},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 200, count = 4}
        },
        [3] = {
            {type = "sent_vj_l4d_cominf", weapon = "", health = 200, count = 5},
            {type = "npc_vj_l4d_com_m_riot", weapon = "", health = 225, count = 5},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 180, count = 7}
        },
        [4] = {
            {type = "sent_vj_l4d_cominf", weapon = "", health = 250, count = 6},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 200, count = 6},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 225, count = 8}
        },
        [5] = {
            {type = "sent_vj_l4d_cominf", weapon = "", health = 250, count = 6},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 275, count = 6},
            {type = "sent_vj_l4d_cominf", weapon = "", health = 400, count = 8, aggressive = true}
        },
        [6] = {
            {type = "sent_vj_l4d_cominf", weapon = "", health = 300, count = 8},
            {type = "npc_vj_l4d_com_m_mudmen", weapon = "", health = 500, count = 8},
            {type = "npc_vj_l4d_com_m_mudmen", weapon = "", health = 450, count = 7, aggressive = true},
            {type = "npc_vj_l4d_com_m_mudmen", weapon = "", health = 1000, count = 2, aggressive = true}
        }
    }
}


DEFENSE_COMMANDER_ECONOMY = {
    STARTING_POINTS = 250,
    POINTS_PER_WAVE = {
        ["STANDARD"] = 50,
        ["EXTENDED"] = 65,
        ["ZOMBIE"] = 80
    }
}


DEFENSE_COMMANDER_ITEMS = {
    ["Weapons"] = {
        {name = "AK-47", entity = "weapon_akm", price = 7, desc = "Reliable assault rifle with good damage", icon = "pwb/sprites/akm" },
        {name = "M4A1", entity = "weapon_ar15", price = 6, desc = "Accurate assault rifle with moderate damage", icon = "vgui/wep_jack_hmcd_assaultrifle"},
        {name = "MP5", entity = "weapon_mp5", price = 3, desc = "Fast-firing SMG with controllable recoil", icon = "vgui/hud/tfa_inss_mp5a2"},
        {name = "M249", entity = "weapon_m249", price = 15, desc = "Heavy machine gun with large magazine", icon = "pwb2/vgui/weapons/m249paratrooper"},
        {name = "Desert Eagle", entity = "weapon_deagle", price = 2, desc = "Powerful pistol with high stopping power", icon = "pwb2/vgui/weapons/deserteagle"}
    },
    ["Equipment"] = {
        {name = "Medkit", entity = "weapon_medkit_sh", price = 15, desc = "Heals injuries and restores health", icon = "vgui/entities/weapon_medkit_sh"},
        {name = "Body Armor (Lvl 4)", entity = "ent_armor_vest1", price = 15, desc = "Provides good protection against bullets", icon = "scrappers/armor1.png"},
        {name = "Helmet ACHHC IIIA", entity = "ent_armor_helmet5", price = 10, desc = "Military grade head protection", icon = "entities/ent_jack_gmod_ezarmor_achhcblack.png"},
        {name = "Adrenaline", entity = "weapon_adrenaline", price = 5, desc = "Temporarily increases stamina and reduces pain", icon = "vgui/entities/weapon_adrenaline"}
    },
    ["Ammunition"] = {
        {name = "5.56mm Ammo", entity = "ent_ammo_5.56x45mm", price = 3, desc = "Standard rifle ammunition", icon = "vgui/hud/hmcd_round_556"},
        {name = "7.62mm Ammo", entity = "ent_ammo_7.62x39mm", price = 5, desc = "Powerful rifle ammunition", icon = "vgui/hud/hmcd_round_792"},
        {name = "9mm Ammo", entity = "ent_ammo_9x19mmparabellum", price = 2, desc = "Standard pistol ammunition", icon = "vgui/hud/hmcd_round_9"},
        {name = "12 Gauge Shells", entity = "ent_ammo_12/70gauge", price = 3, desc = "Shotgun ammunition", icon = "vgui/hud/hmcd_round_12"}
    },
    ["Explosives"] = {
        {name = "Frag Grenade", entity = "weapon_hg_grenade_tpik", price = 35, desc = "Standard fragmentation grenade", icon = "vgui/entities/weapon_hg_grenade_tpik"},
        {name = "Claymore", entity = "weapon_claymore", price = 50, desc = "Directional anti-personnel mine", icon = "vgui/entities/weapon_claymore"},
        {name = "Pipe Bomb", entity = "weapon_hg_pipebomb_tpik", price = 20, desc = "Improvised explosive device", icon = "vgui/entities/weapon_hg_pipebomb_tpik"}
    },
    ["Tactical Support"] = {
        {name = "Emergency Reinforcements", entity = "player_reinforcements", price = 350, desc = "Bring back fallen teammates as reinforcements to continue the fight", icon = "vgui/hud/hmcd_person", special = true}
    }
}
