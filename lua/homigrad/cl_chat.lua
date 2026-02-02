// v7 privet
local hook_Run = hook.Run
hook.Add( "OnPlayerChat", "HGPlayerChat", function( ply, strText, bTeam, bDead, bWhisper ) 
	if bWhisper == nil then return true end

	if ( ply:IsPlayer() and ply:Alive() ) then -- if the player typed /fuckyou then
		local string = {strText}
		
		if hook.Run("HG_OnPlayerCommand", ply, string) then
			return true
		end
		
		local Hook = hook.Run("HG_OnPlayerChat", ply, string, bTeam, bDead, ply:GetPlayerColor():ToColor(), ply:GetPlayerName(), bWhisper)

		strText = string[1]

		if Hook then
			return Hook
		end

		chat.AddText( ply:GetPlayerColor():ToColor(), ply:GetPlayerName(), color_white, ": "..strText ) -- print Hello fuckyou to the console
		
		return true -- this suppresses the fcukyopu from being shown
	end
end )

hook.Add("HG_OnPlayerChat", "TextModificationBasedOnStuff", function(ply, text, bTeam, bDead, plyColor, plyName, bWhisper)
	local txt = text[1]
	
	local dist = ply:GetPos():Distance(lply:GetPos())
	local checkdist = bWhisper and 64 or 512
	if dist > checkdist then
		local cutdist = math.Clamp((dist - checkdist) / (checkdist), 0, 1)
		local cutamt = math.Round(cutdist * #txt)
		
		local iter = utf8.codes(txt)
		local len = 0
		local chars = {}
		local minus = utf8.codepoint("-", 1, 1)

		for i, code in iter do
			len = len + 1
			chars[len] = code--utf8.char(code)
		end

		for i, code in RandomPairs(chars) do
			if cutamt > 0 then
				cutamt = cutamt - 1

				code = minus
			end

			chars[i] = utf8.char(code)
		end

		txt = table.concat(chars)
	end
	
	text[1] = txt
end)

--\\Whisper
	ZChatOpen = ZChatOpen or false
	ZChatWhisper = ZChatWhisper or false

	hook.Add("StartChat", "ChatWhisper", function()		
		ZChatOpen = true
	end)
	
	hook.Add("FinishChat", "ChatWhisper", function()		
		ZChatOpen = false
		ZChatWhisper = false
		
		net.Start("ChatWhisper")
			net.WriteBool(false)
		net.SendToServer()
	end)

	hook.Add("Think", "ChatWhisper", function()		
		if(input.IsKeyDown(KEY_LALT) and !ZChatWhisper)then
			net.Start("ChatWhisper")
				net.WriteBool(true)
			net.SendToServer()
			
			ZChatWhisper = true
		end
		
		if(!input.IsKeyDown(KEY_LALT) and ZChatWhisper)then
			net.Start("ChatWhisper")
				net.WriteBool(false)
			net.SendToServer()
			
			ZChatWhisper = false
		end
	end)

	hook.Add("ModifyMessageBuffer", "ChatWhisper", function(buffer, speaker)
		if IsValid(speaker) and speaker.ChatWhisper then
			buffer[#buffer + 1] = "<color=150,150,150>[whisper]</color> "
		end
	end)
--//

-- hook.Add("Player_Death", "ResetChatFont",function()
-- 	atlaschat.font:SetString("atlaschat.theme.text")
-- end)

-- hook.Add("Player Spawn","ResetChatFont",function()
-- 	atlaschat.font:SetString("atlaschat.theme.text")
-- end)