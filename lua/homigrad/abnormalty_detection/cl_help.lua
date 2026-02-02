-- if(SERVER)then
	-- PrintMessage(HUD_PRINTTALK, "Use 'stats_help' concommand to understand the stats")
-- end

ABNORMALTIESHELP = ABNORMALTIESHELP or {}
ABNORMALTIESHELP.Stats={
	[1] = {
		Name = "Introduction",
		Desc = [[
		DO NOT USE THIS STOP
		STOP
It seems like you've found something strange.
Something you should NEVER use until you know what you are doing, and you do not know.
If, however, you like some spicy feelings, then.
This book is about commencing rituals and doing other wicked things.

1. Zones
Thaumaturgical zones are special zones, which occur in place of usage of thaumaturgical phrases.
Zones can overlap.
Zones allow for rituals to take place within.
Zones have special attributes which you may not be able to know just by glance, so keep track of everything.
Zones can grow after the usage of thaumaturgical phrases within it.
Growth of thaumaturgical zone is directly affected by the complexity of the thaumaturgical phrase being spoken.

2. Phrases
To chant something useful, you need to put meaning into words.
Every letter of alphabet corresponds to some changes in thaumaturgical table.
You need to create a phrase, that will contain only one thaumaturgical meaning in order to interact with the thaumaturgical zones. This phrase will be added to the zone you're currently standing in.

3. Letters
Thaumaturgical phrases consists of some symbols and thaumaturgical letters.
They will change after map cleanup. This can be delayed by 10 minutes every time by spelling a proper thaumaturgical phrase with these letters.

4. Chanting your first phrase
Try to chant something like "resources of the body" 10 times.
After you chanted it 10 times, some thoughts will appear in your head and point you in the direction you're going.

Example:
<...>
- ноте бено мемо ммммт
~ I'm getting somewhere...
~ sacrifice - 2
~ ritual - 5
~ But there's still something I need to exclude...

So, let's for example get rid of sacrifice
<...>
- ноте бено мемо ммммтч
~ I'm getting somewhere...
~ sacrifice - 1
~ ritual - 6
~ But there's still something I need to exclude...

See, I added letter "ч" and gained 1 ritual and lost 1 sacrifice, let's add one more then
<...>
- ноте бено мемо ммммтчч
~ I'm getting somewhere...
~ ritual - 7
~ This is it... I found it!
~ Now, it's just a matter of chanting it over and over again in one spot...

First thaumaturgical phrase done!

5. Resources
Blood:
To collect blood, you need to have someone bleeding within the zone.
Additional blood will be given if you'll draw some kind of symbol.
Note, that zone's starting radius is small and it's growth is slow, so you should avoid wasting blood outside of the zone.
There is also an Abnormal version of this resource, it is stored inside of you instead of in the zone.

Equalizers:
Take damage.
Note, this resource is stored on you instead of in the zone.

6. Rituals
Continue on the NEXT page.
]]
	},
	[2] = {
		Name = "Rituals 1",
		Desc = [[Life force]]
	},
	[3] = {
		Name = "Heal",
		Desc = [[
You will need:
	sacrifice 10, help 20
	Blood 2500
How to activate:
	Chant <help 1, sacrifice 1 ...> with the total of 5 words in quick succession (You have 10 seconds)
What it does?:
	Almost fully heals one player closest to the center of the thaumaturgical zone.
	Chanting player will be prioritised 2 times the other players in zone.
	Be sure to remove other unwanted player before commencing.
	Significantly lowers abnormal effects for 2 minutes each time it's called (stacks).
	Does not cure any mental abnormalties.]]
	},
	[4] = {
		Name = "Ressurection",
		Desc = [[
You will need:
	sacrifice 50, help 30, ritual 10
	Blood 3500
How to activate:
	Chant <ritual 5> 5 times in quick succession (You have 10 seconds)
What it does?:
	Ressurects one body closest to the center of the thaumaturgical zone.
	Be sure to remove other unwanted bodies before commencing.
	Ressurection, sometimes, yield unforseen consequences.
	Besides these consequences, ressurected human can have their heart stopped randomly at first.]]
	},
	[5] = {
		Name = "Rituals 2",
		Desc = [[Invisibility, interaction and etc.]]
	},
	[6] = {
		Name = "Cogito Evasion (Invisibility)",
		Desc = [[
Even if they can see me, they can't aknowledge me.
You will need:
	shield 10, help 20, 
	Equalizers 50
How to activate:
	Chant <shield 10> 5 times in quick succession (You have 10 seconds)
What it does?:
	Grants total cogito evasion (invisibility) until contact with any other cogito handler or after passage of 45 seconds (does not stack).
	Chanting player will be prioritised 2 times the other players in zone.
]]
	},
	[7] = {
		Name = "Cogito Broadcast",
		Desc = [[
Even if they I can see them, I can't aknowledge them, except if I use the same techniques as them.
You will need:
	help 20, ritual 10
	Equalizers 15
How to activate:
	Chant <help 5> 5 times in quick succession (You have 10 seconds)
What it does?:
	Makes contact with every cogito handler.
	Disables invisibility and other things for everyone.
	Chanting player will be prioritised 2 times the other players in zone.
	As a side effect, everything you say will be broadcasted to everyone for approximately 10 seconds (does not stack).
]]
	},
	[8] = {
		Requirement = true,
		Name = "???",
		Desc = [[
		DO NOT USE THIS STOP
(the rest of the text is unreadable)
(I might need to do something in order to be able to read this)
]]
	},
	[9] = {
		Requirement = true,
		Name = "???",
		Desc = [[
(text is unreadable)
(I might need to ignore all warnings to be able to read this)
]]
	},
	[10] = {
		Requirement = true,
		Name = "???",
		Desc = [[
(this page is torn and covered in blood, text is unreadable)
(I might need to go insane to be able to read this)
]]
	},
	[11] = {
		Name = "Rituals 3",
		Desc = [[Composite rituals and hard rituals]]
	},
	[12] = {
		Name = "Thaumaturgical Arm Conjurement",
		Desc = [[
It seems that purity of the blood matters the most in rituals and not the amount.
By utilizing Magic-infused weaponry I will be able to extract the purest blood.
You will need:
	ritual 20, harm 10, sacrifice 10
	Equalizers 5
	Blood 250
	Spare melee weapon
How to activate:
	Place melee weapon inside of the zone,
	Chant pattern <ritual 2, sacrifice 2 ...> with the total of 5 words in quick succession (You have 10 seconds)
What it does?:
	Converts placed melee weapon into Thaumaturgic Arm.
	Weapon will allow you to draw Abnormal blood from yourself or from any other human.
]]
	},
	[13] = {
		Requirement = true,
		Name = "???",
		Desc = [[
		WIP NOT WORKING
(text is unreadable)
(I might need to exaggerate in positive direction to be able to read this)
]]
	},
	[14] = {
		Requirement = true,
		Name = "???",
		Desc = [[
		WIP NOT WORKING
(text is unreadable)
(I might need to exaggerate in negative direction to be able to read this)
]]
	},
	[15] = {
		Requirement = true,
		Name = "???",
		Desc = [[
(text is unreadable)
(I might need to exaggerate in positive direction to be able to read this)
]]
	},
	[16] = {
		Requirement = true,
		Name = "???",
		Desc = [[
(text is unreadable)
(I might need to exaggerate in negative direction to be able to read this)
]]
	},
}

--; Добавить ритуалы:
--; Создание магической тыкалки

function ABNORMALTIESHELP:OpenStats(Recipe)
	Recipe=Recipe or 1
	if(!ABNORMALTIESHELP.Stats[Recipe])then
		if(Recipe <= 0)then
			Recipe = #ABNORMALTIESHELP.Stats
		else
			Recipe = 1
		end
	end
	if(IsValid(ABNORMALTIESHELP.Panel))then ABNORMALTIESHELP.Panel:Remove() end
	
	ABNORMALTIESHELP.Panel = vgui.Create("DFrame")
	local frame = ABNORMALTIESHELP.Panel
	local size={math.max(ScrW()/4,640),math.max(ScrH()/2.5,640)}
	
	frame:SetTitle("")
	frame:SetSize(size[1], 0)
	frame:SizeTo(size[1], size[2], 0.1)
	frame:SetPos((ScrW()-size[1])/2, (ScrH()-size[2]))
	frame:MoveTo((ScrW()-size[1])/2, (ScrH()-size[2])/2, 0.1)
	frame:MakePopup()
	frame:NoClipping(true)
	frame.Paint = function( sel, w, h )
		local fancyayy ={
			{ x = -10, y = -15 },
			{ x = w+50, y = -10 },
			{ x = w+4, y = h },
			{ x = -5, y = h+3 }
		}
		draw.NoTexture()
		surface.SetDrawColor( 150, 0, 0, 255 )
		surface.DrawPoly(fancyayy)
		local fancyayy1 ={
			{ x = 0, y = 1 },
			{ x = w+40, y = -4 },
			{ x = w, y = h-1 },		
			{ x = 0, y = h }
		}
		draw.NoTexture()
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawPoly(fancyayy1)
	end
	

	
	frame.Label = Label(ABNORMALTIESHELP.Stats[Recipe].Name, frame)
	frame.Label:SetFont("CloseCaption_Bold")
	frame.Label:Dock( TOP )
	frame.Label:SetSize(size[1],32)

	frame.Desc = vgui.Create("RichText",frame)
	frame.Desc:AppendText(ABNORMALTIESHELP.Stats[Recipe].Desc)
	function frame.Desc:PerformLayout()
		self:SetVerticalScrollbarEnabled(true)
		self:SetFontInternal("CloseCaption_Normal")
	end
	frame.Desc:Dock( TOP )
	frame.Desc:SetSize(size[1]-90,size[2]-100)

	frame.Prev = vgui.Create("DButton",frame)
	frame.Prev:SetText("<--Prev")
	frame.Prev:SetPos(0, 0)
	frame.Prev:SetSize(50, 20)
	frame.Prev.DoClick = function()
		ABNORMALTIESHELP:OpenStats(Recipe - 1)
	end

	frame.PageNumberEntry = vgui.Create("DTextEntry",frame)
	frame.PageNumberEntry:SetNumeric(true)
	frame.PageNumberEntry:SetText(Recipe)
	frame.PageNumberEntry:SetPos(50, 0)
	frame.PageNumberEntry:SetSize(20, 20)
	frame.PageNumberEntry.OnEnter = function(sel)
		ABNORMALTIESHELP:OpenStats(tonumber(sel:GetValue()))
	end

	frame.Next = vgui.Create("DButton",frame)
	frame.Next:SetText("Next-->")
	frame.Next:SetPos(70, 0)
	frame.Next:SetSize(50, 20)
	frame.Next.DoClick = function()
		ABNORMALTIESHELP:OpenStats(Recipe + 1)
	end
	
	if(ABNORMALTIESHELP.Stats[Recipe].Requirement)then
		net.Start("Abnormalties(SendOpenedPage)")
			net.WriteUInt(Recipe, 8)
		net.SendToServer()
	end
end

concommand.Add("abnormalties_help",function()
	ABNORMALTIESHELP:OpenStats()
end)

--\\Networking
net.Receive("Abnormalties(SendOpenedPage)", function(len, ply)
	local page = net.ReadUInt(8)
	local page_name = net.ReadString()
	local page_desc = net.ReadString()
	ABNORMALTIESHELP.Stats[page].Name = page_name
	ABNORMALTIESHELP.Stats[page].Desc = page_desc
	
	ABNORMALTIESHELP:OpenStats(page)
end)
--//