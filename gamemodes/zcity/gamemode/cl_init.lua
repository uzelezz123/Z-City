zb = zb or {}
include("shared.lua")
include("loader.lua")

if not ConVarExists("hg_newspectate") then
    CreateClientConVar("hg_newspectate", "1", true, false, "Enables smooth spectator camera transitions", 0, 1)
end

function CurrentRound()
	return zb.modes[zb.CROUND]
end

zb.ROUND_STATE = 0
--0 = players can join, 1 = round is active, 2 = endround
local vecZero = Vector(0.2, 0.2, 0.2)
local vecFull = Vector(1, 1, 1)
spect,prevspect,viewmode = nil,nil,1
local hullscale = Vector(0,0,0)
net.Receive("ZB_SpectatePlayer", function(len)
	spect = net.ReadEntity()
	prevspect = net.ReadEntity()
	viewmode = net.ReadInt(4)

	timer.Simple(0.1,function()
		-- LocalPlayer():BoneScaleChange()
		LocalPlayer():SetHull(-hullscale,hullscale)
		LocalPlayer():SetHullDuck(-hullscale,hullscale)

		if viewmode == 3 then
			LocalPlayer():SetMoveType(MOVETYPE_NOCLIP)
		end
	end)
end)

zb.ROUND_TIME = zb.ROUND_TIME or 400
zb.ROUND_START = zb.ROUND_START or CurTime()
zb.ROUND_BEGIN = zb.ROUND_BEGIN or CurTime() + 5

net.Receive("updtime",function()
	local time = net.ReadFloat()
	local time2 = net.ReadFloat()
	local time3 = net.ReadFloat()

	zb.ROUND_TIME = time
	zb.ROUND_START = time2
	zb.ROUND_BEGIN = time3
end)

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local blursettings = {}
local hg_potatopc
hg = hg or {}
function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	// old blur
	if(hg_potatopc:GetBool())then
		surface.SetDrawColor(0, 0, 0, alpha or (amount * 20))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		surface.SetDrawColor(0, 0, 0, alpha or 125)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		local x, y = panel:LocalToScreen(0, 0)
		if blursettings and blursettings[1] == amount and blursettings[2] == passes then
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
			return
		end
		blursettings = {amount, passes}
		for i = -(passes or 0.2), 1, 0.2 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end

	--surface.SetMaterial(blur2)
	--surface.SetDrawColor(color_white)
	--local x, y = panel:LocalToScreen(0, 0)
--
	--// those are currently hardcoded cuz it would be too much of a hassle to change this
	--blur2:SetFloat("$c0_x", (amount or 5) * 2500) // density
	--blur2:SetFloat("$c0_y", (passes or 0.2) * 2000) // noise (inverted)
	--blur2:SetFloat("$c0_z", 1) // blending
--
	--render.UpdateScreenEffectTexture()
	--surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())

	-- surface.SetDrawColor(0, 0, 0, alpha or 125)
	-- surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
end

BlurBackground = BlurBackground or hg.DrawBlur

local keydownattack
local keydownattack2
local keydownreload

hook.Add("HUDPaint","FUCKINGSAMENAMEUSEDINHOOKFUCKME",function()
    if LocalPlayer():Alive() then return end
	local spect = LocalPlayer():GetNWEntity("spect")
	if not IsValid(spect) then return end
	if viewmode == 3 then return end
	
	surface.SetFont("HomigradFont")
	surface.SetTextColor(255, 255, 255, 255)
	local txt = "Spectating player: "..spect:Name()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7)
	surface.DrawText(txt)
	local txt = "In-game name: "..spect:GetPlayerName()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7 + h)
	surface.DrawText(txt)
end)

hook.Add("HG_CalcView", "zzzzzzzUwU", function(ply, pos, angles, fov)
	if not lply:Alive() then
		if lply:KeyDown(IN_ATTACK) then
			if not keydownattack then
				keydownattack = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_ATTACK,32)
				net.SendToServer()
			end
		else
			keydownattack = false
		end

		if lply:KeyDown(IN_ATTACK2) then
			if not keydownattack2 then
				keydownattack2 = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_ATTACK2,32)
				net.SendToServer()
			end
		else
			keydownattack2 = false
		end

		if lply:KeyDown(IN_RELOAD) then
			if not keydownreload then
				keydownreload = true
				net.Start("ZB_ChooseSpecPly")
				net.WriteInt(IN_RELOAD,32)
				net.SendToServer()
			end
		else
			keydownreload = false
		end

		local spect = lply:GetNWEntity("spect",spect)
		if not IsValid(spect) then return end

		local viewmode = lply:GetNWInt("viewmode",viewmode)
		
		if viewmode == 3 then
			if lply:GetMoveType()!=MOVETYPE_NOCLIP then
				lply:SetMoveType(MOVETYPE_NOCLIP)
			end
			lply:SetObserverMode(OBS_MODE_ROAMING)
			return
		else
			lply:SetPos(spect:GetPos())
		end
		
		local ent = hg.GetCurrentCharacter(spect)
		if not IsValid(ent) then return end
		
		local headBone = ent:LookupBone("ValveBiped.Bip01_Head1") or ent:LookupBone("ValveBiped.Bip01_Spine1") or 1
		local bon = ent:GetBoneMatrix(headBone)
		
		if not bon then 
			local eyePos = ent:EyePos()
			if eyePos and eyePos ~= vector_origin then
				pos = eyePos
				ang = ent:EyeAngles()
			else
				pos = ent:GetPos() + Vector(0, 0, 64)
				ang = ent:GetAngles()
			end
		else
			pos, ang = bon:GetTranslation(), bon:GetAngles()
		end

		local eyePos, eyeAng = lply:EyePos(), lply:EyeAngles()
		
		local tr = {}
		tr.start = pos
		tr.endpos = pos + eyeAng:Forward() * -120
		tr.filter = {ent, lply, spect}
		tr.mins = Vector(-4, -4, -4)
		tr.maxs = Vector(4, 4, 4)
		tr = util.TraceHull(tr)

		if viewmode == 2 then
			pos = tr.HitPos + eyeAng:Forward() * 8
			ang = eyeAng
		elseif viewmode == 1 then
			if ent ~= spect and IsValid(ent) then
				local eyeAtt = ent:GetAttachment(ent:LookupAttachment("eyes"))
				if eyeAtt then
					ang = eyeAtt.Ang
				else
					ang = spect:EyeAngles()
				end
			else
				ang = spect:EyeAngles()
			end
			pos = pos + spect:EyeAngles():Forward() * 8
		else
			pos = eyePos
			ang = eyeAng
		end
		
		ang[3] = 0
		
		local view
		local hg_newspectate = GetConVar("hg_newspectate")
		if hg_newspectate and hg_newspectate:GetBool() then
			if not lply.spectLastPos then
				lply.spectLastPos = pos
				lply.spectLastAng = ang
			end
			
			local lerpFactor = FrameTime() * 10
			lply.spectLastPos = LerpVector(lerpFactor, lply.spectLastPos, pos)
			lply.spectLastAng = LerpAngle(lerpFactor, lply.spectLastAng, ang)

			view = {
				origin = lply.spectLastPos,
				angles = lply.spectLastAng,
				fov = fov,
			}
		else
			view = {
				origin = pos,
				angles = ang,
				fov = fov,
			}
		end

		return view
	else
		lply.spectLastPos = nil
		lply.spectLastAng = nil
		lply:SetObserverMode(OBS_MODE_NONE)
	end
end)

zb.fade = zb.fade or 0

hook.Add("RenderScreenspaceEffects", "huyhuyUwU", function()
	if zb.fade > 0 then
		zb.fade = math.Approach(zb.fade, 0, FrameTime() * 1)

		surface.SetDrawColor(0, 0, 0, 255 * math.min(zb.fade, 1))
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end
end)

zb.ROUND_STATE = 0
local function RefreshAllPlayerXP()
	for _, ply in player.Iterator() do
		if not IsValid(ply) then continue end
		net.Start("zb_xp_get")
			net.WriteEntity(ply)
		net.SendToServer()
	end
end

net.Receive("RoundInfo", function()
	local rnd = net.ReadString()
	local oldRoundState = zb.ROUND_STATE
	
	hook.Run("RoundInfoCalled", rnd)

	if zb.CROUND ~= rnd then
		if hg.DynaMusic then
			hg.DynaMusic:Stop()
		end
	end

	zb.CROUND = rnd

	zb.ROUND_STATE = net.ReadInt(4)

	if oldRoundState ~= 3 and zb.ROUND_STATE == 3 then
		surface.PlaySound("levelend.mp3")
	end
	
	if zb.ROUND_STATE == 0 then
		zb.fade = 7
	end

	if zb.CROUND ~= "" then
		if CurrentRound() then
			if zb.ROUND_STATE == 3 then
				if CurrentRound().EndRound then
					CurrentRound():EndRound()
				end
			elseif zb.ROUND_STATE == 1 then
				if CurrentRound().RoundStart then
					CurrentRound():RoundStart()
				end
				RefreshAllPlayerXP()
				timer.Simple(1, function()
					RefreshAllPlayerXP()
				end)
			end
		end
	end
end)

if IsValid(scoreBoardMenu) then
	scoreBoardMenu:Remove()
	scoreBoardMenu = nil
end

hook.Add("Player Disconnected","retrymenu",function(data)
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
end)

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZB_InterfaceSmall", {
    font = font(),
    size = ScreenScale(6),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceMedium", {
    font = font(),
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_ScrappersMedium", {
    font = font(),
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceMediumLarge", {
    font = font(),
    size = 35,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceLarge", {
    font = font(),
    size = ScreenScale(20),
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_InterfaceHumongous", {
    font = font(),
    size = 200,
    weight = 400,
    antialias = true
})

hg.playerInfo = hg.playerInfo or {}

local function addToPlayerInfo(ply, muted, volume)
	hg.playerInfo[ply:SteamID()] = {muted and true or false, volume}

	local json = util.TableToJSON(hg.playerInfo)
	file.Write("zcity_muted.txt", json)

	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")

		if json then
			hg.playerInfo = util.JSONToTable(json)
		end
	end

	//PrintTable(hg.playerInfo)
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "zcityhuy", function(data)
	local ply = Player(data.userid)
	if IsValid(ply) and ply.SetMuted and hg.playerInfo and hg.playerInfo[data.networkid] then
		ply:SetMuted(hg.playerInfo[data.networkid][1])
		ply:SetVoiceVolumeScale(hg.playerInfo[data.networkid][2])
	end
end)

hook.Add("InitPostEntity", "furryhuy", function()
	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")

		if json then
			hg.playerInfo = util.JSONToTable(json)
		end

		if hg.playerInfo then
			for i, ply in player.Iterator() do
				if not istable(hg.playerInfo[ply:SteamID()]) then
					local muted = hg.playerInfo[ply:SteamID()]
					hg.playerInfo[ply:SteamID()] = {}
					hg.playerInfo[ply:SteamID()][1] = muted
					hg.playerInfo[ply:SteamID()][2] = 1
				end//compatibility with old json

				if hg.playerInfo[ply:SteamID()] then
					ply:SetMuted(hg.playerInfo[ply:SteamID()][1])
					ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
				end
			end	
		end
	end
end)

local colGray = Color(122,122,122,255)
local colBlue = Color(130,10,10)
local colBlueUp = Color(160,30,30)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(85,85,85,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

hg.muteall = false
hg.mutespect = false

local function GetVoiceIconPath(ply)
	return ply:IsMuted() and "icon16/sound_mute.png" or "icon16/sound.png"
end

local function SetSoundButtonIcon(button, ply)
	if not IsValid(button) or not IsValid(ply) then return end
	local icon = GetVoiceIconPath(ply)
	if button.SetImage then
		button:SetImage(icon)
		return
	end
	if button.SetIcon then
		button:SetIcon(icon)
		return
	end
	if button.SetMaterial then
		button:SetMaterial(Material(icon))
	end
end

local function OpenPlayerSoundSettings(selfa, ply)
	local Menu = DermaMenu()
	
	if not hg.playerInfo[ply:SteamID()] or not istable(hg.playerInfo[ply:SteamID()]) then addToPlayerInfo(ply, false, 1) end

	local mute = Menu:AddOption( "Mute", function(self)
		if not IsValid(ply) then return end
		if hg.muteall or (hg.mutespect and not ply:Alive()) then return end
		
		local muted = not ply:IsMuted()
		ply:SetMuted(muted)
		self:SetChecked(muted)
		SetSoundButtonIcon(selfa, ply)
		addToPlayerInfo(ply, muted, hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1)
	end ) -- get your stupid one line ass outta here

	mute:SetIsCheckable( true )
	mute:SetChecked( ply:IsMuted() )
	local volumeSlider = vgui.Create("DSlider", Menu)
	volumeSlider:SetLockY( 0.5 )
	volumeSlider:SetTrapInside( true )
	volumeSlider:SetSlideX(hg.playerInfo[ply:SteamID()][2]) 
	volumeSlider.OnValueChanged = function(self, x, y)
		if not IsValid(ply) then return end
		if hg.muteall or (hg.mutespect && !ply:Alive()) then return end
		hg.playerInfo[ply:SteamID()][2] = x
		ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
		addToPlayerInfo(ply, ply:IsMuted(), hg.playerInfo[ply:SteamID()][2])
	end

	function volumeSlider:Paint(w,h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
		draw.RoundedBox( 0, 0, 0, w*self:GetSlideX(), h, Color( 255, 0, 0 ) )
		draw.DrawText( ( math.Round( 100*self:GetSlideX(), 0 ) ).."%", "DermaDefault", w/2, h/4, color_white, TEXT_ALIGN_CENTER )
	end
	function volumeSlider.Knob.Paint(self) end

	Menu:AddPanel(volumeSlider)
	Menu:Open()
end



hook.Add("Player Getup", "nomorespect", function(ply)
	if not hg.mutespect then return end

	//ply:SetMuted(ply.oldmutedspect)
	ply:SetVoiceVolumeScale(!hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
	//ply.oldmutedspect = nil

	//if IsValid(ply.soundButton) then
		//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
	//end
end)

hook.Add("Player_Death", "fixSpectatorVoiceMute", function(ply)
	if not hg.mutespect then return end

	//ply.oldmutedspect = ply:IsMuted()
	//ply:SetMuted(hg.mutespect)
	ply:SetVoiceVolumeScale(0)
	//if IsValid(ply.soundButton) then
		//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
	//end
end)

hook.Add("Player_Death", "fixSpectatorVoiceEffect", function(ply)
	if eightbit and eightbit.EnableEffect and ply.UserID then
		eightbit.EnableEffect(ply:UserID(), 0)
	end
end)

function GM:ScoreboardShow()
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
	Dynamic = 0
	scoreBoardMenu = vgui.Create("ZFrame")
	local mh2ColorFrameBG = Color(28, 27, 24, 245)
	local mh2ColorFrameBorder = Color(96, 90, 82, 255)
	local mh2ColorPanelBG = Color(14, 13, 11, 248)
	local mh2ColorHeaderBG = Color(6, 6, 5, 230)
	local mh2ColorHeaderBorder = Color(255, 255, 255, 45)
	local mh2ColorHeaderActive = Color(165, 150, 130, 95)
	local mh2ColorRowBG = Color(10, 9, 8, 190)
	local mh2ColorRowAlt = Color(15, 14, 12, 165)
	local mh2ColorRowHover = Color(255, 255, 255, 35)
	local mh2ColorRowBorder = Color(255, 255, 255, 26)
	local mh2ColorSplit = Color(255, 255, 255, 22)
	local mh2ColorAccent = Color(176, 165, 145, 180)
	local mh2ColorText = Color(236, 234, 228, 255)
	local mh2ColorTextDim = Color(206, 201, 192, 230)
	local mh2ColorScrollTrack = Color(12, 10, 8, 120)
	local mh2ColorScrollGrip = Color(140, 120, 90, 220)

	local sizeX,sizeY = ScrW() / 1.3 ,ScrH() / 1.2
	local leaderboardOffsetY = ScreenScaleH(14)
	local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2 + leaderboardOffsetY

	scoreBoardMenu:SetPos(posX,posY)
	scoreBoardMenu:SetSize(sizeX,sizeY)
	scoreBoardMenu:MakePopup()
	scoreBoardMenu:SetKeyboardInputEnabled( false )
	scoreBoardMenu:ShowCloseButton( false )
	scoreBoardMenu:SetColorBG(mh2ColorFrameBG)
	scoreBoardMenu:SetColorBR(mh2ColorFrameBorder)

	local muteallbut = vgui.Create("DButton", scoreBoardMenu)
	local muteBtnAllW = math.max(ScreenScaleH(52), math.floor(sizeX * 0.08))
	local muteBtnSpectW = math.max(ScreenScaleH(84), math.floor(sizeX * 0.13))
	local muteBtnH = math.max(ScreenScaleH(11), math.floor(sizeY * 0.028))
	local muteButtonY = scoreBoardMenu:GetTall() - muteBtnH - ScreenScaleH(3)
	muteallbut:SetPos(scoreBoardMenu:GetWide() - muteBtnAllW - muteBtnSpectW - ScreenScale(12), muteButtonY)
	muteallbut:SetSize(muteBtnAllW, muteBtnH)
	muteallbut:SetText("")
	muteallbut:SetZPos(1500)
	
	muteallbut.Paint = function(self,w,h)
		surface.SetDrawColor( not hg.muteall and 160 or 255, hg.muteall and 160 or 255, 160, 120)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		draw.SimpleText("Mute All", "ZB_InterfaceSmall", w * 0.5, h * 0.5, mh2ColorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	muteallbut.DoClick = function(self,w,h)
		hg.muteall = not hg.muteall
		
		for i,ply in player.Iterator() do
			if hg.muteall then
				//ply.oldmutedspect = ply:IsMuted()

				ply:SetVoiceVolumeScale(0)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
			else
				ply:SetVoiceVolumeScale((!hg.mutespect or ply:Alive()) and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
				//ply:SetMuted(ply.oldmuted)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
				//ply.oldmuted = nil
			end
		end 
	end

	local mutespectbut = vgui.Create("DButton", scoreBoardMenu)
	mutespectbut:SetPos(scoreBoardMenu:GetWide() - muteBtnSpectW - ScreenScale(8), muteButtonY)
	mutespectbut:SetSize(muteBtnSpectW, muteBtnH)
	mutespectbut:SetText("")
	mutespectbut:SetZPos(1500)
	
	mutespectbut.Paint = function(self,w,h)
		surface.SetDrawColor( not hg.mutespect and 160 or 255, hg.mutespect and 160 or 255, 160, 120)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		draw.SimpleText("Mute Spectators", "ZB_InterfaceSmall", w * 0.5, h * 0.5, mh2ColorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	mutespectbut.DoClick = function(self,w,h)
		hg.mutespect = not hg.mutespect
		
		for i,ply in player.Iterator() do
			if ply:Alive() then continue end

			if hg.mutespect then
				ply:SetVoiceVolumeScale(0)
				//ply.oldmutedspect = ply:IsMuted()

				//ply:SetMuted(true)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
			else
				ply:SetVoiceVolumeScale(!hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
				//ply:SetMuted(ply.oldmutedspect)
				//if IsValid(ply.soundButton) then
					//ply.soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
				//end
				//ply.oldmutedspect = nil
			end
		end 
	end

	local ServerName = GetHostName() or "ZCity | Developer Server | #01"
	local listTopY = ScreenScaleH(58)
	local leftPanelX = 10
	local leftPanelW = math.floor(sizeX * 0.62)
	local panelGap = 8
	local rightPanelX = leftPanelX + leftPanelW + panelGap
	local rightPanelW = math.max(sizeX - rightPanelX - 10, 140)
	local leftPanelH = sizeY - listTopY - ScreenScaleH(14)
	local rightPanelY = listTopY + ScreenScaleH(22)
	local rightPanelH = sizeY - rightPanelY - ScreenScaleH(14)
	local buttonW = ScrW() / 20
	local buttonH = ScrH() / 30
	local tick
	scoreBoardMenu.PaintOver = function(self,w,h)
		surface.SetDrawColor(mh2ColorFrameBorder)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		surface.SetFont("ZC_MM_Title")
		local headerText = "meleecity dickacy"
		local headerW = surface.GetTextSize(headerText)
		local time = CurTime()
		local blinkChance = math.sin(time * 0.5)
		local redBlink = 255
		if blinkChance > 0.8 then
			local blinkSpeed = 20
			local pulse = (math.sin(time * blinkSpeed) + 1) / 2
			redBlink = 255 - pulse * 200
		end
		surface.SetTextColor(255, redBlink, redBlink, 255)
		DisableClipping(true)
		surface.SetTextPos(w * 0.5 - headerW * 0.5, -ScreenScaleH(34) - leaderboardOffsetY)
		surface.DrawText(headerText)
		DisableClipping(false)

		surface.SetFont("ZCity_Veteran")
		surface.SetTextColor(mh2ColorText)
		local serverW = surface.GetTextSize(ServerName)
		local serverTitleY = ScreenScaleH(11)
		surface.SetTextPos(w * 0.5 - serverW * 0.5, serverTitleY)
		surface.DrawText(ServerName)

		tick = math.Round(LerpFT(0.1,tick or 0, 1 / engine.ServerFrameTime()))
		local tickText = "SV Tick: " .. tick
		local tickW = surface.GetTextSize(tickText)
		local tickY = ScreenScaleH(25)
		surface.SetTextColor(mh2ColorTextDim)
		surface.SetTextPos(w * 0.5 - tickW * 0.5, tickY)
		surface.DrawText(tickText)

		surface.SetFont( "ZB_InterfaceSmall" )
		surface.SetTextColor(mh2ColorTextDim.r, mh2ColorTextDim.g, mh2ColorTextDim.b, 35)
		local txt = "ZC Version: "..hg.Version
		local lengthX, lengthY = surface.GetTextSize(txt)
		surface.SetTextPos(w*0.01,h - lengthY - h*0.01)
		surface.DrawText(txt)

		surface.SetFont("ZCity_Veteran")
		surface.SetTextColor(mh2ColorText)
		local leftLabel = "PLAYERS"
		surface.SetTextPos(leftPanelX + ScreenScale(4), listTopY - ScreenScaleH(18))
		surface.DrawText(leftLabel)

		surface.SetFont("ZCity_Veteran")
		surface.SetTextColor(mh2ColorText)
		local rightLabel = "OBSERVERS"
		local rightLW = surface.GetTextSize(rightLabel)
		surface.SetTextPos(rightPanelX + rightPanelW - rightLW - ScreenScale(6), rightPanelY - ScreenScaleH(18))
		surface.DrawText(rightLabel)
		surface.SetDrawColor(mh2ColorAccent)
		surface.DrawRect(leftPanelX, listTopY - 2, leftPanelW, 1)
		surface.DrawRect(rightPanelX, rightPanelY - 2, rightPanelW, 1)
	end
	if LocalPlayer():Team() ~= TEAM_SPECTATOR then
		local SPECTATE = vgui.Create("DButton",scoreBoardMenu)
		SPECTATE:SetPos(rightPanelX + ScreenScale(3), rightPanelY + rightPanelH - buttonH - ScreenScaleH(4))
		SPECTATE:SetSize(buttonW, buttonH)
		SPECTATE:SetText("")
		SPECTATE:SetZPos(1000)
		
		SPECTATE.DoClick = function()
			net.Start("ZB_SpecMode")
				net.WriteBool(true)
			net.SendToServer()
			scoreBoardMenu:Remove()
			scoreBoardMenu = nil
		end

		SPECTATE.Paint = function(self,w,h)
			surface.SetDrawColor(mh2ColorFrameBorder)
			surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
			draw.SimpleText("Join", "ZB_InterfaceMedium", w * 0.5, h * 0.5, mh2ColorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	if LocalPlayer():Team() == TEAM_SPECTATOR then
		local PLAYING = vgui.Create("DButton",scoreBoardMenu)
		PLAYING:SetPos(leftPanelX + ScreenScale(3), listTopY + leftPanelH - buttonH - ScreenScaleH(4))
		PLAYING:SetSize(buttonW, buttonH)
		PLAYING:SetText("")
		PLAYING:SetZPos(1000)
		
		PLAYING.DoClick = function()
			net.Start("ZB_SpecMode")
				net.WriteBool(false)
			net.SendToServer()
			scoreBoardMenu:Remove()
			scoreBoardMenu = nil
		end

		PLAYING.Paint = function(self,w,h)
			surface.SetDrawColor(mh2ColorFrameBorder)
			surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
			draw.SimpleText("Join", "ZB_InterfaceMedium", w * 0.5, h * 0.5, mh2ColorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	local function StyleScrollbar(sbar)
		if not IsValid(sbar) then return end
		sbar:SetHideButtons(true)
		function sbar:Paint(sw, sh)
			draw.RoundedBox(0, 0, 0, sw, sh, mh2ColorScrollTrack)
		end
		function sbar.btnGrip:Paint(sw, sh)
			draw.RoundedBox(0, 0, 0, sw, sh, mh2ColorScrollGrip)
		end
	end

	local disappearance = lply:GetNetVar("disappearance", nil)
	local function SortPlayers(list, sortState)
		table.sort(list, function(a, b)
			local av, bv
			if sortState.key == "name" then
				av = string.lower(a:Name() or "")
				bv = string.lower(b:Name() or "")
			elseif sortState.key == "ping" then
				av = a:Ping()
				bv = b:Ping()
			else
				av = a:Frags()
				bv = b:Frags()
			end

			if av == bv then
				return a:UserID() < b:UserID()
			end
			return sortState.desc and av > bv or av < bv
		end)
	end

	local function CreateListPanel(x, y, w, h)
		local pnl = vgui.Create("DScrollPanel", scoreBoardMenu)
		pnl:SetPos(x, y)
		pnl:SetSize(w, h)
		function pnl:Paint(pw, ph)
			surface.SetDrawColor(mh2ColorPanelBG)
			surface.DrawRect(0, 0, pw, ph)
			surface.SetDrawColor(mh2ColorHeaderBorder)
	        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
		end
		StyleScrollbar(pnl:GetVBar())
		return pnl
	end

	local playerListPanel = CreateListPanel(leftPanelX, listTopY, leftPanelW, leftPanelH)
	local spectatorListPanel = CreateListPanel(rightPanelX, rightPanelY, rightPanelW, rightPanelH)

	local playerSort = { key = "name", desc = false }
	local spectatorSort = { key = "name", desc = false }
	local selectedSteamID

	local function FitTextToWidth(font, text, maxWidth)
		if maxWidth <= 0 then return "" end
		if text == nil then return "" end
		surface.SetFont(font)
		if surface.GetTextSize(text) <= maxWidth then
			return text
		end
		local ellipsis = "..."
		local ellipsisW = surface.GetTextSize(ellipsis)
		if ellipsisW >= maxWidth then
			return ""
		end
		local low, high = 0, #text
		while low < high do
			local mid = math.floor((low + high + 1) * 0.5)
			local candidate = string.sub(text, 1, mid) .. ellipsis
			if surface.GetTextSize(candidate) <= maxWidth then
				low = mid
			else
				high = mid - 1
			end
		end
		return string.sub(text, 1, low) .. ellipsis
	end

	local function AddPlayerRow(parent, ply, rowIndex)
		local row = vgui.Create("DButton", parent)
		row:SetTall(ScreenScaleH(22))
		row:Dock(TOP)
		row:DockMargin(8, 0, 8, 3)
		row:SetText("")

		local avatar = vgui.Create("AvatarImage", row)
		avatar:Dock(LEFT)
		avatar:SetWide(ScreenScaleH(22))
		avatar:DockMargin(0, 0, 8, 0)
		avatar:SetPlayer(ply, 32)

		local soundButton = vgui.Create("DImageButton", row)
		soundButton:Dock(RIGHT)
		soundButton:SetWide(ScreenScale(10))
		soundButton:DockMargin(8, 5, 6, 5)
		SetSoundButtonIcon(soundButton, ply)
		soundButton.DoClick = function(self)
			OpenPlayerSoundSettings(self, ply)
		end
		ply.soundButton = soundButton

		row.Paint = function(self, rw, rh)
			if not IsValid(ply) then return end
			local base = rowIndex % 2 == 0 and mh2ColorRowAlt or mh2ColorRowBG
			surface.SetDrawColor(base)
			surface.DrawRect(0, 0, rw, rh)
			local wedge = math.min(ScreenScaleH(11), math.floor(rw * 0.12))
			surface.SetDrawColor(255, 255, 255, 14)
			surface.DrawPoly({
				{x = 0, y = 0},
				{x = wedge, y = 0},
				{x = math.max(wedge - ScreenScaleH(7), 0), y = rh},
				{x = 0, y = rh}
			})
			if self:IsHovered() or selectedSteamID == ply:SteamID() then
				surface.SetDrawColor(mh2ColorRowHover)
				surface.DrawRect(0, 0, rw, rh)
			end
			surface.SetDrawColor(mh2ColorRowBorder)
			surface.DrawOutlinedRect(0, 0, rw, rh, 1)

			local pingValue = tostring(ply:Ping() or 0) .. "ms"
			local xpValue = tostring(math.floor(ply.exp or 0)) .. " XP"
			local statsText = pingValue .. "  " .. xpValue
			local nameX = ScreenScaleH(30)
			local rightPadding = ScreenScaleH(14)
			local textGap = ScreenScaleH(8)
			surface.SetFont("ZCity_Veteran")
			local statsW = surface.GetTextSize(statsText)
			local maxNameW = math.max(0, rw - nameX - rightPadding - statsW - textGap)
			local displayName = ply:Name() or "Unknown"
			local appearanceName = ply:GetNWString("PlayerName", "")
			if appearanceName ~= "" then
				displayName = displayName .. " (" .. appearanceName .. ")"
			end
			local fittedName = FitTextToWidth("ZCity_Veteran", displayName, maxNameW)
			draw.SimpleText(fittedName, "ZCity_Veteran", nameX, rh / 2, mh2ColorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(statsText, "ZCity_Veteran", rw - rightPadding, rh / 2, mh2ColorTextDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		function row:DoClick()
			selectedSteamID = ply:SteamID()
			if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/" .. ply:SteamID64())
		end

		function row:DoRightClick()
			local Menu = DermaMenu()
			Menu:AddOption("Account", function()
				zb.Experience.AccountMenu(ply)
			end)
			Menu:AddOption("Copy SteamID", function()
				SetClipboardText(ply:SteamID())
			end)
			Menu:Open()
		end
	end

	local function ClearRows(panel)
		local canvas = panel:GetCanvas()
		if not IsValid(canvas) then return end
		for _, child in ipairs(canvas:GetChildren()) do
			child:Remove()
		end
	end

	local function BuildRows()
		if not IsValid(scoreBoardMenu) then return end
		ClearRows(playerListPanel)
		ClearRows(spectatorListPanel)

		local activePlayers = {}
		local specPlayers = {}
		for _, ply in player.Iterator() do
			if CurrentRound().name == "fear" and not ply:Alive() then continue end
			if disappearance and ply ~= lply then continue end
			if ply:Team() == TEAM_SPECTATOR then
				specPlayers[#specPlayers + 1] = ply
			else
				activePlayers[#activePlayers + 1] = ply
			end
		end

		SortPlayers(activePlayers, playerSort)
		SortPlayers(specPlayers, spectatorSort)

		for i, ply in ipairs(activePlayers) do
			AddPlayerRow(playerListPanel:GetCanvas(), ply, i)
		end
		for i, ply in ipairs(specPlayers) do
			AddPlayerRow(spectatorListPanel:GetCanvas(), ply, i)
		end
	end

	local nextRefresh = 0
	scoreBoardMenu.Think = function()
		if nextRefresh > CurTime() then return end
		nextRefresh = CurTime() + 0.45
		BuildRows()
	end
	BuildRows()

	return true
end

function GM:ScoreboardHide()
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Close()
		scoreBoardMenu = nil
	end
end
local AdminShowVoiceChat = CreateClientConVar("zb_admin_show_voicechat","0",false,false,"Shows voicechat panles",0,1)
hook.Add("PlayerStartVoice", "asd", function(ply)
	if !IsValid(ply) then return end
	if LocalPlayer():IsAdmin() and AdminShowVoiceChat:GetBool() then return end

	local other_alive = (ply:Alive() and LocalPlayer() != ply) or (ply.organism and (ply.organism.otrub or (ply.organism.brain and ply.organism.brain > 0.05)))

	return other_alive or nil
end)

-- свет от молнии а саму молнию я не сделал skill issue
if CLIENT then
	net.Receive("PunishLightningEffect", function()
		local target = net.ReadEntity()
		if not IsValid(target) then return end
		local dlight = DynamicLight(target:EntIndex())
		if dlight then
			dlight.pos = target:GetPos()
			dlight.r = 126
			dlight.g = 139
			dlight.b = 212
			dlight.brightness = 1
			dlight.Decay = 1000
			dlight.Size = 500
			dlight.DieTime = CurTime() + 1
		end
	end)
end

/*  -- а кстати зачем здесь нэт, это же можно было на клиенте полностью сделать...
	if CLIENT then
		net.Receive("PluvCommand", function()
			local specialSteamID = "STEAM_0:1:81850653" 
			local playerSteamID = LocalPlayer():SteamID() 

			local imageURLs = {"https://sadsalat.github.io/salatis/music/boof.gif", "https://i.ibb.co/drt1Lks/KtvCLSs.webp", "https://media.tenor.com/kG4PmVvJuRIAAAAC/rain-world-rain-world-saint.gif"} 
			local soundURLs = {"https://sadsalat.github.io/salatis/music/sus-rock.mp3", "https://sadsalat.github.io/salatis/music/tiktok-raaaah-scream.mp3", "https://sadsalat.github.io/salatis/music/sus-rock.mp3"} 

			local chosenImage = imageURLs[math.random(#imageURLs)]
			local chosenSound = soundURLs[math.random(#soundURLs)]

			sound.PlayURL(chosenSound, "", function(station)
				if IsValid(station) then
					station:Play()
				else
					print("Unable to play the sound.")
				end
			end)

			local html = vgui.Create("HTML")
			html:OpenURL(chosenImage)
			html:SetSize(ScrW(), ScrH())
			html:Center()
			html:MakePopup()

			timer.Simple(3, function()
				if IsValid(html) then
					html:Remove()
				end
			end)
		end)
	end
*/

local lightningMaterial = Material("sprites/lgtning")

net.Receive("AnotherLightningEffect", function()
    local target = net.ReadEntity()
	if not IsValid(target) then return end
    local points = {}
    for i = 1, 27 do
        points[i] = target:GetPos() + Vector(0, 0, i * 50) + Vector(math.Rand(-20,20),math.Rand(-20,20),math.Rand(-20,20))
    end
    hook.Add( "PreDrawTranslucentRenderables", "LightningExample", function(isDrawingDepth, isDrawingSkybox)
        if isDrawingDepth or isDrawingSkybox then return end
        local uv = math.Rand(0, 1)
        render.OverrideBlend( true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD )
        render.SetMaterial(lightningMaterial)
        render.StartBeam(27)
        for i = 1, 27 do
            render.AddBeam(points[i], 20, uv * i, Color(255,255,255,255))
        end
        render.EndBeam()
        render.OverrideBlend( false )
    end )
    timer.Simple(0.1, function()
        hook.Remove("PreDrawTranslucentRenderables", "LightningExample")
    end)
end)

function GM:AddHint( name, delay )
	return false
end

local snakeGameOpen = false

concommand.Add("zb_snake", function() -- вот как здесь!
    if snakeGameOpen then
        print("[Snake Game] Игра уже запущена!")
        return
    end

    local frame = vgui.Create("ZFrame")
    frame:SetTitle("Snake Game")
    frame:SetSize(400, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetDeleteOnClose(true)  
    snakeGameOpen = true  

    local gridSize = 20
    local gridWidth = 19  
    local gridHeight = 19  
    local snakePanel = vgui.Create("DPanel", frame)
    snakePanel:SetSize(380, 380)
    snakePanel:SetPos(10, 10)

    
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)

    local snake = {
        {x = 10, y = 10},
    }
	
    local snakeDirection = "RIGHT"
    local food = nil
    local score = 0
    local gameRunning = true

  
    local function spawnFood()
        local validPosition = false
        while not validPosition do
            local newFood = {
                x = math.random(0, gridWidth - 1), 
                y = math.random(0, gridHeight - 1)
            }
            validPosition = true

        
            for _, segment in ipairs(snake) do
                if segment.x == newFood.x and segment.y == newFood.y then
                    validPosition = false  
                    break
                end
            end

            
            if validPosition then
                food = newFood
            end
        end
    end

    
    local function drawSnake()
        surface.SetDrawColor(0, 255, 0, 255)
        for _, segment in ipairs(snake) do
            surface.DrawRect(segment.x * gridSize, segment.y * gridSize, gridSize - 1, gridSize - 1)
        end
    end

  
    local function drawFood()
        if food then
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawRect(food.x * gridSize, food.y * gridSize, gridSize - 1, gridSize - 1)
        end
    end

   
    local function moveSnake()
        if not gameRunning then return end

        local head = table.Copy(snake[1])

        if snakeDirection == "UP" then
            head.y = head.y - 1
        elseif snakeDirection == "DOWN" then
            head.y = head.y + 1
        elseif snakeDirection == "LEFT" then
            head.x = head.x - 1
        elseif snakeDirection == "RIGHT" then
            head.x = head.x + 1
        end

        
        if head.x < 0 or head.x >= gridWidth or head.y < 0 or head.y >= gridHeight then
            gameRunning = false
        end

       
        for _, segment in ipairs(snake) do
            if segment.x == head.x and segment.y == head.y then
                gameRunning = false
            end
        end

       
        table.insert(snake, 1, head)


        if food and head.x == food.x and head.y == food.y then
            score = score + 1
            spawnFood()  
        else
            
            table.remove(snake)
        end
    end


    local function resetGame()
        snake = {{x = 10, y = 10}}
        snakeDirection = "RIGHT"
        score = 0
        gameRunning = true
        spawnFood()  
    end


    function snakePanel:Paint(w, h)
        surface.SetDrawColor(50, 50, 50, 255)
        surface.DrawRect(0, 0, w, h)

        if gameRunning then
            drawSnake()
            drawFood()
        else
            draw.SimpleText("Game Over! Press R to restart", "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("Score: " .. score, "DermaDefault", 10, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end


    function frame:OnKeyCodePressed(key) -- ФУРИ МУВ теперь понятно почему лагает змейка
        if key == KEY_W and snakeDirection ~= "DOWN" then
            snakeDirection = "UP"
        elseif key == KEY_S and snakeDirection ~= "UP" then
            snakeDirection = "DOWN"
        elseif key == KEY_A and snakeDirection ~= "RIGHT" then
            snakeDirection = "LEFT"
        elseif key == KEY_D and snakeDirection ~= "LEFT" then
            snakeDirection = "RIGHT"
        elseif key == KEY_R then
            resetGame()
        end
    end


    timer.Create("SnakeGameTimer", 0.2, 0, function()
        if gameRunning then
            moveSnake()
        end
        snakePanel:InvalidateLayout(true)
    end)


    frame.OnClose = function()
        timer.Remove("SnakeGameTimer")
        snakeGameOpen = false  
        print("[Snake Game] Игра закрыта.") -- НЕ РАБОТАЕТ
    end


    resetGame()
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
	if ply == LocalPlayer() then
		system.FlashWindow()
	end
end)
