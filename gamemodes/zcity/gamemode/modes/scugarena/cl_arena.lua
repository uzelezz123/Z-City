MODE.name = "scugarena"

local MODE = MODE

local roundend = false

local snds = {
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/esigrazbvx/RW%2013%20-%20Action%20Scene.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/nhorqnrimw/RW%2043%20-%20Bio%20Engineering.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/mytihhgmqb/RW%2046%20-%20Lonesound.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/lpnpntddfm/RW%2042%20-%20Kayava.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/ksytiscxay/RW%2043%20-%20Albino.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/gwzlivihho/Threat%20-%20Chimney%20Canopy.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/hoizfhtpik/Threat%20-%20Farm%20Arrays.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/nrlhdzzkey/Threat%20-%20Garbage%20Wastes.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/neszrspvqq/Threat%20-%20Heavy%20Industrial.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/xlekgoehuo/Threat%20-%20Outskirts.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/sqnnxelsyr/Threat%20-%20Shoreline.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-gamerip-switch-ps4-windows-2017/opgbomraxz/Threat%20-%20Sky%20Islands.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-downpour-soundtrack-2023/bnibwqpmxd/10.%20Threat%20-%20Waterfront%20Complex.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-downpour-soundtrack-2023/zlemcmhgsb/16.%20Threat%20-%20Metropolis%20%28Day%29.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-downpour-soundtrack-2023/xcjyveuqgx/17.%20Threat%20-%20Metropolis%20%28Night%29.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-downpour-soundtrack-2023/tpekkwpwxt/23.%20Threat%20-%20Pipe%20Yard.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-downpour-soundtrack-2023/ciyrnpxhky/29.%20Threat%20-%20Outer%20Expanse.mp3",
	"https://eta.vgmtreasurechest.com/soundtracks/rain-world-downpour-soundtrack-2023/umipiratiq/41.%20Threat%20-%20Rubicon%20%28Unused%29.mp3",
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

net.Receive("scugarena_start", function()
	roundend = false

	restartMusic()

	zb.RemoveFade()
	
    StartTime = CurTime()
	--surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
end)

local slugcat = {
    objective = "Survive and eliminate others.",
    name = "Slugcat",
    color1 = Color(190,15,15)
}

function MODE:RenderScreenspaceEffects()
    if not zb.ROUND_START or zb.ROUND_START + 7.5 < CurTime() then return end
	
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(),0,1)

    surface.SetDrawColor(0,0,0,255 * fade)
    surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
end

function MODE:HUDPaint()
	if zb.ROUND_START + 20 > CurTime() then
		draw.SimpleText( string.FormattedTime(zb.ROUND_START + 20 - CurTime(), "%02i:%02i:%02i"	), "ZB_HomicideMedium", sw * 0.5, sh * 0.75, Color(255,55,55), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

			local vol = math.Clamp((CurTime() - (zb.ROUND_START + 22)),0.1, ply:Alive() and ply.organism.otrub and 0.1 or 1)
			if roundend then
				vol =  math.Clamp((roundend - CurTime() + 1) / 2,0, ply:Alive() and ply.organism.otrub and 0 or 1)
			end
			local musicVolume = GetConVar("snd_musicvolume"):GetFloat()
			dmmusic:SetVolume(vol*musicVolume)
		end
	end
	
	 
	if not lply:Alive() then return end
    if zb.ROUND_START + 8.5 < CurTime() then return end
	zb.RemoveFade()
    local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(),0,1)
    
    draw.SimpleText("Slug Arena", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local Rolename = slugcat.name
	local ColorRole = slugcat.color1
    ColorRole.a = 255 * fade
    draw.SimpleText("You are a "..Rolename , "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local Objective = slugcat.objective
    local ColorObj = slugcat.color1
    ColorObj.a = 255 * fade
    draw.SimpleText( Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local CreateEndMenu = nil
local wonply = nil

net.Receive("scugarena_end", function()
	local ent = net.ReadEntity()
	wonply = nil
	if IsValid(ent) then
		ent.won = true
		wonply = ent
	end
	
	roundend = CurTime()

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

	for i,ply in player.Iterator() do
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
    for i,ply in player.Iterator() do
		ply.won = nil
    end

    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end
