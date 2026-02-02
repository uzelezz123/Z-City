local MODE = MODE


 local _OrigSpawn = SpawnZBaseNPC
 function SpawnZBaseNPC(ply, npcClass, pos, weaponClass)

     local npc
     if _OrigSpawn then
        npc = _OrigSpawn(ply, npcClass, pos, "default")
     else
         npc = ZBaseSpawnZBaseNPC(npcClass, pos, nil, "default")
   end
    if not IsValid(npc) then return end

     if weaponClass and weaponClass ~= "" then
         timer.Simple(0, function()
             if not IsValid(npc) then return end

             for _, wep in ipairs(npc:GetWeapons()) do
                 if IsValid(wep) then wep:Remove() end
             end

             npc:Give(weaponClass)
         end)
     end

    return npc
 end

function MODE:FindValidSpawnPoint(center, radius)
    local attempts = 10
    for i = 1, attempts do
        local randomOffset = Vector(math.random(-radius, radius), math.random(-radius, radius), 0)
        local spawnPos = center + randomOffset

        local trace = util.TraceLine({
            start = spawnPos + Vector(0, 0, 50),
            endpos = spawnPos - Vector(0, 0, 500),
            mask = MASK_SOLID_BRUSHONLY
        })

        if not trace.Hit then continue end
        spawnPos = trace.HitPos + Vector(0, 0, 10) 

        local hullTrace = util.TraceHull({
            start = spawnPos,
            endpos = spawnPos,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            mask = MASK_PLAYERSOLID
        })

        if hullTrace.Hit then continue end

        local ceilingTrace = util.TraceLine({
            start = spawnPos,
            endpos = spawnPos + Vector(0, 0, 100),
            mask = MASK_SOLID
        })

        if ceilingTrace.Hit then continue end

        return spawnPos
    end

    return nil 
end


function MODE:AssignNPCTarget(npc)
    if not IsValid(npc) then return end  
    local function GetValidPlayers()
        local validPlayers = {}
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
                table.insert(validPlayers, ply)
            end
        end
        return validPlayers
    end

    local validPlayers = GetValidPlayers()
    if #validPlayers == 0 then return end  

    local targetPlayer = validPlayers[math.random(#validPlayers)]  
    npc:UpdateEnemyMemory(targetPlayer, targetPlayer:GetPos())  
end

function MODE:StartNewWave()
    self.Wave = self.Wave or 0
    self.TotalWaves = self.TotalWaves or 6
    
    if self.Wave < self.TotalWaves then
        self.Wave = self.Wave + 1
        self.WaveCompleted = false
        
        if self.Wave % 2 == 0 then
            timer.Simple(0.5, function()
                for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
                    if IsValid(ent) then
                        local org = ent.organism
                        //if org and org.critical then
                            for i = 0, ent:GetPhysicsObjectCount() - 1 do
                                ent:GetPhysicsObjectNum(i):Sleep()
                            end
                        //end
                    end
                end
            end)
        end
        
        self:CreateTimer("new_wave_timer", 60, 1, function() 
            self:SpawnWave() 
            self:StartWave() 
        end)

        net.Start("npc_defense_newwave")
            net.WriteFloat(CurTime() + 60)
            net.WriteInt(self.Wave, 4)
        net.Broadcast()
    elseif self.Wave == self.TotalWaves then
        self.WaveCompleted = true
        timer.Simple(5, function()
            if zb and zb.ROUND_STATE == 1 then
                zb.EndMatch()
            end
        end)
    end
end


function MODE:SpawnWave()
    local spawnPoints = zb.GetMapPoints("NPC_DEFENSE_SPAWN")
    if not spawnPoints or #spawnPoints == 0 then
        return
    end
    
    local waveDefinitions = DEFENSE_WAVE_DEFINITIONS[self.CurrentSubMode]
    if not waveDefinitions or not waveDefinitions[self.Wave] then
        return
    end
    
    self.NPCCount = 0
    self.DefenseWaveEntities = {}
    
    local currentWave = waveDefinitions[self.Wave]
    local spawnRadius = 70
    local spawnedNPCs = {}
    

    local hasBoss = false
    for _, npcDef in ipairs(currentWave) do
        if npcDef.boss then
            hasBoss = true
            break
        end
    end
    

    if hasBoss then
        net.Start("defense_boss_incoming")
        net.Broadcast()
        

        for _, ply in ipairs(player.GetAll()) do
            if ply:GetNWString("PlayerRole") == "Commander" and ply:Alive() then
                net.Start("defense_commander_notification")
                net.WriteString("Boss wave! You'll receive double points after completing this wave!")
                net.WriteInt(0, 16)
                net.Send(ply)
            end
        end
    end
    
    print("[DEFENSE] Starting Wave " .. self.Wave .. " - Spawning NPCs...")
    
    for _, npcDef in ipairs(currentWave) do
        for i = 1, npcDef.count do
            local point = spawnPoints[math.random(#spawnPoints)]
            local spawnPos = self:FindValidSpawnPoint(point.pos, spawnRadius)
            
            if not spawnPos then 
                continue 
            end
            
            local npc
            
            local t = npcDef.type
            if     string.sub(t, 1, 3) == "zb_"
                or string.sub(t, 1, 3) == "ej_"
                or string.sub(t, 1, 5) == "beta_"
            then
                npc = SpawnZBaseNPC(nil, npcDef.type, spawnPos, npcDef.weapon)
            elseif string.sub(npcDef.type, 1, 10) == "terminator" or string.find(npcDef.type, "sent_vj_") then
                npc = ents.Create(npcDef.type)
                if not IsValid(npc) then continue end
                npc:SetPos(spawnPos)
                npc:Spawn()
                
                npc.IsDefenseWaveNPC = true
            else
                npc = ents.Create(npcDef.type)
                if not IsValid(npc) then 
                    continue 
                end
                
                npc:SetPos(spawnPos)
                
                if npcDef.model then
                    npc:SetModel(npcDef.model)
                end
                
                if npcDef.keyvalues then
                    for key, value in pairs(npcDef.keyvalues) do
                        npc:SetKeyValue(key, value)
                    end
                end
                
                if npcDef.aggressive then
                    npc:SetKeyValue("aggressivebehavior", "1")
                    npc:SetKeyValue("spawnflags", "256") 
                    
                    if npcDef.type == "npc_zombie" or npcDef.type == "npc_fastzombie" or npcDef.type == "npc_poisonzombie" then
                        npc:SetKeyValue("incominghate", "1")
                    end
                end
                
                npc:Spawn()
                npc:Activate()
                
                if npcDef.weapon and npcDef.weapon ~= "" and not npcDef.default_weapon and 
                   (npcDef.type == "npc_combine_s" or npcDef.type == "npc_metropolice") then
                    npc:Give(npcDef.weapon)
                end
            end

            if not IsValid(npc) then 
                continue 
            end
            
            if npc:GetClass() == "zb_temporary_ent" then continue end
            
            npc.IsDefenseWaveNPC = true
            npc.DefenseNPCCountedAsDead = false
            npc.DefenseEntityID = "defense_npc_" .. npc:EntIndex() .. "_" .. math.random(1000, 9999)
            
            self.DefenseWaveEntities[npc.DefenseEntityID] = npc
            
            print("[DEFENSE] Spawned NPC: " .. npcDef.type .. ", EntIndex: " .. npc:EntIndex())
            
            table.insert(spawnedNPCs, { entity = npc, def = npcDef })
            
            if npcDef.health and not (string.sub(npcDef.type, 1, 3) == "zb_") then
                npc:SetHealth(npcDef.health)
                npc:SetMaxHealth(npcDef.health)
            end

            if npcDef.type == "npc_turret_floor" and npcDef.no_target then
                timer.Simple(0.5, function()
                    if IsValid(npc) then
                        npc:Fire("Enable")
                        npc:SetKeyValue("spawnflags", "0") 
                    end
                end)
            end
            
            
            self:AssignNPCTarget(npc)
            self.NPCCount = self.NPCCount + 1
        end
    end
    

    for _, spawnedNPC in ipairs(spawnedNPCs) do
        local npc = spawnedNPC.entity
        local npcDef = spawnedNPC.def
        
        if IsValid(npc) and npcDef.relationship then
            local targetClass = npcDef.relationship.class
            local disposition = npcDef.relationship.disposition
            
            for _, targetNPC in ipairs(ents.FindByClass(targetClass)) do
                if IsValid(targetNPC) then
                    npc:AddEntityRelationship(targetNPC, disposition, 99)
                    targetNPC:AddEntityRelationship(npc, disposition, 99)
                end
            end
        end
    end
    
    print("[DEFENSE] Wave " .. self.Wave .. " started with " .. self.NPCCount .. " NPCs")
end


function MODE:OnNPCKilled(npc, attacker, inflictor)    
    if not npc or not IsValid(npc) then return end
    
    if npc:GetClass() == "zb_temporary_ent" then return end
    
    if not self.NPCCount then
        self.NPCCount = 0
    end
    

    self.Wave = self.Wave or 0
    self.TotalWaves = self.TotalWaves or 6

    if npc.IsDefenseWaveNPC then
        self.NPCCount = math.max(0, self.NPCCount - 1)
    
        if self.NPCCount <= 0 then
            self:EndWave() 
            

            if self.Wave and self.TotalWaves and self.Wave < self.TotalWaves then
                timer.Simple(1, function()
                    if type(self.StartNewWave) == "function" then
                        self:StartNewWave()
                    end
                end)
            end
        end
    end
end
