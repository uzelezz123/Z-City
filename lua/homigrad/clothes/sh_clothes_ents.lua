ZC_CLOTHES_SLOT_TORSO = 0
ZC_CLOTHES_SLOT_PANTS = 1
ZC_CLOTHES_SLOT_BOOTS = 2
ZC_CLOTHES_SLOT_BACKPACK = 3
-- if you really want this NOW https://steamcommunity.com/sharedfiles/filedetails/?id=3670069780
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
        PrintName = "Black Warm Suit Coat",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/male_torso_combine_official.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/female_torso_combine_official.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },
    suit_pants1 = {
        PrintName = "Black Warm Suit Coat Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
        Male = {
            Model = "models/male_legs_combine_official.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/female_legs_combine_official.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },

    suit_coat2 = {
        PrintName = "White Suit Coat",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife/male_torso_suit_white.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_torso_suit_white.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        }
    },
    suit_pants2 = {
        PrintName = "White Suit Coat Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
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
        }
    },

    suit_coat3 = {
        PrintName = "Black Suit Coat",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife/male_torso_suit_white.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 1,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_torso_suit_white.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 1,
            Bodygroups = "0000000000000"
        }
    },
    suit_pants3 = {
        PrintName = "Black Suit Coat Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
        Male = {
            Model = "models/tnb/halflife/male_legs_suit_white.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 1,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_suit_white.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 1,
            Bodygroups = "0000000000000"
        }
    },
    mountaineering_jacket1 = {
        PrintName = "White Mountaineering jacket",
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

    mountaineering_jacket2 = {
        PrintName = "Black Mountaineering jacket",
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
        PrintName = "Winter Pants",
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

    jacket1 = {
        PrintName = "Gray Winter jacket",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife/male_torso_anorak.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_torso_anorak.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.25
    },

    jacket2 = {
        PrintName = "Gray Wind jacket",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife/male_torso_windbreaker.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_torso_windbreaker.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.05
    },

    jacket3 = {
        PrintName = "Dark-gray jacket",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_TORSO] = true
        },
        Male = {
            Model = "models/tnb/halflife2/male_torso_leatherjacket2.mdl",
            HideSubMaterails = {"models/humans/male/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife2/female_torso_leatherjacket2.mdl",
            HideSubMaterails = {"models/humans/female/group01/players_sheet"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.07
    },

    -- jacket4 = {
    --     PrintName = "Black jacket",
    --     Model = "models/props_junk/cardboard_box003a.mdl",
    --     SlotOccupation = {
    --         [ZC_CLOTHES_SLOT_TORSO] = true
    --     },
    --     Male = {
    --         Model = "models/tnb/halflife2/male_torso_leatherjacket1.mdl",
    --         HideSubMaterails = {"models/humans/male/group01/players_sheet"},
    --         Skin = 0,
    --         Bodygroups = "0000000000000"
    --     },
    --     FeMale = {
    --         Model = "models/tnb/halflife2/female_torso_leatherjacket1.mdl",
    --         HideSubMaterails = {"models/humans/female/group01/players_sheet"},
    --         Skin = 0,
    --         Bodygroups = "0000000000000"
    --     },
    --     WarmSave = 0.07
    -- },

    cargo_pants1 = {
        PrintName = "Cargo Pants",
        Model = "models/props_junk/cardboard_box003a.mdl",
        SlotOccupation = {
            [ZC_CLOTHES_SLOT_PANTS] = true
        },
        Male = {
            Model = "models/tnb/halflife/male_legs_cargopants.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 5,
            Bodygroups = "0000000000000"
        },
        FeMale = {
            Model = "models/tnb/halflife/female_legs_cargopants.mdl",
            HideSubMaterails = {"distac/gloves/pants", "distac/gloves/cross"},
            Skin = 0,
            Bodygroups = "0000000000000"
        },
        WarmSave = 0.1
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