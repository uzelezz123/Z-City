if SERVER then AddCSLuaFile() end
SWEP.PrintName = "Claymore"
SWEP.Category = "Weapons - Explosive"
SWEP.Instructions = "The claymore is an extremely effective thing that can blow an opponent's legs to splinters. There is little chance that the victim will survive the blast. \n\nPress E on the claymore to enable motion triggering when a person gets near it."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Wait = 1
SWEP.Secondary.Next = 0
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "slam"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 4

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

SWEP.WorldModel = "models/hoff/weapons/seal6_claymore/w_claymore.mdl"
SWEP.ViewModel = ""

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_claymore")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_claymore"
	SWEP.BounceWeaponIcon = false
end
SWEP.offsetVec = Vector(3, -7, 6)
SWEP.offsetAng = Angle(0, 90, 180)
function SWEP:DrawWorldModel()
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
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
    if IsValid(self:GetOwner()) and !self:GetOwner():IsPlayer() then return end
	hg.bone.Set(self:GetOwner(), lookup_name, vec, ang)
end

function SWEP:Initialize()
    self:SetHold("slam")
    self.WorldModel = "models/hoff/weapons/seal6_claymore/w_claymore.mdl"
end

function SWEP:Think()
    self:SetHold("slam")
    self:SetHolding(math.max(self:GetHolding() - 3,0))
    if self:GetPlaced() and self.WorldModel ~= "models/jmod/explosives/grenades/satchelcharge/satchel_charge_plunger.mdl" then
        self.WorldModel = "models/jmod/explosives/grenades/satchelcharge/satchel_charge_plunger.mdl"
        self.offsetVec = Vector(1.5, -12, -1)
        self.offsetAng = Angle(180, 80, 30)
    end
end

function SWEP:Animation()
    local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0,-hold/2,0))
    self:BoneSet("r_forearm", vector_origin, Angle(0,hold,0))
    if self.WorldModel == "models/hoff/weapons/seal6_claymore/w_claymore.mdl" then
        self.offsetAng[3] = 180 + hold / 100 * 45
        self.offsetVec[1] = 3 + hold / 100 * 4
    end
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool",0,"Placed")
    self:NetworkVar("Float",0,"Holding")
    self:NetworkVar("Entity",0,"Claymore")
	self:NetworkVarNotify( "Placed", self.OnVarChanged )
end

function SWEP:OnVarChanged(name,old,new)
    if not new then return end
    self.WorldModel = "models/jmod/explosives/grenades/satchelcharge/satchel_charge_plunger.mdl"
    self.offsetVec = Vector(1.5, -12, -1)
    self.offsetAng = Angle(180, 80, 30)
end

local offsetPos,offsetAng = Vector(3,0,0),Angle(180,90,90)

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
        local tr = hg.eyeTrace(ply)
        if not tr.Hit or tr.HitSky then return end
		if not IsValid(tr.Entity) then return end 
		if tr.Entity and tr.Entity:IsPlayer() then return end
        if tr.HitNormal:Dot(vector_up) < math.cos(math.rad(30)) then return end
        local pos,ang = tr.HitPos,tr.HitNormal:Angle()
        ang[3] = ply:EyeAngles()[2]-ang[2]
        local pos,ang = LocalToWorld(offsetPos,offsetAng,pos,ang)

        cam.Start3D()
            csent:SetPos(pos)
            csent:SetAngles(ang)
            csent:SetMaterial("models/wireframe")
            csent:DrawModel()
        cam.End3D()
    end
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    if not self:GetPlaced() then

    else
        if self:GetHolding() > 0 then return end
        if not IsValid(self:GetClaymore()) then if SERVER and IsValid(self) then self:Remove() end return end
        if self.activated then return end
        self.activated = true

        self:EmitSound("weapons/tfa_ins2/mp5a4/mp5k_boltback.wav")

        if SERVER then
            timer.Simple(0.5,function()
                if IsValid(self) then
                    self:GetClaymore():ActivateExplosive()
                    self:Remove()
                    ply:SelectWeapon("weapon_hands_sh")
                end
            end)
        end
    end
end

function SWEP:SecondaryAttack()
    local ply = self:GetOwner()
    
    if not self:GetPlaced() then
        local tr = hg.eyeTrace(ply)
        if not tr.Hit or tr.HitSky then return end

        self:SetHolding(math.min(self:GetHolding() + 6,100))

        if self:GetHolding() < 100 then return end
        if CLIENT then return end
        if tr.HitNormal:Dot(vector_up) < math.cos(math.rad(30)) then return end
        local pos,ang = tr.HitPos,tr.HitNormal:Angle()
        ang[3] = ply:EyeAngles()[2]-ang[2]
        local pos,ang = LocalToWorld(offsetPos,offsetAng,pos,ang)
        
        local isSoftSurface = false
        local matType = tr.MatType or 0
        
        if matType == MAT_DIRT or 
           matType == MAT_SAND or 
           matType == MAT_GRASS or 
           matType == MAT_SNOW or
           matType == MAT_SLOSH or
           matType == MAT_FLESH then
            isSoftSurface = true
        end
        
        if not isSoftSurface then
            local texture = string.lower(tr.HitTexture or "")
            
            if string.find(texture, "dirt") or 
               string.find(texture, "mud") or
               string.find(texture, "sand") or
               string.find(texture, "grass") or
               string.find(texture, "snow") or
               string.find(texture, "gravel") or
               string.find(texture, "ground") then
                isSoftSurface = true
            end
        end
                
        local ent = ents.Create("ent_claymore")
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent.FirmlyAttached = isSoftSurface
        ent:Spawn()
        ent.owner = self:GetOwner()

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(true)
            
            if not isSoftSurface then
                phys:SetMass(15) 

                ent.CanBeKnockedOver = true
            end
        end
        
        if isSoftSurface then
            constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone or 0, 80000, true, false)
        else
            constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone or 0, 1000, true, false)
        end
        
        self:SetPlaced(true)
        self:SetClaymore(ent)
    end
end

function SWEP:GetInfo()
    if not IsValid(self) then return {NULL,false} end
    local data = {}
    data.claymore = self:GetClaymore()
    data.placed = self:GetPlaced()
    return data
end

function SWEP:SetInfo(data)
    self:SetPlaced(data.placed)
    self:SetClaymore(data.claymore)
end