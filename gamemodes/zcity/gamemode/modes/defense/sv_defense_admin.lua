local function HasAccess(ply)
    return ply:IsAdmin() or ply:IsSuperAdmin()
end

util.AddNetworkString("defense_admin_wave_menu")
util.AddNetworkString("defense_admin_wave_skip")


concommand.Add("defense_waves_admin", function(ply, cmd, args)
    if not HasAccess(ply) then
        ply:ChatPrint("nuh uh")
        return
    end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then
        ply:ChatPrint("nope")
        return
    end
    
    local currentWave = MODE.Wave or 0
    local totalWaves = MODE.TotalWaves or 0
    local isActive = MODE:IsWaveActive() or false
    local subMode = MODE.CurrentSubMode or "STANDARD"
    
    net.Start("defense_admin_wave_menu")
    net.WriteString(subMode)
    net.WriteInt(currentWave, 8)
    net.WriteInt(totalWaves, 8)
    net.WriteBool(isActive)
    net.Send(ply)
end)


net.Receive("defense_admin_wave_skip", function(len, ply)
    if not HasAccess(ply) then return end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end
    
    local targetWave = net.ReadInt(8)
    

    if targetWave < 1 or targetWave > MODE.TotalWaves then
        ply:ChatPrint("wha?")
        return
    end
    

    for _, player in ipairs(player.GetAll()) do
        player:ChatPrint("Fatass " .. ply:Nick() .. " switch wave to " .. targetWave)
    end
    

    MODE:ClearAllTimers()
    

    net.Start("StopWaveMusic")
    net.Broadcast()
    

    if MODE:IsWaveActive() then
        MODE:EndWave()
    end
    

    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and (ent:IsNPC() or 
            string.find(tostring(ent:GetClass() or ""), "npc_vj_") or
            string.find(tostring(ent:GetClass() or ""), "sent_vj_") or
            string.find(tostring(ent:GetClass() or ""), "zb_") or
            string.find(tostring(ent:GetClass() or ""), "terminator_nextbot_")) then
            
            ent:Remove()
        end
    end
    

    MODE.NPCCount = 0
    MODE.DefenseWaveEntities = {}
    

    MODE.Wave = targetWave - 1
    MODE.WaveCompleted = false
    

    for _, player in ipairs(player.GetAll()) do
        if player:Alive() and player:Team() ~= TEAM_SPECTATOR then
            player:SetHealth(player:GetMaxHealth())
            

            for _, wep in pairs(player:GetWeapons()) do
                if wep:GetPrimaryAmmoType() >= 0 then
                    player:GiveAmmo(100, wep:GetPrimaryAmmoType())
                end
                if wep:GetSecondaryAmmoType() >= 0 then
                    player:GiveAmmo(100, wep:GetSecondaryAmmoType())
                end
            end
        end
    end
    

    for _, player in ipairs(player.GetAll()) do
        if player:GetNWString("PlayerRole") == "Commander" then
            local currentPoints = player:GetNWInt("CommanderPoints", 0)
            player:SetNWInt("CommanderPoints", currentPoints + 500)
            
            net.Start("defense_commander_notification")
            net.WriteString("500 points for freeeeee!!!")
            net.WriteInt(500, 16)
            net.Send(player)
        end
    end
    

    timer.Simple(2, function()
        if MODE and MODE.StartNewWave then
            MODE:StartNewWave()
        end
    end)
end)
