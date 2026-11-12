CRIMXP = CRIMXP or {}

local statsFrame
local adminRows = {}
local adminChunks = {}

local COL_PANEL = Color(20, 20, 20, 235)
local COL_ROW = Color(43, 43, 43, 235)
local COL_ROW_HOV = Color(56, 56, 56, 240)
local COL_ACCENT = Color(160, 45, 45, 255)
local COL_ACCENT_H = Color(190, 60, 60, 255)
local COL_GREEN = Color(80, 125, 65, 255)
local COL_GREEN_H = Color(100, 150, 85, 255)
local COL_TEXT = Color(235, 235, 235, 235)
local COL_DIM = Color(140, 140, 140, 220)

local function StyleButton(btn, base, hover)
	base = base or COL_ROW
	hover = hover or COL_ROW_HOV

	btn:SetFont("ZB_QM_Btn")
	btn:SetTextColor(COL_TEXT)
	btn.Paint = function(self, w, h)
		surface.SetDrawColor(self:IsHovered() and hover or base)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(0, 0, 0, 55)
		surface.DrawRect(0, h - 3, w, 3)
	end
end

local function StylePanel(panel)
	panel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, COL_PANEL)
	end
end

net.Receive("HG_CrimXPAdminSend", function()
	local total = net.ReadUInt(16)
	local chunks = net.ReadUInt(16)
	local index = net.ReadUInt(16)
	local part = util.JSONToTable(net.ReadString()) or {}

	adminChunks[index] = part

	for i = 1, chunks do
		if not adminChunks[i] then return end
	end

	adminRows = {}
	for i = 1, chunks do
		for _, row in ipairs(adminChunks[i]) do
			adminRows[#adminRows + 1] = row
		end
	end
	adminChunks = {}

	if IsValid(statsFrame) and statsFrame.RefreshRows then
		statsFrame:RefreshRows()
		if statsFrame.RefreshSelection then statsFrame:RefreshSelection() end
	end
end)

net.Receive("HG_CrimXPAdminSaveResult", function()
	local ok = net.ReadBool()
	local message = net.ReadString()

	chat.AddText(ok and Color(80, 200, 80) or Color(255, 80, 80), "[XP] " .. (message or ""))
end)

function CRIMXP.OpenAdminStats()
	if IsValid(statsFrame) then return end
	if not IsValid(LocalPlayer()) or not LocalPlayer():IsAdmin() then return end

	local frame = vgui.Create("ZFrame")
	statsFrame = frame
	frame:SetSize(920, 580)
	frame:Center()
	frame:SetTitle("Criminal Records - Admin")
	frame:MakePopup()

	frame.OnClose = function()
		statsFrame = nil
	end

	local topPanel = vgui.Create("DPanel", frame)
	topPanel:Dock(TOP)
	topPanel:SetTall(36)
	topPanel:DockMargin(8, 8, 8, 6)
	StylePanel(topPanel)

	local search = vgui.Create("DTextEntry", topPanel)
	search:Dock(FILL)
	search:SetPlaceholderText("Search name or SteamID64")

	local refreshBtn = vgui.Create("DButton", topPanel)
	refreshBtn:Dock(RIGHT)
	refreshBtn:SetWide(110)
	refreshBtn:SetText("Refresh")
	StyleButton(refreshBtn, COL_ROW, COL_ROW_HOV)

	local leftPanel = vgui.Create("DPanel", frame)
	leftPanel:Dock(LEFT)
	leftPanel:SetWide(430)
	leftPanel:DockMargin(8, 0, 4, 8)
	StylePanel(leftPanel)

	local list = vgui.Create("DListView", leftPanel)
	list:Dock(FILL)
	list:SetMultiSelect(false)
	list:AddColumn("Player"):SetWidth(150)
	list:AddColumn("Level"):SetWidth(50)
	list:AddColumn("XP"):SetWidth(75)
	list:AddColumn("Fracture$"):SetWidth(80)
	list:AddColumn("Status"):SetWidth(62)

	local rightPanel = vgui.Create("DScrollPanel", frame)
	rightPanel:Dock(FILL)
	rightPanel:DockMargin(4, 0, 8, 8)

	local selectedRow
	local selectedSteamID
	local entries = {}

	local function AddEntry(parent, label, key, value)
		local row = vgui.Create("DPanel", parent)
		row:Dock(TOP)
		row:SetTall(30)
		row:DockMargin(0, 0, 0, 4)

		local title = vgui.Create("DLabel", row)
		title:Dock(LEFT)
		title:SetWide(130)
		title:SetText(label)
		title:SetTextColor(COL_TEXT)
		title:SetFont("ZB_QM_Item")

		local entry = vgui.Create("DTextEntry", row)
		entry:Dock(FILL)
		entry:SetText(tostring(value or 0))
		entry:SetFont("ZB_QM_Item")

		entries[key] = entry
	end

	local function ShowPlayer(row)
		selectedRow = row
		selectedSteamID = row and row.steamid or nil
		entries = {}
		rightPanel:Clear()

		if not row then return end

		local level = CRIMXP.LevelForXP(tonumber(row.xp) or 0)

		local title = vgui.Create("DLabel", rightPanel)
		title:Dock(TOP)
		title:SetTall(34)
		title:SetFont("ZB_QM_Category")
		title:SetText(row.name .. "  |  " .. row.steamid .. (row.active and "  |  ACTIVE" or "  |  OFFLINE"))
		title:SetTextColor(COL_TEXT)

		local hint = vgui.Create("DLabel", rightPanel)
		hint:Dock(TOP)
		hint:SetTall(28)
		hint:SetFont("ZB_QM_Small")
		hint:SetText("Changing the Level field sets total XP to that level's threshold. Changing XP only keeps the current level.")
		hint:SetTextColor(COL_DIM)

		AddEntry(rightPanel, "Level", "level", level)
		AddEntry(rightPanel, "Total XP", "xp", row.xp)
		AddEntry(rightPanel, "Fracture$", "fracture", row.fracture)
		AddEntry(rightPanel, "Kills", "kills", row.kills)
		AddEntry(rightPanel, "Deaths", "deaths", row.deaths)
		AddEntry(rightPanel, "Best Streak", "beststreak", row.beststreak)

		local saveBtn = vgui.Create("DButton", rightPanel)
		saveBtn:Dock(TOP)
		saveBtn:SetTall(38)
		saveBtn:DockMargin(0, 10, 0, 0)
		saveBtn:SetText("Save Criminal Record")
		StyleButton(saveBtn, COL_GREEN, COL_GREEN_H)

		saveBtn.DoClick = function()
			if not selectedRow then return end

			local data = {name = selectedRow.name}
			for key, entry in pairs(entries) do
				data[key] = entry:GetText()
			end

			net.Start("HG_CrimXPAdminSave")
				net.WriteString(selectedRow.steamid)
				net.WriteTable(data)
			net.SendToServer()
		end
	end

	function frame:RefreshRows()
		local needle = search:GetText():lower()
		list:Clear()

		for _, row in ipairs(adminRows) do
			local name = tostring(row.name or "Unknown")
			local steamid = tostring(row.steamid or "")

			if needle == "" or name:lower():find(needle, 1, true) or steamid:find(needle, 1, true) then
				local level = CRIMXP.LevelForXP(tonumber(row.xp) or 0)
				local line = list:AddLine(name, tostring(level), tostring(row.xp or 0), tostring(row.fracture or 0), row.active and "Online" or "Offline")
				line.RowData = row
			end
		end
	end

	function frame:RefreshSelection()
		if not selectedSteamID then return end

		for i = 1, list:GetRowCount() do
			local line = list:GetLine(i)

			if line and line.RowData and line.RowData.steamid == selectedSteamID then
				list:SelectItem(line)
				ShowPlayer(line.RowData)
				return
			end
		end
	end

	list.OnRowSelected = function(_, _, line)
		ShowPlayer(IsValid(line) and line.RowData or nil)
	end

	search.OnValueChange = function()
		frame:RefreshRows()
	end

	refreshBtn.DoClick = function()
		adminChunks = {}
		net.Start("HG_CrimXPAdminRequest")
		net.SendToServer()
	end

	net.Start("HG_CrimXPAdminRequest")
	net.SendToServer()
end
