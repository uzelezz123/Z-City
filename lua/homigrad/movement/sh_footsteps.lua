local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
local hook_Run = hook.Run
local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like camera view", 0, 1)

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

			ViewPunch(Angle((hg_gopro:GetBool() and 5 or 1) * len / 200 * math_max((350 - ply.move) / 50, 1) * mul2, footcl * mul * mul2, footcl * mul * mul2))
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