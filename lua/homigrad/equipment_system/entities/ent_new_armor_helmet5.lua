
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
ENT.PrintName = "SWAT Balistic Helmet"
ENT.Category = "ZCity TestArmor"
ENT.Spawnable = true
ENT.Model = "models/monolithservers2/kerry/swat_hat.mdl"
ENT.ModelMaterial = nil
ENT.IconOverride = "vgui/icons/helmet.png"
ENT.SlotOccupation = {                              -- Slots what armor occupate
    [ZC_ARMOR_SLOT_HEAD] = true,
}
ENT.ShouldRenderLocaly = false
ENT.Overlay = {}
ENT.Overlay.PosAdjust = Vector(-3,0,-1.8)
ENT.Overlay.Fov = -40
ENT.Overlay.ModelMaterial = nil
ENT.Overlay.Model = "models/monolithservers2/kerry/swat_hat.mdl"

ENT.DrawOverlay = hg.DrawFirstPersonHelmet
--\\ Balistic settings                              -- soon can be enchanced, per plate material, durability and other stuff

--\\ HitBoxSets Hitbox Creation
    local HitBoxSet = "new_helmet5"
    ENT.HitBoxSet = HitBoxSet                     -- you can use same hitbox sets on other armor
    --\\ Plates HitBoxSets
        local color_yellow = Color(255,255,0)
        -- Fornt Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(6.5, -6, 0), Angle(0, 0, 0), Vector(2, 1, 3.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(5.5, -4.5, 0), Angle(0, 0, 0), Vector(2, 1, 3.5), color_yellow, true)
            hg.organism:CreateHitBox("Front",HitBox, HitBoxF)
        --//

        --\\ Back Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(4.5, 3, 0), Angle(0, 0, 0), Vector(4, 1, 3.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(3.5, 4.5, 0), Angle(0, 0, 0), Vector(4, 1, 3.5), color_yellow, true)
            hg.organism:CreateHitBox("Back",HitBox, HitBoxF)
        --//

        --\\ Top Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(7.8, -1.5, 0), Angle(0, 0, 0), Vector(1, 3.5, 3.5), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(6.8, 0, 0), Angle(0, 0, 0), Vector(1, 3.5, 3.5), color_yellow, true)
            hg.organism:CreateHitBox("Top",HitBox, HitBoxF)
        --//

        --\\ SideR Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(5.8, -3.5, 3.5), Angle(0, 15, 0), Vector(1.8, 2, 1), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(4.8, -2, 3.5), Angle(0, 15, 0), Vector(1.8, 2, 1), color_yellow, true)
            hg.organism:CreateHitBox("SideR",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(4, 1, 3.5), Angle(0, 0, 0), Vector(3, 1, 1), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(3, 2.5, 3.5), Angle(0, 0, 0), Vector(3, 1, 1), color_yellow, true)
            hg.organism:CreateHitBox("SideR1",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(4.5, -0.5, 3.5), Angle(0, 35, 0), Vector(2, 2, 1), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(3.5, 1, 3.5), Angle(0, 35, 0), Vector(2, 2, 1), color_yellow, true)
            hg.organism:CreateHitBox("SideR2",HitBox, HitBoxF)
        --//

        --\\ SideL Plate
            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(5.8, -3.5, -3.5), Angle(0, 15, 0), Vector(1.8, 2, 1), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(4.8, -2, -3.5), Angle(0, 15, 0), Vector(1.8, 2, 1), color_yellow, true)
            hg.organism:CreateHitBox("SideL",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(4, 1, -3.5), Angle(0, 0, 0), Vector(3, 1, 1), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(3, 2.5, -3.5), Angle(0, 0, 0), Vector(3, 1, 1), color_yellow, true)
            hg.organism:CreateHitBox("SideL1",HitBox, HitBoxF)

            local HitBox = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(4.5, -0.5, -3.5), Angle(0, 35, 0), Vector(2, 2, 1), color_yellow, true)
            local HitBoxF = hg.organism:HitBox("ValveBiped.Bip01_Head1", HitBoxSet, 1, Vector(3.5, 1, -3.5), Angle(0, 35, 0), Vector(2, 2, 1), color_yellow, true)
            hg.organism:CreateHitBox("SideL2",HitBox, HitBoxF)
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
        Back =          BP,

        SideR =          SRP,
        SideR1 =          SRP,
        SideR2 =          SRP,

        SideL =          SLP,
        SideL1 =          SLP,
        SideL2 =          SLP,

        Top =           TP,
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
        ENT[FP].Durability = 50                            -- durability
        ENT[FP].DurabilityMax = 50                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[FP].DurabilityWarranty = 10                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[FP].NeedPunch = true                           -- viewpunch after impact
    --//       
    
    --\\ BackPlate
        ENT[BP] = {}
        ENT[BP].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[BP].ProtectionDamageMul = 0.6                   -- protected damage mul
        ENT[BP].PenetratedDamageMul = 0.9                   -- penetrated damage mul

        ENT[BP].BalisticMaterial = ZC_ARMOR_MATERIAL_UHMWPE -- actually this is just a mul of degradation armor
        ENT[BP].Durability = 50                            -- durability
        ENT[BP].DurabilityMax = 50                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[BP].DurabilityWarranty = 10                    -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[BP].NeedPunch = true                           -- viewpunch after impact
    --//  

    --\\ TopPlate
        ENT[TP] = {}
        ENT[TP].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[TP].ProtectionDamageMul = 0.6                   -- protected damage mul
        ENT[TP].PenetratedDamageMul = 0.9                   -- penetrated damage mul

        ENT[TP].BalisticMaterial = ZC_ARMOR_MATERIAL_UHMWPE -- actually this is just a mul of degradation armor
        ENT[TP].Durability = 50                            -- durability
        ENT[TP].DurabilityMax = 50                         -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[TP].DurabilityWarranty = 10                    -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[TP].NeedPunch = true                           -- viewpunch after impact
    --// 

    --\\ SideLPlate
        ENT[SLP] = {}
        ENT[SLP].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[SLP].ProtectionDamageMul = 0.6                   -- protected damage mul
        ENT[SLP].PenetratedDamageMul = 0.9                   -- penetrated damage mul

        ENT[SLP].BalisticMaterial = ZC_ARMOR_MATERIAL_UHMWPE -- actually this is just a mul of degradation armor
        ENT[SLP].Durability = 25                             -- durability
        ENT[SLP].DurabilityMax = 25                          -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[SLP].DurabilityWarranty = 10                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[SLP].NeedPunch = true                           -- viewpunch after impact
    --//  

    --\\ SideRPlate
        ENT[SRP] = {}
        ENT[SRP].Protection = ZC_ARMOR_PROTCLASS_IIIA
        ENT[SRP].ProtectionDamageMul = 0.6                   -- protected damage mul
        ENT[SRP].PenetratedDamageMul = 0.9                   -- penetrated damage mul

        ENT[SRP].BalisticMaterial = ZC_ARMOR_MATERIAL_UHMWPE -- actually this is just a mul of degradation armor
        ENT[SRP].Durability = 25                             -- durability
        ENT[SRP].DurabilityMax = 25                          -- max durability, for the future repair armor (yeah i'm doing immersive shit)
        ENT[SRP].DurabilityWarranty = 10                     -- guarantee that the protection level will not decrease (no debuff) upon the degradation

        ENT[SRP].NeedPunch = true                           -- viewpunch after impact
    --//  
--//

--\\ Render male model
ENT.Male = {}
ENT.Male.Model = "models/monolithservers2/kerry/swat_hat.mdl"
ENT.Male.ModelSubMaterials = {}                     -- submaterials on rendered model
ENT.Male.HideSubMaterails = {}                      -- playermodel hide submaterials
ENT.Male.Skin = 0                                   -- skin on rendered model
ENT.Male.Bodygroups = "0000000000000"               -- bodygroups on rendered model
--
ENT.Male.BoneMerge = false
ENT.Male.ParentBone = "ValveBiped.Bip01_Head1"     -- parent bone
ENT.Male.OffsetPos = Vector(0, 0, 0)
ENT.Male.OffsetAng = Angle(180, 100, 90)
ENT.Male.ModelSize = 1
--//

--\\ Render female model
ENT.FeMale = {}
ENT.FeMale.Model = "models/monolithservers2/kerry/swat_hat.mdl"
ENT.FeMale.ModelSubMaterials = {}                   -- submaterials on rendered model
ENT.FeMale.HideSubMaterails = {}                    -- playermodel hide submaterials
ENT.FeMale.Skin = 0                                 -- skin on rendered model
ENT.FeMale.Bodygroups = "0000000000000"             -- bodygroups on rendered model
--
ENT.FeMale.BoneMerge = false
ENT.FeMale.ParentBone = "ValveBiped.Bip01_Head1"   -- parent bone
ENT.FeMale.OffsetPos = Vector(0, 0, 0)
ENT.FeMale.OffsetAng = Angle(180, 100, 90)
ENT.FeMale.ModelSize = 1
--//
local filename = string.StripExtension(string.GetFileFromFilename( GetCurrentLuaFile() ))
scripted_ents.Register(ENT, filename)