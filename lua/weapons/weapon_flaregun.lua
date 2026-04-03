if SERVER then
    AddCSLuaFile()
end

SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Flare Gun"
SWEP.Author = ""
SWEP.Instructions = "Single-shot flare pistol."
SWEP.Category = "Weapons - Other"
SWEP.Slot = 2
SWEP.SlotPos = 11
SWEP.ViewModel = "models/weapons/c_sinabackstabber.mdl"
SWEP.WorldModel = "models/weapons/w_sinabackstabber.mdl"
SWEP.WorldModelFake = "models/weapons/c_sinabackstabber.mdl"
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.FiresUnderwater = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.FakePos = Vector(-21.5, 3.2, 5.2)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "muzzle"
SWEP.UseCustomWorldModel = true
SWEP.WorldPos = Vector(0, 0, 0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 20
if CLIENT then
    local IconPath = "vgui/flaregun_homigrad.png"

    SWEP.IconOverride = IconPath
    SWEP.BounceWeaponIcon = false
    SWEP.DrawWeaponInfoBox = true
    SWEP.WepSelectIcon2 = Material(IconPath, "smooth noclamp")
    SWEP.WepSelectIcon2box = true

    local IconMat = SWEP.WepSelectIcon2

    function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
        self:PrintWeaponInfo(x + wide + 20, y + tall * 0.15, alpha)

        if not IconMat or IconMat:IsError() then return end

        surface.SetDrawColor(255, 255, 255, alpha or 255)
        surface.SetMaterial(IconMat)

        local size = math.min(wide, tall) * 0.75
        local ix = x + (wide - size) * 0.5
        local iy = y + (tall - size) * 0.5 - 16

        surface.DrawTexturedRect(ix, iy, size, size)
    end

    function SWEP:DrawHUD()
        self.isscoping = false

        if self.attachments then
            for plc, att in pairs(self.attachments) do
                if not self:HasAttachment(plc) then continue end
                if hg.attachments[plc][att[1]].sightFunction then
                    hg.attachments[plc][att[1]].sightFunction(self)
                end
            end
        end

        if self.ChangeFOV then self:ChangeFOV() end
        if self.DrawHUDAdd then self:DrawHUDAdd() end
        if self.dort and self.DoRT then self:DoRT() end
    end
end

SWEP.AnimList = {
    ["idle"] = "idle",
    ["fire"] = "fire",
    ["reload"] = "reload",
    ["reload_empty"] = "reload"
}

SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 4
SWEP.availableAttachments = {}
SWEP.NoMuzzleEffects = true
SWEP.ShellEject = ""
SWEP.DistSound = ""
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, 0, 0)
SWEP.holsteredAng = Angle(-5, -5, 90)
SWEP.shouldntDrawHolstered = true

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Cone = 0.01
SWEP.Primary.Damage = 7
SWEP.Primary.Sound = {"flaregun.mp3", 75, 100, 100}
SWEP.Primary.SoundFP = {"flaregun.mp3", 75, 100, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/m14/handling/m14_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 4
SWEP.Primary.Wait = 1
SWEP.Tracer = "AR2Tracer"

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(2, -3.55, 2.0)
SWEP.RHandPos = Vector(-5, -1.5, 2)
SWEP.LHandPos = false
SWEP.RHPos = Vector(12, -5, 4.5)
SWEP.RHAng = Angle(-2, -2, 90)
SWEP.LHPos = false
SWEP.LocalMuzzlePos = Vector(8, 4.7, 3)
SWEP.LocalMuzzleAng = Angle(0, 18, -90)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SprayRand = {Angle(0, 0, 0), Angle(0, 0, 0)}
SWEP.Ergonomics = 1
SWEP.AnimShootMul = 0.5
SWEP.AnimShootHandMul = 0.5
SWEP.addSprayMul = 0.5
SWEP.Penetration = 2
SWEP.ShockMultiplier = 1
SWEP.weight = 1
SWEP.NoWINCHESTERFIRE = true
SWEP.AutomaticDraw = false
SWEP.CanSuicide = true
SWEP.DeployAnim = ACT_VM_DRAW
SWEP.ShootAnim = ACT_VM_PRIMARYATTACK
SWEP.IdleAnim = ACT_VM_IDLE

local function isfinite(n)
    return n == n and n ~= math.huge and n ~= -math.huge
end

local function validvec(v)
    return v and isfinite(v.x) and isfinite(v.y) and isfinite(v.z)
end

local function safe_normalized(v, fallback)
    if not validvec(v) then return fallback or vector_forward end
    local len = v:Length()
    if len < 0.001 then return fallback or vector_forward end
    return v / len
end

local function igniteEntitySafe(ent, duration)
    if not IsValid(ent) then return end
    if ent.WaterLevel and ent:WaterLevel() > 0 then return end
    if ent.IsOnFire and ent:IsOnFire() then return end
    if ent.GetClass and ent:GetClass() == "prop_ragdoll" then
        if ent:GetNWBool("pat_flare_ignited") then return end
        ent:SetNWBool("pat_flare_ignited", true)
        timer.Simple(duration + 0.2, function()
            if IsValid(ent) then
                ent:SetNWBool("pat_flare_ignited", false)
            end
        end)
    end
    ent:Ignite(duration, 16)
end

local function igniteHitEntity(ent)
    if not IsValid(ent) then return end
    local d
    if ent:IsPlayer() then
        d = 5
    elseif ent.GetClass and ent:GetClass() == "prop_ragdoll" then
        d = 6
    else
        d = 10
    end
    igniteEntitySafe(ent, d)
end

local function applyRagdollKnockback(ragdoll, hitPos, forceDir, strength, physBoneHint)
    if not IsValid(ragdoll) then return end

    local physBone = tonumber(physBoneHint) or -1
    if physBone < 0 then
        physBone = ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Spine2") or 0)
    end
    if physBone < 0 then
        physBone = 0
    end

    local phys = ragdoll:GetPhysicsObjectNum(physBone)
    if not IsValid(phys) then
        phys = ragdoll:GetPhysicsObject()
    end
    if not IsValid(phys) then return end
    local dir = safe_normalized(forceDir or vector_forward, vector_forward)
    local str = tonumber(strength) or 4500
    if not isfinite(str) or str <= 0 then str = 4500 end
    phys:Wake()
    phys:ApplyForceCenter(dir * str)

    local pelvisBone = ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Pelvis") or -1)
    local pelvis = pelvisBone >= 0 and ragdoll:GetPhysicsObjectNum(pelvisBone) or nil
    if IsValid(pelvis) then
        pelvis:Wake()
        pelvis:ApplyForceCenter(dir * (str * 0.55) + Vector(0, 0, 700))
    end
end

local function handlePlayerFlareHit(weapon, ply, tr, dmginfo)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    dmginfo:SetDamage(0)
    dmginfo:SetDamageForce(vector_origin)

    local attacker = dmginfo:GetAttacker()
    local inflictor = IsValid(weapon) and weapon or dmginfo:GetInflictor()
    local safeAttacker = IsValid(attacker) and attacker or game.GetWorld()
    local safeInflictor = IsValid(inflictor) and inflictor or safeAttacker
    local aimVec = IsValid(attacker) and attacker.GetAimVector and attacker:GetAimVector() or (tr.Normal * -1)
    local rawDir = tr.Normal * -0.35 + aimVec + Vector(0, 0, 0.18)
    local forceDir = safe_normalized(rawDir, vector_forward)

    if ply:InVehicle() then
        ply:ExitVehicle()
    end

    if not IsValid(ply.FakeRagdoll) then
        hg.LightStunPlayer(ply, 2.6)
    end

    timer.Simple(0, function()
        if not IsValid(ply) then return end

        local ragdoll = ply.FakeRagdoll
        if not IsValid(ragdoll) then
            ragdoll = ply:GetNWEntity("FakeRagdoll")
        end
        if not IsValid(ragdoll) then return end

        local burnInfo = DamageInfo()
        burnInfo:SetAttacker(safeAttacker)
        burnInfo:SetInflictor(safeInflictor)
        burnInfo:SetDamage(4)
        burnInfo:SetDamageType(bit.bor(DMG_BURN, DMG_SLOWBURN))
        burnInfo:SetDamagePosition(tr.HitPos)
        burnInfo:SetDamageForce(forceDir * 250)

        ragdoll:TakeDamageInfo(burnInfo)
        igniteEntitySafe(ragdoll, 6)
        applyRagdollKnockback(ragdoll, tr.HitPos, forceDir, 5200, tr.PhysicsBone)
    end)
end

function SWEP:GetFlareLaunchData()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local shootPos = owner:GetShootPos()
    local aimAng = owner:EyeAngles()
    local aimVec = aimAng:Forward()
    local launchPos = shootPos + aimAng:Right() * 2 + aimVec * 10

    return shootPos, aimVec, launchPos
end
function SWEP:ShouldDropOnDie()
    return self:Clip1() > 0
end

function SWEP:Reload()
    return false
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:DoFlareShot(pos, ang)
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local shootPos, aimVec, launchPos = self:GetFlareLaunchData()
    if not shootPos or not aimVec or not launchPos then return end

    local traceData = {
        start = shootPos,
        endpos = shootPos + aimVec * 32768,
        mins = Vector(-5, -5, -5),
        maxs = Vector(5, 5, 5),
        filter = {owner, owner.FakeRagdoll, self},
        mask = MASK_SHOT
    }

    owner:LagCompensation(true)
    local tr = util.TraceHull(traceData)
    if not tr.Hit then
        traceData.mins = nil
        traceData.maxs = nil
        tr = util.TraceLine(traceData)
    end
    owner:LagCompensation(false)

    if not tr then return end

    local hitPos = tr.HitPos or traceData.endpos

    local effectdata = EffectData()
    effectdata:SetEntity(self)
    effectdata:SetStart(launchPos)
    local visualEnd = hitPos - Vector(0, 0, math.Clamp(launchPos:Distance(hitPos) * 0.07, 24, 140))
    effectdata:SetOrigin(visualEnd)
    effectdata:SetMagnitude(260)
    effectdata:SetScale(2.1)
    util.Effect("pat_flare_tracer", effectdata, true, true)

    if tr.HitSky then
        local skyBurstPos = visualEnd
        local tracerTravelTime = math.Clamp(launchPos:Distance(visualEnd) / 260, 0.75, 1.75)

        timer.Simple(tracerTravelTime, function()
            local airburst = EffectData()
            airburst:SetOrigin(skyBurstPos)
            airburst:SetNormal(vector_up)
            airburst:SetScale(2.8)
            util.Effect("pat_flare_airburst", airburst, true, true)
        end)
    elseif tr.Hit then
        local impactdata = EffectData()
        impactdata:SetOrigin(hitPos)
        impactdata:SetNormal(tr.HitNormal)
        impactdata:SetScale(1.6)
        util.Effect("pat_flare_impact", impactdata, true, true)

        local spark = ents.Create("env_spark")
        if IsValid(spark) then
            spark:SetPos(hitPos + tr.HitNormal * 2)
            spark:SetAngles(tr.HitNormal:Angle())
            spark:SetKeyValue("Magnitude", "3")
            spark:SetKeyValue("TrailLength", "3")
            spark:SetKeyValue("MaxDelay", "0")
            spark:Spawn()
            spark:Fire("SparkOnce")
            spark:Fire("Kill", "", 0.1)
        end
    end

    if not IsValid(tr.Entity) then return end

    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(owner)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamage(self.Primary.Damage)
    dmginfo:SetDamageType(bit.bor(DMG_BURN, DMG_DIRECT))
    dmginfo:SetDamagePosition(hitPos)
    local aimVecNorm = safe_normalized(aimVec, vector_forward)
    dmginfo:SetDamageForce(aimVecNorm * math.max(self.Primary.Force, 1) * 250)

    if tr.Entity:IsPlayer() then
        handlePlayerFlareHit(self, tr.Entity, tr, dmginfo)
        return
    end

    tr.Entity:TakeDamageInfo(dmginfo)
    igniteHitEntity(tr.Entity)
end

function SWEP:ConsumeWeapon()
    if CLIENT then return end

    local owner = self:GetOwner()
    timer.Simple(0.15, function()
        if not IsValid(self) then return end
        if IsValid(owner) and owner:IsPlayer() then
            if owner:HasWeapon("weapon_hands_sh") then
                owner:SelectWeapon("weapon_hands_sh")
            end
        end

        SafeRemoveEntity(self)
    end)
end

function SWEP:Shoot(override)
    if not override and not self:CanPrimaryAttack() then return false end
    if not override and not self:CanUse() then return false end
    if self:Clip1() <= 0 then
        self.LastPrimaryDryFire = CurTime()
        self:PrimaryShootEmpty()
        return false
    end

    local primary = self.Primary
    if not override and IsValid(self:GetOwner()) and not self:GetOwner():IsNPC() and primary.Next > CurTime() then return false end
    if not override and IsValid(self:GetOwner()) and not self:GetOwner():IsNPC() and (primary.NextFire or 0) > CurTime() then return false end

    primary.Next = CurTime() + primary.Wait
    self:SetLastShootTime(CurTime())

    local _, pos, ang = self:GetTrace(true)
    self:DoFlareShot(pos, ang)

    self:EmitShoot()
    self:PrimarySpread()
    self:TakePrimaryAmmo(1)

    if SERVER then
        self:SetNWInt("Clip1", self:Clip1())
    end

    self.drawBullet = false
    if self.AutomaticDraw then
        self:Draw()
    end

    if self.PlayAnim then
        self:PlayAnim("fire", 1, false, nil, false, true)
    end

    self:ConsumeWeapon()
    return true
end









