local PLAYER = FindMetaTable("Player")

local vpang = Angle(2, 0, 0)
function PLAYER:LegAttack()
    if not self:Alive() or hg.GetCurrentCharacter(self):IsRagdoll() or self:GetNWFloat("InLegKick",0) > CurTime() then return end
    if self.InLegKick and self.InLegKick > CurTime() then return end
    if self:GetNWBool("TauntStopMoving", false) then return end
    if hook.Run( "PlayerCanLegAttack", self ) == false then return end

    local isMidAir = not self:IsOnGround()
    if self:IsSprinting() and not isMidAir then return end

    if isMidAir and self.organism.stamina[1] < 85 then return end

    local anim = "kick_pistol_base"
    anim = (self:KeyDown(IN_DUCK) or self:Crouching()) and "kick_pistol_base_crouch" or self:EyeAngles()[1] > 60 and "curbstomp_base" or self:EyeAngles()[1] > 35 and "kick_pistol_25_base" or self:EyeAngles()[1] > 20 and "kick_pistol_45_base" or anim

    if isMidAir then
        anim = self:EyeAngles()[1] > 60 and "curbstomp_midair" or self:EyeAngles()[1] > 35 and "kick_midair_25" or self:EyeAngles()[1] > 20 and "kick_midair_45" or "kick_midair"
    end

    self:EmitSound("player/clothes_generic_foley_0" .. math.random(1,5) .. ".wav",65)

    local org = self.organism
    org.stamina.subadd = org.stamina.subadd + (anim == "curbstomp_base" and 12 or 20)
    local speedmul = (2 - (org.stamina[1] / org.stamina.max))
    local speed = 1.5 * speedmul
    local animstopAdjust = 0.3 * speedmul
    local org = self.organism
    if hg.IsGoodKarma(self) and org.karma > 75 then
        dmg = dmg * math.min(1.25, 1 + (org.karma - 75) / 100)
    end

    if isMidAir then
        local vel = self:GetVelocity():Length()
        local mult = Lerp(math.Clamp(vel / 700, 0, 1), 1.25, 2.25)
        dmg = dmg * mult
    end

    dmg = dmg * (self:IsBerserk() and org.berserk * 5 or 1)
    dmg = dmg * (org.legstrength or 1)
    if isMidAir then
        dmg = math.min(dmg, 42)
    end
    --print(dmg)
    --print(speedmul)
    self:PlayCustomAnims(anim, true, speed, true, animstopAdjust, {
        [0.12] = function(self)
            if hg.GetCurrentCharacter(self):IsRagdoll() then return end
            if !self:IsOnGround() and !isMidAir then self:PlayCustomAnims("") return end
            local ang = self:EyeAngles()
            ang[1] = 0

            --self:SetVelocity(ang:Forward() * -120)
            local reportPos = self:GetPos() + self:OBBCenter()
            local tr = util.TraceLine({
                start = reportPos,
                endpos = reportPos + ang:Forward() * 32,
                filter = {hg.GetCurrentCharacter(self),self}
            })
            if tr.Hit and (self:IsOnGround() or isMidAir) then
                self:SetVelocity(ang:Forward() * -300)
            end
        end,
        [0.21] = function(self)
            if hg.GetCurrentCharacter(self):IsRagdoll() then return end
            if !self:IsOnGround() and !isMidAir then self:PlayCustomAnims("") return end
            local ang = self:EyeAngles()
            if ang[1] > 55 and not (self:KeyDown(IN_DUCK) or self:Crouching()) then
				self:ViewPunch(vpang)
				return
			else
				self:ViewPunch(-vpang)
			end
            ang[1] = 0
            local reportPos = self:GetPos() + self:OBBCenter()
            local tr = util.TraceLine({
                start = reportPos,
                endpos = reportPos + ang:Forward() * 72,
                filter = {hg.GetCurrentCharacter(self),self}
            })
            if tr.Hit and (self:IsOnGround() or isMidAir) then
                --self:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
                self:SetVelocity(ang:Forward() * -150)
            end
        end,
        [0.33] = function(self) -- kick moment
            if hg.GetCurrentCharacter(self):IsRagdoll() then return end
            if !self:IsOnGround() and !isMidAir then self:PlayCustomAnims("") return end
            local ang = self:EyeAngles()
            ang[1] = 0

            self:EmitSound("player/shove_0" .. math.random(1,5) .. ".wav",65)

            local inDuck = (self:KeyDown(IN_DUCK) or self:Crouching())
            ang = self:EyeAngles()
            ang[1] = inDuck and 0 or math.max(ang[1],10)

            local reportPos = self:GetPos() + self:OBBCenter() + self:GetUp() * ( -5 )
            local rad = Vector(5,5,5)
            local tr = util.TraceHull({
                start = (inDuck and reportPos) or self:EyePos(),
                endpos = ((inDuck and reportPos) or self:EyePos()) + ang:Forward() * 82 ,
                filter = {hg.GetCurrentCharacter(self),self},
                maxs = rad,
                mins = -rad
            })

            local org = self.organism
            if org.rleg == 1 or org.rlegdislocation then
                org.painadd = org.painadd + 20
            end

            if IsValid(tr.Entity) and tr.Entity:IsOnFire() then
                tr.Entity:Extinguish()
            end
            
            local entss = {}--ents.FindInBox( tr.HitPos + rad, tr.HitPos - rad )
            if !table.HasValue(entss, tr.Entity) then
                entss[#entss+1] = tr.Entity
            end
            local soundplayed = false
            local blacklist = {[self] = true, [hg.GetCurrentCharacter(self)] = true}
            local hitSomething = false
            if tr.Hit then
                hitSomething = true
                soundplayed = true
                if org.rleg == 1 or org.rlegdislocation then
                    org.painadd = org.painadd + 20
                end
                self:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
            elseif isMidAir then
                -- If it's a dropkick, we want a larger hit area or forward trace to ensure it lands
                local tr_midair = util.TraceHull({
                    start = self:EyePos(),
                    endpos = self:EyePos() + ang:Forward() * 82,
                    filter = {hg.GetCurrentCharacter(self),self},
                    maxs = rad * 1.4,
                    mins = -rad * 1.4
                })
                if tr_midair.Hit then
                    hitSomething = true
                    tr = tr_midair
                     if !table.HasValue(entss, tr.Entity) then
                        entss[#entss+1] = tr.Entity
                    end
                     soundplayed = true
                     self:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
                end
            end

            if isMidAir and hitSomething then
                local velocity = self:GetVelocity()
                self:SetNWBool("DropkickHit", true)
                timer.Simple(0, function()
                    if not IsValid(self) or not self:Alive() then return end
                    
                    local char = hg.GetCurrentCharacter(self)
                    if char and char:IsValid() then
                        self:PlayCustomAnims("")
                        self.InLegKick = 0
                        self:SetNWFloat("InLegKick", 0)
                        hg.Fake(self)
                        local phys = char:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:SetVelocity(velocity)
                        end
                    end
                end)
            end

            if IsValid(tr.Entity) and tr.Entity.fires then
            local key, fire = next(tr.Entity.fires)

                if key then 
                    tr.Entity.fires[key] = nil

                    if IsValid(key) then
                        key:Remove()
                    end
                end
            end

            local velocity = self:GetVelocity()
            for k,ent in ipairs(entss) do
                if IsValid(ent) and not blacklist[ent] then
                    local normal = ang:Forward()
                    local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone or 0)
                    if !ent:IsPlayer() and not IsValid(phys) then continue end
                    if not soundplayed then
                        soundplayed = true

                        if org.rleg == 1 or org.rlegdislocation then
                            org.painadd = org.painadd + 20
                        end

                        self:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
                    end

                    local dmginfo = DamageInfo()

                    dmginfo:SetAttacker(self)
                    dmginfo:SetInflictor(self)
                    dmginfo:SetDamage(dmg)
                    dmginfo:SetDamageForce(normal * dmg)
                    dmginfo:SetDamageType((ent:GetClass() == "func_breakable_surf") and DMG_SLASH or DMG_CLUB)
                    dmginfo:SetDamagePosition(tr.HitPos)

                    if ent:IsOnFire() then
                        dmginfo:SetDamageType(DMG_GENERIC)
                    end

                    PenetrationGlobal = 1
					MaxPenLenGlobal = 1
                    
                    local horizSpeed = Vector(velocity.x, velocity.y, 0):Length()
                    local forceMult = math.max(500, 700 - horizSpeed / 6)
                    hg.AddForceRag(ent, tr.PhysicsBone or 0, normal * dmg * forceMult, 0.25)
                    ent:TakeDamageInfo(dmginfo)
                    
                    if IsValid(phys) then
                        local forceOffsetMult = math.max(110, 150 - horizSpeed / 70)
                        phys:ApplyForceOffset(normal * dmg * forceOffsetMult, tr.HitPos)
                    end

					if ent:IsPlayer() or ent:GetClass() == "prop_ragdoll" then
						ent:EmitSound("physics/body/body_medium_impact_hard"..math.random(6)..".wav", 60, math.random(85, 105), 0.6)
					end

                    if ent:IsPlayer() then
                        if math.random(1,5) > 3 then
                            timer.Simple(0,function()
                                hg.Fake(ent)
                            end)
                        end

                        local horizSpeed = Vector(velocity.x, velocity.y, 0):Length()
                        local knockback = math.max(10, 20 - horizSpeed / 70) 
                        ent:SetVelocity(normal * knockback)
                    end
                    if hgIsDoor(ent) and !ent:GetNoDraw() then
                        ent.HP = ent.HP or 200
                        ent.HP = ent.HP - dmg * (tr.MatType == MAT_METAL and 1 or 2)
                        ent:EmitSound( "physics/wood/wood_crate_impact_hard" .. math.random(1,4) .. ".wav" )
                        
                        if DoorIsOpen(ent) then
                            if !DoorIsOpen2(ent) then
                                ent:FastOpenDoor(self, 5, true)
                                --ent:Use(self)
                                local oldname = self:GetName()
                                self:SetName(oldname..self:EntIndex())
                                if ent:GetClass() == "func_door_rotating" then
                                    ent:Fire("open", self:GetName(), 0, self, self)
                                elseif ent:GetClass() == "prop_door_rotating" then
                                    ent:Fire("openawayfrom", self:GetName(), 0, self, self)
                                end
                                self:SetName(oldname)
                            else
                                ent:FastOpenDoor(self, 2, true)
                                ent:Fire("Close", oldname, 0, self, self)
                            end

                            ent:EmitSound("physics/wood/wood_box_impact_hard3.wav")
                        end

                        if ent.HP <= 0 then
                            hgBlastThatDoor(ent, normal * 125)
                        end
                    end
                end
            end
        end
    })
    self.InLegKick = CurTime() + speed - animstopAdjust
    self:SetNWFloat("InLegKick",CurTime() + speed - animstopAdjust)

    if isMidAir then
        timer.Simple(0.05, function()
            local function checkLanding()
                if not IsValid(self) or not self:Alive() then return end
                if self:IsOnGround() then
                    timer.Simple(0.1, function()
                        if not IsValid(self) or not self:Alive() then return end
                        -- Only ragdoll if dropkick did NOT hit (i.e., didn't hit anything)
                        if not self:GetNWBool("DropkickHit", false) then
                            self:PlayCustomAnims("")
                            self.InLegKick = 0
                            self:SetNWFloat("InLegKick", 0)
                            hg.Fake(self)
                        end
                        -- Clear the flag after checking
                        self:SetNWBool("DropkickHit", false)
                    end)
                    return
                end
                
                timer.Simple(0.05, checkLanding)
            end
            
            timer.Simple(0.05, checkLanding)
        end)
    end
end

hook.Add("HG_MovementCalc_2","HG-LegKickAnim",function(mul, ply, cmd, mv)
    if ply:GetNWFloat("InLegKick",0) > CurTime() then
        cmd:RemoveKey(IN_MOVELEFT)
        cmd:RemoveKey(IN_MOVERIGHT)
        cmd:RemoveKey(IN_JUMP)

        mv:RemoveKey(IN_MOVELEFT)
        mv:RemoveKey(IN_MOVERIGHT)
        mv:RemoveKey(IN_JUMP)

        mul[1] = math.min(math.max(0.001,1 - (ply:GetNWFloat("InLegKick",0) - CurTime()) * 2 ),1)

        if cmd:KeyDown(IN_DUCK) or ply:Crouching() then
            cmd:AddKey(IN_DUCK)
            mv:AddKey(IN_DUCK)
        else
            cmd:RemoveKey(IN_DUCK)
            mv:RemoveKey(IN_DUCK)
        end
    end
end)

concommand.Add("hg_kick",function(ply)
    ply:LegAttack()
end)