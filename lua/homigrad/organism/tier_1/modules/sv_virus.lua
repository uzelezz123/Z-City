util.AddNetworkString("VirusStageUpdate")

local VirusModule = {}
hg.organism.module.virus = VirusModule

function VirusModule.InfectPlayer(ply)
    if ply.Virus and ply.Virus.Infected then return end
    ply.Virus = {
        Infected = true,
        Stage = 1,
        NextStageTime = CurTime() + 120,
        Pain = 0,
        PainTarget = 0,
        OxygenIssues = false,
        InternalBleeding = false,
        Convulsions = false,
        Damage = 0,
        LungDamage = 0,
        BrainDamage = 0,
        BrainDamageInterval = 2,
        NextBrainDamageTime = CurTime(),
        NextHPDamageTime = CurTime() + 5,
        NextOxygenIssueTime = CurTime() + math.random(10, 15)
    }
    net.Start("VirusStageUpdate")
    net.WriteInt(ply.Virus.Stage, 8)
    net.Send(ply)
    --print(ply:Nick() .. " has been infected with the virus.")
end

function VirusModule.UpdateVirusStage(ply)
    local virus = ply.Virus
    if not virus or not virus.Infected then return end

    if CurTime() >= virus.NextStageTime then
        virus.Stage = virus.Stage + 1
        virus.NextStageTime = CurTime() + 120

        --print(ply:Nick() .. " has progressed to virus stage " .. virus.Stage)

        if virus.Stage == 2 then
            virus.PainTarget = 5
        elseif virus.Stage == 3 then
            virus.PainTarget = 10
            virus.OxygenIssues = true
            virus.Damage = 3
            virus.LungDamage = 0.2
        elseif virus.Stage == 4 then
            virus.OxygenIssues = nil
            virus.PainTarget = 20
            virus.Damage = 5
            virus.LungDamage = 0.3
            virus.InternalBleeding = true
            ply.organism.internalBleed = 10 
            ply.organism.otrub = true
            timer.Simple(math.random(10, 20), function()
                if IsValid(ply) then
                    ply.organism.otrub = false
                end
            end)
        elseif virus.Stage == 5 then
            virus.PainTarget = 30
            virus.Damage = 4
            virus.LungDamage = 0.5
            virus.BrainDamage = 0.03
            ply.organism.internalBleed = 20 
            ply.organism.otrub = true
        end

        net.Start("VirusStageUpdate")
        net.WriteInt(virus.Stage, 8)
        net.Send(ply)
    end
end

function VirusModule.ApplyVirusEffects(ply)
    local virus = ply.Virus
    if not virus or not virus.Infected then return end

    if virus.Stage >= 2 then
        if CurTime() >= virus.NextHPDamageTime then
            ply:TakeDamage(2, ply, ply)
            virus.NextHPDamageTime = CurTime() + 5
        end
        ply.organism.lungsL[1] = math.min(ply.organism.lungsL[1] + virus.LungDamage, 1)
        ply.organism.lungsR[1] = math.min(ply.organism.lungsR[1] + virus.LungDamage, 1)
    end

    if virus.Stage == 5 and CurTime() >= virus.NextBrainDamageTime then
        ply.organism.brain = ply.organism.brain + virus.BrainDamage
        virus.NextBrainDamageTime = CurTime() + virus.BrainDamageInterval
    end

    if virus.OxygenIssues and CurTime() >= virus.NextOxygenIssueTime then
        ply.organism.o2[1] = math.max(ply.organism.o2[1] - 20, 5)
        timer.Simple(5, function()
            if IsValid(ply) then
                ply.organism.o2[1] = math.min(ply.organism.o2[1] + 20, 30)
                virus.NextOxygenIssueTime = CurTime() + math.random(10, 15)
            end
        end)
    end

    if virus.InternalBleeding then
        ply.organism.internalBleed = 10
    end

    if virus.Convulsions and math.random(1, 100) <= 5 then
        ply.organism.otrub = true
        timer.Simple(math.random(10, 20), function()
            if IsValid(ply) then
                ply.organism.otrub = false
            end
        end)
    end

    if virus.Pain < virus.PainTarget then
        virus.Pain = math.min(virus.Pain + 0.1, virus.PainTarget)
    elseif virus.Pain > virus.PainTarget then
        virus.Pain = math.max(virus.Pain - 0.1, virus.PainTarget)
    end

    ply.organism.pain = virus.Pain
end

function VirusModule.ApplyVirusConvulsions(ply)
    local virus = ply.Virus
    if virus and virus.Convulsions and virus.Stage == 5 and ply.organism.otrub then
        local character = hg.GetCurrentCharacter(ply) or ply
        local mul = (60 - CurTime()) / 60
        if mul > 0 then
            for i = 0, character:GetPhysicsObjectCount() - 1 do
                local phys = character:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:ApplyForceCenter(VectorRand(-750 * mul, 750 * mul))
                end
            end
        end
    end
end

hook.Add("Org Think", "VirusUpdate", function(ply)
    if not ply:IsPlayer() or not ply:Alive() then return end
    if ply:IsPlayer() and ply.Virus and ply.Virus.Infected then
        VirusModule.UpdateVirusStage(ply)
        VirusModule.ApplyVirusEffects(ply)
        VirusModule.ApplyVirusConvulsions(ply)
    end
end)

hook.Add("EntityTakeDamage", "ZombieInfect", function(target, dmginfo)
    if target:IsPlayer() and dmginfo:GetAttacker():IsNPC() then
        local attackerClass = dmginfo:GetAttacker():GetClass()
        if attackerClass == "terminator_nextbot_zambie" or attackerClass == "terminator_nextbot_zambietorso" then
            if target.Virus and target.Virus.Infected then return end
            local chance = target.VirusInfectionChance or 5
            --print(target:Nick() .. " has a " .. chance .. "% chance of being infected.")
            if math.random(1, 100) <= chance then
                VirusModule.InfectPlayer(target)
            else
                target.VirusInfectionChance = (target.VirusInfectionChance or 5) + 5
                --print(target:Nick() .. "'s infection chance increased to " .. target.VirusInfectionChance .. "%.")
            end
        end
    end
end)

hook.Add("PlayerDeath", "VirusReset", function(ply)
    ply.Virus = nil
    --print(ply:Nick() .. " has died and the virus has been reset.")
end)

hook.Add("Org Clear", "VirusClear", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        ply.Virus = nil
    end
end)
