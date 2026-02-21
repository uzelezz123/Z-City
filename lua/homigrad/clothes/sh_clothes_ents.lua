ZC_CLOTHES_SLOT_TORSO = 0
ZC_CLOTHES_SLOT_PANTS = 1
ZC_CLOTHES_SLOT_BOOTS = 2
ZC_CLOTHES_SLOT_BACKPACK = 3

local clothes = {
    wintercoat1 = {
        PrintName = "Winter Coat 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/newcitizen/halflife2/male_torso_wintercoat.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 5,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/newcitizen/halflife2/female_torso_wintercoat.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.15
    },
    suit_coat1 = {
        PrintName = "Suit Coat 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/male_torso_combine_official.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 5,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/female_torso_combine_official.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
    },
         stealh_cost1 = {
        PrintName = "stealth_cost1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife2/male_torso_leatherjacket1.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 5,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_leatherjacket1.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
    }
},
    suit_pants1 = {
        PrintName = "Suit Pants 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
        Male = {
            Model = "models/male_legs_combine_official.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 5,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/female_legs_combine_official.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },
    mountaineering_jacket1 = {
        PrintName = "Mountaineering jacket 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife2/cca/male_torso_metropolice_winter.mdl",
            ModelSubMaterials = {
                ["models/tnb/cca/c13/metro13_retail"] = "NULL",
                ["models/tnb/cca/c13/metro13_armband4"] = "NULL",
                ["models/tnb/cca/c13/metro13_fc"] = "NULL"
            },
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 2,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/cca/female_torso_metropolice_winter.mdl",
            ModelSubMaterials = {
                ["models/tnb/cca/c13/metro13_retail"] = "NULL",
                ["models/tnb/cca/c13/metro13_armband4"] = "NULL",
                ["models/tnb/cca/c13/metro13_fc"] = "NULL"
            },
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 2,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.75
    },

        
    resistance_jacket2 = {
        PrintName = "Resistance Jacket 2",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/rebels/male_torso_resistance2.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/rebels/female_torso_resistance2.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.4
    },
    
    resistance_jacket1 = {
        PrintName = "Resistance Jacket 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/rebels/male_torso_resistance1.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/rebels/female_torso_resistance1.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.4
    },
    
    resistance_pants1 = {
        PrintName = "Resistance Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife2/rebels/male_legs_resistance1.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/rebels/female_legs_resistance1.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.3
    },
    
    rebel_backpack6 = {
        PrintName = "Rebel Backpack 6",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_BACKPACK] = true },
        Male = {
            Model = "models/tnb/halflife2/rebels/male_backpack_rebel6.mdl",
            HideSubMaterails = {},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/rebels/female_backpack_rebel6.mdl",
            HideSubMaterails = {},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },
    
    rebel_backpack4 = {
        PrintName = "Rebel Backpack 4",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_BACKPACK] = true },
        Male = {
            Model = "models/tnb/halflife2/rebels/male_backpack_rebel4.mdl",
            HideSubMaterails = {},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/rebels/female_backpack_rebel4.mdl",
            HideSubMaterails = {},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },
    
    rebel_backpack3 = {
        PrintName = "Rebel Backpack 3",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_BACKPACK] = true },
        Male = {
            Model = "models/tnb/halflife2/rebels/male_backpack_rebel3.mdl",
            HideSubMaterails = {},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/rebels/female_backpack_rebel3.mdl",
            HideSubMaterails = {},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },
    
    
    sweater1 = {
        PrintName = "Sweater",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_torso_sweater.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_sweater.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.3
    },
    
    raincoat2 = {
        PrintName = "Raincoat 2",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_torso_raincoat2.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_raincoat2.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.5
    },
    
    raincoat1 = {
        PrintName = "Raincoat 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_torso_raincoat1.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_raincoat1.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.45
    },
    
    overcoat2 = {
        PrintName = "Overcoat 2",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_torso_overcoat2.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_overcoat2.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.6
    },
    
    metalworker_jacket = {
        PrintName = "Metalworker Jacket",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_torso_metalworker.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_metalworker.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.35
    },
    
    mechanic_jumpsuit = {
        PrintName = "Mechanic Jumpsuit",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_torso_mechanic.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_mechanic.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.3
    },
    
    overalls = {
        PrintName = "Overalls",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_overalls.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_overalls.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.25
    },
    
    suitjacket = {
        PrintName = "Suit Jacket",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/male_torso_suitjacket.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_suitjacket.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.2
    },
    
    black_suit = {
        PrintName = "Black Suit",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife/male_torso_black_suit.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_torso_black_suit.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.15
    },
    
    
    ca_pants = {
        PrintName = "Civil Authority Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife2/ca/male_legs_ca.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/ca/female_legs_ca.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.2
    },
    
    cca_standard_pants = {
        PrintName = "CCA Standard Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife2/cca/male_legs_metropolice_standard.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/cca/female_legs_metropolice_standard.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.2
    },
    
    
    white_pants = {
        PrintName = "White Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife/male_legs_white.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_white.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.1
    },
    
    suit_white_pants = {
        PrintName = "White Suit Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife/male_legs_suit_white.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_suit_white.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.1
    },
    
    admin_pants = {
        PrintName = "Admin Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife/male_legs_admin1.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_admin1.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.15
    },
    
    cargopants = {
        PrintName = "Cargo Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife/male_legs_cargopants.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_cargopants.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.25
    },
    
    jeans = {
        PrintName = "Jeans",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife/male_legs_jeans.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_jeans.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.15
    },
    
    slackjeans = {
        PrintName = "Slack Jeans",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_PANTS] = true },
        Male = {
            Model = "models/tnb/halflife/male_legs_slackjeans.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_slackjeans.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.15
    },
    
    
    hc_fullbody = {
        PrintName = "High Command Uniform",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true,
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
        Male = {
            Model = "models/tnb/halflife2/cca/male_fullbody_hc.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet", "distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/cca/female_fullbody_hc.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet", "distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.3
    },
    
    sec_fullbody = {
        PrintName = "Security Uniform",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true,
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
        Male = {
            Model = "models/tnb/halflife2/cca/male_fullbody_sec.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet", "distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/cca/female_fullbody_sec.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet", "distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.25
    },
    
    metro_overcoat = {
        PrintName = "Metropolice Overcoat",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = { [ZC_CLOTHES_SLOT_TORSO] = true },
        Male = {
            Model = "models/tnb/halflife2/cca/male_torso_metropolice_overcoat.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/cca/female_torso_metropolice_overcoat.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.6
    },

    mountaineering_jacket2 = {
        PrintName = "Mountaineering jacket 2",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife2/cca/male_torso_metropolice_winter.mdl",
            ModelSubMaterials = {
                ["models/tnb/cca/c13/metro13_retail"] = "NULL",
                ["models/tnb/cca/c13/metro13_armband4"] = "NULL",
                ["models/tnb/cca/c13/metro13_fc"] = "NULL"
            },
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 3,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/cca/female_torso_metropolice_winter.mdl",
            ModelSubMaterials = {
                ["models/tnb/cca/c13/metro13_retail"] = "NULL",
                ["models/tnb/cca/c13/metro13_armband4"] = "NULL",
                ["models/tnb/cca/c13/metro13_fc"] = "NULL"
            },
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 3,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.75
    },


    backpack1 = {
        PrintName = "Backpack 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_BACKPACK] = true
        },
        Male = {
            Model = "models/tnb/halflife2/male_backpack1.mdl",
            HideSubMaterails = {},
            Skin = 5,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_backpack1.mdl",
            HideSubMaterails = {},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },

    winter_pants1 = {
        PrintName = "Winter Pants 1",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
        Male = {
            Model = "models/tnb/halflife/male_legs_medic.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 5,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_medic.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.5
    },
}
--ModelSubMaterials = {[""] = ""},

local function register()
    for k, v in pairs(clothes) do
        local ENT = {}
        ENT.Base = "ent_zcity_clothes_base"
        ENT.PrintName = v.PrintName
        ENT.Category = "ZCity Clothes"
        ENT.Spawnable = true
        ENT.Model = v.Model

        ENT.SlotOccupation = v.SlotOccupation

        ENT.Male = v.Male
        ENT.FeMale = v.FeMale
        
        if v.WarmSave then
            ENT.WarmSave = v.WarmSave
        end

        scripted_ents.Register(ENT, "ent_zcity_colthes_" .. k)
    end
end

hook.Add("Think","remove-me-clothes",function()
    register()
    hook.Remove("Think","remove-me-clothes")
end)

hook.Add("Initialize", "init-clothes", register)
--[[

    pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"

    ENT.Base = "base_gmodentity"
    ENT.PrintName = "Clothes base"
    ENT.Category = "ZCity Clothes"
    ENT.Spawnable = false
    ENT.Model = "models/props_junk/cardboard_box003a.mdl"
    ENT.IconOverride = ""

    ZC_CLOTHES_SLOT_TORSO = 0
    ZC_CLOTHES_SLOT_PANTS = 1
    ZC_CLOTHES_SLOT_BOOTS = 2

    ENT.SlotOccupation = {
        --[ZC_CLOTHES_SLOT_TORSO] = true,
        --[ZC_CLOTHES_SLOT_PANTS] = true,
        --[ZC_CLOTHES_SLOT_BOOTS] = true,
    }

    ENT.Male = {}
    ENT.Male.Model = ""
    ENT.Male.HideSubMaterails = {}
    ENT.Male.Skin = 0
    ENT.Male.Bodygroups = "0000000000000"

    ENT.FeMale = {}
    ENT.FeMale.Model = ""
    ENT.FeMale.HideSubMaterails = {}
    ENT.FeMale.Skin = 0
    ENT.FeMale.Bodygroups = "0000000000000"
--]]
