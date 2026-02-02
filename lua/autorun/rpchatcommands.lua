if engine.ActiveGamemode() == "sandbox" then
    if CLIENT then
        local commands = {
            ["/qa"] = function(msg, ply)
                return "¿ " .. msg .. " ? - "..ply:GetPlayerName() , Color(255, 160, 255) -- 
            end,
            ["/me"] = function(msg, ply)
                return ply:GetPlayerName().." " .. msg, Color(255, 255, 175) 
            end,
            ["/it"] = function(msg, ply)
                return msg .. " - " .. ply:GetPlayerName(), Color(140, 140, 200) 
            end,
            ["/try"] = function(msg, ply)
                return ply:GetPlayerName().. " Пытается " .. msg, Color(120, 200, 255) 
            end
        }

        hook.Add("HG_OnPlayerCommand", "RPChatcmd", function(ply, texta)
            local text = texta[1]
            local cmd = string.lower(string.Explode(" ", text)[1])
            local txt = string.Explode(" ", text)
            table.remove(txt,1)
            --print(cmd)
            if commands[cmd] then
                local message, color = commands[cmd](table.concat( txt, " " ), ply)
                chat.AddText( color, " "..message )
                return true
            end
        end)

    end
end
