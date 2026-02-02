AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


util.AddNetworkString("zb_heli_phase_update")

function ENT:Initialize()
    self:SetModel(self.Model)

    if SERVER then

        if not self.WaitTimeSet then
            self.WaitTime = self.WaitTime or 60
        end
        
        self:SetPos(self:GetPos() + Vector(0, 0, 10))

        local landingPos = self:CalculateLandingPosition()
        self:SetPos(landingPos)

        self:SetColor(Color(255, 255, 255, 0))
        self:SetRenderFX(kRenderFxSolidFast)
        self:SetMaterial("Models/effects/comball_tape")
    end


    self.Phase = "landing" 
    self.LandingTime = CurTime()
    self.WaitingStartTime = nil
    self.DepartingTime = nil

    timer.Simple(0.5, function()
        if !IsValid(self) then return end
        self:SetMaterial("")
    end)

    if CLIENT then return end
    

    self:ResetSequence("spawn")
    self:SetPlaybackRate(1)
    self.AnimationStartTime = CurTime()
    self.AnimationLooping = false
    self:SetupBoneColliders()


    for _, s in ipairs(self.SoundTable) do
        timer.Simple(s.t, function()
            if !IsValid(self) or self.Phase == "finished" then return end
            self:CreateSoundProxy(s)
        end)
    end


    timer.Simple(6, function()
        if !IsValid(self) or self.Phase == "finished" then return end
        self:CreateSmokeCloud()
    end)


    timer.Simple(14, function()
        if !IsValid(self) then return end
        self:StartWaiting()
    end)
end

function ENT:StartWaiting()
    self.Phase = "waiting"
    self.WaitingStartTime = CurTime()
    self:SetBodygroup(3, 1) 

    self:SyncPhaseToClients()
    for _, s in ipairs(self.WaitingSounds) do
        timer.Simple(s.t, function()
            if !IsValid(self) or self.Phase ~= "waiting" then return end
            
            if s.loop then
                self:CreateLoopingSound(s)
            else
                self:CreateSoundProxy(s)
            end
        end)
    end

    timer.Simple(self.WaitTime, function()
        if !IsValid(self) then return end
        self:StartDeparting()
    end)

end

function ENT:StartDeparting()
    self.Phase = "departing"
    self.DepartingTime = CurTime()

    self.AnimationLooping = false
    self.PingPongDirection = nil
    self:SetPlaybackRate(1)
    if self.AnimationStartTime then
        local currentCycle = self:GetCycle()
        self:SetCycle(currentCycle)
    end


    self:SyncPhaseToClients()

    self:StopLoopingSounds()

    for _, s in ipairs(self.SoundTable) do
        timer.Simple(s.t, function()
            if !IsValid(self) or self.Phase == "finished" then return end
            self:CreateSoundProxy(s)
        end)
    end

    local animDuration = self:SequenceDuration()
    timer.Simple(animDuration, function()
        if !IsValid(self) then return end
        self:Remove()
    end)
    

end

function ENT:CreateSoundProxy(soundData)
    local sproxy = ents.Create("infil_soundproxy")
    if not IsValid(sproxy) then return end
    
    sproxy:SetOwner(self:GetOwner())
    sproxy:SetPos(self:GetPos())
    sproxy:SetAngles(self:GetAngles())
    sproxy:SetParent(self)
    sproxy.Sound = soundData.s
    sproxy.Bone = soundData.b
    sproxy.Vol = soundData.v or 100
    sproxy:Spawn()
end

function ENT:CreateLoopingSound(soundData)
    local sound = CreateSound(self, soundData.s)
    sound:SetSoundLevel(75)
    sound:PlayEx(soundData.v or 100, 100)
    
    self.LoopingSounds = self.LoopingSounds or {}
    table.insert(self.LoopingSounds, sound)
end

function ENT:StopLoopingSounds()
    if self.LoopingSounds then
        for _, sound in ipairs(self.LoopingSounds) do
            if sound then
                sound:Stop()
            end
        end
        self.LoopingSounds = nil
    end
end

function ENT:CreateSmokeCloud()
    if ents.Create("blima_smoke") then
        local cloud = ents.Create("blima_smoke")
        cloud:SetPos(self:GetPos())
        cloud:Spawn()
    end
end

function ENT:OnRemove()
    self:StopLoopingSounds()
end

function ENT:SyncPhaseToClients()
    net.Start("zb_heli_phase_update")
        net.WriteEntity(self)
        net.WriteString(self.Phase)
        net.WriteFloat(self.WaitingStartTime or 0)
    net.Broadcast()
end

function ENT:Think()
    if SERVER and self.AnimationStartTime and (self.Phase == "landing" or self.Phase == "waiting") then
        local animTime = CurTime() - self.AnimationStartTime
        
        if not self.AnimationLooping and animTime >= 6.0 then
            self.AnimationLooping = true
            self.PingPongStartTime = CurTime()
            self.PingPongDirection = -1 
            self:SetPlaybackRate(-1) 
            self:SetCycle(6.0 / self:SequenceDuration()) 
        elseif self.AnimationLooping then
            local currentCycle = self:GetCycle()
            local sequenceDuration = self:SequenceDuration()
            local cycle6sec = 6.0 / sequenceDuration
            local cycle7sec = 7.0 / sequenceDuration
            
            if self.PingPongDirection == -1 and currentCycle <= cycle6sec then
                self.PingPongDirection = 1
                self:SetPlaybackRate(1)
                self:SetCycle(cycle6sec)
            elseif self.PingPongDirection == 1 and currentCycle >= cycle7sec then
                self.PingPongDirection = -1
                self:SetPlaybackRate(-1)
                self:SetCycle(cycle7sec)
            end
        end
    end

    if self.Phase == "waiting" and self.WaitingStartTime then
        local waitProgress = (CurTime() - self.WaitingStartTime) / self.WaitTime
    end

    self:NextThink(CurTime() + 0.01)
    return true
end
