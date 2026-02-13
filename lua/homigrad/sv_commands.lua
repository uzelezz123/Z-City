COMMANDS = COMMANDS or {}

local validUserGroupSuperAdmin = {
	superadmin = true,
}

local validUserGroup = {
	admin = true,
}

function COMMAND_GETACCES(ply)
	if ply == Entity(0) then return 2 end

	local group = ply:GetUserGroup()
	if validUserGroup[group] then
		return 1
	elseif validUserGroupSuperAdmin[group] then
		return 2
	end

	return 0
end

function COMMAND_ACCES(ply,cmd)
	local access = cmd[2] or 1
	if access ~= 0 and COMMAND_GETACCES(ply) < access then return end

	return true
end

function COMMAND_GETARGS(args)
	local newArgs = {}
	local waitClose,waitCloseText

	for i,text in pairs(args) do
		if not waitClose and string.sub(text,1,1) == "\"" then
			waitClose = true

			if string.sub(text,#text,#text) == "\n" then
				newArgs[#newArgs + 1] = string.sub(text,2,#text - 1)

				waitClose = nil
			else
				waitCloseText = string.sub(text,2,#text)
			end

			continue
		end

		if waitClose then
			if string.sub(text,#text,#text) == "\"" then
				waitClose = nil

				newArgs[#newArgs + 1] = waitCloseText .. string.sub(text,1,#text - 1)
			else
				waitCloseText = waitCloseText .. string.sub(text,1,#text)
			end

			continue
		end

		newArgs[#newArgs + 1] = text
	end

	return newArgs
end

function COMMAND_Input(ply,args)
	local cmd = COMMANDS[args[1]]
	if not cmd then return false end
	if not COMMAND_ACCES(ply,cmd) then return true,false end

	table.remove(args,1)

	return true,cmd[1](ply,args)
end
-- Мдаааа А ПЛЕЙРСЕЙ ДЛЯ КОГО НУЖЕН????
hook.Add("HG_PlayerSay","commands-chat",function(ply, txtTbl, text)
	COMMAND_Input(ply, COMMAND_GETARGS(string.Split(string.sub(text, 2, #text), " ")))
end)

COMMANDS.help = {function(ply,args)
	local text = ""

	if args[1] then
		local cmd = COMMANDS[args[1]]
		local argsList = cmd[3]
		if argsList then argsList = " - " .. argsList else argsList = "" end

		text = text .. "	" .. args[1] .. argsList .. "\n"
	else
		local list = {}
		for name in pairs(COMMANDS) do list[#list + 1] = name end
		table.sort(list,function(a,b) return a > b end)
        
		for _,name in pairs(list) do
			local cmd = COMMANDS[name]
            if not COMMAND_ACCES(ply,cmd) then continue end
            
			local argsList = cmd[3]
			if argsList then argsList = " - " .. argsList else argsList = "" end
            
			text = text .. "	" .. name .. argsList .. "\n"
		end
	end

	text = string.sub(text,1,#text - 1)

	ply:ChatPrint(text)
end,0}

if SERVER then
    util.AddNetworkString("PunishLightningEffect")
    util.AddNetworkString("AnotherLightningEffect")
    util.AddNetworkString("PluvCommand")

    COMMANDS.god = {function(ply)
        if not ply.organism then return end
        
        ply.organism.godmode = true
    end,2}

    COMMANDS.ungod = {function(ply)
        if not ply.organism then return end
        
        ply.organism.godmode = nil
    end,2}

    COMMANDS.punish = {function(ply, args)
        if #args < 1 then
            ply:ChatPrint("Give me the name of this OwO .")
            return
        end

        local targetNickPartial = string.lower(args[1]) 
        local target = nil
        for _, player in player.Iterator() do
            if string.find(string.lower(player:Nick()), targetNickPartial) then 
                target = player
                break
            end
        end

        if not IsValid(target) then
            ply:ChatPrint("I don't see that OwO .")
            return
        end

        target = hg.GetCurrentCharacter(target)

        net.Start("AnotherLightningEffect")
        net.WriteEntity(target)
        net.Broadcast()

        net.Start("PunishLightningEffect")
        net.WriteEntity(target)
        net.Broadcast()

        target:EmitSound("snd_jack_hmcd_lightning.wav")

        local dmg = DamageInfo()
        dmg:SetDamage(1000)
        dmg:SetAttacker(ply)
        dmg:SetInflictor(ply)
        dmg:SetDamageType(DMG_SHOCK)
        target:TakeDamageInfo(dmg)

        ply:ChatPrint("Fatass " .. target:Nick() .. " has been punished.")
    end, 2, "ник игрока"}

    COMMANDS.pluv = {function(ply, args)
        net.Start("PluvCommand")
        net.Send(ply)
    end, 0}

    COMMANDS.notify = {function(ply, args)
        if #args < 2 then
            ply:ChatPrint("Usage: !notify <player> <message>")
            return
        end

        local targetNickPartial = string.lower(args[1]) 
        local target = nil
        for _, player in player.Iterator() do
            if string.find(string.lower(player:Nick()), targetNickPartial) then 
                target = player
                break
            end
        end

        if not IsValid(target) then
            ply:ChatPrint("Player not found: " .. args[1])
            return
        end
        
        table.remove(args, 1) 
        local message = table.concat(args, " ")
        
        if message == "" then
            ply:ChatPrint("Message cannot be empty!")
            return
        end
        
        target:Notify(message, 0)
        ply:ChatPrint("Sent notification to " .. target:GetName() .. ": " .. message)

    end, 2, "ник игрока сообщение"}

	COMMANDS.setmodel = {function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 1 and args[1] or ply:Name()
		local mdl = #args > 1 and args[2] or args[1]
		for i, ply2 in pairs(player.GetListByName(plya)) do
			if ply2:Alive() then
				local Appearance = ply2.CurAppearance or hg.Appearance.GetRandomAppearance()
				Appearance.AColthes = ""
				ply2:SetNetVar("Accessories", "")
				ply2:SetModel(mdl)
				ply2:SetSubMaterial()
				ply2:SetPlayerColor(ply2:GetNWVector("PlayerColor", vector_origin))

				ply:ChatPrint(ply2:Name().. "'s model set to " .. tostring(mdl))
			end
		end
	end, 0}
end