
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
	org.owner:SetNetVar("headcrab", false)
	org.noHead = false
end)

hook.Add("Org Think", "Headcrab",function(owner, org, timeValue)
    if not owner then return end
    if not owner:IsPlayer() or not owner:Alive() then return end

    if org.headcrabon and (org.headcrabon + 15) < CurTime() and org.brain != 1 and org.owner.organism.spine3 != 1 then
		local ent = hg.GetCurrentCharacter(owner) or owner
		local mul = ((org.headcrabon + 60) - CurTime()) / 60
		if mul > 0 then
			ent:GetPhysicsObjectNum(math.random(ent:GetPhysicsObjectCount()) - 1):ApplyForceCenter(VectorRand(-750 * mul,750 * mul))
		end
	end

    if org.owner:IsPlayer() then
		if org.headcrabon then
			org.owner.noHead = true
			org.owner:SetNWString("PlayerName", "Body with headcrab")
			if org.alive then
				local ang = AngleRand(-5, 5)
				ang.r = 0
				org.owner:SetEyeAngles(org.owner:EyeAngles() + ang)
			end
			if (org.headcrabon + 10) < CurTime() and org.alive and not org.headcrabevent then
				org.owner:EmitSound("npc/zombie/zombie_pain"..math.random(6)..".wav", 80, math.random(90, 110))
				if math.random(1, 6) == 3 then
					local neckang = -org.owner:EyeAngles()
					neckang.x = -90
					org.owner:SetEyeAngles(neckang)
					org.owner:Kill()
					org.owner.organism.spine3 = 1
					org.owner:EmitSound("neck_snap_01.wav", 60, 100, 1, CHAN_AUTO)
				else
					org.painadd = org.painadd + 40
					hg.StunPlayer(owner, 5)
				end
				org.headcrabevent = true
			end
		end

        if org.alive and org.headcrabon and (org.headcrabon + 20) < CurTime() then
			if (org.headcrabon + 21) > CurTime() then
				org.owner:EmitSound("npc/zombie/zombie_pain"..math.random(6)..".wav", 80, math.random(80, 90))
			end
			org.needotrub = true
		end

        if org.alive and org.headcrabon and (org.headcrabon + 60) < CurTime() then
			org.owner:SetNWString("PlayerName", "Body with headcrab")
			org.alive = false
		end
    end
end)