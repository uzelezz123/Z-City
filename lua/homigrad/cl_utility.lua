local plymeta = FindMetaTable("Player")
hg.ConVars = hg.ConVars or {}
--\\ AimVector fix
	hg.GetAimVector = hg.GetAimVector or plymeta.GetAimVector

	function plymeta:GetAimVector()
		if self == LocalPlayer() then
			return hg.GetAimVector(self)
		elseif self:InVehicle() then
			local ang = self:EyeAngles()
			--ang:Add(-self:GetVehicle():GetAngles())
			return ang:Forward()
		end
		return hg.GetAimVector(self)
	end
--//

--\\ Check if player is seeing local perspective for himself
	function plymeta:IsLocal()
		local lply = LocalPlayer()
		return ((self ~= lply) or (lply ~= GetViewEntity()))
	end
--//

--\\ Debug useful commands
	if CLIENT then
		function PrintPosParameters(ent)
			for i = 0, ent:GetNumPoseParameters() - 1 do
				local min, max = ent:GetPoseParameterRange( i )
				print( ent:GetPoseParameterName( i ) .. ' ' .. min .. " / " .. max )
			end
		end

		function PrintBones( entity )
			for i = 0, entity:GetBoneCount() - 1 do
				print( i, entity:GetBoneName( i ) )
			end
		end

		function PrintBodygroups( entity )
			PrintTable(entity:GetBodyGroups())
		end

		function PrintAnims( entity )
			PrintTable(entity:GetSequenceList())
		end

		concommand.Add("printanims", function(ply)
			PrintAnims(ply)
		end)

		concommand.Add("printbones", function(ply)
			PrintBones(ply)
		end)

		concommand.Add("printbodygroups", function(ply)
			PrintBodygroups(ply)
		end)

		concommand.Add("printanimswm", function(ply)
			PrintAnims(ply:GetActiveWeapon():GetWM())
		end)

		concommand.Add("printanimszmodel", function(ply)
			PrintAnims(ply.zmodel)
		end)

		concommand.Add("printboneswm", function(ply)
			PrintBones(ply:GetActiveWeapon():GetWM())
		end)

		concommand.Add("printbodygroupswm", function(ply)
			PrintBodygroups(ply:GetActiveWeapon():GetWM())
		end)
	end
--//

--\\ Holster think for weapons & automatic attack stuff
	if CLIENT then
		hook.Add("Player Think", "fucking bullshit", function(ply)
			local wep = ply:GetActiveWeapon()

			if IsValid(wep) and wep.ismelee and ply != LocalPlayer() then
				if wep.Think and not wep.HomicideSWEP then
					wep:Think()
				end

				if hg.KeyDown(ply, IN_ATTACK) and wep:CanPrimaryAttack() and not wep.HomicideSWEP then
					if not wep.Primary.Automatic then
						if not ply.keypress1 then
							wep:PrimaryAttack()
							ply.keypress1 = true
						end
					else
						wep:PrimaryAttack()
					end
				else
					ply.keypress1 = false
				end

				if hg.KeyDown(ply, IN_ATTACK2) and wep:CanSecondaryAttack() and not wep.HomicideSWEP then
					if not wep.Primary.Automatic then
						if not ply.keypress2 then
							wep:SecondaryAttack()
							ply.keypress2 = true
						end
					else
						wep:SecondaryAttack()
					end
				else
					ply.keypress2 = false
				end
			end
		end)
	end
--//

--\\ Remove cl models on cleanup
	hg.oldClientsideModel = hg.oldClientsideModel or ClientsideModel
	hg.ClientsideModels = hg.ClientsideModels or {}

	function ClientsideModel(...)
		local model = hg.oldClientsideModel(...)
		table.insert(hg.ClientsideModels,model)
		--print(model)
		return model
	end

	function hg.PrintModels()
		for i,mdl in ipairs(hg.ClientsideModels) do
			if not IsValid(mdl) then continue end
			print(mdl,mdl:GetModel())
		end
	end

	function hg.ClearClientsideModels()
		for i,mdl in pairs(hg.ClientsideModels) do
			if not IsValid(mdl) then continue end
			mdl:Remove()
		end
		hg.ClientsideModels = {}
	end

	hook.Add("PostCleanupMap","fuckclientsidemodels",hg.ClearClientsideModels)
--//

--\\ Fake status info for scare mode
	local keys = {
		[KEY_S] = "s",
		[KEY_T] = "t",
		[KEY_A] = "a",
		[KEY_U] = "u",
		[KEY_ENTER] = "\n",
		[KEY_SPACE] = " ",
		[KEY_SEMICOLON] = ";",
	}
	local status = {
		[KEY_S] = false,
		[KEY_T] = false,
		[KEY_A] = false,
		[KEY_U] = false,
		[KEY_ENTER] = false,
		[KEY_SPACE] = false,
		[KEY_SEMICOLON] = false,
		[KEY_BACKSPACE] = false,
	}
	local strstatus = ""
	hook.Add("Move", "fakestatus", function(ply, mv)
		if !CurrentRound then return end
		local rnd = CurrentRound()
		if rnd.name != "fear" then return end
		local alive = zb:CheckAlive()
		if (#alive != 1) or (alive[1] != ply) then return end
		for v, val in pairs(status) do
			if input.IsKeyDown(v) then
				if !val then
					status[v] = true
					if v == KEY_BACKSPACE then
						strstatus = string.sub(strstatus, 1, string.len(strstatus) - 1)
					else
						strstatus = strstatus .. keys[v]
					end
					--print(strstatus)
				end
			else
				if val then
					status[v] = false
				end
			end
		end
		local st, en = string.find(strstatus, "status")
		local st2, en2 = string.find(strstatus, "\n")
		if st2 then
			strstatus = ""
		end
		if st and st2 and st2 > st then
			timer.Simple(0, function()
				local bignum = math.pow(2, 20)
				for i = 1, 20 do 
					print(("\n"):rep(bignum))
				end
				MsgC(color_white, string.format([[
hostname: %s
version : 2025.03.26/24 9748 secure
udp/ip  : %s:27015  (public ip: %s)
steamid : [A-1:%s(63621)] (%s)
map     : %s at: 0 x, 0 y, 0 z
uptime  : %s, %s server
players : 1 humans, 0 bots (20 max)
# userid name                uniqueid            connected ping loss state
#      2 "%s"           %s   %s    %s    0 active
]], GetHostName(), game.GetIPAddress(), game.GetIPAddress(), lply:AccountID(), lply:SteamID64(), game.GetMap(), string.FormattedTime(CurTime(), "%02i h %02i m"), string.FormattedTime(CurTime(), "%02i h %02i m"), lply:Name(), lply:SteamID(), string.FormattedTime(CurTime(), "%02i:%02i:%02i"), lply:Ping()))
			end)
		end
	end)
--//

--\\ Network created ragdolls
	hook.Add("NetworkEntityCreated", "network_ragdoll_created", function(ent)
		local index = ent:EntIndex()
		if IsValid(ent) and zb.net and zb.net[index] and zb.net[index].waiting then
			zb.net[index].waiting = nil
			for key,var in pairs(zb.net[index]) do
				hook.Run("OnNetVarSet", index, key, var)
			end
		end
	end)
--//

--\\ Supression
	if CLIENT then
		suppressionVec = Vector(0, 0, 0)
		suppressionDist = 0
		suppressionDistAdd = 0
		net.Receive("add_supression", function()
			if not IsValid(lply) or not lply:IsPlayer() then return end
			if !lply:Alive() or !lply.organism or lply.organism.otrub then return end

			local pos = net.ReadVector()
			local eyePos = LocalPlayer():EyePos()
			local dist = pos:Distance(eyePos)
			if dist > 500 then return end
			local isVisible = not util.TraceLine({
				start = pos,
				endpos = eyePos,
				filter = {lply},
				mask = MASK_SHOT
			}).Hit
			if not isVisible then dist = dist * 2 end

			Suppress(dist * 25)
			ViewPunch(AngleRand(-1,1) * dist / 100)
			ViewPunch2(AngleRand(-1,1) * dist / 100)
		end)

		local anguse = Angle(0,0,0)
		s_suppression = s_suppression or 0
		hook.Add("PostEntityFireBullets","bulletsuppression2",function(ent,bullet)
			if not lply:Alive() then return end
			if not IsValid(lply) or not lply:IsPlayer() then return end
			if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
			local tr = bullet.Trace
			local mr = math.random(17)
			local view = render.GetViewSetup(true)
			if tr.StartPos:Distance( tr.HitPos ) > 5000 then
				local time = view.origin:Distance(tr.StartPos+tr.HitPos/2) / 17836
				timer.Simple(time,function()
					EmitSound("cracks/distant/dist_crack_" .. ( mr < 9 and "0" or "") .. mr .. ".ogg", tr.StartPos+tr.HitPos*0.35, 0, CHAN_AUTO, 1,SNDLVL_140dB)
				end)
			end

			local self = ent
			if tr.Entity == hg.GetCurrentCharacter(lply) then

				Suppress((10))
				return
			end

			if not IsValid(self) or self:GetOwner() == lply:GetViewEntity() then return end

			local eyePos = view.origin
			local dis, pos = util.DistanceToLine(tr.StartPos, tr.HitPos, eyePos)
			local isVisible = not util.TraceLine({
				start = pos,
				endpos = eyePos,
				filter = {self, lply, lply:GetViewEntity(), self:GetOwner(), hg.GetCurrentCharacter(lply)},
				mask = MASK_SHOT
			}).Hit

			if not isVisible then return end

			local dist = pos:Distance(eyePos)
			local shooterdist = tr.StartPos:Distance(eyePos)
			local mr = math.random(9)

			if shooterdist < 200 and not IsLookingAt(self:GetOwner(),eyePos) then return end
			if dist < 180 then EmitSound("cracks/heavy/heav_crack_0" .. mr .. ".ogg", pos, 0, CHAN_AUTO, 1,65) end
			if dist > 120 then return end

			EmitSound("cracks/heavy/heav_crack_0" .. mr .. ".ogg", pos, 0, CHAN_AUTO, 1,85)

			dist = dist / math.abs((tr.HitPos - tr.StartPos):GetNormalized():Dot((tr.StartPos - eyePos):GetNormalized()))
			dist = math.Clamp(1 / dist, 0.05,0.25)
			local localpos = (eyePos - pos):GetNormalized()

			local ang_yaw = localpos:Dot(lply:EyeAngles():Right())
			local ang_pitch = localpos:Dot(lply:EyeAngles():Up())

			anguse[2] = -ang_yaw / (dist * 30)
			anguse[1] = -ang_pitch / (dist * 30)

			local badass = lply.organism and lply.organism.recoilmul or 1
			local bulletdmg = math.max(bullet.Damage/25,1)
			ViewPunch(anguse * badass * bulletdmg)
			ViewPunch2((anguse * badass * bulletdmg)/-2)
			Suppress((dist * 45) * badass * bulletdmg)
		end)
		-- SIB - Salatis Imersive Base
		SIB_suppress = SIB_suppress or {}
		SIB_suppress.Force = 0

		function Suppress(force)
			SIB_suppress.Force = math.Clamp(SIB_suppress.Force + force / 1, 0, 10)
		end

		local pain_mat = Material("sprites/mat_jack_hmcd_narrow")

		local colormodify = {
			[ "$pp_colour_addr" ] = 0,
			[ "$pp_colour_addg" ] = 0,
			[ "$pp_colour_addb" ] = 0,
			[ "$pp_colour_brightness" ] = 0,
			[ "$pp_colour_contrast" ] = 1,
			[ "$pp_colour_colour" ] = 0,
			[ "$pp_colour_mulr" ] = 0,
			[ "$pp_colour_mulg" ] = 0,
			[ "$pp_colour_mulb" ] = 0
		}

		local hg_potatopc = GetConVar("hg_potatopc") or CreateClientConVar("hg_potatopc", "0", true, false, "enable this if you are noob", 0, 1)

		hg.ConVars.potatopc = hg_potatopc

		local vignetteMat = Material( "effects/shaders/zb_vignette" )
		hook.Add("RenderScreenspaceEffects","SIB_Suppresss",function()
			if not LocalPlayer():Alive() then return end

			local fraction = math.Clamp(SIB_suppress.Force / 5, 0, 1)

			local force = SIB_suppress.Force - 1

			if force > 0 then
				render.UpdateScreenEffectTexture()

				vignetteMat:SetFloat("$c2_x", CurTime() + 10000) //Time
				vignetteMat:SetFloat("$c0_z", force / 3 ) //ColorIntensity
				vignetteMat:SetFloat("$c1_y", force / 12 ) //Vignette

				render.SetMaterial(vignetteMat)
				render.DrawScreenQuad()
			end

			if force > 6 then
				colormodify["$pp_colour_colour"] = math.max(2 - force / 6, .4)
				DrawColorModify(colormodify)
			end

			if !hg_potatopc:GetBool() then DrawToyTown(fraction,ScrH() * fraction / 1.5) end

		end)

		hook.Add("Think","SIB_Suppresss_Think",function()
			SIB_suppress.Force = Lerp(0.25 * FrameTime(), SIB_suppress.Force,0)
		end)

		hook.Add("PlayerDeath","huyDeathRemoveSuppression",function()
			SIB_suppress.Force = 0
		end)
	end
--//

--\\ CL Custom player think
	local hook_Run = hook.Run
	local CurTime = CurTime

	lastcall = SysTime() - 0.01

	hg.ragdolls = hg.ragdolls or {}

	hook.Add("EntityRemoved", "huyasdowo", function(ent)
		table.RemoveByValue(hg.ragdolls, ent)
	end)

	hook.Add("Think", "hg-playerthink", function()
		local time = CurTime()
		local dtime = SysTime() - lastcall
		lastcall = SysTime()

		if CLIENT then
			lply = IsValid(lply) and lply or LocalPlayer()
			local entities = hg.seenents
			
			for i = 1, #entities do
				ent = entities[i]
				
				if not IsValid(ent) or (ent:IsPlayer() and not ent:Alive()) or IsValid(ent.FakeRagdoll) then continue end
				--print(ent, CurTime())
				local ply = ent:IsPlayer() and ent or IsValid(ent.ply) and ent.ply
				-- limiter
				//if (ent.lasttimethink or 0) > CurTime() then continue end
				//ent.lasttimethink = CurTime() + (ply and ply == lply and 0 or 0.1)

				if ply and ply:IsPlayer() and ply:Alive() then
					hook_Run("Player Think", ply, time, dtime)
				end

				hook_Run("Player-Ragdoll think", ply or ent, ent, time, dtime)
			end
		end
	end)
--//
--\\ Custom emitsound
	local vectorZero = Vector(0,0,0)
	oldEmitSound = oldEmitSound or EmitSound
	local entMeta = FindMetaTable("Entity")

	function EmitSound( soundName, position, entity, channel, volume, soundLevel, soundFlags, pitch, dsp, filter )
		soundName = soundName or ""
		position = position or vectorZero
		entity = entity or 0
		volume = volume or 1
		soundLevel = soundLevel or 75
		soundFlags = soundFlags or 0
		pitch = pitch or 100
		pitch = changePitch(pitch)
		dsp = dsp or 0
		filter = filter or nil
		local sndparms
		local sndBool = false
		if IsValid(lply) then
			local Ears = lply:GetNetVar("Armor",{})["ears"]
			sndparms = hg.armor.ears[Ears] or false
			sndBool = sndparms and true or false
		end
		oldEmitSound(soundName, position, entity, channel, sndBool and volume > sndparms.NormalizeSnd[1] and sndparms.NormalizeSnd[2] or volume + (sndBool and sndparms.VolumeAdd or 0) , soundLevel + (sndBool and sndparms.SoundlevelAdd or 0), soundFlags, pitch, dsp, filter)
	end

	hg.EmitSound = EmitSound

	oldEntEmitSound = oldEntEmitSound or entMeta.EmitSound

	function entMeta.EmitSound(self,soundName,soundLevel,pitch,volume,channel,soundFlags,dsp,filter)
		soundName = soundName or ""
		position = position or vectorZero
		entity = entity or 0
		volume = volume or 1
		soundLevel = soundLevel or 75
		soundFlags = soundFlags or 0
		pitch = pitch or 100
		--pitch = changePitch(pitch) or 1
		dsp = dsp or 0
		filter = filter or nil
		local sndparms
		if IsValid(lply) then
			local Ears = lply:GetNetVar("Armor",{})["ears"]
			sndparms = hg.armor.ears[Ears] or false
			sndBool = sndparms and true or false
		end
		oldEntEmitSound(self, soundName, soundLevel + (sndBool and sndparms.SoundlevelAdd or 0), pitch, sndparms and volume > sndparms.NormalizeSnd[1] and sndparms.NormalizeSnd[2] or volume + (sndBool and sndparms.VolumeAdd or 0), channel, soundFlags, dsp, filter)
	end
--//

--\\ custom sens
	local hg_zoomsensitivity = ConVarExists("hg_zoomsensitivity") and GetConVar("hg_zoomsensitivity") or CreateConVar("hg_zoomsensitivity", 1, FCVAR_ARCHIVE, "aiming zoom sensitifity multiplier", 0, 3)

	hook.Add("AdjustMouseSensitivity", "AdjustRunSensivityHUY", function(defaultSensitivity)
		if not lply:Alive() then return end--kakoy sencivity NOOB
		local org = lply.organism or {}
		if not org or not org.brain then return end

		local vel = lply:GetVelocity()
		local isrunning = lply:KeyDown(IN_SPEED) and vel:Length() >= 10 and not lply:Crouching() and not IsValid(lply:GetNWEntity("FakeRagdoll"))
		local eyeAngles = lply:EyeAngles()
		local self = lply:GetActiveWeapon()
		self = IsValid(self) and self
		local wepMul = self and self.IsZoom and self:IsZoom() and ((self:HasAttachment("sight", "optic")) and not self.viewmode1 and math.min(self.ZoomFOV / 60, 0.5) or 0.4) * hg_zoomsensitivity:GetFloat() or 1
		local weaponAdjust = 1

		if IsValid(self) and self.AdjustMouseSensitivity then
			weaponAdjust = self:AdjustMouseSensitivity() or 1
		end

		local hookResult = hook.Run("hg_AdjustMouseSensitivity",lply)
		if hookResult ~= nil then
			return hookResult
		end
		eyeAngles[1] = 0

		local forwardMoving = math.max(vel:GetNormalized():Dot(eyeAngles:Forward()), 0.6)
		local brainadjust = org.brain > 0.05 and math.Clamp(((org.brain - 0.05) * math.sin(CurTime()) * 20), -2, 2) or 0
		local stunmul = math.max((1 - math.max(LocalPlayer():GetLocalVar("stun", CurTime()) - CurTime(), 0) / 3), 0)
		if lply:KeyDown(IN_SPEED) and lply:KeyDown(IN_WALK) and vel:LengthSqr() >= 10000 and IsValid(wep) and wep:GetClass() == "weapon_hands_sh" then
			return (math.max((lply.PlayerClassName == "furry" and 0.2 or 0.25) / ((org.immobilization or 0) / 30 + 1),0.2) * wepMul) * weaponAdjust * stunmul + brainadjust
		end
		if isrunning and lply:GetMoveType() ~= MOVETYPE_NOCLIP then
			return 0.5 * math.max(1 / ((org.immobilization or 0) / 30 + 1),0.4) * wepMul * weaponAdjust * stunmul + brainadjust
		end

		return (math.max(1 / ((org.immobilization or 0) / 30 + 1),0.4) * wepMul) * weaponAdjust * stunmul + brainadjust
	end)
--//

--\\ flashlighs move to CL util
	local flashlightPos,flashlightAng = Vector(3, -2, -1),Angle(0, 0, 0)

	function hg.FlashlightTransform(ply)
		local lh = ply:LookupBone("ValveBiped.Bip01_L_Hand")
		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
		local lhmat = ent:GetBoneMatrix(lh)
		local pos = lhmat:GetTranslation()
		local ang = lhmat:GetAngles()
		pos, ang = LocalToWorld(flashlightPos,flashlightAng,pos,ang)
		ply.flmodel = IsValid(ply.flmodel) and ply.flmodel or ClientsideModel("models/runaway911/props/item/flashlight.mdl")
		ply.flmodel:SetNoDraw(true)
		ply.flmodel:SetModelScale(0.75)
		if IsValid(ply.flmodel) then
			ply.flmodel:SetRenderOrigin(pos)
			ply.flmodel:SetRenderAngles(ply:EyeAngles())
		end
	end

	hook.Add("Player_Death","removeflashlight",function(ply)
		if ply.flashlight and ply.flashlight:IsValid() then
			ply.flashlight:Remove()
		end
	end)
--//

--\\ Can see or not
	--local checkcd = 0
	local ents_FindByClass = ents.FindByClass
	local player_GetAll = player.GetAll
	local render_GetViewSetup = render.GetViewSetup
	LocalPlayerSeen = true
	hg.seenents = {}
	hg.seenents2 = {}
	local hg_fov = GetConVar("hg_fov")
	local math_cos = math.cos
	local math_rad = math.rad
	local util_DistanceToLine = util.DistanceToLine
	local table_Add = table.Add

	hook.Add("Think", "CanBeSeenOrNot", function()
		--if checkcd > CurTime() then return end
		--checkcd = CurTime() + 1
		local entities = ents_FindByClass("prop_ragdoll")
		table_Add(entities, player_GetAll())

		hg.seenents = {}
		hg.seenents2 = {}

		if g_VR and g_VR.active then return end

		local view = render_GetViewSetup()
		local origin = view.origin
		local angles = view.angles

		for i = 1, #entities do
			v = entities[i]
			if v.shouldTransmit then
				hg.seenents2[#hg.seenents2 + 1] = v
			end

			local nochange = (v == lply.FakeRagdoll) or (lply:Alive() and v == lply) or (not lply:Alive() and v == lply:GetNWEntity("spect"))

			if nochange then
				v.NotSeen = false
				hg.seenents[#hg.seenents + 1] = v
				continue
			end

			local min,max = v:GetModelBounds()
			local len = (max - min):Length()
			local vPos = v:GetPos()
			local _, point, _ = util_DistanceToLine(origin, origin + angles:Forward() * 9999, vPos)
			local vSize = (point - vPos):GetNormalized() * len
			local diff = (vPos + vSize - origin):GetNormalized()

			if !v.shouldTransmit or (angles:Forward():Dot(diff) <= math_cos(math_rad(hg_fov:GetInt()))) then
				if not nochange then v.NotSeen = true end
				if v == lply then LocalPlayerSeen = false end
			else
				if not nochange then v.NotSeen = false end
				if v == lply then LocalPlayerSeen = true end
				hg.seenents[#hg.seenents + 1] = v
			end
		end
	end)
--//

--\\ move it to CL util
		local meta = FindMetaTable( "Panel" )

		function meta:SlideDown( length, delay )

			local height = self:GetTall()
			self:SetVisible( true )
			self:SetTall( 0 )

			local anim = self:SizeTo( -1, height, length, delay or 0, 0.2 )

		end
	
		local hull = 10
		local HullMaxs = Vector(hull, hull, 72)
		local HullMins = -Vector(hull, hull, 0)
		local HullDuckMaxs = Vector(hull, hull, 36)
		local HullDuckMins = -Vector(hull, hull, 0)
		local ViewOffset = Vector(0, 0, 64)
		local ViewOffsetDucked = Vector(0, 0, 38)

		gameevent.Listen( "OnRequestFullUpdate" )
		hook.Add("OnRequestFullUpdate","SetHull",function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end
			ply:SetHull(HullMins, HullMaxs)
			ply:SetHullDuck(HullDuckMins, HullDuckMaxs)
			ply:SetViewOffset(ViewOffset)
			ply:SetViewOffsetDucked(ViewOffsetDucked)
		end)

		hook.Add("PlayerStartVoice","huy_CheckVoice",function(ply)
			if not IsValid(ply) then return end

			ply.IsSpeak = true
		end)

		hook.Add("PlayerEndVoice","huy_CheckVoice",function(ply)
			if not IsValid(ply) then return end
			
			ply.IsSpeak = false
		end)

		hg.playerInfo = hg.playerInfo or {}

		local function UpdateVoiceDSP(listener, talker)
			if not talker:IsSpeaking() then return end
			if not IsValid(listener) or not IsValid(talker) or listener == talker then return end

			local trace = util.TraceLine({
				start = listener:EyePos(),
				endpos = talker:EyePos(),
				mask = MASK_SOLID_BRUSHONLY,
			})

			local volume = (talker:WaterLevel() == 3) and 0.25 or (trace.Hit and 0.5 or 1)

			talker:SetVoiceVolumeScale(!hg.muteall and math.min(hg.playerInfo[talker:SteamID()] and hg.playerInfo[talker:SteamID()][2] or 1, volume) or 0)
		end

		local cachedLerp = Lerp

		local function mouthmove(ply)
			ply:SetVoiceVolumeScale(!hg.muteall and (!hg.mutespect or ply:Alive()) and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)

			if not ply:Alive() then return end
			
			local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
			
			if ply:VoiceVolume() != 0 then
				if (ply.timedupdate or 0) < CurTime() then
					UpdateVoiceDSP(lply, ply)
					
					ply.timedupdate = CurTime() + 0.5
				end
			end

			if lply:GetPos():DistToSqr(ent:GetPos()) > 1500 * 1500 then return end
			
			local flexes = {
				[1] = ent:GetFlexIDByName( "jaw_drop" ),
				[2] = ent:GetFlexIDByName( "left_part" ),
				[3] = ent:GetFlexIDByName( "right_part" ),
				[4] = ent:GetFlexIDByName( "left_mouth_drop" ),
				[5] = ent:GetFlexIDByName( "right_mouth_drop" ),
				[6] = ent:GetFlexIDByName( "lower_lip" )
			}

			local weight = (ply:IsSpeaking() and math.Clamp( ply:VoiceVolume() * 5, 0, 2 )) or 0

			for k = 1, #flexes do
				v = flexes[ k ]
				ent:SetFlexWeight( v, weight )
			end

			local org = ent.organism
			if not org then return end

			if ply:IsPlayer() and ply:Alive() and not org.otrub then
				ent.Blink = ent.Blink or 0
				ent.Blink = ent.Blink + 0.25
				ent.LastBlinking = ent.Blinking or 0
				if ent.Blink > 940 then
					ent.Blinking = cachedLerp(FrameTime() * 65,ent.Blinking or 0,1)
					if ent.Blink > 951 then
						ent.Blink = 0
					end
				else
					ent.Blinking = cachedLerp(FrameTime() * 65,ent.Blinking or 0,0)
				end
			elseif (ent.Blinking or 0) < 0.95 then
				ent.Blinking = cachedLerp(FrameTime() * 5,ent.Blinking or 0,1)
			end

			if ent:IsRagdoll() and ent:GetFlexIDByName("blink") then
				ent:SetFlexWeight(ent:GetFlexIDByName("blink"), ent.Blinking or 0)
				if ent:GetFlexIDByName("wrinkler") then
					ent:SetFlexWeight(ent:GetFlexIDByName("wrinkler"), ent.Blinking or 0)
				end
				if ent:GetFlexIDByName("half_closed") then
					ent:SetFlexWeight(ent:GetFlexIDByName("half_closed"), ent.Blinking or 0)
				end
			end
		end

		hook.Add("Player Think", "MouthThink", function(ply) if IsValid(ply.FakeRagdoll) then mouthmove(ply) end end)

		hg.mouthmove = mouthmove
--//

--\\ Falling effects like in mirror's edge
	local fallsnd = false
	local windsnd = false

	local fallSndStation
	local fallSnd_Volume = 0

	local windSndStation
	local windSnd_Volume = 0
	local windSnd_VolumeSpeed = 0

	local function createSnd()
		if IsValid(fallSndStation) then
			fallSndStation:Stop()
			fallSndStation = nil
		end
		sound.PlayFile( "sound/zcity/other/fallstatic.wav", "noplay noblock", function(station, _, _)
			if IsValid(station) then
				station:EnableLooping( true )
				station:SetVolume( 0 )
				fallSndStation = station
			end
		end)

		if IsValid(windSndStation) then
			windSndStation:Stop()
			windSndStation = nil
		end
		sound.PlayFile( "sound/zcity/other/runwind.wav", "noplay noblock", function(station, _, _)
			if IsValid(station) then
				station:EnableLooping( true )
				station:SetVolume( 0 )
				windSndStation = station
			end
		end)
	end

	hook.Add("SetupMove","hg_FallSound",function()
		local ply = LocalPlayer()
		if not ply:Alive() or not ply.organism or ply.organism.otrub then
			if fallsnd and IsValid(fallSndStation) then
				fallSndStation:SetVolume(0)
				fallSnd_Volume = 0
				fallsnd = false
			end
			if windsnd and IsValid(windSndStation) then
				windSndStation:SetVolume(0)
				windSndStation:Pause()
				windSnd_Volume = 0
				windSnd_VolumeSpeed = 0
				windsnd = false
			end

			return
		end

		local ent = hg.GetCurrentCharacter(ply)
		if not IsValid(ent) then 
			if fallsnd then 
				fallsnd = false 
			end 
			return 
		end
		local vel = ent:GetVelocity():Length()
		if -ent:GetVelocity().z > 700 and (ent:IsRagdoll() or !ply:OnGround()) and (ent:IsRagdoll() and !ent:IsConstrained() or ply:GetMoveType() == MOVETYPE_WALK) and ply:Alive() then
			if not fallsnd then
				fallsnd = true
			end
			local value = 1 - vel / 500
			local ang = AngleRand(-value, value)

			Suppress(0.05)

			if hg.GetCurrentCharacter(ply):IsRagdoll() then
				ang.r = 0
				ply:SetEyeAngles(ply:EyeAngles() + ang)
			else
				SetViewPunchAngles(ang)
			end
		elseif fallsnd then
			fallsnd = false
		end

		if vel > 250 and ply:Alive() and IsValid(windSndStation) and (ent:IsRagdoll() or ply:GetMoveType() == MOVETYPE_WALK) then
			if not windsnd then
				windsnd = true
			end

			windSnd_VolumeSpeed = vel/1400
			windSndStation:SetPlaybackRate(math.min(math.max(vel/700,1),3))
		elseif windsnd then
			windsnd = false
		end
	end)

	hook.Add("Think","hg_FallSnd",function()
		if not IsValid(fallSndStation) or not IsValid(windSndStation) then
			createSnd()
			return 
		end
		-- Fall
		if fallSndStation:GetState() != GMOD_CHANNEL_PLAYING and fallSnd_Volume > 0.01 then
			fallSndStation:Play()
		end

		fallSnd_Volume = LerpFT(0.05, fallSnd_Volume, fallsnd and 1 or 0)
		fallSndStation:SetVolume(fallSnd_Volume)

		if fallSnd_Volume < 0.01 then
			fallSndStation:Pause()
			fallSndStation:SetTime(0)
		end
		-- Wind
		if windSndStation:GetState() != GMOD_CHANNEL_PLAYING and windSnd_Volume > 0.01 then
			windSndStation:Play()
		end

		windSnd_Volume = LerpFT(0.05, windSnd_Volume, windsnd and windSnd_VolumeSpeed or 0)
		windSndStation:SetVolume(windSnd_Volume)

		if windSnd_Volume < 0.01 then
			windSndStation:Pause()
			windSndStation:SetTime(0)
		end
	end)
--//

--\\ CL Utils setting adjustments
	if CLIENT then
		RunConsoleCommand("mp_decals", "4096")  -- "4194304" - if you set this value you will get crashed :3
		
		hook.Add("Think","RemoveMe_001",function()
			hook.Remove("PostPlayerDraw","BA2_GasmaskDraw")
			hook.Remove("Think","RemoveMe_001")
		end)
	end
--//

--\\ Tinnitus function
	if CLIENT then
		local lply = LocalPlayer()
		local function AddTinnitus(time, needSound)
			lply = LocalPlayer()
			lply.tinnitus = CurTime() + time * 4
			lply:SetDSP(32) -- 36
			if needSound then -- not used anyway :3
				//lply:EmitSound("earringing_end.wav")
				//zcitysnd/real_sonar/tinnitus1.mp3
			end
		end

		local plymeta = FindMetaTable("Player")
		function plymeta:AddTinnitus(time,needSound)
			needSound = needSound or false
			AddTinnitus(time,needSound)
		end

		net.Receive("send_tinnitus",function()
			local time = net.ReadFloat()
			local bool = net.ReadBool()
			AddTinnitus(time,bool)
		end)
	end
--//