local hg_furcity = ConVarExists("hg_furcity") and GetConVar("hg_furcity") or CreateConVar("hg_furcity", 0, bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_LUA_SERVER), "Toggle phrase furryfier :3", 0, 1)

hg.fur = {
	" rawr~",
	" mrrrph~~",
	" meow :3",
	" uwu",
	" >w<",
	" OwO",
	" ^w^",
	" *blushes*",
	" -w-",
	" ~w~",
	" mrrawr~~",
	" mrrp~",
	" mrreow~",
	" mwah~",
	"~",
	"~~"
}

local translateSymbol = {
	["r"] = "w",
	["R"] = "W",
	["l"] = "w",
	["L"] = "W",
	["з"] = "в",
	["З"] = "В",
	["ш"] = "ф",
	["Ш"] = "Ф",
	--["ч"] = "т",
	--["Ч"] = "Т",
	--["у"] = "ю",
	--["У"] = "Ю",
	--["т"] = "в",
	--["Т"] = "В",
}

local repeating = {
	["r"] = true,
	["R"] = true,
	["р"] = true,
	["Р"] = true,
}

// можно сделать чтобы оно просто брало стринг, текущее местоположение буквы и добавляло ещё сверху
//



function hg.FurrifyPhrase(msg)
	local iter = utf8.codes(msg)
	local len = 0
	local chars = {}

	for i, code in iter do
		len = len + 1
		chars[len] = utf8.char(code)
	end

	-- local lastpos = 0
	-- while lastpos != -1 do
	--     local newpos = string.find(msg, "[rR]", lastpos)

	-- end


	--i нельзя менять
	for i = #chars, 1, -1 do
		if repeating[chars[i]] and math.random(2) == 1 then
			for i2 = 1, math.random(3) do
				table.insert(chars, i, chars[i])
			end
		elseif translateSymbol[chars[i]] and math.random(2) == 1 then
			chars[i] = translateSymbol[chars[i]]
		end
	end--legendary

	msg = table.concat(chars)

	if math.random(4) == 1 then
		msg = msg..hg.fur[math.random(#hg.fur)]
	end

	return msg
end

if CLIENT then
	local hg_old_notificate = ConVarExists("hg_old_notificate") and GetConVar("hg_old_notificate") or CreateConVar("hg_old_notificate",0,{FCVAR_USERINFO,FCVAR_ARCHIVE},"Toggle old notifications (chatprints)",0,1)

	surface.CreateFont("BerserkFont", {
		font = "Who asks Satan",
		size = ScreenScale(25),
		extended = true,
		weight = 400,
		antialias = true,
	})

	surface.CreateFont("HuyFont", {
		font = "BudgetLabel",
		extended = true,
		size = ScreenScale(9),
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		strikeout = false,
		shadow = false,
		outline = false,
	})

	surface.CreateFont("SmallHuyFont", {
		font = "BudgetLabel",
		extended = true,
		size = ScreenScale(7),
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		strikeout = false,
		shadow = false,
		outline = false,
	})

	hg.notifications = hg.notifications or {}
	hg.notificationFont = "HuyFont"

	hook.Add("Player_Death","removeNotifications",function(ply)
		if ply != lply then return end

		//hg.currentNotification = nil
		hg.notifications = {}
	end)

	hook.Add("Player Spawn","removeNotificationsa",function(ply)
		if ply != lply then return end

		hg.currentNotification = nil
		hg.notifications = {}
	end)

	hook.Add("HG_OnOtrub","removeNotificationsb",function(ply)
		if ply != lply then return end

		//hg.currentNotification = nil
		hg.notifications = {}
	end)

	local defaultShowTimer = 3

	local function CreateNotification(msg, showTimer, clr)
		if hg_furcity:GetBool() or lply.PlayerClassName == "furry" then
			msg = hg.FurrifyPhrase(msg)
		end

		if lply:IsBerserk() then
			return
		end

		table.insert(hg.notifications, {msg, (showTimer or defaultShowTimer), clr or Color(255, 255, 255, 255)})
	end

	local function CreateNotificationBerserk(msg, showTimer, clr)
		if hg_furcity:GetBool() or lply.PlayerClassName == "furry" then
			msg = hg.FurrifyPhrase(msg) -- uhhhh... hate to break it to you but-
		end

		local tbl = hg.currentNotification

		local clr = tbl and tbl[4] and IsColor(tbl[4]) and tbl[4] or Color(255, 255, 255, 255)
		if tbl and clr and tbl[1] then
			chat.AddText(Color(clr.r, clr.g, clr.b, 255), (last_message or tbl[1]).."\n")
		end

		hg.currentNotification = nil
		hg.notifications = {}

		table.insert(hg.notifications, {msg, (showTimer or defaultShowTimer), clr or Color(255, 255, 255, 255)})
	end

	local PLAYER = FindMetaTable("Player")

	function PLAYER:Notify(...)
		return CreateNotification(...)
	end

	function PLAYER:NotifyBerserk(...)
		return CreateNotificationBerserk(...)
	end

	net.Receive("HGNotificate",function()
		local msg = net.ReadString()
		local clr = net.ReadColor()

		if msg == "" then return end

		CreateNotification(msg, showtime, clr)
	end)

	net.Receive("HGNotificateBerserk",function()
		local msg = net.ReadString()
		local clr = net.ReadColor()

		if msg == "" then return end

		CreateNotificationBerserk(msg, showtime, clr)
	end)

	hg.CreateNotification = CreateNotification
	hg.CreateNotificationBerserk = CreateNotificationBerserk
	local colred = Color(255,0,0)

	local time_spent = CurTime()
	local coloruse = Color(255,255,255,255)
	local function NotificationsThink()
		//if hg.currentNotification or #hg.notifications == 0 then return end
		if #hg.notifications == 0 then return end
		if hg.currentNotification then return end
		if !lply:Alive() then hg.notifications = {} return end
		if lply.organism and lply.organism.otrub then return end
		local tbl = hg.notifications[1]

		if tbl and istable(tbl) and not table.IsEmpty(tbl) then
			/*if hg.currentNotification then
				local tbl2 = hg.currentNotification

				local clr = tbl2 and tbl2[4] and IsColor(tbl2[4]) and tbl2[4] or Color(255, 255, 255, 255)
				if tbl2 and clr and tbl2[1] then
					chat.AddText(Color(coloruse.r, coloruse.g, coloruse.b, 255), (last_message or tbl2[1]).."\n")
				end

				hg.currentNotification = nil
			end*/

			hg.currentNotification = {tbl[1], time_spent, tbl[2], tbl[3]}

			table.remove(hg.notifications,1)
		end--показываем только одну нотификацию за раз (остальные держим в уме....)
	end

	local colBrown = Color(40,40,40)
	local ColorNotification = Color(48,4,4,0)
	local maxtimefade = 1
	local oldclick = 0

	sound.Add({
		name = "peepsnd",
		channel = CHAN_AUTO,
		volume = 0.5,
		level = 30,
		pitch = {150, 150},
		sound = "snd_jack_peep.wav"
	})

	local last_message
	local last_time

	local vector_one = Vector( 1, 1, 0)

	local bluewhite = Color(187, 187, 255)

	local function NotificationsDraw()
		time_spent = CurTime()
		lply = LocalPlayer()
		local org = lply.organism
		if not org or not org.pain or not org.brain then return end
		//if org.otrub and !last_message then return end

		//if hg_old_notificate:GetBool() then return end
		local tbl = hg.currentNotification

		if tbl and istable(tbl) and not table.IsEmpty(tbl) then
			local msg, time, timeshow, clr = tbl[1], tbl[2], tbl[3], tbl[4]

			local mul = ((org.brain > 0.1 or org.pulse < 50) and 3 or 1)// * (org.fear > 0 and math.max(1 - org.fear, 0.6) or 1)
			local time_one_symbol = 0.06 * mul//(lply.organism and lply.organism.fear >= 0.5 and 0.5 or 1)
			local time_to_read = (utf8.len(msg) * time_one_symbol)
			local wait = math.Clamp(time_to_read / 3 * math.Clamp(1 - #hg.notifications / 1, 0.25, 1), 1, 4) + timeshow

			if (time + time_to_read + wait > time_spent) then
				local part = math.min(1 - (time + time_to_read - time_spent) / time_to_read, 1)
				local part2 = (wait + math.min(time + time_to_read - time_spent, 0)) / wait

				local click = math.ceil(part * utf8.len(msg))

				if not last_message and utf8.len(msg) != click and utf8.sub(utf8.force(msg), click, click) == "." then
					tbl[2] = tbl[2] + FrameTime() / 1.5
				end

				if click != oldclick and not last_message then
					sound.Play("peepsnd", render.GetViewSetup().origin - vector_up * 10)
					//surface.PlaySound("peepsnd")
					oldclick = click
				end

				local txt = utf8.sub(utf8.force(msg), 1, click)

				coloruse.r = clr.r
				coloruse.g = math.min(math.Clamp(((90 - org.pain) / 90) * 255, 0, 255), clr.g)
				coloruse.b = math.min(math.Clamp(((90 - org.pain) / 90) * 255, 0, 255), clr.g)

				if (org.otrub or !lply:Alive()) then
					if not last_message then
						txt = utf8.sub(txt, utf8.len(txt), utf8.len(txt)) == utf8.force(" ") and utf8.sub(txt, 1, utf8.len(txt) - 1) or txt
						last_message = txt..(click != utf8.len(msg) and "-" or "")
						last_time = time_spent
						tbl[4] = Color(coloruse.r, coloruse.g, coloruse.b, 255)
					end
				else
					last_message = nil
					last_time = nil
				end

				local font = hg.notificationFont

				surface.SetFont(font)
				local txtw, txth = surface.GetTextSize(last_message or txt)

				local col = coloruse
				col.a = 255 * (last_time and (last_time + 2 - time_spent) or part2)
				colBrown.a = 255 * (last_time and (last_time + 2 - time_spent) or part2)

				if hg.underberserk2 then
					local scale = 1

					scale = (1 + ((hg.berserkIntensity or 0) / 4))

					local rand = org.berserk * 2 * (col.a / 255)

					local x, y = ScrW() / 2 + math.Rand(-rand, rand), ScrH() - ScrH() / 6 + math.Rand(-rand, rand)

					local m = Matrix()
					m:Translate( Vector( x, y, 0 ) )
					m:Scale( vector_one * ( scale or 3) )
					m:Translate( Vector( -txtw / 2, 0, 0 ) )

					col.r = col.r + math.min(1, hg.berserkIntensity) * 255
					col.g = col.g - math.min(1, hg.berserkIntensity) * 200
					col.b = col.b - math.min(1, hg.berserkIntensity) * 200

					render.PushFilterMag( TEXFILTER.ANISOTROPIC )

					cam.PushModelMatrix( m, true )
					DisableClipping(true)
						local col2
						for i = 1, 40 do // erm maybe 40 is too much? idk i don't care :3 :3 :3
							col2 = HSVToColor(350 + (math.sin(SysTime() + i / 50) * 10 * hg.berserkIntensity), 0.8, 0.9)
							local posX = -math.sin(RealTime() * 7) * i / 2 * hg.berserkIntensity
							local posY = -math.cos(RealTime() * 7) * i / 2 * hg.berserkIntensity
							draw.SimpleText(last_message or txt, font, posX, posY, ColorAlpha(col2, col.a - i * 5), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						end

						draw.GlowingText(last_message or txt, font, 0, 0, ColorAlpha(col2, col.a), ColorAlpha(col2, math.min(col.a, 50)), ColorAlpha(col2, math.min(col.a, 10)), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						-- draw.SimpleTextOutlined(last_message or txt, font, 0, 0, ColorAlpha(col, col.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, colBrown)
					DisableClipping(false)
					cam.PopModelMatrix()

					render.PopFilterMag()
				elseif lply.PlayerClassName == "furry" then
					local x, y = ScrW() / 2 - txtw / 2 + math.Rand(0, org.pain > 10 and org.pain / 10 or 0) + math.Rand(0, (255 - clr.g) / 255 * 2), ScrH() - ScrH() / 6 + math.Rand(0, org.pain > 10 and org.pain / 10 or 0) + math.Rand(0, (255 - clr.g) / 255 * 2)

					draw.SimpleText(last_message or txt, "ZB_ProotOSMedium", x + 2, y + 2, ColorAlpha(color_black, col.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(last_message or txt, "ZB_ProotOSMedium", x, y, ColorAlpha(bluewhite, col.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else
					local x, y = ScrW() / 2 - txtw / 2 + math.Rand(0, org.pain > 10 and org.pain / 10 or 0) + math.Rand(0, (255 - clr.g) / 255 * 2), ScrH() - ScrH() / 6 + math.Rand(0, org.pain > 10 and org.pain / 10 or 0) + math.Rand(0, (255 - clr.g) / 255 * 2)

					draw.SimpleTextOutlined(last_message or txt, font, x, y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1.5, colBrown)
				end
			else
				local tbl = hg.currentNotification

				local clr = tbl and tbl[4] and IsColor(tbl[4]) and tbl[4] or Color(255, 255, 255, 255)
				if tbl and clr and tbl[1] then
					//MsgC(Color(clr.r, clr.g, clr.b, 255), (last_message or tbl[1]).."\n")
					chat.AddText(Color(clr.r, clr.g, clr.b, 255), (last_message or tbl[1]).."\n")
				end

				last_message = nil
				last_time = nil

				hg.currentNotification = nil
			end
		end
	end

	hook.Add("DrawOverlay", "HGNotificationsThink", NotificationsDraw)
	hook.Add("Think", "HGNotificationsThink", NotificationsThink)
else
	concommand.Add("hg_notify", function(ply, cmd, args)
		if not ply:IsAdmin() then return end
		for i, ply in pairs(player.GetListByName(args[1])) do
			//(ply, msg, delay, msgKey, showTime, func, clr)
			ply:Notify(args[2], 6, nil, 0, nil, Color(args[3] or 255, args[4] or 255, args[5] or 255))
		end
	end)
end