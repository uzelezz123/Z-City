local MODE = MODE
MODE.name = "hmcd"

--\\Local Functions
local function screen_scale_2(num)
	return ScreenScale(num) / (ScrW() / ScrH())
end
--//

MODE.TypeSounds = {
	["standard"] = {"snd_jack_hmcd_psycho.mp3","snd_jack_hmcd_shining.mp3"},
	["soe"] = "snd_jack_hmcd_disaster.mp3",
	["gunfreezone"] = "snd_jack_hmcd_panic.mp3" ,
	["suicidelunatic"] = "zbattle/jihadmode.mp3",
	["wildwest"] = "snd_jack_hmcd_wildwest.mp3",
	["supermario"] = "snd_jack_hmcd_psycho.mp3"
}
local fade = 0
net.Receive("HMCD_RoundStart",function()
	for i, ply in player.Iterator() do
		ply.isTraitor = false
		ply.isGunner = false
	end

	--\\
	lply.isTraitor = net.ReadBool()
	lply.isGunner = net.ReadBool()
	MODE.Type = net.ReadString()
	local screen_time_is_default = net.ReadBool()
	lply.SubRole = net.ReadString()
	lply.MainTraitor = net.ReadBool()
	MODE.TraitorWord = net.ReadString()
	MODE.TraitorWordSecond = net.ReadString()
	MODE.TraitorExpectedAmt = net.ReadUInt(MODE.TraitorExpectedAmtBits)
	StartTime = CurTime()
	MODE.TraitorsLocal = {}

	if(lply.isTraitor and screen_time_is_default)then
		if(MODE.TraitorExpectedAmt == 1)then
			chat.AddText("You are alone on your mission.")
		else
			if(MODE.TraitorExpectedAmt == 2)then
				chat.AddText("You have 1 accomplice")
			else
				chat.AddText("There are(is) " .. MODE.TraitorExpectedAmt - 1 .. " traitor(s) besides you")
			end

			chat.AddText("Traitor secret words are: \"" .. MODE.TraitorWord .. "\" and \"" .. MODE.TraitorWordSecond .. "\".")
		end

		if(lply.MainTraitor)then
			if(MODE.TraitorExpectedAmt > 1)then
				chat.AddText("Traitor names (only you, as a main traitor can see them):")
			end

			for key = 1, MODE.TraitorExpectedAmt do
				local traitor_info = {net.ReadColor(false), net.ReadString()}

				if(MODE.TraitorExpectedAmt > 1)then
					MODE.TraitorsLocal[#MODE.TraitorsLocal + 1] = traitor_info

					chat.AddText(traitor_info[1], "\t" .. traitor_info[2])
				end
			end
		end
	end

	lply.Profession = net.ReadString()
	--//

	if(MODE.RoleChooseRoundTypes[MODE.Type] and !screen_time_is_default)then
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.RoleChooseRoundStartTime
	else
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.DefaultRoundStartTime
	end

	MODE.RoleEndedChosingState = screen_time_is_default

	if(screen_time_is_default)then
		if istable(MODE.TypeSounds[MODE.Type]) then
			surface.PlaySound(table.Random(MODE.TypeSounds[MODE.Type]))
		else
			surface.PlaySound(MODE.TypeSounds[MODE.Type])
		end
	end

	fade = 0
end)

MODE.TypeNames = {
	["standard"] = "Standard",
	["soe"] = "State of Emergency",
	["gunfreezone"] = "Gun Free Zone",
	["suicidelunatic"] = "Suicide Lunatic",
	["wildwest"] = "Wild west",
	["supermario"] = "Super Mario"
}

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "Change UI text font")
local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZB_HomicideSmall", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMedium", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMediumLarge", {
	font = font(),
	size = ScreenScale(25),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideLarge", {
	font = font(),
	size = ScreenScale(30),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideHumongous", {
	font = font(),
	size = 255,
	weight = 400,
	antialias = true
})

MODE.TypeObjectives = {}
MODE.TypeObjectives.soe = {
	traitor = {
		objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		name = "a Traitor",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You are an innocent with a hunting weapon. Find and neutralize the traitor before it's too late.",
		name = "an Innocent",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "You are an innocent, rely only on yourself, but stick around with crowds to make traitor's job harder.",
		name = "an Innocent",
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.standard = {
	traitor = {
		objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		name = "a Murderer",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You are a bystander with a concealed firearm. You've tasked yourself to help police find the criminal faster.",
		name = "a Bystander",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
		name = "a Bystander",
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.wildwest = {
	traitor = {
		objective = "This town ain't that big for all of us.",
		name = "The Killer",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You're the sheriff of this town. You gotta find and kill the lawless bastard.",
		name = "The Sheriff",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "We gotta get justice served over here, there's a lawless prick murdering men.",
		name = "a Fellow Cowboy",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},
}

MODE.TypeObjectives.gunfreezone = {
	traitor = {
		objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		name = "a Murderer",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
		name = "a Bystander",
		color1 = Color(0,120,190)
	},

	innocent = {
		objective = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
		name = "a Bystander",
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.suicidelunatic = {
	traitor = {
		objective = "My brother insha'Allah, don't let him down.",
		name = "a Shahid",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "Sheep fucker's gone crazy, now you need to survive.",
		name = "an Innocent",
		color1 = Color(0,120,190)
	},

	innocent = {
		objective = "Sheep fucker's gone crazy, now you need to survive.",
		name = "an Innocent",
		color1 = Color(0,120,190)
	},
}


MODE.TypeObjectives.supermario = {
	traitor = {
		objective = "You're the evil Mario! Jump around and take down everyone.",
		name = "Traitor Mario",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You're the hero Mario! Use your jumping ability to stop the traitor.",
		name = "Hero Mario",
		color1 = Color(158,0,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "You're a bystander Mario, survive and avoid the traitor's traps!",
		name = "Innocent Mario",
		color1 = Color(0,120,190)
	},
}

function MODE:RenderScreenspaceEffects()
	-- MODE.DynamicFadeScreenEndTime = MODE.DynamicFadeScreenEndTime or 0
	fade_end_time = MODE.DynamicFadeScreenEndTime or 0
	local time_diff = fade_end_time - CurTime()

	if(time_diff > 0)then
		zb.RemoveFade()

		local fade = math.min(time_diff / MODE.FadeScreenTime, 1)

		surface.SetDrawColor(0, 0, 0, 255 * fade)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end
end

local handicap = {
	[1] = "You are handicapped: your right leg is broken.",
	[2] = "You are handicapped: you are suffering from severe obesity.",
	[3] = "You are handicapped: you are suffering from hemophilia.",
	[4] = "You are handicapped: you are physically incapacitated."
}

function MODE:HUDPaint()
	if not MODE.Type or not MODE.TypeObjectives[MODE.Type] then return end
	if lply:Team() == TEAM_SPECTATOR then return end
	if StartTime + 12 < CurTime() then return end
	
	fade = Lerp(FrameTime()*1, fade, math.Clamp(StartTime + 5 - CurTime(),-2,2))

	draw.SimpleText("Homicide | " .. (MODE.TypeNames[MODE.Type] or "Unknown"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local Rolename = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.name ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.name ) or MODE.TypeObjectives[MODE.Type].innocent.name
	local ColorRole = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color1 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color1 ) or MODE.TypeObjectives[MODE.Type].innocent.color1
	ColorRole.a = 255 * fade

	local color_role_innocent = MODE.TypeObjectives[MODE.Type].innocent.color1
	color_role_innocent.a = 255 * fade

	local color_white_faded = Color(255, 255, 255, 255 * fade)
	color_white_faded.a = 255 * fade

	draw.SimpleText("You are "..Rolename , "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)



	local cur_y = sh * 0.5

	-- local ColorRole = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color1 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color1 ) or MODE.TypeObjectives[MODE.Type].innocent.color1
	-- ColorRole.a = 255 * fade
	if(lply.SubRole and lply.SubRole != "")then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("" .. ((MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Name or lply.SubRole) or lply.SubRole), "ZB_HomicideMediumLarge", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("Assistant", "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end


	if(lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		if(lply.MainTraitor)then
			MODE.TraitorsLocal = MODE.TraitorsLocal or {}

			if(#MODE.TraitorsLocal > 1)then
				draw.SimpleText("Traitors list:", "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				for _, traitor_info in ipairs(MODE.TraitorsLocal) do
					local traitor_color = Color(traitor_info[1].r, traitor_info[1].g, traitor_info[1].b, 255 * fade)
					cur_y = cur_y + ScreenScale(15)

					draw.SimpleText(traitor_info[2], "ZB_HomicideMedium", sw * 0.5, cur_y, traitor_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		else
			draw.SimpleText("Traitor secret words:", "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWord .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWordSecond .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	if(lply.Profession and lply.Profession != "")then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("Occupation: " .. ((MODE.Professions[lply.Profession] and MODE.Professions[lply.Profession].Name or lply.Profession) or lply.Profession), "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	if(handicap[lply:GetLocalVar("karma_sickness", 0)])then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText(handicap[lply:GetLocalVar("karma_sickness", 0)], "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local Objective = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.objective ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.objective ) or MODE.TypeObjectives[MODE.Type].innocent.objective

	if(lply.SubRole and lply.SubRole != "")then
		if(MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Objective)then
			Objective = MODE.SubRoles[lply.SubRole].Objective
		end
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		Objective = "You are equipped with nothing. Help other traitors win."
	end

	--; WARNING Traitor's objective is not lined up with SubRole's
	if(!MODE.RoleEndedChosingState)then
		Objective = "Round is starting..."
	end

	local ColorObj = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color2 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color2 ) or MODE.TypeObjectives[MODE.Type].innocent.color2 or Color(255,255,255)
	ColorObj.a = 255 * fade
	draw.SimpleText( Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local CreateEndMenu

net.Receive("hmcd_roundend", function()
	local traitors, gunners = {}, {}

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local traitor = net.ReadEntity()
		traitors[key] = traitor
		traitor.isTraitor = true
	end

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local gunner = net.ReadEntity()
		gunners[key] = gunner
		gunner.isGunner = true
	end

	timer.Simple(2.5, function()


		lply.isPolice = false
		lply.isTraitor = false
		lply.isGunner = false
		lply.MainTraitor = false
		lply.SubRole = nil
		lply.Profession = nil
	end)

	traitor = traitors[1] or Entity(0)

	CreateEndMenu(traitor)
end)

net.Receive("hmcd_announce_traitor_lose", function()
	local traitor = net.ReadEntity()
	local traitor_alive = net.ReadBool()

	if(IsValid(traitor))then
		chat.AddText(color_white, "Traitor ", traitor:GetPlayerColor():ToColor(), traitor:GetPlayerName() .. ", " .. traitor:Nick(), color_white, " was " .. (traitor_alive and "arrested." or "killed."))
	end
end)

local colGray = Color(85,85,85)
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

CreateEndMenu = function(traitor)
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end

	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

	if !IsValid(hmcdEndMenu) then return end

	local players = {}

	local traitorName = IsValid(traitor) and traitor:GetPlayerName() or "unknown"
	local traitorNick = IsValid(traitor) and traitor:Nick() or "unknown"

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if !IsValid(ply) then return end
		
		players[#players + 1] = {
			nick = ply:Nick(),
			name = ply:GetPlayerName(),
			isTraitor = ply.isTraitor,
			isGunner = ply.isGunner,
			incapacitated = ply.organism and ply.organism.otrub,
			alive = ply:Alive(),
			col = ply:GetPlayerColor():ToColor(),
			frags = ply:Frags(),
			steamid = ply:IsBot() and "BOT" or ply:SteamID64(),
		}
	end

	surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5, ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2, ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX, posY)
	hmcdEndMenu:SetSize(sizeX, sizeY)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton", hmcdEndMenu)
	closebutton:SetPos(5, 5)
	closebutton:SetSize(ScrW() / 20, ScrH() / 30)
	closebutton:SetText("")

	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor(122, 122, 122, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		surface.SetFont("ZB_InterfaceMedium")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos(lengthX - lengthX / 1.1, 4)
		surface.DrawText("Close")
	end

	hmcdEndMenu.PaintOver = function(self,w,h)
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize(traitorName .. " was a traitor ("..traitorNick..")")
		surface.SetTextPos(w / 2 - lengthX / 2, 20)
		surface.DrawText(traitorName .. " was a traitor ("..traitorNick..")")
	end

	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i, info in ipairs(players) do
		local but = vgui.Create("DButton",DScrollPanel)

		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")

		but.Paint = function(self,w,h)
			local col1 = (info.isTraitor and colRed) or (info.alive and colBlue) or colGray
			local col2 = info.isTraitor and (info.alive and colRedUp or colSpect1) or ((info.alive and !info.incapacitated) and colBlueUp) or colSpect1
			local name = info.nick
			surface.SetDrawColor(col1.r, col1.g, col1.b, col1.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(col2.r, col2.g, col2.b, col2.a)
			surface.DrawRect(0, h / 2, w, h / 2)

			local col = info.col
			surface.SetFont("ZB_InterfaceMediumLarge")
			local lengthX, lengthY = surface.GetTextSize(name)

			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(w / 2 + 1, h / 2 - lengthY / 2 + 1)
			surface.DrawText(name)

			surface.SetTextColor(col.r, col.g, col.b, col.a)
			surface.SetTextPos(w / 2, h / 2 - lengthY / 2)
			surface.DrawText(name)


			local col = colSpect2
			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize(info.name)
			surface.SetTextPos(15, h / 2 - lengthY / 2)
			surface.DrawText(info.name .. ((!info.alive and " - died") or (info.incapacitated and " - incapacitated") or ""))

			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r, col.g, col.b, col.a)
			local lengthX, lengthY = surface.GetTextSize(info.frags)
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(info.frags)
		end

		function but:DoClick()
			if info.steamid == "BOT" then chat.AddText(Color(255, 0, 0), "That's a bot.") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..info.steamid)
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
	-- if IsValid(hmcdEndMenu) then
	-- 	hmcdEndMenu:Remove()
	-- 	hmcdEndMenu = nil
	-- end
end

--\\
net.Receive("HMCD(StartPlayersRoleSelection)", function()
	local role = net.ReadString()

	hg.SelectPlayerRole(role)
end)

function hg.SelectPlayerRole(role, mode)
	role = role or "Traitor"
	mode = mode or "soe"

	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end

	if(MODE.RoleChooseRoundTypes[mode])then
		//VGUI_HMCD_RolePanelList = vgui.Create("ZB_TraitorSelectionMenu")
		//VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList = vgui.Create("HMCD_RolePanelList")
		VGUI_HMCD_RolePanelList.RolesIDsList = MODE.RoleChooseRoundTypes[mode][role]	--; WARNING TCP Reroute
		VGUI_HMCD_RolePanelList.Mode = mode
		-- VGUI_HMCD_RolePanelList:SetSize(ScreenScale(600), ScreenScale(300))
		VGUI_HMCD_RolePanelList:SetSize(screen_scale_2(700), screen_scale_2(300))
		VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList:InvalidateParent(false)
		VGUI_HMCD_RolePanelList:Construct()
		VGUI_HMCD_RolePanelList:MakePopup()
	end
end

net.Receive("HMCD(EndPlayersRoleSelection)", function()
	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end
end)

net.Receive("HMCD(SetSubRole)", function(len, ply)
	lply.SubRole = net.ReadString()
end)
--//

--CreateEndMenu()