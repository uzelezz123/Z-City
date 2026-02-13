local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

hg.ConVars = hg.ConVars or {}

--\\ Is Changed
	local ChangedTable = {}

	function hg.IsChanged(val, id, meta)
		if(meta == nil)then
			meta = ChangedTable
		end

		if(meta.ChangedTable == nil)then
			meta["ChangedTable"] = {}
		end

		if(meta.ChangedTable[id] == val)then
			return false
		end

		meta.ChangedTable[id] = val
		return true
	end
--//
--\\ ishgweapon
	function ishgweapon(wep)
		if not wep or not IsValid(wep) then return false end
		return wep.ishgweapon
	end
--//
--\\ isVisible
	function hg.isVisible(pos1, pos2, filter, mask)
		return not util.TraceLine({
			start = pos1,
			endpos = pos2,
			filter = filter,
			mask = mask
		}).Hit
	end
--//
--\\ world size
	function hg.GetWorldSize()
		local world = game.GetWorld()

		local worldMin, worldMax = world:GetModelBounds()
		local size = worldMin:Distance(worldMax)

		return size
	end
--//
--\\ Is valid Player
	function hg.IsValidPlayer(ply)
		return IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply.organism
	end
--//
--\\ string funcs
	local function replace_by_index(str, index, char)
		return utf8.sub(str, 1, index - 1) .. char .. utf8.sub(str, index + 1)
	end

	local function utf8_reverse(codes, len)
		local characters = {}
		local characters2 = {}

		local curlen = 1

		for i, code in codes do
			characters[curlen] = utf8.char(code)
			curlen = curlen + 1
		end

		for i = 1, #characters do
			characters2[#characters - i + 1] = characters[i]
		end

		return table.concat(characters2)
	end

	hg.replace_by_index = replace_by_index
	hg.utf8_reverse = utf8_reverse
--//
--\\ custom KeyDown
	if CLIENT then
		net.Receive("ZB_KeyDown2", function(len)
			local key = net.ReadInt(26)
			local down = net.ReadBool()
			local ply = net.ReadEntity()
			if not IsValid(ply) then return end
			ply.keydown = ply.keydown or {}
			ply.keydown[key] = down
			if ply.keydown[key] == false then ply.keydown[key] = nil end
		end)
	end

	function hg.KeyDown(owner,key)
		if not IsValid(owner) then return false end
		owner.keydown = owner.keydown or {}
		local localKey
		if CLIENT then
			if owner == LocalPlayer() then
				localKey = owner.organism and owner:KeyDown(key) or false
			else
				localKey = owner.keydown[key]
			end
		end
		return SERVER and owner:IsPlayer() and owner:KeyDown(key) or CLIENT and localKey
	end
--//

--\\ BoneMatrix func
	local function setbonematrix(self, bone, matrix)
		do return end
		local parent = self:GetBoneParent(bone)
		parent = parent ~= -1 and parent or 0

		local matp = self.unmanipulated[parent] or self:GetBoneMatrix(parent)
		--print(matp:GetAngles(),parent)
		local new_matrix = matrix
		local old_matrix = self.unmanipulated[bone]

		local lmat = old_matrix:GetInverse() * new_matrix
		local ang = lmat:GetAngles()
		local vec, _ = WorldToLocal(new_matrix:GetTranslation(), angle_zero, old_matrix:GetTranslation(), matp:GetAngles())

		--self:ManipulateBonePosition(bone, vec)
		--self:ManipulateBoneAngles(bone, lmat:GetAngles())
		hg.bone.Set(self, bone, vector_origin, lmat:GetAngles(), "huy1")
	end

	function PLAYER:SetBoneMatrix2(boneID, matrix)
		setbonematrix(self, boneID, matrix)
	end

	function ENTITY:SetBoneMatrix2(boneID, matrix)
		setbonematrix(self, boneID, matrix)
	end
--//

--\\ Weighted Random Select
	function hg.WeightedRandomSelect(tab, mul)
		if not tab or not istable(tab) then return end
		mul = mul or 1
		local total_weight = 0

		for i = 1, #tab do
			total_weight = total_weight + tab[i][1]
		end
		local total_weight_with_mul = total_weight * (mul - 1)
		local random_weight = math.Rand(math.min(total_weight_with_mul,math.Rand(total_weight_with_mul/2,total_weight)), math.min(total_weight * mul,total_weight) )
		local current_weight = 0

		for i = 1, #tab do
			current_weight = current_weight + tab[i][1]
			--print(current_weight,random_weight,current_weight <= random_weight)
			if(current_weight >= random_weight)then
				return i, tab[i][2]
			end
		end
	end
--//
--\\ math funcs
	function qerp(delta, a, b)
		local qdelta = -(delta ^ 2) + (delta * 2)
		qdelta = math.Clamp(qdelta, 0, 1)

		return Lerp(qdelta, a, b)
	end

	FrameTimeClamped = 1/66
	ftlerped = 1/66

	local def = 1 / 144

	local FrameTime, TickInterval, engine_AbsoluteFrameTime = FrameTime, engine.TickInterval, engine.AbsoluteFrameTime
	local Lerp, LerpVector, LerpAngle = Lerp, LerpVector, LerpAngle
	local math_min = math.min
	local math_Clamp = math.Clamp

	local host_timescale = game.GetTimeScale

	hook.Add("Think", "Mul lerp", function()
		local ft = FrameTime()
		ftlerped = Lerp(0.5,ftlerped,math_Clamp(ft,0.001,0.1))
	end)

	function hg.FrameTimeClamped(ft)
		--do return math.Clamp(ft or ftlerped,0.001,0.1) end
		return math_Clamp(1 - math.exp(-0.5 * (ft or ftlerped) * host_timescale()), 0.000, 0.02)
	end

	local FrameTimeClamped_ = hg.FrameTimeClamped

	local function lerpFrameTime(lerp, frameTime)
		return math_Clamp(1 - lerp ^ (frameTime or ftlerped), 0, 1) -- * ( host_timescale() )
	end

	local function lerpFrameTime2(lerp, frameTime)
		--do return math_Clamp(lerp * ftlerped * 150,0,1) end
		--do return math_Clamp(1 - lerp ^ ftlerped,0,1) end
		if lerp == 1 then return 1 end
		return math_Clamp(lerp * FrameTimeClamped_(frameTime or ftlerped) * 150, 0, 1) -- * ( host_timescale() )
	end

	hg.lerpFrameTime2 = lerpFrameTime2
	hg.lerpFrameTime = lerpFrameTime

	function LerpFT(lerp, source, set)
		return Lerp(lerpFrameTime2(lerp), source, set)
	end

	function LerpVectorFT(lerp, source, set)
		return LerpVector(lerpFrameTime2(lerp), source, set)
	end

	function LerpAngleFT(lerp, source, set)
		return LerpAngle(lerpFrameTime2(lerp), source, set)
	end

	local max, min = math.max, math.min
	function util.halfValue(value, maxvalue, k)
		k = maxvalue * k
		return max(value - k, 0) / k
	end

	function util.halfValue2(value, maxvalue, k)
		k = maxvalue * k
		return min(value / k, 1)
	end

	function util.safeDiv(a, b)
		if a == 0 and b == 0 then
			return 0
		else
			return a / b
		end
	end
--//
--\\ GetListByName
	function player.GetListByName(name)
		local list = {}
		if name == "^" then
			return
		elseif name == "*" then
			return player.GetAll()
		end

		for i, ply in player.Iterator() do
			if string.find(string.lower(ply:Name()), string.lower(name)) then list[#list + 1] = ply end
		end
		return list
	end
--//
--\\ spiralGrid
	function hg.spiralGrid(rings)
		local grid = {}
		local col, row

		for ring=1, rings do -- For each ring...
			row = ring
			for col=1-ring, ring do -- Walk right across top row
				table.insert( grid, {col, row} )
			end

			col = ring
			for row=ring-1, -ring, -1 do -- Walk down right-most column
				table.insert( grid, {col, row} )
			end

			row = -ring
			for col=ring-1, -ring, -1 do -- Walk left across bottom row
				table.insert( grid, {col, row} )
			end

			col = -ring
			for row=1-ring, ring do -- Walk up left-most column
				table.insert( grid, {col, row} )
			end
		end

		return grid
	end
--//
--\\ Teleport func
	local hull = 10
	local HullMaxs = Vector(hull, hull, 72)
	local HullMins = -Vector(hull, hull, 0)
	local HullDuckMaxs = Vector(hull, hull, 36)
	local HullDuckMins = -Vector(hull, hull, 0)
	local ViewOffset = Vector(0, 0, 64)
	local ViewOffsetDucked = Vector(0, 0, 38)
	local Pos32 = Vector(0, 0, 32)

	local gridsize = 24
	local tpGrid = hg.spiralGrid(gridsize)
	local cell_size = 50

	function hg.tpPlayer(pos, ply, i, yaw, forced)
		if !tpGrid[i] then
			return hg.tpPlayer(pos, ply, math.random(gridsize), yaw, true)
		end

		local c = tpGrid[i][1]
		local r = tpGrid[i][2]

		local yawForward = yaw or 0
		local offset = Vector( r * cell_size, c * cell_size, 0 )
		offset:Rotate( Angle( 0, yawForward, 0 ) )

		local t = {}
		t.start = pos + Pos32
		t.collisiongroup = COLLISION_GROUP_WEAPON
		t.filter = player.GetAll()
		t.endpos = t.start + offset

		if !IsValid(ply) then
			t.hullmaxs = HullMaxs
			t.hullmins = HullMins
		end

		local tr
		if IsValid(ply) then
			tr = util.TraceEntity( t, ply )
		else
			tr = util.TraceHull(t)
		end

		if !tr.Hit or forced then
			if IsValid(ply) then ply:SetPos(tr.HitPos) end

			return tr.HitPos
		else
			return hg.tpPlayer(pos, ply, i + 1, yaw)
		end
	end
--//
//for i, ply in ipairs(player.GetAll()) do
//	hg.tpPlayer(Vector(44.917309, 1.110850, -82.409622), ply, i, 0)
//end

--\\ Vec Ang Clamp
	function hg.clamp(vecOrAng, val)
		vecOrAng[1] = math.Clamp(vecOrAng[1], -val, val)
		vecOrAng[2] = math.Clamp(vecOrAng[2], -val, val)
		vecOrAng[3] = math.Clamp(vecOrAng[3], -val, val)
		return vecOrAng
	end
--//
--\\ View Punch
	local PLAYER = FindMetaTable("Player")
	hg.SetEyeAngles = hg.SetEyeAngles or PLAYER.SetEyeAngles

	function PLAYER:SetEyeAngles(ang)
		if !self.lockcamera then
			hg.SetEyeAngles(self, ang)
		end
	end

	if CLIENT then
		local PUNCH_DAMPING = 5
		local PUNCH_SPRING_CONSTANT = 15
		vp_punch_angle = vp_punch_angle or Angle()
		local vp_punch_angle_velocity = Angle()
		vp_punch_angle_last = vp_punch_angle_last or vp_punch_angle

		vp_punch_angle2 = vp_punch_angle2 or Angle()
		local vp_punch_angle_velocity2 = Angle()
		vp_punch_angle_last2 = vp_punch_angle_last2 or vp_punch_angle2

		vp_punch_angle3 = vp_punch_angle3 or Angle()
		local vp_punch_angle_velocity3 = Angle()
		vp_punch_angle_last3 = vp_punch_angle_last3 or vp_punch_angle3

		vp_punch_angle4 = vp_punch_angle4 or Angle()
		local vp_punch_angle_velocity4 = Angle()
		vp_punch_angle_last4 = vp_punch_angle_last4 or vp_punch_angle4

		local fuck_you_debil = 0

		function hg.CalculateConsciousnessMul()
			local consciousness = 1

			if lply.organism and lply.organism.consciousness then
				consciousness = consciousness * lply.organism.consciousness
				consciousness = consciousness * math.Clamp(lply.organism.blood / 4000, 0.5, 1)
				consciousness = consciousness * math.Clamp(lply.organism.o2[1] / 20, 0.5, 1)
				--consciousness = consciousness * (lply.organism.larmamputated and 0.8 or 1) * (lply.organism.rarmamputated and 0.8 or 1)
				consciousness = consciousness * (1 - lply.organism.disorientation / 10)
			end

			return math.Clamp(((consciousness - 1) * 3 + 1), 0.4, 1)
		end

		hook.Add("Think", "viewpunch_think", function(ply, cmd)
			--if LocalPlayer():InVehicle() then return end

			local consmul = hg.CalculateConsciousnessMul()

			if not vp_punch_angle:IsZero() or not vp_punch_angle_velocity:IsZero() then
				vp_punch_angle = vp_punch_angle + vp_punch_angle_velocity * ftlerped * 1
				local damping = 1 - (PUNCH_DAMPING * ftlerped) * consmul
				if damping < 0 then damping = 0 end
				vp_punch_angle_velocity = vp_punch_angle_velocity * damping
				local spring_force_magnitude = PUNCH_SPRING_CONSTANT * ftlerped * 5 * consmul
				vp_punch_angle_velocity = vp_punch_angle_velocity - vp_punch_angle * spring_force_magnitude
				local x, y, z = vp_punch_angle:Unpack()
				vp_punch_angle = Angle(math.Clamp(x, -89, 89), math.Clamp(y, -179, 179), math.Clamp(z, -89, 89))
			else
				vp_punch_angle = Angle()
				vp_punch_angle_velocity = Angle()
			end

			if not vp_punch_angle2:IsZero() or not vp_punch_angle_velocity2:IsZero() then
				vp_punch_angle2 = vp_punch_angle2 + vp_punch_angle_velocity2 * ftlerped * 1
				local damping = 1 - (PUNCH_DAMPING * ftlerped) * consmul
				if damping < 0 then damping = 0 end
				vp_punch_angle_velocity2 = vp_punch_angle_velocity2 * damping
				local spring_force_magnitude = PUNCH_SPRING_CONSTANT * ftlerped * 5 * consmul
				vp_punch_angle_velocity2 = vp_punch_angle_velocity2 - vp_punch_angle2 * spring_force_magnitude
				local x, y, z = vp_punch_angle2:Unpack()
				vp_punch_angle2 = Angle(math.Clamp(x, -89, 89), math.Clamp(y, -179, 179), math.Clamp(z, -89, 89))
			else
				vp_punch_angle2 = Angle()
				vp_punch_angle_velocity2 = Angle()
			end

			if not vp_punch_angle3:IsZero() or not vp_punch_angle_velocity3:IsZero() then
				vp_punch_angle3 = vp_punch_angle3 + vp_punch_angle_velocity3 * ftlerped * 1
				local damping = 1 - (PUNCH_DAMPING * ftlerped) * consmul
				if damping < 0 then damping = 0 end
				vp_punch_angle_velocity3 = vp_punch_angle_velocity3 * damping
				local spring_force_magnitude = PUNCH_SPRING_CONSTANT * ftlerped * 5 * consmul
				vp_punch_angle_velocity3 = vp_punch_angle_velocity3 - vp_punch_angle3 * spring_force_magnitude
				local x, y, z = vp_punch_angle3:Unpack()
				vp_punch_angle3 = Angle(math.Clamp(x, -89, 89), math.Clamp(y, -179, 179), math.Clamp(z, -89, 89))
			else
				vp_punch_angle3 = Angle()
				vp_punch_angle_velocity3 = Angle()
			end

			if not vp_punch_angle4:IsZero() or not vp_punch_angle_velocity4:IsZero() then
				vp_punch_angle4 = vp_punch_angle4 + vp_punch_angle_velocity4 * ftlerped * 1
				local damping = 1 - (PUNCH_DAMPING * ftlerped) * consmul
				if damping < 0 then damping = 0 end
				vp_punch_angle_velocity4 = vp_punch_angle_velocity4 * damping
				local spring_force_magnitude = PUNCH_SPRING_CONSTANT * ftlerped * 5 * consmul
				vp_punch_angle_velocity4 = vp_punch_angle_velocity4 - vp_punch_angle4 * spring_force_magnitude
				local x, y, z = vp_punch_angle4:Unpack()
				vp_punch_angle4 = Angle(math.Clamp(x, -89, 89), math.Clamp(y, -179, 179), math.Clamp(z, -89, 89))
			else
				vp_punch_angle4 = Angle()
				vp_punch_angle_velocity4 = Angle()
			end

			--if not LocalPlayer():Alive() then vp_punch_angle:Zero() vp_punch_angle_velocity:Zero() vp_punch_angle2:Zero() vp_punch_angle_velocity2:Zero() end

			local consmulrev = 1 - consmul
			if vp_punch_angle:IsZero() and vp_punch_angle_velocity:IsZero() and vp_punch_angle2:IsZero() and vp_punch_angle_velocity2:IsZero() and vp_punch_angle3:IsZero() and vp_punch_angle_velocity3:IsZero() and  vp_punch_angle4:IsZero() and vp_punch_angle_velocity4:IsZero() then return end
			local add = vp_punch_angle - vp_punch_angle_last + vp_punch_angle2 - vp_punch_angle_last2 + vp_punch_angle3 - vp_punch_angle_last3 + vp_punch_angle4 * consmulrev - vp_punch_angle_last4 * consmulrev
			local ang = LocalPlayer():EyeAngles() + add

			LocalPlayer():SetEyeAngles(ang)
			vp_punch_angle_last = vp_punch_angle
			vp_punch_angle_last2 = vp_punch_angle2
			vp_punch_angle_last3 = vp_punch_angle3
			vp_punch_angle_last4 = vp_punch_angle4 * consmul
		end)

		function SetViewPunchAngles(angle)
			if not angle then
				print("[Local Viewpunch] SetViewPunchAngles called without an angle. wtf?")
				return
			end

			vp_punch_angle = angle
		end

		function SetViewPunchVelocity(angle)
			if not angle then
				print("[Local Viewpunch] SetViewPunchVelocity called without an angle. wtf?")
				return
			end

			vp_punch_angle_velocity = angle * 20
		end

		function Viewpunch(angle)
			if not angle then
				print("[Local Viewpunch] Viewpunch called without an angle. wtf?")
				return
			end

			vp_punch_angle_velocity = vp_punch_angle_velocity + angle * 20
		end

		function Viewpunch2(angle)
			if not angle then
				print("[Local Viewpunch] Viewpunch called without an angle. wtf?")
				return
			end

			vp_punch_angle_velocity2 = vp_punch_angle_velocity2 + angle * 20
		end

		function Viewpunch3(angle)
			if not angle then
				print("[Local Viewpunch] Viewpunch called without an angle. wtf?")
				return
			end

			vp_punch_angle_velocity3 = vp_punch_angle_velocity3 + angle * 20
		end

		function Viewpunch4(angle)
			if not angle then
				print("[Local Viewpunch] Viewpunch called without an angle. wtf?")
				return
			end

			vp_punch_angle_velocity4 = vp_punch_angle_velocity4 + angle * 20
		end

		function ViewPunch(angle)
			Viewpunch(angle)
		end

		function ViewPunch2(angle)
			Viewpunch2(angle)
		end

		function ViewPunch3(angle)
			Viewpunch3(angle)
		end

		function ViewPunch4(angle)
			Viewpunch4(angle)
		end

		function GetViewPunchAngles()
			return vp_punch_angle
		end

		function GetViewPunchAngles2()
			return vp_punch_angle2
		end

		function GetViewPunchAngles3()
			return vp_punch_angle3
		end

		function GetViewPunchAngles4()
			local consmul = hg.CalculateConsciousnessMul()

			return vp_punch_angle4 * (1 - consmul)
		end

		function GetViewPunchVelocity()
			return vp_punch_angle_velocity
		end

		function GetViewPunchVelocity2()
			return vp_punch_angle_velocity2
		end

		function GetViewPunchVelocity3()
			return vp_punch_angle_velocity3
		end

		function GetViewPunchVelocity4()
			return vp_punch_angle_velocity4
		end

		local prev_on_ground,current_on_ground,speedPrevious,speed = false,false,0,0
		local angle_hitground = Angle(0,0,0)
		hook.Add("Think", "CP_detectland", function()
			if IsValid(lply.FakeRagdoll) then return end
			prev_on_ground = current_on_ground
			current_on_ground = LocalPlayer():OnGround()

			speedPrevious = speed
			speed = -LocalPlayer():GetVelocity().z

			if prev_on_ground != current_on_ground and current_on_ground and LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP then
				angle_hitground.p = math.Clamp(speedPrevious / 25, 0, 20)

				ViewPunch(angle_hitground)
			end
		end)

		net.Receive("ViewPunch", function(len)
			local ang = net.ReadAngle()

			ViewPunch(ang)
		end)
	else
		local PLAYER = FindMetaTable("Player")

		util.AddNetworkString("ViewPunch")

		function PLAYER:ViewPunch(ang)
			net.Start("ViewPunch")
			net.WriteAngle(ang)
			net.Send(self)
		end
	end
--//
--\\ IsOnGround
	function hg.IsOnGround(ent)
		local tr = {}
		tr.start = ent:GetPos()
		tr.endpos = ent:GetPos() - vector_up * 10
		tr.filter = ent
		tr.mask = MASK_PLAYERSOLID
		return util.TraceEntityHull(tr,ent).Hit
	end
--//
--\\ nocollide player
	function ActivateNoCollision(target, min) // gmodwiki my beloved
		if !IsValid(target) then return end

		local oldCollision = COLLISION_GROUP_PLAYER
		target:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

		timer.Simple(min or 0, function()
			if !IsValid(target) then return end
			local i = 1
			local time = 30
			local checkdtime = 0.5
			timer.Create(target:SteamID64().."_checkBounds_cycle", checkdtime, math.Round(time / checkdtime), function()
				if !IsValid(target) then return end
				i = i + 1
				local penetrating = ( IsValid(target:GetPhysicsObject()) and target:GetPhysicsObject():IsPenetrating() ) or false
				local tooNearPlayer = false

				for i, ply in player.Iterator() do
					if ply == target then continue end
					if !ply:Alive() or IsValid(ply.FakeRagdoll) then continue end
					if target:GetPos():DistToSqr(ply:GetPos()) <= (24 * 24) then
						tooNearPlayer = true
					end
				end
				//print(target, penetrating, tooNearPlayer, target:GetCollisionGroup())

				if (!penetrating and !tooNearPlayer) or i >= (math.Round(time / checkdtime) - 1) then
					target:SetCollisionGroup(oldCollision)

					timer.Destroy(target:SteamID64().."_checkBounds_cycle")
				end
			end)
		end)
	end
--//
--\\ custom spawn
	gameevent.Listen("player_spawn")

	DEFAULT_JUMP_POWER = 200

	hook.Add("player_spawn", "homigrad-spawn3", function(data)
		local ply = Player(data.userid)
		if not IsValid(ply) then return end

		if CLIENT and ply == LocalPlayer() then
			vp_punch_angle = Angle()
			vp_punch_angle_last = Angle()
			vp_punch_angle2 = Angle()
			vp_punch_angle_last2 = Angle()
		end

		timer.Simple(0, function()
			if not IsValid(ply) then return end

			ply:SetWalkSpeed(100)
			ply:SetRunSpeed(350) -- 230

			ply:SetJumpPower(DEFAULT_JUMP_POWER)

			ply:SetHull(HullMins, HullMaxs)
			ply:SetHullDuck(HullDuckMins, HullDuckMaxs)
			ply:SetViewOffset(ViewOffset)
			ply:SetViewOffsetDucked(ViewOffsetDucked)

			ply:SetSlowWalkSpeed(60)
			ply:SetLadderClimbSpeed(150)
			ply:SetCrouchedWalkSpeed(60)
			ply:SetDuckSpeed(0.4)
			ply:SetUnDuckSpeed(0.4)
			ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
		end)

		if SERVER then
			ply:SetNetVar("carryent", nil)
			ply:SetNetVar("carrybone", nil)
			ply:SetNetVar("carrymass", nil)
			ply:SetNetVar("carrypos", nil)

			ply:SetNetVar("carryent2", nil)
			ply:SetNetVar("carrybone2", nil)
			ply:SetNetVar("carrymass2", nil)
			ply:SetNetVar("carrypos2", nil)
		end

		ply:SetNWEntity("spect", NULL)

		-- if CLIENT and ply:Alive() then ply:BoneScaleChange() end

		ply:SetHull(HullMins, HullMaxs)
		ply:SetHullDuck(HullDuckMins, HullDuckMaxs)
		ply:SetViewOffset(ViewOffset)
		ply:SetViewOffsetDucked(ViewOffsetDucked)

		ply:DrawShadow(true)
		ply:SetRenderMode(RENDERMODE_NORMAL)
		local ang = ply:EyeAngles()

		ply:RemoveFlags(FL_NOTARGET)


		ply.RenderOverride = function(self, flags)
			if not IsValid(self) or self:IsDormant() then return end
			local p,a = self:GetBonePosition(1)
			if not p or p:IsEqualTol(self:GetPos(), 0.01) then return end
			local ent = self.FakeRagdoll
			if IsValid(ent) then return end

			hg.renderOverride(self, ent, flags)
		end

		hook.Run("Player Getup", ply)

		local override = (CLIENT and hg.override[ply]) or (SERVER and OverrideSpawn)

		if eightbit and eightbit.EnableEffect and ply.UserID then
			eightbit.EnableEffect(ply:UserID(), ply.PlayerClassName == "furry" and eightbit.EFF_PROOT or 0)
		end

		if not override then
			hook.Run("Player Spawn", ply)

			if SERVER then
				timer.Simple(0, function() ActivateNoCollision(ply, 5) end)
			end

			if SERVER then
				ply.organism.lightstun = 0
				ply:SetLocalVar("stun", ply.organism.lightstun)
				ply.suiciding = false
			end

			ply.posture = 0
		end

		--hg.addbonecallback(ply)

		if IsValid(ply) and ply:Alive() and not IsValid(ply.bull) and SERVER then
			timer.Simple(1, function()
				if not IsValid(ply) or not ply:Alive() then return end
				ply.bull = ents.Create("npc_bullseye")
				local bull = ply.bull
				local bon = ply:LookupBone("ValveBiped.Bip01_Head1")
				local mat = bon and ply:GetBoneMatrix(bon)
				local pos = mat and mat:GetTranslation() or ply:EyePos()
				local ang = mat and mat:GetAngles() or ply:EyeAngles()
				bull:SetPos(pos)
				bull:SetAngles(ang)
				bull:SetMoveType(MOVETYPE_OBSERVER)
				bull:SetKeyValue("targetname", "Bullseye")
				bull:SetParent(ply, ply:LookupBone("ValveBiped.Bip01_Head1"))
				bull:SetKeyValue("health", "9999")
				bull:SetKeyValue("spawnflags", "256")
				bull:Spawn()
				bull:Activate()
				bull:SetNotSolid(true)
				--bull:SetSolidFlags(FSOLID_TRIGGER)
				--bull:SetCollisionGroup(COLLISION_GROUP_PLAYER)

				bull.ply = ply
				for i, ent in ipairs(ents.FindByClass("npc_*")) do
					if not IsValid(ent) or not ent.AddEntityRelationship then continue end
					ent:AddEntityRelationship(bull, ent:Disposition(ply))
				end
			end)
		end
	end)
--//
--\\ addbonecallback
	function hg.addbonecallback(ent)
		for i, callback in pairs(ent:GetCallbacks("BuildBonePositions")) do
			ent:RemoveCallback("BuildBonePositions", i)
		end

		ent:AddCallback("BuildBonePositions", hg.build_bone_positions)
	end
--//
--\\ RotateAroundPoints
	function hg.RotateAroundPoint(pos, ang, point, offset, offset_ang)
		local v = Vector(0, 0, 0)
		v = v + (point.x * ang:Right())
		v = v + (point.y * ang:Forward())
		v = v + (point.z * ang:Up())

		local newang = Angle()
		newang:Set(ang)

		newang:RotateAroundAxis(ang:Right(), offset_ang.p)
		newang:RotateAroundAxis(ang:Forward(), offset_ang.r)
		newang:RotateAroundAxis(ang:Up(), offset_ang.y)

		v = v + newang:Right() * offset.x
		v = v + newang:Forward() * offset.y
		v = v + newang:Up() * offset.z

		-- v:Rotate(offset_ang)

		v = v - (point.x * newang:Right())
		v = v - (point.y * newang:Forward())
		v = v - (point.z * newang:Up())

		pos = v + pos

		return pos, newang
	end

	function hg.RotateAroundPoint2(pos, ang, point, offset, offset_ang)

		local mat = Matrix()
		mat:SetTranslation(pos)
		mat:SetAngles(ang)
		mat:Translate(point)

		local rot_mat = Matrix()
		rot_mat:SetAngles(offset_ang)
		rot_mat:Invert()

		mat:Mul(rot_mat)

		mat:Translate(-point)

		mat:Translate(offset)

		return mat:GetTranslation(), mat:GetAngles()
	end
--//
local hook_Run = hook.Run
local IsValid = IsValid
--\\ Smooth UnRagdoll
	function hg.SmoothUnfake(ent, ply)
		if ply.gettingup and (ply.gettingup + 1 - CurTime()) > 0 and IsValid(ply) then
			for i = 0, ent:GetBoneCount() - 1 do
				local m1 = ent:GetBoneMatrix(i)
				local m2 = ply:GetBoneMatrix(i)

				if not m1 or not m2 then continue end

				local k = math_Clamp(1 - (ply.gettingup + 0.8 - CurTime()) / 0.8, 0, 1)

				local q1 = Quaternion()
				q1:SetMatrix(m1)

				local q2 = Quaternion()
				q2:SetMatrix(m2)

				local q3 = q1:SLerp(q2, k)

				local newmat = Matrix()
				newmat:SetTranslation(LerpVector(k, m1:GetTranslation(), m2:GetTranslation()))
				newmat:SetAngles(q3:Angle())
				newmat:SetScale(m1:GetScale())

				if i == ent:LookupBone("ValveBiped.Bip01_Head1") and lply == GetViewEntity() and lply == ply then
					newmat:SetScale(Vector(0.01, 0.01, 0.01))
					//ply.headm = newmat
				end

				ent:SetBoneMatrix(i, newmat)
				ply:SetBoneMatrix(i, newmat)
			end
		end
	end
--//
--\\ DrawPlayerRagdoll
	local hg_ragdollcombat = ConVarExists("hg_ragdollcombat") and GetConVar("hg_ragdollcombat") or CreateConVar("hg_ragdollcombat", 0, FCVAR_REPLICATED, "Toggle ragdoll combat-like ragdoll mode (walking, running in ragdoll, etc.)", 0, 1)
	
	function hg.RagdollCombatInUse(ply)
		return hg_ragdollcombat:GetBool() and IsValid(ply.FakeRagdoll)
	end
	
	local hg_firstperson_ragdoll = ConVarExists("hg_firstperson_ragdoll") and GetConVar("hg_firstperson_ragdoll") or CreateConVar("hg_firstperson_ragdoll", "0", FCVAR_ARCHIVE, "Toggle first-person ragdoll camera view", 0, 1) --!! unused??
	local hg_firstperson_death = ConVarExists("hg_firstperson_death") and GetConVar("hg_firstperson_death") or CreateClientConVar("hg_firstperson_death", "0", true, false, "Toggle first-person death camera view", 0, 1)
	local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like camera view", 0, 1)
	local hg_deathfadeout = CreateClientConVar("hg_deathfadeout", "1", true, true, "Toggle screen fade and sound mute on death", 0, 1)

	local vector_full = Vector(1, 1, 1)
	local vector_small = Vector(0.01, 0.01, 0.01)
	local angfuck = Angle()
	function DrawPlayerRagdoll(ent, ply)
		if ply.prevragdoll_index != nil and ply.prevragdoll_index != ply.ragdoll_index and ply.ragdoll_index == 0 then
			//print(ply.ragdoll_index, ply.prevragdoll_index, Entity(ply.ragdoll_index))

			ply.gettingup = CurTime()
			ply.OldRagdoll = Entity(ply.prevragdoll_index)
			ply.FakeRagdollOld = ply.OldRagdoll
		end
		ply.prevragdoll_index = ply.ragdoll_index

		local wep = ply.GetActiveWeapon and ply:GetActiveWeapon()

		local lkp = ent.LookupBone and ent:LookupBone("ValveBiped.Bip01_Head1")
		if !ent.GetManipulateBoneScale or !lkp then return end

		if IsValid(ply.OldRagdoll) then
			ply:SetupBones()
		end

		hg.RenderWeapons(ent, ply)

		ent:SetupBones()

		hg.MainTPIKFunction(ent, ply, wep)

		if IsValid(ply.OldRagdoll) then
			hg.SmoothUnfake(ent, ply)
		end

		if ply:GetNetVar("handcuffed", false) then hg.CuffedAnim(ent, ply) end

		if IsValid(wep) then
			//if wep.isTPIKBase then hg.RenderTPIKBase(ent, ply, wep) end
			//if wep.ismelee then hg.RenderMelees(ent, ply, wep) end
			if wep.DrawWorldModel2 then wep:DrawWorldModel2() end
		end

		local armors = ply:GetNetVar("Armor") or ent.PredictedArmor
		local hideArmorRender = ply:GetNetVar("HideArmorRender", false) or ent.PredictedHideArmorRender
		if armors and next(armors) and not hideArmorRender then
			RenderArmors(ply, armors, ent)
		end

		hg.RenderBandages(ent, ply)

		hg.RenderTourniquets(ent, ply)

		hg.GoreCalc(ent, ply)

		--local current = ent:GetManipulateBoneScale(lkp)
		local fountains = GetNetVar("fountains") or {}
		local wawanted = (GetViewEntity() != ply) and !fountains[ent] and (!(!lply:Alive() and lply:GetNWEntity("spect") == ply and viewmode == 1) and !(hg_firstperson_death:GetBool() and follow == ent)) and vector_full or vector_small
		--print(ent, wawanted, GetViewEntity(), ply, (GetViewEntity() != ply), !fountains[ent], !(!lply:Alive() and lply:GetNWEntity("spect") == ply and viewmode == 1))
		--if !current:IsEqualTol(wawanted, 0.01) then
			--ent:ManipulateBoneScale(lkp, wawanted)
			local mat = ent:GetBoneMatrix(lkp)
			
			if (!hg_gopro:GetBool() and (ent == ply or (!hg_ragdollcombat:GetBool() or hg_firstperson_ragdoll:GetBool()))) or (hg_firstperson_death:GetBool() and follow == ent) then
				mat:SetScale(wawanted)
			end
			--angfuck[3] = -GetViewPunchAngles2()[2] - GetViewPunchAngles3()[2]

			--local _, ang = LocalToWorld(vector_origin, angfuck, vector_origin, mat:GetAngles())
			--mat:SetAngles(ang)

			hg.bone_apply_matrix(ent, lkp, mat)
		--end

		--hg.CoolGloves(ent, ply, wep)

		hg.ProjectilesDraw(ent, ply)

		if ply:GetNetVar("headcrab") then hg.RenderHeadcrab(ent, ply) end
	end
--//
--\\ Is Local
	function hg.IsLocal(ent)
		if SERVER then return true end
		return lply:Alive() and (lply == ent) or (lply:GetNWEntity("spect") == ent)
	end
--//
--\\ custom build_bone_positions
	function hg.build_bone_positions(self, count)
		local ply, ent

		if self:IsRagdoll() then
			ply = self:GetNWEntity("ply")		
			ent = self
		else
			ply = self
			ent = IsValid(self.FakeRagdoll) and self.FakeRagdoll or self
		end

		if IsValid(ply.FakeRagdollOld) then ent = ply.FakeRagdollOld end

		DrawPlayerRagdoll(ent, ply)
	end
--//
--\\ Render Override
	hg.renderOverride = function(self, ent, flags)
		if bit.band(flags, STUDIO_RENDER) != STUDIO_RENDER then return end
		--if self == lply and !selfdraw then return end
		--debug.Trace()
		if !self.shouldTransmit then return end

		ent = IsValid(ent) and ent or self

		if not IsValid(ent) then return end

		--local drawornot = hook_Run("PreDrawPlayer2", ent, self) // true means nodraw
		--if drawornot then return end

		DrawPlayerRagdoll(ent, self)
		RenderAccessoriesCool(ent, self)
		//hg.HomigradBones(self, CurTime(), FrameTime())

		if IsValid(self.OldRagdoll) then DrawAppearance(ent, self, true) end
		if !hg.converging[self] then
			ent:DrawModel()
		else
			DrawConversion(ent, self)
		end
		if IsValid(self.OldRagdoll) then
			DrawAppearance(ent, self)
		else
			DrawAppearance(ent, self)
		end

		hook_Run("PostDrawAppearance", ent, self)
	end
--//

--\\ Lean Lerp
	if CLIENT then
		oldlean = oldlean or 0
		lean_lerp = lean_lerp or 0
		curlean = curlean or 0
		unmodified_angle = unmodified_angle or 0
		local time = SysTime() - 0.01
		hook.Add("Think", "leanin", function()
			local ply = LocalPlayer()
			local angles = ply:EyeAngles()

			local dtime = SysTime() - time
			time = SysTime()

			local lean = (ply.lean or 0)
			lean_lerp = LerpFT(hg.lerpFrameTime2(1,dtime), lean_lerp, lean)
		end)
	end
--//
--\\ Player Spawn - Override Spawn
	hook.Add("Player Spawn","default-thingies",function(ply)
		if OverrideSpawn then return false end
	end)
--//
--\\ gameevents
	gameevent.Listen("player_disconnect")
	hook.Add("player_disconnect", "hg-disconnect", function(data)
		hook.Run("Player Disconnected", data)
	end)

	gameevent.Listen( "player_activate" )
	hook.Add("player_activate","player_activatehg",function(data)
		local ply = Player(data.userid)
		if not IsValid(ply) then return end

		hook.Run("Player Activate", ply)
		if SERVER and ply.SyncVars then ply:SyncVars() end
	end)

	gameevent.Listen("entity_killed")
	hook.Add("entity_killed", "homigrad-death", function(data)
		local ply = Entity(data.entindex_killed)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		hook.Run("Player_Death", ply)
	end)
--//
--\\ IsLookingAt
	function IsLookingAt(ply, targetVec, floatDiff)
		if not IsValid(ply) or not ply:IsPlayer() then return false end
		local diff = targetVec - ply:GetShootPos()
		return ply:GetAimVector():Dot(diff) / diff:Length() >= (floatDiff or 0.8)
	end
--//
--\\ Custom Hull check
	local lend = 3
	local vec = Vector(lend,lend,lend)
	local traceBuilder = {
		mins = -vec,
		maxs = vec,
		mask = MASK_SOLID,
		collisiongroup = COLLISION_GROUP_DEBRIS
	}

	local util_TraceHull = util.TraceHull

	function hg.hullCheck(startpos, endpos, ply)
		//if ply.lasthulltrace == CurTime() and ply.cachedhulltrace then return ply.cachedhulltrace end
		//ply.lasthulltrace = CurTime()
		if ply:InVehicle() then return {HitPos = endpos} end
		traceBuilder.start = IsValid(ply.FakeRagdoll) and endpos or startpos
		traceBuilder.endpos = endpos
		traceBuilder.filter = {ply, ply.FakeRagdoll, ply:InVehicle() and ply:GetVehicle(), ply.OldRagdoll}
		local trace = util_TraceHull(traceBuilder)

		ply.cachedhulltrace = trace

		return trace
	end
--//
--\\ Custom ents trace functions
	local lpos = Vector(6, 2, 1)--Vector(5,0,7)
	local lang = Angle(0, 0, 0)

	function hg.torsoTrace(ply, dist, ent, aim_vector)
		local ent = (IsValid(ent) and ent) or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
		local bon = ent:LookupBone("ValveBiped.Bip01_Spine4")
		if not bon then return end
		local mat = ent:GetBoneMatrix(bon)
		if not mat then return end

		local aim_vector = aim_vector or ply:GetAimVector()

		local pos, ang = LocalToWorld(lpos, lang, mat:GetTranslation(), mat:GetAngles())// aim_vector:Angle())

		return hg.eyeTrace(ply, dist, ent, aim_vector, pos)
	end

	function hg.eye(ply, dist, ent, aimvec, startpos)
		if !ply:IsPlayer() then return false end
		local fakeCam = false//IsValid(ent) and ent != ply
		local ent = (IsValid(ent) and ent) or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
		local bon = ent:LookupBone("ValveBiped.Bip01_Neck1")
		if not bon then return end
		if not IsValid(ply) then return end
		if not ply.GetAimVector then return end

		local aim_vector = isvector(aimvec) and aimvec or isangle(aimvec) and aimvec:Forward() or ply:GetAimVector()

		if not bon or not ent:GetBoneMatrix(bon) then
			local tr = {
				start = ply:EyePos(),
				endpos = ply:EyePos() + aim_vector * (dist or 60),
				filter = ply
			}
			return ply:EyePos(), aim_vector * (dist or 60), ply//util.TraceLine(tr)
		end

		/*if (ply.InVehicle and ply:InVehicle() and IsValid(ply:GetVehicle())) then
			local veh = ply:GetVehicle()
			local vehang = veh:GetAngles()
			local tr = {
				start = ply:EyePos() + vehang:Right() * -6 + vehang:Up() * 4,
				endpos = ply:EyePos() + aim_vector * (dist or 60),
				filter = ply
			}
			return util.TraceLine(tr), nil, headm
		end*/

		local headm = ent:GetBoneMatrix(bon)

		//if CLIENT and IsValid(ply.OldRagdoll) then
		//	headm = ply.headm or headm
		//end
		//ply.headm = nil
		--local att_ang = ply:GetAttachment(ply:LookupAttachment("eyes")).Ang
		--ply.lerp_angle = LerpFT(0.1, ply.lerp_angle or Angle(0,0,0), ply:GetNWBool("TauntStopMoving", false) and att_ang or aim_vector:Angle())
		--aim_vector = ply.lerp_angle:Forward()

		local eyeAng = aim_vector:Angle()
		eyeAng.r = isangle(aimvec) and aimvec.r or ply:EyeAngles().r

		local eyeang2 = aim_vector:Angle()
		--eyeang2.p = 0
		eyeang2.r = isangle(aimvec) and aimvec.r or ply:EyeAngles().r

		//local pos = startpos or headm:GetTranslation() + (fakeCam and (headm:GetAngles():Forward() * 5 + headm:GetAngles():Up() * 0 + headm:GetAngles():Right() * 6) or (eyeAng:Up() * 1 + eyeang2:Forward() * 4))
		local pos = startpos or headm:GetTranslation() + (fakeCam and (headm:GetAngles():Forward() * 2 + headm:GetAngles():Up() * -2 + headm:GetAngles():Right() * 3) or (eyeAng:Up() * 2 + headm:GetAngles():Right() * 4 + headm:GetAngles():Up() * 0  + headm:GetAngles():Forward() * (4 + (ply.PlayerClassName == "Combine" and 4 or 0))))

		local trace = hg.hullCheck(ply:EyePos() - vector_up * 10, pos, ply)

		--[[if CLIENT then
			cam.Start3D()
				render.DrawWireframeBox(trace.HitPos,angle_zero,traceBuilder.mins,traceBuilder.maxs,color_white)
			cam.End3D()
		end--]]

		//local tr = {}
		//tr.start = trace.HitPos
		//tr.endpos = tr.start + aim_vector * (dist or 60)
		//tr.filter = {ply,ent}

		return trace.HitPos, aim_vector * (dist or 60), {ply, ent, ply.OldRagdoll}, trace, headm//util.TraceLine(tr), trace, headm
	end

	function hg.eyeTrace(ply, dist, ent, aim_vector, startpos, fFilter)
		local start, aim, filter, trace, headm = hg.eye(ply, dist, ent, aim_vector, startpos)
		if not start then return end
		--if ply.lasteyetrace == RealTime() and ply.cachedeyetrace and (ply.lasteyetracedist == dist) then return ply.cachedeyetrace, trace, headm end
		--ply.lasteyetrace = RealTime()
		--ply.lasteyetracedist = dist

		--why this shit doesnt work

		if not isvector(start) then return end
		ply.cachedeyetrace = util.TraceLine({
			start = start,
			endpos = start + aim,
			filter = fFilter or filter
		})
		return ply.cachedeyetrace, trace, headm
	end
--//
--\\ is driveable vehicle
	local chairclasses = {
		["prop_vehicle_prisoner_pod"] = true,
	}

	function hg.isdriveablevehicle(veh)
		if not IsValid(veh) then return false end

		if chairclasses[veh:GetClass()] then return false end

		return true
	end
--//

--\\ Suicide
	if SERVER then
		concommand.Add("suicide", function(ply)
			ply.suiciding = !ply.suiciding
		end)
	end

	function hg.CanSuicide(ply)
		if not IsValid(ply) or not ply.GetActiveWeapon then return false end
		local wep = ply:GetActiveWeapon()
		return ishgweapon(wep) and wep.CanSuicide and not wep.reload
	end
--//
--\\ Calculate Weight 
	function hg.CalculateWeight(ply,maxweight)
		local weight = 0

		local weps = ply:GetWeapons()

		for i,wep in ipairs(weps) do
			weight = weight + (wep.weight or 1)
		end

		weight = math.max(weight - 1,0)

		local ammo = ply:GetAmmo()
		for id,count in pairs(ammo) do
			weight = weight + (game.GetAmmoForce(id) * count) / 1500
		end

		ply.armors = ply:GetNetVar("Armor",{})
		for plc,arm in pairs(ply.armors) do
			weight = weight + (hg.armor[plc][arm].mass or 1)
		end

		local weightmul = (1 / (weight / maxweight + 1))
		return weightmul
	end
--//
--\\ Shared custom ragdoll mass
	hg.IdealMassPlayer = {
		["ValveBiped.Bip01_Pelvis"] = 12.775918006897,
		["ValveBiped.Bip01_Spine1"] = 24.36336517334,
		["ValveBiped.Bip01_Spine2"] = 24.36336517334,
		["ValveBiped.Bip01_R_UpperArm"] = 3.4941370487213,
		["ValveBiped.Bip01_L_UpperArm"] = 3.441034078598,
		["ValveBiped.Bip01_L_Forearm"] = 1.7655730247498,
		["ValveBiped.Bip01_L_Hand"] = 1.0779889822006,
		["ValveBiped.Bip01_R_Forearm"] = 1.7567429542542,
		["ValveBiped.Bip01_R_Hand"] = 1.0214320421219,
		["ValveBiped.Bip01_R_Thigh"] = 10.212161064148,
		["ValveBiped.Bip01_R_Calf"] = 4.9580898284912,
		["ValveBiped.Bip01_Head1"] = 5.169750213623,
		["ValveBiped.Bip01_L_Thigh"] = 10.213202476501,
		["ValveBiped.Bip01_L_Calf"] = 4.9809679985046,
		["ValveBiped.Bip01_L_Foot"] = 2.3848159313202,
		["ValveBiped.Bip01_R_Foot"] = 2.3848159313202
	}
--//
--\\ Taunts edits
	function TauntCamera()

		local CAM = {}
		CAM.ShouldDrawLocalPlayer = function( self, ply, on )
			return
		end
		CAM.CalcView = function( self, view, ply, on )
			return
		end
		CAM.CreateMove = function( self, cmd, ply, on )
			return
		end

		return CAM

	end

	local player_default = baseclass.Get( "player_default" )

	player_default.TauntCam = TauntCamera()

	player_manager.RegisterClass( "player_default", player_default, nil )

	local taunt_function_start = {
		[ACT_GMOD_TAUNT_CHEER] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_TAUNT_LAUGH] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_TAUNT_MUSCLE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_TAUNT_DANCE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_TAUNT_PERSISTENCE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_GESTURE_TAUNT_ZOMBIE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_GESTURE_BOW] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_TAUNT_ROBOT] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
		[ACT_GMOD_GESTURE_AGREE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
		[ACT_SIGNAL_HALT] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
		[ACT_GMOD_GESTURE_BECON] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
		[ACT_GMOD_GESTURE_DISAGREE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
		[ACT_GMOD_TAUNT_SALUTE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
		[ACT_GMOD_GESTURE_WAVE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
		[ACT_SIGNAL_FORWARD] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
		[ACT_SIGNAL_GROUP] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	}

	local function stop_taunt(ply)
		ply:SetNWBool("TauntStopMoving", false)
		ply:SetNWBool("TauntLeftHand", false)
		ply:SetNWBool("TauntHolsterWeapons", false)
		ply:SetNWBool("IsTaunting", false)

		if timer.Exists("TauntHG"..ply:EntIndex()) then
			timer.Remove("TauntHG"..ply:EntIndex())
		end

		ply.CurrentActivity = nil
	end

	hook.Add("Player Getup", "TauntEndHG", function(ply, act, length)
		stop_taunt(ply)
	end)

	hook.Add("Fake", "TauntEndHG", function(ply)
		stop_taunt(ply)
	end)

	hook.Add("PlayerStartTaunt", "TauntRecordHG", function(ply, act, length)
		if not taunt_function_start[act] then return end

		taunt_function_start[act](ply, act, length)
		ply:SetNWBool("IsTaunting", true)
		ply:SetNWFloat("StartTaunt", CurTime())

		ply.CurrentActivity = act

		timer.Create("TauntHG" .. ply:EntIndex(), length - 0.3, 1, function()
			if not ply:GetNWBool("IsTaunting", false) then return end

			stop_taunt(ply)

			ply:SetNWBool("IsTaunting", false)
		end)
	end)
--//
--\\ some experemental code
	-- if CLIENT then
	-- 	local function changePosture()
	-- 		RunConsoleCommand("hg_change_standposture", -1)
	-- 	end

	-- 	local function resetPosture()
	-- 		RunConsoleCommand("hg_change_standposture", 0)
	-- 	end

	-- 	hook.Add("radialOptions", "standing_posture", function()
	-- 		do return end

	-- 		local ply = LocalPlayer()
	-- 		local organism = ply.organism or {}
	-- 		local wep = ply:GetActiveWeapon()
	-- 		if IsValid(wep) and wep:GetClass() == "weapon_hands_sh" and not wep:GetFists() and not organism.otrub then
	-- 			local tbl = {changePosture, "Change Stand Posture"}
	-- 			hg.radialOptions[#hg.radialOptions + 1] = tbl
	-- 			--local tbl = {resetPosture, "Reset Stand Posture"}
	-- 			--hg.radialOptions[#hg.radialOptions + 1] = tbl
	-- 		end
	-- 	end)

	-- 	local printed
	-- 	concommand.Add("hg_change_standposture", function(ply, cmd, args)
	-- 		if not args[1] and not isnumber(args[1]) and not printed then print([[я такой газовый чэловек]]) printed = true end
	-- 		local pos = math.Round(args[1] or -1)
	-- 		net.Start("change_standposture")
	-- 		net.WriteInt(pos, 8)
	-- 		net.SendToServer()
	-- 	end)

	-- 	net.Receive("change_standposture", function()
	-- 		local ply = net.ReadEntity()
	-- 		local pos = net.ReadInt(8)

	-- 		ply.standposture = pos
	-- 	end)
	-- else
	-- 	util.AddNetworkString("change_standposture")
	-- 	net.Receive("change_standposture", function(len, ply)
	-- 		local pos = net.ReadInt(8)
	-- 		do return end
	-- 		if (ply.change_posture_cooldown or 0) > CurTime() then return end
	-- 		ply.change_posture_cooldown = CurTime() + 0.1

	-- 		if pos ~= -1 then 
	-- 			if pos == ply.standposture then
	-- 				ply.standposture = 0
	-- 				pos = 0
	-- 			else
	-- 				ply.standposture = pos 
	-- 			end
	-- 		else
	-- 			ply.standposture = ply.standposture or 0
	-- 			ply.standposture = (ply.standposture + 1) >= 3 and 0 or ply.standposture + 1
	-- 		end
	-- 		net.Start("change_standposture")
	-- 		net.WriteEntity(ply)
	-- 		net.WriteInt(ply.standposture, 9)
	-- 		net.Broadcast()
	-- 	end)
	-- end
--//
--\\ AddForceRag
	function hg.AddForceRag(ply, physbone, force, time)
		if !IsValid(ply) or !ply:IsPlayer() then return end
		if ply:IsRagdoll() then
			local phys = ply:GetPhysicsObjectNum(physbone)

			if IsValid(phys) then
				phys:ApplyForceCenter(force)
			end

			return
		end

		ply.AddForceRag = ply.AddForceRag or {}
		ply.AddForceRag[physbone] = ply.AddForceRag[physbone] or {}

		local restforce = math.max(((ply.AddForceRag[physbone][1] or CurTime()) - CurTime()), 0) / 0.25 * (ply.AddForceRag[physbone][2] or vector_origin)
		local resttime = (ply.AddForceRag[physbone][1] or CurTime())

		ply.AddForceRag[physbone][2] = restforce + force
		ply.AddForceRag[physbone][1] = CurTime() + 0.25
	end
--//
--\\ Add RemoveKey do CMoveData
	local CMoveData = FindMetaTable( "CMoveData" )

	function CMoveData:RemoveKeys( keys )
		local newbuttons = bit.band( self:GetButtons(), bit.bnot( keys ) )
		self:SetButtons( newbuttons )
	end

	function CMoveData:RemoveKey( keys )
		local newbuttons = bit.band( self:GetButtons(), bit.bnot( keys ) )
		self:SetButtons( newbuttons )
	end
--//
--\\ Custom movement

	--\\ Antibhop accelerate (not used anyway)
		-- hook.Add("OnPlayerHitGround", "Movement", function(ply, inWater, onFloater, speed)
		-- 	local vel = ply:GetVelocity()

		-- 	if(ply.MovementInertia and vel:LengthSqr() > 10000)then
		-- 		//ply.MovementInertia = ply.MovementInertia + (vel / vel:Length() * math.abs(vel[3])) * 0.75
		-- 	end
		-- end)
	--//

	--\\Сайд мувы калькуляция для движения ниже
		--; Математический анал (не анализ)
		local function calc_vector2d_angle(vector)
			return math.deg(math.atan2(vector.y, vector.x))
		end

		local function calc_forward_side_moves(inertia, ply_angles)
			local ply_angle = ply_angles.y
			local inertia_angle = calc_vector2d_angle(inertia)
			local angdiff = math.AngleDifference(inertia_angle, ply_angle)

			return math.cos(math.rad(angdiff)), -math.sin(math.rad(angdiff))
		end

		local function calc_forward_side_moves_to_vector2d(fm, sm, ply_angles)
			local ply_angle = ply_angles.y
			--ply_angle = ply_angle + (CLIENT and offsetView[2] or 0)

			local vec = Vector(fm * math.cos(math.rad(ply_angle)) - sm * math.cos(math.rad(ply_angle + 90)), fm * math.sin(math.rad(ply_angle)) - sm * math.sin(math.rad(ply_angle + 90)), 0)

			return vec:GetNormalized()
		end

		local function approach_vector(vector_from, vector_to, change)
			return Vector(math.Approach(vector_from.x, vector_to.x, change), math.Approach(vector_from.y, vector_to.y, change), math.Approach(vector_from.z, vector_to.z, change))
		end

		local function approach_vector_smooth(vector_from, vector_to, lerp)
			return Vector(Lerp(lerp, vector_from.x, vector_to.x), Lerp(lerp, vector_from.y, vector_to.y), Lerp(lerp, vector_from.z, vector_to.z))
		end

		hg.approach_vector = approach_vector
	--//

	local hg_movement_stamina_debuff = CreateConVar("hg_movement_stamina_debuff","0.3",{FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY},"Multiply movement debuff when having low stamina",0,1)
	local vecZero = Vector()
	local vomitVPAng = Angle(1,0,0)
	hook.Add("SetupMove", "HG(StartCommand)", function(ply, mv, cmd)
		--if CLIENT then return end
		-- if(1)then return end
		--if CLIENT and ply ~= LocalPlayer() then return end
		--\\DeltaTime
		ply.LastStartCommand = ply.LastStartCommand or SysTime()
		local delta_time = SysTime() - ply.LastStartCommand--FrameTime()
		ply.LastStartCommand = SysTime()
		--//

		if(not IsValid(ply) or not ply:Alive())then
			return
		end

		local org = ply.organism

		if( ( not org ) or ( not org.brain ) )then
			return
		end

		if !hg.RagdollCombatInUse(ply) and (IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdollOld"))) then
			if IsValid(ply.FakeRagdoll) then
				cmd:SetForwardMove(0)
				cmd:SetSideMove(0)

				mv:SetForwardSpeed(0)
				mv:SetSideSpeed(0)
			end

			mv:SetForwardSpeed(math.min(mv:GetForwardSpeed(), 50))
			mv:SetSideSpeed(math.min(mv:GetSideSpeed(), 50))

			cmd:RemoveKey(IN_JUMP)
			mv:RemoveKey(IN_JUMP)

			cmd:AddKey(IN_DUCK)
			mv:AddKey(IN_DUCK)
		end

		if(ply:GetMoveType() == MOVETYPE_NOCLIP)then
			hook.Run("HG_MovementCalc", vecZero, 0, 1, ply, cmd, mv)
			hook.Run("HG_MovementCalc_2", {1}, ply, cmd, mv)

			return
		end

		if(ply:InVehicle())then
			return
		end

		local runnin = ply:KeyDown(IN_SPEED) and not ply:Crouching()

		if runnin then
			--mv:SetSideSpeed(0) --meh
			--cmd:SetSideMove(0)
			cmd:RemoveKey(IN_BACK)
		end

		local wep = ply:GetActiveWeapon()
		local vel = ply:GetVelocity()
		local velLen = vel:Length()
		local fm = cmd:GetForwardMove() * (org.brain and org.brain > 0.1 and math.sin(CurTime() / 2) or 1)
		local sm = cmd:GetSideMove() * (org.brain and org.brain > 0.1 and math.sin(CurTime() / 2) or 1)

		local slow_walking = ply:KeyDown(IN_WALK)
		local aiming = ply:KeyDown(IN_ATTACK2) and wep and IsValid(wep) and ishgweapon(wep)
		local walk_speed = ply:GetWalkSpeed()
		local slow_walk_speed = ply:GetSlowWalkSpeed()
		local crouch_walk_speed = ply:GetCrouchedWalkSpeed()
		local weightmul = hg.CalculateWeight(ply, 140)
		local rag = hg.GetCurrentCharacter(ply)
		ply.weightmul = weightmul
		weightmul = math.max(weightmul > 0.9 and 1 or weightmul / 0.9, 0.1)

		--\\ Experimental pz-like sprint code
			--[[ply:SetRunSpeed((IsValid(wep) and wep ~= NULL and wep:GetClass() == "weapon_hands_sh" and slow_walking) and 390 or 230)
			if IsValid(wep) and wep ~= NULL and wep:GetClass() == "weapon_hands_sh" and runnin and slow_walking then
				mv:SetSideSpeed(0)
				cmd:SetSideMove(0)
				cmd:RemoveKey(IN_BACK)
			end]]
		--//

		--ply:SetRunSpeed(350)

		if ply:GetNWBool("TauntHolsterWeapons", false) then
			if IsValid(ply:GetWeapon("weapon_hands_sh")) then
				cmd:SelectWeapon(ply:GetWeapon("weapon_hands_sh"))
				if SERVER then ply:SelectWeapon(ply:GetWeapon("weapon_hands_sh")) end
			end
		end

		if org.brain and org.brain > 0.05 then
			local brainadjust = org.brain > 0.05 and math.Clamp(((org.brain - 0.05) * math.sin(CurTime() + 10) * 20), -2, 2) or 0

			if brainadjust > 1 then
				local in_jump = cmd:KeyDown(IN_JUMP)

				if in_jump then
					cmd:RemoveKey(IN_JUMP)
					cmd:AddKey(IN_DUCK)
					mv:RemoveKey(IN_JUMP)
					mv:AddKey(IN_DUCK)
				end
			end

			if brainadjust < -1 then
				local in_duck = cmd:KeyDown(IN_DUCK)

				if in_duck then
					cmd:RemoveKey(IN_DUCK)
					cmd:AddKey(IN_JUMP)
					mv:RemoveKey(IN_DUCK)
					mv:AddKey(IN_JUMP)
				end
			end
		end

		if ply:GetNetVar("vomiting", 0) > CurTime() then
			cmd:AddKey(IN_DUCK)
			mv:AddKey(IN_DUCK)
			if ply == lply then ViewPunch(vomitVPAng) end
		end

		--\\Running
		ply.CurrentSpeed = ply.CurrentSpeed or walk_speed
		ply.CurrentFrictionMul = ply.CurrentFrictionMul or 1
		ply.FrictionGainMul = 0.01
		ply.FrictionLoseMul = 0.2
		ply.SpeedGainMul = 240 * weightmul * (ply.organism.superfighter and 5 or 1) * (ply:GetNWInt("SpeedGainClassMul", 1) or 1)
		ply.SpeedLoseMul = 540
		ply.SpeedSharpLoseMul = 0.007
		ply.InertiaBlend = 2000 * weightmul * (ply.organism.superfighter and 100 or 1)
		ply.DuckingSlowdown = ply.DuckingSlowdown or 0
		-- ply.InertiaBlend = 15 * weightmul * ply.CurrentFrictionMul
		local inertia_blend_mul = 1

		if(velLen <= slow_walk_speed)then
			inertia_blend_mul = 3
		end

		--[[
		if ply.WasDucking and not ply:KeyDown(IN_DUCK) then
			ply.WasDucking = false
			ply.DuckingSlowdown = math.Approach(ply.DuckingSlowdown,5,delta_time * 5000)
		end

		ply:SetDuckSpeed(0.4 * (5 - ply.DuckingSlowdown) / 5)
		ply:SetUnDuckSpeed(0.4 * (5 - ply.DuckingSlowdown) / 5)

		ply.WasDucking = ply:KeyDown(IN_DUCK)
		ply.DuckingSlowdown = math.Approach(ply.DuckingSlowdown,0,-delta_time * 1)
		--]]

		ply.InertiaBlend = ply.InertiaBlend * inertia_blend_mul

		hook.Run("HG_MovementCalc", vel, velLen, weightmul, ply, cmd, mv)

		local mul = {(ply.move or ply.CurrentSpeed) / ply:GetRunSpeed()}

		hook.Run("HG_MovementCalc_2", mul, ply, cmd, mv)

		mul = mul[1]

		if mul <= 0.01 then
			mul = 0.01
		end

		mul = mul * (ply:GetNWBool("TauntStopMoving", false) and 0.01 or 1)

		if(runnin and velLen >= 10)then
			ply.CurrentSpeed = math.Approach(ply.CurrentSpeed, (ply.move or ply:GetRunSpeed()) * mul, delta_time * ply.SpeedGainMul)
		else
			if(ply:Crouching())then
				ply.CurrentSpeed = math.Approach(ply.CurrentSpeed, crouch_walk_speed * mul, delta_time * ply.SpeedLoseMul)
			elseif(slow_walking)then
				ply.CurrentSpeed = math.Approach(ply.CurrentSpeed, slow_walk_speed * mul, delta_time * ply.SpeedLoseMul)
			elseif(aiming)then
				ply.CurrentSpeed = math.Approach(ply.CurrentSpeed, slow_walk_speed * mul, delta_time * ply.SpeedLoseMul)
			else
				ply.CurrentSpeed = math.Approach(ply.CurrentSpeed, walk_speed * mul, delta_time * ply.SpeedLoseMul)
			end
		end
		--//

		--\\Набор скорости и её потеря
		ply.LastVelocity = ply.LastVelocity or vel
		ply.LastVelocityLen = ply.LastVelocityLen or velLen
		local vel1 = velLen
		local vel2 = ply.LastVelocityLen

		if(vel1 == 0)then
			vel1 = 1
		end

		if(vel2 == 0)then
			vel2 = 1
		end

		local change = math.abs(math.AngleDifference(calc_vector2d_angle(ply.LastVelocity), calc_vector2d_angle(vel)))// * (SERVER and 0 or 5)

		if ply.LastVelocity == vel and ply.LastChangeVelocity then//this is so bullshit but it works
			change = ply.LastChangeVelocity
		end

		local change_mul = math.abs(ply.CurrentSpeed - slow_walk_speed)

		ply.LastChangeVelocity = change
		ply.CurrentSpeed = math.Approach(ply.CurrentSpeed, slow_walk_speed * mul, delta_time * change * change_mul * ply.SpeedSharpLoseMul * 0.25 * 200)
		ply.LastVelocity = vel
		ply.LastVelocityLen = velLen
		--//

		local speed = ply.CurrentSpeed
		--\\Inertia
		local ply_angles = cmd:GetViewAngles()

		ply.MovementInertia = ply.MovementInertia or vel

		--=\\Штрафы за бег боком и спиной
		fm = fm / math.abs(fm ~= 0 and fm or 1)
		sm = sm / math.abs(sm ~= 0 and sm or 1)
		local movement_penalty = math.abs(sm * 1.2)

		if(movement_penalty == 0)then
			movement_penalty = 1
		end

		if(fm < 0)then
			movement_penalty = math.max(movement_penalty, 1.3)
		end

		--if(CLIENT)then
			speed = speed / movement_penalty
		--end
		--=//

		local inertia_to = calc_forward_side_moves_to_vector2d(fm, sm, ply_angles) * speed
		--=\\Штрафы за движение в воздухе и в воде
		local water_level = ply:WaterLevel()

		if((not ply:OnGround()) and (water_level < 1))then
			if(fm ~= 0 or sm ~=0)then
				local start_pos = ply:GetPos()
				local trace_data = {
					start = start_pos,
					endpos = start_pos + inertia_to / speed * 50,
					filter = ply
				}

				if(util.TraceLine(trace_data).Hit)then
					movement_penalty = 1
				else
					movement_penalty = 5
				end

				--if(CLIENT)then
					speed = speed / movement_penalty
				--end

				inertia_to = calc_forward_side_moves_to_vector2d(fm, sm, ply_angles) * speed
			end
		end
		--=//

		--=\\
		local consciousness = 1

		if ply.organism and ply.organism.consciousness then
			consciousness = consciousness * ply.organism.consciousness
			consciousness = consciousness * math.Clamp(ply.organism.blood / 4000, 0.5, 1)
		end

		local consmul = math.Clamp(((consciousness - 1) * 4 + 1), 0.1, 1)

		//if(water_level > 0)then
		//	ply.CurrentFrictionMul = math.Approach(ply.CurrentFrictionMul, 0.2, delta_time * ply.FrictionLoseMul * water_level)
		//else
			ply.CurrentFrictionMul = math.Approach(ply.CurrentFrictionMul, consmul, delta_time * ply.FrictionGainMul * (consmul < ply.CurrentFrictionMul and 100 or 10))
		//end
		--=//

		ply.InertiaBlend = ply.InertiaBlend * ply.CurrentFrictionMul

		-- local new_inertia = LerpVector(0.5^(delta_time * ply.InertiaBlend), ply.MovementInertia, inertia_to)
		-- local new_inertia = LerpVector(1 - 0.5^(delta_time * ply.InertiaBlend), ply.MovementInertia, inertia_to)
		//local new_inertia = approach_vector(ply.MovementInertia, inertia_to, 1000)//SERVER and delta_time * ply.InertiaBlend * ply:Ping() / 100 or delta_time * ply.InertiaBlend)
		//local new_inertia = approach_vector_smooth(ply.MovementInertia, inertia_to, hg.lerpFrameTime2(0.075, delta_time))
		local new_inertia = approach_vector(ply.MovementInertia, inertia_to, delta_time * ply.InertiaBlend)

		ply.MovementInertia = new_inertia

		local inertia_len = math.sqrt(ply.MovementInertia.x * ply.MovementInertia.x + ply.MovementInertia.y * ply.MovementInertia.y)

		/*if (SERVER or (ply.huy or 0) < SysTime()) and inertia_len > 10 then
			if CLIENT then ply.huy = SysTime() + engine.ServerFrameTime() end
			print(new_inertia, inertia_to)
		end*/

		local forward_move, side_move = calc_forward_side_moves(ply.MovementInertia, ply_angles)

		if(CLIENT)then
			ply.MovementInertiaAddView = ply.MovementInertiaAddView or Angle(0,0,0)
			ply.MovementInertiaAddView.r = ply.MovementInertiaAddView.r + side_move * delta_time * inertia_len * 0.03
			ply.MovementInertiaAddView.p = ply.MovementInertiaAddView.p + math.abs(side_move) * delta_time * inertia_len * 0.01
		end
		--//

		local move = ply:GetRunSpeed() * 1.1
		k = 1 * weightmul
		k = k * math.Clamp(consmul, 0.7, 1)
		k = k * math.Clamp((org.temperature and (1 - (org.temperature - 38) * 0.25) or 1), 0.5, 1)
		k = k * math.Clamp((org.temperature and ((org.temperature - 35) * 0.25 + 1) or 1), 0.5, 1)
		k = k * math.Clamp((org.stamina and org.stamina[1] or 180) / 120, hg_movement_stamina_debuff:GetFloat(), 1)
		k = k * math.Clamp(5 / ((org.immobilization or 0) + 1), 0.25, 1)
		k = k * math.Clamp((org.blood or 0) / 5000, 0, 1)
		k = k * math.Clamp(10 / ((org.shock or 0) + 1), 0.25, 1)
		k = k * (math.min((org.adrenaline or 0) / 24, 0.3) + 1)
		k = k * math.Clamp((org.lleg and org.lleg >= 0.5 and math.max(1 - org.lleg, 0.6) or 1) * (org.lleg and org.rleg >= 0.5 and math.max(1 - org.rleg, 0.6) or 1) * ((org.analgesia * 1 + 1)), 0, 1)
		k = k * (org.llegdislocation and 0.75 or 1) * (org.rlegdislocation and 0.75 or 1)
		k = k * (org.pelvis == 1 and 0.4 or 1)
		k = k * ((IsValid(ply:GetNetVar("carryent")) or IsValid(ply:GetNetVar("carryent2"))) and math.Clamp(50 / math.max(ply:GetNetVar("carrymass", 0) + ply:GetNetVar("carrymass2", 0), 1), 0.5, 1) or 1)
		k = k * math.Clamp(20 / ((org.pain or 0) + 1), 0.01, 1)
		//k = k * (ishgweapon(wep) and not wep:IsPistolHoldType() and not wep:ReadyStance() and 0.75 or 1)

		local slwdwn = ply:GetNetVar("slowDown", 0)
		if(slwdwn > 0)then
			//if(SERVER)then
				//ply:SetNetVar("slowDown", math.Approach(slwdwn, 0, delta_time * 250))
			//end
			k = k * math.Clamp((250 - slwdwn) / 250, 0.75, 1)
		end

		k = math.max(k, 20 / 200)

		if ply:GetNetVar("vomiting", 0) > (CurTime() - 3) then
			k = k * 0.25
		end

		local ent = IsValid(ply:GetNetVar("carryent")) and ply:GetNetVar("carryent") or IsValid(ply:GetNetVar("carryent2")) and ply:GetNetVar("carryent2")

		if SERVER and inertia_len > 5 and runnin then
			local mul = math.Clamp(inertia_len / 200, 0.5, 1) * 5 * (ply:Crouching() and 0.01 or 1)
			if ply == rag then
				if org.pelvis == 1 then
					org.painadd = org.painadd + FrameTime() * mul
				end
				if (org.lleg == 1) or org.llegdislocation then
					org.painadd = org.painadd + FrameTime() * mul
				end

				if (org.rleg == 1) or org.rlegdislocation then
					org.painadd = org.painadd + FrameTime() * mul
				end
			end
		end

		if IsValid(ent) then
			local bon = ply:GetNetVar("carrybone",0) ~= 0 and ply:GetNetVar("carrybone",0) or ply:GetNetVar("carrybone2",0)
			local bone = ent:TranslatePhysBoneToBone(bon)
			local mat = ent:GetBoneMatrix(bone)
			local pos = mat and mat:GetTranslation() or ent:GetPos()
			local lpos = IsValid(ent) and ply:GetNetVar("carrypos",nil) or ply:GetNetVar("carrypos2",nil)

			if lpos then
				if not ent:IsRagdoll()then
					pos = ent:LocalToWorld(lpos)
				else
					pos = LocalToWorld(lpos, angle_zero, mat:GetTranslation(), mat:GetAngles())
				end
			end

			local eyetr = hg.eyeTrace(ply)
			local dist = pos:DistToSqr(eyetr.StartPos)
			local reachdist = weapons.GetStored("weapon_hands_sh").ReachDistance + 30
			if dist > reachdist*reachdist then
				local moving_to = calc_forward_side_moves_to_vector2d(fm, sm, ply_angles)
				local dot = moving_to:Dot((pos - eyetr.StartPos):GetNormalized())
				k = k * dot
			end
		end

		move = move * k
		ply.move = move

		if SERVER and not IsValid(ply.FakeRagdoll) then
			ply.eyeAnglesOld = ply.eyeAnglesOld or ply:EyeAngles()
			local cosine = ply:EyeAngles():Forward():Dot(ply.eyeAnglesOld:Forward())
			ply.eyeAnglesOld = ply:EyeAngles()

			if (velLen > 200 and (math.random(150) == 1 or cosine <= 0.99)) then
				local tr = {}
				tr.start = ply:GetPos()
				tr.endpos = tr.start - vector_up * 1
				tr.filter = ply
				tr = util.TraceLine(tr)

				if tr.SurfaceProps and util.GetSurfaceData(tr.SurfaceProps) and util.GetSurfaceData(tr.SurfaceProps).friction < 0.2 then
					local b1 = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_L_Calf"))
					local phys1 = hg.IdealMassPlayer["ValveBiped.Bip01_L_Calf"]

					local b2 = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_R_Calf"))
					local phys2 = hg.IdealMassPlayer["ValveBiped.Bip01_R_Calf"]

					local torso = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_Spine2"))
					local phystorso = hg.IdealMassPlayer["ValveBiped.Bip01_Spine2"]
					local force = vel:GetNormalized() * 150

					hg.AddForceRag(ply, torso, -force * 5 * phystorso, 0.5)
					hg.AddForceRag(ply, b1, (force * 5 - vector_up * 2) * phys1, 0.5)
					hg.AddForceRag(ply, b2, (force * 5 - vector_up * 2) * phys2, 0.5)

					timer.Simple(0,function()
						hg.StunPlayer(ply)
					end)
				end
			end
		end

		/* -- too op
		ply.lastInDuck = ply:KeyPressed(IN_DUCK) and CurTime() or ply.lastInDuck or 0
		ply.lastInJump = ply:KeyPressed(IN_JUMP) and CurTime() or ply.lastInJump or 0
		if(SERVER && rag == ply && (ply.lastInJump + 0.1 > CurTime()) && (ply.lastInDuck + 0.1 > CurTime()))then
			local force = ply:GetAimVector() * 400
			force[3] = 0
			local torso = ply:TranslateBoneToPhysBone(ply:LookupBone("ValveBiped.Bip01_Spine2"))
			local phystorso = hg.IdealMassPlayer["ValveBiped.Bip01_Spine2"]
			hg.AddForceRag(ply, torso, force * phystorso, 0.5)
			hg.Fake(ply)
		end
		*/
		--print(speed.." "..(CLIENT and "c" or "s"))
		--speed = SERVER and speed + 50 or speed

		if ply:GetMoveType() == MOVETYPE_LADDER or ply:GetMoveType() == MOVETYPE_NONE then
			speed = 100
		end

		mv:SetMaxSpeed(speed)
		mv:SetMaxClientSpeed(speed)
		ply:SetMaxSpeed(speed)
		ply:SetJumpPower(DEFAULT_JUMP_POWER * math.min(k, 1.1) * (not ply:GetNWBool("TauntStopMoving", false) and 1 or 0) * (ply.organism.superfighter and 1.5 or 1) * (ply.JumpPowerMul or 1))

		if(CLIENT)then
			local fwangs = math.rad(GetViewPunchAngles2()[2] + GetViewPunchAngles3()[2])

			forward_move = forward_move * math.cos(fwangs) + side_move * math.sin(fwangs)
			side_move = side_move * math.cos(fwangs) + forward_move * math.sin(fwangs)

			cmd:SetForwardMove(forward_move * inertia_len)
			cmd:SetSideMove(side_move * inertia_len)
		end
	end)
--//
--\\ custom footsteps
	local EmitSound, SoundDuration, hg, ViewPunch, CurTime, math = EmitSound, SoundDuration, hg, ViewPunch, CurTime, math
	local math_max = math.max

	hook.Add("PlayerStepSoundTime", "hguhuy", function(ply, type, walking)
		return 1
	end)

	hook.Add("PlayerFootstep", "CustomFootstep2sad", function(ply, pos, foot, sound, volume, rf)
		if (ply.lastStepTime or 0) > CurTime() then return true end
		local vel = ply:GetVelocity()
		local len = vel:Length()
		local ent = hg.GetCurrentCharacter(ply)

		local sprint = hg.KeyDown(ply, IN_SPEED)
		ply.lastStepTime = CurTime() + 0.7 * (sprint and 1.5 or 1) * (1 / math_max(len, sprint and 200 or 150)) * 100

		if ply.PlayerClassName == "furry" then
			local wep = ply:GetActiveWeapon()
			if sprint and hg.KeyDown(ply, IN_WALK) and IsValid(wep) and wep:GetClass() == "weapon_hands_sh" then
				ply.lastStepTime = CurTime() + 0.4 * (sprint and 1.5 or 1) * (1 / math_max(len, sprint and 200 or 150)) * 100
			end
		end

		hook_Run("HG_PlayerFootstep_Notify", ply, pos, foot, sound, volume, rf)	--; Do not return anything from this _Notify hook

		if CLIENT and ply == lply and ply.move then
			footcl = (footcl == nil and -1 or footcl) + 1
			if footcl > 1 then
				footcl = -1
			elseif footcl == 0 then
				footcl = 1
			end
			local mul = 1 * len / 300 * math_max((350 - ply.move) / 50, 0.4)
			local mul2 = ((ply.organism.lleg or 0) * 3 + 1) * ((ply.organism.rleg or 0) * 3 + 1) * 0.5

			ViewPunch(Angle(1 * len / 200 * math_max((350 - ply.move) / 50, 1) * mul2, footcl * mul * mul2, 0))
			--ViewPunch4(Angle(1 * len / 200 * math_max((350 - ply.move) / 50, 1), footcl * mul, footcl * mul * 16) * 0.05)
		end

		if SERVER and ply.organism then
			local org = ply.organism
			org.painadd = org.painadd + ((org.lleg or 0) > 0.75 and (org.lleg - 0.75) or 0) + ((org.rleg or 0) > 0.75 and (org.rleg - 0.75) or 0)
		end

		if SERVER then
			if ply:GetNetVar("Armor", {})["torso"] then
				EmitSound("arc9_eft_shared/weapon_generic_rifle_spin"..math.random(9)..".ogg", pos, ply:EntIndex(), CHAN_AUTO, changePitch(math.min(len / 100, 0.89)), 80)
			end

			local Hook = hook_Run("HG_PlayerFootstep", ply, pos, foot, sound, volume, rf)
			if Hook then return Hook end

			if !(ply:IsWalking() or ply:Crouching()) and ent == ply then
				local snd
				if ply.PlayerClassName == "furry" then
					snd = "zbattle/footstep/hardbarefoot" .. math.random(1, 5) .. ".ogg"
				else
					snd = "zcitysnd/"..sound -- missing footsteps fix
				end
				if SoundDuration(snd) <= 0 or ply.PlayerClassName == "Gordon" then
					snd = sound
				end
				EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)) )
			end
		end

		return true
	end)
--//
--\\ Remove Sandbox Jump Boost
	hook.Add("PlayerSpawn", "RemoveSandboxJumpBoost", function(ply)
		if (engine.ActiveGamemode() != "sandbox") then return end

		local PLAYER = baseclass.Get("player_sandbox")

		PLAYER.FinishMove           = nil       -- Disable boost
		PLAYER.StartMove           	= nil       -- Disable boost
		PLAYER.SlowWalkSpeed		= 100		-- How fast to move when slow-walking (+WALK)
		PLAYER.WalkSpeed			= 190		-- How fast to move when not running
		PLAYER.RunSpeed				= 320		-- How fast to move when running
		PLAYER.CrouchedWalkSpeed	= 0.4		-- Multiply move speed by this when crouching
		PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
		PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
		PLAYER.JumpPower			= 200		-- How powerful our jump should be
	end)
--//
--\\ Precache Sounds 
	function hg.PrecacheSoundsSWEP(self)
		if self.HolsterSnd and self.HolsterSnd[1] then util.PrecacheSound(self.HolsterSnd[1]) end
		if self.DeploySnd and self.DeploySnd[1] then util.PrecacheSound(self.DeploySnd[1]) end
		if self.Primary.Sound and self.Primary.Sound[1] then util.PrecacheSound(self.Primary.Sound[1]) end
		if self.DistSound then util.PrecacheSound(self.DistSound) end
		if self.SupressedSound and self.SupressedSound[1] then util.PrecacheSound(self.SupressedSound[1]) end
		if self.CockSound then util.PrecacheSound(self.CockSound) end
		if self.ReloadSound then util.PrecacheSound(self.ReloadSound) end
	end
--//
--\\ Tough npcs
	local hg_toughnpcs = CreateConVar("hg_toughnpcs", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Toggle more health for npcs", 0, 1)
	local npcToBuff = {
		["npc_metropolice"] = 100,
		["npc_combine_s"] = 150,
		["npc_citizen"] = 100,
		["npc_kleiner"] = 100,
		["npc_magnusson"] = 100,
		["npc_eli"] = 100,
		["npc_odessa"] = 100,
		["npc_breen"] = 100,
		["npc_zombie"] = 120,
		["npc_fastzombie"] = 90,
		["npc_headcrab"] = 50,
		["npc_headcrab_fast"] = 40,
		["npc_headcrab_black"] = 70,
		["npc_fastzombie_torso"] = 80,
		["npc_zombie_torso"] = 110,
		["npc_manhack"] = 50,
		["npc_antlion_grub"] = 20,
	}
	hook.Add("OnEntityCreated", "toughnpcs", function(ent)
		if SERVER and hg_toughnpcs:GetBool() and IsValid(ent) and ent:IsNPC() and npcToBuff[ent:GetClass()] then
			timer.Simple(0.2, function()
				if not IsValid(ent) then return end

				ent:SetHealth(npcToBuff[ent:GetClass()])
				ent:SetMaxHealth(npcToBuff[ent:GetClass()])
				ent:SetPlaybackRate(2)
				ent:SetKeyValue("m_flPlaybackSpeed", 2)

				print(ent:Health())
			end)
		end
	end)
--//
--\\ Lootable npcs
	--[[ --!! TODO
	local lootNPCs = {
		["npc_combine_s"] = {
			"weapon_hg_stunstick",
			"weapon_medkit_sh",
			"weapon_bandage_sh",
			"weapon_handcuffs",
			"weapon_walkie_talkie"
		},
		["npc_metropolice"] = {
			"weapon_melee",
			"weapon_hg_hl2nade_tpik",
			"weapon_bandage_sh",
			"weapon_handcuffs"
		},
		["npc_citizen"] = {
			"weapon_smallconsumable",
			"weapon_bandage_sh",
			"weapon_painkillers"
		}
	}
	hook.Add("CreateEntityRagdoll", "npcloot", function(ent, rag)
		local loot = lootNPCs[ent:GetClass()]
		if IsValid(ent) and IsValid(rag) and ent:IsNPC() and loot then
			rag.armors = {}
			rag.inventory = {}

			rag.was_opened = true

			rag.inventory.Weapons = loot or {}
			rag:SetNetVar("Inventory", rag.inventory )
		end
	end)
	]]
--//
--\\ timescale pitch change
	local cheats = GetConVar( "sv_cheats" )
	local timeScale = GetConVar( "host_timescale" )

	function changePitch(p)

		if ( game.GetTimeScale() ~= 1 ) then
			p = p * game.GetTimeScale()
		end

		if ( timeScale:GetFloat() ~= 1 and cheats:GetBool() ) then
			p = p * timeScale:GetFloat()
		end

		if ( CLIENT and engine.GetDemoPlaybackTimeScale() ~= 1 ) then
			p = math.Clamp( p * engine.GetDemoPlaybackTimeScale(), 0, 255 )
		end

		return p
	end

	hook.Add( "EntityEmitSound", "TimeWarpSounds", function( t )
		local p = changePitch(t.Pitch)

		if ( p ~= t.Pitch ) then
			t.Pitch = math.Clamp( p, 0, 255 )
			return true
		end
	end )
--//
--\\ remove default death sound
	hook.Add("PlayerDeathSound", "removesound", function() return true end)
--//
--\\ flashlight custom switch
	hook.Add("PlayerSwitchFlashlight", "removeflashlights", function(ply, enabled)
		if ply.PlayerClassName == "Combine" or ply.PlayerClassName == "furry" then return end

		local wep = ply:GetActiveWeapon()

		local flashlightwep

		if IsValid(wep) then
			local laser = wep.attachments and wep.attachments.underbarrel
			local attachmentData
			if (laser and not table.IsEmpty(laser)) or wep.laser then
				if laser and not table.IsEmpty(laser) then
					attachmentData = hg.attachments.underbarrel[laser[1]]
				else
					attachmentData = wep.laserData
				end
			end

			if attachmentData then flashlightwep = attachmentData.supportFlashlight end
		end

		if not flashlightwep then --custom flashlight
			if IsValid(wep) and (wep.IsPistolHoldType and not wep:IsPistolHoldType() and ply.PlayerClassName ~= "Gordon") then return end

			local inv = ply:GetNetVar("Inventory",{})
			if inv and inv["Weapons"] and inv["Weapons"]["hg_flashlight"] and enabled and hg.CanUseLeftHand(ply) then
				local flashvar = ply:GetNetVar("flashlight")

				hg.GetCurrentCharacter(ply):EmitSound("items/flashlight1.wav", 65, flashvar and 110 or 130)
				ply:SetNetVar("flashlight",not flashvar)
				--return true
				if IsValid(ply.flashlight) then ply.flashlight:Remove() end
			else
				ply:SetNetVar("flashlight",false)
			end
			return false
		end
	end)
--//
--\\ Vehicle steering wheels
	local adjust = {
		["steering"] = {Vector(7,9,0),Angle(0,-80,0),Vector(-7,9,0),Angle(0,-100,180)},
		["steeringwheel"] = {Vector(7.5,-3.5,0),Angle(180,-90,0),Vector(-7.5,-3.5,0),Angle(0,90,0)},
		["steering_wheel"] = {Vector(9,13,-1),Angle(0,-90,0),Vector(-9,13,-1),Angle(-180,90,0)},
		["Rig_Buggy.Steer_Wheel"] = {Vector(8,-2.5,0),Angle(0,-90,0),Vector(-8,-2.5,0),Angle(180,90,0)},
		["car.steeringwheel"] = {Vector(15,-10,0),Angle(0,180,0),Vector(15,10,0),Angle(180,0,0)},
		["Airboat.Steer"] = {Vector(-11,-1.5,10),Angle(70,50,50),Vector(11,-1.5,10),Angle(70,50,50)},
		--["steeringwheel"] = {Vector(8.2,4,0),Angle(-5,-45,0),Vector(-8.2,4,0),Angle(-45,-35,90)},
		["handlebars"] = {
			Vector(10,-6,-19),
			Angle(-15,60,-90),
			Vector(-10,-6,-19),
			Angle(-15,120,-90)
		},
		["steerw_bone"] = {Vector(9,10,0),Angle(0,-80,0),Vector(-9,10,0),Angle(0,-100,180)},
	}

	local modelAdjust = {
		["models/left4dead/vehicles/apc_body_glide.mdl"] = {Vector(10.5,14,-1),Angle(0,-90,0),Vector(-10.5,14,-1),Angle(-180,90,0)},
		["models/left4dead/vehicles/nuke_car_glide.mdl"] = {Vector(7,12,-1),Angle(0,-90,0),Vector(-7,12,-1),Angle(180,90,0)},
		["models/gta5/vehicles/sanchez/chassis.mdl"] = {
			Vector(15,17,-4.5),
			Angle(-95,90,-90),
			Vector(-15,17,-4.5),
			Angle(-95,90,-90)},
		["models/gta5/vehicles/wolfsbane/chassis.mdl"] = {
			Vector(14.5,15.5,-7.5),
			Angle(-95,90,-90),
			Vector(-14.5,15.5,-7.5),
			Angle(-95,90,-90)
		},
		["models/gta5/vehicles/blazer/chassis.mdl"] = {
			Vector(13,11,-5),
			Angle(-95,90,-90),
			Vector(-13,11,-5),
			Angle(-95,90,-90)
		},
		["models/gta5/vehicles/speedo/chassis.mdl"] = {
			Vector(8,4,0),
			Angle(0,-90,0),
			Vector(-8,4,0),
			Angle(0,-90,180)
		},
		["models/gta5/vehicles/dukes/chassis.mdl"] = {
			Vector(7,6,0),
			Angle(0,-80,0),
			Vector(-7,6,0),
			Angle(0,-100,180)
		},
		["models/gta5/vehicles/police/chassis.mdl"] = {
			Vector(7.5,5,0),
			Angle(0,-80,0),
			Vector(-7.5,5,0),
			Angle(0,-100,180)
		},
		["models/gta5/vehicles/hauler/chassis.mdl"] = {
			Vector(10,4,0),
			Angle(0,-90,0),
			Vector(-10,4,0),
			Angle(0,-90,180)
		},
		["models/blackterios_glide_vehicles/chevroletcorsaclassic/chevroletcorsaclassic.mdl"] = {
			Vector(-9.5,3,0),
			Angle(180,90,0),
			Vector(9.5,3,0),
			Angle(0,-90,0)
		},
		["models/blackterios_glide_vehicles/datsun510/datsun510.mdl"] = {
			Vector(8.5,7.5,-1),
			Angle(0,-90,0),
			Vector(-8.5,7.5,-1),
			Angle(0,-90,180)
		},
		["models/blackterios_glide_vehicles/fiatduna/fiatduna.mdl"] = {
			Vector(8.5,3.5,-1),
			Angle(0,-90,0),
			Vector(-8.5,3.5,-1),
			Angle(0,-90,180)
		},
		["models/blackterios_glide_vehicles/renaulttrafict1000d/renaulttrafict1000d.mdl"] = {
			Vector(-11.5,7,0),
			Angle(180,90,0),
			Vector(11.5,7,0),
			Angle(0,-90,0)
		},
		["models/blackterios_glide_vehicles/zanellarx150/zanellarx150.mdl"] = {
			Vector(12,9.5,-9),
			Angle(-70,0,0),
			Vector(-12,9.5,-9),
			Angle(-110,0,0)
		},
		["models/gta5/vehicles/seashark/chassis.mdl"] = {
			Vector(11,-2,-16),
			Angle(-35,80,-90),
			Vector(-11,-2,-16),
			Angle(-35,100,-90)
		},
		["models/hl2vehicles/muscle.mdl"] = {
			Vector(9,3.9,0),
			Angle(0,-90,5),
			Vector(-9,3.9,0),
			Angle(180,90,-5)
		}
	}

	function hg.GetCarSteering(Car)
		if not Car.steer then
			for k,v in pairs(adjust) do
				local steer = Car:LookupBone(k)

				if steer then
					Car.steer = steer
					Car.adjust = modelAdjust[Car:GetModel()] or adjust[k]
					break
				end
			end
		end

		return Car.steer, Car.adjust
	end
--//
--\\ Can use hands
	function hg.CanUseLeftHand(ply)
		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply

		if ent.organism and ent.organism.larmamputated then
			return false
		end

		local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon()
		local Car = (ply.GetSimfphys and IsValid(ply:GetSimfphys()) and ply:GetSimfphys()) or ( ply.GlideGetVehicle and IsValid(ply:GlideGetVehicle()) and ply:GlideGetVehicle()) or ply:GetVehicle()

		if (IsValid(Car) and hg.GetCarSteering(Car)) then
			holdingwheel = hg.GetCarSteering(Car) > 0
		end

		local deploying = wep and (wep.deploy and (wep.deploy - CurTime()) > (wep.CooldownDeploy / 2) or wep.holster and (wep.holster - CurTime()) < (wep.CooldownHolster / 2))

		return (not ((((ply:GetTable().ChatGestureWeight or 0) > 0.1 or
			(ply:GetNWBool("TauntLeftHand", false) and ply:GetNWFloat("StartTaunt", 0) + 0.1 < CurTime()) or
			IsValid(ply.flashlight)) and !ply:GetNetVar("handcuffed") and (wep and not wep.reload)) or
			(deploying) or
			(ent != ply and math.abs(ent:GetManipulateBoneAngles(ent:LookupBone("ValveBiped.Bip01_L_Finger11"))[2]) > 5 and !ply:InVehicle()) or
			( ply:InVehicle() and (wep and not IsValid(wep)) and not wep.reload) and hg.isdriveablevehicle(ply:GetVehicle()) )) or ply.zmanipstart
	end

	function hg.CanUseRightHand(ply)
		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply

		if ent.organism and ent.organism.rarmamputated then
			return false
		end

		return true
	end
--//
--\\ custom eargrab anim
	function hg.earanim(ply)
		local plyTable = ply:GetTable()

		plyTable.ChatGestureWeight = plyTable.ChatGestureWeight || 0

		if ( ply:IsPlayingTaunt() ) then return end

		local wep = ply:GetActiveWeapon()
		
		if ( ply:IsTyping() ) or ( ply:GetNetVar("flashlight", false) and ( !wep.IsPistolHoldType or wep:IsPistolHoldType() or ply.PlayerClassName == "Gordon") ) then
			plyTable.ChatGestureWeight = math.Approach( plyTable.ChatGestureWeight, 1, FrameTime() * 3.0 )
		else
			plyTable.ChatGestureWeight = math.Approach( plyTable.ChatGestureWeight, 0, FrameTime() * 3.0 )
		end

		if ( plyTable.ChatGestureWeight > 0 ) then

			ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
			ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, plyTable.ChatGestureWeight )

		end
	end
--//
--\\ other ents use our bullets
	local npcs = {
		["npc_strider"] = {multi = 5, snd = "npc/strider/strider_minigun.wav", force = 5, AmmoType = "14.5x114mm BZTM", PenetrationMul = 10, noricochet = true},
		["npc_combinegunship"] = {multi = 5, snd = "npc/strider/strider_minigun.wav", force = 3, AmmoType = "14.5x114mm BZTM", PenetrationMul = 10},
		["npc_helicopter"] = {multi = 4, force = 2, AmmoType = "14.5x114mm BZTM", PenetrationMul = 10},
		["lunasflightschool_ah6"] = {multi = 20, AmmoType = "14.5x114mm BZTM"},
		["npc_turret_floor"] = {multi = 1.25, AmmoType = "9x19 mm Parabellum"},
		["npc_sniper"] = {multi = 3, AmmoType = "14.5x114mm BZTM", PenetrationMul = 4},
		["npc_hunter"] = {multi = 4, AmmoType = "12/70 RIP", PenetrationMul = 1}, --;; не работает( потому что прожектайлами стреляет
		["npc_turret_ceiling"] = {multi = 1.25, AmmoType = "9x19 mm QuakeMaker"},
	}

	hook.Add("EntityFireBullets", "NPC_Boolets", function(ent, bullet)
		if IsValid(ent) and npcs[ent:GetClass()] and not bullet.NpcShoot then
			local tbl = npcs[ent:GetClass()]
			if ent:GetClass() == "npc_turret_floor" and IsValid(ent:GetEnemy()) and ent:GetEnemy():GetClass() == "npc_bullseye" and IsValid(ent:GetEnemy().rag) then
				bullet.Dir = (ent:GetEnemy().rag:GetBonePosition(ent:GetEnemy().rag:LookupBone("ValveBiped.Bip01_Spine1")) + VectorRand(-20, 20) - bullet.Src):GetNormalized()
			end
			bullet.AmmoType = tbl.AmmoType or bullet.AmmoType
			if bullet.AmmoType then 
				bullet.Damage = (hg.ammotypeshuy[bullet.AmmoType] and hg.ammotypeshuy[bullet.AmmoType].BulletSettings.Damage or game.GetAmmoPlayerDamage(game.GetAmmoID(bullet.AmmoType)))// * npcs[ent:GetClass()].multi
				bullet.Force = (hg.ammotypeshuy[bullet.AmmoType] and hg.ammotypeshuy[bullet.AmmoType].BulletSettings.Force or game.GetAmmoPlayerDamage(game.GetAmmoID(bullet.AmmoType))) * (npcs[ent:GetClass()].force or 1)
				bullet.Penetration = (hg.ammotypeshuy[bullet.AmmoType] and hg.ammotypeshuy[bullet.AmmoType].BulletSettings.Penetration or game.GetAmmoPlayerDamage(game.GetAmmoID(bullet.AmmoType))) * (npcs[ent:GetClass()].PenetrationMul or 1)
			end
			bullet.Filter = { ent }
			bullet.Attacker = ent
			bullet.penetrated = 0
			bullet.noricochet = tbl.noricochet
			ent.weapon = ent

			bullet.IgnoreEntity = ent
		
			bullet.Filter = {ent}
			bullet.Inflictor = ent

			if(!GetGlobalBool("PhysBullets_ReplaceDefault", false)) and not bullet.NpcShoot then
				local oldcallback = bullet.Callback
				function bullet.Callback(i1,i2,i3)
					hg.bulletHit(i1,i2,i3,bullet,ent)

				end

				if npcs[ent:GetClass()].snd then
					ent:EmitSound(tbl.snd, 85, 100, 1, CHAN_AUTO)
				end

				bullet.NpcShoot = true
				ent:FireLuaBullets( bullet )
				bullet.Damage = 0
				bullet.Callback = oldcallback
				return true
			end
		end
	end)
--//

--\\ Custom player use
	hook.Add("PlayerUse","nouseinfake",function(ply,ent)
		local class = ent:GetClass()

		if class == "momentary_rot_button" then return end
		local ductcount = hgCheckDuctTapeObjects(ent)
		local nailscount = hgCheckBindObjects(ent)
		ply.PickUpCooldown = ply.PickUpCooldown or 0
		if (ductcount and ductcount > 0) or (nailscount and nailscount > 0) then return false end
		if class == "prop_physics" or class == "prop_physics_multiplayer" or class == "func_physbox" then
			local PhysObj = ent:GetPhysicsObject()
			if PhysObj and PhysObj.GetMass and PhysObj:GetMass() > 14 then return false end
		end

		if IsValid(ply.FakeRagdoll) then return false end
		if ply.PickUpCooldown > CurTime() then return false end

		ply.PickUpCooldown = CurTime() + 0.15
	end)
--//
--\\ set hull
	hook.Add("Player Activate","SetHull",function(ply)
		ply:SetHull(HullMins, HullMaxs)
		ply:SetHullDuck(HullDuckMins, HullDuckMaxs)
		ply:SetViewOffset(ViewOffset)
		ply:SetViewOffsetDucked(ViewOffsetDucked)
	end)

	hook.Add("Player Spawn","SetHull",function(ply)
		ply:SetNWEntity("FakeRagdoll",NULL)
		ply:SetObserverMode(OBS_MODE_NONE)
	end)
--//
--\\ custom equip
	hook.Add("WeaponEquip","pickupHuy",function(wep,ply)
		--if not wep.init then return end
		timer.Simple(0,function()
			if wep.DontEquipInstantly then wep.DontEquipInstantly = nil return end
			if not ply.noSound and IsValid(wep) then
				local oldwep = ply:GetActiveWeapon()
				timer.Simple(0,function()
					hook.Run("PlayerSwitchWeapon",ply,oldwep,wep)
					ply:SelectWeapon(wep:GetClass())
					ply:SetActiveWeapon(wep)

					if wep.Deploy then
						wep:Deploy()
					end
				end)
			end
		end)
	end)
--//
--\\ block pickup with holding something (why it shared)
	hook.Add("AllowPlayerPickup","pickupWithWeapons",function(ply,ent)
		if ent:IsPlayerHolding() then return false end
	end)
--//
--\\ Custom find use entity
	local hullVec = Vector(1,1,1)
	local checkUse = {
		"player",
		"worldspawn",
		"prop_dynamic"
	}

	hook.Add("FindUseEntity","findhguse",function(ply,heldent)
		if IsValid(heldent) and heldent:GetClass() == "button" then return heldent end

		if not ply:KeyDown(IN_USE) then return false end
		local eyetr = hg.eyeTrace(ply,100,nil,nil,nil,checkUse)

		local ent = eyetr.Entity

		if !IsValid(ent) then
			local tr = {}
			tr.start = eyetr.HitPos
			tr.endpos = eyetr.HitPos
			tr.filter = checkUse	
			tr.mins = -hullVec
			tr.maxs = hullVec
			tr.mask = MASK_SOLID + CONTENTS_DEBRIS + CONTENTS_PLAYERCLIP
			tr.ignoreworld = false

			tr = util_TraceHull(tr)
			ent = tr.Entity
		end

		if !IsValid(ent) then
			ent = heldent
		end

		return ent
	end)
--//
duplicator.Allow( "weapon_base" )
duplicator.Allow( "homigrad_base" )

--\\ Custom running anim rate
	hook.Add("UpdateAnimation", "NormAnimki", function(ply, vel, maxSeqGroundSpeed)
		if not IsValid(ply) or not ply:Alive() or not ply:OnGround() then return end

		if vel:LengthSqr() >= 77000 and vel:LengthSqr() < 110000 then
			ply:SetPlaybackRate(1.2)
			return ply, vel, maxSeqGroundSpeed
		end

		if vel:LengthSqr() >= 77000 then
			ply:SetPlaybackRate(1.4)
			return ply, vel, maxSeqGroundSpeed
		end
	end)
--//

--\\ Custom running anim activity
	hook.Add( "CalcMainActivity", "RunningAnim", function( Player, Velocity )
		if (not Player:InVehicle()) and Player:IsOnGround() and Velocity:Length() > 250 and IsValid(Player:GetActiveWeapon()) and Player:GetActiveWeapon():GetHoldType() == "normal" then
			local isFurry = Player.PlayerClassName == "furry"
			local anim = ACT_HL2MP_RUN_FAST
			if Player:IsOnFire() then
				anim = ACT_HL2MP_RUN_PANICKED
			elseif isFurry then
				if hg.KeyDown(Player, IN_WALK) and not hg.KeyDown(Player, IN_BACK) then
					anim = ACT_HL2MP_RUN_ZOMBIE_FAST
				else
					anim = ACT_HL2MP_RUN_FAST
				end
			else
				anim = ACT_HL2MP_RUN_FAST
			end

			return anim, -1
		end
	end)
--//

--\\ Weired shit, but works!
	timer.Simple(5,function()
		hook.Remove( "ScaleNPCDamage", "AddHeadshotPuffNPC" )
		hook.Remove( "ScalePlayerDamage", "AddHeadshotPuffPlayer" )
		hook.Remove( "EntityTakeDamage", "AddHeadshotPuffRagdoll" )
	end)
--//

--\\ Move this to cl_util.lua
	if CLIENT then
		hook.Add("Player_Death","fixEyeAngles",function(ply)
			timer.Simple(0.1,function()
				if IsValid(ply) then
					local ang = ply:EyeAngles()
					ang[3] = 0
					ply:SetEyeAngles(ang)
				end
			end)
		end)

		hg.flashes = {}
		local tab = {}

		local blackout_mat = Material("sprites/mat_jack_hmcd_narrow")

		function hg.AddFlash(eyepos, dot, pos, time, size)
			time = time or 20
			size = size or 1000--pixels
			size = size / math.max(pos:Distance(eyepos) / 64,0.01) * (dot^2)
			local taint = math.max(200 - size,0) / 200 * time * 0.9
			local scr = pos:ToScreen()

			table.insert(hg.flashes,{x = scr.x, y = scr.y, time = CurTime() + time - taint, lentime = time, size = size})
		end

		local flash
		local mat = Material("sprites/orangeflare1_gmod")
		local mat2 = Material("sprites/glow04_noz")

		amtflashed = 0
		amtflashed2 = 0
		
		hook.Add("Player_Death","huyhuyhuy",function(ply)
			if ply == LocalPlayer() then
				hg.flashes = {}
				amtflashed = 0
				amtflashed2 = 0
			end
		end)

		hook.Add("PreCleanupMap", "noflashesforyouMreowe", function()
			hg.flashes = {}
			amtflashed = 0
			amtflashed2 = 0
		end)

		hook.Add("Post Post Processing","flasheseffect",function()
			if !lply:Alive() then
				if !next(hg.flashes) then
					hg.flashes = {}
				end

				amtflashed = 0
				amtflashed2 = 0
			end
			if (#hg.flashes <= 0) and (amtflashed2 <= 0) then return end
			amtflashed = 0
			for i = 1,#hg.flashes do
				flash = hg.flashes[i]

				if (flash.time or 0) < CurTime() then table.remove(hg.flashes[i]) continue end

				local animpos = (flash.time - CurTime()) / flash.lentime
				local size = flash.size

				flash.animpos = animpos

				amtflashed = amtflashed + animpos * size / 5000
			end
			
			amtflashed = amtflashed + amtflashed2
			amtflashed2 = math.min(math.Approach(amtflashed2, 0, FrameTime() / 20),2)
			
			amtflashed = math.max(amtflashed - math.ease.InOutCubic(math.max(0, math.sin(CurTime() * 1) - 0.6) / 0.4),0)

			tab["$pp_colour_brightness"] = 0 - math.max(amtflashed - 0.1,0)
			DrawColorModify(tab)

			for i = 1, #hg.flashes do
				flash = hg.flashes[i]
				
				local animpos = flash.animpos
				local size = flash.size

				local huy = (1 - animpos) * -100
				surface.SetMaterial(mat)
				surface.SetDrawColor(255,255,255,animpos * 255 + math.Rand(-10,10) * animpos)
				surface.DrawTexturedRect(flash.x - size / 2 + huy, flash.y - size / 2 + huy, size, size)
				surface.SetMaterial(mat2)
				surface.DrawTexturedRect(flash.x - size / 2 + huy, flash.y - size / 2 + huy, size, size)
			end
		end)
	end
--//

--\\ There devs on your server!!!
	DEVELOPERS_LIST = {
		["76561198262308464"] = true, -- mannytko
		["76561198164095903"] = true, -- deka
		["76561198123967035"] = true, -- sadsalat
		["76561197982525837"] = true, -- useless
		["76561198130072232"] = true, -- mr point
		["76561198325967989"] = true, -- zac90
	}

	hook.Add("PlayerInitialSpawn","Hey! Developer here YAY",function(ply)
		if SERVER and DEVELOPERS_LIST[ply:OwnerSteamID64()] then
			PrintMessage(HUD_PRINTTALK, ply:Nick().." - zteam dev here!")
		end
	end)
--//

--\\ Fireworks effects? why so many, we use only one lol
    --Firework trails
    game.AddParticles( "particles/gf2_trails_firework_rocket_01.pcf") 
    
    PrecacheParticleSystem("gf2_firework_trail_main")
    --Firework Large Explosions
    game.AddParticles( "particles/gf2_large_rocket_01.pcf" )
    game.AddParticles( "particles/gf2_large_rocket_02.pcf" )
    game.AddParticles( "particles/gf2_large_rocket_03.pcf" )
    game.AddParticles( "particles/gf2_large_rocket_04.pcf" )
    game.AddParticles( "particles/gf2_large_rocket_05.pcf" )
    game.AddParticles( "particles/gf2_large_rocket_06.pcf" )
    
    PrecacheParticleSystem( "gf2_rocket_large_explosion_01" )
    PrecacheParticleSystem( "gf2_rocket_large_explosion_02" )
    PrecacheParticleSystem( "gf2_rocket_large_explosion_03" )
    PrecacheParticleSystem( "gf2_rocket_large_explosion_04" )
    PrecacheParticleSystem( "gf2_rocket_large_explosion_05" )
    PrecacheParticleSystem( "gf2_rocket_large_explosion_06" )
    
    --Battery stuff
    game.AddParticles( "particles/gf2_battery_generals.pcf" ) 
    game.AddParticles( "particles/gf2_battery_01_effects.pcf" )
    game.AddParticles( "particles/gf2_battery_02_effects.pcf" )
    game.AddParticles( "particles/gf2_battery_03_effects.pcf" )
    game.AddParticles( "particles/gf2_battery_mine_01_effects.pcf" )
    
    --Cakes stuff
    game.AddParticles( "particles/gf2_cake_01_effects.pcf" )
    
    --Firecrackers stuff
    game.AddParticles( "particles/gf2_firecracker_m80.pcf" )
    
    --Misc
    game.AddParticles( "particles/gf2_misc_neighborhater.pcf" )
    game.AddParticles( "particles/gf2_matchhead_light.pcf" )
    
    --Fountains
    
    game.AddParticles( "particles/gf2_fountain_01_effects.pcf")
    game.AddParticles( "particles/gf2_fountain_02_effects.pcf")
    game.AddParticles( "particles/gf2_fountain_03_effects.pcf")
    game.AddParticles( "particles/gf2_fountain_04_effects.pcf")
    game.AddParticles( "particles/gf2_fountain_05_effects.pcf")
    
    --Mortars
    game.AddParticles( "particles/gf2_mortar_shells_effects.pcf")
    game.AddParticles( "particles/gf2_mortar_shells_big_01.pcf")
    game.AddParticles( "particles/gf2_mortar_shells_big_02.pcf")
    game.AddParticles( "particles/gf2_mortar_shells_big_03.pcf")
    
    --Wheels
    
    game.AddParticles( "particles/gf2_wheel_01.pcf")
    
    -- Flares
    game.AddParticles( "particles/gf2_flare_multicoloured_effects.pcf")
    
    -- Giga rockets
    
    game.AddParticles( "particles/gf2_gigantic_rocket_01.pcf" )
    game.AddParticles( "particles/gf2_gigantic_rocket_02.pcf" )
    
    -- Roman Candles
    game.AddParticles( "particles/gf2_romancandle_01_effect.pcf" )
    game.AddParticles( "particles/gf2_romancandle_02_effect.pcf" )
    game.AddParticles( "particles/gf2_romancandle_03_effect.pcf" )
    
    --Small Fireworks
    game.AddParticles( "particles/gf2_firework_small_01.pcf" )
--//
--\\ Fun commands
	local hg_thirdperson = ConVarExists("hg_thirdperson") and GetConVar("hg_thirdperson") or CreateConVar("hg_thirdperson", 0, FCVAR_REPLICATED, "Toggle third-person camera view", 0, 1)
--//
--\\ Explosion Trace
	function hg.ExplosionTrace(start,endpos,filter)
		local filter1 = {}
		filter = filter or {}
		for _,ent in ipairs(filter) do
			filter1[ent] = true
		end
		return util.TraceLine({
			start = start,
			endpos = endpos,
			filter = function(ent) -- i think this too shit, need edit...
				--print(ent:GetModel())
				if filter1[ent] then return false end 
				local phys = ent:GetPhysicsObject()
				--print(ent:GetModel(),phys:GetMass())
				if not ent:IsPlayer() and IsValid(phys) and phys:GetMass() > 50 then return true end
				return true
			end,
			mask = MASK_SHOT
		})
	end
--//

--\\ Anti-gmod PVP system (Anti crouch spam in air)
	hook.Add("StartCommand", "HG_AntiGmodPVP", function(ply, cmd)
		ply.NowCrouched = cmd:KeyDown(IN_DUCK)
		ply.OldCrouched = ply.OldCrouched or cmd:KeyDown(IN_DUCK)

		if not ply:OnGround() and ply:WaterLevel() < 2 and ply:GetMoveType() == MOVETYPE_WALK and ply.OldCrouched != ply.NowCrouched then
			cmd:AddKey(IN_DUCK)
		end

		ply.OldCrouched = cmd:KeyDown(IN_DUCK)
	end)
--//
--\\ Just shared freelook limits
	hg.MaxLookX,hg.MinLookX = 55,-55 
	hg.MaxLookY,hg.MinLookY = 45,-45
--//
--\\ Screen Capture
	if CLIENT then
		local tex = GetRenderTargetEx("rt_hg_screencapture_1",
			ScrW(), ScrH(),
			RT_SIZE_NO_CHANGE,
			MATERIAL_RT_DEPTH_SHARED,
			bit.bor(2, 256),
			0,
			IMAGE_FORMAT_BGRA8888
			)

		local myMat = CreateMaterial("mat_hg_screencapture_1", "UnlitGeneric", {
			["$basetexture"] = tex:GetName(),
			["$translucent"] = 1,
		})

		function hg.GetCaptureTex()
			return tex
		end

		function hg.GetCaptureMat()
			return myMat
		end

		function hg.StartCaptureRender()
			render.PushRenderTarget(tex, 0, 0, ScrW(), ScrH())
			render.Clear(0, 0, 0, 0, false, false)
			render.SetWriteDepthToDestAlpha( false )
		end

		function hg.EndCaptureRender()
			render.PopRenderTarget()
		end

		function hg.DrawCaptured()
			render.SetMaterial(myMat)
			render.DrawScreenQuad()
		end
	end
--//
--\\ Give npc our guns (this is work?)
	hook.Add("Initialize", "addnpcweps", function()
		local weaponsList = weapons.GetList()
		for _, wep in ipairs(weaponsList) do
			local className = wep.ClassName
			if className and className ~= "" and (ishgweapon(wep) or wep.ismelee2) then
				list.Set("NPCUsableWeapons", { 
					class = className,
					name = wep.PrintName or className,
					category = wep.Category or "ZCity"
				})
			end
		end
	end)
--//
--\\ Custom table.IsEmpty
	hg.isempty = hg.isempty or table.IsEmpty
	function table.IsEmpty( tab )
		return next( tab ) == nil
	end
--//

--\\ Custom Screen Shake
if SERVER then
	util.AddNetworkString("util.ScreenShake")
end

hg.OldScreenShake = hg.OldScreenShake or util.ScreenShake

local ScreenShakers = {} -- Shake your a... don't :3
--[[
	ScreenShakers[#ScreenShakers + 1] = {
		vPos = vPos,
		nAmplitude = nAmplitude,
		nFrequency = nFrequency,
		nDuration = nDuration or 1,
		nRadius = nRadius,
		bAirshake = bAirshake,
		tCreated = CurTime()
	}
--]]
function util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake, crfFilter)
	if SERVER then -- SERVER SIDE
		vPos = vPos or Vector(0,0,0)
		nRadius = nRadius or (nAmplitude * 100)
		local tEnts = ents.FindInSphere(vPos, nRadius * nRadius)
		--PrintTable(tEnts)
		local crf = RecipientFilter()
		--print(#tEnts)
		for i = 1, #tEnts do
			local eEnt = tEnts[i]
			if !IsValid(eEnt) then continue end
			if !eEnt:IsPlayer() then continue end
			crf:AddPlayer(eEnt)
		end
		crf = crf or crfFilter
		--print(crf)
		net.Start("util.ScreenShake")
			net.WriteVector(vPos)
			net.WriteFloat(nAmplitude)
			net.WriteFloat(nFrequency)
			net.WriteFloat(nDuration or 1)
			net.WriteFloat(nRadius)
			net.WriteBool(bAirshake)
		net.Send(crf)
	elseif CLIENT then -- CLIENT SIDE
		nRadius = nRadius or (nAmplitude * 100)
		ScreenShakers[#ScreenShakers + 1] = {
			vPos = vPos,
			nAmplitude = nAmplitude,
			nFrequency = nFrequency,
			nDuration = nDuration or 1,
			nRadius = nRadius,
			bAirshake = bAirshake,
			tCreated = CurTime()
		}
		hg.OldScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake, crfFilter)
	end
end

local plyMeta = FindMetaTable("Player")
function plyMeta:ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake)
	if SERVER then
		local crfFilter = RecipientFilter()
		crfFilter:AddPlayer(self)
		util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake, crfFilter)
	elseif CLIENT and self == lply then
		util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake)
	end
end

if CLIENT then
	-- Clientside receive
	net.Receive("util.ScreenShake",function()
		local vPos = net.ReadVector()
		local nAmplitude = net.ReadFloat()
		local nFrequency = net.ReadFloat()
		local nDuration = net.ReadFloat()
		local nRadius = net.ReadFloat()
		local bAirshake = net.ReadBool(bAirshake)

		util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake)
	end)

	hook.Add("PostHGCalcView","util.ScreenShake",function(ply, view)
		for i = 1, #ScreenShakers do
			local shake = ScreenShakers[i]
			if shake then
				if !ply:IsOnGround() and !shake.bAirshake then continue end
				local distance = shake.vPos:DistToSqr(ply:GetPos())
				local mul = 1 - (distance / (shake.nRadius * shake.nRadius) / 2)
				mul = math.max(mul, 0)
				mul = Lerp(math.ease.InExpo(mul),0,1)

				local timeMul = ((shake.tCreated + shake.nDuration) - CurTime()) / shake.nDuration
				shake.vNormal = shake.vNormal or VectorRand(-1,1)
				shake.vShake =  shake.vNormal * (math.Rand(0,2) * timeMul)
				local vNoise = VectorRand(-0.2,0.2)
				shake.vShake = shake.vShake + vNoise
				if !shake.gFrequency or shake.gFrequency < CurTime() then
					shake.gFrequency = CurTime() + (100 - shake.nFrequency) / 100
					shake.vNormal = VectorRand(-1,1)
				end

				shake.finalShake = LerpVectorFT(0.3, shake.finalShake or Vector(0,0,0), shake.vShake)
				local vShake = shake.finalShake
				vShake = vShake * shake.nAmplitude / 5
				vShake = vShake * mul
				vShake = vShake * timeMul
				vShake.z = vShake.z * 0.5
				vShake.x = math.max(vShake.x, 0)

				local angles = view.angles
				view.origin = view.origin
					+ angles:Forward() * vShake.x
					+ angles:Right() * vShake.y
					+ angles:Up() * vShake.z

				angles[1] = angles[1] + vShake.z
				--angles[2] = angles[2] + vShake.x
				angles[3] = angles[3] + vShake.y

				if timeMul <= 0 then
					table.remove(ScreenShakers, i)
				end
			end
		end
		return view
	end)
end
--//