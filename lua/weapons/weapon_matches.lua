if SERVER then
    AddCSLuaFile()
end

if CLIENT then
    SWEP.PrintName = "Matchbox"
    SWEP.Slot = 3
    SWEP.SlotPos = 5
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_matchbox")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_matchbox"
    SWEP.BounceWeaponIcon = false
end

SWEP.Author = "John Walker"
SWEP.Instructions = "Just regular matches, you can light different things..."
SWEP.Category = "ZCity Other"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.WorldModel = "models/weapons/gleb/w_firematch.mdl"

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Offset = {
    Pos = Vector(1.5, 3.5, -1),
    Ang = Angle(0, 0, 100),
    Size = 1.5
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Holding")
end

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    return true
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
    if IsValid(self:GetOwner()) and !self:GetOwner():IsPlayer() then return end
	hg.bone.Set(self:GetOwner(), lookup_name, vec, ang)
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
local rang1, rang2 = Angle(15, -20, 10),Angle(0, 0, 40)
function SWEP:Animation()
    if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end
    local hold = self:GetHolding()
    if self:Clip1() <= 0 then
        self:BoneSet("r_upperarm", vector_origin, rang1)
        self:BoneSet("r_forearm", vector_origin, rang2)
    else
        self:BoneSet("r_upperarm", vector_origin, Angle(20 - hold / 4, -50 - hold / 4, 10 - hold / 1.5))
        self:BoneSet("r_forearm", vector_origin, Angle(0, hold / 1, 10 + hold / 2))
    end

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:Think()
	self:SetHolding(math.max(self:GetHolding() - 4,0))
end

if CLIENT then
    hg_firematch = hg_firematch or {}
    net.Receive("Mathces",function()
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        local eff = ent:CreateParticleEffect("Lighter_flame",1,{PATTACH_CUSTOMORIGIN,ent,ent:GetPos()})
        table.insert(hg_firematch,eff)
        eff:SetControlPoint(0, ent:GetPos()+ ent:GetForward() * 15)
        eff:StartEmission()
        timer.Simple(5,function()
            if IsValid(eff) then
                eff:StopEmission()
            end
        end)
        timer.Simple(6.5,function()
            if IsValid(eff) then
                eff:StopEmissionAndDestroyImmediately()
                table.RemoveByValue(hg_firematch,eff)
            end
        end)
    end)
else
    util.AddNetworkString("Mathces")
end

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end

    --self:SetNextPrimaryFire(CurTime() + 1)
    self:SetHolding(math.min(self:GetHolding() + 8, 100))
    if self:GetHolding() < 100 then return end

    self:SetNextPrimaryFire(CurTime() + 1)
    self:EmitSound("f_firematch_strike.wav")

    local tr = hg.eyeTrace(self:GetOwner(), 120)
    if tr.Entity and tr.Entity.OnMatches then
        tr.Entity:OnMatches()
        self:TakePrimaryAmmo(1)
        return 
    end

    if SERVER then
        local ent = ents.Create("ent_zcity_match")
        if not IsValid(ent) then return end
		
		local owner = self:GetOwner() -- салат ты реально furry какой self.Owner -- да
        
        local boneIndex = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if not boneIndex then return end
        
        local pos, ang = owner:GetBonePosition(boneIndex)
        if not pos or not ang then return end
        
        pos = pos + ang:Forward() * 16
        
        ent:SetPos(pos)
        ent:SetAngles(-ang)
        
        ent:Spawn()

        ent.debil = owner

        local phys = ent:GetPhysicsObject()
        if not IsValid(phys) then if IsValid(ent) then ent:Remove() end return end

        local velocity = owner:GetAimVector()
        velocity = velocity * 100
        velocity = velocity + (VectorRand() * 10)
        phys:ApplyForceCenter(velocity)
    end

    self:TakePrimaryAmmo(1)
end

if CLIENT then
	local colWhite = Color(255, 255, 255, 255)
	local colred = Color(150,0,0)
	local lerpthing = 0
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end
		local tr = hg.eyeTrace(self:GetOwner(), 120)

		if not tr then return end
		local toScreen = tr.HitPos:ToScreen()
		local Size = math.max(math.min(1 - (tr and tr.Fraction or 0), 1), 0.1)
		local x, y = tr.HitPos:ToScreen().x, tr.HitPos:ToScreen().y
	
		lerpthing = Lerp(0.1, lerpthing, tr.Hit and 1 or 0)
		colWhite.a = 255 * Size * lerpthing
		surface.SetDrawColor(colWhite)
		surface.DrawRect(x - 25 * lerpthing * 0.1, y - 2.5, 50 * lerpthing * 0.1, 5)
		surface.DrawRect(x - 2.5, y - 25 * lerpthing * 0.1, 5, 50 * lerpthing * 0.1)

		if IsValid(tr.Entity) and (tr.Entity.OnMatches or tr.Entity.shouldburn) then
			draw.SimpleText( "Ignite object", "HomigradFont", toScreen.x + 3, toScreen.y + 27, color_black, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Ignite object", "HomigradFont", toScreen.x, toScreen.y + 25, colred, TEXT_ALIGN_CENTER )
		end
	end
end


function SWEP:SecondaryAttack()
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if IsValid(owner) then
        local boneIndex = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if boneIndex then
            local pos, ang = owner:GetBonePosition(boneIndex)
            if pos and ang then
                pos = pos + self.Offset.Pos.x * ang:Right() + self.Offset.Pos.y * ang:Forward() + self.Offset.Pos.z * ang:Up()
                ang:RotateAroundAxis(ang:Right(), self.Offset.Ang.p)
                ang:RotateAroundAxis(ang:Up(), self.Offset.Ang.y)
                ang:RotateAroundAxis(ang:Forward(), self.Offset.Ang.r)

                self:SetPos(pos)
                self:SetAngles(ang)
                self:SetupBones()
				self:SetModelScale(self.Offset.Size, 0)
                self:DrawModel()
                return
            end
        end
    end
    self:DrawModel()
end