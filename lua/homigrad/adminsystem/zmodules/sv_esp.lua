
if !hg or !hg.AdminSystem then return end

local AS = hg.AdminSystem
local ESP = {}

local adminMode = {}
local espPlayers = {}
local syncQueue = {}
local allESP = {} 

function ESP:Init()
	util.AddNetworkString("AS_Sync")
	
	self:SetupHooks()
	self:SetupCommands()


	timer.Create("AS_AllESP_Sync", 1, 0, function()
		for steamId, enabled in pairs(allESP) do
			local ply = player.GetBySteamID64(steamId) or player.GetBySteamID(steamId)
			if not IsValid(ply) or not ply:IsSuperAdmin() then
				allESP[steamId] = nil
			end
		end
	end)
	
	timer.Create("AS_SyncQueue", 0.1, 0, function()
		for steamId, ply in pairs(syncQueue) do
			if IsValid(ply) then
				self:DoSync(ply)
			end
			syncQueue[steamId] = nil
		end
	end)
end

function ESP:IsInAdminMode(ply)
	if !IsValid(ply) then return false end
	local steamId = ply:SteamID64() or ply:SteamID()
	return adminMode[steamId] or false
end

function ESP:ToggleAdminMode(ply)
	if !IsValid(ply) then return false end
	if !ply:IsAdmin() then return false end
	if ply:IsSuperAdmin() then return false end
	
	local steamId = ply:SteamID64() or ply:SteamID()
	
	if adminMode[steamId] then
		adminMode[steamId] = nil
		espPlayers[steamId] = nil
		ply:SetTeam(1)
	else
		if ply:Alive() then ply:Kill() end
		ply:SetTeam(TEAM_SPECTATOR)
		adminMode[steamId] = true
	end
	
	self:QueueSync(ply)
	return true
end

function ESP:ToggleESP(ply)
	if !IsValid(ply) then return false end
	if !ply:IsAdmin() then return false end
	
	local steamId = ply:SteamID64() or ply:SteamID()
	
	if espPlayers[steamId] then
		espPlayers[steamId] = nil
		self:QueueSync(ply)
		return true
	end
	
	if !ply:IsSuperAdmin() and !adminMode[steamId] then
		return false
	end
	
	espPlayers[steamId] = true
	self:QueueSync(ply)
	return true
end

function ESP:IsEnabled(ply)
	if !IsValid(ply) then return false end
	local steamId = ply:SteamID64() or ply:SteamID()
	if ply:IsSuperAdmin() and allESP[steamId] then return true end
	return espPlayers[steamId] or false
end

function ESP:QueueSync(ply)
	if !IsValid(ply) then return end
	local steamId = ply:SteamID64() or ply:SteamID()
	syncQueue[steamId] = ply
end

function ESP:IsAllESP(ply)
	if not IsValid(ply) then return false end
	local steamId = ply:SteamID64() or ply:SteamID()
	return ply:IsSuperAdmin() and allESP[steamId] or false
end

function ESP:DoSync(ply)
	if !IsValid(ply) then return end
	
	local steamId = ply:SteamID64() or ply:SteamID()
	local enabled = espPlayers[steamId] or false
	local inAdminMode = adminMode[steamId] or false
	local isAllESP = allESP[steamId] or false
	
	net.Start("AS_Sync")
	net.WriteBool(enabled or isAllESP)
	net.WriteBool(inAdminMode)
	net.WriteBool(isAllESP)
	net.Send(ply)
end

function ESP:SetupHooks()
	hook.Add("PlayerChangedTeam", "AS_TeamCheck", function(ply, oldTeam, newTeam)
		if !IsValid(ply) then return end
		if ply:IsSuperAdmin() then return end
		if !self:IsInAdminMode(ply) then return end
		
		if newTeam != TEAM_SPECTATOR then
			local steamId = ply:SteamID64() or ply:SteamID()
			adminMode[steamId] = nil
			espPlayers[steamId] = nil
			self:QueueSync(ply)
		end
	end)
	
	hook.Add("PlayerDisconnected", "AS_Cleanup", function(ply)
		if !IsValid(ply) then return end
		local steamId = ply:SteamID64() or ply:SteamID()
		espPlayers[steamId] = nil
		adminMode[steamId] = nil
		syncQueue[steamId] = nil
	end)
end

function ESP:SetupCommands()
	concommand.Add("zb_adminmode", function(ply)
		if !IsValid(ply) then return end
		if !ply:IsAdmin() then return end
		if ply:IsSuperAdmin() then return end
		
		ESP:ToggleAdminMode(ply)
	end)
	
	concommand.Add("zb_admesp", function(ply)
		if !IsValid(ply) then return end
		if !ply:IsAdmin() then return end
		
		ESP:ToggleESP(ply)
	end)

	concommand.Add("zb_allesp", function(ply, cmd, args)
		if not IsValid(ply) or not ply:IsSuperAdmin() then return end
		local steamId = ply:SteamID64() or ply:SteamID()
		local enable = tonumber(args[1] or "0") == 1
		allESP[steamId] = enable or nil
		ESP:QueueSync(ply)
	end)
end

AS:RegisterModule("esp", ESP)
