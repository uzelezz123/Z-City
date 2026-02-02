-- Машинки, споты для спавна. 1 машинка респавнится раз в 30 минут, если прошлая была уничтожена.
ZBox = ZBox or {}

ZBox.Plugins = ZBox.Plugins or {}
ZBox.Plugins["Cars"] = ZBox.Plugins["Cars"] or {}
local PLUGIN = ZBox.Plugins["Cars"]

PLUGIN.Name = "Cars"

PLUGIN.Hooks = {}
local Hook = PLUGIN.Hooks

local spots = {
    ["rp_truenorth_v1a"] = {
        {"Carshop", Vector(5869, 11571, 64), Angle(0, 20, 0)}, --; Автосалон
        {"UnderPark 1.1", Vector(11710, 2607, -191), Angle(0, 180, 0)}, --; Подземная парковка 1 spot 1
        {"UnderPark 1.2", Vector(10993, 2239, -191), Angle(0, 0, 0)}, --; Подземная парковка 1 spot 2
        {"TNF Station", Vector(14979.943359, 10537.410156, 64.03125), Angle(9.951991, -90.711845, -0.000001)}, --; Заправка TNF в Городе
        {"Factory Zone", Vector(12546.645508, -1931.185913, 64.031250), Angle(10.179018, 179.087418, -0.000001)}, --; Заводская Зона
        {"Near City", Vector(3396.042236, 10945.347656, 192.031250), Angle(21.909510, 91.318527, -0.000001)}, --; Киношка возле города
        {"City", Vector(8394, 4103, 64), Angle(0, 15, 0)} --; Центр города
    }
}

local cars = {
    "sim_fphys_l4d_suv_2001", "sim_fphys_l4d_nuke_car", "sim_fphys_l4d_van", "sim_fphys_l4d_pickup_4x4",
    "sim_fphys_l4d_pickup_2004", "sim_fphys_l4d_95sedan", "sim_fphys_l4d_pickup_b_78", "sim_fphys_l4d_82hatchback",
    "sim_fphys_l4d_crownvic", "sim_fphys_l4d_police_city2", "sim_fphys_l4d_taxi_rural"
}
PLUGIN.Cars = PLUGIN.Cars or {}

function Hook.ZBox_Start()
    print("Cars: ZBox_Start called")
    timer.Create("CarSpawn", 150, 0, function()
        print("Cars: CarSpawn timer executed")
        
        local mapSpots = spots[game.GetMap()]
        if not mapSpots then
            print("Cars: No spots found for this map")
            return
        end

        local spot = table.Random(mapSpots)
        print("Cars: Selected spot:", spot[1])

        if PLUGIN.Cars[spot[1]] and IsValid(PLUGIN.Cars[spot[1]]) then
            print("Cars: Spot already occupied by a valid car")
            return
        end

        local traceHull = util.TraceHull({
            start = spot[2] + vector_up * 15,
            endpos = spot[2] + vector_up * 15,
            mins = Vector(-50, -50, 0),
            maxs = Vector(50, 50, 100),
            mask = MASK_SOLID
        })

        if traceHull.Hit then
            print("Cars: TraceHull hit something, can't spawn car")
            return
        end

        local carClass = table.Random(cars)
        print("Cars: Selected car class:", carClass)
        
        local ent = simfphys.SpawnVehicleSimple(carClass, spot[2] + vector_up * 15, spot[3])
        
        if IsValid(ent) then
            PLUGIN.Cars[spot[1]] = ent
            ent.ForceTransmission = 2
            local pos = ent:GetPos()
            print(string.format("Cars: Car '%s' spawned at position: X: %.2f, Y: %.2f, Z: %.2f", carClass, pos.x, pos.y, pos.z))
        else
            print("Cars: Failed to spawn car: " .. carClass)
        end
    end)
end

function Hook.ZBox_Disable()
    print("Spawnpoints: ZBox_Disable called")
    timer.Remove("CarSpawn")
end
