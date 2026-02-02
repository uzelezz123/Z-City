include("shared.lua")
ENT.PhysPos = Vector(0,0,0)
ENT.PhysAng = Angle(0,0,0)
local flpos,flang = Vector(4,-1,0),Angle(0,0,0)

local offsetVec,offsetAng = Vector(1,0,0),Angle(100,90,0)
local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local mat = Material("sprites/rollermine_shock")
local mat2 = Material("sprites/light_glow02_add_noz")
local mat3 = Material("effects/flashlight/soft")
local mat4 = Material("sprites/light_ignorez", "alphatest")
function ENT:Draw()
	self:DrawModel()

	if self:GetNetVar("enabled") then
		local view = render.GetViewSetup(true)
		local deg = self:GetAngles():Forward():Dot(view.angles:Forward())
		local chekvisible = util.TraceLine({
			start = self:GetPos() + self:GetAngles():Forward() * 6,
			endpos = view.origin,
			filter = {ply, self, LocalPlayer()},
			mask = MASK_VISIBLE
		})

		if deg < 0 and not chekvisible.Hit then
			render.SetMaterial(mat2)
			render.DrawSprite(self:GetPos() + self:GetAngles():Forward() * 6 + self:GetAngles():Right() * -0.5, 300 * math.min(deg, 0), 100 * math.min(deg, 0), color_white)
			render.DrawSprite(self:GetPos() + self:GetAngles():Forward() * 6 + self:GetAngles():Right() * -0.5, 100 * math.min(deg, 0), 200 * math.min(deg, 0), color_white)
		end
	end
end

function ENT:Think()
	if self:GetNetVar("enabled") then
		self.flashlight = self.flashlight or ProjectedTexture()
		if self.flashlight and self.flashlight:IsValid() then
			self.flashlight:SetTexture(mat3:GetTexture("$basetexture"))
			self.flashlight:SetFarZ(1500)
			self.flashlight:SetHorizontalFOV(50)
			self.flashlight:SetVerticalFOV(50)
			self.flashlight:SetConstantAttenuation(1)
			self.flashlight:SetLinearAttenuation(50)
			self.flashlight:SetPos(self:GetPos() + self:GetAngles():Forward() * 20)
			self.flashlight:SetAngles(self:GetAngles())
			self.flashlight:Update()
		end
	else
		if IsValid(self.flashlight) then
			self.flashlight:Remove()
		end
	end
end

function ENT:Initialize()
end

function ENT:OnRemove()
	if IsValid(self.flashlight) then
		self.flashlight:Remove()
	end
end