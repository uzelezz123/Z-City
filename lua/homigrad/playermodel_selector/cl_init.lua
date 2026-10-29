--;; Huge thanks to the developers of the Enhanced PlayerModel Selector mod. I borrowed some parts of it for certain features.

local clr = {
	bg = Color(28, 28, 28, 240),
	border = Color(75, 75, 75),
	cat = Color(60, 60, 60),
	catbar = Color(42, 42, 42),
	row = Color(43, 43, 43, 235),
	rowhov = Color(56, 56, 56, 240),
	rowbar = Color(47, 47, 47, 235),
	red = Color(184, 169, 201),
	redhov = Color(184, 169, 201),
	green = Color(80, 125, 65),
	greenhov = Color(100, 150, 85),
	orange = Color(220, 150, 45),
	text = Color(235, 235, 235, 235),
	dim = Color(140, 140, 140, 220),
	dark = Color(28, 28, 28),
	shadow = Color(0, 0, 0, 55),
	gray = Color(70, 70, 70)
}

for name, tbl in pairs({Title = {26, 500}, Category = {21, 400}, Item = {19, 400}, Small = {14, 300}, Btn = {16, 500}}) do
	surface.CreateFont("ZB_PMS_" .. name, {font = "Bahnschrift", size = tbl[1], weight = tbl[2], antialias = true})
end

local sndClick, sndRelease, sndHover = "shitty/tap_depress.wav", "shitty/tap_release.wav", "shitty/tap-resonant.wav"
local idleAnims = {"idle_all_01", "menu_walk", "pose_standing_02", "idle_fist", "idle"}
local Menu

local function CanUse()
	return engine.ActiveGamemode() == "sandbox" or LocalPlayer():IsAdmin()
end

local function PaintBG(self, w, h)
	if hg and hg.DrawBlur then hg.DrawBlur(self, 4) end
	surface.SetDrawColor(clr.bg)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(120, 120, 130, 12)
	local sp, off = 64, (CurTime() * 18) % 64
	for x = 0, math.ceil(w / sp) do surface.DrawRect(x * sp - off, 0, 1, h) end
	for y = 0, math.ceil(h / sp) do surface.DrawRect(0, y * sp - off + sp, w, 1) end

	surface.SetDrawColor(clr.border)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
end

local function Btn(parent, text, base, hover, txt)
	local b = vgui.Create("DButton", parent)
	b:SetText(text)
	b:SetFont("ZB_PMS_Btn")
	b:SetTextColor(txt or clr.text)
	b.OnCursorEntered = function() surface.PlaySound(sndHover) end
	b.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and (hover or clr.rowhov) or (base or clr.row))
		draw.RoundedBox(0, 0, h - 3, w, 3, clr.shadow)
	end
	return b
end

local function Category(parent, text, big)
	local bar = vgui.Create("DPanel", parent)
	bar:Dock(TOP)
	bar:SetTall(big and 42 or 38)
	bar:DockMargin(0, 0, 0, big and 10 or 8)
	bar.Paint = function(self, w, h)
		surface.SetDrawColor(clr.cat)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(clr.catbar)
		surface.DrawRect(0, h - 5, w, 5)
		draw.SimpleText(text, big and "ZB_PMS_Title" or "ZB_PMS_Category", w / 2, h / 2 - 2, clr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	return bar
end

local function CloseCross(parent, frame)
	local b = vgui.Create("DButton", parent)
	b:SetSize(38, 38)
	b:Dock(RIGHT)
	b:DockMargin(0, 1, 6, 1)
	b:SetText("")
	b.Paint = function(self, w, h)
		surface.SetDrawColor(self:IsHovered() and Color(255, 110, 110) or clr.text)
		for i = -1, 1 do
			surface.DrawLine(12, 12 + i, w - 12, h - 12 + i)
			surface.DrawLine(w - 12, 12 + i, 12, h - 12 + i)
		end
	end
	b.OnCursorEntered = function() surface.PlaySound(sndHover) end
	b.DoClick = function()
		surface.PlaySound(sndRelease)
		frame:Close()
	end
end

local function StyleScroll(scroll)
	local bar = scroll:GetVBar()
	bar:SetWide(8)
	bar:SetHideButtons(true)
	bar.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 70)
		surface.DrawRect(1, 0, w - 2, h)
	end
	bar.btnGrip.Paint = function(self, w, h)
		surface.SetDrawColor(self:IsHovered() and 120 or 90, self:IsHovered() and 120 or 90, self:IsHovered() and 120 or 90)
		surface.DrawRect(1, 0, w - 2, h)
	end
end

local function StyleEntry(entry, placeholder)
	entry:SetFont("ZB_PMS_Item")
	entry:SetUpdateOnType(true)
	entry.Paint = function(self, w, h)
		surface.SetDrawColor(clr.dark)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(self.BorderColor or clr.gray)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		self:DrawTextEntryText(clr.text, Color(120, 120, 120), clr.text)
		if placeholder and self:GetText() == "" then
			draw.SimpleText(placeholder, "ZB_PMS_Item", 8, h / 2, clr.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

local function ToggleRow(parent, text, getState, onClick)
	local row = vgui.Create("DPanel", parent)
	row:Dock(BOTTOM)
	row:SetTall(40)
	row:DockMargin(0, 8, 0, 0)
	row.Paint = function(self, w, h)
		surface.SetDrawColor(clr.row)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(clr.rowbar)
		surface.DrawRect(0, h - 3, w, 3)
		draw.SimpleText(text, "ZB_PMS_Item", 12, h / 2, clr.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local toggle = vgui.Create("DButton", row)
	toggle:SetText("")
	toggle:SetWide(52)
	toggle:Dock(RIGHT)
	toggle:DockMargin(0, 8, 10, 8)
	local anim = getState() and 1 or 0
	toggle.Paint = function(self, w, h)
		anim = Lerp(FrameTime() * 10, anim, getState() and 1 or 0)
		draw.RoundedBox(0, 0, 0, w, h, clr.dark)
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(0, 0, 0, 30))
		local size = h - 12
		local pos = Lerp(anim, 6, w - size - 6)
		draw.RoundedBox(0, pos, 6, size, size, Color(Lerp(anim, 180, 80), Lerp(anim, 30, 120), Lerp(anim, 30, 50)))
		surface.SetDrawColor(0, 0, 0, Lerp(anim, 150, 40))
		surface.DrawRect(pos, size + 4, size, 3)
	end
	toggle.OnCursorEntered = function() surface.PlaySound(sndHover) end
	toggle.DoClick = function()
		surface.PlaySound(sndClick)
		onClick()
	end
	return row
end

function Menu()
	if not CanUse() then return end
	if IsValid(PMS_Frame) then PMS_Frame:Close() end

	local lply = LocalPlayer()
	local sel = {model = lply:GetModel(), skin = lply:GetSkin() or 0, groups = {}, custom = false}
	for k = 0, lply:GetNumBodyGroups() - 1 do
		sel.groups[k] = lply:GetBodygroup(k)
	end

	local frame = vgui.Create("ZFrame")
	frame:SetSize(math.Clamp(ScrW() * 0.68, 980, 1400), math.Clamp(ScrH() * 0.78, 600, 860))
	frame:Center()
	frame:SetTitle("")
	frame:SetDraggable(true)
	frame:ShowCloseButton(false)
	frame:SetBorder(false)
	frame:MakePopup()
	frame.Paint = PaintBG
	PMS_Frame = frame

	local content = vgui.Create("DPanel", frame)
	content.Paint = nil
	frame.PerformLayout = function(_, w, h)
		content:SetPos(2, 2)
		content:SetSize(w - 4, h - 4)
	end

	CloseCross(Category(content, "Player Model Selector", true), frame)

	local body = vgui.Create("DPanel", content)
	body:Dock(FILL)
	body.Paint = nil

	local left = vgui.Create("DPanel", body)
	left:Dock(LEFT)
	left:SetWide(frame:GetWide() * 0.4)
	left:DockMargin(0, 0, 6, 0)
	left.Paint = nil

	local right = vgui.Create("DPanel", body)
	right:Dock(FILL)
	right:DockMargin(6, 0, 0, 0)
	right.Paint = nil

	Category(left, "Preview")

	local preview, nickEntry, rebuildCustomize, ApplyToPreview, SetPreviewModel

	local function SendApply()
		local num = IsValid(preview.Entity) and preview.Entity:GetNumBodyGroups() or 0
		local t = {}
		for k = 0, num - 1 do t[k + 1] = sel.groups[k] or 0 end

		net.Start("ZC_PMS_Apply")
			net.WriteString(sel.model)
			net.WriteUInt(math.Clamp(sel.skin, 0, 255), 8)
			net.WriteString(table.concat(t, " "))
			net.WriteString(IsValid(nickEntry) and nickEntry:GetValue() or "")
		net.SendToServer()
	end

	local function QueueApply()
		timer.Create("ZC_PMS_AutoApply", 0.3, 1, function()
			if IsValid(frame) then SendApply() end
		end)
	end

	local btnRow = vgui.Create("DPanel", left)
	btnRow:Dock(BOTTOM)
	btnRow:SetTall(38)
	btnRow:DockMargin(0, 8, 0, 0)
	btnRow.Paint = nil

	local applyBtn = Btn(btnRow, "Apply Now", clr.green, clr.greenhov)
	applyBtn.DoClick = function()
		surface.PlaySound(sndClick)
		SendApply()
	end

	local resetBtn = Btn(btnRow, "Restore Appearance", clr.red, clr.redhov)
	resetBtn.DoClick = function()
		surface.PlaySound(sndClick)
		sel.custom = false
		net.Start("ZC_PMS_Reset")
		net.SendToServer()
		timer.Simple(0.5, function()
			if IsValid(frame) and IsValid(nickEntry) then
				nickEntry:SetText(lply:GetNWString("PlayerName", ""))
			end
		end)
	end

	btnRow.PerformLayout = function(self, w, h)
		local half = (w - 8) / 2
		applyBtn:SetPos(0, 0)
		applyBtn:SetSize(half, h)
		resetBtn:SetPos(half + 8, 0)
		resetBtn:SetSize(half, h)
	end

	local nickPanel = vgui.Create("DPanel", left)
	nickPanel:Dock(BOTTOM)
	nickPanel:SetTall(64)
	nickPanel:DockMargin(0, 8, 0, 0)
	nickPanel.Paint = function(self, w, h)
		surface.SetDrawColor(clr.row)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(clr.rowbar)
		surface.DrawRect(0, h - 3, w, 3)
		draw.SimpleText("Appearance Name", "ZB_PMS_Item", 12, 6, clr.text)
		draw.SimpleText("Temporary - your normal name returns after death", "ZB_PMS_Small", w - 12, 12, clr.dim, TEXT_ALIGN_RIGHT)
	end

	nickEntry = vgui.Create("DTextEntry", nickPanel)
	nickEntry:Dock(BOTTOM)
	nickEntry:DockMargin(10, 0, 10, 8)
	nickEntry:SetTall(26)
	nickEntry:SetText(lply:GetNWString("PlayerName", ""))
	StyleEntry(nickEntry)
	nickEntry.Think = function(self)
		local val = self:GetValue() or ""
		self.BorderColor = (val ~= "" and hg.Appearance and hg.Appearance.IsInvalidName and hg.Appearance.IsInvalidName(val)) and clr.redhov or nil
	end
	nickEntry.OnEnter = QueueApply

	ToggleRow(left, "Render Armor", function()
		return not lply:GetNetVar("HideArmorRender", false)
	end, function()
		net.Start("ZC_PMS_Armor")
		net.WriteBool(not lply:GetNetVar("HideArmorRender", false))
		net.SendToServer()
	end)

	preview = vgui.Create("DModelPanel", left)
	preview:Dock(FILL)
	preview:SetFOV(38)
	preview:SetCamPos(Vector(85, 0, 52))
	preview:SetLookAt(Vector(0, 0, 38))
	preview:SetDirectionalLight(BOX_RIGHT, Color(255, 200, 160))
	preview:SetDirectionalLight(BOX_LEFT, Color(120, 160, 255))
	preview:SetAmbientLight(Vector(-40, -40, -40))
	preview:SetAnimated(true)
	preview.RotY = 35

	preview.PaintOver = function(self, w, h)
		surface.SetDrawColor(clr.border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		draw.SimpleText("Hold LMB to rotate", "ZB_PMS_Small", w / 2, h - 10, clr.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end

	preview.LayoutEntity = function(self, ent)
		if self.Dragging then
			local mx = gui.MouseX()
			self.RotY = self.RotY + (mx - (self.LastX or mx)) * 0.6
			self.LastX = mx
		end
		ent:SetAngles(Angle(0, self.RotY, 0))
		self:RunAnimation()

		if not sel.custom and (self.NextSync or 0) < RealTime() then
			self.NextSync = RealTime() + 0.5
			if lply:GetModel() ~= ent:GetModel() then
				sel.model, sel.skin, sel.groups = lply:GetModel(), lply:GetSkin() or 0, {}
				for k = 0, lply:GetNumBodyGroups() - 1 do sel.groups[k] = lply:GetBodygroup(k) end
				SetPreviewModel(sel.model)
			else
				ApplyToPreview()
			end
		end
	end

	preview.PostDrawModel = function(self, ent)
		if not DrawAccesories or ent:GetModel() ~= lply:GetModel() then return end
		local acc = lply:GetNetVar("Accessories")
		if not istable(acc) then return end

		for _, a in ipairs(acc) do
			local data = hg.Accessories and hg.Accessories[a]
			if data then DrawAccesories(ent, ent, a, data, false, true) end
		end
		ent:SetupBones()
	end

	preview.OnMousePressed = function(self, code)
		if code ~= MOUSE_LEFT then return end
		self.Dragging = true
		self.LastX = gui.MouseX()
		self:MouseCapture(true)
	end

	preview.OnMouseReleased = function(self)
		self.Dragging = false
		self:MouseCapture(false)
	end

	ApplyToPreview = function()
		local ent = preview.Entity
		if not IsValid(ent) then return end

		ent:SetSkin(sel.skin)
		for k, v in pairs(sel.groups) do ent:SetBodygroup(k, v) end

		if ent:GetModel() == lply:GetModel() then
			ent:SetNWVector("PlayerColor", lply:GetNWVector("PlayerColor", Vector(1, 1, 1)))
			for i = 0, #ent:GetMaterials() - 1 do
				ent:SetSubMaterial(i, lply:GetSubMaterial(i))
			end
		else
			ent:SetSubMaterial()
		end

		for _, anim in ipairs(idleAnims) do
			local seq = ent:LookupSequence(anim)
			if seq > 0 then
				if ent:GetSequence() ~= seq then ent:ResetSequence(seq) end
				break
			end
		end
	end

	SetPreviewModel = function(mdl)
		preview:SetModel(mdl)
		ApplyToPreview()
		rebuildCustomize()
	end

	Category(right, "Models")

	local searchBar = vgui.Create("DTextEntry", right)
	searchBar:Dock(TOP)
	searchBar:DockMargin(0, 0, 0, 8)
	searchBar:SetTall(32)
	StyleEntry(searchBar, "Search player models...")

	local customPanel = vgui.Create("DPanel", right)
	customPanel:Dock(BOTTOM)
	customPanel:SetTall(math.max(200, frame:GetTall() * 0.3))
	customPanel:DockMargin(0, 8, 0, 0)
	customPanel.Paint = nil

	Category(customPanel, "Customization")

	local customScroll = vgui.Create("DScrollPanel", customPanel)
	customScroll:Dock(FILL)
	StyleScroll(customScroll)

	local modelScroll = vgui.Create("DScrollPanel", right)
	modelScroll:Dock(FILL)
	StyleScroll(modelScroll)

	local iconLayout = vgui.Create("DIconLayout", modelScroll)
	iconLayout:Dock(TOP)
	iconLayout:SetSpaceX(4)
	iconLayout:SetSpaceY(4)

	local function ArrowRow(label, getMax, getVal, setVal)
		local row = vgui.Create("DPanel", customScroll)
		row:SetTall(40)
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, 6)
		row.Paint = function(self, w, h)
			surface.SetDrawColor(clr.row)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(clr.rowbar)
			surface.DrawRect(0, h - 3, w, 3)
			draw.SimpleText(label, "ZB_PMS_Item", 12, h / 2, clr.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local nextBtn = Btn(row, ">")
		nextBtn:SetWide(30)
		nextBtn:Dock(RIGHT)
		nextBtn:DockMargin(2, 7, 10, 7)
		nextBtn.DoClick = function()
			surface.PlaySound(sndClick)
			setVal((getVal() + 1) % getMax())
		end

		local val = vgui.Create("DPanel", row)
		val:SetWide(64)
		val:Dock(RIGHT)
		val:DockMargin(2, 7, 2, 7)
		val.Paint = function(self, w, h)
			surface.SetDrawColor(clr.dark)
			surface.DrawRect(0, 0, w, h)
			draw.SimpleText((getVal() + 1) .. " / " .. getMax(), "ZB_PMS_Small", w / 2, h / 2, clr.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local prevBtn = Btn(row, "<")
		prevBtn:SetWide(30)
		prevBtn:Dock(RIGHT)
		prevBtn:DockMargin(2, 7, 2, 7)
		prevBtn.DoClick = function()
			surface.PlaySound(sndClick)
			setVal((getVal() - 1 + getMax()) % getMax())
		end
	end

	rebuildCustomize = function()
		customScroll:Clear()
		local ent = preview.Entity
		if not IsValid(ent) then return end

		local hasAny = false

		if ent:SkinCount() > 1 then
			hasAny = true
			ArrowRow("Skin", function() return ent:SkinCount() end, function() return sel.skin end, function(v)
				sel.skin, sel.custom = v, true
				ApplyToPreview()
				QueueApply()
			end)
		end

		for _, bg in ipairs(ent:GetBodyGroups() or {}) do
			local id, count = bg.id, ent:GetBodygroupCount(bg.id)
			if count < 2 then continue end

			hasAny = true
			ArrowRow(bg.name or ("Bodygroup " .. id), function() return count end, function() return sel.groups[id] or 0 end, function(v)
				sel.groups[id] = v
				ApplyToPreview()
				QueueApply()
			end)
		end

		if not hasAny then
			local lbl = vgui.Create("DLabel", customScroll)
			lbl:Dock(TOP)
			lbl:DockMargin(4, 6, 4, 0)
			lbl:SetFont("ZB_PMS_Item")
			lbl:SetTextColor(clr.dim)
			lbl:SetText("This model has no skins or bodygroups.")
			lbl:SizeToContents()
		end
	end

	local allModels = player_manager.AllValidModels()

	local function BuildGrid(filter)
		iconLayout:Clear()
		filter = (filter or ""):lower()

		for name, mdl in SortedPairs(allModels) do
			if filter ~= "" and not name:lower():find(filter, 1, true) and not mdl:lower():find(filter, 1, true) then continue end

			local icon = iconLayout:Add("SpawnIcon")
			icon:SetSize(64, 64)
			icon:SetModel(mdl)
			icon:SetTooltip(name)

			icon.PaintOver = function(self, w, h)
				if sel.model == mdl then
					surface.SetDrawColor(clr.orange)
					surface.DrawOutlinedRect(0, 0, w, h, 2)
				end
			end

			icon.DoClick = function()
				surface.PlaySound(sndClick)
				sel.model, sel.skin, sel.groups, sel.custom = mdl, 0, {}, true
				SetPreviewModel(mdl)
				QueueApply()
			end
		end

		iconLayout:Layout()
	end

	searchBar.OnValueChange = function(self)
		BuildGrid(self:GetValue())
	end

	BuildGrid("")
	SetPreviewModel(sel.model)

	frame.OnClose = function()
		timer.Remove("ZC_PMS_AutoApply")
	end
end

net.Receive("ZC_PMS_Open", function() Menu() end)
concommand.Add("playermodel_selector", function() Menu() end)
concommand.Add("zc_playermodel_selector", function() Menu() end)

local function ReplacePlayerEditor()
	list.Set("DesktopWindows", "PlayerEditor", {
		title = "Player Model",
		icon = "icon64/playermodel.png",
		width = 960,
		height = 700,
		onewindow = true,
		init = function(icon, window)
			window:Remove()
			Menu()
		end
	})
end

ReplacePlayerEditor()
hook.Add("InitPostEntity", "ZC_PMS_ReplacePlayerEditor", ReplacePlayerEditor)
