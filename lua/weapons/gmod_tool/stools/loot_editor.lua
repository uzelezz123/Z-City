do return end
-- TOOL.Category = "ZBattle"
-- TOOL.Name = "Loot Editor"

-- TOOL.ClientConVar[ "point" ] = ""

-- function TOOL:LeftClick( trace, attach )
-- 	if SERVER then
-- 		local pos = trace.HitPos
-- 		local name = self:GetOwner():GetInfo(self:GetMode() .. "_point")

-- 		if !name then return end

-- 		local ang = self:GetOwner():EyeAngles()
-- 		ang.x = 0
-- 		local pointData = {
-- 			pos = pos,
-- 			ang = ang
-- 		}
-- 		self:GetOwner():ChatPrint("{ ".."\"".. name .."\", Vector(".. trace.HitPos[1]..", " ..trace.HitPos[2]..", " ..( trace.HitPos[3]+72 ).. "), Angle(".. 0 ..", " ..ang[2]..", " ..0 ..") }")
-- 	end

--     return true
-- end

-- local ConVarsDefault = TOOL:BuildConVarList()
-- local Boxes = {
--     ["NATO_BIG_Military"] = { 
--         EntTable = {
--             "weapon_hk416", "weapon_m249", "weapon_m60", "weapon_sr25", "weapon_xm1014", 
--             "ent_armor_headphones1", "ent_armor_vest1", "ent_armor_vest4", "ent_armor_helmet1", 
--             "ent_armor_helmet5", "ent_armor_nightvision1", "ent_att_optic6", "ent_att_holo4",
--             "ent_att_holo15", "ent_att_optic7", "ent_att_optic8", "ent_att_holo1", "ent_att_holo14",
--             "ent_att_optic9", "ent_ammo_5.56x45mm", "ent_ammo_5.56x45mmm856", "ent_ammo_5.56x45mmap",
--             "ent_ammo_7.62x51mm", "ent_ammo_9x39mm", "ent_ammo_12/70gauge", "ent_ammo_12/70slug",
--             "hg_sling", "weapon_walkie_talkie"
--         }, 
--         Models = {"models/kali/props/cases/hard case a.mdl"}
--     },
--     ["NATO_SMALL_Military"] = { 
--         EntTable = {
--             "weapon_mp7", "weapon_mp5", "weapon_p90", "weapon_hg_grenade_tpik", "weapon_hg_flashbang_tpik",
--             "weapon_hg_smokenade_tpik", "weapon_fn45", "weapon_deagle", "ent_att_supressor7", "ent_att_supressor2",
--             "ent_att_optic6", "ent_att_holo4","ent_att_holo15", "ent_att_optic7", "ent_att_optic8", 
--             "ent_att_holo1", "ent_att_holo14","ent_att_optic9", "ent_ammo_5.56x45mm", "ent_ammo_5.56x45mmm856", 
--             "ent_ammo_5.56x45mmap","ent_ammo_7.62x51mm", "ent_ammo_9x39mm", "ent_ammo_12/70gauge", 
--             "ent_ammo_12/70slug", "ent_att_grip2", "ent_att_grip3", "hg_sling", "weapon_walkie_talkie",
--             "weapon_melee", "weapon_sogknife", "weapon_tomahawk"
--         }, 
--         Models = {"models/props/CS_militia/footlocker01_closed.mdl", "models/kali/props/cases/hard case c.mdl"}
--     },
--     ["RUS_BIG_Military"] = { 
--         EntTable = {
--             "weapon_asval", "weapon_akm", "weapon_hg_rgd_tpik", "weapon_makarov", "weapon_hg_smokenade_tpik",
--             "weapon_melee", "weapon_sogknife", "ent_ammo_9x39mm", "ent_ammo_7.62x39mm",
--             "ent_att_supressor1", "ent_att_supressor8", "ent_att_holo6", "ent_att_holo5", "ent_att_holo7",
--             "ent_att_optic3", "ent_att_holo12", "ent_att_holo13", "ent_att_optic4", "ent_att_optic11",
--             "ent_att_holo2", "ent_armor_vest5", "ent_armor_helmet1",
--         }, 
--         Models = {"models/props/de_prodigy/ammo_can_01.mdl"}
--     },
--     ["RUS_SMALL_Military"] = { 
--         EntTable = {
--             "weapon_ak74", "weapon_ak74u", "weapon_hg_rgd_tpik", "weapon_makarov", "weapon_hg_smokenade_tpik",
--             "weapon_melee", "weapon_sogknife", "ent_ammo_5.45x39mm", "ent_ammo_7.62x39mm", "ent_ammo_9x18mm",
--             "ent_att_supressor1", "ent_att_supressor8", "ent_att_holo6", "ent_att_holo5", "ent_att_holo7",
--             "ent_att_optic3", "ent_att_holo12", "ent_att_holo13", "ent_att_optic4", "ent_att_optic11",
--             "ent_att_holo2", "ent_armor_vest5", "ent_armor_helmet1",
--         }, 
--         Models = {"models/props/de_prodigy/ammo_can_01.mdl"}
--     },
--     ["POLICE_Lockers"] = { 
--         EntTable = {
--             "weapon_ar15", "weapon_remington870", "ent_ammo_5.56x45mm", "ent_ammo_12/70beanbag", "ent_ammo_12/70gauge",
--             "ent_armor_vest3", "ent_armor_vest2", "ent_armor_helmet3", "ent_armor_vest6", "ent_att_holo15", "ent_att_optic2", 
--             "ent_att_optic2", "ent_att_holo14", "ent_att_laser3", "ent_att_grip2", "weapon_ram", "hg_sling", "weapon_walkie_talkie"
--         }, 
--         Models = {"models/props_c17/Lockers001a.mdl"}
--     },
--     ["POLICE_SmallLocker"] = { 
--         EntTable = {
--             "weapon_glock17", "weapon_hk_usp", "weapon_px4beretta", "weapon_hg_tonfa", "weapon_handcuffs", "weapon_handcuffs_key",
--             "weapon_taser", "ent_att_holo16", "ent_att_laser3", "hg_flashlight", "ent_ammo_9x19mmparabellum", "hg_sling", "weapon_walkie_talkie"
--         }, 
--         Models = {"models/props_wasteland/controlroom_filecabinet001a.mdl"}
--     },
--     ["CITIZEN_Wardrobe"] = { 
--         EntTable = {
--             "weapon_remington870", "weapon_glock17", "weapon_px4beretta", "weapon_pocketknife", "ent_armor_vest3",
--             "weapon_bigconsumable", "weapon_smallconsumable", "weapon_ducttape", "hg_flashlight", "ent_ammo_9x19mmparabellum",
--             "weapon_hg_pipebomb_tpik", "weapon_bat", "weapon_zoraki", "ent_ammo_9mmpakflashdefense", "weapon_p22", 
--             "ent_ammo_.22longrifle", "weapon_revolver2"
--         }, 
--         Models = {"models/props_c17/FurnitureDresser001a.mdl", "models/props_c17/FurnitureDrawer001a.mdl"}
--     },
--     ["CITIZEN_RandomBox"] = { 
--         EntTable = {
--             "weapon_fn45", "weapon_px4beretta", "weapon_pocketknife", "weapon_revolver2", "weapon_revolver357",
--             "weapon_smallconsumable", "weapon_ducttape", "hg_flashlight", "ent_ammo_9x19mmparabellum",
--             "weapon_hg_pipebomb_tpik", "weapon_bat", "weapon_zoraki", "ent_ammo_9mmpakflashdefense", 
--             "ent_ammo_.357magnum", "ent_ammo_.45acp"
--         }, 
--         Models = {"models/props_c17/FurnitureDrawer002a.mdl", "models/props_c17/FurnitureDrawer003a.mdl"}
--     },
--     ["CITIZEN_Fridge"] = { 
--         EntTable = {
--             "weapon_smallconsumable", "weapon_bigconsumable"
--         }, 
--         Models = {"models/props_c17/FurnitureFridge001a.mdl"}
--     },
--     ["CITIZEN_Tools"] = { 
--         EntTable = {
--             "weapon_ducttape", "weapon_hammer", "ent_ammo_nails", "ent_hg_hmcd_radio", "weapon_brick", "weapon_hg_sledgehammer", "weapon_hg_shovel",
--             "weapon_leadpipe", "weapon_hg_crowbar", "weapon_hg_extinguisher"
--         }, 
--         Models = {"models/props_junk/wood_crate001a.mdl", "models/props_junk/wood_crate002a.mdl"}
--     },
--     ["MEDICAL_Small"] = { 
--         EntTable = {
--             "weapon_bandage_sh", "weapon_betablock", "weapon_painkillers", "weapon_tourniquet", "weapon_naloxone"
--         }, 
--         Models = {"models/props_wasteland/controlroom_filecabinet001a.mdl"}
--     },
--     ["MEDICAL_Big"] = { 
--         EntTable = {
--             "weapon_bandage_sh", "weapon_betablock", "weapon_painkillers", "weapon_tourniquet", "weapon_naloxone",
--             "weapon_medkit_sh", "weapon_adrenaline", "weapon_needle", "weapon_morphine", "weapon_naloxone",
--             "weapon_traitor_poison1"
--         }, 
--         Models = {"models/props_wasteland/controlroom_filecabinet002a.mdl", "models/props_wasteland/controlroom_storagecloset001a.mdl"}
--     },
-- }
-- hg = hg or {}
-- hg.Boxes = Boxes
-- function TOOL.BuildCPanel( CPanel )

-- 	CPanel:AddControl( "Header", { Description = "ура удобный инструмент я в шоке!!" } )

-- 	local dlist = vgui.Create("DListView")
-- 	dlist:Dock(TOP)
-- 	dlist:SetTall(ScreenScale(100))
-- 	dlist:AddColumn("Point Name")

-- 	for k, v in pairs(hg.Boxes) do
-- 		dlist:AddLine(k)
-- 	end

-- 	CPanel:AddItem(dlist)

-- 	dlist.OnRowSelected = function( lst, index, pnl )
-- 		RunConsoleCommand("loot_editor_point", pnl:GetValue(1))
-- 	end
-- end

-- function TOOL:Allowed()
-- 	return self:GetOwner():IsAdmin()
-- end

-- function TOOL:Deploy()
-- 	if SERVER then
-- 		local ply = self:GetOwner()

-- 		ply:EmitSound("zbattle/pointinator.mp3")
-- 	end
-- end

-- local trace1
-- local red = Color(255, 0, 0, 100)


-- function TOOL:DrawToolScreen( width, height )
-- 	-- Draw black background
-- 	surface.SetDrawColor( Color( 20, 20, 20 ) )
-- 	surface.DrawRect( 0, 0, width, height )
	
-- 	-- Draw white text in middle
-- 	draw.SimpleText( "#UwUs", "Default", width / 2, height / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

-- 	draw.SimpleText(GetConVar("loot_editor_point"):GetString(), "Default", width / 2, height * 0.7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
-- end