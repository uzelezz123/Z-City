--

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Fire Match"
ENT.Category = "ZCity Other"
ENT.Spawnable = true
ENT.Model = "models/weapons/gleb/matchhead.mdl"
ENT.IconOverride = "vgui/wep_jack_hmcd_matchbox"

ENT.PhysicsSounds = true

function ENT:SetupDataTables()
    self:NetworkVar( "Float", 0, "FireLeft" )

	if SERVER then
		self:SetFireLeft( 1 )
	end
end

local ignitable = { -- Very sorry for this silly table, but i don't want allow to ignite all wooden entity
    ["models/gibs/wood_gib01b.mdl"] = true,
    ["models/gibs/wood_gib01a.mdl"] = true,
    ["models/gibs/wood_gib01c.mdl"] = true,
    ["models/gibs/wood_gib01d.mdl"] = true,
    ["models/gibs/wood_gib01e.mdl"] = true
}

function ENT:Initialize()
    self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:DrawShadow(true)
    self:SetModelScale(0.4)
    self:Activate()
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:Wake()
		phys:EnableMotion(true)
	end
    if SERVER then
        self:AddCallback("PhysicsCollide",function(ent1, data)
            if ent1:GetFireLeft() <= 0 then return end
            local pos = ent1:GetPos()
            local ent = data.HitEntity
            --print(IsValid(ent), ignitable[ent:GetModel()], ent:GetModel())
            if IsValid(ent) and ignitable[ent:GetModel()] then
                ent:Ignite()
            end

            for _,v in ipairs(hg.gasolinePath) do
                if v[1]:Distance(pos) > 30 or v[2] ~= false then continue end
                v[2] = CurTime()
                v[3] = owner
            end
            if IsValid(data.HitEntity) and hg.drums[data.HitEntity:EntIndex()] then
                local drum = hg.drums[data.HitEntity:EntIndex()]
                local drumEnt = data.HitEntity
                local tbl = hg.expItems[drumEnt:GetModel()]
                for i, point in ipairs(drum.high_point) do
                    local pos2 = LocalToWorld(point[1], angle_zero, drumEnt:GetPos(), drumEnt:GetAngles())
                    if pos:DistToSqr(pos2) < 5 * 5 then
                        drumEnt.owner = ent1.debil
                        hg.PropExplosion( drumEnt, tbl.ExpType, (drumEnt.Volume or tbl.Force) * 2, drumEnt:GetPhysicsObject():GetMass() )
                    end
                end
            end
        end)
    end

end

function ENT:Use(ply)
	if self:IsPlayerHolding() or (self.UseCD or 0) > CurTime() then
		ply:DropObject(self)

		self.UseCD = CurTime() + 0.3
		return
	end

	ply:PickupObject(self)
	self.owner = ply

	self.UseCD = CurTime() + 0.6
end


function ENT:Draw()
    if not IsValid(self.effectAttachment) then
        self.effectAttachment = ClientsideModel("models/hunter/plates/plate.mdl")
        self.effectAttachment:SetNoDraw(true)
        --print("WHY")
        self:CallOnRemove("RemoveEffect",function(ent)
            if IsValid(ent.effectAttachment) then
                ent.effectAttachment:Remove()
            end
        end)
    end

    local attach = self.effectAttachment

    if not self.eff and self:GetFireLeft() > 0 then
        self.eff = CreateParticleSystem(attach,"Lighter_flame",PATTACH_POINT_FOLLOW,1,Vector(0,0,0))
        eff = self.eff
    end
    local pos = self:GetPos() + self:GetForward() * -1.3 + self:GetUp() * (2 * self:GetFireLeft())
    attach:SetPos(pos)
    self:DrawModel()
end

local color_b = Color(255,255,255)
function ENT:Think()
    if SERVER then
        self:SetFireLeft(math.max(0,self:GetFireLeft() - 1 * FrameTime()))
    end

    if CLIENT then
        if self:GetFireLeft() > 0 and IsValid(self.effectAttachment) then
            local dlight = DynamicLight( self:EntIndex() )
            if ( dlight ) then
                dlight.pos = self.effectAttachment:GetPos()
                dlight.r = 255
                dlight.g = 185
                dlight.b = 0
                dlight.brightness = 1
                dlight.decay = 20
                dlight.size = 16
                dlight.dietime = CurTime() + 0.01
            end
        end
    end

    if CLIENT and (not self.ColorCD or self.ColorCD < CurTime()) then
        color_b:SetLightness(self:GetFireLeft())
		if color_b:GetLightness() <= 0.1 then
			self:SetMaterial("models/props_foliage/tree_deciduous_01a_trunk")
		end
        self:SetColor(color_b)
        self.ColorCD = CurTime() + 0.1

        if self:GetFireLeft() <= 0 and self.eff then
            self.eff:StopEmissionAndDestroyImmediately()
            self.eff = nil
        end
    end
end