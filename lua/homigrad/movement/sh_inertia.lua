local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
--\\ Inertia & stuff
	--\\ Antibhop accelerate (not used anyway)
		--[[hook.Add("OnPlayerHitGround", "Movement", function(ply, inWater, onFloater, speed)
			local vel = ply:GetVelocity()

			if (ply.MovementInertia and vel:LengthSqr() > 10000) then
				ply.MovementInertia = ply.MovementInertia + (vel / vel:Length() * math.abs(vel[3])) * 0.75
			end
		end)]]
	--//

	--\\ Side movement calculation
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

	local hg_movement_stamina_debuff = CreateConVar("hg_movement_stamina_debuff", "0.3", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Multiply movement debuff when having low stamina", 0, 1)
	local hg_inertiamul = CreateConVar("hg_inertiamul", "1", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Multiply inertia for player movement", 0.01, 5)
	local hg_divejump = CreateConVar("hg_divejump", "0", {FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Toggle dive jumps on crouch jump", 0, 1)

	local vomitVPAng, vecZero = Angle(1, 0, 0), Vector()
	hook.Add("SetupMove", "HG(StartCommand)", function(ply, mv, cmd)
		--\\ DeltaTime
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

			if ply.MovementInertia then
				ply.MovementInertia:Zero()
			end
		end

		if (ply:GetMoveType() == MOVETYPE_NOCLIP) then
			hook.Run("HG_MovementCalc", vecZero, 0, 1, ply, cmd, mv)
			hook.Run("HG_MovementCalc_2", {1}, ply, cmd, mv)

			return
		end

		if(ply:InVehicle())then
			return
		end

		local runnin = ply:KeyDown(IN_SPEED) and not ply:Crouching() and ply:KeyDown(IN_FORWARD)

		--[[if runnin then
			mv:SetSideSpeed(0) --meh
			cmd:SetSideMove(0)
			cmd:RemoveKey(IN_BACK)
		end]]

		if not IsValid(ply.FakeRagdoll) and ply:KeyDown(IN_SPEED) and not ply:Crouching() and ply:KeyDown(IN_BACK) then
			cmd:RemoveKey(IN_SPEED)
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

		--\\ Running
		ply.CurrentSpeed = ply.CurrentSpeed or walk_speed
		ply.CurrentFrictionMul = ply.CurrentFrictionMul or 1
		ply.FrictionGainMul = 0.01
		ply.FrictionLoseMul = 0.2
		ply.SpeedGainMul = 240 * weightmul * (ply.organism.superfighter and 5 or 1) * (ply:GetNWInt("SpeedGainClassMul", 1) or 1)
		ply.SpeedLoseMul = 10000
		ply.SpeedSharpLoseMul = 0.007
		ply.InertiaBlend = 2000 * weightmul * (ply.organism.superfighter and 100 or 1)
		ply.DuckingSlowdown = ply.DuckingSlowdown or 0
		-- ply.InertiaBlend = 15 * weightmul * ply.CurrentFrictionMul
		local inertia_blend_mul = 1

		if(velLen <= slow_walk_speed)then
			inertia_blend_mul = 1
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

		--\\ Speed acceleration & deceleration
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

		local change = math.abs(math.AngleDifference(calc_vector2d_angle(ply.LastVelocity), calc_vector2d_angle(vel))) // * (SERVER and 0 or 5)

		if ply.LastVelocity == vel and ply.LastChangeVelocity then // this is so bullshit but it works
			change = ply.LastChangeVelocity
		end

		local change_mul = math.abs(ply.CurrentSpeed - slow_walk_speed)

		ply.LastChangeVelocity = change
		ply.CurrentSpeed = math.Approach(ply.CurrentSpeed, slow_walk_speed * mul, delta_time * change * change_mul * ply.SpeedSharpLoseMul * 0.25 * 200)
		ply.LastVelocity = vel
		ply.LastVelocityLen = velLen
		--//

		local speed = ply.CurrentSpeed
		--\\ Inertia
		local ply_angles = cmd:GetViewAngles()

		ply.MovementInertia = ply.MovementInertia or vel

		--\\ Side & back running debuffs
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
		--//

		local inertia_to = calc_forward_side_moves_to_vector2d(fm, sm, ply_angles) * speed
		--\\ Air & water walking debuffs
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
		--//

		--\\ Friction
			local consciousness = 1

			if ply.organism and ply.organism.consciousness then
				consciousness = consciousness * ply.organism.consciousness
				consciousness = consciousness * math.Clamp(ply.organism.blood / 4000, 0.5, 1)
			end

			local consmul = math.Clamp(((consciousness - 1) * 4 + 1), 0.1, 1)

			//if(water_level > 0)then
			//	ply.CurrentFrictionMul = math.Approach(ply.CurrentFrictionMul, 0.2, delta_time * ply.FrictionLoseMul * water_level)
			//else
				// ply.CurrentFrictionMul = math.Approach(ply.CurrentFrictionMul, consmul, delta_time * ply.FrictionGainMul * (consmul < ply.CurrentFrictionMul and 100 or 10))
			//end

			ply.CurrentFrictionMul = 0.5 / hg_inertiamul:GetFloat()
			ply.InertiaBlend = ply.InertiaBlend * ply.CurrentFrictionMul

			-- local new_inertia = LerpVector(0.5^(delta_time * ply.InertiaBlend), ply.MovementInertia, inertia_to)
			-- local new_inertia = LerpVector(1 - 0.5^(delta_time * ply.InertiaBlend), ply.MovementInertia, inertia_to)
			//local new_inertia = approach_vector(ply.MovementInertia, inertia_to, 1000)//SERVER and delta_time * ply.InertiaBlend * ply:Ping() / 100 or delta_time * ply.InertiaBlend)
			//local new_inertia = approach_vector_smooth(ply.MovementInertia, inertia_to, hg.lerpFrameTime2(0.075, delta_time))
			if !ply:OnGround() then
				ply.MovementInertia = ply.LastVelocity	
			end

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
		k = k * math.Clamp(math.Round((org.stamina and org.stamina[1] or 180), 0) / 120, hg_movement_stamina_debuff:GetFloat(), 1)
		k = k * math.Clamp(5 / ((org.immobilization or 0) + 1), 0.25, 1)
		k = k * math.Clamp((org.blood or 0) / 5000, 0, 1)
		k = k * math.Clamp(10 / ((org.shock or 0) + 1), 0.25, 1)
		k = k * (math.min(math.Round((org.adrenaline or 0), 1) / 24, 0.3) + 1)
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

		--// Dive jump
		if hg_divejump:GetBool() then
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
		end

		--print(speed.." "..(CLIENT and "c" or "s"))
		--speed = SERVER and speed + 50 or speed

		if ply:GetMoveType() == MOVETYPE_LADDER or ply:GetMoveType() == MOVETYPE_NONE then
			inertia_len = 100
		end

		if org.noradrenaline and org.noradrenaline > 0 then
			inertia_len = inertia_len + 200 * math.Round(org.noradrenaline, 1)
		end

		mv:SetMaxSpeed(math.max(100, inertia_len))
		mv:SetMaxClientSpeed(math.max(100, inertia_len))
		ply:SetMaxSpeed(math.max(100, inertia_len))
		ply:SetJumpPower(DEFAULT_JUMP_POWER * math.min(k, 1.1) * (not ply:GetNWBool("TauntStopMoving", false) and 1 or 0) * (ply.organism.superfighter and 1.5 or 1) * (ply.JumpPowerMul or 1))

		if(CLIENT)then
			local fwangs = math.rad(GetViewPunchAngles2()[2] + GetViewPunchAngles3()[2])

			forward_move = forward_move * math.cos(fwangs) + side_move * math.sin(fwangs)
			side_move = side_move * math.cos(fwangs) + forward_move * math.sin(fwangs)

			cmd:SetForwardMove(forward_move * inertia_len)
			cmd:SetSideMove(side_move * inertia_len)
		end

		mv:SetForwardSpeed(forward_move * inertia_len)
		mv:SetSideSpeed(side_move * inertia_len)
	end)
--//

--\\ Remove sandbox jump boost
	local gamemod = engine.ActiveGamemode()
	hook.Add("PlayerSpawn", "RemoveSandboxJumpBoost", function(ply)
		if (gamemod != "sandbox") then return end

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

--\\ Anti-gmod PVP system (anti crouch spam)
	hook.Add("StartCommand", "HG_AntiGmodPVP", function(ply, cmd)
		ply.NowCrouched = cmd:KeyDown(IN_DUCK)
		ply.OldCrouched = ply.OldCrouched or cmd:KeyDown(IN_DUCK)

		if not ply:OnGround() and ply:WaterLevel() < 2 and ply:GetMoveType() == MOVETYPE_WALK and ply.OldCrouched != ply.NowCrouched then
			cmd:AddKey(IN_DUCK)
		end

		ply.OldCrouched = cmd:KeyDown(IN_DUCK)
	end)
--//