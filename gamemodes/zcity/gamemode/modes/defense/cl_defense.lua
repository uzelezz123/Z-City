MODE.name = "defense"

local MODE = MODE


local highlightNPCs = {}


net.Receive("npc_defense_start",function()
    surface.PlaySound("csgo_round.wav")
end)

local teams = {
	[1] = {
		objective = "Defend your base from the attack of the combines.",
		name = "a Refugee",
		color1 = Color(240,109,1),
		color2 = Color(190,95,0)
	},
}

function MODE:RenderScreenspaceEffects()
    if zb.ROUND_START + 7.5 < CurTime() then return end
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)

    surface.SetDrawColor(0, 0, 0, 255 * fade)
    surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

local NextWave_Time = 0

net.Receive("npc_defense_newwave", function()
	local time = net.ReadFloat()
	NextWave_Time = time
end)

local timePos = 0

function MODE:HUDPaint()
	if NextWave_Time > CurTime() - 5 then
		timePos = Lerp( FrameTime()*5, timePos, 1-math.min((NextWave_Time - CurTime())/1,1) )
		local time = string.FormattedTime(NextWave_Time - CurTime())
		time.s = (time.s < 10 and "0" or "")..time.s
		time.m = (time.m < 10 and "0" or "")..time.m
		draw.SimpleText( "Next wave in ".. time.m ..":" .. time.s, "ZB_HomicideMedium", sw * 0.5, sh * (0.9 + timePos), Color(87,146,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

    if zb.ROUND_START + 8.5 < CurTime() then return end
	 
	if not lply:Alive() then return end
    local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
	local team_ = lply:Team()
    draw.SimpleText("ZBattle | HL2 Base Defense", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
    local playerRole = lply:GetNWString("PlayerRole", "Refugee") 
    local roleColor = teams[team_].color1
    roleColor.a = 255 * fade
    draw.SimpleText("You are a " .. playerRole, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local objective = teams[team_].objective
    local objectiveColor = teams[team_].color2
    objectiveColor.a = 255 * fade
    draw.SimpleText(objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, objectiveColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end


net.Receive("defense_highlight_last_npcs", function()
    local npcs = net.ReadTable()
    highlightNPCs = {}
    
    for _, entIndex in ipairs(npcs) do
        local ent = Entity(entIndex)
        if IsValid(ent) then
            highlightNPCs[entIndex] = ent
        end
    end
end)



hook.Add("SetupOutlines", "HighlightLastNPCs", function(outline_Add)

    for entIndex, npc in pairs(highlightNPCs) do
        if not IsValid(npc) then
            highlightNPCs[entIndex] = nil
            continue
        end
        
        outline_Add(npc, Color(255, 50, 50), OUTLINE_MODE_BOTH)
    end
end)



local currentMusic

local function StopCurrentMusic()
    if currentMusic then
        currentMusic:Stop()
        currentMusic = nil
    end
end

local CreateEndMenu

net.Receive("npc_defense_roundend",function()
    CreateEndMenu()
    StopCurrentMusic()
end)

local colGray = Color(85,85,85,255)
local colRed = Color(130,10,10)
local colRedUp = Color(160,30,30)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur


if IsValid(hmcdEndMenu) then
    hmcdEndMenu:Remove()
    hmcdEndMenu = nil
end

CreateEndMenu = function()
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

    surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5 ,ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2,ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX,posY)
	hmcdEndMenu:SetSize(sizeX,sizeY)
	--hmcdEndMenu:SetBackgroundColor(colGray)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton",hmcdEndMenu)
	closebutton:SetPos(5,5)
	closebutton:SetSize(ScrW() / 20,ScrH() / 30)
	closebutton:SetText("")
	
	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor( 122, 122, 122, 255)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		surface.SetFont( "ZB_InterfaceMedium" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos( lengthX - lengthX/1.1, 4)
		surface.DrawText("Close")
	end

    hmcdEndMenu.PaintOver = function(self,w,h)

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Players:")
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText("Players:")
	end

	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i,ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
            local col1 = (ply:Alive() and colRed) or colGray
            local col2 = (ply:Alive() and colRedUp) or colSpect1
			surface.SetDrawColor(col1.r,col1.g,col1.b,col1.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(col2.r,col2.g,col2.b,col2.a)
			surface.DrawRect(0,h/2,w,h/2)

            local col = ply:GetPlayerColor():ToColor()
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			
			surface.SetTextColor(0,0,0,255)
			surface.SetTextPos(w / 2 + 1,h/2 - lengthY/2 + 1)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

			surface.SetTextColor(col.r,col.g,col.b,col.a)
			surface.SetTextPos(w / 2,h/2 - lengthY/2)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

            
			local col = colSpect2
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			surface.SetTextPos(15,h/2 - lengthY/2)
			surface.DrawText((ply:Name() .. (not ply:Alive() and " - died" or "")) or "He quited...")

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:Frags() or "He quited..." )
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(ply:Frags() or "He quited...")
		end

		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end


function createSupportMenu()
    local frame = vgui.Create("ZFrame")
    frame:SetSize(400, 200)
    frame:Center()
    frame:SetTitle("What do you want to order?")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    local function createButton(text, command)
        local button = vgui.Create("DButton", frame)
        button:SetText(text)
        button:SetSize(100, 30)
        button.DoClick = function()
            net.Start("RequestSupport")
            net.WriteString(command)
            net.SendToServer()
            frame:Close()
        end
        return button
    end

    local armorButton = createButton("Armor", "Armor")
    armorButton:SetPos(50, 50)

    local medsButton = createButton("Medications", "Medications")
    medsButton:SetPos(150, 50)

    local ammoButton = createButton("Ammunition", "Ammunition")
    ammoButton:SetPos(250, 50)
end


hook.Add("radialOptions", "CommanderSupportOptions", function()
    local ply = LocalPlayer()
    local organism = ply.organism or {}

    if ply:GetNWString("PlayerRole") == "Commander" and not organism.otrub then
        local tbl = {createSupportMenu, "Request support"}
        hg.radialOptions[#hg.radialOptions + 1] = tbl
    end
end)

local currentMusic
local fadeDuration = 2  
local fadeInterval = 0.1  

local musicConvar = CreateConVar("cl_wavemusic", "1", FCVAR_ARCHIVE, "Toggle music during enemy waves.")

local function FadeOutMusic(music, duration, interval)
    if not IsValid(music) then return end
    
    local volume = music:GetVolume()
    local steps = duration / interval
    local stepDecrease = volume / steps

    timer.Create("MusicFadeOut", interval, steps, function()
        if not IsValid(music) then 
            timer.Remove("MusicFadeOut")
            return 
        end
        
        volume = volume - stepDecrease
        if volume <= 0 then
            music:Stop()
            timer.Remove("MusicFadeOut")
        else
            music:SetVolume(volume)
        end
    end)
end

local function StopCurrentMusic(fade)
    if currentMusic then
        if fade then
            FadeOutMusic(currentMusic, fadeDuration, fadeInterval)
        else
            currentMusic:Stop()
        end
        currentMusic = nil
    end
end

local function PlayMusic(musicFile)
    sound.PlayFile("sound/" .. musicFile, "", function(station)
        if IsValid(station) then
            currentMusic = station

            local musicVolume = GetConVar("snd_musicvolume"):GetFloat()
            currentMusic:SetVolume(musicVolume * 0.5)

            station:Play()
            station:EnableLooping(true)
        end
    end)
end

net.Receive("StartWaveMusic", function()
    local musicFile = net.ReadString()

    game.RemoveRagdolls()

    StopCurrentMusic(true) 

    if musicConvar:GetBool() then
        PlayMusic(musicFile)
    end
end)

net.Receive("StopWaveMusic", function()
    StopCurrentMusic(true)  
end)

cvars.AddChangeCallback("cl_wavemusic", function(convar_name, old_value, new_value)
    if tonumber(new_value) == 0 then
        StopCurrentMusic(true)  
    elseif tonumber(new_value) == 1 then
        
    end
end)

cvars.AddChangeCallback("snd_musicvolume", function(convar_name, old_value, new_value)
    if IsValid(currentMusic) then
        local newVolume = tonumber(new_value) * 0.5  
        currentMusic:SetVolume(newVolume)
    end
end)

local voteEndTime = 0
local selectedMode = nil
local voteMenu = nil
local currentSubMode = nil
local showSelectedMode = false
local selectedModeDisplayTime = 0
local selectedModeDisplayDuration = 5
local voteResults = {}
local totalVotes = 0

local function CreateVoteFonts()
    surface.CreateFont("Defense_Title", {
        font = "Roboto",
        size = 32,
        weight = 700,
        antialias = true,
        shadow = true
    })
    
    surface.CreateFont("Defense_Subtitle", {
        font = "Roboto",
        size = 22,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("Defense_Button", {
        font = "Roboto",
        size = 24,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("Defense_Description", {
        font = "Roboto",
        size = 18,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("Defense_SmallText", {
        font = "Roboto",
        size = 16,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("Defense_Stats", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("Defense_Timer", {
        font = "Roboto",
        size = 26,
        weight = 700,
        antialias = true,
        shadow = true
    })
end


CreateVoteFonts()

local function DrawBackgroundBlur()
    local x, y = 0, 0
    local scrW, scrH = ScrW(), ScrH()
    
    surface.SetDrawColor(0, 0, 0, 150)
    surface.SetMaterial(Material("pp/blurscreen"))
    
    for i = 1, 5 do
        Material("pp/blurscreen"):SetFloat("$blur", (i / 3) * 4)
        Material("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end

    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(0, 0, scrW, scrH)
end

local function CreateVoteMenu()
    if IsValid(voteMenu) then 
        voteMenu:Remove() 
    end

    local blurPanel = vgui.Create("DPanel")
    blurPanel:SetSize(ScrW(), ScrH())
    blurPanel:SetPos(0, 0)
    blurPanel:SetZPos(-100)
    blurPanel.Paint = function(self, w, h)
        DrawBackgroundBlur()
    end

    voteMenu = vgui.Create("ZFrame")
    voteMenu:SetSize(950, 850) 
    voteMenu:Center()
    voteMenu:SetTitle("")
    voteMenu:SetDraggable(false)
    voteMenu:ShowCloseButton(false)
    voteMenu:MakePopup()
    

    voteMenu.OnRemove = function()
        if IsValid(blurPanel) then
            blurPanel:Remove()
        end
    end

    local gradientDown = Material("gui/gradient_down")
    local gradientUp = Material("gui/gradient_up")
    
    voteMenu.Paint = function(self, w, h)

        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 220))
        


        surface.SetDrawColor(40, 40, 40, 230)
        surface.DrawRect(0, 0, w, 80)
        
        surface.SetDrawColor(50, 50, 50, 100)
        surface.SetMaterial(gradientDown)
        surface.DrawTexturedRect(0, 0, w, 80)

        surface.SetDrawColor(70, 70, 70, 150)
        surface.DrawLine(50, 80, w - 50, 80)
        

        surface.SetDrawColor(40, 40, 40, 230)
        surface.DrawRect(0, h - 150, w, 150) 
        
        surface.SetDrawColor(60, 60, 60, 100)
        surface.SetMaterial(gradientUp)
        surface.DrawTexturedRect(0, h - 150, w, 150)
        

        surface.SetDrawColor(70, 70, 70, 150)
        surface.DrawLine(50, h - 150, w - 50, h - 150)
        

        draw.SimpleText("SELECT GAME MODE", "Defense_Title", w / 2, 28, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Vote for the current round mode", "Defense_Subtitle", w / 2, 55, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    

    local timerPanel = vgui.Create("DPanel", voteMenu)
    timerPanel:SetSize(180, 50)
    timerPanel:SetPos(voteMenu:GetWide() / 2 - 90, 735) 
    timerPanel.Paint = function(self, w, h)
        local timeLeft = math.ceil(voteEndTime - CurTime())
        local timeColor = Color(255, 255, 255)

        if timeLeft <= 10 then
            timeColor = Color(255, 50, 50)
        elseif timeLeft <= 20 then
            timeColor = Color(255, 200, 50)
        end
        
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 180))
        draw.SimpleText("TIME LEFT:", "Defense_Stats", w / 2, 12, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(timeLeft .. " SEC", "Defense_Timer", w / 2, 32, timeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    

    local voteStatsPanel = vgui.Create("DPanel", voteMenu)
    voteStatsPanel:SetSize(870, 70) 
    voteStatsPanel:SetPos(voteMenu:GetWide() / 2 - 435, 795) 
    voteStatsPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 180))
        
        local standardPercent = totalVotes > 0 and math.floor((voteResults[1] or 0) / totalVotes * 100) or 0
        local extendedPercent = totalVotes > 0 and math.floor((voteResults[2] or 0) / totalVotes * 100) or 0
        local zombiePercent = totalVotes > 0 and math.floor((voteResults[3] or 0) / totalVotes * 100) or 0
        

        draw.SimpleText("Vote Statistics:", "Defense_Stats", 20, 20, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Total votes: " .. totalVotes, "Defense_Stats", w - 20, 20, Color(200, 200, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        

        draw.RoundedBox(5, 170, 15, 140, 40, Color(50, 100, 200, 150))
        draw.SimpleText("Standard: " .. standardPercent .. "%", "Defense_Stats", 240, 33, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("(" .. (voteResults[1] or 0) .. " votes)", "Defense_SmallText", 240, 48, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        

        draw.RoundedBox(5, 370, 15, 140, 40, Color(200, 100, 50, 150))
        draw.SimpleText("Extended: " .. extendedPercent .. "%", "Defense_Stats", 440, 33, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("(" .. (voteResults[2] or 0) .. " votes)", "Defense_SmallText", 440, 48, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        

        draw.RoundedBox(5, 570, 15, 140, 40, Color(50, 200, 50, 150))
        draw.SimpleText("Zombie: " .. zombiePercent .. "%", "Defense_Stats", 640, 33, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("(" .. (voteResults[3] or 0) .. " votes)", "Defense_SmallText", 640, 48, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    

    voteMenu.Think = function()
        if CurTime() >= voteEndTime then
            if IsValid(voteMenu) then voteMenu:Remove() end
            return
        end
    end
    
    local modeDescriptions = {
        [1] = {
            title = "Standard Mode",
            shortDesc = "Classic 6 waves of combine attacks",
            longDesc = "Old Classic.",
            color = Color(50, 100, 200),
            features = {
                "• 6 waves of combine soldiers with increasing difficulty",
                "• Regular enemy types: Metropolice and Combine Soldiers",
                "• Final wave includes elite Combine Soldiers",
                "• Recommended for new players and standard gameplay"
            }
        },
        [2] = {
            title = "Extended Mode",
            shortDesc = "12 waves with bosses and special enemies",
            longDesc = "Challenge for veteran players! 12 waves of relentless bloodshed and brutality.",
            color = Color(200, 100, 50),
            features = {
                "• 12 waves of intensive combat",
                "• Special boss waves",
                "• Much harder than Standard mode - for experienced players",
                "• Includes turrets, manhacks and other special enemy types"
            }
        },
        [3] = {
            title = "Zombie Mode",
            shortDesc = "6 waves of zombie apocalypse",
            longDesc = "A unique mode replacing combines with various zombie types. ",
            color = Color(50, 200, 50),
            features = {
                "• 6 waves of zombie hordes",
                "• Unique challenge compared to Combine enemies",
                "• More enemies compared to Standard mode"
            }
        }
    }
    

    local function CreateModeButton(index, yPos)
        local button = vgui.Create("DButton", voteMenu)
        button:SetSize(750, 80)
        button:SetPos(voteMenu:GetWide() / 2 - 375, yPos)
        button:SetText("")
        button.Color = modeDescriptions[index].color
        button.HoverFrac = 0
        button.SelectedFrac = 0
        
  
        local isDisabled = (index == 3) 
        
        button.Paint = function(self, w, h)
            local baseColor = modeDescriptions[index].color
            local darkColor = Color(baseColor.r * 0.6, baseColor.g * 0.6, baseColor.b * 0.6)
            local brightColor = Color(baseColor.r * 1.2, baseColor.g * 1.2, baseColor.b * 1.2)
            


            if not isDisabled then
                self.HoverFrac = Lerp(FrameTime() * 10, self.HoverFrac, self:IsHovered() and 1 or 0)
                self.SelectedFrac = Lerp(FrameTime() * 8, self.SelectedFrac, selectedMode == index and 1 or 0)
            else
                self.HoverFrac = 0
                self.SelectedFrac = 0
            end
            

            if isDisabled then
                draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20, 220))
            else
                draw.RoundedBox(6, 0, 0, w, h, Color(30, 30, 30, 200))
            end
            
            local borderColor
            if isDisabled then
                borderColor = Color(70, 70, 70, 100) 
            else
                borderColor = ColorAlpha(baseColor, 100 + 100 * math.max(self.HoverFrac, self.SelectedFrac))
            end
            
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            

            local gradientColor
            if isDisabled then
                gradientColor = Color(40, 40, 40, 100)
            else
                gradientColor = self.SelectedFrac > 0 and 
                    Color(baseColor.r * 0.5, baseColor.g * 0.5, baseColor.b * 0.5, 100 * self.SelectedFrac) or
                    Color(50, 50, 50, 100)
            end
                
            surface.SetDrawColor(gradientColor)
            surface.SetMaterial(gradientDown)
            surface.DrawTexturedRect(0, 0, w, h)
            

            local percent = totalVotes > 0 and math.floor((voteResults[index] or 0) / totalVotes * 100) or 0
            
            if isDisabled then
                draw.RoundedBox(4, w - 180, 10, 170, 30, Color(40, 40, 40, 180))
                draw.SimpleText("IN DEVELOPMENT", "Defense_Stats", w - 95, 25, Color(255, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.RoundedBox(4, w - 70, 10, 60, 30, Color(40, 40, 40, 180))
                draw.SimpleText(percent .. "%", "Defense_Stats", w - 40, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            local textColor = isDisabled and Color(150, 150, 150) or Color(255, 255, 255)
            draw.SimpleText(modeDescriptions[index].title, "Defense_Button", 20, 22, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(modeDescriptions[index].shortDesc, "Defense_SmallText", 20, 50, isDisabled and Color(120, 120, 120) or Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            

            if self.SelectedFrac > 0 and not isDisabled then
                draw.SimpleText("SELECTED", "Defense_SmallText", w - 120, 50, Color(255, 255, 255, 255 * self.SelectedFrac), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        button.DoClick = function()
            if isDisabled then
                surface.PlaySound("buttons/button10.wav")
                return
            end
            
            local previousSelection = selectedMode
            selectedMode = index
            
            if previousSelection ~= selectedMode then
                surface.PlaySound("ui/buttonclick.wav")
                

                net.Start("defense_change_vote")
                net.WriteInt(previousSelection or 0, 4) 
                net.WriteInt(selectedMode, 4) 
                net.SendToServer()
            end
        end
        

        local descPanel = vgui.Create("DPanel", voteMenu)
        descPanel:SetSize(750, 110)
        descPanel:SetPos(voteMenu:GetWide() / 2 - 375, yPos + 90)
        descPanel.Paint = function(self, w, h)

            local bgColor = isDisabled and Color(15, 15, 15, 160) or Color(20, 20, 20, 160)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)

            local textColor = isDisabled and Color(150, 150, 150) or Color(220, 220, 220)
            draw.DrawText(modeDescriptions[index].longDesc, "Defense_Description", 15, 10, textColor, TEXT_ALIGN_LEFT)
            

            local y = 40
            local maxFeaturesPerRow = 2
            local featureWidth = w / maxFeaturesPerRow - 20

            for i, feature in ipairs(modeDescriptions[index].features) do
                local row = math.floor((i - 1) / maxFeaturesPerRow)
                local col = (i - 1) % maxFeaturesPerRow
                local xPos = 15 + col * featureWidth
                local yPos = y + row * 18
                
                if yPos + 18 <= h then 
                    local featureColor = isDisabled and Color(130, 130, 130) or Color(200, 200, 200)
                    draw.SimpleText(feature, "Defense_SmallText", xPos, yPos, featureColor, TEXT_ALIGN_LEFT)
                end
            end
            

            if isDisabled then
                draw.SimpleText("This mode is currently under development and will be available soon!", 
                               "Defense_SmallText", w/2, h-20, Color(255, 100, 100), TEXT_ALIGN_CENTER)
            end
        end
        
        return button
    end

    local standardButton = CreateModeButton(1, 100)
    local extendedButton = CreateModeButton(2, 300)
    local zombieButton = CreateModeButton(3, 500)
end

net.Receive("defense_start_vote", function()
    voteEndTime = net.ReadFloat()
    selectedMode = nil
    voteResults = {0, 0, 0}
    totalVotes = 0
    CreateVoteMenu()
end)

net.Receive("defense_vote_update", function()
    voteResults = net.ReadTable()
    totalVotes = 0
    for _, votes in pairs(voteResults) do
        totalVotes = totalVotes + votes
    end
end)

net.Receive("defense_vote_result", function()
    currentSubMode = net.ReadString()
    voteResults = net.ReadTable()
    
    if IsValid(voteMenu) then
        voteMenu:Remove()
    end
    
    surface.PlaySound("buttons/button14.wav")
end)

net.Receive("defense_show_selected_mode", function()
    local mode = net.ReadString()
    currentSubMode = mode
    showSelectedMode = true
    selectedModeDisplayTime = CurTime()
    
    if mode == "ZOMBIE" then
        surface.PlaySound("npc/zombie/zombie_alert1.wav")
    elseif mode == "EXTENDED" then
        surface.PlaySound("ambient/alarms/klaxon1.wav")
    else
        surface.PlaySound("buttons/combine_button1.wav")
    end
end)

local originalHUDPaint = MODE.HUDPaint
MODE.HUDPaint = function(self)
    if originalHUDPaint then
        originalHUDPaint(self)
    end
    
    if showSelectedMode and CurTime() - selectedModeDisplayTime < selectedModeDisplayDuration then
        local alpha = 255
        if CurTime() - selectedModeDisplayTime > selectedModeDisplayDuration - 1 then
            alpha = 255 * (1 - (CurTime() - (selectedModeDisplayTime + selectedModeDisplayDuration - 1)))
        end
        
        local modeName = "Unknown"
        local modeColor = Color(255, 255, 255)
        local description = ""
        
        if currentSubMode == "STANDARD" then
            modeName = "Standard Mode"
            modeColor = Color(50, 150, 255)
            description = "Classic 6 waves of combine attacks"
        elseif currentSubMode == "EXTENDED" then
            modeName = "Extended Mode"
            modeColor = Color(255, 150, 50)
            description = "12 waves with bosses and special enemies"
        elseif currentSubMode == "ZOMBIE" then
            modeName = "Zombie Mode"
            modeColor = Color(50, 255, 50)
            description = "6 waves of zombie apocalypse"
        end
        
        modeColor.a = alpha
        
        local text = "Selected mode: " .. modeName
        
        draw.SimpleText(text, "Defense_Title", ScrW() * 0.5, ScrH() * 0.3, modeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(description, "Defense_Subtitle", ScrW() * 0.5, ScrH() * 0.35, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    if showSelectedMode and CurTime() - selectedModeDisplayTime >= selectedModeDisplayDuration then
        showSelectedMode = false
    end
end




hook.Remove("radialOptions", "CommanderSupportOptions")

net.Receive("defense_submit_vote", function(len, ply)
    if not IsValid(ply) then return end
    
    local vote = net.ReadInt(4)
    if vote < 1 or vote > 3 then return end
    

    if vote == 3 then return end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" or not MODE.VoteInProgress then return end
    
    if not ply.HasVoted then
        MODE.VoteResults[vote] = MODE.VoteResults[vote] + 1
        ply.HasVoted = vote 
        
        net.Start("defense_vote_update")
        net.WriteTable(MODE.VoteResults)
        net.Broadcast()
    end
end)

hook.Add("Think", "MonitorPlayerRoleChange", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local currentRole = ply:GetNWString("PlayerRole", "")
    
    if not ply.lastRole then
        ply.lastRole = currentRole
    elseif ply.lastRole ~= currentRole then
        hook.Run("OnLocalPlayerRoleChanged", ply.lastRole, currentRole)
        ply.lastRole = currentRole
    end
end)


local bossWaveData = {
    active = false,
    startTime = 0,
    duration = 6, 
    fadeInTime = 0.5, 
    showTime = 5,
    fadeOutTime = 0.5, 
    scale = 0,
    targetScale = 1
}

local bossBannerColors = {
    main = Color(220, 30, 30),
    glow = Color(255, 80, 80),
    text = Color(255, 255, 255),
    shadow = Color(0, 0, 0, 180),
    background = Color(30, 30, 30, 220),
    border = Color(255, 0, 0)
}


net.Receive("defense_boss_incoming", function()
    bossWaveData.active = true
    bossWaveData.startTime = CurTime()
    bossWaveData.scale = 0
    

    surface.PlaySound("ambient/alarms/razortrain_horn1.wav")
    timer.Simple(0.8, function()
        surface.PlaySound("ambient/alarms/klaxon1.wav")
    end)
end)


local function DrawBossIncomingBanner()
    if not bossWaveData.active then return end
    
    local curTime = CurTime()
    local elapsedTime = curTime - bossWaveData.startTime

    if elapsedTime > bossWaveData.duration then
        bossWaveData.active = false
        return
    end

    local alpha = 255
    local centerX = ScrW() / 2
    local centerY = ScrH() * 0.2 
    local bannerWidth = ScrW() * 0.45 
    local bannerHeight = ScrH() * 0.13 
    

    if elapsedTime < bossWaveData.fadeInTime then

        local progress = elapsedTime / bossWaveData.fadeInTime
        alpha = 255 * progress
        bossWaveData.scale = Lerp(progress, 0.5, 1)
    elseif elapsedTime > (bossWaveData.duration - bossWaveData.fadeOutTime) then

        local progress = (elapsedTime - (bossWaveData.duration - bossWaveData.fadeOutTime)) / bossWaveData.fadeOutTime
        alpha = 255 * (1 - progress)
        bossWaveData.scale = Lerp(progress, 1, 1.1) 
    else

        bossWaveData.scale = 1 
    end
    
    local scaledWidth = bannerWidth * bossWaveData.scale
    local scaledHeight = bannerHeight * bossWaveData.scale
    local x = centerX - scaledWidth / 2
    local y = centerY - scaledHeight / 2
    
    local mainColor = Color(bossBannerColors.main.r, bossBannerColors.main.g, bossBannerColors.main.b, alpha)
    local textColor = Color(bossBannerColors.text.r, bossBannerColors.text.g, bossBannerColors.text.b, alpha)
    local shadowColor = Color(bossBannerColors.shadow.r, bossBannerColors.shadow.g, bossBannerColors.shadow.b, alpha * 0.8)
    local backgroundColor = Color(bossBannerColors.background.r, bossBannerColors.background.g, bossBannerColors.background.b, alpha * 0.9)
    local borderColor = Color(bossBannerColors.border.r, bossBannerColors.border.g, bossBannerColors.border.b, alpha)
    

    surface.SetDrawColor(0, 0, 0, alpha * 0.15)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    

    draw.RoundedBox(6, x, y, scaledWidth, scaledHeight, backgroundColor)
    

    local headerHeight = scaledHeight * 0.55
    draw.RoundedBoxEx(6, x, y, scaledWidth, headerHeight, mainColor, true, true, false, false)
    

    surface.SetDrawColor(borderColor)
    for i = 1, 2 do
        surface.DrawOutlinedRect(x + (i-1), y + (i-1), scaledWidth - (i-1)*2, scaledHeight - (i-1)*2)
    end
    

    local textY = y + headerHeight / 2
    

    draw.SimpleText("BOSS INCOMING", "ZB_HomicideMediumLarge", centerX + 2, textY + 2, shadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    

    draw.SimpleText("BOSS INCOMING", "ZB_HomicideMediumLarge", centerX, textY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    

    local infoY = y + headerHeight + (scaledHeight - headerHeight) / 2
    draw.SimpleText("Prepare for a powerful enemy!", "ZB_HomicideMedium", centerX, infoY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    

    local barHeight = scaledHeight * 0.04
    local barY = y + scaledHeight - barHeight 
    local barWidth = scaledWidth 
    local barX = x 
    

    draw.RoundedBox(0, barX, barY, barWidth, barHeight, Color(50, 50, 50, alpha * 0.7))
    

    local barProgress = 1 - (elapsedTime / bossWaveData.duration)
    local barProgressWidth = barWidth * barProgress
    draw.RoundedBox(0, barX, barY, barProgressWidth, barHeight, mainColor)
end


hook.Add("HUDPaint", "DrawBossIncomingBanner", DrawBossIncomingBanner)


--[[concommand.Add("defense_test_boss_banner", function()
	if not LocalPlayer():IsAdmin() then return end
    bossWaveData.active = true
    bossWaveData.startTime = CurTime()
    bossWaveData.scale = 0
    

    surface.PlaySound("ambient/alarms/razortrain_horn1.wav")
    timer.Simple(0.8, function()
        surface.PlaySound("ambient/alarms/klaxon1.wav")
    end)
    
    --chat.AddText(Color(255, 50, 50), "[DEFENSE] ", Color(255, 255, 255), "Boss banner test activated!")
end)]]



