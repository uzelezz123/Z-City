local MODE = MODE

MODE.KillMoney = 1000
MODE.StartMoney = 1000
MODE.start_time = 20

MODE.Rounds = 5

MODE.ROUND_TIME = 240

function MODE:DontKillPlayer(ply)
    return zb.RoundsLeft and (zb.RoundsLeft != self.Rounds)
end

function MODE:CanLaunch()
	local points = zb.GetMapPoints( "HMCD_TDM_T" )
	local points2 = zb.GetMapPoints( "HMCD_TDM_CT" )
	local points3 = zb.GetMapPoints( "BOMB_ZONE_A" )
	local points4 = zb.GetMapPoints( "BOMB_ZONE_B" )

    local points5 = zb.GetMapPoints( "HOSTAGE_DELIVERY_ZONE" )

    return (#points > 0) and (#points2 > 0) and (((#points3 > 1) or (#points4 > 1)) or (#points5 > 1))
end

function MODE:OverrideBalance()--return true to keep alive players
    return zb.RoundsLeft and (zb.RoundsLeft != self.Rounds)
end

function MODE:RoundStartPost()
    if zb.RoundsLeft and zb.RoundsLeft > 1 then
        NextRound(self.name)
    end
end

function MODE:Intermission()
	game.CleanUpMap()
    
    zb.RoundsLeft = zb.RoundsLeft or self.Rounds
    zb.Winners = zb.Winners or {}

    self.GameStarted = zb.RoundsLeft == self.Rounds
    zb.rtype = zb.rtype or "bomb"

    zb.hostagepoints = zb.GetMapPoints( "HOSTAGE_DELIVERY_ZONE" )

    if self.GameStarted then
        zb.Winners = {}
        zb.bombexploded = nil
        zb.bomb = nil
        --zb.rtype = zb.nextcsround or (math.random(2) == 1 and "bomb" or "hostage")
        zb.nextcsround = nil
    end
    
    zb.rtype = (#zb.GetMapPoints( "BOMB_ZONE_A" ) > 0 or #zb.GetMapPoints( "BOMB_ZONE_B" ) > 0) and "bomb" or (zb.hostagepoints and #zb.hostagepoints > 0) and "hostage"

    zb.SendSpecificPointsToPly(nil, "BOMB_ZONE_A", false)
    zb.SendSpecificPointsToPly(nil, "BOMB_ZONE_B", false)
    zb.SendSpecificPointsToPly(nil, "HOSTAGE_DELIVERY_ZONE", false)

	self.CTPoints = {}
	self.TPoints = {}
	table.CopyFromTo( zb.GetMapPoints( "HMCD_TDM_T" ), self.TPoints)
	table.CopyFromTo( zb.GetMapPoints( "HMCD_TDM_CT" ), self.CTPoints)

	for i, ply in player.Iterator() do
		ply:SetupTeam(ply:Team())
        
        if self.GameStarted then
            ply:SetNWInt( "TDM_Money", self.StartMoney )
        end
	end

    if zb.rtype == "bomb" then
        timer.Simple(3,function()
            local team_t = team.GetPlayers(0)
            local ply = team_t[math.random(#team_t)]
            
            local ent = ents.Create("bomb")
            ent:SetPos(ply:EyePos())
            ent:Spawn()

            zb.bomb = ent
            ent.tbl = self
        end)
    elseif zb.rtype == "hostage" then
        timer.Simple(3,function()
            local ent = ents.Create("prop_ragdoll")
            local team_t = team.GetPlayers(0)
            local ply = team_t[math.random(#team_t)]
			--ent:SetModel("models/humans/group01/"..(math.random(2) == 1 and "fe" or "").."male_0"..math.random(9)..".mdl")
            //ApplyAppearance(ent,nil,nil,nil,true)
            ent:SetModel("models/player/hostage/hostage_0"..math.random(4)..".mdl")
            ent:SetPos(ply:GetPos())
            ent:Spawn()
            ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            hg.organism.Add(ent)
            hg.organism.Clear(ent.organism)
            ent.organism.fakePlayer = true

            zb.hostage = ent

            timer.Simple(1, function()
                hg.handcuff(ent)
            end)
        end)
    end

    PrintMessage(HUD_PRINTTALK, "Round "..(self.Rounds + 1 - zb.RoundsLeft).." out of "..(self.Rounds)..".")

	net.Start("tdm_start")
        net.WriteString(zb.rtype)
	net.Broadcast()

    self.GameStarted = nil
end

concommand.Add("tdm_setrounds", function(ply, cmd, args)
    if not ply:IsAdmin() then return end--idiot
	if not args[1] then return end
	local oldRounds = MODE.Rounds
    local oldLeft = zb.RoundsLeft or oldRounds
    local played = oldRounds - oldLeft
    MODE.Rounds = math.max(tonumber(args[1]) or oldRounds, 1)
    zb.RoundsLeft = math.max(MODE.Rounds - played, 0)
    PrintMessage(HUD_PRINTTALK, "TDM rounds set to "..(MODE.Rounds)..". Rounds left: "..zb.RoundsLeft)
end)

COMMANDS.nextcsround = {
	function(ply, args)
		if not ply:IsAdmin() then ply:ChatPrint("You don't have access") return end
		if string.lower(args[1]) == "bomb" then
            zb.nextcsround = "bomb"
        end

        if string.lower(args[1]) == "hostage" then
            zb.nextcsround = "hostage"
        end
	end,
	0
}


function MODE:EndRound()
    zb.RoundsLeft = zb.RoundsLeft or self.Rounds
    zb.Winners = zb.Winners or {}

	timer.Simple(2,function()
		net.Start("tdm_roundend")
		net.Broadcast()
	end)

    local winner = 3

	local tbl = zb:CheckAliveTeams(true)

    if zb.rtype == "bomb" then
        if not IsValid(zb.bomb) then
            winner = 1
        end

        if zb.bombexploded then
            winner = 0
            zb.bombexploded = nil
        else
            winner = 1
        end

        if IsValid(zb.bomb) and #tbl[0] == 0 and not zb.bomb.active then
            winner = 1
        end

        if IsValid(zb.bomb) and #tbl[1] == 0 and #tbl[0] > 0 then
            winner = 0
        end

        if IsValid(zb.bomb) and #tbl[1] == 0 and #tbl[0] == 0 and zb.bomb.active then
            winner = 0
        end

        if IsValid(zb.bomb) and #tbl[0] == 0 and #tbl[1] == 0 and not zb.bomb.active then
            winner = 1
        end
    elseif zb.rtype == "hostage" then
        if not IsValid(zb.hostage) then
            winner = 3

            if IsValid(zb.hostageLastTouched) then
                winner = zb.hostageLastTouched:Team() == 0 and 1 or 0
            end
        end
        
        if IsValid(zb.hostage) and not zb.hostage.organism.alive then
            local max, maxTeam = 0
            if zb.HarmDoneDetailed[zb.hostage] then
                for steamid, tbl in pairs(zb.HarmDone[zb.hostage]) do
                    if tbl.harm > max then
                        max = tbl.harm
                        maxTeam = tbl.teamAttacker
                    end
                end
                
                winner = maxTeam == 0 and 1 or 0

                PrintMessage(HUD_PRINTTALK, (maxTeam == 0 and "Terrorists" or "Counter-Terrorists") .. " killed the hostage")
            else
                winner = 3
            end
        end

        if IsValid(zb.hostage) and zb.hostage.organism.alive then
            winner = #tbl[0] == 0 and 1 or 0
        end

        if IsValid(zb.hostage) and zb.hostage.organism.alive and HostageInZone(zb.hostage:GetPos()) then
            zb.hostage:Remove()
            winner = 1
        end
    end

    local winnerprt = (winner == 1 and "Counter-Terrorists") or (winner == 0 and "Terrorists") or "Nobody"
    
    PrintMessage(HUD_PRINTTALK, winnerprt.." have won the round.")

	for k,ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))

            ply:SetNWInt( "TDM_Money", math.max(ply:GetNWInt( "TDM_Money" ) + 2500, 0) )
		else
			ply:GiveSkill(-math.Rand(0.05,0.1))
            
            ply:SetNWInt( "TDM_Money", math.max(ply:GetNWInt( "TDM_Money" ) + 1750, 0) )
		end
	end

	local winsTeam0 = zb.Winners[0] or 0
	local winsTeam1 = zb.Winners[1] or 0
	if winsTeam0 > winsTeam1 then
		for _, ply in ipairs(team.GetPlayers(1)) do
			ply:SetNWInt("TDM_Money", math.max(ply:GetNWInt("TDM_Money") + 1000, 0))
			ply:ChatPrint("You have received a compensation of 1000 money because your team is losing.")
		end
	elseif winsTeam1 > winsTeam0 then
		for _, ply in ipairs(team.GetPlayers(0)) do
			ply:SetNWInt("TDM_Money", math.max(ply:GetNWInt("TDM_Money") + 1000, 0))
			ply:ChatPrint("You have received a compensation of 1000 money because your team is losing.")
		end
	end

    
    if zb.nextround != self.name then
        zb.Winners = {}
        zb.bombexploded = nil
        zb.bomb = nil
        zb.rtype = nil
        zb.nextcsround = nil
        zb.RoundsLeft = nil

        return
    end

    if zb.RoundsLeft > 0 then
        zb.RoundsLeft = zb.RoundsLeft - 1
        
        zb.Winners[winner] = (zb.Winners[winner] or 0) + 1
    else
        local winner
        local min = 0
        for team_, roundswon in pairs(zb.Winners) do
            if roundswon > min then
                winner = team_
                min = roundswon
            end
        end

        if winner then
            local winnerprt = (winner == 1 and "Counter-Terrorists") or (winner == 0 and "Terrorists") or "Nobody"
            
            PrintMessage(HUD_PRINTTALK, winnerprt.." have won the game.")
        end

        zb.RoundsLeft = nil
    end
end

function HostageInZone(pos)
	local pts = zb.hostagepoints

	local vec1
	local vec2
	local vec3
	local vec4

	if #pts >= 2 then
		vec1 = -(-pts[1].pos)
		vec1[3] = vec1[3] - 256
		vec2 = -(-pts[2].pos)
		vec2[3] = vec2[3] + 256
	end

    if #pts >= 4 then
        vec3 = -(-pts[3].pos)
		vec3[3] = vec3[3] - 256
		vec4 = -(-pts[4].pos)
		vec4[3] = vec4[3] + 256
    end
    
	return (#pts >= 2 and pos:WithinAABox(vec1,vec2)) or (#pts >= 4 and pos:WithinAABox(vec3,vec4))
end

function MODE:ShouldRoundEnd()
    if zb.ROUND_START + 5 > CurTime() then return false end

	local tbl = zb:CheckAliveTeams(true)
    
    if zb.rtype == "bomb" then
        if zb.bombexploded then
            return true
        end
        
        if not IsValid(zb.bomb) then
            return true
        end

        if #tbl[0] == 0 and not zb.bomb.active then
            return true
        end

        if #tbl[1] == 0 and #tbl[0] > 0 then
            return true
        end

        if #tbl[1] == 0 and #tbl[0] == 0 and zb.bomb.active then
            return true
        end
        
        if #tbl[0] == 0 and #tbl[1] == 0 and not zb.bomb.active then
            return true
        end
    elseif zb.rtype == "hostage" then
        if not IsValid(zb.hostage) then
            return true
        end

        if #tbl[0] == 0 or #tbl[1] == 0 or not zb.hostage.organism.alive then
            return true
        end
        
        if zb.hostage.organism.alive and HostageInZone(zb.hostage:GetPos()) then
            return true
        end
    end
end

function MODE:RoundThink()
end

hook.Add("HarmDone", "MoneyGive", function(ply, victim, amt) 
    if not CurrentRound().KillMoney then return end
    if not victim:IsPlayer() then return end
    if ply == victim then return end
    
    local add = amt * MODE.KillMoney * (ply:Team() == victim:Team() and -1 or 1)
    
    add = math.Round(add,0)

    --print(add,ply,ply:GetNWInt("TDM_Money"),victim)

    ply:SetNWInt( "TDM_Money", math.max(ply:GetNWInt( "TDM_Money" ) + add, 0) )

    if (ply:Team() == victim:Team()) and add <= 0 then
        victim:SetNWInt( "TDM_Money", math.max(victim:GetNWInt( "TDM_Money" ) - add, 0) )
    end
end)