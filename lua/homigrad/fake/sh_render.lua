local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
local IsValid, math_Clamp = IsValid, math.Clamp

--\\ Smooth UnRagdoll
	local vecSmall = Vector(0.01, 0.01, 0.01)
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
					newmat:SetScale(vecSmall)
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
	local hg_thirdperson = ConVarExists("hg_thirdperson") and GetConVar("hg_thirdperson") or CreateConVar("hg_thirdperson", 0, FCVAR_REPLICATED, "Toggle third-person camera view", 0, 1)
	local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like camera view", 0, 1)
	local hg_deathfadeout = CreateClientConVar("hg_deathfadeout", "1", true, true, "Toggle screen fade and sound mute on death", 0, 1)

	local vector_full = Vector(1, 1, 1)
	local vector_small = Vector(0.01, 0.01, 0.01)
	local angfuck = Angle()
	function DrawPlayerRagdoll(ent, ply) --// actually not only ragdoll render but player too
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
			
			if (!hg_thirdperson:GetBool() and !hg_gopro:GetBool() and (ent == ply or (!hg_ragdollcombat:GetBool() or hg_firstperson_ragdoll:GetBool()))) or (hg_firstperson_death:GetBool() and follow == ent) then
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