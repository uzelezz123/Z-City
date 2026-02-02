AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("flashbang")

function ENT:InitAdd()
    self:Activate()
end

local burnDamageRadius = 20
local explosionDamageRadius = 30
local disorientationRadius = 300
function ENT:Explode()
    if self:PoopBomb() then
        self:EmitSound("weapons/p99/slideback.wav", 75)
        self.Exploded = true
        return
    end
    local SelfPos = self:GetPos()

    local effectdata = EffectData()
    effectdata:SetOrigin(SelfPos)
    effectdata:SetScale(0.5)
    effectdata:SetNormal(-self:GetAngles():Forward())
    util.Effect("eff_jack_genericboom", effectdata)
    hg.EmitAISound(SelfPos, 512, 16, 1)


    net.Start("projectileFarSound")
        net.WriteString(self.SoundMain)
        net.WriteString(self.SoundFar)
        net.WriteVector(SelfPos)
        net.WriteEntity(self)
        net.WriteBool(self:WaterLevel() > 0)
        net.WriteString("")
    net.Broadcast()
    
    self:EmitSound(self.SoundMain, 145, 85, 1, CHAN_WEAPON)
    self:EmitSound(self.SoundFar, 140, 85, 0.9, CHAN_WEAPON)
    
    timer.Simple(0.05, function()
        if IsValid(self) then
            self:EmitSound(table.Random(self.SoundBass), 150, 70, 0.95, CHAN_AUTO)
        end
    end)
    
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:EmitSound(table.Random(self.SoundBass), 155, 60, 0.9, CHAN_BODY)
        end
    end)

    EmitSound(self.SoundMain, SelfPos, self:EntIndex() + 100, CHAN_STATIC, 1, 140, nil, math.random(75, 85))
    
    EmitSound("snd_jack_fireworkpop5.wav", SelfPos, self:EntIndex() + 200, CHAN_VOICE, 1, 150, nil, math.random(100, 110))
    
    --util.BlastDamage(self, self.owner, SelfPos, self.BlastDis / 0.01905, 5)

    for _, ply in ipairs(ents.FindInSphere(SelfPos, 700)) do
        if not ply:IsPlayer() or not ply:Alive() then continue end

        if hg.isVisible(ply:GetShootPos(), SelfPos, {ply, self}, MASK_VISIBLE) then
            net.Start("flashbang")
                net.WriteVector(SelfPos)
            net.Send(ply)
        end

        local tr = hg.ExplosionTrace(SelfPos, ply:GetPos(), {self, ply})

        if tr.Hit then continue end

        local distance = ply:GetPos():Distance(SelfPos)
        local org = ply.organism  

        if distance <= burnDamageRadius then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(50)
            dmginfo:SetDamageType(DMG_BURN)


            if IsValid(self.Owner) then
                dmginfo:SetAttacker(self.Owner)
            else
                dmginfo:SetAttacker(self)  
            end

            ply:TakeDamageInfo(dmginfo)
        end

        if distance <= explosionDamageRadius then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(75)
            dmginfo:SetDamageType(DMG_BLAST)

            if IsValid(self.Owner) then
                dmginfo:SetAttacker(self.Owner)
            else
                dmginfo:SetAttacker(self)  
            end

            ply:TakeDamageInfo(dmginfo)
        end

        if distance <= disorientationRadius then
            if org then
                hg.ExplosionDisorientation(org.owner, 5, 6)
				hg.RunZManipAnim(org.owner, "shieldexplosion")
                //org.owner:ViewPunch(Angle(0, 0, org.owner:GetAimVector():Dot((SelfPos - org.owner:EyePos()):GetNormalized()) * 55))
            end
        end
    end

    self:Remove()
end