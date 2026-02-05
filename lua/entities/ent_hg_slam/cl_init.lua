include("shared.lua")

local laserMaterial = CreateMaterial("tripmine_laser", "UnlitGeneric", {
	["$basetexture"] = "sprites/laserbeam",
	["$additive"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
	["$nocull"] = "1",
	["$brightness"] = "64",
	["$textureScrollRate"] = "25.6",
})

function ENT:CreateLaserHook()
	self.HookAdded = true
	hook.Add("PostDrawOpaqueRenderables","SlamRender"..self:EntIndex(),function() -- a crutch cuz draw is not being called if entity is not in player view
		if not self.TraceStart or not self.TraceHitPos then return end

		render.SetMaterial(laserMaterial)
		render.DrawBeam(
			self.TraceStart,
			self.TraceHitPos,
			0.35,
			0,
			1,
			Color(255, 55, 52, 64)
		)
	end)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	hook.Remove("PostDrawOpaqueRenderables","SlaMRender"..self:EntIndex())
end