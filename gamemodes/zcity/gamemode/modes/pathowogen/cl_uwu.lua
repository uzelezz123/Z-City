local MODE = MODE

MODE.HellYeahMusic = MODE.HellYeahMusic
MODE.MusicLerp = 0
MODE.MusicTarget = 0

MODE.ExtractionMusic = MODE.ExtractionMusic

MODE.LastHeliCheck = 0

function MODE:Think()
	self.MusicLerp = math.Approach(self.MusicLerp, self.MusicTarget, FrameTime() / 10)

	if self.MusicLerp > 0.01 then
		if !IsValid(self.HellYeahMusic) then
			sound.PlayFile("sound/zbattle/hellyeah.mp3", "noplay noblock", function(audio)
				if IsValid(audio) then
					audio:SetVolume(0)
					audio:EnableLooping(true)
					audio:Play()
					self.HellYeahMusic = audio
				end
			end)
		end

		if IsValid(self.HellYeahMusic) then
			self.HellYeahMusic:SetVolume(self.MusicLerp)
		end
	else
		if IsValid(self.HellYeahMusic) then
			self.HellYeahMusic:Stop()
			self.HellYeahMusic = nil
		end
	end

	if lply:InVehicle() then
		local vehicle = lply.GlideGetVehicle and lply:GlideGetVehicle() or lply:GetVehicle()
		if IsValid(vehicle) and vehicle.HornSound then
			local vel = vehicle:GetVelocity():Length()
			if vel > 500 then
				self.MusicTarget = math.min(1, vel / 1000)
			else
				self.MusicTarget = 0
			end
		end
	else
		self.MusicTarget = 0
	end

	if !self.ExtractionMusic and lply.PlayerClassName != "commanderforces" and lply:Alive() then
		local point = (IsValid(zb.uwucopter) and zb.uwucopter:GetPos()) or zb.ExtractPoint

		if !point then return end
		if self.LastHeliCheck > CurTime() then return end

		if lply:GetPos():DistToSqr(point) < 3000000 then
			if !IsValid(self.ExtractionMusic) then
				sound.PlayFile("sound/zbattle/extracted.ogg", "", function(station)
					if IsValid(station) then
						self.ExtractionMusic = station
					end
				end)
			end
		end

		self.LastHeliCheck = CurTime() + 1
	end
end

function MODE:RoundStart()
	zb.uwucopter = nil
	zb.ExtractPoint = nil
	zb.traitorExtract = nil
end

net.Receive("zb_furbriefing", function()
	vgui.Create("ZB_FurBriefing")
end)

net.Receive("zb_furfurbriefing", function()
	vgui.Create("ZB_FurFurBriefing")
end)

net.Receive("zb_furtraitorbriefing", function()
	vgui.Create("ZB_FurTraitorBriefing")
end)

net.Receive("zb_commandertransmit", function()
	if IsValid(zb.DialogueWindow) then return end

	local dialogue = vgui.Create("ZB_Dialogue")
	dialogue:SetTextAutoClose(net.ReadString())
end)

net.Receive("zb_contractortransmit", function()
	if IsValid(zb.DialogueWindow) then return end

	local dialogue = vgui.Create("ZB_DialogueTraitor")
	dialogue:SetTextAutoClose(net.ReadString())
end)


net.Receive("zb_extractionheli", function()
	MODE.ExtractionMusic = nil
	zb.uwucopter = net.ReadEntity()
end)

net.Receive("zb_extractionpoint", function()
	zb.ExtractPoint = net.ReadVector()
end)

net.Receive("zb_traitorextractionpoint", function()
	zb.traitorExtract = true
	zb.ExtractPoint = net.ReadVector()
end)

local ExtractionColor = Color(210, 145, 80)
local UpVector = Vector(0, 0, 80)

function MODE:PostDrawTranslucentRenderables(depth, skybox, skybox2)
	if zb.traitorExtract then
		cam.IgnoreZ(true)
	end

	if !zb.ExtractPoint then return end
	local pos = zb.ExtractPoint

	local angle = (pos - LocalPlayer():GetPos()):Angle()

	angle = Angle(0, angle.y, 0)

	angle:RotateAroundAxis( angle:Up(), -90 )
	angle:RotateAroundAxis( angle:Forward(), 90 )

	local scale = (zb.traitorExtract and math.max(LocalPlayer():GetPos():DistToSqr(pos) / 100000000, 0.05)) or 0.05

	cam.Start3D2D( pos + UpVector, angle, scale)
		draw.SimpleText("[Extraction]", "ZB_ScrappersHumongous", 10, 10, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("[Extraction]", "ZB_ScrappersHumongous", 0, 0, ExtractionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()

	if zb.traitorExtract then
		cam.IgnoreZ(false)
	end
end

function MODE:HUDPaint()
	if !LocalPlayer():Alive() then return end

	local extraction = LocalPlayer():GetLocalVar("zb_Pathowogen_Extraction")

	if extraction then
		local time = math.ceil(extraction - CurTime())
		if time > 0 then
			draw.SimpleText("Extracting in: " .. time, "ZB_ScrappersMedium", sw * 0.01 + 2, sh * 0.97 + 2, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText("Extracting in: " .. time, "ZB_ScrappersMedium", sw * 0.01, sh * 0.97, ExtractionColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

net.Receive("ZB_Pathowogen_RoundEnd", function()
	if IsValid(zb.DialogueWindow) then
		zb.DialogueWindow:Remove()
	end

	local win = net.ReadUInt(3)
	local data = net.ReadTable()

	local panel = vgui.Create("ZB_PathowogenEnd")
	panel:SetData(win, data)
end)