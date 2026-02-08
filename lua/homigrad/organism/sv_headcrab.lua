
local PLAYER = FindMetaTable("Player")
util.AddNetworkString("hg_headcrab")
function PLAYER:AddHeadcrab(headcrab)
    --self.organism.headcrabon = headcrab
    self:SetNetVar("headcrab",headcrab)
   
    self.organism.headcrabon = headcrab and CurTime()
	self.organism.headcrabevent = false

    --[[net.Start("hg_headcrab")
    net.WriteEntity(self)
    net.WriteString(headcrab)
    net.Broadcast()--]]
end

hook.Add("RagdollDeath","headcrab",function(ply,rag)
    rag:SetNetVar("headcrab", ply:GetNetVar("headcrab"))
    ply:SetNetVar("headcrab", false)
	ply.organism.noHead = false
end)

hook.Add("Org Clear", "removeheadcrab", function(org)
    org.headcrabon = nil
	org.headcrabevent = false
	if IsValid(org.owner) then
		org.owner:SetNetVar("headcrab", false)
	end
	org.noHead = false
end)

local clr_red, lerpAng = Color(150, 0, 0), Angle(0, 0, 0)
hook.Add("Org Think", "Headcrab",function(owner, org, timeValue)
    if not IsValid(owner) then return end
    if not owner:IsPlayer() or not owner:Alive() then return end

    if org.headcrabon and (org.headcrabon + 15) < CurTime() and org.brain != 1 and owner.organism.spine3 != 1 then
		local ent = hg.GetCurrentCharacter(owner) or owner
		local mul = ((org.headcrabon + 60) - CurTime()) / 60
		if mul > 0 then
			ent:GetPhysicsObjectNum(math.random(ent:GetPhysicsObjectCount()) - 1):ApplyForceCenter(VectorRand(-750 * mul,750 * mul))
		end
	end

    if owner:IsPlayer() then
		if org.headcrabon then
			owner.noHead = true
			owner:SetNWString("PlayerName", "Body with headcrab")
			if org.alive then
				lerpAng = LerpAngle(FrameTime() * 3, lerpAng, AngleRand(-90, 90))
				lerpAng.r = 0
				owner:SetEyeAngles(owner:EyeAngles() + lerpAng)
			end
			if (org.headcrabon + 30) < CurTime() and org.alive and not org.headcrabevent then
				owner:EmitSound("npc/zombie/zombie_alert" .. math.random(3) .. ".wav", 80, math.random(60, 70))
				owner:EmitSound("neck_snap_01.wav", 80, 80, 1, CHAN_AUTO)
				owner:SetPlayerClass("headcrabzombie")
				org.painadd = org.painadd + 40
				hg.StunPlayer(owner, 5)
				if zb and zb.GiveRole then
					zb.GiveRole(owner, "Zombie", clr_red)
				end
				org.headcrabevent = true
				org.headcrabon = nil
				org.headcrabevent = false
				if IsValid(owner) and not IsValid(owner.FakeRagdoll) then
					owner:SetNetVar("headcrab", false)
				end
				org.noHead = false
			end
		end

        if org.alive and org.headcrabon and (org.headcrabon + 20) < CurTime() then
			if (org.headcrabon + 21) > CurTime() then
				owner:EmitSound("npc/zombie/zombie_pain"..math.random(6)..".wav", 80, math.random(80, 90))
				org.painadd = org.painadd + 40
				hg.StunPlayer(owner, 5)
				org.needotrub = true
			end
			org.needotrub = true
		end

        if org.alive and org.headcrabon and (org.headcrabon + 60) < CurTime() then
			owner:SetNWString("PlayerName", "Body with headcrab")
			org.alive = false
		end
    end
end)