local chat_dist_normal = 3000
local chat_dist_whisper = 100

--\\Whisper
	util.AddNetworkString("ChatWhisper")
	
	net.Receive("ChatWhisper", function(len, ply)
		ply.ChatWhisper = net.ReadBool()
	end)
--//

local function ChatLogic(output, input, isChat, teamonly, text)
	if not IsValid(output) then return true, true end
	if not IsValid(input) then return false end
	local result, is3D = hook.Run("CanListenOthers",output,input,isChat,teamonly,text)
	
	if result ~= nil then return result,is3D end

	local chat_dist = chat_dist_normal

	if(IsValid(output) and output.ChatWhisper)then
		chat_dist = chat_dist_whisper
	end

	if output:Alive() and input:Alive() and not output.organism.otrub and not input.organism.otrub and output.organism.o2[1] >= 15 and not output.organism.holdingbreath and input:TestPVS( output ) then
		if input:GetPos():Distance(output:GetPos()) < chat_dist and not teamonly then
			return true, true
		else
			return false
		end
	elseif not output:Alive() and not input:Alive() then
		return true
	else
		if not input:Alive() and output:Alive() then 
			if input:GetPos():Distance(output:GetPos()) < chat_dist and input:TestPVS( output ) and not teamonly then
				return true, true
			else
				return false
			end 
		end
		if not output:Alive() and input:Team() == 1002 and input:Alive() then return true end

		return false
	end
end

hook.Add("PlayerCanSeePlayersChat", "RealiticChar", function(text, teamOnly, listener, speaker)
	if not IsValid(speaker) then return end
    local result = ChatLogic(speaker,listener,true,false,text)

    if not IsValid(speaker) then speaker = Entity(0) end

	local Hook = hook.Run("HG_PlayerCanSeePlayersChat", listener, speaker )
	if Hook then
		return Hook
	end

    return result
end)

local function funca(ply, txt)
	if !ply:Alive() or !ply.organism then return end
	local starttxt = txt

	if ply.organism.pain > 80 then
		txt = table.Random(hg.sharp_pain)
	end

	local bJawBroken = ply.organism.jaw == 1 or ply.organism.jawdislocation
	local bUnintelligeble = ply.organism.brain > 0.05
	local bHasMassiveBrainDamage = ply.organism.brain > 0.14

	txt = utf8.force(txt)

	if bJawBroken then
		local iter = utf8.codes(txt)
		local len = 0
		local chars = {}
		local minus = utf8.codepoint("-", 1, 1)
		for i, code in iter do
			if math.random(3) == 1 then -- max dist 640
				code = minus
			end

			len = len + 1
			chars[len] = utf8.char(code)
		end
		txt = table.concat(chars)
	end
	
	if bUnintelligeble then
		local iter = utf8.codes(txt)
		local len = 0
		local chars = {}

		for i, code in iter do
			len = len + 1
			chars[len] = utf8.char(code)
		end

		for i, code in ipairs(chars) do
			if i > 1 and math.random(bHasMassiveBrainDamage and 2 or 3) == 1 then
				local old = chars[i]
				chars[i] = chars[i - 1]
				chars[i - 1] = old
			end

			if bHasMassiveBrainDamage then
				if math.random(3) == 1 then
					chars[i] = math.random(1, 2) == 1 and "m" or "b"
				end
			end
		end

		txt = table.concat(chars)

		if bHasMassiveBrainDamage and math.random(2) == 1 then txt = hg.utf8_reverse(utf8.codes(txt), utf8.len(txt)) end
	end

	if ply.organism.o2[1] < 15 or (ply.organism.brain > 0.15 and math.random(4) == 1) then return "..." end

	return txt
end

local hg_furcity = ConVarExists("hg_furcity") and GetConVar("hg_furcity") or CreateConVar("hg_furcity", 0, bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_LUA_SERVER), "Toggle phrase furryfier :3", 0, 1)

hook.Add("HG_PlayerSay", "huy", function(ply, txt)
	local text = txt[1]

	txt[1] = funca(ply, text)
end)

hook.Add("HG_PlayerSay", "furrifyPhraseOwO", function(ply, txt)
	local text = txt[1]
	
	if hg_furcity:GetBool() or ply.PlayerClassName == "furry" then
		text = hg.FurrifyPhrase(text)
	end

	txt[1] = text
end)

hook.Add("HG_PlayerCanHearPlayersVoice","BrainDamage", function(listener, speaker)
	if speaker.organism.brain > 0.05 then return false, false end
end)

local braindeadphrase_male = {
	"vo/episode_1/npc/male01/cit_behindyousfx01.wav",
	"vo/episode_1/npc/male01/cit_behindyousfx02.wav",
}
local braindeadphrase_female = {
	"vo/episode_1/npc/female01/cit_behindyousfx01.wav",
	"vo/episode_1/npc/female01/cit_behindyousfx02.wav",
}
hook.Add("HG_ReplacePhrase", "BraindeadPhrase", function(ply, phrase, muffed, pitch)
	if IsValid(ply) and ply.organism and ply.organism.brain >= 0.5 then
		local phr = ThatPlyIsFemale(ply) and braindeadphrase_female[math.random(#braindeadphrase_female)] or braindeadphrase_male[math.random(#braindeadphrase_male)]
		return ply, phr, muffed, pitch
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "RealisticVoice", function(listener,speaker)
	local result,is3D = ChatLogic(speaker,listener,false,false)
	local speak = speaker:IsSpeaking()
	speaker.IsSpeak = speak
	
	if speaker.IsOldSpeak ~= speaker.IsSpeak then
		speaker.IsOldSpeak = speak
		--print("huy")
		if speak then hook.Run( "StartVoice", speaker, listener ) else hook.Run( "EndVoice", speaker, listener )  end
	end

	local Hook = hook.Run("HG_PlayerCanHearPlayersVoice", listener, speaker )
	if Hook ~= nil then
		return Hook
	end

	return result,is3D
end)