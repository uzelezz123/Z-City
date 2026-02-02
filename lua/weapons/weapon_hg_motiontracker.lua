if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Motion Detector"
SWEP.Category = "ZCity Other"
SWEP.Instructions = "A device that allows you to detect the movement of objects in the area. It is a very useful tool for security personnel.\n\nHas a paint charge capable of unlocking the infiltrator's disguise."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 4

SWEP.WorldModel = "models/mmod/weapons/w_slam.mdl"
SWEP.WorldModelReal = "models/mmod/weapons/c_slam.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "slam"

SWEP.HoldPos = Vector(-6,0,-2)
SWEP.HoldAng = Angle(-5,0,0)

SWEP.setlh = true
SWEP.setrh = true

SWEP.AnimList = {
	["deploy"] = {"tripmine_draw", 1, false},
    ["idle"] = {"tripmine_idle", 1, true},
	["attach"] = {"tripmine_attach1", 0.5, false}
}

if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_slam")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_slam"
    SWEP.BounceWeaponIcon = false
end

SWEP.offsetVec = Vector(2.7, -5, 0)
SWEP.offsetAng = Angle(-80, 180, 190)
local SLAMPlacementRadius = 80

--[[function SWEP:DrawWorldModel()
    self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
    local WorldModel = self.model
    local owner = self:GetOwner()

    if not IsValid(WorldModel) then return end

    WorldModel:SetNoDraw(true)
    WorldModel:SetModelScale(self.ModelScale or 1)
    WorldModel:SetModel(self:GetModel())
    if IsValid(owner) then
        local offsetVec = self.offsetVec
        local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
        if not boneid then return end
        local matrix = owner:GetBoneMatrix(boneid)
        if not matrix then return end
        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
        WorldModel:SetPos(newPos)
        WorldModel:SetAngles(newAng)
        WorldModel:SetupBones()
    else
        WorldModel:SetPos(self:GetPos())
        WorldModel:SetAngles(self:GetAngles())
    end

    WorldModel:DrawModel()
end]]

if CLIENT then
	function SWEP:DrawWorldModel2()
		render.SetColorModulation(0.45,0.52,1)
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
			
			local _,ang = LocalToWorld(vector_origin,self.sprint_ang * self.sprintanim,vector_origin,ang)

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
		
		if not self.WorldModelExchange then
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
			self.worldModel2:DrawModel()
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
		render.SetColorModulation(1,1,1)
	end
end

function SWEP:Deploy()
	self:PlayAnim("deploy")

	return true
end

function SWEP:PlaceSLAM(pos, ang, tr)
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 0)

    local ent = ents.Create("ent_hg_motiontracker")
    ent:SetAngles(ang)
    ent:SetPos(pos)
    ent:Spawn()

    constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone or 0, 9999, true, true)
    self:SetPlaced(true) -- ЗАЧЕМ А?
    self:SetSLAM(ent) -- НАХЕР ЭТО НУЖНО ЕСЛИ У ТЕБЯ И ТАК ПОТОМ ОРУЖИЕ УДАЛЯЕТСЯ?
    ent.owner = self:GetOwner()

    self:Remove() -- ДЕКА ТЫ ЧЕ ЧАТДЖП ИСПОЛЬЗУЕШЬ? ЧТО ЭТО ЗА КОД БЛЯТЬ
end

function SWEP:InitAdd()
    self:SetHoldType("slam")
	self:PlayAnim("deploy")
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Placed")
    self:NetworkVar("Entity", 0, "SLAM")
    self:NetworkVarNotify("Placed", self.OnVarChanged)
end

function SWEP:OnVarChanged(name, old, new) -- зач
    if not new then return end
    self.WorldModel = "models/mmod/weapons/w_slam.mdl"
    self.offsetVec = Vector(1.5, -12, -1)
    self.offsetAng = Angle(180, 80, 30)
end

local function InPlacementRadius(ply, tr)
    return tr.HitPos:DistToSqr(ply:GetPos()) <= SLAMPlacementRadius * SLAMPlacementRadius
end

local function CanPlace(ply, tr)
	if not tr.Hit or tr.HitSky or not tr.HitPos or not InPlacementRadius(ply, tr) then return false end
	if tr.Entity and IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() or tr.Entity:IsRagdoll()) then return false end

	return true
end

if CLIENT then
    local csent = ClientsideModel(SWEP.WorldModel)
    csent:SetNoDraw(true)
    
    function SWEP:DrawHUD()
        if self:GetPlaced() then return end
        if not IsValid(csent) then
            csent = ClientsideModel(self.WorldModel)
            csent:SetNoDraw(true)
        end
        local ply = self:GetOwner()
        local tr = ply:GetEyeTrace()

        if not CanPlace(ply, tr) then return end

        local pos, ang = tr.HitPos, tr.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
        ang:RotateAroundAxis(ang:Up(), 0)

        cam.Start3D()
            csent:SetPos(pos)
            csent:SetAngles(ang)
            csent:SetMaterial("models/wireframe")
            csent:DrawModel()
			csent:SetBodygroup(1, 1)
        cam.End3D()
    end
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    
    if not self:GetPlaced() then
        local tr = ply:GetEyeTrace()
        if not CanPlace(ply, tr) then return end
        if CLIENT then return end
        local pos, ang = tr.HitPos, tr.HitNormal:Angle()
        pos = pos + ang:Forward() * 2

		self:PlayAnim("attach")
		timer.Simple(0.4, function()
			if IsValid(self) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() == self then
				self:PlaceSLAM(pos, ang, tr)
			end
		end)
    end
end

function SWEP:SecondaryAttack()
	return false
end