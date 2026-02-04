hg.bone = hg.bone or {} -- посттравматический синдром личности

local tbl = {
	["head"] = "ValveBiped.Bip01_Head1",
	["spine"] = "ValveBiped.Bip01_Spine",
	["spine1"] = "ValveBiped.Bip01_Spine1",
	["spine2"] = "ValveBiped.Bip01_Spine2",
	["pelvis"] = "ValveBiped.Bip01_Pelvis",
	["r_upperarm"] = "ValveBiped.Bip01_R_UpperArm",
	["r_forearm"] = "ValveBiped.Bip01_R_Forearm",
	["l_upperarm"] = "ValveBiped.Bip01_L_UpperArm",
	["l_forearm"] = "ValveBiped.Bip01_L_Forearm",
}

hg.bone.client_only = {
	["r_finger0"] = "ValveBiped.Bip01_R_Finger0",
	["r_finger1"] = "ValveBiped.Bip01_R_Finger1",
	["r_finger11"] = "ValveBiped.Bip01_R_Finger11",
	["r_finger12"] = "ValveBiped.Bip01_R_Finger12",
	["l_finger0"] = "ValveBiped.Bip01_L_Finger0",
	["l_finger01"] = "ValveBiped.Bip01_L_Finger01",
	["l_finger02"] = "ValveBiped.Bip01_L_Finger02",
	["l_finger1"] = "ValveBiped.Bip01_L_Finger1",
	["l_finger11"] = "ValveBiped.Bip01_L_Finger11",
	["l_finger2"] = "ValveBiped.Bip01_L_Finger2",
	["l_finger21"] = "ValveBiped.Bip01_L_Finger21",
	["l_finger3"] = "ValveBiped.Bip01_L_Finger3",
	["l_finger31"] = "ValveBiped.Bip01_L_Finger31",
	["l_finger4"] = "ValveBiped.Bip01_L_Finger4",
	["l_finger41"] = "ValveBiped.Bip01_L_Finger41",
}

local PLAYER = FindMetaTable("Player")

function PLAYER:MBPosition(bone, pos)
	--if self:GetManipulateBonePosition(bone):IsEqualTol(pos, 0.01) then return end

	timer.Simple(0, function()
		self:ManipulateBonePosition(bone, pos)
	end)
end

function PLAYER:MBAngles(bone, ang)
	--if self:GetManipulateBoneAngles(bone):IsEqualTol(ang, 0.01) then return end

	timer.Simple(0, function()
		self:ManipulateBoneAngles(bone, ang)
	end)
end

hg.bone.matrixManual_Name = tbl

local matrix, matrixSet

local vecZero, angZero, vecFull = Vector(0, 0, 0), Angle(0, 0, 0), Vector(1, 1, 1)
local layer, name, boneName, boneID

local function reset(ply)
	ply.manipulated = ply.manipulated or {}
	ply.unmanipulated = {}
	ply.manipulate = {}
	ply.matrixes = {}
	
	for bone = 0, ply:GetBoneCount() do
		ply:ManipulateBonePosition(bone, vecZero, true)
		ply:ManipulateBoneAngles(bone, angZero, true)
		ply:ManipulateBoneScale(bone, vecFull, true)
	end
	
	ply.manipulated = {}
end

local function createLayer(ply, layer, lookup_name)
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName)
	
	if not boneID then return end

	ply.manipulated = ply.manipulated or {}
	ply.manipulated[boneID] = ply.manipulated[boneID] or {}
	ply.manipulated[boneID].Pos = ply.manipulated[boneID].Pos or Vector(0, 0, 0)
	ply.manipulated[boneID].Ang = ply.manipulated[boneID].Ang or Angle(0, 0, 0)
	ply.manipulated[boneID].layers = ply.manipulated[boneID].layers or {}
	ply.manipulated[boneID].layers[layer] = ply.manipulated[boneID].layers[layer] or {Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0)}
end

hook.Add("Player Getup", "homigrad-bones", function(ply) reset(ply) end)

local CurTime, LerpVector, LerpAngle = CurTime, LerpVector, LerpAngle
local m, mSet, mAngle, mPos
local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local tickInterval = engine.TickInterval
local FrameTime = FrameTime
local math_min = math.min
local mul = 1
local timeHuy = CurTime()
local hook_Run = hook.Run
local angle = FindMetaTable("Angle")

function math.EqualWithTolerance(val1, val2, tol)
    return math.abs(val1 - val2) <= tol
end

function angle:IsEqualTol(ang, tol)
    if (tol == nil) then
        return self == ang
    end

    return math.EqualWithTolerance(self[1], ang[1], tol)
        and math.EqualWithTolerance(self[2], ang[2], tol)
        and math.EqualWithTolerance(self[3], ang[3], tol)
end

function angle:AngIsEqualTo(otherAng, huy)
	if not angle.IsEqualTol then return false end
	return self:IsEqualTol(otherAng, huy)
end

local hg_anims_draw_distance = ConVarExists("hg_anims_draw_distance") and GetConVar("hg_anims_draw_distance") or CreateClientConVar("hg_anims_draw_distance", 1024, true, nil, "distance to draw anims (0 = infinite)", 0, 4096)
local hg_anim_fps = ConVarExists("hg_anim_fps") and GetConVar("hg_anim_fps") or CreateClientConVar("hg_anim_fps", 66, true, nil, "fps to draw anims (0 = maximum fps available)", 0, 250)

local function recursive_bones(ply, bone)
	local children = ply:GetChildBones(bone)

	local parent = ply:GetBoneParent(bone)
	parent = parent ~= -1 and parent or 0

	local matp = ply.unmanipulated[parent] or ply:GetBoneMatrix(parent)

	if ply.matrixes[bone] then
		local new_matrix = ply.matrixes[bone]
		--print(new_matrix:GetAngles())
		local old_matrix = ply.unmanipulated[bone]
		
		local lmat = old_matrix:GetInverse() * new_matrix
		local ang = lmat:GetAngles()
		local vec, _ = WorldToLocal(new_matrix:GetTranslation(), angle_zero, old_matrix:GetTranslation(), matp:GetAngles())
		--print(old_matrix:GetTranslation())
		--ply.manipulate[bone] = {vec, ang}

		--ply:ManipulateBonePosition(bone, vec)
		--ply:ManipulateBoneAngles(bone, lmat:GetAngles())

		--ply:MBPosition(bone, vec)
		--ply:MBAngles(bone, lmat:GetAngles())

		--ply:MBPosition(bone, lpos)
		--ply:MBAngles(bone, ang)
	end

	for i = 1, #children do
		local bonec = children[i]

		recursive_bones(ply, bonec)
	end
end

local dtime
function hg.HomigradBones(ply, dtime)
	--if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() or IsValid(ply.FakeRagdoll) then return end
	if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() then return end

	local dist = CLIENT and LocalPlayer():GetPos():Distance(ply:GetPos()) or 0
	local drawdistance = CLIENT and hg_anims_draw_distance:GetInt() or 0
	local time = CurTime()
	
	if CLIENT and (!ply.shouldTransmit or ply.NotSeen) then return end

	local dtime2 = SysTime() - (ply.timeFrameasd or (SysTime() - 1))
	local fps = CLIENT and (hg_anim_fps:GetInt() != 0 and hg_anim_fps:GetInt() or 99999) or 15
	
	if CLIENT and (dtime2 < 1 / fps) then return end
	if SERVER and dtime2 < 0.2 then return end
	
	//dtime = dtime2
	ply.timeFrameasd = SysTime()

	hook_Run("Bones", ply, dtime2)
	
	--[[for bonename, tbl in pairs(ply.manipulated) do
		boneName = hg.bone.matrixManual_Name[bonename]
		boneID = ply:LookupBone(boneName)
		ply:ManipulateBonePosition(boneID, tbl.Pos, false)
		ply:ManipulateBoneAngles(boneID, tbl.Ang, false)
	end--]]

	if IsValid(ply.FakeRagdoll) then return end

	if not ply.manipulated then reset(ply) return end
	
	for bone, tbl in pairs(ply.manipulated) do
		for layer, tbl in pairs(tbl.layers) do
			if (tbl.lastset != time) then
				if tbl.Pos:IsEqualTol(vector_origin, 0.01) and tbl.Ang:IsEqualTol(angle_zero, 0.01) then
					ply.manipulated[bone] = nil

					continue
				end

				hg.bone.Set(ply, bone, vector_origin, angle_zero, layer, 0.01, dtime2, true)
			end
		end
	end

	do return end

	if SERVER then return end

	--[[
	local vec = Vector(0,0,0)
	local ang = Angle(0,50,0)

	ply:MBPosition(1, vec)
	ply:MBAngles(1, ang)

	local vec = ply:GetManipulateBonePosition(1)
	local ang = ply:GetManipulateBoneAngles(1)

	local mat = ply:GetBoneMatrix(1)
	local matp = ply:GetBoneMatrix(0)

	local ang1 = matp:GetAngles()

	local vec2 = ang1:Forward() * vec[1] + ang1:Right() * -vec[2] + ang1:Up() * vec[3]
	local ang2 = mat:GetAngles()
	--ОБЯЗАТЕЛЬНО В ПОРЯДКЕ 3 1 2!!! (roll pitch yaw)
	ang2:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang2:RotateAroundAxis(ang2:Right(), ang[1])
	ang2:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang2)

	print(mat:GetTranslation(), mat:GetAngles(), 1)
	
	local ang2 = mat:GetAngles()
	local mat = ply:GetBoneMatrix(10)

	local ang1 = mat:GetAngles()

	ang1:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang1:RotateAroundAxis(ang2:Right(), ang[1])
	ang1:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang1)

	print(mat:GetTranslation(), mat:GetAngles(), 2, "\n")
	--проблема в том что оно не учитывает то что позиция кости меняется при ее повороте...
	--]]

	--better version, здесь учитывает
	--[[
	local vec = Vector(0,0,0)
	local ang = Angle(0,0,0)

	ply:MBPosition(1, vec)
	ply:MBAngles(1, ang)

	local vec = ply:GetManipulateBonePosition(1)
	local ang = ply:GetManipulateBoneAngles(1)

	local mat = ply:GetBoneMatrix(1)
	local matp = ply:GetBoneMatrix(0)

	local ang1 = matp:GetAngles()

	local vec2 = ang1:Forward() * vec[1] + ang1:Right() * -vec[2] + ang1:Up() * vec[3]
	local ang2 = mat:GetAngles()
	--ОБЯЗАТЕЛЬНО В ПОРЯДКЕ 3 1 2!!! (roll pitch yaw)
	ang2:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang2:RotateAroundAxis(ang2:Right(), ang[1])
	ang2:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang2)

	print(mat:GetTranslation(), mat:GetAngles(), 1)
	
	local mat2 = ply:GetBoneMatrix(10)

	local mats = mat * (ply:GetBoneMatrix(1):GetInverse() * mat2)

	print(mats:GetTranslation(), mats:GetAngles(), 2, "\n")
	--]]

	if not ply.matrixes then return end
	--ply:MBAngles(ply:LookupBone("ValveBiped.Bip01_Spine2"), Angle(0,0,0))

	--[[
	--о да.

	--ply:MBAngles(ply:LookupBone("ValveBiped.Bip01_R_UpperArm"), Angle(50,50,50))
	--ply:MBAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(50,50,50))

	--print(ply.unmanipulated[ply:LookupBone("ValveBiped.Bip01_R_Hand")]:GetTranslation())
	--reset(ply)

	
	local arm = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
	local uparm = ply:LookupBone("ValveBiped.Bip01_R_UpperArm")
	local mat = ply:GetBoneMatrix(arm)
	local unmanip = ply.unmanipulated[arm]

	mat:SetTranslation(unmanip:GetTranslation() + vector_up * 10)
	mat:SetAngles(ply:EyeAngles())

	local lmat = unmanip:GetInverse() * mat
	--print(lmat:GetAngles(),lmat:GetTranslation())

	local vec = mat:GetTranslation() - unmanip:GetTranslation()
	local matp = ply.unmanipulated[uparm]
	local vec, _ = WorldToLocal(mat:GetTranslation(), angle_zero, unmanip:GetTranslation(), matp:GetAngles())

	--vec:Rotate(ang)

	--ply:ManipulateBonePosition(arm, vec)
	--ply:ManipulateBoneAngles(arm, lmat:GetAngles())
	--]]
	
	--recursive_bones(ply, 0)

	--[[for i = 0, ply:GetBoneCount() - 1 do
		if not ply.manipulate[i] then continue end
		hg.bone.Set(ply, i, ply.manipulate[i][1], ply.manipulate[i][2], "huy", 1, dtime, true)
	end--]]
end

function hg.get_unmanipulated_bones(ply, bone, matmodify)--set bone to 0 for the 1-st recurse
	ply.unmanipulated = ply.unmanipulated or {}
	matmodify = matmodify or Matrix()

	local vec = ply:GetManipulateBonePosition(bone)
	local ang = ply:GetManipulateBoneAngles(bone)

	local parent = ply:GetBoneParent(bone)
	parent = parent != -1 and parent or 0
	local mat = ply:GetBoneMatrix(bone)
	local matp = ply:GetBoneMatrix(parent)

	local ang1 = matp:GetAngles()

	local vec2 = ang1:Forward() * vec[1] + ang1:Right() * -vec[2] + ang1:Up() * vec[3]
	local ang2 = mat:GetAngles()
	--ОБЯЗАТЕЛЬНО В ПОРЯДКЕ 3 1 2!!! (roll pitch yaw)
	ang2:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang2:RotateAroundAxis(ang2:Right(), ang[1])
	ang2:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang2)

	if matmodify then
		mat = matmodify * mat
	end

	ply.unmanipulated[bone] = mat

	local children = ply:GetChildBones(bone)

	local modify = mat * ply:GetBoneMatrix(bone):GetInverse()
	
	for i = 1, #children do
		local bonec = children[i]

		hg.get_unmanipulated_bones(ply, bonec, modify)
	end
end

hook.Add("Player Think", "homigrad-bones", function(ply, time, dtime)
	hg.HomigradBones(ply, dtime)
end)

function hg.bone.Set(ply, lookup_name, vec, ang, layer, lerp, dtime2)
	local dtime = dtime2 or dtime
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName ~= nil and boneName or lookup_name)

	if not boneID then return end
	
	layer = layer or "unspecified"

	if layer and layer != "all" then
		createLayer(ply, layer, boneID)
		
		if lerp then
			vec = LerpVector(hg.lerpFrameTime(lerp, dtime), ply.manipulated[boneID].layers[layer].Pos, vec)
			ang = LerpAngle(hg.lerpFrameTime(lerp, dtime), ply.manipulated[boneID].layers[layer].Ang, ang)
		end
		
		local oldpos, oldang = hg.bone.Get(ply, boneID)
		--print(oldang)
		local setPos = oldpos - ply.manipulated[boneID].layers[layer].Pos + vec
		local setAng = oldang - ply.manipulated[boneID].layers[layer].Ang + ang

		hg.bone.SetRaw(ply, boneID, setPos, setAng)

		--print(layer, lookup_name, oldang, ply.layers[layer][lookup_name].Ang, ang, setAng)

		ply.manipulated[boneID].layers[layer].Pos = -(-vec)
		ply.manipulated[boneID].layers[layer].Ang = -(-ang)
		ply.manipulated[boneID].layers[layer].lastset = CurTime()
	end
end
--PrintTable(Player(3).manipulated)
function hg.bone.SetRaw(ply, boneID, vec, ang)
	ply.manipulated = ply.manipulated or {}
	ply.manipulated[boneID] = ply.manipulated[boneID] or {}

	ply.manipulated[boneID].Pos = vec
	ply.manipulated[boneID].Ang = ang
	
	ply:ManipulateBonePosition(boneID, vec, false)
	ply:ManipulateBoneAngles(boneID, ang, false)
end

function hg.bone.Get(ply, lookup_name)
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName)

	if not boneID or not ply.manipulated[boneID] then return end

	return ply.manipulated[boneID].Pos, ply.manipulated[boneID].Ang
end