local maxLength = CreateConVar("zchat_maxmessagelength", "256", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Maximum message length allowed")

if CLIENT then
	local fontSize = CreateClientConVar("zchat_fontsize", 5.5, true, false, "Self explanatory", 3, 10)
	local fontName = CreateClientConVar("zchat_font", "Bahnschrift", true, false, "Self explanatory, should be available to GMod")
	local fontAA = CreateClientConVar("zchat_fontaa", 1, true, false, "Font anti-aliasing", 0, 1)
	local fontWeight = CreateClientConVar("zchat_fontweight", 1000, true, false, "Font weight", 0, 1000)

	local function CreateChat()
		if (IsValid(hg.chat)) then
			hg.chat:Remove()
		end

		hg.chat = vgui.Create("zChatbox")
	end

	hook.Add("InitPostEntity", "ZChat", function()
		CreateChat()
	end)

	hook.Add("PlayerStartVoice","RemoveVoicePanles",function()
		if !IsValid(ply) then return end

		local other_alive = (ply:Alive() and LocalPlayer() != ply) or (ply.organism and (ply.organism.otrub or (ply.organism.brain and ply.organism.brain > 0.05)))

		return other_alive or nil
	end)

	-- CreateChat()

	hook.Add("PlayerBindPress", "ZChat", function(client, bind, pressed)
		bind = bind:lower()

		if (bind:find("messagemode") and pressed) then
			hg.chat:SetActive(true)

			return true
		end
	end)

	hook.Add("OnShowZCityPause", "ZChat", function()
		if !hg.chat:GetActive() then return end
		hg.chat:SetActive(false)

		return false
	end)

	hook.Add("HUDShouldDraw", "ZChat", function(name)
		if (name == "CHudChat") then
			return false
		end
	end)

	net.Receive("zChatMessage", function(len)
		local speaker = net.ReadEntity()
		local text = net.ReadString()
		local bWhisper = net.ReadBool()

		speaker.ChatWhisper = bWhisper

		CHAT_SPEAKER = speaker

		local supressed = hook.Run("OnPlayerChat", speaker, text, false, speaker:Alive(), bWhisper)
		if !supressed then
			chat.AddText(speaker, ": ", text)
		end

		CHAT_SPEAKER = nil
	end)

	net.Receive("zChatGlobalMessage", function(len)
		local buffer = net.ReadTable()

		chat.AddText(unpack(buffer))
	end)

	hook.Add("ChatText", "ZChat", function(index, name, text, messageType)
		if (IsValid(hg.chat)) then
			hg.chat:AddMessage(text)
		end
	end)

	function chat.AddText(...)
		if (IsValid(hg.chat)) then
			hg.chat:AddMessage(...)
		end

		-- log chat message to console
		local text = {}

		for _, v in ipairs({...}) do
			if (istable(v) or isstring(v)) then
				text[#text + 1] = v
			elseif (isentity(v) and v:IsPlayer()) then
				text[#text + 1] = team.GetColor(v:Team())
				text[#text + 1] = v:Name()
			elseif (type(v) != "IMaterial") then
				text[#text + 1] = tostring(v)
			end
		end

		text[#text + 1] = "\n"
		MsgC(unpack(text))
	end

	local function LoadFonts()
		local size = fontSize:GetFloat()
		local font = fontName:GetString()
		local fontAntiAliasing = fontAA:GetBool()
		local fontW = fontWeight:GetFloat()

		surface.CreateFont("zChatFont", {
			font = font,
			size = ScreenScale(size),
			extended = true,
			weight = fontW,
			antialias = fontAntiAliasing
		})

		surface.CreateFont("zChatFontSmall", {
			font = font,
			size = ScreenScale(4),
			extended = true,
			weight = fontW,
			antialias = fontAntiAliasing
		})
	end

	cvars.AddChangeCallback("zchat_fontsize", function()
		LoadFonts()
		CreateChat()
	end)

	cvars.AddChangeCallback("zchat_font", function()
		LoadFonts()
		CreateChat()
	end)

	cvars.AddChangeCallback("zchat_fontaa", function()
		LoadFonts()
		CreateChat()
	end)

	cvars.AddChangeCallback("zchat_fontweight", function()
		LoadFonts()
		CreateChat()
	end)

	LoadFonts()

	hook.Add("ModifyMessageBuffer", "ChatFont", function(buffer, speaker)
		if !IsValid(speaker) or !speaker:IsPlayer() then return end

		if speaker.PlayerClassName == "furry" then
			buffer[#buffer + 1] = "<font=ZB_ProotOSChat>"
		elseif speaker:IsBerserk() then
			buffer[#buffer + 1] = "<font=BerserkChatFont>"
		end
	end)

	hook.Add("StartChat", "TypingBool", function()
		net.Start("zChatTyping")
			net.WriteBool(true)
		net.SendToServer()
	end)

	hook.Add("FinishChat", "TypingBool", function()
		net.Start("zChatTyping")
			net.WriteBool(false)
		net.SendToServer()
	end)

	local META = FindMetaTable("Player")

	function META:IsTyping()
		return self:GetNetVar("bIsTyping")
	end

	local ghost = Color(118, 159, 255)
	local dead = Color(255, 0, 0)
	hook.Add("OnPlayerChat", "ZChatDead", function(ply, text, bTeam, bDead, bWhisper)
		if ( ply:IsPlayer() and !ply:Alive() ) then
			chat.AddText( dead, "*DEAD* ", ghost, ply:Nick(), ghost, ": "..text )
			return true
		end
	end)
else
	util.AddNetworkString("zChatMessage")
	util.AddNetworkString("zChatGlobalMessage")
	util.AddNetworkString("zChatTyping")

	net.Receive("zChatMessage", function(len, ply)
		local text = net.ReadString()

		local maxLen = maxLength:GetInt()

		if (text:utf8len() > maxLen) then
			text = text:utf8sub(0, maxLen)
		end

		hook.Run("PlayerSay", ply, text)
	end)

	hook.Add("PlayerSay", "ZChat", function(ply, text)
 		local txtTbl = {text}
		hook.Run("HG_PlayerSay", ply, txtTbl, text) // our shit gets called later
		text = isstring(txtTbl[1]) and txtTbl[1] or text // checks to see if shit hits the ceiling

		if ply:Alive() and ply.organism and ply.organism.otrub then return end

		ply.ChatWhisper = ply:Alive() and ply.ChatWhisper or false

		local rf = RecipientFilter()
		-- local checkdist = ply.ChatWhisper and 128 * 128 or 1024 * 1024
		for i, plya in player.Iterator() do
			if plya:Alive() and plya.organism and plya.organism.otrub then continue end
			if plya:Alive() and !ply:Alive() then continue end

			if (hook.Run("PlayerCanSeePlayersChat", text, false, plya, ply)) then
				rf:AddPlayer(plya)
			end
		end
		
		net.Start("zChatMessage")
			net.WriteEntity(ply)
			net.WriteString(text)
			net.WriteBool(ply.ChatWhisper)
		net.Send(rf)

		-- log chat message to console
		local textConsole = {}

		textConsole[#textConsole + 1] = ply:GetPlayerColor():ToColor()
		textConsole[#textConsole + 1] = ply:GetNWString("PlayerName", ply:Nick())
		textConsole[#textConsole + 1] = color_white
		textConsole[#textConsole + 1] = ": " .. text

		textConsole[#textConsole + 1] = "\n"

		MsgC(unpack(textConsole))

		hook.Run("PostPlayerSay", client, chatType, text)
		return ""
	end)

	net.Receive("zChatTyping", function(len, ply)
		ply:SetNetVar("bIsTyping", net.ReadBool())
	end)

	local META = FindMetaTable("Player")

	function META:IsTyping()
		return self:GetNetVar("bIsTyping")
	end

	function zChatPrint(...)
		net.Start("zChatGlobalMessage")
			net.WriteTable({...})
		net.Broadcast()
	end
end