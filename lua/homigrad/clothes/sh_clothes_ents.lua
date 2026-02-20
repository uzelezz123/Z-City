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
        }
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
    }
}

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

        scripted_ents.Register(ENT, "ent_zcity_colthes_" .. k)
    end
end

register()
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