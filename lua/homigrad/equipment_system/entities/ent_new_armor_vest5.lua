
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
ENT.PrintName = "MF-UNTAR Body Armor"
ENT.Category = "ZCity TestArmor"
ENT.Spawnable = true
ENT.Model = "models/eft_props/gear/armor/ar_untar.mdl"
ENT.ModelMaterial = nil
ENT.IconOverride = "entities/ent_jack_gmod_ezarmor_untar.png"
ENT.SlotOccupation = {                              -- Slots what armor occupate
    [ZC_ARMOR_SLOT_TORSO] = true,
    [ZC_ARMOR_SLOT_BELLY] = true,
}

--\\ Balistic settings                              -- soon can be enchanced, per plate material, durability and other stuff

--\\ HitBoxSets Hitbox Creation
    local HitBoxSet = "new_vest5"
    ENT.HitBoxSet = HitBoxSet                     -- you can use same hitbox sets on other armor
    --\\ Plates HitBoxSets
        local color_blue = Color(0,140,255)
        local color_yellow = Color(255,238,0)
        -- Fornt Kevlar
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(2, 7.5, 0), Angle(0, -10, 0), Vector(7.5, 1.5, 5.5), color_blue, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(-0.5, 6.5, 0), Angle(0, 0, 0), Vector(7.5, 1.5, 5.5), color_blue, true)
            hg.organism:CreateHitBox("Front",HitBox, HitBoxF)
        --//

        -- Back Kevlar
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(2.4, -3, 0), Angle(0, 0, 0), Vector(7.9, 1.5, 5.5), color_blue, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(0.5, -3.5, 0), Angle(0, 0, 0), Vector(7.5, 1.5, 5.5), color_blue, true)
            hg.organism:CreateHitBox("Back", HitBox, HitBoxF)
        --//

        -- Side Kevlar (kevlar... but soon)
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(-0.5, 2.5, 6), Angle(0, 5, 90), Vector(4.5, 1, 5), color_blue, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(-3, 1, 6), Angle(0, 5, 90), Vector(4.5, 1, 5), color_blue, true)
            hg.organism:CreateHitBox("LeftSide",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(-0.5, 2.5, -6), Angle(0, 5, 90), Vector(4.5, 1, 5), color_blue, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Spine2", HitBoxSet, 1, Vector(-3, 1, -6), Angle(0, 5, 90), Vector(4.5, 1, 5), color_blue, true)
            hg.organism:CreateHitBox("RightSide",HitBox, HitBoxF)
        --//
    --//
    hg.organism:AddArmorInputList(HitBoxSet, ZC_ARMOR_SLOT_TORSO)
--//

    --\\ Plates
    local FP = "FrontPlate"
    local BP = "BackPlate"
    local FK = "FrontKevlar"
    local BK = "BackKevlar"
    local LK = "LeftKevlar"
    local RK = "RightKevlar"

    ENT.PlatesLinks = { -- this is links to armor, table down here, key is name of UID HitBox, value is string link ["FrontPlate"] etc.
        Front =         FK,

        Back =          BK,

        LeftSide =      LK,
        RightSide =     RK
    }

    ENT.SideLinks = {                 -- for penetration damage type change, cuz i don't want rewrite organism hitbox system fully
        Front =         "Front",
        Back =          "Back",
        LeftSide =      "Left",
        RightSide =     "Right"
    }

    --\\ FrontKevlar
        ENT[FK] = {}
        ENT[FK].Protection = ZC_ARMOR_PROTCLASS_III
            --\\ Protection classes
                -- ZC_ARMOR_PROTCLASS_II = 4
                -- ZC_ARMOR_PROTCLASS_IIIA = 8
                -- ZC_ARMOR_PROTCLASS_III = 12
                -- ZC_ARMOR_PROTCLASS_III_PLUS = 16
                -- ZC_ARMOR_PROTCLASS_IV = 22
        ENT[FK].ProtectionDamageMul = 0.4                   -- protected damage mul
        ENT[FK].PenetratedDamageMul = 0.8                      -- penetrated damage mul

        ENT[FK].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
            --\\ BalisticMaterials
                -- ZC_ARMOR_MATERIAL_CERAMIC = 3
                -- ZC_ARMOR_MATERIAL_TITAN = 1.8
                -- ZC_ARMOR_MATERIAL_ARSTEEL = 1.4

                -- ZC_ARMOR_MATERIAL_KEVLAR = 0.9
                -- ZC_ARMOR_MATERIAL_KEVLAR_CERAMIC = 0.75
                -- ZC_ARMOR_MATERIAL_KEVLAR_ARSTEEL = 0.6
                -- ZC_ARMOR_MATERIAL_KEVLAR_TITAN = 0.45
        ENT[FK].Durability = 60                            -- durability
        ENT[FK].DurabilityMax = 60                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[FK].DurabilityWarranty = 25                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[FK].NeedPunch = false                           -- viewpunch after impact
    --//
    
    --\\ BackKevlar
        ENT[BK] = {}
        ENT[BK].Protection = ZC_ARMOR_PROTCLASS_III
        ENT[BK].ProtectionDamageMul = 0.4                   -- protected damage mul
        ENT[BK].PenetratedDamageMul = 0.6                   -- penetrated damage mul

        ENT[BK].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
        ENT[BK].Durability = 60                            -- durability
        ENT[BK].DurabilityMax = 60                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[BK].DurabilityWarranty = 25                    -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[BK].NeedPunch = false                           -- viewpunch after impact
    --// 

    --\\ LeftKevlar
        ENT[LK] = {}
        ENT[LK].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[LK].ProtectionDamageMul = 0.4                   -- protected damage mul
        ENT[LK].PenetratedDamageMul = 0.8                   -- penetrated damage mul

        ENT[LK].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
        ENT[LK].Durability = 25                            -- durability
        ENT[LK].DurabilityMax = 25                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[LK].DurabilityWarranty = 20                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[LK].NeedPunch = false                           -- viewpunch after impact
    --//  

    --\\ RightKevlar
        ENT[RK] = {}
        ENT[RK].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[RK].ProtectionDamageMul = 0.4                   -- protected damage mul
        ENT[RK].PenetratedDamageMul = 0.8                   -- penetrated damage mul

        ENT[RK].BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
        ENT[RK].Durability = 25                            -- durability
        ENT[RK].DurabilityMax = 25                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[RK].DurabilityWarranty = 20                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[RK].NeedPunch = false                           -- viewpunch after impact
    --//  
--//

--\\ Render male model
ENT.Male = {}
ENT.Male.Model = "models/eft_props/gear/armor/ar_untar.mdl"
ENT.Male.ModelSubMaterials = {}                     -- submaterials on rendered model
ENT.Male.HideSubMaterails = {}                      -- playermodel hide submaterials
ENT.Male.Skin = 0                                   -- skin on rendered model
ENT.Male.Bodygroups = "0000000000000"               -- bodygroups on rendered model
--
ENT.Male.BoneMerge = false
ENT.Male.ParentBone = "ValveBiped.Bip01_Spine2"     -- parent bone
ENT.Male.OffsetPos = Vector(-0.4, 2.9, 0)
ENT.Male.OffsetAng = Angle(0, 92, 90)
ENT.Male.ModelSize = 0.9
--//

--\\ Render female model
ENT.FeMale = {}
ENT.FeMale.Model = "models/eft_props/gear/armor/ar_untar.mdl"
ENT.FeMale.ModelSubMaterials = {}                   -- submaterials on rendered model
ENT.FeMale.HideSubMaterails = {}                    -- playermodel hide submaterials
ENT.FeMale.Skin = 0                                 -- skin on rendered model
ENT.FeMale.Bodygroups = "0000000000000"             -- bodygroups on rendered model
--
ENT.FeMale.BoneMerge = false
ENT.FeMale.ParentBone = "ValveBiped.Bip01_Spine2"   -- parent bone
ENT.FeMale.OffsetPos = Vector(-1.5, 0, 1.5)
ENT.FeMale.OffsetAng = Angle(0, 92, 90)
ENT.FeMale.ModelSize = 0.82
--//
local filename = string.StripExtension(string.GetFileFromFilename( GetCurrentLuaFile() ))
scripted_ents.Register(ENT, filename)
