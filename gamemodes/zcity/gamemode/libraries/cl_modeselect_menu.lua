if CLIENT then
    local isMenuOpen = nil
    zb.availableModes = zb.availableModes or {}

    zb.RoundList = zb.RoundList or {}
    zb.nextround = zb.nextround or nil
    zb.forcemode = zb.forcemode or "random"
    local queueManagerInstance = nil

    --;; The worst part of the job is taking the shit you wrote and making it readable
    local COL_BG        = Color(28, 28, 28, 240)
    local COL_BORDER    = Color(75, 75, 75, 255)
    local COL_CAT       = Color(60, 60, 60, 255)
    local COL_CATBAR    = Color(42, 42, 42, 255)
    local COL_ROW       = Color(43, 43, 43, 235)
    local COL_ROW_HOV   = Color(56, 56, 56, 240)
    local COL_ROWBAR    = Color(47, 47, 47, 235)
    local COL_ACCENT    = Color(160, 45, 45, 255)
    local COL_ACCENT_H  = Color(190, 60, 60, 255)
    local COL_GREEN     = Color(80, 125, 65, 255)
    local COL_GREEN_H   = Color(100, 150, 85, 255)
    local COL_ORANGE    = Color(220, 150, 45, 255)
    local COL_TEXT      = Color(235, 235, 235, 235)
    local COL_TEXT_DIM  = Color(140, 140, 140, 220)
    local COL_TOGGLE_BG = Color(28, 28, 28, 255)

    local menufont = "Bahnschrift"

    surface.CreateFont("ZB_QM_Title",    {font = menufont, size = 26, weight = 500, antialias = true})
    surface.CreateFont("ZB_QM_Category", {font = menufont, size = 21, weight = 400, antialias = true})
    surface.CreateFont("ZB_QM_Item",     {font = menufont, size = 19, weight = 400, antialias = true})
    surface.CreateFont("ZB_QM_Small",    {font = menufont, size = 14, weight = 300, antialias = true})
    surface.CreateFont("ZB_QM_Btn",      {font = menufont, size = 16, weight = 500, antialias = true})

    local SND_CLICK   = "shitty/tap_depress.wav"
    local SND_RELEASE = "shitty/tap_release.wav"
    local SND_HOVER   = "shitty/tap-resonant.wav"



    net.Receive("ZB_SendModesInfo", function()
        zb.availableModes = net.ReadTable()
        if IsValid(queueManagerInstance) then queueManagerInstance:RebuildModes() end
    end)

    net.Receive("ZB_SendRoundList", function()
        zb.RoundList = net.ReadTable()
        zb.nextround = net.ReadString()
        zb.forcemode = net.ReadString()
        table.insert(zb.RoundList, 1, zb.nextround)
        zb.nextround = nil
        if IsValid(queueManagerInstance) then queueManagerInstance:QueueUpdate() end
    end)

    net.Receive("ZB_NotifyRoundListChange", function()
        local playerName = net.ReadString()
        chat.AddText(Color(180, 180, 255), playerName, COL_TEXT, " has modified the game mode queue")
        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end)

    local function GetModeName(key)
        for _, mode in ipairs(zb.availableModes) do
            if mode.key == key then return mode.name end
        end
        return key
    end
    local function ForceActive()
        return zb.forcemode and zb.forcemode ~= "random" and zb.forcemode ~= ""
    end

    local function DrawFrameBG(self, w, h)
            if hg and hg.DrawBlur then hg.DrawBlur(self, 4) end
            surface.SetDrawColor(COL_BG)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(120, 120, 130, 12)
            local sp = 64
            local ox = (CurTime() * 18) % sp
            for x = 0, math.ceil(w / sp) do
                surface.DrawRect(x * sp - ox, 0, 1, h)
            end
            local oy = (CurTime() * 18) % sp
            for y = 0, math.ceil(h / sp) do
                surface.DrawRect(0, y * sp - oy + sp, w, 1)
            end
            surface.SetDrawColor(COL_BORDER)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local function ZcityBUTT(btn, base, hover, txtColor)
        base     = base     or COL_ROW
        hover    = hover    or COL_ROW_HOV
        txtColor = txtColor or COL_TEXT
        btn:SetFont("ZB_QM_Btn")
        btn:SetTextColor(txtColor)
        btn.OnCursorEntered = function() surface.PlaySound(SND_HOVER) end
        btn.Paint = function(self, w, h)
            local c = self:IsHovered() and hover or base
            draw.RoundedBox(0, 0, 0, w, h, c)
            surface.SetDrawColor(0, 0, 0, 55)
            surface.DrawRect(0, h - 3, w, 3)
        end
    end

    local function CreateToggle(parent, getState, onClick)
        local toggle = vgui.Create("DButton", parent)
        toggle:SetText("")
        toggle:SetSize(52, 24)
        local animProgress = getState() and 1 or 0
        toggle.Paint = function(self, w, h)
                local target = getState() and 1 or 0
                animProgress = Lerp(FrameTime() * 10, animProgress, target)
                local bgColor = Color(
                    Lerp(animProgress, 180, 80),
                    Lerp(animProgress, 30, 120),
                    Lerp(animProgress, 30, 50)
                )
            draw.RoundedBox(0, 0, 0, w, h, COL_TOGGLE_BG)
            draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(0, 0, 0, 30))
            local slsize = h - 12
            local slPos = Lerp(animProgress, 6, w - slsize - 6)
            draw.RoundedBox(0, slPos, 6, slsize, slsize, bgColor)
            surface.SetDrawColor(0, 0, 0, Lerp(animProgress, 150, 40))
            surface.DrawRect(slPos, slsize + 4, slsize, 3)
        end
        toggle.OnCursorEntered = function() surface.PlaySound(SND_HOVER) end
        toggle.DoClick = function()
            surface.PlaySound(SND_CLICK)
            onClick()
        end
        return toggle
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
            surface.SetDrawColor(self:IsHovered() and Color(120, 120, 120) or Color(90, 90, 90))
            surface.DrawRect(1, 0, w - 2, h)
        end
    end

    local function CreateCategoryBar(parent, text)
        local bar = vgui.Create("DPanel", parent)
        bar:Dock(TOP)
        bar:SetTall(38)
        bar:DockMargin(0, 0, 0, 8)
        bar.Paint = function(self, w, h)
            surface.SetDrawColor(COL_CAT)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(COL_CATBAR)
            surface.DrawRect(0, h - 5, w, 5)
            draw.SimpleText(text, "ZB_QM_Category", w / 2, h / 2 - 2, COL_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        return bar
    end

    local function AddCloseButton(parent, frame)
        local btn = vgui.Create("DButton", parent)
        btn:SetSize(38, 38)
        btn:Dock(RIGHT)
        btn:DockMargin(0, 1, 6, 1)
        btn:SetText("")
        btn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(255, 110, 110) or COL_TEXT
            local m = 12
            surface.SetDrawColor(col)
            for i = -1, 1 do
                surface.DrawLine(m, m + i, w - m, h - m + i)
                surface.DrawLine(w - m, m + i, m, h - m + i)
            end
        end
        btn.OnCursorEntered = function() surface.PlaySound(SND_HOVER) end
        btn.DoClick = function()
            surface.PlaySound(SND_RELEASE)
            frame:Close()
        end
        return btn
    end

    local function MakeContent(frame)
        local content = vgui.Create("DPanel", frame)
        content.Paint = nil
        frame.PerformLayout = function(_, w, h)
            content:SetPos(2, 2)
            content:SetSize(w - 4, h - 4)
        end
        return content
    end

    local function CreateAvailableRow(parent, mode, manager)
        local row = vgui.Create("DPanel", parent)
        row:SetTall(54)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 8)
        local statusText, statusCol
            if mode.canlaunch == 1 then
                statusText, statusCol = "Ready to launch", COL_GREEN_H
            elseif mode.canlaunch == 0 then
                statusText, statusCol = "Cannot launch (no points / blocked)", COL_ACCENT_H
            else
                statusText, statusCol = mode.key, COL_TEXT_DIM
            end
        row.Paint = function(self, w, h)
            local forced = (zb.forcemode == mode.key)
            surface.SetDrawColor(self:IsHovered() and COL_ROW_HOV or COL_ROW)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(forced and COL_ORANGE or COL_ROWBAR)
            surface.DrawRect(0, h - 3, w, 3)
            draw.RoundedBox(0, 16, h / 2 - 4, 8, 8, statusCol)
            draw.SimpleText(mode.name, "ZB_QM_Item", 34, h / 2 - 8, COL_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            --draw.SimpleText(forced and "proverka" or statusText, "ZB_QM_Small", 34, h / 2 + 11, forced and COL_ORANGE or COL_TEXT_DIM, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local toggle = CreateToggle(row,
            function() return zb.forcemode == mode.key end,
            function()
                local target = (zb.forcemode == mode.key) and "random" or mode.key
                net.Start("AdminSetGameMode")
                    net.WriteString("setforcemode")
                    net.WriteString(target)
                    net.WriteBool(false)
                net.SendToServer()
                zb.forcemode = target
            end)
        toggle:Dock(RIGHT)
        toggle:DockMargin(10, 15, 16, 15)
        toggle:SetTooltip("Force this mode every round")
        local addBtn = vgui.Create("DButton", row)
        addBtn:SetWide(90)
        addBtn:Dock(RIGHT)
        addBtn:DockMargin(8, 12, 0, 12)
        addBtn:SetText("+ Queue")
        ZcityBUTT(addBtn, COL_GREEN, COL_GREEN_H)
        addBtn.DoClick = function()
            table.insert(zb.RoundList, mode.key)
            surface.PlaySound(SND_CLICK)
            manager:QueueUpdate()
        end
        return row
    end
    local ROW_H, ROW_GAP = 44, 8
    local STRIDE = ROW_H + ROW_GAP
    local function OpenQueueManager()
        if IsValid(queueManagerInstance) then queueManagerInstance:Close() end
        local frame = vgui.Create("ZFrame")
        frame:SetSize(math.Clamp(ScrW() * 0.62, 900, 1280), math.Clamp(ScrH() * 0.72, 560, 780))
        frame:Center()
        frame:SetTitle("")
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame:SetBorder(false)
        frame:MakePopup()
        frame.Paint = DrawFrameBG
        queueManagerInstance = frame
        local content = MakeContent(frame)
        local header = vgui.Create("DPanel", content)
        header:Dock(TOP)
        header:SetTall(42)
        header:DockMargin(0, 0, 0, 10)
        header.Paint = function(self, w, h)
            surface.SetDrawColor(COL_CAT)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(COL_CATBAR)
            surface.DrawRect(0, h - 5, w, 5)
            draw.SimpleText("Game Mode Queue", "ZB_QM_Title", w / 2, h / 2 - 2, COL_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        AddCloseButton(header, frame)
        local body = vgui.Create("DPanel", content)
        body:Dock(FILL)
        body.Paint = nil
        local leftPanel = vgui.Create("DPanel", body)
        leftPanel:Dock(LEFT)
        leftPanel:SetWide(frame:GetWide() * 0.55)
        leftPanel:DockMargin(0, 0, 6, 0)
        leftPanel.Paint = nil
        CreateCategoryBar(leftPanel, "Available Game Modes")
        local searchBar = vgui.Create("DTextEntry", leftPanel)
        searchBar:Dock(TOP)
        searchBar:DockMargin(0, 0, 0, 8)
        searchBar:SetTall(32)
        searchBar:SetFont("ZB_QM_Item")
        searchBar.Paint = function(self, w, h)
            surface.SetDrawColor(COL_TOGGLE_BG)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(70, 70, 70, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            self:DrawTextEntryText(COL_TEXT, Color(120, 120, 120), COL_TEXT)
            if self:GetText() == "" then
                draw.SimpleText("Search game modes...", "ZB_QM_Item", 8, h / 2, COL_TEXT_DIM, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
        local dscroll = vgui.Create("DScrollPanel", leftPanel)
        dscroll:Dock(FILL)
        StyleScroll(dscroll)
        local queuePanel = vgui.Create("DPanel", body)
        queuePanel:Dock(FILL)
        queuePanel:DockMargin(6, 0, 0, 0)
        queuePanel.Paint = nil
        CreateCategoryBar(queuePanel, "Round Queue")
        local btnBar = vgui.Create("DPanel", queuePanel)
        btnBar:Dock(BOTTOM)
        btnBar:SetTall(38)
        btnBar:DockMargin(0, 8, 0, 0)
        btnBar.Paint = nil
        local applyBtn = vgui.Create("DButton", btnBar)
        applyBtn:SetText("Apply Queue")
        ZcityBUTT(applyBtn, COL_GREEN, COL_GREEN_H)
        applyBtn.DoClick = function()
            net.Start("ZB_UpdateRoundList")
                net.WriteTable(table.Copy(zb.RoundList))
                net.WriteBool(true)
            net.SendToServer()
            chat.AddText(COL_GREEN_H, "Game mode queue has been set!")
            surface.PlaySound(SND_CLICK)
        end
        local clearBtn = vgui.Create("DButton", btnBar)
        clearBtn:SetText("Clear Queue")
        ZcityBUTT(clearBtn, COL_ACCENT, COL_ACCENT_H)
        clearBtn.DoClick = function()
            zb.RoundList = {}
            frame:QueueUpdate()
            surface.PlaySound(SND_CLICK)
            chat.AddText(COL_ORANGE, "Queue cleared (press Apply to save)")
        end
        btnBar.PerformLayout = function(self, w, h)
            local half = (w - 8) / 2
            applyBtn:SetPos(0, 0)
            applyBtn:SetSize(half, h)
            clearBtn:SetPos(half + 8, 0)
            clearBtn:SetSize(half, h)
        end
        local queueList = vgui.Create("DPanel", queuePanel)
        queueList:Dock(FILL)
        queueList.rows = {}
        queueList.scroll = 0
        queueList.scrollTarget = 0
        queueList.dragging = nil
        queueList.dragIndex = nil
        queueList.grabDY = 0
        queueList.Paint = function(self, w, h)
            if #self.rows == 0 then
                draw.SimpleText("Queue is empty, modes are picked randomly.", "ZB_QM_Item", 6, 12, COL_TEXT_DIM, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end
        queueList.PaintOver = function(self, w, h)
            local contentH = #self.rows * STRIDE
            if contentH > h + 2 then
                local barH = math.max(24, h * (h / contentH))
                local maxScroll = contentH - h
                local barY = maxScroll > 0 and (self.scroll / maxScroll) * (h - barH) or 0
                surface.SetDrawColor(0, 0, 0, 60)
                surface.DrawRect(w - 5, 0, 4, h)
                surface.SetDrawColor(110, 110, 110, 255)
                surface.DrawRect(w - 5, barY, 4, barH)
            end
        end
        queueList.OnMouseWheeled = function(self, delta)
            self.scrollTarget = self.scrollTarget - delta * STRIDE * 0.9
            return true
        end
        queueList.Think = function(self)
            local h = self:GetTall()
            local w = self:GetWide()
            local contentH = #self.rows * STRIDE
            local maxScroll = math.max(0, contentH - h)
            if self.dragging and IsValid(self.dragging) then
                local _, my = self:LocalCursorPos()
                local desiredY = math.Clamp(my - self.grabDY, -ROW_H * 0.5, h - ROW_H * 0.5)
                self.dragging.animY = desiredY
                self.dragging:SetPos(0, desiredY)
                self.dragging:MoveToFront()
                local minIndex = ForceActive() and 2 or 1
                local newIndex = math.Clamp(math.Round((desiredY + self.scroll) / STRIDE) + 1, minIndex, #self.rows)
                if newIndex ~= self.dragIndex then
                    local rowObj = table.remove(self.rows, self.dragIndex)
                    table.insert(self.rows, newIndex, rowObj)
                    local key = table.remove(zb.RoundList, self.dragIndex)
                    table.insert(zb.RoundList, newIndex, key)
                    self.dragIndex = newIndex
                    surface.PlaySound(SND_HOVER)
                end
                if my < 26 then self.scrollTarget = self.scrollTarget - 8 end
                if my > h - 26 then self.scrollTarget = self.scrollTarget + 8 end
            end
            self.scrollTarget = math.Clamp(self.scrollTarget, 0, maxScroll)
            self.scroll = Lerp(FrameTime() * 12, self.scroll, self.scrollTarget)
            if math.abs(self.scroll - self.scrollTarget) < 0.4 then self.scroll = self.scrollTarget end
            for i, row in ipairs(self.rows) do
                if not IsValid(row) then continue end
                row.queueIndex = i
                if row:GetWide() ~= w then row:SetSize(w, ROW_H) end

                local wantCursor = row:IsLocked() and "arrow" or "sizeall"
                if row.curCursor ~= wantCursor then
                    row:SetCursor(wantCursor)
                    row.curCursor = wantCursor
                end
                if row ~= self.dragging then
                    local targetY = (i - 1) * STRIDE - self.scroll
                    row.animY = Lerp(FrameTime() * 16, row.animY or targetY, targetY)
                    if math.abs(row.animY - targetY) < 0.4 then row.animY = targetY end
                    row:SetPos(0, row.animY)
                end
            end
        end

        local function MakeQueueRow(modeKey)
            local row = vgui.Create("DPanel", queueList)
            row:SetTall(ROW_H)
            row:SetCursor("sizeall")
            row.animY = 0
            row.Paint = function(self, w, h)
                local idx = self.queueIndex or 1
                local isNext = (idx == 1)
                local forced = isNext and ForceActive()
                local dragging = (queueList.dragging == self)
                local bg
                if dragging then bg = Color(72, 72, 72, 250)
                elseif forced then bg = Color(62, 52, 34, 235)
                elseif isNext then bg = Color(50, 62, 46, 235)
                else bg = self:IsHovered() and COL_ROW_HOV or COL_ROW end
                surface.SetDrawColor(bg)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(forced and COL_ORANGE or (isNext and COL_GREEN_H or COL_ROWBAR))
                surface.DrawRect(0, h - 3, w, 3)
                if forced then
                    surface.SetDrawColor(COL_ORANGE)
                    surface.DrawRect(13, h / 2 - 2, 12, 9)
                    surface.DrawOutlinedRect(15, h / 2 - 8, 8, 8, 2)
                else
                    surface.SetDrawColor(dragging and 190 or 110, dragging and 190 or 110, dragging and 190 or 110)
                    for gy = 0, 2 do
                        for gx = 0, 1 do
                            surface.DrawRect(14 + gx * 5, h / 2 - 7 + gy * 6, 3, 3)
                        end
                    end
                end
                local label = isNext and (forced and "FORCE" or "NEXT") or ("#" .. idx)
                local lcol = forced and COL_ORANGE or (isNext and COL_GREEN_H or COL_TEXT_DIM)
                draw.SimpleText(label, "ZB_QM_Small", 34, h / 2, lcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(GetModeName(modeKey), "ZB_QM_Item", 92, h / 2, COL_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                if dragging then
                    surface.SetDrawColor(COL_GREEN_H)
                    surface.DrawOutlinedRect(0, 0, w, h, 2)
                end
            end
            row.IsLocked = function(self)
                return ForceActive() and (self.queueIndex or 1) == 1
            end
            row.OnMousePressed = function(self, code)
                if code ~= MOUSE_LEFT then return end
                if self:IsLocked() then
                    surface.PlaySound(SND_RELEASE)
                    return
                end
                queueList.dragging = self
                queueList.dragIndex = self.queueIndex
                local _, my = queueList:LocalCursorPos()
                queueList.grabDY = my - self.animY
                self:MouseCapture(true)
                surface.PlaySound(SND_CLICK)
            end
            row.OnMouseReleased = function(self, code)
                if queueList.dragging == self then
                    queueList.dragging = nil
                    queueList.dragIndex = nil
                    self:MouseCapture(false)
                    surface.PlaySound(SND_RELEASE)
                end
            end
            local removeBtn = vgui.Create("DButton", row)
            removeBtn:SetWide(30)
            removeBtn:Dock(RIGHT)
            removeBtn:DockMargin(4, 9, 12, 9)
            removeBtn:SetText("✕") --;; fuck images
            removeBtn:SetCursor("hand")
            ZcityBUTT(removeBtn, COL_ACCENT, COL_ACCENT_H)
            removeBtn.Think = function(self)
                self:SetVisible(not row:IsLocked())
            end
            removeBtn.DoClick = function()
                if row:IsLocked() then return end
                table.remove(zb.RoundList, row.queueIndex or 1)
                frame:QueueUpdate()
            end
            return row
        end

        local allowedModes = {
            ["tdm"] = true, ["cstrike"] = true, ["hmcd"] = true,
            ["hl2dm"] = true, ["riot"] = true, ["gwars"] = true,
            ["criresp"] = true,
        }

        function frame:RebuildModes()
            dscroll:Clear()
            local filter = (IsValid(searchBar) and searchBar:GetValue() or ""):lower()
            for i, mode in SortedPairsByMemberValue(zb.availableModes, "canlaunch", true) do
                if not LocalPlayer():IsSuperAdmin() and not allowedModes[mode.key] then continue end
                if filter ~= "" and not string.find(mode.name:lower(), filter, 1, true) then continue end
                CreateAvailableRow(dscroll, mode, self)
            end
        end

        function frame:QueueUpdate()
            for _, r in ipairs(queueList.rows) do
                if IsValid(r) then r:Remove() end
            end
            queueList.rows = {}
            queueList.dragging = nil
            queueList.dragIndex = nil
            local w = queueList:GetWide()
            for idx, modeKey in ipairs(zb.RoundList) do
                local row = MakeQueueRow(modeKey)
                row.queueIndex = idx
                row.animY = (idx - 1) * STRIDE - queueList.scroll
                row:SetSize(w, ROW_H)
                row:SetPos(0, row.animY)
                queueList.rows[idx] = row
            end
            local maxScroll = math.max(0, #zb.RoundList * STRIDE - queueList:GetTall())
            queueList.scrollTarget = math.Clamp(queueList.scrollTarget, 0, maxScroll)
        end

        searchBar.OnChange = function()
            frame:RebuildModes()
        end

        frame:RebuildModes()
        frame:QueueUpdate()

        frame.OnClose = function()
            queueManagerInstance = nil
        end

        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end

    local function OpenAdminMenu()
        if IsValid(isMenuOpen) then return end
        local frame = vgui.Create("ZFrame")
        isMenuOpen = frame
        frame:SetSize(400, 264)
        frame:Center()
        frame:SetTitle("")
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame:SetBorder(false)
        frame:MakePopup()
        frame.Paint = DrawFrameBG
        local content = MakeContent(frame)
        local header = vgui.Create("DPanel", content)
        header:Dock(TOP)
        header:SetTall(42)
        header:DockMargin(0, 0, 0, 12)
        header.Paint = function(self, w, h)
            surface.SetDrawColor(COL_CAT)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(COL_CATBAR)
            surface.DrawRect(0, h - 5, w, 5)
            draw.SimpleText("Admin Panel", "ZB_QM_Title", w / 2, h / 2 - 2, COL_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        AddCloseButton(header, frame)
        local function BigButton(text, base, hover)
            local btn = vgui.Create("DButton", content)
            btn:Dock(TOP)
            btn:DockMargin(14, 0, 14, 12)
            btn:SetTall(52)
            btn:SetText(text)
            btn:SetFont("ZB_QM_Category")
            btn:SetTextColor(COL_TEXT)
            btn.OnCursorEntered = function() surface.PlaySound(SND_HOVER) end
            btn.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsHovered() and hover or base)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(0, 0, 0, 55)
                surface.DrawRect(0, h - 3, w, 3)
            end
            return btn
        end

        local manageBtn = BigButton("Manage Game Mode Queue", COL_ROW, COL_ROW_HOV)
        manageBtn.DoClick = function()
            surface.PlaySound(SND_CLICK)
            OpenQueueManager()
        end

        local statsBtn = BigButton("Player Criminal Records", COL_ROW, COL_ROW_HOV)
        statsBtn.DoClick = function()
            surface.PlaySound(SND_CLICK)
            if CRIMXP and CRIMXP.OpenAdminStats then
                CRIMXP.OpenAdminStats()
            else
                chat.AddText(Color(255, 80, 80), "Criminal records menu is not available.")
            end
        end

        local endBtn = BigButton("End Round", COL_ACCENT, COL_ACCENT_H)
        endBtn.DoClick = function()
            surface.PlaySound(SND_CLICK)
            net.Start("AdminEndRound")
            net.SendToServer()
            frame:Close()
        end
        frame.OnClose = function()
            isMenuOpen = false
        end
    end

    hook.Add("InitPostEntity", "RequestModeData", function()
        if LocalPlayer():IsAdmin() then
            timer.Simple(2, function()
                net.Start("ZB_RequestRoundList")
                net.SendToServer()
            end)
        end
    end)

    local f6Key = KEY_F6

    hook.Add("PlayerButtonDown", "OpenAdminMenuF6", function(ply, key)
        if key == f6Key and LocalPlayer():IsAdmin() and not IsValid(isMenuOpen) then
            OpenAdminMenu()
        end
    end)
end
