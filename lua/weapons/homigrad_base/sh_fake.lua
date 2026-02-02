AddCSLuaFile()
--
SWEP.WorkWithFake = true
SWEP.RHandPos = Vector(-4, -1, 3)
SWEP.LHandPos = Vector(7, -1, -1)
SWEP.AimHands = Vector(0, 1.8, -4.5)
--[[if CLIENT then
    hook.Add("SWEPStep","fakeUpdate",function(self)
        local fakeGun = self:GetNWEntity("fakeGun")
        local owner = self:GetOwner()

        local ent = self:GetWeaponEntity()
        local pos,ang = ent:GetPos(),ent:GetAngles()

        if not IsValid(fakeGun) then return end

        local addControl = owner:GetNWVector("addControl")

        owner.addControl = addControl
		
        local angles = owner:EyeAngles()

        local ragdoll = owner.FakeRagdoll

        if not IsValid(ragdoll) then return end

        local att = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
        pos = att.Pos
        
        local aim = self.AimHands
        local rhandpos = self.RHandPos
        
        local forward,right,up = -aim[1] + 2 - rhandpos[1] + owner.addControl[3], -rhandpos[2] + owner.addControl[2],-10.5 - rhandpos[3] - owner.addControl[1]
        pos:Add(angles:Forward() * forward + angles:Right() * right + angles:Up() * up)
        
        local animpos = (self.weaponAngLerp or Vector(0,0,0))[1] * -5
        angles[1] = angles[1] - animpos / 2

        fakeGun:PhysicsInitShadow(true,true)
        fakeGun:GetPhysicsObject():UpdateShadow(owner:EyePos(),owner:EyeAngles(),FrameTime())
    end)
end]]