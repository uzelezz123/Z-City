--\\Перевод плагиновых штук в ваши штуки
hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties
--//

--\\
PLUGIN.Ressurection = PLUGIN.Ressurection or {}
PLUGIN.Ressurection.ToRessurect = PLUGIN.Ressurection.ToRessurect or {}
--//

--\\
local function FindBody(zone)
	local best_ragdoll = nil
	local best_dist = math.huge

	for _, ent in ipairs(ents.FindInSphere(zone.Pos, zone.Radius)) do
		if(ent:GetClass() == "prop_ragdoll")then
			local ragdoll_owner = ent.ply
			
			if(IsValid(ragdoll_owner) and !ragdoll_owner:Alive())then
				local ragdoll = ragdoll_owner.FakeRagdoll or ragdoll_owner:GetNWEntity("RagdollDeath", ragdoll_owner.FakeRagdoll)
				
				if(IsValid(ragdoll))then
					local dist_sqr = zone.Pos:DistToSqr(ragdoll:GetPos())
					
					if(dist_sqr < best_dist)then
						best_dist = dist_sqr
						best_ragdoll = ragdoll
					end
				end
			end
		end
	end
	
	return best_ragdoll
end

local function Ressurect(owner, body, time)
	PLUGIN.ShowMessageToAll("Something happens now")
	util.ScreenShake(body:GetPos(), 5, 5, time, 300)

	PLUGIN.Ressurection.ToRessurect[owner] = {
		Owner = owner,
		Body = body,
		Time = CurTime() + time,
	}
end

local function TryRessurect(zone, ply)
	local blood_consumption = 3500
	
	if(PLUGIN.GetZoneOrPlyBlood(zone, ply) >= blood_consumption)then
		local body = FindBody(zone)
		
		if(body)then
			local owner = body.ply
			
			if(!PLUGIN.Ressurection.ToRessurect[owner])then
				PLUGIN.ShowMessageInSphere("Ressurecting " .. body:GetNWString("PlayerName") .. "...", zone.Pos, zone.Radius)
				Ressurect(owner, body, 5)
				PLUGIN.RemoveZoneOrPlyBlood(zone, ply, blood_consumption)
				PLUGIN.AddConsequencesToZoneChanters(zone, -2)
				PLUGIN.AddConsequences(ply, -50)
			else
				PLUGIN.ShowMessage(ply, "There are no dead bodies within the zone")
			end
			-- PLUGIN.AddConsequences(ply, 200)
		else
			PLUGIN.ShowMessage(ply, "There are no dead bodies within the zone")
		end
	else
		PLUGIN.ShowMessage(ply, "There is not enough blood in order to reanimate body")
	end
end
--//

--\\SpecialEvents
hook.Add("Abnormalties_HotZoneAbnormaltyAdded", "Abnormalties_Ressurection", function(zone_id, abnormalty_name, amt, ply)
	local zone = PLUGIN.Zones[zone_id]
	
	if(PLUGIN.GetZoneAbnormalty(zone, "sacrifice") >= 50 and PLUGIN.GetZoneAbnormalty(zone, "help") >= 30 and PLUGIN.GetZoneAbnormalty(zone, "ritual") >= 10 and amt > 0)then
		local clear_cd = 10
		
		if(!zone.Vars.RitualPhrasesAmtClearTime)then
			zone.Vars.RitualPhrasesAmtClearTime = CurTime() + clear_cd
		end
		
		if(zone.Vars.RitualPhrasesAmtClearTime <= CurTime())then
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
		
		if(PLUGIN.CompareZonePhrasesToPattern(zone, {{"ritual", 5}}, 5))then
			TryRessurect(zone, ply)
			
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
	end
end)

hook.Add("Think", "Abnormalties_Ressurection", function()
	for ply, info in pairs(PLUGIN.Ressurection.ToRessurect) do
		if(info.Time <= CurTime())then
			local owner = info.Owner
			local body = info.Body
			
			if(!IsValid(owner) or owner:Alive() or !IsValid(body))then
				PLUGIN.ShowMessageToAll("Ritual was interrupted by divine intervention.\nCorruption spreads")
			else
				hg.RespawnIntoBody(owner,body)
				owner:SetHealth(20)
				
				owner.organism.pain = 40
				owner.organism.disorientation = 50
				owner.organism.blood = 3500
				
				if(math.random(1, 4) == 4)then
					owner.organism.pulse = 10	--; Смерть
				else
					owner.organism.pulse = 15
				end
				
				-- hg.Fake(owner, body)
				-- hg.LightStunPlayer(owner)
				
				if(math.random(1, 10) <= 7)then
					owner.Swm = true	--; Паучки
				end
				-- owner:SetPos(body:GetPos())
				-- body:Remove()
				
				--owner:Give("weapon_hands_sh")
				PLUGIN.ShowMessageToAll("Something wicked happened")
			end
			
			PLUGIN.Ressurection.ToRessurect[ply] = nil
		end
	end
end)

hook.Add("PostCleanupMap", "Abnormalties_Ressurection", function()
	PLUGIN.Ressurection.ToRessurect = {}
end)
--//