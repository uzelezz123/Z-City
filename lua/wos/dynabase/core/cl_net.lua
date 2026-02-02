wOS = wOS or {}
wOS.DynaBase = wOS.DynaBase or {}

net.Receive( "wOS.DynaBase.SendAllRegisters", function()
	wOS.DynaBase.EnforceCount = net.ReadUInt( 32 )
	for i=1, wOS.DynaBase.EnforceCount do
		local name = net.ReadString()
		local tbl = wOS.DynaBase:GetSource( name )
		if not tbl then wOS.DynaBase:RegisterSource({Name = name, ServerValid = true}) return end
		tbl.ServerValid = true
	end
end )

net.Receive( "wOS.DynaBase.SendRegister", function()
	local name = net.ReadString()
	local tbl = wOS.DynaBase:GetSource( name )
	if not tbl then wOS.DynaBase:RegisterSource({Name = name, ServerValid = true}) return end
	tbl.ServerValid = true
	wOS.DynaBase.EnforceCount = wOS.DynaBase.EnforceCount + 1
end )

net.Receive( "wOS.DynaBase.ForceMountCallback", function()
	local tbl = cvars.GetConVarCallbacks( "wos_dynabase_mountorder" ) or {}

	local oldval = net.ReadString()
	local newval = net.ReadString()

	for _, func in ipairs( tbl ) do
		func( "wos_dynabase_mountorder", oldval, newval )
	end
end )