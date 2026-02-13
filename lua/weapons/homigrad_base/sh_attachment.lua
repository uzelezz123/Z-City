AddCSLuaFile()
local angFull = Angle(-30, 30, 30)
local angZero = Angle(0, 0, 0)
hg.attachments = hg.attachments or {}
SWEP.availableAttachments = {}
local hg_random_atts = ConVarExists("hg_random_atts") and GetConVar("hg_random_atts") or CreateConVar("hg_random_atts", 0, FCVAR_SERVER_CAN_EXECUTE, "Toggle random attachments on weapon spawn", 0, 1)
function SWEP:ClearAttachments()
	self.attachments = {
		barrel = {},
		sight = {},
		mount = {},
		grip = {},
		underbarrel = {},
		magwell = {},
	}

	if SERVER then
		if self.attachments and table.IsEmpty(self.attachments.barrel) then self.attachments.barrel = self.availableAttachments.barrel and self.availableAttachments.barrel["empty"] or {} end
		if self.attachments and table.IsEmpty(self.attachments.sight) then self.attachments.sight = self.availableAttachments.sight and self.availableAttachments.sight["empty"] or {} end
		if self.attachments and table.IsEmpty(self.attachments.mount) then self.attachments.mount = self.availableAttachments.mount and self.availableAttachments.mount["empty"] or {} end
	end

	if self.StartAtt then
		for i,att in ipairs(self.StartAtt) do
			hg.SetAttachment(self.attachments,att,self:GetClass())
		end
	end

	if SERVER then timer.Simple(0.2, function() self:SetNetVar("attachments",self.attachments) end) end
	self:CallOnRemove("removeAtt", function()
		self.attachments = nil
		if self.modelAtt then
			for atta, model in pairs(self.modelAtt) do
				if not atta then continue end
				if IsValid(model) then model:Remove() end
				self.modelAtt[atta] = nil
			end
		end
	end)

	return self.attachments
end

function hg.ClearAttachments(wep)
	local self = weapons.Get(wep)
	local tbl = {}

	tbl.attachments = {
		barrel = {},
		sight = {},
		mount = {},
		grip = {},
		underbarrel = {},
		magwell = {},
	}

	if SERVER then
		if tbl.attachments and table.IsEmpty(tbl.attachments.barrel) then tbl.attachments.barrel = self.availableAttachments.barrel and self.availableAttachments.barrel["empty"] or {} end
		if tbl.attachments and table.IsEmpty(tbl.attachments.sight) then tbl.attachments.sight = self.availableAttachments.sight and self.availableAttachments.sight["empty"] or {} end
		if tbl.attachments and table.IsEmpty(tbl.attachments.mount) then tbl.attachments.mount = self.availableAttachments.mount and self.availableAttachments.mount["empty"] or {} end
	end

	if self.StartAtt then
		for i,att in ipairs(self.StartAtt) do
			hg.SetAttachment(tbl.attachments,att,wep)
		end
	end
	
	return tbl.attachments
end

function hg.SetAttachment(tbl,att,wep)
	if not wep then return end
	local wep = weapons.Get(wep)
	if not wep then return end
	local placement = nil

	for plc, tbl in pairs(hg.attachments) do
		placement = tbl[att] and tbl[att][1] or placement
	end

	if not placement then return end

	local i
	if wep.availableAttachments[placement] then
		for n, atta in pairs(wep.availableAttachments[placement]) do
			i = istable(atta) and atta[1] == att and n or i
		end
	end
	
	tbl[placement] = i and wep.availableAttachments[placement][i] or {att, {}}
end

function SWEP:HasAttachment(whereabouts, attachment)
	if whereabouts == "sight" and attachment == "optic" and self.scopedef then return true, false end
	if not self.attachments then return false end
	local has = self.attachments[whereabouts]
	if not has or table.IsEmpty(has) then return false end
	if attachment then
		has = string.find(has[1], attachment) and true
	else
		has = has[1] ~= "empty"
	end
	
	return has and self.attachments[whereabouts], has and hg.attachments[whereabouts][self.attachments[whereabouts][1]]
end

function SWEP:GetAttachmentModel(whereabouts, attachment)
	if self:HasAttachment(whereabouts,attachment) and self.modelAtt and self.modelAtt[whereabouts] then
		return self.modelAtt[whereabouts]
	end
end

function SWEP:GetAttachmentInfo(whereabouts, attachment)
	local att,attdata = self:HasAttachment(whereabouts,attachment)

	return attdata
end

function SWEP:ThinkAtt()
end

local colBlackTransparent = Color(0, 0, 0, 125)
local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
function SWEP:ThinkAtt()
	if true then return end
	if SERVER then return end
	local att = self:GetMuzzleAtt()
	local owner = self:GetOwner()
	if not self:IsLocal() then return end
end


local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
local vecadd = Vector(0,0,0)
local hg_attachment_draw_distance = ConVarExists("hg_attachment_draw_distance") and GetConVar("hg_attachment_draw_distance") or CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "distance to draw attachments", 0, 4096)

function SWEP:DrawAttachments()
	local owner = self:GetOwner()
	self.attacments = self:GetNetVar("attachments",{})
	//self.Supressor = (self:HasAttachment("barrel", "supressor") and true) or self.SetSupressor
	local magwell, magwellData = self:HasAttachment("magwell")
	if magwellData then 
		self.Primary.ClipSize = magwellData.capacity
	else
		self.Primary.ClipSize = self.Primary.ClipSize2 or self.Primary.ClipSize
	end
	
	if SERVER then return end

	local gun = self:GetWeaponEntity()
	local att = self:GetMuzzleAtt(self:GetWM(), true)
	if not att then return end
	local pos, ang = att.Pos, att.Ang
	
	local available = self.availableAttachments

	if not IsValid(gun) or not att then return end
	
	if self.attachments == nil and CLIENT then
		self:SyncAtts()
		return
	end
	

	if self.availableAttachments.mount then
		if self.availableAttachments.mount then
			if not self.attachments then return end
			local data = self.attachments["sight"] and self.attachments["sight"][1] and hg.attachments.sight[self.attachments["sight"][1]] or self.attachments["underbarrel"] and self.attachments["underbarrel"][1] and hg.attachments.underbarrel[self.attachments["underbarrel"][1]]
			if data then
				self.attachments.mount = self.availableAttachments.mount[data.mountType]
			end
		end
	end
	

	self.modelAtt = self.modelAtt or {}
	local flagRemovehuy = false
	for plc,att in pairs(self.attachments) do
		local attdata = hg.attachments[plc][att[1]]
		
		local tblhuy = self:HasAttachment(plc) and available[plc] and ((available[plc][att[1]] and istable(available[plc][att[1]]) and available[plc][att[1]][2]) or (istable(available[plc]["removehuy"]) and available[plc]["removehuy"][attdata.mountType] or available[plc]["removehuy"]))
		if tblhuy then flagRemovehuy = true end
		
		if not tblhuy and not flagRemovehuy then tblhuy = att[2] end
		
		if istable(tblhuy) and not table.IsEmpty(tblhuy) then
			for index, mat in pairs(tblhuy) do
				local submat = gun:GetSubMaterial(index)
				--submat = #submat > 0 and submat or gun:GetMaterials()[index]
				
				if submat ~= (mat or "null") then gun:SetSubMaterial(index, mat or "null") end
			end
		end
		--print(att[1])
		if not self:HasAttachment(plc,att[1]) then continue end

		local model = self.modelAtt[plc]
		
		if owner ~= LocalPlayer() and hg_attachment_draw_distance:GetInt() ~= 0 and (hg_attachment_draw_distance:GetInt() ^ 2) < ((LocalPlayer():GetPos() - gun:GetPos()):LengthSqr()) and not attdata.shouldalwaysdraw then if IsValid(model) then model:Remove() end continue end
		
		if not IsValid(model) and attdata[2] and attdata[2] ~= "" then
			self.modelAtt[plc] = ClientsideModel(attdata[2])
			model = self.modelAtt[plc]
			model:SetNoDraw(true)
		end
		
		if not IsValid(model) then continue end

		if attdata[4] and not table.IsEmpty(attdata[4]) then
			for index, mat in pairs(attdata[4]) do
				local submat = model:GetSubMaterial(index)
				submat = #submat > 0 and submat or model:GetMaterials()[index]

				if submat ~= (mat or "null") then model:SetSubMaterial(index, mat or "null") end
			end
		end

		self:Attachment_Transform(model,pos,ang,plc,att,attdata,available)

		if attdata.drawFunction then
			attdata.drawFunction(self,model)
		end

		hg.attachmentFunc(self, attdata)
	end
end

if CLIENT then
	local vec = Vector()
	local addPos = Vector()
	local vecZero = Vector()
	local posa = Vector()
	local newview = Vector()
	function SWEP:GetCameraOverride(view)
		local info = self:GetAttachmentInfo("sight")
		local sight = info and info.offsetView
		if not info then
			info = self:GetAttachmentInfo("underbarrel")
			sight = info and info.offsetView
		end
		if sight then
			newview[1] = -sight[3]
			newview[2] = -sight[1]
			newview[3] = -sight[2]
			local model = self:GetAttachmentModel(info[1])
			if not IsValid(model) then return view.origin end
			local ang = select(3,self:GetTrace())
			ang:RotateAroundAxis(ang:Forward(),90)
			local pos = LocalToWorld(newview,angle_zero,model:GetPos(),ang)
			
			if info.viewFunction then
				pos = info.viewFunction(self,model,pos)
			end
			
			return pos
		end
		return false
	end
end
function SWEP:Attachment_Transform(model,pos,ang,plc,att,attdata,available)
	vecadd:Zero()
	if att[2] and isvector(att[2]) then vecadd:Add(att[2]) end
	if available[plc] and available[plc]["mount"] and isvector(available[plc]["mount"]) then vecadd:Add(available[plc]["mount"]) end
	if available[plc] and istable(available[plc]["mount"]) and available[plc]["mount"][attdata.mountType] and isvector(available[plc]["mount"][attdata.mountType]) then vecadd:Add(available[plc]["mount"][attdata.mountType]) end
	if attdata.offset and isvector(attdata.offset) then vecadd:Add(attdata.offset) end
	local addAng = attdata[3] + (available[plc] and (isangle(available[plc]["mountAngle"]) and available[plc]["mountAngle"] or istable(available[plc]["mountAngle"]) and available[plc]["mountAngle"][attdata.mountType] or angZero) or angZero)

	vecadd:Rotate(ang)
	vecadd:Add(pos)

	local _, ang = LocalToWorld(vecZero, addAng, vecZero, ang)

	if attdata.transformFunction then
		attdata.transformFunction(self,model,vecadd,ang)
	end

	if attdata.bBonemerge and not model.bBonemerged then
		model:SetParent(self:GetWM())
		model:AddEffects(EF_BONEMERGE)
		model.bBonemerged = true
	end

	if attdata.fScale and not model.bScaled then
		model:SetModelScale(attdata.fScale,0)
	end
	--model:SetParent(self:GetWM())
	model:SetRenderOrigin(vecadd)
	model:SetRenderAngles(ang)

	model:SetPos(vecadd)
	model:SetAngles(ang)
	
	model:SetupBones()
	local addred = string.find(att[1], "supressor") and 5 * self.dmgStack2 / 30 or 0
	render.SetColorModulation(1 + addred,1,1)
	if (IsValid(self:GetOwner()) and attdata.norenderWhenDrop) or not attdata.norenderWhenDrop then
		model:DrawModel()
	end
	render.SetColorModulation(1,1,1)

	if attdata.mount then
		if not IsValid(self.modelAtt["mountex"]) then
			self.modelAtt["mountex"] = ClientsideModel(attdata.mount)
			self.modelAtt["mountex"]:SetNoDraw(true)
		end

		local mount = self.modelAtt["mountex"]
		
		local pos = vecZero
		pos:Set(attdata.mountVec)
		pos:Rotate(model:GetAngles())
		pos:Add(model:GetPos())
		local _, ang = LocalToWorld(vecZero, attdata.mountAng, vecZero, model:GetAngles())
		mount:SetRenderOrigin(pos)
		mount:SetRenderAngles(ang)
		mount:SetPos(pos)
		mount:SetAngles(ang)
		mount:SetupBones()
		mount:DrawModel()
	end

	if attdata.holotex then--just create a second model with only glass for stencil (why cant i render just the glass bruuh)
		local model2 = model.model
		if not IsValid(model2) then
			model2 = ClientsideModel(attdata[2])
			model2:SetNoDraw(true)
			model.model = model2
			
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
		
		if not model2.submats then
			model2:SetSubMaterial(0,"null")
			model2:SetSubMaterial(1,"white")

			model:SetSubMaterial(0,"")
			model:SetSubMaterial(1,"null")
			for i,mat in pairs(model:GetMaterials()) do
				if mat != attdata.holotex or mat != attdata.mat then continue end
				model:SetSubMaterial(i,"null")
			end
			model2.submats = true
		end

		model2:SetRenderOrigin(vecadd)
		model2:SetRenderAngles(ang)

		model2:SetPos(vecadd)
		model2:SetAngles(ang)

		model2:SetupBones()
		model2:SetModelScale(attdata.modelscale or 1)
		//model2:DrawModel()
	end
end

if SERVER then
	util.AddNetworkString("hmcd_togglelaser")
	local laserThingies = {
		[0] = 1,
		[1] = 0,
		[2] = 3,
		[3] = 2,
	}

	concommand.Add("hmcd_togglelaser", function(ply, cmd, args)
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep.attachments then return end
		if not wep:HasAttachment("underbarrel") then return end
		wep.lasertoggle = laserThingies[wep.lasertoggle or 0]
		ply:EmitSound("weapons/ump45/ump45_fireselect.wav", 65)
		net.Start("hmcd_togglelaser")
		net.WriteEntity(wep)
		net.WriteInt(wep.lasertoggle, 5)
		net.Broadcast()
	end)

	local flashlightThingies = {
		[0] = 2,
		[2] = 0,
		[1] = 3,
		[3] = 1,
	}

	hook.Add("PlayerSwitchFlashlight", "flashlightHuy", function(ply)
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep.attachments then return end
		if not wep:HasAttachment("underbarrel") then return false end
		wep.lasertoggle = flashlightThingies[wep.lasertoggle or 0]
		ply:EmitSound("weapons/ump45/ump45_fireselect.wav", 65)
		net.Start("hmcd_togglelaser")
		net.WriteEntity(wep)
		net.WriteInt(wep.lasertoggle, 5)
		net.Broadcast()
		return false
	end)
else
	net.Receive("hmcd_togglelaser", function()
		local wep = net.ReadEntity()
		local turn = net.ReadInt(5)
		wep.lasertoggle = turn
	end)
end

if CLIENT then
	local function removeFlashlights(self)
		if self.flashlight and self.flashlight:IsValid() then
			self.flashlight:Remove()
			self.flashlight = nil
		end
	end

	local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
	local mat = Material("sprites/rollermine_shock")
	local mat2 = Material("sprites/light_glow02_add_noz")
	local mat3 = Material("effects/flashlight/soft")
	local mat4 = Material("sprites/light_ignorez", "alphatest")
	local colorTransparent = Color(0,0,0,0)
	function SWEP:DrawLaser()
		if not self.shouldTransmit then return end
		local laser = self.attachments.underbarrel
		if not laser or table.IsEmpty(laser) and not self.laser then return end
		local attachmentData
		if laser and not table.IsEmpty(laser) then
			attachmentData = hg.attachments.underbarrel[laser[1]]
		else
			attachmentData = self.laserData
		end

		if not self.modelAtt then
			self.modelAtt = {}
			return
		end
		
		local model = self.modelAtt["underbarrel"] or self:GetWeaponEntity()
		if not IsValid(model) then return end
		local pos, anga = model:GetPos(), model:GetAngles()
		local pos, ang = LocalToWorld(attachmentData.offsetPos or vecZero, attachmentData.offsetAng or angZero, pos, anga)
		//local tr, _, _ = self:GetTrace()
		
		//if not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then ang = anga end

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
			end
		--]]

		if (self.lasertoggle == 2 or self.lasertoggle == 3) and attachmentData.supportFlashlight and (not attachmentData.nvgFlashlight or (lply.NVGEnabled)) then
			self.flashlight = self.flashlight or ProjectedTexture()
			local tr = util.TraceLine({
				start = pos + ang:Forward() * 10,
				endpos = pos + ang:Forward() * 400 ,
				filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
				mask = MASK_VISIBLE
			})
			if tr.Hit then
				--local dlight = DynamicLight( self:EntIndex() )
				--if ( dlight ) then
				--	local frac = (1 - tr.Fraction)
				--	if (1 - tr.Fraction) > 0.96 then
				--		frac = 0
				--	end
				--	self.DynmanicFlashlightLerpFrac = LerpFT(0.05,self.DynmanicFlashlightLerpFrac or frac, frac)
				--	dlight.pos = tr.HitPos + tr.HitNormal * 30
				--	dlight.r = 255
				--	dlight.g = 255
				--	dlight.b = 255
				--	dlight.brightness = 1 * self.DynmanicFlashlightLerpFrac
				--	dlight.decay = 200
				--	dlight.size = 556 * self.DynmanicFlashlightLerpFrac
				--	dlight.dietime = CurTime() + 0.1
				--end
			end
			if self.flashlight and self.flashlight:IsValid() then
				self.flashlight:SetTexture((attachmentData.mat or mat3):GetTexture("$basetexture"))
				self.flashlight:SetFarZ(attachmentData.farZ or 1500)
				self.flashlight:SetHorizontalFOV(attachmentData.size or 50)
				self.flashlight:SetVerticalFOV(attachmentData.size or 50)
				self.flashlight:SetConstantAttenuation(attachmentData.brightness2 or 1)
				self.flashlight:SetLinearAttenuation(attachmentData.brightness or 50)
				self.flashlight:SetPos(pos + ang:Forward() * 10)
				self.flashlight:SetAngles(ang)
				if (self.flashlightupdate or 0) < CurTime() then 
					self.flashlightupdate = CurTime() + 0.01
					self.flashlight:Update()
				end
				local view = render.GetViewSetup(true)
				local deg = ang:Forward():Dot(view.angles:Forward())
				
				local chekvisible = util.TraceLine({
					start = pos + ang:Forward() * 10,
					endpos = view.origin,
					filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
					mask = MASK_VISIBLE
				})
				if deg < 0 and not chekvisible.Hit then
					render.SetMaterial(mat2)
					render.DrawSprite(pos + ang:Forward() * 0.5, 200 * math.min(deg, 0), 20 * math.min(deg, 0), color_white)
					render.DrawSprite(pos + ang:Forward() * 0.5, 50 * math.min(deg, 0), 150 * math.min(deg, 0), color_white)
				end
			end
		else
			removeFlashlights(self)
		end

		if self.lasertoggle == 1 or self.lasertoggle == 3 then
			local tr = util.TraceLine({
				start = pos,
				endpos = pos + ang:Forward() * 10000,
				filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
				mask = MASK_SHOT
			})

			render.SetMaterial(mat)
			render.DrawBeam(pos, tr.HitPos, 5, 0, 800, ColorAlpha(attachmentData.color,20))
			--local view = render.GetViewSetup(true)
			--[[local chekvisible = util.TraceLine({
				start = tr.HitPos,
				endpos = view.origin,
				filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
				mask = MASK_VISIBLE
			})--]]
			--if not tr.Hit then
				local distance = pos:Distance(tr.HitPos)
				distance = math.max(distance/300,0.2)
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
				render.SetStencilFailOperation( STENCIL_KEEP )
				render.SetStencilZFailOperation( STENCIL_KEEP )

				render.SetColorMaterial()
				render.DrawSphere(tr.HitPos,math.min(5 * (attachmentData.laserSize or 1) * distance,20),20,20,colorTransparent)

				render.SetStencilCompareFunction( STENCIL_EQUAL )

				--render.ClearBuffersObeyStencil(128,128,128,128,false)
				
				render.SetMaterial(mat2)
				local bLPly = self:GetOwner() == LocalPlayer()
				if bLPly then
					distance = distance * 1.5
				end
				local div = distance/(bLPly and 6 or 2.5) * (attachmentData.laserSize ~= nil and (attachmentData.laserSize / 10) or 1)
				local colore = Color(attachmentData.color.r/(div),attachmentData.color.g/(div),attachmentData.color.b/(div))		
				local fSize = math.min(5 * (attachmentData.laserSize or 1) * distance,bLPly and 120 or 30)
				render.DrawSprite(tr.HitPos, fSize, fSize, colore)

				--render.DrawQuadEasy( tr.HitPos, tr.HitNormal, math.min(5 * distance,20), math.min(5 * distance,20), colore, 0 )

				render.SetStencilEnable( false )

				local view = render.GetViewSetup(true)
				local deg = ang:Forward():Dot(view.angles:Forward())
				deg = math.ease.InBack(-deg-0.355)*40
				deg = -deg
				local distance = math.min(pos:Distance(view.origin)/200,3)
				local chekvisible = util.TraceLine({
					start = pos + ang:Forward() * 10,
					endpos = view.origin,
					filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
					mask = MASK_VISIBLE
				})
				if deg < 0 and not chekvisible.Hit then
					render.SetMaterial(mat2)
					render.DrawSprite(pos + ang:Forward() * 3, 125 * math.min(deg, 0)*math.max(distance,1), 55 * math.min(deg, 0)*math.max(distance,1), attachmentData.color)
					render.DrawSprite(pos + ang:Forward() * 3, 55 * math.min(deg, 0)*math.max(distance,1), 125 * math.min(deg, 0)*math.max(distance,1), attachmentData.color)
				end
			--end
		end
	end
end

function SWEP:AttachAnim()
	self:SetNWFloat("addAttachment",CurTime())
end

function SWEP:SyncAtts()
	--net.Start("sync_atts")
	--net.WriteEntity(self)
	--net.SendToServer()
end-- ХD

if CLIENT then
	concommand.Add("ZB_AttachAdd", function(ply, cmd, args)
		local att = args[1]
		net.Start("ZB_AttachAdd")
		net.WriteString(att)
		net.SendToServer()
	end)

	concommand.Add("ZB_AttachRemove", function(ply, cmd, args)
		local att = args[1]
		net.Start("ZB_AttachRemove")
		net.WriteString(att)
		net.SendToServer()
	end)

	concommand.Add("ZB_AttachDrop", function(ply, cmd, args)
		local att = args[1]
		net.Start("ZB_AttachDrop")
		net.WriteString(att)
		net.SendToServer()
	end)

	local CreateMenu
	local menuPanel
	local function dropAttachment(att)
		RunConsoleCommand("ZB_AttachDrop", att)
	end

	local function removeAttachment(att)
		RunConsoleCommand("ZB_AttachRemove", att)
		/*timer.Simple(0.6,function()
			if IsValid(menuPanel) then
				CreateMenu()
			end
		end)*/
	end

	local function addAttachment(att)
		RunConsoleCommand("ZB_AttachAdd", att)
		/*timer.Simple(0.6,function()
			if IsValid(menuPanel) then
				CreateMenu()
			end
		end)*/
	end

	surface.CreateFont("AttachFONT", {
		font = "Bahnschrift",
		size = ScreenScale(5),
		extended = true,
		weight = 500,
		antialias = true
	})

	local plyAttachments = {}
	local weaponAttachments = {}
	local drop = false
	local gray = Color(200, 200, 200)
	local red = Color(75,25,25)
	local redselected = Color(150,0,0)
	local blue = Color(200, 200, 255)
	local black = Color(24,24,24)
	local whitey = Color(255, 255, 255)
	local chosen2
	local doubleclick

	local blurMat = Material("pp/blurscreen")
    local Dynamic = 0
	
	local function refreshtbl()
		local tblcpy = {}

		local inv = lply:GetNetVar("Inventory")
		if inv == nil then return end

		local tbl = inv["Attachments"]
		local wep = lply:GetActiveWeapon()
		local achtbl = {}
		if IsValid(wep) and ishgweapon(wep) then
			achtbl = lply:GetActiveWeapon():GetNetVar("attachments")
		end
		
		for i, att in pairs(tbl) do
			if !att then continue end
			table.insert(tblcpy, {att, false})
		end

		if achtbl then
			for i, att in pairs(achtbl) do
				if !att or !next(att) then continue end
				table.insert(tblcpy, {att[1], true})
			end
		end

		return tblcpy
	end

	hg.GetAttachmentsInv = refreshtbl

	hook.Add("OnNetVarSet", "attachmentPanelRefresh", function(index, key, var)
		if key == "Inventory" or key == "attachments" and Entity(index) == lply:GetActiveWeapon() then
			if IsValid(hg.attachmentsMenuPanel) and hg.attachmentsMenuPanel.RefreshTbl then
				hg.attachmentsMenuPanel:RefreshTbl()
			end
		end
	end)

	local mat = Material("homigrad/vgui/gradient_left.png")
	local clr_blackalpha = Color(0, 0, 0, 100)

	CreateMenu = function()
		if IsValid(hg.attachmentsMenuPanel) then
			hg.attachmentsMenuPanel:Remove()
			hg.attachmentsMenuPanel = nil
		end
	
		local tblcpy = refreshtbl()

		local frame = vgui.Create( "ZFrame" )
		hg.attachmentsMenuPanel = frame
		frame:SetTitle("")
		frame:SetSize( ScrW() / 3, ScrH() / 2 )
		frame:SetPos( ScrW() * 0.5 - frame:GetWide() * 0.5,ScrH() + 500 )
		frame:MakePopup()
		frame:SetKeyboardInputEnabled(false)

		frame:SetAlpha(0)
	
		frame:MoveTo(frame:GetX(), ScrH() / 2 - frame:GetTall() / 2, 0.5, 0, 0.3, function() end)
		frame:AlphaTo( 255, 0.2, 0.1, nil )

		function frame:First()
		end 

		local lbl = vgui.Create("DLabel", frame)
		lbl:SetText( "" )
		lbl:SetFont("ZCity_Tiny")
		lbl:SetSize(0, ScreenScaleH(15))
		lbl:Dock(BOTTOM)
		lbl:DockMargin(10,0,0,10)

		lbl.Paint = function(self, w, h)
			draw.SimpleText("LMB - Add attachment | RMB - remove attachment", "ZCity_Tiny", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local scroll = vgui.Create("DScrollPanel",frame)
		scroll:Dock(FILL)
		frame.scroll = scroll
	
		local sbar = scroll:GetVBar()
		sbar:SetHideButtons(true)

		function sbar:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, clr_blackalpha)
		end

		function sbar.btnGrip:Paint(w, h)
			self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.2,(self:IsHovered() and 1 or 0.2))
			draw.RoundedBox(0, 0, 0, w, h, Color(100 * self.lerpcolor, 10, 10))
		end

		scroll.Think = function()
			//tblcpy = refreshtbl()
		end

		function frame:RefreshTbl()
			tblcpy = refreshtbl()

			if IsValid(scroll) then
				scroll:Remove()
			end

			scroll = vgui.Create("DScrollPanel", frame)
			scroll:Dock(FILL)
			frame.scroll = scroll
			
			table.sort(tblcpy, function(a, b) return ((string.byte(a[1][1], 1, 1) + (a[2] and 9999 or 0)) > (string.byte(b[1][1], 1, 1) + (b[2] and 9999 or 0))) end)
			for k, v in pairs(tblcpy) do
				if !hg.attachmentslaunguage[v[1]] then continue end
				local but = vgui.Create("DButton")
				but:SetText( hg.attachmentslaunguage[v[1]]..(v[2] and " - on the weapon" or "") )
				but:SetFont("ZCity_Tiny")
				but:Dock( TOP )
				but:DockMargin( 0, 0, 0, 5 )
				but:SetSize(0, ScreenScaleH(20))

				local but2 = vgui.Create("DButton", but)
				but2:SetText( "Drop" )
				but2:SetFont("ZCity_SuperTiny")
				but2:Dock( RIGHT )

				but2.Paint = function(self, w, h)
					surface.SetDrawColor(50, 0, 0, 125)
					surface.DrawRect(0, 0, w, h)
				end

				but2.DoClick = function()
					dropAttachment(v[1])
				end

				but.Paint = function(self, w, h)
					surface.SetMaterial(mat)
					local typea = string.byte(v[1], 1, 1) - 100
					surface.SetDrawColor(v[2] and 50 or 100, v[2] and 0 or typea * 9, 0, 255)
					surface.DrawTexturedRect(0, 0, w, h)
				end
	
				local img = vgui.Create("DImage", but)
				img:SetSize(ScreenScaleH(20), ScreenScaleH(20))
				img:Dock(LEFT)
				img:DockMargin( 5, 0, 0, 0 )
				if hg.attachmentsIcons[v[1]] then
					img:SetImage( hg.attachmentsIcons[v[1]] )
				end

				/*but.Think = function()
					if !hg.attachmentslaunguage[tblcpy[k][1]] then return end
	
					img:SetImage( hg.attachmentsIcons[tblcpy[k][1]] )
	
					but:SetText( hg.attachmentslaunguage[tblcpy[k][1]]..(tblcpy[k][2] and " - on the weapon" or "") )
				end*/
	
				but.DoClick = function()
					if v[2] then return end
	
					addAttachment(v[1])
				end
	
				but.DoRightClick = function()
					if !v[2] then return end
	
					removeAttachment(v[1])
				end
	
				scroll:AddItem(but)
			end
		end

		frame:RefreshTbl()
	end

	concommand.Add("hg_get_attachments", function(ply, cmd, args)
		CreateMenu()
	end)
end