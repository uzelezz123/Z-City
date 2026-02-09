include("shared.lua")

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>Flashbang\n<colour=150,150,150>Why are you looking at a flashbang?</colour></font>",450)
end

function ENT:Draw()
	self:DrawModel()
end

local function IsLookingAt(ply, targetVec)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	local view = render.GetViewSetup(true)
	local diff = (view.origin - targetVec):GetNormalized()
	return view.angles:Forward():Dot(diff)
end

net.Receive("flashbang",function()
	local pos = net.ReadVector()
	 

	local time = math.Clamp(5200-(lply:GetPos():Distance(pos)), 1, 5)

	lply:AddTinnitus(time,true)

	local IsLookingFlash = IsLookingAt(lply, pos)
	local viewsetup = render.GetViewSetup(true)
	
	if IsLookingFlash < -0.5 then
		hg.AddFlash(viewsetup.origin,IsLookingFlash,pos,time*5,50000)
	end
	hook.Add("RenderScreenspaceEffects", "Flashed", function()
		if lply.tinnitus - CurTime() < 0 then lply.tinnitus = nil
			hook.Remove("RenderScreenspaceEffects", "Flashed")
			return
		end
		local flash = math.Clamp(lply.tinnitus - CurTime(), 0, 1)
		--lply:SetDSP(32) -- 36
	end)
end)