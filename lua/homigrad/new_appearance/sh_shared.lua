hg.Appearance = hg.Appearance or {}
hg.PointShop = hg.PointShop or {}
local PLUGIN = hg.PointShop
PLUGIN.Items = PLUGIN.Items or {}
-- Validate function for custom name
local allowed = {
	' ',
	'а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я',
	'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
}
local function IsInvalidName(name)
	local trimmedName = string.Trim(name)
	if trimmedName == "" then return true end
	if #trimmedName < 2 then return true end
	if utf8.len(name) > 25 then return true end
	local symblos = utf8.len(name)
	for k = 1, symblos do
		if not table.HasValue(allowed, utf8.GetChar(name, k)) then return true end
	end

	local ret = hook.Run("ZB_IsInvalidName", name)
	if ret ~= nil then return ret end

	return false
end

hg.Appearance.IsInvalidName = IsInvalidName
-- Random name generator
-- in misc/sh_names.lua
local function GenerateRandomName(iSex)
	local sex = iSex or math.random(1, 2)
	local randomName = hg.Appearance.RandomNames[sex][math.random(1, #hg.Appearance.RandomNames[sex])]
	return randomName
end

hg.Appearance.GenerateRandomName = GenerateRandomName
-- Check access to all
local access = {}
--["STEAM_0:1:163575696"] = true -- distac our custom model creator
local hg_appearance_access_for_all = ConVarExists("hg_appearance_access_for_all") and GetConVar("hg_appearance_access_for_all") or CreateConVar("hg_appearance_access_for_all", 1, {FCVAR_REPLICATED, FCVAR_NEVER_AS_STRING, FCVAR_ARCHIVE}, "Toggle free items in appearance for everyone", 0, 1)
if SERVER then
	cvars.AddChangeCallback("hg_appearance_access_for_all", function(convar_name, value_old, value_new) SetGlobalBool("hg_appearance_access_for_all", hg_appearance_access_for_all:GetBool()) end)
	SetGlobalBool("hg_appearance_access_for_all", hg_appearance_access_for_all:GetBool())
end

local function GetAccessToAll(ply)
	return GetGlobalBool("hg_appearance_access_for_all") or ply:IsSuperAdmin() or ply:IsAdmin() or access[ply:SteamID()]
end

hg.Appearance.GetAccessToAll = GetAccessToAll
-- Appearance models
local PlayerModels = {
	[1] = {},
	[2] = {}
}

local function AppAddModel(strName, strMdl, bFemale, tSubmaterialSlots)
	PlayerModels[bFemale and 2 or 1][strName] = {
		mdl = strMdl,
		submatSlots = tSubmaterialSlots,
		sex = bFemale
	}
end

AppAddModel("Male 01", "models/zcity/m/male_01.mdl", false, {
	main = "models/humans/male/group01/players_sheet", -- сделал бы автоматом если бы слоты не отличались...
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 02", "models/zcity/m/male_02.mdl", false, {
	main = "models/humans/male/group01/players_sheet", -- забудьте я просто шизик, сделал более удобную штуку
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 03", "models/zcity/m/male_03.mdl", false, {
	main = "models/humans/male/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 04", "models/zcity/m/male_04.mdl", false, {
	main = "models/humans/male/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 05", "models/zcity/m/male_05.mdl", false, {
	main = "models/humans/male/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 06", "models/zcity/m/male_06.mdl", false, {
	main = "models/humans/male/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 07", "models/zcity/m/male_07.mdl", false, {
	main = "models/humans/male/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 08", "models/zcity/m/male_08.mdl", false, {
	main = "models/humans/male/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Male 09", "models/zcity/m/male_09.mdl", false, {
	main = "models/humans/male/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Female 01", "models/zcity/f/female_01.mdl", true, {
	main = "models/humans/female/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Female 02", "models/zcity/f/female_02.mdl", true, {
	main = "models/humans/female/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Female 03", "models/zcity/f/female_03.mdl", true, {
	main = "models/humans/female/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Female 04", "models/zcity/f/female_04.mdl", true, {
	main = "models/humans/female/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Female 05", "models/zcity/f/female_07.mdl", true, {
	main = "models/humans/female/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

AppAddModel("Female 06", "models/zcity/f/female_06.mdl", true, {
	main = "models/humans/female/group01/players_sheet",
	pants = "distac/gloves/pants",
	boots = "distac/gloves/cross",
	hands = "distac/gloves/hands"
})

hg.Appearance.PlayerModels = PlayerModels
hg.Appearance.FuckYouModels = {{}, {}}
for name, tbl in pairs(hg.Appearance.PlayerModels[1]) do
	hg.Appearance.FuckYouModels[1][tbl.mdl] = tbl
end

for name, tbl in pairs(hg.Appearance.PlayerModels[2]) do
	hg.Appearance.FuckYouModels[2][tbl.mdl] = tbl
end

--fuck you
hg.Appearance.Clothes = {}
hg.Appearance.Clothes[1] = {
	normal = "models/humans/male/group01/normal",
	formal = "models/humans/male/group01/formal",
	plaid = "models/humans/male/group01/plaid",
	striped = "models/humans/male/group01/striped",
	young = "models/humans/male/group01/young",
	cold = "models/humans/male/group01/cold",
	casual = "models/humans/male/group01/casual",
	sweater_xmas = "models/humans/male/group01/sweater",
	worker = "models/humans/male/group01/worker",
}

hg.Appearance.Clothes[2] = {
	normal = "models/humans/female/group01/normal",
	formal = "models/humans/female/group01/formal",
	plaid = "models/humans/female/group01/plaid",
	striped = "models/humans/female/group01/striped",
	young = "models/humans/female/group01/young",
	cold = "models/humans/female/group01/cold",
	casual = "models/humans/female/group01/casual",
	sweater_xmas = "models/humans/female/group01/sweater",
}

hg.Appearance.ClothesDesc = {
	normal = {
		desc = "Garry's Mod default citizen outfit"
	},
	formal = {
		desc = "from orignial Jack's Homicide gamemode.\nForever."
	},
	plaid = {
		desc = "from orignial Jack's Homicide gamemode.\nForever."
	},
	striped = {
		desc = "from orignial Jack's Homicide gamemode.\nForever."
	},
	young = {
		desc = "from orignial Jack's Homicide gamemode.\nForever."
	},
	cold = {
		desc = "from orignial Jack's Homicide gamemode.\nForever."
	},
	casual = {
		desc = "from orignial Jack's Homicide gamemode.\nForever."
	},
	sweater_xmas = {
		desc = "by Wontairr from steam workshop\nRMB to open link",
		link = "https://steamcommunity.com/sharedfiles/filedetails/?id=3621630161"
	},
	worker = {
		desc = "by Chervo93 from steam workshop\nRMB to open link",
		link = "https://steamcommunity.com/sharedfiles/filedetails/?id=3540506879"
	},
}

-- Facemaps
hg.Appearance.FacemapsSlots = hg.Appearance.FacemapsSlots or {}
--["matname"] = {
--     ["facemapname"] = "facemap-material"
--     ["facemapname2"] = "facemap-material2"
--}
hg.Appearance.FacemapsModels = hg.Appearance.FacemapsModels or {}
local function AddFacemap(matOverride, strName, matMaterial, model)
	hg.Appearance.FacemapsSlots[matOverride] = hg.Appearance.FacemapsSlots[matOverride] or {}
	local tbl = hg.Appearance.FacemapsSlots[matOverride]
	tbl[strName] = matMaterial
	if model then hg.Appearance.FacemapsModels[model] = matOverride end
end

-----------------------------------Female------------------------------------------------
local female01facemap = "models/humans/female/group01/joey_facemap"
AddFacemap(female01facemap, "Default", "", "models/zcity/f/female_01.mdl") -- female 01
AddFacemap(female01facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/joey_facemap")
for i = 2, 6 do
	AddFacemap(female01facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/joey_facemap" .. i)
end

local female02facemap = "models/humans/female/group01/kanisha_cylmap"
AddFacemap(female02facemap, "Default", "", "models/zcity/f/female_02.mdl") -- female 02
AddFacemap(female02facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/kanisha_cylmap")
for i = 2, 6 do
	AddFacemap(female02facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/kanisha_cylmap" .. i)
end

local female03facemap = "models/humans/female/group01/kim_facemap"
AddFacemap(female03facemap, "Default", "", "models/zcity/f/female_03.mdl") -- female 03
AddFacemap(female03facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/kim_facemap")
AddFacemap(female03facemap, "Face " .. 5, "models/bloo_ltcom_zel/citizens/facemaps/kim_facemap" .. 6)
for i = 2, 4 do
	AddFacemap(female03facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/kim_facemap" .. i)
end

local female04facemap = "models/humans/female/group01/chau_facemap"
AddFacemap(female04facemap, "Default", "", "models/zcity/f/female_04.mdl") -- female 04
AddFacemap(female04facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/chau_facemap")
for i = 2, 5 do
	AddFacemap(female04facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/chau_facemap" .. i)
end

local female05facemap = "models/humans/female/group01/naomi_facemap"
AddFacemap(female05facemap, "Default", "", "models/zcity/f/female_07.mdl") -- female 05 -- why it's female 07... idk dude
AddFacemap(female05facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/naomi_facemap")
for i = 2, 6 do
	AddFacemap(female05facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/naomi_facemap" .. i)
end

local female06facemap = "models/humans/female/group01/lakeetra_facemap"
AddFacemap(female06facemap, "Default", "", "models/zcity/f/female_06.mdl") -- female 06
AddFacemap(female06facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/lakeetra_facemap")
for i = 2, 5 do
	AddFacemap(female06facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/lakeetra_facemap" .. i)
end

-----------------------------------Male--------------------------------------------------
local male01facemap = "models/humans/male/group01/van_facemap"
AddFacemap(male01facemap, "Default", "", "models/zcity/m/male_01.mdl") -- male 01
AddFacemap(male01facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/van_facemap")
for i = 2, 8 do
	AddFacemap(male01facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/van_facemap" .. i)
end

local male02facemap = "models/humans/male/group01/ted_facemap"
AddFacemap(male02facemap, "Default", "", "models/zcity/m/male_02.mdl") -- male 02
AddFacemap(male02facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/ted_facemap")
for i = 2, 10 do
	AddFacemap(male02facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/ted_facemap" .. i)
end

local male03facemap = "models/humans/male/group01/joe_facemap"
AddFacemap(male03facemap, "Default", "", "models/zcity/m/male_03.mdl") -- male 03
AddFacemap(male03facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/joe_facemap")
for i = 2, 9 do
	AddFacemap(male03facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/joe_facemap" .. i)
end

local male04facemap = "models/humans/male/group01/eric_facemap"
AddFacemap(male04facemap, "Default", "", "models/zcity/m/male_04.mdl") -- male 04
AddFacemap(male04facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/eric_facemap")
for i = 2, 9 do
	AddFacemap(male04facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/eric_facemap" .. i)
end

local male05facemap = "models/humans/male/group01/art_facemap"
AddFacemap(male05facemap, "Default", "", "models/zcity/m/male_05.mdl") -- male 05
AddFacemap(male05facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/art_facemap")
for i = 2, 9 do
	AddFacemap(male05facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/art_facemap" .. i)
end

local male06facemap = "models/humans/male/group01/sandro_facemap"
AddFacemap(male06facemap, "Default", "", "models/zcity/m/male_06.mdl") -- male 06
AddFacemap(male06facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/sandro_facemap")
for i = 2, 10 do
	AddFacemap(male06facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/sandro_facemap" .. i)
end

local male07facemap = "models/humans/male/group01/mike_facemap"
AddFacemap(male07facemap, "Default", "", "models/zcity/m/male_07.mdl") -- male 07
AddFacemap(male07facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/mike_facemap")
for i = 2, 8 do
	AddFacemap(male07facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/mike_facemap" .. i)
end

local male08facemap = "models/humans/male/group01/vance_facemap"
AddFacemap(male08facemap, "Default", "", "models/zcity/m/male_08.mdl") -- male 08
AddFacemap(male08facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/vance_facemap")
for i = 2, 9 do
	AddFacemap(male08facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/vance_facemap" .. i)
end

local male09facemap = "models/humans/male/group01/erdim_cylmap"
AddFacemap(male09facemap, "Default", "", "models/zcity/m/male_09.mdl") -- male 09
AddFacemap(male09facemap, "Face 1", "models/bloo_ltcom_zel/citizens/facemaps/erdim_facemap")
for i = 2, 11 do
	AddFacemap(male09facemap, "Face " .. i, "models/bloo_ltcom_zel/citizens/facemaps/erdim_facemap" .. i)
end

-- Bodygroups
hg.Appearance.Bodygroups = hg.Appearance.Bodygroups or {
	HANDS = {
		[1] = {
			["None"] = {"hands", false},
		},
		[2] = {
			["None"] = {"hands", false},
		},
	}
}

--lua_run Player(682):PS_AddItem("Standard_BodyGroups_Wool fingerless")
local function AppAddBodygroup(strBodyGroup, strName, strStringID, bFemale, bPointShop, bDonateOnly, fCost, psModel, psBodygroups, psSubmats, psStrNameOveride)
	local pointShopID = "Standard_BodyGroups_" .. (psStrNameOveride or strName)
	hg.Appearance.Bodygroups[strBodyGroup] = hg.Appearance.Bodygroups[strBodyGroup] or {}
	hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1] = hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1] or {}
	hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1][strName] = {
		strStringID,
		bPointShop,
		ID = pointShopID
	}

	PLUGIN:CreateItem(pointShopID, string.NiceName(strName), psModel or "models/zcity/gloves/degloves.mdl", psBodygroups, 0, Vector(0, 0, 0), fCost, bDonateOnly, psSubmats or {})
end

local function AddBodygroupsFunc()
	AppAddBodygroup("HANDS", "Gloves", "reggloves_FIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 0)
	AppAddBodygroup("HANDS", "Gloves", "reggloves_FIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 0)
	AppAddBodygroup("HANDS", "Gloves fingerless", "reggloves_outFIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 1)
	AppAddBodygroup("HANDS", "Gloves fingerless", "reggloves_outFIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 1)
	AppAddBodygroup("HANDS", "Skilet", "sceletgloves_FIN_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 0, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Skilet", "sceletgloves_FIN_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 0, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Skilet fingerless", "sceletgloves_outFIN_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 1, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Skilet fingerless", "sceletgloves_outFIN_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 1, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Winter", "wingloves_FIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 2, nil, "Bikers")
	AppAddBodygroup("HANDS", "Winter", "wingloves_FIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 2, nil, "Bikers")
	AppAddBodygroup("HANDS", "Winter fingerless", "wingloves_outFIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 3, nil, "Bikers fingerless")
	AppAddBodygroup("HANDS", "Winter fingerless", "wingloves_outFIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 3, nil, "Bikers fingerless")
	AppAddBodygroup("HANDS", "Bikers gloves", "biker_gloves_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 5)
	AppAddBodygroup("HANDS", "Bikers gloves", "biker_gloves_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 5)
	AppAddBodygroup("HANDS", "Bikers wool", "bikerwool_gloves_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 6, nil)
	AppAddBodygroup("HANDS", "Bikers wool", "bikerwool_gloves_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 6, nil)
	AppAddBodygroup("HANDS", "Wool fingerless", "wool_glove_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 7, nil)
	AppAddBodygroup("HANDS", "Wool fingerless", "wool_gloves_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 7, nil)
	AppAddBodygroup("HANDS", "Mitten wool", "mittenwool_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 8, nil)
	AppAddBodygroup("HANDS", "Mitten wool", "mittenwool_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 8, nil)
end

hook.Add("ZPointshopLoaded", "AddBodygroups", AddBodygroupsFunc)
-- SkeletonTable
hg.Appearance.SkeletonAppearanceTable = {
	AModel = "Male 07",
	AClothes = {
		main = "normal"
	},
	AName = "John Z-City", -- JOHN GMOD
	AColor = Color(180, 0, 0),
	AAttachments = {},
	ABodygroups = {},
	AFacemap = "Default"
}

-- GetRandomAppearance
function hg.Appearance.GetRandomAppearance()
	local randomAppearance = table.Copy(hg.Appearance.SkeletonAppearanceTable)
	local iSex = math.random(1, 2)
	local tMdl, str = table.Random(PlayerModels[iSex])
	randomAppearance.AModel = str
	_, str = table.Random(hg.Appearance.Clothes[iSex])
	randomAppearance.AClothes = {
		main = str,
		pants = str,
		boots = str
	}

	randomAppearance.AName = GenerateRandomName(iSex)
	randomAppearance.AColor = ColorRand(false)
	for i = 1, 1 do
		local data, k = table.Random(hg.Accessories)
		for ii, name in ipairs(randomAppearance.AAttachments) do
			if hg.Accessories[name].placement == data.placement then k = "none" end
		end

		if data.disallowinappearance then k = "none" end
		randomAppearance.AAttachments[i] = k
	end

	local _, facemap = table.Random(hg.Appearance.FacemapsSlots[hg.Appearance.FacemapsModels[tMdl.mdl]])
	randomAppearance.AFacemap = facemap
	return randomAppearance
end

-- Validator
hg.Appearance.ValidateFunctions = {
	AModel = function(str)
		if not isstring(str) then return false end
		if not PlayerModels[1][str] and not PlayerModels[2][str] then return false end
		return true
	end,
	AClothes = function(tbl)
		if not istable(tbl) then return false end
		if table.Count(tbl) > 3 then return false end
		--for k, v in ipairs(tbl) do
		--    if !hg.Appearance.Clothes[1][v] and !hg.Appearance.Clothes[2][v] then return false end
		--end
		return true
	end,
	AName = function(str)
		if not isstring(str) then return false end
		return not IsInvalidName(str)
	end,
	AColor = function(clr)
		--if !IsColor(clr) then return false end
		return true
	end,
	AAttachments = function(tbl)
		if not istable(tbl) then return false end
		if table.Count(tbl) > 3 then return false, "Too many" end
		local occupatedSlots = {}
		--local removeReasons = ""
		for k, v in ipairs(tbl) do
			if not hg.Accessories[v] then
				--removeReasons = removeReasons + v + " - invalid accsesory\n" or "\n"  tbl[k] = ""
				continue
			end

			if occupatedSlots[hg.Accessories[v].placement] then
				tbl[k] = ""
				--removeReasons = removeReasons + v + " - removed occupeated slot accsesory\n" or "\n"
				continue
			end

			if hg.Accessories[v].placement then occupatedSlots[hg.Accessories[v].placement] = true end
		end
		return true --, removeReasons
	end,
	ABodygroups = function(tbl)
		if not istable(tbl) then return false end
		if table.Count(tbl) > 3 then return false end
		return true
	end,
	AFacemap = function(str) if not isstring(str) then return false end end
}

local function AppearanceValidater(tblAppearance)
	local VaildFuncs = hg.Appearance.ValidateFunctions
	local bValidAModel = VaildFuncs.AModel(tblAppearance.AModel)
	local bValidAClothes = VaildFuncs.AClothes(tblAppearance.AClothes)
	local bValidAName = VaildFuncs.AName(tblAppearance.AName)
	local bValidAColor = VaildFuncs.AColor(tblAppearance.AColor)
	local bValidAAttachments = VaildFuncs.AAttachments(tblAppearance.AAttachments)
	--print(bValidAModel,bValidAClothes,bValidAName,bValidAColor,bValidAAttachments)
	if bValidAModel and bValidAClothes and bValidAName and bValidAColor and bValidAAttachments then return true end
	return false
end

hg.Appearance.AppearanceValidater = AppearanceValidater
function ThatPlyIsFemale(ply)
	ply.CahceModel = ply.CahceModel or ""
	if ply.CahceModel == ply:GetModel() then return ply.bSex end
	local tSubModels = ply:GetSubModels()
	if not tSubModels then return false end
	ply.CahceModel = ply:GetModel()
	for i = 1, #tSubModels do
		local name = tSubModels[i]["name"]
		if name == "models/m_anm.mdl" then
			ply.bSex = false
			return false
		end

		if name == "models/f_anm.mdl" then
			ply.bSex = true
			return true
		end
	end
	return false
end

local plymeta = FindMetaTable("Player")
function plymeta:GetSubMaterialSlots()
	local tMdl = hg.Appearance.FuckYouModels[1][self:GetModel()] or hg.Appearance.FuckYouModels[2][self:GetModel()]
	local mats = self:GetMaterials()
	local slots = {}
	if istable(tMdl) then
		for k, v in pairs(tMdl.submatSlots) do
			local slot = 1
			for i = 1, #mats do
				if mats[i] == v then
					slot = i - 1
					break
				end
			end

			slots[#slots + 1] = slot
		end
	end
	return slots
end

function plymeta:GetSubMaterialIdByName(strName)
	local mats = self:GetMaterials()
	local id = false
	for i = 1, #mats do
		if mats[i] == strName then
			id = i - 1
			break
		end
	end
	return id
end

-- function plymeta:GetFacemapSlot()
-- end