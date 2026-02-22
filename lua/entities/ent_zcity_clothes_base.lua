-- meow

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Clothes base"
ENT.Category = "ZCity Clothes"
ENT.Spawnable = false
ENT.Model = "models/props_junk/cardboard_box003a.mdl"
ENT.IconOverride = ""

ENT.SlotOccupation = {
    --[ZC_CLOTHES_SLOT_TORSO] = true,
    --[ZC_CLOTHES_SLOT_PANTS] = true,
    --[ZC_CLOTHES_SLOT_BOOTS] = true,
}

ENT.Male = {}
ENT.Male.Model = ""
ENT.Male.HideSubMaterails = {}
ENT.Male.Skin = 0
ENT.Male.Bodygroups = "0000000000000"

ENT.FeMale = {}
ENT.FeMale.Model = ""
ENT.FeMale.HideSubMaterails = {}
ENT.FeMale.Skin = 0
ENT.FeMale.Bodygroups = "0000000000000"

ENT.PhysicsSounds = true

function ENT:SetupDataTables()
end

function ENT:Initialize()
    self:SetModel(self.Model)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:DrawShadow(true)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
    	phys:SetMass(15)
    	phys:Wake()
    	phys:EnableMotion(true)
    end

    if SERVER then
        self:SetUseType(SIMPLE_USE)
    end
end

--\\ CanWear
    function ENT:CanWear(entUser)
        local Clothes = entUser:GetNetVar("zc_clothes", {})
        if IsValid(self.WearOwner) then return false end
        for _,v in pairs(Clothes) do
            if !IsValid(v) then continue end
            --PrintTable(v.SlotOccupation)
            --PrintTable(self.SlotOccupation)
            for slot, _ in pairs(v.SlotOccupation) do
                if isnumber(slot) and self.SlotOccupation[slot] then return false end
            end

            for slot, _ in pairs(self.SlotOccupation) do
                if isnumber(slot) and v.SlotOccupation[slot] then return false end
            end
        end

        return true
    end
--//
--\\ Use function
    function ENT:Use(entUser)
        if !self:CanWear(entUser) then return end

        self:Wear(entUser)
    end
--//
--\\ Wear Unwear functions
    function ENT:Wear(entUser, bDontChangeMaterials, noChange)
        if !noChange then
            local Clothes = entUser:GetNetVar("zc_clothes", {})
            Clothes[#Clothes + 1] = self
            entUser:SetNetVar("zc_clothes", Clothes)
        end

        local fem = ThatPlyIsFemale(entUser)
        local data = fem and self.FeMale or self.Male
        if !bDontChangeMaterials then
            for k,v in ipairs(data.HideSubMaterails) do
                local mat = entUser:GetSubMaterialIdByName(v)
                self.OldSubMaterials = self.OldSubMaterials or {}
                self.OldSubMaterials[mat] = entUser:GetSubMaterial(mat)

                entUser:SetSubMaterial(mat,"NULL")
            end
        end

        self:SetPos(entUser:GetPos())
        self:SetParent(entUser, 0)
        self.WearOwner = entUser

        self:SetNoDraw(true)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:AddSolidFlags(FSOLID_NOT_SOLID)
        self:SetSolid(SOLID_NONE)

        self:OnWear(entUser)
    end
    function ENT:OnWear(entUser)   end
---------------------------------------------------------------
    function ENT:Unwear(entUser, bDontChangeMaterials, noChange)
        if !noChange then
            local Clothes = entUser:GetNetVar("zc_clothes", {})
            table.RemoveByValue(Clothes, self)
            entUser:SetNetVar("zc_clothes", Clothes)
        end

        if !bDontChangeMaterials and self.OldSubMaterials then
            for k,v in pairs(self.OldSubMaterials) do
                entUser:SetSubMaterial(k,v)
            end
            table.Empty(self.OldSubMaterials)
        end

        self:SetPos(entUser:GetPos())
        self:SetParent(nil, 0)
        self:SetNoDraw(false)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:RemoveSolidFlags(FSOLID_NOT_SOLID)
        self:SetSolid(SOLID_VPHYSICS)

        self.WearOwner = nil

        self:OnUnwear(entUser)
    end
    function ENT:OnUnwear(entUser)   end
--//
--\\
    function ENT:OnRemove()
        if !IsValid(self.WearOwner) then return end

        self:Unwear(self.WearOwner)
    end
--//


--\\ Render clothes
    local vec = Vector(1,1,1)
    function ENT:RenderOnBody(entDrawOn)
        local fem = ThatPlyIsFemale(entDrawOn)

        if !IsValid(self.renderModel) then
            local data = fem and self.FeMale or self.Male
            self.renderModel = ClientsideModel(data.Model, RENDERGROUP_BOTH)

            local model = self.renderModel
            model:SetNoDraw(true)
            model:SetSkin(data.Skin)
            model:SetBodyGroups(data.Bodygroups)
            model:SetParent(entDrawOn)
            model:AddEffects(EF_BONEMERGE)

            if data.ModelSubMaterials then
                for k,v in pairs(data.ModelSubMaterials) do
                    local id = model:GetSubMaterialIdByName(k)
                    model:SetSubMaterial(id, v)
                end
            end

            self:CallOnRemove("RemoveCloth",function()
                if IsValid(self.renderModel) then
                    model:Remove()
                    model = nil
                end
            end)
        end

        local model = self.renderModel

        local mdl = string.Split(string.sub(entDrawOn:GetModel(),1,-5),"/")[#string.Split(string.sub(entDrawOn:GetModel(),1,-5),"/")]
        if mdl and model:GetFlexIDByName(mdl) then
            model:SetFlexWeight(model:GetFlexIDByName(mdl),1)
        end

        if model:GetParent() != entDrawOn then model:SetParent(entDrawOn) end

        model:DrawModel()
    end
--//

--\\ Render hook
    hook.Add("CoolPostDrawAppearance", "ZC_ClothesDraw",function(ent, ply)
        local Clothes = ply:GetNetVar("zc_clothes", {})
        if #Clothes < 1 then return end

        for i = 1, #Clothes do
            local Cloth = Clothes[i]
            if !IsValid(Cloth) then continue end
            Cloth:RenderOnBody(ent)
        end
    end)
--//

--\\ Transfer items
    hook.Add("ItemsTransfered","TransferClothes",function(ply, ragdoll)
        local Clothes = ply:GetNetVar("zc_clothes", {})
        if #Clothes < 1 then return end

        for i = 1, #Clothes do
            local Cloth = Clothes[i]
            if !IsValid(Cloth) then continue end
            Cloth:Unwear(ply, true, true)
            Cloth:Wear(ragdoll, true, true)
        end
        ragdoll:SetNetVar("zc_clothes",Clothes)
        ply:SetNetVar("zc_clothes", {})
    end)
--//

--\\ Temperature system
    hook.Add("ZC_BodyTemperature", "ClothesSaveTemp", function(ply, org, timeValue, changeRate, MaxWarmMul, warmLoseMul)
        local Clothes = ply:GetNetVar("zc_clothes", {})
        if #Clothes < 1 then return end

        for i = 1, #Clothes do
            local Cloth = Clothes[i]
            if !IsValid(Cloth) then continue end
            if !Cloth.WarmSave then continue end
            MaxWarmMul = MaxWarmMul + (Cloth.WarmSave / 1.5)
            changeRate = changeRate * math.max(1 - Cloth.WarmSave, 0.1)
            --warmLoseMul = warmLoseMul * math.max(1 - Cloth.WarmSave / 2.5, 0.1)
        end

        return changeRate, MaxWarmMul, warmLoseMul
    end)
--//