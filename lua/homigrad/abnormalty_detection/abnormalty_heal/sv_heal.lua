--\\Перевод плагиновых штук в ваши штуки
hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties
--//

--\\
PLUGIN.Heal = PLUGIN.Heal or {}
PLUGIN.Heal.ToHeal = PLUGIN.Heal.ToHeal or {}
--//

--\\
local function FindPly(zone, caller)
	local best_ply = nil
	local best_dist = math.huge

	for _, ent in ipairs(ents.FindInSphere(zone.Pos, zone.Radius)) do
		if(ent:IsPlayer() and ent:Alive())then
			local dist_sqr = zone.Pos:DistToSqr(ent:GetPos())
		
			if(caller == ent)then
				dist_sqr = dist_sqr / 2
			end
		
			if(dist_sqr < best_dist)then
				best_dist = dist_sqr
				best_ply = ent
			end
		end
	end
	
	return best_ply
end

local function Heal(owner, time, zone)
	-- PLUGIN.ShowMessageToAll("Something happens now")

	PLUGIN.Heal.ToHeal[owner] = {
		Owner = owner,
		Time = CurTime() + time,
		Zone = zone,
	}
end

local function TryHeal(zone, ply)
	local blood_consumption = 2500
	
	if(PLUGIN.GetZoneOrPlyBlood(zone, ply) >= blood_consumption)then
		local owner = FindPly(zone, ply)
		
		if(owner and !PLUGIN.Heal.ToHeal[owner])then
			Heal(owner, 5)
			PLUGIN.ShowMessageInSphere("Healing " .. owner:GetNWString("PlayerName") .. "...", zone.Pos, zone.Radius)
			PLUGIN.RemoveZoneOrPlyBlood(zone, ply, blood_consumption)
			PLUGIN.AddConsequencesToZoneChanters(zone, -1)
			PLUGIN.AddConsequences(ply, -20)
		else
			PLUGIN.ShowMessage(ply, "There are no players within the zone")
		end
	else
		PLUGIN.ShowMessage(ply, "There is not enough blood in order to heal")
	end
end
--//

--\\SpecialEvents
hook.Add("Abnormalties_HotZoneAbnormaltyAdded", "Abnormalties_Heal", function(zone_id, abnormalty_name, amt, ply)
	local zone = PLUGIN.Zones[zone_id]
	
	if(PLUGIN.GetZoneAbnormalty(zone, "sacrifice") >= 10 and PLUGIN.GetZoneAbnormalty(zone, "help") >= 20 and amt > 0)then
		local clear_cd = 10
		
		if(!zone.Vars.RitualPhrasesAmtClearTime)then
			zone.Vars.RitualPhrasesAmtClearTime = CurTime() + clear_cd
		end
		
		if(zone.Vars.RitualPhrasesAmtClearTime <= CurTime())then
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
		
		if(PLUGIN.CompareZonePhrasesToPattern(zone, {{"help", 1}, {"sacrifice", 1}}, 5))then
			TryHeal(zone, ply)
			PLUGIN.ResetPhrasesAbnormaltiesFromZone(zone)
			
			zone.Vars.RitualPhrasesAmtClearTime = nil
		end
	end
end)

hook.Add("Think", "Abnormalties_Heal", function()
	for ply, info in pairs(PLUGIN.Heal.ToHeal) do
		if(info.Time <= CurTime())then
			local owner = info.Owner
			local zone = info.Zone
			
			if(IsValid(owner) and owner:Alive())then
				owner:SetHealth(math.min(owner:Health() + 50, owner:GetMaxHealth() * 2))
				
				owner.organism.pain = 0
				owner.organism.disorientation = 0
				owner.organism.blood = owner.organism.blood + 2500
				owner.organism.wounds = {}
				owner.organism.lungsL = {[1] = 0, [2] = 0}
				owner.organism.lungsR = {[1] = 0, [2] = 0}
				owner.organism.bleed = 0.1
				owner.organism.pulse = 80
				-- owner.organism.bleedStart = 12312312312
				owner.organism.internalBleed = 0
				owner.organism.spine1 = 0
				owner.organism.spine2 = 0
				owner.organism.spine3 = 0
				owner.organism.lleg = 0
				owner.organism.rleg = 0
				owner.organism.trachea = 0
				owner.organism.pneumothorax = 0
				owner.organism.llegartery = 0
				owner.organism.rlegartery = 0
				owner.organism.spineartery = 0
				owner.organism.brain = 0
				owner.organism.heartstop = false
				owner.organism.jaw = 0
				owner.AbnormaltiesHealGrace = (owner.AbnormaltiesHealGrace or CurTime()) + 120
				
				owner:SetNetVar("wounds", owner.organism.wounds)
				
				if(zone)then
					PLUGIN.ShowMessageInSphere("Healed " .. owner:GetNWString("PlayerName"), zone.Pos, zone.Radius)
				end
			else
				PLUGIN.ShowMessageToAll("Nothing happened")
			end
			
			PLUGIN.Heal.ToHeal[ply] = nil
		end
	end
end)

hook.Add("PostCleanupMap", "Abnormalties_Heal", function()
	PLUGIN.Heal.ToHeal = {}
end)
--//