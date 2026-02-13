hg.Appearance = hg.Appearance or {}

-- File manager

hg.Appearance.SelectedAppearance = ConVarExists("hg_appearance_selected") and GetConVar("hg_appearance_selected") or CreateClientConVar("hg_appearance_selected","main",true,false,"name of selected appearance json file")
hg.Appearance.ForcedRandom = ConVarExists("hg_appearance_force_random") and GetConVar("hg_appearance_force_random") or CreateClientConVar("hg_appearance_force_random","0",true,false,"forced appearance random",0,1)

local dir = "zcity/appearances/"
function hg.Appearance.CreateAppearanceFile(strFile_name, tblAppearance)
	file.CreateDir(dir)
	file.Write(dir .. strFile_name .. ".json", util.TableToJSON(tblAppearance, true) )
end

function hg.Appearance.LoadAppearanceFile(strFile_name)
	if not file.Exists(dir .. strFile_name .. ".json", "DATA") then return false, "no file [data/zcity/appearances/" .. strFile_name .. ".json]" end
	local tblAppearance = util.JSONToTable(file.Read(dir .. strFile_name .. ".json"))

	if not hg.Appearance.AppearanceValidater(tblAppearance) then return false, "file is damaged [data/zcity/appearances/" .. strFile_name .. ".json]"  end

	return tblAppearance
end

function hg.Appearance.GetAppearanceList()
	local files = file.Find( dir .. "*.json" )
	return files
end

-- Send from client...
net.Receive("Get_Appearance", function()
	local forced_random = hg.Appearance.ForcedRandom:GetBool()
    net.Start("Get_Appearance")
		local tbl,reason

		if not forced_random then
			tbl,reason = hg.Appearance.LoadAppearanceFile(hg.Appearance.SelectedAppearance:GetString())
		end
		
        net.WriteTable(tbl and tbl or {})
        net.WriteBool(not tbl)
    net.SendToServer()

	if not tbl and not forced_random then lply:ChatPrint("[Appearance] file load failed - " .. reason) end
end)

local function OnlyGetAppearance()
	local forced_random = hg.Appearance.ForcedRandom:GetBool()
    net.Start("OnlyGet_Appearance")
		local tbl,reason

		if not forced_random then 
			tbl,reason = hg.Appearance.LoadAppearanceFile(hg.Appearance.SelectedAppearance:GetString())
		end

        net.WriteTable(tbl or {})

    net.SendToServer()

	if not tbl and not forced_random then lply:ChatPrint("[Appearance] file load failed - " .. reason) end
end

net.Receive("OnlyGet_Appearance", OnlyGetAppearance)

-- Render things

local whitelist = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true,
    weapon_crowbar = true,
    weapon_pistol = true,
    weapon_crossbow = true
}

local islply

local hg_firstperson_death = ConVarExists("hg_firstperson_death") and GetConVar("hg_firstperson_death") or CreateClientConVar("hg_firstperson_death", "0", "first person death", true, false, 0, 1)

function RenderAccessories(ply, accessories, setup)

	if not IsValid(ply) or not accessories then return end

	if accessories == "none" then return end

	local wep = ply:IsPlayer() and ply:GetActiveWeapon()

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	ent = IsValid(ply.OldRagdoll) and ply.OldRagdoll:IsRagdoll() and ply.OldRagdoll or ent

	islply = ((ply:IsRagdoll() and hg.RagdollOwner(ply)) or ply) == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer())) and GetViewEntity() == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer()))
	
	local fountains = GetNetVar("fountains") or {}
	if ent == follow and hg_firstperson_death:GetBool() and !fountains[ent] then islply = true end

	if islply and IsValid(wep) and whitelist[wep:GetClass()] then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if not ent.shouldTransmit or ent.NotSeen then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if istable(accessories) then
		for k = 1, #accessories do
			local accessoriess = accessories[k]
			local accessData = hg.Accessories[accessoriess]
			if not accessData then continue end
			if accessData.needcoolRender then continue end

			DrawAccesories(ply, ent, accessoriess, accessData, islply, nil, setup)
		end
	else
		local accessData = hg.Accessories[accessories]
		if not accessData then return end
		if accessData.needcoolRender then return end

		DrawAccesories(ply, ent, accessories, accessData, islply, nil, setup)
	end
end

local huy_addvec = Vector(0.4,0,0.4)
function DrawAccesories(ply, ent, accessories,accessData, islply, force, setup)
	if not accessories then return end
	if not accessData then return end

	ply.modelAccess = ply.modelAccess or {}

	local fem = ThatPlyIsFemale(ent)
	if not IsValid(ply.modelAccess[accessories]) then
		if not accessData["model"] then return end
		ply.modelAccess[accessories] = ClientsideModel(fem and accessData["femmodel"] or accessData["model"], RENDERGROUP_BOTH)

		local model = ply.modelAccess[accessories]
		model:SetNoDraw(true)
		model:SetModelScale( accessData[fem and "fempos" or "malepos"][3] )
		model:SetSkin( isfunction(accessData["skin"]) and accessData["skin"](ent) or accessData["skin"] )
		model:SetBodyGroups( accessData["bodygroups"] or "" )
		model:SetParent(ent, ent:LookupBone(accessData["bone"]))
		if accessData.bonemerge then
			model:AddEffects(EF_BONEMERGE)
		end
		if accessData["bSetColor"] then
			if ply.GetPlayerColor then 
				model:SetColor(ply:GetPlayerColor():ToColor())
			else
				model:SetColor(ply:GetNWVector("PlayerColor",Vector(1,1,1)):ToColor())
			end
		end

		if accessData["SubMat"] then
			model:SetSubMaterial(0,accessData["SubMat"])
		end

		ply:CallOnRemove("RemoveAccessories"..accessories,function() 
			if ply.modelAccess and IsValid(model) then
				model:Remove()
				model = nil
			end
		end)
		ent:CallOnRemove("RemoveAccessories2"..accessories,function() 
			if ply.modelAccess and IsValid(model) then
				model:Remove()
				model = nil
			end
		end)
	end

	local model = ply.modelAccess[accessories]
	--print(ent:GetModel(),ent)
	local mdl = string.Split(string.sub(ent:GetModel(),1,-5),"/")[#string.Split(string.sub(ent:GetModel(),1,-5),"/")]
	if mdl and model:GetFlexIDByName(mdl) then
		model:SetFlexWeight(model:GetFlexIDByName(mdl),1)
	end
	--if model:GetFlexIDByName(ThatPlyIsFemale(ply) and "F" or "M") then
	--	model:SetFlexWeight(model:GetFlexIDByName(ThatPlyIsFemale(ply) and "F" or "M"),1)
	--end
	model:SetSkin( isfunction(accessData["skin"]) and accessData["skin"](ent) or accessData["skin"] )

	if not IsValid(model) then ply.modelAccess[accessories] = nil return end

	if ply.armors and accessData["placement"] and ply.armors[accessData["placement"]] then

		return
	end

	if not force and ((ent.NotSeen or not ent.shouldTransmit) or (ply:IsPlayer() and not ply:Alive())) then

		return
	end

	if ply.organism and hg.amputatedlimbs2[accessData["bone"]] and ply.organism[hg.amputatedlimbs2[accessData["bone"]].."amputated"] then return end

	if setup != false then
		local bone = ent:LookupBone(accessData["bone"])
		if not bone then return end
		if ent:GetManipulateBoneScale(bone):LengthSqr() < 0.1 then return end
		local matrix = ent:GetBoneMatrix(bone)
		if not matrix then return end

		local bonePos, boneAng = matrix:GetTranslation(), matrix:GetAngles()

		local addvec = ((ent:GetModel() == "models/player/group01/male_06.mdl") and ((accessData.placement == "head") or (accessData.placement == "face"))) and huy_addvec or vector_origin

		local pos, ang = LocalToWorld(accessData[fem and "fempos" or "malepos"][1], accessData[fem and "fempos" or "malepos"][2], bonePos, boneAng)
		local pos = LocalToWorld(addvec, angle_zero, pos, ang)
		
		--model:SetupBones()
		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
	end

	if model:GetParent() != ent then model:SetParent(ent, bone) end
	if !(islply and accessData.norender) and (!setup or accessData.bonemerge) then
		if accessData["bSetColor"] then
			local colorDraw = accessData["vecColorOveride"] or ( ply.GetPlayerColor and ply:GetPlayerColor() or ply:GetNWVector("PlayerColor",Vector(1,1,1)) )
			render.SetColorModulation( colorDraw[1],colorDraw[2],colorDraw[3] )
		end
		
		model:DrawModel()
		
		if accessData["bSetColor"] then
			render.SetColorModulation( 1, 1, 1 )
		end
	end
end

local flpos,flang = Vector(4,-1,0),Angle(0,0,0)

local offsetVec,offsetAng = Vector(1,0,0),Angle(100,90,0)

local mat2 = Material("sprites/light_glow02_add_noz")
local mat3 = Material("effects/flashlight/soft")

function DrawAppearance(ent, ply, setup)
    local Access = ent:GetNetVar("Accessories") or ent.PredictedAccessories
	
	if IsValid(ent) and Access then
		RenderAccessories(ply, Access, setup)
	end
	
	if setup then return end
	
	if not ply:IsPlayer() then return end
	
	local inv = ply:GetNetVar("Inventory",{})
	if not inv["Weapons"] or not inv["Weapons"]["hg_flashlight"] then
		if ply.flashlight then
			ply.flashlight:Remove()
			ply.flashlight = nil
		end
		if ply.flmodel then
			ply.flmodel:Remove()
			ply.flmodel = nil
		end
		return
	end

	local wep = ply:GetActiveWeapon()
	local flashlightwep

	if IsValid(wep) then
		local laser = wep.attachments and wep.attachments.underbarrel
		local attachmentData
		if ( laser and !table.IsEmpty(laser) ) or wep.laser then
			if laser and !table.IsEmpty(laser) then
				attachmentData = hg.attachments.underbarrel[laser[1]]
			else
				attachmentData = wep.laserData
			end
		end

		if attachmentData then flashlightwep = attachmentData.supportFlashlight end
	end

	if IsValid(ply.flmodel) then
		ply.flmodel:SetNoDraw(!(ply:GetNetVar("flashlight") and (!wep.IsPistolHoldType or wep:IsPistolHoldType())) or wep.reload or flashlightwep)
	end

	if ply:GetNetVar("flashlight") and not flashlightwep and (!wep.IsPistolHoldType or wep:IsPistolHoldType() or ply.PlayerClassName == "Gordon") and not wep.reload then
		local hand = ent:LookupBone("ValveBiped.Bip01_L_Hand")
		if not hand then return end

		local handmat = ent:GetBoneMatrix(hand)
		if not handmat then return end

		local pos,ang = handmat:GetTranslation(),handmat:GetAngles()--ply:EyeAngles()--(ply:GetEyeTrace().HitPos - ply:EyePos()):Angle()
		local pos,ang = LocalToWorld(offsetVec,offsetAng,pos,ang)

		ply.flmodel = IsValid(ply.flmodel) and ply.flmodel or ClientsideModel("models/runaway911/props/item/flashlight.mdl")
		ply.flmodel:SetModelScale(0.75)

		if ent ~= ply then pos = handmat:GetTranslation() end

		local pos,_ = LocalToWorld(flpos,flang,pos,handmat:GetAngles())

		if IsValid(ply.flmodel) and (ply ~= LocalPlayer() or ply ~= GetViewEntity()) then
			local veclh,lang = hg.FlashlightTransform(ply)
		end

		ply.flmodel:DrawModel()

		ply.flashlight = IsValid(ply.flashlight) and ply.flashlight or ProjectedTexture()
		if ply.flashlight and ply.flashlight:IsValid() and (ply.FlashlightUpdateTime or 0) < CurTime() then
			local flash = ply.flashlight
			ply.FlashlightUpdateTime = CurTime() + 0.01
			flash:SetTexture(mat3:GetTexture("$basetexture"))
			flash:SetFarZ(1500)
			flash:SetHorizontalFOV(60)
			flash:SetVerticalFOV(60)
			flash:SetConstantAttenuation(0.1)
			flash:SetLinearAttenuation(50)
			flash:SetPos(ply.flmodel:GetPos() + ply.flmodel:GetAngles():Forward() * (ply:GetVelocity():Length() / 10 + 15))
			flash:SetAngles(ply.flmodel:GetAngles())
			flash:Update()
		end

		--[[ply.dlight = DynamicLight( ply:EntIndex() )
		if ( ply.dlight ) then
			ply.dlight.pos = ply.flmodel:GetPos()
			ply.dlight.r = 255
			ply.dlight.g = 255
			ply.dlight.b = 255
			ply.dlight.brightness = -3
			ply.dlight.decay = 400
			ply.dlight.size = 100
			ply.dlight.dietime = CurTime() + 0.1
		else
			ply.dlight = DynamicLight( ply:EntIndex() )
		end--]]

		local view = render.GetViewSetup(true)
		local deg = ply.flmodel:GetAngles():Forward():Dot(view.angles:Forward())
		deg = math.ease.InBack(-deg + 0.05) * 2
		deg = -deg
		local chekvisible = util.TraceLine({
			start = ply.flmodel:GetPos() + ply.flmodel:GetAngles():Forward() * 6,
			endpos = view.origin,
			filter = {ply, ent, ply.flmodel, LocalPlayer()},
			mask = MASK_VISIBLE
		})

		if deg < 0 and not chekvisible.Hit then
			render.SetMaterial(mat2)
			render.DrawSprite(ply.flmodel:GetPos() + ply.flmodel:GetAngles():Forward() * 5 + ply.flmodel:GetAngles():Right() * -0.5, 50 * math.min(deg, 0), 50 * math.min(deg, 0), color_white)
		end
	else
		if ply.flashlight and IsValid(ply.flashlight) then
			ply.flashlight:Remove()
			ply.flashlight = nil
		end
	end
end

hook.Add("RenderScreenspaceEffects","AppearanceShitty",function()
	if (not LocalPlayer():Alive()) or LocalPlayer():GetViewEntity() ~= LocalPlayer() then return end
	local ply = LocalPlayer()
	local acsses = ply:GetNetVar("Accessories", "none")

	if istable(acsses) then
		for k,accessoriess in ipairs(acsses) do
			local accessData = hg.Accessories[accessoriess]
			if not accessData then continue end
			if ply.armors and accessData["placement"] and ply.armors[accessData["placement"]] then continue end
			if accessData.ScreenSpaceEffects then
				accessData.ScreenSpaceEffects()
			end
		end
	elseif acsses then
		local accessData = hg.Accessories[acsses]
		if not accessData then return end
		if ply.armors and accessData["placement"] and ply.armors[accessData["placement"]] then return end
		if accessData.ScreenSpaceEffects then
			accessData.ScreenSpaceEffects()
		end
	end
end)

function CoolRenderAccessories(ply, accessories)

	if not IsValid(ply) or not accessories then return end

	if accessories == "none" then return end

	local wep = ply:IsPlayer() and ply:GetActiveWeapon()

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply

	islply = ((ply:IsRagdoll() and hg.RagdollOwner(ply)) or ply) == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer())) and GetViewEntity() == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer()))

	if islply and IsValid(wep) and whitelist[wep:GetClass()] then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if not ent.shouldTransmit or ent.NotSeen then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if istable(accessories) then
		for k = 1, #accessories do
			local accessoriess = accessories[k]
			local accessData = hg.Accessories[accessoriess]
			if not accessData then continue end
			if not accessData.needcoolRender then continue end

			DrawAccesories(ply,ent,accessoriess,accessData,islply)
		end
	else
		local accessData = hg.Accessories[accessories]
		if not accessData then return end
		if not accessData.needcoolRender then return end

		DrawAccesories(ply,ent,accessories,accessData,islply)
	end
end

function RenderAccessoriesCool(ent,ply)
	if IsValid(ent) and ent:GetNetVar("Accessories") then
		CoolRenderAccessories(ent, ent:GetNetVar("Accessories", "none"))
	end
end