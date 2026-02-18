local CLASS = player.RegClass("Rebel")

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

local rebel_models = {
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

local rebel_medic_models = {
    ["models/player/group03/male_01.mdl"]   = "models/player/group03m/male_01.mdl",
    ["models/player/group03/male_02.mdl"]   = "models/player/group03m/male_02.mdl",
    ["models/player/group03/male_03.mdl"]   = "models/player/group03m/male_03.mdl",
    ["models/player/group03/male_04.mdl"]   = "models/player/group03m/male_04.mdl",
    ["models/player/group03/male_05.mdl"]   = "models/player/group03m/male_05.mdl",
    ["models/player/group03/male_06.mdl"]   = "models/player/group03m/male_06.mdl",
    ["models/player/group03/male_07.mdl"]   = "models/player/group03m/male_07.mdl",
    ["models/player/group03/male_08.mdl"]   = "models/player/group03m/male_08.mdl",
    ["models/player/group03/male_09.mdl"]   = "models/player/group03m/male_09.mdl",
    ["models/player/group03/female_01.mdl"] = "models/player/group03m/female_01.mdl",
    ["models/player/group03/female_02.mdl"] = "models/player/group03m/female_02.mdl",
    ["models/player/group03/female_03.mdl"] = "models/player/group03m/female_03.mdl",
    ["models/player/group03/female_04.mdl"] = "models/player/group03m/female_04.mdl",
    ["models/player/group03/female_05.mdl"] = "models/player/group03m/female_05.mdl",
    ["models/player/group03/female_06.mdl"] = "models/player/group03m/female_06.mdl"
}


local primary_weapons = {
    "weapon_akm",
    "weapon_asval",
    "weapon_mp7",
    "weapon_spas12",
    "weapon_xm1014",
    "weapon_svd",
    "weapon_osipr"
}

local primary_attachments = {
    ["weapon_svd"] = function(ply, wep)
        if IsValid(wep) then
            hg.AddAttachmentForce(ply,wep,"optic11")
        end
    end,
}

local secondary_weapons = {
    "weapon_m9beretta",
    "weapon_browninghp",
    "weapon_revolver357",
    "weapon_revolver2",
    "weapon_hk_usp",
    "weapon_glock17"
}

local helmet_list = {
    "helmet1",
    "helmet7"
    --"helmet5",
}

local face_list = {
    "mask1",
	"mask3",
    "nightvision1",
    "",
    "",
    "",
    "",
    ""
}

local vest_list = {
    "vest5",
    "vest4",
    "vest1"
}

local rebel_subclasses = {
    default = {
        give_fn = function(ply)
            local wep1 = ply:Give(primary_weapons[math.random(#primary_weapons)])
            ply:GiveAmmo(wep1:GetMaxClip1() * 3, wep1:GetPrimaryAmmoType(), true)

            if isfunction(primary_attachments[wep1:GetClass()]) then
                primary_attachments[wep1:GetClass()](ply, wep1)
            end

            local wep2 = ply:Give(secondary_weapons[math.random(#secondary_weapons)])
            ply:GiveAmmo(wep2:GetMaxClip1() * 3, wep2:GetPrimaryAmmoType(), true)

            local wep_g = ply:Give("weapon_hg_hl2nade_tpik")
            if wep_g then wep_g.count = 1 end
        end
    },

    medic = {
        give_fn = function(ply)
            ply:Give("weapon_bandage_sh")
            local bbag = ply:Give("weapon_bloodbag")
            bbag.bloodtype = "o-"
            bbag.modeValues[1] = 1
            ply:Give("weapon_medkit_sh")
            ply:Give("weapon_mannitol")
            ply:Give("weapon_morphine")
            ply:Give("weapon_naloxone")
            ply:Give("weapon_painkillers")
            ply:Give("weapon_tourniquet")
            ply:Give("weapon_needle")
            ply:Give("weapon_betablock")
            ply:Give("weapon_adrenaline")

            local wep1 = ply:Give(primary_weapons[math.random(#primary_weapons)])
            ply:GiveAmmo(wep1:GetMaxClip1() * 3, wep1:GetPrimaryAmmoType(), true)
            //hg.AddAttachmentForce(ply, wep1, "ent_att_laser2")

            local wep2 = ply:Give(secondary_weapons[math.random(#secondary_weapons)])
            ply:GiveAmmo(wep2:GetMaxClip1() * 3, wep2:GetPrimaryAmmoType(), true)
        end
    },

    sniper = {
        give_fn = function(ply)
            local wep1 = ply:Give("weapon_hg_crossbow")
            ply:GiveAmmo(wep1:GetMaxClip1() * 10, wep1:GetPrimaryAmmoType(), true)

            local wep2 = ply:Give("weapon_revolver357")
            ply:GiveAmmo(wep2:GetMaxClip1() * 3, wep2:GetPrimaryAmmoType(), true)
        end
    },

    grenadier = {
        give_fn = function(ply)
            ply:Give(math.random(0,1) == 1 and "weapon_hg_rebelrpg" or "weapon_hg_rpg")
            ply:Give("weapon_claymore")
            ply:Give("weapon_traitor_ied")
            ply:Give("weapon_hg_slam")
            ply:Give("weapon_hg_pipebomb_tpik")

            local wep = ply:Give("weapon_revolver357")
            ply:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType(), true)
        end
    }
}

local function giveSubClassLoadout(ply, subClass)
    local cfg = rebel_subclasses[subClass] or rebel_subclasses["default"]
    
    cfg.give_fn(ply)

    --;; Система случайного говна
    ply.armors = ply.armors or {}
    local randVest = vest_list[math.random(#vest_list)]
    local randFace = face_list[math.random(#face_list)]
    local randHelmet = helmet_list[math.random(#helmet_list)]

    if randVest ~= "" then hg.AddArmor(ply, randVest) end
    if randHelmet ~= "" then hg.AddArmor(ply, randHelmet) end
    if randFace ~= "" then hg.AddArmor(ply, randFace) end

    ply:SyncArmor()

    ply:Give("weapon_melee")
    ply:Give("weapon_walkie_talkie")
end


function CLASS.On(self, data)
    if CLIENT then return end

    ApplyAppearance(self,nil,nil,nil,true)
    local appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    appearance.AAttachments = ""
    appearance.AColthes = ""

    local mdl_key = appearance.AModel
    if not rebel_models[mdl_key] then
        self:ChatPrint("zcity/appearance.json have invalid variables.. Setting random Appearance")
        appearance = hg.Appearance.GetRandomAppearance()
        mdl_key = appearance.AModel
    end

    self:SetPlayerColor(Color(13,101,5):ToVector())
    self:SetModel(rebel_models[mdl_key])
    self:SetSubMaterial()
    self:SetNetVar("Accessories", "")

    if not data.bNoEquipment then
        self:PlayerClassEvent("GiveEquipment", self.subClass)
    end


    if self.subClass == "medic" then
        local new_mdl = rebel_medic_models[self:GetModel()]
        if new_mdl then
            self:SetModel(new_mdl)
        end
    end


    self.subClass = nil

    if zb and zb.GiveRole then
        zb.GiveRole(self, "Rebel", Color(0, 173, 43))
    end

    self:SetBodygroup(10, 1)                  
    self:SetBodygroup(8, math.random(0,15))   
    self:SetBodygroup(9, math.random(0,9))    
    self:SetSkin(math.random(0,3))            


    self.CurAppearance = appearance
    
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
    hook.Add( "OnEntityCreated", "rebel_relation_ship"..index, function( ent )
        if not IsValid(self) then hook.Remove("OnEntityCreated","rebel_relation_ship"..index) return end
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


function CLASS.GiveEquipment(self, subClass)
    local ply = self
    local flashlight = self:Give("hg_flashlight")
    flashlight:Use(self)

    giveSubClassLoadout(ply, subClass or "default")
end

--;; Серверная часть: звуки боли, перезарядки и т.п.
if SERVER then
    local paintable = {
        [HITGROUP_STOMACH] = function(ply,ent)
            local base_folder = "vo/npc/"..(ThatPlyIsFemale(ply) and "female" or "male").."01/"
            local snd = (ply.painCD and CurTime() < ply.painCD + 10 ) and base_folder.."pain0"..math.random(1,9)..".wav"
                         or base_folder.."mygut02.wav"
            ent:EmitSound(snd,80,ply.VoicePitch)
            ply.painCD = CurTime() + SoundDuration(snd)
            ply.lastPhr = snd
        end,
        [HITGROUP_CHEST] = function(ply,ent)
            local base_folder = "vo/npc/"..(ThatPlyIsFemale(ply) and "female" or "male").."01/"
            local snd = base_folder.."pain0"..math.random(1,9)..".wav"
            ent:EmitSound(snd,80,ply.VoicePitch)
            ply.painCD = CurTime() + SoundDuration(snd)
            ply.lastPhr = snd
        end,
        [HITGROUP_LEFTARM] = function(ply,ent)
            local base_folder = "vo/npc/"..(ThatPlyIsFemale(ply) and "female" or "male").."01/"
            local snd = (ply.painCD and CurTime() < ply.painCD + 10 ) and base_folder.."pain0"..math.random(1,9)..".wav"
                         or base_folder.."myarm0"..math.random(1,2)..".wav"
            ent:EmitSound(snd,80,ply.VoicePitch)
            ply.painCD = CurTime() + SoundDuration(snd)
            ply.lastPhr = snd
        end,
        [HITGROUP_RIGHTARM] = function(ply,ent)
            local base_folder = "vo/npc/"..(ThatPlyIsFemale(ply) and "female" or "male").."01/"
            local snd = (ply.painCD and CurTime() < ply.painCD + 10 ) and base_folder.."pain0"..math.random(1,9)..".wav"
                         or base_folder.."myarm0"..math.random(1,2)..".wav"
            ent:EmitSound(snd,80,ply.VoicePitch)
            ply.painCD = CurTime() + SoundDuration(snd)
            ply.lastPhr = snd
        end,
        [HITGROUP_RIGHTLEG] = function(ply,ent)
            local base_folder = "vo/npc/"..(ThatPlyIsFemale(ply) and "female" or "male").."01/"
            local snd = (ply.painCD and CurTime() < ply.painCD + 10 ) and base_folder.."pain0"..math.random(1,9)..".wav"
                         or base_folder.."myleg0"..math.random(1,2)..".wav"
            ent:EmitSound(snd,80,ply.VoicePitch)
            ply.painCD = CurTime() + SoundDuration(snd)
            ply.lastPhr = snd
        end,
        [HITGROUP_LEFTLEG] = function(ply,ent)
            local base_folder = "vo/npc/"..(ThatPlyIsFemale(ply) and "female" or "male").."01/"
            local snd = (ply.painCD and CurTime() < ply.painCD + 10 ) and base_folder.."pain0"..math.random(1,9)..".wav"
                         or base_folder.."myleg0"..math.random(1,2)..".wav"
            ent:EmitSound(snd,80,ply.VoicePitch)
            ply.painCD = CurTime() + SoundDuration(snd)
            ply.lastPhr = snd
        end
    }

    local rebel_classes = {
        ["Rebel"] = true,
        ["Refugee"] = true,
        ["Rebel_Medic"] = true
    }

    hook.Add("HomigradDamage", "Rebels_painsounds", function(ply, dmgInfo, hitgroup, ent)
        if rebel_classes[ply.PlayerClassName] then
            ply.painCD = ply.painCD or 0
            if paintable[hitgroup] and (ply.painCD < CurTime()) and ply.organism and not ply.organism.otrub and ply:Alive() and not ply.organism.holdingbreath then 
                --paintable[hitgroup](ply,ent)
            end
        end
    end)

    hook.Add("HGReloading", "Rebels_reloadalert", function(wep)
        if CLIENT then return end
        local ply = wep:GetOwner()
        if not IsValid(ply) then return end
        ply.ReloadSND_CD = ply.ReloadSND_CD or 0
        if ply.ReloadSND_CD > CurTime() then return end

        local nearby = ents.FindInSphere(ply:GetPos(), 300)
        for _, mate in ipairs(nearby) do
            if mate:IsPlayer() and mate ~= ply and mate:Alive() and rebel_classes[mate.PlayerClassName] then
                if ply:Alive() and not ply.organism.otrub and rebel_classes[ply.PlayerClassName] and wep.ShellEject ~= "ShotgunShellEject" then
                    local base_folder = "vo/npc/"..(ThatPlyIsFemale(ply) and "female" or "male").."01/"
                    local phrase = (math.random(1,2) == 2) and (base_folder.."coverwhilereload01.wav") or (base_folder.."coverwhilereload02.wav")
                    ply:EmitSound(phrase, 75, ply.VoicePitch)
                    ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
                    ply.lastPhr = phrase
                    ply.ReloadSND_CD = CurTime() + SoundDuration(phrase)*3
                    return
                end
            end
        end
    end)
end


return CLASS
