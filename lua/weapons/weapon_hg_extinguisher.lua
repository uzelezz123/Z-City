if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Fire Extinguisher"
SWEP.Instructions = "This is a hand-held cylindrical pressure vessel containing an agent that can be discharged to extinguish a fire.\n\nLMB to attack.\nR to change mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 0
SWEP.WorldModel = "models/weapons/tfa_nmrih/w_tool_extinguisher.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_tool_extinguisher.mdl"
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""

SWEP.bloodID = 3

SWEP.HoldType = "revolver"

SWEP.DamageType = DMG_SLASH
SWEP.weight = 4

SWEP.HoldPos = Vector(-15,1,2)
SWEP.HoldAng = Angle()

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 1.9
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(0,2,0.3)
SWEP.weaponAng = Angle(0,0,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 38
SWEP.DamageSecondary = 15

SWEP.PenetrationPrimary = 6
SWEP.PenetrationSecondary = 4

SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 45
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 65
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "HoseSpray",
    ["equip"] = "HoseEquip",
    ["holster"] = "HoseUnquip",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/tfa_nmrih_fext")
	SWEP.IconOverride = "vgui/hud/tfa_nmrih_fext"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

function SWEP:Reload()
    if SERVER then
        if self:GetOwner():KeyPressed(IN_RELOAD) then
            self:SetNetVar("extinguishermode", not self:GetNetVar("extinguishermode"))
            --self:GetOwner():ChatPrint("Changed extinguishermode to "..(self:GetNetVar("extinguishermode") and "spray." or "attack."))
            self:PlayAnim(self:GetNetVar("extinguishermode") and "equip" or "unequip",1,false,nil,false,true)
        end--anim,time,cycling,callback,reverse,sendtoclient
    end
end

hook.Add("OnNetVarSet", "AsdGuilt",function(index, key, var)
    if key == "extinguishermode" then
        local self = Entity(index)
        if not IsValid(self) or not self.AnimList then return end
        self.AnimList["deploy"] = self:GetNetVar("extinguishermode") and "HoseEquip" or "Draw"
    end
end)

function SWEP:ModelAnimAdd(model, pos, ang)
    self.CustomLerpMode = LerpFT(0.1,self.CustomLerpMode or 0, self:GetNetVar("extinguishermode") and 1 or 0)
    pos = pos + ((ang:Up() * -14 + ang:Forward() * -5 + ang:Right() * 3) * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Forward(), -5 * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Up(), 3 * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Right(), 10 * self.CustomLerpMode)

    return pos, ang
end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    if not self.allowsec then return end
    
    if self:GetNWFloat("amountspray", 100) <= 0 then return end
    
    if CLIENT then
        self:PlayAnim("attack2",1,false,nil,false)
        self.animtime = CurTime() + CurTime() % 1

        if not IsValid(self.particleeffect) then
            local att = self:GetAttachment(1)
            local tr = hg.eyeTrace(self:GetOwner())
            self.particleeffect = CreateParticleSystem(self:GetWM(), "NMRIH_EXTINGUISHER", PATTACH_POINT_FOLLOW, 1)
            self.particleeffect:StartEmission()
        else
            if self.particleeffect:IsFinished() then
                self.particleeffect:StartEmission()
            end
        end

        if (self.waitDecal or 0) < CurTime() then
            self.waitDecal = CurTime() + 0.02
            local tr = hg.eyeTrace(self:GetOwner(), 256)
            
            if tr.Hit then
                local norm = tr.HitNormal
                local add = 70 * tr.Fraction * tr.Fraction
                local pos = tr.HitPos + norm:Angle():Right() * math.Rand(-add,add) + norm:Angle():Up() * math.Rand(-add,add)

                util.Decal("Splash.Large", pos + norm, pos - norm)
            end

            if self:GetOwner() != GetViewEntity() then
                local view = render.GetViewSetup(true)

                local dot = view.angles:Forward():Dot(tr.Normal)
                
                local pos = tr.StartPos:ToScreen()
                
                if dot < -0.99 and pos.x > 0 and pos.x < ScrW() and pos.y > 0 and pos.y < ScrH() and hg.isVisible(LocalPlayer():EyePos(), tr.StartPos, {LocalPlayer(), self}, MASK_VISIBLE) then
                    //amtflashed2 = amtflashed2 + (FrameTime() * 2)
                end//покачто
            end
        end

        self.sound = self:StartLoopingSound("fire_extinguisher/fire_extinguisger_startloop.wav")
        
        timer.Create("extinguisher"..self:EntIndex(), 0.1, 1, function()
            if IsValid(self) then
                if self.sound then
                    self:StopLoopingSound(self.sound)
                end

                if IsValid(self.particleeffect) then
                    self.particleeffect:StopEmission()
                end
            end
        end)
    else
        if (self.lasttimeused or 0) > CurTime() then return false end
        self.lasttimeused = CurTime() + 0.1
        local tr = hg.eyeTrace(self:GetOwner(), 256)
        self.sprayamt = self.sprayamt or 100
        self.sprayamt = self.sprayamt - FrameTime() * 40
        self:SetNWFloat("amountspray", self.sprayamt)
        		
        for k, ent in ipairs(ents.FindInSphere(tr.HitPos,32)) do
            if ent:IsPlayer() and ent:Alive() and ent != self:GetOwner() then
                local org = ent.organism
                if org and not org.holdingbreath then
                    org.o2[1] = math.max(0,org.o2[1] - 0.5 * (0.1 / 0.25))
                    org.is_sprayed_at = true
                    if not org.otrub and math.random(1, 8) == 1 then
                        ent:Notify("", 5, "coughing", nil, function() hg.organism.module.random_events.TriggerRandomEvent(ent,"Cough") end, color_white)
                    end
                end
            end

            if ent:GetClass() == "vfire" then
                ent.life = (ent.life or 0 ) - 40 * (0.1 / 0.25)
                if ent.life < 2 then
                    ent:Remove()
                end
            end
        end
    end

    return false
end

function SWEP:CanPrimaryAttack()
    if IsValid(self:GetOwner()) and hg.KeyDown(self:GetOwner(), IN_RELOAD) then return end
    if not self:GetNetVar("extinguishermode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -5 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 0 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -5 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 30 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -60 or 0)

    return true
end

SWEP.NoHolster = true
SWEP.MinSensivity = 0.75