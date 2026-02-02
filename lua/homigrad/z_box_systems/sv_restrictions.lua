-- Запреты спавна вещей, и прочего не нужного дерьма.
ZBox = ZBox or {}
ZBox.Plugins = ZBox.Plugins or {}
ZBox.Plugins["Restrictions"] = ZBox.Plugins["Restrictions"] or {}
local PLUGIN = ZBox.Plugins["Restrictions"]

PLUGIN.Name = "Restrictions"

PLUGIN.Hooks = {}
local Hook = PLUGIN.Hooks
local DisableHookSpawns = {
    "PlayerSpawnVehicle",
    "PlayerSpawnRagdoll",
    "PlayerSpawnNPC",
    "PlayerSpawnEffect"
}
for k,v in pairs(DisableHookSpawns) do
    Hook[v] = function(ply)
        --if ply:IsAdmin() then
            --return true
        --else
            return false
        --end
    end
end


-- Доставка дерьма!
local RandomPrashe = {
"WHAT THE HELL ARE YOU BUILDING?",
"You realize you're not the only builder out there, right? Let us deliver to others",
"We don't have that much means of delivery mate!",
"*away from the microphone* Why do we even give them everything for free? Because it's a expe... *in microphone* Oh. You here yet. We're not ready to deliver your \"PROPS\""
}

function Hook.PlayerSpawnProp(ply, model)
    --if ply:IsAdmin() and (ply:GetActiveWeapon():GetClass() == "gmod_tool" or ply:GetActiveWeapon():GetClass() == "weapon_physgun") then
    --    return
    --end
--
    --ply.PropCD = ply.PropCD or 0
    --ply.Props = ply.Props or 0
    --if ply.PropCD < CurTime() then
    --    ply.PropCD = CurTime() + 1 + math.min(ply.Props / 15, 5)
    --    local pos = hg.eyeTrace(ply).HitPos
    --    local tr = util.TraceLine({
    --        start = pos,
    --        endpos = pos + vector_up * 9999,
    --        mask = MASK_SOLID_BRUSHONLY,
    --    })
    --    if tr.HitSky then
    --        ply.Props = ply.Props + 1
    --        ply:ChatPrint("Prop was called, estimated time of delivery 5-7 seconds.")
    --        timer.Create("SendProp" .. ply:EntIndex() .. model .. CurTime(), math.random(5, 7), 1, function()
    --            if not IsValid(ply) then return end
    --            local ent = ents.Create("prop_physics")
    --            ent:SetModel(model)
    --            if ent:BoundingRadius() > 200 then ply:ChatPrint("This shit so big, we can't deliver big PROPS.") ent:Remove() return false end
    --            ent:SetPos(tr.HitPos - tr.HitNormal * ent:BoundingRadius())
    --            ent:Spawn()
    --            ply:ChatPrint("Prop delivered!")
    --        end)
    --    end
    --    return false
    --else
    --    ply:ChatPrint(ply.Props < 15 and "Eh... Can you wait? We don't have time to prepare the delivery..." or table.Random(RandomPrashe))
    --    return false
    --end
end

--Ресрикт оружия...
local weaponRestrict = {
    ["gmod_camera"] = true,["weapon_fists"] = true, ["weapon_flechettegun"] = true, ["manhack_welder"] = true,
    ["weapon_medkit"] = true,["gmod_tool"] = true, ["weapon_physgun"] = true, ["weapon_physcannon"] = true,
    ["weapon_357"] = true, ["weapon_pistol"] = true, ["weapon_bugbait"] = true, ["weapon_crossbow"] = true,
    ["weapon_crowbar"] = true, ["weapon_frag"] = true, ["weapon_ar2"] = true, ["weapon_rpg"] = true,
    ["weapon_shotgun"] = true, ["weapon_slam"] = true, ["weapon_shotgun"] = true, ["weapon_smg1"] = true,
    ["weapon_stunstick"] = true, ["weapon_simremote"] = true, ["weapon_simrepair"] = true, ["weapon_hands_sh"] = true,
    ["wep_hmcd_mansion_broomstick"] = true, ["wep_hmcd_mansion_knife"] = true, ["wep_hmcd_mansion_cuestick"] = true, ["wep_hmcd_mansion_poker"] = true,
    ["wep_zac_hmcd_heroin"] = true, ["wep_hmcd_mansion_pencils"] = true, ["weapon_shield"] = true, ["weapon_matches"] = true,
    ["weapon_traitor_poison3"] = true, ["weapon_hg_rpg"] = true,
}
function Hook.PlayerSpawnSWEP(ply, class)
    --if ply:IsAdmin() and (class == "gmod_tool" or class == "weapon_physgun") then
    --    return
    --end
    if not ply:IsAdmin() then return false end
    --if weaponRestrict[class] and not ply:IsAdmin() then return false end
    --ply.WeaponCD = ply.WeaponCD or 0
    --if ply.WeaponCD < CurTime() then
    --    ply.WeaponCD = CurTime() + 5
    --    local pos = hg.eyeTrace(ply).HitPos
    --    local tr = util.TraceLine({
    --        start = pos,
    --        endpos = pos + vector_up * 9999,
    --        mask = MASK_SOLID_BRUSHONLY,
    --    })
    --    if tr.HitSky then
    --        ply:ChatPrint("Weapon was called, estimated time of delivery 5-7 seconds.")
    --        timer.Create("SendWeapon" .. ply:EntIndex() .. class .. CurTime(), math.random(5, 7), 1, function()
    --            if not IsValid(ply) then return end
    --            local ent = ents.Create(class)
    --            ent.IsSpawned = true
    --            ent:SetPos(tr.HitPos - tr.HitNormal * ent:BoundingRadius())
    --            ent:Spawn()
    --            ply:ChatPrint("Weapon delivered!")
    --        end)
    --    end
    --    return false
    --else
    --    ply:ChatPrint("Eh... Can you wait? We don't have time to prepare the delivery...")
    --    return false
    --end
end


function Hook.PlayerGiveSWEP(ply,class)
    --if ply:IsAdmin() and (class == "gmod_tool" or class == "weapon_physgun") then
       -- return
    --end
    if not ply:IsAdmin() then return false end
    --if weaponRestrict[class] and !ply:IsAdmin() then return false end
    --ply.WeaponCD = ply.WeaponCD or 0
    --if ply.WeaponCD < CurTime() then
    --    ply.WeaponCD = CurTime() + 5
    --    local pos = hg.eyeTrace(ply).HitPos
    --    local tr = util.TraceLine({
    --        start = pos,
    --        endpos = pos + vector_up * 9999,
    --        mask = MASK_SOLID_BRUSHONLY,
    --    })
    --    if tr.HitSky then
    --        ply:ChatPrint("Weapon was called, estimated time of delivery 5-7 seconds.")
    --        timer.Create("SendWeapon"..ply:EntIndex()..class..CurTime(),math.random(5,7),1,function()
    --            if not IsValid(ply) then return end
    --            local ent = ents.Create(class)
    --            ent:SetPos(tr.HitPos - tr.HitNormal * ent:BoundingRadius())
    --            ent:Spawn()
    --            ent.Spawned = true
    --            ply:ChatPrint("Weapon delivered!")
    --        end)
    --    end
    --    return false
    --else
    --    ply:ChatPrint("Eh... Can you wait? We don't have time to prepare the delivery...")
    --    return false
    --end
end

local entsRestrict = {
    ["sent_ball"] = true, ["edit_fog"] = true, ["ba2_airwaste"] = true, ["ba2_barrel"] = true,
    ["ba2_virus_cloud"] = true, ["ba2_gasmask"] = true, ["ba2_gasmask_filter"] = true, ["ba2_hordespawner"] = true,
    ["ba2_pointspawner"] = true, ["ba2_virus_sample"] = true, ["item_ammo_357"] = true, ["item_ammo_357_large"] = true,
    ["item_ammo_ar2"] = true, ["item_ammo_ar2_large"] = true, ["item_ammo_ar2_altfire"] = true, ["combine_mine"] = true,
    ["item_ammo_crossbow"] = true, ["item_healthcharger"] = true, ["item_healthkit"] = true, ["grenade_helicopter"] = true,
    ["item_suit"] = true, ["weapon_striderbuster"] = true, ["item_ammo_pistol"] = true, ["item_ammo_pistol_large"] = true,
    ["item_rpg_round"] = true, ["item_box_buckshot"] = true, ["item_ammo_smg1"] = true, ["item_ammo_smg1_large"] = true,
    ["item_ammo_smg1_grenade"] = true, ["item_battery"] = true, ["item_suitcharger"] = true, ["prop_thumper"] = true,
    ["npc_grenade_frag"] = true, ["bomb"] = true, ["ent_zac_whiskas"] = true, ["ent_hg_catfire"] = true,
    ["ent_hg_cyanide_plotnypih"] = true, ["crossbow_projectile"] = true, ["ent_hg_fire"] = true, ["ent_hg_firesmall"] = true, 
    ["ent_hg_molotov"] = true, ["projectile_base"] = true, ["projectile_nonexplosive_base"] = true, ["ent_hg_snowball"] = true, 
    ["rpg_projectile"] = true
}

function Hook.PlayerSpawnSENT(ply,class)
    if not ply:IsAdmin() then return false end
    --if entsRestrict[class] and !ply:IsAdmin() then return false end
    --ply.ThingCD = ply.ThingCD or 0
    --if ply.ThingCD < CurTime() then
    --    ply.ThingCD = CurTime() + 5
    --    local pos = hg.eyeTrace(ply).HitPos
    --    local tr = util.TraceLine({
    --        start = pos,
    --        endpos = pos + vector_up * 9999,
    --        mask = MASK_SOLID_BRUSHONLY,
    --    })
    --    if tr.HitSky then
    --        ply:ChatPrint("Thing was called, estimated time of delivery 5-7 seconds.")
    --        timer.Create("SendEnt"..ply:EntIndex()..class..CurTime(),math.random(5,7),1,function()
    --            if not IsValid(ply) then return end
    --            local ent = ents.Create(class)
    --            ent:SetPos(tr.HitPos - tr.HitNormal * ent:BoundingRadius())
    --            ent:Spawn()
    --            ent.Spawned = true
    --            ply:ChatPrint("Things delivered!")
    --        end)
    --    end
    --    return false
    --else
    --    ply:ChatPrint("Eh... Can you wait? We don't have time to prepare the delivery...")
    --    return false
    --end
end

function Hook.PlayerNoClip(ply, desiredState)
    if ply:IsAdmin() then
        return true 
    else
        return false 
    end
end

