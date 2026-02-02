hg = hg or {}
hg.AdminSystem = hg.AdminSystem or {}

local AS = hg.AdminSystem

AS.Version = "2.0" --;; 1488
AS.Modules = AS.Modules or {}
AS.PlayerData = AS.PlayerData or {}

function AS:RegisterModule(name, module)
	if !name or !module then return false end
	self.Modules[name] = module
	module.Name = name
	return true
end

function AS:GetModule(name)
	return self.Modules[name]
end

function AS:InitModules()
	for name, module in pairs(self.Modules) do
		if module.Init then
			module:Init()
		end
	end
end

function AS:IsSuperAdmin(ply)
	if !IsValid(ply) then return false end
	return ply:IsSuperAdmin()
end

function AS:IsAdminOnly(ply)
	if !IsValid(ply) then return false end
	return ply:IsAdmin() and !ply:IsSuperAdmin()
end

function AS:IsAdmin(ply)
	if !IsValid(ply) then return false end
	return ply:IsAdmin()
end

function AS:GetUserGroup(ply)
	if !IsValid(ply) then return "user" end
	return ply:GetUserGroup() or "user"
end

function AS:GetPlayerData(ply, module)
	if !IsValid(ply) then return {} end
	local steamId = ply:SteamID64() or ply:SteamID()
	
	self.PlayerData[steamId] = self.PlayerData[steamId] or {}
	
	if module then
		self.PlayerData[steamId][module] = self.PlayerData[steamId][module] or {}
		return self.PlayerData[steamId][module]
	end
	
	return self.PlayerData[steamId]
end

function AS:SetPlayerData(ply, module, data)
	if !IsValid(ply) then return end
	local steamId = ply:SteamID64() or ply:SteamID()
	
	self.PlayerData[steamId] = self.PlayerData[steamId] or {}
	self.PlayerData[steamId][module] = data
end

if SERVER then
	util.AddNetworkString("AdminSystem_Sync")
	util.AddNetworkString("AdminSystem_ModuleAction")
	util.AddNetworkString("AdminSystem_Notification")
end

function AS:Notify(ply, message, notifyType)
end

function AS:GetCurrentMode()
	local mode = zb and (zb.CROUND_MAIN or zb.CROUND)
	return mode and string.lower(mode) or "unknown"
end

hook.Add("InitPostEntity", "AdminSystem_Init", function()
	timer.Simple(1, function()
		if hg.AdminSystem.InitModules then
			hg.AdminSystem:InitModules()
		end
		hook.Run("AdminSystem_Loaded")
	end)
end)

if CLIENT then
	net.Receive("AdminSystem_Notification", function()
		net.ReadString()
		net.ReadUInt(4)
	end)
end
