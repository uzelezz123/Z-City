if !hg or !hg.AdminSystem then return end

local AS = hg.AdminSystem
local ESP = {}

ESP.Enabled = false
ESP.InAdminMode = false
ESP.AllESP = false

local ESPEye = CreateClientConVar("zb_espeye", "0", true, false, "Show admin ESP eye trace line")

local col_default = Color(255, 0, 0)
local col_white = Color(255, 255, 255)
local col_gray = Color(180, 180, 180)
local col_weapon = Color(255, 200, 100)
local col_box_outline = Color(0, 0, 0, 200)

local teamColors = {
	[0] = Color(200, 200, 200),
	[1] = Color(255, 100, 100),
	[2] = Color(100, 150, 255),
	[3] = Color(100, 255, 100),
	[4] = Color(255, 255, 100),
	[1001] = Color(150, 150, 150),
}

local function GetPlayerTeamColor(target)
	if !IsValid(target) then return col_default end
	
	local tm = target:Team()
	
	local teamCol = team.GetColor(tm)
	if teamCol and (teamCol.r != 255 or teamCol.g != 255 or teamCol.b != 255) then
		return Color(teamCol.r, teamCol.g, teamCol.b, 255)
	end
	
	if zb and zb.Points then
		for pointName, pointData in pairs(zb.Points) do
			if pointData.Color and pointData.Team == tm then
				return Color(pointData.Color.r, pointData.Color.g, pointData.Color.b, 255)
			end
		end
	end
	
	if teamColors[tm] then
		return teamColors[tm]
	end
	
	return col_default
end

local UpVector = Vector(0, 0, 80)

local weaponClasses = {
	["weapon_pistol"] = "Pistol",
	["weapon_357"] = "Revolver",
	["weapon_smg1"] = "SMG",
	["weapon_ar2"] = "Rifle",
	["weapon_shotgun"] = "Shotgun",
	["weapon_crossbow"] = "Crossbow",
	["weapon_rpg"] = "RPG",
	["weapon_frag"] = "Grenade",
	["weapon_crowbar"] = "Melee",
	["weapon_stunstick"] = "Melee",
	["weapon_physcannon"] = "Tool",
	["weapon_physgun"] = "Tool",
	["gmod_tool"] = "Tool",
	["gmod_camera"] = "Camera",
}

local function GetWeaponClass(wep)
	if !IsValid(wep) then return "None" end
	
	local class = wep:GetClass()
	
	if weaponClasses[class] then
		return weaponClasses[class]
	end
	
	local lclass = string.lower(class)
	
	if string.find(lclass, "pistol") or string.find(lclass, "glock") or string.find(lclass, "deagle") or string.find(lclass, "usp") then
		return "Pistol"
	elseif string.find(lclass, "smg") or string.find(lclass, "mp5") or string.find(lclass, "mac10") or string.find(lclass, "p90") then
		return "SMG"
	elseif string.find(lclass, "rifle") or string.find(lclass, "ak") or string.find(lclass, "m4") or string.find(lclass, "ar15") or string.find(lclass, "galil") then
		return "Rifle"
	elseif string.find(lclass, "sniper") or string.find(lclass, "awp") or string.find(lclass, "scout") then
		return "Sniper"
	elseif string.find(lclass, "shotgun") or string.find(lclass, "spas") or string.find(lclass, "nova") or string.find(lclass, "xm1014") then
		return "Shotgun"
	elseif string.find(lclass, "knife") or string.find(lclass, "melee") or string.find(lclass, "crowbar") or string.find(lclass, "axe") then
		return "Melee"
	elseif string.find(lclass, "grenade") or string.find(lclass, "flash") or string.find(lclass, "smoke") or string.find(lclass, "molotov") then
		return "Grenade"
	elseif string.find(lclass, "rpg") or string.find(lclass, "rocket") then
		return "Heavy"
	elseif string.find(lclass, "lmg") or string.find(lclass, "m249") or string.find(lclass, "negev") then
		return "LMG"
	end
	
	local printName = wep:GetPrintName()
	if printName and printName != "" then
		return printName
	end
	
	return "Unknown"
end

local function ShouldShowPlayer(ply, target)
	if target == ply then return false end
	if not IsValid(target) or not target:Alive() then return false end
	if target:Team() == TEAM_SPECTATOR then return false end
	
	if ESP.AllESP then
		return true
	end
	
	if ply:IsSuperAdmin() and target:Team() == ply:Team() then
		return false
	end
	return true
end

local function Get2DBox(ent)
	if !IsValid(ent) then return nil end
	
	local mins = ent:OBBMins()
	local maxs = ent:OBBMaxs()
	local pos = ent:GetPos()
	local ang = Angle(0, ent:GetAngles().y, 0)
	
	local corners = {
		Vector(mins.x, mins.y, mins.z),
		Vector(mins.x, maxs.y, mins.z),
		Vector(maxs.x, maxs.y, mins.z),
		Vector(maxs.x, mins.y, mins.z),
		Vector(mins.x, mins.y, maxs.z),
		Vector(mins.x, maxs.y, maxs.z),
		Vector(maxs.x, maxs.y, maxs.z),
		Vector(maxs.x, mins.y, maxs.z)
	}
	
	local minX, minY = ScrW(), ScrH()
	local maxX, maxY = 0, 0
	
	for _, corner in ipairs(corners) do
		local worldPos = LocalToWorld(corner, Angle(0,0,0), pos, ang)
		local screen = worldPos:ToScreen()
		
		if !screen.visible then return nil end
		
		minX = math.min(minX, screen.x)
		minY = math.min(minY, screen.y)
		maxX = math.max(maxX, screen.x)
		maxY = math.max(maxY, screen.y)
	end
	
	return minX, minY, maxX - minX, maxY - minY
end

function ESP:Init()
	self:SetupNetworking()
	self:SetupHooks()
end

function ESP:SetupNetworking()
	net.Receive("AS_Sync", function()
		ESP.Enabled = net.ReadBool()
		ESP.InAdminMode = net.ReadBool()
		ESP.AllESP = net.ReadBool()
	end)
end

function ESP:SetupHooks()
	hook.Add("SetupOutlines", "AS_ESP_Outlines", function(Add)
		if !ESP.Enabled then return end
		
		local ply = LocalPlayer()
		if !IsValid(ply) or !ply:IsAdmin() then return end
		
		local teamTargets = {}
		for _, target in player.Iterator() do
			if ShouldShowPlayer(ply, target) then
				local tm = target:Team()
				teamTargets[tm] = teamTargets[tm] or {}
				table.insert(teamTargets[tm], target)
			end
		end
		
		for tm, targets in pairs(teamTargets) do
			if #targets > 0 then
				local col = GetPlayerTeamColor(targets[1])
				outline.Add(targets, col, OUTLINE_MODE_BOTH)
			end
		end
	end)
	
	hook.Add("PreDrawHUD", "AS_ESP_EyeTrace", function()
		if !ESP.Enabled then return end
		if !ESPEye:GetBool() then return end
		
		local ply = LocalPlayer()
		if !IsValid(ply) or !ply:IsAdmin() then return end
		
		for _, target in player.Iterator() do
			if !ShouldShowPlayer(ply, target) then continue end
			
			local col = GetPlayerTeamColor(target)
			local eyePos = target:EyePos()
			local eyeDir = target:EyeAngles():Forward()
			local endPos = eyePos + eyeDir * 10000
			
			cam.Start3D()
				render.DrawLine(eyePos, endPos, col, true)
			cam.End3D()
		end
	end)
	
	hook.Add("HUDPaint", "AS_ESP_Draw", function()
		if !ESP.Enabled then return end
		
		local ply = LocalPlayer()
		if !IsValid(ply) or !ply:IsAdmin() then return end
		
		local myPos = ply:GetPos()
		
		for _, target in player.Iterator() do
			if !ShouldShowPlayer(ply, target) then continue end
			
			local col = GetPlayerTeamColor(target)
			
			local x, y, w, h = Get2DBox(target)
			if x then
				surface.SetDrawColor(col_box_outline)
				surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2, 1)
				surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2, 1)
				
				surface.SetDrawColor(col)
				surface.DrawOutlinedRect(x, y, w, h, 2)
			end
			
			local screenPos = (target:GetPos() + UpVector):ToScreen()
			if !screenPos.visible then continue end
			
			local sx, sy = screenPos.x, screenPos.y
			local dist = math.floor(myPos:Distance(target:GetPos()) / 52.49)
			
			draw.SimpleTextOutlined(target:Nick(), "TargetIDSmall", sx, sy - 10, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			
			local bottomY = y and (y + h + 5) or (sy + 50)
			draw.SimpleTextOutlined(dist .. " m.", "TargetIDSmall", sx, bottomY, col_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
			
			local wep = target:GetActiveWeapon()
			local weaponClass = GetWeaponClass(wep)
			draw.SimpleTextOutlined(weaponClass, "TargetIDSmall", sx, bottomY + 14, col_weapon, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		end
	end)
end

AS:RegisterModule("esp", ESP)
