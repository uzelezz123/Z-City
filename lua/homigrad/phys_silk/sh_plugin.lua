--\\Перевод плагиновых штук в ваши штуки
	hg.PhysSilk = hg.PhysSilk or {}
	local PLUGIN = hg.PhysSilk
	PLUGIN.ID = "PhysSilk"
--//

--\\Литература
	--; Philip Schneider David Eberly - Geometric Tools for Computer Graphics
--//

--\\
	--; TODO
	--; Граплинг хук физика
	--; Шёлковые ленточки на стрелах
	--; Шёлковые ленточки на палочках
--//

PLUGIN.Name = "Physics Silk"
PLUGIN.Description = "Шёлковые ленточки"
PLUGIN.Version = 1
PLUGIN.SilkTable = PLUGIN.SilkTable or {}
PLUGIN.SilkTableClient = PLUGIN.SilkTableClient or {}

--\\MetaTable
	PLUGIN.Class_Silk = {}
	PLUGIN.Class_Silk.__index = PLUGIN.Class_Silk
	PLUGIN.Class_Silk.__tostring = function(self)
		return "Silk [" .. self.Key .. "]"
	end

	function PLUGIN.Class_Silk:Think()	--; EXPENSIVE
		if(self.Entity)then
			if(IsValid(self.Entity))then
				if(self.EntityOffset)then
					if(self.DoCustomEntityOffset)then
						local pos = self.Entity.Silk_RenderPos
						local ang = self.Entity.Silk_RenderAngles
						self.Pos = LocalToWorld(self.EntityOffset, angle_zero, pos, ang)
					else
						self.Pos = self.Entity:LocalToWorld(self.EntityOffset)
					end
				end
			else
				self:Die()
				
				return
			end
		end

		local interval = FrameTime()
		local physenv_gravity = physenv.GetGravity()
		local last_segment = nil
		local segments_amt = #self.Segments

		for segment_key = 1, segments_amt do
			-- local fraction = segment_key / segments_amt
			local segment = self.Segments[segment_key]
		
			if(!last_segment)then
				segment.Pos = self.Pos
			else
				if(!self.NoGravity)then
					segment.Vel = segment.Vel + physenv_gravity * interval	--; Ослабить взаимодействие в зависимости от того, какой сегмент по очереди и кол-ва сегментов
				end
				
				local vel_len = segment.Vel:Length()
				
				if(vel_len == 0)then
					vel_len = 1
				end
				
				local vel_dir = segment.Vel / vel_len
				
				--=\\AirResist
					local resist_mul = segment.AirResistMul
					local resist = math.min(resist_mul * interval * vel_len * vel_len, vel_len)
					local side_resist = resist * segment.Trebble
					resist = resist - side_resist
					vel_len = vel_len - resist
				--=//
				
				segment.Vel = vel_dir * vel_len
				
				--=\\???
					if(side_resist > segment.Trebble)then
						local vel_ang = segment.Vel:Angle()
						local vel_ang_copy = Angle(vel_ang)
						
						vel_ang_copy:RotateAroundAxis(vel_ang:Right(), 90)
						vel_ang_copy:RotateAroundAxis(vel_ang:Forward(), math.random(0, 360))
						
						segment.Vel = segment.Vel + vel_ang_copy:Forward() * segment.Trebble * side_resist
					end
				--=//
				
				local move_vel = segment.Vel * interval
				
				if(self.NoCollision)then
					segment.Pos = segment.Pos + move_vel
				else
					local trace_info = {
						start = segment.Pos,
						endpos = segment.Pos + move_vel,
						filter = self.Entity,
					}
					
					local trace = util.TraceLine(trace_info)
					segment.Pos = trace.HitPos
				end
				
				local vec_offset = segment.Pos - last_segment.Pos
				local vec_offset_len = vec_offset:Length()
				
				if(vec_offset_len == 0)then
					vec_offset_len = 1
				end
				
				local vec_normalized = vec_offset / vec_offset_len
				segment.Vel = segment.Vel - vec_normalized * math.max(vec_offset_len - last_segment.Length, 0) * 1 --* (1 - fraction)
				local len_diff = vec_offset_len - last_segment.Length
				
				if(len_diff > 0)then
					if(!self.NoCollision and self.DoPullCollision and len_diff < last_segment.Length + 100)then
						local vec_negative_offset_len = vec_offset_len - last_segment.Length
						local trace_info = {
							start = segment.Pos,
							endpos = segment.Pos - vec_normalized * vec_negative_offset_len,
							filter = self.Entity,
						}
						local trace = util.TraceLine(trace_info)
						
						if(trace.Hit)then
							local trace_normal = trace.Normal
							local trace_hitnormal = trace.HitNormal
							--; Orthogonal Projection
							local projection = trace_normal - trace_normal:Dot(trace_hitnormal) * trace_hitnormal
							local projection_ang = projection:Angle()
							
							projection_ang:RotateAroundAxis(trace_hitnormal, 180) --; Вроде оптимизировано должно быть а вроде?
							
							projection = projection_ang:Forward()
							local trace_info_2 = {
								start = trace.HitPos,
								endpos = trace.HitPos + projection,
								filter = self.Entity,
							}
							local trace_2 = util.TraceLine(trace_info_2)
							segment.Pos = trace_2.HitPos
						else
							segment.Pos = trace.HitPos
						end
					else
						segment.Pos = last_segment.Pos + vec_normalized * last_segment.Length
					end
				end
			end
			
			last_segment = segment
		end
	end

	-- PLUGIN.SilkTableClient = {}

	if(CLIENT)then
		function PLUGIN.Class_Silk:Draw()
			if(self.Segments)then
				-- local color = self.TracerSetings.TracerColor or color_white
				local color = color_white
				
				render.SetColorMaterial()
				render.StartBeam(#self.Segments)
				
				for i = 1, #self.Segments do
					color = HSVToColor(i * 10, 1, 1)
					local segment = self.Segments[i]

					render.AddBeam(segment.Pos, segment.Width, 1, color)
				end
				
				render.EndBeam()
			end
		end
		
		-- function PLUGIN.Class_Silk:AddPathPoint(pos)
			-- self.PathPoints = self.PathPoints or {}
			-- self.PathPoints[#self.PathPoints + 1] = pos
		
			-- if(#self.PathPoints >= self.TracerSetings.MaxPathPoints * 2)then
				-- self.PathPoints_Swap = self.PathPoints_Swap or {}
				-- self.PathPoints = self.PathPoints_Swap
				-- self.PathPoints_Swap = {}
			-- elseif(#self.PathPoints >= self.TracerSetings.MaxPathPoints)then
				-- self.PathPoints_Swap = self.PathPoints_Swap or {}
				-- self.PathPoints_Swap[#self.PathPoints_Swap + 1] = pos
			-- end
		-- end
	end

	function PLUGIN.Class_Silk:Die()
		self:Remove()
	end

	function PLUGIN.Class_Silk:Remove()
		if(self.PreRemove)then
			self:PreRemove()
		end

		self.Removed = true
		
		if(self.Clientside)then
			PLUGIN.SilkTableClient[self.Key] = nil
		else
			PLUGIN.SilkTable[self.Key] = nil
		end
	end

	function PLUGIN.Class_Silk:IsValid()
		return !self.Removed
	end

	--=\\
		--==\\Segment Structure
			--; Pos
			--; Length
		--==//

		function PLUGIN.Class_Silk:SetSegment(segment_key, pos, vel, length, width, air_resist, trebble)
			self.Segments[segment_key] = {
				Pos = pos,
				Vel = vel,
				Length = length,
				Width = width,
				AirResistMul = air_resist or 0.2,
				Trebble = trebble or 0.6,
			}
		end
	--=//
--//

--\\Creation
	function PLUGIN.CreateSilk(silk, client_only)
		setmetatable(silk, PLUGIN.Class_Silk)
		
		silk.SegmentsDesiredAmt = silk.SegmentsDesiredAmt or 5
		silk.SegmentsDesiredWidth = silk.SegmentsDesiredWidth or 1.5
		silk.SegmentsDesiredLength = silk.SegmentsDesiredLength or 5
		silk.SegmentsDesiredAirResist = silk.SegmentsDesiredAirResist or 0.5
		silk.SegmentsDesiredTrebble = silk.SegmentsDesiredTrebble or 0.35
		
		if(!silk.Segments)then
			silk.Segments = {}
		
			for segment_key = 1, silk.SegmentsDesiredAmt do
				silk:SetSegment(segment_key, silk.Pos, Vector(0, 0, 0), silk.SegmentsDesiredLength, silk.SegmentsDesiredWidth, silk.SegmentsDesiredAirResist, silk.SegmentsDesiredTrebble)
			end
		end
		
		if(client_only)then
			silk.Key = silk.Key or #PLUGIN.SilkTableClient + 1
			PLUGIN.SilkTableClient[silk.Key] = silk
			silk.Clientside = true
		else
			silk.Key = silk.Key or #PLUGIN.SilkTable + 1
			PLUGIN.SilkTable[silk.Key] = silk
		end
		
		silk.HG_IsSilk = true
		
		hook.Run("SilkPostSetup", silk)
		-- silk:Think()

		return silk
	end
--//

PLUGIN.SilkTable = {}
PLUGIN.SilkTableClient = {}

-- PLUGIN.CreateSilk({
	-- Pos = Vector(0, 0, 0),
	-- SegmentsDesiredAmt = 5,
-- })

-- PLUGIN.CreateSilk({
	-- Pos = Vector(0, 0, 0),
	-- SegmentsDesiredAmt = 6,
-- })

-- PLUGIN.CreateSilk({
	-- Pos = Vector(0, 0, 0),
	-- SegmentsDesiredLength = 5,
	-- SegmentsDesiredAmt = 110,
	-- NoCollision = true,
-- })

--\\Hooks
	hook.Add("Think", "PhysSilk", function()
		for key, silk in pairs(PLUGIN.SilkTable) do
			if(CLIENT)then
				silk.Pos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 340
			end
			
			silk:Think()
		end

		-- for key, silk in pairs(PLUGIN.SilkTableClient) do
			-- silk:Think()
		-- end
	end)

	hook.Add("PostCleanupMap", "PhysSilk", function()
		for key, silk in pairs(PLUGIN.SilkTable) do
			silk:Die()
		end
		
		for key, silk in pairs(PLUGIN.SilkTableClient) do
			silk:Die()
		end
	end)

	if(CLIENT)then
		hook.Add("PostDrawTranslucentRenderables", "PhysSilk", function(bDepth, bSkybox)
			if(not bSkybox)then
				for key, silk in pairs(PLUGIN.SilkTable) do
					silk:Draw()
				end
				
				for key, silk in pairs(PLUGIN.SilkTableClient) do
					silk:Think()
					silk:Draw()
				end
			end
		end)
	end
--//