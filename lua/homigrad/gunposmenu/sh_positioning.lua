local originx = GetConVar("hg_gunorigin_x") or CreateClientConVar("hg_gunorigin_x", "0", true, true, "-4 - 4, gun origin x", -4, 4)
local originy = GetConVar("hg_gunorigin_y") or CreateClientConVar("hg_gunorigin_y", "0", true, true, "-4 - 4, gun origin y", -4, 4)
local originz = GetConVar("hg_gunorigin_z") or CreateClientConVar("hg_gunorigin_z", "0", true, true, "-4 - 4, gun origin z", -4, 4)

if CLIENT then
    hg.GunPositions = hg.GunPositions or {}
    hg.GunPositions[LocalPlayer()] = hg.GunPositions[LocalPlayer()] or {}

    cvars.AddChangeCallback("hg_gunorigin_x", function(convar_name, value_old, value_new)
        hg.GunPositions[LocalPlayer()][1] = value_new
    end,"cback1")
    cvars.AddChangeCallback("hg_gunorigin_y", function(convar_name, value_old, value_new)
        hg.GunPositions[LocalPlayer()][2] = value_new
    end,"cback2")
    cvars.AddChangeCallback("hg_gunorigin_z", function(convar_name, value_old, value_new)
        hg.GunPositions[LocalPlayer()][3] = value_new
    end,"cback3")
end

if SERVER then
    local time = 0
    hg.GunPositions = hg.GunPositions or {}

    local HasSeenGunPos = HasSeenGunPos or {}

    util.AddNetworkString("send_positioning")
    hook.Add("Think","gunposchange",function()
        if time > CurTime() then return end
        time = CurTime() + 1
        local NetworkingTable = {}

        for i, ply in player.Iterator() do
            local v1 = math.Clamp(ply:GetInfoNum("hg_gunorigin_x",0),-4,4)
            local v2 = math.Clamp(ply:GetInfoNum("hg_gunorigin_y",0),-4,4)
            local v3 = math.Clamp(ply:GetInfoNum("hg_gunorigin_z",0),-4,4)
            local changedtable = hg.GunPositions[ply].ChangedTable or {}
            local gunpostable = {v1,v2,v3,ChangedTable = changedtable}
            hg.GunPositions[ply] = gunpostable
            
            local val1 = hg.IsChanged(v1,1,hg.GunPositions[ply])
            local val2 = hg.IsChanged(v2,2,hg.GunPositions[ply])
            local val3 = hg.IsChanged(v3,3,hg.GunPositions[ply])
            
            if val1 or val2 or val3 then
                NetworkingTable[ply] = hg.GunPositions[ply]
            end
        end

        net.Start("send_positioning",true)
            net.WriteTable(NetworkingTable)
        net.Broadcast()
    end)

    hook.Add("PlayerInitialSpawn", "SendGunPos", function(ply)
        hg.GunPositions[ply] = {ply:GetInfoNum("hg_gunorigin_x",0),ply:GetInfoNum("hg_gunorigin_y",0),ply:GetInfoNum("hg_gunorigin_z",0)}
        timer.Simple(1, function()
            net.Start("send_positioning")
                net.WriteTable(hg.GunPositions)
            net.Send(ply)
        end)
    end)
else
    net.Receive("send_positioning",function()
        local net_tbl = net.ReadTable()
        hg.GunPositions = table.Merge(hg.GunPositions,net_tbl)
    end)
end