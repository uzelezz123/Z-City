util.AddNetworkString("NI_SelectWeapon")

net.Receive("NI_SelectWeapon", function(len, ply)
	if not GetGlobalBool("RadialInventory", false) then return end

	local wep = net.ReadEntity()
	if IsValid(wep) and ply:HasWeapon(wep:GetClass()) and wep:GetOwner() == ply and ply:GetActiveWeapon() ~= wep:GetClass() then
		ply:SelectWeapon(wep)
	end
end)

local enableNewInv = CreateConVar("hg_radialinventory", 0, FCVAR_SERVER_CAN_EXECUTE, "Toggle radial (NMRIH-like) inventory", 0, 1)
cvars.AddChangeCallback("hg_radialinventory", function(convar_name, value_old, value_new)
	SetGlobalBool("RadialInventory", enableNewInv:GetBool())
end)