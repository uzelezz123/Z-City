hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties

-- (LIE) Balance is influenced by the amount of phrases said by you in the zone, that is creating and growing new zones after each ritual grants the most instabillity.

ABNORMALTIESHELP = ABNORMALTIESHELP or {}
ABNORMALTIESHELP.LastUpdate = CurTime()
ABNORMALTIESHELP.Stats={
	[8] = {
		Requirement = "consequences",
		Name = "Consequences",
		Desc = [[
		DO NOT USE THIS STOP
(how dramatic, you learn about consequences after you get them)

I just didn't realised it until now.
Performing rituals disrupt every chanter's Balance.

Everyone's Balance is initially at equilibrium.
If you perform a ritual, your Balance will shift in direction, according to ritual's requirements.
Rituals with Blood as a requirement will shift your balance into negative direction.
Rituals with Equalizers as a requirement will shift your balance into positive direction.
Rituals what require both Equalizers and Blood will ??? I dunno really.

No matter the direction, if your Balance is far enough from equilibrium you will experience instabillity.
You may randomly start bleeding, shivering, losing consciousness, taking damage and etc.
Balance will not return to equilibrium on its own, however symptoms will fade over time and instantly return after contact with magic.

To see your current balance, type "/myabno" in chat (this command also shows your other stats).

... Equilibrium is not the only comfortable state to be in though, being in a state of semi-tension is generally uncomfortable, so either full in or nothing.
]]
	},
	[9] = {
		Requirement = "instabillity",
		Name = "Instabillity's forbidden fruits",
		Desc = [[
If you're here, you probably have ignored all previous advice to stop and now are in some kind of extremely unstable state (>= 300 in any direction).
Besides things you already may have seen, I have some kinda good news for you.

You are now the living magic.

Depending on what side of instabillity you're in currently, you'll have different side effects:
Negative:
	Halved Blood requirements in rituals (LIE)
	Passive Abnormal Blood generation
Positive:
	Halved Equalizers requirements in rituals (LIE)
	Passive Equalizers generation
	
You can also now see zone's stats by typing "/zoneabno" in chat.
]]
	},
	[10] = {
		Requirement = "insanity",
		Name = "???",
		Desc = [[
(majority of the page is still covered in blood, but I can now at least read something)
FIRENZE, I AM DEAD
I DID NOT STOP
I REACHED THE LIMIT
HAHA funny thingy actually by typing "/findphrase" in chat AND YOU CAN ALSO SPECIFY WHICH ABNORMALTY YOU WANT TO FIND YOU CAN FIGURE OUT IT YOURSELF OK
/findphrase help FINDS HELP PHRASE, IT WON'T HELP ME THOUGH
]]
	},
	[13] = {
		Requirement = "positive_instabillity",
		Name = "Fly",
		Desc = [[
		WIP NOT WORKING
An ability to fly..
This is beatiful isn't it?
You will need:
	help 20, ritual 10
	Equalizers 300
How to activate:
	Chant pattern <ritual 2, help 2, sacrifice 5 ...> with the total of 5 words in quick succession (You have 10 seconds)
What it does?:
	Grants player, closest to the zone's centre the ability to fly in the direction you're looking while attempting to walk forward for approximately half a moment (45 seconds).
	Chanting player will be prioritised 5 times the other players in zone.
]]
	},
	[14] = {
		Requirement = "negative_instabillity",
		Name = "Swarm Leader",
		Desc = [[
		WIP NOT WORKING
I have never tried it and would not ever try..
Some unfortunate mages condemned themselves to a horrifying fate by mistake.
I noted their progress.
You will need:
	harm 20, ritual 10
	Blood 25'000
How to activate:
	Chant pattern <ritual 2, harm 2, sacrifice 10 ...> with the total of 5 words in quick succession (You have 10 seconds)
What it does?:
	Mutilates someone into the living flower.
	Flowers will perceive someone as their god.
	Grants player, closest to the zone's centre the ability to create and command flowers.
	Chanting player will be prioritised 5 times the other players in zone.
]]
	},
	[15] = {
		Requirement = "positive_instabillity",
		Name = "Equalizer",
		Desc = [[
If only there would have been justice..
(you may also notice it's resemblence to SWAT body armor)
You will need:
	shield 20, ritual 10, help 10
	Equalizers 400
How to activate:
	Chant pattern <shield 5, help 2, sacrifice 2 ...> with the total of 5 words in quick succession (You have 10 seconds)
User Requirements:
	Karma >= 140
What it does?:
	Conjures special equipment (you might as well get the reference here) in the centre of the zone capable of protecting its wearer.
	↑↑ 0.5 MELEE HP
	↑↑ 0.1 MELEE ORGANS
	↓ 1.2 MELEE BLEED
	-- -- --
	↑↑ 0.4 BULLET HP
	↑↑ 0.005 BULLET ORGANS
	↑↑ 0.1 BULLET BLEED
	If user's Karma falls under 140, user dies.
	Lowers abnormal effects of user when in use (just to make your life easier (Heal still does this better though (stacks with Heal))).
]]
	},
	[16] = {
		Requirement = "negative_instabillity",
		Name = "Bleeding Musket",
		Desc = [[
If a have so much blood I might as well start shooting it..
You will need:
	harm 20, ritual 10, sacrifice 10
	Blood 25'000
How to activate:
	Chant pattern <harm 5, ritual 2, sacrifice 2 ...> with the total of 5 words in quick succession (You have 10 seconds)
What it does?:
	Conjures musket that uses it's owner's blood as ammo in the centre of the zone.
	Shooting requires 1000 of your blood or 2000 of your abnormal blood (sums up).
	Applies incredible pain and disorientation through shots.
	Dissolves anything what can not experience pain.
	Completely ignores any armor or special equipment.
	Bullets have high penetration.
	60 PAIN
	10 DISORIENTATION
	or
	80 DISSOLVE
]]
	},
}

--\\Networking
net.Receive("Abnormalties(SendOpenedPage)", function(len, ply)
	local page = net.ReadUInt(8)
	local page_info = ABNORMALTIESHELP.Stats[page]

	if(ply.AbnormaltiesReady)then
		if(page_info)then
			local knowledge = ply.AbnormaltiesKnowledge
			ply.AbnormaltiesLastPagesUpdates = ply.AbnormaltiesLastPagesUpdates or {}
			
			if(knowledge[page_info.Requirement] and ply.AbnormaltiesLastPagesUpdates[page] != ABNORMALTIESHELP.LastUpdate)then
				ply.AbnormaltiesLastPagesUpdates[page] = ABNORMALTIESHELP.LastUpdate
				
				net.Start("Abnormalties(SendOpenedPage)")
					net.WriteUInt(page, 8)
					net.WriteString(page_info.Name)
					net.WriteString(page_info.Desc)
				net.Send(ply)
			end
		end
	else
		PLUGIN.LoadConsequences(ply)
		
		return false
	end
end)
--//