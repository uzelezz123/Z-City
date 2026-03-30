local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game

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

--\\ Vector/Angle clamp function
	function hg.clamp(vecOrAng, val)
		vecOrAng[1] = math.Clamp(vecOrAng[1], -val, val)
		vecOrAng[2] = math.Clamp(vecOrAng[2], -val, val)
		vecOrAng[3] = math.Clamp(vecOrAng[3], -val, val)
		return vecOrAng
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

		local oldCollision = target:GetCollisionGroup()
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
					if target:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then -- if it somehow changed, we shouldn't touch it
						target:SetCollisionGroup(oldCollision)
					end

					timer.Destroy(target:SteamID64().."_checkBounds_cycle")
				end
			end)
		end)
	end
--//
--\\ custom spawn
	gameevent.Listen("player_spawn")

	DEFAULT_JUMP_POWER = 200

	local music_packs = {
		"mirrors_edge",
		"swat4",
		--"hl_coop",
		"splinter_cell",
	}
	local hg_sandboxmusic = ConVarExists("hg_sandboxmusic") and GetConVar("hg_sandboxmusic") or CreateConVar("hg_sandboxmusic", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Toggle dynamic music in sandbox gamemode", 0, 1)
	local gamemod = engine.ActiveGamemode()
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

			if CLIENT and not ply:IsLocal() and gamemod == "sandbox" then
				if hg.DynaMusic then
					if hg_sandboxmusic:GetBool() then
						hg.DynaMusic:Stop()
						hg.DynaMusic:Start(music_packs[math.random(#music_packs)])
					else
						hg.DynaMusic:Stop()
					end
				end
			end

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
		if ent:GetMaterial() == "NULL" then ent:DrawShadow( false ) return end
		if not IsValid(ent) then return end

		--local drawornot = hook_Run("PreDrawPlayer2", ent, self) // true means nodraw
		--if drawornot then return end

		DrawPlayerRagdoll(ent, self)
		RenderAccessoriesCool(ent, self)
		hook_Run("CoolPostDrawAppearance", ent, self)
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
		hook.Add("HUDPaint", "leanin", function()
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
		local val = ply:GetAimVector():Dot(diff) / diff:Length()
		return val >= (floatDiff or 0.8), val
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
--\\ Disable drive (driving is fixed so i don't think that we need this)
	--[[hook.Add("StartEntityDriving", "disabledriving", function(ent, ply)
		return false
	end)

	hook.Add("PlayerDriveAnimate", "disabledriving", function(ent, ply)
		return false
	end)]]
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
		if ply.PlayerClassName == "Combine" or ply.PlayerClassName == "furry" then return false end --!! TODO: CLASS.NoFlashLight boolean

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

		--if IsValid(ply.FakeRagdoll) then return false end
		if ply.PickUpCooldown > CurTime() and not IsValid(ply.FakeRagdoll) then return false end

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

--\\ Weired shit, but works!
	timer.Simple(5,function()
		hook.Remove( "ScaleNPCDamage", "AddHeadshotPuffNPC" )
		hook.Remove( "ScalePlayerDamage", "AddHeadshotPuffPlayer" )
		hook.Remove( "EntityTakeDamage", "AddHeadshotPuffRagdoll" )
	end)
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
		if SERVER and DEVELOPERS_LIST[ply:SteamID64()] then
			PrintMessage(HUD_PRINTTALK, ply:Nick() .. " - zteam dev here!")
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

--\\
	hg_suppression_viewpunch = CreateConVar("hg_suppression_viewpunch", "1", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Enable viewpunching when you on suppressed", 0, 1)
--//