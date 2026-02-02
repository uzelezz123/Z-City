include("shared.lua")

hook.Add("NetworkEntityCreated", "Radiohuy", function(ent)
    if playingents[ent:EntIndex()] then
        local tbl = 
        playingents[ent:EntIndex()]
        
        timer.Simple(0.2,function()
            if ent.PlayURL then
                ent:PlayURL(tbl[2],CurTime()-tbl[1])
            end
            --if ent:GetTextureURL() ~= "" then
                --ent:SetTextureURL( ent:GetTextureURL() )
            --end
        end)
    end
end)

net.Receive("RadioChangeValue", function(len, ply)
	local val = net.ReadFloat()
	local index = net.ReadInt(32)

	if playingents[index] then
		if IsValid(playingents[index][3]) and not playingents[index][3]:IsBlockStreamed() then
			playingents[index][3]:SetTime(val)
		end
	end
end)

net.Receive("RadioChangeVolume", function(len, ply)
	local val = net.ReadFloat()
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			--playingents[index][3]:SetVolume(val)
			playingents[index][5] = val
		end
	end
end)

net.Receive("RadioPause", function(len, ply)
	local val = net.ReadBool()
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			if val then
				playingents[index][3]:Pause()
			else
				playingents[index][3]:Play()
			end
		end
	end
end)

net.Receive("RadioStop", function(len, ply)
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			playingents[index][3]:Stop()
			playingents[index][3] = nil
		end
	end
end)

net.Receive("RadioLooping", function(len, ply)
	local val = net.ReadBool()
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			playingents[index][3]:EnableLooping(val)
		end
	end
end)

local frame

local gradient_d = Material("vgui/gradient-d")
local blurMat = Material("pp/blurscreen")
local Dynamic = 0
local red = Color(150,0,0)

BlurBackground = BlurBackground or hg.DrawBlur

net.Receive("RadioURLInput", function()
	if IsValid(frame) then return end 
	local ent = net.ReadEntity()
	frame = vgui.Create("ZFrame")
	frame:SetSize(400, 350) 
	frame:SetPos(ScrW() / 2 - frame:GetWide() / 2,ScrH() + 500)
	frame:SetTitle(playingents[ent:EntIndex()] and ("Radio: In playing...") or "Radio")
	frame:MakePopup()
	frame:SetAlpha(0)
	frame.OnClose = function() frame = nil end 
	--function frame:Paint( w, h )
	--    draw.RoundedBox( 0, 2.5, 2.5, w-5, h-5, Color( 0, 0, 0, 140) )
	--    surface.DrawTexturedRect( 0, 0, w, h )
	--    BlurBackground(frame)
	--    surface.SetDrawColor( 255, 0, 0, 128)
	--    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	--end

	frame:MoveTo(ScrW() / 2 - frame:GetWide() / 2, ScrH() / 2 - frame:GetTall() / 2, 0.5, 0, 0.3, function()
	end)
	frame:AlphaTo( 255, 0.2, 0.1, nil )

	function frame:Close()
		self:MoveTo(ScrW() / 2 - frame:GetWide() / 2, ScrH()+ 500, 0.5, 0, 0.3, function()
			self:Remove()
		end)
		self:AlphaTo( 0, 0.1, 0, nil )
		self:SetKeyboardInputEnabled(false)
		self:SetMouseInputEnabled(false)
	end

	local tEntryBG1 = vgui.Create("DPanel", frame)
	tEntryBG1:Dock(TOP)
	tEntryBG1:SetBackgroundColor(color_white)
	tEntryBG1:DockMargin(5,5,5,2.5)	
	tEntryBG1:SetSize(50,45)	
	function tEntryBG1:Paint( w, h )
		self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
		draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
		surface.SetDrawColor( color_black )
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end
	

	local urlEntry = vgui.Create("DTextEntry", tEntryBG1)
	urlEntry:Dock( FILL )
	--urlEntry:DockMargin(10,5,150,2.5)	
	--urlEntry:SetSize(50,45)	
	urlEntry:SetTextColor(Color(255,255,255))
	urlEntry:SetPlaceholderText( "Enter URL here" )
	urlEntry:SetPaintBackground(false)

	urlEntry.OnEnter = function()
		net.Start("RadioURLInput")
		net.WriteString(urlEntry:GetValue())
		net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	local controlsPanel = vgui.Create("DPanel", frame)
	controlsPanel:Dock( TOP )
	controlsPanel:DockMargin(5,5,5,2.5)
	controlsPanel:SetSize(50,45)
	controlsPanel.Paint = function()

	end

	local playButton = vgui.Create("DButton", controlsPanel)
	playButton:SetText("Play")
	playButton:Dock( LEFT )
	playButton:DockMargin(1,2,1,2)		
	playButton:SetSize(370/4,45)	
	--playButton:SetFont("HomigradFont")
	playButton:SetTextColor(Color(255,255,255))
	playButton.DoClick = function()
		net.Start("RadioURLInput")
		net.WriteString(urlEntry:GetValue())
		net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	function playButton:Paint( w, h )
		self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
		draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
		surface.SetDrawColor( color_black)
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	local stopButton = vgui.Create("DButton", controlsPanel)
	stopButton:SetText("Stop")
	stopButton:Dock( RIGHT )
	stopButton:DockMargin(1,2,1,2)			
	stopButton:SetSize(370/4,45)	
	--playButton:SetFont("HomigradFont")
	stopButton:SetTextColor(Color(255,255,255))
	stopButton.DoClick = function()
		net.Start("RadioStop")
			net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	function stopButton:Paint( w, h )
		self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
		draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
		surface.SetDrawColor( color_black)
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	local stopButton = vgui.Create("DButton", controlsPanel)
	stopButton:SetText("Looping")
	stopButton:Dock( RIGHT )
	stopButton:DockMargin(1,2,1,2)			
	stopButton:SetSize(370/4,45)	
	--playButton:SetFont("HomigradFont")
	stopButton:SetTextColor(Color(255,255,255))
	stopButton.DoClick = function()
		net.Start("RadioLooping")
			local snd = playingents[ent:EntIndex()][3]
			net.WriteBool(IsValid(snd) and not snd:IsLooping() or false)
			net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	function stopButton:Paint( w, h )
		self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
		draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
		surface.SetDrawColor( color_black)
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	local pauseButton = vgui.Create("DButton", controlsPanel)
	pauseButton:SetText("Pause")
	pauseButton:Dock( FILL )
	pauseButton:DockMargin(1,2,1,2)		
	pauseButton:SetSize(370/4,45)	
	--playButton:SetFont("HomigradFont")
	pauseButton:SetTextColor(Color(255,255,255))
	pauseButton.DoClick = function()
		net.Start("RadioPause")
			local snd = playingents[ent:EntIndex()][3]
			net.WriteBool(IsValid(snd) and snd:GetState() != GMOD_CHANNEL_PAUSED or false)
			net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	function pauseButton:Paint( w, h )
		self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
		draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
		surface.SetDrawColor( color_black)
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end


	if playingents[ent:EntIndex()] and IsValid(playingents[ent:EntIndex()][3]) then
		local lbl = vgui.Create( "DLabelURL", frame )
		lbl:Dock( TOP )
		lbl:DockMargin(10,5,5,2.5)	
		lbl:SetSize(50,45)	
		lbl:SetColor( Color( 255, 255, 255, 255 ) ) 
		lbl:SetText( ("Currently playing \n"..playingents[ent:EntIndex()][2]) ) 
		lbl:SetURL( playingents[ent:EntIndex()][2] )
	end

	if playingents[ent:EntIndex()] and IsValid(playingents[ent:EntIndex()][3]) then
		local DermaNumSlider = vgui.Create( "DNumSlider", frame )
		DermaNumSlider:Dock( TOP )
		DermaNumSlider:DockMargin(10,0,5,0)	
		DermaNumSlider:SetSize(50,45)	
		DermaNumSlider:SetText( "Time slider" )
		DermaNumSlider:SetMin( 0 )			
		DermaNumSlider:SetMax( playingents[ent:EntIndex()][3]:GetLength() )
		DermaNumSlider:SetDecimals( 2 )
		DermaNumSlider:SizeToContents()
		DermaNumSlider.isedited = false
		DermaNumSlider.OnValueChanged = function(self,val)
			if playingents[ent:EntIndex()][3]:IsBlockStreamed() then return end
			if self:IsEditing() then
				DermaNumSlider.isedited = true
				playingents[ent:EntIndex()][3]:SetTime(val)
			else
				if DermaNumSlider.isedited then
					net.Start("RadioChangeValue")
					net.WriteFloat(val)
					net.WriteInt(ent:EntIndex(),32)
					net.SendToServer()
					DermaNumSlider.isedited = false
				end
			end
		end

		playingents[ent:EntIndex()][4] = DermaNumSlider
		DermaNumSlider:SetValue( playingents[ent:EntIndex()][3]:GetTime() )
	end

	if playingents[ent:EntIndex()] and IsValid(playingents[ent:EntIndex()][3]) then
		local DermaNumSlider = vgui.Create( "DNumSlider", frame )
		DermaNumSlider:Dock( TOP )
		DermaNumSlider:DockMargin(10,0,5,0)	
		DermaNumSlider:SetSize(50,45)	
		DermaNumSlider:SetText( "Volume slider" )
		DermaNumSlider:SetMin( 0 )			
		DermaNumSlider:SetMax( 200 )
		DermaNumSlider:SetDecimals( 0 )
		DermaNumSlider:SizeToContents()
		DermaNumSlider.isedited = false
		DermaNumSlider.OnValueChanged = function(self,val)
			if self:IsEditing() then
				DermaNumSlider.isedited = true
				playingents[ent:EntIndex()][3]:SetVolume(val/100)
				playingents[ent:EntIndex()][5] = val/100
			else
				if DermaNumSlider.isedited then
					net.Start("RadioChangeVolume")
						net.WriteFloat(val/100)
						net.WriteInt(ent:EntIndex(),32)
					net.SendToServer()
					DermaNumSlider.isedited = false
				end
			end
		end
		DermaNumSlider:SetValue( playingents[ent:EntIndex()][3]:GetVolume()*100 )

	end
end)

local FFTs
function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	-- Change these numbers to rotate the screen correctly for your model
	ang:RotateAroundAxis( self:GetUp(), 90 )
	ang:RotateAroundAxis( self:GetRight(), -90 )
	ang:RotateAroundAxis( self:GetForward(), 0 )

	local pos = self:GetPos()
	-- Change these numbers to position the screen on your model
	pos = pos + self:GetForward() * 2.5
	pos = pos + self:GetRight() * 0
	pos = pos + self:GetUp() * 4.1

	-- Higher the value, the better the resolution
	local resolution = 1.5

	cam.Start3D2D( pos, ang, 0.05 / resolution )
		FFTs = FFTs or {}
		surface.SetDrawColor( color_black )
		surface.DrawRect( 0, -70, 65*3.3, 80 )
		if playingents[self:EntIndex()] and IsValid(playingents[self:EntIndex()][3]) and playingents[self:EntIndex()][3]:GetState() == GMOD_CHANNEL_PLAYING then
			playingents[self:EntIndex()][3]:FFT(FFTs,FFT_2048)
			for i = 1, 65 do
				draw.RoundedBox(0,0+(i-1)*3.3,10-math.min(FFTs[i+1]*255,80),3,math.min(FFTs[i+1]*255,80),Color( 255, 0, 0))
			end
		end
	cam.End3D2D()
end

playingents = playingents or {}

net.Receive("PlayRadioSound", function()
	local url = net.ReadString()
	local index = net.ReadInt(32)
	local ent = Entity(index)
	
	playingents[index] = {[1] = CurTime(),[2] = url, [5] = 1}

	if IsValid(ent) then
		ent:PlayURL(url)
	end
end)

function ENT:Think()
	local view = render.GetViewSetup()

	self:SetNextClientThink( CurTime() + 0.025 )

	if CLIENT and playingents[self:EntIndex()] and IsValid(playingents[self:EntIndex()][3]) and IsValid(playingents[self:EntIndex()][4]) then
		playingents[self:EntIndex()][4]:SetValue(playingents[self:EntIndex()][3]:GetTime())
	end
	if playingents[self:EntIndex()] and IsValid(playingents[self:EntIndex()][3]) then
		playingents[self:EntIndex()][3]:SetPos(self:GetPos())
		if self:GetPos():Distance(view.origin) > 1000 then
			playingents[self:EntIndex()][3]:SetVolume(0)
			playingents[self:EntIndex()][3]:SetPos(self:GetPos())
		   -- print("huy")
		else
			playingents[self:EntIndex()][3]:SetVolume( playingents[self:EntIndex()][5] or 1 )
		end
	end
	return true
end