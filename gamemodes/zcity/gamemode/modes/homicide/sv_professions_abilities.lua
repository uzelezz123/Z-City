local MODE = MODE
MODE.SendFootStepEvery = 3
-- MODE.SendFootStepEvery = 1

util.AddNetworkString("HMCD_Professions_Abilities_AddFootstep")
util.AddNetworkString("HMCD_Professions_Abilities_DisplayOrganismInfo")

function MODE.DisplayOrganismInfo(organism, ply)
	local text_info = ""
	text_info = text_info .. " Saturation" .. organism.o2 .. "\n"
	
	net.Start("HMCD_Professions_Abilities_DisplayOrganismInfo")
		net.WriteString(text_info)
	net.Send(ply)
end

--\\
hook.Add("HG_PlayerFootstep_Notify", "HMCD_Professions_Abilities", function(ply, pos, foot, snd, volume, filter)
	ply.ProfessionAbility_FootstepsAmt = ply.ProfessionAbility_FootstepsAmt or 0
	ply.ProfessionAbility_FootstepsAmt = ply.ProfessionAbility_FootstepsAmt + 1
	
	if(ply.ProfessionAbility_FootstepsAmt >= MODE.SendFootStepEvery)then
		ply.ProfessionAbility_FootstepsAmt = 0
		
		net.Start("HMCD_Professions_Abilities_AddFootstep")
			net.WriteVector(pos)
			net.WriteFloat(ply:EyeAngles().y)
			net.WriteBool(foot == 0)
			
			local character_color = ply:GetNWVector("PlayerColor")
			
			if(!IsColor(character_color))then
				character_color = Color(character_color[1] * 255, character_color[2] * 255, character_color[3] * 255)
			end
			
			net.WriteColor(character_color, false)
			
			local recepients = {}
			
			for _, recepient_ply in player.Iterator() do
				if(recepient_ply.Profession == "huntsman" and recepient_ply != ply)then
					recepients[#recepients+1] = recepient_ply
				end
			end
		net.Send(recepients)
	end
end)

hook.Add("PlayerPostThink", "HMCD_Professions_Abilities", function(ply)
	if(MODE.RoleChooseRoundTypes[MODE.Type])then
		if(ply:Alive())then
			if(ply.Profession == "doctor")then
				if(ply:KeyDown(IN_SPEED))then
					if(ply:KeyPressed(IN_USE))then
						local aim_ent, other_ply = MODE.GetPlayerTraceToOther(ply)
						
						if(IsValid(aim_ent))then
							if(other_ply)then
								MODE.DisplayOrganismInfo(other_ply.organism, ply)
							end
						end
					end
				end
			end
			
			if(ply.Profession == "huntsman")then
				
			end
		end
	end
end)

concommand.Add("hg_create_pipebomb", function(ply)
	if ply:Alive() and not ply.organism.otrub and ply.Profession == "engineer" then
		local have_ammo
		local have_nails

		for id, amt in pairs(ply:GetAmmo()) do
			local name = game.GetAmmoName(id)

			if name == "Nails" and amt >= 3 then
				have_nails = true
				continue
			end

			local tbl = hg.ammotypeshuy[name]
			if tbl.BulletSettings and tbl.BulletSettings.Mass * amt > 50 then
				have_ammo = {name, amt}
			end
		end

		local have_pipe = ply:HasWeapon("weapon_leadpipe")
		if have_ammo and have_pipe and have_nails then
			ply:SetAmmo(ply:GetAmmoCount("Nails") - 3, "Nails")
			ply:SetAmmo(math.Round((hg.ammotypeshuy[have_ammo[1]].BulletSettings.Mass * have_ammo[2] - 50) / hg.ammotypeshuy[have_ammo[1]].BulletSettings.Mass), have_ammo[1])
			ply:StripWeapon("weapon_leadpipe")

			ply:Give("weapon_hg_pipebomb_tpik")--crafted!
		end
    end
end)

concommand.Add("hg_create_molotov", function(ply)
	if ply:Alive() and not ply.organism.otrub and ply.Profession == "engineer" then
		local have_barrel_nearby
		local have_bandage = ply:HasWeapon("weapon_bandage_sh") or ply:HasWeapon("weapon_bigbandage_sh")
		local have_bottle = ply:HasWeapon("weapon_hg_bottle")

		for i, ent in ipairs(ents.FindInSphere(ply:GetPos(), 64)) do
			if hg.gas_models[ent:GetModel()] and !ent:GetNWBool("EmptyBarrel", false) then
				have_barrel_nearby = true
				break
			end
		end

		if have_barrel_nearby and have_bandage and have_bottle then
			if ply:HasWeapon("weapon_bandage_sh") then
				ply:StripWeapon("weapon_bandage_sh")
			else
				ply:StripWeapon("weapon_bigbandage_sh")
			end
			
			ply:StripWeapon("weapon_hg_bottle")

			ply:Give("weapon_hg_molotov_tpik")
		end
    end
end)
--//