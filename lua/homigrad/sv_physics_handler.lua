local server_is_crashed = false

local physenv, RunConsoleCommand, game = physenv, RunConsoleCommand, game
local physenv_GetPhysicsPaused = physenv.GetPhysicsPaused

local func = function()
	local should_simulate = physenv_GetPhysicsPaused()

	if server_is_crashed
		or not should_simulate then
		return
	end

	server_is_crashed = true

	PrintMessage(HUD_PRINTTALK, "Physics are crashed, restart schedule created")

	timer.Create("PhysicsCrashedSchedule", 10, 1, function()
		engine.CloseServer()
		timer.Simple(0, function()
			RunConsoleCommand("changelevel", game.GetMap())
		end)
	end)
end

hook.Add("Tick", "vphysics_cathcer", func)

local CrazyPhysPerSec = 0
local CrazyPhysTime = 0
local CrazyPhysTrusthold = 500
hook.Add("OnCrazyPhysics", "stop_physics", function(ent, phys)
	if CrazyPhysTime < CurTime() then
		CrazyPhysTime = CurTime() + 1
	end
	CrazyPhysPerSec = CrazyPhysPerSec + 1

	if CrazyPhysTime > CurTime() and CrazyPhysPerSec > CrazyPhysTrusthold then
		physenv.SetPhysicsPaused(true)
	end
end)
