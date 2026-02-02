SWARM = {}
_SWARM_NEWDSP = _SWARM_NEWDSP or 0
_SWARM_NEWFR = _SWARM_NEWFR or false

SWARM_CV_BleedCD = GetConVar("swarm_bleedcd")
SWARM_CV_BleedDmg = GetConVar("swarm_bleeddmg")

function SWARM:Psych(time)
	SWARM_PsychEnd = CurTime() + time
end
net.Receive("SWARM(Psych)",function(len, plycaller)
	SWARM:Psych(net.ReadUInt(4))
end)

function SWARM:Knockout(time,aftertime)
	SWARM_KnockoutEnd = CurTime() + time
	SWARM_AfterKnockoutTime = aftertime
end
net.Receive("SWARM(Knockout)",function(len, plycaller)
	SWARM:Knockout(net.ReadFloat(),net.ReadUInt(4))
end)

function SWARM:ApplyBleed(time)
	SWARM_Bleed = (SWARM_Bleed or 0) + time
	SWARM_NextBleed = CurTime()+SWARM_CV_BleedCD:GetFloat()
end
net.Receive("SWARM(ApplyBleed)",function(len, plycaller)
	SWARM:ApplyBleed(net.ReadFloat())
end)

hook.Add("Think","SWARM",function()
	if(SWARM_PsychEnd)then
		_SWARM_IGNOREDSP = true
		LocalPlayer():SetDSP(math.Round(31,33),false)
		_SWARM_IGNOREDSP = nil
		
		if(SWARM_PsychEnd<=CurTime())then
			SWARM_PsychEnd = nil
			LocalPlayer():SetDSP(_SWARM_NEWDSP,_SWARM_NEWFR)
		end
	end
	
	if(SWARM_KnockoutEnd)then
		if(SWARM_KnockoutEnd<=CurTime())then
			SWARM_KnockoutEnd = nil
			SWARM_AfterKnockoutEnd = CurTime() + SWARM_AfterKnockoutTime
		end
	end
	if(SWARM_AfterKnockoutEnd and SWARM_AfterKnockoutEnd<=CurTime())then
		SWARM_AfterKnockoutEnd = nil
	end
end)

local PlayerMeta = FindMetaTable("Player")
SWARM_OLDFUNC_SetDSP = SWARM_OLDFUNC_SetDSP or PlayerMeta.SetDSP
function PlayerMeta:SetDSP(soundFilter,fastReset)
	if(!_SWARM_IGNOREDSP)then
		_SWARM_NEWDSP = soundFilter
		_SWARM_NEWFR = fastReset
	end
	SWARM_OLDFUNC_SetDSP(self,soundFilter,fastReset)
end

hook.Add("CalcMainActivity","Swarm",function(ply,vel)
	if(SWARM_KnockoutEnd)then
		return ACT_INVALID,ply:LookupSequence("seq_cower")
	end
end)

hook.Add("CreateMove","Swarm",function(cmd)
	if(SWARM_KnockoutEnd)then
		cmd:ClearMovement()
		cmd:SetMouseX(math.Clamp(cmd:GetMouseX(),-6,6))
	end
end)

local SWARM_tex_flora = Material("vgui/swarm/flora")
local SWARM_tex_blackout = Material("vgui/swarm/blackout")
SWARM_Lerp_Perc = 0
hook.Add("PostDrawHUD", "Swarm", function()
	-- local perc = LocalPlayer():GetNWInt("SwarmPercent")
	-- SWARM_Lerp_Perc = Lerp(FrameTime()*0.5,SWARM_Lerp_Perc,perc)
	
	-- if(SWARM_Lerp_Perc>1)then
		-- surface.SetDrawColor(255,255,255,SWARM_Lerp_Perc)
		-- surface.SetMaterial(SWARM_tex_flora)
		-- surface.DrawTexturedRect(0,0,ScrW(),ScrH())

		-- if(SWARM_Lerp_Perc>170)then
			-- surface.SetDrawColor(255,255,255,math.min((SWARM_Lerp_Perc-170)/20,1)*255)
			-- surface.SetMaterial(SWARM_tex_blackout)
			-- surface.DrawTexturedRect(0,0,ScrW(),ScrH())			
		-- end
	-- end
end )