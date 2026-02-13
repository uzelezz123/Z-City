local MODE = MODE

--\\Neck Break
net.Receive("HMCD_BeingVictimOfNeckBreak", function(len, ply)
	LocalPlayer().BeingVictimOfNeckBreak = net.ReadBool()
	
	if(LocalPlayer().BeingVictimOfNeckBreak)then
		BeingVictimOfNeckBreakResetTime = CurTime() + 5
	else
		BeingVictimOfNeckBreakResetTime = nil
	end
end)

net.Receive("HMCD_BreakingOtherNeck", function(len, ply)
	local status = net.ReadBool()
	local attacker_ply = net.ReadEntity()
	
	if(status)then
		local other_ply = net.ReadEntity()
		
		if(IsValid(attacker_ply))then
			MODE.StartBreakingOtherNeck(LocalPlayer(), other_ply)
		end
	else
		if(IsValid(attacker_ply))then
			MODE.StopBreakingOtherNeck(LocalPlayer())
		end
	end
end)
--//

--\\
net.Receive("HMCD_BeingVictimOfDisarmament", function(len, ply)
	LocalPlayer().BeingVictimOfDisarmament = net.ReadBool()
	
	if(LocalPlayer().BeingVictimOfDisarmament)then
		BeingVictimOfDisarmamentResetTime = CurTime() + 5
	else
		BeingVictimOfDisarmamentResetTime = nil
	end
end)

net.Receive("HMCD_DisarmingOther", function(len, ply)
	local status = net.ReadBool()
	
	if(status)then
		local other_ply = net.ReadEntity()
		
		MODE.StartDisarmingOther(LocalPlayer(), other_ply)
	else
		MODE.StopDisarmingOther(LocalPlayer())
	end
end)
--//

--\\Chemical resistance
net.Receive("HMCD_UpdateChemicalResistance", function(len, ply)
	local chemical_name = net.ReadString()
	
	if(chemical_name == "")then
		LocalPlayer().PassiveAbility_ChemicalAccumulation = {}
		LocalPlayer().PassiveAbility_VGUI_ChemicalAccumulation = {}
	end
	
	while chemical_name != "" do
		local amt = net.ReadUInt(MODE.NetSize_ChemicalResistanceBits)
		
		MODE.SetChemicalToPlayer(LocalPlayer(), chemical_name, amt)
		
		chemical_name = net.ReadString()
	end
end)
--//

hook.Add("Think", "HMCD_SubRole_Abilities", function()
	if(BeingVictimOfNeckBreakResetTime and BeingVictimOfNeckBreakResetTime <= CurTime())then
		BeingVictimOfNeckBreakResetTime = nil
		LocalPlayer().BeingVictimOfNeckBreak = false
	end
	
	if(LocalPlayer().Ability_NeckBreak)then
		MODE.ContinueBreakingOtherNeck(LocalPlayer())
	end
	
	if(BeingVictimOfDisarmamentResetTime and BeingVictimOfDisarmamentResetTime <= CurTime())then
		BeingVictimOfDisarmamentResetTime = nil
		LocalPlayer().BeingVictimOfDisarmament = false
	end
	
	if(LocalPlayer().Ability_Disarm)then
		MODE.ContinueDisarmingOther(LocalPlayer())
	end
end)
--[[
hook.Add("InputMouseApply", "HMCD_SubRole_Abilities", function(cmd, mouse_x, mouse_y, ang)
	-- if(LocalPlayer().BeingVictimOfNeckBreak)then
		local mouse_speed = 1.1
		local eye_angles = LocalPlayer():EyeAngles()
		
		-- cmd:SetMouseX(math.Clamp(mouse_x, -mouse_speed, mouse_speed))
		-- cmd:SetMouseY(math.Clamp(mouse_y, -mouse_speed, mouse_speed))
		cmd:SetViewAngles(eye_angles)
		
		-- return true
	-- end
end)
]]
hook.Add("hg_AdjustMouseSensitivity", "HMCD_SubRole_Abilities", function(sensitivity)
	if(LocalPlayer().BeingVictimOfNeckBreak)then
		return 0.1
	end
end)

hook.Add("PrePlayerDraw", "HMCD_SubRoles_Abilities", function(ply, flags)
	-- if(ply.Ability_NeckBreak)then
		-- local ability = ply.Ability_NeckBreak
		-- local victim = ability.Victim
		
		-- if(IsValid(victim))then
			-- local ragdoll = victim.FakeRagdoll or victim:GetNWEntity("RagdollDeath", victim.FakeRagdoll)
			
			-- print(ply, ragdoll)
			
			-- if(IsValid(ragdoll))then
				
			-- else
				-- ragdoll = victim
			-- end
			
			-- local bone_id = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
			
			-- if(bone_id)then
				-- local bone_matrix = ragdoll:GetBoneMatrix(bone_id)
				
				-- if(bone_matrix)then
					-- local pos, ang = bone_matrix:GetTranslation(), bone_matrix:GetAngles()
					
					-- hg.DragHandsToPos(ply, ply:GetActiveWeapon(), pos, true, 3.5, ang:Up(), Angle(90,-15,180), Angle(90,15,0))
				-- end
			-- end
		-- end
		
		-- if(!ability.TimeToExpire)then
			-- ability.TimeToExpire = CurTime() + 5
		-- elseif(ability.TimeToExpire <= CurTime())then
			-- ply.Ability_NeckBreak = nil
		-- end
	-- end
end)