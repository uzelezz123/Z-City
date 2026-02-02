--

local hook = hook

local PLAYER = FindMetaTable("Player")
function PLAYER:PlayCustomAnims(anim, autoStop, speed, autostopAdjust)
	self:SetNWString("hg_CustomAnim", anim)
	self:SetNWFloat("hg_CustomAnimDelay", speed or select(2, self:LookupSequence(anim)))
	self:SetNWFloat("hg_CustomAnimStartTime", CurTime())
	self:SetNWBool("hg_NeedAutoStop", autoStop)
	self:SetNWFloat("hg_AutoStopAdjust", autostopAdjust or 0)
	self:SetCycle(0)
	self:DoAnimationEvent(0)

	return select(2, self:LookupSequence(anim))
end

hook.Add("CalcMainActivity", "SLCAnim_Activity", function(ply, vel)
	local str = ply:GetNWString("hg_CustomAnim", "")
	local num = ply:GetNWFloat("hg_CustomAnimDelay")
	local st = ply:GetNWFloat("hg_CustomAnimStartTime")
	local needAutoStop = ply:GetNWBool("hg_NeedAutoStop", false)
	local autostopAdjust = ply:GetNWFloat("hg_AutoStopAdjust", 0)

	if str ~= nil and str ~= "" then
		ply:SetCycle((CurTime() - st) / num)

		return -1, ply:LookupSequence(str)
	end
end)