-- Это база для ручной настройки тпик... афигеть да?
-- Сообщение всем скриптхукерам, ну вы это хоть оставляйте тех кто это кодил. Уважайте чужой труд!
if SERVER then AddCSLuaFile() end
SWEP.PrintName = "TPIK Base 1"
SWEP.Instructions = "Tpik Base 1"
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

SWEP.WorldModel = "models/nirrti/tablet/tablet_sfm.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"

SWEP.setrhik = true
SWEP.setlhik = true

SWEP.LHPos = Vector(0,-6.6,0)
SWEP.LHAng = Angle(0,0,180)

SWEP.visualweight = 1.2

SWEP.RHPosOffset = Vector(0,0,-7.6)
SWEP.RHAngOffset = Angle(0,0,-90)

SWEP.LHPosOffset = Vector(0,0,0)
SWEP.LHAngOffset = Angle(0,0,0)

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(6,-7,0)
SWEP.offsetAng = Angle(0,90,180)   

SWEP.HeadPosOffset = Vector(15,1.7,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

function SWEP:Think()
    if self:GetHoldType() ~= self.HoldType then
        self:SetHoldType(self.HoldType)
    end

    self:AddThink()
end

function SWEP:AddThink()

end

function SWEP:GetWeaponEntity()
	return IsValid(self.model) and self.model or self
end

SWEP.HoldLH = "pistol_hold2"
SWEP.HoldRH = "pistol_hold2"

SWEP.HoldClampMax = 25
SWEP.HoldClampMin = -25

function SWEP:SetHandPos(noset)
	self.rhandik = self.setrhik
	self.lhandik = self.setlhik
	
	local ply = self:GetOwner()

    if not IsValid(ply) or not IsValid(self:GetWeaponEntity()) then return end
    if not ply.shouldTransmit or ply.NotSeen then return end

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	if ent ~= ply and not (ply:KeyDown(IN_USE) or (ply:GetNetVar("lastFake",0) - CurTime() + 5 > 0)) then return end
	--ply:SetIK(false)
	
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	local rh,lh = ply:LookupBone("ValveBiped.Bip01_R_Hand"), ply:LookupBone("ValveBiped.Bip01_L_Hand")
	local base = ply:LookupBone(self.BaseBone)

	local rhmat = ent:GetBoneMatrix(rh)
	local lhmat = ent:GetBoneMatrix(lh)

    local headhmat = ent:GetBoneMatrix(base)
	
	if not rhmat or not lhmat then return end

    local headAng = ply:EyeAngles()
    --print("post",headAng[1],headAng)
    headAng[1] = math.max(math.min(headAng[1],self.HoldClampMax),self.HoldClampMin)
   -- print("after",headAng[1],headAng)
    local headPos, headAng = LocalToWorld(self.HeadPosOffset,self.HeadAngOffset,headhmat:GetTranslation(),headAng)

    self.handPos = headPos
    self.handAng = headAng

	if not self.handPos or not self.handAng then return end
	
	local vec1, ang1 = -(-self.handPos), -(-self.handAng)
	
	--[[
	--второй способ гавна
	local matrix = Matrix()
	matrix:SetTranslation(self.WorldPos)
	matrix:SetAngles(self.WorldAng)
	local newmat = matrix:GetInverse()
	local ang = -(-self.desiredAng)
	ang:RotateAroundAxis(ang:Forward(),180)
	
	local vec1, ang1 = LocalToWorld(newmat:GetTranslation(), newmat:GetAngles(), self.desiredPos, ang)

	]]

	vec1:Add(ang1:Up() * -1)
	local lhang = -(-ang1)
	lhang:RotateAroundAxis(ang1:Forward(),-90)

	local vec2, ang2 = LocalToWorld(self.LHPos, self.LHAng, vec1, lhang)
	
	local vec1, ang1 = LocalToWorld(self.RHPosOffset, self.RHAngOffset, vec1, ang1)
	local vec2, ang2 = LocalToWorld(self.LHPosOffset, self.LHAngOffset, vec2, ang2)

	rhmat:SetTranslation(vec1)
	rhmat:SetAngles(ang1)

    lhmat:SetTranslation(vec2)
	lhmat:SetAngles(ang2)

	--if IsValid(self:GetWeaponEntity()) then
		--self:AnimHands()
	--end

    hg.set_hold(ent, self.HoldLH)
    hg.set_holdrh(ent, self.HoldRH)
	
	--self:AnimationRender()
	--self:AnimHoldPost(self:GetWeaponEntity())

	hg.bone_apply_matrix(ent, rh, rhmat)
	if ( hg.CanUseLeftHand(ply) and self.lhandik ) then
		hg.bone_apply_matrix(ent, lh, lhmat)
	end

	self.rhmat = rhmat
	self.lhmat = lhmat

	return rhmat, lhmat
end

function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	WorldModel:SetNoDraw(true)
	local owner = self:GetOwner()
	if not IsValid(WorldModel) then return end

	if (not IsValid(owner)) or owner.NotSeen or (not owner.shouldTransmit) then
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
		WorldModel:SetRenderOrigin(self:GetPos())
		WorldModel:SetRenderAngles(self:GetAngles())
		WorldModel:DrawModel()
		return
	end

    if not WorldModel.Modificators then
        WorldModel:SetSkin(self.Skin or 0)
        WorldModel.Modificators = true
    end

	WorldModel:SetModelScale(self.ModelScale or 1)
	if IsValid(owner) then
		local rhmat = self:SetHandPos()--owner:GetBoneMatrix(owner:LookupBone("ValveBiped.Bip01_R_Hand")) 
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local matrix = rhmat
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetRenderOrigin(newPos)
		WorldModel:SetRenderAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
		WorldModel:SetRenderOrigin(self:GetPos())
		WorldModel:SetRenderAngles(self:GetAngles())
	end

    WorldModel:DrawModel()

	if self.lefthandmodel then
		self.model2 = self.model2 or ClientsideModel(self.lefthandmodel)
		local WorldModel = self.model2
		local owner = self:GetOwner()

		WorldModel:SetNoDraw(true)
		WorldModel:SetModelScale(self.ModelScale2 or 1)
		
		if IsValid(owner) then
			local offsetVec = self.offsetVec2
			local offsetAng = self.offsetAng2
			local matrix = lhmat
			if not matrix then return end
			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)
			WorldModel:SetRenderOrigin(newPos)
			WorldModel:SetRenderAngles(newAng)
			WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
			WorldModel:SetRenderOrigin(self:GetPos())
			WorldModel:SetRenderAngles(self:GetAngles())
		end
		
		if IsValid(owner.FakeRagdoll) or not IsValid(owner) or (IsValid(owner:GetActiveWeapon()) and owner:GetActiveWeapon() ~= self) then return end
		WorldModel:DrawModel()
	end

    self:AddDrawModel(WorldModel)
end

function SWEP:Camera(eyePos, eyeAng, view, vellen)
	self:SetHandPos()
	self:DrawWorldModel()

    view.origin = (eyePos - (angle_difference_localvec * 150) - (position_difference * 0.5))

	return view
end

function SWEP:AddDrawModel(ent)
end
