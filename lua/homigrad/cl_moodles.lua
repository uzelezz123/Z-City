-- cl_moodles.lua
-- Client-side moodle rendering template
if not CLIENT then return end

CreateConVar("hg_showothermoodle", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Show moodles of other players above their head", 0, 1)
CreateConVar("hg_sidemoodles", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Show moodles on the side of the screen", 0, 1)

local DEBUG_COLOR_CL_ADD = Color(0, 255, 0)
local DEBUG_COLOR_CL_REMOVE = Color(255, 0, 0)
local color_black = Color(0, 0, 0, 255)

CreateClientConVar("moodle_debug_draw", 0, true, false, "Toggle client-side moodle debug HUD (1=on, 0=off)")
local function IsDebugDrawEnabled() return GetConVar("moodle_debug_draw"):GetInt() == 1 end

local CLIENT_MOODLES = {}
local last_removed_moodle = {}
local prev_view_angles = Angle(0,0,0)
local sway_offset_x = 0
local sway_offset_y = 0

local CRITICAL_MOODLES = {
    ["bleeding_4"] = true,
    ["brain_damage_4"] = true,
    ["cardiac_arrest"] = true,
    ["cold_4"] = true,

    ["heat_4"] = true,
    ["depression_4"] = true,
    ["endurance_4"] = true,
    ["faint_4"] = true,
    ["fractured_neck"] = true,
    ["hemothorax"] = true,
    ["hunger_5"] = true,
    ["internal_bleed"] = true,
    ["overdose_4"] = true,
    ["oxygen_3"] = true,
    ["pain_4"] = true,
    ["respfailure"] = true,
    ["rippedeye_4"] = true,
    ["hypovolemia_4"] = true,
    ["unconscious"] = true,
    ["sepsis"] = true,
    ["horrified"] = true,
    ["deceased"] = true,
}

local VITAL_MOODLES = {
    ["bradycardia"] = true,
    ["oxygen_1"] = true,
    ["oxygen_2"] = true,
    ["oxygen_3"] = true,
    ["hypoxemia_1"] = true,
    ["hypoxemia_2"] = true,
    ["hypoxemia_3"] = true,
    ["cardiac_arrest"] = true, -- Added for otrub visibility
}

-- =======================================================
-- TOOLTIP DATA
-- =======================================================
local MOODLE_INFO = {
    ["amputation"] = { title = "Amputation", desc = "One of your limbs is missing!" },
    ["bleeding_1"] = { title = "Minor Bleeding", desc = "Blood is leaking out of you, but it should be alright." },
    ["bleeding_2"] = { title = "Moderate Bleeding", desc = "Losing more blood than usual, this one probably wont clot." },
    ["bleeding_3"] = { title = "Severe Bleeding", desc = "Blood is leaking out of you, patch it up!" },
    ["bleeding_4"] = { title = "Catastrophic Bleeding", desc = "Why are you looking at this? Go find a bandage!" },
    ["bradycardia"] = { title = "Bradycardia", desc = "Your heart rate is low, something might be wrong..." },
    ["brain_damage_1"] = { title = "Minor Brain Damage", desc = "Huh?." },
    ["brain_damage_2"] = { title = "Moderate Brain Damage", desc = "I smell something very weird..." },
    ["brain_damage_3"] = { title = "Severe Brain Damage", desc = "Aug.h.. Whuat.?" },
    ["brain_damage_4"] = { title = "Critical Brain Damage", desc = "..." },
    ["cardiac_arrest"] = { title = "Cardiac Arrest", desc = "You will soon go to sleep for a very long time." },
    ["cold_1"] = { title = "Chilly", desc = "Its a little cold for comfort." },
    ["cold_2"] = { title = "Cold", desc = "Is it that cold outside?" },
    ["cold_3"] = { title = "Very Cold", desc = "Its really, REALLY cold." },
    ["cold_4"] = { title = "Hypothermia", desc = "Its... So... Cold..." },

    ["concussion"] = { title = "Incapacitated", desc = "You need help to get up." },
    ["deaf_1"] = { title = "Tinnitus", desc = "Your sensitive ears are ringing." },
    ["deaf_2"] = { title = "Partial Deafness", desc = "You barely can hear." },
    ["deaf_3"] = { title = "Deaf", desc = "You cannot hear anything." },
    ["deceased"] = { title = "Critical", desc = "This is the end of you. Goodbye." },
    ["depression_1"] = { title = "Shaken", desc = "You dont want to keep experiencing this." },
    ["depression_2"] = { title = "Traumatized", desc = "Your body saw something it didnt want to see." },
    ["depression_3"] = { title = "Depressed", desc = "Life isnt fair." },
    ["depression_4"] = { title = "Desensitized", desc = "Life stopped making sense." },


    ["fractured_neck"] = { title = "Broken Spine", desc = "You are paralyzed." },
    ["dislocated_spine"] = { title = "Dislocated Spine", desc = "A part of your spine is out of place. You should fix it before it gets worse." },
    ["partial_spine_break"] = { title = "Partially Broken Spine", desc = "Your spine is fractured. Movement is severely impaired and painful." },
    ["dislocated_jaw"] = { title = "Dislocated Jaw", desc = "Your jaw is out of place, put it back in!" },
    ["dislocated_jaw_and_fractured_skull"] = { title = "Jaw and Skull Trauma", desc = "Your jaw is dislocated and your skull is fractured." },
    ["fractured_skull"] = { title = "Fractured Skull", desc = "WHERES YO HEAD AT??????????" },
    ["dislocation"] = { title = "Dislocation", desc = "Its not really that bad, but its recommened to place it back." },
    ["encumbered_1"] = { title = "Encumbered", desc = "You are carrying a bit too much." },
    ["encumbered_2"] = { title = "Heavily Encumbered", desc = "Your movement is noticeably slower." },
    ["encumbered_3"] = { title = "Over-Encumbered", desc = "You can barely move with all this weight." },
    ["encumbered_4"] = { title = "Immobilized", desc = "You are carrying too much to move." },
    ["endurance_1"] = { title = "Tired", desc = "Lets take a break..." },
    ["endurance_2"] = { title = "Exhausted", desc = "Lets REALLY take a break..." },
    ["endurance_3"] = { title = "Severely Exhausted", desc = "I can barely go on..." },
    ["endurance_4"] = { title = "Out of Breath", desc = "Too much... TOO MUCH..." },
    ["energized"] = { title = "Energized", desc = "Feeling great! You are full of energy." },
    ["faint_1"] = { title = "Dizzy", desc = "Feeling a litle sleepy..." },
    ["faint_2"] = { title = "Disoriented", desc = "My eyes are starting to close..." },
    ["faint_3"] = { title = "Faint", desc = "Its hard to stay balanced..." },
    ["faint_4"] = { title = "Syncope", desc = "I think im about to fall asleep right about now..." },
    ["fight_or_flight"] = { title = "Fight or Flight", desc = "Alert, Pain is numbed for now..." },
    ["fracture"] = { title = "Fracture", desc = "One of your limbs is broken, you should get it fixed..." },
    ["fractured_neck"] = { title = "Fractured Neck", desc = "I cant move..." },
    ["fractured_ribs"] = { title = "Fractured Ribs", desc = "Better hope none of them are poking at your lungs..." },
    ["happy_1"] = { title = "Happy", desc = "Satisfied with what you have right now." },
    ["happy_2"] = { title = "Joyful", desc = "Life feels nice." },
    ["happy_3"] = { title = "Ecstatic", desc = "Im loving life right now!" },
    ["happy_4"] = { title = "Euphoric", desc = "Nothing can stop me!" },
    ["heat_1"] = { title = "Warm", desc = "Bit too warm for comfort" },
    ["heat_2"] = { title = "Hot", desc = "Is it summer season already?" },
    ["heat_3"] = { title = "Very Hot", desc = "Its WAY too hot..." },
    ["heat_4"] = { title = "Hyperthermia", desc = "I CANT TAKE THIS HEAT ANYMORE!" },
    ["hemothorax"] = { title = "Pneumothorax", desc = "Its like breathing does nothing..." },
    ["hypovolemia_1"] = { title = "Anemic", desc = "You've lost some blood. You feel a bit weak." },
    ["hypovolemia_2"] = { title = "Pale", desc = "Significant blood loss. You feel weak and dizzy." },
    ["hypovolemia_3"] = { title = "Hypovolemic", desc = "You are on the verge of collapsing from blood loss." },
    ["hypovolemia_4"] = { title = "Exsanguinated", desc = "Your body is shutting down from a lack of blood." },
    ["hunger_1"] = { title = "Peckish", desc = "I could go for a bite." },
    ["hunger_2"] = { title = "Hungry", desc = "I could eat a horse right now." },
    ["hunger_3"] = { title = "Very Hungry", desc = "Now im hungry..." },
    ["hunger_4"] = { title = "Starving", desc = "Im REALLY hungry..." },
    ["hunger_5"] = { title = "Dying of Starvation", desc = "Food..." },
    ["internal_bleed"] = { title = "Internal Bleeding", desc = "Your guts are bleeding!" },
    ["overdose_1"] = { title = "Opiated", desc = "This feels good..." },
    ["overdose_2"] = { title = "Numb", desc = "This feels REALLY good..." },
    ["overdose_3"] = { title = "Drugged", desc = "I see sounds and hear colors..." },
    ["overdose_4"] = { title = "Overdosing", desc = "Okay, i think i took too much..." },
    ["oxygen_1"] = { title = "Hypoxemic", desc = "My skin is all weird and rubbery..." },
    ["oxygen_2"] = { title = "Hypoxemic", desc = "Air.. I need air..." },
    ["oxygen_3"] = { title = "Critical Hypoxemia", desc = "..." },
    ["pain_1"] = { title = "Minor Pain", desc = "Just some discomfort." },
    ["pain_2"] = { title = "Moderate Pain", desc = "Something might be wrong..." },
    ["pain_3"] = { title = "Severe Pain", desc = "Something is wrong..." },
    ["pain_4"] = { title = "Excruciating Pain", desc = "AAAAAAAAAAAAAAAAAAAAAAAAAAAA" },
    ["respfailure"] = { title = "Respiratory Failure", desc = "I cant breathe..." },
    ["rippedeye_3"] = { title = "Missing Eye", desc = "I cant see out of my eye." },
    ["rippedeye_4"] = { title = "Blind", desc = "Who turned the lights off?" },
    ["rippedjaw"] = { title = "Fractured Jaw", desc = "Wheres yo head at?", desc2 = "Your skull is also fractured." },
    ["shock"] = { title = "Shock", desc = "Hurts so much i cant move..." },
    ["speechless"] = { title = "Affected Speech", desc = "I dont know about people understanding your gibberish." },
    ["stimulated"] = { title = "Stimulated", desc = "NOW nothing cant stop me!" },
    ["tachycardia"] = { title = "Tachycardia", desc = "Something is probably wrong, or not." },
    ["thoraxdestroyed"] = { title = "Severe Chest Injury", desc = "Your vital organs in your chest are severely damaged." },
    ["trauma_1"] = { title = "Anxious", desc = "You are feeling a bit on edge." },
    ["trauma_2"] = { title = "Scared", desc = "You dont want to continue experiencing this." },
    ["trauma_3"] = { title = "Terrified", desc = "You are REALLY scared." },
    ["trauma_4"] = { title = "Really fucking scared", desc = "You cant even comprehend your emotions." },
    ["unconscious"] = { title = "Unconscious", desc = "Unresponsive to stimuli, lights out!" },
    ["sepsis"] = { title = "Sepsis", desc = "Not so fun now is it?" },
    ["horrified"] = { title = "Critically Injured", desc = "This is the end of you. Goodbye!" },
}

local color_white = Color(255, 255, 255)

-- Word wrap function
local function wrapText(text, font, maxWidth)
    surface.SetFont(font)
    local lines = {}
    if not text or text == "" then return lines end

    local words = string.Explode(" ", text)
    local current_line = ""

    for i, word in ipairs(words) do
        local test_line = current_line .. (current_line == "" and "" or " ") .. word
        local w, _ = surface.GetTextSize(test_line)

        if w > maxWidth then
            if current_line ~= "" then
                table.insert(lines, current_line)
            end
            current_line = word
        else
            current_line = test_line
        end
    end
    table.insert(lines, current_line)
    return lines
end
net.Receive("Moodle_Add", function()
    local id = net.ReadString()
    local tex = net.ReadString()
    local cnt = net.ReadInt(8)

    local ply = LocalPlayer()
    if IsValid(ply) and ply:GetNWBool("otrub", false) and not VITAL_MOODLES[id] and not CRITICAL_MOODLES[id] then 
        if CLIENT_MOODLES[id] then
            CLIENT_MOODLES[id].updating = false
        end
        return 
    end
    
    local existing = CLIENT_MOODLES[id]
    if not existing then
        CLIENT_MOODLES[id] = { texture = tex, count = cnt, mat = Material(tex), spawn = CurTime() }
    else
        CLIENT_MOODLES[id].texture = tex
        CLIENT_MOODLES[id].count = cnt
        CLIENT_MOODLES[id].mat = CLIENT_MOODLES[id].mat or Material(tex)
    end
    CLIENT_MOODLES[id].updating = true
    CLIENT_MOODLES[id].remove_time = nil

    if last_removed_moodle.id and (CurTime() - last_removed_moodle.time) < 0.1 then
        local old_base, old_level = last_removed_moodle.id:match("(.+)_([%d+])")
        local new_base, new_level = id:match("(.+)_([%d+])")

        if old_base and new_base and old_base == new_base and tonumber(new_level) > tonumber(old_level) then
            CLIENT_MOODLES[id].worsen_time = CurTime()
            util.ScreenShake(Vector(0,0,0), 5, 0.5, 0.5, 0.5)
        end
    end
    
    if IsDebugDrawEnabled() then MsgC(DEBUG_COLOR_CL_ADD, "[M] + "..id.."\n") end
end)

hook.Add("PostDrawTranslucentRenderables", "DrawOtherMoodles", function()
    if not GetConVar("hg_showothermoodle"):GetBool() then return end

    local lply = LocalPlayer()
    local iconSize = 48
    local pad = 4

    for _, ply in ipairs(player.GetAll()) do
        if ply ~= lply and ply:Alive() and IsValid(ply) then
            local moodles = ply:GetNWTable("MoodleStates")
            if not moodles then continue end
            
            local pos = ply:GetPos() + Vector(0, 0, 80)
            local ang = (lply:GetPos() - pos):Angle()

            cam.Start3D2D(pos, Angle(0, ang.y - 90, 90), 0.25)
                local x = 0
                local y = 0
                for id, data in pairs(moodles) do
                    if data.mat and not data.mat:IsError() then
                        surface.SetDrawColor(255, 255, 255, 200)
                        surface.SetMaterial(data.mat)
                        surface.DrawTexturedRect(x, y, iconSize, iconSize)
                    end
                    if GetConVar("hg_sidemoodles"):GetBool() then
                        y = y + iconSize + pad
                    else
                        x = x + iconSize + pad
                    end
                end
            cam.End3D2D()
        end
    end
end)

net.Receive("Moodle_Remove", function()
    local id = net.ReadString()
    if id == "*" then
        if IsDebugDrawEnabled() then MsgC(DEBUG_COLOR_CL_REMOVE, "[MM] - Clearing all moodles\n") end
        for k, v in pairs(CLIENT_MOODLES) do
            v.remove_time = CurTime()
        end
        return 
    end
    
    last_removed_moodle = {id = id, time = CurTime()}
    if CLIENT_MOODLES[id] then
        CLIENT_MOODLES[id].remove_time = CurTime()
    end

    if IsDebugDrawEnabled() then MsgC(DEBUG_COLOR_CL_REMOVE, "[MM] - "..id.."\n") end
end)

hook.Add("HUDPaint", "Moodle_Draw", function()
    local mx, my = gui.MouseX(), gui.MouseY()
    local ply = LocalPlayer()
    if not IsValid(ply) then 
        CLIENT_MOODLES = {} 
        return 
    end

    -- Sway effect
    local current_view_angles = ply:EyeAngles()
    local angle_diff_y = current_view_angles.y - prev_view_angles.y
    local angle_diff_p = current_view_angles.p - prev_view_angles.p
    prev_view_angles = current_view_angles
    sway_offset_x = Lerp(FrameTime() * 5, sway_offset_x, -angle_diff_y * 2)
    sway_offset_y = Lerp(FrameTime() * 5, sway_offset_y, angle_diff_p * 2)

    if table.IsEmpty(CLIENT_MOODLES) then return end
    
    -- Layout settings
    local iconSize, pad = 48, 10
    local screenW = ScrW() > 0 and ScrW() or 1920
    local screenH = ScrH()
    local baseX, baseY

    if GetConVar("hg_sidemoodles"):GetBool() then
        baseX = screenW - 64
        baseY = 16
    else
        baseX = 16
        baseY = 16
    end
    
    local hovered = nil

    -- Animation helpers
    local function easeOutBack(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2
    end

    local function easeOutQuint(t) return 1 - (1 - t)^5 end

    local is_otrub = ply:GetNWBool("otrub", false)

    -- Create a sorted list of moodles to ensure consistent layout
    local sorted_moodles = {}
    for id, data in pairs(CLIENT_MOODLES) do
        table.insert(sorted_moodles, {id = id, data = data, spawn = data.spawn or 0})
    end
    table.sort(sorted_moodles, function(a, b) return a.spawn < b.spawn end)

    local layout_x = baseX
    local layout_y = baseY

    -- First, calculate target positions for all visible moodles
    for _, moodle in ipairs(sorted_moodles) do
        local data = moodle.data

        if not data.remove_time then
            local targetX, targetY
            if GetConVar("hg_sidemoodles"):GetBool() then
                if layout_y + iconSize + pad > screenH then
                    layout_y = baseY
                    layout_x = layout_x - (iconSize + pad)
                end
                targetX = layout_x
                targetY = layout_y
                layout_y = layout_y + iconSize + pad
            else
                if layout_x + iconSize + pad > screenW then
                    layout_x = baseX
                    layout_y = layout_y + iconSize + pad
                end
                targetX = layout_x
                targetY = layout_y
                layout_x = layout_x + iconSize + pad
            end
            data.target_x = targetX
            data.target_y = targetY
        end
    end

    -- Draw Icons
    for _, moodle in ipairs(sorted_moodles) do
        local id = moodle.id
        local data = moodle.data

        --[[if is_otrub and not VITAL_MOODLES[id] and not CRITICAL_MOODLES[id] then
            if not data.remove_time then data.remove_time = CurTime() end
        end]]

        local dt = CurTime() - (data.spawn or (CurTime() - 10))

        -- Animations
        local scale = 1
        local alpha = 255
        if data.remove_time then
            local remove_dt = CurTime() - data.remove_time
            local animT = math.Clamp(remove_dt / 0.4, 0, 1)
            scale = Lerp(easeOutQuint(animT), 1, 0.8)
            alpha = Lerp(easeOutQuint(animT), 255, 0)

            if remove_dt > 0.4 then
                CLIENT_MOODLES[id] = nil
                if IsDebugDrawEnabled() and id ~= "*" then MsgC(DEBUG_COLOR_CL_REMOVE, "[M] - "..id.."\n") end
                continue
            end
        else
            local animT = math.Clamp(dt / 0.5, 0, 1)
            scale = Lerp(easeOutBack(animT), 0.8, 1)
            alpha = Lerp(animT, 0, 255)
        end

        local drawW, drawH = iconSize * scale, iconSize * scale

        -- Initialize position if new
        if not data.x then data.x = data.target_x or baseX end
        if not data.y then data.y = data.target_y or baseY end
        
        -- Smoothly move to target position
        data.x = Lerp(FrameTime() * 15, data.x, data.target_x or data.x)
        data.y = Lerp(FrameTime() * 15, data.y, data.target_y or data.y)

        local drawX = data.x + sway_offset_x
        local drawY = data.y + sway_offset_y

        -- Shake animation for worsening moodles
        if data.worsen_time and (CurTime() - data.worsen_time) < 0.5 then
            local shake_intensity = 5
            local shake_t = (CurTime() - data.worsen_time) / 0.5
            local shake_amount = shake_intensity * (1 - shake_t) * math.sin(shake_t * 20)
            drawX = drawX + shake_amount
        end
        
        -- Draw texture or fallback box
        if data.mat and not data.mat:IsError() then
            if is_otrub then
                surface.SetDrawColor(128, 128, 128, alpha)
            else
                surface.SetDrawColor(255, 255, 255, alpha)
            end
            surface.SetMaterial(data.mat)
            surface.DrawTexturedRect(drawX, drawY, drawW, drawH)
        else
            surface.SetDrawColor(255, 0, 255, alpha)
            surface.DrawRect(drawX, drawY, drawW, drawH)
        end

        -- Draw stack count if > 1
        if data.count and data.count > 1 and data.updating then
            draw.SimpleText(tostring(data.count), "ZCity_Moodle", drawX + drawW - 4, drawY + drawH - 4, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        -- New moodle notification
        if dt < 3 then
            local info = MOODLE_INFO[id]
            if info then
                local fade_alpha = math.Clamp(1 - (dt / 3), 0, 1) * alpha
                local text_x, text_y
                local alignment, y_alignment
                if GetConVar("hg_sidemoodles"):GetBool() then
                    text_x = drawX - 10
                    text_y = drawY + drawH / 2
                    alignment = TEXT_ALIGN_RIGHT
                    y_alignment = TEXT_ALIGN_CENTER
                else
                    text_x = drawX + drawW / 2
                    text_y = drawY + drawH + 5
                    alignment = TEXT_ALIGN_CENTER
                    y_alignment = TEXT_ALIGN_TOP
                end
                draw.SimpleText(info.title, "ZCity_Moodle", text_x, text_y, Color(255, 255, 255, fade_alpha), alignment, y_alignment)
            end
        end

        -- Hover detection (uses unscaled area for easier targeting)
        if mx >= drawX and mx <= drawX + drawW and my >= drawY and my <= drawY + drawH then
            hovered = id
        end
    end

    -- Draw Tooltip
    if hovered and MOODLE_INFO[hovered] then
        local info = MOODLE_INFO[hovered]
        local titleFont = "ZCity_Moodle"
        local descFont = "ZCity_Moodle"
        local maxWidth = 200 -- Reduced from 340 to encourage wrapping
        
        -- Wrap description text
        local descLines = wrapText(info.desc, descFont, maxWidth)
        if info.desc2 then
            local desc2Lines = wrapText(info.desc2, descFont, maxWidth)
            for _, l in ipairs(desc2Lines) do
                table.insert(descLines, l)
            end
        end

        -- Calculate heights
        surface.SetFont(titleFont)
        local _, titleHeight = surface.GetTextSize(info.title)
        surface.SetFont(descFont)
        local _, descHeight = surface.GetTextSize("Tg") -- Get height of a line

        local titlePadding = 15 -- More space between title and description
        local linePadding = 5   -- Space between description lines

        -- Calculate total tooltip height
        local tw = 360
        local th = 12 + titleHeight + titlePadding + (#descLines * descHeight) + math.max(0, #descLines - 1) * linePadding + 12

        local tx = mx + 20
        local ty = my + 20

        if tx + tw > ScrW() then tx = mx - tw - 20 end
        if ty + th > ScrH() then ty = my - th - 20 end
        
        -- Draw background and border
        draw.RoundedBox(6, tx - 6, ty - 6, tw, th, Color(0, 0, 0, 200))
        surface.SetDrawColor(255, 0, 0, 200)
        surface.DrawOutlinedRect(tx - 6, ty - 6, tw, th)

        -- Draw Title
        draw.SimpleText(info.title, titleFont, tx, ty, color_white)

        -- Draw Description
        local currentY = ty + titleHeight + titlePadding
        for _, line in ipairs(descLines) do
            draw.SimpleText(line, descFont, tx, currentY, Color(200, 200, 200))
            currentY = currentY + descHeight + linePadding
        end
    end
end)