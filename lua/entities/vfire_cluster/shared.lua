--[[-------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

vFire by Vioxtar

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------]]

AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

--[[-------------------------------------------------------------------------
Some helper functions because Set/Get LocalPos() can't handle world parents
---------------------------------------------------------------------------]]
local function GetRelPos(v)
	if v.parent:IsWorld() then
		return v:GetPos()
	else
		return v:GetLocalPos()
	end
end

local function SetRelPos(v, pos)
	if v.parent:IsWorld() then
		v:SetPos(pos)
	else
		v:SetLocalPos(pos)
	end
end


--[[-------------------------------------------------------------------------
Add a fire to the cluster
---------------------------------------------------------------------------]]
function ENT:AddFire(fire)
	-- Are we on the same parent?
	if !IsValid(fire) or fire.parent != self.parent then return end

	-- Do we already have the fire?
	if self.fires[fire] then return end

	-- Does the fire already have a cluster?
	local cluster = fire:GetNW2Entity("FireCluster")
	if IsValid(cluster) then
		cluster:RemFire(fire)
	end

	-- Add the fire
	self.fires[fire] = fire
	fire.cluster = self

	-- Update position
	if self.cnt == 0 then
		SetRelPos(self, GetRelPos(fire))
	else
		local p = GetRelPos(self)
		p = (p * self.cnt + GetRelPos(fire)) / (self.cnt + 1)
		SetRelPos(self, p)
	end
	if !self.parent.fireClusters then
		self.parent.fireClusters = {}
		hook.Run("vFireEntityStartedBurning", self.parent)
	end
	if self.parent.fireClusters then
		self.parent.fireClusters[self] = GetRelPos(self)
	end
	
	-- Increment count
	self.cnt = self.cnt + 1

	-- Network the change
	if SERVER then fire:SetNW2Entity("FireCluster", self) end

	-- Memorize distances for all current fires, remember closest fires
	local minDist = math.huge
	local closestFire

	local minDistSmaller = math.huge
	local closestFireSmaller

	local minDistBigger = math.huge
	local closestFireBigger

	self.distMem[fire] = {}
	for k, fire2 in pairs(self.fires) do
		if !IsValid(fire2) then continue end
		local dist = 0
		if fire != fire2 then
			dist = fire:GetPos():Distance(fire2:GetPos())
			if dist < minDist then
				minDist = dist
				closestFire = fire2
			end
			if dist < minDistSmaller then
				minDistSmaller = dist
				closestFireSmaller = fire2
			end
			if dist < minDistBigger then
				minDistBigger = dist
				closestFireBigger = fire2
			end
		end
		self.distMem[fire][fire2] = dist
		self.distMem[fire2][fire] = dist
	end

	-- Use the oppurtunity to set the closest fire
	fire.closestFire = closestFire
	fire.closestSmallerFire = closestFireSmaller
	fire.closestBiggerFire = closestFireBigger

end


--[[-------------------------------------------------------------------------
Remove a fire from the cluster, likely to never be called but who knows
---------------------------------------------------------------------------]]
function ENT:RemFire(fire)
	-- Is the fire still valid?
	if !IsValid(fire) then return end

	-- Do we actually have it?
	if !self.fires[fire] then return end

	-- Remove if this is our last fire
	if self.cnt - 1 <= 0 then
		if SERVER then self:Remove() end
		return
	end

	-- Remove the fire
	self.fires[fire] = nil
	fire.cluster = nil

	-- Update position
	local p = GetRelPos(self)
	p = (p * self.cnt - GetRelPos(fire)) / (self.cnt - 1)
	SetRelPos(self, p)
	if IsValid(self.parent) and self.parent.fireClusters then
		self.parent.fireClusters[self] = GetRelPos(self)
	end

	-- Decrement count
	self.cnt = self.cnt - 1

	-- Remove the fire from the distance memorization table
	self.distMem[fire] = nil
	for k, fire2 in pairs(self.fires) do
		self.distMem[fire2][fire] = nil
	end
end

-- A function similar to think dedicated to checking wind flow via timers
local windExposureCheckTime = 45
function ENT:CalcWindExposure()
	self.windExposure = 1
end

if SERVER then
	local pvsLODCheckTime = 100
	function ENT:CalcPVSLOD()
		for k, ply in pairs(player.GetAll()) do
			self.PVSLOD = self:TestPVS(ply:GetPos())
			if self.PVSLOD then
				-- One is enough
				break
			end
			-- Otherwise continue to check all of the other players
		end
		timer.Simple(pvsLODCheckTime, function()
			if IsValid(self) then
				self:CalcPVSLOD()
			end
		end)
	end
end


function ENT:Initialize()
	if not IsValid(self) then return end
	-- Obtain the parent
	local parent = self:GetNW2Entity("ClusterParent")
	if SERVER then
		if !IsValid(parent) and !parent:IsWorld() then
			self:Remove()
			return
		end
	end

	-- Set the parent if it's valid (and not the world)
	if IsValid(parent) then self:SetParent(parent) end
	-- Store the parent internally
	self.parent = parent

	-- Don't draw ourselves, don't collide with anything
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	self.fires = {}
	self.cnt = 0

	-- Start a timed checkup for wind exposure
	self:CalcWindExposure()

	if SERVER then
		-- Start a timed PVS test for calculation LOD purposes
		self:CalcPVSLOD()
	end

	if CLIENT then

		local soundName = table.Random(list.Get("vFireLoopSounds"))

		self.sound = CreateSound(self, soundName)
		self.sound:PlayEx(0.4, 100)
		self.sound:SetSoundLevel(180, 0.1)

		self.LOD = false
	end

	-- Use a distance memorization table for optimization purposes of all fires
	self.distMem = {}
end



if CLIENT then
	function ENT:GetClusterMagnitude()
		local maxState = 0
		for k, fire in pairs(self.fires) do
			if IsValid(fire) then
				local state = fire:GetFireState()
				if state > maxState then
					maxState = state
				end
			end
		end

		return math.Min(maxState * 0.2, 1)
	end

	local clientTickRate = 3
	function ENT:Think()
		self.LOD = vFireGetLOD(self)

		if !self.LOD then

			local clusterMagnitude = self:GetClusterMagnitude()

			self.sound:ChangeVolume(clusterMagnitude, clientTickRate)
			self.sound:ChangePitch(120 - 40 * clusterMagnitude, clientTickRate)
		end

		self:SetNextClientThink(CurTime() + clientTickRate)
		return true -- We wish to override ticking rate
	end
end

function ENT:OnRemove()
	if CLIENT then
		-- Stop the sound
		local snd = self.sound
		-- We have to loop until it's stopped for some reason...
		local stopAttempts = 1
		while snd:IsPlaying() and stopAttempts <= 50 do
			snd:Stop()
			stopAttempts = stopAttempts + 1
		end
	end


	if SERVER then
		-- Workaround: this is done to prevent a weird error that places cluster at bad origins on removal
		-- the error does no harm, but it spams the console
		self:SetPos(Vector())
	end


	local parent = self.parent
	if parent == nil then
		hook.Run("vFireEntityStoppedBurning", parent)
		return
	end
	if !IsValid(parent) and !parent:IsWorld() then
		hook.Run("vFireEntityStoppedBurning", parent)
		return
	end

	-- Remove ourselves from the parent's clusters table
	if parent.fireClusters then
		parent.fireClusters[self] = nil
		if table.Count(parent.fireClusters) <= 0 then
			hook.Run("vFireEntityStoppedBurning", parent)
			parent.fireClusters = nil
		end
	end
end