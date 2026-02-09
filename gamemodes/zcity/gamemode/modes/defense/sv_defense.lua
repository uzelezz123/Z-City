--[[
  _   _                ______       __                       
 | \ | |               |  _  \     / _|                      
 |  \| | _____      __ | | | |____| |_ ___ _ __  ___  ___ 
 | . ` |/ _ \ \ /\ / / | | | / _ \  _/ _ \ '_ \/ __|/ _ \
 | |\  |  __/\ V  V /  | |/ /  __/ |  __/ | | \__ \  __/
 \_| \_/\___| \_/\_/   |___/ \___|_|\___|_| |_|___/\___|                                                
]]--

local MODE = MODE
MODE.Timers = MODE.Timers or {}
MODE.name = "defense"
MODE.PrintName = "NPC Defense"
MODE.randomSpawns = true
MODE.ROUND_TIME = 10000
MODE.TotalWaves = 6  
MODE.CurrentSubMode = "STANDARD" 
MODE.LootSpawn = true
MODE.ForBigMaps = true
MODE.Chance = 0.02



util.AddNetworkString("defense_start_vote")
util.AddNetworkString("defense_submit_vote")
util.AddNetworkString("defense_change_vote") 
util.AddNetworkString("defense_vote_result")
util.AddNetworkString("defense_vote_update")
util.AddNetworkString("defense_show_selected_mode")
util.AddNetworkString("npc_defense_start")
util.AddNetworkString("npc_defense_newwave")
util.AddNetworkString("npc_defense_roundend")
util.AddNetworkString("npc_defense_prepphase")
util.AddNetworkString("StartWaveMusic")
util.AddNetworkString("StopWaveMusic")
util.AddNetworkString("defense_boss_incoming") 

MODE.VoteTime = 15
MODE.VoteResults = {
    [1] = 0, 
    [2] = 0, 
    [3] = 0  
}
MODE.VoteInProgress = false


function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1.5, true
end


function MODE:IsBossWave(wave)
    wave = wave or self.Wave
    
    if not self.CurrentSubMode or not wave then return false end
    
    local waveDefinitions = DEFENSE_WAVE_DEFINITIONS[self.CurrentSubMode]
    if not waveDefinitions or not waveDefinitions[wave] then return false end
    
    local currentWave = waveDefinitions[wave]
    for _, npcDef in ipairs(currentWave or {}) do
        if npcDef.boss then
            return true
        end
    end
    
    return false
end

function MODE:GetCurrentWaveDefinition()
    if not self.CurrentSubMode or not self.Wave then return nil end
    
    local waveDefinitions = DEFENSE_WAVE_DEFINITIONS[self.CurrentSubMode]
    if not waveDefinitions then return nil end
    
    return waveDefinitions[self.Wave]
end

function MODE:IsWaveActive()
    return self.WaveActive
end

function MODE:StartWave()
    self.WaveActive = true

    if DEFENSE_MUSIC.WAVE[self.Wave] then
        net.Start("StartWaveMusic")
        net.WriteString(DEFENSE_MUSIC.WAVE[self.Wave])
        net.Broadcast()
    end
end

function MODE:EndWave()
    self.WaveActive = false
    self:ClearAllTimers()

    net.Start("StopWaveMusic")
    net.Broadcast()

    if DEFENSE_MUSIC.WAITING[self.Wave] and zb.ROUND_STATE == 1 then
        net.Start("StartWaveMusic")
        net.WriteString(DEFENSE_MUSIC.WAITING[self.Wave])
        net.Broadcast()
    end
    
    self.WaveCompleted = true
    

    timer.Simple(1, function()
        for _, ent in ents.Iterator() do
            if IsValid(ent) then
                if ent:GetClass() == "prop_ragdoll" then
                    local org = ent.organism
                    if not (org and org.isPly) then
                        ent:Remove()
                    end
                end
                

                if ent:IsWeapon() and not IsValid(ent:GetOwner()) then
                    ent:Remove()
                end
            end
        end
    end)

    self:OnWaveComplete()

    if self.Wave and self.TotalWaves and self.Wave >= self.TotalWaves then
        timer.Simple(5, function()
            if zb and zb.ROUND_STATE == 1 then
                zb.EndMatch()
            end
        end)
    end
end

function MODE:CanLaunch()
	local points = zb.GetMapPoints( "PLY_DEFENSE_SPAWN" )
	local points2 = zb.GetMapPoints( "NPC_DEFENSE_SPAWN" )
    
    return false--(#points > 0) and (#points2 > 0)
end

function MODE:Intermission()
    self.NPCCount = 0
    self.Wave = 0
    self.WaveActive = false
    self.WaveCompleted = false

    self:ClearAllTimers() 
    game.CleanUpMap()

    self.SpawnPoints = zb.GetMapPoints("PLY_DEFENSE_SPAWN")
    if not self.SpawnPoints then
        self.SpawnPoints = {}
    end

    for k, ply in player.Iterator() do
        if ply:Team() == TEAM_SPECTATOR then continue end
        ply:SetupTeam(1)
        ply.HasVoted = nil
        
        if ply:Alive() then
            ply:KillSilent()
        end
    end

    self:EndWave()
    self:StartVoting()
end

function MODE:StartVoting()
    self.VoteResults = {
        [1] = 0, 
        [2] = 0, 
        [3] = 0 
    }
    self.VoteInProgress = true

    net.Start("defense_start_vote")
    net.WriteFloat(CurTime() + self.VoteTime)
    net.Broadcast()
    
   
    self.LastVoteUpdate = CurTime()
    self.VotesChanged = false
    
    self:CreateTimer("vote_end_timer", self.VoteTime, 1, function()
        self:EndVoting()
    end)
    
    
    self:CreateTimer("vote_update_timer", 1, self.VoteTime, function()
        if self.VotesChanged or CurTime() - self.LastVoteUpdate > 5 then
            net.Start("defense_vote_update")
            net.WriteTable(self.VoteResults)
            net.Broadcast()
            
            self.VotesChanged = false
            self.LastVoteUpdate = CurTime()
        end
    end)
end

function MODE:EndVoting()
    self:RemoveTimer("vote_update_timer")
    
    local highestVotes = 0
    local selectedModes = {}
    
    for mode, votes in pairs(self.VoteResults) do
        if mode == 3 then continue end
        
        if votes > highestVotes then
            highestVotes = votes
        end
    end
    
    for mode, votes in pairs(self.VoteResults) do
        if mode == 3 then continue end
        
        if votes == highestVotes then
            table.insert(selectedModes, mode)
        end
    end
    
    local selectedMode = 1 
    if #selectedModes > 0 then
        selectedMode = selectedModes[math.random(#selectedModes)]
    end
    

    if selectedMode == 3 then
        selectedMode = 1 
    end
    
    if selectedMode == 1 then
        self.CurrentSubMode = "STANDARD"
        self.TotalWaves = 6
    elseif selectedMode == 2 then
        self.CurrentSubMode = "EXTENDED"
        self.TotalWaves = 12
    elseif selectedMode == 3 then
        self.CurrentSubMode = "STANDARD"
        self.TotalWaves = 6
    end
    
    net.Start("defense_vote_result")
    net.WriteString(self.CurrentSubMode)
    net.WriteTable(self.VoteResults)
    net.Broadcast()
    
    net.Start("defense_show_selected_mode")
    net.WriteString(self.CurrentSubMode)
    net.Broadcast()

    self.VoteInProgress = false
    
    timer.Simple(3, function()
        net.Start("npc_defense_start")
        net.Broadcast()
        self:StartPrepPhase()
    end)
end

function MODE:StartPrepPhase()
    for _, ply in player.Iterator() do
        if ply:Team() ~= TEAM_SPECTATOR and not ply:Alive() then
            ply:Spawn()
        end
    end

    for _, ply in player.Iterator() do
        ply.HasVoted = nil
    end

    net.Start("npc_defense_prepphase")
    net.Broadcast()

    self:GiveEquipment()

    self:CreateTimer("prep_phase_timer", 30, 1, function()
        self.Wave = 1
        self.NPCCount = 0  
        self:StartWave()  
        self:SpawnWave()
    end)

    net.Start("npc_defense_newwave")
        net.WriteFloat(CurTime() + 30)
        net.WriteInt(self.Wave, 4)
    net.Broadcast()
end

function MODE:ShouldRoundEnd()
    if self.VoteInProgress then
        return false
    end
    
    if (#zb:CheckAlive(true) <= 0) then
        local menuActive = false
        for _, ply in player.Iterator() do
            if ply.HasVoted ~= nil then
                menuActive = true
                break
            end
        end
        
        if menuActive then
            return false
        end
        
        return true
    end
    
    if self.WaveCompleted and self.Wave >= self.TotalWaves then
        return true
    end
    
    return false
end

function MODE:RoundStart()
    if DEFENSE_MUSIC.WAITING[0] then
        net.Start("StartWaveMusic")
        net.WriteString(DEFENSE_MUSIC.WAITING[0])
        net.Broadcast()
    end
end

function MODE:RoundThink()
    self.Wave = self.Wave or 0
    self.TotalWaves = self.TotalWaves or 6
    self.WaveCompleted = self.WaveCompleted or false
    
    if not self:IsWaveActive() then
        if self.WaveCompleted and self.Wave and self.TotalWaves and self.Wave >= self.TotalWaves then
            if zb and type(zb.EndMatch) == "function" then
                zb.EndMatch()
            else

                self:ClearAllTimers()
                timer.Simple(1, function()
                    game.CleanUpMap()
                    RunConsoleCommand("gamemode_restart") --;; :trollface:
                end)
            end
        end
        return
    end


    if not self.nextNPCCheck or self.nextNPCCheck < CurTime() then
        self.nextNPCCheck = CurTime() + 2 
        

        if not self.DefenseWaveEntities then
            self.DefenseWaveEntities = {}
        end
        
        local validNPCCount = 0
        

        for id, ent in pairs(self.DefenseWaveEntities) do
            if IsValid(ent) then
                if ent:GetClass() == "zb_temporary_ent" then
                    self.DefenseWaveEntities[id] = nil
                    continue
                end

                local isDead = false
                
                if ent.IsZBaseNPC then
                    isDead = (ent.Dead == true)
                elseif ent:IsNPC() then
                    isDead = (ent:Health() <= 0)
                end
                

                if not isDead and not ent.DefenseNPCCountedAsDead then
                    validNPCCount = validNPCCount + 1
                else

                    if not ent.DefenseNPCCountedAsDead then
                        print("[DEFENSE] Marking NPC as dead: " .. ent:GetClass())
                        ent.DefenseNPCCountedAsDead = true
                        self.DefenseWaveEntities[id] = nil
                    end
                end
            else

                self.DefenseWaveEntities[id] = nil
            end
        end
        
        -- Для чего ты вызываешь вообще все ентити, ТЕБЕ БАНАЛЬНО ВЫГОДНО ИСПОЛЬЗОВАТЬ ents.FindByClass() 
        -- КАКОГО ЧЕРТА У ТЕБЯ ТУТ ВООБЩЕ ЧЕРЕЗ ПЕЙРСЫ... И еще и в думалке D:
        for _, ent in ents.Iterator() do -- дека если ты это не перепишишь я удалю этот режим. | SALAT :3
            if IsValid(ent) and ent.IsDefenseWaveNPC and not ent.DefenseNPCCountedAsDead then
                local class = ent:GetClass() or ""
                

                if class == "zb_temporary_ent" then continue end

                if (ent:IsNPC() or 
                    string.find(class, "npc_vj_") or 
                    string.find(class, "sent_vj_") or
                    string.find(class, "zb_") or 
                    string.find(class, "terminator_nextbot_")) and
                   class ~= "npc_bullseye" and 
                   class ~= "npc_enemyfinder" and 
                   class ~= "npc_bullseye_new" then
                    
                    local isDead = false
                    
                    if ent.IsZBaseNPC then
                        isDead = (ent.Dead == true)
                    elseif ent:IsNPC() then
                        isDead = (ent:Health() <= 0)
                    end
                    
                    if not isDead then

                        if not ent.DefenseEntityID then
                            ent.DefenseEntityID = "defense_npc_" .. ent:EntIndex() .. "_" .. math.random(1000, 9999)
                            self.DefenseWaveEntities[ent.DefenseEntityID] = ent
                            print("[DEFENSE] Found new NPC to track: " .. class)
                        end
                        
                        validNPCCount = validNPCCount + 1
                    else

                        ent.DefenseNPCCountedAsDead = true
                    end
                end
            end
        end
        

        if validNPCCount != self.NPCCount then
            print("[DEFENSE] NPC Count Updated: " .. self.NPCCount .. " -> " .. validNPCCount)
            self.NPCCount = validNPCCount
        end
        

        if self.NPCCount <= 0 and self:IsWaveActive() then
            print("[DEFENSE] Wave Ended: No NPCs remaining!")
            self:EndWave()
            
            if self.Wave < self.TotalWaves then
                timer.Simple(1, function()
                    if type(self.StartNewWave) == "function" then
                        self:StartNewWave()
                    end
                end)
            end
        end
    end
end

function MODE:EndRound()
    net.Start("npc_defense_roundend")
    net.Broadcast()
    self:EndWave()
    self:ClearPlayerRoles()
    self:ClearAllTimers()
    

    self.DefenseWaveEntities = {}
    self.NPCCount = 0
    

    for _, ent in pairs(ents.GetAll()) do -- дека если ты это не перепишишь я удалю этот режим. | SALAT :3
        if IsValid(ent) and (ent:IsNPC() or 
            string.find(tostring(ent:GetClass() or ""), "npc_vj_") or
            string.find(tostring(ent:GetClass() or ""), "sent_vj_") or
            string.find(tostring(ent:GetClass() or ""), "zb_") or
            string.find(tostring(ent:GetClass() or ""), "terminator_nextbot_")) then
            ent:Remove()
        end
    end
end

function MODE:PlayerDeath(ply)

end

function MODE:CreateTimer(name, delay, repetitions, func)
    timer.Create(name, delay, repetitions, func)
    table.insert(self.Timers, name) 
end

function MODE:RemoveTimer(name)
    if timer.Exists(name) then
        timer.Remove(name)
    end
    for i, timerName in ipairs(self.Timers) do
        if timerName == name then
            table.remove(self.Timers, i)
            break
        end
    end
end

function MODE:ClearAllTimers()
    for _, timerName in ipairs(self.Timers) do
        if timer.Exists(timerName) then
            timer.Remove(timerName)
        end
    end
    self.Timers = {}
end

net.Receive("defense_submit_vote", function(len, ply)
    if not IsValid(ply) then return end
    

    if not ply.LastVoteTime then ply.LastVoteTime = 0 end
    if CurTime() - ply.LastVoteTime < 1 then return end
    ply.LastVoteTime = CurTime()
    
    local vote = net.ReadInt(4)
    if vote < 1 or vote > 3 then return end

    if vote == 3 then return end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" or not MODE.VoteInProgress then return end
    
    if not ply.HasVoted then
        MODE.VoteResults[vote] = MODE.VoteResults[vote] + 1
        ply.HasVoted = vote 
        
        
        MODE.VotesChanged = true
        
        
        if CurTime() - MODE.LastVoteUpdate > 2 or math.random(1, 3) == 1 then
            net.Start("defense_vote_update")
            net.WriteTable(MODE.VoteResults)
            net.Broadcast()
            MODE.LastVoteUpdate = CurTime()
            MODE.VotesChanged = false
        end
    end
end)

net.Receive("defense_change_vote", function(len, ply)
    if not IsValid(ply) then return end
    
    if not ply.LastVoteChangeTime then ply.LastVoteChangeTime = 0 end
    if CurTime() - ply.LastVoteChangeTime < 1 then return end
    ply.LastVoteChangeTime = CurTime()
    
    local previousVote = net.ReadInt(4)
    local newVote = net.ReadInt(4)
    
    if newVote < 1 or newVote > 3 then return end
    
    if newVote == 3 then return end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" or not MODE.VoteInProgress then return end
    
    if ply.HasVoted and ply.HasVoted > 0 and ply.HasVoted <= 3 then
        MODE.VoteResults[ply.HasVoted] = math.max(0, MODE.VoteResults[ply.HasVoted] - 1)
    end
    
    MODE.VoteResults[newVote] = MODE.VoteResults[newVote] + 1
    ply.HasVoted = newVote
    
    
    MODE.VotesChanged = true
    
    
    if CurTime() - MODE.LastVoteUpdate > 1 then
        net.Start("defense_vote_update")
        net.WriteTable(MODE.VoteResults)
        net.Broadcast()
        MODE.LastVoteUpdate = CurTime()
        MODE.VotesChanged = false
    end
end)



