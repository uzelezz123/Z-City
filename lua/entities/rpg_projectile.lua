if SERVER then AddCSLuaFile() end
ENT.Base = "projectile_base"
ENT.Author = "Sadsalat"
ENT.Category = "ZCity Other"
ENT.PrintName = "RPG-7 Rocket"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Model = "models/weapons/tfa_ins2/w_rpg7_projectile.mdl"
ENT.Sound = "snd_jack_bigsplodeclose.wav"
ENT.SoundFar = "mortar_strike_far_dist_03.wav"
ENT.SoundWater = "iedins/water/ied_water_detonate_01.wav"
ENT.Speed = 5249
ENT.TruhstTime = 0.4
ENT.IconOverride = "vgui/inventory/weapon_rpg7"

ENT.BlastDamage = 200
ENT.BlastDis = 7

ENT.UseType = SIMPLE_USE


ENT.SafetyDistance = 7 * 52.49

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    if SERVER then
        self:SetUseType(SIMPLE_USE)
        
        self.StartPos = self:GetPos()
        self.SafetyArmed = false
    end
end


function ENT:CheckSafetyDistance()
    if not self.StartPos then
        self.StartPos = self:GetPos()
        return false
    end
    
    local distance = self:GetPos():Distance(self.StartPos)
    
    if distance >= self.SafetyDistance and not self.SafetyArmed then
        self.SafetyArmed = true
        self:EmitSound("buttons/button16.wav", 50, 150, 0.3)
    end
    
    return self.SafetyArmed
end

local function IsSoftSurface(trace)
    local surfName = util.GetSurfacePropName(trace.SurfaceProps or 0):lower()
    
    if surfName:find("dirt") or 
       surfName:find("mud") or 
       surfName:find("grass") or 
       surfName:find("sand") or
       surfName:find("gravel") or
       surfName:find("snow") or
       surfName:find("flesh") or
       surfName:find("foliage") then
        return true
    end
    
    return false
end

local function superfightermoment(self, ent)
    if ent.organism and ent.organism.superfighter then
        if ent:IsPlayer() then hg.Fake(ent) end

        timer.Simple(0,function()
            local rag = hg.GetCurrentCharacter(ent)
            if IsValid(rag) and rag ~= ent then
                local phys = rag:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetMass(0)
                end
                rag:SetPos(self:GetPos())
                rag:SetParent(self)
                constraint.Weld(rag, self, 1, 0, 0, true, true)
            end
        end)

        return true
    end
end

function ENT:AboutToHit2(trace)
    if superfightermoment(self, trace.Entity) then
        return true
    end
    
    if trace.Hit and not trace.HitSky then

        if not self:CheckSafetyDistance() then
            if IsSoftSurface(trace) then
                self.Duded = true 
                return true
            else
                return true
            end
        end
        
        if IsSoftSurface(trace) then
            return true
        else
            self:Detonate()
            return true
        end
    end
    
    return false
end

function ENT:PhysicsCollide2(data, physobj)
    if self.toremove then return end
    if superfightermoment(self, data.HitEntity) and not self.dragvec then
        self.dragvec = data.OurOldVelocity:GetNormalized()
        self.Truhst = CurTime() + 10
        return true
    end
    
    if IsValid(physobj) then
        physobj:SetVelocity(Vector(0, 0, 0))
        physobj:SetAngleVelocity(Vector(0, 0, 0))
    end
    
    local hitEntity = data.HitEntity
    local hitPos = data.HitPos
    local hitNormal = data.HitNormal
    
    local tr = util.TraceHull({
        start = self:GetPos(),
        endpos = hitPos,
        mins = Vector(-2, -2, -2),
        maxs = Vector(2, 2, 2),
        filter = self
    })
    
    local trace = {
        Hit = tr.Hit,
        HitPos = tr.HitPos or hitPos,
        HitNormal = tr.HitNormal or hitNormal,
        Entity = tr.Entity or hitEntity,
        MatType = tr.MatType or 0,
        HitTexture = tr.HitTexture or "unknown",
        SurfaceProps = tr.SurfaceProps or 0
    }
    
    if IsSoftSurface(trace) then
        physobj:EnableMotion(false)
        physobj:Sleep()
        physobj:SetVelocity(Vector(0, 0, 0))
        physobj:SetAngleVelocity(Vector(0, 0, 0))
        self:SetMoveType(MOVETYPE_NONE)
        
        local dud_chance
        if not self:CheckSafetyDistance() then
            dud_chance = 100 
        else
            dud_chance = math.random(1, 100)
        end
        
        if (not self:CheckSafetyDistance()) or (dud_chance <= 5) then
            local penetrationDepth = -3
            local embedPos = hitPos + hitNormal * -penetrationDepth
            local embedAngle = data.OurOldVelocity:Angle()
            
            timer.Simple(0, function()
                if not IsValid(self) then return end

                local ent = ents.Create("ent_ammo_rpg-7projectile")
                ent.AmmoCount = 1
                function ent:Use()
                end
                ent:SetPos(embedPos)
                ent:SetAngles(embedAngle)
                ent:Spawn()

                ent:SetSolid(SOLID_VPHYSICS)
                ent:SetCollisionGroup(COLLISION_GROUP_NONE)
                ent:SetModel(self:GetModel())
                ent:PhysicsInit(SOLID_VPHYSICS)
                local newPhys = ent:GetPhysicsObject()
                if IsValid(newPhys) then
                    newPhys:EnableMotion(false)
                    newPhys:Sleep()
                end

                if IsValid(hitEntity) and !hitEntity:IsWorld() then
                    constraint.Weld(ent, hitEntity, 0, data.PhysicsBone or 0, 50000, true, false)
                end
                self:Remove()
            end)
            
            self.Duded = false 
            self.Deactivated = true 
            self:StopSound("weapons/ins2rpg7/rpg_rocket_loop.wav")
            self:EmitSound("weapons/pistol/pistol_empty.wav", 60, 100, 0.8)
        else
            self:Detonate()
        end
        
        return true
    else
        if not self.Exploded then
            if self:CheckSafetyDistance() then
                self:Detonate()
            else
                self.toremove = true
                timer.Simple(0, function()
                    local ent = ents.Create("ent_ammo_rpg-7projectile")
                    ent.AmmoCount = 1
                    ent:SetPos(self:GetPos())
                    ent:SetAngles(self:GetAngles())
                    ent:Spawn()

                    local newPhys = ent:GetPhysicsObject()
                    if IsValid(newPhys) then
                        newPhys:SetVelocity(data.OurOldVelocity)
                    end

                    self:Remove()
                end)
            end
        end
        return true
    end
end

function ENT:OnTakeDamage(damage)
    if self.Duded and damage:GetDamage() >= 10 then
        self.Duded = false
        self:Detonate()
        return
    end
    
    self.BaseClass.OnTakeDamage(self, damage)
end

local doubt_phrases = {
    "Should I really do this...",
    "What if I explode",
    "I hope this thing doesn't blow up",
    "Hopefully it won't explode",
    "God give me strength",
    "If it blows up, it blows up..."
}

local relief_phrases = {
    "Thank God",
    "I thought I was going to die",
    "Lord I thought it was about to explode",
    "What a relief",
    "My God I thought I was going to die",
    "Hah, not as scary as I thought",
    "Now everything is safe"
}

function ENT:Use(ply)
    if not SERVER then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end

    if self.Deactivated then
        if self:GetPos():Distance(ply:GetPos()) > 100 then
            return
        end
        
        ply:GiveAmmo(1, "RPG_Round", true)
        self:Remove()
        return
    end
    
    if self.Duded then
        if self:GetPos():Distance(ply:GetPos()) > 100 then
            return
        end
        
        if not self.UseWarned then
            local doubt_phrase = doubt_phrases[math.random(#doubt_phrases)]
            if ply.Notify then
                ply:Notify(doubt_phrase, 3)
            else
                ply:ChatPrint(doubt_phrase)
            end
            self.UseWarned = true
            return
        end
        
        if not self.ExtractStarted then
            self.ExtractStarted = true
            self.ExtractingPlayer = ply
            ply:ChatPrint("In progress")
            
            local dots = ""
            timer.Create("RPGExtractDots_" .. self:EntIndex(), 1, 6, function()
                if not IsValid(self) or not IsValid(ply) then 
                    timer.Remove("RPGExtractDots_" .. self:EntIndex())
                    return 
                end
                
                if self:GetPos():Distance(ply:GetPos()) > 100 then
                    timer.Remove("RPGExtractDots_" .. self:EntIndex())
                    --ply:ChatPrint("huy")
                    self.ExtractStarted = false
                    self.ExtractingPlayer = nil
                    return
                end
                
                dots = dots .. "."
                ply:ChatPrint("In progress" .. dots)
                
                if dots == "......" then
                    timer.Remove("RPGExtractDots_" .. self:EntIndex())
                    
                    if math.random(1, 2) == 1 then
                        self.Duded = false
                        self:Detonate()
                    else
                        local relief_phrase = relief_phrases[math.random(#relief_phrases)]
                        if ply.Notify then
                            ply:Notify(relief_phrase, 3)
                        else
                            ply:ChatPrint(relief_phrase)
                        end
                        
                        ply:GiveAmmo(1, "RPG_Round", true)
                        
                        self:Remove()
                    end
                end
            end)
        end
        
        return
    end
    
    if IsValid(ply) then
        ply:PickupObject(self)
    end
end

if SERVER then
    util.AddNetworkString("rpg_explosion_sound")
end


function ENT:PlayDistantExplosionSounds()
    if SERVER then
        net.Start("rpg_explosion_sound")
        net.WriteVector(self:GetPos())
        net.WriteString(self.Sound)
        net.WriteString(self.SoundFar)
        net.Broadcast()
    end
end

--;; shared.lua shit
if CLIENT then
    net.Receive("rpg_explosion_sound", function()
        local explosionPos = net.ReadVector()
        local closeSound = net.ReadString()
        local farSound = net.ReadString()
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local distance = ply:GetPos():Distance(explosionPos)
        local time = distance / 17836 

        local tr = util.TraceLine({
            start = explosionPos,
            endpos = explosionPos + Vector(0, 0, 2000),
            mask = MASK_SOLID_BRUSHONLY
        })
        local bRoom = tr.HitSky or not tr.Hit
        local roomMultiplier = bRoom and 1.0 or 0.7
        
        if distance <= 1500 then
            EmitSound(closeSound, explosionPos, 0, CHAN_AUTO, 1, 120 * roomMultiplier, 0, 100, SOUND_LEVEL_GUNFIRE)
        else
            timer.Simple(time, function()
                if not IsValid(ply) then return end
                
                local baseVolume = math.Clamp(150 - (distance / 100), 60, 150) * roomMultiplier
                local farPitch = math.Clamp(100 - (distance / 1000), 70, 95)

                EmitSound(farSound, explosionPos, 0, CHAN_STATIC, 1, baseVolume, 0, farPitch, SOUND_LEVEL_GUNFIRE)
                
                if distance > 3000 then
                    timer.Simple(0.5, function()
                        EmitSound(farSound, explosionPos, 1, CHAN_STATIC, 1, baseVolume * 0.6, 0, farPitch - 15, SOUND_LEVEL_GUNFIRE)
                    end)
                end
            end)
        end
    end)
end

function ENT:Detonate()
    if SERVER then
        self:PlayDistantExplosionSounds()
        self.NoExplosionSound = true 
    end
    
    self.BaseClass.Detonate(self)
end

local ProblematicNPCs = {
    ["npc_combinegunship"] = true,
    ["npc_combinedropship"] = true,
    ["npc_strider"] = true,
    ["npc_helicopter"] = true,
}

function ENT:CheckProximityToProblematicNPCs()
    if CLIENT then return false end
    if self.Exploded then return false end
    
    local pos = self:GetPos()
    local checkRadius = 150
    
    local nearbyEnts = ents.FindInSphere(pos, checkRadius)
    
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:IsNPC() then
            local class = ent:GetClass()
            if ProblematicNPCs[class] then
                local npcCenter = ent:LocalToWorld(ent:OBBCenter())
                local distToCenter = pos:Distance(npcCenter)
                
                if distToCenter < 200 then
                    return true
                end
                
                local closestPoint = ent:NearestPoint(pos)
                local distToClosest = pos:Distance(closestPoint)
                
                if distToClosest < 80 then
                    return true
                end
            end
        end
    end
    
    return false
end

function ENT:Think()
    if SERVER and not self.SafetyArmed then
        self:CheckSafetyDistance()
    end
    
    if SERVER and not self.Exploded then
        if self:CheckProximityToProblematicNPCs() then
            self:Detonate()
            return
        end
    end
    
    self.BaseClass.Think(self)
end