SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Taser X26"
SWEP.Author = "Taser"
SWEP.Instructions = "A TASER is a conducted energy device (CED) primarily used to incapacitate people, allowing them to be approached and handled in an unresisting and thus less-lethal manner."
SWEP.Category = "Weapons - Other"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/realistic_police/taser/w_taser.mdl"
SWEP.WorldModelFake = "models/realistic_police/taser/c_taser.mdl"
//SWEP.FakeScale = 1.2
//SWEP.ZoomPos = Vector(0, -0.0027, 4.6866)
SWEP.FakePos = Vector(-14.4, 2, 5.8)
SWEP.FakeAng = Angle(0, 14, 0)
SWEP.AttachmentPos = Vector(0,-0.1,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload",
}

SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_taser")
SWEP.IconOverride = "vgui/wep_jack_hmcd_taser"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)

SWEP.weight = 1

SWEP.ScrappersSlot = "Secondary"
SWEP.NoWINCHESTERFIRE = true

SWEP.weaponInvCategory = 4
SWEP.ShellEject = ""
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Taser Cartridge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 8
SWEP.Primary.Sound = {"realtasesound.wav", 75, 90, 100}
SWEP.Primary.Force = 5
SWEP.ReloadTime = 2.5
SWEP.FakeReloadSounds = {
	[0.45] = "weapons/kryceks_swep/mp5/magout.wav",
	[0.9] = "weapons/kryceks_swep/mp5/magin2.wav",
}

SWEP.FakeEmptyReloadSounds = {
	[0.45] = "weapons/kryceks_swep/mp5/magout.wav",
	[0.9] = "weapons/kryceks_swep/mp5/magin2.wav",
}
SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/kryceks_swep/mp5/magout.wav",
	"none",
	"weapons/kryceks_swep/mp5/magin2.wav",
	"none",
	"none"
}
SWEP.OpenBolt = true
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(2, -3.55, 2.0)
SWEP.RHandPos = Vector(-5, -1.5, 2)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0, -0.01, 0), Angle(-0.01, 0.01, 0)}
SWEP.Ergonomics = 1
SWEP.AnimShootMul = 0.5
SWEP.AnimShootHandMul = 0.5
SWEP.addSprayMul = 0.5
SWEP.Penetration = 4
SWEP.ShockMultiplier = 1
SWEP.WorldPos = Vector(0, 0, 0)
SWEP.WorldAng = Angle(0, 19, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0,0,0)
SWEP.attAng = Angle(0.05,100.4,0)
SWEP.rotatehuy = 0
SWEP.lengthSub = 25
SWEP.DistSound = ""
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, 0, 0)
SWEP.holsteredAng = Angle(-5, -5, 90)
SWEP.shouldntDrawHolstered = true
SWEP.ImmobilizationMul = 20
SWEP.NoMuzzleEffects = true

SWEP.availableAttachments = {}

function SWEP:InitializePost()
	self.attachments.underbarrel = {[1] = "lasertaser0"}
end

--local to head
SWEP.RHPos = Vector(12,-5,4.5)
SWEP.RHAng = Angle(-2,-2,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

local finger1 = Angle(0,0,0)
local finger2 = Angle(-15,45,-5)

function SWEP:AnimHoldPost(model)
	--self:BoneSet("l_finger0", vector_zero, finger1)
    --self:BoneSet("l_finger02", vector_zero, finger2)
end

function SWEP:Shoot(override)
	if not self:CanPrimaryAttack() then return false end
	if not self:CanUse() then return false end
	if self:Clip1() == 0 then return end
	local primary = self.Primary
	if not self.drawBullet then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		return false
	end
	local owner = self:GetOwner()
	local gun = self:GetWeaponEntity()
	
	local tr,pos,ang = self:GetTrace(true)

	if primary.Next > CurTime() then return false end
	if (primary.NextFire or 0) > CurTime() then return false end
	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	primary.Automatic = weapons.Get(self:GetClass()).Primary.Automatic
	
    local gun = self:GetWeaponEntity()
	local att = self:GetMuzzleAtt(gun, true)
	--self:GetOwner():Kick("lol")
	self:TakePrimaryAmmo(1)
    
    self:EmitShoot()
	self:PrimarySpread()

	if SERVER then
		local dir = ang:Forward()
		
		self:GetOwner():LagCompensation(true)
        local tr = util.TraceLine( {
            start = pos,
            endpos = pos + dir * 220,
            filter = {self},
            mask = MASK_SHOT
        } )
		self:GetOwner():LagCompensation(false)

		if tr.Entity then
            local ent = tr.Entity
			
			if not ent:IsPlayer() and not ent:IsRagdoll() then return end
            if IsValid(ent.FakeRagdoll) then return end
            
			//if ent == hg.GetCurrentCharacter( self:GetOwner() ) then return end
			local d = DamageInfo()
			d:SetDamage(5)
			d:SetAttacker(self:GetOwner())
			d:SetInflictor(self)
			d:SetDamageType(DMG_SLASH) 
			d:SetDamagePosition(tr.HitPos)
			d:SetDamageForce(tr.Normal * 50)
			ent:TakeDamageInfo(d)

            local ply = ent

            if ent:IsRagdoll() then
                ply = hg.RagdollOwner(ent) or ent
            end

			if ply:InVehicle() then
				ply:ExitVehicle()
			end

			local drugged = ply.organism and ply.organism.analgesia > 0.5

            local time = math.random(5,7) * (drugged and 0.2 or 1)
			
			hg.StunPlayer(ply, time + 3 * (drugged and 0.2 or 1))

			if IsValid(ply) and ply:Alive() then
                local org = ply.organism
                org.tasered = CurTime() + time
            end

            ent:EmitSound("tazer.wav")
            local ragdoll = (IsValid(ply) and ply:Alive()) and ply.FakeRagdoll or ent
            local tasered =  CurTime() + time
			local cons1, cons2
			timer.Simple(0.1,function()
				for i = 0, 1 do
					if not IsValid(ent) then return end
					local ent = hg.GetCurrentCharacter(ent)
					local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone or 0)
					local localpos, _ = WorldToLocal(tr.HitPos + tr.Normal * 5, angle_zero, IsValid(phys) and phys:GetPos() or ent:GetPos(), IsValid(phys) and phys:GetAngles() or angle_zero)
					local lpos2, _ = WorldToLocal(tr.StartPos, angle_zero, self:GetWM():GetPos(), self:GetWM():GetAngles())
					--localpos = Vector()
					
					local cons = constraint.CreateKeyframeRope(tr.HitPos, 0.1, "cable/cable2", nil, ent, localpos + VectorRand(-0.5,0.5), tr.PhysicsBone, self:GetWM(), lpos2, 0,
					{
						["Slack"] = 200 - ent:GetPos():Distance(self:GetPos()),
						["Collide"] = 1,
					})

					if i == 0 then
						cons1 = cons
					else
						cons2 = cons
					end
					--PrintTable(cons:GetSaveTable())
					timer.Simple(7, function()
						if IsValid(cons) then
							cons:SetKeyValue("Dangling", 1)
							cons:SetSaveValue("m_hEndPoint", game.GetWorld())
							//cons:Remove()
							//cons = nil
						end
					end)
				end
			end)
			--чзх добавить возможность тазерить мощнее при нажатии лкм
			local i = 1
			local max = math.Round(time * 80)
			local owner = self:GetOwner()
			timer.Create("Tasering"..ent:EntIndex(), 0.01, max,function()
				i = i + 1
				
                local tasered = tasered
				if !ragdoll.organism then return end
				
				if IsValid(self:GetWM()) and IsValid(owner) and owner:GetActiveWeapon() != self then
					self:GetWM():SetPos(owner:HasWeapon(self:GetClass()) and owner:EyePos() or self:GetPos())
					self:GetWM():SetAngles(owner:HasWeapon(self:GetClass()) and owner:EyeAngles() or self:GetAngles())
				end

				if IsValid(ragdoll) then
					local rh = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_R_Hand")))
					local lh = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_L_Hand")))
					local rl = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_R_Foot")))
					local ll = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_L_Foot")))
					local pelvis = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Pelvis")))
					local spine2 = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Spine2")))
					local spine = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Spine1")))

					local pelvispos = pelvis:GetPos() - pelvis:GetAngles():Right() * -100

					local ang = spine2:GetAngles()
					ang:Add(AngleRand(-5, 5))
					ang:RotateAroundAxis(ang:Up(), 180)

					local mul = 1000 * ragdoll.organism.pulse / 70
					local damp = 50
					
					--hg.ShadowControl(ragdoll, 0, 0.001, ang, mul, damp, vector_origin, 0, 0)
					--hg.ShadowControl(ragdoll, 1, 0.001, ang, mul, damp, vector_origin, 0, 0)
					
					hg.ShadowControl(ragdoll, 3, 0.001, ang, mul, damp, vector_origin, 0, 0)
					hg.ShadowControl(ragdoll, 4, 0.001, ang, mul, damp, vector_origin, 0, 0)
					hg.ShadowControl(ragdoll, 5, 0.001, ang, mul, damp, vector_origin, 0, 0)

					hg.ShadowControl(ragdoll, 2, 0.001, ang, mul, damp, vector_origin, 0, 0)
					hg.ShadowControl(ragdoll, 6, 0.001, ang, mul, damp, vector_origin, 0, 0)
					hg.ShadowControl(ragdoll, 7, 0.001, ang, mul, damp, vector_origin, 0, 0)
					
					hg.ShadowControl(ragdoll, 8, 0.001, ang, mul, damp, vector_origin, 0, 0)
					hg.ShadowControl(ragdoll, 9, 0.001, ang, mul, damp, vector_origin, 0, 0)

					hg.ShadowControl(ragdoll, 11, 0.001, ang, mul, damp, vector_origin, 0, 0)
					hg.ShadowControl(ragdoll, 12, 0.001, ang, mul, damp, vector_origin, 0, 0)
				end

                if ent:IsPlayer() then
                    ent.organism.avgpain = ent.organism.avgpain + 0.02
					--ent:SelectWeapon("weapon_hands_sh")
                end

				if math.random(10000) == 1 then
					ent.organism.heartstop = !ent.organism.heartstop
				end

                if i == max then
                    if IsValid(ragdoll) then
                        ragdoll:StopSound("tazer.wav")
                    end

                    ent:StopSound("tazer.wav")
                end
            end)
            return
		end
	end
end
if SERVER then
    hook.Add("Should Fake Up","Tasered",function(ply)
        if ply and IsValid(ply.FakeRagdoll) then
            local org = ply.organism
            if org and org.tasered and org.tasered > CurTime() then
                return true
            end
        end
    end)

    hook.Add("CanControlFake","Tasered", function(ply,rag) 
        local org = ply.organism
        if org and org.tasered and org.tasered > CurTime() then
            return true
        end
    end)

    hook.Add("Org Clear","RemoveTasered",function(org)
		org.tasered = false 
	end)
end

SWEP.LocalMuzzlePos = Vector(8, 4.7, 3)
SWEP.LocalMuzzleAng = Angle(0, 18, -90)
SWEP.WeaponEyeAngles = Angle(0,0,0)

--RELOAD ANIMS PISTOL

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
    Vector(8,2,3),
    Vector(7,2,3),
    Vector(7,4,3),
    Vector(8,4,3),
    Vector(-10,2,-9),
    Vector(5,3,-2),
    Vector(11,4,3),
    Vector(8,2,3),
	Vector(8,2,3),
    Vector(5,4,1),
    Vector(0,0,0),
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0)
}
SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
    Angle(15,25,4),
    Angle(15,30,45),
    Angle(15,10,35),
    Angle(0,0,0),
}

-- Inspect Assault

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(4,4,15),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(-6,-15,-15),
	Angle(1,15,-45),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(0,0,0),
	Angle(0,0,0)
}