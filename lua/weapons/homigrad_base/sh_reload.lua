AddCSLuaFile()
--
function SWEP:Initialize_Reload()
	self.LastReload = 0
end

SWEP.dwr_customVolume = 1
SWEP.OpenBolt = false
SWEP.Notified = false
function SWEP:CanReload()
	local ply = self:GetOwner()
	if self:LastShootTime() + 0.1 > CurTime() then return end
	if IsValid(ply:GetNetVar("carryent2")) then
		if SERVER then
			local ent = ply:GetNetVar("carryent2")
			ply:SetNetVar("carryent2",NULL)
			ply:SetNetVar("carrybone2",nil)
			ply:SetNetVar("carrymass2",0)
			ply:SetNetVar("carrypos2",nil)
			heldents[ent:EntIndex()] = nil
		end
	end

	if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then
		if not self.Notified and self:Clip1() < self:GetMaxClip1() then
			ply:Notify("I can't reload it in my hand...", 10)
			self.Notified = true
		end
		return false
	end

	if !ply.GetAmmoCount then return true end
	
	if self.ReloadNext or not self:CanUse() or ply:GetAmmoCount(self:GetPrimaryAmmoType()) == 0 or self:Clip1() >= self:GetMaxClip1() + (self.drawBullet and not self.OpenBolt and 1 or 0) then --shit
		return
	end

	return true
end

if SERVER then
	util.AddNetworkString("hg_insertAmmo")
end

function SWEP:InsertAmmo(need)
	local owner = self:GetOwner()
	local primaryAmmo = self:GetPrimaryAmmoType()
	if !owner.GetAmmoCount then return end
	local primaryAmmoCount = owner:GetAmmoCount(primaryAmmo)
	need = need or self:GetMaxClip1() - self:Clip1()
	need = math.min(primaryAmmoCount, need)
	need = math.min(need, self:GetMaxClip1())
	self:SetClip1(self:Clip1() + need)
	owner:SetAmmo(primaryAmmoCount - need, primaryAmmo)

	if SERVER then
		net.Start("hg_insertAmmo")
			net.WriteEntity(self)
			net.WriteInt(self:Clip1(),10)
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive("hg_insertAmmo",function()
		local ent = net.ReadEntity()
		local ammo = net.ReadInt(10)

		if IsValid(ent) then
			ent:SetClip1(ammo)
			ent.reload = nil
			ent.countevent = nil
			ent:ReloadEnd()
			ent.FakeSoundPlayed = nil
			ent.FakeEventPlayed = nil
		end
	end)
end

SWEP.ReloadCooldown = 0.1
local math_min = math.min
function SWEP:ReloadEnd()
	--if not self.CustomAmmoInsertEvent then
	self:InsertAmmo(self:GetMaxClip1() - self:Clip1() + (self.drawBullet ~= nil and not self.OpenBolt and 1 or 0))
	--end
	self.ReloadNext = CurTime() + self.ReloadCooldown --я хуй знает чо это
	self:Draw()
end

SWEP.FakeReloadEvents = {
	--[0.3] = function( self ) end,
}

function SWEP:MapEvents()
	self.FakeReloadEventsMap = {}
	local tbl = table.Flip(self.FakeReloadEvents)
	table.RemoveByValue(tbl, "BaseClass")
	for event, time in SortedPairsByValue(tbl) do
		table.insert(self.FakeReloadEventsMap, time)
	end
end

hook.Add("OnReloadedWep", "changeeventmap", function(self)
	self:MapEvents()
end)

function SWEP:Step_Reload(time)
	if self:KeyDown(IN_WALK) and self:KeyDown(IN_RELOAD) then
		self.checkingammo = true
	else
		self.checkingammo = false
	end

	local time2 = self.reload and self.reload - 0.05
	
	if time2 and time2 < time then
		self.reload = nil
		self.countevent = nil
		self:ReloadEnd()
		self.FakeSoundPlayed = nil
		self.FakeEventPlayed = nil
	else
		self:ClearAnims()
	end

	if time2 then
		local part = 1.15 - (time2 - time) / self.StaminaReloadTime
		--print(self.StaminaReloadTime)
		local shouldalreadyreload
		if SERVER then
			//shouldalreadyreload = self:ReloadSounds(part)
			self:ReloadSounds(part)
		end

		if self:ShouldUseFakeModel() and IsValid(self:GetWM()) then
			if not self.countevent then self.countevent = 1 end
			local time = math.max(math.Round(part,2),0.15)
			if self.GetDebug then
				self:GetOwner():PrintMessage( 4,tostring(time) )
			end
			//local nextTimeEvent = self.FakeReloadEventsMap[self.countevent]
			//local event = self.FakeReloadEvents[nextTimeEvent]
			local event = self.FakeReloadEvents[time]
			--print(self.FakeReloadEvents[time])
			//if event and nextTimeEvent < time and self.FakeEventPlayed ~= event then
			if event and self.FakeEventPlayed ~= event then
				event( self, self.StaminaReloadMul )
				self.FakeEventPlayed = event
				self.countevent = self.countevent + 1
			end
		end
		
		part = math.ease.InOutQuad(part)

		if self:AnimationReload(part, self.StaminaReloadTime) or shouldalreadyreload then
			time2 = nil
			self.reload = nil
			self.countevent = nil
			self:ReloadEnd()
		end
	end

	time2 = self.ReloadNext
	if time2 and time2 < time then
		self.ReloadNext = nil
		self.dwr_reverbDisable = nil
	end
end

SWEP.ReloadAnimLH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0)
}

SWEP.ReloadSlideAnim = {
	0,
}

SWEP.WepAngOffset = Angle(0,0,0)
SWEP.ReloadSlideOffset = 0

local vecZero,angZero = Vector(0,0,0),Angle(0,0,0)

SWEP.vel = Vector(0,0,0)
SWEP.vel2 = Vector(0,0,0)
SWEP.angvel = Angle(0,0,0)

function SWEP:ClearAnims()
	if not self.reload and not self.inspect then
		local deltatime = FrameTime()
		local lerp = hg.lerpFrameTime2(0.1,deltatime)

		if not self.LHPosOffset:IsEqualTol(vecZero, 0.1) then self.LHPosOffset = Lerp(lerp,self.LHPosOffset,vecZero) end
		if not self.LHAngOffset:IsEqualTol(angZero, 0.1) then self.LHAngOffset = Lerp(lerp,self.LHAngOffset,angZero) end
		
		if not self.inanim then
			if not self.RHPosOffset:IsEqualTol(vecZero, 0.1) then self.RHPosOffset = Lerp(lerp,self.RHPosOffset,vecZero) end
			if not self.RHAngOffset:IsEqualTol(angZero, 0.1) then self.RHAngOffset = Lerp(lerp,self.RHAngOffset,angZero) end
		end

		if not self.WepAngOffset:IsEqualTol(vecZero, 0.1) then
			self.WepAngOffset = Lerp(lerp,self.WepAngOffset,angZero)
		else
			self.WepAngOffset:Set(angZero)
		end

		self.ReloadSlideOffset = Lerp(FrameTime()*15,self.ReloadSlideOffset,0)

		if not self.WepAngOffset:IsEqualTol(vecZero, 0.1) then
			self.angvel = Lerp(deltatime,self.angvel,angZero)
		else
			self.angvel:Set(angZero)
		end
		
		self.SndReloadCD = 0
	end
end

local function easedLerp(fraction, from, to)
	return Lerp(math.ease.InOutSine(fraction), from, to)
end

function SWEP:AnimationReload(time, staminaReload)
	if self:ShouldUseFakeModel() then
		return
	end
	
	local wep = self--weapons.GetStored( self:GetClass() )
	
	local anims = wep.ReloadAnimLH
	local anims2 = wep.ReloadAnimLHAng
	local floortime = math.floor(time * (#anims))
	local floortime2 = math.floor(time * (#anims2))
	local lerp = time * (#anims) - floortime
	local lerp2 = time * (#anims2) - floortime2
	
	local pos1,pos2 = anims[math.Clamp(floortime,1,#anims)],anims[math.Clamp(floortime+1,1,#anims)]
	
	if pos2 == "fastreload" then
		if self:Clip1() > 0 then
			self:ClearAnims()
			return true
		else
			pos2 = anims[math.Clamp(floortime+2,1,#anims)]
		end
	elseif pos1 == "fastreload" then
		if self:Clip1() > 0 then
			self:ClearAnims()
			return true
		else
			pos1 = anims[math.Clamp(floortime+1,1,#anims)]
		end
	elseif pos2 == "reloadend" then
		self:ClearAnims()
		return true
	elseif pos1 == "reloadend" then
		self:ClearAnims()
		return true
	end

	--// Prodecural reload magazine stuff
	if pos1 == "removemag" and self.ProceduralMagMethod then
		local method, rem = self.ProceduralMagMethod, self.ProceduralMagSets["remove"]
		local wm = self:GetWM()

		if method == 0 then --// Single bodygroup
			wm:SetBodygroup(self.ProceduralMagID or 1, rem or 1)
		elseif method == 1 then --// Set of bodygroups
			wm:SetBodyGroups(tostring(rem) or "1111")
		elseif method == 2 then --// Submaterial method
			wm:SetSubMaterial(self.ProceduralMagID or 1, tostring(rem) or "null")
		end

		--pos1 = anims[math.Clamp(floortime+1,1,#anims)]
	elseif pos1 == "returnmag" and self.ProceduralMagID and istable(self.ProceduralMagSets) then
		local method, ret = self.ProceduralMagMethod, self.ProceduralMagSets["return"]
		local wm = self:GetWM()

		if method == 0 then --// Single bodygroup
			wm:SetBodygroup(self.ProceduralMagID or 1, ret or 0)
		elseif method == 1 then --// Set of bodygroups
			wm:SetBodyGroups(tostring(ret) or "0000")
		elseif method == 2 then --// Submaterial method
			wm:SetSubMaterial(self.ProceduralMagID or 1, tostring(ret) or "")
		end

		--pos1 = anims[math.Clamp(floortime+1,1,#anims)]
	end

	--print(pos1, pos2)

	if isstring(pos1) or isstring(pos2) then
		pos1,pos2 = anims[math.Clamp(floortime,1,#anims)], anims[math.Clamp(floortime+1,1,#anims)]
	else
		self.LHPosOffset = easedLerp(lerp,pos1,pos2)
	end

	self.LHAngOffset = easedLerp(lerp2,anims2[math.Clamp(floortime2,1,#anims2)],anims2[math.Clamp(floortime2+1,1,#anims2)])

	local anims = wep.ReloadAnimRH
	local anims2 = wep.ReloadAnimRHAng
	local floortime = math.floor(time * (#anims))
	local floortime2 = math.floor(time * (#anims2))
	local lerp = time * (#anims) - floortime
	local lerp2 = time * (#anims2) - floortime2
	
	local pos1,pos2 = anims[math.Clamp(floortime,1,#anims)],anims[math.Clamp(floortime+1,1,#anims)]

	if pos2 == "fastreload" then
		if self:Clip1() > 0 then
			self:ClearAnims()
			return true
		else
			pos2 = anims[math.Clamp(floortime+2,1,#anims)]
		end
	elseif pos1 == "fastreload" then
		if self:Clip1() > 0 then
			self:ClearAnims()
			return true
		else
			pos1 = anims[math.Clamp(floortime+1,1,#anims)]
		end
	elseif pos2 == "reloadend" then
		self:ClearAnims()
		return true
	elseif pos1 == "reloadend" then
		self:ClearAnims()
		return true
	end

	self.RHPosOffset = easedLerp(lerp,pos1,pos2)

	self.RHAngOffset = easedLerp(lerp2,anims2[math.Clamp(floortime2,1,#anims2)],anims2[math.Clamp(floortime2+1,1,#anims2)])

	local anims2 = wep.ReloadAnimWepAng
	local floortime2 = math.floor(time * (#anims2))
	local lerp2 = time * (#anims2) - floortime2

	--self.WepPosOffset = Lerp(lerp,anims[math.Clamp(floortime,1,#anims)],anims[math.Clamp(floortime+1,1,#anims)])
	local ang1,ang2 = anims2[math.Clamp(floortime2,1,#anims2)],anims2[math.Clamp(floortime2+1,1,#anims2)]
	
	local oldang = -(-self.WepAngOffset)
	
	self.WepAngOffset = easedLerp(lerp2,ang1,ang2) + self.angvel

	--self.angvel:Add((self.WepAngOffset-oldang)/2)
	--self.angvel = self.angvel * 0.99
	if CLIENT and self:GetOwner() == LocalPlayer() and self.reload then
		local addang = (self.WepAngOffset-oldang)/12
		addang[3] = addang[3] / 12
		ViewPunch2(addang)
		ViewPunch(addang)
	end

	local anims2 = wep.ReloadSlideAnim
	local floortime2 = math.floor(time * (#anims2))
	local lerp2 = time * (#anims2) - floortime2
	local num1,num2 = anims2[math.Clamp(floortime2,1,#anims2)],anims2[math.Clamp(floortime2+1,1,#anims2)]
	
	
	self.ReloadSlideOffset = easedLerp(lerp2,num1,num2)
end

SWEP.ReloadSoundes = {
	"none"
}
SWEP.SndReloadCD = 0

SWEP.FakeReloadSounds = {
	--[0.3] = "weapons/m4a1/m4a1_magout.wav",
}

SWEP.FakeEmptyReloadSounds = {
	--[0.22] = "weapons/m4a1/m4a1_magrelease.wav",
	--[0.25] = "weapons/m4a1/m4a1_magout.wav",
	--[0.65] = "weapons/m4a1/m4a1_magain.wav",
	--[0.77] = "weapons/m4a1/m4a1_hit.wav",
	--[0.94] = "weapons/m4a1/m4a1_boltarelease.wav",
}

function SWEP:FakeReloadFunctions()

end

function SWEP:ReloadSounds(time)
	if self:ShouldUseFakeModel() then
		local time = math.Round(time,2)

		local sound_tbl = self:Clip1() == 0 and self.FakeEmptyReloadSounds or self.FakeReloadSounds
		local snd = sound_tbl[time]

		if snd and self.FakeSoundPlayed ~= snd then
			self:GetOwner():EmitSound( snd, 60, math.random(98,102), 0.5, CHAN_AUTO )
			self.FakeSoundPlayed = snd

			if table.maxn(self.FakeReloadSounds) < time then
				return true
			end
		end

		return
	end

	local sounds = self.ReloadSoundes
	local floortime2 = math.floor(time * (#sounds))

	if sounds and sounds[floortime2] and self.SndReloadCD != floortime2 and sounds[floortime2] != "none" and (SERVER or self:IsLocal()) then
		self:GetOwner():EmitSound( sounds[floortime2], 60, math.random(98,102), 0.5, CHAN_AUTO )
		self.SndReloadCD = floortime2
	end
end

function SWEP:ReloadStartPost()
end

if SERVER then return end

local vector_full = Vector(1, 1, 1)
SWEP.StaminaReloadMul = 1
net.Receive("hgwep reload", function()
	local self = net.ReadEntity()
	local time = net.ReadFloat()
	if self and self.SetClip1 then self:SetClip1(net.ReadInt(10)) end
	self.StaminaReloadTime = net.ReadFloat()
	self.StaminaReloadMul = net.ReadFloat()
	if self.Reload then self:Reload(time) end
end)

function SWEP:Reload(time)
	if not time then return end
	--if !self:CanReload() then return end
	
	self.LastReload = time
	self:ReloadStart()
	self:ReloadStartPost()
	--self.StaminaReloadTime = -- self.ReloadTime * ( IsValid( self:GetOwner() ) and self:GetOwner().organism and self:GetOwner().organism.stamina and 2 -(self:GetOwner().organism.stamina[1] / 180 ) or 1 )
	self.reload = time + (self.StaminaReloadTime or self.ReloadTime) + 0.05
	if self:ShouldUseFakeModel() then
		self:PlayAnim(self:Clip1() == 0 and "reload_empty" or "reload", (self.StaminaReloadTime or self.ReloadTime), false, function()
			self:PlayAnim("idle", 1, not self.NoIdleLoop)
			--if self.MagIndex then
			--	self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin)
			--end
		end)

		--if self:Clip1() != 0 and self.MagIndex then
		--	self:GetWM():ManipulateBoneScale(self.MagIndex, vector_full)
		--end
	end
	self:Step_Reload(CurTime() - 1)
	self.dwr_reverbDisable = true
end

function SWEP:ReloadStart()
	if not IsValid(self:GetOwner()) then return end
	--self:SetHold(self.ReloadHold or self.HoldType)
	--self:GetOwner():SetAnimation(PLAYER_RELOAD)
end