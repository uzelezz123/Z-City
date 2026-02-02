

hg = hg or {}
hg.CoopPersistence = hg.CoopPersistence or {}

local SAVE_PATH = "coop_persistence/"


file.CreateDir(SAVE_PATH)

function hg.CoopPersistence.GetSavePath()
    return SAVE_PATH .. "session_data.json"
end

function hg.CoopPersistence.SaveAllPlayers()
    local data = {}
    
    for steamid, playerData in pairs(hg.CoopPersistence.PendingSave or {}) do
        data[steamid] = playerData
    end
    
    if table.Count(data) > 0 then
        file.Write(hg.CoopPersistence.GetSavePath(), util.TableToJSON(data, true))
    end
end

function hg.CoopPersistence.LoadAllPlayers()
    local path = hg.CoopPersistence.GetSavePath()
    local content = file.Read(path, "DATA")
    
    if content then
        local data = util.JSONToTable(content)
        if data then
            hg.CoopPersistence.LoadedData = data
            return data
        end
    end
    
    hg.CoopPersistence.LoadedData = {}
    return {}
end


function hg.CoopPersistence.ClearSavedData()
    hg.CoopPersistence.PendingSave = {}
    hg.CoopPersistence.LoadedData = {}
    file.Delete(hg.CoopPersistence.GetSavePath())
end


function hg.CoopPersistence.SavePlayerData(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local steamid = ply:SteamID()
    hg.CoopPersistence.PendingSave = hg.CoopPersistence.PendingSave or {}
    
    local weaponsData = {}
    local inv = ply:GetNetVar("Inventory", {})
    
    if inv.Weapons then
        for wepClass, wepData in pairs(inv.Weapons) do
            if wepClass == "hg_sling" or wepClass == "hg_brassknuckles" or wepClass == "hg_flashlight" then
                weaponsData[wepClass] = true
            elseif IsValid(wepData) and wepData:IsWeapon() then
                if wepData.GetInfo then
                    weaponsData[wepClass] = wepData:GetInfo()
                else
                    weaponsData[wepClass] = {
                        Clip1 = wepData:Clip1(),
                        Clip2 = wepData:Clip2()
                    }
                end
            else
                weaponsData[wepClass] = true
            end
        end
    end

    for _, wep in ipairs(ply:GetWeapons()) do
        local wepClass = wep:GetClass()
        if wepClass == "weapon_hands_sh" or wepClass == "weapon_zombclaws" then continue end
        
        if not weaponsData[wepClass] then
            if wep.GetInfo then
                weaponsData[wepClass] = wep:GetInfo()
            else
                weaponsData[wepClass] = {
                    Clip1 = wep:Clip1(),
                    Clip2 = wep:Clip2()
                }
            end
        end
    end

    local ammoData = {}
    for ammoID, count in pairs(ply:GetAmmo()) do
        if count > 0 then
            local ammoName = game.GetAmmoName(ammoID)
            if ammoName then
                ammoData[ammoName] = count
            end
        end
    end

    local armorData = {}
    if ply.armors then
        for placement, armorName in pairs(ply.armors) do
            armorData[placement] = armorName
        end
    end
    
    local armorHealthData = {}
    if ply.armors_health then
        for placement, health in pairs(ply.armors_health) do
            armorHealthData[placement] = health
        end
    end

    local role = ply.role or {}
    local roleName = role.name or "Refugee"
    local roleColor = role.color or Color(255, 155, 0)

    local playerClass = ply.PlayerClassName or "Refugee"
    local subClass = ply.subClass

    local hevData = nil
    if ply.HEV and ply:GetNetVar("HEVSuit") then
        hevData = {
            Power = ply.HEV.Power,
            Medicine = ply.HEV.Medicine,
            Morphine = ply.HEV.Morphine
        }
    end
    
    hg.CoopPersistence.PendingSave[steamid] = {
        Weapons = weaponsData,
        Ammo = ammoData,
        Armor = armorData,
        Armor_health = armorHealthData,
        Attachments = inv.Attachments or {},
        Role = roleName,
        RoleColor = {roleColor.r, roleColor.g, roleColor.b},
        PlayerClass = playerClass,
        SubClass = subClass,
        Health = ply:Health(),
        MaxHealth = ply:GetMaxHealth(),
        HEV = hevData, 
        Nick = ply:Nick() 
    }
end


function hg.CoopPersistence.RestorePlayerData(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    
    local steamid = ply:SteamID()
    local data = hg.CoopPersistence.LoadedData and hg.CoopPersistence.LoadedData[steamid]
    
    if not data then return false end
    
    
    ply:SetSuppressPickupNotices(true)
    ply.noSound = true
    
    local inv = ply:GetNetVar("Inventory", {})
    inv.Weapons = inv.Weapons or {}
    inv.Ammo = inv.Ammo or {}
    inv.Attachments = data.Attachments or {}
    
    if data.Weapons["hg_sling"] then
        inv.Weapons["hg_sling"] = true
    end
    if data.Weapons["hg_brassknuckles"] then
        inv.Weapons["hg_brassknuckles"] = true
    end
    if data.Weapons["hg_flashlight"] then
        inv.Weapons["hg_flashlight"] = true
    end
    
    ply:SetNetVar("Inventory", inv)
    
    for wepClass, wepData in pairs(data.Weapons) do
        if wepClass == "hg_sling" or wepClass == "hg_brassknuckles" or wepClass == "hg_flashlight" then
            continue
        end
        
        local wep = ply:Give(wepClass)
        if IsValid(wep) then
            if istable(wepData) then
                if wep.SetInfo then
                    wep:SetInfo(wepData)
                else
                    if wepData.Clip1 then wep:SetClip1(wepData.Clip1) end
                    if wepData.Clip2 then wep:SetClip2(wepData.Clip2) end
                end
            end
        end
    end
    
    for ammoName, count in pairs(data.Ammo or {}) do
        ply:GiveAmmo(count, ammoName, true)
    end
    
    if data.Armor and hg.AddArmor then
        for placement, armorName in pairs(data.Armor) do
            hg.AddArmor(ply, armorName)
        end
    end
    
    if data.Armor_health then
        ply.armors_health = ply.armors_health or {}
        for placement, health in pairs(data.Armor_health) do
            ply.armors_health[placement] = health
        end
    end
    
    if data.Health then
        ply:SetHealth(math.max(data.Health, 50)) 
    end
    
    if data.HEV then
        ply.HEV = ply.HEV or {}
        ply.HEV.Power = data.HEV.Power or 75
        ply.HEV.Medicine = data.HEV.Medicine or 600
        ply.HEV.Morphine = data.HEV.Morphine or 4
    end
    
    timer.Simple(0.1, function()
        if IsValid(ply) then
            ply.noSound = false
            ply:SetSuppressPickupNotices(false)
        end
    end)
    
    return true, data
end

function hg.CoopPersistence.HasSurvivedGordon()
    local loadedData = hg.CoopPersistence.LoadedData or {}
    
    for steamid, data in pairs(loadedData) do
        if data.PlayerClass == "Gordon" or data.Role == "Freeman" then
            return true, steamid
        end
    end
    
    return false, nil
end

function hg.CoopPersistence.GetPlayerData(steamid)
    return hg.CoopPersistence.LoadedData and hg.CoopPersistence.LoadedData[steamid]
end

function hg.CoopPersistence.MarkPlayerRestored(steamid)
    if hg.CoopPersistence.LoadedData then
        hg.CoopPersistence.LoadedData[steamid] = nil
    end
end

hook.Add("ShutDown", "CoopPersistence_SaveOnShutdown", function()
    if CurrentRound and CurrentRound().name == "coop" and hg.MapCompleted then
        hg.CoopPersistence.SaveAllPlayers()
    end
end)

hook.Add("InitPostEntity", "CoopPersistence_LoadOnStart", function()
    timer.Simple(1, function()
        hg.CoopPersistence.LoadAllPlayers()
    end)
end)

hook.Add("ZB_PreRoundStart", "CoopPersistence_ClearOnModeChange", function()
    local nextRound = zb.nextround or "hmcd"
    local nextMode = zb:GetMode(nextRound)
    
    if nextMode ~= "coop" then
        hg.CoopPersistence.ClearSavedData()
    end
end)

hook.Add("ZB_StartRound", "CoopPersistence_ClearPending", function()
    if CurrentRound and CurrentRound().name == "coop" then
        hg.CoopPersistence.PendingSave = {}
    end
end)


hook.Add("PlayerSpawn", "CoopPersistence_MidRoundSpawn", function(ply)
    if not CurrentRound or CurrentRound().name ~= "coop" then return end
    if not zb or zb.ROUND_STATE ~= 1 then return end 
    timer.Simple(0.5, function()
        if not IsValid(ply) or not ply:Alive() then return end
        local hasWeapons = #ply:GetWeapons() > 1 
        if hasWeapons then return end
        if CurrentRound().GetPlySpawn then
            CurrentRound():GetPlySpawn(ply)
        end
        
        local steamid = ply:SteamID()
        local savedData = hg.CoopPersistence.GetPlayerData(steamid)
        
        if savedData then
           
            local restored, data = hg.CoopPersistence.RestorePlayerData(ply)
            
            if restored and data then
                local savedPlayerClass = data.PlayerClass
                local savedRole = data.Role
                local savedRoleColor = data.RoleColor and Color(data.RoleColor[1], data.RoleColor[2], data.RoleColor[3]) or Color(255, 155, 0)
                local savedSubClass = data.SubClass
                
               
                if savedPlayerClass == "Gordon" or savedRole == "Freeman" then
                    ply:SetPlayerClass("Gordon", {bRestored = true})
                    zb.GiveRole(ply, "Freeman", Color(255, 155, 0))
                elseif savedSubClass == "medic" then
                    ply.subClass = "medic"
                    ply:SetPlayerClass(savedPlayerClass or "Rebel", {bNoEquipment = true})
                    zb.GiveRole(ply, "Medic", Color(190, 0, 0))
                else
                    ply:SetPlayerClass(savedPlayerClass or "Rebel", {bNoEquipment = true})
                    zb.GiveRole(ply, savedRole or "Rebel", savedRoleColor)
                end
                
                hg.CoopPersistence.MarkPlayerRestored(steamid)
                
                ply:Give("weapon_hands_sh")
                ply:SelectWeapon("weapon_hands_sh")
                
            end
        else
            local currentMap = game.GetMap()
            local mapData = CurrentRound().Maps[currentMap] or {PlayerEqipment = "rebel"}
            local playerClass = mapData.PlayerEqipment
            
            local inv = ply:GetNetVar("Inventory", {})
            inv["Weapons"] = inv["Weapons"] or {}
            inv["Weapons"]["hg_sling"] = true
            inv["Weapons"]["hg_flashlight"] = true
            ply:SetNetVar("Inventory", inv)
            
            if playerClass == "refugee" or playerClass == "citizen" then
                ply:SetPlayerClass("Refugee", {bNoEquipment = playerClass == "citizen"})
                zb.GiveRole(ply, "Refugee", Color(255, 155, 0))
            elseif playerClass == "rebel" then
                ply:SetPlayerClass("Rebel")
                zb.GiveRole(ply, "Rebel", Color(255, 155, 0))
            end
            
            ply:Give("weapon_hands_sh")
            ply:SelectWeapon("weapon_hands_sh")
        end
    end)
end)
