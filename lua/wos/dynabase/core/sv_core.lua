wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}

util.AddNetworkString("wOS.DynaBase.SendAllRegisters")
util.AddNetworkString("wOS.DynaBase.SendRegister")
util.AddNetworkString("wOS.DynaBase.ForceMountCallback")

hook.Add( "PlayerInitialSpawn", "wOS.DynaBase.NetworkRegisteredAnimations", function( ply )
    net.Start( "wOS.DynaBase.SendAllRegisters" )
        net.WriteUInt( wOS.DynaBase:GetSourceCount(), 32 )
        for name, _ in pairs( wOS.DynaBase:GetAllSources() ) do
            net.WriteString( name )
        end
    net.Send( ply )   
end )