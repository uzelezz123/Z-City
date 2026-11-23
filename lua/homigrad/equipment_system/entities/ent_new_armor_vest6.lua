
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
ENT.PrintName = "SWAT Balistic Vest"
ENT.Category = "ZCity TestArmor"
ENT.Spawnable = true
ENT.Model = "models/monolithservers2/kerry/sswat_armor.mdl"
ENT.ModelMaterial = nil
ENT.IconOverride = "vgui/icons/armor01.png"
ENT.SlotOccupation = {                              -- Slots what armor occupate
    [ZC_ARMOR_SLOT_TORSO] = true,
    [ZC_ARMOR_SLOT_BELLY] = true,
    [ZC_ARMOR_SLOT_PELVIS] = true
}

--\\ Balistic settings                              -- soon can be enchanced, per plate material, durability and other stuff

--\\ HitBoxSets Hitbox Creation
    local HitBoxSet = "new_vest6"
    ENT.HitBoxSet = HitBoxSet                     -- you can use same hitbox sets on other armor
    --\\ Plates HitBoxSets
        local color_yellow = Color(0,140,255)
        -- Fornt Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(5.8, 7, 0), Angle(0, -10, 0), Vector(5, 1.5, 5.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(3.5, 7, 0), Angle(0, -10, 0), Vector(5, 1.5, 5.5), color_yellow, true)
            hg.organism:CreateHitBox("Front",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(-1.2, 7.5, 0), Angle(0, 5, 0), Vector(4.8, 1.5, 5.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(-2.5, 6.5, 0), Angle(0, 5, 0), Vector(5.8, 1.5, 5.5), color_yellow, true)
            hg.organism:CreateHitBox("FrontDown",HitBox, HitBoxF)
        --//

        -- Back Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(5.8, -2.5, 0), Angle(0, 0, 0), Vector(5, 1.5, 5.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(3.8, -2.5, 0), Angle(0, 0, 0), Vector(5, 1.5, 5.5), color_yellow, true)
            hg.organism:CreateHitBox("Back", HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(0.5, -3.3, 0), Angle(0, 0, 0), Vector(4.5, 1.5, 5.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(-2, -3.3, 0), Angle(0, 0, 0), Vector(4.5, 1.5, 5.5), color_yellow, true)
            hg.organism:CreateHitBox("BackDown",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine", HitBoxSet, 1, Vector(-1.2, -3.6, 0), Angle(0, 10, 0), Vector(2.5, 1.5, 2.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine", HitBoxSet, 1, Vector(-3.2, -3.6, 0), Angle(0, 10, 0), Vector(2.5, 1, 2.5), color_yellow, true)
            hg.organism:CreateHitBox("BackDownPelvis",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine", HitBoxSet, 1, Vector(-1.2, -3.6, -3), Angle(40, 10, 0), Vector(2, 1.5, 1.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine", HitBoxSet, 1, Vector(-3.2, -3.6, -3), Angle(40, 10, 0), Vector(2, 1, 1.5), color_yellow, true)
            hg.organism:CreateHitBox("BackDownPelvisR",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine", HitBoxSet, 1, Vector(-1.2, -3.2, 3), Angle(-40, 10, 0), Vector(2, 1.5, 1.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine", HitBoxSet, 1, Vector(-3.2, -3.2, 3), Angle(-40, 10, 0), Vector(2, 1, 1.5), color_yellow, true)
            hg.organism:CreateHitBox("BackDownPelvisL",HitBox, HitBoxF)
        --//

        -- Side Plates (kevlar... but soon)
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(-1, 2.5, 6), Angle(0, 0, 90), Vector(4.5, 1, 5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(-3, 2.5, 6), Angle(0, 0, 90), Vector(4.5, 1, 5), color_yellow, true)
            hg.organism:CreateHitBox("LeftSide",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(-1, 2.5, -6), Angle(0, 0, 90), Vector(4.5, 1, 5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine1", HitBoxSet, 1, Vector(-3, 2.5, -6), Angle(0, 0, 90), Vector(4.5, 1, 5), color_yellow, true)
            hg.organism:CreateHitBox("RightSide",HitBox, HitBoxF)
        --//
    --//
    hg.organism:AddArmorInputList(HitBoxSet, ZC_ARMOR_SLOT_TORSO)
--//

    --\\ Plates
    local FP = "FrontKevlar"
    local BP = "BackKevlar"
    local LP = "LeftKevlar"
    local RP = "RightKevlar"

    ENT.PlatesLinks = { -- this is links to armor, table down here, key is name of UID HitBox, value is string link ["FrontPlate"] etc.
        Front =         FP,
        FrontDown =     FP,

        Back =          BP,
        BackDown =      BP,
        BackDownPelvis =BP,
        BackDownPelvisR=BP,
        BackDownPelvisL=BP,

        LeftSide =      LP,
        RightSide =     RP
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
        ENT[FP].Protection = ZC_ARMOR_PROTCLASS_III_PLUS
            --\\ Protection classes
                -- ZC_ARMOR_PROTCLASS_II = 4
                -- ZC_ARMOR_PROTCLASS_IIIA = 8
                -- ZC_ARMOR_PROTCLASS_III = 12
                -- ZC_ARMOR_PROTCLASS_III_PLUS = 16
                -- ZC_ARMOR_PROTCLASS_IV = 22
        ENT[FP].ProtectionDamageMul = 0.7                   -- protected damage mul
        ENT[FP].PenetratedDamageMul = 1                      -- penetrated damage mul

        ENT[FP].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
            --\\ BalisticMaterials
                -- ZC_ARMOR_MATERIAL_CERAMIC = 3
                -- ZC_ARMOR_MATERIAL_TITAN = 1.8
                -- ZC_ARMOR_MATERIAL_ARSTEEL = 1.4

                -- ZC_ARMOR_MATERIAL_KEVLAR = 0.9
                -- ZC_ARMOR_MATERIAL_KEVLAR_CERAMIC = 0.75
                -- ZC_ARMOR_MATERIAL_KEVLAR_ARSTEEL = 0.6
                -- ZC_ARMOR_MATERIAL_KEVLAR_TITAN = 0.45
        ENT[FP].Durability = 60                            -- durability
        ENT[FP].DurabilityMax = 60                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[FP].DurabilityWarranty = 25                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[FP].NeedPunch = false                           -- viewpunch after impact
    --//       
    
    --\\ BackPlate
        ENT[BP] = {}
        ENT[BP].Protection = ZC_ARMOR_PROTCLASS_III_PLUS
        ENT[BP].ProtectionDamageMul = 0.7                   -- protected damage mul
        ENT[BP].PenetratedDamageMul = 1                   -- penetrated damage mul

        ENT[BP].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
        ENT[BP].Durability = 60                            -- durability
        ENT[BP].DurabilityMax = 60                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[BP].DurabilityWarranty = 25                    -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[BP].NeedPunch = false                           -- viewpunch after impact
    --//  

    --\\ LeftPlate
        ENT[LP] = {}
        ENT[LP].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[LP].ProtectionDamageMul = 0.8                   -- protected damage mul
        ENT[LP].PenetratedDamageMul = 1                   -- penetrated damage mul

        ENT[LP].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
        ENT[LP].Durability = 25                            -- durability
        ENT[LP].DurabilityMax = 25                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[LP].DurabilityWarranty = 20                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[LP].NeedPunch = false                           -- viewpunch after impact
    --//  

    --\\ RightPlate
        ENT[RP] = {}
        ENT[RP].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[RP].ProtectionDamageMul = 0.8                   -- protected damage mul
        ENT[RP].PenetratedDamageMul = 1                   -- penetrated damage mul

        ENT[RP].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
        ENT[RP].Durability = 25                            -- durability
        ENT[RP].DurabilityMax = 25                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[RP].DurabilityWarranty = 20                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[RP].NeedPunch = false                           -- viewpunch after impact
    --//  
--//

--\\ Render male model
ENT.Male = {}
ENT.Male.Model = "models/monolithservers2/kerry/sswat_armor.mdl"
ENT.Male.ModelSubMaterials = {}                     -- submaterials on rendered model
ENT.Male.HideSubMaterails = {}                      -- playermodel hide submaterials
ENT.Male.Skin = 0                                   -- skin on rendered model
ENT.Male.Bodygroups = "0000000000000"               -- bodygroups on rendered model
--
ENT.Male.BoneMerge = true
ENT.Male.ParentBone = "ValveBiped.Bip01_Spine2"     -- parent bone
ENT.Male.OffsetPos = Vector(-1, 2, 0)
ENT.Male.OffsetAng = Angle(0,88,90)
ENT.Male.ModelSize = 1
--//

--\\ Render female model
ENT.FeMale = {}
ENT.FeMale.Model = "models/monolithservers2/kerry/sswat_armor.mdl"
ENT.FeMale.ModelSubMaterials = {}                   -- submaterials on rendered model
ENT.FeMale.HideSubMaterails = {}                    -- playermodel hide submaterials
ENT.FeMale.Skin = 0                                 -- skin on rendered model
ENT.FeMale.Bodygroups = "0000000000000"             -- bodygroups on rendered model
--
ENT.FeMale.BoneMerge = false
ENT.FeMale.ParentBone = "ValveBiped.Bip01_Spine2"   -- parent bone
ENT.FeMale.OffsetPos = Vector(-11,2,0)
ENT.FeMale.OffsetAng = Angle(0,90,90)
ENT.FeMale.ModelSize = 0.95
--//
local filename = string.StripExtension(string.GetFileFromFilename( GetCurrentLuaFile() ))
scripted_ents.Register(ENT, filename)
