local net, hg, pairs, Vector, ents, IsValid, util = net, hg, pairs, Vector, ents, IsValid, util

local vecZero = Vector(0,0,0)
local vecInf = Vector(0,0,0) / 0

local function removeBone(rag, bone, phys_bone, nohuys)
 if !nohuys then rag:ManipulateBoneScale(bone, vecZero) end

 if rag.gibRemove[phys_bone] then return end

 local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
 phys_obj:EnableCollisions(false)
 phys_obj:SetMass(0.1)

 constraint.RemoveAll(phys_obj)
 rag.gibRemove[phys_bone] = phys_obj
end

local function recursive_bone(rag, bone, list)
 for i,bone in pairs(rag:GetChildBones(bone)) do
  if bone == 0 then continue end
  list[#list + 1] = bone
  recursive_bone(rag, bone, list)
 end
end

function Gib_RemoveBone(rag, bone, phys_bone, nohuys)
 rag.gibRemove = rag.gibRemove or {}

 removeBone(rag, bone, phys_bone, nohuys)

 local list = {}
 recursive_bone(rag, bone, list)
 for i, bone in pairs(list) do
  removeBone(rag, bone, rag:TranslateBoneToPhysBone(bone), nohuys)
 end
end

gib_ragdols = gib_ragdols or {}
local gib_ragdols = gib_ragdols

local validHitGroup = {
 [HITGROUP_LEFTARM] = true,
 [HITGROUP_RIGHTARM] = true,
 [HITGROUP_LEFTLEG] = true,
 [HITGROUP_RIGHTLEG] = true,
}

local Rand = math.Rand

local validBone = {
 ["ValveBiped.Bip01_R_UpperArm"] = true,
 ["ValveBiped.Bip01_R_Forearm"] = true ,
 ["ValveBiped.Bip01_R_Hand"] = true,
 ["ValveBiped.Bip01_L_UpperArm"] = true,
 ["ValveBiped.Bip01_L_Forearm"] = true,
 ["ValveBiped.Bip01_L_Hand"] = true,

 ["ValveBiped.Bip01_L_Thigh"] = true,
 ["ValveBiped.Bip01_L_Calf"] = true,
 ["ValveBiped.Bip01_L_Foot"] = true,
 ["ValveBiped.Bip01_R_Thigh"] = true,
 ["ValveBiped.Bip01_R_Calf"] = true,
 ["ValveBiped.Bip01_R_Foot"] = true
}

local VectorRand, ents_Create = VectorRand, ents.Create

local mdl_hgibs = Model("models/Gibs/HGIBS.mdl")
local mdl_hgibs_spine = Model("models/Gibs/HGIBS_spine.mdl")
local mdl_hgibs_scapula = Model("models/Gibs/HGIBS_scapula.mdl")
local mdl_hgibs_rib = Model("models/Gibs/HGIBS_rib.mdl")

util.PrecacheModel(mdl_hgibs)
util.PrecacheModel(mdl_hgibs_spine)
util.PrecacheModel(mdl_hgibs_scapula)
util.PrecacheModel(mdl_hgibs_rib)

function SpawnGore(ent, pos, headpos)
 if ent.gibRemove and not ent.gibRemove[ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_Head1"))] then
  local ent = ents_Create("prop_physics")
  ent:SetModel(mdl_hgibs)
  ent:SetPos(headpos or pos)
  ent:SetVelocity(VectorRand(-100, 100))
  ent:Spawn()
 end

 for i = 1, 2 do
  local ent = ents_Create("prop_physics")
  ent:SetModel(mdl_hgibs_spine)
  ent:SetPos(pos)
  ent:SetVelocity(VectorRand(-100, 100))
  ent:Spawn()

  local ent = ents_Create("prop_physics")
  ent:SetModel(mdl_hgibs_scapula)
  ent:SetPos(pos)
  ent:SetVelocity(VectorRand(-100, 100))
  ent:Spawn()

  local ent = ents_Create("prop_physics")
  ent:SetModel(mdl_hgibs_rib)
  ent:SetPos(pos)
  ent:SetVelocity(VectorRand(-100, 100))
  ent:Spawn()
 end
end

local function PhysCallback( ent, data )
 if data.DeltaTime < 0.2 then return end
 ent:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav")
 util.Decal("Blood",data.HitPos - data.HitNormal*1,data.HitPos + data.HitNormal*1,ent)
end

local grub = Model("models/grub_nugget_small.mdl")
util.PrecacheModel(grub)

function SpawnMeatGore(mainent, pos, count, force)
 force = force or Vector(0,0,0)
 for i = 1, (count or math.random(8, 10)) do
  local ent = ents_Create("prop_physics")
  ent:SetModel(grub)
  ent:SetSubMaterial(0,"models/flesh")
  ent:SetPos(pos)
  ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
  ent:SetModelScale(math.Rand(0.8,1.1))
  ent:SetAngles(AngleRand(-180,180))
  ent:Activate()
  ent:Spawn()
  local phys = ent:GetPhysicsObject()
  if IsValid(phys) then
   phys:SetVelocity(mainent:GetVelocity() + VectorRand(-65,65) + force / 10)
   phys:AddAngleVelocity(VectorRand(-65,65))
  end

  ent:AddCallback( "PhysicsCollide", PhysCallback )
 end
end

local headpos_male, headpos_female, headang = Vector(0,0,5), Vector(-2,0,4), Angle(0,0,-0)

util.AddNetworkString("addfountain")

hg.fountains = hg.fountains or {}
local headboom_mdl = Model("models/gleb/zcity/headboom.mdl")
local sounds = {
 Sound("player/zombie_head_explode_01.wav"),
 Sound("player/zombie_head_explode_02.wav"),
 Sound("player/zombie_head_explode_03.wav"),
 Sound("player/zombie_head_explode_04.wav"),
 Sound("player/zombie_head_explode_05.wav"),
 Sound("player/zombie_head_explode_06.wav")
}

util.PrecacheModel(headboom_mdl)
for _, snd in ipairs(sounds) do
 util.PrecacheSound(snd)
end

local BONE_HEAD_NAME = "ValveBiped.Bip01_Head1"
local BONE_NECK_NAME = "ValveBiped.Bip01_Neck1"
local ATT_HEAD = 3

function Gib_Input(rag, bone, force)
 if not IsValid(rag) then return end

 rag._hg_gibcache = rag._hg_gibcache or {}

 local cache = rag._hg_gibcache
 if cache.headBone == nil then cache.headBone = rag:LookupBone(BONE_HEAD_NAME) end
 if cache.neckBone == nil then cache.neckBone = rag:LookupBone(BONE_NECK_NAME) end
 if cache.headPhys == nil and cache.headBone then cache.headPhys = rag:TranslateBoneToPhysBone(cache.headBone) end

 local gibRemove = rag.gibRemove

 if not gibRemove then
  rag.gibRemove = {}
  gibRemove = rag.gibRemove

  gib_ragdols[rag] = true
 end

 local phys_bone = rag:TranslateBoneToPhysBone(bone)
 local phys_obj = rag:GetPhysicsObjectNum(phys_bone)

 if (not gibRemove[phys_bone]) and (bone == cache.headBone) then
  rag:EmitSound(sounds[math.random(#sounds)], 70, math.random(95, 105), 2)

  Gib_RemoveBone(rag, bone, phys_bone)

  rag:ManipulateBonePosition(cache.neckBone,Vector(-1,0,0))

  local ent = ents_Create("prop_dynamic")
  ent:SetModel(headboom_mdl)
  local att = rag:GetAttachment(ATT_HEAD)
  local pos, ang = LocalToWorld(ThatPlyIsFemale(rag) and headpos_female or headpos_male, headang, att.Pos, att.Ang)
  ent:SetPos(pos)
  ent:SetAngles(ang)
  ent:SetParent(rag, ATT_HEAD)
  ent:Spawn()

  SpawnMeatGore(ent, pos, nil, force)

  local armors = rag:GetNetVar("Armor",{})

  if armors["head"] and !hg.armor["head"][armors["head"]].nodrop then
   local ent = hg.DropArmorForce(rag, armors["head"])
   ent:SetPos(phys_obj:GetPos())
  end

  if armors["face"] and !hg.armor["face"][armors["face"]].nodrop then
   local ent = hg.DropArmorForce(rag, armors["face"])
   ent:SetPos(phys_obj:GetPos())
  end

  rag.noHead = true
  rag:SetNWString("PlayerName", "Beheaded body")

  net.Start("addfountain")
  net.WriteEntity(rag)
  net.WriteVector(force or vector_origin)
  net.Broadcast()

  hg.fountains[rag] = {bone = cache.neckBone, lpos = ThatPlyIsFemale(rag) and Vector(4,0,0) or Vector(5,0,0),lang = Angle(0,0,0)}

  rag:CallOnRemove("removefountain", function()
   hg.fountains[rag] = nil
   SetNetVar("fountains", hg.fountains)
  end)

  SetNetVar("fountains", hg.fountains)
 end
end
