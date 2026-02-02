-- Очистка карты, вывоз 200-х, мародерство оружия и лута :3
ZBox = ZBox or {}
ZBox.Plugins = ZBox.Plugins or {}
ZBox.Plugins["Cleaner"] = ZBox.Plugins["Cleaner"] or {}
local PLUGIN = ZBox.Plugins["Cleaner"]

PLUGIN.Name = "Cleaner"

PLUGIN.Hooks = {}
local Hook = PLUGIN.Hooks

local CLEANUP_INTERVAL = 1200 --; 10 мин проверка
local ENTITY_LIFETIME = 1200 --; 10 мин

local ragdollSpawnTimes = {}
local weaponSpawnTimes = {}

function Hook.OnEntityCreated(ent)
    if ent:GetClass() == "prop_ragdoll" then
        ragdollSpawnTimes[ent] = CurTime()
    elseif ent:IsWeapon() and not ent:IsPlayer() then
        weaponSpawnTimes[ent] = CurTime()
    end
end

function Hook.EntityRemoved(ent)
    if ragdollSpawnTimes[ent] then
        ragdollSpawnTimes[ent] = nil
    end
    if weaponSpawnTimes[ent] then
        weaponSpawnTimes[ent] = nil
    end
end

local function CleanupEntities()
    --// Ragdolls 
    --; (ТВОЙ ЕНТИТИ).organism.alive
    for ragdoll, spawnTime in pairs(ragdollSpawnTimes) do
        if not IsValid(ragdoll) then
            ragdollSpawnTimes[ragdoll] = nil
        elseif CurTime() - spawnTime >= ENTITY_LIFETIME then
            local org = ragdoll.organism 
            if org and org.isPly then
                ragdollSpawnTimes[ragdoll] = CurTime()
                continue
            end
            for _, ent in ipairs(ents.FindInSphere(ragdoll:GetPos(),1000)) do
                if ent:IsPlayer() and ent:Alive() then ragdollSpawnTimes[ragdoll] = CurTime() continue end
            end
            ragdoll:Remove()
            ragdollSpawnTimes[ragdoll] = nil
        end
    end
    --// Weapons
    for weapon, spawnTime in pairs(weaponSpawnTimes) do
        if not IsValid(weapon) then
            weaponSpawnTimes[weapon] = nil
        elseif CurTime() - spawnTime >= ENTITY_LIFETIME then
            if IsValid(weapon:GetOwner()) and (weapon:GetOwner():IsPlayer() or weapon:GetOwner():IsNPC()) then
                weaponSpawnTimes[weapon] = CurTime()
                continue 
            end
            for _, ent in ipairs(ents.FindInSphere(weapon:GetPos(),1000)) do
                if ent:IsPlayer() and ent:Alive() then 
                    weaponSpawnTimes[weapon] = CurTime() 
                    continue 
                end
            end
            weapon:Remove()
            weaponSpawnTimes[weapon] = nil
        end
    end
end

function Hook.ZBox_Start()
    timer.Create("CleanerTimer", CLEANUP_INTERVAL, 0, function()
        CleanupEntities()
    end)
end

function Hook.ZBox_Disable()
    timer.Remove("CleanerTimer")
end

