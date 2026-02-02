local MODE = MODE

util.AddNetworkString("defense_highlight_last_npcs")


local npc_autoseek_timer = 0
hook.Add("Think", "NPCAutoSeekPlayer", function()
    local currentRound = CurrentRound()
    if not currentRound or currentRound.name ~= "defense" then return end
    if npc_autoseek_timer > CurTime() then return end
    npc_autoseek_timer = CurTime() + 1
    
    local npcs = ents.FindByClass("npc_*")
    local plys = player.GetAll()
    local plyCount = #plys

    if (plyCount == 0) then
        return
    end

    for i = 1, #npcs do
        local npc = npcs[i]
        if not IsValid(npc) or not npc.GetEnemy then continue end
        
        if IsValid(npc:GetEnemy()) then
            local blocking = npc:GetBlockingEntity()
            
            if IsValid(blocking) and not blocking:IsNPC() and not blocking:IsPlayer() and blocking:GetPos():DistToSqr(npc:GetPos()) < 64 * 64 then
                blocking.unblock_tries = (blocking.unblock_tries or 0) + 1
                
                if blocking.unblock_tries < 5 then
                    local phys = blocking:GetPhysicsObject()
                    blocking:TakeDamage(10, npc)

                    if IsValid(phys) then
                        phys:ApplyForceCenter((phys:GetPos() - npc:GetPos()):GetNormalized() * 3000)
                    end
                else
                    blocking.unblock_tries = 0
                    local oldname = blocking:GetName()
                    blocking:SetName('thrownade')
                    npc:Input('ThrowGrenadeAtTarget', nil, nil, 'thrownade')
                    timer.Simple(1, function() 
                        if IsValid(blocking) then
                            blocking:SetName(oldname) 
                        end
                    end)
                end
            end
            


            if npc:IsUnreachable(npc:GetEnemy()) or npc:HasObstacles() then
                for i, ent in pairs(ents.FindInSphere(npc:GetPos(), 64)) do
                    if ent:IsPlayer() or ent:IsNPC() then continue end

                    local tr = {}
                    tr.start = npc:GetPos()
                    tr.endpos = ent:GetPos()
                    tr.filter = {npc, ent}
                    tr.mask = MASK_SOLID_BRUSHONLY

                    if util.TraceLine(tr).Hit then continue end

                    ent.unblock_tries = (ent.unblock_tries or 0) + 1
                    local phys = ent:GetPhysicsObject()

                    ent:TakeDamage(10, npc)

                    if hgIsDoor(ent) and not ent:GetNoDraw() then
                        hgBlastThatDoor(ent, (ent:GetPos() - npc:GetPos()):GetNormalized() * 50)
                    end

                    if IsValid(phys) then
                        phys:ApplyForceCenter((phys:GetPos() - npc:GetPos()):GetNormalized() * 3000)
                    end
                    if ent.unblock_tries >= 5 then
                        ent.unblock_tries = 0
                        local oldname = ent:GetName()
                        ent:SetName('thrownade')
                        npc:Input('ThrowGrenadeAtTarget', nil, nil, 'thrownade')
                        timer.Simple(1, function() 
                            if IsValid(ent) then
                                ent:SetName(oldname) 
                            end
                        end)
                    end
                end
            end

            npc:ClearBlockingEntity()
        end
        

        local curPly
        local curPlyPos
        local curDist = math.huge
        
        local npcPos = npc:GetPos()

        local dobeyte_vyzhivshih = {}
        for i = 1, plyCount do
            local ply = plys[i]

            if not ply:Alive() then continue end
            if ply.organism and ply.organism.otrub then table.insert(dobeyte_vyzhivshih, i) continue end
            
            if (npc:Disposition(ply) == D_HT) then
                local plyPos = ply:GetPos()
                local dist = npcPos:DistToSqr(plyPos)

                if (dist < curDist) then
                    curPly = ply
                    curPlyPos = plyPos
                    curDist = dist
                end
            end
        end

        if not IsValid(curPly) then
            for i = 1, #dobeyte_vyzhivshih do
                local ply = plys[dobeyte_vyzhivshih[i]]
                
                if (npc:Disposition(ply) == D_HT) then
                    local plyPos = ply:GetPos()
                    local dist = npcPos:DistToSqr(plyPos)

                    if (dist < curDist) then
                        curPly = ply
                        curPlyPos = plyPos
                        curDist = dist
                    end
                end
            end
        end
        
        if IsValid(curPly) and curPlyPos then
            npc:SetEnemy(curPly)
            if not npc:HasEnemyMemory(curPly) then
                npc:UpdateEnemyMemory(curPly, curPlyPos)
            end
        end
    end
end)


hook.Remove("EntityRemoved", "DefenseNPCRemoved")
hook.Add("EntityRemoved", "DefenseNPCRemoved", function(ent)
    if not IsValid(ent) then return end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end

    if ent:GetClass() == "zb_temporary_ent" then return end

    if ent.IsDefenseWaveNPC then
        pcall(function()
            print("[DEFENSE] Entity removed: " .. tostring(ent:GetClass()) .. ", EntIndex: " .. ent:EntIndex())
            
            if not ent.DefenseNPCCountedAsDead then
                ent.DefenseNPCCountedAsDead = true
                MODE.NPCCount = math.max(0, MODE.NPCCount - 1)
                print("[DEFENSE] NPC Count after removal: " .. MODE.NPCCount)
                

                if MODE.NPCCount <= 0 and MODE:IsWaveActive() then
                    print("[DEFENSE] Wave Ended due to NPC removal!")
                    MODE:EndWave()
                    
                    if MODE.Wave < MODE.TotalWaves then
                        timer.Simple(1, function()
                            if type(MODE.StartNewWave) == "function" then
                                MODE:StartNewWave()
                            end
                        end)
                    end
                end
            end
        end)
    end
end)


hook.Remove("OnEntityCreated", "DefenseAddNewNPCs")
hook.Add("OnEntityCreated", "DefenseAddNewNPCs", function(ent)
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end
    
    if not MODE:IsWaveActive() then return end
    
    timer.Simple(0.2, function() 
        if not IsValid(ent) then return end
        
        local class = ent:GetClass() or ""
        

        if class == "zb_temporary_ent" then return end
        
        if not MODE.DefenseWaveEntities then
            MODE.DefenseWaveEntities = {}
        end
        
        if (ent:IsNPC() or 
            string.find(class, "npc_vj_") or 
            string.find(class, "sent_vj_") or
            string.find(class, "zb_") or 
            string.find(class, "terminator_nextbot_")) and 
           not ent.IsDefenseWaveNPC and
           class ~= "npc_bullseye" and 
           class ~= "npc_enemyfinder" and 
           class ~= "npc_bullseye_new" then
            
            if ent:IsNPC() and ent:GetNPCState() == NPC_STATE_SCRIPT then return end
            
            ent.IsDefenseWaveNPC = true
            ent.DefenseEntityID = "defense_npc_" .. ent:EntIndex() .. "_" .. math.random(1000, 9999)
            

            MODE.DefenseWaveEntities[ent.DefenseEntityID] = ent
            MODE.NPCCount = MODE.NPCCount + 1
            
            print("[DEFENSE] NPC Created: " .. class .. ", EntIndex: " .. ent:EntIndex() .. ", Count: " .. MODE.NPCCount)
            

            if ent.IsZBaseNPC then
                ent:CallOnRemove("DefenseZBaseNPCRemoved", function()
                    if not ent.DefenseNPCCountedAsDead then
                        ent.DefenseNPCCountedAsDead = true
                        MODE.NPCCount = math.max(0, MODE.NPCCount - 1)
                        MODE.DefenseWaveEntities[ent.DefenseEntityID] = nil
                        print("[DEFENSE] ZBase NPC Removed: " .. class .. ", Count: " .. MODE.NPCCount)
                    end
                end)
            end
        end
    end)
end)


hook.Remove("OnNPCKilled", "DefenseNPCKilled")
hook.Add("OnNPCKilled", "DefenseNPCKilled", function(npc, attacker, inflictor)
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end
    
    pcall(function()
        if not IsValid(npc) then return end
        
        if npc.IsDefenseWaveNPC then
            print("[DEFENSE] NPC Killed: " .. npc:GetClass() .. ", EntIndex: " .. npc:EntIndex())
            

            if not npc.DefenseNPCCountedAsDead then
                npc.DefenseNPCCountedAsDead = true
                MODE.NPCCount = math.max(0, MODE.NPCCount - 1)
                
                if MODE.DefenseWaveEntities and npc.DefenseEntityID then
                    MODE.DefenseWaveEntities[npc.DefenseEntityID] = nil
                end
                
                print("[DEFENSE] NPC Count after kill: " .. MODE.NPCCount)
                

                if MODE.NPCCount <= 0 and MODE:IsWaveActive() then
                    print("[DEFENSE] Wave Ended due to all NPCs killed!")
                    MODE:EndWave()
                    
                    if MODE.Wave and MODE.TotalWaves and MODE.Wave < MODE.TotalWaves then
                        timer.Simple(1, function()
                            if type(MODE.StartNewWave) == "function" then
                                MODE:StartNewWave()
                            end
                        end)
                    end
                end
            end
        end
    end)
end)

hook.Remove("EntityTakeDamage", "DefenseZombieDamageTrack")
hook.Add("EntityTakeDamage", "DefenseZombieDamageTrack", function(ent, dmginfo)
    if not IsValid(ent) then return end
    

    local class = ent:GetClass() or ""
    if class == "zb_temporary_ent" then return end
    
    if not (string.find(class, "npc_vj_") or string.find(class, "sent_vj_")) then return end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end


    if dmginfo:GetDamage() >= ent:Health() and ent.IsDefenseWaveNPC then
        timer.Simple(0.1, function()
            if not IsValid(ent) then return end
            

            if ent:Health() <= 0 then
                print("[DEFENSE] VJ NPC Died from damage: " .. class)
                
                if not ent.DefenseNPCCountedAsDead then
                    ent.DefenseNPCCountedAsDead = true
                    MODE.NPCCount = math.max(0, MODE.NPCCount - 1)
                    
                    if MODE.DefenseWaveEntities and ent.DefenseEntityID then
                        MODE.DefenseWaveEntities[ent.DefenseEntityID] = nil
                    end
                    
                    print("[DEFENSE] NPC Count after VJ death: " .. MODE.NPCCount)
                    
                    if MODE.NPCCount <= 0 and MODE:IsWaveActive() then
                        print("[DEFENSE] Wave Ended due to all VJ NPCs killed!")
                        MODE:EndWave()
                        
                        if MODE.Wave < MODE.TotalWaves then
                            timer.Simple(1, function()
                                if type(MODE.StartNewWave) == "function" then
                                    MODE:StartNewWave()
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end)



local lastNPCUpdate = 0
local lastNPCList = {}
local lastSentTime = 0

hook.Add("Think", "DefenseNPCValidityCheck", function()
    if CurTime() % 5 != 0 then return end 
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end
    
    if MODE:IsWaveActive() and MODE.DefenseWaveEntities then
        local invalidCount = 0
        local totalEntities = table.Count(MODE.DefenseWaveEntities)
        
        for id, npc in pairs(MODE.DefenseWaveEntities) do
            if not IsValid(npc) or 
               (npc:IsNPC() and npc:Health() <= 0) or 
               (IsValid(npc) and npc:GetClass() == "zb_temporary_ent") then  
                MODE.DefenseWaveEntities[id] = nil
                invalidCount = invalidCount + 1
            end
        end
        
        if invalidCount > 0 then
            local newCount = math.max(0, MODE.NPCCount - invalidCount)
            print("[DEFENSE] NPC Validity Check: Removed " .. invalidCount .. " invalid NPCs, updating count " .. MODE.NPCCount .. " -> " .. newCount)
            MODE.NPCCount = newCount
            
            if MODE.NPCCount <= 0 and MODE:IsWaveActive() then
                print("[DEFENSE] Wave Ended after validity check!")
                MODE:EndWave()
                
                if MODE.Wave < MODE.TotalWaves then
                    timer.Simple(1, function()
                        if type(MODE.StartNewWave) == "function" then
                            MODE:StartNewWave()
                        end
                    end)
                end
            end
        end
        
       
        if MODE.NPCCount <= 3 and MODE.NPCCount > 0 then
            local remainingNPCs = {}
            for id, npc in pairs(MODE.DefenseWaveEntities) do
                if IsValid(npc) and (not npc.DefenseNPCCountedAsDead) then
                    table.insert(remainingNPCs, npc:EntIndex())
                end
            end
            
           
            local shouldSend = #remainingNPCs ~= #lastNPCList or CurTime() - lastSentTime > 5
            
            if shouldSend and #remainingNPCs > 0 then
               
                local isDifferent = #remainingNPCs ~= #lastNPCList
                if not isDifferent then
                    for i, entIndex in ipairs(remainingNPCs) do
                        if lastNPCList[i] ~= entIndex then
                            isDifferent = true
                            break
                        end
                    end
                end
                
                if isDifferent or CurTime() - lastSentTime > 10 then
                    lastNPCList = table.Copy(remainingNPCs)
                    lastSentTime = CurTime()
                    
                    net.Start("defense_highlight_last_npcs")
                    net.WriteTable(remainingNPCs)
                    net.Broadcast()
                end
            end
        end
    end
end)

hook.Add("Think", "DefenseCleanupCheck", function()
    if CurTime() % 15 != 0 then return end 
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end
    
    if not MODE:IsWaveActive() and MODE.WaveCompleted then
        for _, ent in pairs(ents.GetAll()) do
            if IsValid(ent) and (ent:IsNPC() or 
                string.find(tostring(ent:GetClass() or ""), "npc_vj_") or
                string.find(tostring(ent:GetClass() or ""), "sent_vj_") or
                string.find(tostring(ent:GetClass() or ""), "zb_") or
                string.find(tostring(ent:GetClass() or ""), "terminator_nextbot_")) then
                
                local class = ent:GetClass()
                if class ~= "npc_bullseye" and class ~= "npc_enemyfinder" and class ~= "npc_bullseye_new" then
                    print("[DEFENSE] Removing leftover NPC: " .. class)
                    ent:Remove()
                end
            end
        end
    end
end)
