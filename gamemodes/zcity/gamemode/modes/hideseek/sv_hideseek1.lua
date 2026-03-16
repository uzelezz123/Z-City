MODE = MODE or {}
MODE.name = "hideseek"
MODE.PrintName = "Hide and Seek"

MODE.ForBigMaps = false
MODE.ROUND_TIME = 480
MODE.LootSpawn = true

MODE.Chance = 0.03

function MODE:OverrideBalance()
    return true
end

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

function shuffle(tbl)
	local len = #tbl
	for i = len, 2, -1 do
	  local j = math.random(i)
	  tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

function MODE:AssignTeams()
    local players = player.GetAll()
    local numPlayers = #players

    shuffle(players)
    if numPlayers == 0 then return end

    local shooters = 1
    if numPlayers >= 30 then
        shooters = 6
    elseif numPlayers >= 25 then
        shooters = 5
    elseif numPlayers >= 20 then
        shooters = 4
    elseif numPlayers >= 15 then
        shooters = 3
    elseif numPlayers >= 10 then
        shooters = 2
    end

    self.ShooterIndex = {}

    local shooterCount = 0

    for i = 1, numPlayers do
        local ply = players[i]
        if not IsValid(ply) then continue end

        if shooterCount < shooters then
            shooterCount = shooterCount + 1
            ply:SetTeam(2)
            self.ShooterIndex[ply] = shooterCount
        else
            ply:SetTeam(1)
        end
    end
end

util.AddNetworkString("hns_start")
function MODE:Intermission()
    game.CleanUpMap()
    hg.UpdateRoundTime(self.ROUND_TIME)
    self:AssignTeams()

    for k, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_SPECTATOR or ply:Team() == 0 or ply:Team() == 2 then ply:KillSilent() continue end
        ply:SetupTeam(ply:Team())
    end

	net.Start("hns_start")
	net.Broadcast()

end

function MODE:CheckAlivePlayers()
    local swatPlayers = {}
    local victimPlayers = {}
    local shooterPlayers = {}

    for _, ply in ipairs(team.GetPlayers(0)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(swatPlayers, ply)
        end
    end

    for _, ply in ipairs(team.GetPlayers(1)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(victimPlayers, ply)
        end
    end

    for _, ply in ipairs(team.GetPlayers(2)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(shooterPlayers, ply)
        end
    end

    return {swatPlayers, victimPlayers, shooterPlayers}
end





function MODE:ShouldRoundEnd()
    if zb.ROUND_START + 61 > CurTime() then return false end
    local aliveTeams = self:CheckAlivePlayers()
    -- end the round once SWAT is present and shooter is gone
    if CurTime() >= (zb.ROUND_START + 240) and table.Count(aliveTeams[3]) == 0 then
        return true
    end
    local endround = zb:CheckWinner(aliveTeams)
    return endround
end



function MODE:RoundStart()
    
end

MODE.LootTable = {
	{100, {
		{10,"weapon_ducttape"},
		{10,"weapon_matches"},
		{10,"weapon_bigconsumable"},
		{10,"weapon_smallconsumable"},
		{8,"weapon_painkillers"},
		{8,"weapon_bandage_sh"},
		{5,"weapon_medkit_sh"},
		{3,"weapon_leadpipe"},
		{5,"weapon_pocketknife"},
		{5,"weapon_bat"},
		{5,"weapon_hammer"},
		{5,"weapon_hg_bottle"},
	}}
}

function MODE:CanLaunch()
    return true
end

function MODE:GiveEquipment()
    timer.Simple(0.5,function()
        self.SWATQueue = {}
        self.SWATQueueSet = {}

        for i, ply in ipairs(player.GetAll()) do
            if ply:Team() == TEAM_SPECTATOR then continue end

            if ply:Team() == 2 then
                timer.Create("ShooterSpawn"..ply:EntIndex(), 1, 1, function()
                    ply:Spawn()
                    ply:SetSuppressPickupNotices(true)
                    ply.noSound = true

                    ply:SetupTeam(ply:Team())
                    ply:SetPlayerClass("default")

                    zb.GiveRole(ply, "Seeker", Color(190,0,0))

                    hg.AddArmor(ply, {"ent_armor_vest4","ent_armor_helmet2"})

                    local inv = ply:GetNetVar("Inventory") or {}
                    inv["Weapons"] = inv["Weapons"] or {}
                    inv["Weapons"]["hg_sling"] = true
                    --inv["Weapons"]["hg_melee_belt"] = true
                    inv["Weapons"]["hg_flashlight"] = true
                    inv["Weapons"]["hg_brassknuckles"] = true
                    ply:SetNetVar("Inventory", inv)

                    local function giveWithReserve(class)
                        local wep = ply:Give(class)
                        if IsValid(wep) and wep.GetMaxClip1 and wep.GetPrimaryAmmoType and wep:GetMaxClip1() > 0 then
                            ply:GiveAmmo(wep:GetMaxClip1() * 2, wep:GetPrimaryAmmoType(), true)
                        end
                    end

                    local shooterIndex = math.random(1,6)
                        ply:SetNetVar("HNS_Schizo", false)
                        if math.random() <= 0.9 then
                            ply:SetNetVar("HNS_Schizo", true)
                        end

                    if shooterIndex == 1 then
                        giveWithReserve("weapon_ruger")
                        giveWithReserve("weapon_ab10")
						giveWithReserve("weapon_hg_pipebomb_tpik")
                    elseif shooterIndex == 2 then
                        giveWithReserve("weapon_m590a1")
                        giveWithReserve("weapon_glock26")
						giveWithReserve("weapon_hg_molotov_tpik")
                    elseif shooterIndex == 3 then
                        giveWithReserve("weapon_mini14")
                        giveWithReserve("weapon_tec9")
						ply:Give("weapon_adrenaline")
                    elseif shooterIndex == 4 then
                        giveWithReserve("weapon_akmwreked")
                        giveWithReserve("weapon_pl15")
                        giveWithReserve("weapon_mp-80")
						ply:Give("weapon_hg_pipebomb_tpik")
                    elseif shooterIndex == 5 then
                        giveWithReserve("weapon_ar15")
                        giveWithReserve("weapon_cz75")
						ply:Give("weapon_hg_jam")
						ply:SetNetVar("HNS_Schizo", true)
                    elseif shooterIndex == 6 then
                        giveWithReserve("weapon_m16a2")
                        giveWithReserve("weapon_m1911")
                        ply:Give("weapon_hg_type59_tpik")


                    else
                        giveWithReserve("weapon_ruger")
                        giveWithReserve("weapon_ab10")
						giveWithReserve("weapon_hg_pipebomb_tpik")
						ply:Give("weapon_hg_molotov_tpik")
                    end

                    ply:Give("weapon_buck200knife")
                    ply:Give("weapon_fentanyl")

                    ply:Give("weapon_hands_sh")

                    ply:SetSuppressPickupNotices(false)
                    ply.noSound = false
                end)
            else
                ply:SetSuppressPickupNotices(true)
                ply.noSound = true

                ply:SetPlayerClass("default")

                zb.GiveRole(ply, "Hider", Color(0,190,190))

                ply:Give("weapon_hands_sh")

                ply:SetSuppressPickupNotices(false)
                ply.noSound = false
            end

			timer.Simple(0.5,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end

        timer.Create("SWATArrival", 240, 1, function()
            for _, ply in ipairs(team.GetPlayers(2)) do
                if IsValid(ply) and ply:Alive() then
                    local pos = ply:GetPos()
                    sound.Play("c4explode.wav", pos, 140, 120, 1)
                    ParticleEffect("pcf_jack_groundsplode_medium", pos, Angle(0,0,0))
                    if hg and hg.ExplosionEffect then
                        hg.ExplosionEffect(pos, 500, 80)
                    end
                    util.BlastDamage(ply, ply, pos, 500, 1000)
                    ply:Kill()
                end
            end
            self.SWATQueue = {}
            self.SWATQueueSet = {}
        end)
    end)
end

function MODE:SpawnSWAT(ply)
    return
end

function MODE:RoundThink()
end

function MODE:GetTeamSpawn()
	return {zb:GetRandomSpawn()}, {zb:GetRandomSpawn()}
end

function MODE:CanSpawn()
end

util.AddNetworkString("hns_roundend")
function MODE:EndRound()
	for k,ply in player.Iterator() do
		if timer.Exists("SWATSpawn"..ply:EntIndex()) then
			timer.Remove("SWATSpawn"..ply:EntIndex())
		end
		if timer.Exists("ShooterSpawn"..ply:EntIndex()) then
			timer.Remove("ShooterSpawn"..ply:EntIndex())
		end
	end
	if timer.Exists("SWATSpawn") then
		timer.Remove("SWATSpawn")
	end
	if timer.Exists("SWATArrival") then
		timer.Remove("SWATArrival")
	end
	for _, ply in player.Iterator() do
    if IsValid(ply) then
        ply:SetNetVar("HNS_Schizo", false)
    end
end
    self.SWATQueue = {}
	self.SWATQueueSet = {}

    local aliveTeams = self:CheckAlivePlayers()
    local endround, winner = zb:CheckWinner(aliveTeams)
    -- force SWAT win if shooter is eliminated after SWAT arrival
    if CurTime() >= (zb.ROUND_START + 240) and table.Count(aliveTeams[3]) == 0 then
        endround = true
        winner = 0
    end

	timer.Simple(2,function()
		net.Start("hns_roundend")
			net.WriteBool(winner)
		net.Broadcast()
	end)

	for k,ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))
		else
			ply:GiveSkill(-math.Rand(0.05,0.1))
		end
	end
end

function MODE:PlayerDeath(_, ply)
end
