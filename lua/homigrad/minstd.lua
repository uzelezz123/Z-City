local floor = math.floor
local sqrt = math.sqrt
local log = math.log

--module("minstd")

local MINSTD = {}
MINSTD.__index = MINSTD

-- MINSTD parameters
local NTAB = 32

local IA = 16807
local IM = 2147483647 -- 0x7FFFFFFF
local IQ = 127773
local IR = 2836
local AM = 1 / IM
local NDIV = floor(1 + (IM - 1) / NTAB)

function MINSTD:SetSeed(iSeed)
	self.m_iDum = iSeed < 0 and iSeed or -iSeed
	self.m_iY = 0
end

-- Modified Lehmer random number generator
-- Returns integer [1, IM)
function MINSTD:RandomNumber()	
	if (self.m_iDum <= 0 or self.m_iY == 0) then
		if (self.m_iDum > -1) then -- (-1, 0)
			self.m_iDum = 1
		else
			self.m_iDum = -self.m_iDum
		end

		for i = NTAB + 8, 1, -1 do
			local j = floor(self.m_iDum / IQ)

			self.m_iDum = IA * (self.m_iDum - j * IQ) - IR * j

			if (self.m_iDum < 0) then
				self.m_iDum = self.m_iDum + IM
			end

			if (i <= NTAB) then
				self.m_tV[i] = self.m_iDum
			end
		end

		self.m_iY = self.m_tV[1]
	end

	local j = floor(self.m_iDum / IQ)

	self.m_iDum = IA * (self.m_iDum - j * IQ) - IR * j

	if (self.m_iDum < 0) then
		self.m_iDum = self.m_iDum + IM
	end

	j = floor(self.m_iY / NDIV)

	self.m_iY = self.m_tV[j + 1]
	self.m_tV[j + 1] = self.m_iDum

	return self.m_iY
end

-- Returns float [flMin, flMax)
function MINSTD:RandomFloat(flMin --[[= 0]], flMax --[[= 1]], flExponent --[[= 1]])
	if (flMin == nil) then
		flMin = 0
	end

	if (flMax == nil) then
		flMax = 1
	end

	assert(flMin <= flMax, "Min limit is greater than max!")

	-- float in [AM, 1)
	local fl = AM * self:RandomNumber()

	-- MINSTD is not widely distributed enough to go past float limits
	-- So the min value has to be set to 0
	if (fl == AM) then
		fl = 0
	end

	return fl ^ (flExponent or 1) * (flMax - flMin) + flMin
end

-- Returns integer [iMin, iMax]
-- Difference between iMin and iMax must be [0, IM]
function MINSTD:RandomInt(iMin --[[= 0]], iMax --[[= 1]])
	if (iMin == nil) then
		iMin = 0
	else
		iMin = floor(iMin)
	end

	if (iMax == nil) then
		iMax = 1
	else
		iMax = floor(iMax)
	end

	assert(iMin <= iMax, "Min limit is greater than max!")

	local x = iMax - iMin + 1
	assert(IM >= x - 1, "Min and max difference is too large for implementation")

	-- The following maps a uniform distribution on the interval [0, IM]
	-- to a smaller, client-specified range of [0, x - 1] in a way that doesn't bias
	-- the uniform distribution unfavorably. Even for a worst case x, the loop is
	-- guaranteed to be taken no more than half the time, so for that worst case x,
	-- the average number of times through the loop is 2. For cases where x is
	-- much smaller than IM, the average number of times through the
	-- loop is very close to 1
	local iMaxAcceptable = IM - (IM + 1) % x 
	local n

	repeat
		n = self:RandomNumber()
	until (n <= iMaxAcceptable)

	return iMin + n % x
end

-- Implementation of the gaussian random number stream
-- We're gonna use the Box-Muller method (which actually generates 2
-- gaussian-distributed numbers at once)
function MINSTD:RandomGaussianFloat(flMean --[[= 0]], flStdDev --[[= 1]])
	if (self.m_bHaveValue) then
		self.m_bHaveValue = false

		return (flStdDev or 1) * self.m_flRandomValue + (flMean or 0)
	end

	-- Pick 2 random #s from -1 to 1
	-- Make sure they lie inside the unit circle. If they don't, try again
	local v1
	local v2
	local rsq

	repeat
		v1 = 2 * self:RandomFloat(0, 1) - 1
		v2 = 2 * self:RandomFloat(0, 1) - 1
		rsq = v1 * v1 + v2 * v2
	until (rsq <= 1 and rsq ~= 0)

	-- The box-muller transformation to get the two gaussian numbers
	local fac = sqrt(-2 * log(rsq) / rsq)

	-- Store off one value for later use
	self.m_flRandomValue = v1 * fac
	self.m_bHaveValue = true

	return (flStdDev or 1) * (v2 * fac) + (flMean or 0)
end

return setmetatable({
	m_iDum = 0,
	m_iY = 0,
	m_tV = {},
	m_bHaveValue = false,
	m_flRandomValue = 0
}, MINSTD)
