local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
local IsValid = IsValid

--\\ View Punch
	local PLAYER = FindMetaTable("Player")
	hg.SetEyeAngles = hg.SetEyeAngles or PLAYER.SetEyeAngles

	function PLAYER:SetEyeAngles(ang)
		if !self.lockcamera then
			hg.SetEyeAngles(self, ang)
		end
	end

	local math_Clamp = math.Clamp
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

		function hg.CalculateConsciousnessMul()
			local consciousness = 1

			local org = lply.organism
			if org and org.consciousness then
				consciousness = consciousness * org.consciousness
				consciousness = consciousness * math_Clamp(org.blood / 4000, 0.5, 1)
				consciousness = consciousness * math_Clamp(org.o2[1] / 20, 0.5, 1)
				--consciousness = consciousness * (org.larmamputated and 0.8 or 1) * (org.rarmamputated and 0.8 or 1)
				consciousness = consciousness * (1 - org.disorientation / 10)
				//consciousness = consciousness * math.min(1, org.stamina[1] / (org.stamina.max * 0.3))
			end

			return math_Clamp(((consciousness - 1) * 3 + 1), 0.4, 1)
		end

		function hg.InGame()
			local x, y = input.GetCursorPos()

			return !(vgui.CursorVisible() or (x == 0 and y == 0))
		end

		hook.Add("Think", "vp_think", function()
			if IsValid(lply.FakeRagdoll) and hg.InGame() then return end
			
			hook.Run("ViewpunchThink")
		end)

		local lastplyroll
		hook.Add("ViewpunchThink", "viewpunch_think", function(tblang)
			--if lply:InVehicle() then return end

			local consmul = hg.CalculateConsciousnessMul()

			if not vp_punch_angle:IsZero() or not vp_punch_angle_velocity:IsZero() then
				vp_punch_angle = vp_punch_angle + vp_punch_angle_velocity * ftlerped * 1
				local damping = 1 - (PUNCH_DAMPING * ftlerped) * consmul
				if damping < 0 then damping = 0 end
				vp_punch_angle_velocity = vp_punch_angle_velocity * damping
				local spring_force_magnitude = PUNCH_SPRING_CONSTANT * ftlerped * 5 * consmul
				vp_punch_angle_velocity = vp_punch_angle_velocity - vp_punch_angle * spring_force_magnitude
				local x, y, z = vp_punch_angle:Unpack()
				vp_punch_angle = Angle(math_Clamp(x, -89, 89), math_Clamp(y, -179, 179), math_Clamp(z, -89, 89))
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
				vp_punch_angle2 = Angle(math_Clamp(x, -89, 89), math_Clamp(y, -179, 179), math_Clamp(z, -89, 89))
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
				vp_punch_angle3 = Angle(math_Clamp(x, -89, 89), math_Clamp(y, -179, 179), math_Clamp(z, -89, 89))
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
				vp_punch_angle4 = Angle(math_Clamp(x, -89, 89), math_Clamp(y, -179, 179), math_Clamp(z, -89, 89))
			else
				vp_punch_angle4 = Angle()
				vp_punch_angle_velocity4 = Angle()
			end

			--if not lply:Alive() then vp_punch_angle:Zero() vp_punch_angle_velocity:Zero() vp_punch_angle2:Zero() vp_punch_angle_velocity2:Zero() end

			local consmulrev = 1 - consmul
			if vp_punch_angle:IsZero() and vp_punch_angle_velocity:IsZero() and vp_punch_angle2:IsZero() and vp_punch_angle_velocity2:IsZero() and vp_punch_angle3:IsZero() and vp_punch_angle_velocity3:IsZero() and  vp_punch_angle4:IsZero() and vp_punch_angle_velocity4:IsZero() then return end
			local add = vp_punch_angle - vp_punch_angle_last + vp_punch_angle2 - vp_punch_angle_last2 + vp_punch_angle3 - vp_punch_angle_last3 + vp_punch_angle4 * consmulrev - vp_punch_angle_last4 * consmulrev
			if lply.organism and lply.organism.otrub then add:Zero() end
			
			if hg.InGame() then
				lastplyroll = lply:EyeAngles()[3]
			end
			
			local angs = lply:EyeAngles()
			--angs[3] = lastplyroll or angs[3]
			
			local ang = angs + add
			
			lply:SetEyeAngles(ang)
			if tblang then
				tblang.angle = tblang.angle + add
				tblang.vpangle = add
			end
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

		function GetAllViewPunchAngles()
			return GetViewPunchAngles2() + GetViewPunchAngles3() + GetViewPunchAngles4()
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
			current_on_ground = lply:OnGround()

			speedPrevious = speed
			speed = -lply:GetVelocity().z

			if prev_on_ground != current_on_ground and current_on_ground and lply:GetMoveType() != MOVETYPE_NOCLIP then
				angle_hitground.p = math_Clamp(speedPrevious / 25, 0, 20)

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