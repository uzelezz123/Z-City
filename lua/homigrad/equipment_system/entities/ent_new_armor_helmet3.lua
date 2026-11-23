
--\\ Armor Slots
    -- ZC_ARMOR_SLOT_HEAD = 4
    -- ZC_ARMOR_SLOT_FACE = 5
    --     ZC_ARMOR_SLOT_EYES = 6
    -- ZC_ARMOR_SLOT_EARS = 7

    -- ZC_ARMOR_SLOT_TORSO = 8
    --     ZC_ARMOR_SLOT_UPPERARM_L = 9
    --         ZC_ARMOR_SLOT_FOREARM_L = 10
    --     ZC_ARMOR_SLOT_UPPERARM_R = 11
    --         ZC_ARMOR_SLOT_FOREARM_R = 12  

    -- ZC_ARMOR_SLOT_BELLY = 13

    -- ZC_ARMOR_SLOT_PELVIS = 14
    --     ZC_ARMOR_SLOT_THIGH_L = 15
    --         ZC_ARMOR_SLOT_SHIN_L = 16
    --     ZC_ARMOR_SLOT_THIGH_R = 17
    --         ZC_ARMOR_SLOT_SHIN_R = 18
--//

if not load_from_armor_file then return end -- i'm sorry for that, but that way light than create Entity registration module
DEFINE_BASECLASS("ent_zcity_armor_base")
local ENT = {}
ENT.Type = "anim"
ENT.Base = "ent_zcity_armor_base"
ENT.PrintName = "Riot Helmet"
ENT.Category = "ZCity TestArmor"
ENT.Spawnable = true
ENT.Model = "models/eu_homicide/helmet.mdl"
ENT.ModelMaterial = nil
ENT.IconOverride = "vgui/icons/riothelm.png"
ENT.SlotOccupation = {                              -- Slots what armor occupate
    [ZC_ARMOR_SLOT_HEAD] = true,
}
ENT.ShouldRenderLocaly = false
ENT.Overlay = {}
ENT.Overlay.PosAdjust = Vector(-5.5,0,0)
ENT.Overlay.Fov = 35
ENT.Overlay.ModelMaterial = nil
ENT.Overlay.Model = "models/eu_homicide/helmet.mdl"

ENT.DrawOverlay = hg.DrawFirstPersonHelmet
--\\ Balistic settings                              -- soon can be enchanced, per plate material, durability and other stuff

--\\ HitBoxSets Hitbox Creation
    local HitBoxSet = "new_helmet3"
    ENT.HitBoxSet = HitBoxSet                     -- you can use same hitbox sets on other armor
    --\\ Plates HitBoxSets
        local color_yellow = Color(255,255,0)
        -- Fornt Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(6.5, -6, 0), Angle(0, 0, 0), Vector(2, 1, 3.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(5.5, -4.5, 0), Angle(0, 0, 0), Vector(2, 1, 3.5), color_yellow, true)
            hg.organism:CreateHitBox("Front",HitBox, HitBoxF)
        --//
    --//
    hg.organism:AddArmorInputList(HitBoxSet, ZC_ARMOR_SLOT_HEAD)
--//

    --\\ Plates
    local FP = "FrontPlate"
    local BP = "BackPlate"
    local SLP = "SideLPlate"
    local SRP = "SideRPlate"
    local TP = "TopPlate"

    ENT.PlatesLinks = { -- this is links to armor, table down here, key is name of UID HitBox, value is string link ["FrontPlate"] etc.
        Front =         FP,
    }

    -- ENT.SideLinks = {                 -- for penetration damage type change, cuz i don't want rewrite organism hitbox system fully
    --     Front =         "Front",
    --     FrontPlate =    "Front",
    --     FrontPlateDown ="Front",
    --     FrontPlateRight="Front",
    --     FrontPlateLeft= "Front",

    --     Back =          "Back",
    --     BackPlate =     "Back",
    --     BackPlateDown = "Back",
    --     BackPlateRight= "Back",
    --     BackPlateLeft=  "Back",

    --     LeftSide =      "Left",
    --     RightSide =     "Right"
    -- }

    --\\ FrontPlate
        ENT[FP] = {}
        ENT[FP].Protection = ZC_ARMOR_PROTCLASS_IIIA
            --\\ Protection classes
                -- ZC_ARMOR_PROTCLASS_II = 4
                -- ZC_ARMOR_PROTCLASS_IIIA = 8
                -- ZC_ARMOR_PROTCLASS_III = 12
                -- ZC_ARMOR_PROTCLASS_III_PLUS = 16
                -- ZC_ARMOR_PROTCLASS_IV = 22
        ENT[FP].ProtectionDamageMul = 0.6                   -- protected damage mul
        ENT[FP].PenetratedDamageMul = 0.9                   -- penetrated damage mul

        ENT[FP].BalisticMaterial = ZC_ARMOR_MATERIAL_UHMWPE -- actually this is just a mul of degradation armor
            --\\ BalisticMaterials
                -- ZC_ARMOR_MATERIAL_CERAMIC = 3
                -- ZC_ARMOR_MATERIAL_TITAN = 1.8
                -- ZC_ARMOR_MATERIAL_ARSTEEL = 1.4

                -- ZC_ARMOR_MATERIAL_KEVLAR = 0.9
                -- ZC_ARMOR_MATERIAL_KEVLAR_CERAMIC = 0.75
                -- ZC_ARMOR_MATERIAL_KEVLAR_ARSTEEL = 0.6
                -- ZC_ARMOR_MATERIAL_KEVLAR_TITAN = 0.45
                -- ZC_ARMOR_MATERIAL_FIBERGLASS
        ENT[FP].Durability = 50                            -- durability
        ENT[FP].DurabilityMax = 50                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[FP].DurabilityWarranty = 10                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[FP].NeedPunch = true                           -- viewpunch after impact
    --//       
--//

--\\ Render male model
ENT.Male = {}
ENT.Male.Model = "models/eu_homicide/helmet.mdl"
ENT.Male.ModelSubMaterials = {}                     -- submaterials on rendered model
ENT.Male.HideSubMaterails = {}                      -- playermodel hide submaterials
ENT.Male.Skin = 0                                   -- skin on rendered model
ENT.Male.Bodygroups = "0000000000000"               -- bodygroups on rendered model
--
ENT.Male.BoneMerge = false
ENT.Male.ParentBone = "ValveBiped.Bip01_Head1"     -- parent bone
ENT.Male.OffsetPos = Vector(2, 0.2, 0)
ENT.Male.OffsetAng = Angle(180, 110, 90)
ENT.Male.ModelSize = 1
--//

--\\ Render female model
ENT.FeMale = {}
ENT.FeMale.Model = "models/eu_homicide/helmet.mdl"
ENT.FeMale.ModelSubMaterials = {}                   -- submaterials on rendered model
ENT.FeMale.HideSubMaterails = {}                    -- playermodel hide submaterials
ENT.FeMale.Skin = 0                                 -- skin on rendered model
ENT.FeMale.Bodygroups = "0000000000000"             -- bodygroups on rendered model
--
ENT.FeMale.BoneMerge = false
ENT.FeMale.ParentBone = "ValveBiped.Bip01_Head1"   -- parent bone
ENT.FeMale.OffsetPos = Vector(1, 0, 0)
ENT.FeMale.OffsetAng = Angle(180, 110, 90)
ENT.FeMale.ModelSize = 1
--//
local filename = string.StripExtension(string.GetFileFromFilename( GetCurrentLuaFile() ))
scripted_ents.Register(ENT, filename)