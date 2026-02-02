local MODE = MODE

util.AddNetworkString("defense_commander_points")
util.AddNetworkString("defense_commander_notification")
util.AddNetworkString("defense_player_role_assigned")

function MODE:ClearPlayerRoles()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWString("PlayerRole", "")
        ply:SetNWInt("CommanderPoints", 0)
    end
end


function MODE:AddCommanderPoints(points)
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetNWString("PlayerRole") == "Commander" and ply:Alive() then
            local currentPoints = ply:GetNWInt("CommanderPoints", 0)
            ply:SetNWInt("CommanderPoints", currentPoints + points)

            net.Start("defense_commander_notification")
            net.WriteString("You've received " .. points .. " supply points!")
            net.WriteInt(points, 16)
            net.Send(ply)
        end
    end
end

function MODE:OnWaveComplete()
    if not self.CurrentSubMode then return end
    
    local pointsPerWave = DEFENSE_COMMANDER_ECONOMY.POINTS_PER_WAVE[self.CurrentSubMode] or 50
    

    local isBossWave = false
    if self.IsBossWave and type(self.IsBossWave) == "function" then
        isBossWave = self:IsBossWave()
    else

        local waveDefinitions = DEFENSE_WAVE_DEFINITIONS[self.CurrentSubMode]
        if waveDefinitions and waveDefinitions[self.Wave] then
            local currentWave = waveDefinitions[self.Wave]
            for _, npcDef in ipairs(currentWave) do
                if npcDef.boss then
                    isBossWave = true
                    break
                end
            end
        end
    end
    

    if isBossWave then
        pointsPerWave = pointsPerWave * 2
        

        for _, ply in ipairs(player.GetAll()) do
            if ply:GetNWString("PlayerRole") == "Commander" and ply:Alive() then
                local currentPoints = ply:GetNWInt("CommanderPoints", 0)
                ply:SetNWInt("CommanderPoints", currentPoints + pointsPerWave)
                
                net.Start("defense_commander_notification")
                net.WriteString("You received double points for defeating the boss!")
                net.WriteInt(pointsPerWave, 16)
                net.Send(ply)
            end
        end
    else

        self:AddCommanderPoints(pointsPerWave)
    end
end

function MODE:AssignPlayerRoles()
    local players = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then
            table.insert(players, ply)
        end
    end

    if #players == 0 then
        return
    end

    local numPlayers = #players
    local numMedics = math.max(1, math.floor(numPlayers / 4)) 
    local numEngineers = math.max(1, math.floor(numPlayers / 6)) 

    table.Shuffle(players)

    local function EquipBaseGear(ply)
        if not ply or not IsValid(ply) then return end
        
        local inv = ply:GetNetVar("Inventory")
        if not inv or not inv["Weapons"] then return end
        
        inv["Weapons"]["hg_sling"] = true
        ply:SetNetVar("Inventory", inv)


        local weaponClass = DEFENSE_WEAPONS[0][math.random(#DEFENSE_WEAPONS[0])]
        local gun = ply:Give(weaponClass)
        

        timer.Simple(0.2, function()
            if IsValid(ply) and IsValid(gun) then
                if gun.GetMaxClip1 and isfunction(gun.GetMaxClip1) then
                    local ammoAmount = gun:GetMaxClip1() * 3
                    ply:GiveAmmo(ammoAmount, gun:GetPrimaryAmmoType(), true)
                else
                    ply:GiveAmmo(30, ply:GetWeapon(weaponClass):GetPrimaryAmmoType(), true)
                end
                pcall(function()
                    hg.AddAttachmentForce(ply, gun, DEFENSE_ATTACHMENTS[0][math.random(#DEFENSE_ATTACHMENTS[0])])
                end)
            end
        end)
        pcall(function()
            hg.AddArmor(ply, DEFENSE_ARMOR[0][math.random(#DEFENSE_ARMOR[0])])
        end)
        ply:Give("weapon_melee")
        ply:Give("weapon_hg_rgd_tpik")
        ply:Give("weapon_walkie_talkie")
        ply:Give("weapon_bandage_sh")
        ply:Give("weapon_tourniquet")
    end

    local commander = table.remove(players, 1)
    if commander then
        commander:SetNWString("PlayerRole", "Commander")
        commander:SetNWInt("CommanderPoints", DEFENSE_COMMANDER_ECONOMY.STARTING_POINTS)
        

        net.Start("defense_player_role_assigned")
        net.WriteString("Commander")
        net.Send(commander)
        
        EquipBaseGear(commander)
    end

    for i = 1, numMedics do
        local ply = table.remove(players, math.random(#players))
        if not ply or not IsValid(ply) then continue end
        ply:SetNWString("PlayerRole", "Medic")
        EquipBaseGear(ply)
        ply:Give("weapon_medkit_sh")
        local wep = ply:Give("weapon_bloodbag")
        timer.Simple(0.2, function() 
            if IsValid(wep) then 
                wep.modeValues = wep.modeValues or {}
                wep.modeValues[1] = 1 
                wep.bloodtype = "o-" 
            end 
        end)
        ply:Give("weapon_painkillers")
        ply:Give("weapon_betablock")
        ply:Give("weapon_adrenaline")
        ply:Give("weapon_morphine")
    end

    for i = 1, numEngineers do
        local ply = table.remove(players, math.random(#players))
        if not ply or not IsValid(ply) then continue end
        ply:SetNWString("PlayerRole", "Engineer")
        EquipBaseGear(ply)
        ply:Give("weapon_hammer")
        ply:Give("weapon_ducttape")
        ply:Give("weapon_hg_pipebomb_tpik")
        ply:Give("weapon_claymore")
        ply:GiveAmmo(40, "Nails", true)
    end

    for _, ply in ipairs(players) do
        if not ply then break end
        ply:SetNWString("PlayerRole", "Soldier")
        EquipBaseGear(ply)
    end
end

function MODE:GetPlySpawn(ply)
    if self.SpawnPoints and #self.SpawnPoints > 0 then
        ply:SetPos(self.SpawnPoints[#self.SpawnPoints].pos)
        if #self.SpawnPoints > 1 then 
            table.remove(self.SpawnPoints)
        end
    end
end

function MODE:GiveEquipment()
    self.SpawnPoints = zb.GetMapPoints("PLY_DEFENSE_SPAWN")
    if not self.SpawnPoints then
        self.SpawnPoints = {}
    end

    pcall(function()
        self:AssignPlayerRoles()
    end)

    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then
            continue
        end
        
        ply:SetSuppressPickupNotices(true)
        ply.noSound = true

        pcall(function()
            ply:SetPlayerClass("Refugee")
            zb.GiveRole(ply, "Refugee", Color(255, 150, 0))
        end)

        self:GetPlySpawn(ply)

        timer.Simple(0.1, function()
            if IsValid(ply) then
                local hands = ply:Give("weapon_hands_sh")
                if IsValid(hands) then
                    ply:SelectWeapon("weapon_hands_sh")
                end
            end
        end)

        ply:SetSuppressPickupNotices(false)
        ply.noSound = false
    end
end


function SetCommanderRoleByID(playerID)
    local ply = Player(playerID)
    if IsValid(ply) then
        ply:SetNWString("PlayerRole", "Commander")
        
        net.Start("defense_player_role_assigned")
        net.WriteString("Commander")
        net.Send(ply)
        
        ply:ChatPrint("u are cmd now")
    end
end
