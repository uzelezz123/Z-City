--\\Перевод плагиновых штук в ваши штуки
hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties
--//

--\\
PLUGIN.Broadcast = PLUGIN.Broadcast or {}
--//

--\\
function PLUGIN.Broadcast.Do(ply)
	local addon_invisibility = PLUGIN.Invisibility
	
	if(addon_invisibility)then
		for _, other_ply in player.Iterator() do
			if(other_ply != ply and other_ply.Abnormalties_Invisible)then
				other_ply.Abnormalties_InvisibleVisors[ply] = true
				
				addon_invisibility.UpdateInvisiblity(other_ply)
				PLUGIN.ShowMessage(ply, "Made contact with invisible " .. other_ply:GetNWString("PlayerName"))
			end
		end
	end
	
	if(ply.Abnormalties_Invisible)then
		PLUGIN.Invisibility.SetInvisible(ply, false)
		PLUGIN.ShowMessage(ply, "Your invisibility fades")
	end
	
	ply.Abnormalties_BroadcastNextFadeTime = CurTime() + 10
end

local function TryBroadcast(zone, ply)
	local consumption = 15
	
	if(PLUGIN.GetZoneOrPlyEqualizers(zone, ply) >= consumption)then
		local owner = PLUGIN.FindPlyInZone(zone, ply, 2, function(ent)
			return !ply.Abnormalties_BroadcastNextFadeTime
		end)
		
		if(owner)then
			PLUGIN.ShowMessageInSphere("Broadcasting cogito of " .. owner:GetNWString("PlayerName") .. " for 10 seconds...", zone.Pos, zone.Radius)
			PLUGIN.Broadcast.Do(owner)
			PLUGIN.RemoveZoneOrPlyEqualizers(zone, ply, consumption)
			PLUGIN.AddConsequencesToZoneChanters(zone, 1)
			PLUGIN.AddConsequences(ply, 10)
		else
			PLUGIN.ShowMessage(ply, "There are no players within the zone")
		end
	else
		PLUGIN.ShowMessage(ply, "There is not enough equalizers in order to cogito broadcast")
	end
end
--//

--\\SpecialEvents
hook.Add("Abnormalties_HotZoneAbnormaltyAdded", "Abnormalties_Broadcast", function(zone_id, abnormalty_name, amt, ply)
	local zone = PLUGIN.Zones[zone_id]
	
	if(PLUGIN.GetZoneAbnormalty(zone, "help") >= 20 and PLUGIN.GetZoneAbnormalty(zone, "ritual") >= 10 and amt > 0)then
		local clear_cd = 10
		
		if(!zone.Vars.RitualPhrasesAmtClearTime)then
			zone.Vars.RitualPhrasesAmtClearTime = CurTime() + clear_cd
		end
		
		if(zone.Vars.RitualPhrasesAmtClearTime <= CurTime())then
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
		
		if(PLUGIN.CompareZonePhrasesToPattern(zone, {{"help", 5}}, 5))then
			TryBroadcast(zone, ply)
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
	end
end)
--//

hook.Add("CanListenOthers", "Abnormalties_Broadcast", function(output, input, is_chat, teamonly, text)
	if(output.Abnormalties_BroadcastNextFadeTime)then
		if(output.Abnormalties_BroadcastNextFadeTime > CurTime())then
			return true, false
		else
			output.Abnormalties_BroadcastNextFadeTime = nil
		end
	end
end)