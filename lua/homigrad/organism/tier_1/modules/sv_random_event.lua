--local Organism = hg.organism
hg.organism.module.random_events = {}
local module = hg.organism.module.random_events
module[1] = function(org)
	org.timeToRandom = CurTime() + math.random(120,320)
end

local RandomEvents = {
    ["Sneeze"] = function( owner, org )
        owner:EmitSound(ThatPlyIsFemale(owner) and "zcitysnd/female/sneez_"..math.random(1,4)..".mp3" or "zcitysnd/male/sneez_"..math.random(1,4)..".mp3", nil, 100 + (owner.PlayerClassName == "furry" and 20 or 0))
        timer.Simple(.5,function()
            owner:ViewPunch(Angle(-2,0,0))
            timer.Simple(.3,function()
                owner:ViewPunch(Angle(5,0,0))
            end)
        end)
    end,
    ["Hungry"] = function( owner, org )
        owner:EmitSound("zcitysnd/uni/hungry_"..math.random(1,6)..".mp3", nil, 100 + (owner.PlayerClassName == "furry" and 20 or 0))
    end,
    ["Burp"] = function( owner, org )
        owner:EmitSound("snd_jack_hmcd_burp.wav", nil, 100 + (owner.PlayerClassName == "furry" and 20 or 0))
        for i = 1, 10 do
            timer.Simple(i/20,function()
                owner:ViewPunch(AngleRand(-.3,.3))
            end)
        end
    end,
    ["Fart"] = function( owner, org )
        owner:EmitSound("snd_jack_hmcd_fart.wav")
        for i = 1, 30 do
            timer.Simple(i/60,function()
                if not IsValid(owner) then return end
                owner:ViewPunch(AngleRand(-.1,.1))
            end)
        end 
    end,
    ["Cough"] = function( owner, org )
        owner:EmitSound(ThatPlyIsFemale(owner) and "zcitysnd/female/cough_"..math.random(1,6)..".mp3" or "zcitysnd/male/cough_"..math.random(1,6)..".mp3",75,100 + (owner.PlayerClassName == "furry" and 20 or 0),1)
        timer.Simple(.3,function()
            owner:ViewPunch(Angle(3,0,0))
            timer.Simple(.3,function()
                owner:ViewPunch(Angle(2,0,0))
            end)
        end) -- жаль что сломалось, а ради этого неты делать ну, такое... | update уже неважно
    end,
} 

function module.TriggerRandomEvent(owner, eventName)
    if RandomEvents[eventName] then
        if owner:IsRagdoll() then return end
        RandomEvents[eventName](owner, owner.organism)
    end
end

module[2] = function(owner, org, timeValue)
    --print("huy")
    if org.timeToRandom < CurTime() and owner:IsPlayer() and owner:Alive() and owner.PlayerClassName ~= "Combine" then -- Манютка переделывай говно. сделай в классе переменную об этом. либо дай овнеру просто переменную насчет этого.
        if not org.otrub then
            table.Random(RandomEvents)(owner,org)
        end 
        org.timeToRandom = CurTime() + math.random(120,320)
    end
end

hook.Add("Org Think", "VirusRandomEvents", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if owner:IsPlayer() and owner.Virus and owner.Virus.Infected and (owner.Virus.Stage == 1 or owner.Virus.Stage == 2) then
        if not owner.NextVirusRandomEventTime or CurTime() >= owner.NextVirusRandomEventTime then
            local event = math.random(1, 2) == 1 and "Cough" or "Sneeze"
            module.TriggerRandomEvent(owner, event)
            owner.NextVirusRandomEventTime = CurTime() + math.random(10, 15)
        end
    end
end)