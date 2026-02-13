TOOL.Category = "ZBattle"
TOOL.Name = "Point Editor"

TOOL.ClientConVar["point"] = ""

function TOOL:LeftClick(trace, attach)
	local ply = self:GetOwner()
	if not ply:IsAdmin() then
		ply:ChatPrint("You are a furry")
		return false
	end

	if SERVER then
		local pos = trace.HitPos

		local name = ply:GetInfo(self:GetMode() .. "_point")
		if not name then return end

		local ang = ply:EyeAngles()
		ang.x = 0

		local pointData = {
			pos = pos,
			ang = ang
		}

		zb.CreateMapPoint(name, pointData)
		zb.SendPoints()
	end

	return true
end

function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if not ply:IsAdmin() then
		ply:ChatPrint("You are a furry")
		return false
	end

	if SERVER then
		timer.Simple(0.1, function()
			if ply:KeyDown(IN_ATTACK2) then return end

			local pos = trace.HitPos
			local closest_distance = 500
			local closest_winner_point
			local closest_winner_key

			for k, v in pairs(zb.Points) do
				if not v.Points then continue end

				for k2, v2 in ipairs(v.Points) do
					if v2.pos:Distance(pos) <= closest_distance then
						closest_winner_point = k
						closest_winner_key = k2
						closest_distance = v2.pos:Distance(pos)
					end
				end
			end

			if closest_winner_key then
				zb.RemoveMapPoint(closest_winner_point, closest_winner_key, true)
				zb.SendPoints()
			end
		end)
	end

	return true
end

function TOOL:Think()
	self.IsHolding = self.IsHolding or false

	local ply = self:GetOwner()

	if ply:KeyDown(IN_ATTACK2) then
		if not self.LastHold then self.LastHold = CurTime() end
		if not self.Trace1 then self.Trace1 = util.QuickTrace(ply:EyePos(), ply:EyeAngles():Forward() * 999999, ply) end
		if CurTime() - self.LastHold >= 0.1 then self.IsHolding = true end
	else
		if SERVER and self.IsHolding then
			local trace2 = util.QuickTrace(ply:EyePos(), ply:EyeAngles():Forward() * 1000, ply)
			local distance = self.Trace1.HitPos:Distance(trace2.HitPos)

			for k, v in pairs(zb.Points) do
				if not v.Points then continue end

				for i = #v.Points, 1, -1 do
					if self.Trace1.HitPos:Distance(v.Points[i].pos) <= distance then zb.RemoveMapPoint(k, i, true) end
				end
			end

			zb.SendPoints()
		end

		self.LastHold = nil
		self.IsHolding = false
		self.Trace1 = nil
	end
end

-- local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Description = "LMB to add point,\nRMB to remove nearest point" -- ура удобный инструмент я в шоке!!
	})

	local dlist = vgui.Create("DListView")
	dlist:Dock(TOP)
	dlist:SetTall(ScreenScale(100))
	dlist:AddColumn("Point Name")

	for k, _ in SortedPairs(zb.Points) do
		dlist:AddLine(k)
	end

	CPanel:AddItem(dlist)

	dlist.OnRowSelected = function(lst, index, pnl) RunConsoleCommand("point_editor_point", pnl:GetValue(1)) end
end

function TOOL:Allowed()
	return self:GetOwner():IsAdmin()
end

function TOOL:Deploy()
	if SERVER then
		local ply = self:GetOwner()

		ply:EmitSound("zbattle/pointinator.mp3")

		zb.SendPointsToPly(ply)
	end
end

local red = Color(255, 0, 0, 100)
function TOOL:DrawHUD()
	local lply = LocalPlayer()
	if not lply:IsAdmin() then return end

	local radius = 4
	local wideSteps = 10
	local tallSteps = 10

	local angeye = lply:EyeAngles()
	angeye:RotateAroundAxis(angeye:Forward(), 90)
	angeye:RotateAroundAxis(angeye:Right(), 90)

	for id, points in pairs(zb.ClPoints) do
		for id2, point in pairs(points) do
			if not point then continue end

			local pos = point.pos
			local ang = point.ang

			render.SetColorMaterial() -- white material for easy coloring

			local color = zb.Points[id].Color
			local name = zb.Points[id].Name
			local text = name .. " #" .. id2

			surface.SetFont("ChatFont")

			local txtsize, _txtsizey = surface.GetTextSize(text)

			if EyePos():DistToSqr(pos) <= 10000000 then
				cam.Start3D()
					cam.IgnoreZ(true) -- makes next draw calls ignore depth and draw on top
					render.DrawWireframeBox(pos, ang, Vector(15, 1, 1), -Vector(0, 1, 1), color) -- draws the box
					render.DrawWireframeSphere(pos, radius, wideSteps, tallSteps, color)
					cam.IgnoreZ(false) -- disables previous call
				cam.End3D()
			end

			local data = pos:ToScreen()
			local distance = lply:GetPos():Distance(pos)
			local factor = 1 - math.Clamp(distance / 4096, 0, 1)
			local alpha = math.max(255 * factor, 20)

			surface.SetDrawColor(0, 0, 0, alpha - 15)
			surface.DrawRect(data.x - txtsize / 1.7, data.y - 7.5, 15, 15)

			surface.SetDrawColor(color.r, color.g, color.b, alpha)
			surface.DrawRect(data.x - txtsize / 1.7, data.y - 6.5, 13, 13)

			draw.SimpleTextOutlined(text, "ChatFont", data.x, data.y, ColorAlpha(color_white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(color_black, alpha))
		end
	end

	if self.IsHolding then
		local ply = lply
		local trace2 = util.QuickTrace(EyePos(), EyeAngles():Forward() * 1000, ply)

		cam.Start3D()
			render.SetColorMaterial()
			render.DrawSphere(self.Trace1.HitPos, self.Trace1.HitPos:Distance(trace2.HitPos), 50, 50, red)
		cam.End3D()
	else
		trace2 = nil
	end
end

local clr, point_editor = Color(20, 20, 20), GetConVar("point_editor_point")
function TOOL:DrawToolScreen(width, height)
	surface.SetDrawColor(clr)
	surface.DrawRect(0, 0, width, height)

	draw.SimpleText("#PLUVERS", "ZB_ScrappersMedium", width / 2, height / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local ply = self:GetOwner()
	if ply:GetInfo("point_editor_point") == "" or !point_editor then return end

	draw.SimpleText(point_editor:GetString(), "ZB_ScrappersSmall", width / 2, height * 0.7, zb.Points[point_editor:GetString()].Color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end