local CLASS = player.RegClass("Refugee")

local combines = {
    "npc_combine_s",
    "npc_metropolice",
    "npc_helicopter",
    "npc_combinegunship",
    "npc_combine",
    "npc_stalker",
    "npc_hunter",
    "npc_strider",
    "npc_turret_floor",
	"npc_combine_camera",
    "npc_manhack",
    "npc_cscanner",
    "npc_clawscanner"
}

local rebels = {
    "npc_barney",
    "npc_citizen",
    "npc_dog",
    "npc_eli",
    "npc_kleiner",
    "npc_magnusson",
    "npc_monk",
    "npc_mossman",
    "npc_odessa",
    "npc_rollermine_hacked",
    "npc_turret_floor_resistance",
    "npc_vortigaunt",
    "npc_alyx"
}

function CLASS.Off(self)
    if CLIENT then return end
    
    for k,v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(rebels,v:GetClass()) then
            v:AddEntityRelationship( self, D_HT, 99 )
        elseif table.HasValue(combines,v:GetClass()) then
            v:AddEntityRelationship( self, D_LI, 0 )
        end
    end
end

CLASS.CanUseDefaultPhrase = true

local SubMaterials = {
    -- Male
    ["models/player/group01/male_01.mdl"] = 3,
    ["models/player/group01/male_02.mdl"] = 2,
    ["models/player/group01/male_03.mdl"] = 4,
    ["models/player/group01/male_04.mdl"] = 4,
    ["models/player/group01/male_05.mdl"] = 4,
    ["models/player/group01/male_06.mdl"] = 0,
    ["models/player/group01/male_07.mdl"] = 4,
    ["models/player/group01/male_08.mdl"] = 0,
    ["models/player/group01/male_09.mdl"] = 2,
    -- FEMKI
    ["models/player/group01/female_01.mdl"] = 2,
    ["models/player/group01/female_02.mdl"] = 3,
    ["models/player/group01/female_03.mdl"] = 3,
    ["models/player/group01/female_04.mdl"] = 1,
    ["models/player/group01/female_05.mdl"] = 2,
    ["models/player/group01/female_06.mdl"] = 4
}


local commander_models = {
    ["Male 01"]   = "models/player/group03/male_01.mdl",
    ["Male 02"]   = "models/player/group03/male_02.mdl",
    ["Male 03"]   = "models/player/group03/male_03.mdl",
    ["Male 04"]   = "models/player/group03/male_04.mdl",
    ["Male 05"]   = "models/player/group03/male_05.mdl",
    ["Male 06"]   = "models/player/group03/male_06.mdl",
    ["Male 07"]   = "models/player/group03/male_07.mdl",
    ["Male 08"]   = "models/player/group03/male_08.mdl",
    ["Male 09"]   = "models/player/group03/male_09.mdl",
    ["Female 01"] = "models/player/group03/female_01.mdl",
    ["Female 02"] = "models/player/group03/female_02.mdl",
    ["Female 03"] = "models/player/group03/female_03.mdl",
    ["Female 04"] = "models/player/group03/female_04.mdl",
    ["Female 05"] = "models/player/group03/female_05.mdl",
    ["Female 06"] = "models/player/group03/female_06.mdl"
}


local commander_submaterials = {
    ["models/player/group03/male_01.mdl"] = 0,
    ["models/player/group03/male_02.mdl"] = 0,
    ["models/player/group03/male_03.mdl"] = 0,
    ["models/player/group03/male_04.mdl"] = 0,
    ["models/player/group03/male_05.mdl"] = 0,
    ["models/player/group03/male_06.mdl"] = 0,
    ["models/player/group03/male_07.mdl"] = 0,
    ["models/player/group03/male_08.mdl"] = 0,
    ["models/player/group03/male_09.mdl"] = 0,
    ["models/player/group03/female_01.mdl"] = 0,
    ["models/player/group03/female_02.mdl"] = 0,
    ["models/player/group03/female_03.mdl"] = 0,
    ["models/player/group03/female_04.mdl"] = 0,
    ["models/player/group03/female_05.mdl"] = 0,
    ["models/player/group03/female_06.mdl"] = 0
}

local primary = {
    "weapon_doublebarrel",
    "weapon_mp5",
    "weapon_mp7",
    "weapon_sks",
    "weapon_vpo136",
    "weapon_winchester",
}

local secondary = {
    "weapon_m9beretta",
    "weapon_browninghp",
    "weapon_revolver357",
    "weapon_revolver2",
    "weapon_hk_usp",
    "weapon_glock17",
}

local helmet = {
    "helmet1",
    "",
    "",
}

local face = {
    "",
    "",
    "",
    "",
    "",
}

local vest = {
    "vest2",
    "",
    "",
}

local commanderModels = {
    "models/humans/group03/male_01.mdl",
    "models/humans/group03/male_02.mdl",
    "models/humans/group03/male_03.mdl",
    "models/humans/group03/male_04.mdl",
    "models/humans/group03/male_05.mdl",
    "models/humans/group03/male_06.mdl",
    "models/humans/group03/male_07.mdl",
    "models/humans/group03/male_08.mdl",
    "models/humans/group03/male_09.mdl"
}

local medic = {
    ["models/1000shells/hl2rp/rebels/rebels_standart/van.mdl"] = "models/humans/group03m/male_01.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/ted.mdl"] = "models/humans/group03m/male_02.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/joe.mdl"] = "models/humans/group03m/male_03.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/eric.mdl"] = "models/humans/group03m/male_04.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/art.mdl"] = "models/humans/group03m/male_05.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/sandro.mdl"] ="models/humans/group03m/male_06.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/mike.mdl"] = "models/humans/group03m/male_07.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/vance.mdl"] = "models/humans/group03m/male_08.mdl",
    ["models/1000shells/hl2rp/rebels/rebels_standart/erdim.mdl"] = "models/humans/group03m/male_09.mdl",

    ["models/player/group01/female_01.mdl"] = "models/Humans/group03m/female_01.mdl",
    ["models/player/group01/female_02.mdl"] = "models/player/group03m/female_02.mdl",
    ["models/player/group01/female_03.mdl"] = "models/player/group03m/female_03.mdl",
    ["models/player/group01/female_04.mdl"] = "models/player/group03m/female_04.mdl",
    ["models/player/group01/female_05.mdl"] = "models/player/group03m/female_05.mdl",
    ["models/player/group01/female_06.mdl"] = "models/player/group03m/female_06.mdl"
}

function CLASS.GiveEquipment(self, class)
    local currentRound = CurrentRound and CurrentRound()
    if currentRound and currentRound.name == "defense" then
        return
    end
    
    local ply = self
    
    local wep = ply:Give(primary[math.random(#primary)])
    ply:GiveAmmo(wep:GetMaxClip1() * 2, wep:GetPrimaryAmmoType(), true)

    local wep = ply:Give(secondary[math.random(#secondary)])
    ply:GiveAmmo(wep:GetMaxClip1() * 2, wep:GetPrimaryAmmoType(), true)

    if class ~= "medic" then
        --local wep = ply:Give("weapon_hg_hl2nade_tpik")
        --wep.count = 3
    end

    ply.armors = {}
    local vesta = vest[math.random(#vest)]
    local facea = face[math.random(#face)]
    local helmeta = helmet[math.random(#helmet)]
    hg.AddArmor(ply, vesta)
    hg.AddArmor(ply, helmeta)
    hg.AddArmor(ply, facea)

    ply:SyncArmor()

    ply:Give("weapon_melee")
    ply:Give("weapon_walkie_talkie")
    
    if class == "medic" then
        ply:Give("weapon_bandage_sh")
        ply:Give("weapon_medkit_sh")
        ply:Give("weapon_painkillers")
        ply:Give("weapon_tourniquet")
    end
end

function CLASS.On(self, data)
    if CLIENT then return end
    
    
    if type(data) == "table" then
        bNoEquipment = data.bNoEquipment
    elseif type(data) == "boolean" then
        bNoEquipment = data
    end
    
    local currentRound = CurrentRound and CurrentRound()
    local isDefenseMode = currentRound and currentRound.name == "defense"
    local isCommander = self:GetNWString("PlayerRole") == "Commander"

    if isDefenseMode and isCommander then
        local specialModelChance = math.random(1, 1000000)
        if specialModelChance == 1 then
            self:SetModel("models/dejtriyev/dreamybuss/prigozhin.mdl")
        else
            local appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
            appearance.AAttachments = ""
            appearance.AColthes = ""
            local currentModel = string.lower(appearance.AModel)
            
            local commanderModel = commander_models[currentModel]
            if not commanderModel then
                local keys = table.GetKeys(commander_models)
                commanderModel = commander_models[keys[math.random(#keys)]]
            end
            
            self:SetModel(commanderModel)

            if commander_submaterials[commanderModel] ~= nil then
                self:SetSubMaterial()
                self:SetSubMaterial(commander_submaterials[commanderModel])
            end

            self:SetBodygroup(10, 1)
            self:SetBodygroup(8, math.random(0, 15))
            self:SetBodygroup(9, math.random(0, 9))
            self:SetSkin(math.random(0, 3))
        end
    end

    if not bNoEquipment and not isDefenseMode then
        self:PlayerClassEvent("GiveEquipment", self.subClass)
    end

    if self.subClass then
        if self.subClass == "medic" then
            --self:SetModel(medic[self:GetModel()] or self:GetModel())
        end
        
        self.subClass = nil
    end

    if !(isDefenseMode and isCommander) then
        local Appearance = self.CurAppearance or GetRandomAppearance(self)

        self:SetPlayerColor(Color(0, 60, 10):ToVector())
        self:SetNetVar("Accessories", "")
        self:SetSubMaterial()
        local slots = self:GetSubMaterialSlots()
        for k,v in ipairs(slots) do
            self:SetSubMaterial(v, ThatPlyIsFemale(self) and "models/humans/female/group02/citizen_sheet" or "models/humans/male/group02/citizen_sheet")
        end
        self.CurAppearance = Appearance
    end
    
    for k,v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(rebels,v:GetClass()) then
            v:AddEntityRelationship( self, D_LI, 0 )
            v:ClearEnemyMemory()
        elseif table.HasValue(combines,v:GetClass()) then
            v:AddEntityRelationship( self, D_HT, 99 )
            v:ClearEnemyMemory()
        end
    end
    
    local index = self:EntIndex()
    hook.Add( "OnEntityCreated", "refugee_relation_ship"..index, function( ent )
        if not IsValid(self) then hook.Remove("OnEntityCreated","refugee_relation_ship"..index) return end
        if ( ent:IsNPC() ) then
            if table.HasValue(rebels,ent:GetClass()) then
                ent:AddEntityRelationship( self, D_LI, 0 )
            end

            if table.HasValue(combines,ent:GetClass()) then
                ent:AddEntityRelationship( self, D_HT, 99 )
            end
        end
    end )
end

function CLASS.Guilt(self, victim)
    if CLIENT then return end

    if victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
end