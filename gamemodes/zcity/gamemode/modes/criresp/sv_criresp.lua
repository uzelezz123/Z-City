MODE.name = "siege"
MODE.PrintName = "Waco Siege"

MODE.ForBigMaps = false
MODE.ROUND_TIME = 1200
MODE.Chance = 0.05
MODE.start_time = 90
MODE.end_time = 9

resource.AddFile("resource/fonts/Ethnocentric-Regular.ttf")
resource.AddFile("sound/crawlspace.mp3")
resource.AddFile("sound/endtimes.mp3")

local overlimit = CreateConVar("criresp_over20", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Allow more than 20 players in Waco Siege", 0, 1)
local gearlist = MODE.SWATGear
local gearslots = MODE.SWATGearSlots
local defaultgear = MODE.SWATDefaultGear
local operatives = MODE.SWATOperatives or {}

local function GetOperative(id)
	for _, op in ipairs(operatives) do
		if op.id == id then return op end
	end
	return operatives[1]
end

util.AddNetworkString("criresp_start")
util.AddNetworkString("criresp_begin")
util.AddNetworkString("criresp_ready")
util.AddNetworkString("criresp_readycount")
util.AddNetworkString("criresp_custom")
util.AddNetworkString("criresp_over20")
util.AddNetworkString("cri_roundend")

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

local function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

local assigned = {}
local sniperPly = nil
local shieldGiven = false
local sniperGiven = false

local function IsAttachmentBlocked(class, placement, att)
	if class == "weapon_remington870" and (placement == "barrel" or string.sub(att, 1, 9) == "supressor") then
		return true
	end
	return false
end

local function IsAttachmentCompatible(wep, att)
	if not IsValid(wep) or not wep.attachments or not wep.availableAttachments then return false end

	local placement
	for _, tbl in pairs(hg.attachments) do
		if tbl[att] then
			placement = tbl[att][1]
			break
		end
	end
	if not placement then return false end
	if IsAttachmentBlocked(wep:GetClass(), placement, att) then return false end

	local avail = wep.availableAttachments[placement]
	if not avail or not wep.attachments[placement] then return false end

	local i
	for n, atta in pairs(avail) do
		if istable(atta) then
			if atta[1] == att then
				i = n
				break
			end
		elseif atta == att then
			i = n
			break
		end
	end

	local mountType = avail.mountType
	local attMount = hg.attachments[placement][att] and hg.attachments[placement][att].mountType

	if not avail[i] and not (mountType or attMount) then return false end

	if istable(mountType) then
		return attMount ~= nil and table.HasValue(mountType, attMount)
	end

	return mountType == attMount
end

local function ApplyCompatibleAttachments(ply, wep, atts)
	if not atts then return end

	local valid = {}
	for _, att in ipairs(atts) do
		if IsAttachmentCompatible(wep, att) then
			valid[#valid + 1] = att
		end
	end

	if #valid > 0 then
		hg.AddAttachmentForce(ply, wep, valid)
	end
end

function MODE:AssignTeams()
	table.Empty(assigned)
	sniperPly = nil

	local players = player.GetAll()
	shuffle(players)

	local cap = overlimit:GetBool() and #players or 20
	local playing = math.min(#players, cap)

	local numSWAT = 1
	if playing <= 4 then
		numSWAT = 1
	elseif playing <= 6 then
		numSWAT = 2
	elseif playing <= 9 then
		numSWAT = 3
	elseif playing <= 13 then
		numSWAT = 4
	elseif playing <= 17 then
		numSWAT = 5
	else
		numSWAT = 6
	end

	for i, ply in ipairs(players) do
		if not IsValid(ply) then continue end

		if i <= numSWAT then
			assigned[ply] = 0
		elseif i <= playing then
			assigned[ply] = 1
		else
			ply:ChatPrint("Waco Siege is limited to 20 players, you are spectating this round")
		end
	end
end


local function CountReady()
	local ready, total = 0, 0
	for ply in pairs(assigned) do
		if not IsValid(ply) then assigned[ply] = nil continue end
		total = total + 1
		if ply.criresp_ready then ready = ready + 1 end
	end
	return ready, total
end

local function SyncReady()
	local ready, total = CountReady()

	net.Start("criresp_readycount")
		net.WriteUInt(ready, 8)
		net.WriteUInt(total, 8)
	net.Broadcast()

	if total > 0 and ready >= total and zb.ROUND_STATE == 0 then
		zb.START_TIME = math.min(zb.START_TIME or math.huge, CurTime() + 2)
	end
end

net.Receive("criresp_ready", function(len, ply)
	if zb.CROUND ~= "siege" or zb.ROUND_STATE ~= 0 then return end
	if assigned[ply] == nil then return end

	ply.criresp_ready = true
	SyncReady()
end)

net.Receive("criresp_over20", function(len, ply)
	if not ply:IsAdmin() then return end
	overlimit:SetBool(net.ReadBool())
end)

net.Receive("criresp_custom", function(len, ply)
	local op = GetOperative(net.ReadString())
	if not op then return end

	local primaryIndex = net.ReadUInt(8)
	local pistolIndex = net.ReadUInt(8)
	local taser = net.ReadBool()
	local groups = net.ReadString()
	if #groups > 48 then groups = "" end

	local gear, seen = {}, {}
	for i = 1, math.min(net.ReadUInt(4), gearslots) do
		local idx = net.ReadUInt(8)
		if gearlist[idx] and not seen[idx] then
			seen[idx] = true
			table.insert(gear, idx)
		end
	end

	local atts, seenAtts = {}, {}
	for i = 1, math.min(net.ReadUInt(6), 32) do
		local att = net.ReadString()
		if #att > 0 and #att <= 32 and not seenAtts[att] then
			seenAtts[att] = true
			atts[#atts + 1] = att
		end
	end

	ply.criresp_custom = {
		operative = op.id,
		primary = (primaryIndex > 0 and primaryIndex <= #(op.primaries or {})) and primaryIndex or nil,
		pistol = (pistolIndex > 0 and pistolIndex <= #(op.pistols or {})) and pistolIndex or nil,
		taser = (op.tasers and taser) or nil,
		groups = groups,
		gear = #gear > 0 and gear or nil,
		atts = #atts > 0 and atts or nil
	}
end)

function MODE:Intermission()
	game.CleanUpMap()

	self:AssignTeams()

	for k, ply in player.Iterator() do
		ply.criresp_ready = nil
		ply.criresp_sniper = nil
		ply.criresp_nextsnipe = nil
		ply:SetTeam(TEAM_SPECTATOR)
		ply:KillSilent()
	end

	net.Start("criresp_start")
	net.Broadcast()

	timer.Create("criresp_readysync", 3, 0, function()
		if zb.CROUND ~= "siege" or zb.ROUND_STATE ~= 0 then
			timer.Remove("criresp_readysync")
			return
		end
		SyncReady()
	end)
end

local function IsCombatant(ply)
	if not ply:Alive() then return false end
	if ply:GetNetVar("handcuffed", false) then return false end
	if ply.organism and ply.organism.incapacitated then return false end
	return true
end

function MODE:CheckAlivePlayers()
	local swatPlayers = {}
	local banditPlayers = {}

	for _, ply in ipairs(team.GetPlayers(0)) do
		if ply.criresp_sniper then continue end
		if IsCombatant(ply) then
			table.insert(swatPlayers, ply)
		end
	end

	for _, ply in ipairs(team.GetPlayers(1)) do
		if IsCombatant(ply) then
			table.insert(banditPlayers, ply)
		end
	end

	return {swatPlayers, banditPlayers}
end

function MODE:ShouldRoundEnd()
	if zb.ROUND_STATE ~= 1 then return false end
	if zb.ROUND_BEGIN + 51 > CurTime() then return false end

	local aliveTeams = self:CheckAlivePlayers()
	local endround, winner = zb:CheckWinner(aliveTeams)
	return endround
end

local davidianWeapons = {
	-- AKs
	{wep = "weapon_akm", atts = {"holo6", "supressor1"}},
	{wep = "weapon_ak74", atts = {"holo6", "supressor1"}},
	{wep = "weapon_ak74u", atts = {"supressor1"}},
	{wep = "weapon_ak203", atts = {"supressor1"}},
	{wep = "weapon_ak200"},
	-- rifles / SMG
	{wep = "weapon_m16a2"},
	{wep = "weapon_ar15", atts = {"holo1", "grip2"}},
	{wep = "weapon_mac11", atts = {"supressor4"}},
	-- only one .50 cal sniper per round
	{wep = "weapon_m98b", sniper = true},
	-- pistols
	{wep = "weapon_m9beretta"},
	{wep = "weapon_px4beretta"},
	{wep = "weapon_glock17"},
	{wep = "weapon_glock18c"},
	{wep = "weapon_glock26"},
	{wep = "weapon_revolver2"},
	{wep = "weapon_revolver357"},
}

local tblarmors = {
	[0] = {
		{"ent_armor_vest8", "ent_armor_helmet6"}
	}
}

function MODE:CanLaunch()
	local points = zb.GetMapPoints( "HMCD_CRI_CT" )
	local points2 = zb.GetMapPoints( "HMCD_CRI_T" )
	local plramount = zb:CheckPlaying()
	return (#points > 3) and (#points2 > 0) and (#plramount > 5)
end

local function GiveSuspect(ply)
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	ply:SetPlayerClass("terrorist")
	zb.GiveRole(ply, "Branch Davidian", Color(190, 0, 0))

	local pick
	for i = 1, 30 do
		local candidate = davidianWeapons[math.random(#davidianWeapons)]
		if candidate.sniper and sniperGiven then continue end
		pick = candidate
		break
	end
	pick = pick or davidianWeapons[1]

	if pick.sniper then sniperGiven = true end

	local gun = ply:Give(pick.wep)
	if IsValid(gun) and gun.GetMaxClip1 then
		ApplyCompatibleAttachments(ply, gun, pick.atts)
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	else
		print("WTH???")
	end

	ply:Give("weapon_hammer")
	timer.Simple(0.2, function()
		if IsValid(ply) then ply:SetAmmo(3, "Nails") end
	end)

	ply:Give("weapon_ducttape")
	ply:Give("weapon_hands_sh")

	ply:SetSuppressPickupNotices(false)

	timer.Simple(0.5, function()
		if IsValid(ply) then ply.noSound = false end
	end)
end

local function SpawnSWAT(ply, swatPlayers)
	if not IsValid(ply) or ply:Team() ~= 0 then return end

	ply:Spawn()
	ply:Freeze(false)
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	local custom = ply.criresp_custom
	local op = GetOperative(custom and custom.operative) or operatives[1]
	if not op then return end

	ply:SetupTeam(ply:Team())
	ply:SetPlayerClass("swat")
	if op.model then ply:SetModel(op.model) end

	local inv = ply:GetNetVar("Inventory")
	inv["Weapons"]["hg_sling"] = true
	ply:SetNetVar("Inventory", inv)

	hg.AddArmor(ply, tblarmors[0][math.random(#tblarmors[0])])
	ply:SetNetVar("HideArmorRender", false)
	zb.GiveRole(ply, op.role or op.name or "ATF", op.color or Color(0, 0, 190))
	ply:SetPlayerColor((op.color or Color(0, 0, 190)):ToVector())

	table.insert(swatPlayers, ply)

	local opPrimaries = op.primaries or {}
	local primary = opPrimaries[(custom and custom.primary) or 1] or opPrimaries[1]
	if not primary then return end

	local gun = ply:Give(primary.wep)
	if IsValid(gun) and gun.GetMaxClip1 then
		ApplyCompatibleAttachments(ply, gun, (custom and custom.atts) or primary.atts)
		ply:GiveAmmo(gun:GetMaxClip1() * 6, gun:GetPrimaryAmmoType(), true)
	else
		print("WTH???")
	end

	local opPistols = op.pistols or {}
	local pistol = opPistols[(custom and custom.pistol) or 1] or opPistols[1]
	if pistol then
		local sidearm = ply:Give(pistol.wep)
		if IsValid(sidearm) and sidearm.GetMaxClip1 then
			ApplyCompatibleAttachments(ply, sidearm, pistol.atts)
			ply:GiveAmmo(sidearm:GetMaxClip1() * 4, sidearm:GetPrimaryAmmoType(), true)
		end
	end

	if op.tasers and custom and custom.taser then
		local taser = ply:Give(op.tasers[1].wep)
		if IsValid(taser) and taser.GetMaxClip1 then
			ply:GiveAmmo(taser:GetMaxClip1() * 3, taser:GetPrimaryAmmoType(), true)
		end
	end

	ply:Give("weapon_hg_flashbang_tpik")
	ply:Give("weapon_handcuffs")
	ply:Give("weapon_hands_sh")

	if custom and custom.groups and custom.groups ~= "" then
		local groups = string.Explode(" ", custom.groups)
		timer.Simple(0.15, function()
			if not IsValid(ply) or not ply:Alive() then return end
			for k = 0, ply:GetNumBodyGroups() - 1 do
				ply:SetBodygroup(k, tonumber(groups[k + 1]) or 0)
			end
		end)
	end

	ply:SetSuppressPickupNotices(false)
	ply.noSound = false
end

local function SpawnSniper(ply)
	if not IsValid(ply) or ply:Team() ~= 0 then return end

	ply:Spawn()
	ply:Freeze(false)
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	ply:SetupTeam(ply:Team())
	ply:SetPlayerClass("swat")

	local pts = zb.GetMapPoints("SNIPERSPAWN_CRI")
	if pts and #pts > 0 then
		local pnt = pts[math.random(#pts)]
		if pnt and pnt.pos then ply:SetPos(pnt.pos) end
	end

	local inv = ply:GetNetVar("Inventory")
	inv["Weapons"]["hg_sling"] = true
	ply:SetNetVar("Inventory", inv)

	zb.GiveRole(ply, "SWAT Sniper", Color(0, 60, 220))

	local gun = ply:Give("weapon_m98b")
	if IsValid(gun) and gun.GetMaxClip1 then
		ply:GiveAmmo(gun:GetMaxClip1() * 5, gun:GetPrimaryAmmoType(), true)
	end

	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_tourniquet")
	ply:Give("weapon_walkie_talkie")
	ply:Give("weapon_hands_sh")

	ply:SetSuppressPickupNotices(false)
	ply.noSound = false
end


local sniperZones = {}
local sniperZoneNames = {"SNIPERZONE_CRI", "SNIPERZONE_CRI2", "SNIPERZONE_CRI3", "SNIPERZONE_CRI4"}

local function BuildSniperZones()
	table.Empty(sniperZones)

	for _, name in ipairs(sniperZoneNames) do
		local pts = zb.GetMapPoints(name)
		if not pts or #pts < 2 then continue end

		local mins = Vector(math.huge, math.huge, math.huge)
		local maxs = Vector(-math.huge, -math.huge, -math.huge)

		for _, pnt in pairs(pts) do
			if not pnt.pos then continue end
			mins.x, mins.y, mins.z = math.min(mins.x, pnt.pos.x), math.min(mins.y, pnt.pos.y), math.min(mins.z, pnt.pos.z)
			maxs.x, maxs.y, maxs.z = math.max(maxs.x, pnt.pos.x), math.max(maxs.y, pnt.pos.y), math.max(maxs.z, pnt.pos.z)
		end

		mins.z = mins.z - 96
		maxs.z = maxs.z + 160

		table.insert(sniperZones, {mins, maxs})
	end
end

local function InSniperZone(pos)
	for _, zone in ipairs(sniperZones) do
		if pos:WithinAABox(zone[1], zone[2]) then return true end
	end
	return false
end

local function GetBody(ply)
	if IsValid(ply.FakeRagdoll) then return ply.FakeRagdoll end
	if IsValid(ply.OldRagdoll) and ply.OldRagdoll:IsRagdoll() then return ply.OldRagdoll end
	return ply
end

local function GetBonePos(body, boneName)
	local boneId = body:LookupBone(boneName)
	if not boneId then return end

	local matrix = body:GetBoneMatrix(boneId)
	return matrix and matrix:GetTranslation() or body:GetBonePosition(boneId)
end

--;; ÑÐ½Ð°Ð¹Ð¿ÐµÑ€Ð° Ð·Ð¾Ð²ÑƒÑ‚ Ð´Ð¶Ð¾Ð½ Ð·ÑÐ¸Ñ‚Ð¸, Ð¾Ð½ Ð»ÑŽÐ±Ð¸Ñ‚ ÑÑ‚Ñ€ÐµÐ»ÑÑ‚ÑŒ Ð² Ð¿Ð»Ð¾Ñ…Ð¸Ñ… Ð»ÑŽÐ´ÐµÐ¹, Ð¾Ð½ Ð¿ÐµÑ€ÐµÐ¶Ð¸Ð» Ð¼Ð½Ð¾Ð³Ð¾Ðµ Ð½Ð¾ Ñ‚ÐµÐ¿ÐµÑ€ÑŒ Ð¾Ð½ ÑÑ‚Ð¾Ð¸Ñ‚ Ð½Ð° ÑÑ‚Ñ€Ð°Ð¶Ðµ Ð¿Ð¾Ñ€ÑÐ´ÐºÐ° ÑÐ»Ð°Ð²Ð½Ð¾Ð³Ð¾ Ð³Ð¾Ñ€Ð¾Ð´ÐºÐ° Ð·ÐµÐ´, Ð·Ð½Ð°Ð¹Ñ‚Ðµ ÐµÑÐ»Ð¸ Ð²Ñ‹ Ð¿Ð¾Ð³Ð¸Ð±Ð»Ð¸ Ð²Ñ‹Ð¹Ð´Ñ Ð¸Ð· Ð·Ð´Ð°Ð½Ð¸Ðµ Ñ‚Ð¾ ÑÑ‚Ð¾ Ð±Ñ‹Ð» Ð¸Ð¼ÐµÐ½Ð½Ð¾ Ð¾Ð½.
local function SniperShot(ply)
	local body = GetBody(ply)
	local headshot = math.random() <= 0.3

	local target = GetBonePos(body, headshot and "ValveBiped.Bip01_Head1" or "ValveBiped.Bip01_Spine2")
		or body:WorldSpaceCenter()

	local losFilter = {ply, body}

	local src
	for i = 1, 12 do
		local ang = math.Rand(0, math.pi * 2)
		local dist = math.Rand(1200, 2500)
		local test = target + Vector(math.cos(ang) * dist, math.sin(ang) * dist, math.Rand(300, 900))

		local tr = util.TraceLine({start = test, endpos = target, mask = MASK_SHOT, filter = losFilter})
		if tr.Fraction >= 0.98 then
			src = test
			break
		end
	end

	src = src or target + Angle(0, math.Rand(0, 360), 0):Forward() * 64 + Vector(0, 0, 40)

	local attacker = (IsValid(sniperPly) and sniperPly:Alive()) and sniperPly or game.GetWorld()

	game.GetWorld():FireLuaBullets({
		Attacker = attacker,
		Inflictor = game.GetWorld(),
		Src = src,
		Dir = (target - src):GetNormal(),
		Damage = 180,
		Force = 60,
		Num = 1,
		Spread = vector_origin,
		Tracer = 1,
		AmmoType = ".338 Lapua Magnum",
		Penetration = 32.2,
		Diameter = 8.6,
		penetrated = 0,
		limit_ricochet = 0,
		dmgtype = DMG_BULLET,
		DisableLagComp = true,
		Distance = 8000
	})

	sound.Play("mosin/mosin_dist.wav", src, 120, math.random(95, 105))
end

local function SniperZoneThink()
	if #sniperZones == 0 then return end

	local outside = {}
	for _, ply in ipairs(team.GetPlayers(1)) do
		if not ply:Alive() or ply:GetNetVar("handcuffed", false) then continue end
		if InSniperZone(GetBody(ply):GetPos()) then continue end
		table.insert(outside, ply)
	end

	local cooldown = #outside > 1 and math.max(0.6, 2.5 / #outside) or 2.5

	for _, ply in ipairs(outside) do
		if (ply.criresp_nextsnipe or 0) > CurTime() then continue end

		ply.criresp_nextsnipe = CurTime() + cooldown
		SniperShot(ply)
	end
end

function MODE:RoundStart()
	timer.Remove("criresp_readysync")
	shieldGiven = false
	sniperGiven = false

	net.Start("criresp_begin")
	net.Broadcast()

	local swatPlayers = {}

	for ply, teamID in pairs(assigned) do
		if not IsValid(ply) then continue end

		if teamID == 0 then
			ply:SetTeam(0)

			timer.Create("SWATSpawn" .. ply:EntIndex(), 50, 1, function()
				SpawnSWAT(ply, swatPlayers)
			end)
		else
			ply:SetTeam(1)
			ply:Spawn()
			ply:Freeze(false)
			ply:SetupTeam(1)
			GiveSuspect(ply)
		end
	end
end

function MODE:GiveEquipment()
end

function MODE:RoundThink()
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_CRI_CT")), zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_CRI_T"))
end

function MODE:CanSpawn()
end

function MODE:EndRound()
	timer.Remove("criresp_readysync")
	timer.Remove("criresp_sniperzone")
	table.Empty(sniperZones)
	sniperPly = nil

	for k, ply in player.Iterator() do
		ply.criresp_ready = nil
		ply:SetNetVar("HideArmorRender", false)
		if timer.Exists("SWATSpawn" .. ply:EntIndex()) then
			timer.Remove("SWATSpawn" .. ply:EntIndex())
		end
	end

	if timer.Exists("SWATSpawn") then
		timer.Remove("SWATSpawn")
	end

	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
	winner = isnumber(winner) and winner or 3

	local killed, incap, arrested, total = 0, 0, 0, 0
	for _, ply in ipairs(team.GetPlayers(1)) do
		total = total + 1

		if ply:GetNetVar("handcuffed", false) then
			arrested = arrested + 1
		elseif not ply:Alive() then
			killed = killed + 1
		elseif ply.organism and ply.organism.incapacitated then
			incap = incap + 1
		end
	end

	net.Start("cri_roundend")
		net.WriteUInt(winner, 4)
		net.WriteUInt(killed, 8)
		net.WriteUInt(incap, 8)
		net.WriteUInt(arrested, 8)
		net.WriteUInt(total, 8)
	net.Broadcast()

	local winnerTeam = winner == 1 and 0 or winner == 2 and 1 or -1

	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		if ply:Team() == winnerTeam then
			ply:GiveExp(math.random(15, 30))
			ply:GiveSkill(math.Rand(0.1, 0.15))
		else
			ply:GiveSkill(-math.Rand(0.05, 0.1))
		end
	end

	table.Empty(assigned)
end

function MODE:PlayerDeath(ply)
end
