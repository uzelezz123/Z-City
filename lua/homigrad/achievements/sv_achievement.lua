hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}

local function updatePlayer(ply)
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    if not hg.achievements.SqlActive then
        hg.achievements.achievements_data.player_achievements[steamID64] = {}
        return
    end 

	local query = mysql:Select("hg_achievements")
		query:Select("achievements")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
            --print(result)
            --PrintTable(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].achievements) then
				local updateQuery = mysql:Update("hg_achievements")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

                hg.achievements.achievements_data.player_achievements[steamID64] = util.JSONToTable(result[1].achievements)

                --PrintTable(hg.achievements.achievements_data.player_achievements[steamID64])
			else
				local insertQuery = mysql:Insert("hg_achievements")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("achievements", util.TableToJSON({}))
				insertQuery:Execute()

				hg.achievements.achievements_data.player_achievements[steamID64] = {}
			end
		end)
	query:Execute()
end

hook.Add("DatabaseConnected", "AchievementsCreateData", function()
	local query

	query = mysql:Create("hg_achievements")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
        query:Create("achievements", "TEXT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    hg.achievements.SqlActive = true

    print("Achievements SQL database connected.")

    for i, ply in player.Iterator() do
        updatePlayer(ply)
    end
end)

hook.Add( "PlayerInitialSpawn","hg_Exp_OnInitSpawn", updatePlayer)
hook.Add("PlayerDisconnected", "savevalues", function(ply)
    if !hg.achievements.SqlActive then print("Tried to save achievement data to SQL, but it is not active.") return end
    
    hg.achievements.SaveToSQL(ply)
end)

function hg.achievements.SaveToSQL(ply, data)
    if not hg.achievements.SqlActive then return end

    local name = ply:Name()
	local steamID64 = ply:SteamID64()
    local updateQuery = mysql:Update("hg_achievements")
        updateQuery:Update("achievements", util.TableToJSON(data or hg.achievements.GetPlayerAchievements(ply) or {}) )
        updateQuery:Update("steam_name", name)
        updateQuery:Where("steamid", steamID64)
    updateQuery:Execute()
end

function hg.achievements.SavePlayerAchievements()
    if !hg.achievements.SqlActive then print("Tried to save achievement data to SQL, but it is not active.") return end

    for k, ply in player.Iterator() do
        hg.achievements.SaveToSQL(ply)
    end
end

local replacement_img = "homigrad/vgui/models/star.png"

function hg.achievements.CreateAchievementType(key, needed_value, start_value, description, name, img, showpercent)
    img = img or replacement_img
    hg.achievements.achievements_data.created_achevements[key] = {
        start_value = start_value,
        needed_value = needed_value,
        description = description,
        name = name,
        img = img,
        key = key,
        showpercent = showpercent,
    }
end


function hg.achievements.GetAchievements()
    return hg.achievements.achievements_data.created_achevements
end


function hg.achievements.GetAchievementInfo(key)
    return hg.achievements.achievements_data.created_achevements[key]
end


function hg.achievements.GetPlayerAchievements(ply)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID]
end


function hg.achievements.GetPlayerAchievement(ply, key)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID][key] or {}
end


local function isAchievementCompleted(ply, key, val)
    local ach = hg.achievements.achievements_data.created_achevements[key]
    return val >= ach.needed_value and (hg.achievements.achievements_data.player_achievements[ply:SteamID64()][key].value or 0) < val
end

util.AddNetworkString("hg_NewAchievement")

function hg.achievements.SetPlayerAchievement(ply, key, val)
    --print("Triggered achievement for player " .. ply:Name() .. " ; " .. ply:SteamID() .. ": " .. (key or "none") .. ", value " .. (val or "none"))
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    local playerAchievements = hg.achievements.achievements_data.player_achievements[steamID]
    playerAchievements[key] = playerAchievements[key] or {}

    if isAchievementCompleted(ply, key, val) then
        local ach = hg.achievements.achievements_data.created_achevements[key]
        net.Start("hg_NewAchievement")
            net.WriteString(ach.name)
            net.WriteString(ach.img)
        net.Send(ply)
    end

    playerAchievements[key].value = val
end

function hg.achievements.AddPlayerAchievement(ply, key, val)
    local ach = hg.achievements.GetPlayerAchievement(ply, key)
    local ach_info = hg.achievements.GetAchievementInfo(key)

    hg.achievements.SetPlayerAchievement(ply, key, math.Approach(ach.value or ach_info.start_value, ach_info.needed_value, val))
end

util.AddNetworkString("req_ach")

net.Receive("req_ach", function(len, ply)
    if (ply.ach_cooldown or 0) > CurTime() then return end
    ply.ach_cooldown = CurTime() + 2
    net.Start("req_ach")
        net.WriteTable(hg.achievements.GetAchievements())
        net.WriteTable(hg.achievements.GetPlayerAchievements(ply))
    net.Send(ply)
end)

//if !hg.init_ach then
    -- braindeath
    hg.achievements.CreateAchievementType("brain",1,0,"Die from hypoxia.","I will definitely survive...", nil, false)
    -- death from drugs
    hg.achievements.CreateAchievementType("drugs",1,0,"Die from opioids overdose.","Overstimulated", nil, false)
    -- TERMINATOR
    hg.achievements.CreateAchievementType("illbeback",3,0,"Get shot in the head and get up alive.","I'll be back", nil, true)
    -- kill everyone
    hg.achievements.CreateAchievementType("killemall",1,0,"Kill everyone being a traitor and win the round, players on the server should be more than 9.","Kill Em All", nil, false)
    -- russian roulette
    hg.achievements.CreateAchievementType("deadlygambling",10,0,"Survive 10 games of Russian roulette in one life.","Deadly Gambling", nil, true)
    -- lobotomized kill
    hg.achievements.CreateAchievementType("lobotomygaming",1,0,"Kill the traitor while having brain damage","Hydrogen bomb vs Lobotomized patient", nil, false)
    -- hot potato
    hg.achievements.CreateAchievementType("hotpotato",1,0,"Kill the traitor using his own grenade","Hot Potato", nil, false)
    -- please calm down
    hg.achievements.CreateAchievementType("bking", 1, 0, "Something terrible happened on that plane...", "Sir please calm down", nil, false)

    //hg.init_ach = true
//end

local roundply = 0

hook.Add("ZB_StartRound","hg_killemall_Acchivment",function()
    roundply = 0
    for k,v in player.Iterator() do
        roundply = roundply + 1
    end
end)

hook.Add("ZB_TraitorWinOrNot","hg_killemall_Acchivment",function(ply,winner)
    --if gmod.GetGamemode() ~= "zcity" then return end

    if winner == 1 and (ply.TraitorKills or 0 >= roundply - 1) and roundply >= 10 then
        hg.achievements.SetPlayerAchievement(ply,"killemall",1)
    end
end)

hook.Add("PlayerDeath", "hg_killemall_Acchivment", function(ply)
    local ach = hg.achievements.GetPlayerAchievement(ply,"deadlygambling")
    if ach["value"] ~= 10 and ach["value"] ~= 0 then
        hg.achievements.SetPlayerAchievement(ply, "deadlygambling", 0)
    end

    if ply.isTraitor then
        if IsValid(ply.ZBestAttacker) and ply != ply.ZBestAttacker then
            if ply.ZBestAttacker:Alive() and ply.ZBestAttacker.organism.brain >= 0.1 then
                hg.achievements.SetPlayerAchievement(ply.ZBestAttacker, "lobotomygaming", 1)
            end
            
            if IsValid(ply.ZBestInflictor) and ply.ZBestInflictor.ishggrenade and ply.ZBestInflictor.owner2 == ply and IsValid(ply.ZBestInflictor.owner) then
                hg.achievements.SetPlayerAchievement(ply.ZBestInflictor.owner, "hotpotato", 1)
            end
        end

        ply.TraitorKills = 0

        return
    end

    if IsValid(ply.ZBestAttacker) and ply.ZBestAttacker.isTraitor then
        ply.ZBestAttacker.TraitorKills = (ply.ZBestAttacker.TraitorKills or 0) + 1
    end
end)

hook.Add("PlayerSilentDeath","hg_illbeback_Acchivment",function(ply)
    if ply.isTraitor then ply.TraitorKills = 0 return end
end)

hook.Add("HomigradDamage","hg_illbeback_Acchivment",function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs)
    --if gmod.GetGamemode() ~= "zcity" then return end
    if not ply:IsPlayer() then return end
    if (dmgInfo:IsDamageType(128) or dmgInfo:IsDamageType(DMG_BULLET)) and hitgroup == HITGROUP_HEAD and hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",1)
        ply.illbeback = CurTime() + 10
    end
end)

hook.Add("HG_OnOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 1 and ply.illbeback > CurTime() then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",2)
    end
end)

hook.Add("PlayerDeath","hg_illbeback_Acchivment",function(ply)
    local val = hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"]
    if val ~= 3 and val ~= 0 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback", 0)
    end
end)

hook.Add("PlayerSilentDeath","hg_illbeback_Acchivment",function(ply)
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",0)
    end
end)

hook.Add("HG_OnWakeOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 2 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",3)
    end
end)

local tblToFind_bking = {
    {"sir","sir"},
    {"сэр","sir"},
    {"please","please"},
    {"пожалуйста","please"},
    {"calm down","calm down"},
	{"успокойтесь","calm down"}
}
hook.Add("HG_PlayerSay","burgerking",function(ply, txtTbl, txt)
    local bking = {
        ["sir"] = false,
        ["please"] = false,
        ["calm down"] = false
    }
    for _, v in ipairs(tblToFind_bking) do
        local found = string.find( txt:lower(), v[1] )
        --print(found)
        if found then
            bking[v[2]] = true
        end
    end

    if bking["sir"] and bking["please"] and bking["calm down"] then
        hg.achievements.SetPlayerAchievement(ply,"bking",1)
		ply:PS_AddItem("burger king crown")
    end
end)