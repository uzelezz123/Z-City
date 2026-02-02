--\\Перевод плагиновых штук в ваши штуки
hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties
--//

--\\
PLUGIN.ConjureBleedingMusket = PLUGIN.ConjureBleedingMusket or {}
PLUGIN.ConjureBleedingMusket.ToConjure = PLUGIN.ConjureBleedingMusket.ToConjure or {}
--//

--\\
function PLUGIN.ConjureBleedingMusket.Do(ent, time, zone)
	PLUGIN.ConjureBleedingMusket.ToConjure[#PLUGIN.ConjureBleedingMusket.ToConjure + 1] = {
		Time = CurTime() + time,
		Zone = zone,
	}
end

local function TryConjureBleedingMusket(zone, ply)
	local blood_consumption = 25000
	
	if(PLUGIN.GetZoneOrPlyBlood(zone, ply) >= blood_consumption)then
		PLUGIN.ShowMessageInSphere("Conjuring Bleeding Musket...", zone.Pos, zone.Radius)
		PLUGIN.ConjureBleedingMusket.Do(ent, 5, zone)
		PLUGIN.RemoveZoneOrPlyBlood(zone, ply, blood_consumption)
		PLUGIN.AddConsequencesToZoneChanters(zone, -3)
		PLUGIN.AddConsequences(ply, -50)
	else
		PLUGIN.ShowMessage(ply, "There is not enough blood in order to conjure Bleeding Musket")
	end
end
--//

--\\SpecialEvents
hook.Add("Abnormalties_HotZoneAbnormaltyAdded", "Abnormalties_ConjureBleedingMusket", function(zone_id, abnormalty_name, amt, ply)
	local zone = PLUGIN.Zones[zone_id]
	
	if(PLUGIN.GetZoneAbnormalty(zone, "harm") >= 20 and PLUGIN.GetZoneAbnormalty(zone, "ritual") >= 10 and PLUGIN.GetZoneAbnormalty(zone, "sacrifice") >= 10 and amt > 0)then
		local clear_cd = 10
		
		if(!zone.Vars.RitualPhrasesAmtClearTime)then
			zone.Vars.RitualPhrasesAmtClearTime = CurTime() + clear_cd
		end
		
		if(zone.Vars.RitualPhrasesAmtClearTime <= CurTime())then
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
		
		if(PLUGIN.CompareZonePhrasesToPattern(zone, {{"harm", 5}, {"ritual", 2}, {"sacrifice", 2}}, 5))then
			TryConjureBleedingMusket(zone, ply)
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
	end
end)
--//

hook.Add("Think", "Abnormalties_ConjureBleedingMusket", function()
	for id, info in pairs(PLUGIN.ConjureBleedingMusket.ToConjure) do
		if(info.Time <= CurTime())then
			if(info.Zone)then
				local new_ent = ents.Create("weapon_bleeding_musket")
				
				new_ent:SetPos(info.Zone.Pos + Vector(0, 0, 30))
				new_ent:Spawn()
				new_ent:Activate()
			end
			
			PLUGIN.ConjureBleedingMusket.ToConjure[id] = nil
		end
	end
end)

hook.Add("PostCleanupMap", "Abnormalties_ConjureBleedingMusket", function()
	PLUGIN.ConjureBleedingMusket.ToConjure = {}
end)