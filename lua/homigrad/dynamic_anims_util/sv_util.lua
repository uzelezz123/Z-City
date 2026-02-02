--

local PLAYER = FindMetaTable("Player")
function PLAYER:PlayCustomAnims(anim, autoStop, speed, needForceLook, autostopAdjust, tSvCallbacks)
	self:SetNWString("hg_CustomAnim", anim)
	self:SetNWFloat("hg_CustomAnimDelay", speed or select(2, self:LookupSequence(anim)))
	self:SetNWFloat("hg_CustomAnimStartTime", CurTime())
	self:SetNWBool("hg_NeedAutoStop", autoStop)
	self:SetNWFloat("hg_AutoStopAdjust", autostopAdjust or 0)
	self:SetCycle(0)
	self:DoAnimationEvent(0)

	self.CustomAnimCallbacks = tSvCallbacks or nil

    if needForceLook then
        local ang = self:EyeAngles()
        ang[1] = 0
        self:SetVelocity(ang:Forward() * 15)
    end

	return select(2, self:LookupSequence(anim))
end

hook.Add("PlayerDeath", "StopWhenDieCustomAnim", function(ply)
	ply:PlayCustomAnims("")
end)

hook.Add("CalcMainActivity", "CustomAnim_Activity", function(ply, vel)
	local str = ply:GetNWString("hg_CustomAnim", "")
	local num = ply:GetNWFloat("hg_CustomAnimDelay")
	local st = ply:GetNWFloat("hg_CustomAnimStartTime")
	local needAutoStop = ply:GetNWBool("hg_NeedAutoStop", false)
	local autostopAdjust = ply:GetNWFloat("hg_AutoStopAdjust", 0)

	if str ~= nil and str ~= "" then
		ply:SetCycle((CurTime() - st) / num)
		local timing = math.Truncate(math.Round( (CurTime() - st) / num, 3),2)
		ply.OldCustomAnimCallbackTime = ply.OldCustomAnimCallbackTime or timing
		if ply.CustomAnimCallbacks and ply.CustomAnimCallbacks[ timing ] and ply.OldCustomAnimCallbackTime != timing then
			ply.CustomAnimCallbacks[ timing ]( ply )
			ply.OldCustomAnimCallbackTime = timing
		end

		if needAutoStop and st + (num - autostopAdjust) < CurTime() then
			ply:PlayCustomAnims("")
		end

		return -1, ply:LookupSequence(str)
	end
end)