if SERVER then
    util.AddNetworkString("ZB_GiveRole")

    function zb.GiveRole(ply, name, color)
        hook.Run( "ZB_GettingRole", ply, name )
        net.Start("ZB_GiveRole")
            net.WriteTable({
                name = name or "WHO ARE YOU?",
                color = color or color_white
            })
        net.Send(ply)
    end
else
    net.Receive("ZB_GiveRole",function()
        LocalPlayer().role = net.ReadTable() or false
    end)    
end