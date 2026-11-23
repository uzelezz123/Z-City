
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
ENT.PrintName = "Balistic Mask NIJ IIIA"
ENT.Category = "ZCity TestArmor"
ENT.Spawnable = true
ENT.Model = "models/jmod/ballistic_mask.mdl"
ENT.ModelMaterial = "sal/hanker"
ENT.IconOverride = "vgui/icons/ballisticmask"
ENT.SlotOccupation = {                              -- Slots what armor occupate
    [ZC_ARMOR_SLOT_HEAD] = true,
    [ZC_ARMOR_SLOT_FACE] = true,
    [ZC_ARMOR_SLOT_EYES] = true,
}
ENT.ShouldRenderLocaly = false
ENT.OverlayMaterial = Material("sprites/mat_jack_hmcd_narrow")

ENT.DrawOverlay = hg.DrawSimpleOverlay
--\\ Balistic settings                              -- soon can be enchanced, per plate material, durability and other stuff

--\\ HitBoxSets Hitbox Creation
    local HitBoxSet = "new_mask1"
    ENT.HitBoxSet = HitBoxSet                     -- you can use same hitbox sets on other armor
    --\\ Plates HitBoxSets
        local color_yellow = Color(255,255,0)
        -- Fornt Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(3.5, -4.5, 0), Angle(0, 0, 0), Vector(5, 2.5, 3.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(2.5, -4.5, 0), Angle(0, 0, 0), Vector(5, 2.5, 3.5), color_yellow, true)
            hg.organism:CreateHitBox("Front",HitBox, HitBoxF)
        --//
    --//
    hg.organism:AddArmorInputList(HitBoxSet, ZC_ARMOR_SLOT_HEAD)
--//

    --\\ Plates
    local FP = "FrontPlate"

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

        ENT[FP].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
            --\\ BalisticMaterials
                -- ZC_ARMOR_MATERIAL_CERAMIC = 3
                -- ZC_ARMOR_MATERIAL_TITAN = 1.8
                -- ZC_ARMOR_MATERIAL_ARSTEEL = 1.4

                -- ZC_ARMOR_MATERIAL_KEVLAR = 0.9
                -- ZC_ARMOR_MATERIAL_KEVLAR_CERAMIC = 0.75
                -- ZC_ARMOR_MATERIAL_KEVLAR_ARSTEEL = 0.6
                -- ZC_ARMOR_MATERIAL_KEVLAR_TITAN = 0.45
        ENT[FP].Durability = 50                            -- durability
        ENT[FP].DurabilityMax = 50                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[FP].DurabilityWarranty = 25                    -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[FP].NeedPunch = true                           -- viewpunch after impact
    --//       
--//

--\\ Render male model
ENT.Male = {}
ENT.Male.Model = "models/jmod/ballistic_mask.mdl"
ENT.Male.ModelSubMaterials = {[0] = "sal/hanker"}                     -- submaterials on rendered model
ENT.Male.HideSubMaterails = {}                      -- playermodel hide submaterials
ENT.Male.Skin = 0                                   -- skin on rendered model
ENT.Male.Bodygroups = "0000000000000"               -- bodygroups on rendered model
--
ENT.Male.BoneMerge = false
ENT.Male.ParentBone = "ValveBiped.Bip01_Head1"     -- parent bone
ENT.Male.OffsetPos = Vector(4.55, -0.8, 0)
ENT.Male.OffsetAng = Angle(180, 90, 90)
ENT.Male.ModelSize = 1
--//

--\\ Render female model
ENT.FeMale = {}
ENT.FeMale.Model = "models/jmod/ballistic_mask.mdl"
ENT.FeMale.ModelSubMaterials = {[0] = "sal/hanker"}                   -- submaterials on rendered model
ENT.FeMale.HideSubMaterails = {}                    -- playermodel hide submaterials
ENT.FeMale.Skin = 0                                 -- skin on rendered model
ENT.FeMale.Bodygroups = "0000000000000"             -- bodygroups on rendered model
--
ENT.FeMale.BoneMerge = false
ENT.FeMale.ParentBone = "ValveBiped.Bip01_Head1"   -- parent bone
ENT.FeMale.OffsetPos = Vector(3.5, -0.8, 0)
ENT.FeMale.OffsetAng = Angle(180, 90, 90)
ENT.FeMale.ModelSize = 0.95
--//
local filename = string.StripExtension(string.GetFileFromFilename( GetCurrentLuaFile() ))
scripted_ents.Register(ENT, filename)