--SOMEWHERE IN PLUVTOWN

local PLUGIN = hg.PluvTown

-- local Pluv = Material("pluv/pluv.png")

PLUGIN.AddHook("PostDrawAppearance", function(ent, ply)
	//for _, ply in player.Iterator() do
		-- if ply == LocalPlayer() then continue end
		if ply.NotSeen then return end
		if IsValid(ply.FakeRagdoll) then return end
		if !ply:Alive() then return end

		local head = ent:LookupBone("ValveBiped.Bip01_Head1")
		if !head then return end
		local matrix = ent:GetBoneMatrix(head)
		if !matrix then return end

		local pos = matrix:GetTranslation()

		-- if ply != LocalPlayer() then
		-- 	local tr = util.TraceLine({
		-- 		start = EyePos(),
		-- 		endpos = pos,
		-- 		filter = function(ent) return ent != ply and ent != LocalPlayer() end
		-- 	})

		-- 	if tr.Hit then return end
		-- end

		local angle = matrix:GetAngles()

		local ent = LocalPlayer():GetViewEntity()
		local Diff = math.AngleDifference(ent:GetAngles().y, angle.y) % 360 - 180

		angle:RotateAroundAxis( angle:Up(), -75)
		-- angle:RotateAroundAxis( angle:Forward(), 0)
		angle:RotateAroundAxis( angle:Right(), -90 - (Diff / 4))


		ply.PluvAngles = LerpAngle(FrameTime() * 5, ply.PluvAngles or angle, angle)
		PluvAngle = ply.PluvAngles

		pos = pos + PluvAngle:Forward() * -4 + PluvAngle:Up() * (8 - (math.abs(Diff) / 80)) + PluvAngle:Right() * -4.5

		local light1 = render.GetLightColor(pos)
		local light2 = render.ComputeLighting(pos, PluvAngle:Up() * 2)
		local light3 = render.ComputeDynamicLighting(pos, PluvAngle:Up() * 2)

		local light = (light1 + light2 + light3) * 3

		local CurrentPluv = hg.PluvTown.PluvMats[ply:GetNetVar("CurPluv", "pluv")]
		local PluvLayer = hg.PluvTown.PluvLayers[ply:GetNetVar("CurPluvLayer")]

		cam.Start3D()
			cam.Start3D2D( pos, PluvAngle, 0.05)
				surface.SetMaterial(CurrentPluv)
				surface.SetDrawColor(255 * light[1], 255 * light[2], 255 * light[3])
				surface.DrawTexturedRect(0, 0, 150, 130)

				if PluvLayer then
					surface.SetMaterial(PluvLayer)
					surface.DrawTexturedRect(0, 0, 150, 130)
				end
			cam.End3D2D()
		cam.End3D()
	//end
	/*
	for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
		if ent.NotSeen then continue end

		local head = ent:LookupBone("ValveBiped.Bip01_Head1")
		if !head then continue end
		local matrix = ent:GetBoneMatrix(head)
		if !matrix then continue end

		local ragowner = hg.RagdollOwner(ent) or ent

		local pos = matrix:GetTranslation()

		-- if ent != LocalPlayer().FakeRagdoll then
		-- 	local tr = util.TraceLine({
		-- 		start = EyePos(),
		-- 		endpos = pos,
		-- 		filter = function(ent2) return ent2 != ent and ent2 != LocalPlayer() and ent2 != LocalPlayer().FakeRagdoll end
		-- 	})

		-- 	if tr.Hit then continue end
		-- end

		local angle = matrix:GetAngles()
		angle:RotateAroundAxis( angle:Up(), -75)
		angle:RotateAroundAxis( angle:Forward(), 0)
		angle:RotateAroundAxis( angle:Right(), -90)

		ent.PluvAngles = LerpAngle(FrameTime() * 5, ent.PluvAngles or angle, angle)
		PluvAngle = ent.PluvAngles

		pos = pos + PluvAngle:Forward() * -3.5 + PluvAngle:Up() * 7 + PluvAngle:Right() * -4.5

		local light1 = render.GetLightColor(pos)
		local light2 = render.ComputeLighting(pos, PluvAngle:Up() * 2)
		local light3 = render.ComputeDynamicLighting(pos, PluvAngle:Up() * 2)

		local light = (light1 + light2 + light3) * 3

		local CurrentPluv = hg.PluvTown.PluvMats[ent:GetNetVar("CurPluv", "pluv") or ragowner:GetNetVar("CurPluv", "pluv")]
		local PluvLayer = hg.PluvTown.PluvLayers[ent:GetNetVar("CurPluvLayer") or ragowner:GetNetVar("CurPluvLayer")]

		cam.Start3D()
			cam.Start3D2D( pos, PluvAngle, 0.05 )
				surface.SetMaterial(CurrentPluv)
				surface.SetDrawColor(255 * light[1], 255 * light[2], 255 * light[3])
				surface.DrawTexturedRect(0, 0, 150, 130)

				if PluvLayer then
					surface.SetMaterial(PluvLayer)
					surface.DrawTexturedRect(0, 0, 150, 130)
				end
			cam.End3D2D()
		cam.End3D()
    end
	*/
end)