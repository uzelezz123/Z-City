--\\
	--; TODO
	--; Для вычисления урона (энергии) Ek = (m * V^2) / 2
	--; Сопротивление воздуха F = B * v^2,
	--; Метры в сек в юниты в сек V * 52.5
	--; Дрейф

	--; Из разных пушек разная скорость пули
	--; Некоторые параметры будут считаться исходя из аммоайди

	--; У дроби высокое сопротивление воздуху (~75 метров и они падают)
--//

--\\Перевод плагиновых штук в ваши штуки
	hg.PhysBullet = hg.PhysBullet or {}
	local PLUGIN = hg.PhysBullet
	PLUGIN.ID = "PhysBullet"

	function PLUGIN:AddHook(id, func)
		hook.Add(id, "HG.Plugin.List[" .. self.ID .. "].Hooks[" .. id .. "]", func)
	end

	function PLUGIN:RunHook(id, ...)
		return hook.Run("HG.Plugin.List[" .. self.ID .. "].Hooks[" .. id .. "]", ...)
	end
--//

-- ulx luarun SetGlobalBool('PhysBullets_ReplaceDefault', true)
SetGlobalBool("PhysBullets_ReplaceDefault", false)

PLUGIN.Name = "Physics Bullet"
PLUGIN.Description = "Creates projectiles"
PLUGIN.Version = 1
PLUGIN.MainMaterial = Material("sprites/splodesprite")
PLUGIN.BulletsTable = PLUGIN.BulletsTable or {}
PLUGIN.MaxKeyBitsFilter = 6 --; Used for filter networking
PLUGIN.MaxKeyBits = 13 --; The same as gmod max ents bits, should be more than enough
PLUGIN.MaxAmmoIDBits = 8 --; Used for AmmoID
PLUGIN.MaxVelocityLenBits = 16 --; Up to 32767 * 2 hu/s
PLUGIN.MaxVelocityBits = 8
PLUGIN.MaxVelocityInt = 2^(PLUGIN.MaxVelocityBits - 1) - 1
PLUGIN.FirstPenetrationMul = 0.006	--; Что это нафиг
PLUGIN.DefaultSurfaceHardness = 0.5

PLUGIN.SurfaceHardness = {
	[MAT_METAL] = 0.9,
	[MAT_COMPUTER] = 0.9,
	[MAT_VENT] = 0.9,
	[MAT_GRATE] = 0.9,
	[MAT_FLESH] = 0.5,
	[MAT_ALIENFLESH] = 0.3,
	[MAT_SAND] = 0.1,
	[MAT_DIRT] = 0.9,
	[74] = 0.1,
	[85] = 0.2,
	[MAT_WOOD] = 0.5,
	[MAT_FOLIAGE] = 0.5,
	[MAT_CONCRETE] = 0.9,
	[MAT_TILE] = 0.8,
	[MAT_SLOSH] = 0.05,
	[MAT_PLASTIC] = 0.3,
	[MAT_GLASS] = 0.6,
}

PLUGIN.Bullet_StandartMask = MASK_SHOT

--\\Misc
	local function define_if_not_defined(tbl, key, value)
		if(tbl[key] == nil)then
			tbl[key] = value
		end
	end

	local function translate_default_bullet_to_phys(bullet)
		bullet.Pos = bullet.Pos or bullet.Src
		bullet.Shooter = bullet.Shooter or bullet.Attacker
		bullet.Size = bullet.Size or bullet.HullSize or 0
		bullet.TraceFilter = bullet.TraceFilter or bullet.IgnoreEntity
		bullet.AmmoID = bullet.AmmoID or bullet.AmmoType
		bullet.TraceMask = bullet.TraceMask or PLUGIN.Bullet_StandartMask
		
		if(isstring(bullet.AmmoID))then
			bullet.AmmoID = game.GetAmmoID(bullet.AmmoID)
		end

		--=\\
			bullet.Force = bullet.Force or 1
			bullet.AmmoForce = bullet.AmmoForce or game.GetAmmoForce(bullet.AmmoID)	--; ????????????????????
		--=//

		local hg_ammo_table = hg.ammotypeshuy[game.GetAmmoName(bullet.AmmoID)] or game.GetAmmoData(bullet.AmmoID)
		hg_ammo_table = hg_ammo_table or {}
		hg_ammo_table.BulletSettings = hg_ammo_table.BulletSettings or {}
		hg_ammo_table.BulletFunctions = hg_ammo_table.BulletFunctions or {}
		
		--=\\???
			bullet.AirResistMul = bullet.AirResistMul or hg_ammo_table.BulletSettings.AirResistMul
			bullet.LifeTime = bullet.LifeTime or hg_ammo_table.BulletSettings.LifeTime
			bullet.Mass = bullet.Mass or hg_ammo_table.BulletSettings.Mass or 1
			bullet.DamageType = bullet.DamageType or hg_ammo_table.dmgtype or DMG_BULLET
			bullet.PhysPenetrationMul = bullet.PhysPenetrationMul or hg_ammo_table.BulletSettings.PhysPenetrationMul or 1
			bullet.ForceMul = bullet.ForceMul or hg_ammo_table.ForceMul or 1
			bullet.TracerSetings = bullet.TracerSetings or hg_ammo_table.TracerSetings or {}
			bullet.TracerSetings.MaxPathPoints = bullet.TracerSetings.MaxPathPoints or 5
			bullet.FunctionInfo = bullet.FunctionInfo or hg_ammo_table.FunctionInfo or {}
		--=//

		--=\\Functions Overrides
			bullet.Draw = hg_ammo_table.BulletFunctions.Draw or bullet.Draw
			bullet.Remove = hg_ammo_table.BulletFunctions.Remove or bullet.Remove
			bullet.PreRemove = hg_ammo_table.BulletFunctions.PreRemove or bullet.PreRemove
			bullet.PostRemove = hg_ammo_table.BulletFunctions.PostRemove or bullet.PostRemove
			bullet.Hit = hg_ammo_table.BulletFunctions.Hit or bullet.Hit
			bullet.PostRicochet = hg_ammo_table.BulletFunctions.PostRicochet or bullet.PostRicochet
			bullet.PostPenetration = hg_ammo_table.BulletFunctions.PostPenetration or bullet.PostPenetration
			bullet.OnStopped = hg_ammo_table.BulletFunctions.OnStopped or bullet.OnStopped
			bullet.AddPathPoint = hg_ammo_table.BulletFunctions.AddPathPoint or bullet.AddPathPoint
		--=//

		if(bullet.Vel == nil)then
			bullet.StartLen = (bullet.Speed or hg_ammo_table.Speed or 320) * 52.5 * math.Rand(0.9, 1.1)
			bullet.Vel = bullet.Dir * bullet.StartLen
			bullet.Dir = nil
		end
		
		if(not bullet.StartLen)then
			bullet.StartLen = bullet.Vel:Length()
		end

		if(SERVER and bullet.Spread)then	--; OPTIMIZE ME
			local dir = bullet.DirOriginal or bullet.Dir
			local len = 1
			
			if(not dir)then
				len = bullet.Vel:Length()
				dir = bullet.Vel / len
			end
			
			bullet.DirOriginal = bullet.DirOriginal or dir
			local ang = dir:Angle()
			local vec_right = ang:Right()
			local vec_up = ang:Up()
			local spread_x = bullet.Spread[1] * 45
			local spread_y = bullet.Spread[2] * 45
			
			ang:RotateAroundAxis(vec_up, math.Rand(-spread_x, spread_x))
			ang:RotateAroundAxis(vec_right, math.Rand(-spread_y, spread_y))
			
			bullet.Vel = ang:Forward() * len
		end
	end

	local function copy_bullet(bullet)
		local new_bullet = table.Copy(bullet)
		new_bullet.Pos = Vector(new_bullet.Pos)
		new_bullet.Vel = Vector(new_bullet.Vel)
		
		if(new_bullet.DirOriginal)then
			new_bullet.DirOriginal = Vector(new_bullet.DirOriginal)
		end
		
		new_bullet.Key = nil
		
		return new_bullet
	end
--//

--\\Misc Network
	function PLUGIN.net_writekey(value)
		net.WriteUInt(value, PLUGIN.MaxKeyBits)
	end

	function PLUGIN.net_readkey()
		return net.ReadUInt(PLUGIN.MaxKeyBits)
	end

	function PLUGIN.net_writeammoid(value)
		net.WriteUInt(value, PLUGIN.MaxAmmoIDBits)
	end

	function PLUGIN.net_readammoid()
		return net.ReadUInt(PLUGIN.MaxAmmoIDBits)
	end

	function PLUGIN.net_writevelocity(value, len)
		if(!len)then
			len = value:Length()
			value = value / len
		end
		
		net.WriteInt(math.Round(value[1] * PLUGIN.MaxVelocityInt), PLUGIN.MaxVelocityBits)
		net.WriteInt(math.Round(value[2] * PLUGIN.MaxVelocityInt), PLUGIN.MaxVelocityBits)
		net.WriteInt(math.Round(value[3] * PLUGIN.MaxVelocityInt), PLUGIN.MaxVelocityBits)
		--; оптимизация круто но слишком заметна какашка когда скорость пули маленькая (ниче не заметно)
		net.WriteUInt(len, PLUGIN.MaxVelocityLenBits)
	end

	function PLUGIN.net_readvelocity()
		local x = net.ReadInt(PLUGIN.MaxVelocityBits)
		local y = net.ReadInt(PLUGIN.MaxVelocityBits)
		local z = net.ReadInt(PLUGIN.MaxVelocityBits)
		local value = Vector(x / PLUGIN.MaxVelocityInt, y / PLUGIN.MaxVelocityInt, z / PLUGIN.MaxVelocityInt)
		local len = net.ReadUInt(PLUGIN.MaxVelocityLenBits)
		
		return value * len
	end

	function PLUGIN.net_writetracefilter(filter)
		if(not istable(filter))then
			filter = {filter}
		end

		local len = #filter
		
		net.WriteUInt(len, PLUGIN.MaxKeyBitsFilter)	--; OPTIMIZE ME Optimizable
		
		for key = 1, len do
			local value = filter[key]
			
			if(isstring(value))then
				net.WriteBool(true)
				net.WriteString(value)
			elseif(isentity(value))then
				net.WriteBool(false)
				net.WriteEntity(value)
			else
				ErrorNoHaltWithStack("Expected value at key " .. key .. " to be string or Entity, but got " .. type(value) .. "\n")
				return false
			end
		end
	end

	function PLUGIN.net_readtracefilter()
		local len = net.ReadUInt(PLUGIN.MaxKeyBitsFilter)
		local filter = {}
		
		for key = 1, len do
			local is_str = net.ReadBool()
			
			if(is_str)then
				filter[key] = net.ReadString()
			else
				filter[key] = net.ReadEntity()
			end
		end
		
		return filter
	end
--//

--\\Network
	PLUGIN.NetworkTableFull = {
		{"Key", PLUGIN.net_writekey, PLUGIN.net_readkey},
		{"AmmoID", PLUGIN.net_writeammoid, PLUGIN.net_readammoid},
		{"CreationTime", net.WriteFloat, net.ReadFloat},
		{"LifeTime", net.WriteFloat, net.ReadFloat},
		{"DieOnHit", net.WriteBool, net.ReadBool},
		{"NoGravity", net.WriteBool, net.ReadBool},
		{"Pos", net.WriteVector, net.ReadVector},
		{"Vel", PLUGIN.net_writevelocity, PLUGIN.net_readvelocity},
		{"Size", net.WriteFloat, net.ReadFloat},
		{"AirResistMul", net.WriteFloat, net.ReadFloat}, --; WARNING
		{"Penetration", net.WriteFloat, net.ReadFloat},
		-- {"LoseVelocity", net.WriteFloat, net.ReadFloat},
		-- {"Color", net.WriteColor, net.ReadColor},
		{"TraceFilter", PLUGIN.net_writetracefilter, PLUGIN.net_readtracefilter},
	}

	PLUGIN.NetworkTableUpdate = {
		{"Key", PLUGIN.net_writekey, PLUGIN.net_readkey},	--; Always first
		{"Pos", net.WriteVector, net.ReadVector},
		{"Vel", PLUGIN.net_writevelocity, PLUGIN.net_readvelocity},
	}
--//

--; Пульки которые пиф паф взиу пиу
--; Написано будет все на анлийском потомучто я так уже начал и менять лень

--\\
	--; Bullet structure:
	--; Size - (number) Hull trace's size
	--; Color - Color of the bullet
	--; Pos	- Position

	--; Vel = bullet.Dir * (number) - Velocity
	--; AmmoID = 0 - Default game library's AmmoID
	--; AirResistMul = 0.0001 - Air resistance mul
	--; Mass = 1 - Mass
	--; PhysPenetrationMul = 1 - DEPRECATED Penetration trace length mul
	--; Damage = 0 - Damage dealt to the thing receiving shot
	--; NoNetwork = false - Disable networking?
	--; NoNetworkUpdate = false - Disable update networking?
	--; LoseVelocity = 1 - Velocity lost per second (scaled to engine.TickInterval)
	--; NoGravity = nil - Disable gravity? no gravity does not mean no air friction:troll:
	--; TraceFilter = bullet.Shooter - Trace filter. Functions are not supported for networking
	--; LifeTime = 5 - Time for this thing to live

	--; DieOnHit = false - Die on hit?

	--; Key = auto - Bullet's key in global table
	--; SizeMins = auto - Calculated automatically
	--; SizeMaxs = auto - Calculated automatically
	--; CreationTime = CurTime() - Time of creation
	--; LastThinkTime = CurTime() - Time of last think
	--; LastUpdateTime = auto - NetCDUpdateBullet
	--; AttackedEnts = auto - Calculated automatically

	--; Removed = auto - Set then removed
--//

--\\MetaTable
	PLUGIN.Class_Bullet = {}
	PLUGIN.Class_Bullet.__index = PLUGIN.Class_Bullet
	PLUGIN.Class_Bullet.__tostring = function(self)
		return "Bullet [" .. self.Key .. "]"
	end

	function PLUGIN.Class_Bullet:Think()
		if(not PLUGIN:RunHook("BulletPreThink", self))then
			if(self.LastThinkTime == CurTime())then
				self.LastThinkTime = CurTime()
				return
			end
			
			self.LastThinkTime = CurTime()
		end

		if(PLUGIN:RunHook("BulletThink", self) == false)then
			return
		end

		if(self.CreationTime + self.LifeTime <= CurTime())then
			if(self.OnStopped)then
				self:OnStopped(nil, "time")
			end
		
			self:Die()
			return
		end
		
		--[[if self.DistanceTraveled > 100 then
			print(self.Vel:Length()/52)
		end--]]
		--; на 100 ~~метров~~ юнитов какая скорость узнать бесплатно
		
		if(self.DistanceTraveled >= self.Distance)then
			if(self.OnStopped)then
				self:OnStopped(nil, "distance")
			end
		
			self:Die()
			return
		end

		local interval = FrameTime()
		local physenv_gravity = physenv.GetGravity()
		
		--=\\Изменения self.Vel
			--==\\Gravity
				if(!self.NoGravity)then
					self.Vel = self.Vel + physenv_gravity * interval
				end
			--==//
			
			--==\\Drift
				-- local drift = 50
				-- local drift_vec = Vector(util.SharedRandom("x" .. self.Key, -drift, drift, CurTime()), util.SharedRandom("y" .. self.Key, -drift, drift, CurTime()), util.SharedRandom("z" .. self.Key, -drift, drift, CurTime()))
				-- self:ApplyForceCenter(drift_vec)
			--==//
		--=//
		
		local len = self.Vel:Length()
		self.DistanceTraveled = self.DistanceTraveled + len * interval
		
		if(len == 0)then
			len = 1
		end
		
		local dir = self.Vel / len
		
		--=\\Изменения длины скорости
		
		--[[
		local tbl = hg.ammotypeshuy[game.GetAmmoName(self.AmmoID)].BulletSettings
		
		local Cd = tbl.AirResistanceCoef
		local p = 1.2255--; в воздухе
		local V = len / 52.5
		local S = len / 52.5 * interval
		--; E = P / t
		--; (t = interval)
		local energy = tbl.Mass / 1000 * (V^2) / 2
		local energy_loss = (Cd * p * (V^2)) / 2 * S * S--; неверно...
		local newenergy = energy - energy_loss
		local newspeed = newenergy
		--]]
		
		--==\\AirResist
			local resist_mul = self.AirResistMul
			
			if(self.PenetratingMaterial)then
				resist_mul = PLUGIN.CalcMaterialResist(self.PenetratingMaterial)
				-- Entity(1):ChatPrint(tostring(resist_mul))
			end
			
			len = len - math.min(resist_mul * interval * len * len, len)
		--==//
		
		--=//
		
		if(hg.IsChanged(self.Size, "Size", self))then
			local size = self.Size / 2
			self.SizeMins = Vector(-size, -size, -size)
			self.SizeMaxs = Vector(size, size, size)
		end
		
		local trace_hit = true
		local vel_vector = self.Vel
		local vel_normal = dir
		local len_before = len
		local iteration = 0
		
		while trace_hit and vel_vector do
			local hull_trace = {}
			local move_vector = vel_vector * interval
			hull_trace.start = self.Pos
			hull_trace.endpos = self.Pos + move_vector
			hull_trace.mins = self.SizeMins
			hull_trace.maxs = self.SizeMaxs
			hull_trace.filter = self.TraceFilter
			hull_trace.mask = self.TraceMask
			
			local trace = nil
			
			if(self.Size == 0)then
				trace = util.TraceLine(hull_trace)
			else
				trace = util.TraceHull(hull_trace)
			end
			
			trace_hit = trace.Hit
			
			if(self.PenetratingMaterial)then
				if(!trace.AllSolid)then
					local max_penetrate_iterations = 10
					local one_penetrate_chunk = move_vector / max_penetrate_iterations * self.Penetration / 50
					local penetration_pos = nil
					local last_unsure_penetration_pos = nil
					
					for penetrate_iteration = 1, max_penetrate_iterations do
						hull_trace.start = self.PenetratingStartPos + one_penetrate_chunk * penetrate_iteration
						hull_trace.endpos = hull_trace.start - one_penetrate_chunk * penetrate_iteration
						hull_trace.mins = self.SizeMins
						hull_trace.maxs = self.SizeMaxs
						hull_trace.filter = self.TraceFilter
						hull_trace.mask = self.TraceMask
						local penetration_trace = nil
						
						if(self.Size == 0)then
							penetration_trace = util.TraceLine(hull_trace)
						else
							penetration_trace = util.TraceHull(hull_trace)
						end
						
						if(!penetration_trace.StartSolid and penetration_trace.Hit)then
							penetration_pos = penetration_trace.HitPos
							
							break
						elseif(!penetration_trace.AllSolid)then
							last_unsure_penetration_pos = hull_trace.start
						end
					end
				
					if(penetration_pos)then
						self.Pos = penetration_pos
						len_before = PLUGIN.CalcVelocityLostInMaterial(material, self.PenetratingStartPos:DistToSqr(penetration_pos), len_before)
						len = math.min(len, len_before)
						
						if(SERVER)then
							local tr_back = {}
							tr_back.start = penetration_pos + move_vector * 1
							tr_back.endpos = tr_back.start - move_vector * 2
							tr_back.mask = self.TraceMask
							local trace_backwards = util.TraceLine(tr_back)
							
							if(!trace_backwards.StartSolid)then
								local effectdata = EffectData()
								
								effectdata:SetOrigin(trace_backwards.HitPos)
								effectdata:SetEntity(trace_backwards.Entity)
								effectdata:SetStart(trace_backwards.StartPos)
								effectdata:SetSurfaceProp(trace_backwards.SurfaceProps)
								effectdata:SetDamageType(DMG_BULLET)
								effectdata:SetHitBox(trace_backwards.HitBox)
								util.Effect("Impact", effectdata, true, true)
							end
						end
						
						self.PenetratingMaterial = nil
						self.PenetratingStartPos = nil
						self.PenetratingSky = false
					else
						last_unsure_penetration_pos = last_unsure_penetration_pos or (self.Pos + move_vector)
						self.PenetratingStartPos = last_unsure_penetration_pos	--; WARNING
						
						-- if(self.PenetratingSky)then
							-- self.Pos = self.Pos + move_vector
						-- else
							if(self.OnStopped)then
								self:OnStopped(last_unsure_penetration_pos, "penetration", self.PenetratingTrace)
							end
							
							self:Die()
						-- end
						
						return
					end
					
					--=\\PLUG
						if(CLIENT)then
							self:AddPathPoint(self.Pos)
						end
					--=//
					
					goto phys_bullets_continue
				end
			end
			
			if(self.PenetratingMaterial)then
				self.Pos = self.Pos + move_vector
			else
				self.Pos = trace.HitPos
			end
			
			--=\\PLUG
				if(CLIENT)then
					self:AddPathPoint(self.Pos)
				end
			--=//
			
			--=\\Damage Trace
				if(SERVER and IsValid(trace.Entity))then
					self.AttackedEnts = self.AttackedEnts or {}
					
					if(!self.AttackedEnts[trace.Entity])then
						self.AttackedEnts[trace.Entity] = true
						local speedmul = (len_before / self.StartLen)
						local dmg = DamageInfo()
						
						dmg:SetDamage(self.Damage * math.sqrt(speedmul))--; скорость слишком быстро теряется... поэтому квадрат
						dmg:SetDamageType(self.DamageType or DMG_BULLET)
						dmg:SetDamagePosition(trace.HitPos)
						dmg:SetDamageForce(self.AmmoForce * dir * (speedmul * self.Force * self.ForceMul))
						
						if(IsValid(self.Shooter))then
							dmg:SetAttacker(self.Shooter)
							dmg:SetInflictor(self.Shooter)
						else
							dmg:SetAttacker(Entity(0))
							dmg:SetInflictor(Entity(0))
						end

						trace.Entity:DispatchTraceAttack(dmg, trace, dir)

						if(trace.Entity.organism)then
							if(self.OnStopped)then
								self:OnStopped(nil, "organism", trace)
							end
							
							self:Die()

							return
						end
					end
				end
			--=//
			
			if(trace_hit)then
				if(SERVER and not trace.StartSolid)then
					local effectdata = EffectData()
					effectdata:SetOrigin(trace.HitPos)
					effectdata:SetEntity(trace.Entity)
					effectdata:SetStart(trace.StartPos)
					effectdata:SetSurfaceProp(trace.SurfaceProps)
					effectdata:SetDamageType(DMG_BULLET)
					effectdata:SetHitBox(trace.HitBox)
					util.Effect("Impact", effectdata, true, true)
				end
				
				if(self.PenetratingMaterial)then
				
				else
					vel_normal, len, len_before = self:Hit(trace, len, len_before)
				end
			end
			
			if(self.Removed)then
				return
			end
			
			vel_normal = vel_normal or dir
			len = len or len_before
			vel_vector = vel_normal * len
			
			if(len < 0.001)then
				if(self.OnStopped)then
					self:OnStopped(nil, "len", self.PenetratingTrace)
				end
			
				self:Die()
				
				return
			end
			
			::phys_bullets_continue::	--; Extreme sin
			
			iteration = iteration + 1
			
			if(iteration > 4)then
				break
			end
		end
		
		self.Vel = vel_normal * len_before
		
		if(SERVER and not self.NoNetworkUpdate)then
			if(not self.LastUpdateTime or (self.LastUpdateTime + PLUGIN.NetCDUpdateBullet <= CurTime()))then
				self.LastUpdateTime = CurTime()
				
				PLUGIN.NetworkBulletUpdate(self)
			end
		end

		PLUGIN:RunHook("BulletPostThink", self)
	end

	local traces_materials = traces_materials or {}

	if(CLIENT)then
		function PLUGIN.Class_Bullet:Draw()
			local tracer_body = self.TracerSetings.TracerBody
			
			if(tracer_body)then
				local color = self.TracerSetings.TracerColor or color_white
				local size = math.max(self.Size, self.TracerSetings.TracerHeadSize or 5)
				
				render.SetMaterial(tracer_body)
				render.DrawSprite(self.Pos, size, size, color)
			end
			
			--=\\PLUG
				if(self.PathPoints)then
					local color = self.TracerSetings.TracerColor or color_white
				
					if(self.TracerSetings.TracerTail)then
						local material_name = self.TracerSetings.TracerTail:GetName()
						
						if(!traces_materials[material_name])then
							traces_materials[material_name] = CreateMaterial(material_name .. "_albedo", "UnlitGeneric", {
								["$basetexture"] = self.TracerSetings.TracerTail:GetTexture("$basetexture"),
								["$additive"] = 1,
								["$vertexalpha"] = 1,
								["$vertexcolor"] = 1
							})
						end
						
						render.SetMaterial(traces_materials[material_name])
						-- render.SetMaterial(self.TracerSetings.TracerTail)
					else
						render.SetColorMaterial()
					end
					
					render.StartBeam(math.min(#self.PathPoints, self.TracerSetings.MaxPathPoints))
					
					for i = math.max(#self.PathPoints - self.TracerSetings.MaxPathPoints, 1), #self.PathPoints do
						render.AddBeam(self.PathPoints[i], (self.TracerSetings.TracerWidth or 2) / 5, 1, color)
					end
					
					render.EndBeam()
				end
			--=//
		end
		
		function PLUGIN.Class_Bullet:AddPathPoint(pos)
			self.PathPoints = self.PathPoints or {}
			self.PathPoints[#self.PathPoints + 1] = pos
		
			if(#self.PathPoints >= self.TracerSetings.MaxPathPoints * 2)then
				self.PathPoints_Swap = self.PathPoints_Swap or {}
				self.PathPoints = self.PathPoints_Swap
				self.PathPoints_Swap = {}
			elseif(#self.PathPoints >= self.TracerSetings.MaxPathPoints)then
				self.PathPoints_Swap = self.PathPoints_Swap or {}
				self.PathPoints_Swap[#self.PathPoints_Swap + 1] = pos
			end
		end
	end

	function PLUGIN.Class_Bullet:GetPos()
		return self.Pos
	end

	function PLUGIN.Class_Bullet:SetPos(pos)
		self.Pos = pos
	end

	function PLUGIN.Class_Bullet:GetVelocity()
		return self.Vel
	end

	function PLUGIN.Class_Bullet:SetVelocity(vel)
		self.Vel = vel
	end

	function PLUGIN.Class_Bullet:ApplyForceCenter(vel)
		self.Vel = self.Vel + vel
	end

	function PLUGIN.Class_Bullet:Hit(trace, len, len_before)
		if(self.DieOnHit)then
			-- if(SERVER)then	--; WARNING
				self:Die()
				return
			-- end
		end
		
		local new_vel_normal, len, ricochet, ang_diff, stopped = PLUGIN.CalcHit(trace, len, len_before, self.TraceMask, self.Penetration, self.SizeMins, self.SizeMaxs)
		
		--[[if(stopped)then
			self:Die()

			return
		end--]]

		if(ricochet)then
			local len_subtract_frac = (90 - ang_diff) / 90
			local resist_mul = PLUGIN.CalcMaterialResist(self.PenetratingMaterial)
			len_before = len_before - math.min(resist_mul * self.AirResistMul * 140 * len_subtract_frac * len_before * len_before, len_before)	--; Не подтверждено ни чем
			len = math.min(len, len_before)
			
			if(SERVER)then
				local rnd = math.random(12)
				if rnd == 8 then rnd = 9 end
				sound.Play("arc9_eft_shared/ricochet/ricochet" .. rnd .. ".ogg", trace.HitPos, 75, math.random(90, 110))
				--sound.Play("snd_jack_hmcd_ricochet_" .. math.random(1, 2) .. ".wav", trace.HitPos, 75, math.random(90, 110))
				--sound.Play("weapons/arccw/ricochet0" .. math.random(1, 5) .. "_quiet.wav", trace.HitPos, 75, math.random(90, 110))
			end
			
			if(self.PostRicochet)then
				self:PostRicochet(new_vel_normal, len, ricochet, ang_diff, len_before, trace)
			end
		else
			self.Pos = self.Pos + new_vel_normal * 1
			self.PenetratingMaterial = trace.MatType
			self.PenetratingStartPos = trace.HitPos
			self.PenetratingTrace = trace
			
			if(trace.HitSky)then
				self.PenetratingSky = true
			else
				local resist_mul = PLUGIN.CalcMaterialResist(self.PenetratingMaterial, 1)
				local resist = math.min(resist_mul * self.AirResistMul / self.PhysPenetrationMul * 200000000 / self.Mass, len_before)	--; Не подтверждено ни чем
				len_before = len_before - resist
				len = math.min(len, len_before)
				-- self.AirResistMul = self.AirResistMul * 2
			end
			
			if(self.PostPenetration)then
				self:PostPenetration(new_vel_normal, len, ricochet, ang_diff, len_before, trace)
			end
			
			if(stopped)then
				if(self.OnStopped) then
					self:OnStopped(nil, "hit", trace)
				end

				self:Die()
			end
		end
		
		return new_vel_normal, len, len_before
	end

	function PLUGIN.Class_Bullet:Die()
		self:Remove()
	end

	function PLUGIN.Class_Bullet:Remove()
		if(self.PreRemove)then
			if(self:PreRemove() == false)then
				return
			end
		end

		self.Removed = true
		PLUGIN.BulletsTable[self.Key] = nil
		
		if(SERVER)then
			if(self.CreationTime ~= CurTime())then
				PLUGIN.NetworkBulletRemove(self)
			end
		end
		
		if(self.PostRemove)then
			self:PostRemove()
		end
	end
--//

--\\Creation
	function PLUGIN.CreateBullet(bullet)
		setmetatable(bullet, PLUGIN.Class_Bullet)
		translate_default_bullet_to_phys(bullet)
		
		bullet.AmmoID = bullet.AmmoID or 0
		bullet.Damage = bullet.Damage or 1
		bullet.AirResistMul = bullet.AirResistMul or 0.0001	--; AMMOID
		bullet.AirResistMul = bullet.AirResistMul / 5	--; Подтвердить вычислением
		bullet.Distance = bullet.Distance or 56756
		bullet.DistanceTraveled = 0
		bullet.LifeTime = bullet.LifeTime or 5
		bullet.LoseVelocity = bullet.LoseVelocity or 1	--; REDO
		bullet.Penetration = bullet.Penetration or 10
		define_if_not_defined(bullet, "DieOnHit", false)
		define_if_not_defined(bullet, "NoNetwork", false)
		define_if_not_defined(bullet, "NoNetworkUpdate", false)
		bullet.CreationTime = bullet.CreationTime or CurTime()
		bullet.LastUpdateTime = bullet.LastUpdateTime or bullet.CreationTime
		bullet.TraceFilter = bullet.TraceFilter or bullet.Shooter
		bullet.Key = bullet.Key or #PLUGIN.BulletsTable + 1
		bullet.HG_IsBullet = true
		PLUGIN.BulletsTable[bullet.Key] = bullet
		
		if(bullet.Damage == 0)then
			bullet.Damage = game.GetAmmoPlayerDamage(bullet.AmmoID) or 0
		end
		
		PLUGIN:RunHook("BulletPostSetup", bullet)
		
		local lag_compensate = false
		
		if(SERVER and bullet.Shooter:IsPlayer())then
			lag_compensate = true
			bullet.Vel = bullet.Vel + bullet.Shooter:GetVelocity()
		end
		
		if(lag_compensate)then
			bullet.Shooter:LagCompensation(true)
		end
		
		bullet:Think()
		
		if(lag_compensate)then
			bullet.Shooter:LagCompensation(false)
		end
		
		if(bullet.Num and bullet.Num > 1)then
			local new_bullet = copy_bullet(bullet)
			new_bullet.Num = new_bullet.Num - 1
			
			PLUGIN.CreateBullet(new_bullet)
		end

		if(SERVER and not bullet.Removed and not bullet.NoNetwork)then
			PLUGIN.NetworkBulletFull(bullet, nil)
		end
		
		PLUGIN:RunHook("BulletPostCreationNetwork", bullet)

		return bullet
	end
--//

--\\Calculations
	function PLUGIN.CalcMaterialResist(material, mul)
		return (PLUGIN.SurfaceHardness[material] or PLUGIN.DefaultSurfaceHardness) * (mul or 0.01)
	end

	function PLUGIN.CalcVelocityLostInMaterial(material, dist, len_before)
		local resist_mul = PLUGIN.CalcMaterialResist(material, 2)
		
		return math.max(len_before - resist_mul * dist, 0)
	end

	function PLUGIN.CalcHit(trace, len, len_before, trace_mask, penetration, size_mins, size_maxs)
		local trace_len = trace.Fraction * len
		local len_left = len - trace_len
		local trace_normal = trace.Normal
		local trace_hit_normal = trace.HitNormal
		local trace_angle = trace_normal:Angle()
		local surface_normal = trace.HitNormal
		
		--=\\
			local ricochet = true
			local stopped = false
			local ang_diff = -(math.deg(math.acos(trace_hit_normal:DotProduct(trace_normal))) - 180)	--; TODO
			local mat_hardness = PLUGIN.SurfaceHardness[trace.MatType] or PLUGIN.DefaultSurfaceHardness
			local penetration_mul = 1 - mat_hardness

			if(true)then	--; Доп вычисление REDO
				if(len_before < 2500)then
					ricochet = false
					stopped = true
				else
					--; Даже при большом угле считать пробитие поверхности для проверки на истинный рикошет
					local penetration_dist = len_before * penetration_mul * PLUGIN.FirstPenetrationMul
					local hull_trace = {}
					local move_vector = trace_normal * penetration_dist
					hull_trace.start = trace.HitPos + trace_normal * 1.0
					hull_trace.endpos = hull_trace.start + move_vector
					hull_trace.mask = trace_mask
					local trace_new = util.TraceLine(hull_trace)
					
					if(trace_new.HitTexture == "**studio**")then
						local max_penetrate_iterations = 5
						local one_penetrate_chunk = (move_vector) / max_penetrate_iterations
						
						for penetrate_iteration = 1, max_penetrate_iterations do
							hull_trace.start = trace.HitPos + one_penetrate_chunk * penetrate_iteration + trace_normal
							hull_trace.endpos = hull_trace.start - one_penetrate_chunk * penetrate_iteration - trace_normal
							hull_trace.mask = trace_mask
							hull_trace.mins = size_mins
							hull_trace.maxs = size_maxs
							local trace_penetrating = nil
							
							if(size_mins and size_maxs)then
								trace_penetrating = util.TraceHull(hull_trace)
							else
								trace_penetrating = util.TraceLine(hull_trace)
							end
							
							if(!trace_penetrating.StartSolid)then
								ricochet = false

								break
							else
								if penetrate_iteration == max_penetrate_iterations then
									stopped = true
								end
							end
						end
					else
						if(trace.HitSky)then
							ricochet = false
						elseif(!trace_new.AllSolid and trace.HitTexture != "**displacement**")then
							if(size_mins and size_maxs)then	--; DEPRECATED
								--
							else
								ricochet = false
							end
						end
					end
					
					if((90 - ang_diff + util.SharedRandom("Ricochet", -15, 15, CurTime() * 100)) > (60 * mat_hardness * 0.6))then
						ricochet = false
					end
				end
			end
		--=//
		
		local ricochet_frac = (90 - ang_diff) / 90
		local new_vel_normal = nil
		
		if(ricochet)then
			trace_angle:RotateAroundAxis(surface_normal, 180)
			
			new_vel_normal = -trace_angle:Forward()
			new_vel_normal = new_vel_normal + Vector(util.SharedRandom("Ricochet", -1, 1, CurTime() + 1) * 0.3, util.SharedRandom("Ricochet", -1, 1, CurTime() + 2) * 0.3, util.SharedRandom("Ricochet", -1, 1, CurTime() + 3) * 0.3) * ricochet_frac
			new_vel_normal:Normalize()
		else
			new_vel_normal = trace_normal
		end
		
		return new_vel_normal, len_left, ricochet, ang_diff, stopped
	end
--//

--\\Hooks
	PLUGIN:AddHook("Think", function()
		for key, bullet in pairs(PLUGIN.BulletsTable) do
			bullet:Think()
		end
	end)

	if(CLIENT)then
		PLUGIN:AddHook("PostDrawTranslucentRenderables", function(bDepth, bSkybox)
			if(not bSkybox)then
				for key, bullet in pairs(PLUGIN.BulletsTable) do
					bullet:Draw()	--; I wasn't able to do the think part and render part at the same time cause then it'll bounce even with game paused
				end
			end
		end)
	end
--//

hook.Add("PostCleanupMap", "PhysBullets", function()
	for key, bullet in pairs(PLUGIN.BulletsTable) do
		bullet:Die()
	end
end)

hook.Add("EntityFireBullets", "あPhysBullets", function(ent, bullet)
	if(GetGlobalBool("PhysBullets_ReplaceDefault", false))then
		if(SERVER)then
			if bullet.DontUsePhysBullets then return end

			if(!IsValid(bullet.IgnoreEntity))then
				bullet.IgnoreEntity = ent
			end

			bullet.Spread = bullet.Spread or vector_origin

			if isnumber(bullet.Spread) then
				bullet.Spread = Vector(bullet.Spread, bullet.Spread, 0)
			end

			-- bullet.NoGravity = true
			-- bullet.DieOnHit = true
			-- bullet.Damage = 0
			local att = bullet.Attacker
			
			PLUGIN.CreateBullet(bullet)
			-- hook.Run("PostEntityFireBullets", ent, bullet)
		end
		
		return false
	end
end)

--\\Includes
	-- PLUGIN:Include("sv_plugin.lua")
	-- PLUGIN:Include("cl_plugin.lua")
--//

