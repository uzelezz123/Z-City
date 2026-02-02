hg.organism = hg.organism or {}
local empty = {}
local Vector = Vector --ыыы
local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local box, _mins = Vector(0, 0, 0), Vector(0, 0, 0)
local center
local function getTransform(pos, ang, mins, maxs, obbCenter)
	box:Set(mins)
	box:Sub(maxs)
	box:Div(2) --holyshit...
	box:Rotate(ang)
	_mins:Set(mins)
	_mins:Rotate(ang)
	_mins:Sub(box)
	center = pos + _mins
	return center, (obbCenter - center):Length() + box:Length() / 2
end

local LocalToWorld = LocalToWorld
function hg.organism.ShootMatrix(ent, organs)
	if not organs or not istable(organs) or table.IsEmpty(organs) then return end
	local boxs = {}
	local mins, maxs, matrix, box
	local pos, ang, center
	local sphereChunk = 0
	local obbCenter = ent:GetPos() --да какая же хуйня это))0
	obbCenter:Add(ent:OBBCenter())
	for i = 0, ent:GetHitBoxCount(0) - 1 do
		matrix = ent:GetBoneMatrix(ent:GetHitBoxBone(i, 0))
		if not matrix then continue end
		mins, maxs = ent:GetHitBoxBounds(i, 0)
		pos = matrix:GetTranslation()
		ang = matrix:GetAngles()
		local center, disOfCenter = getTransform(pos, ang, mins, maxs, obbCenter)
		if disOfCenter > sphereChunk then sphereChunk = disOfCenter end
		boxs[#boxs + 1] = {pos, ang, mins, maxs, center}
	end

	for nameBone, organs in pairs(organs) do
		local bone = ent:LookupBone(nameBone)
		--if not bone then continue end
		matrix = ent:GetBoneMatrix(bone)
		if not matrix then continue end
		pos = matrix:GetTranslation()
		ang = matrix:GetAngles()
		for key, organ in pairs(organs) do
			--print(key,organ[1])
			local additional = organ[7]
			if additional then
				local ent = ent:IsPlayer() and ent or ent:IsRagdoll() and IsValid(hg.RagdollOwner(ent)) and hg.RagdollOwner(ent) or ent
				if ent and ent.armors and not table.HasValue(ent.armors,organ[1]) then
					continue
				end
			end
			mins = -organ[5]
			maxs = -mins
			local center, disOfCenter, boxLen = getTransform(pos, ang, mins, maxs, obbCenter)
			if disOfCenter > sphereChunk then sphereChunk = disOfCenter end
			local pos, ang = LocalToWorld(organ[3], organ[4], pos, ang)
			boxs[#boxs + 1] = {pos, ang, mins, maxs, center, nameBone, key}
		end
	end

	//table.sort(boxs, function(a, b) return (organs[a[6]] and organs[a[6]][a[7]][2] or 0) > (organs[b[6]] and organs[b[6]][b[7]][2] or 0) end)
	//PrintTable(boxs)
	return boxs, obbCenter, sphereChunk
end

--local util_IsOBBIntersectingOBB = util.IsOBBIntersectingOBB --huy not server side
local util_IntersectRayWithOBB = util.IntersectRayWithOBB
local math_ceil = math.ceil
local stepDiv = 1
local tracePos = Vector(0, 0, 0)

function hg.organism.Trace_Bullet(organs)
	local organ = box[6] and organs[box[6]][box[7]]
	return organ and organ[2] or 0
end

local models_female = {
	["models/player/group01/female_01.mdl"] = true,
	["models/player/group01/female_02.mdl"] = true,
	["models/player/group01/female_03.mdl"] = true,
	["models/player/group01/female_04.mdl"] = true,
	["models/player/group01/female_05.mdl"] = true,
	["models/player/group01/female_06.mdl"] = true,
	["models/player/group03/female_01.mdl"] = true,
	["models/player/group03/female_02.mdl"] = true,
	["models/player/group03/female_03.mdl"] = true,
	["models/player/group03/female_04.mdl"] = true,
	["models/player/group03/female_05.mdl"] = true,
	["models/player/group03/police_fem.mdl"] = true
}

if SERVER then return end

local male, female
net.Receive("HitboxesGetOrgans",function()
	male = net.ReadTable()
	female = net.ReadTable()
end)

function hg.organism.GetHitBoxOrgans(model, ent)
    if model == "models/gfreakman/gordonf_highpoly.mdl" then
        return gordon
    end
    return (models_female[model] and female) or male
end

local render_DrawW
local white, red, blue, black = Color(255, 255, 255), Color(255, 0, 0), Color(0, 0, 255), Color(0, 0, 0)
local hg_show_hitbox = ConVarExists("hg_show_hitbox") and GetConVar("hg_show_hitbox") or CreateClientConVar("hg_show_hitbox", "0", false, false, "shows custom players hitboxes, work only for admins or with sv_cheats 1 enabled")
local hg_show_hitbox_dir = ConVarExists("hg_show_hitbox_dir") and GetConVar("hg_show_hitbox_dir") or CreateClientConVar("hg_show_hitbox_dir", "0", false, false, "work only for admins or with sv_cheats 1 enabled")
render_DrawWireframeBox = render.DrawWireframeBox
hook.Add("PostDrawTranslucentRenderables", "homigrad-organism", function()
	if not hg_show_hitbox:GetBool() then return end
	if not LocalPlayer():IsAdmin() then return end
	for i, ply in player.Iterator() do
		if GetViewEntity() == ply then continue end
		ply = hg.GetCurrentCharacter(ply)
		local organs = hg.organism.GetHitBoxOrgans(ply:GetModel(), ply)
		if not organs then return end
		local boxs, pos, sphere = hg.organism.ShootMatrix(ply, organs)
		if hg_show_hitbox_dir:GetFloat() > 0 and hg.organism.Trace then
			local dir = Vector(hg_show_hitbox_dir:GetFloat(), 0, 0)
			dir:Rotate(LocalPlayer():EyeAngles())
			local distance = math_ceil(dir:Length())
			local start = hg.eyeTrace(lply).HitPos -- Vector(1005.879456,608.151123,-77.997421)
			//pos, dir, size, maxpen, boxs, center, endDis, organs, ricochetable, funcInput, ...
			local endPos, hitBoxs, inputHole, outputHole = hg.organism.Trace(start, dir, 1, 0, boxs, pos, sphere, organs, false, hg.organism.Trace_Bullet, organs)
			--render.DrawWireframeBox(endPos, angZero, -box, box)
			
			render.DrawWireframeBox(start, LocalPlayer():EyeAngles(), -Vector(0,distance / 50,distance / 50),Vector(distance / 1,distance / 50,distance / 50))
			for i = 1, #boxs do
				local box = boxs[i]
				local organ = box[6] and organs[box[6]][box[7]]
				render_DrawWireframeBox(box[1], box[2], box[3], box[4], (hitBoxs[i] and white) or (organ and organ[6]) or black)
			end

			for i = 1, #inputHole do
				render.DrawWireframeSphere(inputHole[i], 1, 16, 16, red)
			end

			for i = 1, #outputHole do
				render.DrawWireframeSphere(outputHole[i], 0.5, 16, 16, blue)
			end
		else
			for i = 1, #boxs do
				local box = boxs[i]
				local organ = box[6] and organs[box[6]][box[7]]
				render_DrawWireframeBox(box[1], box[2], box[3], box[4], (organ and organ[6]) or black)
			end
		end
		--render.DrawWireframeSphere(pos,sphere,16,16,color2)
	end
end)