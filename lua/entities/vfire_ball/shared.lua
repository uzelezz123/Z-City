--[[-------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

vFire by Vioxtar

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------]]

AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

function ENT:SetupDataTables()
	 -- 1 is Tiny, 7 is Inferno
	self:NetworkVar("Int", 0, "FireState")
end

--[[-------------------------------------------------------------------------
In charge of updating particle systems
---------------------------------------------------------------------------]]
if CLIENT then
	function ENT:RedoParticles(state)

		if !IsValid(self) then return end

		-- Store the state that's actually visible for consistent animations
		self.visState = state

		if self.flames then
			if self.flames:IsValid() then 
				self.flames:StopEmission()
			end
		end

		local size = vFireStateToSize(state)

		self.visLOD = false
		local LODStr = ""
		if self.LOD then
			LODStr = "_LOD"
			self.visLOD = true
		end

		self.flames = CreateParticleSystem(
			self,
			"vFire_Flames_"..size..LODStr,
			1,
			0,
			Vector(0, 0, 0)
		)
	end

	
	local pullForceControlPointIndex = 2
	-- The stateMul table defines how far to set the pull control point for each state
	-- The bigger the distance, the less effect the control point has
	local stateMul = {30, 45, 65, 115, 245, 345, 400}
	-- The minimum flame pull strength, used to avoid dividing by zero
	local minStrength = 1 / 1000000000
	-- Pulls the flames towards a direction, with an optional strength ranging between [0, 1]
	function ENT:FlameSetDirection(dir, strength)
		if IsValid(self.flames) then
			dir:Normalize()
			dir = dir * stateMul[self:GetFireState()]
			local pos
			if strength then
				pos = self:GetPos() + dir / math.Clamp(strength, minStrength, 1)
			else
				pos = self:GetPos() + dir
			end
			self.flames:SetControlPoint(pullForceControlPointIndex, pos)
		end
	end
end

if SERVER then
	--[[-------------------------------------------------------------------------
	Change life without exceeding max life
	---------------------------------------------------------------------------]]
	function ENT:ChangeLife(newLife)
		self.life = math.min(newLife, vFireMaxLife)
		self:SetFireState(vFireLifeToState(self.life))

		if self.life <= 0 then
			self:Remove()
		end
	end

	function ENT:Ignore(ent)
		self.ignore[ent] = true
	end
	function ENT:StopIgnoring(ent)
		if self.ignore[ent] then
			self.ignore[ent] = nil
		end
	end

	function ENT:RandomStickSkip()
		return math.Rand(0, 1) >= self.stickProbability
	end

	function ENT:TimedRemoval(time)

		if !time then time = math.Rand(0.3, 0.8) end

		-- Timed removal
		timer.Simple(time, function()
			if IsValid(self) then self:Remove() end
		end)
	end

	function ENT:StickFire(parent, pos, normal)

		local feedFactor = math.Rand(0.5, 1)

		timer.Simple(0, function() -- Time it to avoid changing any sort of collision rules on a collision hook
			if !IsValid(parent) and !parent:IsWorld() then return end
			if !self.feedCarry then return end
			local fire = CreateVFire(parent, pos, normal, self.feedCarry * feedFactor, self)

			if IsValid(fire) then
				fire:ChangeLife(self.life * (1 - feedFactor))
				fire:SetFireState(math.max(math.Round(1*(self.feedCarry/10),0),1))
			end
		end)

		-- Dampen the ball and add a random velocity
		--if IsValid(self) then
		--	local phys = self:GetPhysicsObject()
		--	phys:SetDamping(math.Rand(2, 8), 1)
		--	phys:AddVelocity(VectorRand() * phys:GetEnergy() * 0.002)
		--end

		self:TimedRemoval()
	end

	--[[-------------------------------------------------------------------------
	Attempt to stick to surfaces via a trace
	---------------------------------------------------------------------------]]
	function ENT:AttemptFireStick()
		local vel = self.oldVel or self:GetVelocity()
		local tr = util.QuickTrace(self:GetPos(), vel, self)
		if tr.Hit and !tr.HitSky then

			local ent = tr.Entity
			if vFireIsVFireEnt(ent) then return false end

			self:StickFire(ent, tr.HitPos, tr.HitNormal)

			return true
		end

		return false
	end

	--[[-------------------------------------------------------------------------
	Call the attempt fire stick function on touching or collisions
	---------------------------------------------------------------------------]]
	function ENT:StartTouch(ent)
		if self.stuck then return end

		-- Every third fire ball should bounce off the surface
		if self:RandomStickSkip() then return end

		if ent then
			if self.ignore[ent] or vFireIsVFireEnt(ent) then return end
		end

		-- We can completely skip the attempt itself if we're burning a character
		if vFireIsCharacter(ent) then
			self:StickFire(ent, ent:GetPos(), VectorRand())
			self.stuck = true
		else
			self.stuck = self:AttemptFireStick()
		end

		if self.stuck then
			hook.Run("vFireBallStuckFire", self, ent)
		end
	end

	function ENT:PhysicsCollide(colData, collider)
		if self.stuck then return end

		-- Every third fire ball should bounce off the surface
		if self:RandomStickSkip() then return end

		local ent = colData.HitEntity
		
		if ent then
			if self.ignore[ent] or vFireIsVFireEnt(ent) then return end
		end

		-- We can completely skip the attempt itself if we're burning a character
		if vFireIsCharacter(ent) then
			self:StickFire(ent, ent:GetPos(), VectorRand())
			self.stuck = true
		else
			self.stuck = self:AttemptFireStick()
		end
		
		if self.stuck then
			hook.Run("vFireBallStuckFire", self, ent)
		end
	end

	--[[-------------------------------------------------------------------------
	Update our old velocity to be used for correct fire stick attempts
	---------------------------------------------------------------------------]]
	function ENT:PhysicsUpdate()

		if self:WaterLevel() > 0 then
			timer.Simple(0, function()
				if IsValid(self) then
					self:Remove()
				end
			end)
		end

		if self.stuck then return end
		self.oldVel = self:GetVelocity()
	end

	--[[-------------------------------------------------------------------------
	Set the sticking probability
	---------------------------------------------------------------------------]]
	function ENT:SetStickProbability(prob)
		self.stickProbability = prob
	end
end


--[[-------------------------------------------------------------------------
Set starting parameters of a fire entity
---------------------------------------------------------------------------]]
local radius = 0.01
function ENT:Initialize()

	-- Make sure it's not directly seen
	self:DrawShadow(false)

	-- Make sure it's not directly interactable
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)


	if SERVER then
		-- The ignore table
		self.ignore = {}
		self:Ignore(self:GetOwner())

		-- What is the probability of sticking fire? Default is skip every 3rd impact
		self.stickProbability = 2/3

		-- We are essentially a small sphere
		self:PhysicsInitSphere(radius, "default_silent")

		-- Dampen ourselves
		local phys = self:GetPhysicsObject()
		phys:SetDamping(0.85, 0)
		phys:SetMass(1)
		phys:Wake()

		-- Use triggers to access the StartTouch hook
		self:SetTrigger(true)

		self:SetCollisionBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))
		self:UseTriggerBounds(true, radius)

		-- Our conditions
		self.life = 0
		self.stuck = false
		self.feedCarry = 0
	end

	if CLIENT then
		local state = 1
		self.lastState = 1
		self.visState = 1

		self.LOD = false
		self.visLOD = false
	
		-- Start working
		self:RedoParticles(1)
		self:Think()
	end
end


--[[-------------------------------------------------------------------------
Remove ourselves from needed tables
---------------------------------------------------------------------------]]
function ENT:OnRemove()
	-- This may not be necessary, but just in case: destroy all particle systems
	if CLIENT then
		if self.flames then
			if self.flames:IsValid() then self.flames:StopEmission() end
		end
		if self.base then
			if self.base:IsValid() then self.base:StopEmission() end
		end
	end
end

--[[-------------------------------------------------------------------------
Handles life, spreads, feeds, decal placement, networking and calling new particle system updates
---------------------------------------------------------------------------]]
local serverTickRate = 0.2
local clientTickRate = 0.3
function ENT:Think()

	if CLIENT then

		self.LOD = vFireGetLOD(self)

		local shouldRedoParticles = false

		-- Handle state changes
		local lastState = self.lastState
		local state = self:GetFireState()
		self.lastState = state
		if state != lastState then -- We changed states
	
			shouldRedoParticles = true
			
			-- Make sure we'll always draw ourselves
			local renderSize = state * 20
			self:SetRenderBounds(Vector(0, 0, 0), Vector(0, 0, 0), Vector(renderSize, renderSize, renderSize))

			self:FlameSetDirection(self:GetVelocity(), 1)

		end

		local LODActive = false
		if self.LOD then LODActive = true end

		if LODActive != self.visLOD then
			shouldRedoParticles = true
		end

		if shouldRedoParticles and self.RedoParticles then
			self:RedoParticles(state)
		end


	end

	if SERVER then

		-- Decrease life
		self:ChangeLife(self.life - 1)


	end

	if SERVER then self:NextThink(CurTime() + serverTickRate) end
	if CLIENT then self:SetNextClientThink(CurTime() + clientTickRate) end

	return true -- We wish to override ticking rate
end


if CLIENT then
	function ENT:Draw()
		-- Do nothing
	end
end