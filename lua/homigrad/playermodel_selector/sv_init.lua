COMMANDS = COMMANDS or {}

util.AddNetworkString("ZC_PMS_Apply")
util.AddNetworkString("ZC_PMS_Reset")
util.AddNetworkString("ZC_PMS_Open")
util.AddNetworkString("ZC_PMS_Armor")

local function CanUse(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if engine.ActiveGamemode() == "sandbox" then return true end
	return ply:IsAdmin()
end

net.Receive("ZC_PMS_Apply", function(len, ply)
	if not CanUse(ply) then return end
	if not ply:Alive() then ply:ChatPrint("You must be alive to change your model") return end
	if (ply.zc_pms_next or 0) > CurTime() then return end
	ply.zc_pms_next = CurTime() + 0.15

	local mdl = net.ReadString()
	local skin = net.ReadUInt(8)
	local groupsStr = net.ReadString()
	local nick = net.ReadString()

	if not isstring(mdl) or not string.StartsWith(mdl, "models/") or not string.EndsWith(mdl, ".mdl") then return end
	if IsUselessModel(mdl) then return end
	util.PrecacheModel(mdl)

	if player_manager.TranslateToPlayerModelName(mdl) ~= nil then
		ply:ConCommand("cl_playermodel "..player_manager.TranslateToPlayerModelName(mdl))	-- Sets the player convar so your choice saves
	end

	local Appearance = ply.CurAppearance or hg.Appearance.GetRandomAppearance()
	Appearance.AColthes = ""
	ply:SetNetVar("Accessories", "")
	ply:SetModel(mdl)
	ply:SetBodyGroups("00000000000000000000")
	ply:SetSubMaterial()
	ply:SetPlayerColor(ply:GetNWVector("PlayerColor", vector_origin))

	ply:SetSkin(math.Clamp(skin, 0, math.max(ply:SkinCount() - 1, 0)))

	local groups = string.Explode(" ", groupsStr or "")
	for k = 0, ply:GetNumBodyGroups() - 1 do
		ply:SetBodygroup(k, tonumber(groups[k + 1]) or 0)
	end

	if nick ~= "" and hg.Appearance and not hg.Appearance.IsInvalidName(nick) then
		ply:SetNWString("PlayerName", nick)
	end
end)

net.Receive("ZC_PMS_Armor", function(len, ply)
	if not CanUse(ply) then return end
	ply:SetNetVar("HideArmorRender", net.ReadBool())
end)

net.Receive("ZC_PMS_Reset", function(len, ply)
	if not CanUse(ply) then return end
	if not ply:Alive() then return end

	ApplyAppearance(ply, nil, nil, nil, true)
	ply:ChatPrint("Appearance restored")
end)

local function OpenSelector(ply)
	if not CanUse(ply) then
		if IsValid(ply) then ply:ChatPrint("You don't have access") end
		return
	end

	net.Start("ZC_PMS_Open")
	net.Send(ply)
end

COMMANDS.models = {function(ply, args)
	OpenSelector(ply)
end, 0}

COMMANDS.pms = COMMANDS.models
COMMANDS.modelselector = COMMANDS.models
