hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties

--\\
local convar_newbie = CreateClientConVar("abnormalties_newbie", "1", true, false, "Set to 1 if you want to see a hint again")

PLUGIN.MainColor = Color(150, 0, 0)
--//
-- abnormalties_help
--\\
net.Receive("Abnormalties(ShowTranslation)", function(len, ply)
	local abnormalty = {}
	local abnormalty_name = net.ReadString()
	local abnormalty_amt = net.ReadUInt(32)
	
	while abnormalty_name != "" and net.BytesLeft() > 0 do
		abnormalty[abnormalty_name] = abnormalty_amt
		abnormalty_name = net.ReadString()
		abnormalty_amt = net.ReadUInt(32)
	end
	
	if(convar_newbie:GetBool())then
		convar_newbie:SetBool(false)
		
		PLUGIN.ShowMessage("You've stumbled upon something abnormal, type abnormalties_help in console for help")
	end
	
	PLUGIN.ShowTranslation(abnormalty)
end)

net.Receive("Abnormalties(ShowMessage)", function(len, ply)
	local msg = net.ReadString()
	
	PLUGIN.ShowMessage(msg)
end)
--//

--\\
function PLUGIN.ShowTranslation(abnormalty)
	-- Abnormalties_VGUI_Abnormalty = abnormalty
	-- Abnormalties_VGUI_AbnormaltyTimeEnd = CurTime() + 10
	local count = 0
	
	chat.AddText(PLUGIN.MainColor, "I'm getting somewhere...")
	
	for abnormalty_name, abnormalty_amt in pairs(abnormalty) do
		chat.AddText(PLUGIN.MainColor, abnormalty_name, " - " .. abnormalty_amt)
		
		count = count + 1
	end
	
	if(count > 1)then
		chat.AddText(PLUGIN.MainColor, "But there's still something I need to exclude...")
	elseif(count == 1)then
		chat.AddText(PLUGIN.MainColor, "This is it... I found it!")
		chat.AddText(PLUGIN.MainColor, "Now, it's just a matter of chanting it over and over again in one spot...")
	elseif(count == 0)then
		chat.AddText(PLUGIN.MainColor, "But... It's useless, I need to put meaning into words...")
	end
end

function PLUGIN.ShowMessage(msg)
	chat.AddText(PLUGIN.MainColor, msg)
end
--//