SWEP.Base = "weapon_tpik_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Ammo = "Arrow"
SWEP.Primary.Automatic = true
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.ViewModel = ""
SWEP.HoldType = "slam"
SWEP.supportTPIK = true
SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(0,0,0)
SWEP.animtime = 0
SWEP.animspeed = 0
SWEP.cycling = false
SWEP.reverseanim = false
SWEP.sprint_ang = Angle(40,0,-45)
SWEP.HoldPos = Vector(0,0,0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.basebone = 1
SWEP.WorkWithFake = true
SWEP.modelscale = 1
SWEP.modelscale2 = 0.8
SWEP.WorldModel = "models/z_city/nmrih/weapons/bow/w_bow_deerhunter.mdl"
SWEP.weight = 1.5
SWEP.AnimList = {
	["deploy"] = {"draw", 1, false, false, function(self)
		self.CurState = -1
	end},
	["deploy_empty"] = {"drawdry", 1, false, false, function(self)
		self.CurState = -1
	end},

	["holster"] = {"holster", 1},
	["holster_empty"] = {"holsterdry", 1},

	["idle"] = {"idle01", 0.5, false},
	["idle_empty"] = {"idle01dry", 0.5, false},
	
	["meleeattack"] = {"shove", 0.9, false, false, function(self)
		self.CurState = -1
	end},
	["meleeattack_empty"] = {"shovedry", 0.9, false, false, function(self)
		self.CurState = -1
	end},
	["attack"] = {"fire_iron", 2, false, false, function(self)
		self.CurState = 1
		--self.DisableWalkBob = true
		self:PlayAnim("iron_streched")
	end},
	["attack_last"] = {"fire_iron_last", 1, false, false, function(self)
		self.CurState = 0
	end},
	["idle_to_aim"] = {"idle_to_iron", 0.8, false, false, function(self)
		self.CurState = 1
		self:PlayAnim("iron_streched")
	end},
	["idle_to_aim_empty"] = {"idle_to_irondry", 0.8, false, false, function(self)
		self.CurState = 1
	end},
	["aim_to_idle"] = {"iron_to_idle", 0.6, false, false, function(self)
		self.CurState = -1
		self.DisableWalkBob = false
	end},
	["aim_to_idle_empty"] = {"iron_to_idledry", 0.6, false, false, function(self)
		self.CurState = -1
		--self.DisableWalkBob = false
	end},
	["iron_streched"] = {"Iron_Idle_Stretched_Relaxed",4,true,false,nil},
}
SWEP.AnimsEvents = {
	["fire_iron"] = {
		[0.2] = function(self)
			--self.DisableWalkBob = false
			--PrintAnims(self:GetWM())
			self:EmitSound("weapons/bow_deerhunter/arrow_fetch_0"..math.random(4)..".wav", 60, math.random(95, 105), 1, CHAN_BODY)
		end,
		[0.6] = function(self)
			self:EmitSound("weapons/bow_deerhunter/arrow_load_0"..math.random(3)..".wav", 60, math.random(95, 105), 1, CHAN_ITEM)
		end,
		[0.7] = function(self)
			self:EmitSound("weapons/bow_deerhunter/arrow_load_0"..math.random(3)..".wav", 60, math.random(95, 105), 1, CHAN_ITEM)
		end,
	},
	["Iron_Idle_Stretched_Relaxed"] = {
		[0.01] = function(self)
			self.DisableWalkBob = true
			self:EmitSound("weapons/bow_deerhunter/bow_pullback_0".. (math.random(2) == 2 and 3 or 1) ..".wav",55)
		end
	},
	["iron_to_idle"] = {
		[0.01] = function(self)
			self.DisableWalkBob = false
			--self:EmitSound("weapons/bow_deerhunter/bow_pullback_0".. (math.random(2) == 2 and 3 or 1) ..".wav")
		end
	}
}
function SWEP:SecondaryAttack()
	return
end

function SWEP:OwnerChanged()
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:PlayAnim(self:GetOwner():GetAmmoCount("Arrow") == 0 and "deploy_empty" or "deploy")
        self:SetHold(self.HoldType)
        timer.Simple(0,function() self.picked = true end)
    else
        timer.Simple(0,function() self.picked = nil end)
    end
end

function SWEP:OnRemove()
    if IsValid(self.worldModel) then
        self.worldModel:Remove()
    end
end
SWEP.Initialzed = false
function SWEP:Deploy()
	local owner = self:GetOwner()
    
	if SERVER and self.Initialzed and not owner.noSound then owner:EmitSound(self.DeploySnd, 65) end
	
	if not self.Initialzed then
		owner:SetAmmo((owner:GetAmmoCount("Arrow") or 0) + 1, "Arrow")
	end -- no nab

    self.Initialzed = true
    self:PlayAnim(owner:GetAmmoCount("Arrow") == 0 and "deploy_empty" or "deploy")
    self:SetHold(self.HoldType)

	return true
end

SWEP.AnimArHoldtypes = {
	Iron_Idle_Stretched_Relaxed = true,
	fire_iron = true,
	idle_to_iron = true
}

-- read if cute :3