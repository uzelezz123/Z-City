local function IsAdmin(ply)
    return ply:IsAdmin() or ply:IsSuperAdmin()
end

util.AddNetworkString("defense_admin_command")

net.Receive("defense_admin_command", function(len, ply)
    if not IsAdmin(ply) then return end

    local command = net.ReadString()
    local args = net.ReadTable()

    if command == "start_wave" then
        local wave = tonumber(args[1])
        if wave and wave > 0 then
            MODE:StartWave(wave)
        end
    elseif command == "end_wave" then
        MODE:EndWave()
    elseif command == "set_wave" then
        local wave = tonumber(args[1])
        if wave and wave > 0 then
            MODE.Wave = wave
        end
    elseif command == "add_points" then
        local points = tonumber(args[1])
        if points and points > 0 then
            MODE:AddCommanderPoints(points)
        end
    end
end)