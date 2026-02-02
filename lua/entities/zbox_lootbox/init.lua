AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetModel(self.Model) --| Стандартные функции спавна

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(75) --| ДАЙТЕ ЕМУ ВЕС
		phys:Wake()
		phys:EnableMotion(true)
	end

    self.Loot = {
        --[[ 
            [ ID ] = { 
                class = "ИМЯ КЛАССА",
                entData = {
                    DataETC = "ДАТА" --| Для контейнеров игроков, где можно хранить вещи.
                    --| Кстати с помощью этого можно делать уникальные ентити которые будут иметь свои приколы, хоть по суте один и тот-же класс
                }
            }, 
        --]]
    }
    self.ShowContainer = {
        --| Игроки которые открыли контейнер

    }
end

local loottypes = {
    [ "entity" ] = function( self, user, class, spawnFunctions, entData )
        if not IsValid( user ) or not user:IsPlayer() then return false end --| Проверяем валидность игрока.
        --| После проверки создаем ентити.
        local ent = ents.Create( class )
        --| Не забываем выдать свойство заспавнености. Выключает возможность автоподбора.
        ent.IsSpawned = true
        --| Ищим позицую для спавна нашего ентити.
        local spawnPos = util.TraceEntityHull( {
            start = self:GetPos() + ( vector_up * 5 ),
            endpos = user:GetPos() + ( vector_up * 15 ),
            filter = { self },
            mask = MASK_SHOT
        }, ent ).HitPos
        ent:SetPos( spawnPos ) --| Ставим позицию.
        ent:Spawn() --| И спавним.

        --| Если была какая либо записанная дата, даем ее ентити.
        if entData then
            for k,data in pairs( entData ) do
                ent[ k ] = data
            end
        end
        --| Производим спавнфункции, если они есть.
        if spawnFunctions then
            for _, func in ipairs( spawnFunctions ) do
                func( ent )
            end
        end

        return ent --| Возврат ентити.
    end,
}

ZBox = ZBox or {}
ZBox.LootSystem = ZBox.LootSystem or {}

function ENT:TakeItem( ply, itemID ) --| Хватай бесплатно
    local item = self.Loot[itemID]
    local spawnFunctions = ZBox.LootSystem.spawnFunctions or {}
    if item then
        loottypes[ "entity" ]( self, ply, item.class, spawnFunctions[ item.class ], item.entData )
        self.Loot[itemID] = nil
        item = nil
    end
end

function ENT:Use( activator ) --| Передача данных о крейте только в момент открытия. Чтобы не СРАЛО
    if !IsValid( activator ) or !activator:IsPlayer() then return false end --| Проверяем валидность игрока...
    if ( activator:GetPos() - self:GetPos() ):Length() > 400 then 
        print( "[ ZBox | LootSystem ]: ".. activator .. "[SteamID:".. activator:SteamID() .. "]" .." trying USE CONTAINER but, he not in radius CHEATS?" ) 
        return false 
    end

    self:OpenContainer( activator )
end

util.AddNetworkString( "ZBox_LootSystem_net" )

function ZBox.LootSystem.SendLootTable( ent, ply, tbl ) --| Отправка крутых нетов.

    net.Start( "ZBox_LootSystem_net" )
        net.WriteEntity( ent )
        net.WriteString( util.TableToJSON( tbl ) ) --| Зачем тратить лишние ресурсы на таблицу, давайте ее просто переведем в стринг лол.
    net.Send( ply )--ресурсы одна "с" дебил

    return true
end

net.Receive( "ZBox_LootSystem_net", function( len, ply ) 
    local Container = net.ReadEntity()
    Container.TakeCD = Container.TakeCD or 0
    if Container.TakeCD > CurTime() then 
        print( "[ ZBox | LootSystem ]: ".. ply .. "[SteamID:".. ply:SteamID() .. "]" .." trying TAKE ITEM but, cooldown is on." ) 
        return false 
    end

    Container.TakeCD = CurTime() + 0.1

    if ( ply:GetPos() - Container:GetPos() ):Length() > 400 then 
        print( "[ ZBox | LootSystem ]: ".. ply .. "[SteamID:".. ply:SteamID() .. "]" .." trying TAKE ITEM but, he not in radius CHEATS?!" ) 
        return false 
    end

    local ItemID = net.ReadUInt(10)

    if not Container.Loot[ItemID] then 
        print( "[ ZBox | LootSystem ]: ".. ply .. "[SteamID:".. ply:SteamID() .. "]" .." trying TAKE ITEM but, item is invalid." ) 
        return false 
    end

    Container:TakeItem( ply, ItemID ) 
end)

local SendLootTable = ZBox.LootSystem.SendLootTable

function ENT:OpenContainer( ply ) --| Открываем контейнер игроку.
    local OptimizedTable = {} --| Создаем пустую таблицу для отправки клиенту.
    for k, data in pairs( self.Loot ) do --| Запись в таблицу.
        OptimizedTable[ k ] = { class = data.class }
    end
    self:EmitSound("items/ammocrate_open.wav")
    SendLootTable( self, ply, OptimizedTable ) --| Отправка клиенту.
    self.ShowContainer[ ply:EntIndex() ] = ply
end


function ENT:GenerateLoot()
    if not self.CanGenerate then return end
    local count = 0
    local ammout = math.random( 1, self.LootCountMul or 3)
    for i = 1, ammout do
        if #self.Loot > 6 then return end
        local item = table.Random(self.LootTable)
		
		if(istable(item))then
			_, item = hg.WeightedRandomSelect(tab, mul)
		end
		
        if count >= ammout then return end
        count = count + 1
        self.Loot[#self.Loot + 1] = { class = item.class }
    end
    self.LastLootGenerate = CurTime()
end

function ENT:Think()
    self.LastLootGenerate = self.LastLootGenerate or 0

    if self.LastLootGenerate + 1200 < CurTime() then
        self:GenerateLoot()
    end

    self:NextThink( CurTime() + 60 )
    return true
end