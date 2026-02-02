AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SpecialTime = 0

local math = math -- owo
local math_random, math_Clamp, CurTime, Color = math.random, math.Clamp, CurTime, Color

local ang4 = Angle(0,0,180)
local ang5 = Angle(0,0,0)

local ang3 = Angle(0,0,180)
local clamp = math_Clamp

local function WhomILookinAt(ply, cone, dist)
	local CreatureTr, ObjTr, OtherTr
	for i = 1, 150 * cone do
		local Tr = hg.eyeTrace(ply,dist)
		if Tr.Hit and not Tr.HitSky and Tr.Entity then
			local Ent, Class = Tr.Entity, Tr.Entity:GetClass()
			if Ent:IsPlayer() or Ent:IsNPC() then
				CreatureTr = Tr
			elseif (Class == "prop_physics") or (Class == "prop_physics_multiplayer") or (Class == "prop_ragdoll") then
				ObjTr = Tr
			else
				OtherTr = Tr
			end
		end
	end

	if CreatureTr then return CreatureTr.Entity, CreatureTr.HitPos, CreatureTr.HitNormal, CreatureTr.PhysicsBone, CreatureTr end
	if ObjTr then return ObjTr.Entity, ObjTr.HitPos, ObjTr.HitNormal, ObjTr.PhysicsBone, ObjTr end
	if OtherTr then return OtherTr.Entity, OtherTr.HitPos, OtherTr.HitNormal, OtherTr.PhysicsBone, OtherTr end

	return
end

function SWEP:Deploy()
	if not IsFirstTimePredicted() then
		self:PlayAnim("draw",1)
		local owner = self:GetOwner()
		if not IsValid(owner:GetViewModel()) then
			owner:GetViewModel():SetPlaybackRate(.1)
		end
		return true
	end

	self:SetNextPrimaryFire(CurTime() + .5)
	self:UpdateNextIdle()
	self:SetFists(false)
	self:SetNextDown(CurTime())
	self:PlayAnim("draw",1)
	return true
end

function SWEP:SecondaryAttack()
	if self:GetOwner():InVehicle() then return end
	if not IsFirstTimePredicted() then return end
	if self:GetFists() and self:GetOwner().PlayerClassName == "sc_infiltrator" then
		self:PrimaryAttack(true)
	end
	if self:GetFists() then return end
	if self:GetOwner():GetNetVar("handcuffed",false) then return end
	if SERVER then
		self:SetCarrying()
		local ply = self:GetOwner()
		local pos = hg.eye(self:GetOwner())
		local tr = util.QuickTrace(pos, self:GetOwner():GetAimVector() * self.ReachDistance, {self:GetOwner()})

		if ply.PlayerClassName == "furry" then
			tr = util.TraceHull({
				start = pos,
				endpos = pos + self:GetOwner():GetAimVector() * self.ReachDistance,
				filter = {self:GetOwner()},
				mins = Vector(-5, -5, -5),
				maxs = Vector(5, 5, 5),
			})
		end

		--if (IsValid(tr.Entity) or game.GetWorld() == tr.Entity) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
		if (IsValid(tr.Entity)) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
			local Dist = (select(1, hg.eye(self:GetOwner())) - tr.HitPos):Length()
			--if Dist < self.ReachDistance then
				sound.Play("weapons/melee/blunt_light"..math_random(8)..".wav", self:GetOwner():GetShootPos(), 65, math_random(90, 110))
				self:SetCarrying(tr.Entity, tr.PhysicsBone, tr.HitPos, Dist)
				tr.Entity.Touched = true
				self:ApplyForce()
			--end
		elseif IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			local Dist = (select(1, hg.eye(self:GetOwner())) - tr.HitPos):Length()
			if Dist < self.ReachDistance then
				sound.Play("weapons/melee/blunt_light"..math_random(8)..".wav", self:GetOwner():GetShootPos(), 65, math_random(90, 110))
				self:GetOwner():SetVelocity(self:GetOwner():GetAimVector() * 20)
				tr.Entity:SetVelocity((self:GetOwner():KeyDown(IN_SPEED) and 1 or -1) * self:GetOwner():GetAimVector() * 50)
				self:SetNextSecondaryFire(CurTime() + .25)
				if self:GetOwner().organism.superfighter or self:GetOwner().PlayerClassName == "sc_infiltrator" or (self:GetOwner().PlayerClassName == "furry" and tr.Entity.PlayerClassName ~= "furry") or self:GetOwner():IsBerserk() then
					hg.LightStunPlayer(tr.Entity, 3)
					timer.Simple(0,function()
						local rag = hg.GetCurrentCharacter(tr.Entity)
						if IsValid(rag) and rag ~= tr.Entity then
							self:SetCarrying(rag, tr.PhysicsBone, tr.HitPos, Dist)
						end
					end)
				end
			end
		end
	end
end

SWEP.Checking = 0

-- function SWEP:AdjustMouseSensitivity()
-- 	local owner = self:GetOwner()
-- 	local ent = owner:GetNetVar("carryent", nil)
-- 	if IsValid(ent) and ent:IsRagdoll() and owner.PlayerClassName ~= "sc_infiltrator" and owner.PlayerClassName ~= "superfighter" then
-- 		local entPos = ent:GetPos()
-- 		local vecPos = owner:GetAimVector()

-- 		local diff = entPos - owner:GetShootPos()

-- 		local dot = vecPos:Dot( diff )/ diff:Length()
-- 		return math.max(dot-0.5,0.01)
-- 	end
-- end -- nope

function SWEP:ApplyForce()
	local ply = self:GetOwner()
	local target = self:GetOwner():GetAimVector() * self.CarryDist + select(1, hg.eye(ply))
	if not IsValid(self.CarryEnt) then return end
	local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

	if ply.organism and ply.organism.rarmamputated and ply:IsTyping() then
		self:SetCarrying()

		return
	end

	if IsValid(phys) then
		local TargetPos = phys:GetPos()

		if self.CarryEnt.poisoned then
			if ply.organism then
				ply.organism.poison2 = CurTime()
				self.CarryEnt.poisoned = nil
			end
		end

		if self.CarryEnt.organism and ((ply.sendTimeOrg or 0) < CurTime()) then
			ply.sendTimeOrg = CurTime() + 0.5

			//hg.send_organism(self.CarryEnt.organism, ply)
		end

		if self.CarryPos then
			if self.CarryEnt:IsRagdoll() then
				TargetPos = LocalToWorld(self.CarryPos, angle_zero, phys:GetPos(), phys:GetAngles())
			else
				TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos)
			end
		end

		local vec = target - TargetPos
		local len, mul = vec:Length(), phys:GetMass()

		vec:Normalize()

		if (ply.organism and ply.organism.superfighter) then
			mul = mul * 5
		end

		if (ply.organism and ply:IsBerserk()) then
			mul = mul * (1 + ply.organism.berserk / 5)
		end

		local avec = vec * len * 8 - phys:GetVelocity()

		local Force = avec * mul
		local ForceMagnitude = math.min(Force:Length(), 3000) * (1 / math.max(phys:GetVelocity():Dot(vec) / 25, 1))

		Force = Force:GetNormalized() * ForceMagnitude

		if len > 12000 then
			self:SetCarrying()
			return
		end

		phys:Wake()
		self.CarryEnt:SetPhysicsAttacker(ply, 15)

		if SERVER then
			if self.CarryEnt.welds then
				for i, weld in pairs(self.CarryEnt.welds) do
					if IsValid(weld) then weld:Remove() end
				end
				self.CarryEnt.welds = nil
			end
			if (ply:GetGroundEntity() == self.CarryEnt) or (ply:GetEntityInUse() == self.CarryEnt) or IsValid(ply.FakeRagdoll) or self.CarryEnt:IsPlayerHolding() then
				self:SetCarrying()
				return
			end
		end

		if self.CarryEnt:GetClass() == "ent_hg_cyanide_canister" then
			ply.Guilt = math.max(ply.Guilt, 5)
		end

		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			local ply2 = RagdollOwner(self.CarryEnt) or self.CarryEnt
			local bone = self.CarryEnt:GetBoneName(self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone))

			if ply:KeyPressed(IN_RELOAD) then
				if not ply2.noHead and ply2.organism then

					if ply2.organism.CantCheckPulse then
						ply:ChatPrint("The armor is too thick to feel the pulse.")
					elseif ((bone == "ValveBiped.Bip01_L_Hand") or (bone == "ValveBiped.Bip01_R_Hand") or (bone == "ValveBiped.Bip01_Head1")) then
						local org = ply2.organism

						if org.heartstop then
							ply:ChatPrint("No pulse.")
						else
							ply:ChatPrint(org.pulse < 20 and "Barely can feel the pulse." or (org.pulse <= 50 and "Low pulse.") or (org.pulse <= 90 and "Normal pulse.") or "High pulse.")
						end

						if (org.last_heartbeat + 60) > CurTime() then
							ply:ChatPrint("The body is still warm.")
						else
							ply:ChatPrint((org.last_heartbeat + 180) < CurTime() and "The body has been here for awhile." or "The body is slightly warm")
						end

						if org.blood < 3500 then
							//if org.blood < 1000 then
								//ply:ChatPrint("The skin looks almost white.")
							//else
								ply:ChatPrint("The skin is pale.")
							//end
						end

						if org.bleed > 0 then
							ply:ChatPrint("The body is bleeding "..((org.bleed > 10 and "profusely.") or (org.bleed > 5 and "moderately.") or "slightly."))
						end

						//org.bulletwounds = 0
						//org.stabwounds = 0
						//org.slashwounds = 0
						//org.bruises = 0
						//org.burns = 0
						//org.explosionwounds = 0

						if org.bulletwounds > 0 then
							ply:ChatPrint("You notice "..org.bulletwounds.." bullet wounds on this body.")
						end

						if org.stabwounds > 0 then
							ply:ChatPrint("You notice "..org.stabwounds.." stab wounds on this body.")//28 STAB WOUNDS. YOU WOULDNT LEAVE HIM A CHANCE, HUH?
						end

						if org.slashwounds > 0 then
							ply:ChatPrint("You notice "..org.slashwounds.." slashes on this body.")
						end

						if org.bruises > 0 then
							ply:ChatPrint("You notice "..org.bruises.." bruises on this body.")
						end

						if org.burns > 0 then
							ply:ChatPrint("The body was burned.")
						end

						if org.explosionwounds > 0 then
							ply:ChatPrint("The body appears to have blast trauma.")
						end

						if (bone == "ValveBiped.Bip01_Head1") then
							if (org.o2[1] < 10 or not org.alive) then
								ply:ChatPrint("Not breathing.")
							else
								ply:ChatPrint("Breathing.")
							end

							ply:ChatPrint(org.otrub and "No reaction." or "Reaction present.")

							if org.isPly and not org.otrub then
								org.owner:ChatPrint("You were checked for reaction.")
							end
						end
					end

					self.Checking = math.min(self.Checking + FrameTime() * 2, 10)
				else
					ply:Notify("I dont think I need to check their vitals.", 10)
				end
			end
		end

		if SERVER then
			local ply2 = self.CarryEnt
			local org = ply2.organism
			if ply:KeyDown(IN_ATTACK) and !ply.organism.superfighter and !(org and ply.PlayerClassName == "furry" and org.owner.PlayerClassName != "furry") and !ply:IsBerserk() then
				local bone = self.CarryEnt:GetBoneName(self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone))

				local tr = {}
				tr.start = TargetPos
				tr.endpos = TargetPos - vector_up * 16
				tr.mask = MASK_SOLID_BRUSHONLY
				local trace = util.TraceLine(tr)

				if bone != "ValveBiped.Bip01_Spine2" or not trace.Hit then
					phys:ApplyForceCenter(ply:GetAimVector() * math.min(5000, phys:GetMass() * 800))
					self:SetCarrying()
				end

				if org and bone == "ValveBiped.Bip01_Spine2" and trace.Hit then
					if self.firstTimePrint then
						if not ply2.noHead then
							ply:ChatPrint("You are beginning to perform CPR.")
						else
							ply:Notify("I dont think CPR would help here...", 10)
						end
					end

					self.firstTimePrint = false
					if (self.CPRThink or 0) < CurTime() then
						self.CPRThink = CurTime() + (1 / 120) * 60
						if org.alive then
							//org.o2[1] = math.min(org.o2[1] + hg.organism.OxygenateBlood(org) * 2 * (ply.Profession == "doctor" and 2 or 1), org.o2.range)
							org.pulse = math.min(org.pulse + 5 * (ply.Profession == "doctor" and 2 or 1),70)
							org.CO = math.Approach(org.CO, 0, (ply.Profession == "doctor" and 2 or 1))
							org.COregen = math.Approach(org.COregen, 0, (ply.Profession == "doctor" and 2 or 1))

							if math_random(3) == 1 then
								org.lungsfunction = true
							end

							if math_random(50) == 1 and (ply.Profession != "doctor") then
								local dmginfo = DamageInfo()
								dmginfo:SetDamageType(DMG_CRUSH)
								dmginfo:SetInflictor(self)
								hg.organism.input_list.chest(org, 1, 5, dmginfo)
							end

							if org.pulse > 15 then org.heartstop = false end
						end

						phys:ApplyForceCenter(-vector_up * 6000)

						--self.CarryEnt:EmitSound("physics/body/body_medium_impact_soft" .. tostring(math_random(7)) .. ".wav")
					end
				end
			else
				self.firstTimePrint = true
				self.firstTimePrint2 = true
			end

			if ply:KeyDown(IN_ATTACK) and ply.PlayerClassName == "furry" and org ~= nil and org.alive and org.owner.PlayerClassName != "furry" then
				org.assimilated = math.Approach(org.assimilated, 1, FrameTime() / 6)
				ply:SetLocalVar("assimilation", org.assimilated)

				if org.assimilated == 1 then
					org.owner:SetPlayerClass("furry")
				end

				hg.LightStunPlayer(org.owner, 1)

				//phys:ApplyForceCenter(ply:GetAimVector() * 40000 * self.Penetration)
				//self:SetCarrying()
			end

			if ply:KeyDown(IN_ATTACK) and (ply.organism.superfighter or ply:IsBerserk()) then
				phys:ApplyForceCenter(ply:GetAimVector() * 40000 * self.Penetration * (1 + ply.organism.berserk / 10))
				self:SetCarrying()
			end
		end

		if self.CarryPos then
			phys:ApplyForceOffset(Force, TargetPos)
		else
			phys:ApplyForceCenter(Force)
		end

		--[[if IsValid(self.CarryEnt) and self.CarryBone then
			hg.ShadowControl(self.CarryEnt, self.CarryBone, 0.1, angle_zero, 0, 0, target, 60, 40)
		end]]

		if ply:KeyDown(IN_USE) then
			SetAng = SetAng or ply:EyeAngles()
			local commands = ply:GetCurrentCommand()
			local x, y = commands:GetMouseX(), commands:GetMouseY()
			if IsValid(self.CarryEnt) and self.CarryEnt:IsRagdoll() then
				rotate = Vector(0, -x, -y) / 6
			else
				rotate = Vector(0, -x, -y) / 4
			end

			//phys:AddAngleVelocity(rotate * phys:GetMass() / 10)
		end

		phys:ApplyForceCenter(Vector(0, 0, mul))
		phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent, bone, pos, dist)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if IsValid(ent) or game.GetWorld() == ent then
		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist = dist

		local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

		if ent:GetClass() ~= "prop_ragdoll" then
			self.CarryPos = ent:WorldToLocal(pos)
		else
			self.CarryPos = WorldToLocal(pos, angle_zero, phys:GetPos(), phys:GetAngles())
		end

		if not IsValid(owner:GetNetVar("carryent")) then
			owner:SetNetVar("carryent", self.CarryEnt)
			owner:SetNetVar("carrybone", self.CarryBone)
			owner:SetNetVar("carrymass", phys:GetMass())
			owner:SetNetVar("carrypos", self.CarryPos)
		end

		if not self.CarryEnt:GetCustomCollisionCheck() then
			self.CarryEnt:SetCustomCollisionCheck(true)
			self.CarryEnt:CollisionRulesChanged()
			owner:CollisionRulesChanged()

			self.CarryEnt:CallOnRemove("removenarsla",function()
				if not IsValid(owner) then return end
				owner:CollisionRulesChanged()
				owner:SetNetVar("carryent",nil)
				owner:SetNetVar("carrybone",nil)
				owner:SetNetVar("carrymass",nil)
				owner:SetNetVar("carrypos",nil)
			end)

			owner:SetNetVar("carrymass",self.CarryEnt:GetPhysicsObjectNum(self.CarryBone):GetMass())
		end
	else
		if IsValid(self.CarryEnt) and self.CarryEnt:GetCustomCollisionCheck() then
			self.CarryEnt:CollisionRulesChanged()
			owner:CollisionRulesChanged()
			//self.CarryEnt:SetCustomCollisionCheck(false)
		end

		if IsValid(owner:GetNetVar("carryent")) then
			owner:SetNetVar("carryent",nil)
			owner:SetNetVar("carrybone",nil)
			owner:SetNetVar("carrypos",nil)
			owner:SetNetVar("carrymass",0)
		end

		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist = nil
	end
end

SWEP.DamagePrimary = 10

function SWEP:BlockingLogic(ent, mul, attacktype, trace)
	local ent = hg.RagdollOwner(ent) or ent

	if ent:IsPlayer() then
		local wep = ent:GetActiveWeapon()

		local owner = self:GetOwner()

		local pos, aimvec = hg.eye(ent)
		local pos2, aimvec2 = hg.eye(owner)

		local dist, posHit, distLine = util.DistanceToLine(pos + aimvec * 100, pos, trace.HitPos)

		//print(dist, distLine)

		local dmg = wep.DamagePrimary
		local selfdmg = self.DamagePrimary * 0.2

		if wep.GetBlocking and wep:GetBlocking() and wep.SetStartedBlocking and dist < 10 then
			ent.organism.stamina.subadd = ent.organism.stamina.subadd + mul * math_Clamp(selfdmg / dmg, 0.1, 1) * selfdmg * (1 - math_Clamp((self:GetStartedBlocking() - CurTime() + 0.1), 0, 0.1) / 0.1)

			wep:SetLastBlocked(CurTime())

			//viewpunch the attacker maybe?
			self:PunchPlayer(owner, attacktype, -owner:GetAimVector(), selfdmg / 2)
			self:PunchPlayer(ent, attacktype, owner:GetAimVector(), selfdmg / 2)

			ent:EmitSound("physics/body/body_medium_impact_soft6.wav") -- parry sound

			if wep.SetLastBlocked then
				wep:SetLastBlocked(CurTime())
			end

			return math_Clamp(selfdmg / dmg / math_Clamp(ent.organism.stamina[1] / (ent.organism.stamina.max * 0.66), 0.1, 1), 0.1, 1)
		end
	end

	return 1
end

function SWEP:Think()
	local owner = self:GetOwner()

	self.Secondary.Automatic = false//owner.PlayerClassName == "furry"

	self.Checking = math.max(self.Checking - FrameTime(), 0)

	if self:GetOwner():GetNWBool("TauntHolsterWeapons", false) then
		self:SetFists(false)
		self:SetBlocking(false)
		self:SetCarrying()
		self:Reload()
		return
	end

	if IsValid(owner) and owner:KeyDown(IN_ATTACK2) and not self:GetFists() then
		if IsValid(self.CarryEnt) or game.GetWorld() == self.CarryEnt then self:ApplyForce() end
	elseif self.CarryEnt then
		self:SetCarrying()
	end

	if self:GetFists() and owner:KeyDown(IN_ATTACK2) and (self:GetNextSecondaryFire() < CurTime()) and owner.PlayerClassName ~= "sc_infiltrator" then
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetBlocking(true)
	else
		self:SetBlocking(false)
	end

	local HoldType = "normal"
	if self:GetFists() then
		if CLIENT and self:GetHoldType() != "revolver" and self:GetHoldType() != "slam" then
			self:PlayAnim("draw",1)
		end
		HoldType = "revolver"
		local Time = CurTime()
		--[[if self:GetNextIdle() < Time and not self:GetBlocking() then
			if owner:GetVelocity():LengthSqr() > 11000 then
				self:PlayAnim("walk",1.4)
				self:UpdateNextIdle(1.4)
			else
				self:PlayAnim("idle",1.5)
				self:UpdateNextIdle()
			end
		end]]

		if owner.organism and not owner.organism.rarmamputated then
			self.SpecialTime = math.Clamp(self.SpecialTime - 0.1, Time, self.SpecialTime)

			if self.SpecialTime > 0 and self.SpecialTime <= Time then
				self:PlayAnim("attack_charge_end",0.9)
				if SERVER then
					self:AttackFront(special_attack,rand)
					sound.Play("player/shove_0"..math_random(5)..".wav", self:GetPos(), 75, math_random(115, 125))
				end
				self.SpecialTime = 0
			end
		end
		
		if self:GetBlocking() then
			self:SetNextDown(Time + 1)

			//owner:DoAnimationEvent(ACT_HL2MP_FIST_BLOCK)
			HoldType = "slam"
		end

		//if (self:GetNextDown() < Time) or owner:KeyDown(IN_SPEED) then
		if owner:KeyDown(IN_SPEED) and (owner.PlayerClassName != "furry" or owner:KeyDown(IN_WALK)) then
			self:SetNextDown(Time + 1)
			self:SetFists(false)
			self:SetBlocking(false)
		end
	else
		HoldType = "normal"
	end

	if IsValid(self.CarryEnt) or self.CarryEnt then HoldType = "normal" end
	if owner:KeyDown(IN_SPEED) and (owner.PlayerClassName != "furry" or owner:KeyDown(IN_WALK)) then HoldType = "normal" end
	if SERVER then self:SetHoldType(HoldType) end
end

local depang = Angle(0.5, 0, 0)
function SWEP:PrimaryAttack(forcespecial)
	local owner = self:GetOwner()
	if not IsValid(owner) or owner:InVehicle() then return end
	if (self.attacked or 0) > CurTime() then return end
	if owner.organism and owner.organism.rarmamputated and owner.organism.larmamputated then return end

	local isfur = owner.PlayerClassName == "furry"
	local side = isfur and "fists_left" or "attack_quick_2"
	local rand = math.Round(util.SharedRandom( "fist_Punching", 1, 2 ),0) == 1
	local twohands = (owner:GetNetVar("carrymass",0) ~= 0 and owner:GetNetVar("carrymass",0) or owner:GetNetVar("carrymass2",0)) > 15

	local inv = owner:GetNetVar("Inventory",{})
	if not inv then return end
	local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]

	if rand or (CLIENT and ((owner:GetTable().ChatGestureWeight and owner:GetTable().ChatGestureWeight >= 0.1) or twohands)) or havekastet then
		if isfur then
			if owner.organism and owner.organism.larmamputated then
				rand = 1
				side = "fists_right"
			end
		
			if owner.organism and owner.organism.rarmamputated then
				rand = 2
				side = "fists_left"
			end
		else
			side = "attack_quick_1"

			if owner.organism and owner.organism.larmamputated then
				rand = 1
				side = "attack_quick_1"
			end
		
			if owner.organism and owner.organism.rarmamputated then
				rand = 2
				side = "attack_quick_2"
			end
		end
	end

	if owner:KeyDown(IN_ATTACK2) and owner.PlayerClassName ~= "sc_infiltrator" then return end
	if owner:GetNetVar("handcuffed",false) then return end
	local olddown = self:GetNextDown()
	self:SetNextDown(CurTime() + 7)
	if not self:GetFists() then
		self:SetFists(true)
		if CLIENT then
			self:EmitSound("pwb2/weapons/matebahomeprotection/mateba_cloth.wav", 60, math.random(90, 100), 1, CHAN_BODY)
		end
		owner:ViewPunch(depang)
		if not isfur then
			self:PlayAnim("draw",1)
		else
			self:PlayAnim("fists_draw",1)
		end
		self:SetNextPrimaryFire(CurTime() + .35)
		return
	end

	if self:GetBlocking() then return end
	--if owner:KeyDown(IN_SPEED) then return end

	if not IsFirstTimePredicted() then
		self:PlayAnim(side,1)
		return
	end
	self.attacked = CurTime() + 0.2

	local special_attack = (olddown - 5) < CurTime()
	if forcespecial then
		special_attack = true
	end
	if owner.organism and owner.organism.rarmamputated then
		special_attack = false
	end

	self:UpdateNextIdle()

	self:SetNextPrimaryFire(CurTime() + .6 * math_Clamp((180 - owner.organism.stamina[1]) / 90,1,2) + (special_attack and 0.5 or isfur and 0.4 or 0))
	self:SetNextSecondaryFire(CurTime() + .6 + (special_attack and 0.5 or isfur and 0.4 or 0))
	self:SetLastShootTime(CurTime())

	if isfur then
		local Ent = WhomILookinAt(owner, .3, 45)
		if IsValid(Ent) then
			local ent_org = Ent.organism -- ServerLog: Mr. Point: я люблю плывиски mrrrph~~
			if ent_org and ent_org.owner.PlayerClassName == "furry" then
				if (owner.cooldownlick or 0) < CurTime() and SERVER then
					owner.cooldownlick = CurTime() + 1

					ent_org.avgpain = math.Approach(ent_org.avgpain, 0, 15)
					ent_org.painadd = math.Approach(ent_org.painadd, 0, 15)

					owner:EmitSound("zbattle/furry/lick"..math_random(3)..".wav")
					self:SetNextPrimaryFire(CurTime() + .5)
				end

				//self:SetFists(false)
				return
			end
		end
	end

	if special_attack then
		if not isfur then
			self:PlayAnim("attack_charge_begin",0.5)
			sound.Play("player/clothes_generic_foley_0"..math_random(5)..".wav", self:GetPos(), 55, math_random(110, 120))
			self.SpecialTime = CurTime() + 2
		else
			self:PlayAnim(side,1)
			if SERVER then
				self:AttackFront(special_attack,rand)
				sound.Play("player/shove_0"..math_random(5)..".wav", self:GetPos(), 60, math_random(120, 130))
				sound.Play("weapons/melee/swing_light_sharp_0"..math_random(2)..".wav", self:GetPos(), 65, math_random(130, 140))
			end
		end
	else
		self:PlayAnim(side,isfur and 1 or 0.85)
		if SERVER then
			self:AttackFront(special_attack,rand)
			sound.Play("player/shove_0"..math_random(5)..".wav", self:GetPos(), 60, math_random(110, 120))
		end
	end
end

local concrete = {
	"physics/concrete/boulder_impact_hard1.wav",
	"physics/concrete/boulder_impact_hard2.wav",
	"physics/concrete/boulder_impact_hard3.wav",
	"physics/concrete/boulder_impact_hard4.wav"
}

function SWEP:AttackFront(special_attack, rand)
	if CLIENT then return end
	local owner = self:GetOwner()
	--self.PenetrationCopy = -(-self.Penetration) -- это как
	owner:LagCompensation(true)
	local Ent, HitPos, _, physbone, trace = WhomILookinAt(owner, .3, special_attack and 35 or 45)
	local AimVec = owner:GetAimVector()
	local isfur = owner.PlayerClassName == "furry"
	if IsValid(Ent) or (Ent and Ent.IsWorld and Ent:IsWorld()) then
		if string.find(Ent:GetClass(),"break") and Ent:GetBrushSurfaces()[1] and string.find(Ent:GetBrushSurfaces()[1]:GetMaterial():GetName(),"glass") then
			//Ent:EmitSound("physics/glass/glass_sheet_impact_hard"..math_random(3)..".wav")

			//if math_random(1,8) == 8 and Ent:Health() < 250 then
				hg.organism.AddWoundManual(owner, math.Rand(50,75) * 1, vector_origin, AngleRand(), owner:LookupBone("ValveBiped.Bip01_"..(rand and "R" or "L").."_Hand"), CurTime())
				//Ent:Fire("Break")
				//Ent.Broken = true
			//end

			//owner:LagCompensation(false) // idiot

			//return
		end

		local inv = owner:GetNetVar("Inventory",{})
		local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]
		local SelfForce, Mul = 150, 1 * (havekastet and 1.7 or 1)
		if self:IsEntSoft(Ent) then
			SelfForce = 25
			if Ent:IsPlayer() and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking and Ent:GetActiveWeapon():GetBlocking() and not RagdollOwner(Ent) then
				sound.Play( owner.PlayerClassName == "furry" and "pwb/weapons/knife/hit"..math_random(1,4)..".wav" or "weapons/melee/blunt_light"..math_random(8)..".wav", HitPos, 60, math_random(90, 110))
				if owner:IsBerserk() then
					sound.Play("zbattle/berserk/unarmed" .. math_random(1, 9) .. ".wav", HitPos, 90, math_random(90, 110), 0.1 + owner.organism.berserk / 2)
				end
			else
				local snd = special_attack and "weapons/melee/blunt_heavy"..math_random(6)..".wav" or "Flesh.ImpactHard"
				sound.Play( owner.PlayerClassName == "furry" and "pwb/weapons/knife/hit"..math_random(1,4)..".wav" or snd, HitPos, 80, math_random(90, 110))
				if owner:IsBerserk() then
					sound.Play("zbattle/berserk/unarmed" .. math_random(1, 9) .. ".wav", HitPos, 90, math_random(90, 110), 0.1 + owner.organism.berserk / 2)
				end
			end
			if owner.PlayerClassName == "furry" then
				util.Decal("Blood",HitPos + owner:EyeAngles():Forward() * -1,HitPos - owner:EyeAngles():Forward() * -1)
				timer.Simple(0,function()
					local effectdata2 = EffectData()
					effectdata2:SetNormal(owner:EyeAngles():Forward() * -1)
					effectdata2:SetStart(HitPos + owner:EyeAngles():Forward() * -1)
					effectdata2:SetMagnitude(1)
					util.Effect("zippy_impact_flesh",effectdata2)
					Mul = Mul + 7.5
				end)
			end
		else
			if not isfur and not owner.organism.superfighter and not havekastet and not owner:IsBerserk() and math.random(special_attack and 2 or 1, special_attack and 6 or 4) > 3 then
				owner.organism.painadd = owner.organism.painadd + (math.random(3, 6) * (special_attack and 2.5 or 1.5))
				hg.organism.AddWoundManual(owner, math_random(6, 8) * (special_attack and 2 or 1), vector_origin, AngleRand(), owner:LookupBone("ValveBiped.Bip01_"..(rand and "R" or "L").."_Hand"), CurTime())
			end
			sound.Play(owner.PlayerClassName == "furry" and "pwb/weapons/knife/hitwall.wav" or "weapons/melee/blunt_light"..math_random(8)..".wav", HitPos, 65, math_random(90, 110))
			if owner:IsBerserk() then
				sound.Play(table.Random(concrete), HitPos, 90, math_random(90, 110), 0.1 + owner.organism.berserk / 2)
				util.Decal("Rollermine.Crater",HitPos + owner:EyeAngles():Forward() * -1,HitPos - owner:EyeAngles():Forward() * -1, Ent)
			end
		end

		local DamageAmt = ((math_random(8, 10) * (special_attack and 4 or 1)) * ((isfur and (owner:IsBerserk() and 10 or 0.85)) or 1)) * (self.DamageMul or 1)
		local ent = Ent
		local vec = AimVec

		Ent:PrecacheGibs()

		if string.find(ent:GetClass(),"prop_") and not ent:IsRagdoll() then
			ent:CallOnRemove("gibbreak",function()
				ent:GibBreakClient( vec * 100 )
			end)

			timer.Simple(1,function()
				if IsValid(ent) then ent:RemoveCallOnRemove("gibbreak") end
			end)
		end

		Mul = Mul * (owner.MeleeDamageMul or 1)

		if Ent:IsPlayer() and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking then
			Mul = Mul * (self:GetBlocking() and 0.5 or 1)
		end

		if owner.organism.superfighter then
			Mul = Mul * 5 * self.Penetration
			if Ent.organism then
				Ent.organism.immobilization = 10
			end
		end

		if owner:IsBerserk() then
			Mul = Mul * (1 + owner.organism.berserk * 5) * self.Penetration
			if Ent.organism then
				Ent.organism.immobilization = 1
			end
		end

		Mul = Mul * self:BlockingLogic(Ent, Mul, 0, trace)

		local Dam = DamageInfo()
		Dam:SetAttacker(owner)
		Dam:SetInflictor(self)
		Dam:SetDamage(DamageAmt * Mul * 0.85 * (owner.PlayerClassName == "furry" and 5 or 1))
		Dam:SetDamageForce(AimVec * Mul ^ 2)
		Dam:SetDamageType((owner.PlayerClassName == "furry" or (Ent:GetClass() == "func_breakable_surf")) and DMG_SLASH or DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)

		local Phys = Ent:IsPlayer() and Ent:GetPhysicsObject() or Ent:GetPhysicsObjectNum(physbone or 0)

		if Ent:IsPlayer() then
			Ent:ViewPunch(Angle(special_attack and -45 or -5,0,0))
		end

		if IsValid(Phys) then
			if Ent:IsPlayer() then Ent:SetVelocity(AimVec * SelfForce * 1.5 * (owner.organism.superfighter and 5 or 1) * (1 + owner.organism.berserk * 5)) end
			Phys:ApplyForceOffset(AimVec * 5000 * Mul, HitPos)
			owner:SetVelocity(AimVec * SelfForce * .8 * (owner.organism.superfighter and 2 or 1) * (1 + owner.organism.berserk / 10))
		end
	end

	if SERVER then
		owner.organism.stamina.subadd = owner.organism.stamina.subadd + 6
	end

	owner:LagCompensation(false)
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	self:SetFists(false)
	self:SetBlocking(false)

	local ent = self:GetCarrying()

	if SERVER then
		local target,_ = WorldToLocal(self:GetOwner():GetAimVector() * (self.CarryDist or 50) + self:GetOwner():GetShootPos(),angle_zero,self:GetOwner():EyePos(),self:GetOwner():EyeAngles())

		if IsValid(ent) then
			local owner = self:GetOwner()
			local bon = self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone)
			local bone = self.CarryEnt:GetBoneName(bon)
			local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

			if ((bone ~= "ValveBiped.Bip01_L_Hand") and (bone  ~= "ValveBiped.Bip01_R_Hand") and (bone ~= "ValveBiped.Bip01_Head1")) then
				if not heldents[ent:EntIndex()] then
					hg.SetCarryEnt2(owner, ent, bon, phys:GetMass(), self.CarryPos, owner:GetAimVector() * (self.CarryDist or 50) + owner:GetShootPos())
				else
					--hg.SetCarryEnt2(owner)
				end
			end

			--self:SetCarrying()
		end
	end
end