CRIMXP = CRIMXP or {}

local Config = CRIMXP.Config
local IsValid = IsValid
local CurTime = CurTime

sql.Query([[CREATE TABLE IF NOT EXISTS hg_crimxp (
	steamid VARCHAR(32) NOT NULL PRIMARY KEY,
	name TEXT DEFAULT '',
	xp INTEGER NOT NULL DEFAULT 0,
	kills INTEGER NOT NULL DEFAULT 0,
	deaths INTEGER NOT NULL DEFAULT 0,
	beststreak INTEGER NOT NULL DEFAULT 0,
	fracture INTEGER NOT NULL DEFAULT 0
);]])

local columns = sql.Query("PRAGMA table_info(hg_crimxp);")
if columns then
	local has = {}
	for _, col in ipairs(columns) do
		has[col.name] = true
	end

	if not has.fracture then
		sql.Query("ALTER TABLE hg_crimxp ADD COLUMN fracture INTEGER NOT NULL DEFAULT 0;")
	end

	if not has.name then
		sql.Query("ALTER TABLE hg_crimxp ADD COLUMN name TEXT DEFAULT '';")
	end
end

CRIMXP.Data = CRIMXP.Data or {}

local track = {}
CRIMXP.track = track

local function keyOf(ply)
	if ply:IsBot() then return "BOT_" .. ply:EntIndex() end
	return ply:SteamID64()
end

local function NameOf(ply)
	local name = ply.GetNWString and ply:GetNWString("PlayerName", "") or ""
	if name ~= "" then return name end

	return ply:Nick()
end

local function WeaponNameOf(wep)
	if not IsValid(wep) then return end

	return (wep.GetPrintName and wep:GetPrintName()) or string.NiceName(wep:GetClass())
end

local function blankData()
	return {xp = 0, kills = 0, deaths = 0, streak = 0, beststreak = 0, fracture = 0}
end

local function LoadRow(ply)
	local key = keyOf(ply)

	if ply:IsBot() then return blankData() end

	local row = sql.QueryRow("SELECT xp, kills, deaths, beststreak, fracture FROM hg_crimxp WHERE steamid = " .. sql.SQLStr(key) .. ";")
	if row then
		return {
			xp = math.max(tonumber(row.xp) or 0, 0),
			kills = math.max(tonumber(row.kills) or 0, 0),
			deaths = math.max(tonumber(row.deaths) or 0, 0),
			streak = 0,
			beststreak = math.max(tonumber(row.beststreak) or 0, 0),
			fracture = math.max(tonumber(row.fracture) or 0, 0),
		}
	end

	sql.Query("INSERT OR IGNORE INTO hg_crimxp (steamid, name, xp, kills, deaths, beststreak, fracture) VALUES (" .. sql.SQLStr(key) .. ", " .. sql.SQLStr(NameOf(ply)) .. ", 0, 0, 0, 0, 0);")
	return blankData()
end

local function SaveRow(ply)
	if ply:IsBot() then return end
	local key = keyOf(ply)
	local data = CRIMXP.Data[key]
	if not data then return end

	sql.Query("UPDATE hg_crimxp SET name = " .. sql.SQLStr(NameOf(ply)) .. ", xp = " .. data.xp .. ", kills = " .. data.kills .. ", deaths = " .. data.deaths .. ", beststreak = " .. data.beststreak .. ", fracture = " .. (data.fracture or 0) .. " WHERE steamid = " .. sql.SQLStr(key) .. ";")
end

function CRIMXP.GetData(ply)
	local key = keyOf(ply)
	if not CRIMXP.Data[key] then
		CRIMXP.Data[key] = LoadRow(ply)
	end
	return CRIMXP.Data[key]
end

function CRIMXP.Sync(ply)
	local data = CRIMXP.GetData(ply)
	local level, into, need = CRIMXP.LevelForXP(data.xp)

	ply:SetNWInt("hg_crime_level", level)
	ply:SetNWInt("hg_crime_xp", data.xp)
	ply:SetNWInt("hg_crime_xp_into", into)
	ply:SetNWInt("hg_crime_xp_need", need)
	ply:SetNWInt("hg_crime_kills", data.kills)
	ply:SetNWInt("hg_crime_deaths", data.deaths)
	ply:SetNWInt("hg_crime_streak", data.streak)
	ply:SetNWInt("hg_crime_beststreak", data.beststreak)
	ply:SetNWInt("hg_crime_fracture", data.fracture or 0)
end

for _, name in pairs(CRIMXP.Net) do util.AddNetworkString(name) end

function CRIMXP.GiveFracture(ply, amount)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	amount = math.floor(amount or 0)
	if amount == 0 then return end

	local data = CRIMXP.GetData(ply)
	data.fracture = math.max((data.fracture or 0) + amount, 0)
	SaveRow(ply)
	CRIMXP.Sync(ply)

	hook.Run("HG_CrimXPFractureGained", ply, amount, data.fracture)

	return data.fracture
end

function CRIMXP.GiveXP(ply, amount, silent)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not amount or amount == 0 then return end

	local data = CRIMXP.GetData(ply)
	local oldLevel = CRIMXP.LevelForXP(data.xp)

	data.xp = math.max(data.xp + math.floor(amount), 0)
	SaveRow(ply)
	CRIMXP.Sync(ply)

	local newLevel = CRIMXP.LevelForXP(data.xp)

	local levelUpFracture = 0

	if newLevel > oldLevel then
		local levelsGained = newLevel - oldLevel
		levelUpFracture = math.floor((Config.FractureLevelUpBonus or 0) * levelsGained)

		if levelUpFracture > 0 then CRIMXP.GiveFracture(ply, levelUpFracture) end
	end

	if newLevel > oldLevel and not silent then
		local rankName, rankColor = CRIMXP.GetRank(newLevel)

		net.Start(CRIMXP.Net.LevelUp)
			net.WriteUInt(newLevel, 16)
			net.WriteString(rankName)
			net.WriteColor(rankColor)
			net.WriteUInt(math.max(levelUpFracture, 0), 32)
		net.Send(ply)

		ply:ChatPrint("[XP] Level up! You are now level " .. newLevel .. " (" .. rankName .. ")")
	elseif newLevel < oldLevel then
		ply:ChatPrint("[XP] You are now level " .. newLevel)
	end

	hook.Run("HG_CrimXPGained", ply, amount, data.xp)
end

hook.Add("PlayerInitialSpawn", "hg_crimxp_load", function(ply)
	CRIMXP.GetData(ply)
	CRIMXP.Sync(ply)

	if not ply:IsBot() then
		local data = CRIMXP.GetData(ply)
		local level = CRIMXP.LevelForXP(data.xp)
		local rankName = CRIMXP.GetRank(level)

		if data.xp <= 0 then
			ply:ChatPrint("[XP] Criminal record created. Earn XP by killing players. Type !xp to view your record.")
		else
			ply:ChatPrint("[XP] Welcome back, " .. rankName .. ". You are level " .. level .. " with " .. data.xp .. " XP.")
		end
	end
end)

hook.Add("PlayerDisconnected", "hg_crimxp_save", function(ply)
	track[ply] = nil

	local key = keyOf(ply)
	if CRIMXP.Data[key] then
		SaveRow(ply)
		CRIMXP.Data[key] = nil
	end
end)

hook.Add("PlayerSpawn", "hg_crimxp_reset", function(ply)
	track[ply] = nil
end)

hook.Add("PlayerSilentDeath", "hg_crimxp_reset", function(ply)
	track[ply] = nil
end)

hook.Add("ShutDown", "hg_crimxp_shutdown", function()
	for _, ply in player.Iterator() do
		SaveRow(ply)
	end
end)

local function ResolveAttacker(ent)
	if not IsValid(ent) then return end
	if ent:IsRagdoll() then ent = hg.RagdollOwner(ent) end
	if IsValid(ent) and ent:IsPlayer() then return ent end
end

local function WriteAppearance(ply)
	net.WriteString(ply:GetModel() or "")

	local skin = ply:GetSkin() or 0
	net.WriteUInt(math.Clamp(skin, 0, 255), 8)

	local bodygroups = {}
	local groups = ply:GetBodyGroups()
	for i = 1, #groups do
		local bg = groups[i]
		bodygroups[#bodygroups + 1] = {bg.id, ply:GetBodygroup(bg.id)}
	end
	net.WriteTable(bodygroups)

	local submats = {}
	local mats = ply:GetMaterials()
	for i = 1, #mats do
		local mat = ply:GetSubMaterial(i - 1)
		if mat and mat ~= "" then
			submats[#submats + 1] = {i - 1, mat}
		end
	end
	net.WriteTable(submats)
end

hook.Add("HomigradDamage", "hg_crimxp_track", function(victim, dmgInfo, hitgroup, ent, harm)
	if not IsValid(victim) then return end
	if victim:IsRagdoll() then victim = hg.RagdollOwner(victim) end
	if not IsValid(victim) or not victim:IsPlayer() then return end

	local attacker = ResolveAttacker(dmgInfo:GetAttacker())
	if not attacker then return end

	harm = harm or 0

	local t = track[victim]
	if not t then
		t = {}
		track[victim] = t
	end

	local rec = t[attacker]
	if not rec then
		rec = {harm = 0, head = 0, melee = false, dist = 0, time = 0}
		t[attacker] = rec
	end

	rec.harm = rec.harm + harm
	rec.time = CurTime()

	if hitgroup == HITGROUP_HEAD then rec.head = rec.head + harm end

	local inflictor = dmgInfo:GetInflictor()
	if dmgInfo:IsDamageType(DMG_CLUB) or (IsValid(inflictor) and (inflictor.ismelee or inflictor.ismelee2)) then
		rec.melee = true
	end

	local wep = IsValid(inflictor) and inflictor:IsWeapon() and inflictor
	if not IsValid(wep) then
		local aw = attacker:GetActiveWeapon()
		if IsValid(aw) then wep = aw end
	end

	local wepName = WeaponNameOf(wep)
	if wepName then rec.weaponName = wepName end

	if IsValid(attacker) and victim:GetShootPos() then
		rec.dist = attacker:GetShootPos():DistToSqr(victim:GetShootPos())
	end
end)

hook.Add("PlayerDeath", "hg_crimxp_kill", function(victim, inflictor, attacker)
	if not IsValid(victim) or not victim:IsPlayer() then return end

	local t = track[victim]
	track[victim] = nil

	local data = CRIMXP.GetData(victim)
	data.deaths = data.deaths + 1
	data.streak = 0
	SaveRow(victim)
	CRIMXP.Sync(victim)

	local killer, killerRec

	if t then
		for atk, rec in pairs(t) do
			if IsValid(atk) and atk ~= victim and rec.harm > (killerRec and killerRec.harm or 0) then
				killer, killerRec = atk, rec
			end
		end
	end

	if not IsValid(killer) then
		killer = ResolveAttacker(attacker)
		if killer == victim then killer = nil end
	end

	if not IsValid(killer) then
		net.Start(CRIMXP.Net.Death)
			net.WriteString("")
			net.WriteUInt(0, 16)
			net.WriteString("")
			net.WriteColor(Color(255, 255, 255))
			net.WriteString("")
			net.WriteUInt(0, 16)
		net.Send(victim)
		return
	end

	local kData = CRIMXP.GetData(killer)
	kData.kills = kData.kills + 1
	kData.streak = (kData.streak or 0) + 1
	if kData.streak > (kData.beststreak or 0) then kData.beststreak = kData.streak end

	local kLevel = CRIMXP.LevelForXP(kData.xp)
	local vLevel = CRIMXP.LevelForXP(data.xp)
	local victimName = NameOf(victim)
	local killerName = NameOf(killer)
	local vRankName, vRankColor = CRIMXP.GetRank(vLevel)

	local xp = Config.BaseKillXP
	local breakdown = {}

	local function addXP(label, amount)
		if amount <= 0 then return end
		xp = xp + amount
		breakdown[#breakdown + 1] = {label, amount}
	end

	local scale = 1 + math.Clamp((vLevel - kLevel) * Config.VictimLevelScale, -Config.VictimLevelScaleCap, Config.VictimLevelScaleCap)
	if scale ~= 1 then
		addXP("TARGET LEVEL", math.Round(Config.BaseKillXP * (scale - 1)))
	end

	if killerRec then
		if killerRec.head > killerRec.harm * 0.2 then addXP("HEADSHOT", Config.HeadshotBonus) end
		if killerRec.melee then addXP("MELEE KILL", Config.MeleeBonus) end
		if killerRec.dist > Config.LongshotDist * Config.LongshotDist then addXP("LONGSHOT", Config.LongshotBonus) end
	end

	local now = CurTime()

	if killer.CrimXPLastKill and now - killer.CrimXPLastKill <= Config.MultikillWindow then
		killer.CrimXPChain = (killer.CrimXPChain or 0) + 1
	else
		killer.CrimXPChain = 1
	end

	killer.CrimXPLastKill = now

	local chain = killer.CrimXPChain

	if chain >= 2 then
		local bonusIdx = math.min(chain - 1, #Config.MultikillBonus)
		addXP("KILL BONUS", Config.MultikillBonus[bonusIdx])
	end

	if kData.streak > 0 and kData.streak % Config.StreakEvery == 0 then
		addXP(kData.streak .. " KILL STREAK", Config.StreakBonus)
	end

	if victim:IsBot() then
		xp = math.Round(xp * Config.BotKillXP)
	end

	local fracture = Config.FractureBaseKill

	if killerRec then
		if killerRec.head > killerRec.harm * 0.2 then fracture = fracture + Config.FractureHeadshot end
		if killerRec.melee then fracture = fracture + Config.FractureMelee end
		if killerRec.dist > Config.LongshotDist * Config.LongshotDist then fracture = fracture + Config.FractureLongshot end
	end

	if chain >= 2 then
		local fmIdx = math.min(chain - 1, #Config.FractureMultikillBonus)
		fracture = fracture + Config.FractureMultikillBonus[fmIdx]
	end

	if kData.streak > 0 and kData.streak % Config.StreakEvery == 0 then
		fracture = fracture + Config.FractureStreakBonus
	end

	if victim:IsBot() then
		fracture = math.Round(fracture * Config.FractureBotKill)
	end

	SaveRow(killer)
	CRIMXP.Sync(killer)

	CRIMXP.GiveXP(killer, xp)
	CRIMXP.GiveFracture(killer, fracture)

	if t and killerRec then
		for atk, rec in pairs(t) do
			if IsValid(atk) and atk ~= killer and atk ~= victim and rec.harm >= killerRec.harm * Config.AssistFraction then
				CRIMXP.GiveXP(atk, Config.AssistXP)
				CRIMXP.GiveFracture(atk, Config.FractureAssist)

				net.Start(CRIMXP.Net.Assist)
					net.WriteString(victimName)
					net.WriteUInt(Config.AssistXP, 16)
				net.Send(atk)

				atk:ChatPrint("[XP] Assist on " .. victimName .. " (+" .. Config.AssistXP .. " XP)")
			end
		end
	end

	net.Start(CRIMXP.Net.Kill)
		net.WriteString(victimName)
		net.WriteUInt(vLevel, 16)
		net.WriteUInt(xp, 17)
		net.WriteTable(breakdown)
		net.WriteUInt(kData.streak, 16)
		net.WriteUInt(chain, 8)
		net.WriteUInt(kData.kills, 32)
		net.WriteString(vRankName)
		net.WriteColor(vRankColor)
		WriteAppearance(victim)
		net.WriteUInt(math.max(fracture, 0), 32)
	net.Send(killer)

	local rankName, rankColor = CRIMXP.GetRank(kLevel)

	local weaponName = (killerRec and killerRec.weaponName) or "Unknown"

	if weaponName == "Unknown" then
		local inf = IsValid(inflictor) and inflictor or nil
		if IsValid(inf) and inf:IsWeapon() then
			weaponName = WeaponNameOf(inf) or "Unknown"
		else
			local aw = (IsValid(attacker) and attacker.GetActiveWeapon and attacker:GetActiveWeapon()) or (IsValid(killer) and killer:GetActiveWeapon())
			if IsValid(aw) then
				weaponName = WeaponNameOf(aw) or "Unknown"
			elseif IsValid(inf) then
				weaponName = string.NiceName(inf:GetClass())
			end
		end
	end

	local distMeters = 0
	if IsValid(killer) and IsValid(victim) then
		distMeters = math.Round(killer:GetPos():Distance(victim:GetPos()) / 39.37)
	end

	net.Start(CRIMXP.Net.Death)
		net.WriteString(killerName)
		net.WriteUInt(kLevel, 16)
		net.WriteString(rankName)
		net.WriteColor(rankColor)
		net.WriteString(weaponName or "Unknown")
		net.WriteUInt(math.Clamp(distMeters, 0, 65535), 16)
	net.Send(victim)

	killer:AddFrags(1)
	victim:AddDeaths(1)

	killer:ChatPrint("[XP] You killed " .. victimName .. " (+" .. xp .. " XP)")
	victim:ChatPrint("[XP] You were killed by " .. killerName .. " (Level " .. kLevel .. " " .. rankName .. ")")

	hook.Run("HG_CrimXPKill", killer, victim, xp)
end)

hook.Add("HG_PlayerSay", "hg_crimxp_chat", function(ply, txtTbl, txt)
	local cmd = string.Trim(string.lower(txt or ""))

	if cmd == "!xp" or cmd == "!stats" or cmd == "!level" or cmd == "!rank" then
		if istable(txtTbl) then txtTbl[1] = "" end
		ply:ConCommand("hg_xp")
	end
end)

local function FindPlayerByRef(ref)
	if not isstring(ref) or ref == "" then return end

	ref = string.lower(ref)
	local found

	for _, ply in player.Iterator() do
		local name = string.lower(NameOf(ply))
		local nick = string.lower(ply:Nick())

		if name == ref or nick == ref then
			return ply
		elseif not found and (string.find(name, ref, 1, true) or string.find(nick, ref, 1, true)) then
			found = ply
		end
	end

	return found
end

local function IsAdmin(ply)
	return not IsValid(ply) or ply:IsAdmin() or ply:IsSuperAdmin()
end

local function AdminTarget(ply, arg, silent)
	if not IsAdmin(ply) then return end

	local target = FindPlayerByRef(arg)
	if not IsValid(target) then
		if IsValid(ply) then ply:ChatPrint("[XP] Player not found.") end
		return
	end

	return target
end

concommand.Add("hg_xp_give", function(ply, cmd, args)
	local target = AdminTarget(ply, args[1])
	if not target then return end

	local amount = tonumber(args[2] or "")
	if not amount then
		if IsValid(ply) then ply:ChatPrint("[XP] Usage: hg_xp_give <player> <amount>") end
		return
	end

	CRIMXP.GiveXP(target, math.floor(amount))

	local msg = "[XP] Gave " .. amount .. " XP to " .. NameOf(target)
	if IsValid(ply) then ply:ChatPrint(msg) end
	print(msg)
end, nil, "Give XP to a player (admin)")

concommand.Add("hg_xp_setxp", function(ply, cmd, args)
	local target = AdminTarget(ply, args[1])
	if not target then return end

	local amount = tonumber(args[2] or "")
	if not amount or amount < 0 then
		if IsValid(ply) then ply:ChatPrint("[XP] Usage: hg_xp_setxp <player> <xp>") end
		return
	end

	local data = CRIMXP.GetData(target)
	data.xp = math.floor(amount)
	SaveRow(target)
	CRIMXP.Sync(target)
	target:ChatPrint("[XP] Your XP was set to " .. data.xp .. " by an admin")

	local msg = "[XP] Set " .. NameOf(target) .. "'s XP to " .. data.xp
	if IsValid(ply) then ply:ChatPrint(msg) end
	print(msg)
end)

concommand.Add("hg_xp_reset", function(ply, cmd, args)
	local target = AdminTarget(ply, args[1])
	if not target then return end

	local data = CRIMXP.GetData(target)
	data.xp = 0
	data.kills = 0
	data.deaths = 0
	data.streak = 0
	data.beststreak = 0
	data.fracture = 0
	SaveRow(target)
	CRIMXP.Sync(target)
	target:ChatPrint("[XP] Your criminal record was wiped by an admin")

	local msg = "[XP] Reset " .. NameOf(target) .. "'s record"
	if IsValid(ply) then ply:ChatPrint(msg) end
	print(msg)
end)

concommand.Add("hg_xp_stats", function(ply, cmd, args)
	local target = ply

	if args[1] and IsValid(ply) and ply:IsAdmin() then
		target = FindPlayerByRef(args[1]) or ply
	end

	if not IsValid(target) then return end

	local data = CRIMXP.GetData(target)
	local level, into, need = CRIMXP.LevelForXP(data.xp)
	local rankName = CRIMXP.GetRank(level)

	local lines = {
		"[XP] " .. NameOf(target) .. " - Level " .. level .. " " .. rankName,
		"[XP] XP: " .. data.xp .. " (" .. into .. "/" .. (need > 0 and need or "MAX") .. ")",
		"[XP] Kills: " .. data.kills .. " | Deaths: " .. data.deaths .. " | K/D: " .. string.format("%.2f", data.kills / math.max(data.deaths, 1)),
		"[XP] Streak: " .. data.streak .. " | Best streak: " .. data.beststreak,
		"[XP] Fracture$: " .. (data.fracture or 0),
	}

	for _, line in ipairs(lines) do
		if IsValid(ply) then ply:ChatPrint(line) else print(line) end
	end
end)

util.AddNetworkString("HG_CrimXPAdminRequest")
util.AddNetworkString("HG_CrimXPAdminSend")
util.AddNetworkString("HG_CrimXPAdminSave")
util.AddNetworkString("HG_CrimXPAdminSaveResult")

local ADMIN_CHUNK = 15
local ADMIN_MAX_STAT = 2147483647

local function adminNumber(value, fallback, whole, minimum)
	if isstring(value) then value = value:gsub(",", ""):gsub("%s+", "") end

	local number = tonumber(value)
	if number == nil then number = tonumber(fallback) or 0 end
	if whole then number = math.floor(number) end
	if minimum then number = math.max(number, minimum) end

	return number
end

local function findOnlineBySteamID(steamid)
	for _, ply in player.Iterator() do
		if not ply:IsBot() and ply:SteamID64() == steamid then return ply end
	end
end

local function buildAdminRows()
	local rows = {}
	local seen = {}
	local stored = sql.Query("SELECT steamid, name, xp, kills, deaths, beststreak, fracture FROM hg_crimxp;") or {}
	local storedByID = {}

	for _, row in ipairs(stored) do
		storedByID[tostring(row.steamid)] = row
	end

	for _, ply in player.Iterator() do
		if not ply:IsBot() then
			local steamid = ply:SteamID64()
			local data = CRIMXP.GetData(ply)

			seen[steamid] = true
			rows[#rows + 1] = {
				steamid = steamid,
				name = NameOf(ply),
				active = true,
				xp = tonumber(data.xp) or 0,
				kills = tonumber(data.kills) or 0,
				deaths = tonumber(data.deaths) or 0,
				beststreak = tonumber(data.beststreak) or 0,
				fracture = tonumber(data.fracture) or 0,
			}
		end
	end

	for steamid, row in pairs(storedByID) do
		if not seen[steamid] and not steamid:find("^BOT_") then
			local name = tostring(row.name or "")

			rows[#rows + 1] = {
				steamid = steamid,
				name = name ~= "" and name or "Unknown",
				active = false,
				xp = tonumber(row.xp) or 0,
				kills = tonumber(row.kills) or 0,
				deaths = tonumber(row.deaths) or 0,
				beststreak = tonumber(row.beststreak) or 0,
				fracture = tonumber(row.fracture) or 0,
			}
		end
	end

	table.sort(rows, function(a, b)
		if a.active ~= b.active then return a.active end
		return a.name:lower() < b.name:lower()
	end)

	return rows
end

local function sendAdminRows(ply)
	if not IsAdmin(ply) then return end

	local rows = buildAdminRows()
	local total = #rows
	local chunks = math.max(1, math.ceil(total / ADMIN_CHUNK))

	for index = 1, chunks do
		local part = {}

		for i = (index - 1) * ADMIN_CHUNK + 1, math.min(index * ADMIN_CHUNK, total) do
			part[#part + 1] = rows[i]
		end

		net.Start("HG_CrimXPAdminSend")
			net.WriteUInt(total, 16)
			net.WriteUInt(chunks, 16)
			net.WriteUInt(index, 16)
			net.WriteString(util.TableToJSON(part))
		net.Send(ply)
	end
end

local function sendAdminResult(ply, ok, message)
	if not IsValid(ply) then return end

	net.Start("HG_CrimXPAdminSaveResult")
		net.WriteBool(ok)
		net.WriteString(message or "")
	net.Send(ply)
end

net.Receive("HG_CrimXPAdminRequest", function(_, ply)
	sendAdminRows(ply)
end)

net.Receive("HG_CrimXPAdminSave", function(_, ply)
	if not IsAdmin(ply) then
		sendAdminResult(ply, false, "Access denied")
		return
	end

	local steamid = net.ReadString()
	local incoming = net.ReadTable()

	if not isstring(steamid) or steamid == "" or not istable(incoming) then
		sendAdminResult(ply, false, "Invalid criminal record data")
		return
	end

	local target = findOnlineBySteamID(steamid)
	local current

	if IsValid(target) then
		current = CRIMXP.GetData(target)
	else
		current = sql.QueryRow("SELECT xp, kills, deaths, beststreak, fracture FROM hg_crimxp WHERE steamid = " .. sql.SQLStr(steamid) .. ";") or blankData()
	end

	local currentXP = tonumber(current.xp) or 0
	local currentLevel = CRIMXP.LevelForXP(currentXP)
	local level = math.Clamp(adminNumber(incoming.level, currentLevel, true, 1), 1, CRIMXP.Config.MaxLevel)

	local xp
	if level ~= currentLevel then
		xp = CRIMXP.TotalXPForLevel(level)
	else
		xp = adminNumber(incoming.xp, currentXP, true, 0)
	end

	local kills = adminNumber(incoming.kills, current.kills, true, 0)
	local deaths = adminNumber(incoming.deaths, current.deaths, true, 0)
	local beststreak = adminNumber(incoming.beststreak, current.beststreak, true, 0)
	local fracture = adminNumber(incoming.fracture, current.fracture, true, 0)
	local name = tostring(incoming.name or ""):sub(1, 64)
	if name == "" then name = IsValid(target) and NameOf(target) or "Unknown" end

	xp = math.min(xp, ADMIN_MAX_STAT)
	kills = math.min(kills, ADMIN_MAX_STAT)
	deaths = math.min(deaths, ADMIN_MAX_STAT)
	beststreak = math.min(beststreak, ADMIN_MAX_STAT)
	fracture = math.min(fracture, ADMIN_MAX_STAT)

	if IsValid(target) then
		local data = CRIMXP.GetData(target)
		data.xp = xp
		data.kills = kills
		data.deaths = deaths
		data.beststreak = beststreak
		data.fracture = fracture
		SaveRow(target)
		CRIMXP.Sync(target)

		target:ChatPrint("[XP] Your criminal record was updated by an admin.")
	else
		sql.Query("INSERT OR IGNORE INTO hg_crimxp (steamid, name, xp, kills, deaths, beststreak, fracture) VALUES (" .. sql.SQLStr(steamid) .. ", '', 0, 0, 0, 0, 0);")
		sql.Query("UPDATE hg_crimxp SET name = " .. sql.SQLStr(name) .. ", xp = " .. xp .. ", kills = " .. kills .. ", deaths = " .. deaths .. ", beststreak = " .. beststreak .. ", fracture = " .. fracture .. " WHERE steamid = " .. sql.SQLStr(steamid) .. ";")
	end

	sendAdminResult(ply, true, "Saved criminal record for " .. name)

	timer.Simple(0.2, function()
		if IsValid(ply) then sendAdminRows(ply) end
	end)
end)
