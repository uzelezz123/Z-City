ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "loot_crate"
ENT.Category = "ZCity Other"
ENT.Spawnable = false
ENT.IconOverride = "entities/ent_jack_gmod_ezarmor_sc_kappa.png"

ENT.Model = "models/props_junk/wood_crate001a.mdl"
ENT.LootTable = {}
ENT.CanGenerate = false

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetModel(self.Model) --| Стандартные функции спавна

end

function ENT:Draw()
    self:DrawModel()
end

function ENT:PhysicsCollide(data, physobj)
    if data.Speed > 1000 and data.DeltaTime > .2 then
        self:EmitSound("Boulder.ImpactHard")
        self:EmitSound("Canister.ImpactHard")
        self:EmitSound("Boulder.ImpactHard")
        self:EmitSound("Canister.ImpactHard")
        self:EmitSound("Boulder.ImpactHard")
        util.ScreenShake(data.HitPos, 100, 200, .5, 500)
        local Poof = EffectData()
        Poof:SetOrigin(data.HitPos)
        Poof:SetScale(5)
        Poof:SetNormal(data.HitNormal)
        util.Effect("eff_jack_aidimpact", Poof, true, true)

        local Tr = util.QuickTrace(data.HitPos - data.OurOldVelocity, data.OurOldVelocity * 50, {self})

        if Tr.Hit then
            util.Decal("Rollermine.Crater", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
        end
    elseif data.Speed > 80 and data.DeltaTime > .2 then
        self:EmitSound("Canister.ImpactHard")
    end

    --[[if data.DeltaTime > .1 then
        local Phys = self:GetPhysicsObject()
        Phys:SetVelocity(Phys:GetVelocity() / 1.5)
        Phys:AddAngleVelocity(-Phys:GetAngleVelocity() / 1.30)
    end--]]
end