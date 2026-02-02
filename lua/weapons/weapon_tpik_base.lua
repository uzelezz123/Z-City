if SERVER then AddCSLuaFile() end
SWEP.PrintName = "TPIK Base"
SWEP.Instructions = "Tpik Base"
SWEP.Category = "ZCity Anims items"
SWEP.Instructions = ":3 если вы скриптхукнули знайте вы для нас вонючка."
SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.Slot = 1

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/weapons/zcity/chands_gestures.mdl"
SWEP.WorldModelReal = "models/weapons/zcity/chands_gestures.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "slam"

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

SWEP.supportTPIK = true

SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(0,0,0)

SWEP.animtime = 0
SWEP.animspeed = 0
SWEP.cycling = false
SWEP.reverseanim = false

SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
    -- ["AnimName"] = { "animrealname", number iTime, boolean bCycle, function fCallback, boolean bReverse }
}

if CLIENT then
	--SWEP.WepSelectIcon = Material("vgui/hud/tfa_iw7_tactical_knife")
	--SWEP.IconOverride = "vgui/hud/tfa_iw7_tactical_knife.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true

SWEP.sprint_ang = Angle(20,0,0)
SWEP.sprint_pos = Vector(0,0,0)

SWEP.HoldPos = Vector(0,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.basebone = 1

SWEP.WorkWithFake = true
SWEP.visualweight = 1.2

function SWEP:SetHold(value)
    self:SetWeaponHoldType(value)
    self:SetHoldType(value)
    self.holdtype = value
end

SWEP.modelscale = 1
SWEP.modelscale2 = 1
if CLIENT then

    local vecPochtiZero = Vector(0.0001, 0.0001, 0.0001)

    function PrintBones( entity )
        for i = 0, entity:GetBoneCount() - 1 do
            print( i, entity:GetBoneName( i ) )
        end
    end

	function SWEP:GetWM()
        self.worldModel = IsValid(self.worldModel) and self.worldModel or ClientsideModel(self.WorldModel)
        self.worldModel:SetNoDraw(true)
		return self.worldModel
	end

    function SWEP:DrawWorldModel()
        if not IsValid(self:GetOwner()) then
            self:DrawWorldModel2()
        end
    end

	function SWEP:DrawWorldModel2()
		local owner = self:GetOwner()

        if not IsValid(self.worldModel) then
            self.worldModel = ClientsideModel(self.WorldModel)
            local model = self.worldModel
            self.worldModel:SetSkin(self.WMSkin or 0)
            self:CallOnRemove("remove_worldmodel1",function()
                if IsValid(model) then
                    model:Remove()
                    model = nil
                end
            end)
        end

        self.worldModel:SetNoDraw(true)
        if IsValid(owner) and (not owner.shouldTransmit or owner.NotSeen) then return end
        if not IsValid(owner) and (not self.shouldTransmit or self.NotSeen) then return end

		local WorldModel = self.worldModel

        self.worldModel:SetModelScale(self.modelscale2)
        
        local ent = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner

        if (IsValid(owner)) and (ent == owner or hg.KeyDown(owner,IN_USE) or (owner:GetNetVar("lastFake",0) > CurTime())) then
            local timing = 0
            if not self.cycling then
                timing = (1 - math.Clamp((self.animtime - CurTime()) / self.animspeed,0,1))
                timing = self.reverseanim and (1 - timing) or timing
                timing = self.CustomTiming and self:CustomTiming() or timing
                WorldModel:SetCycle(timing)
                
                if self.callback and timing == ((not self.reverseanim) and 1 or 0) then
                    self.callback(self)
                    self.callback = nil
                end
            else
                timing = ((CurTime() - (self.animtime - self.animspeed))%self.animspeed) / self.animspeed
                WorldModel:SetCycle(timing)
            end

            self.sprintanim = qerp(0.02 * FrameTime() / engine.TickInterval(),self.sprintanim or 0,(owner.IsSprinting and owner:IsSprinting()) and 1 or 0)
            
			local tr = hg.eyeTrace(owner,60)
			local ang = owner:EyeAngles()
            if not tr then return end

            if WorldModel:GetModel() ~= self.WorldModelReal then WorldModel:SetModel(self.WorldModelReal) end

			local pos = tr.StartPos + ang:Forward() * (self.HoldPos[1] - 4) + ang:Right() * self.HoldPos[2] + ang:Up() * self.HoldPos[3]
			--pos = pos + ang:Forward() * self.AttackPos[1] * self.attackanim + ang:Right() * self.AttackPos[2] * self.attackanim + ang:Up() * self.AttackPos[3] * self.attackanim
			local ang = owner:EyeAngles()
            local _,ang = LocalToWorld(vector_origin,(self.HoldAng or angle_zero),vector_origin,ang)
			
			local pos, ang = LocalToWorld(self.sprint_pos * self.sprintanim,self.sprint_ang * self.sprintanim,pos,ang)

			if self.HoldClampMax ~= nil and self.HoldClampMin ~= nil then
				local headAng = owner:EyeAngles()
				ang.x = math.max(math.min(headAng.x,self.HoldClampMax),self.HoldClampMin)
			end

			WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang)
		else
            if WorldModel:GetModel() ~= self.WorldModel then WorldModel:SetModel(self.WorldModel) end
			
            WorldModel:SetRenderOrigin(self:GetPos())
			WorldModel:SetRenderAngles(self:GetAngles())
		end

        if IsValid(owner) and not (ent == owner or hg.KeyDown(owner,IN_USE) or (owner:GetNetVar("lastFake",0) > CurTime())) then
            local bon = ent:LookupBone("ValveBiped.Bip01_R_Hand")
            if not bon then return end
            local mat = ent:GetBoneMatrix(bon)
            if not mat then return end
            local pos,ang = LocalToWorld(self.lpos or vector_origin,self.lang or angle_zero,mat:GetTranslation(),mat:GetAngles())
            WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang)
        end

        WorldModel:SetupBones()
        
        if IsValid(self.worldModel2) then
            self.worldModel2:SetNoDraw(true)
        end

        if not self.WorldModelExchange or self.HideMeshBones then
            if self.HideMeshBones then
                for k,v in ipairs(self.HideMeshBones) do
                    if not WorldModel:LookupBone(v) then continue end
                    --print(v)
                    --WorldModel:ManipulateBoneScale(WorldModel:LookupBone(v),vecPochtiZero)
                    local matrix = WorldModel:GetBoneMatrix(WorldModel:LookupBone(v))
                    if self.HideMeshOnlyScale and self.HideMeshOnlyScale[v] then
                        matrix:SetScale(vecPochtiZero)
                    else
                        matrix:Zero()
                    end
                    WorldModel:SetBoneMatrix(WorldModel:LookupBone(v),matrix)
                end
            end
            WorldModel:DrawModel()
        end

        if IsValid(self.worldModel) and self.WorldModelExchange then
            if not IsValid(self.worldModel2) then
                self.worldModel2 = ClientsideModel(self.WorldModelExchange)
                local model = self.worldModel2
                self:CallOnRemove("remove_worldmodel2",function()
                    if IsValid(model) then
                        model:Remove()
                        model = nil
                    end
                end)
            end

            local pos,ang = self.worldModel:GetPos(),self.worldModel:GetAngles()
            local huy = self.worldModel:GetModel() == self.WorldModelReal
            
            if IsValid(self:GetOwner()) or self.DontChangeDropped then
                pos,ang = LocalToWorld(self.weaponPos,self.weaponAng,huy and self.worldModel:GetBoneMatrix(self.basebone or 1):GetTranslation() or self.worldModel:GetPos(),huy and self.worldModel:GetBoneMatrix(self.basebone or 1):GetAngles() or self.worldModel:GetAngles())
            end
            self.worldModel2:SetModelScale(self.modelscale)
            self.worldModel2:SetRenderOrigin(pos)
            self.worldModel2:SetRenderAngles(ang)
            self.worldModel2:SetupBones()
            --print(self.worldModel:GetManipulateBoneScale(self.basebone or 1))
            if self.worldModel:GetManipulateBoneScale(self.basebone or 1) != vector_origin then
                self.worldModel2:DrawModel()
            end
        end

        if self:IsLocal() and self.isTPIKBase then
            local camBone = WorldModel:LookupBone(self.ViewBobCamBone or "Camera_animated") or WorldModel:LookupBone("ValveBiped.Bip01_R_Hand")
            if camBone then
                local gAngles = WorldModel:GetBoneMatrix(camBone):GetAngles()
                local _,gAngles = WorldToLocal(vector_origin,gAngles, WorldModel:GetPos(), WorldModel:GetBoneMatrix(WorldModel:LookupBone(self.ViewBobCamBase or "") or 0):GetAngles())
                self.OldAngPunch = self.OldAngPunch or gAngles
                ViewPunch( ( self.OldAngPunch - gAngles )/(self.ViewPunchDiv or 100) )
                self.OldAngPunch = gAngles
            end
        end
		
		if(self.DrawPostWorldModel)then
			self:DrawPostWorldModel()
		end
	end
end
SWEP.isTPIKBase = true
--hook.Add("PostDrawPlayerRagdoll","ragdollhuytpik",function(ent,ply)
function hg.RenderTPIKBase(ent, ply, wep)
    if wep.DrawWorldModel2 then
        wep:DrawWorldModel2()
    else
        wep:DrawWorldModel()
    end
end
--end)

local host_timescale = game.GetTimeScale

function SWEP:Camera(eyePos, eyeAng, view, vellen)
    self:SetHandPos()
    self:DrawWorldModel2()

    local owner = self:GetOwner()

	self.walkinglerp = Lerp(hg.lerpFrameTime2(0.1),self.walkinglerp or 0,((self.DisableWalkBob or owner:InVehicle()) and 0) or hg.GetCurrentCharacter(owner):GetVelocity():LengthSqr())
	self.huytime = self.huytime or 0
	local walk = math.Clamp(self.walkinglerp / 10000,0,1)
	
	self.huytime = self.huytime + walk * FrameTime() * 8 * host_timescale()
	if owner:IsSprinting() then
		--walk = walk * 2
	end

	local huy = self.huytime
	
	local x,y = math.cos(huy) * math.sin(huy) * walk * 1,math.sin(huy) * walk * 1
	eyePos = eyePos - eyeAng:Up() * walk
	eyePos = eyePos - eyeAng:Up() * x * 0.5
	eyePos = eyePos - eyeAng:Right() * y * 0.5

    view.origin = (eyePos - (angle_difference_localvec * 150) - (position_difference * 0.5))
    
    return view
end

function SWEP:CanPrimaryAttack()
    return self:GetOwner():IsSprinting()
end

function SWEP:SetHandPos(noset)
	local ply = self:GetOwner()

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

	self.rhandik = self.setrh
	self.lhandik = self.setlh and (ply:GetTable().ChatGestureWeight < 0.1)

    local rhmat, lhmat = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Hand")), ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_L_Hand"))

	ply.rhold = rhmat
	ply.lhold = lhmat

	if self.lhandik and (ent == ply or hg.KeyDown(ply,IN_USE) or (ply:GetNetVar("lastFake",0) > CurTime())) and hg.CanUseLeftHand(ply) then
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
	end

	local bones = hg.TPIKBonesRH

	if self.rhandik and (ent == ply or hg.KeyDown(ply,IN_USE) or (ply:GetNetVar("lastFake",0) > CurTime())) then
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

    if self.PostSetHandPos then
        self:PostSetHandPos()
    end

    --return rhmat,lhmat
end

function SWEP:SetupDataTables()
end

function SWEP:OwnerChanged()
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:PlayAnim("deploy")
        self:SetHold(self.HoldType)
        timer.Simple(0,function() self.picked = true end)
    else
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
    self:PlayAnim("deploy")
    self:SetHold(self.HoldType)
	
	return true
end

function SWEP:Holster(wep)
    --self:SetInAttack(false)
    return true
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or hg.RagdollOwner(ent) or ent:IsRagdoll()
end

function SWEP:ThinkAdd()
end

function SWEP:Think()
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()

    self:SetHold(self.HoldType)

    self:ThinkAdd()
end

function SWEP:PrimaryAttackAdd(ent)
end

function SWEP:SecondaryAttackAdd(ent)
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:InitAdd()
end

function SWEP:Initialize()

    if self.modelscale then
        self:SetModelScale(self.modelscale)
        self:Activate()
    end
    self:SetHold(self.HoldType)

    self:InitAdd()
end

function SWEP:IsLocal()
	if SERVER then return end
	return not ((self:GetOwner() ~= LocalPlayer()) or (LocalPlayer() ~= GetViewEntity()))
end
SWEP.tries = 10

if SERVER then
    util.AddNetworkString("melee_attack2")
elseif CLIENT then
    net.Receive("melee_attack2",function()
        local tbl = net.ReadTable()
        local ent = net.ReadEntity()
        local sendtoclient = net.ReadBool()
        if IsValid(ent) and ent.PlayAnim and ( sendtoclient and sendtoclient or !ent:IsLocal()) then
            ent:PlayAnim(tbl.anim,tbl.time,tbl.cycling,tbl.callback,tbl.reverse)
            --if tbl.anim == "attack" or tbl.anim == "attack2" and ent:GetOwner().AnimRestartGesture then
            --    ent:GetOwner():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM, true)
            --end
        end
    end)
end

function SWEP:PlayAnim(anim,time,cycling,callbackFuncName,reverse,sendtoclient)
    if SERVER then
        sendtoclient = true
        net.Start("melee_attack2")
            local netTbl = {
                anim = anim,
                time = time,
                cycling = cycling,
                callback = callbackFuncName,
                reverse = reverse
            }
            net.WriteTable(netTbl) 
            net.WriteEntity(self)
            net.WriteBool(sendtoclient)
        net.SendPVS(self:GetPos())

        local tAnim = self.AnimList[anim] or {}
        --self:GetWM():SetSequence(tAnim[1] or anim)
        --self.animtime = CurTime() + ( time or tAnim[2] or 1)
        self.seq = tAnim and tAnim[1] or anim
        self.anim = anim
        self.animspeed = time or tAnim[2] or 1
        --self.cycling = cycling or (tAnim[3] ~= nil and tAnim[3])
        --self.reverseanim = reverse or (tAnim[4] ~= nil and tAnim[4])

        if self[callbackFuncName] or tAnim[5] then
            local timerAnim = self.animspeed - (tAnim[6] or self.CallbackTimeAdjust or 0)
            self.CallbackTime = CurTime() + timerAnim
            self.callback = self[callbackFuncName] or tAnim[5]
            
            hook.Add("Think","AnimCallback"..self:EntIndex(), function()
                if IsValid(self) and IsValid(self:GetOwner()) and self.CallbackTime < CurTime() then
                    hook.Remove("Think","AnimCallback"..self:EntIndex())
                    self.callback(self)
                end
            end)
        end

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

    local mdl = self:GetWM()
    if mdl:GetModel() ~= self.WorldModelReal then mdl:SetModel(self.WorldModelReal) end
    local tAnim = self.AnimList[anim] or {}
    self.seq = tAnim and tAnim[1] or anim
    self.anim = anim
    mdl:SetSequence(tAnim[1] or anim)
    self.animtime = CurTime() + ( time or tAnim[2] or 1)
    self.animspeed = time or tAnim[2] or 1
    self.cycling = cycling or (tAnim[3] ~= nil and tAnim[3])
    self.reverseanim = reverse or (tAnim[4] ~= nil and tAnim[4])
    if self[callbackFuncName] or tAnim[5] then
        self.callback = self[callbackFuncName] or tAnim[5]
    end

    if self.AnimsEvents and self.AnimsEvents[self.seq] then
		local Time = self.animspeed
		for k,v in pairs(self.AnimsEvents[self.seq]) do
			self.VM_TimerEvents = self.VM_TimerEvents or {}

			local TimerName = "VM_Events_ZC-Base" .. self:EntIndex() .. self.seq .. k
			local TimerID = #self.VM_TimerEvents + 1
			local seq = self.seq

			timer.Create(TimerName, Time * k, 1, function()
				if not IsValid(self) then return end
				if seq != self.seq then self:VM_RemoveAllEvents() end
				v(self, mdl)
				self.VM_TimerEvents[TimerID] = nil
			end)

			self.VM_TimerEvents[TimerID] = TimerName
		end
	end
end

if CLIENT then
    function SWEP:VM_RemoveAllEvents()
		for k,v in ipairs(self.VM_TimerEvents) do
			timer.Remove(v)
		end
		table.Empty(self.VM_TimerEvents)
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