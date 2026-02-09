
local lpos, lang = Vector(5, 2, -12), Angle(-90, -90, 90)
local lpos2, lang2 = Vector(-5, 3, 6),Angle(0, 0, 0)

local drawfuncopendoor = function(ent, ply, vm, time)
	if ply.zmanipaddtbl then
		local door = ply.zmanipaddtbl[1]

		if !IsValid(door) then return end

		local lh = vm:LookupBone("ValveBiped.Bip01_L_Hand")
		local mat = vm:GetBoneMatrix(lh)
		
		local handle = door:LookupBone("handle")
		if !handle then return end
		local matdoor = door:GetBoneMatrix(handle)
		if !matdoor then return end

		local dot = door:GetAngles():Forward():Dot(ply:EyeAngles():Forward())
		local sign = dot > 0

		local pos, ang = LocalToWorld(LerpVector(1 - (dot + 1) * 0.5, lpos, lpos2), sign and lang or lang2, matdoor:GetTranslation(), matdoor:GetAngles())
		
		local distmul = 1 - math.min(1, pos:DistToSqr(mat:GetTranslation()) / (40 * 40))

		mat:SetTranslation(LerpVector(math.Clamp((1 - time) * distmul, 0, 1), mat:GetTranslation(), pos))
		--mat:SetAngles(ang)

		hg.bone_apply_matrix(vm, lh, mat)
	end
end

local lpos3, lang3 = Vector(0, 0, 0),Angle(0, 0, 0)

local drawfuncinteract = function(ent, ply, vm, time)
	do return end
	if ply.zmanipaddtbl then
		local ent = ply.zmanipaddtbl[1]

		if !IsValid(ent) then return end

		local lh = vm:LookupBone("ValveBiped.Bip01_L_Hand")
		local mat = vm:GetBoneMatrix(lh)
		
		--local handle = door:LookupBone("handle")
		--local matdoor = door:GetBoneMatrix(handle)
		local mat2 = ent:GetBoneMatrix(0)

		local pos, ang = LocalToWorld(lpos3, lang3, mat2:GetTranslation(), mat2:GetAngles())
		
		local distmul = 1 - math.min(1, pos:DistToSqr(mat:GetTranslation()) / (40 * 40))

		mat:SetTranslation(LerpVector(math.Clamp((1 - time) * distmul, 0, 1), mat:GetTranslation(), pos))
		--mat:SetAngles(ang)

		hg.bone_apply_matrix(vm, lh, mat)
	end
end

local tbl = {
	["models/zmanip/c_zmanipinteract.mdl"] = {
		["interact"] = {
			seq = "interact",
			playTime = 1,
			otherData = { 
				angClamps = { {-75}, {65} }
			},
			drawFunc = drawfuncinteract,
		},
		["use"] = {seq = "use"},
	},
	["models/zmanip/c_zmanipgestures.mdl"] = {
		["flipoff"] = {seq = "flipoff", playTime = 1.2, otherData = {posAdjust = Vector(-4,4,0)}},
		["okayhand"] = {seq = "okayhand", playTime = 2},
		["thumbsup"] = {seq = "thumbsup"},
		["swimforward"] = {seq = "swimforward", playTime = 1},
		["swimleft"] = {seq = "swimleft", playTime = 1},
	},
	["models/zmanip/c_zmaniphandanims.mdl"] = {
		["explosion"] = {seq = "shieldexplosion"},
	},
	["models/zmanip/c_zmanipusedoor.mdl"] = {
		["usedoor"] = {seq = "usedoor"}
	},
	["models/zmanip/c_zmaniphandanims.mdl"] = {
		["visordown"] = {seq = "visordown", playTime = 1.4,
			otherData = {
				posAdjust = Vector(7,1,1),
				angClamps = { {-75}, {35} },
			} },
	},
	["models/weapons/zcity/c_hands_gestures.mdl"] = {
		["door_open_forward"] = {seq = "door_open_forward", playTime = 1.2 ,
			otherData = {
				posAdjust = Vector(7,0,3),
				angClamps = { {12}, {12} },
			},
			drawFunc = drawfuncopendoor,
		},
		["door_open_back"] = {seq = "door_open_back", playTime = 1.2,
			otherData = {
				posAdjust = Vector(7,0,3),
				angClamps = { {12}, {12} },
			},
			drawFunc = drawfuncopendoor,
		},
		["fuckyou"] = {seq = "fuckyou", playTime = 2.2,
			otherData = {
				posAdjust = Vector(6,2,1),
				angClamps = { {-55}, {55} },
			}},
		["point"] = {seq = "point", playTime = 3,
			otherData = {
				angClamps = { {-55}, {55} },
			}},
		["thump_up"] = {seq = "thump_up", playTime = 2.2,
			otherData = {
				posAdjust = Vector(5,2,1),
				angClamps = { {-55}, {55} },
			}},
	}
}

hg.ZManipAnims = {}
for mdl, tbl2 in pairs(tbl) do
	for anim, tSettings in pairs(tbl2) do
		hg.ZManipAnims[anim] = {
			mdl = mdl,
			seq = tSettings.seq,
			playTime = tSettings.playTime or 1,
			timeAdjust = tSettings.timeAdjust or 1,
			otherData = tSettings.otherData,
			drawFunc = tSettings.drawFunc,
		}
	end
end

function hg.RunZManipAnim(ply, anim, revers, timeOveride, addtbl)
	local ent = hg.GetCurrentCharacter(ply)
	local zmdl = ply.zmodel

	if !IsValid(zmdl) then return end
	--if ply.zmanipstart ~= nil then return end
	local tbl = hg.ZManipAnims[anim] or anim
	if not tbl.mdl then return end

	zmdl:SetModel(tbl.mdl)
	ply.zmanipstart = CurTime()
	ply.zmaniptime = timeOveride or tbl.playTime or 1
	ply.zmanipseq = tbl.seq
	ply.zmanipanim = anim
	ply.zmanip_revers = revers
	ply.zmanipother = {}
	ply.zmanipother = tbl.otherData
	ply.zmanipdrawFunc = tbl.drawFunc
	ply.zmanipaddtbl = addtbl
	if (ply.NextFoley or 0) < CurTime() then
		ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
		ply.NextFoley = CurTime() + (ply.zmaniptime or 1)
	end

	zmdl:SetSequence(tbl.seq)
end

net.Receive("RunZManipAnim", function()
	local ply = net.ReadPlayer()
	local anim = net.ReadString()
	local revers = net.ReadBool()
	local timeOveride = net.ReadFloat()
	local addtbl = net.ReadTable()
	
	hg.RunZManipAnim(ply, anim, revers, timeOveride != 0 and timeOveride or nil, addtbl)
end)

local mdl = Model("models/zmanip/c_zmanipinteract.mdl") -- interact use
function hg.DoZManip(ent, ply)
	if not IsValid(ply.zmodel) then
		ply.zmodel = ClientsideModel(mdl)
		ply.zmodel:SetNoDraw(true)
	end

	if not ply.zmanipstart or IsValid(ply:GetNetVar("carryent2")) or (ply.organism and ply.organism.larmamputated) then return end
	
	local time = (math.Clamp((CurTime() - ply.zmanipstart) / ply.zmaniptime, 0, 1))
	
	if time >= 1 then
		ply.zmanipstart = nil
		return
	end

	local WorldModel = ply.zmodel

	local wep = ply:GetActiveWeapon()

	if wep.ShouldDoZManip and !wep:ShouldDoZManip() then return end
	if !IsValid(wep) then return end

	local tr = hg.eyeTrace(ply, 60)
	if not tr then return end

	local ang = ply:EyeAngles()

	local ml = time * 1
	--print(ml)
	local pos = tr.StartPos + ang:Forward() * (1 - 6 - ml / 1.5) + ang:Right() * (-1 + ml / 2)

	-- position adjust

	if ply.zmanipother and ply.zmanipother.posAdjust then
		pos = pos
		+ ang:Forward() * ply.zmanipother.posAdjust[1]
		+ ang:Right() * ply.zmanipother.posAdjust[2]
		+ ang:Up() * ply.zmanipother.posAdjust[3]
	end


	local ang = ply:EyeAngles()
	local _,ang = LocalToWorld(vector_origin,(angle_zero),vector_origin,ang)

	-- angles clamp

	if ply.zmanipother and ply.zmanipother.angClamps then
		if ply.zmanipother.angClamps[1][1] and ply.zmanipother.angClamps[2][1] then
			ang[1] = math.max( math.min( ang[1], ply.zmanipother.angClamps[2][1] ), ply.zmanipother.angClamps[1][1] )
		end
		if ply.zmanipother.angClamps[1][2] and ply.zmanipother.angClamps[2][2] then
			ang[2] = math.max( math.min( ang[2], ply.zmanipother.angClamps[2][2] ), ply.zmanipother.angClamps[1][2] )
		end
		if ply.zmanipother.angClamps[1][3] and ply.zmanipother.angClamps[2][3] then
			ang[3] = math.max( math.min( ang[3], ply.zmanipother.angClamps[2][3] ), ply.zmanipother.angClamps[1][3] )
		end
	end

	WorldModel:SetRenderOrigin(pos)
	WorldModel:SetRenderAngles(ang)
	WorldModel:SetPos(pos)
	WorldModel:SetAngles(ang)

	WorldModel:SetupBones()
	wep.lhandik = true

	WorldModel:SetCycle(ply.zmanip_revers and 1 - time or time)

	local camBone = WorldModel:LookupBone("ValveBiped.Bip01_L_Hand")

    if camBone and hg.IsLocal(ply) then
        local matrix = WorldModel:GetBoneMatrix(camBone)

        if matrix then
            local gAngles = matrix:GetAngles()
            local _,gAngles = WorldToLocal(vector_origin, gAngles, pos, ang)
            WorldModel.OldAngPunch = WorldModel.OldAngPunch or gAngles
            local punch = ( WorldModel.OldAngPunch - gAngles ) / 250

            //ViewPunch2( -punch )
            ViewPunch( punch )

            WorldModel.OldAngPunch = gAngles
        end
    end

	local lh = ent:LookupBone("ValveBiped.Bip01_L_Hand")
	local lhmat = ent:GetBoneMatrix(lh)
	local wmlh = WorldModel:LookupBone("ValveBiped.Bip01_L_Hand")
	local wmlhmat = WorldModel:GetBoneMatrix(wmlh)

	local lpos, lang = WorldToLocal(lhmat:GetTranslation(), lhmat:GetAngles(), wmlhmat:GetTranslation(), angle_zero)

	if ply.zmanipdrawFunc then
		ply.zmanipdrawFunc(ent, ply, WorldModel, time)
	end

	local bones = hg.TPIKBonesLH
	for _, bone in ipairs(bones) do
		local wm_boneindex = WorldModel:LookupBone(bone)
		if !wm_boneindex then continue end
		local wm_bonematrix = WorldModel:GetBoneMatrix(wm_boneindex)
		if !wm_bonematrix then continue end

		local ply_boneindex = ent:LookupBone(bone)
		if !ply_boneindex then continue end
		local ply_bonematrix = ent:GetBoneMatrix(ply_boneindex)
		if !ply_bonematrix then continue end

		local bonepos = wm_bonematrix:GetTranslation()
		local boneang = wm_bonematrix:GetAngles()

		bonepos.x = math.Clamp(bonepos.x, pos.x - 38, pos.x + 38) -- clamping if something gone wrong so no stretching (or animator is fleshy)
		bonepos.y = math.Clamp(bonepos.y, pos.y - 38, pos.y + 38)
		bonepos.z = math.Clamp(bonepos.z, pos.z - 38, pos.z + 38)

		local lerp = (time < 0.25 and (0.25 - time) * 4 or math.max(0, time - 0.75) * 4)
		lerp = math.ease.InOutSine(lerp)

		local m1 = Matrix()
		m1:SetAngles(boneang)
		local m2 = Matrix()
		m2:SetAngles(ply_bonematrix:GetAngles())

		local q1 = Quaternion()
		q1:SetMatrix(m1)

		local q2 = Quaternion()
		q2:SetMatrix(m2)

		local q3 = q1:SLerp(q2, lerp)

		ply_bonematrix:SetTranslation(LerpVector(lerp, bonepos, ply_bonematrix:GetTranslation()))
		ply_bonematrix:SetAngles(q3:Angle())

		--ply_bonematrix:SetTranslation(bonepos + lpos * lerp)
		--ply_bonematrix:SetAngles(q1:Angle())

		--hg.bone_apply_matrix(ent, ply_boneindex, ply_bonematrix)
		ent:SetBoneMatrix(ply_boneindex, ply_bonematrix)
		--ply:SetBonePosition(ply_boneindex, bonepos, boneang)
	end
end