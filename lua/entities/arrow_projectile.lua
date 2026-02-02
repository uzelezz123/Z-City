if SERVER then AddCSLuaFile() end
ENT.Base = "projectile_nonexplosive_base"
ENT.Author = "Mannytko"
ENT.Category = "ZCity Other"
ENT.PrintName = "Arrow Projectile"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Model = "models/z_city/nmrih/items/arrow/ammo_arrow_single.mdl"
ENT.HitSound = "weapons/impact/concrete_impact_bullet4.wav"

ENT.Damage = 50
ENT.Force = 3

--ENT.DesiredSilks = {	--; WARNING POINTER
--	{SegmentsDesiredAmt = 5, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
--	{SegmentsDesiredAmt = 6, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2.1, 0, 0)},
--	{SegmentsDesiredAmt = 10, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
--}

if SERVER then
	--local angg = Angle(0, 90, 0)
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		--self:SetAngles(-self:GetAngles())
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(1)
			phys:Wake()
		end
	end

	function ENT:Use(ply)
		ply:GiveAmmo(1, "Arrow", true)
		ply:EmitSound("weapons/bow_deerhunter/arrow_load_0"..math.random(3)..".wav", 55)

		if IsValid(self.HitEntity) and self.HitEntity.organism then
			if self.HitEntity.organism.LodgedEntities then
				self.HitEntity.organism.LodgedEntities[self] = nil
			end

			local mat = self.HitEntity:GetBoneMatrix(self.HitEntity:TranslatePhysBoneToBone(self.phys_bone_id or 0))
			
			if mat then
				local lpos, lang = WorldToLocal(self:GetPos(), angle_zero, mat:GetTranslation(), mat:GetAngles())
				
				for i = 1, 5 do
					hg.organism.AddWoundManual(self.HitEntity.organism.owner, 50, vector_origin, AngleRand(-180, 180), self.HitEntity:GetBoneName(self.HitEntity:TranslatePhysBoneToBone(self.phys_bone_id)), CurTime() + math.Rand(0, 2))
				end
			end

			self:EmitSound("arrow_tear.wav")
		end
		
		self:Remove()
	end
end

function ENT:PostDraw()
	--if(hg.PhysSilk)then
	--	self.Silks = self.Silks or {}
--
	--	for silk_desired_key, silk_desired in ipairs(self.DesiredSilks) do
	--		if(IsValid(self.Silks[silk_desired_key]))then
	--			-- self.Silks[silk_desired_key].Pos = self:LocalToWorld(silk_desired.EntityOffset)
	--		else
	--			local silk = table.Copy(silk_desired)
	--			silk.Pos = self:LocalToWorld(silk_desired.EntityOffset)
	--			silk.Entity = self
	--			self.Silks[silk_desired_key] = hg.PhysSilk.CreateSilk(silk, true)
	--		end
	--	end
	--end
end