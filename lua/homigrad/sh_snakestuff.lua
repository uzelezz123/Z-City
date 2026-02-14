
local zmeyka_netsendtime = 0.05

if CLIENT then
	function draw.Circle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is needed for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end

	local function LerpColor(lerp, source, set)
		return Lerp(lerp, source.r, set.r), Lerp(lerp, source.g, set.g), Lerp(lerp, source.b, set.b)
	end

	local math_AngleDifference = math.AngleDifference

	local function calculate_anchoredpos(pos1,pos2,len,prevang,delenie)
		local length = len / delenie
		
		local anchored_point = pos2-pos1
		
		local angle = anchored_point:Angle()
		local diff = math_AngleDifference(angle[2],prevang)
		
		if math.abs(diff) > 30 then
			angle[2] = math.ApproachAngle(angle[2],prevang,FrameTime() * 500)
		end
		return pos1 + angle:Forward() * length,angle
		--return pos1 + anchored_point:GetNormalized() * length
	end

	local snakes = {}
	local snakes_poses = {}
	local old_snakesposes = {}

	local function clearSnakes()
		snakes = {}
	end

	local function addSnake(index,bodyfunc,numsegments,detail,gravity,followvec,color1,color2,leading_part)
		leading_part = leading_part or 1
		local max = numsegments * detail
		local segments = {}

		local color1 = color1 or Color(math.random(255),math.random(255),math.random(255))
		local color2 = color2 or Color(math.random(255),math.random(255),math.random(255))

		for i = 1,max do
			table.insert(segments,bodyfunc(i,max))
		end

		snakes[index] = {
			segments,
			detail,
			gravity,
			followvec,
			color1,
			color2,
			leading_part
		}

		return index
	end

	local time_send = 0
	local len = 30
	local segments = {}
	local gravity = 0
	local delenie = 6
	local max = 8 * delenie

	local math_cos,math_sin,FrameTime,math_Clamp = math.cos,math.sin,FrameTime,math.Clamp

	local vecUp = Vector(0,1)
	local pos = Vector(0,0)

	local color = Color(0,0,0)
	local color2 = Color(0,0,0)

	local cursor

	local zmeyka_legs = ConVarExists("zmeyka_legs") and GetConVar("zmeyka_legs") or CreateClientConVar("zmeyka_legs",0,true,true,"Toggle UI snake/worm legs",0,1)

	local zmeyka_lmao = function()
		cursor = Vector(input.GetCursorPos())
		
		for k in pairs(snakes) do
			local poses_right = {}
			local poses_left = {}
			local snake = snakes[k]
			local pos = snake[4]
			local segments = snake[1]
			delenie = snake[2]
			gravity = snake[3]
			pos = isfunction(snake[4]) and snake[4]() or snake[4]
			color = snake[5] or color
			color2 = snake[6] or color
			local leading_part = snake[7]

			segments[leading_part][4] = zmeyka_legs:GetBool() and (pos:IsEqualTol(segments[leading_part][1],20) and vector_origin or (pos - segments[leading_part][1]):GetNormalized() * FrameTime() * 500) or (pos - segments[leading_part][1]) * FrameTime() * 25
			segments[leading_part][3] = segments[leading_part][4]:Angle()[2]
			local iters = leading_part > 1 and leading_part < #segments and 2 or 2
			local iter1 = {leading_part,#segments,1}
			local iter2 = {leading_part,1,-1}

			for j = 1,iters do
				if j == 1 then
					for i = iter1[1],iter1[2],iter1[3] do
						local pos = segments[i][1]
						local len = segments[i][2]
						local prevseg = segments[math_Clamp(i > leading_part and i-1 or i+1,1,#segments)]
						local pos2 = prevseg[1]
						local len2 = prevseg[2]

						local pos2_new,angle_new
						
						if i == leading_part then
							pos2_new = segments[i][1]
							angle_new = prevseg[3]
						else
							pos2_new,angle_new = calculate_anchoredpos(pos2,pos+segments[i][4],len+len2-1,prevseg[3],delenie)
							angle_new = angle_new[2]
						end
						
						local vel = (pos2_new - segments[i][1]) * FrameTime() * 25
						
						segments[i][1] = pos2_new + (i == leading_part and segments[i][4] or vector_origin)
						segments[i][3] = angle_new
						segments[i][4] = gravity and Lerp(0.1,segments[i][4] or vector_origin,vecUp * gravity + vel) or vector_origin--Vector(0,FrameTime() * 100)--Lerp(FrameTime() * 10,(segments[i][4] or Vector(0,0)) + vel,vector_origin)

						local angle = math.rad(segments[i][3])
						
						x1,y1 = math_cos(angle + math.pi / 2),math_sin(angle + math.pi / 2)
						x2,y2 = math_cos(angle - math.pi / 2),math_sin(angle - math.pi / 2)

						local pos = segments[i][1]
						
						poses_right[i] = {x = pos[1] + x1 * len,y = pos[2] + y1 * len,u = 0.5,v = 0.5}
						poses_left[i] = {x = pos[1] + x2 * len,y = pos[2] + y2 * len,u = 0.5,v = 0.5}
					end
				else
					for i = iter2[1],iter2[2],iter2[3] do
						
						local pos = segments[i][1]
						local len = segments[i][2]
						
						local prevseg = segments[math_Clamp(i >= leading_part and i-1 or i+1,1,#segments)]
						local pos2 = prevseg[1]
						local len2 = prevseg[2]

						local pos2_new,angle_new
						
						if i == leading_part then
							pos2_new = segments[i][1]
							angle_new = prevseg[3]
						else
							pos2_new,angle_new = calculate_anchoredpos(pos2,pos+segments[i][4],len+len2-1,prevseg[3],delenie)
							angle_new = angle_new[2]
						end
						
						local vel = (pos2_new - segments[i][1]) * FrameTime() * 25
						
						segments[i][1] = pos2_new + (i == leading_part and segments[i][4] or vector_origin)
						segments[i][3] = angle_new
						segments[i][4] = gravity and Lerp(0.1,segments[i][4] or vector_origin,vecUp * gravity + vel) or vector_origin--Vector(0,FrameTime() * 100)--Lerp(FrameTime() * 10,(segments[i][4] or Vector(0,0)) + vel,vector_origin)

						local angle = math.rad(segments[i][3])
						
						x1,y1 = math_cos(angle + math.pi / 2),math_sin(angle + math.pi / 2)
						x2,y2 = math_cos(angle - math.pi / 2),math_sin(angle - math.pi / 2)

						local pos = segments[i][1]
						
						poses_right[i] = {x = pos[1] + x1 * len,y = pos[2] + y1 * len,u = 0.5,v = 0.5}
						poses_left[i] = {x = pos[1] + x2 * len,y = pos[2] + y2 * len,u = 0.5,v = 0.5}
					end
				end
			end
			
			if (time_send or 0) < CurTime() and k == lply:UserID() then
				time_send = CurTime() + zmeyka_netsendtime
				
				net.Start("zmeyka_net")
				net.WriteVector(segments[leading_part][1])
				net.WriteFloat(segments[leading_part][3])
				--net.WriteVector(segments[#segments][1])
				net.SendToServer()
			end

			for i = #segments,1,-1 do--govno debila
				local r,g,b,a = LerpColor(i / #poses_right,color,color2)
				surface.SetDrawColor(r,g,b,a)
				hg.drawPart(segments[i],r,g,b,a)
				if poses_right[i] then
					local poly = {
						poses_left[i+1],
						poses_right[i],
						poses_left[i],
						poses_right[i+1],
					}
					local poly2 = {
						poses_right[i+1],
						poses_left[i],
						poses_right[i],
						poses_left[i+1],
					}
				
					surface.DrawPoly( poly )
					surface.DrawPoly( poly2 )
				end
				
				draw.NoTexture()
				surface.SetDrawColor(r,g,b,a)
				draw.Circle(segments[i][1][1],segments[i][1][2],segments[i][2],16)
			end

			if snakes_poses[k] and lply:UserID() ~= k then
				--local lerp = 1 - ((snakes_poses[k][4] or CurTime()) - CurTime()) * 10
				
				old_snakesposes[k][1] = Lerp(0.1,old_snakesposes[k][1],snakes_poses[k][1])
				old_snakesposes[k][2] = Lerp(0.1,old_snakesposes[k][2],snakes_poses[k][2])
				--old_snakesposes[k][3] = Lerp(0.01,old_snakesposes[k][3],snakes_poses[k][3])
				segments[leading_part][1] = old_snakesposes[k][1]
				segments[leading_part][3] = old_snakesposes[k][2]
				--segments[#segments][1] = old_snakesposes[k][3]

				local txt = Player(k):Name()
				surface.SetFont("HomigradFont")
				local w,h = surface.GetTextSize(txt)
				--local rad = math.rad(segments[leading_part][3])
				--local x,y = math.sin(rad),math.cos(rad)
				surface.SetTextPos(segments[leading_part][1][1]-w/2,segments[leading_part][1][2]-h/2-ScreenScale(5))
				surface.DrawText(txt)
			end

			if not snakes_poses[k] and lply:UserID() ~= k then
				snakes[k] = nil
				continue
			end
		end
	end

	local zmeyka = GetConVar("zmeyka") or CreateClientConVar("zmeyka",1,true,false,"Toggle snake/worm that appears in emote menu",0,1)

	local funcs = {
		[1] = function(float) return math.ease.OutCirc(float) end,
		[2] = function(float) return math.acos(float) end,
		[3] = function(float) return math.ease.OutElastic(float) end,
		[4] = function(float) return math.ease.InOutQuad(float) end,
		[5] = function(float) return 1 end,
	}

	local zmeyka_size = ConVarExists("zmeyka_size") and GetConVar("zmeyka_size") or CreateClientConVar("zmeyka_size",30,true,true,"Modify size of UI snake/worm",10,50)
	local zmeyka_gravity = ConVarExists("zmeyka_gravity") and GetConVar("zmeyka_gravity") or CreateClientConVar("zmeyka_gravity",0,true,true,"Modify gravity of UI snake/worm",0,30)
	local zmeyka_func = ConVarExists("zmeyka_func") and GetConVar("zmeyka_func") or CreateClientConVar("zmeyka_func",3,true,true,"Change UI snake/worm appearance",1,5)

	local function startZmeyka(i)
		local color1 = Color(math.random(255),math.random(255),math.random(255))
		local color2 = Color(math.random(255),math.random(255),math.random(255))
		
		local len = zmeyka_size:GetFloat()
		
		local func = funcs[zmeyka_func:GetInt()]

		--clearSnakes()

		local num = (math.random(8) + 8)
		local detail = 4

		addSnake(i,function(i,max) return {Vector(0,0),len * func(i / max),0,Vector(0,0)} end,num,detail,zmeyka_gravity:GetBool() and zmeyka_gravity:GetFloat(),function() return i ~= lply:UserID() and old_snakesposes[i] and old_snakesposes[i][1] or cursor end,color1,color2,1)--math.floor(num * detail))
		--addSnake(0,function(i,max) return {Vector(0,0),len * func(i / max),0,Vector(0,0)} end,num,detail,zmeyka_gravity:GetBool() and zmeyka_gravity:GetFloat(),function() return old_snakesposes[i] and old_snakesposes[i][1] or cursor end,color1,color2,1)--math.floor(num * detail))
		
		--[[if math.random(5) == 1 then
			local func = funcs[math.random(#funcs)]
			local len = math.Rand(30,40)
			local vec = Vector(0,0)
			addSnake(function(i,max) return {Vector(0,0),len * func(i / max),0,Vector(0,0)} end,8,4,false,function() vec[1] = ((math.cos(CurTime()) / 6 + math.sin(CurTime() * 2) / 6 + math.cos(CurTime() / 3) / 6) + 1) / 2 * ScrW() vec[2] = ((math.sin(CurTime()) / 6 + math.cos(CurTime() * 4) / 6 + math.cos(CurTime() / 4) / 6) + 1) / 2 * ScrH() return vec end,nil,nil)
			
			local func = funcs[math.random(#funcs)]
			local len = math.Rand(30,40)
			local vec = Vector(0,0)
			addSnake(function(i,max) return {Vector(0,0),len * func(i / max),0,Vector(0,0)} end,8,4,false,function() vec[1] = ((math.cos(CurTime() / 2) / 6 + math.sin(CurTime() * 4) / 6 + math.cos(CurTime() / 6) / 6) + 1) / 2 * ScrW() vec[2] = ((math.sin(CurTime() * 3) / 6 + math.cos(CurTime() / 2) / 6 + math.cos(CurTime() / 3) / 6) + 1) / 2 * ScrH() return vec end,nil,nil)
			
			local func = funcs[math.random(#funcs)]
			local len = math.Rand(30,40)
			local vec = Vector(0,0)
			addSnake(function(i,max) return {Vector(0,0),len * func(i / max),0,Vector(0,0)} end,8,4,false,function() vec[1] = ((math.cos(CurTime() * 2) / 6 + math.sin(CurTime() * 1) / 6 + math.cos(CurTime() / 4) / 6) + 1) / 2 * ScrW() vec[2] = ((math.sin(CurTime() / 2) / 6 + math.cos(CurTime() * 1) / 6 + math.cos(CurTime() / 1) / 6) + 1) / 2 * ScrH() return vec end,nil,nil)
		end--]]

		hook.Add("HUDPaint","debildebilich",zmeyka_lmao)

		if zmeyka_legs:GetBool() then hg.start_snake() end
	end

	hook.Add("ContextMenuOpen","zmeyka_test",function()
		if not zmeyka:GetBool() then return end

		--startZmeyka(lply:UserID())
	end)

	hook.Add("ContextMenuClosed","zmeyka_test",function()
		--hook.Remove("HUDPaint","debildebilich",zmeyka_lmao)
	end)

	hook.Add("radialOptions","zmeyka_test",function()
		if not zmeyka:GetBool() then return end

		if not snakes[lply:UserID()] then startZmeyka(lply:UserID()) end
	end)

	hook.Add("RadialMenuPressed","zmeyka_test",function()
		snakes = {}
		hook.Remove("HUDPaint","debildebilich",zmeyka_lmao)
	end)

	local modes = {}

	modes.slider = function(optiondata, panel)
		local DermaNumSlider = vgui.Create( "DNumSlider", panel )
		DermaNumSlider:Dock( TOP )
		DermaNumSlider:DockMargin(10,5,5,2.5)	
		DermaNumSlider:SetSize(50,45)	
		DermaNumSlider:SetText( optiondata.convar .. "\n" .. optiondata.desc )	
		DermaNumSlider:SetMin( optiondata.min )				 	
		DermaNumSlider:SetMax( optiondata.max )				
		DermaNumSlider:SetDecimals( optiondata.decimals or 0 )				
		DermaNumSlider:SetConVar( optiondata.convar )	
		DermaNumSlider:SizeToContents()
	end

	modes.switcher = function(optiondata, panel)
		local DermaCheckbox = panel:Add( "DCheckBoxLabel" )
		DermaCheckbox:Dock( TOP )
		DermaCheckbox:DockMargin(10,5,10,2.5)
		DermaCheckbox:SetText( optiondata.convar .. "\n" .. optiondata.desc )
		DermaCheckbox:SetConVar( optiondata.convar )
		DermaCheckbox:SetValue( GetConVar(optiondata.convar):GetBool() )
		DermaCheckbox:SizeToContents()		
	end

	modes.binder = function(optiondata, panel)
	end

	local settings = {}

	local function AddOptionPanel( convarname, mode, optiondata, category )
		optiondata = optiondata or {}
		category = category or "other"
		optiondata.convar = convarname

		settings[category] = settings[category] or {}

		settings[category][convarname] = {mode, optiondata}
	end

	AddOptionPanel( "zmeyka_size", "slider", {desc = "base size",min = 10, max = 50}, "general" )
	AddOptionPanel( "zmeyka_gravity", "slider", {desc = "gravity",min = 0, max = 30}, "general" )
	AddOptionPanel( "zmeyka_func", "slider", {desc = "func",min = 1, max = 5}, "general" )
	AddOptionPanel( "zmeyka_legs", "switcher", {desc = "func"}, "general" )
	
	local red = Color(75,25,25)
	local redselected = Color(150,0,0)

	local blurMat = Material("pp/blurscreen")
	local Dynamic = 0
	BlurBackground = BlurBackground or hg.DrawBlur

	local function CreateOptionsMenu()
		local sizeX,sizeY = ScrW() / 3.2 ,ScrH() / 2.2
		local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2

		local MainFrame = vgui.Create("ZFrame") -- The name of the panel we don't have to parent it.
		MainFrame:SetPos( posX, posY ) -- Set the position to 100x by 100y. 
		MainFrame:SetSize( sizeX, sizeY ) -- Set the size to 300x by 200y.
		MainFrame:SetTitle( "zmeyka settings" ) -- Set the title in the top left to "Derma Frame".
		MainFrame:MakePopup() -- Makes your mouse be able to move around.
		//function MainFrame:Paint( w, h )
		//	draw.RoundedBox( 0, 2.5, 2.5, w-5, h-5, Color( 0, 0, 0, 140) )
		//	BlurBackground(MainFrame)
		//	surface.SetDrawColor( 255, 0, 0, 128)
		//	surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		//end

		local DScrollPanel = vgui.Create("DScrollPanel", MainFrame)
		DScrollPanel:SetPos(10, 50)
		DScrollPanel:SetSize(sizeX - 20, sizeY - 60)
		function DScrollPanel:Paint( w, h )
			BlurBackground(self)

			surface.SetDrawColor( 255, 0, 0, 128)
			surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		end
		
		local DLabel = vgui.Create( "DLabel", DScrollPanel )
		DLabel:Dock(TOP)
		DLabel:DockMargin(20,15,5,2.5)
		DLabel:SetText( "General" )

		for k,v in pairs(settings["general"]) do
		
			modes[v[1]](v[2],DScrollPanel)
		end
	end

	concommand.Add("zmeyka_settings",function()
		CreateOptionsMenu()
	end)

	net.Receive("zmeyka_net",function()
		snakes_poses = net.ReadTable()
		
		for i,snake in pairs(snakes_poses) do
			if not old_snakesposes[i] then old_snakesposes[i] = snake end
			snake[4] = CurTime() + zmeyka_netsendtime
			if Player(i) ~= lply and not snakes[i] then
				startZmeyka(i)
			end
		end
	end)

	local Segments = {}
	
	local function calculate_anchoredpos2(anchor_pos,lead_pos,length,previous_angle)		
		local anchored_point = lead_pos-anchor_pos
		
		local angle = anchored_point:Angle()
		local diff = math.AngleDifference(angle[2],previous_angle[2])
		
		--[[if math.abs(diff) > 30 then
			angle[2] = math.ApproachAngle(angle[2],previous_angle[2],FrameTime() * 500)
		end--]]

		return anchor_pos + angle:Forward() * length,angle
	end

	local function render_segments()
	end

	local function think_segments()
	end

	local function CreateSegment(child,think,drawfunc,spawnfunc)
		local Segment = {}
		Segment.Pos = Vector(0,0,0)
		Segment.Ang = Angle(0,0,0)
		Segment.Length = 50
		Segment.Size = 5
		Segment.Child = child
		Segment.Vel = Vector(0,0,0)
		Segment.Think = think
		Segment.Draw = drawfunc
		Segment.index = table.insert(Segments,Segment)
		if Segments[Segment.Child] then Segments[Segment.Child].Parent = Segment.index end
		if isfunction(spawnfunc) then spawnfunc() end

		local oldthink = think_segments
		think_segments = function()
			oldthink()
			Segment.Think(Segment)
		end

		local oldrender = render_segments
		render_segments = function()
			oldrender()
			Segment.Draw(Segment)
		end

		return Segment,Segment.index
	end

	local function segment_think(self)
		self.Pos = self.Pos + self.Vel * 0.8

		local child = Segments[self.Child]
		if child then
			local oldpos = -(-self.Pos)
			self.Pos = calculate_anchoredpos2(child.Pos,self.Pos,child.Length,child.Ang)
			local child_pos,child_angle = calculate_anchoredpos2(self.Pos,child.Pos,self.Length,self.Ang)	
			child.Pos = child_pos
			child.Ang = child_angle
			child.Vel = oldpos - self.Pos
		end

		--[[local parent = Segments[self.Parent]
		if parent then
			local parent_pos,parent_angle = calculate_anchoredpos2(self.Pos,parent.Pos,self.Length,self.Ang)	
			parent.Pos = parent_pos
			parent.Ang = parent_angle
		end--]]
	end

	local function segment_draw(self,r,g,b,a)
		draw.NoTexture()
		surface.SetDrawColor(r or 255,g or 255,b or 255,a or 255)
		local pos = self.Pos
		local len = self.Size
		
		draw.Circle(pos[1],pos[2],len,16)
		local child = Segments[self.Child]
		if child then
			local angle = math.rad(child.Ang[2])
			local x1,y1 = math.cos(angle+math.pi/2),math.sin(angle+math.pi/2)
			local poly = {}
			local tbl = {x = pos[1] + x1 * len,y = pos[2] + y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			local tbl = {x = pos[1] - x1 * len,y = pos[2] - y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			local pos = child.Pos
			local tbl = {x = pos[1] - x1 * len,y = pos[2] - y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			local tbl = {x = pos[1] + x1 * len,y = pos[2] + y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			surface.DrawPoly(poly)
		end
	end

	hg.drawPart = function(segment,r,g,b,a)
		local leg = Segments[segment.leg1]
		
		if leg then
			segment_draw(leg,r,g,b,a)
			local leg = Segments[Segments[segment.leg1].Child]
			if leg then
				segment_draw(leg,r,g,b,a)
			end
		end

		local leg = Segments[segment.leg2]
		
		if leg then
			segment_draw(leg,r,g,b,a)
			local leg = Segments[Segments[segment.leg2].Child]
			if leg then
				segment_draw(leg,r,g,b,a)
			end
		end
	end

	local function start_snake()
		render_segments = function() end
		think_segments = function() end
		Segments = {}
		local snake = snakes[lply:UserID()]
		if not snake then return end
		local segments = snake[1]
		for j = 1,#segments,5 do
			local prevseg,segment
			local last = 3
			for i = 1,last do
				segment,prevseg = CreateSegment(prevseg,segment_think,segment_draw)
				segment.part = j
				if i == last then
					segment.Think = function(segment)
						local angle = math.rad(segments[j][3])
						local x1,y1 = math.cos(angle+math.pi/1.4),math.sin(angle+math.pi/1.4)
						local lastpos = segments[j][1]
						local x,y = lastpos[1],lastpos[2]
						local huypos = Vector(x + x1 * 100,y + y1 * 100)
						segments[j].lastpos = segments[j].lastpos or huypos
						if (segments[j].lastpos:DistToSqr(huypos) >= 90*90) and ((segments[j].laststep or 0) < CurTime()) then
							segments[j].lastpos = huypos
							segments[j].laststep = CurTime() + math.Rand(0,0.2)
						end
						segment.Vel = segments[j].lastpos - segment.Pos
						segments[j].leg1 = segment.index
						segment_think(segment)
					end
				end
				if i == 1 then
					segment.Think = function(segment)
						local segments = snake[1]
						local lastpos = segments[j][1]
						local x,y = lastpos[1],lastpos[2]
						segment.Pos[1] = x
						segment.Pos[2] = y 
					end
				end
				segment.Draw = function(segment)
					if not segment.part or not segments[segment.part] or not snakes[lply:UserID()] then return end
					--segment_draw(segment,LerpColor(segment.part / #segments,snake[5],snake[6]))
				end
			end
		end
		for j = 1,#segments,5 do
			local prevseg,segment
			local last = 3
			for i = 1,last do
				segment,prevseg = CreateSegment(prevseg,segment_think,segment_draw)
				segment.part = j
				if i == last then
					segment.Think = function(segment)
						local angle = math.rad(segments[j][3])
						local x1,y1 = math.cos(angle-math.pi/1.4),math.sin(angle-math.pi/1.4)
						local lastpos = segments[j][1]
						local x,y = lastpos[1],lastpos[2]
						local huypos = Vector(x + x1 * 100,y + y1 * 100)
						segments[j].lastpos2 = segments[j].lastpos2 or huypos
						if (segments[j].lastpos2:DistToSqr(huypos) >= 90*90) and ((segments[j].laststep2 or 0) < CurTime()) then
							segments[j].lastpos2 = huypos
							segments[j].laststep2 = CurTime() + math.Rand(0,0.2)
						end
						segments[j].leg2 = segment.index
						segment.Vel = segments[j].lastpos2 - segment.Pos
						segment_think(segment)
					end
				end
				if i == 1 then
					segment.Think = function(segment)
						local segments = snake[1]
						local lastpos = segments[j][1]
						local x,y = lastpos[1],lastpos[2]
						segment.Pos[1] = x
						segment.Pos[2] = y 
					end
				end
				segment.Draw = function(segment)
					if not segment.part or not segments[segment.part] or not snakes[lply:UserID()] then return end
					--segment_draw(segment,LerpColor(segment.part / #segments,snake[5],snake[6]))
				end
			end
		end
	end

	hg.start_snake = start_snake

	hook.Add("HUDPaint","new_snake",function() render_segments() end)
	hook.Add("Think","new_snake",function() think_segments() end)
else
	util.AddNetworkString("zmeyka_net")

	local snakes = {}

	net.Receive("zmeyka_net",function(len,ply)
		if ply:Alive() then return end
		if (ply.time_zmeyka_net or 0) > CurTime() then return end
		ply.time_zmeyka_net = CurTime() + zmeyka_netsendtime

		local leading = net.ReadVector()
		local leading_angle = net.ReadFloat()
		--local endpart = net.ReadVector()
		local id = ply:UserID()
		snakes[id] = {leading,leading_angle}--,endpart}

		timer.Create("zmeyka_remove"..id,1,1,function() snakes[id] = nil end)

		ply:CallOnRemove("removesnake",function() snakes[id] = nil end)
		
		net.Start("zmeyka_net")
		net.WriteTable(snakes)
		net.Send(ply)
	end)
end

/*if CLIENT then
	local Segments = {}
	
	local function calculate_anchoredpos2(anchor_pos,lead_pos,length,previous_angle)		
		local anchored_point = lead_pos-anchor_pos
		
		local angle = anchored_point:Angle()
		local diff = math.AngleDifference(angle[2],previous_angle[2])
		
		--[[if math.abs(diff) > 30 then
			angle[2] = math.ApproachAngle(angle[2],previous_angle[2],FrameTime() * 500)
		end--]]

		return anchor_pos + angle:Forward() * length,angle
	end

	local function render_segments()
	end

	local function think_segments()
	end

	local function CreateSegment(child,think,drawfunc,spawnfunc)
		local Segment = {}
		Segment.Pos = Vector(0,0,0)
		Segment.Ang = Angle(0,0,0)
		Segment.Length = 150
		Segment.Size = 30
		Segment.Child = child
		Segment.Vel = Vector(0,0,0)
		Segment.Think = think
		Segment.Draw = drawfunc
		Segment.index = table.insert(Segments,Segment)
		if Segments[Segment.Child] then Segments[Segment.Child].Parent = Segment.index end
		if isfunction(spawnfunc) then spawnfunc() end

		local oldthink = think_segments
		think_segments = function()
			oldthink()
			Segment.Think(Segment)
		end

		local oldrender = render_segments
		render_segments = function()
			oldrender()
			Segment.Draw(Segment)
		end

		return Segment,Segment.index
	end

	local function segment_think(self)
		self.Pos = self.Pos + self.Vel / 2

		local child = Segments[self.Child]
		if child then
			local oldpos = -(-self.Pos)
			self.Pos = calculate_anchoredpos2(child.Pos,self.Pos,child.Length,child.Ang)
			local child_pos,child_angle = calculate_anchoredpos2(self.Pos,child.Pos,self.Length,self.Ang)	
			child.Pos = child_pos
			child.Ang = child_angle
			child.Vel = oldpos - self.Pos
		end

		local parent = Segments[self.Parent]
		if parent then
			local parent_pos,parent_angle = calculate_anchoredpos2(self.Pos,parent.Pos,self.Length,self.Ang)	
			parent.Pos = parent_pos
			parent.Ang = parent_angle
		end
	end

	local function segment_draw(self)
		surface.SetDrawColor(255,255,255,255)
		local pos = self.Pos
		local len = self.Size
		
		draw.Circle(pos[1],pos[2],len,16)
		local child = Segments[self.Child]
		if child then
			local angle = math.rad(child.Ang[2])
			local x1,y1 = math.cos(angle+math.pi/2),math.sin(angle+math.pi/2)
			local poly = {}
			local tbl = {x = pos[1] + x1 * len,y = pos[2] + y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			local tbl = {x = pos[1] - x1 * len,y = pos[2] - y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			local pos = child.Pos
			local tbl = {x = pos[1] - x1 * len,y = pos[2] - y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			local tbl = {x = pos[1] + x1 * len,y = pos[2] + y1 * len,u = 0.5,v = 0.5}
			table.insert(poly,tbl)
			surface.DrawPoly(poly)
		end
	end

	local function start_snake()
		render_segments = function() end
		think_segments = function() end
		Segments = {}
		local prevseg,segment
		local last = 3
		for i = 1,last do
			segment,prevseg = CreateSegment(prevseg,segment_think,segment_draw)
			if i == last then segment.Think = function(segment) local x,y = input.GetCursorPos() segment.Vel[1] = x - segment.Pos[1] segment.Vel[2] = y - segment.Pos[2] segment_think(segment) end end
			if i == 1 then segment.Think = function(segment) local x,y = ScrW()/2,ScrH()/2 segment.Pos[1] = x segment.Pos[2] = y  end end
		end
	end
	
	hook.Add("ContextMenuOpen","zmeyka_new",function()
		start_snake()
	end)

	hook.Add("HUDPaint","new_snake",function() render_segments() end)
	hook.Add("Think","new_snake",function() think_segments() end)
end*/