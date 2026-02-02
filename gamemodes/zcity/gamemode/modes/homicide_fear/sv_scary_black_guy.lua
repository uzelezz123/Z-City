local MODE = MODE

local EVENT = {}
EVENT.Name = "scary_black_guy"
EVENT.Chance = 0.2

local function GetNearBehindPos(pos, viewer, viewerAng)
    pos = pos + vector_up * 32
    viewerAng.pitch = 0
    local return_pos = util.TraceHull({
        start = pos,
        endpos = pos - viewerAng:Forward() * 1300,
        filter = viewer,
        maxs = Vector(32,32,32),
        mins = -Vector(32,32,32)
    }).HitPos
    return_pos = util.TraceLine({
        start = return_pos,
        endpos = return_pos - vector_up * 300
    }).HitPos

    local dist = return_pos:Distance(pos)
    --viewer:ChatPrint(dist)
    return ((dist < 850 and  dist > 5) and return_pos) or false
end

function EVENT:StartScare( ply )
    local pos = GetNearBehindPos(ply:GetPos(),ply,ply:EyeAngles())
    if not pos then return false, "failed" end
    self.Ent = ents.Create("ent_zc_anim")
    self.Ent:SetPos(pos)--
    self.Ent:SetModel("models/Humans/Group01/male_06.mdl")
    self.Ent:SetMaterial("models/debug/debugwhite")
    self.Ent:SetColor(color_black)
    local ang = ply:EyeAngles()
    ang.pitch = 0
    ang.roll = 0
    self.Ent:SetAngles(ang)
    self.Ent:Spawn()
    self.Ent:SetWhiteListToSee(true)
    self.Ent:SetNetVar("CanSeeUserID",{[ply:UserID()] = true})
    self.Ent:ResetSequence(126)
    local EndIndex = self.Ent:EntIndex()
    timer.Simple(1,function()
        if IsValid(ply) and ply:Alive() then return end
        ply:SendLua("Entity("..EndIndex.."):EmitSound(\"cry1.wav\")") -- 
    end)
    self.Started = CurTime()
end
--126 idle
--13 attack
--EVENT:StartScare( Player(13) )--

function EVENT:Think( ply )
    if !ply:Alive() then self:StopScare() return end
    if !IsValid(self.Ent) then self:StopScare() return end
    if self.Started + 60 < CurTime() then self:StopScare() return end
    --self.Ent:SetAngles((ply:EyePos() - self.Ent:GetPos()):Angle())
    local pos = self.Ent:GetPos() + vector_up * 32
    if IsLookingAt(ply, pos, 0.75) and hg.isVisible(pos,ply:EyePos(),{self.Ent, ply},MASK_VISIBLE) then
        self.LookinTime = self.LookinTime or CurTime() + 1
        if self.LookinTime < CurTime() then
            self:Run(ply)
        end
    end
    
end

function EVENT:IsActive( ply )
    return IsValid(self.Ent) and IsValid(ply) and ply:Alive()
end

function EVENT:Run( ply )
    local plypos = ply:GetPos()
    local entpos = self.Ent:GetPos()
    local vec = LerpVector(15*FrameTime(),entpos,ply:GetPos())
    self.Ent:SetPos(vec)
    if !self.ScareSoundSend then
        self.ScareSoundSend = true
        self.Ent:ResetSequence(13)
        ply:SendLua("surface.PlaySound(\"lurker_scream.wav\")")
    end
    if vec:Distance(ply:GetPos()) < 50 then
        ply:KillSilent()
        timer.Simple(0.6,function()
            ply:SendLua("RunConsoleCommand(\"stopsound\")")
        end)--
        for k,v in player.Iterator() do
            v:ScreenFade(SCREENFADE.IN, Color(0,0,0), 0.7, 0.4)
        end
        self.Ent:Remove()
    end
end

function EVENT:StopScare( ply )
    if IsValid(self.Ent) then
        self.Ent:Remove()
    end
end

MODE:AddEvent(EVENT)