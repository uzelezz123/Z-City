local max, min, Clamp, Approach = math.max, math.min, math.Clamp, math.Approach
--local Organism = hg.organism
hg.organism.module.pain = {}
local module = hg.organism.module.pain
module[1] = function(org)
	org.shock = 0
	org.pain = 0
	org.avgpain = 0
	org.painadd = 0
	org.hurt = 0
	org.hurtadd = 0
	org.painkiller = 0
	org.analgesia = 0
	org.analgesiaAdd = 0
	org.naloxone = 0
	org.naloxoneadd = 0
	org.immobilization = 0
	org.painlessen = 0
	org.tranquilizer = 0
	org.shock_turn = 0

	org.stun = 0
	org.lightstun = 0
end

function hg.organism.paincheck(org)
	local analgesiaMul = (org.analgesia * 4 + 1)
	local adrenalineMul = min(max(1 + org.adrenaline, 1), 1.2)

	return (org.shock > org.shock_turn * 4 * analgesiaMul)
end

module[2] = function(owner, org, timeValue)
	local adrenalineMul = min(max(1 + org.adrenaline, 1), 1.2)
	local adrenaline = org.adrenaline
	local analgesiaMul = (org.analgesia * 4 + 1)
	local painkillerMul = (org.painkiller * 0.5 + 1)

	org.shock_turn = 10 * (!org.otrub and 1 or 0.1)

	if org.shock > org.shock_turn * 1.5 * analgesiaMul * painkillerMul then
		--org.needfake = true
	end

	org.pain_turn = org.otrub and adrenalineMul * 80 or adrenalineMul * 90

	local owner = org.owner
	
	if !org.lasthit or org.lasthit + 1.5 < CurTime() then org.shock = max(org.shock - timeValue * 4 * (org.otrub and 1 or 0.5), 0) end
	org.immobilization = max(org.immobilization - timeValue * 2 * adrenalineMul, 0)

	local shouldPainAdd = not (org.otrub or org.spine2 >= hg.organism.fake_spine2 or org.spine3 >= hg.organism.fake_spine3)
	
	local add = math.min(timeValue * 20, org.painadd)
	local sub = (add <= 0.2) and (timeValue * 2 * (org.otrub and 2 or 1) + timeValue * (org.painkiller * 2) + timeValue * (org.analgesia * 4)) or (0)

	if adrenaline > 0.5 then
		sub = sub * math.max(1 - adrenaline, 0.05) / 1.5// / (adrenaline >= 2 and 16 or 8)
		add = add * math.max(1 - adrenaline, 0.05) / 1.5// / (adrenaline >= 2 and 16 or 8)
	end

	if org.pain > 60 and not org.otrub then
		add = add / 5
		if org.pain > 70 and add > 0.01 then
			sub = sub / 20
		else
			sub = sub / 5
		end

		org.disorientation = math.max(org.pain / 50, org.disorientation)//org.disorientation + add
		org.fearadd = 1
	end

	org.disorientation = math.min(org.disorientation, 10)

	if org.pain > 80 then
		org.shock = math.Approach(org.shock, 70, timeValue * 4)
	end

	if (org.shock > (30 * analgesiaMul)) or org.otrub then
		org.consciousness = math.Approach(org.consciousness, 0.1, timeValue / 5)
	end

	if org.tranquilizer > 0 then
		org.tranquilizer = math.Approach(org.tranquilizer, 0, org.tranquilizer > 1 and timeValue / 5 or timeValue / 30)
		--org.shock = math.Approach(org.shock, 50, timeValue * org.tranquilizer * 5)
		org.consciousness = math.Approach(org.consciousness, 0, timeValue / 30 * org.tranquilizer)
	else
		org.consciousness = math.Approach(org.consciousness, org.blood < 3000 and (org.blood - 2500) / 500 or 1, timeValue / 15)
	end

	if org.consciousness < 0.1 then
		org.needotrub = true
	end

	if org.consciousness < 0.4 then
		org.needfake = true
	end

	org.avgpain = min(org.avgpain + add, 150)
	if !org.lasthit or org.lasthit + 1 < CurTime() then org.avgpain = max(org.avgpain - sub, 0) end
	org.painlessen = sub

	org.pain = org.avgpain * math.max(1 - adrenaline / 4, 0.75) * math.max(1 - org.analgesia, 0)

	org.painadd = min(max(org.painadd - add, 0), 150)

	//org.painkiller = Approach(org.painkiller, 0, timeValue / 240 * (org.naloxone * 25 + 1))

	if hg.organism.paincheck(org) then
		org.needotrub = true
	end
	
	org.analgesia =  Approach(org.analgesia, 0, timeValue / 240 * (org.naloxone * 25 + 1))
	
	if org.analgesiaAdd > 0 then
		org.analgesia =  Approach(org.analgesia, 4, timeValue / 15)
		org.analgesiaAdd = Approach(org.analgesiaAdd, 0, timeValue / 15)
	end

	org.naloxone = Approach(org.naloxone, org.naloxoneadd > 0 and 4 or 0, org.naloxoneadd > 0 and timeValue / 30 or timeValue / 60)
	org.naloxoneadd = Approach(org.naloxoneadd, 0, timeValue / 15)
	
	--if owner.suiciding and org.adrenaline < 1.5 then
	--	org.adrenalineAdd = Approach(org.adrenalineAdd, 4, timeValue / 5)
	--end

	if org.adrenalineAdd > 0 then
		org.adrenaline = Approach(org.adrenaline, 4, timeValue / 5)
	end

	org.adrenalineAdd = Approach(org.adrenalineAdd, 0, org.adrenalineAdd < 0 and timeValue / 30 or timeValue / 5)

	org.adrenaline = Approach(org.adrenaline, 0, timeValue / 25)

	if org.lleg < 1 and !org.llegamputated then
		org.lleg = max(org.lleg - timeValue / 240, 0)
	end

	if org.rleg < 1 and !org.rlegamputated then
		org.rleg = max(org.rleg - timeValue / 240, 0)
	end

	if org.rarm < 1 then
		org.rarm = max(org.rarm - timeValue / 240, 0)
	end

	if org.larm < 1 then
		org.larm = max(org.larm - timeValue / 240, 0)
	end

	if org.pain > 100 then
		--org.needfake = true
	end

	//local tempo = math.Clamp(5 - (org.temperature - 31), 0, 15)
	
	//org.shock = math.max(org.shock, tempo * 4)
	
	org.disorientation = math.Approach(org.disorientation, 0, timeValue / 5)
end