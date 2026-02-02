--\\Перевод плагиновых штук в ваши штуки
hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties
--//

--\\
PLUGIN.ConjureTA = PLUGIN.ConjureTA or {}
PLUGIN.ConjureTA.ToConjure = PLUGIN.ConjureTA.ToConjure or {}
--//

--\\
function PLUGIN.ConjureTA.Do(ent, time)
	PLUGIN.ConjureTA.ToConjure[ent] = {
		Time = CurTime() + time,
	}
end

local function TryConjureTA(zone, ply)
	local equalizers_consumption = 5
	local blood_consumption = 250
	
	if(PLUGIN.GetZoneOrPlyEqualizers(zone, ply) >= equalizers_consumption and PLUGIN.GetZoneOrPlyBlood(zone, ply) >= blood_consumption)then
		local ent = PLUGIN.FindEntInZone(zone, ply, function(ent)
			return !PLUGIN.ConjureTA.ToConjure[ent] and ent.ismelee and !ent.ThaumaturgicArm and !IsValid(ent:GetOwner())
		end)
		
		if(ent)then
			PLUGIN.ShowMessageInSphere("Conjuring Thaumaturgic Arm...", zone.Pos, zone.Radius)
			PLUGIN.ConjureTA.Do(ent, 5)
			PLUGIN.RemoveZoneOrPlyEqualizers(zone, ply, equalizers_consumption)
			PLUGIN.RemoveZoneOrPlyBlood(zone, ply, blood_consumption)
			PLUGIN.AddConsequencesToZoneChanters(zone, -1)
			PLUGIN.AddConsequences(ply, -10)
		else
			PLUGIN.ShowMessage(ply, "There are no melee weapon sacrifices within the zone")
		end
	else
		PLUGIN.ShowMessage(ply, "There is not enough equalizers or blood in order to conjure thaumaturgic arm")
	end
end
--//

--\\SpecialEvents
hook.Add("Abnormalties_HotZoneAbnormaltyAdded", "Abnormalties_ConjureTA", function(zone_id, abnormalty_name, amt, ply)
	local zone = PLUGIN.Zones[zone_id]
	
	if(PLUGIN.GetZoneAbnormalty(zone, "ritual") >= 20 and PLUGIN.GetZoneAbnormalty(zone, "harm") >= 10 and PLUGIN.GetZoneAbnormalty(zone, "sacrifice") >= 10 and amt > 0)then
		local clear_cd = 10
		
		if(!zone.Vars.RitualPhrasesAmtClearTime)then
			zone.Vars.RitualPhrasesAmtClearTime = CurTime() + clear_cd
		end
		
		if(zone.Vars.RitualPhrasesAmtClearTime <= CurTime())then
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
		
		if(PLUGIN.CompareZonePhrasesToPattern(zone, {{"ritual", 2}, {"sacrifice", 2}}, 5))then
			TryConjureTA(zone, ply)
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
	end
end)
--//

hook.Add("Think", "Abnormalties_ConjureTA", function()
	for ent, info in pairs(PLUGIN.ConjureTA.ToConjure) do
		if(info.Time <= CurTime())then
			if(IsValid(ent))then
				local new_ent = ents.Create("weapon_thaumaturgic_arm")
				
				new_ent:SetPos(ent:GetPos())
				new_ent:Spawn()
				new_ent:Activate()
				ent:Remove()
			end
			
			PLUGIN.ConjureTA.ToConjure[ent] = nil
		end
	end
end)

hook.Add("PostCleanupMap", "Abnormalties_ConjureTA", function()
	PLUGIN.ConjureTA.ToConjure = {}
end)