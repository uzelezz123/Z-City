local healthModel
local redModel
local blinkModel
local whiteMat = Material("models/debug/debugwhite")
local gradientMat = Material("gui/center_gradient")

local IND_SIZE_BASE = 120
local IND_SIZE_MAX = 170
local GRADIENT_OFFSET_X = -30
local GRADIENT_OFFSET_Y = 20
local STAMINA_OFFSET_X = -30
local STAMINA_OFFSET_Y = 13
local PULSE_DURATION = 8
local BLINK_SCALE = Vector(1.05, 1.05, 1.05)
local BLINK_DURATION = 5
local FRACTURE_BLINK_SPEED = 10
local POS_VISIBLE_X = 0
local POS_HIDDEN_X = -400

local currentX = nil
local pulseStartTime = 0
local limbStates = {}
local boneCache = {}
local lastLifeState = nil


local bodyParts = {
    lleg = {
        bones = {"ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Foot"},
        health = function(org) return org.lleg or 0 end,
        dislocated = function(org) return org.llegdislocation end,
        amputated = function(org) return org.llegamputated end,
        amputation_bone = "ValveBiped.Bip01_L_Calf",
    },
    rleg = {
        bones = {"ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Foot"},
        health = function(org) return org.rleg or 0 end,
        dislocated = function(org) return org.rlegdislocation end,
        amputated = function(org) return org.rlegamputated end,
        amputation_bone = "ValveBiped.Bip01_R_Calf",
    },
    larm = {
        bones = {"ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand"},
        health = function(org) return org.larm or 0 end,
        dislocated = function(org) return org.larmdislocation end,
        amputated = function(org) return org.larmamputated end,
        amputation_bone = "ValveBiped.Bip01_L_Forearm",
    },
    rarm = {
        bones = {"ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand"},
        health = function(org) return org.rarm or 0 end,
        dislocated = function(org) return org.rarmdislocation end,
        amputated = function(org) return org.rarmamputated end,
        amputation_bone = "ValveBiped.Bip01_R_Forearm",
    },
    chest = {
        bones = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine"},
        health = function(org) return math.max(org.chest or 0, org.spine2 or 0, org.spine3 or 0) end,
    },
    pelvis = {
        bones = {"ValveBiped.Bip01_Pelvis"},
        health = function(org) return math.max(org.pelvis or 0, org.spine1 or 0) end,
    },
    neck = {
        bones = {"ValveBiped.Bip01_Neck1"},
        health = function(org) return org.spine3 or 0 end,
        dislocated = function(org) return org.arteria end, -- Using dislocated for arteria damage
    },
    head = {
        bones = {"ValveBiped.Bip01_Head1"},
        health = function(org) return org.skull or 0 end,
        dislocated = function(org) return org.jawdislocation end, -- Using for jaw dislocation
        broken = function(org) return org.jaw or 0 end, -- Using for jaw destruction
    },
}

local function ScreenScaleFixed(size)
    return size * (ScrH() / 480)
end

local function SetBoneScaleRecursive(ent, boneName, scale)
    local boneID = ent:LookupBone(boneName)
    if not boneID then return end
    
    ent:ManipulateBoneScale(boneID, scale)
    
    local children = ent:GetChildBones(boneID)
    for _, childID in pairs(children) do
        ent:ManipulateBoneScale(childID, scale)
    end
end

local function ScaleBoneAndChildren(ent, boneID, scale)
    ent:ManipulateBoneScale(boneID, scale)
    local children = ent:GetChildBones(boneID)
    for _, child in ipairs(children) do
        ScaleBoneAndChildren(ent, child, scale)
    end
end

local function InitBlinkModel(ent)
    ent:SetupBones()
    for i = 0, ent:GetBoneCount() - 1 do
        ent:ManipulateBoneScale(i, Vector(0, 0, 0))
    end
end

local function ResetModels(ply)
    if IsValid(healthModel) then
        if healthModel.accessories then
            for _, v in pairs(healthModel.accessories) do
                if IsValid(v) then v:Remove() end
            end
        end
        healthModel:Remove()
    end
    if IsValid(blinkModel) then
        blinkModel:Remove()
    end
    if IsValid(redModel) then
        redModel:Remove()
    end
    healthModel = nil
    redModel = nil
    blinkModel = nil
    limbStates = {}
    pulseStartTime = 0
end

local function DrawHealthAccessories(healthModel, ply)
    local accessories = ply:GetNetVar("Accessories")
    if not accessories then 
        if healthModel.accessories then
            for k, v in pairs(healthModel.accessories) do
                if IsValid(v) then v:Remove() end
            end
            healthModel.accessories = nil
        end
        return 
    end
    
    healthModel.accessories = healthModel.accessories or {}
    local accList = istable(accessories) and accessories or {accessories}
    local currentAccs = {}
    
    for _, accName in pairs(accList) do
        currentAccs[accName] = true
        local accessData = hg.Accessories[accName]
        if not accessData then continue end
        if accessData.norender then continue end
        
        local model = healthModel.accessories[accName]
        local isFemale = false
        if hg.Appearance.FuckYouModels and hg.Appearance.FuckYouModels[2][healthModel:GetModel()] then
            isFemale = true
        end
        
        if not IsValid(model) then
            local modelPath = isFemale and accessData.femmodel or accessData.model
            if not modelPath then continue end
            
            model = ClientsideModel(modelPath, RENDERGROUP_OTHER)
            model:SetNoDraw(true)
            model:SetModelScale(accessData[isFemale and "fempos" or "malepos"][3])
            
            local skin = accessData.skin
            if isfunction(skin) then skin = skin(healthModel) end
            model:SetSkin(skin or 0)
            
            model:SetBodyGroups(accessData.bodygroups or "")
            
            if accessData.bonemerge then
                model:AddEffects(EF_BONEMERGE)
            end
            
            if accessData.bSetColor then
                local col = ply:GetPlayerColor() or Vector(1,1,1)
                model:SetColor(col:ToColor())
            end
            
            if accessData.SubMat then
                model:SetSubMaterial(0, accessData.SubMat)
            end
            
            healthModel.accessories[accName] = model
        end
        
        local boneName = accessData.bone
        local bone = healthModel:LookupBone(boneName)
        
        if bone then
            local matrix = healthModel:GetBoneMatrix(bone)
            if matrix then
                local bonePos, boneAng = matrix:GetTranslation(), matrix:GetAngles()
                local posData = accessData[isFemale and "fempos" or "malepos"]
                local localPos, localAng = posData[1], posData[2]
                
                local pos, ang = LocalToWorld(localPos, localAng, bonePos, boneAng)
                
                model:SetRenderOrigin(pos)
                model:SetRenderAngles(ang)
                
                if model:GetParent() ~= healthModel then
                    model:SetParent(healthModel, bone)
                end
                
                model:DrawModel()
            end
        end
    end
    
    for name, model in pairs(healthModel.accessories) do
        if not currentAccs[name] then
            if IsValid(model) then model:Remove() end
            healthModel.accessories[name] = nil
        end
    end
end

hook.Add("HUDPaint", "HG_HealthIndicator", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local alive = ply:Alive()
    if lastLifeState ~= alive then
        ResetModels(ply)
        lastLifeState = alive
    end
    
    if not alive then return end
    if gui.IsGameUIVisible() then return end
    
    if not IsValid(healthModel) then
        healthModel = ClientsideModel(ply:GetModel(), RENDERGROUP_OTHER)
        healthModel:SetNoDraw(true)
        healthModel:SetIK(false)
        local seq = healthModel:LookupSequence("idle_suitcase")
        if seq then
            healthModel:SetSequence(seq)
            healthModel:SetCycle(0)
        end
    end
    
    if not IsValid(blinkModel) then
        blinkModel = ClientsideModel(ply:GetModel(), RENDERGROUP_OTHER)
        blinkModel:SetNoDraw(true)
        blinkModel:SetIK(false)
        local seq = blinkModel:LookupSequence("idle_suitcase")
        if seq then
            blinkModel:SetSequence(seq)
            blinkModel:SetCycle(0)
        end
        InitBlinkModel(blinkModel)
    end

    if not IsValid(redModel) then
        redModel = ClientsideModel(ply:GetModel(), RENDERGROUP_OTHER)
        redModel:SetNoDraw(true)
        redModel:SetIK(false)
        local seq = redModel:LookupSequence("idle_suitcase")
        if seq then
            redModel:SetSequence(seq)
            redModel:SetCycle(0)
        end
        InitBlinkModel(redModel)
    end

    if healthModel:GetModel() ~= ply:GetModel() then
        healthModel:SetModel(ply:GetModel())
        redModel:SetModel(ply:GetModel())
        blinkModel:SetModel(ply:GetModel())
        
        local seq = healthModel:LookupSequence("idle_suitcase")
        if seq then
            healthModel:SetSequence(seq)
            healthModel:SetCycle(0)
        end
        local seq2 = blinkModel:LookupSequence("idle_suitcase")
        if seq2 then
            blinkModel:SetSequence(seq2)
            blinkModel:SetCycle(0)
        end
        local seq3 = redModel:LookupSequence("idle_suitcase")
        if seq3 then
            redModel:SetSequence(seq3)
            redModel:SetCycle(0)
        end

        InitBlinkModel(blinkModel)
        limbStates = {}
        
        if healthModel.accessories then
            for _, v in pairs(healthModel.accessories) do
                if IsValid(v) then v:Remove() end
            end
            healthModel.accessories = nil
        end
    end

    local consciousness = 1
    local otrub = false
    local org = ply.organism
    
    if org then
        if org.consciousness then consciousness = org.consciousness end
        if org.otrub then otrub = org.otrub end
    end
    
    local targetX = otrub and POS_HIDDEN_X or POS_VISIBLE_X
    local targetXScaled = ScreenScaleFixed(targetX)
    
    if not currentX then currentX = ScreenScaleFixed(POS_HIDDEN_X) end
    currentX = Lerp(FrameTime() * 2, currentX, targetXScaled)
    
    local time = CurTime()
    if org then
        for partName, partData in pairs(bodyParts) do
            local health = (partData.health and partData.health(org)) or 0
            local isBroken = health >= 1 or (partData.broken and partData.broken(org))
            local isDislocated = partData.dislocated and partData.dislocated(org)
            local isAmputated = partData.amputated and partData.amputated(org)

            if not limbStates[partName] then
                limbStates[partName] = {
                    health = 0,
                    amputated = false,
                    blinking = false,
                    blinkEnd = 0,
                    fractured = false
                }
            end

            local state = limbStates[partName]
            state.health = health
            state.isBroken = isBroken
            state.isDislocated = isDislocated

            -- Handle amputation
            if isAmputated then
                if not state.amputated then
                    state.amputated = true
                    state.blinking = true
                    state.blinkEnd = time + BLINK_DURATION
                    pulseStartTime = time
                end
            elseif state.amputated then
                state.amputated = false
                state.blinking = false
            end

            -- Handle fracture/dislocation
            if isBroken or isDislocated then
                if not state.fractured then
                    state.fractured = true
                    pulseStartTime = time
                end
            elseif state.fractured then
                state.fractured = false
            end
            
            if state.blinking and time > state.blinkEnd then
                state.blinking = false
            end
        end
    end

    local size = IND_SIZE_BASE
    
    local w, h = ScreenScaleFixed(size), ScreenScaleFixed(size)
    local y = ScreenScaleFixed(20)
    
    local camPos = Vector(95, 0, 65) 
    local lookAng = Angle(11, 180, 0)
    
    local renderX = currentX
    
    local SILHOUETTE_OFFSET_X = -15
    local SILHOUETTE_OFFSET_Y = 15
    
    local viewX = renderX + ScreenScaleFixed(SILHOUETTE_OFFSET_X)
    local viewY = y + ScreenScaleFixed(SILHOUETTE_OFFSET_Y)
    
    local modelOffset = Vector(0, 0, 0)
    
    surface.SetMaterial(gradientMat)
    local gCol = math.Clamp(consciousness, 0, 1) * 255
    surface.SetDrawColor(gCol, gCol, gCol, 25)
    
    local gradX = currentX + ScreenScaleFixed(GRADIENT_OFFSET_X)
    local gradY = y + ScreenScaleFixed(GRADIENT_OFFSET_Y)
    local gradW = w * 1.2 
    local gradH = h
    
    surface.DrawTexturedRect(gradX, gradY, gradW, gradH)
    
    local camRenderX = viewX
    if camRenderX < 0 then
        local dist = camPos.x
        local fov = 50
        local visibleHeight = 2 * dist * math.tan(math.rad(fov) / 2)
        local unitsPerPixel = visibleHeight / h
        
        local pixelShift = camRenderX 
        local unitShift = pixelShift * unitsPerPixel 
        
        modelOffset = Vector(0, unitShift, 0)
        camRenderX = 0
    end
    
        cam.Start3D(camPos, lookAng, 50, camRenderX, viewY, w, h)
        render.SuppressEngineLighting(true)
        render.MaterialOverride(whiteMat)
        
        local time = CurTime()
        local col = math.Clamp(consciousness, 0, 1)

        healthModel:SetPos(modelOffset)
        healthModel:SetAngles(Angle(0, 0, 0))
        for i = 0, ply:GetNumBodyGroups() - 1 do
            healthModel:SetBodygroup(i, ply:GetBodygroup(i))
        end
        healthModel:SetSkin(ply:GetSkin())
        healthModel:SetupBones()

        -- Base model (healthy parts)
        render.SetColorModulation(col, col, col)
        for partName, partData in pairs(bodyParts) do
            local state = limbStates[partName]
            if state and (state.health > 0 or state.isBroken or state.isDislocated or state.amputated) then
                for _, boneName in ipairs(partData.bones) do
                    local boneID = healthModel:LookupBone(boneName)
                    if boneID then healthModel:ManipulateBoneScale(boneID, Vector(0,0,0)) end
                end
            end
        end
        healthModel:DrawModel()
        for partName, partData in pairs(bodyParts) do
            for _, boneName in ipairs(partData.bones) do
                local boneID = healthModel:LookupBone(boneName)
                if boneID then healthModel:ManipulateBoneScale(boneID, Vector(1,1,1)) end
            end
        end

        -- Damaged parts
        for partName, partData in pairs(bodyParts) do
            local state = limbStates[partName]
            if state and state.health > 0 and not state.isBroken and not state.isDislocated then
                local r = state.health
                render.SetColorModulation(col, col * (1 - r), col * (1 - r))
                for _, boneName in ipairs(partData.bones) do
                    local boneID = healthModel:LookupBone(boneName)
                    if boneID then healthModel:ManipulateBoneScale(boneID, Vector(1,1,1)) end
                end
            else
                for _, boneName in ipairs(partData.bones) do
                    local boneID = healthModel:LookupBone(boneName)
                    if boneID then healthModel:ManipulateBoneScale(boneID, Vector(0,0,0)) end
                end
            end
        end
        healthModel:DrawModel()

        -- Broken/Dislocated parts
        local val = (math.sin(time * FRACTURE_BLINK_SPEED) + 1) / 2
        render.SetColorModulation(val, 0, 0)
        for partName, partData in pairs(bodyParts) do
            local state = limbStates[partName]
            if state and (state.isBroken or state.isDislocated) then
                for _, boneName in ipairs(partData.bones) do
                    local boneID = healthModel:LookupBone(boneName)
                    if boneID then healthModel:ManipulateBoneScale(boneID, Vector(1,1,1)) end
                end
            else
                for _, boneName in ipairs(partData.bones) do
                    local boneID = healthModel:LookupBone(boneName)
                    if boneID then healthModel:ManipulateBoneScale(boneID, Vector(0,0,0)) end
                end
            end
        end
        healthModel:DrawModel()

        -- Reset all bones
        for partName, partData in pairs(bodyParts) do
            for _, boneName in ipairs(partData.bones) do
                local boneID = healthModel:LookupBone(boneName)
                if boneID then healthModel:ManipulateBoneScale(boneID, Vector(1,1,1)) end
            end
        end

        DrawHealthAccessories(healthModel, ply)
        
        render.MaterialOverride(nil)
        render.SetColorModulation(1, 1, 1)
        render.SuppressEngineLighting(false)
    cam.End3D()
    
    if org and org.stamina then
        local st = org.stamina
        local val = (type(st) == "table") and st[1] or st
        if type(val) == "table" then val = val[1] or 0 end
        if type(val) ~= "number" then val = 0 end
        
        local max = (type(st) == "table") and st.max or 100
        if type(max) ~= "number" then max = 100 end
        max = math.max(max, 1)
        
        local barW = ScreenScaleFixed(6)
        local barH = h * 0.8
        local barX = viewX + w + ScreenScaleFixed(STAMINA_OFFSET_X)
        local barY = viewY + (h - barH) / 2 + ScreenScaleFixed(STAMINA_OFFSET_Y)
        
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(barX, barY, barW, barH)
        
        local fillH = barH * math.Clamp(val / max, 0, 1)
        surface.SetDrawColor(0, 50, 100, 255)
        surface.DrawRect(barX + 1, barY + barH - fillH + 1, barW - 2, fillH - 2)
    end
end)

hook.Add("OnRemove", "HG_CleanupHealthIndicator", function()
    if IsValid(healthModel) then healthModel:Remove() end
    if IsValid(blinkModel) then blinkModel:Remove() end
end)
