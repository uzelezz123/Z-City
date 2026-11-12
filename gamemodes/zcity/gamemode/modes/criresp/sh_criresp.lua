local MODE = MODE

zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.HMCD_CRI_CT = zb.Points.HMCD_CRI_CT or {}
zb.Points.HMCD_CRI_CT.Color = Color(0,0,150)
zb.Points.HMCD_CRI_CT.Name = "HMCD_CRI_CT"

zb.Points.HMCD_CRI_T = zb.Points.HMCD_CRI_T or {}
zb.Points.HMCD_CRI_T.Color = Color(237,13,13)
zb.Points.HMCD_CRI_T.Name = "HMCD_CRI_T"

zb.Points.SNIPERZONE_CRI = zb.Points.SNIPERZONE_CRI or {}
zb.Points.SNIPERZONE_CRI.Color = Color(255,150,0)
zb.Points.SNIPERZONE_CRI.Name = "SNIPERZONE_CRI"

zb.Points.SNIPERZONE_CRI2 = zb.Points.SNIPERZONE_CRI2 or {}
zb.Points.SNIPERZONE_CRI2.Color = Color(255,110,0)
zb.Points.SNIPERZONE_CRI2.Name = "SNIPERZONE_CRI2"

zb.Points.SNIPERZONE_CRI3 = zb.Points.SNIPERZONE_CRI3 or {}
zb.Points.SNIPERZONE_CRI3.Color = Color(255,70,0)
zb.Points.SNIPERZONE_CRI3.Name = "SNIPERZONE_CRI3"

zb.Points.SNIPERZONE_CRI4 = zb.Points.SNIPERZONE_CRI4 or {}
zb.Points.SNIPERZONE_CRI4.Color = Color(255,40,0)
zb.Points.SNIPERZONE_CRI4.Name = "SNIPERZONE_CRI4"

zb.Points.SNIPERSPAWN_CRI = zb.Points.SNIPERSPAWN_CRI or {}
zb.Points.SNIPERSPAWN_CRI.Color = Color(0,220,255)
zb.Points.SNIPERSPAWN_CRI.Name = "SNIPERSPAWN_CRI"

MODE.SWATModel = "models/css_seb_swat/css_swat.mdl"

MODE.SWATPrimaries = {
	{name = "Remington 870", wep = "weapon_remington870"},
	{name = "HK MP5", wep = "weapon_mp5", atts = {"supressor4"}},
	{name = "AR-15", wep = "weapon_ar15", atts = {"holo1", "grip2", "supressor2"}},
}

MODE.SWATPistols = {
	{name = "Beretta M9", wep = "weapon_m9beretta", atts = {"supressor4"}},
	{name = "Beretta PX4", wep = "weapon_px4beretta", atts = {"supressor6"}},
	{name = "Glock 17", wep = "weapon_glock17", atts = {"supressor4"}},
	{name = "Glock 18C", wep = "weapon_glock18c"},
	{name = "Glock 26", wep = "weapon_glock26"},
	{name = "CZ 75", wep = "weapon_cz75", atts = {"supressor4"}},
}

MODE.SWATGear = {
	{name = "Flashbang", item = "weapon_hg_flashbang_tpik"},
}

MODE.SWATGearSlots = 1
MODE.SWATDefaultGear = {1}

MODE.SWATOperatives = {
	{
		id = "atf",
		name = "ATF",
		role = "ATF",
		model = MODE.SWATModel,
		color = Color(0, 0, 190),
		primaries = MODE.SWATPrimaries,
		pistols = MODE.SWATPistols,
	},
	{
		id = "fbi",
		name = "FBI",
		role = "FBI Agent",
		model = "models/player/police.mdl",
		color = Color(30, 80, 200),
		primaries = {
			{name = "HK MP5", wep = "weapon_mp5", atts = {"supressor4"}},
			{name = "Colt 9mm SMG", wep = "weapon_colt9mm"},
			{name = "MAC-11", wep = "weapon_mac11"},
			{name = "PL-15", wep = "weapon_pl15"},
			{name = "PM-9", wep = "weapon_pm9"},
			{name = "Steyr TMP", wep = "weapon_tmp"},
			{name = "TEC-9", wep = "weapon_tec9"},
			{name = "Uzi", wep = "weapon_uzi"},
			{name = "AB-10", wep = "weapon_ab10"},
			{name = "Remington 870", wep = "weapon_remington870"},
			{name = "M16A2", wep = "weapon_m16a2"},
			{name = "AR-15", wep = "weapon_ar15", atts = {"holo1", "grip2", "supressor2"}},
			{name = "M4A1", wep = "weapon_m4a1", atts = {"holo1", "grip2", "supressor2"}},
			{name = "Barrett M98B", wep = "weapon_m98b"},
			{name = "SR25", wep = "weapon_sr25"},
			{name = "SVD", wep = "weapon_svd"},
			{name = "Mosin-Nagant", wep = "weapon_mosin"},
		},
		pistols = {
			{name = "Beretta M9", wep = "weapon_m9beretta", atts = {"supressor4"}},
			{name = "Beretta PX4", wep = "weapon_px4beretta", atts = {"supressor6"}},
			{name = "Glock 17", wep = "weapon_glock17", atts = {"supressor4"}},
			{name = "Glock 18C", wep = "weapon_glock18c"},
			{name = "Glock 26", wep = "weapon_glock26"},
			{name = "CZ 75", wep = "weapon_cz75", atts = {"supressor4"}},
			{name = "CZ 75-A", wep = "weapon_cz75a", atts = {"supressor4"}},
			{name = "HK USP", wep = "weapon_hk_usp"},
			{name = "Makarov", wep = "weapon_makarov"},
		},
	},
	{
		id = "hrt",
		name = "HRT",
		role = "HRT Operator",
		model = "models/player/riot.mdl",
		color = Color(190, 100, 20),
		primaries = {
			{name = "HK MP5", wep = "weapon_mp5", atts = {"supressor4"}},
			{name = "M4A1", wep = "weapon_m4a1", atts = {"holo1", "grip2", "supressor2"}},
			{name = "M16A2", wep = "weapon_m16a2"},
			{name = "HK416", wep = "weapon_hk416", atts = {"holo1", "grip2", "supressor2"}},
			{name = "Remington 870", wep = "weapon_remington870"},
			{name = "Barrett M98B", wep = "weapon_m98b"},
			{name = "SR25", wep = "weapon_sr25"},
			{name = "SVD", wep = "weapon_svd"},
			{name = "Mosin-Nagant", wep = "weapon_mosin"},
		},
		pistols = {
			{name = "Colt M1911", wep = "weapon_m1911"},
			{name = "Glock 17", wep = "weapon_glock17", atts = {"supressor4"}},
			{name = "Glock 18C", wep = "weapon_glock18c"},
			{name = "Glock 26", wep = "weapon_glock26"},
		},
		tasers = {
			{name = "Taser X26", wep = "weapon_taser"},
		},
	},
}