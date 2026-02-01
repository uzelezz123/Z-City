if SERVER then AddCSLuaFile() end
SWEP.PrintName = "Combat Knife"
SWEP.Instructions = "A military grade combat knife designed to neutralize the enemy during combat operations and special operations."
SWEP.Category = "Weapons - Melee"
SWEP.Instructions = "This is your trusty carbon-steel fixed-blade knife.\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.WorldModel = "models/weapons/combatknife/tactical_knife_iw7_wm.mdl"
SWEP.WorldModelReal = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "knife"

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:IsSprinting()
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
    if not owner.IsSprinting then return false end
    if owner:IsSprinting() and hg.GetCurrentCharacter(owner):IsPlayer() then return true end
end

function SWEP:CanSecondaryAttack()
    if self:GetClass() == "weapon_melee" then return false end
	return true
end

SWEP.supportTPIK = true
SWEP.ismelee = true
SWEP.ismelee2 = true

SWEP.AttackTime = 0.2
SWEP.AnimTime1 = 0.7
SWEP.WaitTime1 = 0.5
SWEP.AttackLen1 = 55

SWEP.Attack2Time = 0.1
SWEP.AnimTime2 = 0.6
SWEP.WaitTime2 = 0.4
SWEP.AttackLen2 = 45

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 15
SWEP.DamageSecondary = 8

SWEP.PenetrationPrimary = 8
SWEP.PenetrationSecondary = 4

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 0.75
SWEP.PenetrationSizeSecondary = 2.5

SWEP.StaminaPrimary = 10
SWEP.StaminaSecondary = 8.5

SWEP.ViewPunch1 = Angle(2,0,0)
SWEP.ViewPunch2 = Angle(0,1,0)

SWEP.AttackSize = 5

SWEP.weaponPos = Vector(2,0.1,-0.8)
SWEP.weaponAng = Angle(180,90,90)

SWEP.AnimList = {
    ["idle"] = "vm_knifeonly_idle",
    ["deploy"] = "vm_knifeonly_raise",
    ["attack"] = "vm_knifeonly_stab",
    ["attack2"] = "vm_knifeonly_swipe",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/tfa_iw7_tactical_knife")
	SWEP.IconOverride = "vgui/hud/tfa_iw7_tactical_knife.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AttackSwing = "weapons/slam/throw.wav" --!! заменить звуки
SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "snd_jack_hmcd_knifestab.wav"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_slash.wav"
SWEP.DeploySnd = "snd_jack_hmcd_knifedraw.wav"

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.attack_ang = Angle(-55,-3,0)
SWEP.sprint_ang = Angle(30,0,0)

SWEP.HoldPos = Vector(-10,3,-2)
SWEP.HoldAng = Angle(-10,5,0)

SWEP.basebone = 1

SWEP.AttackPos = Vector(0,0,-10)
SWEP.AttackingPos = Vector(16,0,0)

SWEP.WorkWithFake = true

function SWEP:SetHold(value)
    self:SetWeaponHoldType(value)
    self:SetHoldType(value)
    self.holdtype = value
end

function SWEP:InUse()
    local ply = self:GetOwner()
    if !IsValid(ply) then return end
    local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
    local org = ply.organism

    local power = ply:GetNWFloat("power", 1)

	if power < 0.4 and ent != ply then
		return false
	end
    
    return (ent == ply or hg.KeyDown(ply, IN_USE) or IsValid(ply.OldRagdoll))
end

SWEP.modelscale = 1
SWEP.modelscale2 = 1
if CLIENT then
    function PrintBones( entity )
        for i = 0, entity:GetBoneCount() - 1 do
            print( i, entity:GetBoneName( i ) )
        end
    end

    function PrintAnims( entity )
        PrintTable(entity:GetSequenceList())
    end

	function SWEP:GetWM()
        if IsValid(self.worldModel) then
            return self.worldModel
        else
            self.worldModel = ClientsideModel(self.WorldModel)
            self.worldModel:SetNoDraw(true)
            self.worldModel:SetupBones()
            self:CallOnRemove("remove_worldmodel1",function()
                if IsValid(model) then
                    model:Remove()
                    model = nil
                end
            end)
        end
		return self.worldModel
	end

	local npcang = Angle(0, 0, 180)
    function SWEP:DrawWorldModel()
		local ent = self:GetOwner()
        if not IsValid(ent) then
            self:DrawWorldModel2()
        end
        
        if ent:IsNPC() then
			local RHand = ent:LookupBone("ValveBiped.Bip01_R_Hand")
			if not RHand then return end
			local matrixR = ent:GetBoneMatrix(RHand) or ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Forearm"))
			if not matrixR then 
				//matrixR = Matrix()
				//local att = ent:GetAttachment(ent:LookupAttachment("anim_attachment_RH"))
				//matrixR:SetTranslation(att.Pos)
				//matrixR:SetAngles(att.Ang)
				return
			end

			matrixR:Rotate(npcang)

			if not IsValid(self.NPCworldModel) then
				self.NPCworldModel = ClientsideModel(self.WorldModel)
				self:CallOnRemove("remove_npcworldmodel1",function()
					if IsValid(self.NPCworldModel) then
						self.NPCworldModel:Remove()
						self.NPCworldModel = nil
					end
				end)
			end

			local WorldModel = self.NPCworldModel
			WorldModel:SetNoDraw(true)
			WorldModel:SetModelScale(self.modelscale2)
			WorldModel:SetRenderOrigin(matrixR:GetTranslation())
			WorldModel:SetRenderAngles(matrixR:GetAngles())
            WorldModel:SetPos(matrixR:GetTranslation())
            WorldModel:SetAngles(matrixR:GetAngles())
			WorldModel:SetupBones()
			WorldModel:DrawModel()
        end
    end

    SWEP.Current = 1

	function SWEP:DrawWorldModel2()
		local owner = self:GetOwner()
        
        if not IsValid(self.worldModel) then
            self.worldModel = self:GetWM()
        end
        
        self.worldModel:SetNoDraw(true)
        
        if IsValid(owner) and (not owner.shouldTransmit or owner.NotSeen) then return end
        if not IsValid(owner) and (not self.shouldTransmit or self.NotSeen) then return end

		local WorldModel = self.worldModel
        
        self.worldModel:SetModelScale(self.modelscale2)
        local ent = hg.GetCurrentCharacter(owner)

        local inuse = self:InUse()

        if IsValid(owner) then
            if not self.cycling then
                local timing = (1 - math.Clamp((self.animtime - CurTime()) / self.animspeed, 0, 1))
                timing = self.reverseanim and (1 - timing) or timing
                WorldModel:SetCycle(timing)
                --PrintTable( WorldModel:GetSequenceList() )
                
                if self.callback and timing == ((not self.reverseanim) and 1 or 0) then
                    self.callback(self)
                    self.callback = nil
                end
            else
                local timing = ((CurTime() - (self.animtime - self.animspeed))%self.animspeed) / self.animspeed
                WorldModel:SetCycle(timing)
            end

            if WorldModel:GetModel() ~= self.WorldModelReal then WorldModel:SetModel(self.WorldModelReal) end
            
            local pos, ang = self:ModelAnim(WorldModel)

			WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang)
            WorldModel:SetPos(pos)
            WorldModel:SetAngles(ang)
		else
            if WorldModel:GetModel() ~= self.WorldModel then WorldModel:SetModel(self.WorldModel) end
			
            WorldModel:SetRenderOrigin(self:GetPos())
			WorldModel:SetRenderAngles(self:GetAngles())
            WorldModel:SetPos(self:GetPos())
            WorldModel:SetAngles(self:GetAngles())
		end

        WorldModel:SetupBones()
        
        if IsValid(owner) and !inuse then
            local bon = ent:LookupBone("ValveBiped.Bip01_R_Hand")
            if not bon then return end
            local mat = ent:GetBoneMatrix(bon)
            if not mat then return end

            local pos, ang = mat:GetTranslation(), mat:GetAngles()
            //local oldpos, oldang = WorldModel:GetPos(), WorldModel:GetAngles()

            //self.Current = LerpFT(0.1, self.Current,  and 1 or 0)
            
            //local pos = Lerp(self.Current, oldpos, pos)
            //local ang = Lerp(self.Current, oldang, ang)

            WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang) 
            WorldModel:SetPos(pos)
            WorldModel:SetAngles(ang)

            local bon = WorldModel:LookupBone("ValveBiped.Bip01_R_Hand")
            local matW = WorldModel:GetBoneMatrix(bon)

            if !matW then return end

            local invmat = mat * matW:GetInverse()

            for i = 0, WorldModel:GetBoneCount() - 1 do
                local mata = WorldModel:GetBoneMatrix(i)
                if !mata then continue end
                mata = invmat * mata
                WorldModel:SetBoneMatrix(i, mata)
            end
        end

        if not self.WorldModelExchange then
            WorldModel:DrawModel()
        end

        if IsValid(self.worldModel) and self.WorldModelExchange then
            if not IsValid(self.worldModel2) then
                self.worldModel2 = ClientsideModel(self.WorldModelExchange)
                self.worldModel2:SetNoDraw(true)
                self.worldModel2:SetupBones()
                local model = self.worldModel2

                self:CallOnRemove("remove_worldmodel2",function()
                    if IsValid(model) then
                        model:Remove()
                        model = nil
                    end
                end)
            end

            self.worldModel2:SetNoDraw(true)

            local pos,ang = self.worldModel:GetPos(),self.worldModel:GetAngles()
            local huy = self.worldModel:GetModel() == self.WorldModelReal
            
            if (IsValid(self:GetOwner()) or self.DontChangeDropped) then
                local mat = self.worldModel:GetBoneMatrix(self.basebone or 1)
                pos,ang = LocalToWorld(self.weaponPos,self.weaponAng,huy and mat and mat:GetTranslation() or self.worldModel:GetPos(),huy and mat and mat:GetAngles() or self.worldModel:GetAngles())
            end

            self.worldModel2:SetModelScale(self.modelscale)
            self.worldModel2:SetRenderOrigin(pos)
            self.worldModel2:SetRenderAngles(ang)
            self.worldModel2:SetPos(pos)
            self.worldModel2:SetAngles(ang)
            self.worldModel2:SetupBones()
            self.worldModel2:DrawModel()
        end
		
		if(self.DrawPostWorldModel)then
			self:DrawPostWorldModel()
		end

        if self:WaterLevel() > 0 then
            ClearDecalToEnt(IsValid(self.worldModel2) and self.worldModel2 or self.worldModel, self:EntIndex())
        end
	end
end

local addAng = Angle()
local addPos = Vector()

local vechuy = Vector()

local addPosLerp = Vector()
local addAngLerp = Angle()

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    return false
end

SWEP.SuicidePos = Vector(5, -24, 5)
SWEP.SuicideAng = Angle(0, 90, 20)
SWEP.SuicideCutVec = Vector(2, -5, 6)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5

SWEP.CanSuicide = false -- for weapon_melee its configured in Initialize

function SWEP:ModelAnim(model, pos, ang)
    local owner = self:GetOwner()

    if !IsValid(owner) or !owner:IsPlayer() then return end

    local ent = hg.GetCurrentCharacter(owner)
    local tr = hg.eyeTrace(owner, 20, ent)
    local eyeAng = owner:EyeAngles()

    local vel = ent:GetVelocity()
    local vellen = vel:Length()

    local vellenlerp = self.velocityAdd and self.velocityAdd:Length() or vellen

    if !tr then return end

    local dtime = SysTime() - (self.timetick2 or SysTime() + 0.015)

    self.walkLerped = LerpFT(0.1, self.walkLerped or 0, (owner:InVehicle()) and 0 or vellenlerp * 200)
	self.walkTime = self.walkTime or 0
    
	local walk = math.Clamp(self.walkLerped / 200, 0, 1)
	
	self.walkTime = self.walkTime + walk * dtime * 7 * game.GetTimeScale() * (owner:OnGround() and 1 or 0)
    
    self.velocityAdd = self.velocityAdd or Vector()
    self.velocityAddVel = self.velocityAddVel or Vector()

    //vel.z = vel.z + ((owner:IsFlagSet(FL_ANIMDUCKING) and !owner:IsFlagSet(FL_DUCKING)) and (100) or (!owner:IsFlagSet(FL_ANIMDUCKING) and owner:IsFlagSet(FL_DUCKING)) and (-100) or 0)
    self.velocityAddVel = LerpFT(0.9, self.velocityAddVel * 0.99, -vel * 0.01)
    self.velocityAddVel[3] = self.velocityAddVel[3]

    self.velocityAdd = LerpFT(0.03, self.velocityAdd, self.velocityAddVel)

	local huy = self.walkTime
	
	local x, y = math.cos(huy) * math.sin(huy) * walk + math.cos(CurTime() * 5) * walk * math.sin(CurTime() * 2) * 0.5, math.sin(huy) * walk * 1 + math.sin(CurTime() * 5) * walk * math.cos(CurTime() * 4) * 0.5
    
    addPos:Zero()
    addAng:Zero()
    addPosLerp:Zero()
    addAngLerp:Zero()

    addPosLerp.z = addPosLerp.z + ((hg.KeyDown(owner, IN_DUCK)) and -2 or 0)

    if !self:CustomBlockAnim(addPosLerp, addAngLerp) then
        addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -2 or 0)
        addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -4 or 0)
        addPosLerp.y = addPosLerp.y + (self:GetBlocking() and 8 or 0)
        addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -30 or 0)
    end

    if owner:GetNWFloat("InLegKick",0) > CurTime() + 0.1 then
       addAngLerp.p = addAngLerp.p - math.min(math.abs(math.max(eyeAng.p,0)),25)
    end

    addPosLerp.x = addPosLerp.x - 20 * math.max(0.5 - tr.Fraction,0)

    if self.CanSuicide and owner.suiciding then
        addPosLerp:Set(self.SuicidePos)
        addAngLerp:Set(self.SuicideAng)
    end

    self.lerpedAddPos = LerpFT(0.06, self.lerpedAddPos or Vector(), addPosLerp)
    self.lerpedAddAng = LerpFT(0.06, self.lerpedAddAng or Angle(), addAngLerp)

    if self:IsLocal() then
        addPos.z = x * 2 * vellenlerp * 0.3 - vellenlerp * 1
        addPos.y = y * 2 * vellenlerp * 0.3
    
        addAng.z = -x * 2// * vellenlerp * 0.3
        addAng.y = -y * 2// * vellenlerp * 0.3

        addPos.y = addPos.y - angle_difference.y * 2
        addAng.y = addAng.y + angle_difference.y * 4

        addPos.z = addPos.z + angle_difference.p * 2
        addAng.p = addAng.p + angle_difference.p * 4

        addAng.p = addAng.p + math.cos(CurTime() * 2) * 1

        //addPos.z = addPos.z + eyeAng[1] * 0.05
        addPos.x = addPos.x + eyeAng[1] * 0.05

        local veldot = self.velocityAdd:Dot(eyeAng:Right())
        
        addAng.r = addAng.r - veldot * 5 + math.cos(CurTime() * 5) * walk * 2 - angle_difference.y * 2

        //addAng.p = addAng.p + math.cos(CurTime() * 2) * 1
    end

    self.lastAddPos = addPos

    //local inattack1 = self:GetAttackType() == 1 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false
    //local inattack2 = self:GetAttackType() == 2 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false

    //self.attackanim = LerpFT(0.1, self.attackanim, (inattack1 and 0.8 or 0) - (inattack2 and 0.3 or 0))
    //self.sprintanim = LerpFT(0.05, self.sprintanim, self:IsSprinting() and 1 or 0)

    local hpos = self.HoldPos
    local hang = self.HoldAng
    
    if self.SuicideStart and self.SuicideStart + self.SuicideTime > CurTime() then
        local animpos = (1 - math.Clamp((self.SuicideStart + self.SuicideTime - CurTime()) / self.SuicideTime, 0, 1))
        animpos = math.ease.OutElastic(animpos)
        
        addPos:Add(self.SuicideCutVec * animpos)
        addAng:Add(self.SuicideCutAng * animpos)
    end

    if self.cutthroat then
        local animpos = math.Clamp((self.cutthroat - CurTime() + 1) / 1, 0, 1)
        animpos = math.ease.InOutCubic(animpos)
        addPos:Add(self.SuicideCutVec * animpos)
        addAng:Add(self.SuicideCutAng * animpos)
    end

    local pos, ang = LocalToWorld(hpos + addPos + self.lerpedAddPos, hang + addAng + self.lerpedAddAng, tr.StartPos + self.velocityAdd, eyeAng)

	self.timetick2 = SysTime()

    return pos, ang
end

SWEP.KickAng = Angle(0,0,0)

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"

--hook.Add("PostDrawPlayerRagdoll","ragdollhuymelee",function(ent,ply)
function hg.RenderMelees(ent, ply, wep)
    if wep.DrawWorldModel2 then
        wep:DrawWorldModel2()
    else
        wep:DrawWorldModel()
    end
end
--end)

local host_timescale = game.GetTimeScale

function SWEP:Camera(eyePos, eyeAng, view, vellen)
    //self:SetHandPos()
    self:DrawWorldModel2()

    local WorldModel = self.worldModel

    if not IsValid(WorldModel) then return end

    local camBone = (WorldModel:LookupBone(self.FakeViewBobBone) or (self.FakeVPShouldUseHand and WorldModel:LookupBone("ValveBiped.Bip01_R_Hand") or WorldModel:LookupBone("Weapon"))) or WorldModel:LookupBone("ValveBiped.Bip01_R_Hand")
    
    if camBone then
        local matrix = WorldModel:GetBoneMatrix(camBone)

        if matrix then
            local gAngles = matrix:GetAngles()
            local _,gAngles = WorldToLocal(vector_origin, gAngles, eyePos, eyeAng)
            self.OldAngPunch = self.OldAngPunch or gAngles
            local punch = ( self.OldAngPunch - gAngles ) / (self.ViewPunchDiv or 120)
            
            self.punch = punch

            //ViewPunch2( -punch )
            ViewPunch( punch )
            
            self.OldAngPunch = gAngles
        end
    end

    local owner = self:GetOwner()
    if not owner.InVehicle then return end

    view.origin = eyePos - (angle_difference_localvec * 150) - (position_difference * 0.5)
    view.angles = eyeAng
    
    local lpos = self.lastAddPos or vector_origin
    //view.angles[1] = view.angles[1] + lpos.z * 1
    //view.angles[2] = view.angles[2] + lpos.y * 1
    
    return view
end

local ang180, ang1 = Angle(0,180,0), Angle(-135,-90,0)
function SWEP:SetHandPos(noset)
	local ply = self:GetOwner()
	local owner = self:GetOwner()

    self.rhandik = false
	self.lhandik = false
    
    if not IsValid(ply) or not IsValid(self.worldModel) then return end
    if not ply.shouldTransmit or ply.NotSeen then return end

    local ent = hg.GetCurrentCharacter(ply)

	local bones = hg.TPIKBonesLH

    local ply_spine_index = ent:LookupBone("ValveBiped.Bip01_Spine4")
    if !ply_spine_index then return end
    local ply_spine_matrix = ent:GetBoneMatrix(ply_spine_index)
    if !ply_spine_matrix then return end
    local wmpos = ply_spine_matrix:GetTranslation()

	local wm = self:GetWM()
	if !IsValid(wm) then return end
	-- ent:SetupBones()

	self.rhandik = self.setrh and IsValid(owner) and (ent == owner or hg.KeyDown(owner,IN_USE) or (IsValid(ply.OldRagdoll)))//self.setrh
	self.lhandik = self.setlh and IsValid(owner) and (ent == owner or hg.KeyDown(owner,IN_USE) or (IsValid(ply.OldRagdoll))) and (ply:GetTable().ChatGestureWeight < 0.1) and hg.CanUseLeftHand(ply) and !(owner.suiciding and self.SuicideNoLH)

    local rhmat, lhmat = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Hand")), ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_L_Hand"))

	ply.rhold = rhmat
	ply.lhold = lhmat

	if self.lhandik and self:InUse() then
		for _, bone in ipairs(bones) do
			local wm_boneindex = wm:LookupBone(bone)
			if !wm_boneindex then continue end
			local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
			if !wm_bonematrix then continue end
			
			local ply_boneindex = ent:LookupBone(bone)
			if !ply_boneindex then continue end
			local ply_bonematrix = ent:GetBoneMatrix(ply_boneindex)
			if !ply_bonematrix then continue end

			local bonepos = wm_bonematrix:GetTranslation()
			local boneang = wm_bonematrix:GetAngles()

			bonepos.x = math.Clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38)
			bonepos.y = math.Clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
			bonepos.z = math.Clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

			ply_bonematrix:SetTranslation(bonepos)
			ply_bonematrix:SetAngles(boneang)
			
            --if bone == "ValveBiped.Bip01_L_Hand" then lhmat = ply_bonematrix end
			ent:SetBoneMatrix(ply_boneindex, ply_bonematrix)
			--ent:SetBonePosition(ply_boneindex, bonepos, boneang)
		end
    else
        if ply == ent then
            local ply_spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
            if !ply_spine_index then return end
            local ply_spine_matrix = ply:GetBoneMatrix(ply_spine_index)
            local wmpos = ply_spine_matrix:GetTranslation() - ply:EyeAngles():Right() * 5

            local tr = {}
            tr.start = wmpos
            tr.endpos = wmpos + ply:GetAimVector() * 30
            tr.filter = ply

            local trace = util.TraceLine(tr)

            if trace.Hit then
                hg.DragLeftHand(ply, self, trace.HitPos - ply:GetAimVector() * 5, ply:GetAimVector(), (trace.Entity:IsWorld() and Lerp(1, trace.HitNormal:Angle(), ply:EyeAngles() + ang180) or ply:EyeAngles() + ang180) + ang1 - ply:EyeAngles())
            end
        end
    end

	local bones = hg.TPIKBonesRH

	if self.rhandik and self:InUse() then
		for _, bone in ipairs(bones) do
			local wm_boneindex = wm:LookupBone(bone)
			if !wm_boneindex then continue end
			local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
			if !wm_bonematrix then continue end
			
			local ply_boneindex = ent:LookupBone(bone)
			if !ply_boneindex then continue end
			local ply_bonematrix = ent:GetBoneMatrix(ply_boneindex)
			if !ply_bonematrix then continue end

			local bonepos = wm_bonematrix:GetTranslation()
			local boneang = wm_bonematrix:GetAngles()

			bonepos.x = math.Clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38)
			bonepos.y = math.Clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
			bonepos.z = math.Clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

			ply_bonematrix:SetTranslation(bonepos)
			ply_bonematrix:SetAngles(boneang)

            --if bone == "ValveBiped.Bip01_R_Hand" then rhmat = ply_bonematrix end
            ent:SetBoneMatrix(ply_boneindex, ply_bonematrix)
			--ent:SetBonePosition(ply_boneindex, bonepos, boneang)
		end
	end

    --return rhmat,lhmat
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Blocking")
	self:NetworkVar("Float", 1, "LastBlocked")
	self:NetworkVar("Float", 2, "StartedBlocking")
    self:NetworkVar("Float", 3, "AttackWait")
    self:NetworkVar("Float", 4, "LastAttack")
    self:NetworkVar("Int", 5, "AttackType")
	self:NetworkVar("Bool", 6, "InAttack")
    self:NetworkVar("Float", 7, "AttackLength")
    self:NetworkVar("Float", 8, "AttackTime")
end

function SWEP:OwnerChanged()
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:PlayAnim("deploy",0.5,false,nil,false)
        self:SetHold(self.HoldType)
        timer.Simple(0,function() self.picked = true end)
    else
        self:SetInAttack(false)
        timer.Simple(0,function() self.picked = nil end)
    end
end

function SWEP:OnRemove()
    if IsValid(self.worldModel) then
        self.worldModel:Remove()
    end
end
SWEP.Initialzed = false
function SWEP:Deploy()
    if SERVER and self.Initialzed and not self:GetOwner().noSound then self:GetOwner():EmitSound(self.DeploySnd,65) end
    self.Initialzed = true
    self:PlayAnim("deploy", 1, false, nil, false)
    self:SetHold(self.HoldType)
	
	return true
end

function SWEP:Holster(wep)
    self:SetInAttack(false)
    return true
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or hg.RagdollOwner(ent) or ent:IsRagdoll()
end

function SWEP:ThinkAdd()
end

function SWEP:Think()
    self:CustomThink()
end

if CLIENT then
    local sensitivity = 1

    function SWEP:AdjustMouseSensitivity()
        local owner = self:GetOwner()
        local ent = hg.GetCurrentCharacter(owner)

        local time = math.max(self:GetLastAttack() - CurTime(),0)

        local inattack1 = time / self.AttackTimeLength
        local inattack2 = time / self.Attack2TimeLength
        local mul = self:GetAttackType() == 1 and inattack1 or inattack2

        mul = math.max( (math.max(math.min(mul,self.MinSensivity or 0.35),0)) - (self.MinSensivity/10) ,0 )
        mul = 1-(mul)
		if wep.GetBlocking and wep:GetBlocking() then
			mul = math.Clamp(mul * 0.35, 0.2, 1)
		end

        sensitivity = math.min(sensitivity, mul)
        sensitivity = LerpFT(0.02, sensitivity, mul)
        
        return IsValid(ent) and ent:IsPlayer() and sensitivity
    end

end

function SWEP:MultiplyDMG(owner, ent, vellen, mul)
    mul = mul * 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90,1,1.3)
    mul = mul * math.Clamp(vellen / 250, 0.9, 1.25)
    mul = mul * (ent ~= owner and 0.75 or 1)
    mul = mul * (owner.MeleeDamageMul or 1)

    if owner.organism.superfighter then
        mul = mul * 5
    end

    if owner:IsBerserk() then
        mul = mul * (1 + owner.organism.berserk)
    end

    return mul
end

function SWEP:Attack(owner, ent, vellen, attacktype, inattackLength)
    //if SERVER then owner:SetNetVar("slowDown", owner:GetNetVar("slowDown", 0) + (attacktype and self.DamageSecondary or self.DamagePrimary)) end
    
    if not self.FirstAttackTick then 
        if CLIENT then
            if owner == lply and self.viewpunch then
                ViewPunch(self.ViewPunch1)
                self.viewpunch = nil
            end
        else
            self.Penetration = attacktype and self.PenetrationSecondary or self.PenetrationPrimary
            self.PenetrationSize = attacktype and self.PenetrationSizeSecondary or self.PenetrationSizePrimary
            
            owner:EmitSound(self.AttackSwing or "weapons/slam/throw.wav",50,math.random(95,105))
            
            if owner.organism then
                owner.organism.stamina.subadd = owner.organism.stamina.subadd + (attacktype and self.StaminaSecondary or self.StaminaPrimary) * 0.5 * math.Clamp(vellen / 200, 1, 1.25)
            end

            if !attacktype then
                if self.CustomAttack and self:CustomAttack() then
                    self:SetInAttack(false)

                    return
                end
            else
                if self.CustomAttack2 and self:CustomAttack2() then
                    self:SetInAttack(false)

                    return
                end
            end
        end
    end
    
    self.HitEnts = self.HitEnts or {owner, ent}
    
    local vellen = math.min(owner:GetVelocity():Length() * 0.05, 40)
    local eyetr = hg.eyeTrace(owner, (self:GetAttackLength() + vellen), ent, owner:GetAimVector())
    //debugoverlay.Line(eyetr.StartPos, eyetr.StartPos + eyetr.Normal * (self:GetAttackLength() + vellen), 3, color_white)
    //local ent = ents.Create("prop_physics")
    //ent:SetModel("models/props_interiors/pot01a.mdl")
    //ent:SetPos(eyetr.HitPos)
    //ent:Spawn()
    //ent:SetMoveType(MOVETYPE_NONE)
    //ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    if self:IsEntSoft(eyetr.Entity) then return eyetr end
    
    local trace

    local amt = 6

    for i = 0, amt do
        local normal = eyetr.Normal:Angle()

        normal:RotateAroundAxis(normal:Forward(), (attacktype and self.SwingAng2 or self.SwingAng) or -90)
        normal:RotateAroundAxis(normal:Up(), ((0.5 - inattackLength) * ((attacktype and self.AttackRads2 or self.AttackRads) or 65)))
        normal:RotateAroundAxis(normal:Up(), (i - amt * 0.5) * 1)
        
        --debugoverlay.Line(eyetr.StartPos, eyetr.StartPos + normal:Forward() * (self:GetAttackLength() + vellen), 3, color_white)

        local tr = {}

        tr.start = eyetr.StartPos
        tr.endpos = eyetr.StartPos + normal:Forward() * (self:GetAttackLength() + vellen)
        tr.filter = self.MultiDmg1 and {owner, ent} or self.HitEnts

        local size = 0.15

        tr.mins = -Vector(size, size, size)
        tr.maxs = Vector(size, size, size)

        trace = util.TraceLine(tr)

        //if SERVER then
        //    local vec = trace.Normal * math.min(self.DamagePrimary * 0.5, 20)
        //    vec[3] = 0
    //
        //    owner:SetVelocity(vec)
        //end

        if self:IsEntSoft(trace.Entity) then break end
    end
    
    return trace
end

function SWEP:PlayEffects(trace, attacktype)
    local owner = self:GetOwner()
    
    if self:IsEntSoft(trace.Entity) then
        owner:EmitSound(attacktype and self.Attack2HitFlesh or self.AttackHitFlesh,50)

        if self.DamageType == DMG_SLASH then
            util.Decal( "Blood", trace.HitPos + trace.HitNormal * 15, trace.HitPos - trace.HitNormal * 15, owner )
            util.Decal( "Blood", trace.HitPos + trace.HitNormal * 2, owner:GetPos(), trace.Entity )
        end
    elseif not self.AttackHitPlayed then
        self.AttackHitPlayed = true

        owner:EmitSound(self.AttackHit,50)
    end
end

function SWEP:BreakGlass(ent)
	if not IsValid(ent) then return end
    if string.find(ent:GetClass(),"break") and ent:GetBrushSurfaces()[1] and string.find(ent:GetBrushSurfaces()[1]:GetMaterial():GetName(),"glass") then
        //ent:EmitSound("physics/glass/glass_sheet_impact_hard"..math.random(3)..".wav")
        
        if math.random(1, 4) == 4 and ent:Health() < 250 then
            //ent:Fire("Break")
        end
        
        return true
    else
        return false
    end
end

function SWEP:BehindAttack(ent)
    local owner = self:GetOwner()

    return self:IsEntSoft(ent) and ent:IsPlayer() and (owner:GetAimVector():Dot(ent:GetAimVector()) > math.cos(math.rad(45)))
end

function SWEP:PunchPlayer(ent, attacktype, trnormal, dmg)
    if ent:IsPlayer() or ent:IsRagdoll() then 
        local ply = hg.RagdollOwner(ent) or ent

        if ply:IsPlayer() then
            local normal = Angle(0,0,0)
            normal:RotateAroundAxis(normal:Forward(),-((attacktype and self.SwingAng2 or self.SwingAng) or -90))
            normal:RotateAroundAxis(normal:Up(),-((attacktype and self.AttackRads2 or self.AttackRads) or 65))

            local dot = ply:GetAimVector():Dot(trnormal)
            
            local angrand = AngleRand(-5, 5)

            ply:ViewPunch((normal * -dot) * dmg / 30)
			if ply:OnGround() or ply.organism.superfighter then
           		ply:SetVelocity((trnormal:Angle() + normal):Forward() * -5 * dmg + trnormal * dmg * 10)
			end
        end
    end
end

SWEP.MinSensivity = 0.35

function SWEP:AlreadyHit(ent, trace, dmg)
    local ply = hg.RagdollOwner(ent)

    if IsValid(ply) and self.HitEnts[#self.HitEnts] == ply then
        return true
    else
        return false
    end
end

function SWEP:BlockingLogic(ent, mul, attacktype, trace)
    local ent = hg.RagdollOwner(ent) or ent

    if ent:IsPlayer() and !table.HasValue(self.HitEnts, ent) then
        local wep = ent:GetActiveWeapon()

        local owner = self:GetOwner()

        local pos, aimvec = hg.eye(ent)
        local pos2, aimvec2 = hg.eye(owner)

        if not aimvec or not aimvec2 then return 1 end

        local dist, posHit, distLine = util.DistanceToLine(pos + aimvec * 100, pos, trace.HitPos)

        //print(dist, distLine)

        local dmg = wep.DamagePrimary
        local selfdmg = self.DamagePrimary * 0.2

        if wep.GetBlocking and wep:GetBlocking() and wep.SetStartedBlocking and dist < 10 then
            local perfectblock = CurTime() - wep:GetStartedBlocking() < 0.5
            
            ent.organism.stamina.subadd = ent.organism.stamina.subadd + mul * math.Clamp(selfdmg / dmg, 0.1, 1) * selfdmg * (perfectblock and 0 or 1)

            //viewpunch the attacker maybe?
            self:PunchPlayer(owner, attacktype, -owner:GetAimVector(), selfdmg / 2)
            self:PunchPlayer(ent, attacktype, owner:GetAimVector(), selfdmg / 2)
            
            if perfectblock then
                ent:EmitSound("tasty/empty.wav")
            end
            
            //ent:EmitSound("physics/metal/metal_computer_impact_bullet3.wav") -- parry sound

            if wep.SetLastBlocked then
                wep:SetLastBlocked(CurTime())
            end

            return math.Clamp(selfdmg / dmg / math.Clamp(ent.organism.stamina[1] / (ent.organism.stamina.max * 0.66), 0.1, 1), 0.1, 1) * (perfectblock and 0 or 1)
        end
    end

    return 1
end

local matBlood = Material("zbattle/blood")
SWEP.blockSound = nil
SWEP.ShouldAttackOnce = true

function SWEP:IsClient()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:AddDecal()
    net.Start("bloody_decal_1")
    net.WriteEntity(self)
    net.SendPVS(self:GetPos())
end

function SWEP:CustomThink()
    local owner = self:GetOwner()
    local actwep = owner.GetActiveWeapon and owner:GetActiveWeapon()

	if SERVER and not owner:IsNPC() and owner.organism and (not owner.organism.canmove or ((owner.organism.stun - CurTime()) > 0) or (owner.organism.larm == 1 and owner.organism.rarm == 1)) and IsValid(actwep) and self == actwep then
		self:RemoveFake()
		
		hg.drop(owner)

		return
	end

    if self.CanSuicide and hg.KeyDown(owner, IN_ATTACK) and owner.suiciding and !self.SuicideStart then
        self.SuicideStart = CurTime()

        if SERVER then
            if self.SuicideFunc then
                self:SuicideFunc()
            else
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamageType(DMG_SLASH)

                local org = owner.organism
                local ent = hg.GetCurrentCharacter(owner)
                
                local ang = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Neck1")):GetAngles()
                local _, ang = LocalToWorld(vector_origin, Angle(0, -60, 0), vector_origin, ang)
                
                hg.organism.input_list["arteria"](org, 0, 5, dmgInfo, nil, -ang:Forward())
                
                for i = 1, 5 do
                    hg.organism.AddWoundManual(owner, 50, VectorRand(-2, 2), ang, "ValveBiped.Bip01_Neck1", CurTime() + math.Rand(0, 2))
                end

                owner:AddNaturalAdrenaline(math.max(2 - org.adrenaline, 0))
                org.fear = math.max(org.fear, 1)

                --timer.Simple(0, function()
                --    hg.organism.Vomit(owner, "player/flesh/flesh_bullet_impact_03.wav")
                --end)
                hook.Run("HomigradDamage", owner, dmgInfo, HITGROUP_HEAD, hg.GetCurrentCharacter(org.owner), 15)
                owner:EmitSound(self.SuicideSound or self.Attack2HitFlesh, 50)
                
                --timer.Simple(0.05, function()
                --    owner:ViewPunch(self.SuicidePunchAng or Angle(5, 10, 0))
                --end)
            end
        end
    end

    if self.SuicideStart and self.SuicideStart + self.SuicideTime < CurTime() then
        owner.suiciding = false
        self.cutthroat = CurTime()
        self.SuicideStart = nil
    end

    self:SetHold(owner.suiciding and self.SuicideHoldType or self.HoldType)

    if SERVER and owner.organism and owner.organism.rarmamputated then
        self:RemoveFake()
		
		hg.drop(owner)

        return
    end

    if owner.organism and owner.organism.larmamputated and self.TwoHanded then return end

    self:ThinkAdd()
    
    if CLIENT and owner ~= lply then return end

    //if SERVER then
        local oldblocking = self:GetBlocking()
        local blocking = ((CurTime() - self:GetStartedBlocking()) > 1 or oldblocking) and owner.organism and owner.organism.stamina[1] > 90 and !self:GetInAttack() and (self:GetAttackTime() - CurTime() - 0) < 0 and ((self:GetLastBlocked() + 3) < CurTime()) and self:CanBlock() and hg.KeyDown(owner, IN_ATTACK2)
        --if self:CutDuct() then return end
        self:SetBlocking(blocking)
        
        if self:GetBlocking() and !oldblocking then
            self:SetStartedBlocking(CurTime())
        end
    //end

	if self:GetBlocking() then
		if not self.blockSound then
			sound.Play("pwb2/weapons/matebahomeprotection/mateba_cloth.wav", self:GetPos(), 65)
			self.blockSound = true
		end
	else
		if self.blockSound then
			sound.Play("pwb2/weapons/mac11/draw.wav", self:GetPos(), 55)
		end
		self.blockSound = nil
	end

    if self:GetInAttack() then
        local inattack1 = math.max(self:GetLastAttack() - CurTime(), 0) / self.AttackTime
        local inattack2 = math.max(self:GetLastAttack() - CurTime(), 0) / self.Attack2Time

        local inattackL1 = math.max(self:GetAttackTime() - CurTime(), 0) / self.AttackTimeLength
        local inattackL2 = math.max(self:GetAttackTime() - CurTime(), 0) / self.Attack2TimeLength
        
        local ent = hg.GetCurrentCharacter(owner)
        local vellen = ent:GetVelocity():Length()

        local mul = self:MultiplyDMG(owner, ent, vellen, 1)
        
        if self:GetAttackType() == 1 and inattack1 == 0 then
            owner:LagCompensation(true)
            
            local trace = self:Attack(owner, ent, vellen, false, inattackL1)

            owner:LagCompensation(false)

            if SERVER and (owner:OnGround() or owner.organism.superfighter) then -- ранбуст для супербойцов
                local vec = owner:GetAimVector() * math.min(self.DamagePrimary * 0.5, 20)
                vec[3] = 0

                owner:SetVelocity(vec)
            end

            if !trace then return end

            local ent = trace.Entity

            local shouldhit = (IsValid(ent) or ent:IsWorld())

            local dmg = math.random(self.DamagePrimary - 3, self.DamagePrimary + 3)

            if !shouldhit then
                goto meleeskip1
            end

            if SERVER and self:IsEntSoft(ent) and self.HitEnts[#self.HitEnts] ~= ent then
                self:AddDecal()
            end

            if CLIENT then goto meleeskip1 end

            ent:PrecacheGibs()

            mul = mul * (self:BehindAttack(ent) and 2 or 1)
            mul = mul * self:BlockingLogic(ent, mul, false, trace)

            dmg = dmg * mul

            if self:AlreadyHit(ent, trace) then
                goto meleeskip1
            end
            
            if self.HitEnts[#self.HitEnts] ~= ent then
                self:PlayEffects(trace, false)
            end
            
            if self.MultiDmg1 or (self.HitEnts[#self.HitEnts] ~= ent) then
                //if self:BreakGlass(ent) then
                    //goto meleeskip1
                //end

                if self.MultiDmg1 or not self:IsEntSoft(ent) then
                    dmg = dmg / (self.AttackRads * self.AttackTimeLength)
                else
                    dmg = dmg / 1.5
                end
                                
                local dmginfo = DamageInfo()

                dmginfo:SetAttacker(owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamage(dmg)
                dmginfo:SetDamageForce(trace.Normal * dmg)
                dmginfo:SetDamageType(ent:GetClass() == "func_breakable_surf" and DMG_SLASH or self.DamageType)
                dmginfo:SetDamagePosition(trace.HitPos)
                
                self.slash = self.MultiDmg1
                ent:TakeDamageInfo(dmginfo)
                self.attackedOnce = true
                self.slash = nil
                
                hg.AddForceRag(ent, trace.PhysicsBone or 0, trace.Normal * math.min(dmg, 25) * 400, 0.5)

                self:PunchPlayer(ent, false, trace.Normal, dmg)

                local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone or 0)

                if IsValid(phys) then
                    phys:ApplyForceOffset(trace.Normal * math.min(dmg, 25) * 400, trace.HitPos)
                end

                self:PrimaryAttackAdd(ent, trace)
            end

            ::meleeskip1::
            
            if not ent:IsWorld() and self:IsEntSoft(ent) then
                self.HitEnts[#self.HitEnts + 1] = ent
            end

            self.FirstAttackTick = true

            if inattackL1 == 0 then
                self:SetInAttack(false)
                self.HitEnts = nil
                self.FirstAttackTick = false
                self.AttackHitPlayed = false
            end
        elseif self:GetAttackType() == 2 and inattack2 == 0 then
            owner:LagCompensation(true)
            
            local trace = self:Attack(owner, ent, vellen, true, inattackL2)

            owner:LagCompensation(false)

            if !trace then return end

            local ent = trace.Entity

            local shouldhit = (IsValid(ent) or ent:IsWorld())

            local dmg = math.random(self.DamageSecondary - 3, self.DamageSecondary + 3)

            if !shouldhit then
                goto meleeskip2
            end

            if SERVER and self:IsEntSoft(ent) and self.DamageType == DMG_SLASH and self.HitEnts[#self.HitEnts] ~= ent then
                self:AddDecal()
            end

            if CLIENT then goto meleeskip2 end

            ent:PrecacheGibs()

            if SERVER then -- ранбуст для супербойцов and (ent:OnGround() or ent.organism and ent.organism.superfighter)
                local vec = trace.Normal * math.min(self.DamageSecondary  * 0.5, 20)
                vec[3] = 0
                
                ent:SetVelocity(vec)
            end

            mul = mul * (self:BehindAttack(ent) and 2 or 1)
            mul = mul * self:BlockingLogic(ent, mul, true, trace)

            dmg = dmg * mul

            if self:AlreadyHit(ent, trace) then
                goto meleeskip2
            end

            if self.HitEnts[#self.HitEnts] ~= ent then
                self:PlayEffects(trace, true)
            end

            if self.MultiDmg2 or (self.HitEnts[#self.HitEnts] ~= ent) then
                //if self:BreakGlass(ent) then
                    //goto meleeskip2
                //end

                if self.MultiDmg2 or not self:IsEntSoft(ent) then
                    dmg = dmg / math.max(1,self.AttackRads2 * self.Attack2TimeLength)
                end

                local dmginfo = DamageInfo()

                dmginfo:SetAttacker(owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamage(dmg)
                dmginfo:SetDamageForce(trace.Normal * dmg)
                dmginfo:SetDamageType(ent:GetClass() == "func_breakable_surf" and DMG_SLASH or self.DamageType)
                dmginfo:SetDamagePosition(trace.HitPos)

                self.slash = self.MultiDmg2
                --print(dmg)
                ent:TakeDamageInfo(dmginfo)
                self.attackedOnce = true
                self.slash = nil

                local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone or 0)

                hg.AddForceRag(ent, trace.PhysicsBone or 0, trace.Normal * math.min(dmg, 25) * 400, 0.5)

                self:PunchPlayer(ent, true, trace.Normal, dmg)

                if IsValid(phys) then
                    phys:ApplyForceOffset(trace.Normal * math.min(dmg, 25) * 400, trace.HitPos)
                end

                self:SecondaryAttackAdd(ent, trace)
            end

            ::meleeskip2::

            if not ent:IsWorld() and self:IsEntSoft(ent) then
                self.HitEnts[#self.HitEnts + 1] = ent
            end

            self.FirstAttackTick = true

            if inattackL2 == 0 then
                self:SetInAttack(false)
                self.HitEnts = nil
                self.FirstAttackTick = false
                self.AttackHitPlayed = false
            end
        end
    else
        self.attackedOnce = nil
    end

end

function SWEP:PrimaryAttackAdd(ent)
end

function SWEP:SecondaryAttackAdd(ent)
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 45
SWEP.AttackRads2 = 65

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local ply = self:GetOwner()

    if self.cutthroat and self.cutthroat + 1 > CurTime() then return end
    if self.CanSuicide and ply.suiciding then return end

    if ply.organism and ply.organism.larmamputated and self.TwoHanded then return end
    if !hg.KeyDown(self:GetOwner(), IN_ATTACK2) and not self:CanPrimaryAttack() then return end
    
    if self:GetLastBlocked() + 1 > CurTime() then
        //return
    end

    if self:GetBlocking() then
        self:SecondaryAttack(true)

        return
    end
    
    local ply = self:GetOwner()
    local ent = hg.GetCurrentCharacter(ply)

    if !self:InUse() then return end
    if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return end
    
    local mul = 1 / math.Clamp((180 - self:GetOwner().organism.stamina[1]) / 90, 1, 2)

    
    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self:PlayAnim("attack", self.AnimTime1 / mul,false,nil,false,false)
    self:SetAttackType(1)
    self:SetLastAttack(CurTime() + self.AttackTime / mul)
    self:SetAttackTime(self:GetLastAttack() + (self.AttackTimeLength / mul))
    self:SetAttackLength(self.AttackLen1)
    self:SetAttackWait(self.WaitTime1 / mul)
    self:SetInAttack(true)

    if CLIENT and not self:IsLocal() and ply.AnimRestartGesture then
        self:GetOwner():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
    end

    self.viewpunch = true
end

function SWEP:CutDuct()
    if self.DamageType ~= DMG_SLASH or CLIENT then return end
    
    local ent = hg.eyeTrace(self:GetOwner()).Entity
    
    if IsValid(ent) then
        if hgIsDoor(ent) and ent.LockedDoor then
            ent.LockedDoor = ent.LockedDoor - FrameTime() * 10
            
            if (ent.SoundTime or 0) < CurTime() then
                ent.SoundTime = CurTime() + 5

                self:GetOwner():EmitSound("tapetear.mp3",65)
                self:PlayAnim("duct_cut",5)
            end

            if ent.LockedDoor <= 0 then
                if !ent.LockedDoorNail and !ent.LockedDoorMap then ent:Fire("unlock", "", 0) end
                ent.LockedDoor = nil
            end
            
            return true
        end

        if ent.DuctTape and next(ent.DuctTape) then
            if (ent.SoundTime or 0) < CurTime() then
                ent.SoundTime = CurTime() + 5

                self:GetOwner():EmitSound("tapetear.mp3",65)
                self:PlayAnim("duct_cut",5)
            end
            
            local key = next(ent.DuctTape)
            local duct = ent.DuctTape[key]
            
            duct[2] = duct[2] - FrameTime()
            
            if duct[2] <= 0 then
                if IsValid(duct[1]) then
                    duct[1]:Remove()
                    duct[1] = nil
                end
                
                ent.DuctTape[key] = nil
            end

            return true
        end
    end
end

function SWEP:CanBlock()
    return true
end

function SWEP:SecondaryAttack(override)
    local ply = self:GetOwner()
    if ply.organism and ply.organism.larmamputated and self.TwoHanded then return end

    if self:CutDuct() then
        return
    end

    if self:CanBlock() and not override then
        return 
    end

    if self:GetLastBlocked() + 1 > CurTime() then
        return
    end

    if not self:CanSecondaryAttack() then
        
        return
    end

    if not IsFirstTimePredicted() then return end

    local ent = hg.GetCurrentCharacter(ply)

    if !self:InUse() then return end
    if (hg.KeyDown(ply, IN_USE) and not IsValid(ply.FakeRagdoll)) then return end
    if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return end

    local mul = 1 / math.Clamp((180 - ply.organism.stamina[1]) / 90, 1, 2)

    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self:PlayAnim("attack2",self.AnimTime2 / mul,false,nil,false,false)
    self:SetAttackType(2)
    self:SetLastAttack(CurTime() + self.Attack2Time / mul)
    self:SetAttackTime( self:GetLastAttack() + (self.Attack2TimeLength / mul) )
    self:SetAttackLength(self.AttackLen2)
    self:SetAttackWait(self.WaitTime2 / mul)
    self:SetInAttack(true)
    
    if CLIENT and not self:IsLocal() and ply.AnimRestartGesture then
        ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
    end

    self.viewpunch = true
end

function SWEP:InitAdd()
end

if CLIENT then
	SWEP.HowToUseInstructions = "<font=ZCity_Tiny>"..string.upper( (input.LookupBinding("+use") or "BIND YOUR +USE KEY PLEASE. WRITE \"bind e +use\" IN CONSOLE FOR THE LOVE OF GOD") ).." to pickup</font>"
end

local util = util
function SWEP:Initialize()
    self.attackanim = 0
    self.sprintanim = 0
    self.animtime = 0
    self.animspeed = 1
    self.reverseanim = false
    self:PlayAnim("idle",10,true)

	if CLIENT then
		self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>".. self.PrintName .."</font>\n<font=ZCity_SuperTiny><colour=125,125,125>".. self.HowToUseInstructions .."</colour></font>",450)
	end

    if self:GetClass() == "weapon_melee" then
        self.ImmobilizationMul = 2
        self.StaminaMul = 0.5
        self.BreakBoneMul = 0.5
        self.ShockMultiplier = 0.5
        self.PainMultiplier = 2

        self.CanSuicide = true

        function self:Reload()
            if SERVER then
                if self:GetOwner():KeyPressed(IN_ATTACK) then
                    self:SetNetVar("mode", not self:GetNetVar("mode"))
                    self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
                    --self.Swing = self:GetNetVar("mode")
                    --self.UpSwing = not self:GetNetVar("mode")
                end
            end
        end

        function self:CustomBlockAnim(addPosLerp, addAngLerp)
            addPosLerp.z = addPosLerp.z + (self:GetBlocking() and 5 or 0)
            addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 2 or 0)
            addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -18 or 0)
            addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 20 or 0)
            addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 60 or 0)
            
            return true
        end

        function self:CanPrimaryAttack()
            if hg.KeyDown(self:GetOwner(), IN_RELOAD) then return end
            if not self:GetNetVar("mode") then
                return true
            else
                self.allowsec = true
                self:SecondaryAttack(true)
                self.allowsec = nil
                return false
            end
        end
        
        function self:CanSecondaryAttack()
            return self.allowsec and true or false
        end
    end

    self:SetAttackLength(60)
    self:SetAttackWait(0)
    if self.modelscale then
        self:SetModelScale(self.modelscale)
        self:Activate()
    end
    self:SetHold(self.HoldType)
    
    util.PrecacheSound(self.AttackSwing)
    util.PrecacheSound(self.AttackHit)
    util.PrecacheSound(self.Attack2Hit)
    util.PrecacheSound(self.AttackHitFlesh)
    util.PrecacheSound(self.Attack2HitFlesh)
    util.PrecacheSound(self.DeploySnd)

    self:InitAdd()
end

function SWEP:IsLocal()
	if SERVER then return end
	return not ((self:GetOwner() ~= lply) or (lply ~= GetViewEntity()))
end

SWEP.tries = 10

if SERVER then
    util.AddNetworkString("melee_attack")
elseif CLIENT then
    net.Receive("melee_attack",function()
        local tbl = net.ReadTable()
        local ent = net.ReadEntity()
        local sendtoclient = net.ReadBool()

        if IsValid(ent) and ent.PlayAnim then
            ent:PlayAnim(tbl.anim,tbl.time,tbl.cycling,tbl.callback,tbl.reverse)

            if (tbl.anim == "attack" or tbl.anim == "attack2") and ent:GetOwner().AnimRestartGesture and IsValid(ent:GetOwner()) and not ent:GetOwner():IsWorld() then
                if !ent:IsLocal() then
                    ent:GetOwner():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
                end
            end
        end
    end)
end

function SWEP:PlayAnim(anim, time, cycling, callback, reverse, sendtoclient)
    if SERVER then
        sendtoclient = sendtoclient or false
        net.Start("melee_attack")
            local netTbl = {
                anim = anim,
                time = time,
                cycling = cycling,
                callback = callback,
                reverse = reverse
            }
            net.WriteTable(netTbl) 
            net.WriteEntity(self)
            net.WriteBool(sendtoclient)
        net.SendPVS(self:GetPos())
    return end
    if not IsValid(self:GetWM()) or not IsValid(self:GetOwner()) or self:GetOwner():GetActiveWeapon() ~= self then
		self.tries = self.tries - 1
		if self.tries > 0 then
			timer.Simple(0.01,function()
                if not IsValid(self) then return end
				self:PlayAnim(anim,time,cycling,callback,reverse)
			end)
		end
		return
	end
    self.tries = 10

    if self:GetWM():GetModel() ~= self.WorldModelReal then self:GetWM():SetModel(self.WorldModelReal) end
    
    self:GetWM():SetSequence(self.AnimList[anim] or anim)
    self.animtime = CurTime() + time
    self.animspeed = time
    self.cycling = cycling
    self.reverseanim = reverse
    if callback then
        self.callback = callback
    end
end

function SWEP:SetFakeGun(ent)
	self:SetNWEntity("fakeGun", ent)
	self.fakeGun = ent
end

function SWEP:RemoveFake()
	if not IsValid(self.fakeGun) then return end
	self.fakeGun:Remove()
	self:SetFakeGun()
end

local function GetPhysBoneNum(ent,string)
	if not IsValid(ent) then return 7 end
	return ent:TranslateBoneToPhysBone(ent:LookupBone(string))
end

function SWEP:CreateFake(ragdoll)
	if IsValid(self:GetNWEntity("fakeGun")) then return end
	if not IsValid(ragdoll) then return end
	local ent = ents.Create("prop_physics")
    ent.notprop = true
	local physbonerh = GetPhysBoneNum(ragdoll,"ValveBiped.Bip01_R_Hand")
	local rh = ragdoll:GetPhysicsObjectNum(physbonerh)

	ent:SetPos(rh:GetPos())
	ent:SetModel(self.WorldModel)
	ent:Spawn()
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:GetPhysicsObject():SetMass(0)
    ent:SetNoDraw(true)
    ent.dontPickup = true
	ent.fakeOwner = self
	ragdoll:DeleteOnRemove(ent)
	ragdoll.fakeGun = ent
	if IsValid(ragdoll.ConsRH) then ragdoll.ConsRH:Remove() end
	self:SetFakeGun(ent)
	ent:CallOnRemove("homigrad-swep", self.RemoveFake, self)

	ent:SetNoDraw(true)
end

function SWEP:NPCThink()
    local ent = self:GetOwner()
    self:SetWeaponHoldType("melee")
    
    if ent:GetClass() == "npc_metropolice" then
        self:SetWeaponHoldType("smg")
    end
    
    --ent:Fire( "GagEnable" )
    
    if ent:GetClass() == "npc_citizen" then
        --ent:Fire( "DisableWeaponPickup" )
    end
    
    local enemy = ent:GetEnemy()
    if not enemy then return end

    local dist = enemy:GetPos():Distance(ent:GetPos())

    if enemy and dist > 85 then
        --ent:SetSchedule(SCHED_CHASE_ENEMY)
    end

    if dist < 85 and (self.LastNPCAttack or 0) < CurTime() then
        local dmg = math.random(self.DamagePrimary - 3, self.DamagePrimary + 3)
        
        local tr = {}
        tr.start = ent:EyePos()
        tr.endpos = enemy.EyePos and enemy:EyePos() or enemy:GetPos()
        tr.filter = ent

        local trace = util.TraceLine(tr)

        if IsValid(trace.Entity) and trace.Entity == enemy then
            self.LastNPCAttack = CurTime() + self.AnimTime1
			ent:EmitSound(self.AttackSwing, 70)

            ent:SetSchedule(SCHED_MELEE_ATTACK1)

            local dmginfo = DamageInfo()
            dmginfo:SetAttacker(ent)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamage(dmg)
            dmginfo:SetDamageForce(trace.Normal * dmg * 1)
            dmginfo:SetDamageType(self.DamageType)
            dmginfo:SetDamagePosition(trace.HitPos)
            trace.Entity:TakeDamageInfo(dmginfo)
			ent:EmitSound(self.AttackHitFlesh, 60)
        end
    end
end

function SWEP:GetNPCRestTimes()
	return self.AnimTime1, self.AnimTime1
end

function SWEP:GetCapabilities()
    if (self.NPCThinktime or 0) < CurTime() then self.NPCThinktime = CurTime() + 0.01 self:NPCThink() end
    return bit.bor( CAP_WEAPON_MELEE_ATTACK1, CAP_MOVE_GROUND )
end

function SWEP:SetupWeaponHoldTypeForAI( t )
	self.ActivityTranslateAI = {}
	if ( t == "melee" ) then
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_HL2MP_IDLE_KNIFE
		
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		
		return
	end
	
	if ( t == "smg" ) then
	
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ] 				= ACT_MELEE_ATTACK_SWING
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_MELEE_ATTACK_SWING
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_RANGE_ATTACK_THROW
		self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		
		return
	end
	
	if ( t == "shotgun" ) then
		
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_HL2MP_IDLE_KNIFE
		
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_SMALL_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_BIG_FLINCH ] 				= ACT_RANGE_ATTACK_PISTOL
		
		return
	end
	
	if ( t == "pistol") then 
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_RELAXED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_STIMULATED ] 		= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_IDLE_AIM_AGITATED ] 			= ACT_HL2MP_IDLE_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ]          = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK1 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_MELEE_ATTACK2 ]              = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		self.ActivityTranslateAI [ ACT_SPECIAL_ATTACK1 ] 			= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ]              = ACT_IDLE_SHOTGUN
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_IDLE_SHOTGUN
		
		self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM ]				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_RELAXED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_STIMULATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI[ ACT_WALK_AIM_AGITATED ]		= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= ACT_HL2MP_WALK_KNIFE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= ACT_HL2MP_WALK_KNIFE
		
		self.ActivityTranslateAI[ ACT_RUN_RELAXED ]			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_STIMULATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI[ ACT_RUN_AGITATED ]		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH ] 				= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_CROUCH_AIM ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN ] 						= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_HL2MP_RUN_KNIFE
		self.ActivityTranslateAI [ ACT_MP_RUN ] 					= ACT_HL2MP_RUN_KNIFE
		
		return
	end
end


--[[function SWEP:CustomAttack2() -- prikol
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()

    ent.localshit = Vector(0,0,0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = self.DamagePrimary * 0.7
    ent.MaxSpeed = 1300
    ent.DamageType = self.DamageType
    ent.AttackHit = "Concrete.ImpactHard"
    ent.AttackHitFlesh = "Flesh.ImpactHard"
    ent.noStuck = true

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:ViewPunch(self.ViewPunch1 * 0.6)
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end]]