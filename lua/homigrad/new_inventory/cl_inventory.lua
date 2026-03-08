local clr_inv, clr_inv_selected = Color(20, 0, 0, 200), Color(90, 0, 0, 200)
local type = type
hook.Add("PlayerButtonDown", "NI_PlayerButtonDown", function(ply, key)
	if GetGlobalBool("RadialInventory", false) and key == KEY_1 and ply.organism and not ply.organism.otrub then
		local tbl1 = {}
		local weps = ply:GetWeapons()
		for i = 1, #weps do
			local wep = weps[i]
			--if wep == ply:GetActiveWeapon() then continue end

			local icon = type(wep.WepSelectIcon) == "IMaterial" and wep.WepSelectIcon or (type(wep.WepSelectIcon2) == "IMaterial" and wep.WepSelectIcon2)
			tbl1[#tbl1 + 1] = {
				function()
					net.Start("NI_SelectWeapon")
					net.WriteEntity(wep)
					net.SendToServer()
					if wep ~= ply:GetActiveWeapon() then
						surface.PlaySound("arc9_eft_shared/weapon_generic_spin"..math.random(10)..".ogg")
					end
				end, wep:GetPrintName(), nil, nil, icon, clr_inv, clr_inv_selected
			}
		end
		hg.CreateRadialMenu(tbl1, false)
	end
end)

hook.Add("PlayerButtonUp", "NI_PlayerButtonUp", function(ply, key)
	if GetGlobalBool("RadialInventory", false) and key == KEY_1 then
		hg.PressRadialMenu(1)
	end
end)