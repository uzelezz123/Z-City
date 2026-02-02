local fps = 1 / 24
local delay = 0
local math_min = math.min
local CurTime, FrameTime = CurTime, FrameTime
gasparticles_hook = gasparticles_hook or {}
local gasparticles_hook = gasparticles_hook
hook.Add("PostDrawOpaqueRenderables", "gasparticles", function()
	local time = CurTime()
	if not gasparticles_hook then return end
	if delay > time then
		local animpos = math_min((delay - time) / fps, 1)
		if not gasparticles_hook[1] then return end
		gasparticles_hook[1](animpos)
	else
		delay = time + fps
		if not gasparticles_hook[2] then return end
		gasparticles_hook[2](fps)
	end
end)