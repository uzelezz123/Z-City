AddCSLuaFile()
--
local surface_hardness = {
	[MAT_METAL] = 1,
	[MAT_COMPUTER] = 0.9,
	[MAT_VENT] = 0.9,
	[MAT_GRATE] = 0.9,
	[MAT_FLESH] = 0.5,
	[MAT_ALIENFLESH] = 0.3,
	[MAT_SAND] = 0.1,
	[MAT_DIRT] = 0.9,
	[74] = 0.1,
	[85] = 0.2,
	[MAT_WOOD] = 0.5,
	[MAT_FOLIAGE] = 0.5,
	[MAT_CONCRETE] = 0.9,
	[MAT_TILE] = 0.8,
	[MAT_SLOSH] = 0.05,
	[MAT_PLASTIC] = 0.3,
	[MAT_GLASS] = 0.6,
}

local effect = {
	[MAT_METAL] = {"metal",1},
	[MAT_COMPUTER] = {"metal",1},
	[MAT_VENT] = {"metal",1},
	[MAT_FLESH] = {"flesh",0.75},
	[MAT_ALIENFLESH] = {"alienflesh",1},
	[MAT_SAND] = {"sand",1},
	[MAT_DIRT] = {"dirt",1},
	[MAT_WOOD] = {"wood",1},
	[MAT_FOLIAGE] = {"grass",1},
	[MAT_CONCRETE] = {"concrete",1},
	[MAT_TILE] = {"concrete",1},
	[MAT_SLOSH] = {"concrete",1},
	[MAT_PLASTIC] = {"concrete",1},
	[MAT_GLASS] = {"glass",1},
}

local bulletHit
--local hg_bulletholes = GetConVar("hg_bulletholes") or CreateClientConVar("hg_bulletholes", "150", true, false, "0-500, amount of bullet hole effects (r6s-like)", 0, 500)
local timer, util, math, IsValid, WorldToLocal, Vector, sound, EffectData, game = timer, util, math, IsValid, WorldToLocal, Vector, sound, EffectData, game

local function callbackBullet(self, tr, dmg, force, bullet)
	if CLIENT then return end
	if not bullet then return end
	bullet.limit_ricochet = bullet.limit_ricochet or 0
	bullet.penetrated = bullet.penetrated or 0
	if bullet.penetrated > 6 then return end
	if bullet.limit_ricochet > 6 then return end
	if tr.Entity.organism then return end
	
	local dir, hitNormal, hitPos = tr.Normal, tr.HitNormal, tr.HitPos
	local hardness = surface_hardness[tr.MatType] or 0.5
	local ApproachAngle = -math.deg(math.asin(hitNormal:DotProduct(dir)))
	local MaxRicAngle = 60 * hardness * (bullet.noricochet and 0 or 1)
	
	-- all the way through
	--print(ApproachAngle > MaxRicAngle * 0.7  )
	if ApproachAngle > MaxRicAngle * 1 then--or tr.Entity:IsVehicle() then
		local Pen = (bullet.Penetration or 5) * 3 or dmg
		local MaxDist, SearchPos, SearchDist, Penetrated = math.min(Pen / hardness * 0.4, 100), hitPos, 5, false
		
		local hit
		while SearchDist < MaxDist do
			SearchPos = hitPos + dir * SearchDist
			local PeneTrace = util.QuickTrace(SearchPos, -dir * SearchDist)
			if not PeneTrace.StartSolid then
				Penetrated = true
				hit = PeneTrace
				bullet.Penetration = bullet.Penetration - Pen * SearchDist / MaxDist / 3

				break
			else
				SearchDist = SearchDist + 5
			end
		end
		
		if CLIENT then
			if Penetrated then				
				local ent = IsValid(tr.Entity) and tr.Entity or Entity(0)
				--if #hg.bulletholes > hg_bulletholes:GetInt() then table.remove(hg.bulletholes,1) table.remove(hg.bulletholes,1) end
				local hitPos2,dir2 = WorldToLocal(hitPos,dir:Angle(),ent:GetPos(),ent:GetAngles())
				local _,hitNormal2 = WorldToLocal(hitPos,hitNormal:Angle(),ent:GetPos(),ent:GetAngles())
				--table.insert(hg.bulletholes,{hitPos2,dir2,SearchDist,hitNormal2,Pen,ent})
				local hitPos2,dir2 = WorldToLocal(hit.HitPos,(-dir):Angle(),ent:GetPos(),ent:GetAngles())
				local _,hitNormal2 = WorldToLocal(hit.HitPos,hit.HitNormal:Angle(),ent:GetPos(),ent:GetAngles())
				--table.insert(hg.bulletholes,{hitPos2,dir2,SearchDist,hitNormal2,Pen,ent})
				hg.addBulletHoleEffect(hitPos)
				hg.addBulletHoleEffect(hit.HitPos)
				--return true
			end
			--return false
		end
		
		--print(Penetrated)
		if Penetrated then--or tr.Entity:IsVehicle() then
			--[[self:FireLuaBullets({
				Attacker = self:GetOwner(),
				Damage = 0,
				Force = 0,
				Num = 1,
				Tracer = 0,
				TracerName = "nil",
				Dir = -dir,
				Spread = Vector(0, 0, 0),
				Src = SearchPos + dir,
				DisableLagComp = true,
				Filter = {},
				Distance = SearchPos
				--Penetration = bullet.Penetration,
				--Diameter = bullet.Diameter 
				--Callback = bulletHit
			},true)--]]
			util.Decal("Impact.Concrete",SearchPos + dir*5, SearchPos - dir*15)
			timer.Simple(0.15,function()
				if effect[tr.MatType] then
					local effectdata2 = EffectData()
					effectdata2:SetNormal(dir)
					effectdata2:SetStart(hitPos + dir * 15)
					effectdata2:SetMagnitude(1 * effect[tr.MatType][2])
					util.Effect("zippy_impact_"..effect[tr.MatType][1],effectdata2)
				end
			end)
			local tBullet = {
				Attacker = IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner() or self,
				Damage = dmg * 0.65,
				Force = force / 3,
				Num = 1,
				Tracer = 0,
				TracerName = "nil",
				Dir = dir,
				Spread = vector_origin,
				Src = SearchPos + dir,
				Callback = bulletHit,
				DisableLagComp = true,
				Filter = {},
				Penetration = bullet.Penetration,
				Diameter = bullet.Diameter,
				penetrated = bullet.penetrated + 1,
				dmgtype = bullet.dmgtype or DMG_BULLET,
				NpcShoot = bullet.NpcShoot,
				limit_ricochet = bullet.limit_ricochet + 1,
				noricochet = bullet.noricochet,
				AmmoType = bullet.AmmoType
			}

			self.bullet = tBullet
			
			self:FireLuaBullets( tBullet )
			
			local tr = util.TraceLine( {
				start = SearchPos + dir,
				endpos = SearchPos + dir * 10000,
				mask = MASK_SHOT
			} )
			timer.Simple(0.1,function()
				local effectdata1 = EffectData()
				effectdata1:SetOrigin(tr.HitPos)
				effectdata1:SetStart(hitPos + hitNormal)
				effectdata1:SetEntity(self)
				effectdata1:SetMagnitude(2)
				util.Effect("eff_tracer", effectdata1)
			end)
		end
	elseif ApproachAngle < MaxRicAngle * 0.7 then --previosly 0.2, made 1 for fun
		--if CLIENT then return end
		-- ping whiiiizzzz
		local rnd = math.random(12)
		if rnd == 8 then rnd = 9 end
		sound.Play("arc9_eft_shared/ricochet/ricochet" .. rnd .. ".ogg", hitPos, 75, math.random(90, 110))
		--sound.Play("snd_jack_hmcd_ricochet_" .. math.random(1, 2) .. ".wav", hitPos, 75, math.random(90, 110))
		--sound.Play("weapons/arccw/ricochet0" .. math.random(1, 5) .. "_quiet.wav", hitPos, 75, math.random(90, 110))
		util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		local NewVec = dir:Angle()
		NewVec:RotateAroundAxis(hitNormal, 180)
		NewVec = NewVec:Forward()
		local tBullet = {
			Attacker = IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner() or self,
			Damage = (dmg or 1) * .85,
			Force = force / 3,
			Num = 1,
			Tracer = 0,
			TracerName = "nil",
			Dir = -NewVec,
			Spread = vector_origin,
			Src = hitPos + hitNormal,
			Callback = bulletHit,
			DisableLagComp = true,
			Filter = {},
			Penetration = bullet.Penetration,
			Diameter = bullet.Diameter,
			penetrated = bullet.penetrated + 1,
			dmgtype = bullet.dmgtype or DMG_BULLET,
			limit_ricochet = bullet.limit_ricochet + 1,
			noricochet = bullet.noricochet,
			AmmoType = bullet.AmmoType
		}
		
		self.bullet = tBullet

		self:FireLuaBullets( tBullet )
		
		local tr = util.TraceLine( {
			start = hitPos + hitNormal,
			endpos = hitPos + hitNormal + -NewVec * 10000,
			mask = MASK_SHOT
		} )
		timer.Simple(0,function()
			local effectdata1 = EffectData()
			effectdata1:SetOrigin(tr.HitPos)
			effectdata1:SetStart(hitPos + hitNormal)
			effectdata1:SetEntity(self)
			effectdata1:SetMagnitude(2)
			util.Effect("eff_tracer", effectdata1)
		end)
	elseif math.random(2) == 1 then
		if CLIENT then return end
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(hitPos)
		effectdata1:SetNormal(tr.Normal)
		effectdata1:SetStart(tr.HitNormal)
		effectdata1:SetEntity(self)
		effectdata1:SetFlags(2)
		effectdata1:SetMagnitude(4)
		util.Effect("eff_bulletdrop", effectdata1)
	end
end

function SWEP:CallbackBullet(self, tr)
	return callbackBullet(self, tr)
end

local hg_potatopc

local hands = {
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
}

local shootDecals, shootDecalRand = {
	"decals/metal/shot6",
	"decals/metal/shot7",
	"decals/bigshot2",
	"decals/bigshot4",
	"decals/bigshot5",
}, 1
for i, decal in ipairs(shootDecals) do
	game.AddDecal("Impact.ShootAdd" .. i, decal)
	shootDecalRand = i
end

game.AddDecal("Impact.ShootPowderAdd", "decals/burn01a")

local ipairs, ents = ipairs, ents
local ents_FindInCone = ents.FindInCone
local vectorup = Vector(0, 0, 25)
local ang = math.cos( math.rad( 125 ) )
local function gasInertia(pos, force, dir)
	if force >= 150 then return end
	for _, ent in ipairs(ents_FindInCone(pos, dir, force, ang)) do
		--print(ent)
		if IsValid(ent) and not ent:IsNPC() and not ent:IsPlayer() then
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				if phys:GetMass() > 5 then continue end
				local entpos = ent:GetPos()
				local dist = pos:Distance(entpos)
				local falloff = 1.5 - (dist / (force))

				phys:Wake()
				phys:ApplyForceCenter( ( ( (pos - entpos):GetNormalized() + dir) * 2 * ((-phys:GetMass() / 1.5) * (force / 5)) + vectorup ) * falloff)
			end
		end
	end
end

local powderMat, powderClr, world = Material("decals/burn01a"), Color(255, 255, 255, 150), game.GetWorld()
local allowedMats = {
	[MAT_CONCRETE] = true,
	[MAT_METAL] = true
}
bulletHit = function(ply, tr, dmgInfo, bullet, Weapon)
	if CLIENT then return end
	local inflictor = IsValid(ply) and not ply:IsNPC() and ply.GetActiveWeapon and ply:GetActiveWeapon() or dmgInfo:GetInflictor()
	local dmg, force = dmgInfo:GetDamage(), dmgInfo:GetDamage()--dmgInfo:GetDamageForce():Length()

	if IsValid(ply) and IsValid(ply.FakeRagdoll) and tr.Entity == ply.FakeRagdoll and hands[hg.realPhysNum(ply.FakeRagdoll, tr.PhysicsBone)] then
		return false, false
	end

	--// uncomment to use default impact effects
	--[[local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	effectdata:SetEntity( tr.Entity )
	effectdata:SetStart( tr.StartPos )
	effectdata:SetSurfaceProp( tr.SurfaceProps )
	effectdata:SetDamageType( dmgInfo:GetDamageType() )
	effectdata:SetHitBox( tr.HitBox )
	util.Effect( "Impact", effectdata )]]

	local trPos, trNormal, trStart = tr.HitPos, tr.HitNormal, tr.StartPos
	if tr.MatType == MAT_FLESH then
		util.Decal("Impact.Flesh", trPos + trNormal, trPos - trNormal)
	end

	--local force = bullet.Force
	if force >= 20 then
		local dist = trStart:DistToSqr(trPos)
		if dist <= 160000 and (math.random(3) == 2 or force >= 30) and tr.Entity:IsWorld() and allowedMats[tr.MatType] then
			util.Decal("Impact.ShootAdd" .. math.random(shootDecalRand), trPos + trNormal, trPos - trNormal)
		end
		if force >= 30 and dist <= 1400000 and (math.random(3) == 2 or force >= 45) then
			util.Decal("Impact.ShootPowderAdd", trPos + trNormal, trPos - trNormal)
			--util.DecalEx(powderMat, world, trPos, trNormal, powderClr, 1, 1) uzelezz said that DecalEx crashing the game..
		end

		gasInertia(trPos, force * 3, -tr.Normal)
		gasInertia(trStart, force * 3, tr.Normal)
	end

	timer.Simple(0,function()
		if not bullet then return end
		callbackBullet(Weapon or inflictor, tr, dmg, force, bullet)
	end)
end

hg.bulletHit = bulletHit
hg.callbackBullet = callbackBullet

local bullet = {}
local empty = {}
local vecCone = Vector(0, 0, 0)
local cone, att, att2, owner, primary, ang
local math_Rand, math_random = math.Rand, math.random
local gun
function SWEP:GetWeaponEntity()
	return IsValid(self.worldModel) and IsValid(self:GetOwner()) and self.worldModel or self
end

SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 0)
local gun
local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local attTbl = {
	Pos = vecZero,
	Ang = angZero
}

function SWEP:GetMuzzleAtt(ent, trueAtt, supressorAdd)
	local owner = IsValid(self) and self:GetOwner() or ent:GetOwner() or ent
	--do return {Pos=Vector(0,0,0),Ang=Angle(0,0,0)} end
	gun = ent or self:GetWeaponEntity()
	if not IsValid(gun) then return attTbl end

	if SERVER then 
		if owner:IsNPC() then 
			attTbl.Pos = owner:EyePos()
			attTbl.Ang = owner:GetAimVector():Angle()
			
			return attTbl 
		end
	end

	--if true then return {Pos = self.desiredPos or vector_origin,Ang = self.desiredAng or angle_zero} end

	local att = gun:GetAttachment(gun:LookupAttachment( self:ShouldUseFakeModel() and self.FakeAttachment or "muzzle"))
	local att = att ~= nil and att or gun:GetAttachment(gun:LookupAttachment("muzzle_flash"))
	--local att = gun:GetAttachment(gun:LookupAttachment("muzzle"))
	--local att = att!=nil and att or gun:GetAttachment(gun:LookupAttachment("muzzle_flash"))
	local attPos = self.attPos
	local attAng = self.attAng

	if not att then
		local angHuy = gun:GetAngles()
		local posHuy = gun:GetPos()
		
		angHuy:RotateAroundAxis(angHuy:Forward(), 90)
		local _,angHuy = LocalToWorld(vecZero,attAng,vecZero,angHuy)
		
		posHuy:Add(angHuy:Up() * attPos[1] + angHuy:Right() * attPos[2] + angHuy:Forward() * attPos[3])
		if supressorAdd and self:HasAttachment("barrel", "supressor") then posHuy:Add(angHuy:Forward() * 10) end

		if self:ShouldUseFakeModel() then posHuy, angHuy = LocalToWorld(self.AttachmentPos, self.AttachmentAng, posHuy, angHuy) end

		attTbl.Pos = posHuy
		attTbl.Ang = angHuy

		return attTbl
	end
	
	if trueAtt then
		local pos, ang = att.Pos, att.Ang
		
		local pos, ang = LocalToWorld(attPos, attAng, pos, ang)
		

		att.Pos = pos
		att.Ang = ang
		ang:RotateAroundAxis(ang:Forward(),self.rotatehuy or 0)
		
		if self:ShouldUseFakeModel() then pos, ang = LocalToWorld(self.AttachmentPos, self.AttachmentAng, pos, ang) end

		--ang:Add(attAng)
		if supressorAdd and self:HasAttachment("barrel", "supressor") then pos:Add(ang:Forward() * 10) end
		--pos:Add(ang:Up() * attPos[1] + ang:Right() * attPos[2] + ang:Forward() * attPos[3])
	end

	if self:ShouldUseFakeModel() then att.Pos, att.Ang = LocalToWorld(self.AttachmentPos, self.AttachmentAng, att.Pos, att.Ang) end

	return att
end

local tr = {}
local att
local util_TraceLine = util.TraceLine

function SWEP:GetTrace(bCacheTrace, desiredPos, desiredAng, NoTrace, closeanim)
	if SERVER and !bCacheTrace and self.cache_trace and !(desiredPos or desiredAng) then return self.cache_trace[1], self.cache_trace[2], self.cache_trace[3] end
	local owner = self:GetOwner()
	
	if IsValid(owner) and owner:IsNPC() then local att = self:GetMuzzleAtt() return nil,SERVER and owner:GetShootPos() or att.Pos,SERVER and owner:GetAimVector():Angle() or att.Ang end
	
	local gun = self:GetWeaponEntity()
	if !IsValid(gun) then return end

	local gunpos, gunang

	if CLIENT and !closeanim then
		gunpos, gunang = self.desiredPos, self.desiredAng
	else
		gunpos, gunang = self:WorldModel_Transform(true)
	end
	
	gunpos = gunpos or gun:GetPos()
	gunang = gunang or gun:GetAngles()
	--debugoverlay.Line(gunpos, gunpos + gunang:Forward() * 20,0.5,color_white)

	if CLIENT and self:ShouldUseFakeModel() then
		local mat = Matrix()
		mat:SetTranslation(self.FakePos)
		mat:SetAngles(self.FakeAng)
		mat = mat:GetInverse()
		gunpos, gunang = LocalToWorld(mat:GetTranslation(), mat:GetAngles(), gunpos, gunang)
	end
	
	local pos, ang = LocalToWorld(self.LocalMuzzlePos, self.LocalMuzzleAng, gunpos, gunang)
	
	if NoTrace then self.cache_trace = self.cache_trace or {} self.cache_trace[2] = pos self.cache_trace[3] = ang
		if !bCacheTrace then
			return {}, pos, ang
		else
			return pos, ang
		end
	end

	local dir = ang:Forward()

	local fake = CLIENT and owner.FakeRagdoll or nil
	tr.start = pos
	tr.endpos = pos + dir * 8000
	tr.filter = {gun, not owner.suiciding and owner or NULL,fake}

	local trace = util_TraceLine(tr)
	if bCacheTrace then
		self.cache_trace = self.cache_trace or {}
		self.cache_trace[1] = trace
		self.cache_trace[2] = pos
		self.cache_trace[3] = ang
	end
	--debugoverlay.Sphere(trace.HitPos, 1, 1, SERVER and Color(255, 0, 0) or Color(0, 255, 0))
	return trace, pos, ang
end

SWEP.ShellEject = "EjectBrass_556"
SWEP.MuzzleEffectType = 1


local images_muzzle = {
	[2] = {"effects/muzzleflash1", "effects/muzzleflash2", "effects/muzzleflash3", "effects/muzzleflash4"},
	[3] = {"effects/gunshipmuzzle","effects/combinemuzzle2"}
}
local vecZero = Vector(0, 0, 0)
local image_distort = "sprites/heatwave"

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mpistol" -- shared in sh_effects.lua
SWEP.PPSMuzzleEffectSuppress = "pcf_jack_mf_suppressed"

function SWEP:GetLocalHuynyis()
	local gun = self:GetWeaponEntity()
	local owner = self:GetOwner()

	local atth = gun:GetAttachment(gun:LookupAttachment("muzzle"))
	local atth = atth ~= nil and atth or gun:GetAttachment(gun:LookupAttachment("muzzle_flash"))
	
	local att2 = self:GetMuzzleAtt(gun,false)
	local muzzle_local_pos,muzzle_local_ang = WorldToLocal(att2.Pos,att2.Ang,gun:GetPos(),gun:GetAngles())
	if atth then
		muzzle_local_pos,muzzle_local_ang = LocalToWorld(self.attPos,self.attAng,muzzle_local_pos,muzzle_local_ang)
	end
	if not IsValid(owner.FakeRagdoll) then
		muzzle_local_ang:RotateAroundAxis(muzzle_local_ang:Up(),-(self.rotatehuy or 0))
	end

	return muzzle_local_pos,muzzle_local_ang
end

function SWEP:GetRealDebilAttachment(muzzle_local_pos,muzzle_local_ang)
	if not IsValid(owner) then return end
	local gun = self:GetWeaponEntity()
	local owner = self:GetOwner()
	local eyeang = owner:GetAimVector():Angle()
	eyeang[3] = eyeang[3] + (owner:EyeAngles()[3])
	local eyeang = eyeang + (self.weaponAngLerp or angZero)
	local _,ang2 = LocalToWorld(vector_origin,muzzle_local_ang,vector_origin,eyeang)
	local pos,ang = LocalToWorld(muzzle_local_pos,muzzle_local_ang,gun:GetPos(),gun:GetAngles())
	local angh = (owner.suiciding or IsValid(owner.FakeRagdoll)) and ang or ang2

	return pos,angh
end

/*for i, ent in pairs(ents.FindByClass("weapon_akm")) do
	if !IsValid(ent) then continue end
	ent:PrimaryAttack()
end*/

function SWEP:FireBullet()
    local gun = self:GetWeaponEntity()
    local owner = self:GetOwner()
	local isply = IsValid(owner) and owner:IsPlayer() and !owner.suiciding
	local isnpc = IsValid(owner) and owner:IsNPC()
	local ent = owner

	if self:ShouldUseFakeModel() and not self.NoIdleLoop and isply then
		self:PlayAnim("idle", 1)
	end

	if isply then
    	ent = hg.GetCurrentCharacter(owner)
	end

    local ammotype = hg.ammotypeshuy[self.Primary.Ammo].BulletSettings
    
	if SERVER and !timer.Exists("ShootWeaponAfterDeath"..self:EntIndex()) then
		timer.Create("ShootWeaponAfterDeath"..self:EntIndex(), 0.1, 1, function()
			if (!IsValid(owner) or !owner:Alive()) and self.Primary and self.Primary.Automatic then
				self:PrimaryAttack()
			end
		end)
	end

    local att = self:GetMuzzleAtt(gun, true)
    if not att then return end
    local pos, ang = att.Pos, att.Ang
    //if not isply and not owner:IsNPC() then return end
    local fakeGun = self:GetNWEntity("fakeGun")

    local primary = self.Primary

	if isply then
		owner:LagCompensation(true)
	end

	self:WorldModel_Transform()
	local tr, pos, ang = self:GetTrace(true)

	if isply then
		owner:LagCompensation(false)
	end

	local trace
	local dir = ang:Forward()
	if isply then
		//print(gun:GetAngles(), dir, owner.offsetView)
		local dist, point = util.DistanceToLine(pos, pos - dir * 50, owner:EyePos())
		local tr = {}
		tr.start = point
		tr.endpos = pos
		tr.filter = {owner, ent, SERVER and hg.ragdollFake[owner]}
		trace = util.TraceLine(tr)
	end

    local numbullet = ammotype.NumBullet or 1

	if not IsValid(owner) then
		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:ApplyForceOffset(-dir * self.Primary.Force * 5, pos)
		end
	end

	--[[local enta = ents.Create("prop_physics")
	enta:SetModel("models/props_c17/lampShade001a.mdl")
	enta:SetPos(head:GetTranslation() + head:GetAngles():Forward() * 15)
	enta:Spawn()
	enta:SetSolidFlags(FSOLID_NOT_SOLID)
	enta:GetPhysicsObject():EnableMotion(false)--]]

	local standing = false
	if ent ~= owner then
		standing = (owner:GetNetVar("lastFake",0) - CurTime() + 5) > 0
	end

	local headpos, headang

	if CLIENT then
		if IsValid(ent) then
			local head = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1"))

			if head then
				headpos, headang = head:GetTranslation(), head:GetAngles()
			else
				headpos, headang = ent:GetPos(), ent:GetAngles()
			end
		end
	else
		if IsValid(ent) then
			--headpos, headang = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine2")):GetTranslation(), ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1")):GetAngles()--ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
			--headpos, headang = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation(), ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1")):GetAngles()--ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
			headpos, headang = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
			headpos = headpos + headang:Forward() * 3-- - dir * 5
		end
		--[[local ent = ents.Create("prop_physics")
		ent:SetModel("models/props_junk/PopCan01a.mdl")
		ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		ent:SetPos(headpos)
		ent:Spawn()
		if IsValid(ent:GetPhysicsObject()) then
			ent:GetPhysicsObject():EnableMotion(false)
		end
		do return end--]]
	end

	local willsuicide = IsValid(owner) and owner:GetNWFloat("willsuicide", 0) != 0 and owner:GetNWFloat("willsuicide", 0) or ((owner.startsuicide or CurTime()) + 1) or CurTime() + 1
	local suiciding = owner.suiciding
	local willsuicidereal = (suiciding and (willsuicide == 0 or willsuicide < CurTime()))
	if isnpc then
		suiciding, willsuicidereal = false, false
	end

	local bullet = {}
    bullet.Src = (willsuicidereal and headpos or (trace and (trace.HitPos - trace.Normal) or pos))
	bullet.Dir = dir
	bullet.Attacker = owner

	if isnpc and CLIENT then
		local npcYawOffset = math.Remap( owner:GetPoseParameter("aim_yaw"),0,1,-60,60 )
		local npcPitchOffset = math.Remap( owner:GetPoseParameter("aim_pitch"),0,1,-88,50 )
		bullet.Dir = (owner:GetAngles()+AngleRand(-4,4)+Angle(npcPitchOffset,npcYawOffset,0)):Forward()
	end

	bullet.Force = ammotype.Force and ammotype.Force / 1.5 or primary.Force
    bullet.Damage = ammotype.Damage or primary.Damage or 25
	bullet.Damage = bullet.Damage * (self.Supressor and 0.9 or 1) * (self.DamageMultiplier or 1)

	bullet.Spread = (ammotype.Spread or self.Primary.Spread or 0) * 3
	bullet.Num = 1
	
	bullet.AmmoType = primary.Ammo
	bullet.TracerName = self.Tracer or "nil"
    bullet.IgnoreEntity = nil
    bullet.Callback = bulletHit

    bullet.Speed = ammotype.Speed
	bullet.Distance = ammotype.Distance or 56756
	bullet.Filter = {self, self.worldModel}

	bullet.noricochet = ammotype.noricochet
	
	local f1 = owner--not owner.suiciding and owner or nil
	local f2 = owner:IsPlayer() and owner:InVehicle() and owner:GetVehicle() or nil
	local f3 = owner:IsPlayer() and owner.GetSimfphys and IsValid(owner:GetSimfphys()) and owner:GetSimfphys() or nil
	local f4 = owner:IsPlayer() and owner:InVehicle() and owner.FakeRagdoll
	local f5 = standing and ent or nil
	if IsValid(f1) then table.insert(bullet.Filter, 1, f1) end
	if IsValid(f2) then table.insert(bullet.Filter, 1, f2) end
	if IsValid(f3) then table.insert(bullet.Filter, 1, f3) end
	if IsValid(f4) then table.insert(bullet.Filter, 1, f4) end
	if IsValid(f5) then table.insert(bullet.Filter, 1, f5) end
	
	bullet.Inflictor = self
	bullet.DontUsePhysBullets = self.DontUsePhysBullets
	if isnpc then
		--[[self.DontUsePhysBullets = true
		bullet.DontUsePhysBullets = true]]
		bullet.IgnoreEntity = owner
	end
	
    for i = 1, numbullet do
		local bullet = table.Copy(bullet)
		bullet.penetrated = 0
		bullet.MaxPenLen = 100
		bullet.Penetration = (ammotype.Penetration or (-(-self.Penetration))) * (self.PenetrationMultiplier or 1)
		bullet.Diameter = ammotype.Diameter or 1

		if SERVER and owner.suiciding and willsuicidereal then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(bullet.Damage)
			dmginfo:SetInflictor(self)
			dmginfo:SetAttacker(owner)
			dmginfo:SetDamageType(DMG_BULLET)
			dmginfo:SetDamageForce(dir * bullet.Force)
			dmginfo:SetDamagePosition(headpos)
			ent:TakeDamageInfo(dmginfo)
		end

		if(hg.PhysBullet and self.UsePhysBullets)then
			if(SERVER)then
				hg.PhysBullet.CreateBullet(bullet)
			end
		else
			--if owner.suiciding then bullet.DisableLagComp = true end
			self:FireLuaBullets(bullet)

			if CLIENT and !GetGlobalBool("PhysBullets_ReplaceDefault") then					
				if tr then
					local effectdata1 = EffectData()
					if tr.HitPos then effectdata1:SetOrigin(tr.HitPos) end
					if tr.StartPos then effectdata1:SetStart(pos) end
					effectdata1:SetEntity(self)
					effectdata1:SetMagnitude(1)
					util.Effect("eff_tracer", effectdata1)
				end
			end
		end
    end

	if CLIENT then
		local att = self:GetMuzzleAtt(gun, true)
		if not att then return end
		local pos, ang = att.Pos, att.Ang

		local mul = self.MuzzleMul or 1
		mul = mul * (self.Supressor and 0.25 or 1)

		if mul > 0 then
			if not self.Supressor then 
				ParticleEffect(self.PPSMuzzleEffect, pos, ang, self)
			else
				ParticleEffect(self.PPSMuzzleEffectSuppress, pos, ang, self)
			end
			hg_potatopc = hg_potatopc or hg.ConVars.potatopc
			if not hg_potatopc:GetBool() then
				local dlight = DynamicLight(self:EntIndex())
				dlight.pos = pos
				dlight.r = math_random(245, 255)
				dlight.g = math_random(245, 255)
				dlight.b = math_random(150, 200)
				dlight.brightness = math_Rand(7, 8)
				dlight.Decay = 4000
				dlight.Size = math_Rand(60, 75) * mul
				dlight.DieTime = CurTime() + 1 / 60
			end
		end
	end

	self:PostFireBullet(bullet)
end

function SWEP:PostFireBullet()
end

if CLIENT then
	net.Receive("reject shell",function()
		local ent = net.ReadEntity()
		if ent and ent.RejectShell then
			ent:RejectShell(net.ReadString())
		end
	end)

	function SWEP:RejectShell(shell)
		if not shell then return end
		local gun = self:GetWM()
		if not IsValid(gun) then return end
		local attmuzle = self:GetMuzzleAtt(gun, true)
		local att = gun:GetAttachment(gun:LookupAttachment(self.FakeEjectBrassATT or "ejectbrass")) or gun:GetAttachment(gun:LookupAttachment("shell"))
		local pos, ang
		if not att then
			pos, ang = gun:GetPos(), gun:GetAngles()
		else
			pos, ang = att.Pos, att.Ang
		end

		local _
		if self.EjectPos then pos = gun:GetPos() + ang:Right() * self.EjectPos.x + ang:Up() * self.EjectPos.z + ang:Forward() * self.EjectPos.y end
		if self.EjectAng then _,ang = LocalToWorld(vecZero,self.EjectAng,vecZero,ang) end

		local ammotype = hg.ammotypeshuy[self.Primary.Ammo].BulletSettings
		local ejectAng = attmuzle.Ang
		if self.EjectAddAng then
			_,ejectAng = LocalToWorld(vecZero,self.EjectAddAng,vecZero,attmuzle.Ang) 
		end
		if self.CustomSecShell then self:MakeShell(self.CustomSecShell, pos, ejectAng, ang:Forward() * 75) end
		if ammotype.Shell or self.CustomShell then self:MakeShell(ammotype.Shell or self.CustomShell, pos, ejectAng, ang:Forward() * 105) return end
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetAngles(ang)
		effectdata:SetFlags(25)
		util.Effect(shell, effectdata)
	end
else
	util.AddNetworkString("reject shell")
	function SWEP:RejectShell(shell)
		net.Start("reject shell")
			net.WriteEntity(self)
			net.WriteString(shell)
		net.Broadcast()
	end
end