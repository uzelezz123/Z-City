local MODE = MODE
local mode_type = mode_type --; Watafucko ahhh

MODE.FootStepsDrawDistanceSqr = 290
MODE.FootStepsArrangementDistanceSqr = MODE.FootStepsDrawDistanceSqr + 100
MODE.FootStepsDrawDistanceCrouchedSqr = 800
MODE.FootStepsArrangementDistanceCrouchedSqr = MODE.FootStepsDrawDistanceCrouchedSqr + 100
MODE.FootStepsCurDrawDistanceSqr = MODE.FootStepsDrawDistanceSqr
MODE.FootStepsCurArrangementDistanceSqr = MODE.FootStepsArrangementDistanceSqr

MODE.FootStepsDrawDistanceSqr = MODE.FootStepsDrawDistanceSqr ^ 2
MODE.FootStepsArrangementDistanceSqr = MODE.FootStepsArrangementDistanceSqr ^ 2
MODE.FootStepsDrawDistanceCrouchedSqr = MODE.FootStepsDrawDistanceCrouchedSqr ^ 2
MODE.FootStepsArrangementDistanceCrouchedSqr = MODE.FootStepsArrangementDistanceCrouchedSqr ^ 2

MODE.FootSteps = MODE.FootSteps or {}
MODE.FootStepsAmt = MODE.FootStepsAmt or 0 --; Auto calculated
MODE.ArrangedFootSteps = MODE.ArrangedFootSteps or {}
MODE.FootStepsArrangementTimeCD = 1
MODE.NextFootStepsArrangementTime = 0
MODE.FootStepsLifeTimeMin = 10
MODE.FootStepsLifeTimeMax = 5000
MODE.FootStepsCriticalAmt = 500

local footMat = Material("thieves/footprint")
local footMat2 = Material("dog_swep/footprint2")

function MODE.IsRoundTypeSuitableForProfessions()
	mode_type = MODE.Type or mode_type

	return zb.CROUND == "hmcd"-- and MODE.ProfessionsRoundTypes[mode_type]
end

--\\Use these and only these functions to address MODE.FootSteps, otherwise it will break
function MODE.AddFootstep(pos, ang_y, foot, color)
	local footstep_info = {}
	
	local trace_data = {}
		trace_data.start = pos
		trace_data.endpos = trace_data.start + Vector(0, 0, -10)
		trace_data.filter = {"player"}
	local trace = util.TraceLine(trace_data)
	
	footstep_info.Normal = trace.HitNormal
	footstep_info.Pos = trace.HitPos + footstep_info.Normal
	footstep_info.Ang = ang_y
	footstep_info.Color = color
	footstep_info.CreationTime = CurTime()
	MODE.FootSteps[#MODE.FootSteps + 1] = footstep_info
	MODE.FootStepsAmt = MODE.FootStepsAmt + 1
end

function MODE.RemoveFootstep(footstep_key)
	if(MODE.FootSteps[footstep_key])then
		MODE.FootSteps[footstep_key] = nil
		MODE.FootStepsAmt = MODE.FootStepsAmt - 1
	end
end
--//

hook.Add("PostDrawTranslucentRenderables", "HMCD_Professions_Abilities", function()
	local view = render.GetViewSetup(true)
	local ply_pos = view.origin
	local ply_angs = view.angles

	if(MODE.NextFootStepsArrangementTime <= CurTime())then
		MODE.NextFootStepsArrangementTime = math.huge
		
		MODE.CoroutineFootStepsArrangement = coroutine.create(function()
			local frame_time = FrameTime()
			local new_arranged_footsteps = {}
			
			if(LocalPlayer():Crouching())then
				MODE.FootStepsCurArrangementDistanceSqr = Lerp(frame_time * 3, MODE.FootStepsCurArrangementDistanceSqr, MODE.FootStepsArrangementDistanceCrouchedSqr)
			else
				MODE.FootStepsCurArrangementDistanceSqr = Lerp(frame_time * 3, MODE.FootStepsCurArrangementDistanceSqr, MODE.FootStepsArrangementDistanceSqr)
			end

			local iteration = 0
			
			for footstep_key, footstep_info in pairs(MODE.FootSteps) do
				iteration = iteration + 1
				local cur_life_time = MODE.FootStepsLifeTimeMin + (1 - math.min(MODE.FootStepsAmt / MODE.FootStepsCriticalAmt, 1)) * (MODE.FootStepsLifeTimeMax - MODE.FootStepsLifeTimeMin)
				
				if(footstep_info.CreationTime + cur_life_time <= CurTime())then
					MODE.RemoveFootstep(footstep_key)
				else
					if(footstep_info.Pos:DistToSqr(ply_pos) <= MODE.FootStepsCurArrangementDistanceSqr)then
						new_arranged_footsteps[#new_arranged_footsteps + 1] = footstep_info
					end
				end
				
				if(iteration > 100)then
					iteration = 0
					
					coroutine.yield()
				end
			end
			
			MODE.ArrangedFootSteps = new_arranged_footsteps
			MODE.CoroutineFootStepsArrangement = nil
			MODE.NextFootStepsArrangementTime = CurTime() + MODE.FootStepsArrangementTimeCD
		end)
		
		coroutine.resume(MODE.CoroutineFootStepsArrangement)
	end

	if(MODE.IsRoundTypeSuitableForProfessions() and LocalPlayer().Profession == "huntsman")then
		local frame_time = FrameTime()
		
		if(LocalPlayer():Crouching())then
			MODE.FootStepsCurDrawDistanceSqr = Lerp(frame_time * 3, MODE.FootStepsCurDrawDistanceSqr, MODE.FootStepsDrawDistanceCrouchedSqr)
		else
			MODE.FootStepsCurDrawDistanceSqr = Lerp(frame_time * 3, MODE.FootStepsCurDrawDistanceSqr, MODE.FootStepsDrawDistanceSqr)
		end
		
		cam.Start3D(ply_pos, ply_angs)
			for footstep_key, footstep_info in ipairs(MODE.ArrangedFootSteps) do
				local length = 20
				
				render.SetMaterial(footMat)
				
				local dist_sqr = footstep_info.Pos:DistToSqr(ply_pos)
				footstep_info.Color.a = math.max((1 - (dist_sqr / MODE.FootStepsCurDrawDistanceSqr)), 0) * 255
				
				render.DrawQuadEasy(footstep_info.Pos, footstep_info.Normal, 10, length, footstep_info.Color, footstep_info.Ang)
			end
		cam.End3D()
	end
end)

hook.Add("Think", "HMCD_Professions_Abilities", function()
	if(MODE.CoroutineFootStepsArrangement)then
		if(!coroutine.resume(MODE.CoroutineFootStepsArrangement))then
			MODE.CoroutineFootStepsArrangement = nil
			MODE.NextFootStepsArrangementTime = CurTime() + MODE.FootStepsArrangementTimeCD
		end
	end
end)

hook.Add("PostCleanupMap", "HMCD_Professions_Abilities", function()
	MODE.FootSteps = {}
	MODE.ArrangedFootSteps = {}
	MODE.FootStepsAmt = 0
end)

net.Receive("HMCD_Professions_Abilities_AddFootstep", function()
	MODE.AddFootstep(net.ReadVector(), net.ReadFloat(), net.ReadBool(), net.ReadColor(false))
end)

local function createPipeBomb()
	RunConsoleCommand("hg_create_pipebomb")
end

local function createMolotov()
	RunConsoleCommand("hg_create_molotov")
end

hook.Add("radialOptions", "EngineerCraft", function()
    local ply = LocalPlayer()
    local organism = ply.organism or {}

    if ply:Alive() and not organism.otrub and ply.Profession == "engineer" then
		-- pipe bomb
		local have_ammo
		local have_nails

		for id, amt in pairs(ply:GetAmmo()) do
			local name = game.GetAmmoName(id)

			if name == "Nails" and amt >= 3 then
				have_nails = true
				continue
			end

			local tbl = hg.ammotypeshuy[name]
			if tbl.BulletSettings and tbl.BulletSettings.Mass * amt > 50 then
				have_ammo = true
			end
		end

		local have_pipe = ply:HasWeapon("weapon_leadpipe")
		if have_ammo and have_pipe and have_nails then
			local tbl = {createPipeBomb, "Create pipe bomb"}
        	hg.radialOptions[#hg.radialOptions + 1] = tbl
		end

		-- molotov
		local have_barrel_nearby
		local have_bandage = ply:HasWeapon("weapon_bandage_sh") or ply:HasWeapon("weapon_bigbandage_sh")
		local have_bottle = ply:HasWeapon("weapon_hg_bottle")
		
		for i, ent in ipairs(ents.FindInSphere(ply:GetPos(), 64)) do
			if hg.gas_models[ent:GetModel()] and !ent:GetNWBool("EmptyBarrel", false) then
				have_barrel_nearby = true
				break
			end
		end

		if have_barrel_nearby and have_bandage and have_bottle then
			local tbl = {createMolotov, "Create molotov"}
        	hg.radialOptions[#hg.radialOptions + 1] = tbl
		end
    end
end)