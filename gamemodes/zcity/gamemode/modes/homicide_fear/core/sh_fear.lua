
local MODE = MODE

MODE.base = "hmcd"

MODE.PrintName = "Homicide2"
MODE.name = "fear"
MODE.Events = MODE.Events or {}
MODE.StartedEvents = MODE.StartedEvents or {}

function MODE:CreateTimer(name, delay, repetitions, func)
	self.saved.Timers = self.saved.Timers or {}

	if timer.Exists(name) then
		--print("Fear: Attempted to create an already existing timer: " .. name)
		return
	end

	timer.Create(name, delay, repetitions, func)

	self.saved.Timers[name] = true
end

function MODE:AddEvent(tEvent)
	MODE.Events[tEvent.Name] = tEvent
end

function MODE:StartEvent(name, ply)
	local userID = ply:UserID()

	if MODE.StartedEvents[userID] != nil and MODE.StartedEvents[userID].IsActive and MODE.StartedEvents[userID]:IsActive(ply) then return end
	
	MODE.StartedEvents[userID] = table.Copy(MODE.Events[name])
	MODE.StartedEvents[userID]:StartScare(ply)
	hook.Add("Think","ScareThatGuy"..userID,function()
		if not IsValid(ply) or not ply:Alive() then MODE:StopEvent(userID) return end
		MODE:DoEventThink(ply)
	end)
end

function MODE:DoEventThink(ply)
	local userID = ply:UserID()
	if MODE.StartedEvents[userID] and MODE.StartedEvents[userID].Think then
		MODE.StartedEvents[userID]:Think( ply )
	end
end

function MODE:StopEvent(userID)
	hook.Remove("Think","ScareThatGuy"..userID)
	MODE.StartedEvents[userID] = nil
end

function MODE:ShouldCollide(ent1, ent2)
	ent1 = ent1.ply or ent1
	if !IsValid(ent1) or !ent1:IsPlayer() then return end
	ent2 = ent2.ply or ent2
	if !IsValid(ent2) or !ent2:IsPlayer() then return end

	if ent1:GetNetVar("disappearance", nil) or ent2:GetNetVar("disappearance", nil) then
		return false
	end
end

-- function MODE:EntityEmitSound(tbl)
-- 	if CLIENT then
--     	if !lply:Alive() then return end
-- 	end

--     local ent = tbl.Entity
--     ent = ent.ply or ply

--     if !IsValid(ent) or !ent:IsPlayer() then return end
--     local bool = lply:GetNWBool("afterlife") or ent:GetNWBool("afterlife")
--     if !bool then return end

--     tbl.DSP = 59
--     tbl.SoundLevel = tbl.SoundLevel - 30
--     tbl.Volume = 0.1

--     return true
-- end