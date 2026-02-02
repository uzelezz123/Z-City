AddCSLuaFile()
--
function SWEP:Initialize_Spray()
	self.EyeSpray = Angle(0, 0, 0)
	self.SprayI = 0
	self.dmgStack = 0
	self.dmgStack2 = 0
end

SWEP.SpreadMulZoom = 1.5
SWEP.SpreadMul = 2
SWEP.CrouchMul = 0.75
SWEP.Spray = {}
for i = 1, 150 do
	SWEP.Spray[i] = Angle(-0.02 - math.cos(i) * 0.01, math.cos(i * i) * 0.01, 0)
end

SWEP.SprayRand = {Angle(0, 0, 0), Angle(0, 0, 0)}
SWEP.addSprayMul = 1

SWEP.RecoilMul = 0.8

local cos, sin, math_max, math_min = math.cos, math.sin, math.max, math.min
function SWEP:GetPrimaryMul()
	local owner = self:GetOwner()
	local mul = ((0.5) + math_max(self.Primary.Force / 110 - 1, 0)) * (owner.Crouching and owner:Crouching() and self.CrouchMul or 1) * (self.attachments and self.attachments.barrel and self.attachments.barrel[1] ~= "empty" and 0.75 or 1)
	self:ApplyForce(mul)
	mul = (mul or 0) * (self.Supressor and 0.75 or 1) * (owner.organism and owner.organism.recoilmul or 1)
	return mul
end

SWEP.sprayAngles = Angle(0,0,0)

SWEP.weaponSway = Angle(0,0,0)

function SWEP:PrimarySpread()
	self.Primary.Force2 = (hg.ammotypeshuy[self.Primary.Ammo] and hg.ammotypeshuy[self.Primary.Ammo].BulletSettings and hg.ammotypeshuy[self.Primary.Ammo].BulletSettings.Force) or self.Primary.Force
	self:SetLastShootTime(CurTime())
	self.lastShoot = RealTime()--SysTime()
	
	local owner = self:GetOwner()

	if not IsValid(owner) then return end

	local mul = self:GetPrimaryMul()
	self.SprayI = self.SprayI + 1
	self.dmgStack = self.dmgStack + self.Primary.Damage
	self.dmgStack2 = math.min(self.dmgStack2 + 0.2, 60)
	local sprayI = self.SprayI
	
	if SERVER then
		if owner:IsNPC() then return end
		local org = owner.organism
		if org then
			org.painadd = org.painadd + (org.larm * 0 + org.rarm * 2) * self.Primary.Force / 20 * (self.NumBullet or 1)
		end
	end

	if CLIENT and (owner == LocalPlayer() or (not LocalPlayer():Alive() and owner == LocalPlayer():GetNWEntity("spect"))) and !self.norecoil then
		local organism = owner.organism or {}
		
		local force = self.Primary.Damage / 100 * self.addSprayMul * (self.NumBullet or 1) * math.min(sprayI / 30,0.6)--(self.Primary.Automatic and math.min(sprayI / 30,1) or 1)
		mul = mul * (((organism.larm or 0) + (organism.rarm or 0) + 2) / 1 + ((organism.larmamputated and 5 or 0) + (organism.rarmamputated and 5 or 0)))
		mul = mul * ((owner.posture == 7 or owner.posture == 8 or owner.holdingWeapon) and 2 or 1)
		mul = mul * self.RecoilMul
		mul = mul * (owner:Crouching() and 0.75 or 1)
		--mul = mul * (hg.IsOnGround(hg.GetCurrentCharacter(owner)) and 1 or 5)
		mul = mul * (self:IsResting() and 0.1 or 1)

		local angRand = AngleRand(0.03, 0.05)
		angRand[1] = -math.abs(angRand[1])
		angRand[2] = (math.random(2) == 1 and 1 or -1) * angRand[2]
		angRand[3] = 0
		local spray

		if sprayI < 3 then
			spray = angRand
		else
			spray = self.Spray[sprayI] or Angle(0.01, 0)
		end
		
		local angranda = AngleRand(self.SprayRand[1], self.SprayRand[2])
		angranda[3] = 0
		spray = spray + angranda * self.addSprayMul * mul * (self.randmul or 1)

		local angrand2 = AngleRand(-force, force)
		
		local angrand3 = -(-angrand2)
		angrand3[3] = 0
		if not self.SprayRandOnly then
			angrand2[1] = math.Clamp(-math.abs(angrand2[1]),-10,-force/1.5)
			angrand2[2] = math.Clamp(angrand2[2],-1,1)
			angrand2[3] = -angrand2[2] * 1
			local mulhuy = GetGlobalBool("FullRealismMode",false) and 10 or 1
			mul = mul * (self.attachments and self.attachments.grip and not table.IsEmpty(self.attachments.grip) and hg.attachments.grip[self.attachments.grip[1]].recoilReduction or 1)
			
			local huyang = angrand2 * mul / 2 * mulhuy
			huyang[3] = 0
			ViewPunch2(huyang * (owner.posture == 1 and not self:IsZoom() and 3 or 1) * 0.25)-- ^ ((not self.Primary.Automatic and 0.5 or 1)))
			
			local angpopa = angrand2 * mul
			angpopa[3] = 0
			ViewPunch(angpopa)-- ^ ((not self.Primary.Automatic and 0.5 or 1)))
			spray = spray + angRand * 2 * (self.randmul or 1)
		end

		local prank3 = math.Rand(-self.Primary.Force2,self.Primary.Force2) / (self.Primary.Force2 != 0 and self.Primary.Force2 or 1) * 2
		local angleprikol = Angle(0,0,prank3)

		//ViewPunch2(angleprikol)

		local mul = mul * self.Primary.Force2 / 100 * (self:IsPistolHoldType() and 2 or 1) * (self.NumBullet and self.NumBullet * 3 or 1)
		ViewPunch2(Angle(-1 * math.Rand(1,2),-1 * math.Rand(-1,1),0) * mul)
		ViewPunch(Angle(-1 * math.Rand(1,2),-1 * math.Rand(-1,1),0) * mul / -2)
		timer.Simple(0.01, function() ViewPunch2(Angle(-1 * math.Rand(1,2),1 * math.Rand(-1,1),0) * mul) end)
		timer.Simple(0.02, function() ViewPunch2(Angle(1 * math.Rand(1,2.4),0,0) * mul) end)
		
		local sprayAng = spray * (self:IsResting() and 0.1 or 1) * 8 + angrand3 * self.addSprayMul
		sprayAng[3] = 0

		owner:SetEyeAngles(owner:EyeAngles() + sprayAng * 3 * (organism.recoilmul or 1) * (owner.posture == 1 and not self:IsZoom() and 0.1 or 1) * 0.25)
		
		local rnd1, rnd2 = math.Rand(1,2), math.Rand(-1,1)
		ViewPunch2(Angle(2 * rnd1,2 * rnd2,0) * mul * 0.5)
		ViewPunch(Angle(-2 * rnd1,-2 *rnd2,0) * mul)

		local max_clip1 = self:GetMaxClip1()
		
		if(max_clip1 == 0)then
			max_clip1 = 1
		end
		
		local sprayvel = spray * mul * math.max(sprayI / max_clip1, 0.5) * self.addSprayMul * (self.cameraShakeMul or 1) * 10 * 1.2//(self.Primary.Automatic and 1 or 1)
		
		--self.weaponSway = self.weaponSway + sprayvel

		self.sprayAngles[3] = self.sprayAngles[3] + math.max(self.Primary.Damage / 100,1) * self.addSprayMul * (self.cameraShakeMul or 1) * ((((self.NumBullet or 1) - 1) / 2) + 1) * (((self.podkid or 1) - 1) / 3 + 1) / 40

		self:ApplyEyeSprayVel(sprayvel * 1)
		--self:AnimApply_RecoilCameraZoom()
	end
end

function SWEP:ApplyForce(mul)
	//mul = mul * self.Primary.Damage / 60 * (self.NumBullet or 1)
	local ply = self:GetOwner()

	if IsValid(ply.FakeRagdoll) then
		if SERVER then
			local ent = ply.FakeRagdoll
			local phys = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Hand")))
			local tr, pos, ang = self:GetTrace(nil, nil, nil, true)
			local dir = ang:Forward()
			phys:ApplyForceCenter(-dir * self.Primary.Force * 5)
		end

		return true
	end
end

--if CLIENT then
local angZero = Angle(0, 0, 0)
function SWEP:ApplyEyeSprayVel(value)
	self.EyeSprayVel = self.EyeSprayVel + value * 0.2
	self:ApplyEyeSpray(self.EyeSprayVel)
	--self.AdditionalAng = self.AdditionalAng + Angle(-math.Rand(self.EyeSprayVel[1] * 1 ,self.EyeSprayVel[1] * 2),math.Rand(self.EyeSprayVel[2] * 2 ,self.EyeSprayVel[2] * 5),-self.EyeSprayVel[2] * 10)
	--self.AdditionalPos[1] = self.AdditionalPos[1] + self.EyeSprayVel[1] * 15
end

function SWEP:Step_SprayVel(dtime)
	self.EyeSprayVel = self.EyeSprayVel or Angle(0, 0, 0)
	self.EyeSprayVel = self.EyeSprayVel - self.EyeSprayVel * hg.lerpFrameTime2(0.95,dtime)--self.EyeSpray * 0.04
	self:ApplyEyeSpray(self.EyeSprayVel)
end

function SWEP:ApplyEyeSpray(value)
	if CLIENT and self:GetOwner() ~= LocalPlayer() then return end
	self.EyeSpray = self.EyeSpray + value * 0.2 * (FrameTime() / engine.TickInterval())
end

function SWEP:Step_Spray(time,dtime)
	if self.Primary.Next + 0.3 < time then self.SprayI = 0 end
	
	if SERVER then return end
	local eyeSpray = self.EyeSpray
	self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + eyeSpray)
	eyeSpray:Set(LerpAngle(hg.lerpFrameTime2(0.1,dtime), eyeSpray, angZero))
end

--[[else
	function SWEP:ApplyEyeSpray(value) end
	function SWEP:ApplyEyeSprayVel(value) end
end--]]
SWEP.ZoomFOV = 20
function SWEP:AdjustMouseSensitivity()
	--return self:IsZoom() and self:HasAttachment("sight") and (math.min(self.ZoomFOV / 10, 0.5) or 0.5) or 1
end