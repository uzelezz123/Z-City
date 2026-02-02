
MODE.name = "superfighters"

local MODE = MODE

local radius = nil
local mapsize = 7500
-- MODE.MapSize = mapsize

StartTime = StartTime or 0

zb.ROUND_START = zb.ROUND_START or 0

ZonePos = ZonePos or Vector(0,0,0)
dmmusic = dmmusic or nil

local roundend = false

local snds = {
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/ujuwzquyre/01.%20A%20Grim%20Feeling.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/zgagxqybov/02.%20Alley%20.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/qsoislqepd/17.%20Hazardous.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/zqxkrixwbn/26.%20Rooftops.mp3",
	"https://kappa.vgmsite.com/soundtracks/superfighters-deluxe-original-soundtrack-2018/kvlgywwwnt/13.%20Escape.mp3"
}

local function restartMusic()
	local snd = snds[math.random(#snds)]

	if IsValid(dmmusic) then
		dmmusic:Stop()
		dmmusic = nil
	end
	
	sound.PlayURL(snd, "mono noblock noplay", function(station, errID, err)
		if IsValid(station) then
			station:SetVolume(0.1)
			
			dmmusic = station
		else
			print(errID, err)
		end
	end)
end

net.Receive("supfight_start",function()	
	roundend = false

	restartMusic()

	zb.RemoveFade()
	
    StartTime = CurTime()
	ZonePos = net.ReadVector()
    --surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
end)

local fighter = {
    objective = "Kill everyone.",
    name = "Superfighter",
    color1 = Color(0,120,190)
}

--local zonemodel = ClientsideModel("models/hunter/misc/sphere375x375.mdl",RENDERGROUP_TRANSLUCENT)
--zonemodel:SetNoDraw(true)
--zonemodel:SetMaterial("hmcd_dmzone")

local mat = Material("hmcd_dmzone")

local mapsize = 7500

function MODE:PostDrawTranslucentRenderables(bDepth, bSkybox, isDraw3DSkybox)
	if(!bSkybox and !isDraw3DSkybox)then
		--render.SetMaterial(mat)
		--render.DrawSphere( ZonePos, -(mapsize * math.max(( (zb.ROUND_START + 300) - CurTime()) / 300,0.025)), 60, 60, color_white )
	end
	--zonemodel:DrawModel()
end

function MODE:RenderScreenspaceEffects()
	
    if zb.ROUND_START + 7.5 < CurTime() then return end
	
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(),0,1)

    surface.SetDrawColor(0,0,0,255 * fade)
    surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
end

function MODE:HUDPaint()
	if zb.ROUND_START + 5 > CurTime() then
		draw.SimpleText( string.FormattedTime(zb.ROUND_START + 5 - CurTime(), "%02i:%02i:%02i"	), "ZB_HomicideMedium", sw * 0.5, sh * 0.75, Color(255,55,55), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		local ply = LocalPlayer()
		if IsValid(dmmusic) then
			if dmmusic:GetTime() >= (dmmusic:GetLength() - 1) then
				restartMusic()

				return
			end

			if dmmusic:GetState() != GMOD_CHANNEL_PLAYING then
				dmmusic:Play()
				
				return
			end

			local vol = math.Clamp((CurTime() - (zb.ROUND_START + 7)),0.1, ply:Alive() and ply.organism.otrub and 0.1 or 1 + math.min((ply.organism.adrenaline or 0) * 25,2))
			if roundend then
				vol = math.Clamp((roundend - CurTime() + 1) / 2,0.1, ply:Alive() and ply.organism.otrub and 0.1 or 1 + math.min((ply.organism.adrenaline or 0) * 25,2))
			end
			local musicVolume = GetConVar("snd_musicvolume"):GetFloat()
			dmmusic:SetVolume(vol*musicVolume)
		end
	end
	
	for i, ply in player.Iterator() do
		if ply == LocalPlayer() or not ply:Alive() then continue end
		local tr = hg.eyeTrace(ply)
		local dist = ply:GetPos():Distance(LocalPlayer():GetPos())
		local pos = tr.StartPos + vector_up * 15
		local posscr = pos:ToScreen()
		dist = math.Clamp(dist / 128, 1, 16)
		local width = ScrW() / 8 / dist
		local height = ScrH() / 64 / dist
		local health = ply:Health() / 100
		surface.SetDrawColor(122,122,122,255)
		surface.DrawRect(posscr.x - width / 2, posscr.y - height, width, height)
		surface.SetDrawColor(255 * (1 - health),255 * health,0,255)
		surface.DrawRect(posscr.x - width / 2, posscr.y - height, width * health, height)
		
		surface.SetTextColor(255,255,255,255)
		surface.SetFont("ScoreboardDefault")
		local txt = ply:Name()
		local w, h = surface.GetTextSize(txt)
		surface.SetTextPos(posscr.x - w / 2, posscr.y - h * 1 - height)
		surface.DrawText(txt)
		--draw.DrawText(txt, "ScoreboardDefault", posscr.x, posscr.y - h * 1 - height, color_white, TEXT_ALIGN_CENTER )
	end

	 
	if not lply:Alive() then return end
    if zb.ROUND_START + 8.5 < CurTime() then return end
	zb.RemoveFade()
    local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(),0,1)
    
    draw.SimpleText("Superfighters 3D", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local Rolename = fighter.name
	local ColorRole = fighter.color1
    ColorRole.a = 255 * fade
    draw.SimpleText("You are a "..Rolename , "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local Objective = fighter.objective
    local ColorObj = fighter.color1
    ColorObj.a = 255 * fade
    draw.SimpleText( Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local CreateEndMenu = nil
local wonply = nil

net.Receive("supfight_end",function()
	local ent = net.ReadEntity()
	wonply = nil
	if IsValid(ent) then
		ent.won = true
		wonply = ent
	end
	
	roundend = CurTime()

	hook.Remove("Think", "ZoneSoundThink")
	
	if(MODE.SoundStation and MODE.SoundStation:IsValid())then
		MODE.SoundStation:Stop()
		
		MODE.SoundStation = nil
	end
	
    CreateEndMenu()
end)

local colGray = Color(85,85,85,255)
local colRed = Color(217,201,99)
local colRedUp = Color(207,181,59)

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

    hmcdEndMenu.Paint = function(self,w,h)
		BlurBackground(self)
		local txt = (wonply and wonply:GetPlayerName() or "Nobody").." won!"
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize(txt)
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText(txt)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end
	
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)
	function DScrollPanel:Paint( w, h )
		BlurBackground(self)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i,ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
			local col1 = (ply.won and colRed) or (ply:Alive() and colBlue) or colGray
            local col2 = (ply.won and colRedUp) or (ply:Alive() and colBlueUp) or colSpect1
			
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
    for i,ply in ipairs(player.GetAll()) do
		ply.won = nil
    end

    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end