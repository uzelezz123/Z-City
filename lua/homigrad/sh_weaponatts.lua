hg.attachments = {}
hg.attachments.sight = {
	["empty"] = {"sight", "", Angle(0, 0, 0), {}},
	["holo0"] = {
		"sight", -- integrated
		"",
		Angle(0, 0, 0),
		{}
	},
	["holo1"] = {
		"sight",
		"models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.5, 0, 9),
		{
			--[1] = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass"
		},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",
		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_eotech_xps3-2_marks.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1,
		holo_lum = 0.1,
		valid = true,
	},
	["holo2"] = {
		"sight",
		"models/weapons/tfa_ins2/upgrades/phy_optic_kobra.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.3, -0.03, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/tfa_ins2/optics/kobra_lense",
		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_aksion_ekp_8_18_marks_03a"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		valid = true,
	},
	["holo3"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_sig_romeo_8t.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.45, -0.03, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_sig_romeo_8t_lod0_mark.png"),
		holo_size = CLIENT and ScreenScale(0.45) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo4"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_walther_mrs.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0.02, -0.05),
		offsetView = Vector(-1.4, -0.03, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_walther_mrs_mark_001.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo5"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_ekb_okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.05),
		offsetView = Vector(-1.2, 0.1, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_ekb_okp7_true_marks.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo5fur"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_ekb_okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.05),
		offsetView = Vector(-1.2, 0.1, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/reticles/okp.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo6"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(-2, 0.25, 0.2),
		offsetView = Vector(-0.75, 0.2, 6),
		{},
		mountType = "dovetail",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_ekb_okp7_true_marks.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 2),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo6fur"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(-2, 0.25, 0.2),
		offsetView = Vector(-0.75, 0.2, 6),
		{},
		mountType = "dovetail",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/reticles/okp.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 2),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo7"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_belomo_pk_06.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, -0.05),
		offsetView = Vector(-1.1, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_belomo_pk_06_mark_000.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo8"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_holosun_hs401g5.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-1.4, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_aimpoint_micro_h1_high_marks.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		holo_lum = 0.1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo9"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_leapers_utg_38_ita_1x30.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-1, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_leapers_utg_38_ita_1x30_mark2.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo11"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_trijicon_srs_02.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0.1, 0),
		offsetView = Vector(-1.5, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_aimpoint_micro_h1_high_marks.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo12"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_valday_1p87.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-2, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("zcity/holo/1p87_ret_b_ca.png"),
		holo_size = CLIENT and ScreenScale(1.1) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo13"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_valday_krechet.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-2.35, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("zcity/holo/1p87_ret_a_ca.png"),
		holo_size = CLIENT and ScreenScale(1.5) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo14"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/eft_optic_xps3_0.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.05),
		offsetView = Vector(-1.45, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_eotech_xps3-4_marks.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo15"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_base_sig_romeo_4.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0.8, -0.05),
		offsetView = Vector(-0.75, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_sig_romeo_4_base_weaver.mdl",
		mountVec = Vector(0.2, 0, -0.78),
		mountAng = Angle(0, 0, 0),

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_sig_romeo_4_mark.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo16"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_base_trijicon_rmr.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 1, -0.05),
		offsetView = Vector(-0.55, 0, 10),
		{},
		mountType = "pistolmount",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_sig_romeo_4_mark.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
			vecadd:Add(ang:Forward()*-self.shooanim*self.SightSlideOffset)
		end,
		valid = true,
	},
	["holo17"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_compact_prism.mdl",
		Angle(180, 0, -90),
		offset = Vector(0, 0, -0.02),
		offsetView = Vector(-1.4, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "effects/arc9/rt",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_sig_romeo_4_mark.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["optic0"] = {
		"sight", --встроенный
		"",
		Angle(0, 0, 0),
		{},
	},
	["optic2"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_fullfield_tac30.mdl",
		Angle(0, 0, -90),
		offset = Vector(2, 1.5, -0.025),
		offsetView = Vector(0, 0, 12),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_30mm_burris_fullfield_tac30_1_4x24_marks.png"),
		localScopePos = Vector(2, 0, 0),
		scope_blackout = 2000,
		rot = 0,
		FOVMin = 6,
		FOVMax = 28,
		FOVScoped = 40,
		blackoutsize = 4000,
		sizeperekrestie = 2200,
		perekrestieSize = true,
		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_geissele_super_precision.mdl",
		mountVec = Vector(-3, 0, -1.5),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic3"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_valday_ps320.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.5, 0, 7),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("decals/perekrestie11.png"),
		localScopePos = Vector(2, 0, 1.5),
		scope_blackout = 1400,
		rot = 0,
		FOVMin = 3,
		FOVMax = 10,
		FOVScoped = 40,
		blackoutsize = 4000,
		sizeperekrestie = 3548,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		perekrestieSize = false,

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic4"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/pso1m2.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(-2, 0, 0.3),
		offsetView = Vector(-0.8, 0.56, 7.5),
		mountType = "dovetail",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_dovetail_belomo_pso_1_4x24_marks_0.png"),
		localScopePos = Vector(12, 0.56, 0.8),
		scope_blackout = 1500,
		rot = 0,
		FOVMin = 12,
		FOVMax = 12,
		FOVScoped = 40,
		blackoutsize = 4200,
		sizeperekrestie = 2000,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		perekrestieSize = true,

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic5"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_razor_hd.mdl",
		Angle(0, 0, -90),
		offset = Vector(2, 1.5, -0.03),
		offsetView = Vector(0, 0, 12),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_30mm_razor_hd_gen_2_1_6x24_mark.png"),
		localScopePos = Vector(2, 0, 0),
		scope_blackout = 2000,
		rot = 0,
		FOVMin = 6,
		FOVMax = 28,
		FOVScoped = 20,
		blackoutsize = 3700,
		sizeperekrestie = 3200,
		perekrestieSize = true,
		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_geissele_super_precision.mdl",
		mountVec = Vector(-3, 0, -1.6),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic6"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_leupold_mark4.mdl",
		Angle(0, 0, -90),
		offset = Vector(2, 1.5, -0.03),
		offsetView = Vector(0, 0, 12),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/adjustable/scope_35mm_leupold_mark_5hd_5_25x56_mark_f.png"),
		localScopePos = Vector(0, 0, 0),
		scope_blackout = 3400,
		rot = 0,
		FOVMin = 2,
		FOVMax = 10,
		FOVScoped = 40,
		blackoutsize = 3800,
		sizeperekrestie = 2000,
		perekrestieSize = false,
		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_lobaev_dvl.mdl",
		mountVec = Vector(-1.8, 0, -1.5),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic7"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_sig_bravo4.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.02),
		offsetView = Vector(-1.35, 0, 8),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_all_sig_bravo4_4x30_marks.png"),
		localScopePos = Vector(0, 0, 1.36),
		scope_blackout = 1500,
		rot = 0,
		FOVMin = 11,
		FOVMax = 11,
		FOVScoped = 40,
		blackoutsize = 4500,
		sizeperekrestie = 2100,
		perekrestieSize = true,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic8"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_leupold_mark4_hamr.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.025),
		offsetView = Vector(-1.65, 0, 7),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_all_leupold_mark4_hamr_marks.png"),
		localScopePos = Vector(7, 0, 1.65),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 16,
		FOVMax = 16,
		FOVScoped = 40,
		blackoutsize = 4000,
		sizeperekrestie = 2500,
		perekrestieSize = false,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_walther_mrs_mark_001.png"),
		holo_size = CLIENT and ScreenScale(0.45) or 1, --size of the holo

		holomodel = "models/weapons/arc9/darsu_eft/mods/scope_base_burris_fast_fire_3.mdl",
		addholovec = Vector(0.4,0,2.3),
		addholoang = Angle(0,0,0),
		drawFunction = function(self,model) -- in swep:drawattachment
			if not IsValid(self) then return end

			self.modelAtt["addholo"] = IsValid(self.modelAtt["addholo"]) and self.modelAtt["addholo"] or ClientsideModel(hg.attachments.sight["optic8"].holomodel)
			local addholo = self.modelAtt["addholo"]

			addholo:DrawModel()
			addholo:SetNoDraw(model:GetNoDraw())

			local model2 = addholo.model
			if not IsValid(model2) then
				model2 = ClientsideModel(hg.attachments.sight["optic8"].holomodel)
				addholo.model = model2
				
				self.holomodels = self.holomodels or {}
				self.holomodels[model2] = true
	
				model:CallOnRemove("removeshithole",function()
					self.holomodels = self.holomodels or {}
					
					if self.holomodels then
						self.holomodels[model2] = nil
					end

					if IsValid(model2) then
						model2:Remove()
					end
				end)
	
			end
			if not addholo.submat then
				addholo:SetSubMaterial(0,"null")
				addholo:SetSubMaterial(1,"white")
		
				model2:SetSubMaterial(0,"")
				model2:SetSubMaterial(1,"null")
				addholo.submat = true
			end
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		viewFunction = function(self,model,pos)
			if self:KeyDown(IN_ATTACK2) then
				if (IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_JUMP)) or (!IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_USE)) then
					if not self.keypr then
						self.viewmode1 = not self.viewmode1
						self.keypr = true
						self:EmitSound("universal/uni_lean_"..(self.viewmode1 and "in" or "out").."_0"..math.random(4)..".wav",35,math.random(95,105))
					end
				else
					self.keypr = false
				end
			end

			local ang = model:GetAngles()

			if self.viewmode1 then
				self.upview = Lerp(FrameTime()*12, self.upview or 0, 1.3)
			else
				self.upview = Lerp(FrameTime()*4, self.upview or 0, 0)
			end

			pos = pos + ang:Up() * self.upview

			return pos
		end,

		transformFunction = function(self,model,pos,ang) -- in transformfunction
			if not IsValid(self) then return end
			self.modelAtt["addholo"] = self.modelAtt["addholo"] or ClientsideModel(hg.attachments.sight["optic8"].holomodel)
			local addholo = self.modelAtt["addholo"]
			local inf = hg.attachments.sight["optic8"]
			local pos,ang = LocalToWorld(inf.addholovec,inf.addholoang,pos,ang)
			if not IsValid(addholo) then return end
			addholo:SetRenderOrigin(pos)
			addholo:SetRenderAngles(ang)
			addholo:SetModelScale(1.2)
			addholo:SetupBones()

			if IsValid(addholo.model) then
				addholo.model:SetRenderOrigin(pos)
				addholo.model:SetRenderAngles(ang)
				addholo.model:SetModelScale(1.2)
				addholo.model:SetupBones()
			end
		end,
		valid = true,
	},
	["optic9"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/scope/eft_scope_ta01.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0.3, -0.03),
		offsetView = Vector(-1.35, 0, 8),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/eft_reticle_ta01.png"),
		localScopePos = Vector(0, 0, 1.35),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 7,
		FOVMax = 7,
		FOVScoped = 40,
		blackoutsize = 4700,
		sizeperekrestie = 4500,
		perekrestieSize = true,

		mount = "models/weapons/arc9/darsu_eft/mods/mount_vulcan_gen3.mdl",
		mountVec = Vector(-0.9, 0, -0.3),
		mountAng = Angle(0, -180, 0),

		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic11"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/pso1m2.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(-2, 0, 0.3),
		offsetView = Vector(-0.8, 0.56, 7.5),
		mountType = "dovetail",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_dovetail_belomo_pso_1m2_1_4x24_marks_0.png"),
		localScopePos = Vector(12, 0.56, 0.8),
		scope_blackout = 1500,
		rot = 0,
		FOVMin = 12,
		FOVMax = 12,
		FOVScoped = 40,
		blackoutsize = 4200,
		sizeperekrestie = 2000,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),


		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic12"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_eotech_vudu.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(2.5, 0.2, 0),
		offsetView = Vector(0, 0, 14),
		mountType = "kar98mount",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_25_4mm_vomz_pilad_4x32m_mark.png"),
		localScopePos = Vector(-0, 0, 0),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 8,
		FOVMax = 8,
		FOVScoped = 40,
		blackoutsize = 3500,
		sizeperekrestie = 5000,
		perekrestieSize = false,

		mount = "models/weapons/arc9_eft_shared/atts/mounts/mount_dovetail_sag_bit_bracket.mdl",
		mountVec = Vector(-2, 1, -1.5),
		mountAng = Angle(15, 90, 0),

		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		viewFunction = function(self,model,pos)
			do return pos end

			if self:KeyDown(IN_ATTACK2) then
				if (IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_JUMP)) or (!IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_USE)) then
					if not self.keypr then
						self.viewmode1 = not self.viewmode1
						self.keypr = true
						self:EmitSound("universal/uni_lean_"..(self.viewmode1 and "in" or "out").."_0"..math.random(4)..".wav",35,math.random(95,105))
					end
				else
					self.keypr = false
				end
			end

			local ang = model:GetAngles()

			if self.viewmode1 then
				self.upview = Lerp(FrameTime()*7, self.upview or 0, -0.97)
			else
				self.upview = Lerp(FrameTime()*4, self.upview or 0, 0)
			end

			pos = pos + ang:Up() * self.upview

			return pos
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic13"] = {
		"sight",
		"models/escape from tarkov/static/weapons/npz pag-17.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		offsetView = Vector(-25.5,3.1,9),
		mountType = "agsmount",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_base_kmz_1p59_3_10x_mark_3x.png"),
		localScopePos = Vector(0,3.1,25.5),
		scope_blackout = 2200,
		rot = 0,
		FOVMin = 9,
		FOVMax = 9,
		FOVScoped = 40,
		blackoutsize = 2200,
		sizeperekrestie = 6000,
		perekrestieSize = true,

		drawFunction = function(self,model) -- in swep:drawattachment
			if not model.submated then
				model:SetSubMaterial(1,"effects/arc9/rt")
				model.submated = true
			end
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
	},
	["ironsight1"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/ironsight/eft_rearsight_mbus.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, 0),
		offsetView = Vector(-1.4, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		mount = "models/weapons/arc9_eft_shared/atts/ironsight/eft_frontsight_mbus.mdl",
		mountVec = Vector(11.5, 0, 0),
		mountAng = Angle(0, 180, 0),
		valid = true,
	},
	["ironsight2"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/ironsight/eft_rearsight_a2.mdl",
		Angle(0, 0, -90),
		offset = Vector(-4.3, 0, -0.05),
		offsetView = Vector(-1.39, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["ironsight3"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/fs_a2.mdl",
		Angle(0, 0, -90),
		offset = Vector(8, 0, 0),
		offsetView = Vector(-1.5, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["ironsight4"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/ironsight/eft_rearsight_mbus.mdl",
		Angle(0, 0, -90),
		offset = Vector(-2.5, 0, 0),
		offsetView = Vector(-1.4, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		mount = "models/weapons/arc9_eft_shared/atts/ironsight/eft_frontsight_mbus.mdl",
		mountVec = Vector(10, 0, 0),
		mountAng = Angle(0, 180, 0),
		valid = true,
	},
}

function hg.attachmentFunc(self, attachmentData)
	self.size = attachmentData.size or self.size
	self.holo_pos = attachmentData.holo_pos or self.holo_pos
	self.scale = attachmentData.scale or self.scale
	self.holo = attachmentData.holo or self.holo
	self.holo_size = attachmentData.holo_size or self.holo_size
	self.holo_lum = attachmentData.holo_lum or self.holo_lum
	--self.holo_view = curAtt[4] or self.holo_view
	if attachmentData.perekrestieSize ~= nil then
		self.perekrestieSize = attachmentData.perekrestieSize
	end
	self.mat = attachmentData.mat or self.mat
	self.scopemat = attachmentData.scopemat or self.scopemat
	self.perekrestie = attachmentData.perekrestie or self.perekrestie
	self.localScopePos = attachmentData.localScopePos or self.localScopePos
	self.scope_blackout = attachmentData.scope_blackout or self.scope_blackout
	self.rot = attachmentData.rot or self.rot
	self.FOVMin = attachmentData.FOVMin or self.FOVMin
	self.FOVMax = attachmentData.FOVMax or self.FOVMax
	self.FOVScoped = attachmentData.FOVScoped or self.FOVScoped
	self.blackoutsize = attachmentData.blackoutsize or self.blackoutsize
	self.sizeperekrestie = attachmentData.sizeperekrestie or self.sizeperekrestie
end

hg.attachments.mount = {
	["empty"] = {"mount", "", Angle(0, 0, 0), {}},
	["mount1"] = {
		"mount",
		"models/wystan/attachments/akrailmount.mdl",
		Angle(90, -0, -90),
		{
			[0] = "pwb/models/weapons/w_akm/akm"
		}
	},
	["mount2"] = {"mount", "models/weapons/arc9/darsu_eft/mods/mount_all_larue_picatinny_raiser_qd_lt101.mdl", Angle(0, -0, -90), {}},
	["mount3"] = {"mount", "models/weapons/arc9_eft_shared/atts/mounts/mount_dovetail_pilad.mdl", Angle(90, 0, -90), {}},
	["mount4"] = {"mount", "models/weapons/arc9/darsu_eft/mods/tac_pistol_um3.mdl", Angle(0, 0, 90), {}}
}

hg.attachments.barrel = {
	["empty"] = {"barrel", "", Angle(0, 0, 0), {}},
	["supressor0"] = { -- with 0 key attachment can't be seen in menus, removed, etc.
		"barrel", -- integrated
		"",
		Angle(0, 0, 0),
		{}
	},
	["supressor1"] = {"barrel","models/weapons/upgrades/a_suppressor_ak.mdl", Angle(0, 0, 0), {},offset = Vector(0.1, -0.5, -0.2),valid = true,},
	["supressor2"] = {"barrel", "models/cw2/attachments/556suppressor.mdl", Angle(0, 90, 0), {},offset = Vector(4 - 17 - 4, 0.55 - 1, -3.15),valid = true,},
	["supressor3"] = {"barrel", "models/weapons/tfa_ins2/upgrades/usp_match/w_suppressor_pistol.mdl", Angle(0, 0, -90), {},offset = Vector(-7+1, -3.4+0.5, 0),valid = true,},
	["supressor4"] = {"barrel", "models/cw2/attachments/9mmsuppressor.mdl", Angle(0, -90, 0), {},offset = Vector(4, -0.4, -1.25),valid = true,},
	["supressor5"] = {"barrel", "models/weapons/tfa_ins2/upgrades/att_suppressor_12ga.mdl", Angle(0, 0, 0), {},offset = Vector(-31, 2.2, 1.85),valid = true,},
	["supressor6"] = {"barrel", "models/atts/homemadesuppressor/plastic_bottle_1.mdl", Angle(-90, 0, 0), {}, modelscale = 0.75, offset = Vector(11.5,-0.5,-0.1),},
	["supressor7"] = {
		"barrel", "models/weapons/arc9/darsu_eft/mods/silencer_base_sig_srd_762_qd_762x51.mdl", 
		Angle(0, 0, 0), 
		{}, 
		modelscale = 1, 
		offset = Vector(-1.5,0.1,0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	["supressor8"] = {
		"barrel", "models/weapons/arc9_eft_shared/atts/muzzle/silencer_mount_silencerco_hybrid_46_multi.mdl", 
		Angle(0, 0, 0), 
		{}, 
		modelscale = 1, 
		offset = Vector(-1.5,0.1,0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	}
}

hg.attachments.grip = {
	["grip1"] = {
		"grip",
		"models/weapons/arc9/darsu_eft/mods/fg_rk2.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-16.9, -1.3, -0.15),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3,1.8,-3.2),
		LHandAng = Angle(-20,-15,14),
		hold = "grip_hold",
		valid = true,
	}, -- models/weapons/arc9/darsu_eft/mods/fg_ash12.mdl
	["grip2"] = {
		"grip",
		"models/weapons/arc9/darsu_eft/mods/fg_ash12.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-17, -1.4, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3,1.8,-3.2),
		LHandAng = Angle(-20,-15,14),
		hold = "grip_hold",
		valid = true,
	},
	["grip3"] = {
		"grip",
		"models/weapons/arc9/darsu_eft/mods/fg_afg.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-18, -1.6, 0),
		holdtype = "ar2",
		mountType = "picatinny",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-2,1.5,-1.2),
		LHandAng = Angle(0,0,-15),
		valid = true,
		hold = "grip_hold",
	},
	["grip_ak740"] = {
		"grip",
		"models/weapons/ins/upgrades/a_standard_ak74.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "ak74",
		recoilReduction = 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(0,0,0),
		LHandAng = Angle(0,0,0),
		ShouldtUseLHand = true,
		bBonemerge = true,
		norenderWhenDrop = true,
	},
	["grip1_ak740"] = {
		"grip",
		"models/weapons/ins/upgrades/a_woodgrips_ak74.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "ak74",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(0,0,0),
		LHandAng = Angle(0,0,0),
		bBonemerge = true,
		norenderWhenDrop = true,
		hold = "grip_hold",
	},
	["grip_ak120"] = {
		"grip",
		"models/weapons/zcity/upgrades/a_standard_ak12u.mdl",
		Angle(180, 0, 90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "ak12",
		recoilReduction = 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(15,-1.2,-3),
		LHandAng = Angle(20,30,20),
		ShouldtUseLHand = true,
		bBonemerge = true,
		norenderWhenDrop = true,
	},
	["grip_akm0"] = { -- with 0 key attachment can't be seen in menus, removed, etc.
		"grip",
		"models/weapons/upgrades/a_standard_akm.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "akm",
		recoilReduction = 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(0,0,0),
		LHandAng = Angle(0,0,0),
		ShouldtUseLHand = true,
		bBonemerge = true,
		norenderWhenDrop = true,
	},
	["grip_akdong"] = {
		"grip",
		"models/weapons/upgrades/a_woodgrips_aks74u.mdl",
		Angle(0, 0, -90),
		{
			[0] = "null"
		},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "ak74",
		recoilReduction = 0.6,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-0.8,1.5,-3.6),
		LHandAng = Angle(-30,-10,15),
		ShouldtUseLHand = false,
		bBonemerge = false,
		norenderWhenDrop = true,
		hold = "grip_hold",
	},
}

hg.attachments.underbarrel = {
	["lasertaser0"] = { -- with 0 key attachment can't be seen in menus, removed, etc.
		"underbarrel", -- integrated
		(CLIENT and "models/hunter/plates/plate.mdl") or "",
		Angle(0, -8, 0),
		{
			[0] = "null"
		},
		offset = Vector(-2, 1.9, 0.2),
		offsetPos = Vector(0, -0, 0),
		color = Color(255, 0, 0, 250),
		supportFlashlight = true,
		mat = nil,
		farZ = 300,
		size = 40,
		brightness = 20,
		brightness2 = 0,
		shouldalwaysdraw = true,
	},
	["laser1"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_ncstar_tbl.mdl",
		Angle(180, 180, -180),
		{},
		offset = Vector(-13.8, 0.2, 1),
		offsetPos = Vector(0, -0, 0.73),
		offsetAng = Angle(1, 0, 0),
		mountType = "picatinny_small",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(75, 0, 146, 90),
		shouldalwaysdraw = true,
		valid = true,
	},
	["laser2"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_kleh2.mdl",
		Angle(180, 180, -180),
		{},
		offset = Vector(-13.9, 0.2, 1),
		offsetPos = Vector(0, -0, 0.73),
		offsetAng = Angle(1, 0, 0),
		mountType = "picatinny_small",
		supportFlashlight = true,
		mat = nil,
		farZ = 1600,
		size = 50,
		brightness = 100,
		brightness2 = 0.2,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(255, 0, 0, 90),
		shouldalwaysdraw = true,
		valid = true,
	},
	["laser3"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_baldr_pro.mdl",
		Angle(180, 180,180),
		{},
		offset = Vector(-13.9, 0.2, 1),
		offsetPos = Vector(0, -0, 0.73),
		mountType = "picatinny_small",
		supportFlashlight = true,
		mat = nil,
		farZ = 1600,
		size = 50,
		brightness = 70,
		brightness2 = 0.3,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(0, 0, 0, 0),
		shouldalwaysdraw = true,
		valid = true,
	},

	--[[
		if not IsValid(lply.EZNVGlamp) then
			lply.EZNVGlamp = ProjectedTexture()
			lply.EZNVGlamp:SetTexture("effects/flashlight001")
			lply.EZNVGlamp:SetBrightness(.05)
		else
			local Ang = EyeAngles()
			lply.EZNVGlamp:SetPos(lply:EyePos())
			lply.EZNVGlamp:SetEnableShadows(false)
			lply.EZNVGlamp:SetAngles(Ang)
			lply.EZNVGlamp:SetConstantAttenuation(.1)
			local FoV = lply:GetFOV()
			lply.EZNVGlamp:SetFOV(FoV+45)
			lply.EZNVGlamp:SetFarZ(150000 / FoV)
			lply.EZNVGlamp:Update()
		end models/weapons/upgrades/a_laser_rail.mdl
	--]]

	["laser4"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_anpeq2.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-16.9, 1, -0.05),
		offsetPos = Vector(0, -0.6, 0.6),
		offsetAng = Angle(0.5, 0, 0),
		offsetView = Vector(-1.5,0,0),
		supportFlashlight = true,
		nvgFlashlight = true,
		mat = nil,
		farZ = 15000,
		size = 90,
		brightness = 0.1,
		brightness2 = 0.05,
		mountType = "picatinny",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(255, 0, 0, 90),
		shouldalwaysdraw = true,
		valid = true,
	},

	["laser5"] = {
		"underbarrel",
		"models/weapons/upgrades/a_laser_rail.mdl",
		Angle(180, 180, 0),
		{},
		offset = Vector(-14, 0, 0.8),
		offsetPos = Vector(0, 0, 0),
		offsetAng = Angle(-1, 0, 0),
		mountType = "picatinny_small",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(255, 0, 0, 200),
		shouldalwaysdraw = true,
		valid = true,
	},

	["laserrpg0"] = {
		"underbarrel", -- integrated
		(CLIENT and "models/hunter/plates/plate.mdl") or "",
		Angle(0, 0, 0),
		{
			[0] = "null"
		},
		offset = Vector(0, 0, 0),
		offsetPos = Vector(0, 0, 0),
		color = Color(255, 0, 0, 255),
		supportFlashlight = false,
		mat = nil,
		farZ = 300,
		size = 40,
		laserSize = 3,
		brightness = 20,
		brightness2 = 0,
		shouldalwaysdraw = true,
	},
}
hg.attachments.magwell = {
	["mag1"] = {
		"magwell",
		"models/weapons/arc9/darsu_eft/mods/mag_glock_drum_50.mdl",
		Angle(180, 180, 90),
		{},
		offsetPos = Vector(0, 0, 0),
		capacity = 50,
		ammotype = "9x19 mm Parabellum",
	},
}
hg.attachments.agsmag = {
	["agsmag0"] = {
		"agsmag",
		"models/escape from tarkov/static/weapons/magazine.mdl",
		Angle(180, 180, 90),
		{},
		offsetPos = Vector(0, 0, 0),
		capacity = 50,
		ammotype = "Grenade 30x29mm",
	}
}

hg.validattachments = {}
for placement, tbl in pairs(hg.attachments) do
	for att, attTbl in pairs(tbl) do
		if attTbl.valid then
			hg.validattachments[placement] = hg.validattachments[placement] or {}
			hg.validattachments[placement][att] = attTbl
		end
	end
end

local attNames = {
	["supressor1"] = "PBS-1",
	["supressor2"] = "Silencerco Saker 556 ASR",
	["supressor3"] = "KAC HK USP-T",
	["supressor4"] = "Gemtech TUNDRA-SV 9mm Supressor",
	["supressor5"] = "Ротор 43 12К",
	["supressor6"] = "Homemade Suppressor",
	["holo1"] = "EOTech 552",
	["holo2"] = "KOBRA ЭКП-8-18",
	["holo17"] = "Aimpoint COMP M2",
	["optic2"] = "Fullfield TAC 30",
	["optic3"] = "Валдай ПС-320 1x/6x",
	["optic4"] = "ПСО-1",
	["optic5"] = "Vortex Razor HD Gen.2 1-6x24",
	["optic11"] = "ПСО-1М2",
	["laser1"] = "TBL Blue Laser",
	["laser2"] = "Klesch Laser + Flashlight",
	["grip1"] = "RK-2",
	["holo3"] = "ROMEO8T",
	["holo4"] = "Walther \"MRS\"",
	["optic6"] = "Leupold Mark 4 LR 6.5-20x50",
	["laser3"] = "Olight \"Baldr Pro\"",
	["laser4"] = "TAC ANPEQ2",
	["optic7"] = "SIG Sauer \"BRAVO4 4X30\"",
	["optic8"] = "Leupold \"Mark 4 HAMR 4x24mm DeltaPoint\"",
	["mag1"] = "Rounded mag Glock18 32 Bullets",
	["grip2"] = "ASh-12 Vertical Grip",
	["grip3"] = "Magpul AFG Tactical Grip",
	["grip_akdong"] = "AK-74 Dong Grip",
	["holo5"] = "\"ОКП-7\"",
	["holo5fur"] = "\"ОКП-7\" Furry",
	["holo6"] = "\"ОКП-7\" Dovetail",
	["holo6fur"] = "\"ОКП-7\" Dovetail Furry",
	["holo7"] = "BelOMO PK-06",
	["holo8"] = "Holosun \"HS401G5\"",
	["holo9"] = "Leapers \"UTG\"",
	["holo11"] = "Trijicon\"SRS-02\"",
	["holo12"] = "Valday PK-120",
	["holo13"] = "Valday Krechet",
	["ironsight1"] = "MBUS backiron and foreiron",
	["ironsight2"] = "M4A1 Iron Sights",
	["ironsight3"] = "M4A1 Foreiron",
	["holo14"] = "EOTech \"XPS3-0\"",
	["optic9"] = "Trijicon \"ACOG TA01NSN 4x32\"",
	["optic12"] = "Sight for kar98k",
	["optic13"] = "PAG-17 optical sight",
	["holo15"] = "SIG Sauer \"ROMEO4\"",
	["supressor7"] = "SIG Sauer \"SRD762-QD\" 7.62x51",
	["holo16"] = "Trijicon \"RMR\"",
	["supressor8"] = "SilencerCo Hybrid 46",
	["grip_ak74"] = "Standart Handle AK-74",
	["grip1_ak74"] = "Grip Handle AK-74",
	["laser5"] = "AccuBow Laser",
}

local attachmentsIcons = {
	["supressor1"] = "vgui/icons/silencer_akm",
	["supressor2"] = "vgui/icons/silencer_assaultrifle",
	["supressor3"] = "vgui/icons/silencer_usp",
	["supressor4"] = "entities/eft_attachments/muzzles/srd9.png",
	["supressor5"] = "entities/eft_attachments/muzzles/rotor.png",
	["supressor6"] = "scrappers/homemadesuppressor.png",
	["supressor7"] = "entities/eft_ar10_attachments/srdqd.png",
	["holo1"] = "vgui/icons/sights_eotech",
	["holo2"] = "vgui/icons/sights_kobra",
	["holo17"] = "entities/eft_attachments/scopes/compm4.png",
	["optic2"] = "entities/eft_attachments/scopes/30mmtac30.png",
	["optic3"] = "entities/eft_attachments/scopes/ps320.png",
	["optic4"] = "entities/eft_attachments/scopes/s_pso1m2.png",
	["optic5"] = "entities/eft_attachments/scopes/30mmrazor.png",
	["laser1"] = "entities/eft_attachments/tactical/tbl.png",
	["laser2"] = "entities/eft_attachments/tactical/k2iks.png",
	["grip1"] = "entities/eft_attachments/foregrips/rk2.png",
	["holo3"] = "entities/eft_attachments/scopes/romeo8t.png",
	["holo4"] = "entities/eft_attachments/scopes/mrs.png",
	["optic6"] = "entities/eft_attachments/scopes/30mmmark4.png",
	["laser3"] = "entities/eft_attachments/tactical/baldr.png",
	["optic7"] = "entities/eft_attachments/scopes/bravo4.png",
	["optic8"] = "entities/eft_attachments/scopes/hamr.png",
	["grip2"] = "entities/eft_attachments/foregrips/ash12.png",
	["grip_akdong"] = "entities/ak74hg.png",
	["holo5"] = "entities/eft_attachments/scopes/okp7.png",
	["holo5fur"] = "entities/eft_attachments/scopes/okp7.png",
	["holo6"] = "entities/eft_attachments/scopes/s_okp.png",
	["holo6fur"] = "entities/eft_attachments/scopes/s_okp.png",
	["holo7"] = "entities/eft_attachments/scopes/pk06.png",
	["holo8"] = "entities/eft_attachments/scopes/hs401g5.png",
	["holo9"] = "entities/eft_attachments/scopes/utg.png",
	["holo11"] = "entities/eft_attachments/scopes/srs02.png",
	["holo12"] = "entities/eft_attachments/scopes/pk120.png",
	["holo13"] = "entities/eft_attachments/scopes/krechet.png",
	["ironsight1"] = "entities/eft_attachments/ironsights/mbus.png",
	["mag1"] = "entities/eft_attachments/mags/eft_mag_drum545.png",
	["holo14"] = "entities/eft_attachments/scopes/xps3.png",
	["optic9"] = "entities/eft_attachments/scopes/ta01nsn.png",
	["optic11"] = "entities/eft_attachments/scopes/s_pso1m2.png",
	["optic12"] = "entities/eft_attachments/scopes/30mmvudu.png",
	["optic13"] = "entities/ent_jack_gmod_ezarmor_pvs14nvm.png",
	["holo15"] = "entities/eft_attachments/scopes/romeo4.png",
	["holo16"] = "entities/eft_attachments/scopes/rmr.png",
	["supressor8"] = "entities/eft_attachments/muzzles/hybridslinecer.png",
	["laser4"] = "vgui/icons/laser_long",
	["laser5"] = "entities/laser.png",
}

local attCategoryNames = {
	["sight"] = "Sights",
	["barrel"] = "Muzzles",
	["underbarrel"] = "Underbarrel",
	["magwell"] = "Magwells",
	["mount"] = "Mounts",
	["grip"] = "Grips"
}
hg.attachmentslaunguage = attNames
hg.attachmentsIcons = attachmentsIcons
local function initAttachments()
	for possibleAtt, attachments in pairs(hg.attachments) do
		for attachment, attData in pairs(attachments) do
			if CLIENT then language.Add(attachment, attNames[attachment] or attachment) end
			local att = {}
			att.Base = "attachment_base"
			att.PrintName = CLIENT and language.GetPhrase(attachment) or attachment
			att.name = attachment
			att.Category = "ZCity Attachments " .. (attCategoryNames[possibleAtt] or "")
			att.Spawnable = not (string.find(attachment, "0") or string.find(attachment, "empty") or string.find(attachment, "mount"))
			att.Model = attData[2]
			att.WorldModel = attData[2]
			att.SubMats = attData[4]
			att.attachment = attData
			att.PhysModel = attData.PhysModel or nil
			att.PhysPos = attData.PhysPos or nil
			att.PhysAng = attData.PhysAng or nil
			att.IconOverride = attachmentsIcons[attachment]
			scripted_ents.Register(att, "ent_att_" .. attachment)
		end
	end
end

function hg.GetAttachmentTab(att)
	local found

	for ia,attPos in pairs(hg.attachments) do
		for i,fatt in pairs(attPos) do
			if i == att then found = ia end
		end
	end

	return found
end

function hg.GiveAttachment(ply,att)
	local att = string.Replace(att,"ent_att_","")
	local inv = ply:GetNetVar("Inventory",{})

	inv["Attachments"] = inv["Attachments"] or {}

	--if not table.HasValue(inv["Attachments"],att) then
	inv["Attachments"][#inv["Attachments"] + 1] = att

	ply:SetNetVar("Inventory",inv)
	--end
end

function hg.NotValidAtt(att)
	local att = isstring(att) and att or istable(att) and isstring(att[1]) and att[1]
	
	if att then
		local att = string.Replace(att,"ent_att_","")

		local valid = false
		for atta, tbl in pairs(hg.validattachments) do
			if tbl[att] and tbl[att].valid then
				valid = true
			end
		end
		
		return not valid
	end

	return true
end

function hg.IsValidAtt(att)
	return not hg.NotValidAtt(att)
end

initAttachments()
hook.Add("Initialize", "init-atts", initAttachments)