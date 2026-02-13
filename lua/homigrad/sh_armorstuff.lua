hg.armor = {}

local function DrawFirstPersonHelmet(ply, strModel, vecAdjust, fFov, setMat)
	if ply:GetNetVar("headcrab") then return end
	if not ply:Alive() then return end
	if ply.organism and ply.organism.otrub then return end

	if not IsValid(ply.FirstPersonHelmetModel) then
		ply.FirstPersonHelmetModel = ClientsideModel(strModel)
		ply.FirstPersonHelmetModel:SetNoDraw(true)
		return
	end

	if not IsValid(ply.FirstPersonHelmetModel2) then
		ply.FirstPersonHelmetModel2 = ClientsideModel(strModel)
		ply.FirstPersonHelmetModel2:SetNoDraw(true)
		ply.FirstPersonHelmetModel2:SetModelScale(1.05)
		return
	end

	local mdl = ply.FirstPersonHelmetModel
	local mdl2 = ply.FirstPersonHelmetModel2

	if mdl:GetModel() != strModel then
		mdl:SetModel(strModel)
	end

	if mdl2:GetModel() != strModel then
		mdl2:SetModel(strModel)
	end
	
	if setMat and !mdl.matseted1 then
		mdl:SetSubMaterial(0,setMat)
		mdl.matseted = false
		mdl.matseted1 = true
		--print('huy')
	elseif !setMat and !mdl.matseted then
		--print("huy")
		mdl:SetSubMaterial(0,nil)
		mdl.matseted = true
		mdl.matseted1 = false
	end

	local view = render.GetViewSetup()
	cam.Start3D(view.origin,view.angles,view.fov + fFov,nil,nil,nil,nil,1,10)
		--cam.IgnoreZ(true)
		local viewpunching = GetViewPunchAngles() / 2
		local ang = view.angles + viewpunching
		mdl:SetRenderOrigin(view.origin + ang:Forward() * vecAdjust.x + ang:Right() * vecAdjust.y + ang:Up() * vecAdjust.z)
		mdl:SetRenderAngles(ang)
		mdl2:SetRenderOrigin(view.origin + ang:Forward() * vecAdjust.x + ang:Right() * vecAdjust.y + ang:Up() * vecAdjust.z)
		mdl2:SetRenderAngles(ang)
		mdl:SetParent(ply, ply:LookupBone("ValveBiped.Bip01_Head1"))
		render.SetColorModulation(1,1,1)
			render.SetStencilWriteMask( 0xFF )
			render.SetStencilTestMask( 0xFF )
			render.SetStencilReferenceValue( 0 )
			render.SetStencilCompareFunction( STENCIL_ALWAYS )
			render.SetStencilPassOperation( STENCIL_KEEP )
			render.SetStencilFailOperation( STENCIL_KEEP )
			render.SetStencilZFailOperation( STENCIL_KEEP )
			render.ClearStencil()

			-- Enable stencils
			render.SetStencilEnable( true )
			-- Set everything up everything draws to the stencil buffer instead of the screen
			render.SetStencilReferenceValue( 1 )
			render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
			render.SetStencilPassOperation( STENCIL_REPLACE )
			render.SetBlend(0)
				mdl2:DrawModel()
			render.SetBlend(1)
			render.SetStencilCompareFunction( STENCIL_EQUAL )
			mdl:DrawModel()
			DrawBokehDOF(8,0.9,15)
			-- Let everything render normally again
			render.SetStencilEnable( false )
		render.SetColorModulation(1,1,1)
		--cam.IgnoreZ(false)
	cam.End3D()
end

hg.armor.torso = {
	["vest1"] = {
		"torso",
		"models/combataegis/body/ballisticvest_d.mdl",
		Vector(19, 3, 0),
		Angle(0, 90, 90),
		protection = 14.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/combataegis/body/ballisticvest.mdl",
		femPos = Vector(-4, 0, 1),
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 10,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest2"] = {
		"torso",
		"models/eu_homicide/armor_prop.mdl",
		Vector(-1, 2, 0),
		Angle(0, 90, 90),
		protection = 6.7,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eu_homicide/armor_on.mdl",
		femPos = Vector(-2.4, 0, 1.1),
		femscale = 0.94,
		effect = "Impact",
		surfaceprop = 77,
		mass = 3,
		ScrappersSlot = "Armor",
	},
	["vest3"] = {
		"torso",
		"models/jworld_equipment/kevlar.mdl",
		Vector(-9, 3.2, 0),
		Angle(0, 90, 90),
		protection = 9.8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/lightvest/lightvest.mdl",
		material = {"models/lightvest/accs_diff_000_b_uni",
		"models/lightvest/accs_diff_000_c_uni", "models/lightvest/accs_diff_000_c_uni",
		"models/lightvest/accs_diff_000_d_uni", "sal/acc/armor01_4", "sal/acc/armor01_5"},
		femPos = Vector(2.5, 0, 1),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 77,
		mass = 5,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest4"] = {
		"torso",
		"models/jworld_equipment/kevlar.mdl",
		Vector(-9, 3.2, 0),
		Angle(0, 90, 90),
		protection = 13.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/lightvest/lightvest.mdl",
		material = {"models/lightvest/accs_diff_000_a_uni",
		"models/lightvest/accs_diff_000_h_uni", "models/lightvest/accs_diff_000_f_uni",
		"models/lightvest/accs_diff_000_e_uni", "sal/acc/armor01_3"},
		femPos = Vector(2.5, 0, 1),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest5"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b13_flora.mdl",
		Vector(0, 2.7, 0),
		Angle(0, 90, 90),
		protection = 13,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b13_flora.mdl",
		femPos = Vector(-1, 0, 1.2),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
	},--models/eft_props/gear/armor/ar_paca.mdl
	["vest6"] = {
		"torso",
		"models/eft_props/gear/armor/ar_paca.mdl",
		Vector(-0.4, 2.9, 0),
		Angle(0, 92, 90),
		protection = 9.9,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_paca.mdl",
		femPos = Vector(-1.5, 0, 1.5),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		Spawnable = false,
	},
	["vest7"] = {
		"torso",
		"models/eft_props/gear/armor/ar_untar.mdl",
		Vector(-0.4, 2.9, 0),
		Angle(0, 92, 90),
		protection = 10.2,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_untar.mdl",
		femPos = Vector(-1.5, 0, 1.5),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
	},
	["vest8"] = {
		"torso",
		"models/monolithservers2/kerry/sswat_armor.mdl",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 12.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/monolithservers2/kerry/sswat_armor.mdl",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["gordon_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 16.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["cmb_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["metrocop_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["ego_equalizer"] = {
		"torso",
		"models/monolithservers2/kerry/sswat_armor.mdl",
		Vector(-8, 2.5, 0),
		Angle(0, 92, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/monolithservers2/kerry/sswat_armor.mdl",
		-- material = "models/shiny",
		material = "models/lightvest/accs_diff_000_d_uni", -- "models/props_c17/paper01"
		femPos = Vector(0, 0, 0),
		scale = 0.95,
		femscale = 0.95,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		AdminOnly = true
	},
}
local vectors = {
	[1] = Vector(-2,0,-1.5),
	[2] = Vector(-4,0,0.2),
	[3] = Vector(-5,0,0),
	[4] = Vector(-2,0,0),
	[5] = Vector(-4.5,0,-2)
}
hg.armor.head = {
	["helmet1"] = {
		"head",
		"models/barney_helmet.mdl",
		Vector(1, -2, 0),
		Angle(180, 110, 90),
		protection = 9.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/barney_helmet.mdl",
		femPos = Vector(-1, 0, 0),
		material = "sal/hanker",
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/barney_helmet.mdl", vectors[1], -40, "sal/hanker")
		end,
		viewmaterial = false,
		femscale = 0.92,
		effect = "Impact",
		surfaceprop = 67,
		mass = 2,
		ScrappersSlot = "Armor",
	},
	["helmet2"] = {
		"head",
		"models/dean/gtaiv/helmet.mdl",
		Vector(2.6, 0, 0),
		Angle(180, 110, 90),
		protection = 4.2,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/dean/gtaiv/helmet.mdl",
		femPos = Vector(-1, 0, 0),
		norender = true,
		skins = {0,1,3,7,10,11,14},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/dean/gtaiv/helmet.mdl", vectors[2], 20)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		cantsight = true
	},
	["helmet3"] = {
		"head",
		"models/eu_homicide/helmet.mdl",
		Vector(2, 0.2, 0),
		Angle(180, 110, 90),
		protection = 4,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eu_homicide/helmet.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eu_homicide/helmet.mdl", vectors[3], 25)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		cantsight = true
	},
	["helmet4"] = {
		"head",
		"models/props_interiors/pot02a.mdl",
		Vector(7, -3.8, -3.8),
		Angle(-45, -65, 90),
		protection = 3,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/props_interiors/pot02a.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet5"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_achhc_b.mdl",
		Vector(2.2,-1, 0),
		Angle(180, 100, 90),
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_achhc_b.mdl",
		femPos = Vector(-1, 0, 0.1),
		norender = true,
		effect = "Impact",
		surfaceprop = 67,
		scale = 0.9,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet6"] = {
		"head",
		"models/monolithservers2/kerry/swat_hat.mdl",
		Vector(0, 0, 0),
		Angle(180, 100, 90),
		protection = 11,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/monolithservers2/kerry/swat_hat.mdl",
		femPos = Vector(0, 0, 0),
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/monolithservers2/kerry/swat_hat.mdl", vectors[5], 0)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		scale = 1,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet7"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_s_sh_68.mdl",
		Vector(2.5, -0.8, 0),
		Angle(180, 95, 90),
		protection = 12,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_s_sh_68.mdl",
		femPos = Vector(-0.6, 0, 0.3),
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_s_sh_68.mdl", vectors[4], 0)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1.8,
		ScrappersSlot = "Armor",
	},
	["gordon_helmet"] = {
		"head",
		"models/dpfilms/props/hev_helmet.mdl",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 16,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/dpfilms/props/hev_helmet.mdl",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		viewmaterial = false,
		whitelistClasses = {
			["Gordon"] = true,
		},
		norender = true,
		AdminOnly = true
	},
	["cmb_helmet"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		nodrop = true,
		Spawnable = false,
	},
	["metrocop_helmet"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 7,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		nodrop = true,
		Spawnable = false,
	},
	["protovisor"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		viewmaterial = false,
		voice_change = false,
		nodrop = true,
		Spawnable = false,
	},
}

hg.armor.ears = {
	["headphones1"] = {
		"ears",
		"models/eft_props/gear/headsets/headset_msa.mdl",
		Vector(2.2, 0, 0),
		Angle(0, 100, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/headsets/headset_msa.mdl",
		femPos = Vector(-0.5, 0, 1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		scale = 0.9,
		femscale = 0.85,
		SoundlevelAdd = 15,
		VolumeAdd = 0.2,
		NormalizeSnd = {0.75,0.2}
	}
}

local function DrawNoise(amt, alpha)
	local W, H = ScrW(), ScrH()

	for i = 0, amt do
		local Bright = math.random(0, 255)
		surface.SetDrawColor(Bright, Bright, Bright, alpha)
		local X, Y = math.random(0, W), math.random(0, H)
		surface.DrawRect(X, Y, 1, 1)
	end
end

local blurMat2, Dynamic2 = Material("pp/blurscreen"), 0

local function BlurScreen(density,alpha)
	local layers, density, alpha = 1, density or .4, alpha or 255
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blurMat2)
	local FrameRate, Num, Dark = 1 / FrameTime(), 3, 150

	for i = 1, Num do
		blurMat2:SetFloat("$blur", (i / layers) * density * Dynamic2)
		blurMat2:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	Dynamic2 = math.Clamp(Dynamic2 + (1 / FrameRate) * 7, 0, 1)
end

local custommat = Material("overlays/nvg_scene_opticf2.png")

sound.Add( {
	name = "breath_normal",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 55,
	pitch = 100,
	sound = "breath_normal.wav"
} )

local colormodify01 = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.15,
	["$pp_colour_addb"] = 0.17,
	["$pp_colour_brightness"] = 0.01,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local colormodify02 = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.15,
	["$pp_colour_addb"] = 0.17,
	["$pp_colour_brightness"] = -0.1,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hg.armor.face = {
	["mask1"] = {
		"face", -- "face"
		"models/jmod/ballistic_mask.mdl",
		Vector(4.55, -0.8, 0),
		Angle(180, 90, 90),
		protection = 9.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/jmod/ballistic_mask.mdl",
		femPos = Vector(-1.2, 0, 0.15),
		material = {"sal/hanker","griggs/models/ballistic_mask_2011x","griggs/models/ballistic_mask_collector",
					"griggs/models/ballistic_mask_cute","griggs/models/ballistic_mask_golden_guard",
					"griggs/models/ballistic_mask_grunt","griggs/models/ballistic_mask_peace",
					"griggs/models/ballistic_mask_phonky","griggs/models/ballistic_mask_steamhappy",
					"griggs/models/ballistic_mask_z", "griggs/models/ballistic_mask_pluvmaska",
					"griggs/models/ballistic_mask_coolkid_01","griggs/models/ballistic_mask_coolkid_02",
					"sosoda/models/ballistic_mask_manhunt"},
		norender = true,
		scale = 1,
		femscale = 0.97,
		viewmaterial = Material("sprites/mat_jack_hmcd_narrow"),
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 1.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["mask2"] = {
		"face", -- "face"
		"models/gasmasksfix/m40_drop.mdl",
		Vector(3,-2,-0.5),
		Angle(-90, 90, 0),
		protection = 1.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gasmasksfix/m40_fix.mdl",
		femPos = Vector(-1,0,0),
		norender = true,
		scale = 1,
		femscale = 1,
		viewmaterial = Material("overlays/ba_gasmask"),
		effect = "Impact",
		surfaceprop = 67,
		loopsound = "breath_normal",
		mass = 0.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["mask3"] = {
		"face", -- "face"
		"models/props_silo/welding_helmet.mdl",
		Vector(0, 0.3, 0),
		Angle(-90, 180, 90),
		protection = 7,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/props_silo/welding_helmet.mdl",
		femPos = Vector(-1, 0, 0.5),
		norender = true,
		scale = 1.03,
		femscale = 1,
		viewmaterial = Material("sprites/mat_jack_hmcd_narrow"),
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 2,
		ScrappersSlot = "Armor",
		voice_change = true,
		PhysModel = "models/hunter/blocks/cube025x025x025.mdl",
		PhysPos = Vector(1, 0, 5),
		PhysAng = Angle(0, 90, 0),
	},
	["nightvision1"] = {
		"face", -- "face"
		"models/arctic_nvgs/nvg_gpnvg.mdl",
		Vector(1.6, 0.6, 0),
		Angle(0, -90, -90),
		protection = 0,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/arctic_nvgs/nvg_gpnvg.mdl",
		femPos = Vector(-1, 0, 0.5),
		norender = true,
		scale = 0.95,
		femscale = 0.92,
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 1.5,
		ScrappersSlot = "Armor",
		custommat = Material("overlays/nvg_scene_opticf2.png"),
		NVGRender = function()
			 
			if not IsValid(lply.EZNVGlamp) then
				lply.EZNVGlamp = ProjectedTexture()
				lply.EZNVGlamp:SetTexture("effects/flashlight001")
				lply.EZNVGlamp:SetBrightness(.06)
				lply.EZNVGlamp:SetEnableShadows(false)
				local FoV = lply:GetFOV()
				lply.EZNVGlamp:SetFOV(FoV + 45)
				lply.EZNVGlamp:SetFarZ(500000 / FoV)
				lply.EZNVGlamp:SetConstantAttenuation(.1)
			else
				local Ang = EyeAngles()
				lply.EZNVGlamp:SetPos(lply:EyePos())
				lply.EZNVGlamp:SetAngles(Ang)
				lply.EZNVGlamp:Update()
			end

			BlurScreen(0.2,65)

			DrawColorModify(colormodify01)
			DrawColorModify(colormodify02)

			DrawBloom(0.4, 1, 4, 4, 1, 0, 12, 12, 6)
			DrawNoise(500,25)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(custommat or mat)
			local viewpunching = GetViewPunchAngles()
			local w, h = ScrW(), ScrH()
			surface.DrawTexturedRect(-w + (w * 1.5) / 2 - viewpunching.r * 6, -20 - viewpunching.x * 6, w * 1.5, h + 40)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-w + (w * 1.5) / 2, (h + 20) - viewpunching.x * 6, w * 1.5, h + 40)
			surface.DrawRect(-w + (w * 1.5) / 2, -(h + 40) - viewpunching.x * 6, w * 1.5, h + 40)
		end,
		CustomSnd = "snds_jack_gmod/tinycapcharge.wav",
		AfterPickup = function(ply)
			--timer.Simple(1,function()
			--	if IsValid(ply) and ply:IsPlayer() then
			--		ply:Notify("Enable \\ Disable NVG - С + E",nil,nil,0)
			--	end
			--end)
		end
	}
}

if CLIENT then
	net.Receive("AddFlash", function()
		local pos = net.ReadVector()
		local time = net.ReadFloat()
		local size = net.ReadInt(20)
		if not IsValid(lply) then return end
		hg.AddFlash(hg.eye(lply), 1, pos, time, size)
	end)
end

local armorNames = {
	["vest1"] = "Plate Body Armor IV",
	["helmet1"] = "ACH Helmet III",
	["helmet2"] = "Biker Helmet",
	["helmet3"] = "Riot Helmet",
	["helmet4"] = "Pot",
	["helmet7"] = "SSh-68",
	["vest2"] = "Police Riot Vest",
	["vest3"] = "Kevlar IIIA Vest",
	["vest4"] = "Kevlar III Vest",
	["mask1"] = "Balistic Mask",
	["mask2"] = "M40 Gas Mask",
	["mask3"] = "Welding Mask",
	["vest5"] = "6B13",
	["nightvision1"] = "NVG GPNVG 18",
	["vest6"] = "PACA Soft Armor",
	["vest7"] = "MF-UNTAR Body Armor",
	["headphones1"] = "MSA Sordin Supreme PRO-X/L",
	["helmet5"] = "HighCom Striker ACHHC IIIA helmet",
	["vest8"] = "SWAT Balistic Vest",
	["ego_equalizer"] = "[HE] Equalizer",
	["helmet6"] = "SWAT Balistic Helmet",
	["gordon_helmet"] = "HEV Suit Helmet",
}
hg.armorNames = armorNames
local armorIcons = {
	["vest1"] = "scrappers/armor1.png",
	["helmet1"] = "vgui/icons/helmet.png",
	["helmet2"] = "vgui/icons/mothelmet.png",
	["helmet3"] = "vgui/icons/riothelm.png",
	["helmet4"] = "entities/ent_jack_gmod_ezarmor_bomber.png",
	["helmet7"] = "entities/ent_jack_gmod_ezarmor_ssh68.png",
	["vest2"] = "vgui/icons/policevest.png",
	["vest3"] = "vgui/icons/armor01.png",
	["vest4"] = "vgui/icons/armor02.png",
	["mask1"] = "vgui/icons/ballisticmask",
	["mask2"] = "vgui/icons/gasmask",
	["mask3"] = "entities/ent_jack_gmod_ezarmor_weldingkill.png",
	["ego_equalizer"] = "entities/ent_jack_gmod_ezarmor_hazmat.png",
	["vest5"] = "entities/ent_jack_gmod_ezarmor_6b13flora.png",
	["nightvision1"] = "vgui/icons/nvg",
	["vest6"] = "entities/ent_jack_gmod_ezarmor_paca.png",
	["vest7"] = "entities/ent_jack_gmod_ezarmor_untar.png",
	["headphones1"] = "entities/ent_jack_gmod_ezarmor_sordin.png",
	["helmet5"] = "entities/ent_jack_gmod_ezarmor_achhcblack.png",
	["vest8"] = "vgui/icons/armor01.png",
	["helmet6"] = "vgui/icons/helmet.png",
}
hg.armorIcons = armorIcons

local entityMeta = FindMetaTable("Entity")
function entityMeta:SyncArmor()
	if self.armors then
		self:SetNetVar("Armor", self.armors)
		local rag = hg.GetCurrentCharacter(self)
		if IsValid(rag) and rag:IsRagdoll() then
			rag:SetNetVar("Armor", self.armors)
			rag:SetNetVar("HideArmorRender", self:GetNetVar("HideArmorRender", false))
		end
	end
end

local function initArmor()
	for possibleArmor, armors in pairs(hg.armor) do
		for armorkey, armorData in pairs(armors) do
			if CLIENT then language.Add(armorkey, armorNames[armorkey] or armorkey) end
			if armorData.inbuilt then continue end
			
			local armor = {}
			armor.Base = "armor_base"
			armor.PrintName = CLIENT and language.GetPhrase(armorkey) or armorkey
			armor.name = armorkey
			armor.Category = "ZCity Armor"
			armor.Spawnable = true
			if armorData.Spawnable != nil then
				armor.Spawnable = false
			end
			if armorData.AdminOnly then
				armor.AdminOnly = true
			end
			armor.Model = armorData[2]
			armor.WorldModel = armorData[2]
			armor.SubMats = armorData[4]
			armor.armor = armorData
			armor.placement = armorData[1]
			armor.IconOverride = armorIcons[armorkey]
			armor.PhysModel = armorData.PhysModel or nil
			armor.PhysPos = armorData.PhysPos or nil
			armor.PhysAng = armorData.PhysAng or nil
			armor.material = armorData.material or nil
			armor.skins = armorData.skins or nil
			scripted_ents.Register(armor, "ent_armor_" .. armorkey)
		end
	end
end

function hg.GetArmorPlacement(armor)
	if istable(armor) then return end
	armor = string.Replace(armor,"ent_armor_","")
	
	local found
	for i,armplc in pairs(hg.armor) do
		for i2,armor2 in pairs(armplc) do
			if i2 == armor then found = i end
		end
	end
	return found
end

local stringToNum = {
	["torso"] = 1,
	["head"] = 2,
	["face"] = 3,
}

function hg.GetArmorPlacementNum(armor)
	return stringToNum[hg.GetArmorPlacement(armor)]
end

initArmor()
hook.Add("Initialize", "init-atts", initArmor)
