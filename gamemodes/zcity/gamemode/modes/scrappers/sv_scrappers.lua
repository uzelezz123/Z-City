MODE.name = "scrappers"
MODE.PrintName = "Scrappers"
MODE.start_time = 0
MODE.end_time = 5
 
MODE.ROUND_TIME = 300
 

MODE.OverrideSpawn = true
MODE.LootSpawn = true
MODE.ForBigMaps = true

MODE.Chance = 0.05

local MODE = MODE

function MODE:CanLaunch()
    return false
end

util.AddNetworkString("zb_Scrappers_BuyOut")
util.AddNetworkString("zb_Scrappers_BoughtUpdate")
util.AddNetworkString("zb_Scrappers_BuyingItem")
util.AddNetworkString("zb_CreateShopMenu")
util.AddNetworkString("zb_RemoveShopMenu")
util.AddNetworkString("zb_FromInvToRaid")
util.AddNetworkString("zb_FromRaidToInv")
util.AddNetworkString("zb_FromRaidToInvTable")
util.AddNetworkString("ZB_PlayerReady")
util.AddNetworkString("zb_SellItem")
util.AddNetworkString("zb_Scrappers_SendShop")

net.Receive("zb_Scrappers_BuyOut", function(len, ply) --Бог простит
    --таб - вкладка магазина ("Weapons", "Medicine " и т.д.)--religious fix
    local tab = net.ReadString()
    --позиция - место в таблице, таблица идёт через цифры.
    local pos = net.ReadUInt(16)

    --проверки на то, продали ли уже и ставит ли новую ставку тот же игрок
    if zb.ScrappersScrambledList[tab][pos].Bought then return end
    if zb.ScrappersScrambledList[tab][pos].BuyingOut and zb.ScrappersScrambledList[tab][pos].BuyingOut == ply then return end

    --если мод мало денег то ретурн
    local price = (zb.ScrappersScrambledList[tab][pos].AuctionPrice and (zb.ScrappersScrambledList[tab][pos].AuctionPrice - (zb.ScrappersScrambledList[tab][pos].PaidPlayers[ply] or 0))) or zb.ScrappersScrambledList[tab][pos].price
    if ply:GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney) < price then return end

    --новая цена ставится на прошлую + 100
    zb.ScrappersScrambledList[tab][pos].AuctionPrice = (zb.ScrappersScrambledList[tab][pos].AuctionPrice and zb.ScrappersScrambledList[tab][pos].AuctionPrice + 100) or zb.ScrappersScrambledList[tab][pos].price + 100

    --человек который купит этот предмет через 10 секунд
    zb.ScrappersScrambledList[tab][pos].BuyingOut = ply

    --люди которые когда-то потратили деньги на этот предмет, если кто-то его купит вместо них то им вернут деньги
    zb.ScrappersScrambledList[tab][pos].PaidPlayers = zb.ScrappersScrambledList[tab][pos].PaidPlayers or {}

    --мод мало денег
    ply:SetLocalVar("zb_Scrappers_Money", ply:GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney) - price)

    --^ то что сверху, добавляются в список
    zb.ScrappersScrambledList[tab][pos].PaidPlayers[ply] = zb.ScrappersScrambledList[tab][pos].AuctionPrice - 100 or zb.ScrappersScrambledList[tab][pos].price

    net.Start("zb_Scrappers_BuyingItem")
        net.WriteString(tab)
        net.WriteUInt(pos, 16)

        --время покупки для нормальной синхронизации
        net.WriteFloat(math.Round(CurTime(), 2))

        --цена предмета на данный момент
        net.WriteUInt(zb.ScrappersScrambledList[tab][pos].AuctionPrice or zb.ScrappersScrambledList[tab][pos].price, 32)
    net.Broadcast()

    timer.Create("zb_Scrappers_BuyOut_" .. tab .. "_" .. pos, 10, 1, function()
        local inventory = ply:GetLocalVar("zb_Scrappers_Inventory", {})

        --поздравим покупателя! ему добавляется предмет в инвентарь
        local weapon = hg.GetItem(zb.ScrappersScrambledList[tab][pos].weapon) or {}
        local slot = weapon and weapon.ScrappersSlot or "Other"

        inventory[slot] = inventory[slot] or {}
        table.insert(inventory[slot],zb.ScrappersScrambledList[tab][pos].weapon)
        --print(slot,zb.ScrappersScrambledList[tab][pos].weapon)
        ply:SetLocalVar("zb_Scrappers_Inventory", inventory)

        --деньги возвращаются
        for k, v in pairs(zb.ScrappersScrambledList[tab][pos].PaidPlayers) do
            if k == ply then continue end

            k:SetLocalVar("zb_Scrappers_Money", k:GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney) + v)
        end

        zb.ScrappersScrambledList[tab][pos].BuyingOut = nil
        zb.ScrappersScrambledList[tab][pos].Bought = true

        --сказать всем что этот предмет был куплен на алиэкспресс
        net.Start("zb_Scrappers_BoughtUpdate")
            net.WriteString(tab)
            net.WriteUInt(pos, 16)
        net.Broadcast()
    end)
end)

-- Мод много продаж
net.Receive("zb_SellItem", function(len, ply) -- Бог простил
    local slot = net.ReadUInt(16)
    local pos = net.ReadUInt(16)
    
    local Inventory = ply:GetLocalVar("zb_Scrappers_Inventory", {})
    
    if table.IsEmpty(Inventory) then return end
    if !Inventory[slot] or !Inventory[slot][pos] then return end
    local weapon = hg.GetItem(Inventory[slot][pos]) or {}
    local slot2 = weapon and weapon.ScrappersSlot or "Other"

    if not MODE.ShopList[table.GetKeys(MODE.ShopList)[ slot2 ]][ Inventory[slot][pos] ] then return end
    local price = MODE.ShopList[table.GetKeys(MODE.ShopList)[slot2]][Inventory[slot][pos]]["price"]
    ply:SetLocalVar("zb_Scrappers_Money", ply:GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney) + price - (price * (50/100)))
    Inventory[slot][pos] = nil

    ply:SetLocalVar("zb_Scrappers_Inventory", Inventory)

end) -- А ведь реально простил...

zb.slotFunctions = {
    ["Primary"] = function(RaidInventory,Inventory,slot,pos)--primary
        if RaidInventory[slot] or not table.IsEmpty(RaidInventory[slot]) then return end
        
        RaidInventory[slot] = Inventory[slot][pos]
        Inventory[slot][pos] = nil
    end,
    ["Secondary"] = function(RaidInventory,Inventory,slot,pos)--secondary
        if RaidInventory[slot] and not table.IsEmpty(RaidInventory[slot]) then return end
        
        RaidInventory[slot] = Inventory[slot][pos]
        Inventory[slot][pos] = nil
    end,
    ["Melee"] = function(RaidInventory,Inventory,slot,pos)--melee
        if RaidInventory[slot] and table.HasValue(RaidInventory[slot],Inventory[slot][pos]) then return end

        RaidInventory[slot][#RaidInventory[slot] + 1] = Inventory[slot][pos]
        Inventory[slot][pos] = nil
    end,
    ["Medicine"] = function(RaidInventory,Inventory,slot,pos)--medicine
        if RaidInventory[slot] and table.HasValue(RaidInventory[slot],Inventory[slot][pos]) then return end

        RaidInventory[slot][#RaidInventory[slot] + 1] = Inventory[slot][pos]
        Inventory[slot][pos] = nil
    end,
    ["Other"] = function(RaidInventory,Inventory,slot,pos)--other
        if RaidInventory[slot] and table.HasValue(RaidInventory[slot],Inventory[slot][pos]) then return end
        RaidInventory[slot][#RaidInventory[slot] + 1] = Inventory[slot][pos]
        Inventory[slot][pos] = nil
    end,
    ["Armor"] = function(RaidInventory,Inventory,slot,pos)--armor
        if RaidInventory[slot][hg.GetArmorPlacement(Inventory[slot][pos])] then return end
        
        RaidInventory[slot][hg.GetArmorPlacement(Inventory[slot][pos])] = Inventory[slot][pos]
        Inventory[slot][pos] = nil
    end,
}

net.Receive("zb_FromInvToRaid", function(len, ply)
    local slot = net.ReadString()
    local pos = net.ReadUInt(16)
    local RaidInventory = ply:GetLocalVar("zb_Scrappers_RaidInventory", {})
    local Inventory = ply:GetLocalVar("zb_Scrappers_Inventory", {})
    
    if table.IsEmpty(Inventory) then return end
    if !Inventory[slot] or !Inventory[slot][pos] then return end
    local item = hg.GetItem(Inventory[slot][pos])
    local slot = item.ScrappersSlot or "Other"
    
    RaidInventory[slot] = RaidInventory[slot] or {}

    if zb.slotFunctions[slot] then
        zb.slotFunctions[slot](RaidInventory,Inventory,slot,pos)
    else
        table.insert(RaidInventory[slot],Inventory[slot][pos])
        Inventory[slot][pos] = nil
    end
    
    ply:SetLocalVar("zb_Scrappers_RaidInventory", RaidInventory)
    ply:SetLocalVar("zb_Scrappers_Inventory", Inventory)
end)

net.Receive("zb_FromRaidToInv", function(len, ply)
    local slot = net.ReadString()
    local pos = net.ReadUInt(8)

    local RaidInventory = ply:GetLocalVar("zb_Scrappers_RaidInventory", {})
    local Inventory = ply:GetLocalVar("zb_Scrappers_Inventory", {})

    if table.IsEmpty(RaidInventory) then return end
    if !RaidInventory[slot] or !RaidInventory[slot][pos] then return end
    local item = hg.GetItem(istable(RaidInventory[slot]) and RaidInventory[slot][pos] or RaidInventory[slot])
    slot = item.ScrappersSlot or "Other"

    Inventory[slot] = Inventory[slot] or {}
    if istable(RaidInventory[slot]) then
        table.insert(Inventory[slot],RaidInventory[slot][pos])
        RaidInventory[slot][pos] = nil
    else
        table.insert(Inventory[slot],RaidInventory[slot])
        RaidInventory[slot] = nil
    end

    ply:SetLocalVar("zb_Scrappers_RaidInventory", RaidInventory)
    ply:SetLocalVar("zb_Scrappers_Inventory", Inventory)
end)

zb.ReadyPlayers = zb.ReadyPlayers or {}
net.Receive("ZB_PlayerReady", function(len, ply)
    do return true end
    zb.ReadyPlayers[ply] = true

    if timer.Exists("zb_Scrappers_LobbyEnd") and table.Count(zb.ReadyPlayers) >= math.ceil(#player.GetAll() / 1.5) then
        timer.Adjust("zb_Scrappers_LobbyEnd", math.min(timer.TimeLeft("zb_Scrappers_LobbyEnd"),30))
        SetNetVar("Scrappers_LobbyEnd", math.Round(CurTime()) + math.min(timer.TimeLeft("zb_Scrappers_LobbyEnd"),30))
    end
end)

function MODE:ShouldRoundEnd()
    local playersAlive = zb:CheckAlive()
    if timer.Exists("zb_Scrappers_ExtractionTime") and #playersAlive == 0 then
        timer.Adjust("zb_Scrappers_ExtractionTime",0)
    end
    return false
end

function MODE:Intermission()
end

function MODE:ConvertLoadoutToInventory(ply)
    local loadout = ply:GetWeapons()
    local RaidInventory = {}

    for k, v in ipairs(loadout) do
        if v:GetClass() == "weapon_hands_sh" then continue end

        local slot = hg.GetItem(v:GetClass()).ScrappersSlot or "Other"

        RaidInventory[slot] = RaidInventory[slot] or {}
        RaidInventory[slot][#RaidInventory[slot] + 1] = v:GetClass()
    end

    RaidInventory["Armor"] = {}
    for plc,arm in pairs(ply:GetNetVar("Armor")) do
        RaidInventory["Armor"][#RaidInventory["Armor"] + 1] = "ent_armor_" .. arm
    end

    RaidInventory["Other"] = {}
    local tbl = ply:GetNetVar("Inventory")
    for i,att in pairs(tbl["Attachments"]) do
        RaidInventory["Other"][#RaidInventory["Other"] + 1] = "ent_att_" .. att
    end

    for i,ent in pairs(loadout) do
        if ent.attachments and not table.IsEmpty(ent.attachments) then
            for i,att in pairs(ent.attachments) do
                if hg.NotValidAtt(att) then continue end
                RaidInventory["Other"][#RaidInventory["Other"] + 1] = "ent_att_" .. att[1]
            end
        end
    end
    ply:SetLocalVar("zb_Scrappers_RaidInventory", RaidInventory)
end

function MODE:ExtractedPlayer(ply)
    self:ConvertLoadoutToInventory(ply)

    local money = ply:GetNetVar("zb_Scrappers_RaidMoney", 0)
    local MoneyStored = ply:GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney)

    ply:SetLocalVar("zb_Scrappers_Money", MoneyStored + money)
end

function MODE:LoadPlayers()
    local spawns = table.Copy(zb.Points["SCRAPPERS_SPAWNPOINTS"].Points)

    for i, ply in ipairs(player.GetAll()) do

        ApplyAppearance(ply)
        ply:Spawn()
        zb.GiveRole(ply, "Scrapper", Color(190,0,0))

        local random = math.random(#spawns)

        ply:SetPos(spawns[random].pos)
        ply:SetAngles(spawns[random].ang)

        table.remove(spawns, random)

        ply:Give("weapon_hands_sh")
        for k, v in pairs(ply:GetLocalVar("zb_Scrappers_RaidInventory", {})) do
            if not v then continue end
            --print(v)
            --if istable(v) then PrintTable(v) end
            local wep = hg.GiveItem(ply,v)

            timer.Simple(0, function()
                if IsValid(wep) and wep.Primary and wep.Primary.ClipSize and wep.Primary.Ammo then
                    ply:GiveAmmo(wep.Primary.ClipSize * 3, wep.Primary.Ammo, true)
                end
            end)
        end

    end

    SetNetVar("zb_Scrappers_Extraction", math.Round(CurTime()) + self.RoundTime)

    timer.Create("zb_Scrappers_ExtractionTimeAlarm", self.RoundTime - 60, 1, function()
        for k, v in ipairs(player.GetAll()) do
            if !v:Alive() then continue end

            v:EmitSound("zbattle/alarm.wav")
        end
    end)

    timer.Create("zb_Scrappers_ExtractionTime", self.RoundTime, 1, function()
        for i, ply in ipairs(player.GetAll()) do
            local FoundExtract = false

            if ply:Alive() then
                for i2, point in ipairs(zb.Points["SCRAPPERS_EXTRACTION"].Points) do
                    if (ply:GetPos() - point.pos):LengthSqr() < 40000 then
                        self:ExtractedPlayer(ply)
                        FoundExtract = true
                        break
                    end
                end
            end

            if !FoundExtract then
                ply:SetLocalVar("zb_Scrappers_RaidInventory", {})
            end
        end

        self:SubRoundStart()
    end)

end

function MODE:GetRandomSlotWithinLimit(tab, highest, sum)
    local value, key = table.Random(self.ShopList[tab])

    if value.price > highest and highest >= 1000 then value, key, sum = self:GetRandomSlotWithinLimit(tab, highest, sum) end

    sum = sum - value.price

    return value, key, sum
end

function MODE:SubRoundStart()
    zb.ScrappersScrambledList = {}
    zb.ReadyPlayers = {}

    local everyone = player.GetAll()
    local highest = 0
    local moneysum = 0

    for i, ply in pairs(everyone) do
        local money = ply:GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney)

        if money > highest then
            highest = money
        end

        moneysum = moneysum + money

        ApplyAppearance(ply)

        zb.SendSpecificPointsToPly(ply, "SCRAPPERS_EXTRACTION")
    end

    for k, v in pairs(self.ShopList) do
        zb.ScrappersScrambledList[k] = zb.ScrappersScrambledList[k] or {}
        for i = 1, math.Round(#everyone * 1.5) do
            local value, key, sum = self:GetRandomSlotWithinLimit(k, highest, moneysum)
            moneysum = sum

            zb.ScrappersScrambledList[k][i] = {}
            zb.ScrappersScrambledList[k][i].weapon = key
            zb.ScrappersScrambledList[k][i].price = value.price
        end
    end

    timer.Simple(5, function()
        for i, ply in pairs(player.GetAll()) do
            ply:SetVelocity(vector_origin)
            ply:KillSilent()
            ply:SetTeam(0)

            ply:SetNetVar("zb_Scrappers_RaidMoney", 0)
        end
    end)

    game.CleanUpMap()

    for k, v in ipairs(zb.Points["SCRAPPERS_BIGBOX"].Points or {}) do
        local random = math.random(1, 5)

        if random == 1 then
            local box = ents.Create("prop_physics")
            box:SetPos(v.pos)
            box:SetModel("models/props_junk/wood_crate002a.mdl")
            box:SetAngles(v.ang)
            box:Spawn()
        elseif random <= 3 then
            local box = ents.Create("prop_physics")
            box:SetPos(v.pos)
            box:SetModel("models/props_junk/wood_crate001a.mdl")
            box:SetAngles(v.ang)
            box:Spawn()
        end
    end

    for k, v in ipairs(zb.Points["SCRAPPERS_BIGBOX"].Points or {}) do
        local random = math.random(1, 5)

        if random == 1 then
            local box = ents.Create("prop_physics")
            box:SetPos(v.pos)
            box:SetModel("models/props_junk/wood_crate002a.mdl")
            box:SetAngles(v.ang)
            box:Spawn()
        elseif random <= 3 then
            local box = ents.Create("prop_physics")
            box:SetPos(v.pos)
            box:SetModel("models/props_junk/wood_crate001a.mdl")
            box:SetAngles(v.ang)
            box:Spawn()
        end
    end

    for k, v in ipairs(zb.Points["RandomSpawns"].Points or {}) do
        local random = math.random(1, 3)

        if random == 1 then
            local zombie = ents.Create("nb_ba2_infected_citizen")
            zombie:SetPos(v.pos)
            zombie:SetAngles(v.ang)
            zombie:Spawn()
            zombie:Activate()
        end
    end

    for k, v in ipairs(zb.Points["SCRAPPERS_SMALLBOX"].Points or {}) do
        local random = math.random(1, 3)

        if random == 1 then
            local box = ents.Create("prop_physics")
            box:SetPos(v.pos)
            box:SetModel("models/props_junk/wood_crate001a.mdl")
            box:SetAngles(v.ang)
            box:Spawn()
        end
    end

    for k, v in ipairs(zb.Points["SCRAPPERS_VEHICLE"].Points or {}) do
        local random = math.random(1, 3)

        if random == 1 then
            local vehicle_class = self.Vehicles[math.random(#self.Vehicles)]

            simfphys.SpawnVehicleSimple( vehicle_class, v.pos, v.ang)
        end
    end

    for k, v in ipairs(zb.Points["SCRAPPERS_BIGVEHICLE"].Points or {}) do
        local random = math.random(1, 3)

        if random == 1 then
            local vehicle_class = self.BigVehicles[math.random(#self.BigVehicles)]

            simfphys.SpawnVehicleSimple( vehicle_class, v.pos, v.ang)
        end
    end

    for k, v in ipairs(zb.Points["SCRAPPERS_APCSPAWN"].Points or {}) do
        local random = math.random(1, 3)

        if random == 1 then
            simfphys.SpawnVehicleSimple( "sim_fphys_conscriptapc", v.pos, v.ang)
        end
    end

    SetNetVar("Scrappers_LobbyEnd", math.Round(CurTime()) + MODE.LobbyTime)

    net.Start("zb_Scrappers_SendShop")
        net.WriteTable(zb.ScrappersScrambledList)
    net.Broadcast()

    timer.Create("zb_Scrappers_LobbyEnd", MODE.LobbyTime, 1, function()
        net.Start("zb_RemoveShopMenu")
        net.Broadcast()

        self:LoadPlayers()
    end)
end

function MODE:RoundStart()
    for k, v in ipairs(player.GetAll()) do
        ApplyAppearance(v)
    end

    for k, v in pairs(zb.net.locals) do
        zb.net.locals[k]["zb_Scrappers_Inventory"] = nil
        zb.net.locals[k]["zb_Scrappers_RaidInventory"] = nil
        zb.net.locals[k]["zb_Scrappers_Money"] = nil
    end

    for _, v in pairs(player.GetAll()) do
        v:SetLocalVar("zb_Scrappers_Inventory", nil)
        v:SetLocalVar("zb_Scrappers_RaidInventory", nil)
        v:SetLocalVar("zb_Scrappers_Money", nil)
    end

    self:SubRoundStart()
end

function MODE:EndRound()
    timer.Remove("zb_Scrappers_LobbyEnd")
    timer.Remove("zb_Scrappers_ExtractionTime")
    timer.Remove("zb_Scrappers_ExtractionTimeAlarm")
end

function MODE:GiveEquipment()
end

function MODE:PlayerDeath(ply)
    ply:SetTeam(TEAM_SPECTATOR)
    ply:SetViewEntity(NULL)
    ply:SetLocalVar("zb_Scrappers_RaidInventory", nil)
    ply:SetLocalVar("zb_Scrappers_RaidMoney", nil)
end

function MODE:CanSpawn(ply)
    if ply:Team() == 0 then return true end

    return false
end

COMMANDS.skip = {function(ply,args)
    if timer.Exists("zb_Scrappers_ExtractionTime") then
        timer.Adjust("zb_Scrappers_ExtractionTime",0)
    else
        if timer.Exists("zb_Scrappers_LobbyEnd") then
            timer.Adjust("zb_Scrappers_LobbyEnd",1)
            SetNetVar("Scrappers_LobbyEnd", math.Round(CurTime()) + 1)
        end
    end
end,1}

function MODE:PlayerInitialSpawn(ply)
    ply:SetTeam(1001)
end