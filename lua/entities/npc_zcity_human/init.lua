AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Z-City Human NPC"
ENT.Category = "Z-City"
ENT.Spawnable = true
ENT.AdminOnly = false

ENT.AutomaticFrameAdvance = true
ENT.m_bShouldCollideWithPlayer = true

list.Set("NPC", "npc_zcity_human", {
    Name = "Z-City Human",
    Class = "npc_zcity_human",
    Category = "Z-City"
})

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/zcity/m/male_01.mdl")
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()
        self:SetSolid(SOLID_BBOX)
        self:SetMoveType(MOVETYPE_STEP)
        self:CapabilitiesAdd(CAP_MOVE_GROUND + CAP_OPEN_DOORS + CAP_AUTO_DOORS + CAP_USE)
        self:SetMaxHealth(100)
        self:SetHealth(100)

        hg.organism.Add(self)
        hg.organism.Clear(self.organism)
        self.organism.fakePlayer = true

        if hg.Appearance and hg.Appearance.GetRandomAppearance then
            local appearance = hg.Appearance.GetRandomAppearance()
            hg.Appearance.ForceApplyAppearance(self, appearance)
        end

        self.PlayerName = "Z-City Human"
        self.GetPlayerName = function() return self.PlayerName end
        self:SetNWString("PlayerName", self.PlayerName)
        self:SetNWVector("PlayerColor", Vector(0.7, 0.7, 0.7))

        self.ZCityWeapon = "weapon_ar15"
        self.ZCityMedicine = "weapon_medkit_sh"
        self.ZCityGrenade = "weapon_hg_grenade_tpik"
        self:SetKeyValue("squadname", "zcity_human")

        timer.Simple(0.1, function()
            if not IsValid(self) then return end
            self:Give(self.ZCityWeapon)
            self:Give(self.ZCityMedicine)
            self:Give(self.ZCityGrenade)
            self:SelectWeapon(self.ZCityWeapon)
            self:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_VERY_GOOD)
        end)
    end

    function ENT:RunAsPlayerAttack()
        local enemy = self:GetEnemy()
        if not IsValid(enemy) then return end

        self:SetLastPosition(enemy:GetPos())
        self:SetSchedule(SCHED_CHASE_ENEMY)

        local weapon = self:GetActiveWeapon()
        if IsValid(weapon) and weapon.PrimaryAttack then
            weapon:PrimaryAttack()
        end
    end

    function ENT:Think()
        local enemy = self:GetEnemy()
        if not IsValid(enemy) then
            local found = ents.FindInSphere(self:GetPos(), 900)
            for _, ent in ipairs(found) do
                if IsValid(ent) and ent:IsPlayer() and ent:Alive() and ent ~= self then
                    self:AddEntityRelationship(ent, D_HT, 99)
                    self:SetEnemy(ent)
                    break
                end
            end
        end

        if IsValid(enemy) then
            local dist = self:GetPos():Distance(enemy:GetPos())
            if dist < 700 then
                self:SetSchedule(SCHED_CHASE_ENEMY)
                self:RunAsPlayerAttack()
            else
                self:SetSchedule(SCHED_CHASE_ENEMY)
            end
        else
            self:SetSchedule(SCHED_IDLE_WANDER)
        end

        self:NextThink(CurTime() + 0.1)
        return true
    end

    function ENT:OnInjured(dmginfo)
        local org = self.organism
        if not org then return end

        if org.blood and org.blood < 3500 and math.random(1, 4) == 1 then
            local medkit = ents.Create("prop_physics")
            medkit:SetModel("models/w_models/weapons/w_eq_medkit.mdl")
            medkit:SetPos(self:WorldSpaceCenter())
            medkit:Spawn()

            org.bleed = math.max(org.bleed - 20, 0)
            org.pain = math.max(org.pain - 15, 0)
            org.health = math.min(org.health + 25, 100)
            self:SetHealth(math.Clamp(self:Health() + 25, 0, self:GetMaxHealth()))
            SafeRemoveEntityDelayed(medkit, 20)
        end
    end

    function ENT:OnKilled(dmginfo)
        hg.organism.Remove(self)
        self:SetSchedule(SCHED_FALL_TO_GROUND)

        if self.ZCityWeapon or self.ZCityGrenade or self.ZCityMedicine then
            local inv = { Weapons = {} }
            inv.Weapons[self.ZCityWeapon] = true
            inv.Weapons[self.ZCityGrenade] = true
            inv.Weapons[self.ZCityMedicine] = true
            self:SetNetVar("Inventory", inv)
        end

        local ragdoll = ents.Create("prop_ragdoll")
        ragdoll:SetModel(self:GetModel())
        ragdoll:SetPos(self:GetPos())
        ragdoll:SetAngles(self:GetAngles())
        ragdoll:Spawn()
        ragdoll:Activate()
        ragdoll.inventory = self:GetNetVar("Inventory", {})
        ragdoll:SetNetVar("Inventory", ragdoll.inventory)
        ragdoll:SetNetVar("Accessories", self:GetNetVar("Accessories", {}))
        ragdoll.armors = self.armors
    end
end
