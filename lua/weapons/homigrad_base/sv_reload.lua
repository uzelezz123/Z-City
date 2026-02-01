--
local CurTime = CurTime
util.AddNetworkString("hgwep reload")
function SWEP:Reload(time)
	if self.reload then return end
	if IsValid(self:GetOwner().FakeRagdoll) and self:GetOwner().FakeRagdoll.ConsLH then return end
	if not self:CanUse() or not self:CanReload() then self:OnCantReload() return end
	self.LastReload = CurTime()
	self:ReloadStart()
	self:ReloadStartPost()
	local org = self:GetOwner().organism
	self.StaminaReloadMul = (org and ((2 - (self:GetOwner().organism.stamina[1] / 180)) + ((org.pain / 40) + (org.larm / 3) + (org.rarm / 5)) - (1 - math.Clamp(org.recoilmul or 1,0.45,1.4))) or 1)
	self.StaminaReloadMul = math.Clamp(self.StaminaReloadMul,0.65,1.5)
	self.StaminaReloadTime = self.ReloadTime * self.StaminaReloadMul
	self.StaminaReloadTime = (self.StaminaReloadTime + (self:Clip1() > 0 and -self.StaminaReloadTime/3 or 0 ))
	self.reload = self.LastReload + self.StaminaReloadTime
	self.dwr_reverbDisable = true
	net.Start("hgwep reload")
		net.WriteEntity(self)
		net.WriteFloat(self.LastReload)
		net.WriteInt(self:Clip1(),10)
		net.WriteFloat(self.StaminaReloadTime)
		net.WriteFloat(self.StaminaReloadMul)
	net.Broadcast()
end

function SWEP:OnCantReload()

end

function SWEP:ReloadStart()
	self:SetHold(self.ReloadHold or self.HoldType)
	hook.Run("HGReloading", self)
	--if self.ReloadSound then self:GetOwner():EmitSound(self.ReloadSound, 60, 100, 0.8, CHAN_AUTO) end
end

local randomgovno = {
	"Shit.. I missed...",
	"Fuck.. I dropped it...",
}

-- возможно немного насралкод но работает норм
local IsValid, hg, pairs, isnumber, timer, math, AngleRand, timer = IsValid, hg, pairs, isnumber, timer, math, AngleRand, timer

local function FailSafe(ply)
	if not IsValid(ply) then return end

	ply:SetNW2Bool("FloorReloading", false)
	if timer.Exists("FloorReload_"..ply:SteamID64()) then
		timer.Remove("FloorReload_"..ply:SteamID64())
	end
end

local function SafeCheck(ply, ent, dist)
	if not IsValid(ply) and not ply:Alive() then return false end
	if ply:GetNetVar("carryent2") ~= ent or dist then FailSafe(ply) return false end

	local org = ply.organism
	if org.rarmamputated and org.larmamputated then FailSafe(ply) return false end
	if not ply:GetNW2Bool("FloorReloading", false) then FailSafe(ply) return false end

	return true
end

local mRandom, mRand, mClamp = math.random, math.Rand, math.Clamp

concommand.Add("hg_reloadfloorweapon", function(ply, cmd, args)
	if not IsValid(ply) and not ply:Alive() then return end
	local org = ply.organism
	if org.rarmamputated and org.larmamputated then return end

	local ent = (IsValid(hg.eyeTrace(ply).Entity) and hg.eyeTrace(ply).Entity) or (IsValid(ply:GetNetVar("carryent")) and ply:GetNetVar("carryent"))
	if not IsValid(ent) or not ishgweapon(ent) or ent:GetPos():DistToSqr(ply:GetPos()) > 6000 then return end

	local isshotgun = (ent.Base == "weapon_m4super" or ent:GetClass() == "weapon_m4super")
	local limbs = org.rarmamputated or org.larmamputated
	local clip, maxclip, ammocount = ent:Clip1(), ent:GetMaxClip1(), ply:GetAmmoCount(ent.Primary.Ammo)

	if clip >= maxclip then return end

	if limbs and clip < maxclip or (ammocount > 0 or (isshotgun and clip > 0 and not ent.drawBullet)) then
		if isshotgun and ent.drawBullet and ammocount <= 0 then return end

		local dist = ent:GetPos():DistToSqr(ply:GetPos()) > 6000
		local phys = ent:GetPhysicsObject()

		hg.SetCarryEnt2(ply, ent, 0, phys:GetMass(), vector_origin, ply:GetAimVector() * 10 + ply:GetUp() * -25 + ply:GetShootPos(), ply:EyeAngles())
		ply:EmitSound("physics/body/body_medium_impact_soft"..mRandom(7)..".wav", 55)
		ply:ViewPunch(AngleRand(-2, 2))
		ply:SetNW2Bool("FloorReloading", true) -- отсюда начинается фейлсейф..

		if ent.FakeReloadSounds ~= nil then
			for i, snd in pairs(ent.FakeReloadSounds) do
				if not SafeCheck(ply, ent, dist) then FailSafe(ply) return end

				if isnumber(i) then
					timer.Simple(i * mRand(3.2, 3.6) * ((isshotgun and ammocount <= 0 and not ent.drawBullet) and 0.5 or 1), function()
						if not SafeCheck(ply, ent, dist) then FailSafe(ply) return end

						if mRandom(10 * org.consciousness) == (5 * org.consciousness) then
							if IsValid(ply:GetNetVar("carryent2")) then
								local ent2 = ply:GetNetVar("carryent2")
								ply:SetNetVar("carryent2",NULL)
								ply:SetNetVar("carrybone2",nil)
								ply:SetNetVar("carrymass2",0)
								ply:SetNetVar("carrypos2",nil)
								heldents[ent2:EntIndex()] = nil
							end

							ent:EmitSound("physics/metal/weapon_impact_hard"..mRandom(3)..".wav", 65)
							ply:Notify(randomgovno[mRandom(#randomgovno)], 10)
							ply:EmitSound("physics/body/body_medium_impact_soft"..mRandom(7)..".wav", 55)
							ply:ViewPunch(AngleRand(-3, 3))
							FailSafe(ply)

							return
						end

						ent:EmitSound(snd)
						local mul = mClamp(i * 2, 0.2, 1.1)
						ply:ViewPunch(AngleRand(-3 * mul, 3 * mul))
					end)
				end
			end
		end

		timer.Create("FloorReload_"..ply:SteamID64(), (ent.ReloadTime + mRand(0.8, 1.8) * ((isshotgun and ammocount <= 0 and not ent.drawBullet) and 0.5 or 1)) or 5, 1, function()
			if not SafeCheck(ply, ent, dist) then FailSafe(ply) return end

			ply:EmitSound("physics/body/body_medium_impact_soft"..mRandom(7)..".wav", 55)
			ply:ViewPunch(AngleRand(-2, 2))
			ply:PickupWeapon(ent)
			ply:SetActiveWeapon(ent)
			ent:ReloadEnd()

			FailSafe(ply)
		end)
	end
end)

hook.Add("PlayerDeath", "fixgovno", function(ply)
	FailSafe(ply)
end)