
-- Constants
-- Constants
local DAMAGE_THRESHOLD = 95
local DAMAGE_THRESHOLD_HANDS = 70
local HIGH_VELOCITY_THRESHOLD = 175
local DOOR_BREAK_THRESHOLD = 115

-- Damage multipliers
local MULTIPLIERS = {
    head = 0.16,
    legs = 0.14,
    arms = 0.12,
    hands = 0.10
}

-- Dislocation chances
local BASE_DISLOCATION_CHANCE = 0.05
local HIGH_SPEED_DISLOCATION_CHANCE = 0.2
local FAILED_BREACH_DISLOCATION_CHANCE = 0.3

local function apply_dislocation(owner, limb, limb_name)
    if limb == "lleg" then owner.organism.llegdislocation = true
    elseif limb == "rleg" then owner.organism.rlegdislocation = true
    elseif limb == "larm" then owner.organism.larmdislocation = true
    elseif limb == "rarm" then owner.organism.rarmdislocation = true
    end
    --owner:Notify("Your " .. limb_name .. " was dislocated from the impact!", 1, limb .. "_dislocated", 5)
end

local function RagdollBodyDamage()
    for _, ragdoll in ipairs(ents.FindByClass("prop_ragdoll")) do
        if not IsValid(ragdoll) or not ragdoll.IsGlideRagdoll then continue end

        local owner = ragdoll.GlideRagdollPlayer
        if not IsValid(owner) or not owner.organism then continue end

        local body_parts = {
            { bone_name = "ValveBiped.Bip01_Head1", type = "head" },
            { bone_name = "ValveBiped.Bip01_L_Hand", type = "hands" },
            { bone_name = "ValveBiped.Bip01_R_Hand", type = "hands" },
            { bone_name = "ValveBiped.Bip01_L_Forearm", type = "arms", dislocation_limb = "larm", limb_name = "left arm" },
            { bone_name = "ValveBiped.Bip01_R_Forearm", type = "arms", dislocation_limb = "rarm", limb_name = "right arm" },
            { bone_name = "ValveBiped.Bip01_L_Calf", type = "legs", dislocation_limb = "lleg", limb_name = "left leg" },
            { bone_name = "ValveBiped.Bip01_R_Calf", type = "legs", dislocation_limb = "rleg", limb_name = "right leg" }
        }

        for _, part in ipairs(body_parts) do
            local bone_index = ragdoll:LookupBone(part.bone_name)
            if bone_index then
                local phys = ragdoll:GetPhysicsObject(ragdoll:TranslateBoneToPhysBone(bone_index))
                if IsValid(phys) then
                    local vel = phys:GetVelocity()
                    local speed = vel:Length()
                    local threshold = (part.type == "hands") and DAMAGE_THRESHOLD_HANDS or DAMAGE_THRESHOLD

                    if speed > threshold then
                        print("Ragdoll combat damage triggered for", owner:Nick(), "- part:", part.type, "- speed:", speed)

                        local pos = phys:GetPos()
                        local tr = util.TraceLine({
                            start = pos,
                            endpos = pos + vel:GetNormalized() * 8,
                            filter = {owner, ragdoll}
                        })

                        if IsValid(tr.Entity) then
                            if part.type == "head" then
                                net.Start("hg_HeadTrauma")
                                net.Send(owner)
                            end
                            local damage_multiplier = MULTIPLIERS[part.type]
                            local damage = (speed - threshold) * damage_multiplier

                            if tr.Entity:IsPlayer() and tr.Entity ~= owner then
                                local dmginfo = DamageInfo()
                                dmginfo:SetDamage(damage)
                                dmginfo:SetAttacker(owner)
                                dmginfo:SetInflictor(ragdoll)
                                dmginfo:SetDamageType(DMG_CLUB)
                                dmginfo:SetDamageForce(vel * (damage_multiplier * 100))
                                dmginfo:SetDamagePosition(tr.HitPos)
                                tr.Entity:TakeDamageInfo(dmginfo)

                                if part.dislocation_limb then
                                    local chance = (speed > HIGH_VELOCITY_THRESHOLD) and HIGH_SPEED_DISLOCATION_CHANCE or BASE_DISLOCATION_CHANCE
                                    if math.random() < chance then
                                        apply_dislocation(owner, part.dislocation_limb, part.limb_name)
                                    end
                                end
                            elseif hgIsDoor and hgIsDoor(tr.Entity) and not tr.Entity:GetNoDraw() then
                                local door = tr.Entity
                                if speed > DOOR_BREAK_THRESHOLD then
                                    hgBlastThatDoor(door, vel:GetNormalized() * speed * 0.5)
                                else
                                    door.HP = door.HP or 200
                                    door.HP = door.HP - damage
                                    door:EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(1,4) .. ".wav")

                                    if door.HP <= 0 then
                                        hgBlastThatDoor(door, vel:GetNormalized() * 200)
                                    else
                                        if part.dislocation_limb and math.random() < FAILED_BREACH_DISLOCATION_CHANCE then
                                            apply_dislocation(owner, part.dislocation_limb, part.limb_name)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

hook.Add("Think", "RagdollBodyDamage", RagdollBodyDamage)
