-- Спавны игроков, благо я научился это по нормальному делать :steamhappy:
--; Их сделал дека >:D
ZBox = ZBox or {}
ZBox.Plugins = ZBox.Plugins or {}
ZBox.Plugins["Spawnpoints"] = ZBox.Plugins["Spawnpoints"] or {}
local PLUGIN = ZBox.Plugins["Spawnpoints"]

PLUGIN.Name = "Spawnpoints"

PLUGIN.Hooks = {}
local Hook = PLUGIN.Hooks

local spawns = {
    ["rp_truenorth_v1a"] = {
        [1] = Vector(-2952, 14210, 200),
        [2] = Vector(-703, 11371, 185),
        [3] = Vector(12290, 13146, 109),
        [4] = Vector(12515, 6488, 317),
        [5] = Vector(15366, -8413, 77),
        [6] = Vector(14036, -5350, 205),
        [7] = Vector(13645, -6290, 333),
        [8] = Vector(15187, -2086, 45),
        [9] = Vector(-1533, -6899, 4432),
        [10] = Vector(-9355, -15436, 4152),
        [11] = Vector(11154, -15290, 111),
        [12] = Vector(-11579, 15667, -134),
        [13] = Vector( 3245.56, -1039.57, 0 ),
        [14] = Vector( 3338.06, 1613.28, 8.03 ),
        [15] = Vector( 1660.31, -4338.47, 32.03 ),
        [16] = Vector( -10242.25, 14891.46, 2563.43 )
    }
}
local map
local unavailableSpawns = {}


local function getMapBounds()
    local worldEntity = game.GetWorld()
    local minBound, maxBound = worldEntity:GetModelBounds()
    return minBound, maxBound
end

local minBound, maxBound = -Vector(5000,5000,5000), Vector(5000,5000,5000)

hook.Add("InitPostEntity", "niasas", function()
    minBound, maxBound = getMapBounds()
end)

local function isSpawnPointAvailable(index)
    return not unavailableSpawns[index] or unavailableSpawns[index] < CurTime()
end


local function disableSpawnPoint(index, duration)
    unavailableSpawns[index] = CurTime() + duration
end


local function isValidSpawnLocation(pos)

    local traceDown = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 500),
        mask = MASK_SOLID_BRUSHONLY
    })


    if not traceDown.Hit or traceDown.HitSky then
        return false
    end


    if bit.band(util.PointContents(traceDown.HitPos), CONTENTS_WATER) == CONTENTS_WATER then
        return false
    end

    
    local traceHull = util.TraceHull({
        start = pos,
        endpos = pos + Vector(0, 0, 1), 
        mins = Vector(-16, -16, 0), 
        maxs = Vector(16, 16, 72),
        mask = MASK_PLAYERSOLID
    })

    if traceHull.Hit then
        return false
    end

    return true
end


local function findRandomSpawnLocation()
    local maxAttempts = 100
    for _ = 1, maxAttempts do
        local pos = Vector(
            math.random(minBound.x, maxBound.x),
            math.random(minBound.y, maxBound.y),
            math.random(minBound.z, maxBound.z)
        )


        if isValidSpawnLocation(pos) then
            return pos
        end
    end
    return nil 
end


Hook["Player Spawn"]= function(ply)
    map = map or game.GetMap()
    local spawnPoints = spawns[map]
    local availableSpawnIndex = nil
    if not spawnPoints then return end


    for index, pos in pairs(spawnPoints) do
        if isSpawnPointAvailable(index) then
            availableSpawnIndex = index
            break
        end
    end

    if availableSpawnIndex then
        ply:SetPos(spawnPoints[availableSpawnIndex])
        disableSpawnPoint(availableSpawnIndex, 30) 
    else
        
        --local randomSpawn = findRandomSpawnLocation()
        --if randomSpawn then
        --    ply:SetPos(randomSpawn)
        --else
           
            ply:SetPos(spawnPoints[1])
        --end
    end

    ply:Give("weapon_spawnmenu_pda")
end

function Hook.PlayerSay(ply, text)
    if not ply:IsAdmin() then return end

   --local args = string.Split(text, " ")
   --if args[1] == "!sspawn" and args[2] then
   --    local targetName = args[2]
   --    local targetPlayer = nil

   --   
   --    for _, player in ipairs(player.GetAll()) do
   --        if string.find(string.lower(player:Nick()), string.lower(targetName)) then
   --            targetPlayer = player
   --            break
   --        end
   --    end

   --    if targetPlayer then
   --        
   --        local randomSpawn = findRandomSpawnLocation()
   --        if randomSpawn then
   --            targetPlayer:SetPos(randomSpawn)
   --            ply:ChatPrint("лох " .. targetPlayer:Nick() .. " заспавнен.")
   --        else
   --            ply:ChatPrint("не нашел.")
   --        end
   --    else
   --        ply:ChatPrint("лох \"" .. targetName .. "\" не найден")
   --    end

   --    return "" 
   --end
end

--NPCSPAWN

local npcSpawnPoints = {
    {pos = Vector(-5447.6118164063, -14284.108398438, 104.03125), ang = Angle(0, 136.78108215332, 0)},
    {pos = Vector(-5579.3837890625, -13829.672851563, 104.03125), ang = Angle(0, 56.208976745605, 0)},
    {pos = Vector(-5833.6083984375, -14099.512695313, 104.03125), ang = Angle(0, 39.422115325928, 0)},
    {pos = Vector(-5551.3881835938, -14595.715820313, 104.03125), ang = Angle(0, -122.04198455811, 0)}
}

local npcClass = "zbox_ex_russian_military"
local respawnTime = 540
local spawnedNPCs = {}

--ZBaseInternalSpawnNPC( ply, Position, Normal, Class, Equipment, SpawnFlagsSaved, NoDropToFloor, skipSpawnAndActivate )

local Weapons = {
    "weapon_asval",
    "weapon_akm",
    "weapon_saiga12",
    "weapon_svd",
    "weapon_sks",
    "weapon_ak74",
    "weapon_ak74u"
}

local function SpawnNPCs()
    for _, spawnInfo in pairs(npcSpawnPoints) do
        local npc = ZBaseInternalSpawnNPC( nil, spawnInfo.pos, -vector_up, npcClass, nil, false, true, false )
        if IsValid(npc) then
            npc:SetAngles(spawnInfo.ang)
            npc:Give(table.Random(Weapons))
            table.insert(spawnedNPCs, npc)
        end
    end
end


local function AreAllNPCsDead()
    return #spawnedNPCs == 0
end

local function RemoveNPCFromTable(npc)
    for index, storedNPC in pairs(spawnedNPCs) do
        if storedNPC == npc then
            table.remove(spawnedNPCs, index)
            break
        end
    end
end

local function CheckAndRespawnNPCs()
    if AreAllNPCsDead() then
        timer.Simple(respawnTime, function()
            if AreAllNPCsDead() then
                SpawnNPCs()
            end
        end)
    end
end

function Hook.OnNPCKilled(npc, attacker, inflictor)
    if npc:GetClass() == npcClass then
        RemoveNPCFromTable(npc)
        if AreAllNPCsDead() then
            CheckAndRespawnNPCs()
        end
    end
end

function Hook.ZBox_Start()
    --SpawnNPCs()
    --CheckAndRespawnNPCs()
end