local min, max, Round, halfValue2 = math.min, math.max, math.Round, util.halfValue2
--local Organism = hg.organism
hg.organism.module.pulse = {}
local module = hg.organism.module.pulse
module[1] = function(org)
	org.heart = 0
	org.heartstop = false
	org.pulse = 70 -- that's the blood pressure
	org.heartbeat = 70

	org.tempchanging = 0
	org.heatbuff = 30 -- seconds of heat supply
	org.needed_temp = 36.7
end

function hg.organism.should_gain_fear(org)
	return ((org.pain > 30) or (org.blood < 3000) or (org.bleed > 1))// + (org.just_damaged_bone and ((org.just_damaged_bone + 10 - CurTime()) >= 10) and 10 or 0)
end

module[2] = function(owner, org, timeValue)
	local heart = 1 - org.heart
	local brain = math.Clamp(1 - org.brain * 1.5,0,1)
	local o2 = org.o2
	local o2 = halfValue2(o2[1], o2.range, o2.k)

	//if org.isPly and not org.otrub and (heart == 0) then org.owner:Notify("My torso hurts.",true,"heart",6) end
	//if org.isPly and not org.otrub and org.heartstop then org.owner:Notify("",true,"heartstop",6) end

	local stamina = org.stamina
	
	local pulse = 70-- + 120 * ((stamina.max or 180) - stamina[1]) / (stamina.max or 180) * (org.lungsfunction and 1 or 0)
	--pulse = pulse + math.min(org.adrenaline, 2) * 40 + (!org.otrub and math.max(org.fear * 50, 0) or 0)
	pulse = org.alive and pulse or 0
	pulse = math.Clamp(pulse, 0, 200)
	
	org.pulse = math.Approach(org.pulse, pulse, pulse > org.pulse and timeValue * 2 or timeValue * 2)
	
	--local k = heart * o2 * (1 / math.Clamp((org.blood - 2000) / 3000,0.2,1)) * brain * (org.heartstop and 0.1 or 1) --* halfValue2(stamina[2], stamina.fatigueRange, stamina.fatigueK)
	local k = heart * o2 * (math.Clamp((org.blood - 1000) / 4000,0,1)) * brain * (org.heartstop and 0.1 or 1)
	pulse = pulse * k
	pulse = pulse * (math.Clamp(math.Remap(org.temperature, 28, 36.7, 0.5, 1), 0.5, 1))
	
	org.pulse = math.Approach(org.pulse, pulse, heart == 0 and timeValue * 10 or timeValue * 5)

	org.fearadd = math.Clamp(org.fearadd, 0, 3)

	local heartbeat = org.pulse < 70 and 70 + (70 - org.pulse) * 4 or org.pulse

	local runnin_or_exhausted = org.analgesia < 1 and (org.stamina.sub > 0 or org.stamina[1] < (org.stamina.max * 0.66))
	org.heartbeat = math.Approach(org.heartbeat, math.max(heartbeat - 10, runnin_or_exhausted and (org.stamina[1] < (org.stamina.max * 0.33) and 200 or 140) or 60), !runnin_or_exhausted and timeValue * 1 or timeValue * 5)
	
	heartbeat = heartbeat + (owner.suiciding and 50 or 0)
	heartbeat = heartbeat + 40 * math.max(0, org.fear)
	heartbeat = heartbeat + math.Clamp(org.shock, 0, 40)
	heartbeat = heartbeat + math.Clamp(org.pain, 40, 80) - 40
	heartbeat = heartbeat + 40 * math.min(org.adrenaline, 3)
	heartbeat = heartbeat - 40 * math.min(org.analgesia / 2.5, 1)
	heartbeat = heartbeat + 100 * math.Clamp(math.Remap(org.temperature, 40, 42, 0, 1), 0, 1)
	heartbeat = heartbeat - 160 * (1 - math.Clamp(math.Remap(org.temperature, 28, 36.7, 0, 1), 0, 1))

	org.heartbeat = math.Approach(org.heartbeat, heartbeat, heartbeat > org.heartbeat and timeValue * 5 or timeValue * 2)
	
	if org.heartstop then
		org.heartbeat = 0
	end

	org.fear = math.Approach(org.fear, (org.otrub and 0 or (org.fearadd > 0 and 1 or -1)), org.otrub and timeValue * 0.5 or (org.fearadd > 0 and (org.fear < 0 and timeValue * 5 * org.fearadd or timeValue / 5 * org.fearadd) or (org.fear <= 0 and timeValue / 240 or timeValue / 50)))
	-- less time to start fearing, more time to become calm again
	-- if no fear, in 3 minutes become slightly talkative, so would say random phrases to calm themselves in a current situation
	local gainfear = hg.organism.should_gain_fear(org)
	org.fearadd = math.Approach(org.fearadd, 0, gainfear and timeValue or timeValue / 4.9) -- 15 seconds to stop fearing something and start to calm down
	org.fearadd = math.Approach(org.fearadd, 1, gainfear and timeValue / 5 or 0)
	
	local adrenK = max(1 + org.adrenaline, 1)
	local adren = org.adrenaline

	if org.pulse < 10 or org.brain >= 0.6 then org.heartstop = true end
	if org.temperature < 28 or org.temperature > 42 then org.heartstop = true end

	if org.temperature < 34 or org.temperature > 38 then
		org.fear = math.max(org.fear, 0)
	end

	-- temperature
	local needed_temp = math.min(math.max(37 * (org.pulse / 45), 35), 36.7)
	local changeRate = timeValue / 60
	changeRate = changeRate * (org.temperature < needed_temp and math.Clamp(org.heatbuff / 60, 1, 2) or 1)
	if math.abs(org.tempchanging) < changeRate then
		org.temperature = math.Approach(org.temperature, needed_temp, changeRate)
	else
		org.needed_temp = needed_temp
	end
	
	if not org.heartstop then
		org.last_heartbeat = CurTime()
	end

	if org.heartstop and adren > 0 and (org.adrenaline_try or 0) < CurTime() then
		local chance = math.Clamp(adren * 25,0,25)
		local rand = math.random(100)

		org.adrenaline_try = CurTime() + 0.1

		if chance > rand then org.heartstop = false end
	end

	if org.heartstop then
		org.heartstoptime = org.heartstoptime or CurTime()
		if org.isPly then
			//org.owner:Notify("I'm feeling dizzy...", true, "heartstop", 10)
		end
	else
		if org.isPly then
			//org.owner:ResetNotification("heartstop")
		end
		org.heartstoptime = nil
	end

	if org.alive and org.heartstoptime and org.heartstoptime + 30 < CurTime() and (org.lastsoundtime or 0) < CurTime() and org.o2.regen > 0 and org.otrub then
		org.owner:EmitSound("zcitysnd/real_sonar/"..(ThatPlyIsFemale(org.owner) and "female" or "male").."_wheeze"..math.random(5)..".mp3", 50)
		--org.owner:EmitSound("breathing/agonalbreathing_"..math.random(13)..".wav", 50)
		
		org.lastsoundtime = CurTime() + math.random(25,35)
	end
end

--if org.heartstop then org.needotrub = true end --не совсем...
util.AddNetworkString("pulse")
function hg.organism.Pulse(owner, org, timeValue)
	local stamina = org.stamina
	if org.o2[1] > 1 and org.alive and org.heart < 1 and org.brain < 0.6 then
		--org.brain = max(org.brain - timeValue / 30, 0) --regen
	end--brain damage is usually permanent

	if owner:IsPlayer() and owner:Alive() then
		net.Start("pulse")
		net.Send(owner)
	end
end